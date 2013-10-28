From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Mon, 28 Oct 2013 12:01:32 -0400
Message-ID: <20131028160131.GA31048@hmsreliant.think-freely.org>
References: <1381510298-20572-1-git-send-email-nhorman@tuxdriver.com>
 <20131012172124.GA18241@gmail.com>
 <20131014202854.GH26880@hmsreliant.think-freely.org>
 <1381785560.2045.11.camel@edumazet-glaptop.roam.corp.google.com>
 <1381789127.2045.22.camel@edumazet-glaptop.roam.corp.google.com>
 <20131017003421.GA31470@hmsreliant.think-freely.org>
 <20131017084121.GC22705@gmail.com>
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
In-Reply-To: <20131017084121.GC22705@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Ingo, et al.-
	Ok, sorry for the delay, here are the test results you've been asking
for.


First, some information about what I did.  I attached the module that I ran this
test with at the bottom of this email.  You'll note that I started using a
module parameter write patch to trigger the csum rather than the module load
path.  The latter seemed to be giving me lots of variance in my run times, which
I wanted to eliminate.  I attributed it to the module load mechanism itself, and
by using the parameter write path, I was able to get more consistent results.

First, the run time tests:

I ran this command:
for i in `seq 0 1 3`
do
	 echo $i > /sys/module/csum_test/parameters/module_test_mode
	 perf stat --repeat 20 --null echo 1 > echo 1 > /sys/module/csum_test/parameters/test_fire
done

The for loop allows me to chagne the module_test_mode, which is tied to a switch
statement in do_csum that selects which checksumming method we use
(base/prefetch/parallel alu/both).  The results are:


Base:
 Performance counter stats for 'bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       0.093269042 seconds time elapsed                                          ( +-  2.24% )

Prefetch (5x64):
 Performance counter stats for 'bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       0.079440009 seconds time elapsed                                          ( +-  2.29% )

Parallel ALU:
 Performance counter stats for 'bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       0.087666677 seconds time elapsed                                          ( +-  4.01% )

Prefetch + Parallel ALU:
 Performance counter stats for 'bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       0.080758702 seconds time elapsed                                          ( +-  2.34% )

So we can see here that we get about a 1% speedup between the base and the both
(Prefetch + Parallel ALU) case, with prefetch accounting for most of that
speedup.

Looking at the specific cpu counters we get this:


Base:
     Total time: 0.179 [sec]

 Performance counter stats for 'perf bench sched messaging -- bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       1571.304618 task-clock                #    5.213 CPUs utilized            ( +-  0.45% )
            14,423 context-switches          #    0.009 M/sec                    ( +-  4.28% )
             2,710 cpu-migrations            #    0.002 M/sec                    ( +-  2.83% )
            75,402 page-faults               #    0.048 M/sec                    ( +-  0.07% )
     1,597,349,326 cycles                    #    1.017 GHz                      ( +-  1.74% ) [40.51%]
       104,882,858 stalled-cycles-frontend   #    6.57% frontend cycles idle     ( +-  1.25% ) [40.33%]
     1,043,429,984 stalled-cycles-backend    #   65.32% backend  cycles idle     ( +-  1.25% ) [39.73%]
       868,372,132 instructions              #    0.54  insns per cycle        
                                             #    1.20  stalled cycles per insn  ( +-  1.43% ) [39.88%]
       161,143,820 branches                  #  102.554 M/sec                    ( +-  1.49% ) [39.76%]
         4,348,075 branch-misses             #    2.70% of all branches          ( +-  1.43% ) [39.99%]
       457,042,576 L1-dcache-loads           #  290.868 M/sec                    ( +-  1.25% ) [40.63%]
         8,928,240 L1-dcache-load-misses     #    1.95% of all L1-dcache hits    ( +-  1.26% ) [41.17%]
        15,821,051 LLC-loads                 #   10.069 M/sec                    ( +-  1.56% ) [41.20%]
         4,902,576 LLC-load-misses           #   30.99% of all LL-cache hits     ( +-  1.51% ) [41.36%]
       235,775,688 L1-icache-loads           #  150.051 M/sec                    ( +-  1.39% ) [41.10%]
         3,116,106 L1-icache-load-misses     #    1.32% of all L1-icache hits    ( +-  3.43% ) [40.96%]
       461,315,416 dTLB-loads                #  293.588 M/sec                    ( +-  1.43% ) [41.18%]
           140,280 dTLB-load-misses          #    0.03% of all dTLB cache hits   ( +-  2.30% ) [40.96%]
       236,127,031 iTLB-loads                #  150.275 M/sec                    ( +-  1.63% ) [41.43%]
            46,173 iTLB-load-misses          #    0.02% of all iTLB cache hits   ( +-  3.40% ) [41.11%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [40.82%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [40.37%]

       0.301414024 seconds time elapsed                                          ( +-  0.47% )

