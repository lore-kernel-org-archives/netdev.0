From: Ryousei Takano <takano-ryousei@aist.go.jp>
Subject: [PATCHv3 1/3] NET_SCHED: PSPacer qdisc module
Date: Wed, 28 Nov 2007 20:59:54 +0900 (JST)
Message-ID: <20071128.205954.108955785.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, kaber@trash.net,
	dada1@cosmosbay.com, t.kudoh@aist.go.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:61635 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560AbXK1MAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 07:00:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch includes the PSPacer (Precise Software Pacer) qdisc
module, which achieves precise transmission bandwidth control.
You can find more information at the project web page
(http://www.gridmpi.org/gridtcp.jsp).

Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
---
 include/linux/pkt_sched.h |   29 ++
 net/sched/Kconfig         |    9 +
 net/sched/Makefile        |    1 +
 net/sched/sch_psp.c       |  962 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 1001 insertions(+), 0 deletions(-)
 create mode 100644 net/sched/sch_psp.c

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 919af93..d2c5da1 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -430,6 +430,35 @@ enum {
 
 #define TCA_ATM_MAX	(__TCA_ATM_MAX - 1)
 
+/* Precise Software Pacer section */
+
+#define TC_PSP_MAXDEPTH (8)
+
+enum {
+	MODE_NORMAL = 0,
+	MODE_STATIC = 1,
+};
+
+struct tc_psp_copt
+{
+	__u32	level;
+	__u32	mode;
+	__u32	rate;		/* bytes/sec */
+};
+
+struct tc_psp_qopt
+{
+	__u32	defcls;
+	__u32	rate;		/* bytes/sec */
+};
+
+enum
+{
+	TCA_PSP_UNSPEC,
+	TCA_PSP_COPT,
+	TCA_PSP_QOPT,
+};
+
 /* Network emulator */
 
 enum
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 9c15c48..ec40e43 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -184,6 +184,15 @@ config NET_SCH_DSMARK
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_dsmark.
 
+config NET_SCH_PSP
+	tristate "Precise Software Pacer (PSP)"
+	---help---
+	  Say Y here if you want to include PSPacer module, which means
+	  that you will be able to control precise pacing.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called sch_psp.
+
 config NET_SCH_NETEM
 	tristate "Network emulator (NETEM)"
 	---help---
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 81ecbe8..85425c2 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_NET_SCH_TBF)	+= sch_tbf.o
 obj-$(CONFIG_NET_SCH_TEQL)	+= sch_teql.o
 obj-$(CONFIG_NET_SCH_PRIO)	+= sch_prio.o
 obj-$(CONFIG_NET_SCH_ATM)	+= sch_atm.o
+obj-$(CONFIG_NET_SCH_PSP)	+= sch_psp.o
 obj-$(CONFIG_NET_SCH_NETEM)	+= sch_netem.o
 obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
diff --git a/net/sched/sch_psp.c b/net/sched/sch_psp.c
new file mode 100644
index 0000000..620a224
--- /dev/null
+++ b/net/sched/sch_psp.c
@@ -0,0 +1,962 @@
+/*
+ * net/sched/sch_psp.c	PSPacer: Precise Software Pacer
+ *
+ *		Copyright (C) 2004-2007 National Institute of Advanced
+ *		Industrial Science and Technology (AIST), Japan.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Ryousei Takano, <takano-ryousei@aist.go.jp>
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/ethtool.h>
+#include <linux/if_arp.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <net/pkt_sched.h>
+#include <asm/div64.h>
+
+/*
+ * PSPacer achieves precise rate regulation results, and no microscopic
+ * burst transmission which exceeds the limit is generated.
+ *
+ * The basic idea is that transmission timing can be precisely controlled,
+ * if packets are sent back-to-back at the wire rate.  PSPacer controls
+ * the packet transmision intervals by inserting additional packets,
+ * called gap packets, between adjacent packets.  The transmission interval
+ * can be controlled accurately by adjusting the number and size of the gap
+ * packets. PSPacer uses the 802.3x PAUSE frame as the gap packet.
+ *
+ * For the purpose of adjusting the gap size, this Qdisc maintains a byte
+ * clock which is recorded by a total transmitted byte per connection.
+ * Each sub-class has a class local clock which is used to make decision
+ * whether to send a packet or not.  If there is not any packets to send,
+ * gap packets are inserted.
+ *
+ * References:
+ * [1] R.Takano, T.Kudoh, Y.Kodama, M.Matsuda, H.Tezuka, and Y.Ishikawa,
+ *     "Design and Evaluation of Precise Software Pacing Mechanisms for
+ *     Fast Long-Distance Networks", PFLDnet2005.
+ * [2] http://www.gridmpi.org/gridtcp.jsp
+ */
+
+#define HW_GAP (16)	/* Preamble(8) + Inter Frame Gap(8) */
+#define FCS    (4)	/* Frame Check Sequence(4) */
+#define MIN_GAP (64)	/* Minimum size of gap packet */
+#define MIN_TARGET_RATE (1000)	/* 1 KBytes/sec */
+
+#define PSP_HSIZE (16)
+
+struct psp_class
+{
+	u32 classid;			/* class id */
+	int refcnt;			/* reference count */
+
+	struct gnet_stats_basic bstats;	/* basic stats */
+	struct gnet_stats_queue qstats;	/* queue stats */
+
+	int level;			/* class level in hierarchy */
+	struct psp_class *parent;	/* parent class */
+	struct list_head sibling;	/* sibling classes */
+	struct list_head children;	/* child classes */
+
+	struct Qdisc *qdisc;		/* leaf qdisc */
+
+	struct tcf_proto *filter_list;	/* filter list */
+	int filter_cnt;			/* filter count */
+
+	struct list_head hlist;		/* hash list */
+	struct list_head dlist;		/* drop list */
+	struct list_head plist;		/* normal/pacing class qdisc list */
+
+	int activity;			/* activity flag */
+#define FLAG_ACTIVE (0x00000001)	/*  this class has packets or not */
+#define FLAG_DMARK  (0x00000002)	/*  reset mark */
+	int mode;			/* normal/pacing */
+	u64 rate;			/* current target rate (bytes/sec) */
+	u64 allocated_rate;		/* allocated rate to children */
+	u64 gapsize;			/* current gapsize */
+	u64 clock;			/* class local byte clock */
+};
+
+struct psp_sched_data
+{
+	int defcls;				/* default class id */
+	struct list_head root;			/* root class list */
+	struct list_head hash[PSP_HSIZE];	/* class hash */
+	struct list_head drop_list;		/* active leaf class list (for
+						   dropping) */
+	struct list_head pacing_list;		/* gap leaf class list (in
+						   order of the gap size) */
+	struct list_head normal_list;		/* no gap leaf class list */
+
+	struct sk_buff_head requeue;		/* requeued packet */
+
+	struct tcf_proto *filter_list;		/* filter list */
+	int filter_cnt;				/* filter count */
+
+	u64 max_rate;				/* physical rate */
+	u64 allocated_rate;			/* sum of allocated rate */
+	unsigned int mtu;			/* interface MTU size
+						   (included ethernet heaer) */
+	u64 clock;				/* wall clock */
+
+	struct sk_buff *gap;			/* template of gap packets */
+	struct gnet_stats_basic gstats;		/* psp specific stats */
+};
+
+/* A gap packet header (struct ethhdr + h_opcode). */
+struct gaphdr {
+	unsigned char h_dest[ETH_ALEN];		/* destination eth addr */
+	unsigned char h_source[ETH_ALEN];	/* source eth addr */
+	__be16 h_proto;				/* MAC control */
+	__be16 h_opcode;			/* MAC control opcode */
+} __attribute__((packed));
+
+/* The destination address must be specified as 01:80:c2:00:00:01. */
+static const unsigned char gap_dest[ETH_ALEN] = {0x01, 0x80, 0xc2, 0x00,
+						 0x00, 0x01};
+
+
+static struct sk_buff *alloc_gap_packet(struct Qdisc *sch, int size)
+{
+	struct sk_buff *skb;
+	struct net_device *dev = sch->dev;
+	struct gaphdr *gap;
+	int pause_time = 0;
+
+	skb = alloc_skb(size, GFP_KERNEL);
+	if (!skb)
+		return NULL;
+
+	skb_reset_network_header(skb);
+	skb_put(skb, size);
+
+	/*
+	 * fill the payload of a gap packet with 0xff, where size indicates
+	 * the interface MTU size.
+	 */
+	memset(skb->data, 0xff, size);
+
+	gap = (struct gaphdr *)skb->data;
+	memcpy(gap->h_dest, gap_dest, ETH_ALEN);
+	memcpy(gap->h_source, dev->dev_addr, ETH_ALEN);
+	gap->h_proto = htons(ETH_P_PAUSE);
+	gap->h_opcode = htons(pause_time);
+
+	skb->dev = sch->dev;
+	skb->protocol = htons(ETH_P_802_3);
+
+	return skb;
+}
+
+static inline unsigned int psp_hash(u32 h)
+{
+	h ^= h >> 8;
+	h ^= h >> 4;
+	return h & (PSP_HSIZE - 1);
+}
+
+static inline struct psp_class *psp_find(u32 handle, struct Qdisc *sch)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl;
+
+	list_for_each_entry(cl, &q->hash[psp_hash(handle)], hlist) {
+		if (cl->classid == handle)
+			return cl;
+	}
+	return NULL;
+}
+
+static struct psp_class *psp_classify(struct sk_buff *skb, struct Qdisc *sch,
+				      int *qerr)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl;
+	struct tcf_result res;
+	struct tcf_proto *tcf;
+	int result;
+
+	if (TC_H_MAJ(skb->priority ^ sch->handle) == 0 &&
+	    (cl = psp_find(skb->priority, sch)) != NULL)
+		if (cl->level == 0)
+			return cl;
+
+	*qerr = NET_XMIT_BYPASS;
+	tcf = q->filter_list;
+	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
+#ifdef CONFIG_NET_CLS_ACT
+		switch (result) {
+		case TC_ACT_QUEUED:
+		case TC_ACT_STOLEN:
+			*qerr = NET_XMIT_SUCCESS;
+		case TC_ACT_SHOT:
+			return NULL;
+		}
+#endif
+		cl = (struct psp_class *)res.class;
+		if (cl == NULL) {
+			cl = psp_find(res.classid, sch);
+			if (cl == NULL)
+				break; /* filter selected invalid classid */
+		}
+
+		if (cl->level == 0)
+			return cl; /* hit leaf class */
+
+		/* apply inner filter chain */
+		tcf = cl->filter_list;
+	}
+
+	/* classification failed, try default class */
+	cl = psp_find(TC_H_MAKE(TC_H_MAJ(sch->handle), q->defcls), sch);
+	if (cl == NULL || cl->level > 0)
+		return NULL;
+
+	return cl;
+}
+
+static inline void psp_activate(struct psp_sched_data *q, struct psp_class *cl)
+{
+	cl->activity |= FLAG_ACTIVE;
+	list_add_tail(&cl->dlist, &q->drop_list);
+}
+
+static inline void psp_deactivate(struct psp_sched_data *q,
+				  struct psp_class *cl)
+{
+	cl->activity &= ~FLAG_ACTIVE;
+	list_del_init(&cl->dlist);
+}
+
+static void add_leaf_class(struct psp_sched_data *q, struct psp_class *cl)
+{
+	struct psp_class *p;
+	unsigned int mtu = q->mtu + FCS;
+	u64 ipg, npkts;
+
+	/* chain normal/pacing class list */
+	switch (cl->mode) {
+	case MODE_NORMAL:
+		list_add_tail(&cl->plist, &q->normal_list);
+		break;
+
+	case MODE_STATIC:
+		/*
+		 * ipg = (max_rate / target_rate - 1) * mtu
+		 * gappkt_size = ipg - (HW_GAP + FCS) * npkts,
+		 * where npkts = DIV_ROUND_UP(max_rate, target_rate)
+		 */
+		npkts = q->max_rate + cl->rate - 1;
+		do_div(npkts, cl->rate);
+		ipg = q->max_rate * mtu;
+		do_div(ipg, cl->rate);
+		ipg -= mtu;
+		cl->gapsize = ipg - (HW_GAP + FCS) * npkts;
+		cl->gapsize = max_t(u64, cl->gapsize, MIN_GAP);
+
+		cl->activity |= FLAG_DMARK;
+		list_for_each_entry(p, &q->pacing_list, plist) {
+			if (cl->gapsize < p->gapsize)
+				break;
+		}
+		list_add_tail(&cl->plist, &p->plist);
+		break;
+	}
+}
+
+static u64 recalc_gapsize(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl;
+	unsigned int len = skb->len;
+	u64 gapsize = 0;
+	int err;
+
+	cl = psp_classify(skb, sch, &err);
+	BUG_TRAP(cl);
+
+	if (cl->mode == MODE_STATIC) {
+		gapsize = cl->gapsize * len;
+		do_div(gapsize, q->mtu);
+	}
+	return max_t(u64, gapsize, MIN_GAP);
+}
+
+/*
+ * Update byte clocks
+ * When a packet is sent out:
+ *     Qdisc's clock += packet length
+ *     if the class is the pacing class:
+ *         class's clock += packet length + gap length
+ */
+static void update_clocks(struct sk_buff *skb, struct Qdisc *sch,
+			  struct psp_class *cl)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	unsigned int len = skb->len;
+	u64 gapsize;
+
+	q->clock += len;
+	if (cl == NULL || cl->mode == MODE_NORMAL)
+		return;
+
+	/* pacing class */
+	gapsize = recalc_gapsize(skb, sch);
+	if (!(cl->activity & FLAG_DMARK)) {
+		cl->clock += len + gapsize;
+	} else { /* reset class clock */
+		cl->activity &= ~FLAG_DMARK;
+		cl->clock = q->clock + gapsize;
+	}
+}
+
+/*
+ * Lookup next target class
+ * Firstly, search the pacing class list:
+ *     If the Qdisc's clock < the class's clock then the class is selected.
+ * Secondly, search the normal class list.
+ *
+ * Finally, a gap packet is inserted, because there is not any packets
+ * to send out.  And it returns the size of the gap packet.
+ */
+static struct psp_class *lookup_next_class(struct Qdisc *sch, u64 *gapsize)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl, *next = NULL;
+	u64 diff, nearest;
+
+	/* pacing class */
+	nearest = q->mtu;
+	list_for_each_entry(cl, &q->pacing_list, plist) {
+		if (cl->clock > q->clock) {
+			diff = cl->clock - q->clock;
+			if (nearest > diff)
+				nearest = diff;
+			continue;
+		}
+		if (!(cl->activity & FLAG_ACTIVE)) {
+			cl->activity |= FLAG_DMARK;
+			continue;
+		}
+
+		if (next == NULL)
+			next = cl;
+	}
+	if (next)
+		return next;
+
+	/* normal class */
+	list_for_each_entry(cl, &q->normal_list, plist) {
+		if (!(cl->activity & FLAG_ACTIVE))
+			continue;
+
+		list_move_tail(&cl->plist, &q->normal_list);
+		return cl;
+	}
+
+	/* gap packet */
+	*gapsize = max_t(u64, nearest, sizeof(struct gaphdr));
+	return NULL;
+}
+
+static int psp_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl;
+	int err;
+
+	cl = psp_classify(skb, sch, &err);
+	if (cl == NULL) {
+		if (err == NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return err;
+	}
+
+	err = cl->qdisc->ops->enqueue(skb, cl->qdisc);
+	if (unlikely(err != NET_XMIT_SUCCESS)) {
+		sch->qstats.drops++;
+		cl->qstats.drops++;
+		return err;
+	}
+
+	cl->bstats.packets++;
+	cl->bstats.bytes += skb->len;
+	if (!(cl->activity & FLAG_ACTIVE))
+		psp_activate(q, cl);
+
+	sch->q.qlen++;
+	sch->bstats.packets++;
+	sch->bstats.bytes += skb->len;
+	return NET_XMIT_SUCCESS;
+}
+
+static int psp_requeue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+
+	__skb_queue_head(&q->requeue, skb);
+	sch->q.qlen++;
+	sch->qstats.requeues++;
+
+	return NET_XMIT_SUCCESS;
+}
+
+static struct sk_buff *psp_dequeue(struct Qdisc *sch)
+{
+	struct sk_buff *skb = NULL;
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl;
+	u64 gapsize;
+
+	if (sch->q.qlen == 0)
+		return NULL;
+
+	/* requeue */
+	skb = __skb_dequeue(&q->requeue);
+	if (skb != NULL) {
+		sch->q.qlen--;
+		return skb;
+	}
+
+	/* normal/pacing class */
+	cl = lookup_next_class(sch, &gapsize);
+	if (cl != NULL) {
+		skb = cl->qdisc->ops->dequeue(cl->qdisc);
+		if (skb == NULL)
+			return NULL; /* nothing to send */
+
+		sch->q.qlen--;
+
+		goto update_clocks;
+	}
+
+	/* clone a gap packet */
+	skb = skb_clone(q->gap, GFP_ATOMIC);
+	if (unlikely(!skb)) {
+		printk(KERN_ERR "psp: cannot clone a gap packet.\n");
+		return NULL;
+	}
+	skb_trim(skb, gapsize);
+	q->gstats.bytes += gapsize;
+	q->gstats.packets++;
+
+ update_clocks:
+	update_clocks(skb, sch, cl);
+	if (cl && cl->qdisc->q.qlen == 0)
+		psp_deactivate(q, cl);
+	return skb;
+}
+
+static unsigned int psp_drop(struct Qdisc *sch)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl;
+	unsigned int len;
+
+	list_for_each_entry(cl, &q->drop_list, dlist) {
+		if (cl->qdisc->ops->drop != NULL &&
+		    (len = cl->qdisc->ops->drop(cl->qdisc)) > 0) {
+			if (cl->qdisc->q.qlen == 0)
+				psp_deactivate(q, cl);
+			else
+				list_move_tail(&cl->dlist, &q->drop_list);
+
+			cl->qstats.drops++;
+			sch->qstats.drops++;
+			sch->q.qlen--;
+			return len;
+		}
+	}
+	return 0;
+}
+
+static void psp_reset(struct Qdisc *sch)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl;
+	int i;
+
+	for (i = 0; i < PSP_HSIZE; i++) {
+		list_for_each_entry(cl, &q->hash[i], hlist) {
+			if (cl->level == 0)
+				qdisc_reset(cl->qdisc);
+		}
+	}
+
+	__skb_queue_purge(&q->requeue);
+	INIT_LIST_HEAD(&q->drop_list);
+	sch->q.qlen = 0;
+}
+
+static void psp_destroy_class(struct Qdisc *sch, struct psp_class *cl)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *pos, *next;
+
+	if (cl->mode == MODE_STATIC) {
+		if (cl->parent)
+			cl->parent->allocated_rate -= cl->rate;
+		else
+			q->allocated_rate -= cl->rate;
+	}
+
+	tcf_destroy_chain(q->filter_list);
+
+	list_for_each_entry_safe(pos, next, &cl->children, sibling)
+		psp_destroy_class(sch, pos);
+
+	list_del(&cl->hlist);
+	list_del(&cl->sibling);
+	psp_deactivate(q, cl);
+	if (cl->level == 0) {
+		list_del(&cl->plist);
+		qdisc_destroy(cl->qdisc);
+	}
+	kfree(cl);
+}
+
+static void psp_destroy(struct Qdisc *sch)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl, *next;
+
+	tcf_destroy_chain(q->filter_list);
+
+	list_for_each_entry_safe(cl, next, &q->root, sibling)
+		psp_destroy_class(sch, cl);
+
+	__skb_queue_purge(&q->requeue);
+
+	/* free gap packet */
+	kfree_skb(q->gap);
+}
+
+static int psp_init(struct Qdisc *sch, struct rtattr *opt)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct rtattr *tb[TCA_PSP_QOPT];
+	struct net_device *dev = sch->dev;
+	struct tc_psp_qopt *qopt;
+	struct ethtool_cmd cmd = { ETHTOOL_GSET };
+	int i;
+
+	if (sch->parent != TC_H_ROOT) {
+		printk(KERN_ERR "psp: PSPacer only works as a root qdisc.\n");
+		return -EINVAL;
+	}
+
+	if (dev->type != ARPHRD_ETHER) {
+		printk(KERN_ERR "psp: PSPacer only supports Ethernet"
+		       " devices.\n");
+		return -EINVAL;
+	}
+
+	if (dev->features & NETIF_F_TSO) {
+		printk(KERN_ERR "psp: PSPacer does not support TSO."
+		       " You must disable it: \"ethtool -K %s tso off\"\n",
+		       dev->name);
+		return -EINVAL;
+	}
+
+	if (!opt || rtattr_parse_nested(tb, TCA_PSP_QOPT, opt) ||
+	    tb[TCA_PSP_QOPT-1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_PSP_QOPT-1]) < sizeof(*qopt))
+		return -EINVAL;
+
+	qopt = RTA_DATA(tb[TCA_PSP_QOPT-1]);
+
+	q->defcls = qopt->defcls;
+	q->mtu = dev->mtu + dev->hard_header_len;
+	q->gap = alloc_gap_packet(sch, q->mtu);
+	if (q->gap == NULL)
+		return -ENOBUFS;
+	if (qopt->rate == 0) {
+		/*
+		 * set qdisc max rate.  If the kernel supports ethtool ioctl,
+		 * it sets to that value, otherwise it statically sets to
+		 * the GbE transmission rate (i.e. 125MB/s).
+		 */
+		/*
+		 * NOTE: Since ethtool's {cmd.speed} specifies Mbps,
+		 * the value is converted in units of byte/sec.
+		 */
+		u64 max = 125000000;
+
+		if (dev->ethtool_ops && dev->ethtool_ops->get_settings) {
+			if (dev->ethtool_ops->get_settings(dev, &cmd) == 0) {
+				max = cmd.speed * 1000000;
+				do_div(max, BITS_PER_BYTE);
+			}
+		}
+		q->max_rate = max;
+	} else {
+		q->max_rate = qopt->rate;
+	}
+
+	INIT_LIST_HEAD(&q->root);
+	for (i = 0; i < PSP_HSIZE; i++)
+		INIT_LIST_HEAD(q->hash + i);
+	INIT_LIST_HEAD(&q->drop_list);
+	INIT_LIST_HEAD(&q->pacing_list);
+	INIT_LIST_HEAD(&q->normal_list);
+	skb_queue_head_init(&q->requeue);
+
+	return 0;
+}
+
+static int psp_dump_qdisc(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	unsigned char *b = skb_tail_pointer(skb);
+	struct rtattr *rta;
+	struct tc_psp_qopt qopt;
+
+	qopt.defcls = q->defcls;
+	qopt.rate = q->max_rate;
+	rta = (struct rtattr *)b;
+	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	RTA_PUT(skb, TCA_PSP_QOPT, sizeof(qopt), &qopt);
+	rta->rta_len = skb_tail_pointer(skb) - b;
+
+	return skb->len;
+
+rtattr_failure:
+	skb_trim(skb, skb_tail_pointer(skb) - skb->data);
+	return -1;
+}
+
+static int psp_dump_qdisc_stats(struct Qdisc *sch, struct gnet_dump *d)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+
+	return gnet_stats_copy_app(d, &q->gstats, sizeof(q->gstats));
+}
+
+static int psp_dump_class(struct Qdisc *sch, unsigned long arg,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+	struct psp_class *cl = (struct psp_class *)arg;
+	unsigned char *b = skb_tail_pointer(skb);
+	struct rtattr *rta;
+	struct tc_psp_copt copt;
+
+	tcm->tcm_parent = cl->parent ? cl->parent->classid : TC_H_ROOT;
+	tcm->tcm_handle = cl->classid;
+	if (cl->level == 0) {
+		tcm->tcm_info = cl->qdisc->handle;
+		cl->qstats.qlen = cl->qdisc->q.qlen;
+	}
+
+	rta = (struct rtattr *)b;
+	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
+	memset(&copt, 0, sizeof(copt));
+	copt.level = cl->level;
+	copt.mode = cl->mode;
+	copt.rate = cl->rate;
+	RTA_PUT(skb, TCA_PSP_COPT, sizeof(copt), &copt);
+	RTA_PUT(skb, TCA_PSP_QOPT, 0, NULL);
+	rta->rta_len = skb_tail_pointer(skb) - b;
+
+	return skb->len;
+ rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int psp_dump_class_stats(struct Qdisc *sch, unsigned long arg,
+				struct gnet_dump *d)
+{
+	struct psp_class *cl = (struct psp_class *)arg;
+
+	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
+		return -1;
+
+	return 0;
+}
+
+static int psp_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
+		     struct Qdisc **old)
+{
+	struct psp_class *cl = (struct psp_class *)arg;
+
+	if (cl == NULL)
+		return -ENOENT;
+	if (cl->level != 0)
+		return -EINVAL;
+	if (new == NULL) {
+		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+					cl->classid);
+		if (new == NULL)
+			new = &noop_qdisc;
+	}
+
+	sch_tree_lock(sch);
+	*old = xchg(&cl->qdisc, new);
+	qdisc_reset(*old);
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+	sch_tree_unlock(sch);
+	return 0;
+}
+
+static struct Qdisc *psp_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	struct psp_class *cl = (struct psp_class *)arg;
+
+	return (cl != NULL && cl->level == 0) ? cl->qdisc : NULL;
+}
+
+static unsigned long psp_get(struct Qdisc *sch, u32 classid)
+{
+	struct psp_class *cl = psp_find(classid, sch);
+
+	if (cl)
+		cl->refcnt++;
+	return (unsigned long)cl;
+}
+
+static void psp_put(struct Qdisc *sch, unsigned long arg)
+{
+	struct psp_class *cl = (struct psp_class *)arg;
+
+	if (--cl->refcnt == 0)
+		psp_destroy_class(sch, cl);
+}
+
+static int psp_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
+			    struct rtattr **tca, unsigned long *arg)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl = (struct psp_class *)*arg, *parent;
+	struct rtattr *opt = tca[TCA_OPTIONS-1];
+	struct rtattr *tb[TCA_PSP_QOPT];
+	struct tc_psp_copt *copt;
+	unsigned int limit;
+
+	if (opt == NULL ||
+	    rtattr_parse(tb, TCA_PSP_QOPT, RTA_DATA(opt), RTA_PAYLOAD(opt)))
+		return -EINVAL;
+
+	copt = RTA_DATA(tb[TCA_PSP_COPT - 1]);
+
+	parent = (parentid == TC_H_ROOT ? NULL : psp_find(parentid, sch));
+
+	if (cl == NULL) { /* create new class */
+		struct Qdisc *new_q;
+
+		cl = kzalloc(sizeof(struct psp_class), GFP_KERNEL);
+		if (cl == NULL)
+			return -ENOBUFS;
+
+		cl->refcnt = 1;
+		INIT_LIST_HEAD(&cl->sibling);
+		INIT_LIST_HEAD(&cl->children);
+		INIT_LIST_HEAD(&cl->hlist);
+		INIT_LIST_HEAD(&cl->dlist);
+		INIT_LIST_HEAD(&cl->plist);
+
+		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
+
+		sch_tree_lock(sch);
+		if (parent && parent->level != 0) {
+			unsigned int qlen = parent->qdisc->q.qlen;
+
+			/* turn parent into inner node */
+			qdisc_reset(parent->qdisc);
+			qdisc_tree_decrease_qlen(parent->qdisc, qlen);
+			qdisc_destroy(parent->qdisc);
+			psp_deactivate(q, cl);
+			list_del(&parent->plist);
+
+			parent->level = (parent->parent ? parent->parent->level
+					 : TC_PSP_MAXDEPTH) - 1;
+		}
+		cl->qdisc = new_q ? new_q : &noop_qdisc;
+		cl->classid = classid;
+		cl->parent = parent;
+
+		list_add_tail(&cl->hlist, q->hash + psp_hash(classid));
+		list_add_tail(&cl->sibling,
+			      (parent ? &parent->children : &q->root));
+	} else {
+		if (cl->mode == MODE_STATIC)
+			q->allocated_rate -= cl->rate;
+
+		sch_tree_lock(sch);
+	}
+
+	/* setup mode and target rate */
+	cl->mode = copt->mode;
+	if (copt->rate < MIN_TARGET_RATE)
+		copt->rate = MIN_TARGET_RATE;
+	cl->rate = copt->rate;
+	if (cl->mode == MODE_STATIC) {
+		limit = (parent ? parent->allocated_rate : q->allocated_rate) +
+			cl->rate;
+		if (limit > q->max_rate) {
+			printk(KERN_ERR "psp: target rate is oversubscribed!");
+			list_del_init(&cl->hlist);
+			psp_deactivate(q, cl);
+			if (--cl->refcnt == 0)
+				psp_destroy_class(sch, cl);
+			sch_tree_unlock(sch);
+			return -EINVAL;
+		}
+
+		if (parent)
+			parent->allocated_rate += cl->rate;
+		else
+			q->allocated_rate += cl->rate;
+	}
+
+	if (cl->level == 0) {
+		if (!list_empty(&cl->plist))
+			list_del(&cl->plist);
+		add_leaf_class(q, cl);
+	}
+	sch_tree_unlock(sch);
+	*arg = (unsigned long)cl;
+	return 0;
+}
+
+static struct tcf_proto **psp_find_tcf(struct Qdisc *sch, unsigned long arg)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl = (struct psp_class *)arg;
+	struct tcf_proto **fl = cl ? &cl->filter_list : &q->filter_list;
+
+	return fl;
+}
+
+static unsigned long psp_bind_filter(struct Qdisc *sch, unsigned long parent,
+				     u32 classid)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl = psp_find(classid, sch);
+
+	if (cl)
+		cl->filter_cnt++;
+	else
+		q->filter_cnt++;
+	return (unsigned long)cl;
+}
+
+static void psp_unbind_filter(struct Qdisc *sch, unsigned long arg)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl = (struct psp_class *)arg;
+
+	if (cl)
+		cl->filter_cnt--;
+	else
+		q->filter_cnt--;
+}
+
+static int psp_delete(struct Qdisc *sch, unsigned long arg)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	struct psp_class *cl = (struct psp_class *)arg;
+
+	if (!list_empty(&cl->children) || cl->filter_cnt)
+		return -EBUSY;
+
+	sch_tree_lock(sch);
+
+	if (cl->level == 0) {
+		unsigned int qlen = cl->qdisc->q.qlen;
+
+		qdisc_reset(cl->qdisc);
+		qdisc_tree_decrease_qlen(cl->qdisc, qlen);
+	}
+
+	list_del_init(&cl->hlist);
+	psp_deactivate(q, cl);
+	list_del_init(&cl->plist);
+	if (--cl->refcnt == 0)
+		psp_destroy_class(sch, cl);
+
+	sch_tree_unlock(sch);
+	return 0;
+}
+
+static void psp_walk(struct Qdisc *sch, struct qdisc_walker *arg)
+{
+	struct psp_sched_data *q = qdisc_priv(sch);
+	int i;
+
+	if (arg->stop)
+		return;
+
+	for (i = 0; i < PSP_HSIZE; i++) {
+		struct psp_class *cl;
+
+		list_for_each_entry(cl, &q->hash[i], hlist) {
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
+static const struct Qdisc_class_ops psp_class_ops = {
+	.graft		=	psp_graft,
+	.leaf		=	psp_leaf,
+	.get		=	psp_get,
+	.put		=	psp_put,
+	.change		=	psp_change_class,
+	.delete		=	psp_delete,
+	.walk		=	psp_walk,
+	.tcf_chain	=	psp_find_tcf,
+	.bind_tcf	=	psp_bind_filter,
+	.unbind_tcf	=	psp_unbind_filter,
+	.dump		=	psp_dump_class,
+	.dump_stats	=	psp_dump_class_stats,
+};
+
+static struct Qdisc_ops psp_qdisc_ops __read_mostly = {
+	.cl_ops		=	&psp_class_ops,
+	.id		=	"psp",
+	.priv_size	=	sizeof(struct psp_sched_data),
+	.enqueue	=	psp_enqueue,
+	.dequeue	=	psp_dequeue,
+	.requeue	=	psp_requeue,
+	.drop		=	psp_drop,
+	.init		=	psp_init,
+	.reset		=	psp_reset,
+	.destroy	=	psp_destroy,
+	.dump		=	psp_dump_qdisc,
+	.dump_stats	=	psp_dump_qdisc_stats,
+	.owner		=	THIS_MODULE,
+};
+
+static int __init psp_module_init(void)
+{
+	return register_qdisc(&psp_qdisc_ops);
+}
+
+static void __exit psp_module_exit(void)
+{
+	unregister_qdisc(&psp_qdisc_ops);
+}
+
+module_init(psp_module_init)
+module_exit(psp_module_exit)
+MODULE_LICENSE("GPL");
-- 
1.5.3.4

