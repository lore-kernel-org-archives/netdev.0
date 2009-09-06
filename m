From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net_sched 07/07: add classful multiqueue dummy scheduler
Date: Sun, 6 Sep 2009 22:04:09 +0200
Message-ID: <20090906200409.GB8833@ami.dom.local>
References: <20090904164119.27300.23137.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:31684 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbZIFUEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2009 16:04:21 -0400
Received: by fg-out-1718.google.com with SMTP id 22so586224fge.1
        for <netdev@vger.kernel.org>; Sun, 06 Sep 2009 13:04:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090904164119.27300.23137.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 09/04/2009 06:41 PM:

> commit f114d0f02c9e72fea7bbc4d28a113946183fc65f
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Fri Sep 4 18:25:04 2009 +0200
> 
>     net_sched: add classful multiqueue dummy scheduler
>     
>     This patch adds a classful dummy scheduler which can be used as root qdisc
>     for multiqueue devices and exposes each device queue as a child class.
>     
>     This allows to address queues individually and graft them similar to regular
>     classes. Additionally it presents an accumulated view of the statistics of
>     all real root qdiscs in the dummy root.
>     
>     Two new callbacks are added to the qdisc_ops and qdisc_class_ops:
>     
>     - cl_ops->select_queue selects the tx queue number for new child classes.
>     
>     - qdisc_ops->attach() overrides root qdisc device grafting to attach
>       non-shared qdiscs to the queues.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index a92dc62..9c69585 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -80,6 +80,7 @@ struct Qdisc
>  struct Qdisc_class_ops
>  {
>  	/* Child qdisc manipulation */
> +	unsigned int		(*select_queue)(struct Qdisc *, struct tcmsg *);
>  	int			(*graft)(struct Qdisc *, unsigned long cl,
>  					struct Qdisc *, struct Qdisc **);
>  	struct Qdisc *		(*leaf)(struct Qdisc *, unsigned long cl);
> @@ -122,6 +123,7 @@ struct Qdisc_ops
>  	void			(*reset)(struct Qdisc *);
>  	void			(*destroy)(struct Qdisc *);
>  	int			(*change)(struct Qdisc *, struct nlattr *arg);
> +	void			(*attach)(struct Qdisc *);

Probably it's a matter of taste, but I wonder why these two methods
used only by one qdisc in max 2 places can't be functions instead
(maybe even static in case of select_queue)? (And this mq sched could
be tested with some flag instead of ->attach, I guess.)

>  
>  	int			(*dump)(struct Qdisc *, struct sk_buff *);
>  	int			(*dump_stats)(struct Qdisc *, struct gnet_dump *);
> @@ -255,6 +257,8 @@ static inline void sch_tree_unlock(struct Qdisc *q)
>  
>  extern struct Qdisc noop_qdisc;
>  extern struct Qdisc_ops noop_qdisc_ops;
> +extern struct Qdisc_ops pfifo_fast_ops;
> +extern struct Qdisc_ops mq_qdisc_ops;
>  
>  struct Qdisc_class_common
>  {
> diff --git a/net/sched/Makefile b/net/sched/Makefile
> index 54d950c..f14e71b 100644
> --- a/net/sched/Makefile
> +++ b/net/sched/Makefile
> @@ -2,7 +2,7 @@
>  # Makefile for the Linux Traffic Control Unit.
>  #
>  
> -obj-y	:= sch_generic.o
> +obj-y	:= sch_generic.o sch_mq.o
>  
>  obj-$(CONFIG_NET_SCHED)		+= sch_api.o sch_blackhole.o
>  obj-$(CONFIG_NET_CLS)		+= cls_api.o
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index d71f12b..2a78d54 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -678,6 +678,11 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
>  		if (dev->flags & IFF_UP)
>  			dev_deactivate(dev);
>  
> +		if (new && new->ops->attach) {
> +			new->ops->attach(new);
> +			num_q = 0;
> +		}
> +

Actually, I wonder if it's not cleaner to let replace all qdiscs with
noops below like in qdisc delete case, and do this attaching in one
place only (dev_activate).

>  		for (i = 0; i < num_q; i++) {
>  			struct netdev_queue *dev_queue = &dev->rx_queue;
>  
> @@ -692,7 +697,7 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
>  		}
>  
>  		notify_and_destroy(skb, n, classid, dev->qdisc, new);
> -		if (new)
> +		if (new && !new->ops->attach)
>  			atomic_inc(&new->refcnt);
>  		dev->qdisc = new ? : &noop_qdisc;
>  
> @@ -1095,10 +1100,16 @@ create_n_graft:
>  		q = qdisc_create(dev, &dev->rx_queue,
>  				 tcm->tcm_parent, tcm->tcm_parent,
>  				 tca, &err);
> -	else
> -		q = qdisc_create(dev, netdev_get_tx_queue(dev, 0),
> +	else {
> +		unsigned int ntx = 0;
> +
> +		if (p && p->ops->cl_ops && p->ops->cl_ops->select_queue)
> +			ntx = p->ops->cl_ops->select_queue(p, tcm);

So, this if could be probably made shorter with a common function, but
the main point is: this probably works only for qdiscs having mq as a
parent, and not below.

> +
> +		q = qdisc_create(dev, netdev_get_tx_queue(dev, ntx),
>  				 tcm->tcm_parent, tcm->tcm_handle,
>  				 tca, &err);
> +	}
>  	if (q == NULL) {
>  		if (err == -EAGAIN)
>  			goto replay;
> @@ -1674,6 +1685,7 @@ static int __init pktsched_init(void)
>  {
>  	register_qdisc(&pfifo_qdisc_ops);
>  	register_qdisc(&bfifo_qdisc_ops);
> +	register_qdisc(&mq_qdisc_ops);
>  	proc_net_fops_create(&init_net, "psched", 0, &psched_fops);
>  
>  	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index e7c47ce..4ae6aa5 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -514,7 +514,7 @@ static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
>  	return 0;
>  }
>  
> -static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
> +struct Qdisc_ops pfifo_fast_ops __read_mostly = {
>  	.id		=	"pfifo_fast",
>  	.priv_size	=	sizeof(struct pfifo_fast_priv),
>  	.enqueue	=	pfifo_fast_enqueue,
> @@ -670,6 +670,26 @@ static void attach_one_default_qdisc(struct net_device *dev,
>  	dev_queue->qdisc_sleeping = qdisc;
>  }
>  
> +static void attach_default_qdiscs(struct net_device *dev)
> +{
> +	struct netdev_queue *txq;
> +	struct Qdisc *qdisc;
> +
> +	txq = netdev_get_tx_queue(dev, 0);
> +
> +	if (!netif_is_multiqueue(dev) || dev->tx_queue_len == 0) {
> +		netdev_for_each_tx_queue(dev, attach_one_default_qdisc, NULL);
> +		dev->qdisc = txq->qdisc_sleeping;
> +		atomic_inc(&dev->qdisc->refcnt);
> +	} else {
> +		qdisc = qdisc_create_dflt(dev, txq, &mq_qdisc_ops, TC_H_ROOT);
> +		if (qdisc) {
> +			qdisc->ops->attach(qdisc);
> +			dev->qdisc = qdisc;
> +		}
> +	}
> +}
> +
>  static void transition_one_qdisc(struct net_device *dev,
>  				 struct netdev_queue *dev_queue,
>  				 void *_need_watchdog)
> @@ -689,7 +709,6 @@ static void transition_one_qdisc(struct net_device *dev,
>  
>  void dev_activate(struct net_device *dev)
>  {
> -	struct netdev_queue *txq;
>  	int need_watchdog;
>  
>  	/* No queueing discipline is attached to device;
> @@ -698,13 +717,8 @@ void dev_activate(struct net_device *dev)
>  	   virtual interfaces
>  	 */
>  
> -	if (dev->qdisc == &noop_qdisc) {
> -		netdev_for_each_tx_queue(dev, attach_one_default_qdisc, NULL);
> -
> -		txq = netdev_get_tx_queue(dev, 0);
> -		dev->qdisc = txq->qdisc_sleeping;
> -		atomic_inc(&dev->qdisc->refcnt);
> -	}
> +	if (dev->qdisc == &noop_qdisc)
> +		attach_default_qdiscs(dev);
>  
>  	if (!netif_carrier_ok(dev))
>  		/* Delay activation until next carrier-on event */
> diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
> new file mode 100644
> index 0000000..5e453fd
> --- /dev/null
> +++ b/net/sched/sch_mq.c
> @@ -0,0 +1,234 @@
> +/*
> + * net/sched/sch_mq.c		Classful multiqueue dummy scheduler
> + *
> + * Copyright (c) 2009 Patrick McHardy <kaber@trash.net>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + */
> +
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/string.h>
> +#include <linux/errno.h>
> +#include <linux/skbuff.h>
> +#include <net/netlink.h>
> +#include <net/pkt_sched.h>
> +
> +struct mq_sched {
> +	struct Qdisc		**qdiscs;
> +};
> +
> +static void mq_destroy(struct Qdisc *sch)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct mq_sched *priv = qdisc_priv(sch);
> +	unsigned int ntx;
> +
> +	if (priv->qdiscs)
> +		return;
> +	for (ntx = 0; ntx < dev->num_tx_queues && priv->qdiscs[ntx]; ntx++)
> +		qdisc_destroy(priv->qdiscs[ntx]);
> +	kfree(priv->qdiscs);
> +}
> +
> +static int mq_init(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct mq_sched *priv = qdisc_priv(sch);
> +	struct netdev_queue *dev_queue;
> +	struct Qdisc *qdisc;
> +	unsigned int ntx;
> +
> +	if (sch->parent != TC_H_ROOT)
> +		return -EOPNOTSUPP;
> +
> +	if (!netif_is_multiqueue(dev))
> +		return -EOPNOTSUPP;
> +
> +	/* pre-allocate qdiscs, attachment can't fail */
> +	priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
> +			       GFP_KERNEL);

I guess we could avoid this at all or at least to do it in one step with
current ->attach.

> +	if (priv->qdiscs == NULL)
> +		return -ENOMEM;
> +
> +	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
> +		dev_queue = netdev_get_tx_queue(dev, ntx);
> +		qdisc = qdisc_create_dflt(dev, dev_queue, &pfifo_fast_ops,
> +					  TC_H_MAKE(TC_H_MAJ(sch->handle),
> +						    TC_H_MIN(ntx + 1)));

As I wrote in 05/07 comment, I wonder if we really can't achieve this
with old TC_H_ROOT parentid, and maybe some mapping while dumping to
the userspace only. Another possibility would be considering a new
kind of root (mqroot?) to tell precisely, where a new qdisc should be
added.

> +		if (qdisc == NULL)
> +			goto err;
> +		qdisc->flags |= TCQ_F_CAN_BYPASS;
> +		priv->qdiscs[ntx] = qdisc;
> +	}
> +
> +	return 0;
> +
> +err:
> +	mq_destroy(sch);
> +	return -ENOMEM;
> +}
> +
> +static void mq_attach(struct Qdisc *sch)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct mq_sched *priv = qdisc_priv(sch);
> +	struct Qdisc *qdisc;
> +	unsigned int ntx;
> +
> +	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
> +		qdisc = priv->qdiscs[ntx];
> +		qdisc = dev_graft_qdisc(qdisc->dev_queue, qdisc);
> +		if (qdisc)
> +			qdisc_destroy(qdisc);
> +	}
> +	kfree(priv->qdiscs);
> +	priv->qdiscs = NULL;
> +}
> +
> +static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct Qdisc *qdisc;
> +	unsigned int ntx;
> +
> +	sch->q.qlen = 0;
> +	memset(&sch->bstats, 0, sizeof(sch->bstats));
> +	memset(&sch->qstats, 0, sizeof(sch->qstats));
> +
> +	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
> +		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
> +		spin_lock_bh(qdisc_lock(qdisc));
> +		sch->q.qlen		+= qdisc->q.qlen;
> +		sch->bstats.bytes	+= qdisc->bstats.bytes;
> +		sch->bstats.packets	+= qdisc->bstats.packets;
> +		sch->qstats.qlen	+= qdisc->qstats.qlen;

Like in Christoph's case, we should probably use q.qlen instead.

Thanks,
Jarek P.

> +		sch->qstats.backlog	+= qdisc->qstats.backlog;
> +		sch->qstats.drops	+= qdisc->qstats.drops;
> +		sch->qstats.requeues	+= qdisc->qstats.requeues;
> +		sch->qstats.overlimits	+= qdisc->qstats.overlimits;
> +		spin_unlock_bh(qdisc_lock(qdisc));
> +	}
> +	return 0;
> +}
> +
> +static struct netdev_queue *mq_queue_get(struct Qdisc *sch, unsigned long cl)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	unsigned long ntx = cl - 1;
> +
> +	if (ntx >= dev->num_tx_queues)
> +		return NULL;
> +	return netdev_get_tx_queue(dev, ntx);
> +}
> +
> +static unsigned int mq_select_queue(struct Qdisc *sch, struct tcmsg *tcm)
> +{
> +	unsigned int ntx = TC_H_MIN(tcm->tcm_parent);
> +
> +	if (!mq_queue_get(sch, ntx))
> +		return 0;
> +	return ntx - 1;
> +}
> +
> +static int mq_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
> +		    struct Qdisc **old)
> +{
> +	struct netdev_queue *dev_queue = mq_queue_get(sch, cl);
> +	struct net_device *dev = qdisc_dev(sch);
> +
> +	if (dev->flags & IFF_UP)
> +		dev_deactivate(dev);
> +
> +	*old = dev_graft_qdisc(dev_queue, new);
> +
> +	if (dev->flags & IFF_UP)
> +		dev_activate(dev);
> +	return 0;
> +}
> +
> +static struct Qdisc *mq_leaf(struct Qdisc *sch, unsigned long cl)
> +{
> +	struct netdev_queue *dev_queue = mq_queue_get(sch, cl);
> +
> +	return dev_queue->qdisc_sleeping;
> +}
> +
> +static unsigned long mq_get(struct Qdisc *sch, u32 classid)
> +{
> +	unsigned int ntx = TC_H_MIN(classid);
> +
> +	if (!mq_queue_get(sch, ntx))
> +		return 0;
> +	return ntx;
> +}
> +
> +static void mq_put(struct Qdisc *sch, unsigned long cl)
> +{
> +	return;
> +}
> +
> +static int mq_dump_class(struct Qdisc *sch, unsigned long cl,
> +			 struct sk_buff *skb, struct tcmsg *tcm)
> +{
> +	struct netdev_queue *dev_queue = mq_queue_get(sch, cl);
> +
> +	tcm->tcm_parent = TC_H_ROOT;
> +	tcm->tcm_handle |= TC_H_MIN(cl);
> +	tcm->tcm_info = dev_queue->qdisc_sleeping->handle;
> +	return 0;
> +}
> +
> +static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
> +			       struct gnet_dump *d)
> +{
> +	struct netdev_queue *dev_queue = mq_queue_get(sch, cl);
> +
> +	sch = dev_queue->qdisc_sleeping;
> +	if (gnet_stats_copy_basic(d, &sch->bstats) < 0 ||
> +	    gnet_stats_copy_queue(d, &sch->qstats) < 0)
> +		return -1;
> +	return 0;
> +}
> +
> +static void mq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	unsigned int ntx;
> +
> +	if (arg->stop)
> +		return;
> +
> +	arg->count = arg->skip;
> +	for (ntx = arg->skip; ntx < dev->num_tx_queues; ntx++) {
> +		if (arg->fn(sch, ntx + 1, arg) < 0) {
> +			arg->stop = 1;
> +			break;
> +		}
> +		arg->count++;
> +	}
> +}
> +
> +static const struct Qdisc_class_ops mq_class_ops = {
> +	.select_queue	= mq_select_queue,
> +	.graft		= mq_graft,
> +	.leaf		= mq_leaf,
> +	.get		= mq_get,
> +	.put		= mq_put,
> +	.walk		= mq_walk,
> +	.dump		= mq_dump_class,
> +	.dump_stats	= mq_dump_class_stats,
> +};
> +
> +struct Qdisc_ops mq_qdisc_ops __read_mostly = {
> +	.cl_ops		= &mq_class_ops,
> +	.id		= "mq",
> +	.priv_size	= sizeof(struct mq_sched),
> +	.init		= mq_init,
> +	.destroy	= mq_destroy,
> +	.attach		= mq_attach,
> +	.dump		= mq_dump,
> +	.owner		= THIS_MODULE,
> +};
> --
