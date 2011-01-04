From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 2/2] net_sched: implement a root
	container qdisc sch_mclass
Date: Tue, 4 Jan 2011 11:18:17 +0000
Message-ID: <20110104111816.GA8085@ff.dom.local>
References: <20110104030553.13187.69135.stgit@jf-dev1-dcblab> <20110104030558.13187.27076.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hadi@cyberus.ca, shemminger@vyatta.com,
	tgraf@infradead.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64768 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306Ab1ADLS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 06:18:27 -0500
Received: by fxm20 with SMTP id 20so13963409fxm.19
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 03:18:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110104030558.13187.27076.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 03, 2011 at 07:05:58PM -0800, John Fastabend wrote:
> This implements a mqprio queueing discipline that by default creates
> a pfifo_fast qdisc per tx queue and provides the needed configuration
> interface.
> 
> Using the mqprio qdisc the number of tcs currently in use along
> with the range of queues alloted to each class can be configured. By
> default skbs are mapped to traffic classes using the skb priority.
> This mapping is configurable.
> 
> Configurable parameters,
> 
> struct tc_mclass_qopt {

Now *_mqprio here and in the subject of the message.

>         __u8    num_tc;
>         __u8    prio_tc_map[16];

s/16/TC_SOMETHING/

>         __u8    hw;
>         __u16   count[16];
>         __u16   offset[16];
> };
> 
> Here the count/offset pairing give the queue alignment and the
> prio_tc_map gives the mapping from skb->priority to tc.
> 
> The hw bit determines if the hardware should configure the count
> and offset values. If the hardware bit is set then the operation
> will fail if the hardware does not implement the ndo_setup_tc
> operation. This is to avoid undetermined states where the hardware
> may or may not control the queue mapping. Also minimal bounds
> checking is done on the count/offset to verify a queue does not
> exceed num_tx_queues and that queue ranges do not overlap. Otherwise
> it is left to user policy or hardware configuration to create
> useful mappings.
> 
> It is expected that hardware QOS schemes can be implemented by
> creating appropriate mappings of queues in ndo_tc_setup().
> 
> One expected use case is drivers will use the ndo_setup_tc to map
> queue ranges onto 802.1Q traffic classes. This provides a generic
> mechanism to map network traffic onto these traffic classes and
> removes the need for lower layer drivers to no specifics about
> traffic types.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  include/linux/netdevice.h |    3 
>  include/linux/pkt_sched.h |    9 +
>  net/sched/Kconfig         |   10 +
>  net/sched/Makefile        |    1 
>  net/sched/sch_generic.c   |    4 +
>  net/sched/sch_mqprio.c    |  357 +++++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 384 insertions(+), 0 deletions(-)
>  create mode 100644 net/sched/sch_mqprio.c
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 073c48d..f90a863 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -764,6 +764,8 @@ struct netdev_tc_txq {
>   * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
>   *			  struct nlattr *port[]);
>   * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
> + *
> + * int (*ndo_setup_tc)(struct net_device *dev, int tc);
>   */
>  #define HAVE_NET_DEVICE_OPS
>  struct net_device_ops {
> @@ -822,6 +824,7 @@ struct net_device_ops {
>  						   struct nlattr *port[]);
>  	int			(*ndo_get_vf_port)(struct net_device *dev,
>  						   int vf, struct sk_buff *skb);
> +	int			(*ndo_setup_tc)(struct net_device *dev, u8 tc);
>  #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
>  	int			(*ndo_fcoe_enable)(struct net_device *dev);
>  	int			(*ndo_fcoe_disable)(struct net_device *dev);
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 2cfa4bc..8e29fa6 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -481,4 +481,13 @@ struct tc_drr_stats {
>  	__u32	deficit;
>  };
>  
> +/* MCLASS */

/* MQPRIO */

> +struct tc_mqprio_qopt {
> +	__u8	num_tc;
> +	__u8	prio_tc_map[16];
> +	__u8	hw;
> +	__u16	count[16];
> +	__u16	offset[16];

s/16/TC_SOMETHING/

> +};
> +
>  #endif
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index a36270a..e42853b 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -205,6 +205,16 @@ config NET_SCH_DRR
>  
>  	  If unsure, say N.
>  
> +config NET_SCH_MQPRIO
> +	tristate "Multi-queue priority scheduler (MQPRIO)"
> +	help
> +	  Say Y here if you want to use the Multi-queue Priority scheduler.

We might mention about a proper NIC required.

> +
> +	  To compile this driver as a module, choose M here: the module will
> +	  be called sch_mqprio.
> +
> +	  If unsure, say N.
> +
>  config NET_SCH_INGRESS
>  	tristate "Ingress Qdisc"
>  	depends on NET_CLS_ACT
> diff --git a/net/sched/Makefile b/net/sched/Makefile
> index 960f5db..26ce681 100644
> --- a/net/sched/Makefile
> +++ b/net/sched/Makefile
> @@ -32,6 +32,7 @@ obj-$(CONFIG_NET_SCH_MULTIQ)	+= sch_multiq.o
>  obj-$(CONFIG_NET_SCH_ATM)	+= sch_atm.o
>  obj-$(CONFIG_NET_SCH_NETEM)	+= sch_netem.o
>  obj-$(CONFIG_NET_SCH_DRR)	+= sch_drr.o
> +obj-$(CONFIG_NET_SCH_MQPRIO)	+= sch_mqprio.o
>  obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
>  obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
>  obj-$(CONFIG_NET_CLS_FW)	+= cls_fw.o
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 34dc598..723b278 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -540,6 +540,7 @@ struct Qdisc_ops pfifo_fast_ops __read_mostly = {
>  	.dump		=	pfifo_fast_dump,
>  	.owner		=	THIS_MODULE,
>  };
> +EXPORT_SYMBOL(pfifo_fast_ops);
>  
>  struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
>  			  struct Qdisc_ops *ops)
> @@ -674,6 +675,7 @@ struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
>  
>  	return oqdisc;
>  }
> +EXPORT_SYMBOL(dev_graft_qdisc);
>  
>  static void attach_one_default_qdisc(struct net_device *dev,
>  				     struct netdev_queue *dev_queue,
> @@ -761,6 +763,7 @@ void dev_activate(struct net_device *dev)
>  		dev_watchdog_up(dev);
>  	}
>  }
> +EXPORT_SYMBOL(dev_activate);
>  
>  static void dev_deactivate_queue(struct net_device *dev,
>  				 struct netdev_queue *dev_queue,
> @@ -840,6 +843,7 @@ void dev_deactivate(struct net_device *dev)
>  	list_add(&dev->unreg_list, &single);
>  	dev_deactivate_many(&single);
>  }
> +EXPORT_SYMBOL(dev_deactivate);
>  
>  static void dev_init_scheduler_queue(struct net_device *dev,
>  				     struct netdev_queue *dev_queue,
> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
> new file mode 100644
> index 0000000..e9e74c7
> --- /dev/null
> +++ b/net/sched/sch_mqprio.c
> @@ -0,0 +1,357 @@
> +/*
> + * net/sched/sch_mqprio.c
> + *
> + * Copyright (c) 2010 John Fastabend <john.r.fastabend@intel.com>
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + */
> +
> +#include <linux/types.h>
> +#include <linux/slab.h>
> +#include <linux/kernel.h>
> +#include <linux/string.h>
> +#include <linux/errno.h>
> +#include <linux/skbuff.h>
> +#include <net/netlink.h>
> +#include <net/pkt_sched.h>
> +#include <net/sch_generic.h>
> +
> +struct mqprio_sched {
> +	struct Qdisc		**qdiscs;
> +	int hw_owned;
> +};
> +
> +static void mqprio_destroy(struct Qdisc *sch)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct mqprio_sched *priv = qdisc_priv(sch);
> +	unsigned int ntx;
> +
> +	if (!priv->qdiscs)
> +		return;
> +
> +	for (ntx = 0; ntx < dev->num_tx_queues && priv->qdiscs[ntx]; ntx++)
> +		qdisc_destroy(priv->qdiscs[ntx]);
> +
> +	if (priv->hw_owned && dev->netdev_ops->ndo_setup_tc)
> +		dev->netdev_ops->ndo_setup_tc(dev, 0);
> +	else
> +		netdev_set_num_tc(dev, 0);

I'm not sure why this unsetting is needed in case it was set by a
driver before mqprio was created.

> +
> +	kfree(priv->qdiscs);
> +}
> +
> +static int mqprio_parse_opt(struct net_device *dev, struct tc_mqprio_qopt *qopt)
> +{
> +	int i, j;
> +
> +	/* Verify num_tc is not out of max range */
> +	if (qopt->num_tc > TC_MAX_QUEUE)
> +		return -EINVAL;
> +
> +	for (i = 0; i < qopt->num_tc; i++) {
> +		unsigned int last = qopt->offset[i] + qopt->count[i];
> +		/* Verify the queue offset is in the num tx range */
> +		if (qopt->offset[i] >= dev->num_tx_queues)
> +			return -EINVAL;
> +		/* Verify the queue count is in tx range being equal to the
> +		 * num_tx_queues indicates the last queue is in use.
> +		 */
> +		else if (last > dev->num_tx_queues)
> +			return -EINVAL;
> +
> +		/* Verify that the offset and counts do not overlap */
> +		for (j = i + 1; j < qopt->num_tc; j++) {
> +			if (last > qopt->offset[j])
> +				return -EINVAL;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct mqprio_sched *priv = qdisc_priv(sch);
> +	struct netdev_queue *dev_queue;
> +	struct Qdisc *qdisc;
> +	int i, err = -EOPNOTSUPP;
> +	struct tc_mqprio_qopt *qopt = NULL;
> +
> +	/* Unwind attributes on failure */
> +	u8 unwnd_tc = dev->num_tc;
> +	u8 unwnd_map[TC_BITMASK+1];

 	u8 unwnd_map[TC_BITMASK + 1];

> +	struct netdev_tc_txq unwnd_txq[TC_MAX_QUEUE];
> +
> +	if (sch->parent != TC_H_ROOT)
> +		return -EOPNOTSUPP;
> +
> +	if (!netif_is_multiqueue(dev))
> +		return -EOPNOTSUPP;
> +
> +	if (nla_len(opt) < sizeof(*qopt))
> +		return -EINVAL;
> +	qopt = nla_data(opt);
> +
> +	memcpy(unwnd_map, dev->prio_tc_map, sizeof(unwnd_map));
> +	memcpy(unwnd_txq, dev->tc_to_txq, sizeof(unwnd_txq));
> +
> +	/* If the mqprio options indicate that hardware should own
> +	 * the queue mapping then run ndo_setup_tc if this can not
> +	 * be done fail immediately.
> +	 */
> +	if (qopt->hw && dev->netdev_ops->ndo_setup_tc) {
> +		priv->hw_owned = 1;
> +		err = dev->netdev_ops->ndo_setup_tc(dev, qopt->num_tc);
> +		if (err)
> +			return err;
> +	} else if (!qopt->hw) {
> +		if (mqprio_parse_opt(dev, qopt))
> +			return -EINVAL;
> +
> +		if (netdev_set_num_tc(dev, qopt->num_tc))
> +			return -EINVAL;
> +
> +		for (i = 0; i < qopt->num_tc; i++)
> +			netdev_set_tc_queue(dev, i,
> +					    qopt->count[i], qopt->offset[i]);
> +	} else {
> +		return -EINVAL;
> +	}
> +
> +	/* Always use supplied priority mappings */
> +	for (i = 0; i < TC_BITMASK+1; i++) {

	for (i = 0; i < TC_BITMASK + 1; i++) {

> +		if (netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i])) {
> +			err = -EINVAL;
> +			goto tc_err;
> +		}
> +	}
> +
> +	/* pre-allocate qdisc, attachment can't fail */
> +	priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
> +			       GFP_KERNEL);
> +	if (priv->qdiscs == NULL) {
> +		err = -ENOMEM;
> +		goto tc_err;
> +	}
> +
> +	for (i = 0; i < dev->num_tx_queues; i++) {
> +		dev_queue = netdev_get_tx_queue(dev, i);
> +		qdisc = qdisc_create_dflt(dev_queue, &pfifo_fast_ops,
> +					  TC_H_MAKE(TC_H_MAJ(sch->handle),
> +						    TC_H_MIN(i + 1)));
> +		if (qdisc == NULL) {
> +			err = -ENOMEM;
> +			goto err;
> +		}
> +		qdisc->flags |= TCQ_F_CAN_BYPASS;
> +		priv->qdiscs[i] = qdisc;
> +	}
> +
> +	sch->flags |= TCQ_F_MQROOT;
> +	return 0;
> +
> +err:
> +	mqprio_destroy(sch);
> +tc_err:
> +	if (priv->hw_owned)
> +		dev->netdev_ops->ndo_setup_tc(dev, unwnd_tc);
> +	else
> +		netdev_set_num_tc(dev, unwnd_tc);
> +
> +	memcpy(dev->prio_tc_map, unwnd_map, sizeof(unwnd_map));
> +	memcpy(dev->tc_to_txq, unwnd_txq, sizeof(unwnd_txq));
> +
> +	return err;
> +}
> +
> +static void mqprio_attach(struct Qdisc *sch)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct mqprio_sched *priv = qdisc_priv(sch);
> +	struct Qdisc *qdisc;
> +	unsigned int ntx;
> +
> +	/* Attach underlying qdisc */
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
> +static struct netdev_queue *mqprio_queue_get(struct Qdisc *sch,
> +					     unsigned long cl)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	unsigned long ntx = cl - 1;
> +
> +	if (ntx >= dev->num_tx_queues)
> +		return NULL;
> +	return netdev_get_tx_queue(dev, ntx);
> +}
> +
> +static int mqprio_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
> +		    struct Qdisc **old)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
> +
> +	if (dev->flags & IFF_UP)
> +		dev_deactivate(dev);
> +
> +	*old = dev_graft_qdisc(dev_queue, new);
> +
> +	if (dev->flags & IFF_UP)
> +		dev_activate(dev);
> +
> +	return 0;
> +}
> +
> +static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct mqprio_sched *priv = qdisc_priv(sch);
> +	unsigned char *b = skb_tail_pointer(skb);
> +	struct tc_mqprio_qopt opt;
> +	struct Qdisc *qdisc;
> +	unsigned int i;
> +
> +	sch->q.qlen = 0;
> +	memset(&sch->bstats, 0, sizeof(sch->bstats));
> +	memset(&sch->qstats, 0, sizeof(sch->qstats));
> +
> +	for (i = 0; i < dev->num_tx_queues; i++) {
> +		qdisc = netdev_get_tx_queue(dev, i)->qdisc;
> +		spin_lock_bh(qdisc_lock(qdisc));
> +		sch->q.qlen		+= qdisc->q.qlen;
> +		sch->bstats.bytes	+= qdisc->bstats.bytes;
> +		sch->bstats.packets	+= qdisc->bstats.packets;
> +		sch->qstats.qlen	+= qdisc->qstats.qlen;
> +		sch->qstats.backlog	+= qdisc->qstats.backlog;
> +		sch->qstats.drops	+= qdisc->qstats.drops;
> +		sch->qstats.requeues	+= qdisc->qstats.requeues;
> +		sch->qstats.overlimits	+= qdisc->qstats.overlimits;
> +		spin_unlock_bh(qdisc_lock(qdisc));
> +	}
> +
> +	opt.num_tc = dev->num_tc;
> +	memcpy(opt.prio_tc_map, dev->prio_tc_map, 16);

