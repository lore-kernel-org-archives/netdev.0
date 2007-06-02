From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: 02 Jun 2007 10:09:37 +0200
Message-ID: <ygfsl9azsji.fsf@janus.isnogud.escape.de>
References: <20070530131123.10843.0@janus.isnogud.escape.de>
	<20070530131204.10843.5@janus.isnogud.escape.de>
	<465DB0B6.109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:36170 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbXFBIKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jun 2007 04:10:41 -0400
In-Reply-To: <465DB0B6.109@trash.net>; from Patrick McHardy on Wed, 30 May 2007 19:13:26 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> I have a set of patches coming up that introduce a rtnetlink API
> for adding/modifying/deleting software network devices. I would
> prefer if you could switch this driver over instead of doing the
> "create N devices during loading" that many current drivers do,
> leaving you with 20 unused devices after boot.
> 
> > +static int loopback = 0; /* vcan default: no loopback, just free the skb */
> > +module_param(loopback, int, S_IRUGO);
> > +MODULE_PARM_DESC(loopback, "Loop back sent frames. vcan default: 0 (Off)");
> 
> 
> And it allows you have both loopback and non-loopback devices
> in case that would be useful.

That sounds very promising.  I also was unhappy with the fixed number
of vcan devices at module load time and have thought about ioctl's to
add/delete devices and to change the loopback flag.  A more general
approach like the one you seem to be working on is preferable of
course.

> Qdiscs might change skb->cb. Maybe use skb->sk?

When we decided to use skb->cb it seemed the only possible option.
We need a field that we can set to zero to indicate we don't want the
driver to loop back the packet and the value in that field must
survive the path

        can_send()
        dev_queue_xmit()
        ...
        dev->hard_start_xmit()
        
        netif_rx()
        can_rcv()

I think I misread the comment

 *      @cb: Control buffer. Free for use by every layer. Put private vars here

to mean I can use it for this purpose and since it worked as intended
we felt ok with this.  Now I see, it states exactly the opposite that
I can't count on the value being preserved across layers.

skb->sk can't be used since we shouldn't set it to zero before
dev_queue_xmit() as Oliver already pointed out.  IIRC, skb->sk
couldn't also be used in rx half of that path, since it was set to
null somewhere in netif_rx() but now, reading the src, I can't see
where this would happen.  Maybe this has changed or my memory has some
bit errors.  I'll look at it again.  Even if it turns out skb->sk can
be used in rx path, the need remains to pass down a flag from
can_send() to dev->hard_start_xmit() indicating whether to loop back
or not.

> > +static int vcan_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> 
> Not needed.
> 
> > +static int vcan_rebuild_header(struct sk_buff *skb)
> 
> Also not needed.
> 
> > +static int vcan_header(struct sk_buff *skb, struct net_device *dev,
> 
> Also not needed.

Yep.  These are some remnants from when I was experimenting to see
when these functions are called and with what args.  We will remove
this.  Thanks for pointing this out.

> > +static struct net_device_stats *vcan_get_stats(struct net_device *dev)
> > +{
> > +	struct net_device_stats *stats = netdev_priv(dev);
> > +
> > +	return stats;
> > +}
> 
> Not needed if you just use dev->stats.

OK, this was added *very* recently in some 2.6.22-{pre,rc} version and
I haven't noticed before.  We'll use that.

> > +static __init int vcan_init_module(void)
> 
> Looks quite large for such a simple task. Should get a lot
> simpler by switching to the rtnetlink API.

That would be nice.

urs
