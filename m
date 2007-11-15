From: Urs Thuermann <urs.thuermann@gmx.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 15 Nov 2007 12:36:02 +0100
Message-ID: <ygfr6irbv19.fsf@janus.isnogud.escape.de>
References: <20071114121339.25823.0@janus.isnogud.escape.de>
	<20071114121425.25823.2@janus.isnogud.escape.de>
	<20071114133837.6b899595@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:46989 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762954AbXKOLkq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 06:40:46 -0500
In-Reply-To: <20071114133837.6b899595@freepuppy.rosehill>; from Stephen Hemminger on Wed, 14 Nov 2007 13:38:37 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> > +#ifdef CONFIG_CAN_DEBUG_CORE
> > +extern void can_debug_skb(struct sk_buff *skb);
> > +extern void can_debug_cframe(const char *msg, struct can_frame *cframe);
> > +#define DBG(fmt, args...)  (DBG_VAR & 1 ? printk( \
> > +					KERN_DEBUG DBG_PREFIX ": %s: " fmt, \
> > +					__func__, ##args) : 0)
> > +#define DBG_FRAME(fmt, cf) (DBG_VAR & 2 ? can_debug_cframe(fmt, cf) : 0)
> > +#define DBG_SKB(skb)       (DBG_VAR & 4 ? can_debug_skb(skb) : 0)
> > +#else
> > +#define DBG(fmt, args...)
> > +#define DBG_FRAME(fmt, cf)
> > +#define DBG_SKB(skb)
> > +#endif
> 
> 
> This non-standard debugging seems like it needs a better interface.
> Also, need paren's around (DBG_VAR & 1) and don't use UPPERCASE for
> variable names.

No additional parenthesis is needed here.  ?: is the lowest precedence
operator above assignment and ,.  Also, DBG_VAR is no variable name.
It's a macro that expands to a variable name like can_debug, raw_debug
or bcm_debug.

> > +HLIST_HEAD(rx_dev_list);
> 
> Please either make rx_dev_list static or call it can_rx_dev_list
> to avoid name conflices.
> 
> 
> > +static struct dev_rcv_lists rx_alldev_list;
> > +static DEFINE_SPINLOCK(rcv_lists_lock);
> > +
> > +static struct kmem_cache *rcv_cache __read_mostly;
> > +
> > +/* table of registered CAN protocols */
> > +static struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
> > +static DEFINE_SPINLOCK(proto_tab_lock);
> > +
> > +struct timer_list stattimer; /* timer for statistics update */
> > +struct s_stats  stats;       /* packet statistics */
> > +struct s_pstats pstats;      /* receive list statistics */
> 
> More global variables without prefix.

These variables are not exported with EXPORT_SYMBOL, so there should
be no name conflict.  They cannot be made static because they are used
in af_can.c and proc.c.  Nevertheless we can prefix them with can_ if
you still think it's necessary.

> > +static int can_proc_read_stats(char *page, char **start, off_t off,
> > +			       int count, int *eof, void *data)
> > +{

> > +}
> 
> The read interface should use seq_file interface rather than
> formatting into page buffer.

Why?  For this simple function a page buffer is enough space and the
seq_file API would require more effort.  IMHO, seq_files offer
advantages if the proc file shows some sequence of data generated in
an iteration through some loop (see below).

> > +static int can_proc_read_reset_stats(char *page, char **start, off_t off,
> > +				     int count, int *eof, void *data)
> > +{

> > +}
> 
> Why not have a write interface to do the reset?

I haven't looked into writable proc files yet.  Will do so.

> > +static int can_proc_read_rcvlist(char *page, char **start, off_t off,
> > +				 int count, int *eof, void *data)
> > +{
> > +	/* double cast to prevent GCC warning */
> > +	int idx = (int)(long)data;

> > +}

This is were I would prefer sequence files.  However, the seq file
interface doesn't allow me to pass additional info like the `data'
argument.  This means I would have to write separate functions
instead.

> Output from checkpatch:
> 
> WARNING: do not add new typedefs
> #116: FILE: include/linux/can.h:41:
> +typedef __u32 canid_t;
> 
> WARNING: do not add new typedefs
> #124: FILE: include/linux/can.h:49:
> +typedef __u32 can_err_mask_t;

These typedef were considered OK in previous discussions on the list.

> ERROR: use tabs not spaces
> #498: FILE: net/can/af_can.c:159:
> +^I^I^I^I        " not implemented.\n", module_name);$

Fixed.

> WARNING: braces {} are not necessary for single statement blocks
> #1080: FILE: net/can/af_can.c:741:
> +	if (!proto_tab[proto]) {
> +		printk(KERN_ERR "BUG: can: protocol %d is not registered\n",
> +		       proto);
> +	}

Hm, isn't it common to use braces for single statements if they span
more than one line?

Thanks for your review.

urs
