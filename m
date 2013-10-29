From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Tue, 29 Oct 2013 10:17:06 -0400
Message-ID: <20131029141706.GC25078@neilslaptop.think-freely.org>
References: <20131028162438.GB14350@gmail.com>
 <20131028174630.GB31048@hmsreliant.think-freely.org>
 <20131028182913.GD31048@hmsreliant.think-freely.org>
 <20131029082542.GA24625@gmail.com>
 <20131029112022.GA24477@neilslaptop.think-freely.org>
 <20131029113031.GA16897@gmail.com>
 <20131029114907.GE24477@neilslaptop.think-freely.org>
 <20131029125233.GA17449@gmail.com>
 <20131029130712.GA25078@neilslaptop.think-freely.org>
 <20131029131149.GB20408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131029131149.GB20408@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 02:11:49PM +0100, Ingo Molnar wrote:
> 
> * Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > I'm sure it worked properly on my system here, I specificially 
> > checked it, but I'll gladly run it again.  You have to give me an 
> > hour as I have a meeting to run to, but I'll have results shortly.
> 
> So what I tried to react to was this observation of yours:
> 
> > > > Heres my data for running the same test with taskset 
> > > > restricting execution to only cpu0.  I'm not quite sure whats 
> > > > going on here, but doing so resulted in a 10x slowdown of the 
> > > > runtime of each iteration which I can't explain. [...]
> 
> A 10x slowdown would be consistent with not running your testcase 
> but 'perf bench sched messaging' by accident, or so.
> 
> But I was really just guessing wildly here.
> 
> Thanks,
> 
> 	Ingo
> 


So, I apologize, you were right.  I was running the test.sh script but perf was
measuring itself.  Using this command line:

for i in `seq 0 1 3`
do
echo $i > /sys/modules/csum_test/parameters/module_test_mode; taskset -c 0 perf stat --repeat -C 0 -ddd /root/test.sh
done >> counters.txt 2>&1

with test.sh unchanged I get these results:


Base:
 Performance counter stats for '/root/test.sh' (20 runs):

         56.069737 task-clock                #    1.005 CPUs utilized            ( +-  0.13% ) [100.00%]
                 5 context-switches          #    0.091 K/sec                    ( +-  5.11% ) [100.00%]
                 0 cpu-migrations            #    0.000 K/sec                   [100.00%]
               366 page-faults               #    0.007 M/sec                    ( +-  0.08% )
       144,264,737 cycles                    #    2.573 GHz                      ( +-  0.23% ) [17.49%]
         9,239,760 stalled-cycles-frontend   #    6.40% frontend cycles idle     ( +-  3.77% ) [19.19%]
       110,635,829 stalled-cycles-backend    #   76.69% backend  cycles idle     ( +-  0.14% ) [19.68%]
        54,291,496 instructions              #    0.38  insns per cycle        
                                             #    2.04  stalled cycles per insn  ( +-  0.14% ) [18.30%]
         5,844,933 branches                  #  104.244 M/sec                    ( +-  2.81% ) [16.58%]
           301,523 branch-misses             #    5.16% of all branches          ( +-  0.12% ) [16.09%]
        23,645,797 L1-dcache-loads           #  421.721 M/sec                    ( +-  0.05% ) [16.06%]
           494,467 L1-dcache-load-misses     #    2.09% of all L1-dcache hits    ( +-  0.06% ) [16.06%]
         2,907,250 LLC-loads                 #   51.851 M/sec                    ( +-  0.08% ) [16.06%]
           486,329 LLC-load-misses           #   16.73% of all LL-cache hits     ( +-  0.11% ) [16.06%]
        11,113,848 L1-icache-loads           #  198.215 M/sec                    ( +-  0.07% ) [16.06%]
             5,378 L1-icache-load-misses     #    0.05% of all L1-icache hits    ( +-  1.34% ) [16.06%]
        23,742,876 dTLB-loads                #  423.453 M/sec                    ( +-  0.06% ) [16.06%]
                 0 dTLB-load-misses          #    0.00% of all dTLB cache hits  [16.06%]
        11,108,538 iTLB-loads                #  198.120 M/sec                    ( +-  0.06% ) [16.06%]
                 0 iTLB-load-misses          #    0.00% of all iTLB cache hits  [16.07%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [16.07%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [16.07%]

       0.055817066 seconds time elapsed                                          ( +-  0.10% )

