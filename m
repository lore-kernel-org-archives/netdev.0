From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Mon, 28 Oct 2013 14:29:13 -0400
Message-ID: <20131028182913.GD31048@hmsreliant.think-freely.org>
References: <1381510298-20572-1-git-send-email-nhorman@tuxdriver.com>
 <20131012172124.GA18241@gmail.com>
 <20131014202854.GH26880@hmsreliant.think-freely.org>
 <1381785560.2045.11.camel@edumazet-glaptop.roam.corp.google.com>
 <1381789127.2045.22.camel@edumazet-glaptop.roam.corp.google.com>
 <20131017003421.GA31470@hmsreliant.think-freely.org>
 <20131017084121.GC22705@gmail.com>
 <20131028160131.GA31048@hmsreliant.think-freely.org>
 <20131028162438.GB14350@gmail.com>
 <20131028174630.GB31048@hmsreliant.think-freely.org>
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
In-Reply-To: <20131028174630.GB31048@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 28, 2013 at 01:46:30PM -0400, Neil Horman wrote:
> On Mon, Oct 28, 2013 at 05:24:38PM +0100, Ingo Molnar wrote:
> > 
> > * Neil Horman <nhorman@tuxdriver.com> wrote:
> > 
> > > Looking at the specific cpu counters we get this:
> > > 
> > > Base:
> > >      Total time: 0.179 [sec]
> > > 
> > >  Performance counter stats for 'perf bench sched messaging -- bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):
> > > 
> > >        1571.304618 task-clock                #    5.213 CPUs utilized            ( +-  0.45% )
> > >             14,423 context-switches          #    0.009 M/sec                    ( +-  4.28% )
> > >              2,710 cpu-migrations            #    0.002 M/sec                    ( +-  2.83% )
> > 
> > Hm, for these second round of measurements were you using 'perf stat 
> > -a -C ...'?
> > 
> > The most accurate method of measurement for such single-threaded 
> > workloads is something like:
> > 
> > 	taskset 0x1 perf stat -a -C 1 --repeat 20 ...
> > 
> > this will bind your workload to CPU#0, and will do PMU measurements 
> > only there - without mixing in other CPUs or workloads.
> > 
> > Thanks,
> > 
> > 	Ingo
> I wasn't, but I will...
> Neil
> 
> > --

Heres my data for running the same test with taskset restricting execution to
only cpu0.  I'm not quite sure whats going on here, but doing so resulted in a
10x slowdown of the runtime of each iteration which I can't explain.  As before
however, both the parallel alu run and the prefetch run resulted in speedups,
but the two together were not in any way addative.  I'm going to keep playing
with the prefetch stride, unless you have an alternate theory.

Regards
Neil


Base:
     Total time: 1.013 [sec]

 Performance counter stats for 'perf bench sched messaging -- bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       1140.286043 task-clock                #    1.001 CPUs utilized            ( +-  0.65% ) [100.00%]
            48,779 context-switches          #    0.043 M/sec                    ( +- 10.08% ) [100.00%]
                 0 cpu-migrations            #    0.000 K/sec                   [100.00%]
            75,398 page-faults               #    0.066 M/sec                    ( +-  0.05% )
     2,950,225,491 cycles                    #    2.587 GHz                      ( +-  0.65% ) [16.63%]
       263,349,439 stalled-cycles-frontend   #    8.93% frontend cycles idle     ( +-  1.87% ) [16.70%]
     1,615,723,017 stalled-cycles-backend    #   54.77% backend  cycles idle     ( +-  0.64% ) [16.76%]
     2,168,440,946 instructions              #    0.74  insns per cycle        
                                             #    0.75  stalled cycles per insn  ( +-  0.52% ) [16.76%]
       406,885,149 branches                  #  356.827 M/sec                    ( +-  0.61% ) [16.74%]
        10,099,789 branch-misses             #    2.48% of all branches          ( +-  0.73% ) [16.73%]
     1,138,829,982 L1-dcache-loads           #  998.723 M/sec                    ( +-  0.57% ) [16.71%]
        21,341,094 L1-dcache-load-misses     #    1.87% of all L1-dcache hits    ( +-  1.22% ) [16.69%]
        38,453,870 LLC-loads                 #   33.723 M/sec                    ( +-  1.46% ) [16.67%]
         9,587,987 LLC-load-misses           #   24.93% of all LL-cache hits     ( +-  0.48% ) [16.66%]
       566,241,820 L1-icache-loads           #  496.579 M/sec                    ( +-  0.70% ) [16.65%]
         9,061,979 L1-icache-load-misses     #    1.60% of all L1-icache hits    ( +-  3.39% ) [16.65%]
     1,130,620,555 dTLB-loads                #  991.524 M/sec                    ( +-  0.64% ) [16.64%]
           423,302 dTLB-load-misses          #    0.04% of all dTLB cache hits   ( +-  4.89% ) [16.63%]
       563,371,089 iTLB-loads                #  494.061 M/sec                    ( +-  0.62% ) [16.62%]
           215,406 iTLB-load-misses          #    0.04% of all iTLB cache hits   ( +-  6.97% ) [16.60%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [16.59%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [16.58%]

       1.139598762 seconds time elapsed                                          ( +-  0.65% )

