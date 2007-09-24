From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 24 Sep 2007 21:23:36 +0200
Message-ID: <ygflkavj29z.fsf@janus.isnogud.escape.de>
References: <20070920184323.3795.0@janus.isnogud.escape.de>
	<20070920184532.3795.2@janus.isnogud.escape.de>
	<1190318781.26101.148.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:35313 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759479AbXIXTZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 15:25:51 -0400
In-Reply-To: <1190318781.26101.148.camel@localhost>; from Joe Perches on Thu, 20 Sep 2007 13:06:21 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:

> I'd prefer something like this, which removes the unnecessary
> kmalloc/kfree pairs or the equivalent conversions to functions.

I have changed this to a static buffer.  Since this is only in
#ifdef CONFIG_CAN_DEBUG_CORE, it shouldn't hurt.

> #define can_debug_cframe(cf, fmt, arg...) \
> do { \
> 	char buf[20]; \
> 	int dlc = cf->can_dlc; \
> 	if (dlc > 8) \
> 		dlc = 8; \
> 	if (cf->can_id & CAN_EFF_FLAG) \
> 		sprintf(buf, "<%08X> [%X] ", cf->can_id & CAN_EFF_MASK, dlc); \
> 	else \
> 		sprintf(buf, "<%03X> [%X] ", cf->can_id & CAN_SFF_MASK, dlc); \
> 	printk(KERN_DEBUG fmt, ##arg); \
> 	print_hex_dump(buf, DUMP_PREFIX_NONE, cf->data, dlc); \
> } while (0)

The line isn't printed atomically, i.e. it could happen that something
is printed between the fmt+args and the hexdump, i.e inbetween the
line.

> and
> 
> #define can_debug_skb(skb) \
> do { \
> 	pr_debug("skbuff at %p, dev: %d, proto: %04x\n", \
> 		 skb, skb->dev ? skb->dev->ifindex : -1, \
> 		 ntohs(skb->protocol)); \
> 	pr_debug("users: %d, dataref: %d, nr_frags: %d, " \
> 		 "h,d,t,e,l: %p %+d %+d %+d, %d\n", \
> 		 atomic_read(&skb->users), \
> 		 atomic_read(&(skb_shinfo(skb)->dataref)), \
> 		 skb_shinfo(skb)->nr_frags, \
> 		 skb->head, skb->data - skb->head, \
> 		 skb->tail - skb->head, skb->end - skb->head, skb->len); \
> 	print_hex_dump(KERN_DEBUG, "skb_head: ", DUMP_PREFIX_NONE, \
> 		       16, 1, skb->head, skb->end - skb->head); \ 
> } while (0)

Here, the consecutive lines aren't printed atomically.

I think sprintf() to a buffer first and the do one printk() is
better.  But I will use hex_dump_to_buffer().


urs