Prefetch (5x64):
     Total time: 0.172 [sec]

 Performance counter stats for 'perf bench sched messaging -- bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       1565.797128 task-clock                #    5.238 CPUs utilized            ( +-  0.46% )
            13,845 context-switches          #    0.009 M/sec                    ( +-  4.20% )
             2,624 cpu-migrations            #    0.002 M/sec                    ( +-  2.72% )
            75,452 page-faults               #    0.048 M/sec                    ( +-  0.08% )
     1,642,106,355 cycles                    #    1.049 GHz                      ( +-  1.33% ) [40.17%]
       107,786,666 stalled-cycles-frontend   #    6.56% frontend cycles idle     ( +-  1.37% ) [39.90%]
     1,065,286,880 stalled-cycles-backend    #   64.87% backend  cycles idle     ( +-  1.59% ) [39.14%]
       888,815,001 instructions              #    0.54  insns per cycle        
                                             #    1.20  stalled cycles per insn  ( +-  1.29% ) [38.92%]
       163,106,907 branches                  #  104.169 M/sec                    ( +-  1.32% ) [38.93%]
         4,333,456 branch-misses             #    2.66% of all branches          ( +-  1.94% ) [39.77%]
       459,779,806 L1-dcache-loads           #  293.639 M/sec                    ( +-  1.60% ) [40.23%]
         8,827,680 L1-dcache-load-misses     #    1.92% of all L1-dcache hits    ( +-  1.77% ) [41.38%]
        15,556,816 LLC-loads                 #    9.935 M/sec                    ( +-  1.76% ) [41.16%]
         4,885,618 LLC-load-misses           #   31.40% of all LL-cache hits     ( +-  1.40% ) [40.84%]
       236,131,778 L1-icache-loads           #  150.806 M/sec                    ( +-  1.32% ) [40.59%]
         3,037,537 L1-icache-load-misses     #    1.29% of all L1-icache hits    ( +-  2.23% ) [41.13%]
       454,835,028 dTLB-loads                #  290.481 M/sec                    ( +-  1.23% ) [41.34%]
           139,907 dTLB-load-misses          #    0.03% of all dTLB cache hits   ( +-  2.18% ) [41.21%]
       236,357,655 iTLB-loads                #  150.950 M/sec                    ( +-  1.31% ) [41.29%]
            46,633 iTLB-load-misses          #    0.02% of all iTLB cache hits   ( +-  2.74% ) [40.67%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [40.16%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [40.09%]

       0.298948767 seconds time elapsed                                          ( +-  0.36% )

Here it appears everything between the two runs is about the same.  We reduced
the number of dcache misses by a small amount (0.03 percentage points), which is
nice, but I'm not sure would account for the speedup we see in the run time.

