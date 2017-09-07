From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v2 2/2] net_sched: fix all the madness of tc filter chain
Date: Wed,  6 Sep 2017 21:26:07 -0700
Message-ID: <20170907042607.24413-2-xiyou.wangcong@gmail.com>
References: <20170907042607.24413-1-xiyou.wangcong@gmail.com>
Cc: jakub.kicinski@netronome.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:38719 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753374AbdIGE0S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 00:26:18 -0400
Received: by mail-pf0-f194.google.com with SMTP id q76so3986514pfq.5
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 21:26:18 -0700 (PDT)
In-Reply-To: <20170907042607.24413-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following madness of tc filter chain:

1) tcf_chain_destroy() is called by both tcf_block_put() and
   tcf_chain_put().  tcf_chain_put() is correctly refcnt'ed and paired
   with tcf_chain_get(), but tcf_block_put() is not, it should be paired
   with tcf_block_get() which means we still need to decrease the refcnt.
   Think it in another way: if we call tcf_bock_put() immediately after
   tcf_block_get(), could we get effectively a nop? This causes a memory
   leak as reported by Jakub.

2) tp proto should hold a refcnt to the chain too. This significantly
   simplifies the logic:

2a) Chain 0 is no longer special, it is created and refcnted by tp
    like any other chains. All the ugliness in tcf_chain_put() can be
    gone!

2b) No need to handle the flushing oddly, because block still holds
    chain 0, it can not be released, this guarantees block is the last
    user.

2c) The race condition with RCU callbacks is easier to handle with just
    a rcu_barrier()! Much easier to understand, nothing to hide! Thanks
    to the previous patch. Please see also the comments in code.

2d) Make the code understandable by humans, much less error-prone.

Fixes: 744a4cf63e52 ("net: sched: fix use after free when tcf_chain_destroy is called multiple times")
Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
Reported-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Cc: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_api.c | 38 ++++++++++++++++++++++----------------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 6c5ea84d2682..e9060dc36519 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -209,21 +209,20 @@ static void tcf_chain_flush(struct tcf_chain *chain)
 		RCU_INIT_POINTER(*chain->p_filter_chain, NULL);
 	while ((tp = rtnl_dereference(chain->filter_chain)) != NULL) {
 		RCU_INIT_POINTER(chain->filter_chain, tp->next);
+		tcf_chain_put(chain);
 		tcf_proto_destroy(tp);
 	}
 }
 
 static void tcf_chain_destroy(struct tcf_chain *chain)
 {
-	/* May be already removed from the list by the previous call. */
-	if (!list_empty(&chain->list))
-		list_del_init(&chain->list);
+	list_del(&chain->list);
+	kfree(chain);
+}
 
-	/* There might still be a reference held when we got here from
-	 * tcf_block_put. Wait for the user to drop reference before free.
-	 */
-	if (!chain->refcnt)
-		kfree(chain);
+static void tcf_chain_hold(struct tcf_chain *chain)
+{
+	++chain->refcnt;
 }
 
 struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
@@ -233,7 +232,7 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 
 	list_for_each_entry(chain, &block->chain_list, list) {
 		if (chain->index == chain_index) {
-			chain->refcnt++;
+			tcf_chain_hold(chain);
 			return chain;
 		}
 	}
@@ -246,10 +245,7 @@ EXPORT_SYMBOL(tcf_chain_get);
 
 void tcf_chain_put(struct tcf_chain *chain)
 {
-	/* Destroy unused chain, with exception of chain 0, which is the
-	 * default one and has to be always present.
-	 */
-	if (--chain->refcnt == 0 && !chain->filter_chain && chain->index != 0)
+	if (--chain->refcnt == 0)
 		tcf_chain_destroy(chain);
 }
 EXPORT_SYMBOL(tcf_chain_put);
@@ -294,10 +290,18 @@ void tcf_block_put(struct tcf_block *block)
 	if (!block)
 		return;
 
-	list_for_each_entry_safe(chain, tmp, &block->chain_list, list) {
+	/* Standalone actions are not allowed to jump to any chain, and
+	 * bound actions should be all removed after flushing. However,
+	 * filters are destroyed in RCU callbacks, we have to flush and wait
+	 * for them before releasing this refcnt, otherwise we race with RCU
+	 * callbacks!!!
+	 */
+	list_for_each_entry(chain, &block->chain_list, list)
 		tcf_chain_flush(chain);
-		tcf_chain_destroy(chain);
-	}
+	rcu_barrier();
+
+	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
+		tcf_chain_put(chain);
 	kfree(block);
 }
 EXPORT_SYMBOL(tcf_block_put);
@@ -375,6 +379,7 @@ static void tcf_chain_tp_insert(struct tcf_chain *chain,
 		rcu_assign_pointer(*chain->p_filter_chain, tp);
 	RCU_INIT_POINTER(tp->next, tcf_chain_tp_prev(chain_info));
 	rcu_assign_pointer(*chain_info->pprev, tp);
+	tcf_chain_hold(chain);
 }
 
 static void tcf_chain_tp_remove(struct tcf_chain *chain,
@@ -386,6 +391,7 @@ static void tcf_chain_tp_remove(struct tcf_chain *chain,
 	if (chain->p_filter_chain && tp == chain->filter_chain)
 		RCU_INIT_POINTER(*chain->p_filter_chain, next);
 	RCU_INIT_POINTER(*chain_info->pprev, next);
+	tcf_chain_put(chain);
 }
 
 static struct tcf_proto *tcf_chain_tp_find(struct tcf_chain *chain,
-- 
2.13.0
