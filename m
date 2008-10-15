From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/7] netns ebtables: part 1
Date: Wed, 15 Oct 2008 08:20:14 +0400
Message-ID: <20081015042014.GE24058@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@osdl.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One needs to add ".netns_ok = 1" to igmp_protocol to test all of this
with ebtables() in netns.
-------------------------------------------------
[PATCH 1/7] netns ebtables: part 1

* make list of ebt_tables per-netns
* propagate netns from userspace, register table in passed netns
* temporarily register every ebt_table in init_net

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netfilter_bridge/ebtables.h |    2 -
 include/net/netns/x_tables.h              |    1 
 net/bridge/netfilter/ebtable_broute.c     |    2 -
 net/bridge/netfilter/ebtable_filter.c     |    2 -
 net/bridge/netfilter/ebtable_nat.c        |    2 -
 net/bridge/netfilter/ebtables.c           |   54 ++++++++++++++++++++----------
 6 files changed, 41 insertions(+), 22 deletions(-)

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
--- a/include/net/netns/x_tables.h
+++ b/include/net/netns/x_tables.h
@@ -6,5 +6,6 @@
 
 struct netns_xt {
 	struct list_head tables[NPROTO];
+	struct list_head ebt_tables;
 };
 #endif
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
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -55,7 +55,6 @@
 
 
 static DEFINE_MUTEX(ebt_mutex);
-static LIST_HEAD(ebt_tables);
 
 static struct xt_target ebt_standard_target = {
 	.name       = "standard",
@@ -324,9 +323,9 @@ find_inlist_lock(struct list_head *head, const char *name, const char *prefix,
 #endif
 
 static inline struct ebt_table *
-find_table_lock(const char *name, int *error, struct mutex *mutex)
+find_table_lock(struct net *net, const char *name, int *error, struct mutex *mutex)
 {
-	return find_inlist_lock(&ebt_tables, name, "ebtable_", error, mutex);
+	return find_inlist_lock(&net->xt.ebt_tables, name, "ebtable_", error, mutex);
 }
 
 static inline int
@@ -953,7 +952,7 @@ static void get_counters(struct ebt_counter *oldcounters,
 }
 
 /* replace the table */
-static int do_replace(void __user *user, unsigned int len)
+static int do_replace(struct net *net, void __user *user, unsigned int len)
 {
 	int ret, i, countersize;
 	struct ebt_table_info *newinfo;
@@ -1025,7 +1024,7 @@ static int do_replace(void __user *user, unsigned int len)
 	if (ret != 0)
 		goto free_counterstmp;
 
-	t = find_table_lock(tmp.name, &ret, &ebt_mutex);
+	t = find_table_lock(net, tmp.name, &ret, &ebt_mutex);
 	if (!t) {
 		ret = -ENOENT;
 		goto free_iterate;
@@ -1106,7 +1105,7 @@ free_newinfo:
 	return ret;
 }
 
-int ebt_register_table(struct ebt_table *table)
+int ebt_register_table(struct net *net, struct ebt_table *table)
 {
 	struct ebt_table_info *newinfo;
 	struct ebt_table *t;
@@ -1166,7 +1165,7 @@ int ebt_register_table(struct ebt_table *table)
 	if (ret != 0)
 		goto free_chainstack;
 
-	list_for_each_entry(t, &ebt_tables, list) {
+	list_for_each_entry(t, &net->xt.ebt_tables, list) {
 		if (strcmp(t->name, table->name) == 0) {
 			ret = -EEXIST;
 			BUGPRINT("Table name already exists\n");
@@ -1179,7 +1178,7 @@ int ebt_register_table(struct ebt_table *table)
 		ret = -ENOENT;
 		goto free_unlock;
 	}
-	list_add(&table->list, &ebt_tables);
+	list_add(&table->list, &net->xt.ebt_tables);
 	mutex_unlock(&ebt_mutex);
 	return 0;
 free_unlock:
@@ -1217,7 +1216,7 @@ void ebt_unregister_table(struct ebt_table *table)
 }
 
 /* userspace just supplied us with counters */
-static int update_counters(void __user *user, unsigned int len)
+static int update_counters(struct net *net, void __user *user, unsigned int len)
 {
 	int i, ret;
 	struct ebt_counter *tmp;
@@ -1237,7 +1236,7 @@ static int update_counters(void __user *user, unsigned int len)
 		return -ENOMEM;
 	}
 
-	t = find_table_lock(hlp.name, &ret, &ebt_mutex);
+	t = find_table_lock(net, hlp.name, &ret, &ebt_mutex);
 	if (!t)
 		goto free_tmp;
 
@@ -1395,10 +1394,10 @@ static int do_ebt_set_ctl(struct sock *sk,
 
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
@@ -1415,7 +1414,7 @@ static int do_ebt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	if (copy_from_user(&tmp, user, sizeof(tmp)))
 		return -EFAULT;
 
-	t = find_table_lock(tmp.name, &ret, &ebt_mutex);
+	t = find_table_lock(sock_net(sk), tmp.name, &ret, &ebt_mutex);
 	if (!t)
 		return ret;
 
@@ -1471,27 +1470,46 @@ static struct nf_sockopt_ops ebt_sockopts =
 	.owner		= THIS_MODULE,
 };
 
+static int __net_init ebtables_net_init(struct net *net)
+{
+	INIT_LIST_HEAD(&net->xt.ebt_tables);
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
 
+	ret = register_pernet_subsys(&ebtables_net_ops);
+	if (ret < 0)
+		goto out_net;
 	ret = xt_register_target(&ebt_standard_target);
 	if (ret < 0)
-		return ret;
+		goto out_target;
 	ret = nf_register_sockopt(&ebt_sockopts);
-	if (ret < 0) {
-		xt_unregister_target(&ebt_standard_target);
-		return ret;
-	}
+	if (ret < 0)
+		goto out_sockopt;
 
 	printk(KERN_INFO "Ebtables v2.0 registered\n");
 	return 0;
+
+out_sockopt:
+	xt_unregister_target(&ebt_standard_target);
+out_target:
+	unregister_pernet_subsys(&ebtables_net_ops);
+out_net:
+	return ret;
 }
 
 static void __exit ebtables_fini(void)
 {
 	nf_unregister_sockopt(&ebt_sockopts);
 	xt_unregister_target(&ebt_standard_target);
+	unregister_pernet_subsys(&ebtables_net_ops);
 	printk(KERN_INFO "Ebtables v2.0 unregistered\n");
 }
 
