From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.4] update to network emulation QOS scheduler
Date: Thu, 1 Jul 2004 13:11:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040701131101.184f7840@dell_ss3.pdx.osdl.net>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Catalin BOIE <util@deuroconsult.ro>, netdev@oss.sgi.com,
        lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is the 2.4 version of the conversion of simple network delay scheduler to
network emulator.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
--- a/include/linux/pkt_sched.h	2004-07-01 13:06:36 -07:00
+++ b/include/linux/pkt_sched.h	2004-07-01 13:06:36 -07:00
@@ -432,12 +432,15 @@
 
 #define TCA_ATM_MAX	TCA_ATM_STATE
 
-/* Delay section */
-struct tc_dly_qopt
+/* Network emulator */
+struct tc_netem_qopt
 {
-	__u32	latency;
-	__u32   limit;
-	__u32	loss;
+	__u32	latency;	/* added delay (us) */
+	__u32   limit;		/* fifo limit (packets) */
+	__u32	loss;		/* random packet loss (0=none ~0=100%) */
+	__u32	gap;		/* re-ordering gap (0 for delay all) */
+	__u32   duplicate;	/* random packet dup  (0=none ~0=100%) */
+	__u32	rate;		/* maximum transmit rate (bytes/sec) */
 };
 
 #endif
diff -Nru a/net/sched/Config.in b/net/sched/Config.in
--- a/net/sched/Config.in	2004-07-01 13:06:36 -07:00
+++ b/net/sched/Config.in	2004-07-01 13:06:36 -07:00
@@ -15,7 +15,7 @@
 tristate '  TEQL queue' CONFIG_NET_SCH_TEQL
 tristate '  TBF queue' CONFIG_NET_SCH_TBF
 tristate '  GRED queue' CONFIG_NET_SCH_GRED
-tristate '  Network delay simulator' CONFIG_NET_SCH_DELAY
+tristate '  Network emulator' CONFIG_NET_SCH_NETEM
 tristate '  Diffserv field marker' CONFIG_NET_SCH_DSMARK
 if [ "$CONFIG_NETFILTER" = "y" ]; then
    tristate '  Ingress Qdisc' CONFIG_NET_SCH_INGRESS
diff -Nru a/net/sched/Makefile b/net/sched/Makefile
--- a/net/sched/Makefile	2004-07-01 13:06:36 -07:00
+++ b/net/sched/Makefile	2004-07-01 13:06:36 -07:00
@@ -14,7 +14,7 @@
 obj-$(CONFIG_NET_SCH_INGRESS)	+= sch_ingress.o 
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_CSZ)	+= sch_csz.o
-obj-$(CONFIG_NET_SCH_DELAY)	+= sch_delay.o
+obj-$(CONFIG_NET_SCH_NETEM)	+= sch_netem.o
 obj-$(CONFIG_NET_SCH_HPFQ)	+= sch_hpfq.o
 obj-$(CONFIG_NET_SCH_HFSC)	+= sch_hfsc.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff -Nru a/net/sched/sch_delay.c b/net/sched/sch_delay.c
