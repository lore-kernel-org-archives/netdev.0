From: rshriram@cs.ubc.ca
Subject: [PATCH V3] net/sched: sch_plug - Queue traffic until an explicit release command
Date: Sun,  5 Feb 2012 15:51:32 -0800
Message-ID: <1328485892-16721-1-git-send-email-rshriram@cs.ubc.ca>
Cc: jhs@mojatatu.com, hagen@jauu.net,
	Shriram Rajagopalan <rshriram@cs.ubc.ca>,
	Brendan Cully <brendan@cs.ubc.ca>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.162.52.240] ([198.162.52.240]:50526 "EHLO
	athos.nss.cs.ubc.ca" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752899Ab2BEXvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 18:51:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shriram Rajagopalan <rshriram@cs.ubc.ca>

The qdisc supports two operations - plug and unplug. When the
qdisc receives a plug command via netlink request, packets arriving
henceforth are buffered until a corresponding unplug command is received.
Depending on the type of unplug command, the queue can be unplugged
indefinitely or selectively.

This qdisc can be used to implement output buffering, an essential
functionality required for consistent recovery in checkpoint based
fault-tolerance systems. Output buffering enables speculative execution
by allowing generated network traffic to be rolled back. It is used to
provide network protection for Xen Guests in the Remus high availability
project, available as part of Xen.

This module is generic enough to be used by any other system that wishes
to add speculative execution and output buffering to its applications.

This module was originally available in the linux 2.6.32 PV-OPS tree,
used as dom0 for Xen.

For more information, please refer to http://nss.cs.ubc.ca/remus/
and http://wiki.xensource.com/xenwiki/Remus

Changes in V3:
  * Removed debug output (printk) on queue overflow
  * Added TCQ_PLUG_RELEASE_INDEFINITE - that allows the user to
    use this qdisc, for simple plug/unplug operations.
  * Use of packet counts instead of pointers to keep track of
    the buffers in the queue.

Signed-off-by: Shriram Rajagopalan <rshriram@cs.ubc.ca>
Signed-off-by: Brendan Cully <brendan@cs.ubc.ca>
[author of the code in the linux 2.6.32 pvops tree]
---
 include/linux/pkt_sched.h |   21 ++++
 net/sched/Kconfig         |   26 +++++
 net/sched/Makefile        |    1 +
 net/sched/sch_plug.c      |  233 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 281 insertions(+), 0 deletions(-)
 create mode 100644 net/sched/sch_plug.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 0d5b793..410b33d 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -127,6 +127,27 @@ struct tc_multiq_qopt {
 	__u16	max_bands;		/* Maximum number of queues */
 };
 
+/* PLUG section */
+
+#define TCQ_PLUG_BUFFER                0
+#define TCQ_PLUG_RELEASE_ONE           1
+#define TCQ_PLUG_RELEASE_INDEFINITE    2
+#define TCQ_PLUG_LIMIT                 3
+
+struct tc_plug_qopt {
+	/* TCQ_PLUG_BUFFER: Inset a plug into the queue and
+	 *  buffer any incoming packets
+	 * TCQ_PLUG_RELEASE_ONE: Dequeue packets from queue head
+	 *   to beginning of the next plug.
+	 * TCQ_PLUG_RELEASE_INDEFINITE: Dequeue all packets from queue.
+	 *   Stop buffering packets until the next TCQ_PLUG_BUFFER
+	 *   command is received (just act as a pass-thru queue).
+	 * TCQ_PLUG_LIMIT: Increase/decrease queue size
+	 */
+	int             action;
+	__u32           limit;
+};
+
 /* TBF section */
 
 struct tc_tbf_qopt {
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 2590e91..75b58f8 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -260,6 +260,32 @@ config NET_SCH_INGRESS
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_ingress.
 
+config NET_SCH_PLUG
+	tristate "Plug network traffic until release (PLUG)"
+	---help---
+
+	  This queuing discipline allows userspace to plug/unplug a network
+	  output queue, using the netlink interface.  When it receives an
+	  enqueue command it inserts a plug into the outbound queue that
+	  causes following packets to enqueue until a dequeue command arrives
+	  over netlink, causing the plug to be removed and resuming the normal
+	  packet flow.
+
+	  This module also provides a generic "network output buffering"
+	  functionality (aka output commit), wherein upon arrival of a dequeue
+	  command, only packets up to the first plug are released for delivery.
+	  The Remus HA project uses this module to enable speculative execution
+	  of virtual machines by allowing the generated network output to be rolled
+	  back if needed.
+
+	  For more information, please refer to http://wiki.xensource.com/xenwiki/Remus
+
+	  Say Y here if you are using this kernel for Xen dom0 and
+	  want to protect Xen guests with Remus.
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
index 0000000..ba7b737
--- /dev/null
+++ b/net/sched/sch_plug.c
@@ -0,0 +1,233 @@
+/*
+ * sch_plug.c Queue traffic until an explicit release command
+ *
+ *             This program is free software; you can redistribute it and/or
+ *             modify it under the terms of the GNU General Public License
+ *             as published by the Free Software Foundation; either version
+ *             2 of the License, or (at your option) any later version.
+ *
+ * There are two ways to use this qdisc:
+ * 1. A simple "instantaneous" plug/unplug operation, by issuing an alternating
+ *    sequence of TCQ_PLUG_BUFFER & TCQ_PLUG_RELEASE_INDEFINITE commands.
+ *
+ * 2. For network output buffering (a.k.a output commit) functionality.
+ *    Output commit property is commonly used by applications using checkpoint
+ *    based fault-tolerance to ensure that the checkpoint from which a system
+ *    is being restored is consistent w.r.t outside world.
+ *
+ *    Consider for e.g. Remus - a Virtual Machine checkpointing system,
+ *    wherein a VM is checkpointed, say every 50ms. The checkpoint is replicated
+ *    asynchronously to the backup host, while the VM continues executing the
+ *    next epoch speculatively.
+ *
+ *    The following is a typical sequence of output buffer operations:
+ *       1.At epoch i, start_buffer(i)
+ *       2. At end of epoch i (i.e. after 50ms):
+ *          2.1 Stop VM and take checkpoint(i).
+ *          2.2 start_buffer(i+1) and Resume VM
+ *       3. While speculatively executing epoch(i+1), asynchronously replicate
+ *          checkpoint(i) to backup host.
+ *       4. When checkpoint_ack(i) is received from backup, release_buffer(i)
+ *    Thus, this Qdisc would receive the following sequence of commands:
+ *       TCQ_PLUG_BUFFER (epoch i)
+ *       .. TCQ_PLUG_BUFFER (epoch i+1)
+ *       ....TCQ_PLUG_RELEASE_ONE (epoch i)
+ *       ......TCQ_PLUG_BUFFER (epoch i+2)
+ *       ........
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
+/*
+ * State of the queue, when used for network output buffering:
+ *
+ *                 plug(i+1)            plug(i)          head
+ * ------------------+--------------------+---------------->
+ *                   |                    |
+ *                   |                    |
+ * pkts_current_epoch| pkts_last_epoch    |pkts_to_release
+ * ----------------->|<--------+--------->|+--------------->
+ *                   v                    v
+ *
+ */
+
+struct plug_sched_data {
+	/* If true, the dequeue function releases all packets
+	 * from head to end of the queue. The queue turns into
+	 * a pass-through queue for newly arriving packets.
+	 */
+	bool unplug_indefinite;
+
+	/* Queue Limit in bytes */
+	u32 limit;
+
+	/* Number of packets (output) from the current speculatively
+	 * executing epoch.
+	 */
+	u32 pkts_current_epoch;
+
+	/* Number of packets corresponding to the recently finished
+	 * epoch. These will be released when we receive a
+	 * TCQ_PLUG_RELEASE_ONE command. This command is typically
+	 * issued after committing a checkpoint at the target.
+	 */
+	u32 pkts_last_epoch;
+
+	/*
+	 * Number of packets from the head of the queue, that can
+	 * be released (committed checkpoint).
+	 */
+	u32 pkts_to_release;
+};
+
+static int plug_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct plug_sched_data *q = qdisc_priv(sch);
+
+	if (likely(sch->qstats.backlog + skb->len <= q->limit)) {
+		if (!q->unplug_indefinite)
+			q->pkts_current_epoch++;
+		return qdisc_enqueue_tail(skb, sch);
+	}
+
+	return qdisc_reshape_fail(skb, sch);
+}
+
+static struct sk_buff *plug_dequeue(struct Qdisc *sch)
+{
+	struct plug_sched_data *q = qdisc_priv(sch);
+
+	if (qdisc_is_throttled(sch))
+		return NULL;
+
+	if (!q->unplug_indefinite) {
+		if (!q->pkts_to_release) {
+			/* No more packets to dequeue. Block the queue
+			 * and wait for the next release command.
+			 */
+			qdisc_throttled(sch);
+			return NULL;
+		}
+		q->pkts_to_release--;
+	}
+
+	return qdisc_dequeue_head(sch);
+}
+
+static int plug_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct plug_sched_data *q = qdisc_priv(sch);
+
+	q->pkts_current_epoch = 0;
+	q->pkts_last_epoch = 0;
+	q->pkts_to_release = 0;
+	q->unplug_indefinite = false;
+
+	if (opt == NULL) {
+		/* We will set a default limit of 100 pkts (~150kB)
+		 * in case tx_queue_len is not available. The
+		 * default value is completely arbitrary.
+		 */
+		u32 pkt_limit = qdisc_dev(sch)->tx_queue_len ? : 100;
+		q->limit = pkt_limit * psched_mtu(qdisc_dev(sch));
+	} else {
+		struct tc_plug_qopt *ctl = nla_data(opt);
+
+		if (nla_len(opt) < sizeof(*ctl))
+			return -EINVAL;
+
+		q->limit = ctl->limit;
+	}
+
+	qdisc_throttled(sch);
+	return 0;
+}
+
+/* Receives 4 types of messages:
+ * TCQ_PLUG_BUFFER: Inset a plug into the queue and
+ *  buffer any incoming packets
+ * TCQ_PLUG_RELEASE_ONE: Dequeue packets from queue head
+ *   to beginning of the next plug.
+ * TCQ_PLUG_RELEASE_INDEFINITE: Dequeue all packets from queue.
+ *   Stop buffering packets until the next TCQ_PLUG_BUFFER
+ *   command is received (just act as a pass-thru queue).
+ * TCQ_PLUG_LIMIT: Increase/decrease queue size
+ */
+static int plug_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct plug_sched_data *q = qdisc_priv(sch);
+	struct tc_plug_qopt *msg;
+
+	if (opt == NULL)
+		return -EINVAL;
+
+	msg = nla_data(opt);
+	if (nla_len(opt) < sizeof(*msg))
+		return -EINVAL;
+
+	switch (msg->action) {
+	case TCQ_PLUG_BUFFER:
+		/* Save size of the current buffer */
+		q->pkts_last_epoch = q->pkts_current_epoch;
+		q->pkts_current_epoch = 0;
+		if (q->unplug_indefinite)
+			qdisc_throttled(sch);
+		q->unplug_indefinite = false;
+		break;
+	case TCQ_PLUG_RELEASE_ONE:
+		/* Add packets from the last complete buffer to the
+		 * packets to be released set.
+		 */
+		q->pkts_to_release += q->pkts_last_epoch;
+		q->pkts_last_epoch = 0;
+		qdisc_unthrottled(sch);
+		netif_schedule_queue(sch->dev_queue);
+		break;
+	case TCQ_PLUG_RELEASE_INDEFINITE:
+		q->unplug_indefinite = true;
+		q->pkts_to_release = 0;
+		q->pkts_last_epoch = 0;
+		q->pkts_current_epoch = 0;
+		qdisc_unthrottled(sch);
+		netif_schedule_queue(sch->dev_queue);
+		break;
+	case TCQ_PLUG_LIMIT:
+		/* Limit is supplied in bytes */
+		q->limit = msg->limit;
+		break;
+	default:
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
