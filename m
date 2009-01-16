From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 16 Jan 2009 17:46:23 +1100
Message-ID: <200901161746.25205.nickpiggin@yahoo.com.au>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com> <200901161503.13730.nickpiggin@yahoo.com.au> <20090115201210.ca1a9542.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: matthew@wil.cx, matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, andi.kleen@intel.com,
	suresh.b.siddha@intel.com, harita.chilukuri@intel.com,
	douglas.w.styner@intel.com, peter.xihong.wang@intel.com,
	hubert.nueckel@intel.com, chris.mason@oracle.com,
	srostedt@redhat.com, linux-scsi@vger.kernel.org,
	andrew.vasquez@qlogic.com, anirban.chakraborty@qlogic.com
To: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.mail.mud.yahoo.com ([209.191.84.64]:26744 "HELO
	smtp111.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751944AbZAPGqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 01:46:48 -0500
In-Reply-To: <20090115201210.ca1a9542.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 16 January 2009 15:12:10 Andrew Morton wrote:
> On Fri, 16 Jan 2009 15:03:12 +1100 Nick Piggin <nickpiggin@yahoo.com.au> 
wrote:
> > I would like to see SLQB merged in mainline, made default, and wait for
> > some number releases. Then we take what we know, and try to make an
> > informed decision about the best one to take. I guess that is problematic
> > in that the rest of the kernel is moving underneath us. Do you have
> > another idea?
>
> Nope.  If it doesn't work out, we can remove it again I guess.

OK, I have these numbers to show I'm not completely off my rocker to suggest
we merge SLQB :) Given these results, how about I ask to merge SLQB as default
in linux-next, then if nothing catastrophic happens, merge it upstream in the
next merge window, then a couple of releases after that, given some time to
test and tweak SLQB, then we plan to bite the bullet and emerge with just one
main slab allocator (plus SLOB).


System is a 2socket, 4 core AMD. All debug and stats options turned off for
all the allocators; default parameters (ie. SLUB using higher order pages,
and the others tend to be using order-0). SLQB is the version I recently
posted, with some of the prefetching removed according to Pekka's review
(probably a good idea to only add things like that in if/when they prove to
be an improvement).

time fio examples/netio (10 runs, lower better):
SLAB AVG=13.19 STD=0.40
SLQB AVG=13.78 STD=0.24
SLUB AVG=14.47 STD=0.23

SLAB makes a good showing here. The allocation/freeing pattern seems to be
very regular and easy (fast allocs and frees). So it could be some "lucky"
caching behaviour, I'm not exactly sure. I'll have to run more tests and
profiles here.


hackbench (10 runs, lower better):
1 GROUP
SLAB AVG=1.34 STD=0.05
SLQB AVG=1.31 STD=0.06
SLUB AVG=1.46 STD=0.07

2 GROUPS
SLAB AVG=1.20 STD=0.09
SLQB AVG=1.22 STD=0.12
SLUB AVG=1.21 STD=0.06

4 GROUPS
SLAB AVG=0.84 STD=0.05
SLQB AVG=0.81 STD=0.10
SLUB AVG=0.98 STD=0.07

8 GROUPS
SLAB AVG=0.79 STD=0.10
SLQB AVG=0.76 STD=0.15
SLUB AVG=0.89 STD=0.08

16 GROUPS
SLAB AVG=0.78 STD=0.08
SLQB AVG=0.79 STD=0.10
SLUB AVG=0.86 STD=0.05

32 GROUPS
SLAB AVG=0.86 STD=0.05
SLQB AVG=0.78 STD=0.06
SLUB AVG=0.88 STD=0.06

64 GROUPS
SLAB AVG=1.03 STD=0.05
SLQB AVG=0.90 STD=0.04
SLUB AVG=1.05 STD=0.06

128 GROUPS
SLAB AVG=1.31 STD=0.19
SLQB AVG=1.16 STD=0.36
SLUB AVG=1.29 STD=0.11

SLQB tends to be the winner here. SLAB is close at lower numbers of
groups, but drops behind a bit more as they increase.


tbench (10 runs, higher better):
1 THREAD
SLAB AVG=239.25 STD=31.74
SLQB AVG=257.75 STD=33.89
SLUB AVG=223.02 STD=14.73

2 THREADS
SLAB AVG=649.56 STD=9.77
SLQB AVG=647.77 STD=7.48
SLUB AVG=634.50 STD=7.66

4 THREADS
SLAB AVG=1294.52 STD=13.19
SLQB AVG=1266.58 STD=35.71
SLUB AVG=1228.31 STD=48.08

8 THREADS
SLAB AVG=2750.78 STD=26.67
SLQB AVG=2758.90 STD=18.86
SLUB AVG=2685.59 STD=22.41

16 THREADS
SLAB AVG=2669.11 STD=58.34
SLQB AVG=2671.69 STD=31.84
SLUB AVG=2571.05 STD=45.39

SLAB and SLQB seem to be pretty close, winning some and losing some.
They're always within a standard deviation of one another, so we can't
make conclusions between them. SLUB seems to be a bit slower.


Netperf UDP unidirectional send test (10 runs, higher better):

Server and client bound to same CPU
SLAB AVG=60.111 STD=1.59382
SLQB AVG=60.167 STD=0.685347
SLUB AVG=58.277 STD=0.788328

Server and client bound to same socket, different CPUs
SLAB AVG=85.938 STD=0.875794
SLQB AVG=93.662 STD=2.07434
SLUB AVG=81.983 STD=0.864362

Server and client bound to different sockets
SLAB AVG=78.801 STD=1.44118
SLQB AVG=78.269 STD=1.10457
SLUB AVG=71.334 STD=1.16809

SLQB is up with SLAB for the first and last cases, and faster in
the second case. SLUB trails in each case. (Any ideas for better types
of netperf tests?)


Kbuild numbers don't seem to be significantly different. SLAB and SLQB
actually got exactly the same average over 10 runs. The user+sys times
tend to be almost identical between allocators, with elapsed time mainly
depending on how much time the CPU was not idle.


Intel's OLTP shows SLQB is "neutral" to SLAB. That is, literally within
their measurement confidence interval. If it comes down to it, I think we
could get them to do more runs to narrow that down, but we're talking a
couple of tenths of a percent already.


I haven't done any non-local network tests. Networking is the one of the
subsystems most heavily dependent on slab performance, so if anybody
cares to run their favourite tests, that would be really helpful.

Disclaimer
----------
Now remember this is just one specific HW configuration, and some
allocators for some reason give significantly (and sometimes perplexingly)
different results between different CPU and system architectures.

The other frustrating thing is that sometimes you happen to get a lucky
or unlucky cache or NUMA layout depending on the compile, the boot, etc.
So sometimes results get a little "skewed" in a way that isn't reflected
in the STDDEV. But I've tried to minimise that. Dropping caches and
restarting services etc. between individual runs.