Parallel ALU:
     Total time: 0.182 [sec]

 Performance counter stats for 'perf bench sched messaging -- bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       1553.544876 task-clock                #    5.217 CPUs utilized            ( +-  0.42% )
            14,066 context-switches          #    0.009 M/sec                    ( +-  6.24% )
             2,831 cpu-migrations            #    0.002 M/sec                    ( +-  3.33% )
            75,432 page-faults               #    0.049 M/sec                    ( +-  0.08% )
     1,659,509,743 cycles                    #    1.068 GHz                      ( +-  1.27% ) [40.10%]
       106,466,680 stalled-cycles-frontend   #    6.42% frontend cycles idle     ( +-  1.50% ) [39.98%]
     1,035,481,957 stalled-cycles-backend    #   62.40% backend  cycles idle     ( +-  1.23% ) [39.38%]
       875,104,201 instructions              #    0.53  insns per cycle        
                                             #    1.18  stalled cycles per insn  ( +-  1.30% ) [38.66%]
       160,553,275 branches                  #  103.346 M/sec                    ( +-  1.32% ) [38.85%]
         4,329,119 branch-misses             #    2.70% of all branches          ( +-  1.39% ) [39.59%]
       448,195,116 L1-dcache-loads           #  288.498 M/sec                    ( +-  1.91% ) [41.07%]
         8,632,347 L1-dcache-load-misses     #    1.93% of all L1-dcache hits    ( +-  1.90% ) [41.56%]
        15,143,145 LLC-loads                 #    9.747 M/sec                    ( +-  1.89% ) [41.05%]
         4,698,204 LLC-load-misses           #   31.03% of all LL-cache hits     ( +-  1.03% ) [41.23%]
       224,316,468 L1-icache-loads           #  144.390 M/sec                    ( +-  1.27% ) [41.39%]
         2,902,842 L1-icache-load-misses     #    1.29% of all L1-icache hits    ( +-  2.65% ) [42.60%]
       433,914,588 dTLB-loads                #  279.306 M/sec                    ( +-  1.75% ) [43.07%]
           132,090 dTLB-load-misses          #    0.03% of all dTLB cache hits   ( +-  2.15% ) [43.12%]
       230,701,361 iTLB-loads                #  148.500 M/sec                    ( +-  1.77% ) [43.47%]
            45,562 iTLB-load-misses          #    0.02% of all iTLB cache hits   ( +-  3.76% ) [42.88%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [42.29%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [41.32%]

       0.297758185 seconds time elapsed                                          ( +-  0.40% )

Here It seems the major advantage was backend stall cycles saved (which makes
sense to me).  Since we split the instruction path into two units that could run
independently of each other we spent less time waiting for prior instructions to
retire.  As a result we dropped two percentage points in our stall number.

Prefetch + Parallel ALU:
     Total time: 0.182 [sec]

 Performance counter stats for 'perf bench sched messaging -- bash -c echo 1 > /sys/module/csum_test/parameters/test_fire' (20 runs):

       1549.171283 task-clock                #    5.231 CPUs utilized            ( +-  0.50% )
            13,717 context-switches          #    0.009 M/sec                    ( +-  4.32% )
             2,721 cpu-migrations            #    0.002 M/sec                    ( +-  2.47% )
            75,432 page-faults               #    0.049 M/sec                    ( +-  0.07% )
     1,579,140,244 cycles                    #    1.019 GHz                      ( +-  1.71% ) [40.06%]
       103,803,034 stalled-cycles-frontend   #    6.57% frontend cycles idle     ( +-  1.74% ) [39.60%]
     1,016,582,613 stalled-cycles-backend    #   64.38% backend  cycles idle     ( +-  1.79% ) [39.57%]
       881,036,653 instructions              #    0.56  insns per cycle        
                                             #    1.15  stalled cycles per insn  ( +-  1.61% ) [39.29%]
       164,333,010 branches                  #  106.078 M/sec                    ( +-  1.51% ) [39.38%]
         4,385,459 branch-misses             #    2.67% of all branches          ( +-  1.62% ) [40.29%]
       463,987,526 L1-dcache-loads           #  299.507 M/sec                    ( +-  1.52% ) [40.20%]
         8,739,535 L1-dcache-load-misses     #    1.88% of all L1-dcache hits    ( +-  1.95% ) [40.37%]
        15,318,497 LLC-loads                 #    9.888 M/sec                    ( +-  1.80% ) [40.43%]
         4,846,148 LLC-load-misses           #   31.64% of all LL-cache hits     ( +-  1.68% ) [40.59%]
       231,982,874 L1-icache-loads           #  149.746 M/sec                    ( +-  1.43% ) [41.25%]
         3,141,106 L1-icache-load-misses     #    1.35% of all L1-icache hits    ( +-  2.32% ) [41.76%]
       459,688,615 dTLB-loads                #  296.732 M/sec                    ( +-  1.75% ) [41.87%]
           138,667 dTLB-load-misses          #    0.03% of all dTLB cache hits   ( +-  1.97% ) [42.31%]
       235,629,204 iTLB-loads                #  152.100 M/sec                    ( +-  1.40% ) [42.04%]
            46,038 iTLB-load-misses          #    0.02% of all iTLB cache hits   ( +-  2.75% ) [41.20%]
                 0 L1-dcache-prefetches      #    0.000 K/sec                   [40.77%]
                 0 L1-dcache-prefetch-misses #    0.000 K/sec                   [40.27%]

       0.296173305 seconds time elapsed                                          ( +-  0.44% )
