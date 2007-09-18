From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 3/7] CAN: Add raw protocol
Date: 18 Sep 2007 23:49:46 +0200
Message-ID: <ygfbqbzzls5.fsf@janus.isnogud.escape.de>
References: <20070917100321.18347.0@janus.isnogud.escape.de>
	<20070917100439.18347.3@janus.isnogud.escape.de>
	<46EFDCF5.3020609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs@isnogud.escape.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:40439 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869AbXIRVun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 17:50:43 -0400
In-Reply-To: <46EFDCF5.3020609@trash.net>; from Patrick McHardy on Tue, 18 Sep 2007 16:13:09 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> > +config CAN_RAW_USER
> > +	bool "Allow non-root users to access Raw CAN Protocol sockets"
> > +	depends on CAN_RAW
> > +	default N
> > +	---help---
> > +	  The Controller Area Network is a local field bus transmitting only
> > +	  broadcast messages without any routing and security concepts.
> > +	  In the majority of cases the user application has to deal with
> > +	  raw CAN frames. Therefore it might be reasonable NOT to restrict
> > +	  the CAN access only to the user root
> 
> 
> Would it be much more trouble for userspace to use capabilities for
> this? This would allow userspace to always know what to expect, I
> don't think distributions will enable this option (which might again
> not matter since they're probably rarely used in cars :)).

First, it's not only used in cars but also in other embedded and
automation contexts :-)

In fact, we already check capabilities in af_can.c:can_create() like
this

        if (cp->capability >= 0 && !capable(cp->capability))
                return -EPERM;

Each protocol implementation can set cp->capability to -1 so that all
users can open sockets without any restriction or to some capability,
typically CAP_NET_RAW.  In raw.c it is done so

	#ifdef CONFIG_CAN_RAW_USER
	#define RAW_CAP (-1)
	#else
	#define RAW_CAP CAP_NET_RAW
	#endif

I also didn't love this configure option very much when we added it.
But in embedded systems it is often not much of a problem to let
anybody access raw sockets, since there are no "normal" users.  This
is the reason for the configure option.  I haven't yet looked into
capabilities and their inheritance between process in detail.	Would
it be easy to let all user space run with CAP_NET_RAW?  What if some
process calls setuid() or execve()s a set-uid program?  Will
capabilities be retained?

> > +	addr = (struct sockaddr_can *)skb->cb;
> > +	memset(addr, 0, sizeof(*addr));
> > +	addr->can_family  = AF_CAN;
> > +	addr->can_ifindex = skb->dev->ifindex;
> 
> 
> >From a quick look it looks like there's more than enough space, but
> I guess a BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct sockaddr_can))
> in the module init path wouldn't hurt.

OK.  I didn't know about BUILD_BUG_ON.

> > +		can_rx_register(dev, filter[i].can_id, filter[i].can_mask,
> > +				raw_rcv, sk, IDENT);
> 
> 
> Shouldn't this check for errors?

Yes...

> > +		can_rx_register(dev, 0, ro->err_mask | CAN_ERR_FLAG,
> > +				raw_rcv, sk, IDENT);
> 
> 
> Same question here ..

and yes...

I talk(1)ed to Oliver an hour ago.  He will look at this.

> > +static int raw_notifier(struct notifier_block *nb,
> > +			unsigned long msg, void *data)
> > +{
> > +	struct net_device *dev = (struct net_device *)data;
> > +	struct raw_sock *ro = container_of(nb, struct raw_sock, notifier);
> > +	struct sock *sk = &ro->sk;
> > +
> > +	DBG("msg %ld for dev %p (%s idx %d) sk %p ro->ifindex %d\n",
> > +	    msg, dev, dev->name, dev->ifindex, sk, ro->ifindex);
> > +
> > +	if (dev->nd_net != &init_net)
> > +		return NOTIFY_DONE;
> > +
> > +	if (dev->type != ARPHRD_CAN)
> > +		return NOTIFY_DONE;
> > +
> > +	if (ro->ifindex != dev->ifindex)
> > +		return NOTIFY_DONE;
> 
> 
> Wouldn't that be a BUG()?

Would it?  I think there is only one netdev_chain, not one per
device.  I.e. our raw_notifier() gets all events on any netdevice, not
only the ones we're interested in, for example also eth0.  And I think
we should silently ignore these events by returning NOTIFY_DONE.  Am I
missing something here?

urs
