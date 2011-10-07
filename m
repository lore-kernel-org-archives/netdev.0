From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Fri, 07 Oct 2011 14:37:47 -0400
Message-ID: <6.2.5.6.2.20111007143050.039bd578@binnacle.cx>
References: <6.2.5.6.2.20111006231958.039bb570@binnacle.cx>
 <1317966007.3457.47.camel@edumazet-laptop>
 <6.2.5.6.2.20111007020308.039be248@binnacle.cx>
 <CAAsGZS4s1wTWW1j7FRUWW9jqpPUVF3Q46AMa7+njvE1ckX0Snw@mail.gmail.com> <CAAsGZS4s1wTWW1j7FRUWW9jqpPUVF3Q46AMa7+njvE1ckX0Snw
 @mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
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
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.binnacle.cx ([74.95.187.105]:7585 "EHLO mx.binnacle.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774Ab1JGSr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 14:47:56 -0400
In-Reply-To: <CAAsGZS4s1wTWW1j7FRUWW9jqpPUVF3Q46AMa7+njvE1ckX0Snw
 @mail.gmail.com>
References: <6.2.5.6.2.20111006231958.039bb570@binnacle.cx>
 <1317966007.3457.47.camel@edumazet-laptop>
 <6.2.5.6.2.20111007020308.039be248@binnacle.cx>
 <CAAsGZS4s1wTWW1j7FRUWW9jqpPUVF3Q46AMa7+njvE1ckX0Snw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At 02:09 PM 10/7/2011 -0400, chetan loke wrote:
>I'm a little confused. Seems like there are
>conflicting goals. If you want to bypass the
>kernel-protocol-stack then you have the following
>options: a) kernel af_packet. This is where we
>would get a chance to test all the kernel features
>etc.

Perhaps I haven't been sufficiently clear.
The "packet socket" mode I refer to in the
earlier post was using AF/PF_PACKET mode sockets
as in

   socket(PF_PACKET, SOCK_RAW, eth_p_all);

Have run it in both normal and memory mapped
modes.  MMAP mode is a slight bit more expensive
due to the cache pressure from the additional
copy.  On the 6174 MMAP seems to be a smidgen
better in certain tests, but in the end both
read() and mapped approaches are effectively
identical on performance--and generally match
the cost of UDP sockets almost exactly.

b) Use non-commodity(?) NICs(from vendors
>you mentioned): where it might have some on-board
>memory(cushion) and so it can absorb the spikes
>and can also smoothen out too many
>PCI-transactions for bursty (and small payload -
>as in 64 byte traffic). But wait, when you use the
>libs provided by these vendors, then their
>driver(especially the Rx path) is not so much
>working in inline mode as NIC drivers in case a)
>above. This driver with a special Rx-path purely
>exists for managing your mmap'd queues.So
>of-course it's going to be faster that the
>traditional inline drivers. In this partial-inline
>mode, the adapter might i) batch the packets and
>ii) send a single notification to the
>host-side. With that single event you are now
>processing 1+ packets.

Kernel bypass is probably the best answer for
what we do.  Problem has been lack of maturity
in their driver software.  Looks like it's reaching
a point where they cover our use case.  As mentioned
earlier, Solarflare could not match the Intel
82599 + ixgbe for this app last year.  Was a
disaster.  Myricom is focused on UDP (better
for us), but only just added multi-core IRQ
doorbell wakeups in recent months.  Previously
one had to accept all IRQs on a single core or
poll, neither of which works for us.

>You got it. In case of tilera there are two modes:
>tile-cpu in device mode: beats most of the
>non-COTS NICs. It runs linux on the adapter
>side. Imagine having the flexibility/power to
>program the ASIC using your favorite OS. Its
>orgasmic. So go for it!  tile-cpu in host-mode:
>Yes, it could be a game changer.

We almost went for the 1st gen Tile64 outboard
NIC approach, but were concerned about whether
they would survive--still are.  Intel has
crushed more than a few competitors along
the way.  If Google or Facebook buys into the
Tile-Gx it becomes a safe choice overnight.
