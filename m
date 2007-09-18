From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 18 Sep 2007 23:20:51 +0200
Message-ID: <ygffy1bzn4c.fsf@janus.isnogud.escape.de>
References: <20070917100321.18347.0@janus.isnogud.escape.de>
	<20070917100438.18347.2@janus.isnogud.escape.de>
	<46EFD33D.8030905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs@isnogud.escape.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:58129 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753855AbXIRVZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 17:25:47 -0400
In-Reply-To: <46EFD33D.8030905@trash.net>; from Patrick McHardy on Tue, 18 Sep 2007 15:31:41 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> > +++ net-2.6.24/include/linux/can.h	2007-09-17 10:27:09.000000000 +0200

> Is this file used only from within the kernel? If so you could use
> the nicer-to-look-at u8/u16/u32 types instead of the double underscored
> ones.

No, this file contains the interface to user space.

> > +++ net-2.6.24/include/linux/can/core.h	2007-09-17 11:08:39.000000000 +0200
> > @@ -0,0 +1,78 @@
> > +
> > +extern int can_proto_register(struct can_proto *cp);
> > +extern int can_proto_unregister(struct can_proto *cp);
> 
> 
> The callers of the unregister function don't check the return code,
> and they can't handle errors anyways since they use it in the
> module unload path, so making it void seems more appropriate
> (and maybe a WARN_ON for the "not-found" case).

These functions have been declared returning void originally, but in
the review process with Thomas we changed them since they can fail.
Even if the current users, i.e. raw.c and bcm.c don't use the return
value, others might do.  I therefore prefer to keep the int return
value.  Rather we should check whether we can do something useful with
the return value in raw.c and bcm.c.  At least we can put a WARN_ON
there.

> Same here, none of the callers check the return value and since
> they're all declared as void they can't propagate any errors back.

Same as above.

> > +#include "af_can.h"
> 
> 
> It seems most of the things declared in that file are only used within
> af_can.c. Might be easier to read the code if you'd just move it over.

af_can.h declares the interface between af_can.c and proc.c.  There
should be nothing in af_can.h which is only used in af_can.c

> > +int stats_timer = 1; /* default: on */
> 
> 
> This seems to be only used in af_can.c, so it could be static.
> __read_mostly also seems to be approriate.

Right.  Will be changed.

> There are a few more that look like they could be __read_mostly
> below, but I'll skip these since you probably know better than me.

Yes, I will check these also.

> > +HLIST_HEAD(rx_dev_list);
> 
> 
> Same here (static).

Can't be static since it's used in proc.c.  But __read_mostly might
make sense.

What exactly is the effect of __read_mostly?  Is that in a separate
ELF section?  Where is that finally located?

> > +		if (ret == -ENOSYS)
> > +			printk(KERN_INFO "can: request_module(%s) not"
> > +			       " implemented.\n", module_name);
> > +		else if (ret)
> > +			printk(KERN_ERR "can: request_module(%s) failed\n",
> > +			       module_name);
> 
> 
> Both of these printks seem to be user-triggerable, so they should
> be rate-limited (or maybe get removed completely/changed to DBG).

Hm, I don't think DBG() would be right here, since the messages show
problems in the installation to the admin.  OTOH, I see that a user
can flood the log by opening sockets with invalid proto numbers.  Rate
limiting might solve this, or we should print the message only once
per proto number.  I will think about this.


> > +	/* check for success and correct type */
> > +	cp = proto_tab[protocol];
> 
> 
> What prevents the module from getting unloaded again (and using
> a stale pointer)?

When the module is unloaded it calls can_proto_unregister() which
clears the pointer.  Do you see a race condition here?

> > +	if (!cp || cp->type != sock->type)
> > +		return -EPROTONOSUPPORT;
> > +
> > +	if (net != &init_net)
> > +		return -EAFNOSUPPORT;
> 
> 
> Shouldn't this be done before attempting the module load?

Yes, you're right.

