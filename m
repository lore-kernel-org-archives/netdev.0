From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 09/15] net_sched: remove RCU callbacks in u32 filter
Date: Mon, 23 Oct 2017 15:02:58 -0700
Message-ID: <20171023220304.2268-10-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:46471 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdJWWDn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:43 -0400
Received: by mail-pf0-f195.google.com with SMTP id p87so18103511pfj.3
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:42 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu().

Note, u32_clear_hnode() is very special here, because
it deletes all elements from a hashtable, we definitely
don't want to wait for each element, however we can
unpublish the whole hashtable from upper layer first,
so that after one grace period, the whole hashtable is
safe to remove too.

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_u32.c | 64 ++++++++++++++---------------------------------------
 1 file changed, 17 insertions(+), 47 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 10b8d851fc6b..393c0aead78a 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -68,7 +68,6 @@ struct tc_u_knode {
 	u32 __percpu		*pcpu_success;
 #endif
 	struct tcf_proto	*tp;
-	struct rcu_head		rcu;
 	/* The 'sel' field MUST be the last field in structure to allow for
 	 * tc_u32_keys allocated at end of structure.
 	 */
@@ -82,7 +81,6 @@ struct tc_u_hnode {
 	struct tc_u_common	*tp_c;
 	int			refcnt;
 	unsigned int		divisor;
-	struct rcu_head		rcu;
 	/* The 'ht' field MUST be the last field in structure to allow for
 	 * more entries allocated at end of structure.
 	 */
@@ -95,7 +93,6 @@ struct tc_u_common {
 	int			refcnt;
 	u32			hgenerator;
 	struct hlist_node	hnode;
-	struct rcu_head		rcu;
 };
 
 static inline unsigned int u32_hash_fold(__be32 key,
@@ -410,35 +407,6 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n,
 	return 0;
 }
 
-/* u32_delete_key_rcu should be called when free'ing a copied
- * version of a tc_u_knode obtained from u32_init_knode(). When
- * copies are obtained from u32_init_knode() the statistics are
- * shared between the old and new copies to allow readers to
- * continue to update the statistics during the copy. To support
- * this the u32_delete_key_rcu variant does not free the percpu
- * statistics.
- */
-static void u32_delete_key_rcu(struct rcu_head *rcu)
-{
-	struct tc_u_knode *key = container_of(rcu, struct tc_u_knode, rcu);
-
-	u32_destroy_key(key->tp, key, false);
-}
-
-/* u32_delete_key_freepf_rcu is the rcu callback variant
- * that free's the entire structure including the statistics
- * percpu variables. Only use this if the key is not a copy
- * returned by u32_init_knode(). See u32_delete_key_rcu()
- * for the variant that should be used with keys return from
- * u32_init_knode()
- */
-static void u32_delete_key_freepf_rcu(struct rcu_head *rcu)
-{
-	struct tc_u_knode *key = container_of(rcu, struct tc_u_knode, rcu);
-
-	u32_destroy_key(key->tp, key, true);
-}
-
 static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 {
 	struct tc_u_knode __rcu **kp;
@@ -453,7 +421,8 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 				RCU_INIT_POINTER(*kp, key->next);
 
 				tcf_unbind_filter(tp, &key->res);
-				call_rcu(&key->rcu, u32_delete_key_freepf_rcu);
+				synchronize_rcu();
+				u32_destroy_key(key->tp, key, true);
 				return 0;
 			}
 		}
@@ -565,7 +534,7 @@ static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 					 rtnl_dereference(n->next));
 			tcf_unbind_filter(tp, &n->res);
 			u32_remove_hw_knode(tp, n->handle);
-			call_rcu(&n->rcu, u32_delete_key_freepf_rcu);
+			u32_destroy_key(n->tp, n, true);
 		}
 	}
 }
@@ -578,8 +547,6 @@ static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 
 	WARN_ON(ht->refcnt);
 
-	u32_clear_hnode(tp, ht);
-
 	hn = &tp_c->hlist;
 	for (phn = rtnl_dereference(*hn);
 	     phn;
@@ -587,7 +554,10 @@ static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 		if (phn == ht) {
 			u32_clear_hw_hnode(tp, ht);
 			RCU_INIT_POINTER(*hn, ht->next);
-			kfree_rcu(ht, rcu);
+			synchronize_rcu();
+
+			u32_clear_hnode(tp, ht);
+			kfree(ht);
 			return 0;
 		}
 	}
@@ -617,20 +587,19 @@ static void u32_destroy(struct tcf_proto *tp)
 		u32_destroy_hnode(tp, root_ht);
 
 	if (--tp_c->refcnt == 0) {
-		struct tc_u_hnode *ht;
+		struct tc_u_hnode *ht, *tmp;
 
 		hlist_del(&tp_c->hnode);
 
-		for (ht = rtnl_dereference(tp_c->hlist);
-		     ht;
-		     ht = rtnl_dereference(ht->next)) {
+		tmp = rtnl_dereference(tp_c->hlist);
+		RCU_INIT_POINTER(tp_c->hlist, NULL);
+		synchronize_rcu();
+
+		while ((ht = tmp) != NULL) {
+			tmp = rtnl_dereference(ht->next);
 			ht->refcnt--;
 			u32_clear_hnode(tp, ht);
-		}
-
-		while ((ht = rtnl_dereference(tp_c->hlist)) != NULL) {
-			RCU_INIT_POINTER(tp_c->hlist, ht->next);
-			kfree_rcu(ht, rcu);
+			kfree(ht);
 		}
 
 		kfree(tp_c);
@@ -926,7 +895,8 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 		u32_replace_knode(tp, tp_c, new);
 		tcf_unbind_filter(tp, &n->res);
-		call_rcu(&n->rcu, u32_delete_key_rcu);
+		synchronize_rcu();
+		u32_destroy_key(n->tp, n, false);
 		return 0;
 	}
 
-- 
2.13.0
