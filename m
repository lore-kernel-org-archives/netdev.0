From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH 3/4] net_sched: implement a root container qdisc
	sch_mclass
Date: Fri, 17 Dec 2010 07:34:51 -0800
Message-ID: <20101217153451.12170.66224.stgit@jf-dev1-dcblab>
References: <20101217153439.12170.39538.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, shemminger@vyatta.com,
	tgraf@infradead.org, eric.dumazet@gmail.com, nhorman@tuxdriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62225 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755173Ab0LQPh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 10:37:29 -0500
In-Reply-To: <20101217153439.12170.39538.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements a mclass 'multi-class' queueing discipline that by
default creates multiple mq qdisc's one for each traffic class. Each
mq qdisc then owns a range of queues per the netdev_tc_txq mappings.

Using the mclass qdisc the number of tcs currently in use along
with the range of queues alloted to each class can be configured. By
default skbs are mapped to traffic classes using the skb priority.
This mapping is configurable.

Configurable parameters,

struct tc_mclass_qopt {
        __u8    num_tc;
        __u8    prio_tc_map[16];
        __u8    hw;
        __u16   count[16];
        __u16   offset[16];
};

Here the count/offset pairing give the queue alignment and the
prio_tc_map gives the mapping from skb->priority to tc. The
hw bit determines if the hardware should configure the count
and offset values. If the hardware bit is set then the operation
will fail if the hardware does not implement the ndo_setup_tc
operation. This is to avoid undetermined states where the hardware
may or may not control the queue mapping. Also minimal bounds
checking is done on the count/offset to verify a queue does not
exceed num_tx_queues and that queue ranges do not overlap. Otherwise
it is left to user policy or hardware configuration to create
useful mappings.

It is expected that hardware QOS schemes can be implemented by
creating appropriate mappings of queues in ndo_tc_setup(). This
scheme can be expanded as needed with additional qdisc being graft'd
onto the root qdisc to provide per tc queuing disciplines. Allowing
Software and hardware queuing disciplines can be used together

One expected use case is drivers will use the ndo_setup_tc to map
queue ranges onto 802.1Q traffic classes. This provides a generic
mechanism to map network traffic onto these traffic classes and
removes the need for lower layer drivers to no specifics about
traffic types.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/netdevice.h |    3 
 include/linux/pkt_sched.h |    9 +
 include/net/sch_generic.h |    1 
 net/sched/Makefile        |    2 
 net/sched/sch_api.c       |    1 
 net/sched/sch_generic.c   |    8 +
 net/sched/sch_mclass.c    |  375 +++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 397 insertions(+), 2 deletions(-)
 create mode 100644 net/sched/sch_mclass.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9694138..169a23f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -762,6 +762,8 @@ struct netdev_tc_txq {
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
  *			  struct nlattr *port[]);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
+ *
+ * int (*ndo_setup_tc)(struct net_device *dev, int tc);
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -820,6 +822,7 @@ struct net_device_ops {
 						   struct nlattr *port[]);
 	int			(*ndo_get_vf_port)(struct net_device *dev,
 						   int vf, struct sk_buff *skb);
+	int			(*ndo_setup_tc)(struct net_device *dev, u8 tc);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 2cfa4bc..0134ed4 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -481,4 +481,13 @@ struct tc_drr_stats {
 	__u32	deficit;
 };
 
+/* MCLASS */
+struct tc_mclass_qopt {
+	__u8	num_tc;
+	__u8	prio_tc_map[16];
+	__u8	hw;
+	__u16	count[16];
+	__u16	offset[16];
+};
+
 #endif
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ea1f8a8..2bbcd09 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -276,6 +276,7 @@ extern struct Qdisc noop_qdisc;
 extern struct Qdisc_ops noop_qdisc_ops;
 extern struct Qdisc_ops pfifo_fast_ops;
 extern struct Qdisc_ops mq_qdisc_ops;
