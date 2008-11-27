From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 05/29: netns ebtables: part 2
Date: Thu, 27 Nov 2008 17:15:09 +0100 (MET)
Message-ID: <20081127161509.13891.18728.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53360 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbYK0QPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:15:10 -0500
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 6beceee5aa2cb94c4ae9f0784c7d3135d343f5b5
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Tue Nov 4 14:27:15 2008 +0100

    netfilter: netns ebtables: part 2
    
    * return ebt_table from ebt_register_table(), module code will save it into
      per-netns data for unregistration
    * duplicate ebt_table at the very beginning of registration -- it's added into
      list, so one ebt_table wouldn't end up in many lists (and each netns has
      different one)
    * introduce underscored tables in individial modules, this is temporary to not
      break bisection.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 624e788..e40ddb9 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -300,7 +300,8 @@ struct ebt_table
 
 #define EBT_ALIGN(s) (((s) + (__alignof__(struct ebt_replace)-1)) & \
 		     ~(__alignof__(struct ebt_replace)-1))
-extern int ebt_register_table(struct net *net, struct ebt_table *table);
+extern struct ebt_table *ebt_register_table(struct net *net,
+					    struct ebt_table *table);
 extern void ebt_unregister_table(struct ebt_table *table);
 extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
    const struct net_device *in, const struct net_device *out,
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index 1731ce8..3277d68 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -41,22 +41,23 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table broute_table =
+static struct ebt_table __broute_table =
 {
 	.name		= "broute",
 	.table		= &initial_table,
 	.valid_hooks	= 1 << NF_BR_BROUTING,
-	.lock		= __RW_LOCK_UNLOCKED(broute_table.lock),
+	.lock		= __RW_LOCK_UNLOCKED(__broute_table.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
+static struct ebt_table *broute_table;
 
 static int ebt_broute(struct sk_buff *skb)
 {
 	int ret;
 
 	ret = ebt_do_table(NF_BR_BROUTING, skb, skb->dev, NULL,
-	   &broute_table);
+	   broute_table);
 	if (ret == NF_DROP)
 		return 1; /* route it */
 	return 0; /* bridge it */
@@ -64,21 +65,19 @@ static int ebt_broute(struct sk_buff *skb)
 
 static int __init ebtable_broute_init(void)
 {
-	int ret;
-
-	ret = ebt_register_table(&init_net, &broute_table);
-	if (ret < 0)
-		return ret;
+	broute_table = ebt_register_table(&init_net, &__broute_table);
+	if (IS_ERR(broute_table))
+		return PTR_ERR(broute_table);
 	/* see br_input.c */
 	rcu_assign_pointer(br_should_route_hook, ebt_broute);
-	return ret;
+	return 0;
 }
 
 static void __exit ebtable_broute_fini(void)
 {
 	rcu_assign_pointer(br_should_route_hook, NULL);
 	synchronize_net();
-	ebt_unregister_table(&broute_table);
+	ebt_unregister_table(broute_table);
 }
 
 module_init(ebtable_broute_init);
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index af8953c..596564c 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -50,21 +50,22 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table frame_filter =
+static struct ebt_table __frame_filter =
 {
 	.name		= "filter",
 	.table		= &initial_table,
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(frame_filter.lock),
+	.lock		= __RW_LOCK_UNLOCKED(__frame_filter.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
+static struct ebt_table *frame_filter;
 
 static unsigned int
 ebt_hook(unsigned int hook, struct sk_buff *skb, const struct net_device *in,
    const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, &frame_filter);
+	return ebt_do_table(hook, skb, in, out, frame_filter);
 }
 
 static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
@@ -95,19 +96,19 @@ static int __init ebtable_filter_init(void)
 {
 	int ret;
 
-	ret = ebt_register_table(&init_net, &frame_filter);
-	if (ret < 0)
-		return ret;
+	frame_filter = ebt_register_table(&init_net, &__frame_filter);
+	if (IS_ERR(frame_filter))
+		return PTR_ERR(frame_filter);
 	ret = nf_register_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
 	if (ret < 0)
-		ebt_unregister_table(&frame_filter);
+		ebt_unregister_table(frame_filter);
 	return ret;
 }
 
 static void __exit ebtable_filter_fini(void)
 {
 	nf_unregister_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
-	ebt_unregister_table(&frame_filter);
+	ebt_unregister_table(frame_filter);
 }
 
 module_init(ebtable_filter_init);
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index bafe160..0d8fc5b 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -50,28 +50,29 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table frame_nat =
+static struct ebt_table __frame_nat =
 {
 	.name		= "nat",
 	.table		= &initial_table,
 	.valid_hooks	= NAT_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(frame_nat.lock),
+	.lock		= __RW_LOCK_UNLOCKED(__frame_nat.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
+static struct ebt_table *frame_nat;
 
 static unsigned int
 ebt_nat_dst(unsigned int hook, struct sk_buff *skb, const struct net_device *in
    , const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, &frame_nat);
+	return ebt_do_table(hook, skb, in, out, frame_nat);
 }
 
 static unsigned int
 ebt_nat_src(unsigned int hook, struct sk_buff *skb, const struct net_device *in
    , const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, &frame_nat);
+	return ebt_do_table(hook, skb, in, out, frame_nat);
 }
 
 static struct nf_hook_ops ebt_ops_nat[] __read_mostly = {
@@ -102,19 +103,19 @@ static int __init ebtable_nat_init(void)
 {
 	int ret;
 
-	ret = ebt_register_table(&init_net, &frame_nat);
-	if (ret < 0)
-		return ret;
+	frame_nat = ebt_register_table(&init_net, &__frame_nat);
+	if (IS_ERR(frame_nat))
+		return PTR_ERR(frame_nat);
 	ret = nf_register_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
 	if (ret < 0)
-		ebt_unregister_table(&frame_nat);
+		ebt_unregister_table(frame_nat);
 	return ret;
 }
 
 static void __exit ebtable_nat_fini(void)
 {
 	nf_unregister_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
-	ebt_unregister_table(&frame_nat);
+	ebt_unregister_table(frame_nat);
 }
 
 module_init(ebtable_nat_init);
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index c1a82b2..82e1752 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1098,7 +1098,7 @@ free_newinfo:
 	return ret;
 }
 
-int ebt_register_table(struct net *net, struct ebt_table *table)
+struct ebt_table *ebt_register_table(struct net *net, struct ebt_table *table)
 {
 	struct ebt_table_info *newinfo;
 	struct ebt_table *t;
@@ -1110,14 +1110,21 @@ int ebt_register_table(struct net *net, struct ebt_table *table)
 	    repl->entries_size == 0 ||
 	    repl->counters || table->private) {
 		BUGPRINT("Bad table data for ebt_register_table!!!\n");
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
+	}
+
+	/* Don't add one table to multiple lists. */
+	table = kmemdup(table, sizeof(struct ebt_table), GFP_KERNEL);
+	if (!table) {
+		ret = -ENOMEM;
+		goto out;
 	}
 
 	countersize = COUNTER_OFFSET(repl->nentries) * nr_cpu_ids;
 	newinfo = vmalloc(sizeof(*newinfo) + countersize);
 	ret = -ENOMEM;
 	if (!newinfo)
-		return -ENOMEM;
+		goto free_table;
 
 	p = vmalloc(repl->entries_size);
 	if (!p)
@@ -1149,7 +1156,7 @@ int ebt_register_table(struct net *net, struct ebt_table *table)
 
 	if (table->check && table->check(newinfo, table->valid_hooks)) {
 		BUGPRINT("The table doesn't like its own initial data, lol\n");
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 	}
 
 	table->private = newinfo;
@@ -1173,7 +1180,7 @@ int ebt_register_table(struct net *net, struct ebt_table *table)
 	}
 	list_add(&table->list, &net->xt.tables[NFPROTO_BRIDGE]);
 	mutex_unlock(&ebt_mutex);
-	return 0;
+	return table;
 free_unlock:
 	mutex_unlock(&ebt_mutex);
 free_chainstack:
@@ -1185,7 +1192,10 @@ free_chainstack:
 	vfree(newinfo->entries);
 free_newinfo:
 	vfree(newinfo);
-	return ret;
+free_table:
+	kfree(table);
+out:
+	return ERR_PTR(ret);
 }
 
 void ebt_unregister_table(struct ebt_table *table)
@@ -1206,6 +1216,7 @@ void ebt_unregister_table(struct ebt_table *table)
 		vfree(table->private->chainstack);
 	}
 	vfree(table->private);
+	kfree(table);
 }
 
 /* userspace just supplied us with counters */
