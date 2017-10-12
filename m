From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/34] net: sched: introduce support for multiple filter chain pointers registration
Date: Thu, 12 Oct 2017 19:17:51 +0200
Message-ID: <20171012171823.1431-3-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:55393 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752311AbdJLRS1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:27 -0400
Received: by mail-wm0-f66.google.com with SMTP id u138so15332498wmu.4
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:27 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

So far, there was possible only to register a single filter chain
pointer to block->chain[0]. However, when the blocks will get shareable,
we need to allow multiple filter chain pointers registration.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_sched.h   |  7 +++++
 include/net/sch_generic.h |  3 ++-
 net/sched/cls_api.c       | 68 ++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 67 insertions(+), 11 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 259bc19..2d234af 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -4,7 +4,9 @@
 #include <linux/jiffies.h>
 #include <linux/ktime.h>
 #include <linux/if_vlan.h>
+#include <linux/netdevice.h>
 #include <net/sch_generic.h>
+#include <net/net_namespace.h>
 #include <uapi/linux/pkt_sched.h>
 
 #define DEFAULT_TX_QUEUE_LEN	1000
@@ -146,4 +148,9 @@ static inline bool is_classid_clsact_egress(u32 classid)
 	       TC_H_MIN(classid) == TC_H_MIN(TC_H_MIN_EGRESS);
 }
 
