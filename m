From: rshriram@cs.ubc.ca
Subject: [PATCH] net/sched: sch_plug - Queue traffic until an explicit release command
Date: Mon, 19 Dec 2011 13:22:32 -0800
Message-ID: <1324329752-28459-1-git-send-email-rshriram@cs.ubc.ca>
Cc: netdev@vger.kernel.org, Brendan Cully <brendan@cs.ubc.ca>,
	Shriram Rajagopalan <rshriram@cs.ubc.ca>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.162.52.240] ([198.162.52.240]:56788 "EHLO
	athos.nss.cs.ubc.ca" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab1LSVWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 16:22:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This qdisc can be used to implement output buffering, an essential
functionality required for consistent recovery in checkpoint based
fault tolerance systems. The qdisc supports two operations - plug and
unplug. When the qdisc receives a plug command via netlink request,
packets arriving henceforth are buffered until a corresponding unplug
command is received.

Its intention is to support speculative execution by allowing generated
network traffic to be rolled back. It is used to provide network
protection for domUs in the Remus high availability project, available as
part of Xen. This module is generic enough to be used by any other
system that wishes to add speculative execution and output buffering to
its applications.

This module was originally available in the linux 2.6.32 PV-OPS tree,
used as dom0 for Xen.

For more information, please refer to http://nss.cs.ubc.ca/remus/
and http://wiki.xensource.com/xenwiki/Remus

Signed-off-by: Brendan Cully <brendan@cs.ubc.ca>
Signed-off-by: Shriram Rajagopalan <rshriram@cs.ubc.ca>
[shriram - ported the code from older 2.6.32 to current tree]
---
 net/sched/Kconfig    |   19 ++++++
 net/sched/Makefile   |    1 +
 net/sched/sch_plug.c |  159 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 179 insertions(+), 0 deletions(-)
 create mode 100644 net/sched/sch_plug.c

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 2590e91..d0ccefa 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -260,6 +260,25 @@ config NET_SCH_INGRESS
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_ingress.
 
+config NET_SCH_PLUG
+	tristate "Plug network traffic until release (PLUG)"
+	---help---
+	  Say Y here if you are using this kernel for Xen dom0 and
+	  want to protect Xen guests with Remus.
+
+	  This queueing discipline is controlled by netlink. When it receives an
+	  enqueue command it inserts a plug into the outbound queue that causes
+	  following packets to enqueue until a dequeue command arrives over
+	  netlink, releasing packets up to the plug for delivery.
+
+	  This module provides "output buffering" functionality in the Remus HA
+	  project. It enables speculative execution of virtual machines by allowing
+	  the generated network output to be rolled back if needed. For more 
+	  information, please refer to http://wiki.xensource.com/xenwiki/Remus
+
+	  To compile this code as a module, choose M here: the
+	  module will be called sch_plug.
+
 comment "Classification"
 
 config NET_CLS
diff --git a/net/sched/Makefile b/net/sched/Makefile
index dc5889c..8cdf4e2 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -33,6 +33,7 @@ obj-$(CONFIG_NET_SCH_MULTIQ)	+= sch_multiq.o
 obj-$(CONFIG_NET_SCH_ATM)	+= sch_atm.o
 obj-$(CONFIG_NET_SCH_NETEM)	+= sch_netem.o
 obj-$(CONFIG_NET_SCH_DRR)	+= sch_drr.o
+obj-$(CONFIG_NET_SCH_PLUG)	+= sch_plug.o
 obj-$(CONFIG_NET_SCH_MQPRIO)	+= sch_mqprio.o
 obj-$(CONFIG_NET_SCH_CHOKE)	+= sch_choke.o
 obj-$(CONFIG_NET_SCH_QFQ)	+= sch_qfq.o
diff --git a/net/sched/sch_plug.c b/net/sched/sch_plug.c
new file mode 100644
index 0000000..7436498
--- /dev/null
+++ b/net/sched/sch_plug.c
@@ -0,0 +1,159 @@
+/*
+ * sch_plug.c Queue traffic until an explicit release command
+ *
+ *             This program is free software; you can redistribute it and/or
+ *             modify it under the terms of the GNU General Public License
+ *             as published by the Free Software Foundation; either version
+ *             2 of the License, or (at your option) any later version.
+ *
+ * The operation of the buffer is as follows:
+ * When a checkpoint begins, a plug is inserted into the
+ *   network queue by a netlink request (it operates by storing
+ *   a pointer to the next packet which arrives and blocking dequeue
+ *   when that packet is at the head of the queue).
+ * When a checkpoint completes (the backup acknowledges receipt),
+ *   currently-queued packets are released.
+ * So it supports two operations, plug and unplug.
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <net/pkt_sched.h>
+
+#define FIFO_BUF    (10*1024*1024)
+
+#define TCQ_PLUG   0
+#define TCQ_UNPLUG 1
+
+struct plug_sched_data {
+	/*
+	 * stop points to the first packet which should not be
+	 * delivered.  If it is NULL, plug_enqueue will set it to the
+	 * next packet it sees.
+	 *
+	 * release is the last packet in the fifo that can be
+	 * released.
+	 */
+	struct sk_buff *stop, *release;
+};
+
+struct tc_plug_qopt {
+	/* 0: reset stop packet pointer
+	 * 1: dequeue to release pointer */
+	int action;
+};
+
+static int skb_remove_foreign_references(struct sk_buff *skb)
+{
+	return !skb_linearize(skb);
+}
+
+static int plug_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+{
+	struct plug_sched_data *q = qdisc_priv(sch);
+
+	if (likely(sch->qstats.backlog + skb->len <= FIFO_BUF)) {
+		if (!q->stop)
+			q->stop = skb;
+
+		if (!skb_remove_foreign_references(skb)) {
+			printk(KERN_DEBUG "error removing foreign ref\n");
+			return qdisc_reshape_fail(skb, sch);
+		}
+
+		return qdisc_enqueue_tail(skb, sch);
+	}
+	printk(KERN_WARNING "queue reported full: %d,%d\n",
+	       sch->qstats.backlog, skb->len);
+
+	return qdisc_reshape_fail(skb, sch);
+}
+
+/* dequeue doesn't actually dequeue until the release command is
+ * received. */
+static struct sk_buff *plug_dequeue(struct Qdisc* sch)
+{
+	struct plug_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *peek;
+
+	if (qdisc_is_throttled(sch))
+		return NULL;
+
+	peek = (struct sk_buff *)((sch->q).next);
+
+	/* this pointer comparison may be shady */
+	if (peek == q->release) {
+		/*
+		 * This is the tail of the last round. Release it and
+		 * block the queue
+		 */
+		qdisc_throttled(sch);
+		return NULL;
+	}
+
+	return qdisc_dequeue_head(sch);
+}
+
+static int plug_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	qdisc_throttled(sch);
+	return 0;
+}
+
+/*
+ * receives two messages:
+ *   0: checkpoint queue (set stop to next packet)
+ *   1: dequeue until stop
+ */
+static int plug_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct plug_sched_data *q = qdisc_priv(sch);
+	struct tc_plug_qopt *msg;
+
+	if (!opt || nla_len(opt) < sizeof(*msg))
+		return -EINVAL;
+
+	msg = nla_data(opt);
+
+	if (msg->action == TCQ_PLUG) {
+		/* reset stop */
+		q->stop = NULL;
+	} else if (msg->action == TCQ_UNPLUG) {
+		/* dequeue */
+		q->release = q->stop;
+		qdisc_unthrottled(sch);
+		netif_schedule_queue(sch->dev_queue);
+	} else {
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+struct Qdisc_ops plug_qdisc_ops = {
+	.id          =       "plug",
+	.priv_size   =       sizeof(struct plug_sched_data),
+	.enqueue     =       plug_enqueue,
+	.dequeue     =       plug_dequeue,
+	.peek        =       qdisc_peek_head,
+	.init        =       plug_init,
+	.change      =       plug_change,
+	.owner       =       THIS_MODULE,
+};
+
+static int __init plug_module_init(void)
+{
+	return register_qdisc(&plug_qdisc_ops);
+}
+
+static void __exit plug_module_exit(void)
+{
+	unregister_qdisc(&plug_qdisc_ops);
+}
+module_init(plug_module_init)
+module_exit(plug_module_exit)
+MODULE_LICENSE("GPL");
-- 
1.7.0.4
