From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/29: netns ebtables: part 1
Date: Thu, 27 Nov 2008 17:15:08 +0100 (MET)
Message-ID: <20081127161508.13891.87491.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53357 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbYK0QPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:15:09 -0500
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 511061e2dd1b84bb21bb97c9216a19606c29ac02
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Tue Nov 4 14:22:55 2008 +0100

    netfilter: netns ebtables: part 1
    
    * propagate netns from userspace, register table in passed netns
    * remporarily register every ebt_table in init_net
    
    P. S.: one needs to add ".netns_ok = 1" to igmp_protocol to test with
    ebtables(8) in netns.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index d45e29c..624e788 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -300,7 +300,7 @@ struct ebt_table
 
 #define EBT_ALIGN(s) (((s) + (__alignof__(struct ebt_replace)-1)) & \
 		     ~(__alignof__(struct ebt_replace)-1))
-extern int ebt_register_table(struct ebt_table *table);
+extern int ebt_register_table(struct net *net, struct ebt_table *table);
 extern void ebt_unregister_table(struct ebt_table *table);
 extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
    const struct net_device *in, const struct net_device *out,
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index 246626b..1731ce8 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -66,7 +66,7 @@ static int __init ebtable_broute_init(void)
 {
 	int ret;
 
-	ret = ebt_register_table(&broute_table);
+	ret = ebt_register_table(&init_net, &broute_table);
 	if (ret < 0)
 		return ret;
 	/* see br_input.c */
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 1a58af5..af8953c 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -95,7 +95,7 @@ static int __init ebtable_filter_init(void)
 {
 	int ret;
 
-	ret = ebt_register_table(&frame_filter);
+	ret = ebt_register_table(&init_net, &frame_filter);
 	if (ret < 0)
 		return ret;
 	ret = nf_register_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index f60c1e7..bafe160 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -102,7 +102,7 @@ static int __init ebtable_nat_init(void)
 {
 	int ret;
 
-	ret = ebt_register_table(&frame_nat);
+	ret = ebt_register_table(&init_net, &frame_nat);
 	if (ret < 0)
 		return ret;
 	ret = nf_register_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 0fa208e..c1a82b2 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -55,7 +55,6 @@
 
 
 static DEFINE_MUTEX(ebt_mutex);
-static LIST_HEAD(ebt_tables);
 
 static struct xt_target ebt_standard_target = {
 	.name       = "standard",
@@ -315,9 +314,11 @@ find_inlist_lock(struct list_head *head, const char *name, const char *prefix,
 }
 
 static inline struct ebt_table *
-find_table_lock(const char *name, int *error, struct mutex *mutex)
+find_table_lock(struct net *net, const char *name, int *error,
+		struct mutex *mutex)
 {
-	return find_inlist_lock(&ebt_tables, name, "ebtable_", error, mutex);
+	return find_inlist_lock(&net->xt.tables[NFPROTO_BRIDGE], name,
+				"ebtable_", error, mutex);
 }
 
 static inline int
@@ -944,7 +945,7 @@ static void get_counters(struct ebt_counter *oldcounters,
 }
 
 /* replace the table */
-static int do_replace(void __user *user, unsigned int len)
+static int do_replace(struct net *net, void __user *user, unsigned int len)
 {
 	int ret, i, countersize;
 	struct ebt_table_info *newinfo;
@@ -1016,7 +1017,7 @@ static int do_replace(void __user *user, unsigned int len)
 	if (ret != 0)
 		goto free_counterstmp;
 
-	t = find_table_lock(tmp.name, &ret, &ebt_mutex);
+	t = find_table_lock(net, tmp.name, &ret, &ebt_mutex);
 	if (!t) {
 		ret = -ENOENT;
 		goto free_iterate;
@@ -1097,7 +1098,7 @@ free_newinfo:
 	return ret;
 }
 
-int ebt_register_table(struct ebt_table *table)
+int ebt_register_table(struct net *net, struct ebt_table *table)
 {
 	struct ebt_table_info *newinfo;
 	struct ebt_table *t;
@@ -1157,7 +1158,7 @@ int ebt_register_table(struct ebt_table *table)
 	if (ret != 0)
 		goto free_chainstack;
 
-	list_for_each_entry(t, &ebt_tables, list) {
+	list_for_each_entry(t, &net->xt.tables[NFPROTO_BRIDGE], list) {
 		if (strcmp(t->name, table->name) == 0) {
 			ret = -EEXIST;
 			BUGPRINT("Table name already exists\n");
@@ -1170,7 +1171,7 @@ int ebt_register_table(struct ebt_table *table)
 		ret = -ENOENT;
 		goto free_unlock;
 	}
-	list_add(&table->list, &ebt_tables);
+	list_add(&table->list, &net->xt.tables[NFPROTO_BRIDGE]);
 	mutex_unlock(&ebt_mutex);
 	return 0;
 free_unlock:
@@ -1208,7 +1209,7 @@ void ebt_unregister_table(struct ebt_table *table)
 }
 
 /* userspace just supplied us with counters */
-static int update_counters(void __user *user, unsigned int len)
+static int update_counters(struct net *net, void __user *user, unsigned int len)
 {
 	int i, ret;
 	struct ebt_counter *tmp;
@@ -1228,7 +1229,7 @@ static int update_counters(void __user *user, unsigned int len)
 		return -ENOMEM;
 	}
 
-	t = find_table_lock(hlp.name, &ret, &ebt_mutex);
+	t = find_table_lock(net, hlp.name, &ret, &ebt_mutex);
 	if (!t)
 		goto free_tmp;
 
@@ -1386,10 +1387,10 @@ static int do_ebt_set_ctl(struct sock *sk,
 
 	switch(cmd) {
 	case EBT_SO_SET_ENTRIES:
-		ret = do_replace(user, len);
+		ret = do_replace(sock_net(sk), user, len);
 		break;
 	case EBT_SO_SET_COUNTERS:
-		ret = update_counters(user, len);
+		ret = update_counters(sock_net(sk), user, len);
 		break;
 	default:
 		ret = -EINVAL;
@@ -1406,7 +1407,7 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	if (copy_from_user(&tmp, user, sizeof(tmp)))
 		return -EFAULT;
 
-	t = find_table_lock(tmp.name, &ret, &ebt_mutex);
+	t = find_table_lock(sock_net(sk), tmp.name, &ret, &ebt_mutex);
 	if (!t)
 		return ret;
 
