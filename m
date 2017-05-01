From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 39/53] ebtables: remove nf_hook_register usage
Date: Mon,  1 May 2017 12:47:06 +0200
Message-ID: <1493635640-24325-40-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49632 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S378972AbdEAKsu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 06:48:50 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F2BDE210578
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:00 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E3909FF2D8
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:48:00 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A1210FF2CF
        for <netdev@vger.kernel.org>; Mon,  1 May 2017 12:47:58 +0200 (CEST)
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Similar to ip_register_table, pass nf_hook_ops to ebt_register_table().
This allows to handle hook registration also via pernet_ops and allows
us to avoid use of legacy register_hook api.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge/ebtables.h |  6 ++-
 net/bridge/netfilter/ebtable_broute.c     |  4 +-
 net/bridge/netfilter/ebtable_filter.c     | 15 ++------
 net/bridge/netfilter/ebtable_nat.c        | 15 ++------
 net/bridge/netfilter/ebtables.c           | 61 +++++++++++++++++++------------
 5 files changed, 50 insertions(+), 51 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 984b2112c77b..a30efb437e6d 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -109,8 +109,10 @@ struct ebt_table {
 #define EBT_ALIGN(s) (((s) + (__alignof__(struct _xt_align)-1)) & \
 		     ~(__alignof__(struct _xt_align)-1))
 extern struct ebt_table *ebt_register_table(struct net *net,
-					    const struct ebt_table *table);
-extern void ebt_unregister_table(struct net *net, struct ebt_table *table);
+					    const struct ebt_table *table,
+					    const struct nf_hook_ops *);
+extern void ebt_unregister_table(struct net *net, struct ebt_table *table,
+				 const struct nf_hook_ops *);
 extern unsigned int ebt_do_table(struct sk_buff *skb,
 				 const struct nf_hook_state *state,
 				 struct ebt_table *table);
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index 8fe36dc3aab2..2585b100ebbb 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -65,13 +65,13 @@ static int ebt_broute(struct sk_buff *skb)
 
 static int __net_init broute_net_init(struct net *net)
 {
-	net->xt.broute_table = ebt_register_table(net, &broute_table);
+	net->xt.broute_table = ebt_register_table(net, &broute_table, NULL);
 	return PTR_ERR_OR_ZERO(net->xt.broute_table);
 }
 
 static void __net_exit broute_net_exit(struct net *net)
 {
-	ebt_unregister_table(net, net->xt.broute_table);
+	ebt_unregister_table(net, net->xt.broute_table, NULL);
 }
 
 static struct pernet_operations broute_net_ops = {
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 593a1bdc079e..f22ef7c21913 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -93,13 +93,13 @@ static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
 
 static int __net_init frame_filter_net_init(struct net *net)
 {
-	net->xt.frame_filter = ebt_register_table(net, &frame_filter);
+	net->xt.frame_filter = ebt_register_table(net, &frame_filter, ebt_ops_filter);
 	return PTR_ERR_OR_ZERO(net->xt.frame_filter);
 }
 
 static void __net_exit frame_filter_net_exit(struct net *net)
 {
-	ebt_unregister_table(net, net->xt.frame_filter);
+	ebt_unregister_table(net, net->xt.frame_filter, ebt_ops_filter);
 }
 
 static struct pernet_operations frame_filter_net_ops = {
@@ -109,20 +109,11 @@ static struct pernet_operations frame_filter_net_ops = {
 
 static int __init ebtable_filter_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&frame_filter_net_ops);
-	if (ret < 0)
-		return ret;
-	ret = nf_register_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
-	if (ret < 0)
-		unregister_pernet_subsys(&frame_filter_net_ops);
-	return ret;
+	return register_pernet_subsys(&frame_filter_net_ops);
 }
 
 static void __exit ebtable_filter_fini(void)
 {
-	nf_unregister_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
 	unregister_pernet_subsys(&frame_filter_net_ops);
 }
 
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index eb33919821ee..2f7a4f314406 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -93,13 +93,13 @@ static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
 
 static int __net_init frame_nat_net_init(struct net *net)
 {
-	net->xt.frame_nat = ebt_register_table(net, &frame_nat);
+	net->xt.frame_nat = ebt_register_table(net, &frame_nat, ebt_ops_nat);
 	return PTR_ERR_OR_ZERO(net->xt.frame_nat);
 }
 
 static void __net_exit frame_nat_net_exit(struct net *net)
 {
-	ebt_unregister_table(net, net->xt.frame_nat);
+	ebt_unregister_table(net, net->xt.frame_nat, ebt_ops_nat);
 }
 
 static struct pernet_operations frame_nat_net_ops = {
@@ -109,20 +109,11 @@ static struct pernet_operations frame_nat_net_ops = {
 
 static int __init ebtable_nat_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&frame_nat_net_ops);
-	if (ret < 0)
-		return ret;
-	ret = nf_register_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
-	if (ret < 0)
-		unregister_pernet_subsys(&frame_nat_net_ops);
-	return ret;
+	return register_pernet_subsys(&frame_nat_net_ops);
 }
 
 static void __exit ebtable_nat_fini(void)
 {
-	nf_unregister_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
 	unregister_pernet_subsys(&frame_nat_net_ops);
 }
 
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index bdc629eb0207..9ec0c9f908fa 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1157,8 +1157,30 @@ static int do_replace(struct net *net, const void __user *user,
 	return ret;
 }
 
+static void __ebt_unregister_table(struct net *net, struct ebt_table *table)
+{
+	int i;
+
+	mutex_lock(&ebt_mutex);
+	list_del(&table->list);
+	mutex_unlock(&ebt_mutex);
+	EBT_ENTRY_ITERATE(table->private->entries, table->private->entries_size,
+			  ebt_cleanup_entry, net, NULL);
+	if (table->private->nentries)
+		module_put(table->me);
+	vfree(table->private->entries);
+	if (table->private->chainstack) {
+		for_each_possible_cpu(i)
+			vfree(table->private->chainstack[i]);
+		vfree(table->private->chainstack);
+	}
+	vfree(table->private);
+	kfree(table);
+}
+
 struct ebt_table *
-ebt_register_table(struct net *net, const struct ebt_table *input_table)
+ebt_register_table(struct net *net, const struct ebt_table *input_table,
+		   const struct nf_hook_ops *ops)
 {
 	struct ebt_table_info *newinfo;
 	struct ebt_table *t, *table;
@@ -1238,6 +1260,16 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table)
 	}
 	list_add(&table->list, &net->xt.tables[NFPROTO_BRIDGE]);
 	mutex_unlock(&ebt_mutex);
