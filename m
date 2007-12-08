From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH net-2.6.25] qdisc: new rate limiter
Date: Fri, 7 Dec 2007 16:26:18 -0800
Message-ID: <20071207162618.35715892@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35472 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753745AbXLHA1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 19:27:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a time based rate limiter for use in network testing. When doing
network tests it is often useful to test at reduced bandwidths. The existing
Token Bucket Filter provides rate control, but causes bursty traffic that
can cause different performance than real world. Another alternative is
the PSPacer, but it depends on pause frames which may also cause issues.

The qdisc depends on high resolution timers and clocks, so it will probably
use more CPU than others making it a poor choice for use when doing traffic
shaping for QOS. 

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/include/linux/pkt_sched.h	2007-10-30 09:18:29.000000000 -0700
+++ b/include/linux/pkt_sched.h	2007-12-07 13:37:50.000000000 -0800
@@ -475,4 +475,10 @@ struct tc_netem_corrupt
 
 #define NETEM_DIST_SCALE	8192
 
+struct tc_rlim_qopt
+{
+	__u32   limit;		/* fifo limit (packets) */
+	__u32	rate;		/* bits per sec */
+};
+
 #endif
--- a/net/sched/Kconfig	2007-12-07 13:37:25.000000000 -0800
+++ b/net/sched/Kconfig	2007-12-07 13:37:50.000000000 -0800
@@ -196,6 +196,19 @@ config NET_SCH_NETEM
 
 	  If unsure, say N.
 
+config NET_SCH_RLIM
+       tristate "Network Rate Limiter"
+	---help---
+	  Say Y here if you want to use timer based network rate limiter
+	  algorithm.
+
+	  See the top of <file:net/sched/sch_rlim.c> for more details.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called sch_rlim.
+
+	  If unsure, say N.
+
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
 	---help---
--- a/net/sched/Makefile	2007-10-30 09:18:30.000000000 -0700
+++ b/net/sched/Makefile	2007-12-07 13:37:50.000000000 -0800
@@ -28,6 +28,7 @@ obj-$(CONFIG_NET_SCH_TEQL)	+= sch_teql.o
 obj-$(CONFIG_NET_SCH_PRIO)	+= sch_prio.o
 obj-$(CONFIG_NET_SCH_ATM)	+= sch_atm.o
 obj-$(CONFIG_NET_SCH_NETEM)	+= sch_netem.o