Prefetch(5*64):
 Performance counter stats for '/root/test.sh' (20 runs):

         47.423853 task-clock                #    1.005 CPUs utilized            ( +-  0.62% ) [100.00%]
                 6 context-switches          #    0.116 K/sec                    ( +-  4.27% ) [100.00%]
                 0 cpu-migrations            #    0.000 K/sec                   [100.00%]
               368 page-faults               #    0.008 M/sec                    ( +-  0.07% )
       120,423,860 cycles                    #    2.539 GHz                      ( +-  0.85% ) [14.23%]
         8,555,632 stalled-cycles-frontend   #    7.10% frontend cycles idle     ( +-  0.56% ) [16.23%]
        87,438,794 stalled-cycles-backend    #   72.61% backend  cycles idle     ( +-  1.13% ) [18.33%]
        55,039,308 instructions              #    0.46  insns per cycle        
                                             #    1.59  stalled cycles per insn  ( +-  0.05% ) [18.98%]
         5,619,298 branches                  #  118.491 M/sec                    ( +-  2.32% ) [18.98%]
           303,686 branch-misses             #    5.40% of all branches          ( +-  0.08% ) [18.98%]
        26,577,868 L1-dcache-loads           #  560.432 M/sec                    ( +-  0.05% ) [18.98%]
         1,323,630 L1-dcache-load-misses     #    4.98% of all L1-dcache hits    ( +-  0.14% ) [18.98%]
         3,426,016 LLC-loads                 #   72.242 M/sec                    ( +-  0.05% ) [18.98%]
         1,304,201 LLC-load-misses           #   38.07% of all LL-cache hits     ( +-  0.13% ) [18.98%]
        13,190,316 L1-icache-loads           #  278.137 M/sec                    ( +-  0.21% ) [18.98%]
            33,881 L1-icache-load-misses     #    0.26% of all L1-icache hits    ( +-  4.63% ) [17.93%]
        25,366,685 dTLB-loads                #  534.893 M/sec                    ( +-  0.24% ) [15.93%]
               734 dTLB-load-misses          #    0.00% of all dTLB cache hits   ( +-  8.40% ) [13.94%]
        13,314,660 iTLB-loads                #  280.759 M/sec                    ( +-  0.05% ) [12.97%]
                 0 iTLB-load-misses          #    0.00% of all iTLB cache hits  [12.98%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [12.98%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [12.87%]

       0.047194407 seconds time elapsed                                          ( +-  0.62% )

