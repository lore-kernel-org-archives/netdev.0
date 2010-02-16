From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 16/62: xt_recent: netns support
Date: Tue, 16 Feb 2010 15:55:41 +0100 (MET)
Message-ID: <20100216145539.2796.44846.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51989 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756315Ab0BPOzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:43 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 7d07d5632b672c892a65882c2a119345fd9596c9
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Mon Jan 18 08:31:00 2010 +0100

    netfilter: xt_recent: netns support
    
    Make recent table list per-netns.
    Make proc files per-netns.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 768d01f..2033331 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -28,6 +28,7 @@
 #include <linux/skbuff.h>
 #include <linux/inet.h>
 #include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_recent.h>
@@ -78,15 +79,26 @@ struct recent_table {
 	struct list_head	iphash[0];
 };
 
-static LIST_HEAD(tables);
+struct recent_net {
+	struct list_head	tables;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry	*xt_recent;
+#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
+	struct proc_dir_entry	*ipt_recent;
+#endif
+#endif
+};
+
+static int recent_net_id;
+static inline struct recent_net *recent_pernet(struct net *net)
+{
+	return net_generic(net, recent_net_id);
+}
+
 static DEFINE_SPINLOCK(recent_lock);
 static DEFINE_MUTEX(recent_mutex);
 
 #ifdef CONFIG_PROC_FS
-#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-static struct proc_dir_entry *proc_old_dir;
-#endif
-static struct proc_dir_entry *recent_proc_dir;
 static const struct file_operations recent_old_fops, recent_mt_fops;
 #endif
 
@@ -172,11 +184,12 @@ static void recent_entry_update(struct recent_table *t, struct recent_entry *e)
 	list_move_tail(&e->lru_list, &t->lru_list);
 }
 
