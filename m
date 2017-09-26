From: Artem Savkov <asavkov@redhat.com>
Subject: [PATCH] ebtables: fix race condition in frame_filter_net_init()
Date: Tue, 26 Sep 2017 14:29:38 +0200
Message-ID: <20170926122938.11603-1-asavkov@redhat.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Artem Savkov <asavkov@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is possible for ebt_in_hook to be triggered before ebt_table is assigned
resulting in a NULL-pointer dereference. Make sure hooks are
registered as the last step.

Fixes: aee12a0a3727 ebtables: remove nf_hook_register usage
Signed-off-by: Artem Savkov <asavkov@redhat.com>
---
 include/linux/netfilter_bridge/ebtables.h |  5 +++--
 net/bridge/netfilter/ebtable_broute.c     |  2 +-
 net/bridge/netfilter/ebtable_filter.c     |  8 ++++++--
 net/bridge/netfilter/ebtable_nat.c        |  8 ++++++--
 net/bridge/netfilter/ebtables.c           | 24 +++++++++++++-----------
 5 files changed, 29 insertions(+), 18 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 2c2a5514b0df..7d68f5ba6ded 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -109,8 +109,9 @@ struct ebt_table {
 #define EBT_ALIGN(s) (((s) + (__alignof__(struct _xt_align)-1)) & \
 		     ~(__alignof__(struct _xt_align)-1))
 extern struct ebt_table *ebt_register_table(struct net *net,
-					    const struct ebt_table *table,
-					    const struct nf_hook_ops *);
+					    const struct ebt_table *table);
+extern int ebt_register_hooks(struct net *net, struct ebt_table *table,
+				 const struct nf_hook_ops *ops);
 extern void ebt_unregister_table(struct net *net, struct ebt_table *table,
 				 const struct nf_hook_ops *);
 extern unsigned int ebt_do_table(struct sk_buff *skb,
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index 2585b100ebbb..b41017409aa5 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -65,7 +65,7 @@ static int ebt_broute(struct sk_buff *skb)
 
 static int __net_init broute_net_init(struct net *net)
 {
-	net->xt.broute_table = ebt_register_table(net, &broute_table, NULL);
+	net->xt.broute_table = ebt_register_table(net, &broute_table);
 	return PTR_ERR_OR_ZERO(net->xt.broute_table);
 }
 
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 45a00dbdbcad..ca04582b374e 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -93,8 +93,12 @@ static const struct nf_hook_ops ebt_ops_filter[] = {
 
 static int __net_init frame_filter_net_init(struct net *net)
 {
-	net->xt.frame_filter = ebt_register_table(net, &frame_filter, ebt_ops_filter);
-	return PTR_ERR_OR_ZERO(net->xt.frame_filter);
+	net->xt.frame_filter = ebt_register_table(net, &frame_filter);
+
+	if (IS_ERR(net->xt.frame_filter))
+		return PTR_ERR(net->xt.frame_filter);
+
+	return ebt_register_hooks(net, net->xt.frame_filter, ebt_ops_filter);
 }
 
 static void __net_exit frame_filter_net_exit(struct net *net)
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 57cd5bb154e7..f4a2ff93be34 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -93,8 +93,12 @@ static const struct nf_hook_ops ebt_ops_nat[] = {
 
 static int __net_init frame_nat_net_init(struct net *net)
 {
-	net->xt.frame_nat = ebt_register_table(net, &frame_nat, ebt_ops_nat);
-	return PTR_ERR_OR_ZERO(net->xt.frame_nat);
+	net->xt.frame_nat = ebt_register_table(net, &frame_nat);
+
+	if (IS_ERR(net->xt.frame_nat))
+		return PTR_ERR(net->xt.frame_nat);
+
+	return ebt_register_hooks(net, net->xt.frame_nat, ebt_ops_nat);
 }
 
 static void __net_exit frame_nat_net_exit(struct net *net)
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 83951f978445..e72120ac426e 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1169,9 +1169,19 @@ static void __ebt_unregister_table(struct net *net, struct ebt_table *table)
 	kfree(table);
 }
 
+int ebt_register_hooks(struct net *net, struct ebt_table *table,
+		      const struct nf_hook_ops *ops)
+{
+	int ret = nf_register_net_hooks(net, ops, hweight32(table->valid_hooks));
+
+	if (ret)
+		__ebt_unregister_table(net, table);
+
+	return ret;
+}
+
 struct ebt_table *
-ebt_register_table(struct net *net, const struct ebt_table *input_table,
-		   const struct nf_hook_ops *ops)
+ebt_register_table(struct net *net, const struct ebt_table *input_table)
 {
 	struct ebt_table_info *newinfo;
 	struct ebt_table *t, *table;
@@ -1252,15 +1262,6 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table,
 	list_add(&table->list, &net->xt.tables[NFPROTO_BRIDGE]);
 	mutex_unlock(&ebt_mutex);
 
-	if (!ops)
-		return table;
-
-	ret = nf_register_net_hooks(net, ops, hweight32(table->valid_hooks));
-	if (ret) {
-		__ebt_unregister_table(net, table);
-		return ERR_PTR(ret);
-	}
-
 	return table;
 free_unlock:
 	mutex_unlock(&ebt_mutex);
@@ -2456,6 +2457,7 @@ static void __exit ebtables_fini(void)
 	printk(KERN_INFO "Ebtables v2.0 unregistered\n");
 }
 
+EXPORT_SYMBOL(ebt_register_hooks);
 EXPORT_SYMBOL(ebt_register_table);
 EXPORT_SYMBOL(ebt_unregister_table);
 EXPORT_SYMBOL(ebt_do_table);
-- 
2.13.5
