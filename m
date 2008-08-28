From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET_NEXT PATCH 1/2] pkt_sched: Add multiqueue scheduler support
Date: Wed, 27 Aug 2008 18:12:53 -0700
Message-ID: <20080828011253.7909.5172.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:44018 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbYH1BM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 21:12:57 -0400
Received: by rv-out-0506.google.com with SMTP id k40so130630rvb.1
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 18:12:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is intended to add a qdisc to support the new tx multiqueue
architecture by providing a band for each hardware queue.  By doing
this it is possible to support a different qdisc per physical hardware
queue.

This qdisc uses the skb->queue_mapping to select which band to place
the traffic onto.  It then uses a round robin w/ a check to see if the
subqueue is stopped to determine which band to dequeue the packet from.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/pkt_sched.h |    6 +
 net/sched/Kconfig         |    9 +
 net/sched/Makefile        |    1 
 net/sched/sch_multiq.c    |  474 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 490 insertions(+), 0 deletions(-)
 create mode 100644 net/sched/sch_multiq.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index e5de421..7fbc952 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -123,6 +123,12 @@ struct tc_prio_qopt
 	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
 };
 
+/* MULTIQ section */
+
+struct tc_multiq_qopt {
+	int	bands;			/* Number of bands */
+};
+
 /* TBF section */
 
 struct tc_tbf_qopt
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 9437b27..efaa7a7 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -106,6 +106,15 @@ config NET_SCH_PRIO
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_prio.
 
+config NET_SCH_MULTIQ
+	tristate "Hardware Multiqueue-aware Multi Band Queuing (MULTIQ)"
+	---help---
+	  Say Y here if you want to use an n-band queue packet scheduler
+	  to support devices that have multiple hardware transmit queues.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called sch_multiq.
+
 config NET_SCH_RED
 	tristate "Random Early Detection (RED)"
 	---help---
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 1d2b0f7..3d9b953 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -26,6 +26,7 @@ obj-$(CONFIG_NET_SCH_SFQ)	+= sch_sfq.o
 obj-$(CONFIG_NET_SCH_TBF)	+= sch_tbf.o
 obj-$(CONFIG_NET_SCH_TEQL)	+= sch_teql.o
 obj-$(CONFIG_NET_SCH_PRIO)	+= sch_prio.o
+obj-$(CONFIG_NET_SCH_MULTIQ)	+= sch_multiq.o
 obj-$(CONFIG_NET_SCH_ATM)	+= sch_atm.o
 obj-$(CONFIG_NET_SCH_NETEM)	+= sch_netem.o
 obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
