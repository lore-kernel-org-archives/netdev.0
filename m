From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 2/2] net: sched: cls_u32 changes to knode must
 appear atomic to readers
Date: Fri, 19 Sep 2014 21:50:34 -0700
Message-ID: <20140920045031.9869.76112.stgit@nitbit.x32>
References: <20140920045003.9869.16851.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:36988 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754430AbaITEu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 00:50:56 -0400
Received: by mail-ob0-f180.google.com with SMTP id wn1so2054588obc.11
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 21:50:56 -0700 (PDT)
In-Reply-To: <20140920045003.9869.16851.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to the cls_u32 classifier must appear atomic to the
readers. Before this patch if a change is requested for both
the exts and ifindex, first the ifindex is updated then the
exts with tcf_exts_change(). This opens a small window where
a reader can have a exts chain with an incorrect ifindex. This
violates the the RCU semantics.

Here we resolve this by always passing u32_set_parms() a copy
of the tc_u_knode to work on and then inserting it into the hash
table after the updates have been successfully applied.

Tested with the following short script:


#tc filter add dev p3p2 parent 8001:0 protocol ip prio 99 handle 1: \
	       u32 divisor 256

#tc filter add dev p3p2 parent 8001:0 protocol ip prio 99 \
	       u32 link 1: hashkey mask ffffff00 at 12    \
	       match ip src 192.168.8.0/2

#tc filter add dev p3p2 parent 8001:0 protocol ip prio 102    \
	       handle 1::10 u32 classid 1:2 ht 1: 	      \
	       match ip src 192.168.8.0/8 match ip tos 0x0a 1e

#tc filter change dev p3p2 parent 8001:0 protocol ip prio 102 \
		 handle 1::10 u32 classid 1:2 ht 1:        \
		 match ip src 1.1.0.0/8 match ip tos 0x0b 1e

CC: Eric Dumazet <edumazet@google.com>
CC: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_u32.c |  135 ++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 126 insertions(+), 9 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 8d90e50..e3fb530 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -354,27 +354,53 @@ static int u32_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
+static int u32_destroy_key(struct tcf_proto *tp,
+			   struct tc_u_knode *n,
+			   bool free_pf)
 {
 	tcf_unbind_filter(tp, &n->res);
 	tcf_exts_destroy(tp, &n->exts);
 	if (n->ht_down)
 		n->ht_down->refcnt--;
 #ifdef CONFIG_CLS_U32_PERF
-	free_percpu(n->pf);
+	if (free_pf)
+		free_percpu(n->pf);
 #endif
 #ifdef CONFIG_CLS_U32_MARK
-	free_percpu(n->pcpu_success);
+	if (free_pf)
+		free_percpu(n->pcpu_success);
 #endif
 	kfree(n);
 	return 0;
 }
 
+/* u32_delete_key_rcu should be called when free'ing a copied
+ * version of a tc_u_knode obtained from u32_init_knode(). When
+ * copies are obtained from u32_init_knode() the statistics are
+ * shared between the old and new copies to allow readers to
+ * continue to update the statistics during the copy. To support
+ * this the u32_delete_key_rcu variant does not free the percpu
+ * statistics.
+ */
 static void u32_delete_key_rcu(struct rcu_head *rcu)
 {
 	struct tc_u_knode *key = container_of(rcu, struct tc_u_knode, rcu);
 
-	u32_destroy_key(key->tp, key);
+	u32_destroy_key(key->tp, key, false);
+}
+
+/* u32_delete_key_freepf_rcu is the rcu callback variant
+ * that free's the entire structure including the statistics
+ * percpu variables. Only use this if the key is not a copy
+ * returned by u32_init_knode(). See u32_delete_key_rcu()
+ * for the variant that should be used with keys return from
+ * u32_init_knode()
+ */
+static void u32_delete_key_freepf_rcu(struct rcu_head *rcu)
+{
+	struct tc_u_knode *key = container_of(rcu, struct tc_u_knode, rcu);
+
+	u32_destroy_key(key->tp, key, true);
 }
 
 static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
@@ -390,7 +416,7 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 			if (pkp == key) {
 				RCU_INIT_POINTER(*kp, key->next);
 
-				call_rcu(&key->rcu, u32_delete_key_rcu);
+				call_rcu(&key->rcu, u32_delete_key_freepf_rcu);
 				return 0;
 			}
 		}
