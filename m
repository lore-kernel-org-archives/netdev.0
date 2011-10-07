From: chetan loke <loke.chetan@gmail.com>
Subject: Re: big picture UDP/IP performance question re 2.6.18 -> 2.6.32
Date: Fri, 7 Oct 2011 14:09:20 -0400
Message-ID: <CAAsGZS4s1wTWW1j7FRUWW9jqpPUVF3Q46AMa7+njvE1ckX0Snw@mail.gmail.com>
References: <6.2.5.6.2.20111006231958.039bb570@binnacle.cx>
	<1317966007.3457.47.camel@edumazet-laptop>
	<6.2.5.6.2.20111007020308.039be248@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christoph Lameter <cl@gentwo.org>, Willy Tarreau <w@1wt.eu>,
	Ingo Molnar <mingo@elte.hu>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Joe Perches <joe@perches.com>, lokechetan@gmail.com,
	Con Kolivas <conman@kolivas.org>,
	Serge Belyshev <belyshev@depni.sinp.msu.ru>
To: starlight@binnacle.cx
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6.2.5.6.2.20111007020308.039be248@binnacle.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 7, 2011 at 2:13 AM,  <starlight@binnacle.cx> wrote:
> At 07:40 AM 10/7/2011 +0200, Eric Dumazet wrote:
>>
>>Thats exactly the opposite : Your old kernel is not fast enough
>>to enter/exit NAPI on every incoming frame.
>>
>>Instead of one IRQ per incoming frame, you have less interrupts:
>>A napi run processes more than 1 frame.
>
> Please look at the data I posted. =C2=A0Batching
> appears to give 80us *better* latency in this
> case--with the old kernel.
>

Wait till we get to a point where we can use fanout+tpacket_v3 and
then hopefully we will have eased the burden from folks where for
particular use-cases they have to mimic this in user-land. Just a FYI
and not related to this thread: A month ago or so, I quickly
tried(using David's sample fanout app-code) fanout+tpacket_v3 and the
combo-mode wasn't quite working as expected. Not sure but might need
to visit the kernel-mmap-logic to create multiple mmap'd rings in the
kernel if fanout+tpacket_v3 is being used.



> Yes, of course I am interested in Intel's flow
> director and similar solutions, netfilter especially.
> 2.6.32 is only recently available in commercial
> deployment and I will be looking at that next up.
> Mainly I'll be looking at complete kernel bypass
> with 10G. =C2=A0Myricom looks like it might be good.
> Tested Solarflare last year and it was a bust
> for high volume UDP (one thread) but I've heard
> that they fixed that and will revisit.

I'm a little confused. Seems like there are conflicting goals. If you
want to bypass the kernel-protocol-stack then you have the following
options:
a) kernel af_packet. This is where we would get a chance to test all
the kernel features etc.
b) Use non-commodity(?) NICs(from vendors you mentioned): where it
might have some on-board memory(cushion) and so it can absorb the
spikes and can also smoothen out too many PCI-transactions for bursty
(and small payload - as in 64 byte traffic). But wait, when you use
the libs provided by these vendors, then their driver(especially the
Rx path) is not so much working in inline mode as NIC drivers in case
a) above. This driver with a special Rx-path purely exists for
managing your mmap'd queues.So of-course it's going to be faster that
the traditional inline drivers. In this partial-inline mode, the
adapter might i) batch the packets and ii) send a single notification
to the host-side. With that single event you are now processing 1+
packets.

And now we can't really compare a) and b) because the drivers are
working in different modes. i.e inline and partial-inline mode
respectively. In case a) you might get notifications for every-packet.
So you are now stressing the process-scheduler, networking-stack etc.
In case b) you might not be able to stress all the kernel-paths. Also,
you get what you pay. If you pay 2x or 3x the cost for a non-COTS NIC
then you can push the vendors for implementing auto-coalescing and
what not on the adapter side. For case a), networking-stack needs to
keep up with whatever firmware we get from the vendor. Also, bugs if
any, can't be fixed the community for case b). So there's a tradeoff.

Sure, we need to see where small changes elsewhere in the kernel are
causing a huge penalty for user-space but you get the point.


> Please understand that I am not a curmudgeonly
> Luddite. =C2=A0I realize that sometimes it is
> necessary to trade efficiency for scalability.
> All I'm doing here is trying to quantify the
> current state of affairs and make recommendations
> in a commercial environment. =C2=A0For the moment
> all the excellent enhancements designed to
> permit extreme scalability are costing too
> much in efficiency to be worth using in
> production. =C2=A0When/if Tilera delivers their
> 100 core CPU in volume this state of affairs
> will likely change. =C2=A0I imagine both Intel
> and AMD have many-core solutions in the pipe
> as well, though it will be interesting to see
> if Tilera has the essential patents and can
> surpass the two majors in the market and the
> courts.
>

You got it. In case of tilera there are two modes:
tile-cpu in device mode: beats most of the non-COTS NICs. It runs
linux on the adapter side. Imagine having the flexibility/power to
program the ASIC using your favorite OS. Its orgasmic. So go for it!
tile-cpu in host-mode: Yes, it could be a game changer.


Chetan Loke