+extern struct Qdisc_ops mclass_qdisc_ops;
 
 struct Qdisc_class_common {
 	u32			classid;
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 960f5db..76dcf5b 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -2,7 +2,7 @@
 # Makefile for the Linux Traffic Control Unit.
 #
 
-obj-y	:= sch_generic.o sch_mq.o
+obj-y	:= sch_generic.o sch_mq.o sch_mclass.o
 
 obj-$(CONFIG_NET_SCHED)		+= sch_api.o sch_blackhole.o
 obj-$(CONFIG_NET_CLS)		+= cls_api.o
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b22ca2d..24f40e0 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1770,6 +1770,7 @@ static int __init pktsched_init(void)
 	register_qdisc(&bfifo_qdisc_ops);
 	register_qdisc(&pfifo_head_drop_qdisc_ops);
 	register_qdisc(&mq_qdisc_ops);
+	register_qdisc(&mclass_qdisc_ops);
 
 	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
 	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 0918834..73ed9b7 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -709,7 +709,13 @@ static void attach_default_qdiscs(struct net_device *dev)
 		dev->qdisc = txq->qdisc_sleeping;
 		atomic_inc(&dev->qdisc->refcnt);
 	} else {
-		qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops, TC_H_ROOT);
+		if (dev->num_tc)
+			qdisc = qdisc_create_dflt(txq, &mclass_qdisc_ops,
+						  TC_H_ROOT);
+		else
+			qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops,
+						  TC_H_ROOT);
+
 		if (qdisc) {
 			qdisc->ops->attach(qdisc);
 			dev->qdisc = qdisc;
diff --git a/net/sched/sch_mclass.c b/net/sched/sch_mclass.c
new file mode 100644
index 0000000..551b660
--- /dev/null
+++ b/net/sched/sch_mclass.c
@@ -0,0 +1,375 @@
+/*
+ * net/sched/sch_mclass.c
+ *
+ * Copyright (c) 2010 John Fastabend <john.r.fastabend@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <net/sch_generic.h>
+
+struct mclass_sched {
+	struct Qdisc		**qdiscs;
+	int hw_owned;
+};
+
+static void mclass_destroy(struct Qdisc *sch)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct mclass_sched *priv = qdisc_priv(sch);
+	unsigned int ntc;
+
+	if (!priv->qdiscs)
+		return;
+
+	for (ntc = 0; ntc < dev->num_tc && priv->qdiscs[ntc]; ntc++)
+		qdisc_destroy(priv->qdiscs[ntc]);
+
+	if (priv->hw_owned && dev->netdev_ops->ndo_setup_tc)
+		dev->netdev_ops->ndo_setup_tc(dev, 0);
+	else
+		netdev_set_num_tc(dev, 0);
+
+	kfree(priv->qdiscs);
+}
+
+static int mclass_parse_opt(struct net_device *dev, struct tc_mclass_qopt *qopt)
+{
+	int i, j;
+
+	/* Verify TC offset and count are sane */
+	for (i = 0; i < qopt->num_tc; i++) {
+		int last = qopt->offset[i] + qopt->count[i];
+		if (last > dev->num_tx_queues)
+			return -EINVAL;
+		for (j = i + 1; j < qopt->num_tc; j++) {
+			if (last > qopt->offset[j])
+				return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+static int mclass_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct mclass_sched *priv = qdisc_priv(sch);
+	struct netdev_queue *dev_queue;
+	struct Qdisc *qdisc;
+	int i, err = -EOPNOTSUPP;
+	struct tc_mclass_qopt *qopt = NULL;
+
+	/* Unwind attributes on failure */
+	u8 unwnd_tc = dev->num_tc;
+	u8 unwnd_map[16];
+	struct netdev_tc_txq unwnd_txq[16];
+
+	if (sch->parent != TC_H_ROOT)
+		return -EOPNOTSUPP;
+
+	if (!netif_is_multiqueue(dev))
+		return -EOPNOTSUPP;
+
+	if (nla_len(opt) < sizeof(*qopt))
+		return -EINVAL;
+	qopt = nla_data(opt);
+
+	memcpy(unwnd_map, dev->prio_tc_map, sizeof(unwnd_map));
+	memcpy(unwnd_txq, dev->tc_to_txq, sizeof(unwnd_txq));
+
+	/* If the mclass options indicate that hardware should own
+	 * the queue mapping then run ndo_setup_tc if this can not
+	 * be done fail immediately.
+	 */
+	if (qopt->hw && dev->netdev_ops->ndo_setup_tc) {
+		priv->hw_owned = 1;
+		if (dev->netdev_ops->ndo_setup_tc(dev, qopt->num_tc))
+			return -EINVAL;
+	} else if (!qopt->hw) {
+		if (mclass_parse_opt(dev, qopt))
+			return -EINVAL;
+
+		if (netdev_set_num_tc(dev, qopt->num_tc))
+			return -ENOMEM;
+
+		for (i = 0; i < qopt->num_tc; i++)
+			netdev_set_tc_queue(dev, i,
+					    qopt->count[i], qopt->offset[i]);
+	} else {
+		return -EINVAL;
+	}
+
+	/* Always use supplied priority mappings */
+	for (i = 0; i < 16; i++) {
+		if (netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i])) {
+			err = -EINVAL;
+			goto tc_err;
+		}
+	}
+
+	/* pre-allocate qdisc, attachment can't fail */
+	priv->qdiscs = kcalloc(qopt->num_tc,
+			       sizeof(priv->qdiscs[0]), GFP_KERNEL);
+	if (priv->qdiscs == NULL) {
+		err = -ENOMEM;
+		goto tc_err;
+	}
+
+	for (i = 0; i < dev->num_tc; i++) {
+		dev_queue = netdev_get_tx_queue(dev, dev->tc_to_txq[i].offset);
+		qdisc = qdisc_create_dflt(dev_queue, &mq_qdisc_ops,
+					  TC_H_MAKE(TC_H_MAJ(sch->handle),
+						    TC_H_MIN(i + 1)));
+		if (qdisc == NULL) {
+			err = -ENOMEM;
+			goto err;
+		}
+		qdisc->flags |= TCQ_F_CAN_BYPASS;
+		priv->qdiscs[i] = qdisc;
+	}
+
+	sch->flags |= TCQ_F_MQROOT;
+	return 0;
+
+err:
+	mclass_destroy(sch);
+tc_err:
+	if (priv->hw_owned)
+		dev->netdev_ops->ndo_setup_tc(dev, unwnd_tc);
+	else
+		netdev_set_num_tc(dev, unwnd_tc);
+
+	memcpy(dev->prio_tc_map, unwnd_map, sizeof(unwnd_map));
+	memcpy(dev->tc_to_txq, unwnd_txq, sizeof(unwnd_txq));
+
+	return err;
+}
+
+static void mclass_attach(struct Qdisc *sch)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct mclass_sched *priv = qdisc_priv(sch);
+	struct Qdisc *qdisc;
+	unsigned int ntc;
+
+	/* Attach underlying qdisc */
+	for (ntc = 0; ntc < dev->num_tc; ntc++) {
+		qdisc = priv->qdiscs[ntc];
+		if (qdisc->ops && qdisc->ops->attach)
+			qdisc->ops->attach(qdisc);
+	}
+}
+
+static int mclass_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
+		    struct Qdisc **old)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct mclass_sched *priv = qdisc_priv(sch);
+	unsigned long ntc = cl - 1;
+
+	if (ntc >= dev->num_tc)
+		return -EINVAL;
+
+	if (dev->flags & IFF_UP)
+		dev_deactivate(dev);
+
+	*old = priv->qdiscs[ntc];
+	if (new == NULL)
+		new = &noop_qdisc;
+	priv->qdiscs[ntc] = new;
+	qdisc_reset(*old);
+
+	if (dev->flags & IFF_UP)
+		dev_activate(dev);
+
+	return 0;
+}
+
+static int mclass_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct mclass_sched *priv = qdisc_priv(sch);
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tc_mclass_qopt opt;
+	struct Qdisc *qdisc;
+	unsigned int i;
+
+	sch->q.qlen = 0;
+	memset(&sch->bstats, 0, sizeof(sch->bstats));
+	memset(&sch->qstats, 0, sizeof(sch->qstats));
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		qdisc = netdev_get_tx_queue(dev, i)->qdisc;
+		spin_lock_bh(qdisc_lock(qdisc));
+		sch->q.qlen		+= qdisc->q.qlen;
+		sch->bstats.bytes	+= qdisc->bstats.bytes;
+		sch->bstats.packets	+= qdisc->bstats.packets;
+		sch->qstats.qlen	+= qdisc->qstats.qlen;
+		sch->qstats.backlog	+= qdisc->qstats.backlog;
+		sch->qstats.drops	+= qdisc->qstats.drops;
+		sch->qstats.requeues	+= qdisc->qstats.requeues;
+		sch->qstats.overlimits	+= qdisc->qstats.overlimits;
+		spin_unlock_bh(qdisc_lock(qdisc));
+	}
+
+	opt.num_tc = dev->num_tc;
+	memcpy(opt.prio_tc_map, dev->prio_tc_map, 16);
+	opt.hw = priv->hw_owned;
+
+	for (i = 0; i < dev->num_tc; i++) {
+		opt.count[i] = dev->tc_to_txq[i].count;
+		opt.offset[i] = dev->tc_to_txq[i].offset;
+	}
+
+	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+
+	return skb->len;
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static struct Qdisc *mclass_leaf(struct Qdisc *sch, unsigned long cl)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	struct mclass_sched *priv = qdisc_priv(sch);
+	unsigned long ntc = cl - 1;
+
+	if (ntc >= dev->num_tc)
+		return NULL;
+	return priv->qdiscs[ntc];
+}
+
+static unsigned long mclass_get(struct Qdisc *sch, u32 classid)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	unsigned int ntc = TC_H_MIN(classid);
+
+	if (ntc >= dev->num_tc)
+		return 0;
+	return ntc;
+}
+
+static void mclass_put(struct Qdisc *sch, unsigned long cl)
+{
+}
+
+static int mclass_dump_class(struct Qdisc *sch, unsigned long cl,
+			 struct sk_buff *skb, struct tcmsg *tcm)
+{
+	struct Qdisc *class;
+	struct net_device *dev = qdisc_dev(sch);
+	struct mclass_sched *priv = qdisc_priv(sch);
+	unsigned long ntc = cl - 1;
+
+	if (ntc >= dev->num_tc)
+		return -EINVAL;
+
+	class = priv->qdiscs[ntc];
+
+	tcm->tcm_parent = TC_H_ROOT;
+	tcm->tcm_handle |= TC_H_MIN(cl);
+	tcm->tcm_info = class->handle;
+	return 0;
+}
+
+static int mclass_dump_class_stats(struct Qdisc *sch, unsigned long cl,
+			       struct gnet_dump *d)
+{
+	struct Qdisc *class, *qdisc;
+	struct net_device *dev = qdisc_dev(sch);
+	struct mclass_sched *priv = qdisc_priv(sch);
+	unsigned long ntc = cl - 1;
+	unsigned int i;
+	u16 count, offset;
+
+	if (ntc >= dev->num_tc)
+		return -EINVAL;
+
+	class = priv->qdiscs[ntc];
+	count = dev->tc_to_txq[ntc].count;
+	offset = dev->tc_to_txq[ntc].offset;
+
+	memset(&class->bstats, 0, sizeof(class->bstats));
+	memset(&class->qstats, 0, sizeof(class->qstats));
+
+	/* Drop lock here it will be reclaimed before touching statistics
+	 * this is required because the qdisc_root_sleeping_lock we hold
+	 * here is the look on dev_queue->qdisc_sleeping also acquired
+	 * below.
+	 */
+	spin_unlock_bh(d->lock);
+
+	for (i = offset; i < offset + count; i++) {
+		qdisc = netdev_get_tx_queue(dev, i)->qdisc;
+		spin_lock_bh(qdisc_lock(qdisc));
+		class->q.qlen		 += qdisc->q.qlen;
+		class->bstats.bytes	 += qdisc->bstats.bytes;
+		class->bstats.packets	 += qdisc->bstats.packets;
+		class->qstats.qlen	 += qdisc->qstats.qlen;
+		class->qstats.backlog	 += qdisc->qstats.backlog;
+		class->qstats.drops	 += qdisc->qstats.drops;
+		class->qstats.requeues	 += qdisc->qstats.requeues;
+		class->qstats.overlimits += qdisc->qstats.overlimits;
+		spin_unlock_bh(qdisc_lock(qdisc));
+	}
+
+	/* Reclaim root sleeping lock before completing stats */
+	spin_lock_bh(d->lock);
+
+	class->qstats.qlen = class->q.qlen;
+	if (gnet_stats_copy_basic(d, &class->bstats) < 0 ||
+	    gnet_stats_copy_queue(d, &class->qstats) < 0)
+		return -1;
+	return 0;
+}
+
+static void mclass_walk(struct Qdisc *sch, struct qdisc_walker *arg)
+{
+	struct net_device *dev = qdisc_dev(sch);
+	unsigned long ntc;
+
+	if (arg->stop)
+		return;
+
+	arg->count = arg->skip;
+	for (ntc = arg->skip; ntc < dev->num_tc; ntc++) {
+		if (arg->fn(sch, ntc + 1, arg) < 0) {
+			arg->stop = 1;
+			break;
+		}
+		arg->count++;
+	}
+}
+
+static const struct Qdisc_class_ops mclass_class_ops = {
+	.graft		= mclass_graft,
+	.leaf		= mclass_leaf,
+	.get		= mclass_get,
+	.put		= mclass_put,
+	.walk		= mclass_walk,
+	.dump		= mclass_dump_class,
+	.dump_stats	= mclass_dump_class_stats,
+};
+
+struct Qdisc_ops mclass_qdisc_ops __read_mostly = {
+	.cl_ops		= &mclass_class_ops,
+	.id		= "mclass",
+	.priv_size	= sizeof(struct mclass_sched),
+	.init		= mclass_init,
+	.destroy	= mclass_destroy,
+	.attach		= mclass_attach,
+	.dump		= mclass_dump,
+	.owner		= THIS_MODULE,
+};

