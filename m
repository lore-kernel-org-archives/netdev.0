From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: 19 Sep 2007 00:24:39 +0200
Message-ID: <ygf7imnzk60.fsf@janus.isnogud.escape.de>
References: <20070917100321.18347.0@janus.isnogud.escape.de>
	<20070917100440.18347.5@janus.isnogud.escape.de>
	<46EFE89D.7050006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs@isnogud.escape.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:51571 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244AbXIRWZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 18:25:50 -0400
In-Reply-To: <46EFE89D.7050006@trash.net>; from Patrick McHardy on Tue, 18 Sep 2007 17:02:53 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> > +static int loopback; /* loopback testing. Default: 0 (Off) */
> > +module_param(loopback, int, S_IRUGO);
> > +MODULE_PARM_DESC(loopback, "Loop back frames (for testing). Default: 0 (Off)");
> 
> 
> I would still prefer to have this on a per-device level configured
> through netlink, but since we currently don't support specifying
> flags for new devices anyways, I won't argue about it anymore
> (OTOH, if you'd agree I could send a patch to add this feature
> to the rtnl_link API).

Hm, somehow this topic comes up again and again.  I think there is
some misunderstanding about loopback in general and vcan, but I must
admit that our documentation until recently didn't describe this good
enough.  In fact, I think we also got better understanding from this
discussion and trying to explain this.

vcan is *not* a special loopback device like lo and it is not needed
to use PF_CAN.  Every CAN device driver should preferably loop back
frames sent by dev->hard_start_xmit() to netif_rx().  Since this is
unusual for netdevice drivers, the CAN core can do this itself as a
fallback for drivers that don't loopback.

For vcan it makes no difference whether loopback is done in the vcan
driver or in the CAN core.  No user will ever have to use this module
parameter.  Having a driver which can show both driver behaviors is
however useful for debugging our own code, to check whether the CAN
core does the right thing in both cases.

vcan is not a loopback device but a null device which simply discards
all sent frames since there is no hardware to send the frame to.  Like
other CAN drivers it can loop back the frame to the CAN core, but this
is not different from other CAN drivers.

It can be useful to have several vcan null devices so that different
apps can talk to each other through different interfaces.



Now I think we should consider removing the loopback code from
can_send() and demand from each CAN driver that it *has to* implement
this itself.

> > +
> > +struct vcan_priv {
> > +	struct net_device *dev;
> > +	struct list_head list;
> > +};
> 
> 
> This is not needed anymore. The rtnl_link_unregister function calls
> the ->dellink function for each device of this type. Check out the
> current dummy.c driver.

OK.

> > +		if (atomic_read(&skb->users) != 1) {
> > +			struct sk_buff *old_skb = skb;
> > +
> > +			skb = skb_clone(old_skb, GFP_ATOMIC);
> > +			DBG(KERN_INFO "%s: %s: freeing old skbuff %p, "
> > +			    "using new skbuff %p\n",
> > +			    dev->name, __FUNCTION__, old_skb, skb);
> > +			kfree_skb(old_skb);
> 
> skb_share_check()?

New to me.  I read that skb_share_check() decrements the refcount so I
am not sure it is we want.  Will take a look tomorrow.

> > +		/* receive with packet counting */
> > +		skb->sk = srcsk;
> 
> 
> Where is the socket used and what makes sure it still exists?

This socket pointer is used when the loopback frame is processed in
raw_rcv, only to compare it to the receiving socket to determine if
this frame was sent by the receiving socket itself.  The srcsk is only
compared, not dereferenced.

> > +static void vcan_dellink(struct net_device *dev)
> > +{
> > +	struct vcan_priv *priv = netdev_priv(dev);
> > +
> > +	list_del(&priv->list);
> > +	unregister_netdevice(dev);
> > +}
> 
> 
> Both the addlink and dellink function can be removed, the default
> for addlink is register_netdevice, the default for unregister
> is unregister_netdevice (and the list is not needed anymore as
> mentioned above).

OK, we'll remove them.

> > +	rtnl_lock();
> > +	err = __rtnl_link_register(&vcan_link_ops);
> > +	rtnl_unlock();
> 
> 
> Just using rtnl_link_register here is fine.

OK, we'll change that.

> and rtnl_link_unregister (without manual cleanup) here.

OK.

urs