+
+	if (!ops)
+		return table;
+
+	ret = nf_register_net_hooks(net, ops, hweight32(table->valid_hooks));
+	if (ret) {
+		__ebt_unregister_table(net, table);
+		return ERR_PTR(ret);
+	}
+
 	return table;
 free_unlock:
 	mutex_unlock(&ebt_mutex);
@@ -1256,29 +1288,12 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table)
 	return ERR_PTR(ret);
 }
 
-void ebt_unregister_table(struct net *net, struct ebt_table *table)
+void ebt_unregister_table(struct net *net, struct ebt_table *table,
+			  const struct nf_hook_ops *ops)
 {
-	int i;
-
-	if (!table) {
-		BUGPRINT("Request to unregister NULL table!!!\n");
-		return;
-	}
-	mutex_lock(&ebt_mutex);
-	list_del(&table->list);
-	mutex_unlock(&ebt_mutex);
-	EBT_ENTRY_ITERATE(table->private->entries, table->private->entries_size,
-			  ebt_cleanup_entry, net, NULL);
-	if (table->private->nentries)
-		module_put(table->me);
-	vfree(table->private->entries);
-	if (table->private->chainstack) {
-		for_each_possible_cpu(i)
-			vfree(table->private->chainstack[i]);
-		vfree(table->private->chainstack);
-	}
-	vfree(table->private);
-	kfree(table);
+	if (ops)
+		nf_unregister_net_hooks(net, ops, hweight32(table->valid_hooks));
+	__ebt_unregister_table(net, table);
 }
 
 /* userspace just supplied us with counters */
-- 
2.1.4
