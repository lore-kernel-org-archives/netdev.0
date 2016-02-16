From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 3/8] net: sched: add cls_u32 offload hooks for
 netdevs
Date: Mon, 15 Feb 2016 22:01:25 -0800
Message-ID: <20160216060125.32452.25924.stgit@john-Precision-Tower-5810>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	jeffrey.t.kirsher@intel.com
To: amir@vadai.me, john.fastabend@gmail.com, jhs@mojatatu.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36510 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753582AbcBPGBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 01:01:44 -0500
Received: by mail-pf0-f173.google.com with SMTP id e127so99237360pfe.3
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 22:01:44 -0800 (PST)
In-Reply-To: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows netdev drivers to consume cls_u32 offloads via
the ndo_setup_tc ndo op.

This works aligns with how network drivers have been doing qdisc
offloads for mqprio.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/netdevice.h |    6 ++-
 include/net/pkt_cls.h     |   34 +++++++++++++++
 net/sched/cls_u32.c       |   99 ++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 136 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 105a661..f8b500e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -779,17 +779,21 @@ static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
-/* This structure holds attributes of qdisc and classifiers
+/* These structures hold the attributes of qdisc and classifiers
  * that are being passed to the netdevice through the setup_tc op.
  */
 enum {
 	TC_SETUP_MQPRIO,
+	TC_SETUP_CLSU32,
 };
 
+struct tc_cls_u32_offload;
+
 struct tc_to_netdev {
 	unsigned int type;
 	union {
 		u8 tc;
+		struct tc_cls_u32_offload *cls_u32;
 	};
 };
 
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index bc49967..174e4dc 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -358,4 +358,38 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
 }
 #endif /* CONFIG_NET_CLS_IND */
 
+struct tc_cls_u32_knode {
+	struct tcf_exts *exts;
+	u8 fshift;
+	u32 handle;
+	u32 val;
+	u32 mask;
+	u32 link_handle;
+	struct tc_u32_sel *sel;
+};
+
+struct tc_cls_u32_hnode {
+	u32 handle;
+	u32 prio;
+	unsigned int divisor;
+};
+
+enum {
+	TC_CLSU32_NEW_KNODE,
+	TC_CLSU32_REPLACE_KNODE,
+	TC_CLSU32_DELETE_KNODE,
+	TC_CLSU32_NEW_HNODE,
+	TC_CLSU32_REPLACE_HNODE,
+	TC_CLSU32_DELETE_HNODE,
+};
+
+struct tc_cls_u32_offload {
+	/* knode values */
+	int command;
+	union {
+		struct tc_cls_u32_knode knode;
+		struct tc_cls_u32_hnode hnode;
+	};
+};
+
 #endif
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 4fbb674..d54bc94 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -43,6 +43,7 @@
 #include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
+#include <linux/netdevice.h>
 
 struct tc_u_knode {
 	struct tc_u_knode __rcu	*next;
@@ -424,6 +425,93 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 	return 0;
 }
 
+static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tc_cls_u32_offload u32_offload = {0};
+	struct tc_to_netdev offload;
+
+	offload.type = TC_SETUP_CLSU32;
+	offload.cls_u32 = &u32_offload;
+
+	if (dev->netdev_ops->ndo_setup_tc) {
+		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
+		offload.cls_u32->knode.handle = handle;
+		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					      tp->protocol, &offload);
+	}
+}
+
+static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tc_cls_u32_offload u32_offload = {0};
+	struct tc_to_netdev offload;
+
+	offload.type = TC_SETUP_CLSU32;
+	offload.cls_u32 = &u32_offload;
+
+	if (dev->netdev_ops->ndo_setup_tc) {
+		offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
+		offload.cls_u32->hnode.divisor = h->divisor;
+		offload.cls_u32->hnode.handle = h->handle;
+		offload.cls_u32->hnode.prio = h->prio;
+
+		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					      tp->protocol, &offload);
+	}
+}
+
+static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tc_cls_u32_offload u32_offload = {0};
+	struct tc_to_netdev offload;
+
+	offload.type = TC_SETUP_CLSU32;
+	offload.cls_u32 = &u32_offload;
+
+	if (dev->netdev_ops->ndo_setup_tc) {
+		offload.cls_u32->command = TC_CLSU32_DELETE_HNODE;
+		offload.cls_u32->hnode.divisor = h->divisor;
+		offload.cls_u32->hnode.handle = h->handle;
+		offload.cls_u32->hnode.prio = h->prio;
+
+		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					      tp->protocol, &offload);
+	}
+}
+
+static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
+{
+	struct net_device *dev = tp->q->dev_queue->dev;
+	struct tc_cls_u32_offload u32_offload = {0};
+	struct tc_to_netdev offload;
+
+	offload.type = TC_SETUP_CLSU32;
+	offload.cls_u32 = &u32_offload;
+
+	if (dev->netdev_ops->ndo_setup_tc) {
+		offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
+		offload.cls_u32->knode.handle = n->handle;
+		offload.cls_u32->knode.fshift = n->fshift;
+#ifdef CONFIG_CLS_U32_MARK
+		offload.cls_u32->knode.val = n->val;
+		offload.cls_u32->knode.mask = n->mask;
+#else
+		offload.cls_u32->knode.val = 0;
+		offload.cls_u32->knode.mask = 0;
+#endif
+		offload.cls_u32->knode.sel = &n->sel;
+		offload.cls_u32->knode.exts = &n->exts;
+		if (n->ht_down)
+			offload.cls_u32->knode.link_handle = n->ht_down->handle;
+
+		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					      tp->protocol, &offload);
+	}
+}
+
 static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 {
 	struct tc_u_knode *n;
@@ -434,6 +522,7 @@ static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 			RCU_INIT_POINTER(ht->ht[h],
 					 rtnl_dereference(n->next));
 			tcf_unbind_filter(tp, &n->res);
+			u32_remove_hw_knode(tp, n->handle);
 			call_rcu(&n->rcu, u32_delete_key_freepf_rcu);
 		}
 	}
@@ -454,6 +543,7 @@ static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 	     phn;
 	     hn = &phn->next, phn = rtnl_dereference(*hn)) {
 		if (phn == ht) {
+			u32_clear_hw_hnode(tp, ht);
 			RCU_INIT_POINTER(*hn, ht->next);
 			kfree_rcu(ht, rcu);
 			return 0;
@@ -540,8 +630,10 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 	if (ht == NULL)
 		return 0;
 
-	if (TC_U32_KEY(ht->handle))
+	if (TC_U32_KEY(ht->handle)) {
+		u32_remove_hw_knode(tp, ht->handle);
 		return u32_delete_key(tp, (struct tc_u_knode *)ht);
+	}
 
 	if (root_ht == ht)
 		return -EINVAL;
@@ -769,6 +861,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		u32_replace_knode(tp, tp_c, new);
 		tcf_unbind_filter(tp, &n->res);
 		call_rcu(&n->rcu, u32_delete_key_rcu);
+		u32_replace_hw_knode(tp, new);
 		return 0;
 	}
 
@@ -795,6 +888,8 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		RCU_INIT_POINTER(ht->next, tp_c->hlist);
 		rcu_assign_pointer(tp_c->hlist, ht);
 		*arg = (unsigned long)ht;
+
+		u32_replace_hw_hnode(tp, ht);
 		return 0;
 	}
 
@@ -877,7 +972,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 		RCU_INIT_POINTER(n->next, pins);
 		rcu_assign_pointer(*ins, n);
-
+		u32_replace_hw_knode(tp, n);
 		*arg = (unsigned long)n;
 		return 0;
 	}
