From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: Generic rx-recycling and emergency skb pool
Date: Thu, 26 Aug 2010 19:31:08 +0200
Message-ID: <20100826173108.GA32294@Chamillionaire.breakpoint.cc>
References: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
 <1278138205.2474.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org, tglx@linutronix.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:39898 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751985Ab0HZRbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 13:31:10 -0400
Content-Disposition: inline
In-Reply-To: <1278138205.2474.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2010-07-03 08:23:25 [+0200]:

>Sebastian
Eric,

>Most modern NICS are multiqueue, so that each cpu can use a queue on its
>own without slowing down other cpus.
True. gianfar uses multiqueue howver in its napi poll one CPU grabs a
locks and inspects every queue one by one.

>Yet rx recycling has one queue per device, defeating part of the
>multiqueue goal.
Well, we could add rx recycling per queue if you prefer it that way.

>Patch 6/8 even touches dev->refcnt on each emerg packet
>Patch 6/8 adds 8 bytes (emerg_dev) to skb. Oh well...
>
>Adding cache layers, especially dumb ones like this one, is probably the
>sign something more fundamental is broken somewhere.

The memory for the skbs is comming from slab. slab's latency is getting
quite high on memory pressure. Therefore I try to avoid talking to slab
while I'm allocating a new skb. So I created a pool of pre-allocated.

>I do believe for example that netdev_alloc_skb() should not try to use
>the node affinity of the device, but use current cpu node for sk_buff at
>least, and possibly for data part too.
>
>One other problem of skb are the two memory blocs involved, and fact
>that first one (skb) is already very big and fat, and filled/dirtied
>many cycles before its use in RX path.
>
>Maybe its time to provide new API, so that a driver can build an skb at
>the time RX interrupt is handled, not at the time the rx ring buffer is
>renewed. RX ring should only provide the data part to NIC, and skb
>should be built when NIC delivers the frame, so that we provide to IP
>stack a real hot skb.

And where are you allocating the memory from? Remember, SLAB could be
slow :)

Sebastian