> > +int can_send(struct sk_buff *skb, int loop)
> > +{
> > +	int err;
> > +
> > +	if (skb->dev->type != ARPHRD_CAN) {
> > +		kfree_skb(skb);
> > +		return -EPERM;
> 
> 
> EPERM doesn't seem like the best fit, but I don't have a better
> suggestion myself at the moment.

We have chosen EPERM because a user shouldn't be allowed to open a raw
CAN socket and then send arbitrary frames to other non-CAN interfaces.
This is also because the raw and bcm protocols can be configured to
grant access to non-root users.

> > +		if (!(skb->dev->flags & IFF_LOOPBACK)) {
> > +			/*
> > +			 * If the interface is not capable to do loopback
> > +			 * itself, we do it here.
> > +			 */
> > +			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
> > +
> > +			if (!newskb) {
> > +				kfree_skb(skb);
> > +				return -ENOMEM;
> > +			}
> > +
> > +			newskb->sk = skb->sk;
> > +			newskb->ip_summed = CHECKSUM_UNNECESSARY;
> > +			newskb->pkt_type = PACKET_BROADCAST;
> > +			netif_rx(newskb);
> 
> 
> So the intention here is to send the packet to the non-loopback device
> and manually loop it, which means sending it twice?

CAN is a broadcast message network, so every frame should be (usually)
sent to all receivers, on remote hosts and to all local sockets.  If
the driver for the interface is not able to loop back the frame for
local delivery, the can_send() function will do this as a fallback.
For real CAN devices it is preferred that the driver does loopback.
For vcan it makes no difference where loopback is done.  The module
paramenter for vcan is therefore only useful to test and debug the CAN
core module.  It is nothing a normal user will ever use.

> > +static struct dev_rcv_lists *find_dev_rcv_lists(struct net_device *dev)
> > +{
> > +	struct dev_rcv_lists *d;
> > +	struct hlist_node *n;
> > +
> > +	/*
> > +	 * find receive list for this device
> > +	 *
> > +	 * The hlist_for_each_entry*() macros curse through the list
> > +	 * using the pointer variable n and set d to the containing
> > +	 * struct in each list iteration.  Therefore, after list
> > +	 * iteration, d is unmodified when the list is empty, and it
> > +	 * points to last list element, when the list is non-empty
> > +	 * but no match in the loop body is found.  I.e. d is *not*
> > +	 * NULL when no match is found.  We can, however, use the
> > +	 * cursor variable n to decide if a match was found.
> > +	 */
> > +
> > +	hlist_for_each_entry(d, n, &rx_dev_list, list) {
> 
> 
> On the receive path you use RCU, so this should be
> hlist_for_each_entry_rcu(), no? The bottem half disabling during
> addition/removal also seems unnecessary, but I might be missing
> something.

find_dev_rcv_lists() is called in one place from can_rcv() with RCU
lock held, as you write.  The other two calls to find_dev_rcv_lists()
are from can_rx_register/unregister() functions which change the
receive lists.  Therefore, we can't only use RCU but need protection
against simultanous writes.  We do this with the spin_lock_bh().  The
_bh variant, because can_rcv() runs in interrupt and we need to block
that.  I thought this is pretty standard.

I'll check this again tomorrow, but I have put much time in these
locking issues already, changed it quite a few times and hoped to have
got it right finally.

...

I have just looked at the code again and I think we're right here.  
Please reply if you think otherwise and we must fix it.


> > +	case NETDEV_REGISTER:
> > +
> > +		/*
> > +		 * create new dev_rcv_lists for this device
> > +		 *
> > +		 * N.B. zeroing the struct is the correct initialization
> > +		 * for the embedded hlist_head structs.
> > +		 * Another list type, e.g. list_head, would require
> > +		 * explicit initialization.
> > +		 */
> > +
> > +		DBG("creating new dev_rcv_lists for %s\n", dev->name);
> > +
> > +		d = kzalloc(sizeof(*d),
> > +			    in_interrupt() ? GFP_ATOMIC : GFP_KERNEL);
> 
> 
> netdevice registration should never happen from interrupt handlers.

Hm, I seem to remember we had such an occurance with hot-pluggable
devices, i.e. USB.  But I may be wrong.  In what context is
NETDEV_REGISTER called for e.g. USB devices?  Can we safely write
just GFP_KERNEL here?

> > +static struct packet_type can_packet = {
> > +	.type = __constant_htons(ETH_P_CAN),
> > +	.dev  = NULL,
> > +	.func = can_rcv,
> > +};
> 
> __read_mostly (for those below as well)?

OK.

> > +		stattimer.expires = jiffies + HZ;
> 
> round_jiffies?

Yes.  We don't depend on exact times relative to module load time, but
we would like to have the timer expirations 1 second apart.  But we
would still get this with round_jiffies(), right?

> > +static unsigned long calc_rate(unsigned long oldjif, unsigned long newjif,
> > +			       unsigned long count)
> > +{
> > +	unsigned long ret = 0;
> > +
> > +	if (oldjif == newjif)
> > +		return 0;
> > +
> > +	/* see can_rcv() - this should NEVER happen! */
> 
> 
> If I'm not mistaken this comment is outdated and should refer to
> can_stat_update().

Yep.  Thanks.

> > +	stattimer.expires = jiffies + HZ;
> 
> 
> round_jiffies?

Yes, like above.

> > + * proc read functions
> > + *
> > + * From known use-cases we expect about 10 entries in a receive list to be
> > + * printed in the proc_fs. So PAGE_SIZE is definitely enough space here.
> 
> 
> Would be nicer to use seq_file (for all the proc stuff).

That has already been on my TODO list.  There was some problem which I
don't remember ATM, which is why I dropped it temporarily.  Now on my
TODO list again.


Thank you for your feedback.
urs
