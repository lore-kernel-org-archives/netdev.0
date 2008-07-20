From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
	RCU.
Date: Sun, 20 Jul 2008 18:32:50 -0400
Message-ID: <1216593170.4847.137.camel@localhost>
References: <1216387641.4833.96.camel@localhost>
	 <20080718.140539.122169028.davem@davemloft.net>
	 <1216566963.4847.81.camel@localhost>
	 <20080720.102534.246150854.davem@davemloft.net>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080720.102534.246150854.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2008-20-07 at 10:25 -0700, David Miller wrote:

> They tend to implement round-robin or some similar fairness algorithm
> amongst the queues, with zero concern about packet priorities.

pfifo_fast would be a bad choice in that case, but even a pfifo cannot
guarantee proper RR because it would present packets in a FIFO order
(and example the first 10 could go to hardware queue1 and the next to
hardware queue2).
 
My view: i think you need a software queue per hardware queue.
Maybe even these queues residing in the driver; that way you take care
of congestion and it doesnt matter if the hardware is RR or strict prio
(and you dont need the pfifo or pfifo_fast anymore).
The use case would be something along:
packets comes in, you classify find its for queue1, grab the
per-hardware-queue1 lock, find the hardware queue1 is overloaded and
stash it instead in s/ware queue1. If it wasnt congested, it would go on
hardware queue1.
When hardware queue1 becomes available and netif-woken, you pick first
from s/ware queue1 (and batching could apply cleanly here) and send them
to hardware queue.

> It really is just like a bunch of queues to the phsyical layer,
> fairly shared.

I am suprised prioritization is not an issue. [My understanding of the
intel/cisco datacentre cabal is they serve virtual machines using
virtual wires; i would think in such scenarios youd have some customers
who pay more than others].

> These things are built for parallelization, not prioritization.

Total parallelization happens in the ideal case. If X cpus classify
packets going to X different hardware queueus each CPU grabs only locks
for that hardware queue. In virtualization, where only one customer's
traffic is going to a specific hardware queue, things would work well.
Non-virtualization scenario may result in collision in which two or more
CPUs may contend for the same hardware queue (either transmitting or
netif-waking etc).
 
cheers,
jamal

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