-static struct recent_table *recent_table_lookup(const char *name)
+static struct recent_table *recent_table_lookup(struct recent_net *recent_net,
+						const char *name)
 {
 	struct recent_table *t;
 
-	list_for_each_entry(t, &tables, list)
+	list_for_each_entry(t, &recent_net->tables, list)
 		if (!strcmp(t->name, name))
 			return t;
 	return NULL;
@@ -195,6 +208,8 @@ static void recent_table_flush(struct recent_table *t)
 static bool
 recent_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
+	struct net *net = dev_net(par->in ? par->in : par->out);
+	struct recent_net *recent_net = recent_pernet(net);
 	const struct xt_recent_mtinfo *info = par->matchinfo;
 	struct recent_table *t;
 	struct recent_entry *e;
@@ -227,7 +242,7 @@ recent_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 		ttl++;
 
 	spin_lock_bh(&recent_lock);
-	t = recent_table_lookup(info->name);
+	t = recent_table_lookup(recent_net, info->name);
 	e = recent_entry_lookup(t, &addr, par->match->family,
 				(info->check_set & XT_RECENT_TTL) ? ttl : 0);
 	if (e == NULL) {
@@ -271,6 +286,7 @@ out:
 
 static bool recent_mt_check(const struct xt_mtchk_param *par)
 {
+	struct recent_net *recent_net = recent_pernet(par->net);
 	const struct xt_recent_mtinfo *info = par->matchinfo;
 	struct recent_table *t;
 #ifdef CONFIG_PROC_FS
@@ -297,7 +313,7 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 		return false;
 
 	mutex_lock(&recent_mutex);
-	t = recent_table_lookup(info->name);
+	t = recent_table_lookup(recent_net, info->name);
 	if (t != NULL) {
 		t->refcnt++;
 		ret = true;
@@ -314,7 +330,7 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 	for (i = 0; i < ip_list_hash_size; i++)
 		INIT_LIST_HEAD(&t->iphash[i]);
 #ifdef CONFIG_PROC_FS
-	pde = proc_create_data(t->name, ip_list_perms, recent_proc_dir,
+	pde = proc_create_data(t->name, ip_list_perms, recent_net->xt_recent,
 		  &recent_mt_fops, t);
 	if (pde == NULL) {
 		kfree(t);
@@ -323,10 +339,10 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 	pde->uid = ip_list_uid;
 	pde->gid = ip_list_gid;
 #ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-	pde = proc_create_data(t->name, ip_list_perms, proc_old_dir,
+	pde = proc_create_data(t->name, ip_list_perms, recent_net->ipt_recent,
 		      &recent_old_fops, t);
 	if (pde == NULL) {
-		remove_proc_entry(t->name, proc_old_dir);
+		remove_proc_entry(t->name, recent_net->xt_recent);
 		kfree(t);
 		goto out;
 	}
@@ -335,7 +351,7 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 #endif
 #endif
 	spin_lock_bh(&recent_lock);
-	list_add_tail(&t->list, &tables);
+	list_add_tail(&t->list, &recent_net->tables);
 	spin_unlock_bh(&recent_lock);
 	ret = true;
 out:
@@ -345,20 +361,21 @@ out:
 
 static void recent_mt_destroy(const struct xt_mtdtor_param *par)
 {
+	struct recent_net *recent_net = recent_pernet(par->net);
 	const struct xt_recent_mtinfo *info = par->matchinfo;
 	struct recent_table *t;
 
 	mutex_lock(&recent_mutex);
-	t = recent_table_lookup(info->name);
+	t = recent_table_lookup(recent_net, info->name);
 	if (--t->refcnt == 0) {
 		spin_lock_bh(&recent_lock);
 		list_del(&t->list);
 		spin_unlock_bh(&recent_lock);
 #ifdef CONFIG_PROC_FS
 #ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-		remove_proc_entry(t->name, proc_old_dir);
+		remove_proc_entry(t->name, recent_net->ipt_recent);
 #endif
-		remove_proc_entry(t->name, recent_proc_dir);
+		remove_proc_entry(t->name, recent_net->xt_recent);
 #endif
 		recent_table_flush(t);
 		kfree(t);
@@ -607,8 +624,65 @@ static const struct file_operations recent_mt_fops = {
 	.release = seq_release_private,
 	.owner   = THIS_MODULE,
 };
+
+static int __net_init recent_proc_net_init(struct net *net)
+{
+	struct recent_net *recent_net = recent_pernet(net);
+
+	recent_net->xt_recent = proc_mkdir("xt_recent", net->proc_net);
+	if (!recent_net->xt_recent)
+		return -ENOMEM;
+#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
+	recent_net->ipt_recent = proc_mkdir("ipt_recent", net->proc_net);
+	if (!recent_net->ipt_recent) {
+		proc_net_remove(net, "xt_recent");
+		return -ENOMEM;
+	}
+#endif
+	return 0;
+}
+
+static void __net_exit recent_proc_net_exit(struct net *net)
+{
+#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
+	proc_net_remove(net, "ipt_recent");
+#endif
+	proc_net_remove(net, "xt_recent");
+}
+#else
+static inline int recent_proc_net_init(struct net *net)
+{
+	return 0;
+}
+
+static inline void recent_proc_net_exit(struct net *net)
+{
+}
 #endif /* CONFIG_PROC_FS */
 
+static int __net_init recent_net_init(struct net *net)
+{
+	struct recent_net *recent_net = recent_pernet(net);
+
+	INIT_LIST_HEAD(&recent_net->tables);
+	return recent_proc_net_init(net);
+}
+
+static void __net_exit recent_net_exit(struct net *net)
+{
+	struct recent_net *recent_net = recent_pernet(net);
+
+	BUG_ON(!list_empty(&recent_net->tables));
+	recent_proc_net_exit(net);
+}
+
+static struct pernet_operations recent_net_ops = {
+	.init	= recent_net_init,
+	.exit	= recent_net_exit,
+	.id	= &recent_net_id,
+	.size	= sizeof(struct recent_net),
+};
+
 static struct xt_match recent_mt_reg[] __read_mostly = {
 	{
 		.name       = "recent",
@@ -640,39 +714,19 @@ static int __init recent_mt_init(void)
 		return -EINVAL;
 	ip_list_hash_size = 1 << fls(ip_list_tot);
 
-	err = xt_register_matches(recent_mt_reg, ARRAY_SIZE(recent_mt_reg));
-#ifdef CONFIG_PROC_FS
+	err = register_pernet_subsys(&recent_net_ops);
 	if (err)
 		return err;
-	recent_proc_dir = proc_mkdir("xt_recent", init_net.proc_net);
-	if (recent_proc_dir == NULL) {
-		xt_unregister_matches(recent_mt_reg, ARRAY_SIZE(recent_mt_reg));
-		err = -ENOMEM;
-	}
-#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-	if (err < 0)
-		return err;
-	proc_old_dir = proc_mkdir("ipt_recent", init_net.proc_net);
-	if (proc_old_dir == NULL) {
-		remove_proc_entry("xt_recent", init_net.proc_net);
-		xt_unregister_matches(recent_mt_reg, ARRAY_SIZE(recent_mt_reg));
-		err = -ENOMEM;
-	}
-#endif
-#endif
+	err = xt_register_matches(recent_mt_reg, ARRAY_SIZE(recent_mt_reg));
+	if (err)
+		unregister_pernet_subsys(&recent_net_ops);
 	return err;
 }
 
 static void __exit recent_mt_exit(void)
 {
-	BUG_ON(!list_empty(&tables));
 	xt_unregister_matches(recent_mt_reg, ARRAY_SIZE(recent_mt_reg));
-#ifdef CONFIG_PROC_FS
-#ifdef CONFIG_NETFILTER_XT_MATCH_RECENT_PROC_COMPAT
-	remove_proc_entry("ipt_recent", init_net.proc_net);
-#endif
-	remove_proc_entry("xt_recent", init_net.proc_net);
-#endif
+	unregister_pernet_subsys(&recent_net_ops);
 }
 
 module_init(recent_mt_init);
