From: adobriyan@gmail.com
Subject: [PATCH 1/6] netns brnetfilter: per-netns ebtables
Date: Fri, 22 Aug 2008 02:20:41 +0400
Message-ID: <20080821221943.GO31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, kaber@trash.et
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:41698 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755226AbYHUWTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:19:19 -0400
Received: by mu-out-0910.google.com with SMTP id w8so254531mue.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:19:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* make registered ebtables list per-netns
* for that, duplicate table at the very beginning of register,
  we can't add one table to multiple lists.
* propagate netns from userspace socket down to iterators over list,
* register individual modules only in init_net for a minute.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netfilter_bridge/ebtables.h |    2 
 include/net/net_namespace.h               |    4 +
 include/net/netns/bridge.h                |    9 +++
 net/bridge/netfilter/ebtable_broute.c     |   19 +++-----
 net/bridge/netfilter/ebtable_filter.c     |   17 +++----
 net/bridge/netfilter/ebtable_nat.c        |   19 ++++----
 net/bridge/netfilter/ebtables.c           |   70 +++++++++++++++++++++---------
 7 files changed, 91 insertions(+), 49 deletions(-)

--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -286,7 +286,7 @@ struct ebt_table
 
 #define EBT_ALIGN(s) (((s) + (__alignof__(struct ebt_replace)-1)) & \
 		     ~(__alignof__(struct ebt_replace)-1))
-extern int ebt_register_table(struct ebt_table *table);
+extern struct ebt_table *ebt_register_table(struct net *net, struct ebt_table *table);
 extern void ebt_unregister_table(struct ebt_table *table);
 extern int ebt_register_match(struct ebt_match *match);
 extern void ebt_unregister_match(struct ebt_match *match);
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -19,6 +19,7 @@
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netns/conntrack.h>
 #endif
+#include <net/netns/bridge.h>
 
 struct proc_dir_entry;
 struct net_device;
@@ -73,6 +74,9 @@ struct net {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	struct netns_ct		ct;
 #endif
+#ifdef CONFIG_BRIDGE_NETFILTER
+	struct netns_br		br;
+#endif
 #endif
 	struct net_generic	*gen;
 };
new file mode 100644
--- /dev/null
+++ b/include/net/netns/bridge.h
@@ -0,0 +1,9 @@
+#ifndef __NETNS_BRIDGE_H
+#define __NETNS_BRIDGE_H
+
+#include <linux/list.h>
+
+struct netns_br {
+	struct list_head	ebt_tables;
+};
+#endif
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
-	ret = ebt_register_table(&broute_table);
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
 
-	ret = ebt_register_table(&frame_filter);
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
 
-	ret = ebt_register_table(&frame_nat);
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
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -54,7 +54,6 @@
 
 
 static DEFINE_MUTEX(ebt_mutex);
-static LIST_HEAD(ebt_tables);
 static LIST_HEAD(ebt_targets);
 static LIST_HEAD(ebt_matches);
 static LIST_HEAD(ebt_watchers);
