From: Artem Savkov <asavkov@redhat.com>
Subject: [PATCH v3] ebtables: fix race condition in frame_filter_net_init()
Date: Tue, 26 Sep 2017 18:35:45 +0200
Message-ID: <20170926163545.3668-1-asavkov@redhat.com>
References: <20170926153923.30094-1-asavkov@redhat.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Artem Savkov <asavkov@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926153923.30094-1-asavkov@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is possible for ebt_in_hook to be triggered before ebt_table is assigned
resulting in a NULL-pointer dereference. Make sure hooks are
registered as the last step.

v3: restore errorneously removed ops == NULL case check

Fixes: aee12a0a3727 ebtables: remove nf_hook_register usage
Signed-off-by: Artem Savkov <asavkov@redhat.com>
---
 include/linux/netfilter_bridge/ebtables.h |  7 ++++---
 net/bridge/netfilter/ebtable_broute.c     |  4 ++--
 net/bridge/netfilter/ebtable_filter.c     |  4 ++--
 net/bridge/netfilter/ebtable_nat.c        |  4 ++--
 net/bridge/netfilter/ebtables.c           | 17 +++++++++--------
 5 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 2c2a5514b0df..528b24c78308 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -108,9 +108,10 @@ struct ebt_table {
 
 #define EBT_ALIGN(s) (((s) + (__alignof__(struct _xt_align)-1)) & \
 		     ~(__alignof__(struct _xt_align)-1))
-extern struct ebt_table *ebt_register_table(struct net *net,
-					    const struct ebt_table *table,
-					    const struct nf_hook_ops *);
+extern int ebt_register_table(struct net *net,
+			      const struct ebt_table *table,
+			      const struct nf_hook_ops *ops,
+			      struct ebt_table **res);
 extern void ebt_unregister_table(struct net *net, struct ebt_table *table,
 				 const struct nf_hook_ops *);
 extern unsigned int ebt_do_table(struct sk_buff *skb,
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index 2585b100ebbb..276b60262981 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -65,8 +65,8 @@ static int ebt_broute(struct sk_buff *skb)
 
 static int __net_init broute_net_init(struct net *net)
 {
-	net->xt.broute_table = ebt_register_table(net, &broute_table, NULL);
-	return PTR_ERR_OR_ZERO(net->xt.broute_table);
+	return ebt_register_table(net, &broute_table, NULL,
+				  &net->xt.broute_table);
 }
 
 static void __net_exit broute_net_exit(struct net *net)
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 45a00dbdbcad..c41da5fac84f 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -93,8 +93,8 @@ static const struct nf_hook_ops ebt_ops_filter[] = {
 
 static int __net_init frame_filter_net_init(struct net *net)
 {
-	net->xt.frame_filter = ebt_register_table(net, &frame_filter, ebt_ops_filter);
-	return PTR_ERR_OR_ZERO(net->xt.frame_filter);
+	return ebt_register_table(net, &frame_filter, ebt_ops_filter,
+				  &net->xt.frame_filter);
 }
 
 static void __net_exit frame_filter_net_exit(struct net *net)
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 57cd5bb154e7..08df7406ecb3 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -93,8 +93,8 @@ static const struct nf_hook_ops ebt_ops_nat[] = {
 
 static int __net_init frame_nat_net_init(struct net *net)
 {
-	net->xt.frame_nat = ebt_register_table(net, &frame_nat, ebt_ops_nat);
-	return PTR_ERR_OR_ZERO(net->xt.frame_nat);
+	return ebt_register_table(net, &frame_nat, ebt_ops_nat,
+				  &net->xt.frame_nat);
 }
 
 static void __net_exit frame_nat_net_exit(struct net *net)
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 83951f978445..3b3dcf719e07 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1169,9 +1169,8 @@ static void __ebt_unregister_table(struct net *net, struct ebt_table *table)
 	kfree(table);
 }
 
-struct ebt_table *
-ebt_register_table(struct net *net, const struct ebt_table *input_table,
-		   const struct nf_hook_ops *ops)
+int ebt_register_table(struct net *net, const struct ebt_table *input_table,
+		       const struct nf_hook_ops *ops, struct ebt_table **res)
 {
 	struct ebt_table_info *newinfo;
 	struct ebt_table *t, *table;
@@ -1183,7 +1182,7 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table,
 	    repl->entries == NULL || repl->entries_size == 0 ||
 	    repl->counters != NULL || input_table->private != NULL) {
 		BUGPRINT("Bad table data for ebt_register_table!!!\n");
-		return ERR_PTR(-EINVAL);
+		return -EINVAL;
 	}
 
 	/* Don't add one table to multiple lists. */
@@ -1252,16 +1251,18 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table,
 	list_add(&table->list, &net->xt.tables[NFPROTO_BRIDGE]);
 	mutex_unlock(&ebt_mutex);
 
+	WRITE_ONCE(*res, table);
+
 	if (!ops)
-		return table;
+		return 0;
 
 	ret = nf_register_net_hooks(net, ops, hweight32(table->valid_hooks));
 	if (ret) {
 		__ebt_unregister_table(net, table);
-		return ERR_PTR(ret);
+		*res = NULL;
 	}
 
-	return table;
+	return ret;
 free_unlock:
 	mutex_unlock(&ebt_mutex);
 free_chainstack:
@@ -1276,7 +1277,7 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table,
 free_table:
 	kfree(table);
 out:
-	return ERR_PTR(ret);
+	return ret;
 }
 
 void ebt_unregister_table(struct net *net, struct ebt_table *table,
-- 
2.13.5
