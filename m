From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] packet delay scheduler
Date: Thu, 18 Mar 2004 12:04:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318120451.1c9ee286@dell_ss3.pdx.osdl.net>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
	<20040316174134.2f1da12a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040316174134.2f1da12a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Okay, here is a very simple QOS scheduler that delays packets for 2.6.
It is good for testing, and might be useful for people who want to put
some class of traffic into a "penalty box".

Alexey's tc command is really easy to extend to new disciplines.  There is
a version which knows about this scheduler at:
	http://developer.osdl.org/shemminger/tcp/iproute2-delay.tar.bz2
The only changes were to tc/Makefile and new file tc/q_delay.c

A trivial example is:
	 tc qdisc add dev eth0 root delay latency 25ms rate 100mbit

Try it, if others find it useful please consider adding it.

diff -Nru a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
--- a/include/linux/pkt_sched.h	Thu Mar 18 12:04:02 2004
+++ b/include/linux/pkt_sched.h	Thu Mar 18 12:04:02 2004
@@ -432,4 +432,10 @@
 
 #define TCA_ATM_MAX	TCA_ATM_STATE
 
+/* Delay section */
+struct tc_dly_qopt
+{
+	__u32	latency;
+	__u32   limit;
+};	
 #endif
diff -Nru a/net/sched/Kconfig b/net/sched/Kconfig
--- a/net/sched/Kconfig	Thu Mar 18 12:04:02 2004
+++ b/net/sched/Kconfig	Thu Mar 18 12:04:02 2004
@@ -164,6 +164,17 @@
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_dsmark.
 
+config NET_SCH_DELAY
+	tristate "Delay simulator"
+	depends on NET_SCHED
+	help
+	  Say Y if you want to delay packets by a fixed amount of
+	  time. This is often useful to simulate network delay when
+	  testing applications or protocols.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sch_delay.
+
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
 	depends on NET_SCHED && NETFILTER
diff -Nru a/net/sched/Makefile b/net/sched/Makefile
--- a/net/sched/Makefile	Thu Mar 18 12:04:02 2004
+++ b/net/sched/Makefile	Thu Mar 18 12:04:02 2004
@@ -22,6 +22,7 @@
 obj-$(CONFIG_NET_SCH_TEQL)	+= sch_teql.o
 obj-$(CONFIG_NET_SCH_PRIO)	+= sch_prio.o
 obj-$(CONFIG_NET_SCH_ATM)	+= sch_atm.o
+obj-$(CONFIG_NET_SCH_DELAY)	+= sch_delay.o
 obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
 obj-$(CONFIG_NET_CLS_FW)	+= cls_fw.o
