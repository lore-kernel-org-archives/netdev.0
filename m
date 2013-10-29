From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Tue, 29 Oct 2013 16:26:44 -0400
Message-ID: <20131029202644.GB32389@localhost.localdomain>
References: <20131028182913.GD31048@hmsreliant.think-freely.org>
 <20131029082542.GA24625@gmail.com>
 <20131029112022.GA24477@neilslaptop.think-freely.org>
 <20131029113031.GA16897@gmail.com>
 <20131029114907.GE24477@neilslaptop.think-freely.org>
 <20131029125233.GA17449@gmail.com>
 <20131029130712.GA25078@neilslaptop.think-freely.org>
 <20131029131149.GB20408@gmail.com>
 <20131029141706.GC25078@neilslaptop.think-freely.org>
 <20131029142716.GA28113@gmail.com>
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
In-Reply-To: <20131029142716.GA28113@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 03:27:16PM +0100, Ingo Molnar wrote:
> 
> * Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > So, I apologize, you were right.  I was running the test.sh script 
> > but perf was measuring itself. [...]
> 
> Ok, cool - one mystery less!
> 
> > Which overall looks alot more like I expect, save for the parallel 
> > ALU cases. It seems here that the parallel ALU changes actually 
> > hurt performance, which really seems counter-intuitive.  I don't 
> > yet have any explination for that.  I do note that we seem to have 
> > more stalls in the both case so perhaps the parallel chains call 
> > for a more agressive prefetch.  Do you have any thoughts?
> 
> Note that with -ddd you 'overload' the PMU with more counters than 
> can be run at once, which introduces extra noise. Since you are 
> running the tests for 0.150 secs or so, the results are not very 
> representative:
> 
>                734 dTLB-load-misses          #    0.00% of all dTLB cache hits   ( +-  8.40% ) [13.94%]
>         13,314,660 iTLB-loads                #  280.759 M/sec                    ( +-  0.05% ) [12.97%]
> 
> with such low runtimes those results are very hard to trust.
> 
> So -ddd is typically used to pick up the most interesting PMU events 
> you want to see measured, and then use them like this:
> 
>    -e dTLB-load-misses -e iTLB-loads
> 
> etc. For such short runtimes make sure the last column displays 
> close to 100%, so that the PMU results become trustable.
> 
> A nehalem+ PMU will allow 2-4 events to be measured in parallel, 
> plus generics like 'cycles', 'instructions' can be added 'for free' 
> because they get counted in a separate (fixed purpose) PMU register.
> 
> The last colum tells you what percentage of the runtime that 
> particular event was actually active. 100% (or empty last column) 
> means it was active all the time.
> 
> Thanks,
> 
> 	Ingo
> 

Hmm, 

I ran this test:

for i in `seq 0 1 3`
do
echo $i > /sys/module/csum_test/parameters/module_test_mode
taskset -c 0 perf stat --repeat 20 -C 0 -e L1-dcache-load-misses -e L1-dcache-prefetches -e cycles -e instructions -ddd ./test.sh
done

And I updated the test module to run for a million iterations rather than 100000 to increase the sample size and got this:


Base:
 Performance counter stats for './test.sh' (20 runs):

        47,305,064 L1-dcache-load-misses     #    2.09% of all L1-dcache hits    ( +-  0.04% ) [18.74%]
                 0 L1-dcache-prefetches                                         [18.75%]
    13,906,212,348 cycles                    #    0.000 GHz                      ( +-  0.05% ) [18.76%]
     4,426,395,949 instructions              #    0.32  insns per cycle          ( +-  0.01% ) [18.77%]
     2,261,551,278 L1-dcache-loads                                               ( +-  0.02% ) [18.76%]
        47,287,226 L1-dcache-load-misses     #    2.09% of all L1-dcache hits    ( +-  0.04% ) [18.76%]
       276,842,685 LLC-loads                                                     ( +-  0.01% ) [18.76%]
        46,454,114 LLC-load-misses           #   16.78% of all LL-cache hits     ( +-  0.05% ) [18.76%]
     1,048,894,486 L1-icache-loads                                               ( +-  0.07% ) [18.76%]
           472,205 L1-icache-load-misses     #    0.05% of all L1-icache hits    ( +-  1.19% ) [18.76%]
     2,260,639,613 dTLB-loads                                                    ( +-  0.01% ) [18.75%]
               172 dTLB-load-misses          #    0.00% of all dTLB cache hits   ( +- 35.14% ) [18.74%]
     1,048,732,481 iTLB-loads                                                    ( +-  0.07% ) [18.74%]
                19 iTLB-load-misses          #    0.00% of all iTLB cache hits   ( +- 39.75% ) [18.73%]
                 0 L1-dcache-prefetches                                         [18.73%]
                 0 L1-dcache-prefetch-misses                                    [18.73%]

       5.370546698 seconds time elapsed                                          ( +-  0.05% )


