From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Thu, 06 Oct 2011 22:24:03 -0400
Message-ID: <6.2.5.6.2.20111006164948.05ba0e00@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christoph Lameter <cl@gentwo.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Will
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

UPDATE

Hi all, I'm back with a significant update.

First, discovered that the problem with UDP was a tightening of the reverse-path filter logic in newer kernels.  To make the test work had to configure 'net.ipv4.conf.default.rp_filter = 0' in 'sysctl.conf'.  Was able to rerun all the tests in the nominal UDP sockets mode instead of packet socket mode.

Second I was intrigued by an assertion put forward that older kernels are always better than newer kernels.  So with some effort I managed to coerce 2.6.9(rhel4) into running on the Opteron 6174 CPU, though it only recognized eight of the twelve cores.


Here are the CPU results.  User and sys are expressed in jiffies.

kernel version      cpu total   user     sys        IRQ/s
2.6.18-194.8.1.el5  02:18:40  625666  206423 (24.8%)  18k
2.6.9-101.EL(rhel4) 02:31:12  689024  218198 (24.0%)  18k*
2.6.32-71.29.1.el6  02:50:14  602191  419276 (41.0%)  64k
2.6.39.4(vanilla)   02:42:35  629817  345674 (35.4%)  85k

kernel version      cpu total   user     sys        IRQ/s
2.6.18-194.8.1.el5         -       -       -            -
2.6.9-101.EL(rhel4)    +9.0%  +10.1%   +5.7%           0%*
2.6.32-71.29.1.el6    +22.7%   -3.8%   +103%        +255%
2.6.39.4(vanilla)     +17.2%   +0.7%  +67.4%        +372%

* test speed was run at 2/3rds to equalize
  the per-core frame rate since four cores
  were disabled


Here are some latency data samples.  Report interval is 10 seconds, all latency columns are in milliseconds.

2.6.18-194.8.1.el5
sample     min      max     mean    sigma
198283   0.011    3.139    0.239    0.169
206597   0.012    3.085    0.237    0.178
195939   0.012    4.220    0.266    0.211
206378   0.013    4.006    0.274    0.218
211994   0.012    3.771    0.248    0.184
222325   0.011    3.106    0.234    0.156
210871   0.011    2.693    0.254    0.177

2.6.9-101.EL(rhel4)
sample     min      max     mean    sigma
139786   0.013    3.637    0.335    0.238 
149788   0.013    3.957    0.384    0.258 
144065   0.014    7.637    0.376    0.283 
142088   0.012    3.996    0.398    0.281 
141026   0.014    4.174    0.383    0.253 
143387   0.014    4.457    0.366    0.236 
147699   0.013    4.615    0.359    0.238 

2.6.32-71.29.1.el6
sample     min      max     mean    sigma
206452   0.015    4.516    0.268    0.197
195740   0.016    4.227    0.277    0.206
206644   0.012    3.412    0.276    0.194
212008   0.012    2.569    0.269    0.182
222119   0.011    2.523    0.266    0.178
211377   0.012    2.779    0.277    0.178
214113   0.013    2.680    0.277    0.184

2.6.39.4(vanilla)
sample     min      max     mean    sigma
198530   0.012    2.736    0.274    0.147
200148   0.012    1.971    0.272    0.145
209972   0.010    2.975    0.270    0.150
219775   0.012    2.595    0.263    0.151
215601   0.015    2.554    0.276    0.153
211549   0.010    3.075    0.282    0.158
219332   0.012    2.658    0.271    0.144

2.6.9(rhel4) was a bit worse than 2.6.18(rhel5).  However the fact that it ran on eight cores instead of twelve may have subtly affected the outcome.  Also this kernel was built with the gcc 3.4.6 RH distro compiler which may generate code less well optimized for the 6174 CPU.  Therefore I view it as pretty close to a tie, but 2.6.18(rhel5) is the obviously better choice for the superior hardware support it provides.

Despite consuming a great deal more CPU, the newer kernels made a good showing on latency in this mode where only one thread wakeup occurs per arriving frame.  Both have slighter tighter latency distributions and slightly improved worst-case latencies.  2.6.39.4 is somewhat better than 2.6.32(rhel6) on all fronts.  Nonetheless I find the much higher CPU consumption to be a major negative since this reduces the overall capacity available on identical hardware.

-----

Now for the tests performed earlier and to which all my comments prior to this post apply.  Ran these only because I thought UDP was broken, but now I find I'm pleased with the added perspective they provide.  In this mode our application reads all the data from four interfaces via packet sockets (one per interface), and then requeues the packets to a pool of worker threads.  Potentially two application worker thread wakeup events occur for each frame, though wakeups only occur when work queues become empty.  The worker thread pool consists of nine threads with packets routed by similar type to maximize cache locality during processing.

