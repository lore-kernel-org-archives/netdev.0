From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sun, 03 Jun 2007 20:27:17 +0200
Message-ID: <46630805.9070309@trash.net>
References: <20070530131123.10843.0@janus.isnogud.escape.de>	<20070530131204.10843.5@janus.isnogud.escape.de>	<465DB0B6.109@trash.net> <ygfsl9azsji.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50201 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbXFCS3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2007 14:29:42 -0400
In-Reply-To: <ygfsl9azsji.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>>And it allows you have both loopback and non-loopback devices
>>in case that would be useful.
> 
> 
> That sounds very promising.  I also was unhappy with the fixed number
> of vcan devices at module load time and have thought about ioctl's to
> add/delete devices and to change the loopback flag.  A more general
> approach like the one you seem to be working on is preferable of
> course.


I got a bit delayed, but I hope to have the patches in postable state
tommorrow.

>>Qdiscs might change skb->cb. Maybe use skb->sk?
> 
> 
> When we decided to use skb->cb it seemed the only possible option.
> We need a field that we can set to zero to indicate we don't want the
> driver to loop back the packet and the value in that field must
> survive the path
> 
>         can_send()
>         dev_queue_xmit()
>         ...
>         dev->hard_start_xmit()
>         
>         netif_rx()
>         can_rcv()
> 
> I think I misread the comment
> 
>  *      @cb: Control buffer. Free for use by every layer. Put private vars here
> 
> to mean I can use it for this purpose and since it worked as intended
> we felt ok with this.  Now I see, it states exactly the opposite that
> I can't count on the value being preserved across layers.


Yes, that comment is a bit misleading.

> skb->sk can't be used since we shouldn't set it to zero before
> dev_queue_xmit() as Oliver already pointed out.  IIRC, skb->sk
> couldn't also be used in rx half of that path, since it was set to
> null somewhere in netif_rx() but now, reading the src, I can't see
> where this would happen.  Maybe this has changed or my memory has some
> bit errors.  I'll look at it again.  Even if it turns out skb->sk can
> be used in rx path, the need remains to pass down a flag from
> can_send() to dev->hard_start_xmit() indicating whether to loop back
> or not.


That flag is a socket flag acording to Oliver, so you can use the flag
itself. You could keep skb->sk for the RX path (don't call skb_orphan
in your hard_start_xmit function), if that doesn't work worst case would
be to use a flag in the skb (we still have 2 unused bits) until you've
figured out a better way.
