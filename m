From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE] ESFQ --> SFQ patches for Linux 2.6.24
Date: Tue, 19 Feb 2008 15:18:39 +0100
Message-ID: <47BAE53F.1000404@trash.net>
References: <479E8BFA.4030304@fatooh.org>	<47AE5D4E.3000204@fatooh.org>	<741dcbb80802091830y117df44fia36bde3cacf95b5e@mail.gmail.com> <20080209.221332.215185649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010304050500060404030802"
Cc: brockn@gmail.com, linux-net@vger.kernel.org,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20080209.221332.215185649.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010304050500060404030802
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: "Brock Noland" <brockn@gmail.com>
> Date: Sat, 9 Feb 2008 20:30:58 -0600
> 
>> Is this going to be merged anytime soon?
> 
> If it gets submitted to the proper mailing list, it might.
> 'linux-net' is for user questions, it is not where the networking
> developers hang out, 'netdev' is.
> 
> And you have to post patches for review, not URL's point to
> the patches.  It has to be int he email, in an applyable form
> so people can review the thing properly.


Since SFQ is not exactly simple and I needed something like this
myself, I followed Paul's suggestion and added a new scheduler
(DRR) for this with more flexible limits.

I'll rediff against net-2.6.26 within the next days and send
a final version for review (anyone interested is welcome to
already review this version of course :).


--------------010304050500060404030802
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 13d0cc64d0f7fed945c357cf4ca43330c8f95ad2
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Feb 18 22:21:55 2008 +0100

    [NET_SCHED]: Add DRR scheduler
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dbb7ac3..2fca9c4 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -482,4 +482,20 @@ struct tc_netem_corrupt
 
 #define NETEM_DIST_SCALE	8192
 
+/* DRR */
+
+enum
+{
+	TCA_DRR_UNSPEC,
+	TCA_DRR_QUANTUM,
+	__TCA_DRR_MAX
+};
+
+#define TCA_DRR_MAX	(__TCA_DRR_MAX - 1)
+
+struct tc_drr_stats
+{
+	s32	deficit;
+};
+
 #endif
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 82adfe6..7e1ab99 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -196,6 +196,9 @@ config NET_SCH_NETEM
 
 	  If unsure, say N.
 
+config NET_SCH_DRR
+	tristate "DRR scheduler"
+
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
 	depends on NET_CLS_ACT
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 1d2b0f7..b055f74 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -28,6 +28,7 @@ obj-$(CONFIG_NET_SCH_TEQL)	+= sch_teql.o
 obj-$(CONFIG_NET_SCH_PRIO)	+= sch_prio.o
 obj-$(CONFIG_NET_SCH_ATM)	+= sch_atm.o
 obj-$(CONFIG_NET_SCH_NETEM)	+= sch_netem.o
