From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Thu, 20 Sep 2007 13:06:21 -0700
Message-ID: <1190318781.26101.148.camel@localhost>
References: <20070920184323.3795.0@janus.isnogud.escape.de>
	 <20070920184532.3795.2@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3081 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbXITUGk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 16:06:40 -0400
In-Reply-To: <20070920184532.3795.2@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-09-20 at 20:43 +0200, Urs Thuermann wrote:
> +#define DBG(...)       (debug & 1 ? \
> +                              (printk(KERN_DEBUG "can-%s %s: ", \
> +                               IDENT, __func__), printk(args)) : 0)
> +#define DBG_FRAME(args...) (debug & 2 ? can_debug_cframe(args) : 0)
> +#define DBG_SKB(skb)       (debug & 4 ? can_debug_skb(skb) : 0)
> +#else
> +#define DBG(args...)
> +#define DBG_FRAME(args...)
> +#define DBG_SKB(skb)
> +#endif

Shouldn't these be like the more common

#define DBG(fmt, args...) \
do { \
	if (debug & 1) \
		printk(KERN_DEBUG "can-%s %s: " fmt, IDENT, __func__, ##args); \
} while (0)

#define DBG_FRAME(cf, fmt, args...) \
do { \
	if (debug & 2) \
		can_debug_cframe(cf, fmt, ##args); \
} while (0)

#define DBG_SKB(skb) \
do { \
	if (debug & 4) \
		can_debug_skb(skb); \
while (0)

> void can_debug_cframe(const char *msg, struct can_frame *cf, ...)

This prototype looks backwards to me.

msg is a printf format string.

I'd prefer something like this, which removes the unnecessary
kmalloc/kfree pairs or the equivalent conversions to functions.

#define can_debug_cframe(cf, fmt, arg...) \
do { \
	char buf[20]; \
	int dlc = cf->can_dlc; \
	if (dlc > 8) \
		dlc = 8; \
	if (cf->can_id & CAN_EFF_FLAG) \
		sprintf(buf, "<%08X> [%X] ", cf->can_id & CAN_EFF_MASK, dlc); \
	else \
		sprintf(buf, "<%03X> [%X] ", cf->can_id & CAN_SFF_MASK, dlc); \
	printk(KERN_DEBUG fmt, ##arg); \
	print_hex_dump(buf, DUMP_PREFIX_NONE, cf->data, dlc); \
} while (0)

and

#define can_debug_skb(skb) \
do { \
	pr_debug("skbuff at %p, dev: %d, proto: %04x\n", \
		 skb, skb->dev ? skb->dev->ifindex : -1, \
		 ntohs(skb->protocol)); \
	pr_debug("users: %d, dataref: %d, nr_frags: %d, " \
		 "h,d,t,e,l: %p %+d %+d %+d, %d\n", \
		 atomic_read(&skb->users), \
		 atomic_read(&(skb_shinfo(skb)->dataref)), \
		 skb_shinfo(skb)->nr_frags, \
		 skb->head, skb->data - skb->head, \
		 skb->tail - skb->head, skb->end - skb->head, skb->len); \
	print_hex_dump(KERN_DEBUG, "skb_head: ", DUMP_PREFIX_NONE, \
		       16, 1, skb->head, skb->end - skb->head); \ 
} while (0)

cheers, Joe