diff -Nru a/net/sched/sch_delay.c b/net/sched/sch_delay.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/net/sched/sch_delay.c	Thu Mar 18 12:04:02 2004
@@ -0,0 +1,269 @@
+/*
+ * net/sched/sch_delay.c	Simple constant delay
+ *
+ * 		This program is free software; you can redistribute it and/or
+ * 		modify it under the terms of the GNU General Public License
+ * 		as published by the Free Software Foundation; either version
+ * 		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Stephen Hemminger <shemminger@osdl.org>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/in.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/if_ether.h>
+#include <linux/inet.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/notifier.h>
+#include <net/ip.h>
+#include <net/route.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/pkt_sched.h>
+
+/*	Network delay simulator
+	This scheduler adds a fixed delay to all packets.
+	Similar to NISTnet and BSD Dummynet.
+
+	It uses byte fifo underneath similar to TBF */
+struct dly_sched_data {
+	u32	latency;
+	u32	limit;
+	struct timer_list timer;
+	struct Qdisc *qdisc;
+};
+
+/* Time stamp put into socket buffer control block */
+struct dly_skb_cb {
+	psched_time_t	queuetime;
+};
+
+/* Enqueue packets with underlying discipline (fifo)
+ * but mark them with current time first.
+ */
+static int dly_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
+	struct dly_skb_cb *cb = (struct dly_skb_cb *)skb->cb;
+	int ret;
+
+	PSCHED_GET_TIME(cb->queuetime);
+
+	/* Queue to underlying scheduler */
+	ret = q->qdisc->enqueue(skb, q->qdisc);
+	if (ret)
+		sch->stats.drops++;
+	else {
+		sch->q.qlen++;
+		sch->stats.bytes += skb->len;
+		sch->stats.packets++;
+	}
+	return 0;
+}
+
+/* Requeue packets but don't change time stamp */
+static int dly_requeue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
+	int ret;
+
+	ret = q->qdisc->ops->requeue(skb, q->qdisc);
+	if (ret == 0)
+		sch->q.qlen++;
+	return ret;
+}
+
+static unsigned int dly_drop(struct Qdisc *sch)
+{
+	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
+	unsigned int len;
+
+	len = q->qdisc->ops->drop(q->qdisc);
+	if (len) {
+		sch->q.qlen--;
+		sch->stats.drops++;
+	}
+	return len;
+}
+
+/* Dequeue packet.
+ * If packet needs to be held up, then stop the
+ * queue and set timer to wakeup later.
+ */
+static struct sk_buff *dly_dequeue(struct Qdisc *sch)
+{
+	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
+	struct sk_buff *skb = q->qdisc->dequeue(q->qdisc);
+
+	if (skb) {
+		struct dly_skb_cb *cb = (struct dly_skb_cb *)skb->cb;
+		psched_time_t now;
+		long diff;
+
+		PSCHED_GET_TIME(now);
+		diff = q->latency - PSCHED_TDIFF(now, cb->queuetime);
+
+		if (diff <= 0) {
+			sch->q.qlen--;
+			sch->flags &= ~TCQ_F_THROTTLED;
+			return skb;
+		}
+
+		if (!netif_queue_stopped(sch->dev)) {
+			long delay = PSCHED_US2JIFFIE(diff);
+			if (delay <= 0)
+				delay = 1;
+			mod_timer(&q->timer, jiffies+delay);
+		}
+
+		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
+			sch->q.qlen--;
+			sch->stats.drops++;
+		}
+		sch->flags |= TCQ_F_THROTTLED;
+	}
+	return NULL;
+}
+
+static void dly_reset(struct Qdisc *sch)
+{
+	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
+
+	qdisc_reset(q->qdisc);
+	sch->q.qlen = 0;
+	sch->flags &= ~TCQ_F_THROTTLED;
+	del_timer(&q->timer);
+}
+
+static void dly_timer(unsigned long arg)
+{
+	struct Qdisc *sch = (struct Qdisc *)arg;
+
+	sch->flags &= ~TCQ_F_THROTTLED;
+	netif_schedule(sch->dev);
+}
+
+/* Tell Fifo the new limit. */
+static int change_limit(struct Qdisc *q, u32 limit)
+{
+	struct rtattr *rta;
+	int ret;
+
+	rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
+	if (!rta)
+		return -ENOMEM;
+
+	rta->rta_type = RTM_NEWQDISC;
+	((struct tc_fifo_qopt *)RTA_DATA(rta))->limit = limit;
+	ret = q->ops->change(q, rta);
+	kfree(rta);
+
+	return ret;
+}
+
+/* Setup underlying FIFO discipline */
+static int dly_change(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
+	struct tc_dly_qopt *qopt = RTA_DATA(opt);
+	int err;
+
+	if (q->qdisc == &noop_qdisc) {
+		struct Qdisc *child
+			= qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops);
+		if (!child)
+			return -EINVAL;
+		q->qdisc = child;
+	}
+
+	err = change_limit(q->qdisc, qopt->limit);
+	if (err) {
+		qdisc_destroy(q->qdisc);
+		q->qdisc = &noop_qdisc;
+	} else {
+		q->latency = qopt->latency;
+		q->limit = qopt->limit;
+	}
+	return err;
+}
+
+static int dly_init(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
+
+	if (!opt)
+		return -EINVAL;
+
+	init_timer(&q->timer);
+	q->timer.function = dly_timer;
+	q->timer.data = (unsigned long) sch;
+	q->qdisc = &noop_qdisc;
+
+	return dly_change(sch, opt);
+}
+
+static void dly_destroy(struct Qdisc *sch)
+{
+	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
+
+	del_timer(&q->timer);
+	qdisc_destroy(q->qdisc);
+	q->qdisc = &noop_qdisc;
+}
+
+static int dly_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct dly_sched_data *q = (struct dly_sched_data *)sch->data;
+	unsigned char	 *b = skb->tail;
+	struct tc_dly_qopt qopt;
+
+	qopt.latency = q->latency;
+	qopt.limit = q->limit;
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
+static struct Qdisc_ops dly_qdisc_ops = {
+	.id		=	"delay",
+	.priv_size	=	sizeof(struct dly_sched_data),
+	.enqueue	=	dly_enqueue,
+	.dequeue	=	dly_dequeue,
+	.requeue	=	dly_requeue,
+	.drop		=	dly_drop,
+	.init		=	dly_init,
+	.reset		=	dly_reset,
+	.destroy	=	dly_destroy,
+	.change		=	dly_change,
+	.dump		=	dly_dump,
+	.owner		=	THIS_MODULE,
+};
+
+
+static int __init dly_module_init(void)
+{
+	return register_qdisc(&dly_qdisc_ops);
+}
+static void __exit dly_module_exit(void)
+{
+	unregister_qdisc(&dly_qdisc_ops);
+}
+module_init(dly_module_init)
+module_exit(dly_module_exit)
+MODULE_LICENSE("GPL");
