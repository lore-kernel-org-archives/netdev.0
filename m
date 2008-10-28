From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Tue, 28 Oct 2008 11:24:22 +0100
Message-ID: <1225189462.4903.238.camel@marge.simson.net>
References: <20081027113306.5b1d5898@lxorguk.ukuu.org.uk>
	 <20081027183312.GD11494@elte.hu> <20081027193933.GB2590@ioremap.net>
	 <20081027.124848.163119274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, mingo@elte.hu, alan@lxorguk.ukuu.org.uk,
	jkosina@suse.cz, akpm@linux-foundation.org, a.p.zijlstra@chello.nl,
	rjw@sisk.pl, s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:47186 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752439AbYJ1KY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 06:24:29 -0400
In-Reply-To: <20081027.124848.163119274.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-27 at 12:48 -0700, David Miller wrote: 
> From: Evgeniy Polyakov <zbr@ioremap.net>
> Date: Mon, 27 Oct 2008 22:39:34 +0300
> 
> > On Mon, Oct 27, 2008 at 07:33:12PM +0100, Ingo Molnar (mingo@elte.hu) wrote:
> > > The moment there's real IO it becomes harder to analyze but the same 
> > > basic behavior remains: the more unfair the IO scheduler, the "better" 
> > > dbench results we get.
> > 
> > Right now there is no disk IO at all. Only quite usual network and
> > process load.
> 
> I think the hope is that by saying there isn't a problem enough times,
> it will become truth. :-)
> 
> More seriously, Ingo, what in the world do we need to do in order to get
> you to start doing tbench runs and optimizing things (read as: fixing
> the regression you added)?
> 
> I'm personally working on a test fibonacci heap implementation for
> the fair sched code, and I already did all of the cost analysis all
> the way back to the 2.6.22 pre-CFS days.
> 
> But I'm NOT a scheduler developer, so it isn't my responsibility to do
> this crap for you.  You added this regression, why do I have to get my
> hands dirty in order for there to be some hope that these regressions
> start to get fixed?

I don't want to ruffle any feathers, but my box has comment or two..

Has anyone looked at the numbers box emitted?  Some what I believe to be
very interesting data-points may have been overlooked.

Here's a piece thereof again for better of worse.  One last post won't
burn the last electron.  If they don't agree anyone else's numbers,
that's ok, their numbers have meaning too, and speak for themselves.

Retest hrtick pain:

2.6.26.7-up virgin no highres timers enabled
ring-test   - 1.155 us/cycle  = 865 KHz                                 1.000
netperf     - 130470.93 130771.00 129872.41 rr/s    avg 130371.44 rr/s  1.000 (within jitter of previous tests)
tbench      - 355.153 357.163 356.836 MB/sec        avg 356.384 MB/sec  1.000

2.6.26.7-up virgin highres timers enabled, hrtick enabled
ring-test   - 1.368 us/cycle  = 730 KHz                                  .843
netperf     - 118959.08 118853.16 117761.42 rr/s    avg 118524.55 rr/s   .909
tbench      - 340.999 338.655 340.005 MB/sec        avg 339.886 MB/sec   .953

OK, there's the htrick regression in all it's gory.  Ouch, that hurt.  

Remember those numbers, box muttered them again in 27 testing.  These
previously tested kernels don't even have highres timers enabled, so
obviously hrtick is a non-issue for them.

2.6.26.6-up + clock + buddy + weight
ring-test   - 1.234 us/cycle  = 810 KHz                                  .947 [cmp1]
netperf     - 128026.62 128118.48 127973.54 rr/s    avg 128039.54 rr/s   .977
tbench      - 342.011 345.307 343.535 MB/sec        avg 343.617 MB/sec   .964

2.6.26.6-up + clock + buddy + weight + revert_to_per_rq_vruntime + buddy_overhead
ring-test   - 1.174 us/cycle  = 851 KHz                                  .995 [cmp2]
netperf     - 133928.03 134265.41 134297.06 rr/s    avg 134163.50 rr/s  1.024
tbench      - 358.049 359.529 358.342 MB/sec        avg 358.640 MB/sec  1.006

Note that I added all .27 additional scheduler overhead to .26, and then
removed every last bit of it, theoretically leaving nothing but improved
clock accuracy in the wake.  The ring-test number indicates that our max
context switch rate was thereby indeed fully recovered.  We even got a
modest throughput improvement for our trouble.

