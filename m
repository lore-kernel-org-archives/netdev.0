From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] net: add Documentation/networking/scaling.txt
Date: Thu, 11 Aug 2011 11:02:18 -0700
Message-ID: <4E44192A.2070204@hp.com>
References: <1312899648.5889.14.camel@gopher.nyc.corp.google.com>	<4E418030.2010102@hp.com>	<CA+FuTSfCp+Ju6YAGvPUzkLXiMFqV8XZV_SOueW5bwxeaeD1vng@mail.gmail.com> <1313080279.3261.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Will de Bruijn <willemb@google.com>, rdunlap@xenotime.net,
	linux-doc@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, therbert@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1313080279.3261.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/11/2011 09:31 AM, Eric Dumazet wrote:
> Le jeudi 11 ao=C3=BBt 2011 =C3=A0 10:26 -0400, Will de Bruijn a =C3=A9=
crit :
>
>>
>> I'll be happy to revise it once more. This version also lacks the
>> required one-line description in Documentation/networking/00-INDEX, =
so
>> I will have to resubmit, either way.
>>
>
> Well, patch was already accepted by David in net tree two days ago ;)

Didn't see the customary "Applied" email - mailer glitch somewhere?

Anyhow, regardless of how further changes are made, or if they are made=
,=20
here's the bits I was considering might a matter of opinion, or perhaps=
=20
simply stripes on the bikeshed...

<rss>
> +=3D=3D Suggested Configuration
> +
> +RSS should be enabled when latency is a concern or whenever receive
> +interrupt processing forms a bottleneck. Spreading load between CPUs
> +decreases queue length. For low latency networking, the optimal sett=
ing
> +is to allocate as many queues as there are CPUs in the system (or th=
e
> +NIC maximum, if lower). Because the aggregate number of interrupts g=
rows
> +with each additional queue, the most efficient high-rate configurati=
on
> +is likely the one with the smallest number of receive queues where n=
o
> +CPU that processes receive interrupts reaches 100% utilization. Per-=
cpu
> +load can be observed using the mpstat utility.

Whether it lowers latency in the absence of an interrupt processing=20
bottleneck depends on whether or not the application(s) receiving the=20
data are able/allowed to run on the CPU(s) to which the IRQs of the=20
queues are directed right?

Also, what mpstat and its ilk shows as CPUs could be HW threads - is it=
=20
indeed the case that one is optimal when there are as many queues as=20
there are HW threads, or is it when there are as many queues as there=20
are discrete cores?

If I have disabled interrupt coalescing in the name of latency, does th=
e=20
number of queues actually affect the number of interrupts?

Certainly any CPU processing interrupts that stays below 100%=20
utilization is less likely to be a bottleneck, but if there are=20
algorithms/heuristics that get more efficient under load, staying below=
=20
the 100% CPU utilization mark doesn't mean that peak efficiency has bee=
n=20
reached.  If there is something that processes more and more packets pe=
r=20
lock grab/release then it is actually most efficient in terms of packet=
s=20
processed per unit CPU consumption once one gets to the ragged edge of=20
saturation.

Is utilization of the rx ring associated with the queue the more=20
accurate, albeit unavailable, measure of saturation?

<rps>
> +=3D=3D Suggested Configuration
> +
> +For a single queue device, a typical RPS configuration would be to s=
et
> +the rps_cpus to the CPUs in the same cache domain of the interruptin=
g
> +CPU. If NUMA locality is not an issue, this could also be all CPUs i=
n
> +the system. At high interrupt rate, it might be wise to exclude the
> +interrupting CPU from the map since that already performs much work.
> +
> +For a multi-queue system, if RSS is configured so that a hardware
> +receive queue is mapped to each CPU, then RPS is probably redundant
> +and unnecessary. If there are fewer hardware queues than CPUs, then
> +RPS might be beneficial if the rps_cpus for each queue are the ones =
that
> +share the same cache domain as the interrupting CPU for that queue.

This isn't the first mention of "cache domain" - there is actually one=20
above it in the RSS Configuration section, but is the anticipated=20
audience reasonably expected to already know what a cache domain is,=20
particularly as it may relate/differ from NUMA locality?

A very simplistic search for "cache domain" against Documentation/=20
doesn't find that term used anywhere else.

<rfs>
> +When the scheduler moves a thread to a new CPU while it has outstand=
ing
> +receive packets on the old CPU, packets may arrive out of order. To
> +avoid this, RFS uses a second flow table to track outstanding packet=
s
> +for each flow: rps_dev_flow_table is a table specific to each hardwa=
re
> +receive queue of each device. Each table value stores a CPU index an=
d a
> +counter. The CPU index represents the *current* CPU onto which packe=
ts
> +for this flow are enqueued for further kernel processing. Ideally, k=
ernel
> +and userspace processing occur on the same CPU, and hence the CPU in=
dex
> +in both tables is identical. This is likely false if the scheduler h=
as
> +recently migrated a userspace thread while the kernel still has pack=
ets
> +enqueued for kernel processing on the old CPU.

This one is more drift than critique of the documentation itself, but=20
just how often is the scheduler shuffling a thread of execution around=20
anyway?  I would have thought that was happening on a timescale that=20
would seem positively glacial compared to packet arrival rates.

<accelerated rfs>
> +=3D=3D Suggested Configuration
> +
> +This technique should be enabled whenever one wants to use RFS and t=
he
> +NIC supports hardware acceleration.

Again, drifting from critique simply of the documentation, but if=20
accelerated RFS is indeed goodness when RFS is being used and the NIC H=
W=20
supports it, shouldn't it be enabled automagically?  And then drifting=20
back to the documentation itself, if accelerated RFS isn't enabled=20
automagically with RFS today, does the reason suggest a caveat to the=20
suggested configuration?

<xps>
> +The queue chosen for transmitting a particular flow is saved in the
> +corresponding socket structure for the flow (e.g. a TCP connection).
> +This transmit queue is used for subsequent packets sent on the flow =
to
> +prevent out of order (ooo) packets. The choice also amortizes the co=
st
> +of calling get_xps_queues() over all packets in the connection. To a=
void
> +ooo packets, the queue for a flow can subsequently only be changed i=
f
> +skb->ooo_okay is set for a packet in the flow. This flag indicates t=
hat
> +there are no outstanding packets in the flow, so the transmit queue =
can
> +change without the risk of generating out of order packets. The
> +transport layer is responsible for setting ooo_okay appropriately. T=
CP,
> +for instance, sets the flag when all data for a connection has been
> +acknowledged.

I'd probably go with "over all packets in the flow" as that part is in=20
the "generic" discussion space rather than the specific example of a TC=
P=20
connection.

And I'm curious/confused about rates of thread migration vs packets - i=
t=20
seems like the mechanisms in place to avoid OOO packets have a property=
=20
that the queue selected can remain "stuck" when the packet rates are=20
sufficiently high.  If being stuck isn't likely, it suggests that=20
"normal" processing is enough to get packets drained - that the thread=20
of execution is (at least in the context of sending and receiving=20
traffic) going idle.  Is that then consistent with that thread of=20
execution being bounced from CPU to CPU by the scheduler in the first p=
lace?

In the specific example of TCP, I see where ACK of data is sufficient t=
o=20
guarantee no OOO on outbound when migrating, but all that is really=20
necessary is transmit completion by the NIC, no?  Admittedly, getting=20
that information to TCP is probably undesired overhead, but doesn't=20
using the ACK "penalize" the thread/TCP talking to more remote (in term=
s=20
of RTT) destinations?

rick jones
