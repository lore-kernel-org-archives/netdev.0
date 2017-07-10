From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 1/4] net: sched: introduce support for multiple filter chain pointers registration
Date: Mon, 10 Jul 2017 20:51:07 +0200
Message-ID: <20170710185110.3180-2-jiri@resnulli.us>
References: <20170710185110.3180-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, stephen@networkplumber.org, jbenc@redhat.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        john.fastabend@gmail.com, alexander.h.duyck@intel.com,
        daniel@iogearbox.net, ogerlitz@mellanox.com, mrv@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35021 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754620AbdGJSvQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 14:51:16 -0400
Received: by mail-wr0-f196.google.com with SMTP id z45so27004788wrb.2
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 11:51:15 -0700 (PDT)
In-Reply-To: <20170710185110.3180-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

So far, there was possible only to register a single filter chain
pointer to a block->chain[0]. However, when the blocks will get
shareable, we need to allow multiple filter chain pointers registration.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/sch_generic.h |  2 +-
 net/sched/cls_api.c       | 66 ++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 57 insertions(+), 11 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1c123e2..7396de8 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -257,7 +257,7 @@ struct qdisc_skb_cb {
 
 struct tcf_chain {
 	struct tcf_proto __rcu *filter_chain;
-	struct tcf_proto __rcu **p_filter_chain;
+	struct list_head filter_chain_list;
 	struct list_head list;
 	struct tcf_block *block;
 	u32 index; /* chain index */
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 39da0c5..411f5577 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -186,6 +186,11 @@ static void tcf_proto_destroy(struct tcf_proto *tp)
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
@@ -194,6 +199,7 @@ static struct tcf_chain *tcf_chain_create(struct tcf_block *block,
 	chain = kzalloc(sizeof(*chain), GFP_KERNEL);
 	if (!chain)
 		return NULL;
+	INIT_LIST_HEAD(&chain->filter_chain_list);
 	list_add_tail(&chain->list, &block->chain_list);
 	chain->block = block;
 	chain->index = chain_index;
@@ -203,10 +209,11 @@ static struct tcf_chain *tcf_chain_create(struct tcf_block *block,
 
 static void tcf_chain_flush(struct tcf_chain *chain)
 {
+	struct tfc_filter_chain_list_item *item;
 	struct tcf_proto *tp;
 
-	if (*chain->p_filter_chain)
-		RCU_INIT_POINTER(*chain->p_filter_chain, NULL);
+	list_for_each_entry(item, &chain->filter_chain_list, list)
+		RCU_INIT_POINTER(*item->p_filter_chain, NULL);
 	while ((tp = rtnl_dereference(chain->filter_chain)) != NULL) {
 		RCU_INIT_POINTER(chain->filter_chain, tp->next);
 		tcf_proto_destroy(tp);
@@ -248,11 +255,40 @@ void tcf_chain_put(struct tcf_chain *chain)
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
@@ -271,7 +307,7 @@ int tcf_block_get(struct tcf_block **p_block,
 		err = -ENOMEM;
 		goto err_chain_create;
 	}
-	tcf_chain_filter_chain_ptr_set(chain, p_filter_chain);
+	tcf_chain_filter_chain_ptr_add(chain, p_filter_chain);
 	*p_block = block;
 	return 0;
 
@@ -288,6 +324,8 @@ void tcf_block_put(struct tcf_block *block)
 	if (!block)
 		return;
 
+	tcf_chain_filter_chain_ptr_del(tcf_block_chain_zero(block), NULL);
+
 	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
 		tcf_chain_destroy(chain);
 	kfree(block);
@@ -362,9 +400,13 @@ static void tcf_chain_tp_insert(struct tcf_chain *chain,
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
 }
@@ -375,8 +417,12 @@ static void tcf_chain_tp_remove(struct tcf_chain *chain,
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
 }
 
-- 
2.9.3
