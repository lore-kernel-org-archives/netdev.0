From: jamal <hadi@cyberus.ca>
Subject: Re: in-driver QoS
Date: 15 Jun 2004 08:26:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1087302412.1042.46.camel@jzny.localdomain>
References: <20040608184831.GA18462@bougret.hpl.hp.com>
	 <200406111619.40260.vkondra@mail.ru>
	 <1086960639.1068.697.camel@jzny.localdomain>
	 <200406142353.28277.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200406142353.28277.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-06-14 at 16:53, Vladimir Kondratiev wrote:
> Jamal,
> let's list the features need to be provided for 802.11 QoS, and problems.
> 
> It is worth to provide standard interface with wireless stack; otherwise each 
> driver will invent its own solution.
> 
> 1. NIC have number of Tx DMA channels, with different channels used for 
> different priorities. It is dictated by standard (TGe).
> 
> Most likely, it should be 4 queues for EDCA traffic (4 priorities), 1 for HCCA 
> (polled, pre-agreed streams) and optionally 1 for multicast traffic (AP need 
> it).
> 
> Each queue need to start/stop separately. For flexibility, it should be some 
> way for driver to request queues and specify mapping to these queues.
> 
> Ideas for how to implement it in stack?

Refer to my earlier note on implementation. 
The only challenge is in starting and stopping each hardware DMA/FIFO
separately. Thats whats missing today.
The mapping between s/ware level queues and DMA/FIFO level is done via
skb tags and is enforced via tc policies entered by the admin. Some of
the current tags could be used or a new one created just for this.

> Meanwhile, ideas how to get separate per-priority control with existing 
> infrastructure?

like i said the qdisc infrastruture is in place.

> 2. There is traffic that require admission control. Unless driver performs 
> allocation with AP, this traffic is not allowed. 

Is this admission control something like 802.1x/EAP?
I think stuff like that belongs to user space. You could use the new tc
extensions i have to redirect packets to a user space process which then
installs tc policies based on some compute the user space app does (eg
lookup some LDAP/RADIUS attributes etc)

> TGe standard dictates it.
> 
> Driver should participate in bandwidth allocation (via RSVP?). It should get 
> some form of request (IOCTL?) which it will serve by performing allocation on 
> link layer. It is easy to do proprietary IOCTL and white custom RSVP daemon, 
> but it is much better to do something generic for all drivers to use.

There is nothing new here as far as linux is concerned. Driver doesnt
participate in any of this directly. Traffic control is done by a layer
above driver. By the time the packet gets to the driver, it just looks
at the skb tag and maps it to the right DMA/FIFO (may stop the
netif_queue for the FIFO etc)
I dont know many people running RSVP or COPS for that matter. But we
have the mechanisms for them in place. I know a lot of fscked people who
will wanna do this via SNMP. And dont forget your bash scripts of
course.
Now imagine you trying to make all the above be aware of whatever your
driver is supposed to be doing via ioctls. Not a very scalable idea.

cheers,
jamal