Prefetch:
 Performance counter stats for './test.sh' (20 runs):

       124,885,469 L1-dcache-load-misses     #    4.96% of all L1-dcache hits    ( +-  0.09% ) [18.74%]
                 0 L1-dcache-prefetches                                         [18.75%]
    11,434,328,889 cycles                    #    0.000 GHz                      ( +-  1.11% ) [18.77%]
     4,601,831,553 instructions              #    0.40  insns per cycle          ( +-  0.01% ) [18.77%]
     2,515,483,814 L1-dcache-loads                                               ( +-  0.01% ) [18.77%]
       124,928,127 L1-dcache-load-misses     #    4.97% of all L1-dcache hits    ( +-  0.09% ) [18.76%]
       323,355,145 LLC-loads                                                     ( +-  0.02% ) [18.76%]
       123,008,548 LLC-load-misses           #   38.04% of all LL-cache hits     ( +-  0.10% ) [18.75%]
     1,256,391,060 L1-icache-loads                                               ( +-  0.01% ) [18.75%]
           374,691 L1-icache-load-misses     #    0.03% of all L1-icache hits    ( +-  1.41% ) [18.75%]
     2,514,984,046 dTLB-loads                                                    ( +-  0.01% ) [18.75%]
                67 dTLB-load-misses          #    0.00% of all dTLB cache hits   ( +- 51.81% ) [18.74%]
     1,256,333,548 iTLB-loads                                                    ( +-  0.01% ) [18.74%]
                19 iTLB-load-misses          #    0.00% of all iTLB cache hits   ( +- 39.74% ) [18.74%]
                 0 L1-dcache-prefetches                                         [18.73%]
                 0 L1-dcache-prefetch-misses                                    [18.73%]

       4.496839773 seconds time elapsed                                          ( +-  0.64% )


Parallel ALU:
 Performance counter stats for './test.sh' (20 runs):

        49,489,518 L1-dcache-load-misses     #    2.19% of all L1-dcache hits    ( +-  0.09% ) [18.74%]
                 0 L1-dcache-prefetches                                         [18.76%]
    13,777,501,365 cycles                    #    0.000 GHz                      ( +-  1.73% ) [18.78%]
     4,707,160,703 instructions              #    0.34  insns per cycle          ( +-  0.01% ) [18.78%]
     2,261,693,074 L1-dcache-loads                                               ( +-  0.02% ) [18.78%]
        49,468,878 L1-dcache-load-misses     #    2.19% of all L1-dcache hits    ( +-  0.09% ) [18.77%]
       279,524,254 LLC-loads                                                     ( +-  0.01% ) [18.76%]
        48,491,934 LLC-load-misses           #   17.35% of all LL-cache hits     ( +-  0.12% ) [18.75%]
     1,057,877,680 L1-icache-loads                                               ( +-  0.02% ) [18.74%]
           461,784 L1-icache-load-misses     #    0.04% of all L1-icache hits    ( +-  1.87% ) [18.74%]
     2,260,978,836 dTLB-loads                                                    ( +-  0.02% ) [18.74%]
                27 dTLB-load-misses          #    0.00% of all dTLB cache hits   ( +- 89.96% ) [18.74%]
     1,057,886,632 iTLB-loads                                                    ( +-  0.02% ) [18.74%]
                 4 iTLB-load-misses          #    0.00% of all iTLB cache hits   ( +-100.00% ) [18.74%]
                 0 L1-dcache-prefetches                                         [18.73%]
                 0 L1-dcache-prefetch-misses                                    [18.73%]

       5.500417234 seconds time elapsed                                          ( +-  1.60% )


Both:
 Performance counter stats for './test.sh' (20 runs):

       116,621,570 L1-dcache-load-misses     #    4.68% of all L1-dcache hits    ( +-  0.04% ) [18.73%]
                 0 L1-dcache-prefetches                                         [18.75%]
    11,597,067,510 cycles                    #    0.000 GHz                      ( +-  1.73% ) [18.77%]
     4,952,251,361 instructions              #    0.43  insns per cycle          ( +-  0.01% ) [18.77%]
     2,493,003,710 L1-dcache-loads                                               ( +-  0.02% ) [18.77%]
       116,640,333 L1-dcache-load-misses     #    4.68% of all L1-dcache hits    ( +-  0.04% ) [18.77%]
       322,246,216 LLC-loads                                                     ( +-  0.03% ) [18.76%]
       114,528,956 LLC-load-misses           #   35.54% of all LL-cache hits     ( +-  0.04% ) [18.76%]
       999,371,469 L1-icache-loads                                               ( +-  0.02% ) [18.76%]
           406,679 L1-icache-load-misses     #    0.04% of all L1-icache hits    ( +-  1.97% ) [18.75%]
     2,492,708,710 dTLB-loads                                                    ( +-  0.01% ) [18.75%]
               140 dTLB-load-misses          #    0.00% of all dTLB cache hits   ( +- 38.46% ) [18.74%]
       999,320,389 iTLB-loads                                                    ( +-  0.01% ) [18.74%]
                19 iTLB-load-misses          #    0.00% of all iTLB cache hits   ( +- 39.90% ) [18.73%]
                 0 L1-dcache-prefetches                                         [18.73%]
                 0 L1-dcache-prefetch-misses                                    [18.72%]

       4.634419247 seconds time elapsed                                          ( +-  1.60% )


I note a few oddities here:

1) We seem to be getting more counter results than I specified, not sure why
2) The % active column is adding up to way more than 100 (which from my read of
the man page makes sense, given that multiple counters might increment in
response to a single instruction execution
3) The run times are proportionally larger, but still indicate that Parallel ALU
execution is hurting rather than helping, which is counter-intuitive.  I'm
looking into it, but thought you might want to see these results in case
something jumped out at you

Regards
Neil