+obj-$(CONFIG_NET_SCH_RLIM)	+= sch_rlim.o
 obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
 obj-$(CONFIG_NET_CLS_FW)	+= cls_fw.o
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/net/sched/sch_rlim.c	2007-12-07 16:22:10.000000000 -0800
@@ -0,0 +1,350 @@
+/*
+ * net/sched/sch_rate.c	Timer based rate control
+ *
+ * Copyright (c) 2007 Stephen Hemminger <shemminger@linux-foundation.org>
+ *
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
+#include <asm/div64.h>
+
+/*	Simple Rate control
+
+	Algorthim used in NISTnet and others.
+	Logically similar to Token Bucket, but more real time and less lumpy.
+
+	A packet is not allowed to be dequeued until a after the deadline.
+	Each packet dequeued increases the deadline by rate * size.
+
+	If qdisc throttles, it starts a timer, which will wake it up
+	when it is ready to transmit. This scheduler works much better
+	if high resolution timers are available.
+
+	Like classful TBF, limit is just kept for backwards compatibility.
+	It is passed to the default pfifo qdisc - if the inner qdisc is
+	changed the limit is not effective anymore.
+
+*/
+
+/* Use scaled math to get 1/64 ns resolution */
+#define NSEC_SCALE	6
+
+struct rlim_sched_data {
+	ktime_t next_send;	/* next scheduled departure */
+	u64	cost;		/* nsec/byte * 64 */
+	u32	limit;		/* upper bound on fifo (packets) */
+
+	struct Qdisc *qdisc;	/* Inner qdisc, default - bfifo queue */
+	struct qdisc_watchdog watchdog;
+};
+
+static int rlim_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+	int ret;
+
+	ret = q->qdisc->enqueue(skb, q->qdisc);
+	if (ret)
+		sch->qstats.drops++;
+	else {
+		sch->q.qlen++;
+		sch->bstats.bytes += skb->len;
+		sch->bstats.packets++;
+	}
+
+	return ret;
+}
+
+
+static u64 pkt_time(const struct rlim_sched_data *q,
+		    const struct sk_buff *skb)
+{
+	return (q->cost * skb->len) >> NSEC_SCALE;
+}
+
+static unsigned int rlim_drop(struct Qdisc *sch)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+	unsigned int len = 0;
+
+	if (q->qdisc->ops->drop && (len = q->qdisc->ops->drop(q->qdisc)) != 0) {
+		sch->q.qlen--;
+		sch->qstats.drops++;
+	}
+
+	return len;
+}
+
+static struct sk_buff *rlim_dequeue(struct Qdisc *sch)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+	ktime_t now = ktime_get();
+
+	/* if haven't reached the correct time slot, start timer */
+	if (now.tv64 < q->next_send.tv64) {
+		sch->flags |= TCQ_F_THROTTLED;
+		hrtimer_start(&q->watchdog.timer, q->next_send,
+			      HRTIMER_MODE_ABS);
+		return NULL;
+	}
+
+	skb = q->qdisc->dequeue(q->qdisc);
+	if (skb) {
+		q->next_send = ktime_add_ns(now, pkt_time(q, skb));
+		sch->flags &= ~TCQ_F_THROTTLED;
+	}
+	return skb;
+}
+
+static int rlim_requeue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+	int ret;
+
+	ret = q->qdisc->ops->requeue(skb, q->qdisc);
+	if (!ret) {
+		q->next_send = ktime_sub_ns(q->next_send, pkt_time(q, skb));
+		sch->q.qlen++;
+		sch->qstats.requeues++;
+	}
+
+	return ret;
+}
+
+static void rlim_reset(struct Qdisc *sch)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+
+	qdisc_reset_queue(sch);
+
+	q->next_send = ktime_get();
+	qdisc_watchdog_cancel(&q->watchdog);
+}
+
+
+/* Pass size change message down to embedded FIFO */
+static int set_fifo_limit(struct Qdisc *q, int limit)
+{
+	struct rtattr *rta;
+	int ret = -ENOMEM;
+
+	/* Hack to avoid sending change message to non-FIFO */
+	if (strncmp(q->ops->id + 1, "fifo", 4) != 0)
+		return 0;
+
+	rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
+	if (rta) {
+		rta->rta_type = RTM_NEWQDISC;
+		rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
+		((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
+
+		ret = q->ops->change(q, rta);
+		kfree(rta);
+	}
+	return ret;
+}
+
+static int rlim_change(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+	const struct tc_rlim_qopt *qopt;
+	int err;
+
+	if (opt == NULL || RTA_PAYLOAD(opt) < sizeof(struct tc_rlim_qopt))
+		return -EINVAL;
+
+	qopt = RTA_DATA(opt);
+	err = set_fifo_limit(q->qdisc, qopt->limit);
+	if (err)
+		return err;
+
+	q->limit = qopt->limit;
+	if (qopt->rate == 0)
+		q->cost = 0;	/* unlimited */
+	else {
+		q->cost = (u64)NSEC_PER_SEC << NSEC_SCALE;
+		do_div(q->cost, qopt->rate);
+	}
+
+	pr_debug("rlim_change: rate=%u cost=%llu\n",
+		 qopt->rate, q->cost);
+
+	return 0;
+}
+
+static int rlim_init(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+
+	if (opt == NULL || RTA_PAYLOAD(opt) < sizeof(struct tc_rlim_qopt))
+		return -EINVAL;
+
+	qdisc_watchdog_init(&q->watchdog, sch);
+
+	q->qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+				     TC_H_MAKE(sch->handle, 1));
+	if (!q->qdisc)
+		return -ENOMEM;
+
+	q->next_send = ktime_get();
+
+	return rlim_change(sch, opt);
+}
+
+static void rlim_destroy(struct Qdisc *sch)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+
+	qdisc_watchdog_cancel(&q->watchdog);
+	qdisc_destroy(q->qdisc);
+}
+
+static int rlim_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	const struct rlim_sched_data *q = qdisc_priv(sch);
+	unsigned char *b = skb_tail_pointer(skb);
+	struct rtattr *rta;
+	struct tc_rlim_qopt opt;
+
+	rta = (struct rtattr *)b;
+	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+
+	opt.limit = q->limit;
+	if (q->cost == 0)
+		opt.rate = 0;
+	else
+		opt.rate = div64_64(NSEC_PER_SEC << NSEC_SCALE, q->cost);
+
+	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	rta->rta_len = skb_tail_pointer(skb) - b;
+
+	return skb->len;
+
+      rtattr_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static int rlim_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
+		       struct Qdisc **old)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+
+	if (new == NULL)
+		new = &noop_qdisc;
+
+	sch_tree_lock(sch);
+	*old = xchg(&q->qdisc, new);
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+	qdisc_reset(*old);
+	sch_tree_unlock(sch);
+
+	return 0;
+}
+
+static struct Qdisc *rlim_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+	return q->qdisc;
+}
+
+static unsigned long rlim_get(struct Qdisc *sch, u32 classid)
+{
+	return 1;
+}
+
+static void rlim_put(struct Qdisc *sch, unsigned long arg)
+{
+}
+
+static int rlim_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
+			      struct rtattr **tca, unsigned long *arg)
+{
+	return -ENOSYS;
+}
+
+static int rlim_delete(struct Qdisc *sch, unsigned long arg)
+{
+	return -ENOSYS;
+}
+
+static void rlim_walk(struct Qdisc *sch, struct qdisc_walker *walker)
+{
+	if (!walker->stop) {
+		if (walker->count >= walker->skip)
+			if (walker->fn(sch, 1, walker) < 0) {
+				walker->stop = 1;
+				return;
+			}
+		walker->count++;
+	}
+}
+
+static struct tcf_proto **rlim_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	return NULL;
+}
+
+static int rlim_dump_class(struct Qdisc *sch, unsigned long cl,
+			    struct sk_buff *skb, struct tcmsg *tcm)
+{
+	struct rlim_sched_data *q = qdisc_priv(sch);
+
+	if (cl != 1)		/* only one class */
+		return -ENOENT;
+
+	tcm->tcm_handle |= TC_H_MIN(1);
+	tcm->tcm_info = q->qdisc->handle;
+
+	return 0;
+}
+
+static struct Qdisc_class_ops rlim_class_ops = {
+	.graft	   = rlim_graft,
+	.leaf	   = rlim_leaf,
+	.get	   = rlim_get,
+	.put	   = rlim_put,
+	.change	   = rlim_change_class,
+	.delete	   = rlim_delete,
+	.walk	   = rlim_walk,
+	.tcf_chain = rlim_find_tcf,
+	.dump	   = rlim_dump_class,
+};
+
+static struct Qdisc_ops rlim_qdisc_ops = {
+	.id		= "rlim",
+	.cl_ops		= &rlim_class_ops,
+	.priv_size	= sizeof(struct rlim_sched_data),
+	.enqueue	= rlim_enqueue,
+	.dequeue	= rlim_dequeue,
+	.requeue	= rlim_requeue,
+	.drop		= rlim_drop,
+	.init		= rlim_init,
+	.reset		= rlim_reset,
+	.destroy	= rlim_destroy,
+	.change		= rlim_change,
+	.dump		= rlim_dump,
+	.owner		= THIS_MODULE,
+};
+
+static int __init rlim_module_init(void)
+{
+	return register_qdisc(&rlim_qdisc_ops);
+}
+
+static void __exit rlim_module_exit(void)
+{
+	unregister_qdisc(&rlim_qdisc_ops);
+}
+
+module_init(rlim_module_init)
+module_exit(rlim_module_exit)
+MODULE_LICENSE("GPL");