new file mode 100644
index 0000000..886690e
--- /dev/null
+++ b/net/sched/sch_multiq.c
@@ -0,0 +1,474 @@
+/*
+ * net/sched/sch_multiq.c
+ * 		This qdisc is based off of the rr qdisc and is meant to
+ * 		prevent head-of-line blocking on devices that have multiple
+ * 		hardware queues.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Alexander Duyck <alexander.h.duyck@intel.com>
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+
+
+struct multiq_sched_data {
+	int bands;
+	int curband;
+	struct tcf_proto *filter_list;
+	struct Qdisc **queues;
+
+};
+
+
+static struct Qdisc *
+multiq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	u32 band;
+	struct tcf_result res;
+	int err;
+
+	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+	err = tc_classify(skb, q->filter_list, &res);
+#ifdef CONFIG_NET_CLS_ACT
+	switch (err) {
+	case TC_ACT_STOLEN:
+	case TC_ACT_QUEUED:
+		*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+	case TC_ACT_SHOT:
+		return NULL;
+	}
+#endif
+	band = skb_get_queue_mapping(skb);
+
+	if (band >= q->bands)
+		return q->queues[0];
+
+	return q->queues[band];
+}
+
+static int
+multiq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct Qdisc *qdisc;
+	int ret;
+
+	qdisc = multiq_classify(skb, sch, &ret);
+#ifdef CONFIG_NET_CLS_ACT
+	if (qdisc == NULL) {
+
+		if (ret & __NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+#endif
+
+	ret = qdisc_enqueue(skb, qdisc);
+	if (ret == NET_XMIT_SUCCESS) {
+		sch->bstats.bytes += qdisc_pkt_len(skb);
+		sch->bstats.packets++;
+		sch->q.qlen++;
+		return NET_XMIT_SUCCESS;
+	}
+	if (net_xmit_drop_count(ret))
+		sch->qstats.drops++;
+	return ret;
+}
+
+
+static int
+multiq_requeue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct Qdisc *qdisc;
+	int ret;
+
+	qdisc = multiq_classify(skb, sch, &ret);
+#ifdef CONFIG_NET_CLS_ACT
+	if (qdisc == NULL) {
+		if (ret & __NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+#endif
+
+	ret = qdisc->ops->requeue(skb, qdisc);
+	if (ret == NET_XMIT_SUCCESS) {
+		sch->q.qlen++;
+		sch->qstats.requeues++;
+		return NET_XMIT_SUCCESS;
+	}
+	if (net_xmit_drop_count(ret))
+		sch->qstats.drops++;
+	return ret;
+}
+
+
+static struct sk_buff *multiq_dequeue(struct Qdisc *sch)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *qdisc;
+	struct sk_buff *skb;
+	int band;
+
+	for (band = 0; band < q->bands; band++) {
+		/* cycle through bands to ensure fairness */
+		q->curband++;
+		if (q->curband >= q->bands)
+			q->curband = 0;
+
+		/* Check that target subqueue is available before
+		 * pulling an skb to avoid excessive requeues
+		 */
+		if (!__netif_subqueue_stopped(qdisc_dev(sch), q->curband)) {
+			qdisc = q->queues[q->curband];
+			skb = qdisc->dequeue(qdisc);
+			if (skb) {
+				sch->q.qlen--;
+				return skb;
+			}
+		}
+	}
+	return NULL;
+
+}
+
+static unsigned int multiq_drop(struct Qdisc *sch)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	int band;
+	unsigned int len;
+	struct Qdisc *qdisc;
+
+	for (band = q->bands-1; band >= 0; band--) {
+		qdisc = q->queues[band];
+		if (qdisc->ops->drop) {
+			len = qdisc->ops->drop(qdisc);
+			if (len != 0) {
+				sch->q.qlen--;
+				return len;
+			}
+		}
+	}
+	return 0;
+}
+
+
+static void
+multiq_reset(struct Qdisc *sch)
+{
+	int band;
+	struct multiq_sched_data *q = qdisc_priv(sch);
+
+	for (band = 0; band < q->bands; band++)
+		qdisc_reset(q->queues[band]);
+	sch->q.qlen = 0;
+}
+
+static void
+multiq_destroy(struct Qdisc *sch)
+{
+	int band;
+	struct multiq_sched_data *q = qdisc_priv(sch);
+
+	tcf_destroy_chain(&q->filter_list);
+	for (band = 0; band < q->bands; band++)
+		qdisc_destroy(q->queues[band]);
+
+	kfree(q->queues);
+}
+
+static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	struct tc_multiq_qopt *qopt;
+	struct Qdisc **queues;
+	int i;
+
+	if (sch->parent != TC_H_ROOT)
+		return -EINVAL;
+	if (!netif_is_multiqueue(qdisc_dev(sch)))
+		return -EINVAL;
+	if (nla_len(opt) < sizeof(*qopt))
+		return -EINVAL;
+
+	qopt = nla_data(opt);
+
+	if (!qopt->bands)
+		qopt->bands = qdisc_dev(sch)->real_num_tx_queues;
+	if (qopt->bands != qdisc_dev(sch)->real_num_tx_queues ||
+	    qopt->bands < 2)
+		return -EINVAL;
+
+	queues = kzalloc(sizeof(struct Qdisc *)*qopt->bands, GFP_KERNEL);
+	if (!queues)
+		return -ENOBUFS;
+
+	for (i = 0; i < qopt->bands; i++)
+		queues[i] = &noop_qdisc;
+
+	sch_tree_lock(sch);
+	q->queues = xchg(&queues, q->queues);
+	if (queues != NULL) {
+		for (i = 0; i < q->bands; i++) {
+			if (queues[i] != &noop_qdisc) {
+				qdisc_tree_decrease_qlen(queues[i],
+							 queues[i]->q.qlen);
+				qdisc_destroy(queues[i]);
+			}
+		}
+		kfree(queues);
+
+	}
+	q->bands = qopt->bands;
+
+	sch_tree_unlock(sch);
+
+	for (i = 0; i < q->bands; i++) {
+		if (q->queues[i] == &noop_qdisc) {
+			struct Qdisc *child;
+			child = qdisc_create_dflt(qdisc_dev(sch),
+						  sch->dev_queue,
+						  &pfifo_qdisc_ops,
+						  TC_H_MAKE(sch->handle,
+							    i + 1));
+			if (child) {
+				sch_tree_lock(sch);
+				child = xchg(&q->queues[i], child);
+
+				if (child != &noop_qdisc) {
+					qdisc_tree_decrease_qlen(child,
+								 child->q.qlen);
+					qdisc_destroy(child);
+				}
+				sch_tree_unlock(sch);
+			}
+		}
+	}
+	return 0;
+}
+
+static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+
+	q->queues = NULL;
+
+	if (opt == NULL)
+		return -EINVAL;
+
+	return multiq_tune(sch, opt);
+}
+
+static int multiq_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	unsigned char *b = skb_tail_pointer(skb);
+	struct nlattr *nest;
+	struct tc_multiq_qopt opt;
+
+	opt.bands = q->bands;
+
+	nest = nla_nest_compat_start(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	if (nest == NULL)
+		goto nla_put_failure;
+	nla_nest_compat_end(skb, nest);
+
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static int multiq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
+		      struct Qdisc **old)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	unsigned long band = arg - 1;
+
+	if (band >= q->bands)
+		return -EINVAL;
+
+	if (new == NULL)
+		new = &noop_qdisc;
+
+	sch_tree_lock(sch);
+	*old = q->queues[band];
+	q->queues[band] = new;
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+	qdisc_reset(*old);
+	sch_tree_unlock(sch);
+
+	return 0;
+}
+
+static struct Qdisc *
+multiq_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	unsigned long band = arg - 1;
+
+	if (band >= q->bands)
+		return NULL;
+
+	return q->queues[band];
+}
+
+static unsigned long multiq_get(struct Qdisc *sch, u32 classid)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	unsigned long band = TC_H_MIN(classid);
+
+	if (band - 1 >= q->bands)
+		return 0;
+	return band;
+}
+
+static unsigned long multiq_bind(struct Qdisc *sch, unsigned long parent,
+				 u32 classid)
+{
+	return multiq_get(sch, classid);
+}
+
+
+static void multiq_put(struct Qdisc *q, unsigned long cl)
+{
+	return;
+}
+
+static int multiq_change(struct Qdisc *sch, u32 handle, u32 parent,
+			 struct nlattr **tca, unsigned long *arg)
+{
+	unsigned long cl = *arg;
+	struct multiq_sched_data *q = qdisc_priv(sch);
+
+	if (cl - 1 > q->bands)
+		return -ENOENT;
+	return 0;
+}
+
+static int multiq_delete(struct Qdisc *sch, unsigned long cl)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	if (cl - 1 > q->bands)
+		return -ENOENT;
+	return 0;
+}
+
+
+static int multiq_dump_class(struct Qdisc *sch, unsigned long cl,
+			     struct sk_buff *skb, struct tcmsg *tcm)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+
+	if (cl - 1 > q->bands)
+		return -ENOENT;
+	tcm->tcm_handle |= TC_H_MIN(cl);
+	if (q->queues[cl-1])
+		tcm->tcm_info = q->queues[cl-1]->handle;
+	return 0;
+}
+
+static int multiq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
+				 struct gnet_dump *d)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *cl_q;
+
+	cl_q = q->queues[cl - 1];
+	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
+	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
+		return -1;
+
+	return 0;
+}
+
+static void multiq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	int band;
+
+	if (arg->stop)
+		return;
+
+	for (band = 0; band < q->bands; band++) {
+		if (arg->count < arg->skip) {
+			arg->count++;
+			continue;
+		}
+		if (arg->fn(sch, band+1, arg) < 0) {
+			arg->stop = 1;
+			break;
+		}
+		arg->count++;
+	}
+}
+
+static struct tcf_proto **multiq_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+
+	if (cl)
+		return NULL;
+	return &q->filter_list;
+}
+
+static const struct Qdisc_class_ops multiq_class_ops = {
+	.graft		=	multiq_graft,
+	.leaf		=	multiq_leaf,
+	.get		=	multiq_get,
+	.put		=	multiq_put,
+	.change		=	multiq_change,
+	.delete		=	multiq_delete,
+	.walk		=	multiq_walk,
+	.tcf_chain	=	multiq_find_tcf,
+	.bind_tcf	=	multiq_bind,
+	.unbind_tcf	=	multiq_put,
+	.dump		=	multiq_dump_class,
+	.dump_stats	=	multiq_dump_class_stats,
+};
+
+static struct Qdisc_ops multiq_qdisc_ops __read_mostly = {
+	.next		=	NULL,
+	.cl_ops		=	&multiq_class_ops,
+	.id		=	"multiq",
+	.priv_size	=	sizeof(struct multiq_sched_data),
+	.enqueue	=	multiq_enqueue,
+	.dequeue	=	multiq_dequeue,
+	.requeue	=	multiq_requeue,
+	.drop		=	multiq_drop,
+	.init		=	multiq_init,
+	.reset		=	multiq_reset,
+	.destroy	=	multiq_destroy,
+	.change		=	multiq_tune,
+	.dump		=	multiq_dump,
+	.owner		=	THIS_MODULE,
+};
+
+static int __init multiq_module_init(void)
+{
+	return register_qdisc(&multiq_qdisc_ops);
+}
+
+static void __exit multiq_module_exit(void)
+{
+	unregister_qdisc(&multiq_qdisc_ops);
+}
+
+module_init(multiq_module_init)
+module_exit(multiq_module_exit)
+
+MODULE_LICENSE("GPL");

