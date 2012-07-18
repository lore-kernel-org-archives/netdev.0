From: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Subject: AW: RFC: (now non Base64) replace packets already in queue
Date: Wed, 18 Jul 2012 14:50:21 +0000
Message-ID: <FB112703C4930F4ABEBB5B763F9649113937CBF2@MAILSERV2A.lorien.fkie.fgan.de>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>
  <4FEC854E.8080603@hp.com>
  <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de>
  <1340960817.15719.6.camel@edumazet-glaptop>
  <FB112703C4930F4ABEBB5B763F964911393795D6@MAILSERV2A.lorien.fkie.fgan.de>
  <1341214310.5269.27.camel@edumazet-glaptop>
  <FB112703C4930F4ABEBB5B763F96491139379643@MAILSERV2A.lorien.fkie.fgan.de>
  <4FF20557.4090501@gmail.com> <1341266168.22621.466.camel@edumazet-glaptop>
 <FB112703C4930F4ABEBB5B763F96491139379DC7@MAILSERV2A.lorien.fkie.fgan.de>
 <FB112703C4930F4ABEBB5B763F96491139379ECF@MAILSERV2A.lorien.fkie.fgan.de>
 <4FF4A873.1000001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>
To: =?iso-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailguard.fkie.fraunhofer.de ([128.7.3.5]:33288 "EHLO
	a.mx.fkie.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628Ab2GROuZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 10:50:25 -0400
In-Reply-To: <4FF4A873.1000001@gmail.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I'm sorry for the very late answer. But I had top-priority family issues.

> I suggest you try and send a properly formated patch with your code, so
> that people here can have a look at it and evaluate the interest of
> integrating it into main line kernel.

Attached at the button of the eMail.


> That being said, I really think you should try to manage a userspace
> queue, [..] you can
> add many nice features into userspace to enhance the speed/quality 
> [..]
> And I really see your packet replacement system as one of those nice
> features and cannot imagine a good reason not to put it in userspace.

All this features are done already. E.g. we are using RoHC.
But we also want to use the TC stuff - its already there - why reprogramming?

Here the patch. But I didn't find which git tree I should use. This patch is against Linux-2.6. I'm sorry. Can you tell me, which tree I've to use?
-------------
>From 52f27fa2b0867de821af38c731c2ebc763afb1f1 Mon Sep 17 00:00:00 2001
From: Ralph Erdt <Ralph.Robert.Erdt@fkie.fraunhofer.de>
Date: Wed, 18 Jul 2012 16:43:44 +0200
Subject: [PATCH] RFC: TC qdisc "replace packet in queue"

This adds a new TC qdisc, which replaces packets in the queue. It
compares every incoming packet with all of the packets in the queue.
If the incoming and the compared packet meet all these conditions:
 - UDPv4
 - not fragmented
 - TOS like the given value(s)
 - same TOS
 - same source IP
 - same destination IP
 - same destination port
the packet in the queue will be replaced with the incoming packet.

The variable "overlimit" is the counter of replaced packets

Background:
In very low bandwidth networks (<=9.6Kbps, shared, etc.) it's hard
(rather: impossible) to get all packets sent.
But some of the packets contain information, which gets obsolete over
time. E.g. (GPS) positions, which will be sent periodically. If the
application sends a new packet while an old position packet is still in
the queue, the old packet is obsolete. This can be dropped. But just
dropping the old packet and queuing the new packet will result in never
sending a packet of this type. So this qdisc replace the old packet with
the new one. The information gets the chance to get sent - with the
newest available information.

Code-Status:
RFC for discussing.
The configuration by "debug-fs" is ... not optimal. But following the
"litte step" rules this is a first option. A configuration with tc will
be done later (if this patch got offical).

Signed-off-by: Ralph Erdt <Ralph.Robert.Erdt@fkie.fraunhofer.de>
---
 net/sched/Kconfig  |   16 +++
 net/sched/Makefile |    1 +
 net/sched/sch_pr.c |  264 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 281 insertions(+), 0 deletions(-)
 create mode 100644 net/sched/sch_pr.c

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index e7a8976..e29ad48 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -308,6 +308,22 @@ config NET_SCH_PLUG
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_plug.
 
+config NET_SCH_PR
+	tristate "Packet Replace"
+	help
+	  Say Y here if you want to use the "Packet Replace"
+	  packet scheduling algorithm.
+
+	  This qdisc will replace packets in the queue, if this is a packet
+	  from the same UDP stream (IP/Port).
+
+	  See the top of <file:net/sched/sch_pr.c> for more details.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sch_pr.
+
+	  If unsure, say N.
+
 comment "Classification"
 
 config NET_CLS
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 5940a19..ef669ff 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -39,6 +39,7 @@ obj-$(CONFIG_NET_SCH_CHOKE)	+= sch_choke.o
 obj-$(CONFIG_NET_SCH_QFQ)	+= sch_qfq.o
 obj-$(CONFIG_NET_SCH_CODEL)	+= sch_codel.o
 obj-$(CONFIG_NET_SCH_FQ_CODEL)	+= sch_fq_codel.o
+obj-$(CONFIG_NET_SCH_PR)	+= sch_pr.o
 
 obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
diff --git a/net/sched/sch_pr.c b/net/sched/sch_pr.c
new file mode 100644
index 0000000..5cbf8d8
--- /dev/null
+++ b/net/sched/sch_pr.c
@@ -0,0 +1,264 @@
+/*
+ * net/sched/sch_pr.c	"packet replace"
+ *
+ * Copyrigth (c) 2012 Fraunhofer FKIE, all rigths reserved.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Ralph Erdt (Fraunhofer FKIE),
+ *                                 <ralph.robert.erdt@fkie.fraunhofer.de>
+ */
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <net/pkt_sched.h>
+
+#include <linux/ip.h>
+#include <net/ip.h>
+#include <linux/debugfs.h>
+
+/*
+ * replace packet in queue
+ * ==========================
+ * This is a modified fifo queue (fifo by Alexey Kuznetsov).
+ *
+ * This packet compares every incoming packet with all of the packets in the
+ * queue.
+ * If the incoming and the compared packet meet all these conditions:
+ *  - UDPv4
+ *  - not fragmented
+ *  - TOS like the given value(s)
+ *  - same TOS
+ *  - same source IP
+ *  - same destination IP
+ *  - same destination port
+ * the packet in the queue will be replaced with the incoming packet.
+ *
+ * The variable "overlimit" is the counter of replaced packets
+ *
+ * Background:
+ * In very low bandwidth networks (<=9.6Kbps, shared, etc.) it's hard
+ * (rather: impossible) to get all packets sent.
+ * But some of the packets contain information, which gets obsolete over time.
+ * E.g. (GPS) positions, which will be sent periodically. If the application
+ * sends a new packet while an old position packet is still in the queue, the
+ * old packet is obsolete. This can be dropped. But just dropping the old
+ * packet and queuing the new packet will result in never sending a packet
+ * of this type.
+ * So this qdisc replace the old packet with the new one. The information gets
+ * the chance to get sent - with the newest available information.
+ *
+ * DRAWBACKS:
+ * Its not very CPU cycle saving. But on very low bandwith networks the
+ * application have to be careful with sending packets. And with a propper
+ * configuration, this will be OK.
+ */
+
+struct dentry *dgdir, *dgfile;
+
+#define TOSBITMASK 0
+#define TOSCOMPARE 1
+/* tos Flag. 1.: BitMask. 2.: Compare with */
+static u8 tos[] = {0xFF, 0xFF};
+
+bool pr_packet_to_work_with(struct sk_buff *pkt)
+{
+	struct iphdr *hdr;
+
+	if (unlikely(pkt->protocol != htons(ETH_P_IP)))
+		return false;
+
+	/* Only compare UDP - Layer 4 must be there */
+	if (unlikely(pkt->network_header == NULL))
+		return false;
+
+	hdr = ip_hdr(pkt);
+
+	/* Check for UDPv4 */
+	if (unlikely(hdr->protocol != IPPROTO_UDP))
+		return false;
+
+	/* no fragmented packets */
+	if (unlikely(ip_is_fragment(hdr)))
+		return false;
+
+	/* Correct TOS ? */
+	if ((hdr->tos & tos[TOSBITMASK]) != tos[TOSCOMPARE])
+		return false;
+
+	return true;
+}
+
+bool comp(struct sk_buff *a, struct sk_buff *b)
+{
+	struct iphdr *ah = NULL;
+	struct iphdr *bh = NULL;
+	u32 ipA, ipB;
+	u16 portsA, portsB;
+	int poff;
+	/* The packet has a header
+	 *  - the existence was already checked by "pr_packet_to_work_with" */
+	ah = ip_hdr(a);
+	bh = ip_hdr(b);
+
+	/* TOS must be the same */
+	if (ah->tos != bh->tos)
+		return false;
+
+	/* IP and Port must be the same */
+	ipA = (__force u32)ah->daddr;
+	ipB = (__force u32)bh->daddr;
+	if ((ipA != ipB))
+		return false;
+	ipA = (__force u32)ah->saddr;
+	ipB = (__force u32)bh->saddr;
+	if ((ipA != ipB))
+		return false;
+
+	poff = proto_ports_offset(IPPROTO_UDP);
+	if (unlikely(poff < 0))
+		/* This should be impossible.. */
+		return false;
+
+	/* Src Ports are always different - just compare destination ports */
+	portsA = *(u16 *)((void *)ah + bh->ihl * 4 + poff + 2);
+	portsB = *(u16 *)((void *)bh + ah->ihl * 4 + poff + 2);
+	if ((portsA != portsB))
+		return false;
+
+	return true;
+}
+
+static int pr_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct sk_buff *replace = NULL;
+
+	/* Search, if there is a packet with same IDs */
+	/* Only search, if this packet is worth it */
+	if (pr_packet_to_work_with(skb)) {
+		struct sk_buff *it;
+		skb_queue_walk((&(sch->q)), it) {
+			/* If the other packet is worth it? */
+			if (pr_packet_to_work_with(it)) {
+				if (comp(skb, it)) {
+					replace = it;
+					break;
+				}
+			}
+		}
+	}
+
+	if (replace == NULL) {
+		/* a new kind of packet. Just enqueue */
+		if (likely(skb_queue_len(&sch->q) < sch->limit))
+			return qdisc_enqueue_tail(skb, sch);
+		return qdisc_reshape_fail(skb, sch);
+	} else {
+		/* replace the packet */
+		sch->qstats.overlimits++;
+		/* There is no drop nor replace. So do the replace myself */
+		skb->next = replace->next;
+		skb->prev = replace->prev;
+		if (replace->next != NULL)
+			replace->next->prev = skb;
+		if (replace->prev != NULL)
+			replace->prev->next = skb;
+		kfree_skb(replace);
+		return NET_XMIT_SUCCESS;
+	}
+}
+
+static int pr_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	sch->flags |= TCQ_F_CAN_BYPASS; /* sounds good, but what? */
+	sch->limit = qdisc_dev(sch)->tx_queue_len ? : 1;
+	return 0;
+}
+
+static int pr_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct tc_fifo_qopt opt = { .limit = sch->limit };
+
+	if (nla_put(skb, TCA_OPTIONS, sizeof(opt), &opt))
+		goto nla_put_failure;
+
+	return skb->len;
+
+nla_put_failure:
+	return -1;
+}
+
+struct Qdisc_ops pr_qdisc_ops __read_mostly = {
+	.id		=	"pr",
+	.priv_size	=	0,
+	.enqueue	=	pr_enqueue,
+	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
+	.drop		=	qdisc_queue_drop,
+	.init		=	pr_init,
+	.reset		=	qdisc_reset_queue,
+	.change		=	pr_init,
+	.dump		=	pr_dump,
+	.owner		=	THIS_MODULE,
+};
+EXPORT_SYMBOL(pr_qdisc_ops);
+
+/* DebugFS interface as first shot configuration */
+static ssize_t dg_read_file(struct file *file, char __user *userbuf,
+					size_t count, loff_t *ppos)
+{
+	return simple_read_from_buffer(userbuf, count, ppos, tos, 2);
+}
+
+static ssize_t dg_write_file(struct file *file, const char __user *buf,
+					size_t count, loff_t *ppos)
+{
+	u8 tmp[] = {0xFF, 0xFF};
+	int res;
+	if (count != 2)
+		return -EINVAL;
+
+	res = copy_from_user(tmp, buf, count);
+	if (res != 0)
+		return -EINVAL;
+
+	/* Two bytes to copy.. for this a memcpy with errorhandling?!? */
+	tos[0] = tmp[0];
+	tos[1] = tmp[1];
+
+	return count;
+}
+
+static const struct file_operations dgfops = {
+	.read = dg_read_file,
+	.write = dg_write_file,
+};
+
+static int __init pr_module_init(void)
+{
+	bool ret = register_qdisc(&pr_qdisc_ops);
+	if (!ret) {
+		/* open Communication channel */
+		dgdir = debugfs_create_dir("sch_pr", NULL);
+		dgfile = debugfs_create_file("tos", 0644, dgdir, tos, &dgfops);
+	}
+	return ret;
+}
+
+static void __exit pr_module_exit(void)
+{
+	debugfs_remove(dgfile);
+	debugfs_remove(dgdir);
+	unregister_qdisc(&pr_qdisc_ops);
+}
+
+module_init(pr_module_init);
+module_exit(pr_module_exit);
+MODULE_LICENSE("GPL");
-- 
1.7.7
