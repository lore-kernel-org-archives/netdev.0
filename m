From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sat, 16 Aug 2008 21:47:32 +0200
Message-ID: <20080816193956.GB24083@ami.dom.local>
References: <20080815190905.M56388@visp.net.lb> <200808162115.16346.denys@visp.net.lb> <20080816185241.GA24083@ami.dom.local> <200808162222.56318.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:45138 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbYHPTo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 15:44:28 -0400
Received: by ug-out-1314.google.com with SMTP id c2so60289ugf.37
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 12:44:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808162222.56318.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 16, 2008 at 10:22:56PM +0300, Denys Fedoryshchenko wrote:
> > These patches shouldn't change so much. I meant: was this last patch
> > (with previous one ie. take #3) tested the same as earlier take #3
> > alone? (There were warnings only, no oopses.)
> Yes, sure with take #3 also.
> 
> Warnings disappeared, but kernel paniced, and it is really looks like another 
> bug. I will try also to enable more debug options at night (after 2-3 hours, 
> when traffic is low), including intensive memory debugging, maybe i can catch 
> some memory poisoning.

I only wanted to be sure if the reason(s) of this first oops was found
before looking for the next problem. They could be connected yet.
Anyway, I'm currently most interested in this patch below, so I could
know the better base for next fixes.

Jarek P. 

> 
> >
> > BTW, here is a patch with another way of fixing this. I would be glad
> > if you could try this too. The previous patch should be reverted, so
> > we need only: "take #3", this one and these two you mentioned above.
> >
> > Jarek P.
> >
> > ---
> >
> >  include/linux/netdevice.h |    1 +
> >  include/net/sch_generic.h |    5 ++++-
> >  net/core/dev.c            |    1 +
> >  3 files changed, 6 insertions(+), 1 deletions(-)
> >
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 488c56e..7041c2c 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -445,6 +445,7 @@ struct netdev_queue {
> >  	struct net_device	*dev;
> >  	struct Qdisc		*qdisc;
> >  	unsigned long		state;
> > +	spinlock_t		qdisc_lock;
> >  	spinlock_t		_xmit_lock;
> >  	int			xmit_lock_owner;
> >  	struct Qdisc		*qdisc_sleeping;
> > diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> > index a7abfda..f84e96c 100644
> > --- a/include/net/sch_generic.h
> > +++ b/include/net/sch_generic.h
> > @@ -185,7 +185,10 @@ static inline struct qdisc_skb_cb *qdisc_skb_cb(struct
> > sk_buff *skb)
> >
> >  static inline spinlock_t *qdisc_lock(struct Qdisc *qdisc)
> >  {
> > -	return &qdisc->q.lock;
> > +	if (unlikely(qdisc->flags & TCQ_F_BUILTIN))
> > +		return &qdisc->q.lock;
> > +
> > +	return &qdisc->dev_queue->qdisc_lock;
> >  }
> >
> >  static inline struct Qdisc *qdisc_root(struct Qdisc *qdisc)
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 600bb23..9ec20e0 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3859,6 +3859,7 @@ static void __netdev_init_queue_locks_one(struct
> > net_device *dev, void *_unused)
> >  {
> >  	spin_lock_init(&dev_queue->_xmit_lock);
> > +	spin_lock_init(&dev_queue->qdisc_lock);
> >  	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
> >  	dev_queue->xmit_lock_owner = -1;
> >  }
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
