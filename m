From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sat, 25 Oct 2008 05:37:28 +0200
Message-ID: <1224905848.5161.27.camel@marge.simson.net>
References: <20081009231759.GA8664@tservice.net.ru>
	 <20081010115518.GA3159@tservice.net.ru> <20081010115725.GD19487@elte.hu>
	 <200810250025.35734.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Evgeniy Polyakov <s0mbre@tservice.net.ru>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:50358 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751900AbYJYDhc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 23:37:32 -0400
In-Reply-To: <200810250025.35734.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-10-25 at 00:25 +0200, Rafael J. Wysocki wrote:
> On Friday, 10 of October 2008, Ingo Molnar wrote:
> > 
> > * Evgeniy Polyakov <s0mbre@tservice.net.ru> wrote:
> > 
> > > On Fri, Oct 10, 2008 at 01:42:45PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> > > > > vanilla 27: 347.222
> > > > > no TSO/GSO: 357.331
> > > > > no hrticks: 382.983
> > > > > no balance: 389.802
> > > > 
> > > > okay. The target is 470 MB/sec, right? (Assuming the workload is sane 
> > > > and 'fixing' it does not mean we have to schedule worse.)
> > > 
> > > Well, that's where I started/stopped, so maybe we will even move
> > > further? :)
> > 
> > that's the right attitude ;)
> 
> Can anyone please tell me if there was any conclusion of this thread?

Part of the .27 regression was added scheduler overhead going from .26
to .27.  The scheduler overhead is now gone, but an unidentified source
of localhost throughput loss remains for both SMP and UP configs.

	-Mike

My last test data, updated to reflect recent commits:

Legend:
clock  = v2.6.26..5052696 + 5052696..v2.6.27-rc7 sched clock changes
weight = a7be37a + c9c294a + ced8aa1 (adds math overhead)
buddy  = 103638d (adds math overhead)
buddy_overhead = b0aa51b (removes math overhead of buddy)
revert_to_per_rq_vruntime = f9c0b09 (+2 lines, removes math overhead of weight)

2.6.26.6-up virgin
ring-test   - 1.169 us/cycle  = 855 KHz                                 1.000
netperf     - 130967.54 131143.75 130914.96 rr/s    avg 131008.75 rr/s  1.000
tbench      - 357.593 355.455 356.048 MB/sec        avg 356.365 MB/sec  1.000

2.6.26.6-up + clock + buddy + weight (== .27 scheduler)
ring-test   - 1.234 us/cycle  = 810 KHz                                  .947 [cmp1]
netperf     - 128026.62 128118.48 127973.54 rr/s    avg 128039.54 rr/s   .977
tbench      - 342.011 345.307 343.535 MB/sec        avg 343.617 MB/sec   .964

2.6.26.6-up + clock + buddy + weight + revert_to_per_rq_vruntime + buddy_overhead
ring-test   - 1.174 us/cycle  = 851 KHz                                  .995 [cmp2]
netperf     - 133928.03 134265.41 134297.06 rr/s    avg 134163.50 rr/s  1.024
tbench      - 358.049 359.529 358.342 MB/sec        avg 358.640 MB/sec  1.006

                                                       versus .26 counterpart
2.6.27-up virgin
ring-test   - 1.193 us/cycle  = 838 KHz                                 1.034 [vs cmp1]
netperf     - 121293.48 121700.96 120716.98 rr/s    avg 121237.14 rr/s   .946
tbench      - 340.362 339.780 341.353 MB/sec        avg 340.498 MB/sec   .990

2.6.27-up + revert_to_per_rq_vruntime + buddy_overhead
ring-test   - 1.122 us/cycle  = 891 KHz                                 1.047 [vs cmp2]
netperf     - 119353.27 118600.98 119719.12 rr/s    avg 119224.45 rr/s   .900
tbench      - 338.701 338.508 338.562 MB/sec        avg 338.590 MB/sec   .951

SMP config

2.6.26.6-smp virgin
ring-test   - 1.575 us/cycle  = 634 KHz                                 1.000
netperf     - 400487.72 400321.98 404165.10 rr/s    avg 401658.26 rr/s  1.000
tbench      - 1178.27 1177.18 1184.61 MB/sec        avg 1180.02 MB/sec  1.000

2.6.26.6-smp + clock + buddy + weight + revert_to_per_rq_vruntime + buddy_overhead
ring-test   - 1.575 us/cycle  = 634 KHz                                 1.000
netperf     - 412191.70 411873.15 414638.27 rr/s    avg 412901.04 rr/s  1.027
tbench      - 1193.18 1200.93 1199.61 MB/sec        avg 1197.90 MB/sec  1.015

                                                             versus 26.6 plus
2.6.27-smp virgin
ring-test   - 1.674 us/cycle  = 597 KHz                                  .941
netperf     - 382536.26 380931.29 380552.82 rr/s    avg 381340.12 rr/s   .923
tbench      - 1151.47 1143.21 1154.17 MB/sec        avg 1149.616 MB/sec  .959

2.6.27-smp + revert_to_per_rq_vruntime + buddy_overhead
ring-test   - 1.570 us/cycle  = 636 KHz                                 1.003
netperf     - 386487.91 389858.00 388180.91 rr/s    avg 388175.60 rr/s   .940
tbench      - 1179.52 1184.25 1180.18 MB/sec        avg 1181.31 MB/sec   .986