Prefetch:
     Total time: 0.981 [sec]

 Performance counter stats for 'perf bench sched messaging -- bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       1128.603117 task-clock                #    1.001 CPUs utilized            ( +-  0.66% ) [100.00%]
            45,992 context-switches          #    0.041 M/sec                    ( +-  9.47% ) [100.00%]
                 0 cpu-migrations            #    0.000 K/sec                   [100.00%]
            75,428 page-faults               #    0.067 M/sec                    ( +-  0.06% )
     2,920,666,228 cycles                    #    2.588 GHz                      ( +-  0.66% ) [16.59%]
       255,998,006 stalled-cycles-frontend   #    8.77% frontend cycles idle     ( +-  1.78% ) [16.67%]
     1,601,090,475 stalled-cycles-backend    #   54.82% backend  cycles idle     ( +-  0.69% ) [16.75%]
     2,164,301,312 instructions              #    0.74  insns per cycle        
                                             #    0.74  stalled cycles per insn  ( +-  0.59% ) [16.78%]
       404,920,928 branches                  #  358.781 M/sec                    ( +-  0.54% ) [16.77%]
        10,025,146 branch-misses             #    2.48% of all branches          ( +-  0.66% ) [16.75%]
     1,133,764,674 L1-dcache-loads           # 1004.573 M/sec                    ( +-  0.47% ) [16.74%]
        21,251,432 L1-dcache-load-misses     #    1.87% of all L1-dcache hits    ( +-  1.01% ) [16.72%]
        38,006,432 LLC-loads                 #   33.676 M/sec                    ( +-  1.56% ) [16.70%]
         9,625,034 LLC-load-misses           #   25.32% of all LL-cache hits     ( +-  0.40% ) [16.68%]
       565,712,289 L1-icache-loads           #  501.250 M/sec                    ( +-  0.57% ) [16.66%]
         8,726,826 L1-icache-load-misses     #    1.54% of all L1-icache hits    ( +-  3.40% ) [16.64%]
     1,130,140,463 dTLB-loads                # 1001.362 M/sec                    ( +-  0.53% ) [16.63%]
           419,645 dTLB-load-misses          #    0.04% of all dTLB cache hits   ( +-  4.44% ) [16.62%]
       560,199,307 iTLB-loads                #  496.365 M/sec                    ( +-  0.51% ) [16.61%]
           213,413 iTLB-load-misses          #    0.04% of all iTLB cache hits   ( +-  6.65% ) [16.59%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [16.56%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [16.54%]

       1.127934534 seconds time elapsed                                          ( +-  0.66% )