--- a/net/sched/sch_delay.c	2004-07-01 13:06:36 -07:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,289 +0,0 @@
-/*
- * net/sched/sch_delay.c	Simple constant delay
- *
- * 		This program is free software; you can redistribute it and/or
- * 		modify it under the terms of the GNU General Public License
- * 		as published by the Free Software Foundation; either version
- * 		2 of the License, or (at your option) any later version.
- *
- * Authors:	Stephen Hemminger <shemminger@osdl.org>
- */
-
-#include <linux/config.h>
-#include <linux/module.h>
-#include <linux/types.h>
-#include <linux/kernel.h>
-
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
-#include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
-#include <net/ip.h>
-#include <net/route.h>
-#include <linux/skbuff.h>
-#include <net/sock.h>
-#include <net/pkt_sched.h>
-
-/*	Network delay simulator
-	This scheduler adds a fixed delay to all packets.
-	Similar to NISTnet and BSD Dummynet.
-
-	It uses byte fifo underneath similar to TBF */
-struct dly_sched_data {
-	u32	latency;
-	u32	limit;
-	u32	loss;
-	struct timer_list timer;
-	struct Qdisc *qdisc;
-};
-
-/* Time stamp put into socket buffer control block */
-struct dly_skb_cb {
-	psched_time_t	queuetime;
-};
-
-/* Enqueue packets with underlying discipline (fifo)
- * but mark them with current time first.
- */
-static int dly_enqueue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
-	struct dly_skb_cb *cb = (struct dly_skb_cb *)skb->cb;
-	int ret;
-
-	/* Random packet drop 0 => none, ~0 => all */
-	if (q->loss >= net_random()) {
-		sch->stats.drops++;
-		return 0;	/* lie about loss so TCP doesn't know */
-	}
-
-	PSCHED_GET_TIME(cb->queuetime);
-
-	/* Queue to underlying scheduler */
-	ret = q->qdisc->enqueue(skb, q->qdisc);
-	if (ret)
-		sch->stats.drops++;
-	else {
-		sch->q.qlen++;
-		sch->stats.bytes += skb->len;
-		sch->stats.packets++;
-	}
-	return ret;
-}
-
-/* Requeue packets but don't change time stamp */
-static int dly_requeue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
-	int ret;
-
-	ret = q->qdisc->ops->requeue(skb, q->qdisc);
-	if (ret == 0)
-		sch->q.qlen++;
-	return ret;
-}
-
-static unsigned int dly_drop(struct Qdisc *sch)
-{
-	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
-	unsigned int len;
-
-	len = q->qdisc->ops->drop(q->qdisc);
-	if (len) {
-		sch->q.qlen--;
-		sch->stats.drops++;
-	}
-	return len;
-}
-
-/* Dequeue packet.
- * If packet needs to be held up, then stop the
- * queue and set timer to wakeup later.
- */
-static struct sk_buff *dly_dequeue(struct Qdisc *sch)
-{
-	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
-	struct sk_buff *skb;
-
- retry:
-	skb = q->qdisc->dequeue(q->qdisc);
-	if (skb) {
-		struct dly_skb_cb *cb = (struct dly_skb_cb *)skb->cb;
-		psched_time_t now;
-		long diff, delay;
-
-		PSCHED_GET_TIME(now);
-		diff = q->latency - PSCHED_TDIFF(now, cb->queuetime);
-
-		if (diff <= 0) {
-			sch->q.qlen--;
-			sch->flags &= ~TCQ_F_THROTTLED;
-			return skb;
-		}
-
-		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
-			sch->q.qlen--;
-			sch->stats.drops++;
-			goto retry;
-		}
-
-		delay = PSCHED_US2JIFFIE(diff);
-		if (delay <= 0)
-		  delay = 1;
-		mod_timer(&q->timer, jiffies+delay);
-
-		sch->flags |= TCQ_F_THROTTLED;
-	}
-	return NULL;
-}
-
-static void dly_reset(struct Qdisc *sch)
-{
-	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
-
-	qdisc_reset(q->qdisc);
-	sch->q.qlen = 0;
-	sch->flags &= ~TCQ_F_THROTTLED;
-	del_timer(&q->timer);
-}
-
-static void dly_timer(unsigned long arg)
-{
-	struct Qdisc *sch = (struct Qdisc *)arg;
-
-	sch->flags &= ~TCQ_F_THROTTLED;
-	netif_schedule(sch->dev);
-}
-
-/* Tell Fifo the new limit. */
-static int change_limit(struct Qdisc *q, u32 limit)
-{
-	struct rtattr *rta;
-	int ret;
-
-	rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
-	if (!rta)
-		return -ENOMEM;
-
-	rta->rta_type = RTM_NEWQDISC;
-	rta->rta_len = RTA_LENGTH(sizeof(struct tc_fifo_qopt));
-	((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
-	ret = q->ops->change(q, rta);
-	kfree(rta);
-
-	return ret;
-}
-
-/* Setup underlying FIFO discipline */
-static int dly_change(struct Qdisc *sch, struct rtattr *opt)
-{
-	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
-	struct tc_dly_qopt *qopt = RTA_DATA(opt);
-	int err;
-
-	if (q->qdisc == &noop_qdisc) {
-		struct Qdisc *child
-			= qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops);
-		if (!child)
-			return -EINVAL;
-		q->qdisc = child;
-	}
-
-	err = change_limit(q->qdisc, qopt->limit);
-	if (err) {
-		qdisc_destroy(q->qdisc);
-		q->qdisc = &noop_qdisc;
-	} else {
-		q->latency = qopt->latency;
-		q->limit = qopt->limit;
-		q->loss = qopt->loss;
-	}
-	return err;
-}
-
-static int dly_init(struct Qdisc *sch, struct rtattr *opt)
-{
-	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
-	int err;
-
-	if (!opt)
-		return -EINVAL;
-
-	MOD_INC_USE_COUNT;
-
-	init_timer(&q->timer);
-	q->timer.function = dly_timer;
-	q->timer.data = (unsigned long) sch;
-	q->qdisc = &noop_qdisc;
-
-	err = dly_change(sch, opt);
-	if (err)
-		MOD_DEC_USE_COUNT;
-
-	return err;
-}
-
-static void dly_destroy(struct Qdisc *sch)
-{
-	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
-
-	del_timer(&q->timer);
-	qdisc_destroy(q->qdisc);
-	q->qdisc = &noop_qdisc;
-
-	MOD_DEC_USE_COUNT;
-}
-
-static int dly_dump(struct Qdisc *sch, struct sk_buff *skb)
-{
-	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
-	unsigned char	 *b = skb->tail;
-	struct tc_dly_qopt qopt;
-
-	qopt.latency = q->latency;
-	qopt.limit = q->limit;
-	qopt.loss = q->loss;
-
-	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
-
-	return skb->len;
-
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
-}
-
-struct Qdisc_ops dly_qdisc_ops = {
-	.id		=	"delay",
-	.priv_size	=	sizeof(struct dly_sched_data),
-	.enqueue	=	dly_enqueue,
-	.dequeue	=	dly_dequeue,
-	.requeue	=	dly_requeue,
-	.drop		=	dly_drop,
-	.init		=	dly_init,
-	.reset		=	dly_reset,
-	.destroy	=	dly_destroy,
-	.change		=	dly_change,
-	.dump		=	dly_dump,
-};
-
-#ifdef MODULE
-int init_module(void)
-{
-	return register_qdisc(&dly_qdisc_ops);
-}
-
-void cleanup_module(void)
-{
-	unregister_qdisc(&dly_qdisc_ops);
-}
-#endif
-MODULE_LICENSE("GPL");
diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/sched/sch_netem.c	2004-07-01 13:06:36 -07:00
@@ -0,0 +1,255 @@
+/*
+ * net/sched/sch_netem.c	Network emulator
+ *
+ * 		This program is free software; you can redistribute it and/or
+ * 		modify it under the terms of the GNU General Public License
+ * 		as published by the Free Software Foundation; either version
+ * 		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Stephen Hemminger <shemminger@osdl.org>
+ *		Catalin(ux aka Dino) BOIE <catab at umbrella dot ro>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <asm/bitops.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+
+#include <net/pkt_sched.h>
+
+/*	Network emulator
+ *
+ *	This scheduler can alters spacing and order
+ *	Similar to NISTnet and BSD Dummynet.
+ */
+
+struct netem_sched_data {
+	struct sk_buff_head qnormal;
+	struct sk_buff_head qdelay;
+	struct timer_list timer;
+
+	u32 latency;
+	u32 loss;
+	u32 counter;
+	u32 gap;
+};
+
+/* Time stamp put into socket buffer control block */
+struct netem_skb_cb {
+	psched_time_t	time_to_send;
+};
+
+/* Enqueue packets with underlying discipline (fifo)
+ * but mark them with current time first.
+ */
+static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
+
+	pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
+
+	/* Random packet drop 0 => none, ~0 => all */
+	if (q->loss >= net_random()) {
+		sch->stats.drops++;
+		return 0;	/* lie about loss so TCP doesn't know */
+	}
+
+	if (q->qnormal.qlen < sch->dev->tx_queue_len) {
+		PSCHED_GET_TIME(cb->time_to_send);
+		PSCHED_TADD(cb->time_to_send, q->latency);
+
+		__skb_queue_tail(&q->qnormal, skb);
+		sch->q.qlen++;
+		sch->stats.bytes += skb->len;
+		sch->stats.packets++;
+		return 0;
+	}
+
+	sch->stats.drops++;
+	kfree_skb(skb);
+	return NET_XMIT_DROP;
+}
+
+/* Requeue packets but don't change time stamp */
+static int netem_requeue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+
+	__skb_queue_head(&q->qnormal, skb);
+	sch->q.qlen++;
+	return 0;
+}
+
+/*
+ * Check the look aside buffer list, and see if any freshly baked buffers.
+ * If head of queue is not baked, set timer.
+ */
+static struct sk_buff *netem_get_delayed(struct netem_sched_data *q)
+{
+	struct sk_buff *skb;
+	psched_time_t now;
+	long delay;
+
+	skb = skb_peek(&q->qdelay);
+	if (skb) {
+		const struct netem_skb_cb *cb
+			= (const struct netem_skb_cb *)skb->cb;
+
+		PSCHED_GET_TIME(now);
+		delay = PSCHED_US2JIFFIE(PSCHED_TDIFF(cb->time_to_send, now));
+		pr_debug("netem_dequeue: delay queue %p@%lu %ld\n",
+			 skb, jiffies, delay);
+
+		/* it's baked enough */
+		if (delay <= 0) {
+			__skb_unlink(skb, &q->qdelay);
+			del_timer(&q->timer);
+			return skb;
+		}
+
+		if (!timer_pending(&q->timer)) {
+			q->timer.expires = jiffies + delay;
+			add_timer(&q->timer);
+		}
+	}
+	return NULL;
+}
+
+/* Dequeue packet.
+ * If packet needs to be held up, then put in the delay
+ * queue and set timer to wakeup later.
+ */
+static struct sk_buff *netem_dequeue(struct Qdisc *sch)
+{
+	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct sk_buff *skb;
+
+	skb = netem_get_delayed(q);
+	if (!skb && (skb = __skb_dequeue(&q->qnormal))) {
+		/* are we doing out of order packet skip? */
+		if (q->counter < q->gap) {
+			pr_debug("netem_dequeue: send %p normally\n", skb);
+			q->counter++;
+		} else {
+			/* don't send now hold for later */
+			pr_debug("netem_dequeue: hold [%p]@%lu\n", skb, jiffies);
+			__skb_queue_tail(&q->qdelay, skb);
+			q->counter = 0;
+			skb = netem_get_delayed(q);
+		}
+	}
+
+	if (skb)
+		sch->q.qlen--;
+	return skb;
+}
+
+static void netem_timer(unsigned long arg)
+{
+	struct Qdisc *sch = (struct Qdisc *)arg;
+
+	pr_debug("netem_timer: fired @%lu\n", jiffies);
+	netif_schedule(sch->dev);
+}
+
+static void netem_reset(struct Qdisc *sch)
+{
+	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+
+	skb_queue_purge(&q->qnormal);
+	skb_queue_purge(&q->qdelay);
+
+	sch->q.qlen = 0;
+	del_timer_sync(&q->timer);
+}
+
+static int netem_change(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	struct tc_netem_qopt *qopt = RTA_DATA(opt);
+
+	if (qopt->limit)
+		sch->dev->tx_queue_len = qopt->limit;
+
+	q->gap = qopt->gap;
+	q->loss = qopt->loss;
+	q->latency = qopt->latency;
+
+	return 0;
+}
+
+static int netem_init(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+
+	if (!opt)
+		return -EINVAL;
+
+	skb_queue_head_init(&q->qnormal);
+	skb_queue_head_init(&q->qdelay);
+	init_timer(&q->timer);
+	q->timer.function = netem_timer;
+	q->timer.data = (unsigned long) sch;
+	q->counter = 0;
+
+	return netem_change(sch, opt);
+}
+
+static void netem_destroy(struct Qdisc *sch)
+{
+	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+
+	del_timer_sync(&q->timer);
+}
+
+static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct netem_sched_data *q = (struct netem_sched_data *)sch->data;
+	unsigned char	 *b = skb->tail;
+	struct tc_netem_qopt qopt;
+
+	qopt.latency = q->latency;
+	qopt.limit = sch->dev->tx_queue_len;
+	qopt.loss = q->loss;
+	qopt.gap = q->gap;
+
+	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
+
+	return skb->len;
+
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static struct Qdisc_ops netem_qdisc_ops = {
+	.id		=	"netem",
+	.priv_size	=	sizeof(struct netem_sched_data),
+	.enqueue	=	netem_enqueue,
+	.dequeue	=	netem_dequeue,
+	.requeue	=	netem_requeue,
+	.init		=	netem_init,
+	.reset		=	netem_reset,
+	.destroy	=	netem_destroy,
+	.change		=	netem_change,
+	.dump		=	netem_dump,
+};
+
+
+static int __init netem_module_init(void)
+{
+	return register_qdisc(&netem_qdisc_ops);
+}
+static void __exit netem_module_exit(void)
+{
+	unregister_qdisc(&netem_qdisc_ops);
+}
+module_init(netem_module_init)
+module_exit(netem_module_exit)
+MODULE_LICENSE("GPL");
