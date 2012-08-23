From: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Subject: [PATCH] Subject: [PATCH] RFC: TC qdisc "replace packet in queue"
 (resend)
Date: Thu, 23 Aug 2012 07:33:04 +0000
Message-ID: <FB112703C4930F4ABEBB5B763F96491139383125@MAILSERV2A.lorien.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailguard.fkie.fraunhofer.de ([128.7.3.5]:41300 "EHLO
	a.mx.fkie.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933655Ab2HWIRu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 04:17:50 -0400
Received: from rufsun5.fkie.fgan.de ([128.7.2.5] helo=mailhost.fkie.fraunhofer.de)
	by a.mx.fkie.fraunhofer.de with esmtps (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <ralph.erdt@fkie.fraunhofer.de>)
	id 1T4Ruc-00082d-9s
	for netdev@vger.kernel.org; Thu, 23 Aug 2012 09:33:06 +0200
Received: from mailserv1.fkie.fgan.de ([128.7.96.101] helo=mailserv1.lorien.fkie.fgan.de)
	by mailhost.fkie.fraunhofer.de with esmtp (Exim 4.72)
	(envelope-from <ralph.erdt@fkie.fraunhofer.de>)
	id 1T4Ruc-0002Y6-7F
	for netdev@vger.kernel.org; Thu, 23 Aug 2012 09:33:06 +0200
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From ca96a5b6044d650459b4fdd902ccab00e90f29cf Mon Sep 17 00:00:00 2001
From: Ralph Erdt <Ralph.Robert.Erdt@fkie.fraunhofer.de>
Date: Thu, 23 Aug 2012 08:36:23 +0200
Subject: [PATCH] Subject: [PATCH] RFC: TC qdisc "replace packet in queue"
 (resend)

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

FAQ:
-Why not using "codel"?
Codel was written to adress the bufferblot problem and *drop* packets
*randomly*. This is to control the flow - to delay the traffic. In fact
- just dropping will result in higher traffic use because of requery of
  missing parts. This is no a problem in "big" networks.
But we have to save traffic at all costs. So our qdisc will not drop -
it will replace. With using domain knowlegde this  will reduces the
traffic intelligent. OK - replace is like drop the first, and the
argument that there is a resend with codel won't count. But codel just
drops randomly - we replace intelligently.
By the way: You don't want to use TCP over such a connection. UDP is the
choice.

-What is with the queue in the wireless stack?
We didn't talk about 802.11 (wifi). We talk about VERY SLOW networks
(you can count the transmitted packets - over one SECOND for one big
packet, ping > one SECOND).
Our soultiuon has no queue - there is no need for this. And I'm sure: if
this qdisc is of interest, there is a similar technology at work.

-Why not using a user-space program with a tun/tap interface? There is
a lot of magic you can make.
We are already using this user-space program with a tun/tap interface
and already doing a lot of magic. But we also want to use the linux
traffic control magic - it's already there, working and fits (tun/tap
interface). We just missing this little part.

Signed-off-by: Ralph Erdt <Ralph.Robert.Erdt@fkie.fraunhofer.de>
---
 net/sched/Kconfig  |   16 +++
 net/sched/Makefile |    1 +
 net/sched/sch_pr.c |  264 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 281 insertions(+), 0 deletions(-)
 create mode 100644 net/sched/sch_pr.c

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 62fb51f..61cba0f 100644
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
index 978cbf0..c7b5cc6 100644
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