Parallel ALU:
     Total time: 0.986 [sec]

 Performance counter stats for 'perf bench sched messaging -- bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       1131.914738 task-clock                #    1.001 CPUs utilized            ( +-  0.49% ) [100.00%]
            40,807 context-switches          #    0.036 M/sec                    ( +- 10.72% ) [100.00%]
                 0 cpu-migrations            #    0.000 K/sec                    ( +-100.00% ) [100.00%]
            75,329 page-faults               #    0.067 M/sec                    ( +-  0.04% )
     2,929,149,996 cycles                    #    2.588 GHz                      ( +-  0.49% ) [16.58%]
       250,428,558 stalled-cycles-frontend   #    8.55% frontend cycles idle     ( +-  1.75% ) [16.66%]
     1,621,074,968 stalled-cycles-backend    #   55.34% backend  cycles idle     ( +-  0.46% ) [16.73%]
     2,147,405,781 instructions              #    0.73  insns per cycle        
                                             #    0.75  stalled cycles per insn  ( +-  0.56% ) [16.77%]
       401,196,771 branches                  #  354.441 M/sec                    ( +-  0.58% ) [16.76%]
         9,941,701 branch-misses             #    2.48% of all branches          ( +-  0.67% ) [16.74%]
     1,126,651,774 L1-dcache-loads           #  995.350 M/sec                    ( +-  0.50% ) [16.73%]
        21,075,294 L1-dcache-load-misses     #    1.87% of all L1-dcache hits    ( +-  0.96% ) [16.72%]
        37,885,850 LLC-loads                 #   33.471 M/sec                    ( +-  1.10% ) [16.71%]
         9,729,116 LLC-load-misses           #   25.68% of all LL-cache hits     ( +-  0.62% ) [16.69%]
       562,058,495 L1-icache-loads           #  496.556 M/sec                    ( +-  0.54% ) [16.67%]
         8,617,450 L1-icache-load-misses     #    1.53% of all L1-icache hits    ( +-  3.06% ) [16.65%]
     1,121,765,737 dTLB-loads                #  991.034 M/sec                    ( +-  0.57% ) [16.63%]
           388,875 dTLB-load-misses          #    0.03% of all dTLB cache hits   ( +-  4.27% ) [16.62%]
       556,029,393 iTLB-loads                #  491.229 M/sec                    ( +-  0.64% ) [16.61%]
           189,181 iTLB-load-misses          #    0.03% of all iTLB cache hits   ( +-  6.98% ) [16.60%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [16.58%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [16.56%]

       1.131247174 seconds time elapsed                                          ( +-  0.49% )


Both:
     Total time: 0.993 [sec]

 Performance counter stats for 'perf bench sched messaging -- bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       1130.912197 task-clock                #    1.001 CPUs utilized            ( +-  0.60% ) [100.00%]
            45,859 context-switches          #    0.041 M/sec                    ( +-  9.00% ) [100.00%]
                 0 cpu-migrations            #    0.000 K/sec                   [100.00%]
            75,398 page-faults               #    0.067 M/sec                    ( +-  0.07% )
     2,926,527,048 cycles                    #    2.588 GHz                      ( +-  0.60% ) [16.60%]
       255,482,254 stalled-cycles-frontend   #    8.73% frontend cycles idle     ( +-  1.62% ) [16.67%]
     1,608,247,364 stalled-cycles-backend    #   54.95% backend  cycles idle     ( +-  0.73% ) [16.74%]
     2,162,135,903 instructions              #    0.74  insns per cycle        
                                             #    0.74  stalled cycles per insn  ( +-  0.46% ) [16.77%]
       403,436,790 branches                  #  356.736 M/sec                    ( +-  0.44% ) [16.76%]
        10,062,572 branch-misses             #    2.49% of all branches          ( +-  0.85% ) [16.75%]
     1,133,889,264 L1-dcache-loads           # 1002.632 M/sec                    ( +-  0.56% ) [16.74%]
        21,460,116 L1-dcache-load-misses     #    1.89% of all L1-dcache hits    ( +-  1.31% ) [16.73%]
        38,070,119 LLC-loads                 #   33.663 M/sec                    ( +-  1.63% ) [16.72%]
         9,593,162 LLC-load-misses           #   25.20% of all LL-cache hits     ( +-  0.42% ) [16.71%]
       562,867,188 L1-icache-loads           #  497.711 M/sec                    ( +-  0.59% ) [16.68%]
         8,472,343 L1-icache-load-misses     #    1.51% of all L1-icache hits    ( +-  3.02% ) [16.64%]
     1,126,997,403 dTLB-loads                #  996.538 M/sec                    ( +-  0.53% ) [16.61%]
           414,900 dTLB-load-misses          #    0.04% of all dTLB cache hits   ( +-  4.12% ) [16.60%]
       561,156,032 iTLB-loads                #  496.198 M/sec                    ( +-  0.56% ) [16.59%]
           212,482 iTLB-load-misses          #    0.04% of all iTLB cache hits   ( +-  6.10% ) [16.58%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [16.57%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [16.56%]

       1.130242195 seconds time elapsed                                          ( +-  0.60% )

> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