2.6.18-194.8.1.el5
sample     min      max     mean    sigma
217629   0.015    1.841    0.150    0.080
217523   0.015    1.213    0.155    0.076
209183   0.014    0.624    0.129    0.066
220726   0.014    1.255    0.160    0.087
220400   0.015    3.374    0.197    0.172
238151   0.014    1.275    0.182    0.090
249239   0.016    1.399    0.197    0.093

2.6.9-101.EL(rhel4)
sample     min      max     mean    sigma
138561   0.019    3.163    0.333    0.236
144033   0.014    3.691    0.337    0.240
147437   0.016    3.802    0.320    0.226
147297   0.016    4.063    0.351    0.292
156178   0.018    3.560    0.322    0.244
166156   0.019    3.983    0.326    0.246
161930   0.017    3.441    0.311    0.197

2.6.32-71.29.1.el6
sample     min      max     mean    sigma
210340   0.017    8.734    0.344    0.638
220199   0.020    7.319    0.341    0.530
216868   0.019    6.376    0.332    0.544
211556   0.019    7.494    0.318    0.493
219462   0.014    7.472    0.344    0.545
225027   0.022    8.103    0.382    0.639
245629   0.017    8.713    0.382    0.594

2.6.39.4(vanilla)
sample     min      max     mean    sigma
253791   0.020    6.127    0.505    0.544
256739   0.020    6.960    0.535    0.577
258719   0.019    8.116    0.500    0.541
244735   0.018    6.781    0.542    0.634
250195   0.021    8.205    0.531    0.568

In this mode latency is quite a lot better with the 2.6.18(rhel5) kernel and seriously worse in the newer kernels.  Perhaps what is happening in 2.6.18(rhel) is that frames are being received on one set of cores and processed on a different set, with relatively few actual thread sleep/wake events.  The cache on each core is hot for the task it is performing, and due to the specialization of each worker thread less code cache pressure is present.  In 2.6.39.4 I can only say that the context switch rate was in the typical 200k/sec range where older kernels ran at less than half that.  Sorry now that I did not record CS rates more carefully.

Here's CPU consumption:

kernel version      cpu total   user     sys        IRQ/s
2.6.18-194.8.1.el5  02:07:16  615516  148152 (19.4%)  28k 
2.6.9-101.EL(rhel4) 02:30:22  696344  205953 (22.8%)  20k
2.6.32-71.29.1.el6  02:15:50  585276  229767 (28.1%) 163k
2.6.39.4(vanilla)   02:27:44  658074  228420 (25.7%) 165k

kernel version      cpu total   user     sys        IRQ/s
2.6.18-194.8.1.el5         -       -       -            -
2.6.9-101.EL(rhel4)   +18.1%  +13.1%   +39.0%        -29%
2.6.32-71.29.1.el6     +6.7%   -4.9%   +55.0%       +482%
2.6.39.4(vanilla)     +16.0%   +6.0%   +54.1%       +489%

The 2.6.18(rhel5) kernel performed significantly better here than in the many-threaded UDP-mode which I attribute to the close matching of the thread and core count and the reasons stated in the previous paragraph.  CPU consumption of 2.6.9(rhel4) with thirteen active threads scheduled on eight cores was about the same here as it was with the large UDP-mode thread count.

Relative to the many-threaded UDP-mode, matching of thread and core counts seems to help .32(rhel6) a great deal, but to a lesser degree for .39.

As with UDP-mode, system overhead is substantialy higher with newer kernels.

-----

Note that some tests were run with packets sockets and a large thread pool, but not all scenarios were covered and I find it less interesting than the small thread pool so it is omitted here.

Have perf reports for all 2.6.39.4 runs and a perf report for the the packet socket run on 2.6.32(rhel6).  If anyone is interested let me know and I'll post them.

-----

Overall our application runs best with 2.6.18(rhel5) in all regards excepting a slight improvement in latency distribution where, despite higher CPU consumption, the .32 and .39 kernels are better at 50% CPU load.  Naturally at higher data rates the newer kernel latency will go to pieces sooner and the absolute maximum performance attainable is substantially lower.

Until truly spectacular core counts arrive 2.6.18 remains the kernel of choice.

We would find it attractive if an option to compile newer kernels with a circa 2.6.18 O(1) scheduler was made available in the future.  Not a problem if doing so would disable any number of dependent kernel features.  Target here is HPC where in our view less is more and virtuzlization, resource allocation fairness (not to mention the SCHED_OTHER priority policy) etc. have little or no utility.  A shorter scheduler code path-length and lower cache pressure are more important than enhanced functionality.  The original O(1) scheduler appears to handle chains of related-processing thread hand-offs dramatically better.
