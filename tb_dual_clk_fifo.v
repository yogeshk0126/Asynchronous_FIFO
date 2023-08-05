`timescale 1ns/1ps

module tb_dual_clk_fifo;

    // Parameters for the FIFO
    localparam DSIZE = 8;
    localparam ASIZE = 4;
    localparam MEMDEPTH = 1 << ASIZE;

    // Inputs
    reg [DSIZE-1:0] wdata;
    reg winc, wclk, wrst_n;
    reg rinc, rclk, rrst_n;

    // Outputs
    wire [DSIZE-1:0] rdata;
    wire wfull, rempty;

    // Instantiate the dual_clk_fifo module
    dual_clk_fifo inst (
        .rdata(rdata),
        .wfull(wfull),
        .rempty(rempty),
        .wdata(wdata),
        .winc(winc),
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rinc(rinc),
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    // Clock generators
    always #5 wclk = ~wclk;
    always #10 rclk = ~rclk;

    // Random number generator for write data
    reg [DSIZE-1:0] rand_data = 0;
    initial begin
        repeat (100) begin
            #($urandom_range(5, 50));
            rand_data = $urandom;
        end
    end

    // Testbench stimulus
    initial begin
        $dumpfile("tb_dual_clk_fifo.vcd");
        $dumpvars(0, tb_dual_clk_fifo);

        // Initialize the FIFO
        wrst_n = 0;
        rrst_n = 0;
        wclk = 0;
        rclk = 0;
        winc = 0;
        rinc = 0;
        wdata = 0;

        #20 wrst_n = 1;
        #20 rrst_n = 1;

        // Case 1: Write and read random data
        repeat (100) begin
            #10;
            wdata = rand_data;
            winc = 1;
            #10;
            winc = 0;
            rinc = 1;
            #10;
            rinc = 0;
        end

        // Case 2: Test for empty and full conditions
        repeat (10) begin
            #10;
            if (!rempty)
                rinc = 1;
            else
                rinc = 0;

            if (!wfull) begin
                wdata = rand_data;
                winc = 1;
            end else
                winc = 0;

            #10;
            rinc = 0;
            winc = 0;
        end

        // Case 3: Write and read multiple times
        repeat (10) begin
            #10;
            wdata = 8'b10101010;
            winc = 1;
            #10;
            wdata = 8'b11001100;
            #10;
            wdata = 8'b00110011;
            #10;
            winc = 0;
            rinc = 1;
            #10;
            rinc = 0;
        end

        // Add more test cases as needed

        $finish;
    end

endmodule