@@ -408,7 +434,7 @@ static void u32_clear_hnode(struct tc_u_hnode *ht)
 		while ((n = rtnl_dereference(ht->ht[h])) != NULL) {
 			RCU_INIT_POINTER(ht->ht[h],
 					 rtnl_dereference(n->next));
-			call_rcu(&n->rcu, u32_delete_key_rcu);
+			call_rcu(&n->rcu, u32_delete_key_freepf_rcu);
 		}
 	}
 }
@@ -584,6 +610,82 @@ errout:
 	return err;
 }
 
+static void u32_replace_knode(struct tcf_proto *tp,
+			      struct tc_u_common *tp_c,
+			      struct tc_u_knode *n)
+{
+	struct tc_u_knode __rcu **ins;
+	struct tc_u_knode *pins;
+	struct tc_u_hnode *ht;
+
+	if (TC_U32_HTID(n->handle) == TC_U32_ROOT)
+		ht = rtnl_dereference(tp->root);
+	else
+		ht = u32_lookup_ht(tp_c, TC_U32_HTID(n->handle));
+
+	ins = &ht->ht[TC_U32_HASH(n->handle)];
+
+	/* The node must always exist for it to be replaced if this is not the
+	 * case then something went very wrong elsewhere.
+	 */
+	for (pins = rtnl_dereference(*ins); ;
+	     ins = &pins->next, pins = rtnl_dereference(*ins))
+		if (pins->handle == n->handle)
+			break;
+
+	RCU_INIT_POINTER(n->next, pins->next);
+	rcu_assign_pointer(*ins, n);
+}
+
+static struct tc_u_knode *u32_init_knode(struct tcf_proto *tp,
+					 struct tc_u_knode *n)
+{
+	struct tc_u_knode *new;
+	struct tc_u32_sel *s = &n->sel;
+
+	new = kzalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key),
+		      GFP_KERNEL);
+
+	if (!new)
+		return NULL;
+
+	RCU_INIT_POINTER(new->next, n->next);
+	new->handle = n->handle;
+	RCU_INIT_POINTER(new->ht_up, n->ht_up);
+
+#ifdef CONFIG_NET_CLS_IND
+	new->ifindex = n->ifindex;
+#endif
+	new->fshift = n->fshift;
+	new->res = n->res;
+	RCU_INIT_POINTER(new->ht_down, n->ht_down);
+
+	/* bump reference count as long as we hold pointer to structure */
+	if (new->ht_down)
+		new->ht_down->refcnt++;
+
+#ifdef CONFIG_CLS_U32_PERF
+	/* Statistics may be incremented by readers during update
+	 * so we must keep them in tact. When the node is later destroyed
+	 * a special destroy call must be made to not free the pf memory.
+	 */
+	new->pf = n->pf;
+#endif
+
+#ifdef CONFIG_CLS_U32_MARK
+	new->val = n->val;
+	new->mask = n->mask;
+	/* Similarly success statistics must be moved as pointers */
+	new->pcpu_success = n->pcpu_success;
+#endif
+	new->tp = tp;
+	memcpy(&new->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
+
+	tcf_exts_init(&new->exts, TCA_U32_ACT, TCA_U32_POLICE);
+
+	return new;
+}
+
 static int u32_change(struct net *net, struct sk_buff *in_skb,
 		      struct tcf_proto *tp, unsigned long base, u32 handle,
 		      struct nlattr **tca,
@@ -610,12 +712,27 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 	n = (struct tc_u_knode *)*arg;
 	if (n) {
+		struct tc_u_knode *new;
+
 		if (TC_U32_KEY(n->handle) == 0)
 			return -EINVAL;
 
-		return u32_set_parms(net, tp, base,
-				     rtnl_dereference(n->ht_up), n, tb,
-				     tca[TCA_RATE], ovr);
+		new = u32_init_knode(tp, n);
+		if (!new)
+			return -ENOMEM;
+
+		err = u32_set_parms(net, tp, base,
+				    rtnl_dereference(n->ht_up), new, tb,
+				    tca[TCA_RATE], ovr);
+
+		if (err) {
+			u32_destroy_key(tp, new, false);
+			return err;
+		}
+
+		u32_replace_knode(tp, tp_c, new);
+		call_rcu(&n->rcu, u32_delete_key_rcu);
+		return 0;
 	}
 
 	if (tb[TCA_U32_DIVISOR]) {