Parallel ALU:
 Performance counter stats for '/root/test.sh' (20 runs):

         57.395070 task-clock                #    1.004 CPUs utilized            ( +-  1.71% ) [100.00%]
                 5 context-switches          #    0.092 K/sec                    ( +-  3.90% ) [100.00%]
                 0 cpu-migrations            #    0.000 K/sec                   [100.00%]
               367 page-faults               #    0.006 M/sec                    ( +-  0.10% )
       143,232,396 cycles                    #    2.496 GHz                      ( +-  1.68% ) [16.73%]
         7,299,843 stalled-cycles-frontend   #    5.10% frontend cycles idle     ( +-  2.69% ) [18.47%]
       109,485,845 stalled-cycles-backend    #   76.44% backend  cycles idle     ( +-  2.01% ) [19.99%]
        56,867,669 instructions              #    0.40  insns per cycle        
                                             #    1.93  stalled cycles per insn  ( +-  0.22% ) [19.49%]
         6,646,323 branches                  #  115.800 M/sec                    ( +-  2.15% ) [17.75%]
           304,671 branch-misses             #    4.58% of all branches          ( +-  0.37% ) [16.23%]
        23,612,428 L1-dcache-loads           #  411.402 M/sec                    ( +-  0.05% ) [15.95%]
           518,988 L1-dcache-load-misses     #    2.20% of all L1-dcache hits    ( +-  0.11% ) [15.95%]
         2,934,119 LLC-loads                 #   51.121 M/sec                    ( +-  0.06% ) [15.95%]
           509,027 LLC-load-misses           #   17.35% of all LL-cache hits     ( +-  0.15% ) [15.95%]
        11,103,819 L1-icache-loads           #  193.463 M/sec                    ( +-  0.08% ) [15.95%]
             5,381 L1-icache-load-misses     #    0.05% of all L1-icache hits    ( +-  2.45% ) [15.95%]
        23,727,164 dTLB-loads                #  413.401 M/sec                    ( +-  0.06% ) [15.95%]
                 0 dTLB-load-misses          #    0.00% of all dTLB cache hits  [15.95%]
        11,104,205 iTLB-loads                #  193.470 M/sec                    ( +-  0.06% ) [15.95%]
                 0 iTLB-load-misses          #    0.00% of all iTLB cache hits  [15.95%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [15.95%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [15.96%]

       0.057151644 seconds time elapsed                                          ( +-  1.69% )

Both:
 Performance counter stats for '/root/test.sh' (20 runs):

         48.377833 task-clock                #    1.005 CPUs utilized            ( +-  0.67% ) [100.00%]
                 5 context-switches          #    0.113 K/sec                    ( +-  3.88% ) [100.00%]
                 0 cpu-migrations            #    0.001 K/sec                    ( +-100.00% ) [100.00%]
               367 page-faults               #    0.008 M/sec                    ( +-  0.08% )
       122,529,490 cycles                    #    2.533 GHz                      ( +-  1.05% ) [14.24%]
         8,796,729 stalled-cycles-frontend   #    7.18% frontend cycles idle     ( +-  0.56% ) [16.20%]
        88,936,550 stalled-cycles-backend    #   72.58% backend  cycles idle     ( +-  1.48% ) [18.16%]
        58,405,660 instructions              #    0.48  insns per cycle        
                                             #    1.52  stalled cycles per insn  ( +-  0.07% ) [18.61%]
         5,742,738 branches                  #  118.706 M/sec                    ( +-  1.54% ) [18.61%]
           303,555 branch-misses             #    5.29% of all branches          ( +-  0.09% ) [18.61%]
        26,321,789 L1-dcache-loads           #  544.088 M/sec                    ( +-  0.07% ) [18.61%]
         1,236,101 L1-dcache-load-misses     #    4.70% of all L1-dcache hits    ( +-  0.08% ) [18.61%]
         3,409,768 LLC-loads                 #   70.482 M/sec                    ( +-  0.05% ) [18.61%]
         1,212,511 LLC-load-misses           #   35.56% of all LL-cache hits     ( +-  0.08% ) [18.61%]
        10,579,372 L1-icache-loads           #  218.682 M/sec                    ( +-  0.05% ) [18.61%]
            19,426 L1-icache-load-misses     #    0.18% of all L1-icache hits    ( +- 14.70% ) [18.61%]
        25,329,963 dTLB-loads                #  523.586 M/sec                    ( +-  0.27% ) [17.29%]
               802 dTLB-load-misses          #    0.00% of all dTLB cache hits   ( +-  5.43% ) [15.33%]
        10,635,524 iTLB-loads                #  219.843 M/sec                    ( +-  0.09% ) [13.38%]
                 0 iTLB-load-misses          #    0.00% of all iTLB cache hits  [12.72%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [12.72%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [12.72%]

       0.048140073 seconds time elapsed                                          ( +-  0.67% )


Which overall looks alot more like I expect, save for the parallel ALU cases.
It seems here that the parallel ALU changes actually hurt performance, which
really seems counter-intuitive.  I don't yet have any explination for that.  I
do note that we seem to have more stalls in the both case so perhaps the
parallel chains call for a more agressive prefetch.  Do you have any thoughts?

Regards
Neil
