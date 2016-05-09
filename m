From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [PATCH net-next 2/2] net: cls_u32: Add support for skip-sw flag to tc u32 classifier.
Date: Mon,  9 May 2016 12:18:44 -0700
Message-ID: <1462821524-2534-2-git-send-email-sridhar.samudrala@intel.com>
References: <1462821524-2534-1-git-send-email-sridhar.samudrala@intel.com>
To: john.r.fastabend@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:16295 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964AbcEITXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 15:23:53 -0400
In-Reply-To: <1462821524-2534-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On devices that support TC U32 offloads, this flag enables a filter to be
added only to HW. skip-sw and skip-hw are mutually exclusive flags. By
default without any flags, the filter is added to both HW and SW, but no
error checks are done in case of failure to add to HW. With skip-sw,
failure to add to HW is treated as an error.

Here is a sample script that adds 2 filters, one with skip-sw and the other
with skip-hw flag.

   # add ingress qdisc
   tc qdisc add dev p4p1 ingress

   # enable hw tc offload.
   ethtool -K p4p1 hw-tc-offload on

   # add u32 filter with skip-sw flag.
   tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
      handle 800:0:1 u32 ht 800: flowid 800:1 \
      skip-sw \
      match ip src 192.168.1.0/24 \
      action drop

   # add u32 filter with skip-hw flag.
   tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
      handle 800:0:2 u32 ht 800: flowid 800:2 \
      skip-hw \
      match ip src 192.168.2.0/24 \
      action drop

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 include/net/pkt_cls.h        | 17 +++++++++++++++++
 include/uapi/linux/pkt_cls.h |  1 +
 net/sched/cls_u32.c          | 45 +++++++++++++++++++++++++++++++++++---------
 3 files changed, 54 insertions(+), 9 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 339ef08..8b48938 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -406,6 +406,23 @@ static inline bool tc_should_offload(struct net_device *dev, u32 flags)
 	return true;
 }
 
+static inline bool tc_skip_sw(u32 flags)
+{
+	return (flags & TCA_CLS_FLAGS_SKIP_SW) ? true : false;
+}
+
+/* SKIP_HW and SKIP_SW are mutually exclusive flags. */
+static inline bool tc_flags_valid(u32 flags)
+{
+	if (flags & ~(TCA_CLS_FLAGS_SKIP_HW | TCA_CLS_FLAGS_SKIP_SW))
+		return false;
+
+	if (!(flags ^ (TCA_CLS_FLAGS_SKIP_HW | TCA_CLS_FLAGS_SKIP_SW)))
+		return false;
+
+	return true;
+}
+
 enum tc_fl_command {
 	TC_CLSFLOWER_REPLACE,
 	TC_CLSFLOWER_DESTROY,
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 3e8b65f..eba5914 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -153,6 +153,7 @@ enum {
 
 /* tca flags definitions */
 #define TCA_CLS_FLAGS_SKIP_HW	(1 << 0)
+#define TCA_CLS_FLAGS_SKIP_SW	(1 << 1)
 
 /* U32 filters */
 
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index e64877a..079b43b 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -134,6 +134,11 @@ next_knode:
 		j = 0;
 #endif
 
+		if (tc_skip_sw(n->flags)) {
+			n = rcu_dereference_bh(n->next);
+			goto next_knode;
+		}
+
 #ifdef CONFIG_CLS_U32_MARK
 		if ((skb->mark & n->mask) != n->val) {
 			n = rcu_dereference_bh(n->next);
@@ -443,13 +448,14 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	}
 }
 
-static void u32_replace_hw_hnode(struct tcf_proto *tp,
+static int u32_replace_hw_hnode(struct tcf_proto *tp,
 				 struct tc_u_hnode *h,
 				 u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload u32_offload = {0};
 	struct tc_to_netdev offload;
+	int err;
 
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
@@ -460,9 +466,13 @@ static void u32_replace_hw_hnode(struct tcf_proto *tp,
 		offload.cls_u32->hnode.handle = h->handle;
 		offload.cls_u32->hnode.prio = h->prio;
 
-		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					      tp->protocol, &offload);
+		err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+						    tp->protocol, &offload);
+		if (tc_skip_sw(flags))
+			return err;
 	}
+
+	return 0;
 }
 
 static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
@@ -485,13 +495,14 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	}
 }
 
-static void u32_replace_hw_knode(struct tcf_proto *tp,
+static int u32_replace_hw_knode(struct tcf_proto *tp,
 				 struct tc_u_knode *n,
 				 u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_u32_offload u32_offload = {0};
 	struct tc_to_netdev offload;
+	int err;
 
 	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
@@ -512,9 +523,13 @@ static void u32_replace_hw_knode(struct tcf_proto *tp,
 		if (n->ht_down)
 			offload.cls_u32->knode.link_handle = n->ht_down->handle;
 
-		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					      tp->protocol, &offload);
+		err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+						    tp->protocol, &offload);
+		if (tc_skip_sw(flags))
+			return err;
 	}
+
+	return 0;
 }
 
 static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
@@ -845,8 +860,11 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_U32_FLAGS])
+	if (tb[TCA_U32_FLAGS]) {
 		flags = nla_get_u32(tb[TCA_U32_FLAGS]);
+		if (!tc_flags_valid(flags))
+			return err;
+	}
 
 	n = (struct tc_u_knode *)*arg;
 	if (n) {
@@ -871,10 +889,15 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 			return err;
 		}
 
+		err = u32_replace_hw_knode(tp, new, flags);
+		if (err) {
+			u32_destroy_key(tp, new, false);
+			return err;
+		}
+
 		u32_replace_knode(tp, tp_c, new);
 		tcf_unbind_filter(tp, &n->res);
 		call_rcu(&n->rcu, u32_delete_key_rcu);
-		u32_replace_hw_knode(tp, new, flags);
 		return 0;
 	}
 
@@ -978,6 +1001,10 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		struct tc_u_knode __rcu **ins;
 		struct tc_u_knode *pins;
 
+		err = u32_replace_hw_knode(tp, n, flags);
+		if (err)
+			goto errhw;
+
 		ins = &ht->ht[TC_U32_HASH(handle)];
 		for (pins = rtnl_dereference(*ins); pins;
 		     ins = &pins->next, pins = rtnl_dereference(*ins))
@@ -986,11 +1013,11 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 		RCU_INIT_POINTER(n->next, pins);
 		rcu_assign_pointer(*ins, n);
-		u32_replace_hw_knode(tp, n, flags);
 		*arg = (unsigned long)n;
 		return 0;
 	}
 
+errhw:
 #ifdef CONFIG_CLS_U32_MARK
 	free_percpu(n->pcpu_success);
 errout:
-- 
2.1.0
