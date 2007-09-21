From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 21 Sep 2007 12:35:37 +0200
Message-ID: <ygf8x705mrq.fsf@janus.isnogud.escape.de>
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
Received: from oker.escape.de ([194.120.234.254]:58022 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809AbXIUKky (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 06:40:54 -0400
In-Reply-To: <1190318781.26101.148.camel@localhost>; from Joe Perches on Thu, 20 Sep 2007 13:06:21 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:

> On Thu, 2007-09-20 at 20:43 +0200, Urs Thuermann wrote:
> > +#define DBG(...)       (debug & 1 ? \
> > +                              (printk(KERN_DEBUG "can-%s %s: ", \
> > +                               IDENT, __func__), printk(args)) : 0)
> > +#define DBG_FRAME(args...) (debug & 2 ? can_debug_cframe(args) : 0)
> > +#define DBG_SKB(skb)       (debug & 4 ? can_debug_skb(skb) : 0)
> > +#else
> > +#define DBG(args...)
> > +#define DBG_FRAME(args...)
> > +#define DBG_SKB(skb)
> > +#endif
> 
> Shouldn't these be like the more common
> 
> #define DBG(fmt, args...) \

When I wrote these macros we had one platform where we still used
linux-2.4 and gcc-2.95.3 and with that old gcc your macro def would
mean you can't use DBG with only one argument, like DBG("some string\n");
since gcc-2.95 would leave the , after __func__ followed by the
closing ")".  I didn't find a way with gcc-2.95 to make the format
string a separate macro argument (which I also wanted).  OK, that's
history now and linux-2.6 needs gcc-3/4 anyway, so I will change this.

> do { \
> 	if (debug & 1) \
> 		printk(KERN_DEBUG "can-%s %s: " fmt, IDENT, __func__, ##args); \
> } while (0)

I use "do { ... } while(0)" only for statements, not for expressions.
But I could have used the && instead of ?: operator.  I don't think
the "do { ... } while(0)" looks nicer or has any other advantage.

> > void can_debug_cframe(const char *msg, struct can_frame *cf, ...)
> 
> This prototype looks backwards to me.

You mean the order or `msg' and `cf'?  You want to switch them so that
the variable args follow immediately the format string?  Might make
sense, OTOH we wanted to have the message as the first argument.

> I'd prefer something like this, which removes the unnecessary
> kmalloc/kfree pairs or the equivalent conversions to functions.
> 
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

Ah, I didn't know print_hex_dump().  That looks nicer.  But as Thomas
mentioned, we shouldn't convert these functions into macros.

urs
