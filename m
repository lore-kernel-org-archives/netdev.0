From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Fri, 07 Oct 2011 02:13:42 -0400
Message-ID: <6.2.5.6.2.20111007020308.039be248@binnacle.cx>
References: <6.2.5.6.2.20111006231958.039bb570@binnacle.cx>
 <1317966007.3457.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christoph Lameter <cl@gentwo.org>, Willy Tarreau <w@1wt.eu>,
	Ingo Molnar <mingo@elte.hu>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Joe Perches <joe@perches.com>,
	Chetan Loke <Chetan.Loke@netscout.com>,
	Con Kolivas <conman@kolivas.org>,
	Serge Belyshev <belyshev@depni.sinp.msu.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317966007.3457.47.camel@edumazet-laptop>
References: <6.2.5.6.2.20111006231958.039bb570@binnacle.cx>
 <1317966007.3457.47.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 07:40 AM 10/7/2011 +0200, Eric Dumazet wrote:
>
>Thats exactly the opposite : Your old kernel is not fast enough 
>to enter/exit NAPI on every incoming frame.
>
>Instead of one IRQ per incoming frame, you have less interrupts:
>A napi run processes more than 1 frame.

Please look at the data I posted.  Batching
appears to give 80us *better* latency in this
case--with the old kernel.

>Now increase your incoming rate, and you'll discover a new 
>kernel will be able to process more frames without losses.

Data loss happens mainly in relation to CPU
utilization-per-message-rate as buffers are
configured huge at all points.  So newer
kernels break down at significantly lower
message rates than older kernels.  Determined
this last year when testing SLES 11 and
unmodified 2.6.27.

I can run a max-rate comparison for 2.6.39.4
if you like.

>About your thread model :
>
>You have one thread that reads the incoming
>frame, and do a distribution on several queues
>based on some flow parameters. Then you wakeup 
>a second thread.
>
>This kind of model is very expensive and triggers
>lot of false sharing.

Please note my use of the word "nominal" and the
overall context.  Both thread-per-socket and
dual-thread handoff handling tests were performed
with the clear observation that the former is
the production model and works best at maximum
load.

However at 50% load (the test here), the
dual-thread handoff model is the clear winner
over *all* other scenarios.

>New kernels are able to perform this fanout in kernel land.

Yes, of course I am interested in Intel's flow
director and similar solutions, netfilter especially.
2.6.32 is only recently available in commercial
deployment and I will be looking at that next up.
Mainly I'll be looking at complete kernel bypass
with 10G.  Myricom looks like it might be good.
Tested Solarflare last year and it was a bust
for high volume UDP (one thread) but I've heard
that they fixed that and will revisit.

In relation to the above observation that
less CPU-per-packet is best for avoiding
data loss, it also correlates somewhat
(though not always) with better latency.

I've used the 'e1000e' 1G network interfaces
for these tests because they work better than
the multi-queue 'igb' (Intel 82576) and
'ixgbe' (Intel 82599) in all scenarios other
than maximum-stress load.  The reason is
apparently that the old 'e1000e' driver has
shorter, more efficient code paths while
'igb' and 'ixgbe' use significantly more
CPU to process the same number of packets.
I can quantify that if it is of interest.

At present the only place where multi-queue
NICs best four 1G NICs is at breaking-point
traffic loads where asymmetries in the traffic
can't be easily redistributed by the kernel
and the resulting hot-spots are weakest-link
breakpoints.

Please understand that I am not a curmudgeonly
Luddite.  I realize that sometimes it is
necessary to trade efficiency for scalability.
All I'm doing here is trying to quantify the
current state of affairs and make recommendations
in a commercial environment.  For the moment
all the excellent enhancements designed to
permit extreme scalability are costing too
much in efficiency to be worth using in
production.  When/if Tilera delivers their
100 core CPU in volume this state of affairs
will likely change.  I imagine both Intel
and AMD have many-core solutions in the pipe
as well, though it will be interesting to see
if Tilera has the essential patents and can
surpass the two majors in the market and the
courts.
