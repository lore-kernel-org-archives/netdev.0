From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: in-driver QoS
Date: Tue, 8 Jun 2004 11:48:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608184831.GA18462@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vladimir Kondratiev wrote :
> 
> In 802.11 network, there is TGe (or 802.11e), working group, developing QoS 
> extensions for 802.11.

	802.11e is about prioritisation of the traffic, not QoS. QoS
is about bandwidth reservation and enforcement of policies, and
802.11e does none of that.

> Now, question is: how will we support these QoS features in network stack?

	Simple : Linux driver should always send traffic at the
highest priority, and never use the lowest priority. This way, we are
guaranteed to always get the highest performance, and get higher
benchmarks than Win32 or other OSes.

> skb->priority help determining Tx queue, but fundamental problem is with 
> single Tx queue from network stack.

	Andi already corrected you about the fact that the net layer
can offer multiple queue. If you look in .../net/sched/, you will see
that skb->priority is used intensively, even for the generic
scheduler. Most often, skb->priority is derived from sk->sk_priority,
which is the socket priority.

Andi Kleen wrote :
> It already has that kind of in the form of arbitary qdiscs. The trick
> will be only to do all queueing in the qdisc and keep the hardware
> queue length as small as possible.

	I fully agree with that statement. One of the advantage of TC
is that it enforces policies, which is more like real QoS.
	Note that the netdev queue is potentially larger than the
hardware queue, especially with the recent increase due to Gigabit
Ethernet, so there is more gain to be expected scheduling the netdev
queue than the hardware queue in case of congestion.

> Disadvantage will be more use of CPU time to refill driver
> queues.

	More precisely, you increase the Tx-done interrupt frequency,
so the number of context switches. The time to refill the queues
remain the same. But, interrupt mitigation seems like a good thing in
general.

> BTW the standard qdisc pfifo_fast already has three queues,
> selected by the old TOS.

	TOS is part of the IP header, and you don't want to read IP
headers in the link layer, it's a clear layer violation. I think using
skb->priority is a better way.

Vladimir Kondratiev wrote :
> 
> How could I use these multiple qdiscs?

	You need to enable "advanced router" in ***config and check
pointers in this excellent howto :
		http://linux-ip.net/html/index.html
		(see section I.1.12)

> I.e. I have 4 queues in the driver, I want to fill it separately,
> start/stop incoming queues from stack etc.

	The driver is not the one deciding the policy, the network
stack is. Therefore the driver accept whatever packet the network
scheduler decide to give it and store it in the most appropriate
queue (based on some meta-information such as skb->priority).
	This way the behavior of the driver is simple and predictable,
you don't need to implement intserv/diffserv in the driver, and you
can easily plug any scheduling you decide on top of it by
reconfiguring the network stack.

	Have fun...

	Jean