+static inline struct net *qdisc_net(struct Qdisc *q)
+{
+	return dev_net(q->dev_queue->dev);
+}
+
 #endif
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index df4032c..6583c59 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -261,7 +261,7 @@ struct qdisc_skb_cb {
 
 struct tcf_chain {
 	struct tcf_proto __rcu *filter_chain;
-	struct tcf_proto __rcu **p_filter_chain;
+	struct list_head filter_chain_list;
 	struct list_head list;
 	struct tcf_block *block;
 	u32 index; /* chain index */
@@ -270,6 +270,7 @@ struct tcf_chain {
 
 struct tcf_block {
 	struct list_head chain_list;
+	struct net *net;
 	struct Qdisc *q;
 };
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index f7d3f1f..0ffd79a 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -171,6 +171,11 @@ static void tcf_proto_destroy(struct tcf_proto *tp)
 	kfree_rcu(tp, rcu);
 }
 
+struct tfc_filter_chain_list_item {
+	struct list_head list;
+	struct tcf_proto __rcu **p_filter_chain;
+};
+
 static struct tcf_chain *tcf_chain_create(struct tcf_block *block,
 					  u32 chain_index)
 {
@@ -179,6 +184,7 @@ static struct tcf_chain *tcf_chain_create(struct tcf_block *block,
 	chain = kzalloc(sizeof(*chain), GFP_KERNEL);
 	if (!chain)
 		return NULL;
+	INIT_LIST_HEAD(&chain->filter_chain_list);
 	list_add_tail(&chain->list, &block->chain_list);
 	chain->block = block;
 	chain->index = chain_index;
@@ -188,10 +194,11 @@ static struct tcf_chain *tcf_chain_create(struct tcf_block *block,
 
 static void tcf_chain_flush(struct tcf_chain *chain)
 {
+	struct tfc_filter_chain_list_item *item;
 	struct tcf_proto *tp;
 
-	if (chain->p_filter_chain)
-		RCU_INIT_POINTER(*chain->p_filter_chain, NULL);
+	list_for_each_entry(item, &chain->filter_chain_list, list)
+		RCU_INIT_POINTER(*item->p_filter_chain, NULL);
 	while ((tp = rtnl_dereference(chain->filter_chain)) != NULL) {
 		RCU_INIT_POINTER(chain->filter_chain, tp->next);
 		tcf_chain_put(chain);
@@ -233,11 +240,41 @@ void tcf_chain_put(struct tcf_chain *chain)
 }
 EXPORT_SYMBOL(tcf_chain_put);
 
+static int
+tcf_chain_filter_chain_ptr_add(struct tcf_chain *chain,
+			       struct tcf_proto __rcu **p_filter_chain)
+{
+	struct tfc_filter_chain_list_item *item;
+
+	item = kmalloc(sizeof(*item), GFP_KERNEL);
+	if (!item)
+		return -ENOMEM;
+	item->p_filter_chain = p_filter_chain;
+	list_add(&item->list, &chain->filter_chain_list);
+	return 0;
+}
+
 static void
-tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
+tcf_chain_filter_chain_ptr_del(struct tcf_chain *chain,
 			       struct tcf_proto __rcu **p_filter_chain)
 {
-	chain->p_filter_chain = p_filter_chain;
+	struct tfc_filter_chain_list_item *item;
+
+	list_for_each_entry(item, &chain->filter_chain_list, list) {
+		if (!p_filter_chain ||
+		    item->p_filter_chain == p_filter_chain) {
+			RCU_INIT_POINTER(*item->p_filter_chain, NULL);
+			list_del(&item->list);
+			kfree(item);
+			return;
+		}
+	}
+	WARN_ON(1);
+}
+
+static struct tcf_chain *tcf_block_chain_zero(struct tcf_block *block)
+{
+	return list_first_entry(&block->chain_list, struct tcf_chain, list);
 }
 
 int tcf_block_get(struct tcf_block **p_block,
@@ -256,7 +293,8 @@ int tcf_block_get(struct tcf_block **p_block,
 		err = -ENOMEM;
 		goto err_chain_create;
 	}
-	tcf_chain_filter_chain_ptr_set(chain, p_filter_chain);
+	tcf_chain_filter_chain_ptr_add(chain, p_filter_chain);
+	block->net = qdisc_net(q);
 	block->q = q;
 	*p_block = block;
 	return 0;
@@ -274,6 +312,8 @@ void tcf_block_put(struct tcf_block *block)
 	if (!block)
 		return;
 
+	tcf_chain_filter_chain_ptr_del(tcf_block_chain_zero(block), NULL);
+
 	/* XXX: Standalone actions are not allowed to jump to any chain, and
 	 * bound actions should be all removed after flushing. However,
 	 * filters are destroyed in RCU callbacks, we have to hold the chains
@@ -371,9 +411,13 @@ static void tcf_chain_tp_insert(struct tcf_chain *chain,
 				struct tcf_chain_info *chain_info,
 				struct tcf_proto *tp)
 {
-	if (chain->p_filter_chain &&
-	    *chain_info->pprev == chain->filter_chain)
-		rcu_assign_pointer(*chain->p_filter_chain, tp);
+	if (*chain_info->pprev == chain->filter_chain) {
+		struct tfc_filter_chain_list_item *item;
+
+		list_for_each_entry(item, &chain->filter_chain_list, list)
+			rcu_assign_pointer(*item->p_filter_chain, tp);
+	}
+
 	RCU_INIT_POINTER(tp->next, tcf_chain_tp_prev(chain_info));
 	rcu_assign_pointer(*chain_info->pprev, tp);
 	tcf_chain_hold(chain);
@@ -385,8 +429,12 @@ static void tcf_chain_tp_remove(struct tcf_chain *chain,
 {
 	struct tcf_proto *next = rtnl_dereference(chain_info->next);
 
-	if (chain->p_filter_chain && tp == chain->filter_chain)
-		RCU_INIT_POINTER(*chain->p_filter_chain, next);
+	if (tp == chain->filter_chain) {
+		struct tfc_filter_chain_list_item *item;
+
+		list_for_each_entry(item, &chain->filter_chain_list, list)
+			RCU_INIT_POINTER(*item->p_filter_chain, next);
+	}
 	RCU_INIT_POINTER(*chain_info->pprev, next);
 	tcf_chain_put(chain);
 }
-- 
2.9.5
