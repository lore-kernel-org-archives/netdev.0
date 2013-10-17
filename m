From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Thu, 17 Oct 2013 10:41:21 +0200
Message-ID: <20131017084121.GC22705@gmail.com>
References: <1381510298-20572-1-git-send-email-nhorman@tuxdriver.com>
 <20131012172124.GA18241@gmail.com>
 <20131014202854.GH26880@hmsreliant.think-freely.org>
 <1381785560.2045.11.camel@edumazet-glaptop.roam.corp.google.com>
 <1381789127.2045.22.camel@edumazet-glaptop.roam.corp.google.com>
 <20131017003421.GA31470@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131017003421.GA31470@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Neil Horman <nhorman@tuxdriver.com> wrote:

> On Mon, Oct 14, 2013 at 03:18:47PM -0700, Eric Dumazet wrote:
> > On Mon, 2013-10-14 at 14:19 -0700, Eric Dumazet wrote:
> > > On Mon, 2013-10-14 at 16:28 -0400, Neil Horman wrote:
> > > 
> > > > So, early testing results today.  I wrote a test module that, allocated a 4k
> > > > buffer, initalized it with random data, and called csum_partial on it 100000
> > > > times, recording the time at the start and end of that loop.  Results on a 2.4
> > > > GHz Intel Xeon processor:
> > > > 
> > > > Without patch: Average execute time for csum_partial was 808 ns
> > > > With patch: Average execute time for csum_partial was 438 ns
> > > 
> > > Impressive, but could you try again with data out of cache ?
> > 
> > So I tried your patch on a GRE tunnel and got following results on a
> > single TCP flow. (short result : no visible difference)
> > 
> > 
> 
> So I went to reproduce these results, but was unable to (due to the fact that I
> only have a pretty jittery network to do testing accross at the moment with
> these devices).  So instead I figured that I would go back to just doing
> measurements with the module that I cobbled together (operating under the
> assumption that it would give me accurate, relatively jitter free results (I've
> attached the module code for reference below).  My results show slightly
> different behavior:
> 
> Base results runs:
> 89417240
> 85170397
> 85208407
> 89422794
> 91645494
> 103655144
> 86063791
> 75647774
> 83502921
> 85847372
> AVG = 875 ns
>
> Prefetch only runs:
> 70962849
> 77555099
> 81898170
> 68249290
> 72636538
> 83039294
> 78561494
> 83393369
> 85317556
> 79570951
> AVG = 781 ns
> 
> Parallel addition only runs:
> 42024233
> 44313064
> 48304416
> 64762297
> 42994259
> 41811628
> 55654282
> 64892958
> 55125582
> 42456403
> AVG = 510 ns
> 
> 
> Both prefetch and parallel addition:
> 41329930
> 40689195
> 61106622
> 46332422
> 49398117
> 52525171
> 49517101
> 61311153
> 43691814
> 49043084
> AVG = 494 ns
> 
> 
> For reference, each of the above large numbers is the number of 
> nanoseconds taken to compute the checksum of a 4kb buffer 100000 times.  
> To get my average results, I ran the test in a loop 10 times, averaged 
> them, and divided by 100000.
> 
> Based on these, prefetching is obviously a a good improvement, but not 
> as good as parallel execution, and the winner by far is doing both.

But in the actual usecase mentioned the packet data was likely cache-cold, 
it just arrived in the NIC and an IRQ got sent. Your testcase uses a 
super-hot 4K buffer that fits into the L1 cache. So it's apples to 
oranges.

To correctly simulate the workload you'd have to:

 - allocate a buffer larger than your L2 cache.

 - to measure the effects of the prefetches you'd also have to randomize
   the individual buffer positions. See how 'perf bench numa' implements a
   random walk via --data_rand_walk, in tools/perf/bench/numa.c.
   Otherwise the CPU might learn your simplistic stream direction and the
   L2 cache might hw-prefetch your data, interfering with any explicit 
   prefetches the code does. In many real-life usecases packet buffers are
   scattered.

Also, it would be nice to see standard deviation noise numbers when two 
averages are close to each other, to be able to tell whether differences 
are statistically significant or not.

For example 'perf stat --repeat' will output stddev for you:

  comet:~/tip> perf stat --repeat 20 --null bash -c 'usleep $((RANDOM*10))'

   Performance counter stats for 'bash -c usleep $((RANDOM*10))' (20 runs):

       0.189084480 seconds time elapsed                                          ( +- 11.95% )

The last '+-' percentage is the noise of the measurement.

Also note that you can inspect many cache behavior details of your 
algorithm via perf stat - the -ddd option will give you a laundry list:

  aldebaran:~> perf stat --repeat 20 -ddd perf bench sched messaging
  ...

     Total time: 0.095 [sec]

 Performance counter stats for 'perf bench sched messaging' (20 runs):

       1519.128721 task-clock (msec)         #   12.305 CPUs utilized            ( +-  0.34% )
            22,882 context-switches          #    0.015 M/sec                    ( +-  2.84% )
             3,927 cpu-migrations            #    0.003 M/sec                    ( +-  2.74% )
            16,616 page-faults               #    0.011 M/sec                    ( +-  0.17% )
     2,327,978,366 cycles                    #    1.532 GHz                      ( +-  1.61% ) [36.43%]
     1,715,561,189 stalled-cycles-frontend   #   73.69% frontend cycles idle     ( +-  1.76% ) [38.05%]
       715,715,454 stalled-cycles-backend    #   30.74% backend  cycles idle     ( +-  2.25% ) [39.85%]
     1,253,106,346 instructions              #    0.54  insns per cycle        
                                             #    1.37  stalled cycles per insn  ( +-  1.71% ) [49.68%]
       241,181,126 branches                  #  158.763 M/sec                    ( +-  1.43% ) [47.83%]
         4,232,053 branch-misses             #    1.75% of all branches          ( +-  1.23% ) [48.63%]
       431,907,354 L1-dcache-loads           #  284.313 M/sec                    ( +-  1.00% ) [48.37%]
        20,550,528 L1-dcache-load-misses     #    4.76% of all L1-dcache hits    ( +-  0.82% ) [47.61%]
         7,435,847 LLC-loads                 #    4.895 M/sec                    ( +-  0.94% ) [36.11%]
         2,419,201 LLC-load-misses           #   32.53% of all LL-cache hits     ( +-  2.93% ) [ 7.33%]
       448,638,547 L1-icache-loads           #  295.326 M/sec                    ( +-  2.43% ) [21.75%]
        22,066,490 L1-icache-load-misses     #    4.92% of all L1-icache hits    ( +-  2.54% ) [30.66%]
       475,557,948 dTLB-loads                #  313.047 M/sec                    ( +-  1.96% ) [37.96%]
         6,741,523 dTLB-load-misses          #    1.42% of all dTLB cache hits   ( +-  2.38% ) [37.05%]
     1,268,628,660 iTLB-loads                #  835.103 M/sec                    ( +-  1.75% ) [36.45%]
            74,192 iTLB-load-misses          #    0.01% of all iTLB cache hits   ( +-  2.88% ) [36.19%]
         4,466,526 L1-dcache-prefetches      #    2.940 M/sec                    ( +-  1.61% ) [36.17%]
         2,396,311 L1-dcache-prefetch-misses #    1.577 M/sec                    ( +-  1.55% ) [35.71%]

       0.123459566 seconds time elapsed                                          ( +-  0.58% )

There's also a number of prefetch counters that might be useful:

 aldebaran:~> perf list | grep prefetch
  L1-dcache-prefetches                               [Hardware cache event]
  L1-dcache-prefetch-misses                          [Hardware cache event]
  LLC-prefetches                                     [Hardware cache event]
  LLC-prefetch-misses                                [Hardware cache event]
  node-prefetches                                    [Hardware cache event]
  node-prefetch-misses                               [Hardware cache event]

Thanks,

	Ingo