+obj-$(CONFIG_NET_SCH_DRR)	+= sch_drr.o
 obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
 obj-$(CONFIG_NET_CLS_FW)	+= cls_fw.o
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
new file mode 100644
index 0000000..aa241b5
--- /dev/null
+++ b/net/sched/sch_drr.c
@@ -0,0 +1,534 @@
+/*
+ * net/sched/sch_drr.c         Deficit Round Robin scheduler
+ *
+ * Copyright (c) 2008 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/pkt_sched.h>
+#include <net/sch_generic.h>
+#include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
+
+struct drr_class {
+	struct hlist_node		hlist;
+	u32				classid;
+	unsigned int			refcnt;
+
+	struct gnet_stats_basic		bstats;
+	struct gnet_stats_queue		qstats;
+	struct gnet_stats_rate_est	rate_est;
+	struct list_head		alist;
+	struct Qdisc *			qdisc;
+
+	u32				quantum;
+	s32				deficit;
+};
+
+#define DRR_HSIZE	16
+
+struct drr_sched {
+	struct list_head		active;
+	struct tcf_proto *		filter_list;
+	unsigned int			filter_cnt;
+	struct hlist_head		clhash[DRR_HSIZE];
+	struct sk_buff *		requeue;
+};
+
+static unsigned int drr_hash(u32 h)
+{
+	h ^= h >> 8;
+	h ^= h >> 4;
+
+	return h & (DRR_HSIZE - 1);
+}
+
+static struct drr_class *drr_find_class(struct Qdisc *sch, u32 classid)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl;
+	struct hlist_node *n;
+
+	hlist_for_each_entry(cl, n, &q->clhash[drr_hash(classid)], hlist) {
+		if (cl->classid == classid)
+			return cl;
+	}
+	return NULL;
+}
+
+static void drr_purge_queue(struct drr_class *cl)
+{
+	unsigned int len = cl->qdisc->q.qlen;
+
+	qdisc_reset(cl->qdisc);
+	qdisc_tree_decrease_qlen(cl->qdisc, len);
+}
+
+static const struct nla_policy drr_policy[TCA_DRR_MAX + 1] = {
+	[TCA_DRR_QUANTUM]	= { .type = NLA_U32 },
+};
+
+static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
+			    struct nlattr **tca, unsigned long *arg)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl = (struct drr_class *)*arg;
+	struct nlattr *tb[TCA_DRR_MAX + 1];
+	u32 quantum;
+	int err;
+
+	err = nla_parse_nested(tb, TCA_DRR_MAX, tca[TCA_OPTIONS], drr_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_DRR_QUANTUM]) {
+		quantum = nla_get_u32(tb[TCA_DRR_QUANTUM]);
+		if (quantum == 0)
+			return -EINVAL;
+	} else
+		quantum = psched_mtu(sch->dev);
+
+	if (cl != NULL) {
+		sch_tree_lock(sch);
+		if (tb[TCA_DRR_QUANTUM])
+			cl->quantum = quantum;
+		sch_tree_unlock(sch);
+
+		if (tca[TCA_RATE])
+			gen_replace_estimator(&cl->bstats, &cl->rate_est,
+					      &sch->dev->queue_lock,
+					      tca[TCA_RATE]);
+		return 0;
+	}
+
+	cl = kzalloc(sizeof(struct drr_class), GFP_KERNEL);
+	if (cl == NULL)
+		return -ENOBUFS;
+
+	cl->refcnt	= 1;
+	cl->classid	= classid;
+	cl->quantum	= quantum;
+	cl->deficit	= quantum;
+	cl->qdisc	= qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+					    classid);
+	if (cl->qdisc == NULL)
+		cl->qdisc = &noop_qdisc;
+
+	if (tca[TCA_RATE])
+		gen_replace_estimator(&cl->bstats, &cl->rate_est,
+				      &sch->dev->queue_lock, tca[TCA_RATE]);
+
+	sch_tree_lock(sch);
+	hlist_add_head(&cl->hlist, &q->clhash[drr_hash(classid)]);
+	sch_tree_unlock(sch);
+
+	*arg = (unsigned long)cl;
+	return 0;
+}
+
+static void drr_destroy_class(struct Qdisc *sch, struct drr_class *cl)
+{
+	gen_kill_estimator(&cl->bstats, &cl->rate_est);
+	qdisc_destroy(cl->qdisc);
+	kfree(cl);
+}
+
+static int drr_delete_class(struct Qdisc *sch, unsigned long arg)
+{
+	struct drr_class *cl = (struct drr_class *)arg;
+
+	sch_tree_lock(sch);
+
+	drr_purge_queue(cl);
+	hlist_del(&cl->hlist);
+
+	if (--cl->refcnt == 0)
+		drr_destroy_class(sch, cl);
+
+	sch_tree_unlock(sch);
+	return 0;
+}
+
+static unsigned long drr_get_class(struct Qdisc *sch, u32 classid)
+{
+	struct drr_class *cl = drr_find_class(sch, classid);
+
+	if (cl != NULL)
+		cl->refcnt++;
+
+	return (unsigned long)cl;
+}
+
+static void drr_put_class(struct Qdisc *sch, unsigned long arg)
+{
+	struct drr_class *cl = (struct drr_class *)arg;
+
+	if (--cl->refcnt == 0)
+		drr_destroy_class(sch, cl);
+}
+
+static struct tcf_proto **drr_tcf_chain(struct Qdisc *sch, unsigned long cl)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+
+	if (cl)
+		return NULL;
+
+	return &q->filter_list;
+}
+
+static unsigned long drr_bind_tcf(struct Qdisc *sch, unsigned long parent,
+				  u32 classid)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl = drr_find_class(sch, classid);
+
+	if (cl != NULL)
+		q->filter_cnt++;
+
+	return (unsigned long)cl;
+}
+
+static void drr_unbind_tcf(struct Qdisc *sch, unsigned long arg)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+
+	q->filter_cnt--;
+}
+
+static int drr_graft_class(struct Qdisc *sch, unsigned long arg,
+			   struct Qdisc *new, struct Qdisc **old)
+{
+	struct drr_class *cl = (struct drr_class *)arg;
+
+	if (new == NULL) {
+		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+					cl->classid);
+		if (new == NULL)
+			new = &noop_qdisc;
+	}
+
+	sch_tree_lock(sch);
+	drr_purge_queue(cl);
+	*old = xchg(&cl->qdisc, new);
+	sch_tree_unlock(sch);
+	return 0;
+}
+
+static struct Qdisc *drr_class_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	struct drr_class *cl = (struct drr_class *)arg;
+
+	return cl->qdisc;
+}
+
+static void drr_qlen_notify(struct Qdisc *csh, unsigned long arg)
+{
+	struct drr_class *cl = (struct drr_class *)arg;
+
+	if (cl->qdisc->q.qlen == 0)
+		list_del(&cl->alist);
+}
+
+static int drr_dump_class(struct Qdisc *sch, unsigned long arg,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+	struct drr_class *cl = (struct drr_class *)arg;
+	struct nlattr *nest;
+
+	tcm->tcm_parent	= TC_H_ROOT;
+	tcm->tcm_handle	= cl->classid;
+	tcm->tcm_info	= cl->qdisc->handle;
+
+	nest = nla_nest_start(skb, TCA_OPTIONS);
+	if (nest == NULL)
+		goto nla_put_failure;
+
+	NLA_PUT_U32(skb, TCA_DRR_QUANTUM, cl->quantum);
+
+	nla_nest_end(skb, nest);
+	return skb->len;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
+	return -1;
+}
+
+static int drr_dump_class_stats(struct Qdisc *sch, unsigned long arg,
+				struct gnet_dump *d)
+{
+	struct drr_class *cl = (struct drr_class *)arg;
+	struct tc_drr_stats xstats = {
+		.deficit	= cl->deficit,
+	};
+
+	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+	    gnet_stats_copy_queue(d, &cl->qdisc->qstats) < 0)
+		return -1;
+
+	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
+}
+
+static void drr_walk(struct Qdisc *sch, struct qdisc_walker *arg)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl;
+	struct hlist_node *n;
+	unsigned int i;
+
+	if (arg->stop)
+		return;
+
+	for (i = 0; i < DRR_HSIZE; i++) {
+		hlist_for_each_entry(cl, n, &q->clhash[i], hlist) {
+			if (arg->count < arg->skip) {
+				arg->count++;
+				continue;
+			}
+			if (arg->fn(sch, (unsigned long)cl, arg) < 0) {
+				arg->stop = 1;
+				return;
+			}
+			arg->count++;
+		}
+	}
+}
+
+static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
+				      int *qerr)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl;
+	struct tcf_result res;
+	int result;
+
+	if (TC_H_MAJ(skb->priority ^ sch->handle) == 0) {
+		cl = drr_find_class(sch, skb->priority);
+		if (cl != NULL)
+			return cl;
+	}
+
+	*qerr = NET_XMIT_BYPASS;
+	result = tc_classify(skb, q->filter_list, &res);
+	if (result >= 0) {
+#ifdef CONFIG_NET_CLS_ACT
+		switch (result) {
+		case TC_ACT_QUEUED:
+		case TC_ACT_STOLEN:
+			*qerr = NET_XMIT_SUCCESS;
+		case TC_ACT_SHOT:
+			return NULL;
+		}
+#endif
+		cl = (struct drr_class *)res.class;
+		if (cl == NULL)
+			cl = drr_find_class(sch, res.classid);
+		return cl;
+	}
+	return NULL;
+}
+
+static int drr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl;
+	unsigned int len;
+	int err;
+
+	cl = drr_classify(skb, sch, &err);
+	if (cl == NULL) {
+		if (err == NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return err;
+	}
+
+	len = skb->len;
+	err = cl->qdisc->enqueue(skb, cl->qdisc);
+	if (unlikely(err != NET_XMIT_SUCCESS)) {
+		cl->qstats.drops++;
+		sch->qstats.drops++;
+		return err;
+	}
+
+	if (cl->qdisc->q.qlen == 1)
+		list_add_tail(&cl->alist, &q->active);
+
+	cl->bstats.packets++;
+	cl->bstats.bytes += len;
+	sch->bstats.packets++;
+	sch->bstats.bytes++;
+
+	sch->q.qlen++;
+	return err;
+}
+
+static struct sk_buff *drr_dequeue(struct Qdisc *sch)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl, *next;
+	struct sk_buff *skb;
+
+	if (q->requeue != NULL) {
+		skb = q->requeue;
+		q->requeue = NULL;
+		goto out;
+	}
+
+	list_for_each_entry_safe(cl, next, &q->active, alist) {
+		if (cl->deficit <= 0) {
+			WARN_ON(!cl->qdisc->q.qlen);
+			list_move_tail(&cl->alist, &q->active);
+			cl->deficit += cl->quantum;
+			continue;
+		}
+
+		skb = cl->qdisc->dequeue(cl->qdisc);
+		if (skb == NULL)
+			continue;
+
+		cl->deficit -= skb->len;
+		if (cl->deficit <= 0) {
+			if (cl->qdisc->q.qlen)
+				list_move_tail(&cl->alist, &q->active);
+			cl->deficit += cl->quantum;
+		}
+		if (!cl->qdisc->q.qlen)
+			list_del(&cl->alist);
+out:
+		sch->q.qlen--;
+		return skb;
+	}
+
+	return NULL;
+}
+
+static int drr_requeue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+
+	q->requeue = skb;
+	sch->q.qlen++;
+
+	return NET_XMIT_SUCCESS;
+}
+
+static unsigned int drr_drop(struct Qdisc *sch)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl;
+	unsigned int len;
+
+	list_for_each_entry(cl, &q->active, alist) {
+		if (cl->qdisc->ops->drop) {
+			len = cl->qdisc->ops->drop(cl->qdisc);
+			if (len > 0) {
+				if (cl->qdisc->q.qlen == 0)
+					list_del(&cl->alist);
+				return len;
+			}
+		}
+	}
+	return 0;
+}
+
+static int drr_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	unsigned int i;
+
+	for (i = 0; i < DRR_HSIZE; i++)
+		INIT_HLIST_HEAD(&q->clhash[i]);
+	INIT_LIST_HEAD(&q->active);
+	return 0;
+}
+
+static void drr_reset_qdisc(struct Qdisc *sch)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl;
+	struct hlist_node *n;
+	unsigned int i;
+
+	if (q->requeue) {
+		kfree_skb(q->requeue);
+		q->requeue = NULL;
+	}
+	for (i = 0; i < DRR_HSIZE; i++) {
+		hlist_for_each_entry(cl, n, &q->clhash[i], hlist) {
+			if (cl->qdisc->q.qlen)
+				list_del(&cl->alist);
+			qdisc_reset(cl->qdisc);
+			cl->deficit = cl->quantum;
+		}
+	}
+	sch->q.qlen = 0;
+}
+
+static void drr_destroy_qdisc(struct Qdisc *sch)
+{
+	struct drr_sched *q = qdisc_priv(sch);
+	struct drr_class *cl;
+	struct hlist_node *n, *next;
+	unsigned int i;
+
+	tcf_destroy_chain(q->filter_list);
+
+	for (i = 0; i < DRR_HSIZE; i++) {
+		hlist_for_each_entry_safe(cl, n, next, &q->clhash[i], hlist)
+			drr_destroy_class(sch, cl);
+	}
+}
+
+static const struct Qdisc_class_ops drr_class_ops = {
+	.change		= drr_change_class,
+	.delete		= drr_delete_class,
+	.get		= drr_get_class,
+	.put		= drr_put_class,
+	.tcf_chain	= drr_tcf_chain,
+	.bind_tcf	= drr_bind_tcf,
+	.unbind_tcf	= drr_unbind_tcf,
+	.graft		= drr_graft_class,
+	.leaf		= drr_class_leaf,
+	.qlen_notify	= drr_qlen_notify,
+	.dump		= drr_dump_class,
+	.dump_stats	= drr_dump_class_stats,
+	.walk		= drr_walk,
+};
+
+static struct Qdisc_ops drr_qdisc_ops __read_mostly = {
+	.cl_ops		= &drr_class_ops,
+	.id		= "drr",
+	.priv_size	= sizeof(struct drr_sched),
+	.enqueue	= drr_enqueue,
+	.dequeue	= drr_dequeue,
+	.requeue	= drr_requeue,
+	.drop		= drr_drop,
+	.init		= drr_init_qdisc,
+	.reset		= drr_reset_qdisc,
+	.destroy	= drr_destroy_qdisc,
+	.owner		= THIS_MODULE,
+};
+
+static int __init drr_init(void)
+{
+	return register_qdisc(&drr_qdisc_ops);
+}
+
+static void __exit drr_exit(void)
+{
+	unregister_qdisc(&drr_qdisc_ops);
+}
+
+module_init(drr_init);
+module_exit(drr_exit);
+MODULE_LICENSE("GPL");

--------------010304050500060404030802--
