From: jamal <hadi@cyberus.ca>
Subject: Re: ethernet QoS support?
Date: 12 Jul 2004 08:18:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089634701.1055.260.camel@jzny.localdomain>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com>
	 <200407091641.35651.vkondra@mail.ru>
	 <1089383622.1030.21.camel@jzny.localdomain>
	 <200407092126.43021.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200407092126.43021.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-07-09 at 14:26, Vladimir Kondratiev wrote:

> > Who marks the skb->priority? Is that the default mark as per TOS?
> > I think the VLAN code marks it as well.
> I don't care. It should not be driver's business. Actually, it is TOS. AFAIK, 
> application supposed to do setsockoption(SO_PRIORITY) on its socket so set 
> priority.

That or if routed from another host, then TOS does get extracted and set
to skb->priority


> Agree about intelligence. Driver should serve link and MAC layer. But exactly 
> because link layer have different priorities, driver need several Tx queues. 
> It is stack's business to route packet to the proper queue. Driver should 
> deliver it using appropriate MAC layer priority.

So far you have said there are two schedulers h/ware understands: strict
priority(3 band strict priority is the deafult in Linux) and WRR. 
The qdisc level is already taken care of today.


> Waiting. If no support will exist, it simply means we will be unable to use 
> QoS provided by modern 802.11. 

I think someone with motivation and hardware (such as you 
Vladimir ;->)should take the lead. I have offered to consult and review
code.

> Depending on market development, impact may 
> range from being slightly slower relating to Windows clients, to being almost 
> completely unable to communicate for traffic like VOIP. Later will be the 
> case if most access points will implement QoS as in TGE.
> 
> I can now deliver packets accordingly to skb->priority, but if stack have 
> different idea for what is proper proportion between different sorts of 
> traffic, driver's Tx path will be flooded with low priority frames.

I dont think so - as long as you map to a specific qdisc things should
work fine. i.e the scheduling semantics will be taken good care of by
the qdisc level.
So lets separate the two levels, driver and qdisc level.
I dont think they should be synchronized. In my opinion, the
synchronization point is the configurator/operator/management s/ware of
the box.

> Situation is much worser for streams with admission control. I have no 
> mechanism to communicate with stack for such traffic establishment and tear 
> down.

Let me make an interim suggestion:
To illustrate i will assume 3 priorities with priority 1 higher than
priority 3. Substitute with whatever driver does. Assuming the
priorities will be reflected in the skb->priority.

- Shut down device only when highest(1) priority ring is full.
- if packets received for priority 2 and 3 and their respective rings
are full, drop the packet in the driver and return a 0 i.e dont shut
device.

You can also do the following in the case of strict priority(caveat is
reordering may happen):
for each prio X try to stash on DMA ring of prio X. If full, try X+1, if
full try X+2 etc.

Thoughts?

cheers,
jamal