s/16/TC_SOMETHING

> +	opt.hw = priv->hw_owned;
> +
> +	for (i = 0; i < dev->num_tc; i++) {
> +		opt.count[i] = dev->tc_to_txq[i].count;
> +		opt.offset[i] = dev->tc_to_txq[i].offset;
> +	}
> +
> +	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
> +
> +	return skb->len;
> +nla_put_failure:
> +	nlmsg_trim(skb, b);
> +	return -1;
> +}
> +
> +static struct Qdisc *mqprio_leaf(struct Qdisc *sch, unsigned long cl)
> +{
> +	struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
> +
> +	return dev_queue->qdisc_sleeping;
> +}
> +
> +static unsigned long mqprio_get(struct Qdisc *sch, u32 classid)
> +{
> +	unsigned int ntx = TC_H_MIN(classid);
> +
> +	if (!mqprio_queue_get(sch, ntx))
> +		return 0;
> +	return ntx;
> +}
> +
> +static void mqprio_put(struct Qdisc *sch, unsigned long cl)
> +{
> +}
> +
> +static int mqprio_dump_class(struct Qdisc *sch, unsigned long cl,
> +			 struct sk_buff *skb, struct tcmsg *tcm)
> +{
> +	struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
> +
> +	tcm->tcm_parent = TC_H_ROOT;
> +	tcm->tcm_handle |= TC_H_MIN(cl);
> +	tcm->tcm_info = dev_queue->qdisc_sleeping->handle;
> +	return 0;
> +}
> +
> +static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
> +			       struct gnet_dump *d)
> +{
> +	struct netdev_queue *dev_queue = mqprio_queue_get(sch, cl);
> +
> +	sch = dev_queue->qdisc_sleeping;
> +	sch->qstats.qlen = sch->q.qlen;
> +	if (gnet_stats_copy_basic(d, &sch->bstats) < 0 ||
> +	    gnet_stats_copy_queue(d, &sch->qstats) < 0)
> +		return -1;
> +	return 0;
> +}
> +
> +static void mqprio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	unsigned long ntx;
> +
> +	if (arg->stop)
> +		return;
> +
> +	arg->count = arg->skip;
> +	for (ntx = arg->skip; ntx < dev->num_tx_queues; ntx++) {

Did you give up those stats per tc class? You only show the leaf
classes here, but you could first loop per num_tc (as virtual
parent classes). So in dump_class_stats you should be able to
distinguish class 'level' by cl and do the second loop if necessary.
To show the class hierarchy you change tcm_parent in dump_class
for 'leaf' classes (like eg in sch_htb/htb_dump_class).

Jarek P.

> +		if (arg->fn(sch, ntx + 1, arg) < 0) {
> +			arg->stop = 1;
> +			break;
> +		}
> +		arg->count++;
> +	}
> +}
> +
> +static const struct Qdisc_class_ops mqprio_class_ops = {
> +	.graft		= mqprio_graft,
> +	.leaf		= mqprio_leaf,
> +	.get		= mqprio_get,
> +	.put		= mqprio_put,
> +	.walk		= mqprio_walk,
> +	.dump		= mqprio_dump_class,
> +	.dump_stats	= mqprio_dump_class_stats,
> +};
> +
> +struct Qdisc_ops mqprio_qdisc_ops __read_mostly = {
> +	.cl_ops		= &mqprio_class_ops,
> +	.id		= "mqprio",
> +	.priv_size	= sizeof(struct mqprio_sched),
> +	.init		= mqprio_init,
> +	.destroy	= mqprio_destroy,
> +	.attach		= mqprio_attach,
> +	.dump		= mqprio_dump,
> +	.owner		= THIS_MODULE,
> +};
> +
> +static int __init mqprio_module_init(void)
> +{
> +	return register_qdisc(&mqprio_qdisc_ops);
> +}
> +
> +static void __exit mqprio_module_exit(void)
> +{
> +	unregister_qdisc(&mqprio_qdisc_ops);
> +}
> +
> +module_init(mqprio_module_init);
> +module_exit(mqprio_module_exit);
> +
> +MODULE_LICENSE("GPL");
> 
