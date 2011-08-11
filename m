From: Will de Bruijn <willemb@google.com>
Subject: Re: [PATCH v2] net: add Documentation/networking/scaling.txt
Date: Thu, 11 Aug 2011 17:34:05 -0400
Message-ID: <CA+FuTSc3mcL6i8J2CBvbOui1xLNDHPf0DJj=NorSduvRLq+vbg@mail.gmail.com>
References: <1312899648.5889.14.camel@gopher.nyc.corp.google.com>
 <4E418030.2010102@hp.com> <CA+FuTSfCp+Ju6YAGvPUzkLXiMFqV8XZV_SOueW5bwxeaeD1vng@mail.gmail.com>
 <1313080279.3261.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4E44192A.2070204@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, rdunlap@xenotime.net,
	linux-doc@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, therbert@google.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4E44192A.2070204@hp.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Well, patch was already accepted by David in net tree two days ago ;=
)
>
> Didn't see the customary "Applied" email - mailer glitch somewhere?
>

I didn't catch that either. Since it's already in, I instead wrote a
patch set where
[1/2] adds one-liners to 00-INDEX for scaling.txt and all other
missing entries (I had no idea how many there were when I started)
[2/2] fixes the few text-related issues that Rick raised below.

Will send them out shortly.

> <rss>
> Whether it lowers latency in the absence of an interrupt processing
> bottleneck depends on whether or not the application(s) receiving the=
 data
> are able/allowed to run on the CPU(s) to which the IRQs of the queues=
 are
> directed right?

The latency saved would be the time spent in the interrupt handler.
With multiple application threads, this delay is reduced if packets
are spread between interrupt service routines on different CPUs. These
savings, if any, are irrespective of where the application threads are
run. I have no data for the practical savings in absence of a
bottleneck: it could be inconsequential.

> Also, what mpstat and its ilk shows as CPUs could be HW threads - is =
it
> indeed the case that one is optimal when there are as many queues as =
there
> are HW threads, or is it when there are as many queues as there are d=
iscrete
> cores?

In my experience, cores. I'll add a brief statement on HT.

> If I have disabled interrupt coalescing in the name of latency, does =
the
> number of queues actually affect the number of interrupts?

Good point: I suppose it doesn't.

> Certainly any CPU processing interrupts that stays below 100% utiliza=
tion is
> less likely to be a bottleneck, but if there are algorithms/heuristic=
s that
> get more efficient under load, staying below the 100% CPU utilization=
 mark
> doesn't mean that peak efficiency has been reached. =A0If there is so=
mething
> that processes more and more packets per lock grab/release then it is
> actually most efficient in terms of packets processed per unit CPU
> consumption once one gets to the ragged edge of saturation.

a busy polling CPU would be an example where measuring utilization is
useless. But for default interrupt-based device driver operation,
utilization of a CPU dedicated exclusively to HW interrupt processing
is indicative of overflow.

> Is utilization of the rx ring associated with the queue the more accu=
rate,
> albeit unavailable, measure of saturation?

measuring overflow here could be an interesting alternative.

> This isn't the first mention of "cache domain"

I will add a definition on first use.

> This one is more drift than critique of the documentation itself, but=
 just
> how often is the scheduler shuffling a thread of execution around any=
way? =A0I
> would have thought that was happening on a timescale that would seem
> positively glacial compared to packet arrival rates.

I didn't contribute to the evaluation or implementation, so cannot
answer decisively (just happen to have written a user's guide for
colleagues that could be reworked into this)

> Again, drifting from critique simply of the documentation, but if
> accelerated RFS is indeed goodness when RFS is being used and the NIC=
 HW
> supports it, shouldn't it be enabled automagically? =A0And then drift=
ing back
> to the documentation itself, if accelerated RFS isn't enabled automag=
ically
> with RFS today, does the reason suggest a caveat to the suggested
> configuration?

It probably should be enabled automatically, indeed.

> I'd probably go with "over all packets in the flow"

will change that.

> And I'm curious/confused about rates of thread migration vs packets -=
 it
> seems like the mechanisms in place to avoid OOO packets have a proper=
ty that
> the queue selected can remain "stuck" when the packet rates are suffi=
ciently
> high.

It sounds like that, yes.

> If being stuck isn't likely, it suggests that "normal" processing is
> enough to get packets drained - that the thread of execution is (at l=
east in
> the context of sending and receiving traffic) going idle.

Not necessarily, if a single thread processes many connections at
once. State is kept on a per connection basis in the sk struct.

> In the specific example of TCP, I see where ACK of data is sufficient=
 to
> guarantee no OOO on outbound when migrating, but all that is really
> necessary is transmit completion by the NIC, no? =A0Admittedly, getti=
ng that
> information to TCP is probably undesired overhead, but doesn't using =
the ACK
> "penalize" the thread/TCP talking to more remote (in terms of RTT)
> destinations?

Probably, but perhaps someone with more intimate knowledge of the
implementation should answer definitely.