However.. 
                                                       versus .26 counterpart
2.6.27-up virgin
ring-test   - 1.193 us/cycle  = 838 KHz                                 1.034 [vs cmp1]
netperf     - 121293.48 121700.96 120716.98 rr/s    avg 121237.14 rr/s   .946
tbench      - 340.362 339.780 341.353 MB/sec        avg 340.498 MB/sec   .990

2.6.27-up + revert_to_per_rq_vruntime + buddy_overhead
ring-test   - 1.122 us/cycle  = 891 KHz                                 1.047 [vs cmp2]
netperf     - 119353.27 118600.98 119719.12 rr/s    avg 119224.45 rr/s   .900
tbench      - 338.701 338.508 338.562 MB/sec        avg 338.590 MB/sec   .951

..removing the overhead from .27 does not produce the anticipated result
despite a max context switch rate markedly above that of 2.6.26.

There lies an as yet unaddressed regression IMBHO.  The hrtick has been
addressed.  It sucked at high frequency, and it's gone.  The added math
overhead in .27 hurt some too, and is now history as well.

These two regressions are nearly identical in magnitude per box.

I don't know who owns that regression, neither does box or git.  I'm not
pointing fingers in any direction.  I've walked the regression hunting
path, and know first-hand how rocky that path is.

There are other things along the regression path that are worth noting:

Three of the releases I tested were tested with identical schedulers,
cfs-v24.1, yet they produced markedly different output, output which
regresses.  Again, I'm not pointing fingers, I'm merely illustrating how
rocky this regression hunting path is.  In 25, the sum of all kernel
changes dropped our max switch rate markedly, yet both tbench and
netperf _improved_ markedly.  More rocks in the road.  etc etc etc.

To really illustrate rockiness, cutting network config down from distro
lard-ball to something leaner and meaner took SMP throughput from this
(was only testing netperf at that time) on 19 Aug..

2.6.22.19 pinned
16384  87380  1        1       300.00   59866.40   
16384  87380  1        1       300.01   59852.78   
16384  87380  1        1       300.01   59618.48   
16384  87380  1        1       300.01   59655.35   

..to this on 13 Sept..

2.6.22.19 (also pinned)
Throughput 1136.02 MB/sec 4 procs

16384  87380  1        1       60.01    94179.12
16384  87380  1        1       60.01    88780.61
16384  87380  1        1       60.01    91057.72
16384  87380  1        1       60.01    94242.16

..and to this on 15 Sept.

2.6.22.19 (also pinned)
Throughput 1250.73 MB/sec 4 procs                  1.00

16384  87380  1        1       60.01    111272.55  1.00
16384  87380  1        1       60.00    104689.58
16384  87380  1        1       60.00    110733.05
16384  87380  1        1       60.00    110748.88

2.6.22.19-cfs-v24.1

Throughput 1204.14 MB/sec 4 procs                  .962

16384  87380  1        1       60.01    101799.85  .929
16384  87380  1        1       60.01    101659.41
16384  87380  1        1       60.01    101628.78
16384  87380  1        1       60.01    101700.53

wakeup granularity = 0 (make scheduler as preempt happy as 2.6.22 is)

Throughput 1213.21 MB/sec 4 procs                  .970

16384  87380  1        1       60.01    108569.27  .992
16384  87380  1        1       60.01    108541.04
16384  87380  1        1       60.00    108579.63
16384  87380  1        1       60.01    108519.09

Is that a rock in my let's double triple quintuple examine scheduler
performance along the regression path or what?  Same box, same
benchmarks and same schedulers I've been examining the whole time.

.992 and .970.

The list goes on and on and on, including SCHED_RR testing where I saw
regression despite no CFS math.  My point here is that every little
change of anything changes the picture up to and including radically.
These configuration changes, if viewed in regression terms, are HUGE.
Build a fully enabled netfilter into the kernel vs modular, and it
becomes even more so. 

The picture with UP config is different, but as far as box is concerned,
while scheduler involvement is certainly interesting, there are even
more interesting places.  Somewhere.

Hopefully this post won't be viewed in the rather cynical light of your
first quoted stanza.  Box is incapable of such, and I have no incentive
to do such ;-)  I just run the benchmarks, collect whatever numbers box
feels like emitting, and run around trying to find the missing bits.

	-Mike