@@ -307,9 +306,9 @@ find_inlist_lock(struct list_head *head, const char *name, const char *prefix,
 #endif
 
 static inline struct ebt_table *
-find_table_lock(const char *name, int *error, struct mutex *mutex)
+find_table_lock(struct net *net, const char *name, int *error, struct mutex *mutex)
 {
-	return find_inlist_lock(&ebt_tables, name, "ebtable_", error, mutex);
+	return find_inlist_lock(&net->br.ebt_tables, name, "ebtable_", error, mutex);
 }
 
 static inline struct ebt_match *
@@ -915,7 +914,7 @@ static void get_counters(struct ebt_counter *oldcounters,
 }
 
 /* replace the table */
-static int do_replace(void __user *user, unsigned int len)
+static int do_replace(struct net *net, void __user *user, unsigned int len)
 {
 	int ret, i, countersize;
 	struct ebt_table_info *newinfo;
@@ -987,7 +986,7 @@ static int do_replace(void __user *user, unsigned int len)
 	if (ret != 0)
 		goto free_counterstmp;
 
-	t = find_table_lock(tmp.name, &ret, &ebt_mutex);
+	t = find_table_lock(net, tmp.name, &ret, &ebt_mutex);
 	if (!t) {
 		ret = -ENOENT;
 		goto free_iterate;
@@ -1149,7 +1148,7 @@ void ebt_unregister_watcher(struct ebt_watcher *watcher)
 	mutex_unlock(&ebt_mutex);
 }
 
-int ebt_register_table(struct ebt_table *table)
+struct ebt_table *ebt_register_table(struct net *net, struct ebt_table *table)
 {
 	struct ebt_table_info *newinfo;
 	struct ebt_table *t;
@@ -1157,18 +1156,27 @@ int ebt_register_table(struct ebt_table *table)
 	int ret, i, countersize;
 	void *p;
 
-	if (!table || !(repl = table->table) || !repl->entries ||
+	table = kmemdup(table, sizeof(struct ebt_table), GFP_KERNEL);
+	if (!table) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	if (!(repl = table->table) || !repl->entries ||
 	    repl->entries_size == 0 ||
 	    repl->counters || table->private) {
 		BUGPRINT("Bad table data for ebt_register_table!!!\n");
-		return -EINVAL;
+		ret = -EINVAL;
+		goto free_table;
 	}
 
 	countersize = COUNTER_OFFSET(repl->nentries) * nr_cpu_ids;
 	newinfo = vmalloc(sizeof(*newinfo) + countersize);
 	ret = -ENOMEM;
-	if (!newinfo)
-		return -ENOMEM;
+	if (!newinfo) {
+		ret = -ENOMEM;
+		goto free_table;
+	}
 
 	p = vmalloc(repl->entries_size);
 	if (!p)
@@ -1200,7 +1208,8 @@ int ebt_register_table(struct ebt_table *table)
 
 	if (table->check && table->check(newinfo, table->valid_hooks)) {
 		BUGPRINT("The table doesn't like its own initial data, lol\n");
-		return -EINVAL;
+		ret = -EINVAL;
+		goto free_table;
 	}
 
 	table->private = newinfo;
@@ -1209,7 +1218,7 @@ int ebt_register_table(struct ebt_table *table)
 	if (ret != 0)
 		goto free_chainstack;
 
-	list_for_each_entry(t, &ebt_tables, list) {
+	list_for_each_entry(t, &net->br.ebt_tables, list) {
 		if (strcmp(t->name, table->name) == 0) {
 			ret = -EEXIST;
 			BUGPRINT("Table name already exists\n");
@@ -1222,9 +1231,9 @@ int ebt_register_table(struct ebt_table *table)
 		ret = -ENOENT;
 		goto free_unlock;
 	}
-	list_add(&table->list, &ebt_tables);
+	list_add(&table->list, &net->br.ebt_tables);
 	mutex_unlock(&ebt_mutex);
-	return 0;
+	return table;
 free_unlock:
 	mutex_unlock(&ebt_mutex);
 free_chainstack:
@@ -1236,7 +1245,10 @@ free_chainstack:
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
@@ -1257,10 +1269,11 @@ void ebt_unregister_table(struct ebt_table *table)
 		vfree(table->private->chainstack);
 	}
 	vfree(table->private);
+	kfree(table);
 }
 
 /* userspace just supplied us with counters */
-static int update_counters(void __user *user, unsigned int len)
+static int update_counters(struct net *net, void __user *user, unsigned int len)
 {
 	int i, ret;
 	struct ebt_counter *tmp;
@@ -1280,7 +1293,7 @@ static int update_counters(void __user *user, unsigned int len)
 		return -ENOMEM;
 	}
 
-	t = find_table_lock(hlp.name, &ret, &ebt_mutex);
+	t = find_table_lock(net, hlp.name, &ret, &ebt_mutex);
 	if (!t)
 		goto free_tmp;
 
@@ -1434,14 +1447,15 @@ static int copy_everything_to_user(struct ebt_table *t, void __user *user,
 static int do_ebt_set_ctl(struct sock *sk,
 	int cmd, void __user *user, unsigned int len)
 {
+	struct net *net = sock_net(sk);
 	int ret;
 
 	switch(cmd) {
 	case EBT_SO_SET_ENTRIES:
-		ret = do_replace(user, len);
+		ret = do_replace(net, user, len);
 		break;
 	case EBT_SO_SET_COUNTERS:
-		ret = update_counters(user, len);
+		ret = update_counters(net, user, len);
 		break;
 	default:
 		ret = -EINVAL;
@@ -1451,6 +1465,7 @@ static int do_ebt_set_ctl(struct sock *sk,
 
 static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 {
+	struct net *net = sock_net(sk);
 	int ret;
 	struct ebt_replace tmp;
 	struct ebt_table *t;
@@ -1458,7 +1473,7 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	if (copy_from_user(&tmp, user, sizeof(tmp)))
 		return -EFAULT;
 
-	t = find_table_lock(tmp.name, &ret, &ebt_mutex);
+	t = find_table_lock(net, tmp.name, &ret, &ebt_mutex);
 	if (!t)
 		return ret;
 
@@ -1514,6 +1529,16 @@ static struct nf_sockopt_ops ebt_sockopts =
 	.owner		= THIS_MODULE,
 };
 
+static int ebtables_net_init(struct net *net)
+{
+	INIT_LIST_HEAD(&net->br.ebt_tables);
+	return 0;
+}
+
+static struct pernet_operations ebtables_net_ops = {
+	.init = ebtables_net_init,
+};
+
 static int __init ebtables_init(void)
 {
 	int ret;
@@ -1523,6 +1548,9 @@ static int __init ebtables_init(void)
 	mutex_unlock(&ebt_mutex);
 	if ((ret = nf_register_sockopt(&ebt_sockopts)) < 0)
 		return ret;
+	ret = register_pernet_subsys(&ebtables_net_ops);
+	if (ret < 0)
+		nf_unregister_sockopt(&ebt_sockopts);
 
 	printk(KERN_INFO "Ebtables v2.0 registered\n");
 	return 0;
@@ -1530,6 +1558,7 @@ static int __init ebtables_init(void)
 
 static void __exit ebtables_fini(void)
 {
+	unregister_pernet_subsys(&ebtables_net_ops);
 	nf_unregister_sockopt(&ebt_sockopts);
 	printk(KERN_INFO "Ebtables v2.0 unregistered\n");
 }
-- 
1.5.6.3