Here, with both optimizations, we've reduced both our backend stall cycles, and
our dcache miss rate (though our load misses here is higher than it was when we
are just doing parallel ALU execution.  I wonder if the separation of the adcx
path is leading to multiple load requests before the prefetch completes.  I'll
try messing with the stride a bit more to see if I can get some more insight
there.

So there you have it.  I think, looking at this, I can say that its not as big a
win as my initial measurements were indicating, but still a win.

Thoughts?

Regards
Neil

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/init.h>
#include <linux/moduleparam.h>
#include <linux/rtnetlink.h>
#include <net/rtnetlink.h>
#include <linux/u64_stats_sync.h>

#define BUFSIZ 2*1024*1024
#define NBPAGES 16

extern int csum_mode;
int module_test_mode = 0;
int test_fire = 0;

static int __init csum_init_module(void)
{
        return 0;
}

static void __exit csum_cleanup_module(void)
{
        return;
}

static int set_param_str(const char *val, const struct kernel_param *kp)
{
        int i;
        __wsum sum = 0;
        /*u64 start, end;*/
        void *base, *addrs[NBPAGES];
        u32 rnd, offset;

	
        memset(addrs, 0, sizeof(addrs));
        for (i = 0; i < NBPAGES; i++) {
                addrs[i] = kmalloc_node(BUFSIZ, GFP_KERNEL, 0);
                if (!addrs[i])
                        goto out;
        }

	csum_mode = module_test_mode;

	local_bh_disable();
        /*pr_err("STARTING ITERATIONS on cpu %d\n", smp_processor_id());*/
        /*start = ktime_to_ns(ktime_get());*/

        for (i = 0; i < 100000; i++) {
                rnd = prandom_u32();
                base = addrs[rnd % NBPAGES];
                rnd /= NBPAGES;
                offset = rnd % (BUFSIZ - 1500);
                offset &= ~1U;
                sum = csum_partial(base + offset, 1500, sum);
        }
        /*end = ktime_to_ns(ktime_get());*/
        local_bh_enable();

	/*pr_err("COMPLETED 100000 iterations of csum %x in %llu nanosec\n", sum, end - start);*/

	csum_mode = 0;
out:
        for (i = 0; i < NBPAGES; i++)
                kfree(addrs[i]);

        return 0;
}

static int get_param_str(char *buffer, const struct kernel_param *kp)
{
	return sprintf(buffer, "%d\n", test_fire);
}

static struct kernel_param_ops param_ops_str = {
	.set = set_param_str,
	.get = get_param_str,
};

module_param_named(module_test_mode, module_test_mode, int, 0644);
MODULE_PARM_DESC(module_test_mode, "csum test mode");
module_param_cb(test_fire, &param_ops_str, &test_fire, 0644);
module_init(csum_init_module);
module_exit(csum_cleanup_module);
MODULE_LICENSE("GPL");
