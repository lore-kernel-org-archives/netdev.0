From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 16 Jan 2009 19:59:29 +1100
Message-ID: <200901161959.31432.nickpiggin@yahoo.com.au>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com> <200901161746.25205.nickpiggin@yahoo.com.au> <20090115230043.57caae5d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au, matthew@wil.cx,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, andi.kleen@intel.com,
	suresh.b.siddha@intel.com, harita.chilukuri@intel.com,
	douglas.w.styner@intel.com, peter.xihong.wang@intel.com,
	hubert.nueckel@intel.com, chris.mason@oracle.com,
	srostedt@redhat.com, linux-scsi@vger.kernel.org,
	andrew.vasquez@qlogic.com, anirban.chakraborty@qlogic.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.mail.mud.yahoo.com ([209.191.84.77]:21938 "HELO
	smtp120.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759628AbZAPI7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 03:59:54 -0500
In-Reply-To: <20090115230043.57caae5d.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 16 January 2009 18:00:43 Andrew Morton wrote:
> On Fri, 16 Jan 2009 17:46:23 +1100 Nick Piggin <nickpiggin@yahoo.com.au> 
> > SLQB tends to be the winner here.
>
> Can you think of anything with which it will be the loser?

Here are some more performance numbers with "slub_test" kernel module.
It's basically a really tiny microbenchmark, so I don't really consider
it gives too useful results, except it does show up some problems in
SLAB's scalability  that may start to bite as we continue to get more
threads per socket.

(I ran a few of these tests on one of Dave's 2 socket, 128 thread
systems, and slab gets really painful... these kinds of thread counts
may only be a couple of years away from x86).

All numbers are in CPU cycles.

Single thread testing
=====================
1. Kmalloc: Repeatedly allocate 10000 objs then free them
obj size  SLAB       SLQB      SLUB
8           77+ 128   69+ 47   61+ 77
16          69+ 104  116+ 70   77+ 80
32          66+ 101   82+ 81   71+ 89
64          82+ 116   95+ 81   94+105
128        100+ 148  106+ 94  114+163
256        153+ 136  134+ 98  124+186
512        209+ 161  170+186  134+276
1024       331+ 249  236+245  134+283
2048       608+ 443  380+386  172+312
4096      1109+ 624  678+661  239+372
8192      1166+1077  767+683  535+433
16384     1213+1160  914+731  577+682

We can see SLAB has a fair bit more overhead in this case. SLUB starts
doing higher order allocations I think around size 256, which reduces
costs there. Don't know what the SLQB artifact at 16 is caused by...


2. Kmalloc: alloc/free test (repeatedly allocate and free)
       SLAB  SLQB  SLUB
8       98   90     94
16      98   90     93
32      98   90     93
64      99   90     94
128    100   92     93
256    104   93     95
512    105   94     97
1024   106   93     97
2048   107   95     95
4096   111   92     97
8192   111   94    631
16384  114   92    741

Here we see SLUB's allocator passthrough (or is the the lack of queueing?).
Straight line speed at small sizes is probably due to instructions in the
fastpaths. It's pretty meaningless though because it probably changes if
there is any actual load on the CPU, or another CPU architecture. Doesn't
look bad for SLQB though :)


Concurrent allocs
=================
1. Like the first single thread test, lots of allocs, then lots of frees.
But running on all CPUs. Average over all CPUs.
       SLAB        SLQB         SLUB
8        251+ 322    73+  47   65+  76
16       240+ 331    84+  53   67+  82
32       235+ 316    94+  57   77+  92
64       338+ 303   120+  66  105+ 136
128      549+ 355   139+ 166  127+ 344
256     1129+ 456   189+ 178  236+ 404
512     2085+ 872   240+ 217  244+ 419
1024    3895+1373   347+ 333  251+ 440
2048    7725+2579   616+ 695  373+ 588
4096   15320+4534  1245+1442  689+1002

A problem with SLAB scalability starts showing up on this system with only
4 threads per socket. Again, SLUB sees a benefit from higher order
allocations.


2. Same as 2nd single threaded test, alloc then free, on all CPUs.
      SLAB  SLQB  SLUB
8      99   90    93
16     99   90    93
32     99   90    93
64    100   91    94
128   102   90    93
256   105   94    97
512   106   93    97
1024  108   93    97
2048  109   93    96
4096  110   93    96

No surprises. Objects always fit in queues (or unqueues, in the case of
SLUB), so there is no cross cache traffic.


Remote free test
================
1. Allocate N objects on CPUs 1-7, then free them all from CPU 0. Average cost
   of all kmalloc+kfree
      SLAB        SLQB     SLUB
8       191+ 142   53+ 64  56+99
16      180+ 141   82+ 69  60+117
32      173+ 142  100+ 71  78+151
64      240+ 147  131+ 73  117+216
128     441+ 162  158+114  114+251
256     833+ 181  179+119  185+263
512    1546+ 243  220+132  194+292
1024   2886+ 341  299+135  201+312
2048   5737+ 577  517+139  291+370
4096  11288+1201  976+153  528+482


2. All CPUs allocate on objects on CPU N, then freed by CPU N+1 % NR_CPUS
   (ie. CPU1 frees objects allocated by CPU0).
      SLAB        SLQB     SLUB
8       236+ 331   72+123   64+ 114
16      232+ 345   80+125   71+ 139
32      227+ 342   85+134   82+ 183
64      324+ 336  140+138  111+ 219
128     569+ 384  245+201  145+ 337
256    1111+ 448  243+222  238+ 447
512    2091+ 871  249+244  247+ 470
1024   3923+1593  254+256  254+ 503
2048   7700+2968  273+277  369+ 699
4096  15154+5061  310+323  693+1220

SLAB's concurrent allocation bottlnecks show up again in these tests.

Unfortunately these are not too realistic tests of remote freeing pattern,
because normally you would expect remote freeing and allocation happening
concurrently, rather than all allocations up front, then all frees. If
the test behaved like that, then object could probably fit in SLAB's
queues and it might see some good numbers.

