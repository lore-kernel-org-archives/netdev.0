From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [RFC v2] netfilter: xt_condition: add condition target
Date: Tue, 20 Jul 2010 12:50:34 +0300
Message-ID: <1279619434-11849-1-git-send-email-luciano.coelho@nokia.com>
Cc: netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	sameo@linux.intel.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements a condition target to the xt_condition module,
which let's the user set netfilter rules that enable/disable the
variables used by the condition match.  Originally, the condition
match only allowed the variable to be changed via procfs.  This new
target makes it easy to enable or disable the condition depending on
the rules set.

Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
---
 include/linux/netfilter/xt_condition.h |   12 ++-
 net/netfilter/Kconfig                  |   19 ++--
 net/netfilter/Makefile                 |    2 +-
 net/netfilter/xt_condition.c           |  179 +++++++++++++++++++++++---------
 4 files changed, 153 insertions(+), 59 deletions(-)

diff --git a/include/linux/netfilter/xt_condition.h b/include/linux/netfilter/xt_condition.h
index 4faf3ca..c9e72c2 100644
--- a/include/linux/netfilter/xt_condition.h
+++ b/include/linux/netfilter/xt_condition.h
@@ -3,12 +3,22 @@
 
 #include <linux/types.h>
 
+#define XT_CONDITION_MAX_NAME_SIZE 31
+
 struct xt_condition_mtinfo {
-	char name[31];
+	char name[XT_CONDITION_MAX_NAME_SIZE];
 	__u8 invert;
 
 	/* Used internally by the kernel */
 	void *condvar __attribute__((aligned(8)));
 };
 
+struct condition_tg_info {
+	char name[XT_CONDITION_MAX_NAME_SIZE];
+	__u8 enabled;
+
+	/* Used internally by the kernel */
+	void *condvar __attribute__((aligned(8)));
+};
+
 #endif /* _XT_CONDITION_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index e54e216..adaa3b4 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -310,6 +310,17 @@ config NETFILTER_XT_MARK
 	"Use netfilter MARK value as routing key") and can also be used by
 	other subsystems to change their behavior.
 
+config NETFILTER_XT_CONDITION
+	tristate '"condition" match and target support'
+	depends on NETFILTER_ADVANCED
+	depends on PROC_FS
+	---help---
+	This option adds the "CONDITION" target and "condition" match.
+
+	It allows you to match rules against condition variables
+	stored in the /proc/net/nf_condition directory. It also allows
+	you to set the variables using the target.
+
 config NETFILTER_XT_CONNMARK
 	tristate 'ctmark target and match support'
 	depends on NF_CONNTRACK
@@ -621,14 +632,6 @@ config NETFILTER_XT_MATCH_COMMENT
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
 
-config NETFILTER_XT_MATCH_CONDITION
-	tristate '"condition" match support'
-	depends on NETFILTER_ADVANCED
-	depends on PROC_FS
-	---help---
-	This option allows you to match firewall rules against condition
-	variables stored in the /proc/net/nf_condition directory.
-
 config NETFILTER_XT_MATCH_CONNBYTES
 	tristate  '"connbytes" per-connection counter match support'
 	depends on NF_CONNTRACK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 474dd06..ee34f6c 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -43,6 +43,7 @@ obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
 # combos
 obj-$(CONFIG_NETFILTER_XT_MARK) += xt_mark.o
 obj-$(CONFIG_NETFILTER_XT_CONNMARK) += xt_connmark.o
+obj-$(CONFIG_NETFILTER_XT_CONDITION) += xt_condition.o
 
 # targets
 obj-$(CONFIG_NETFILTER_XT_TARGET_CLASSIFY) += xt_CLASSIFY.o
@@ -66,7 +67,6 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) += xt_IDLETIMER.o
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) += xt_cluster.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
-obj-$(CONFIG_NETFILTER_XT_MATCH_CONDITION) += xt_condition.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) += xt_connbytes.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNLIMIT) += xt_connlimit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNTRACK) += xt_conntrack.o
diff --git a/net/netfilter/xt_condition.c b/net/netfilter/xt_condition.c
index 9af0257..dbd762c 100644
--- a/net/netfilter/xt_condition.c
+++ b/net/netfilter/xt_condition.c
@@ -2,11 +2,13 @@
  *	"condition" match extension for Xtables
  *
  *	Description: This module allows firewall rules to match using
- *	condition variables available through procfs.
+ *	condition variables available through procfs.  It also allows
+ *	target rules to set the condition variable.
  *
  *	Authors:
  *	Stephane Ouellette <ouellettes@videotron.ca>, 2002-10-22
  *	Massimiliano Hofer <max@nucleus.it>, 2006-05-15
+ *	Luciano Coelho <luciano.coelho@nokia.com>, 2010-07-20
  *
  *	This program is free software; you can redistribute it and/or modify it
  *	under the terms of the GNU General Public License; either version 2
@@ -32,7 +34,8 @@ static unsigned int condition_gid_perms;
 MODULE_AUTHOR("Stephane Ouellette <ouellettes@videotron.ca>");
 MODULE_AUTHOR("Massimiliano Hofer <max@nucleus.it>");
 MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
-MODULE_DESCRIPTION("Allows rules to match against condition variables");
+MODULE_AUTHOR("Luciano Coelho <luciano.coelho@nokia.com>");
+MODULE_DESCRIPTION("Allows rules to set and match condition variables");
 MODULE_LICENSE("GPL");
 module_param(condition_list_perms, uint, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(condition_list_perms, "default permissions on /proc/net/nf_condition/* files");
@@ -91,56 +94,34 @@ static int condition_proc_write(struct file *file, const char __user *buffer,
 	return length;
 }
 
-static bool
-condition_mt(const struct sk_buff *skb, struct xt_action_param *par)
+static struct condition_variable *xt_condition_insert(const char *name)
 {
-	const struct xt_condition_mtinfo *info = par->matchinfo;
-	const struct condition_variable *var   = info->condvar;
-
-	return var->enabled ^ info->invert;
-}
-
-static int condition_mt_check(const struct xt_mtchk_param *par)
-{
-	struct xt_condition_mtinfo *info = par->matchinfo;
 	struct condition_variable *var;
 
-	/* Forbid certain names */
-	if (*info->name == '\0' || *info->name == '.' ||
-	    info->name[sizeof(info->name)-1] != '\0' ||
-	    memchr(info->name, '/', sizeof(info->name)) != NULL) {
-		pr_info("name not allowed or too long: \"%.*s\"\n",
-			(unsigned int)sizeof(info->name), info->name);
-		return -EINVAL;
-	}
 	/*
 	 * Let's acquire the lock, check for the condition and add it
 	 * or increase the reference counter.
 	 */
 	mutex_lock(&proc_lock);
 	list_for_each_entry(var, &conditions_list, list) {
-		if (strcmp(info->name, var->status_proc->name) == 0) {
+		if (strcmp(name, var->status_proc->name) == 0) {
 			++var->refcount;
-			mutex_unlock(&proc_lock);
-			info->condvar = var;
-			return 0;
+			goto out;
 		}
 	}
 
 	/* At this point, we need to allocate a new condition variable. */
 	var = kmalloc(sizeof(struct condition_variable), GFP_KERNEL);
-	if (var == NULL) {
-		mutex_unlock(&proc_lock);
-		return -ENOMEM;
-	}
+	if (var == NULL)
+		goto out;
 
 	/* Create the condition variable's proc file entry. */
-	var->status_proc = create_proc_entry(info->name, condition_list_perms,
+	var->status_proc = create_proc_entry(name, condition_list_perms,
 			   proc_net_condition);
 	if (var->status_proc == NULL) {
 		kfree(var);
-		mutex_unlock(&proc_lock);
-		return -ENOMEM;
+		var = NULL;
+		goto out;
 	}
 
 	var->refcount = 1;
@@ -151,16 +132,13 @@ static int condition_mt_check(const struct xt_mtchk_param *par)
 	var->status_proc->uid        = condition_uid_perms;
 	var->status_proc->gid        = condition_gid_perms;
 	list_add(&var->list, &conditions_list);
+out:
 	mutex_unlock(&proc_lock);
-	info->condvar = var;
-	return 0;
+	return var;
 }
 
-static void condition_mt_destroy(const struct xt_mtdtor_param *par)
+static void xt_condition_put(struct condition_variable *var)
 {
-	const struct xt_condition_mtinfo *info = par->matchinfo;
-	struct condition_variable *var = info->condvar;
-
 	mutex_lock(&proc_lock);
 	if (--var->refcount == 0) {
 		list_del(&var->list);
@@ -172,6 +150,101 @@ static void condition_mt_destroy(const struct xt_mtdtor_param *par)
 	mutex_unlock(&proc_lock);
 }
 
+static bool
+condition_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_condition_mtinfo *info = par->matchinfo;
+	const struct condition_variable *var   = info->condvar;
+
+	return var->enabled ^ info->invert;
+}
+
+static int condition_mt_check(const struct xt_mtchk_param *par)
+{
+	struct xt_condition_mtinfo *info = par->matchinfo;
+	struct condition_variable *var;
+
+	/* Forbid certain names */
+	if (*info->name == '\0' || *info->name == '.' ||
+	    info->name[sizeof(info->name)-1] != '\0' ||
+	    memchr(info->name, '/', sizeof(info->name)) != NULL) {
+		pr_info("name not allowed or too long: \"%.*s\"\n",
+			(unsigned int)sizeof(info->name), info->name);
+		return -EINVAL;
+	}
+
+	var = xt_condition_insert(info->name);
+	if (var == NULL)
+		return -ENOMEM;
+
+	info->condvar = var;
+	return 0;
+}
+
+static void condition_mt_destroy(const struct xt_mtdtor_param *par)
+{
+	const struct xt_condition_mtinfo *info = par->matchinfo;
+
+	xt_condition_put(info->condvar);
+}
+
+static unsigned int condition_tg_target(struct sk_buff *skb,
+					 const struct xt_action_param *par)
+{
+	const struct condition_tg_info *info = par->targinfo;
+	struct condition_variable *var = info->condvar;
+
+	pr_debug("setting condition %s, enabled %d\n",
+		 info->name, info->enabled);
+
+	var->enabled = info->enabled;
+
+	return XT_CONTINUE;
+}
+
+static int condition_tg_checkentry(const struct xt_tgchk_param *par)
+{
+	struct condition_tg_info *info = par->targinfo;
+	struct condition_variable *var;
+
+	pr_debug("checkentry %s\n", info->name);
+
+	/* Forbid certain names */
+	if (*info->name == '\0' || *info->name == '.' ||
+	    info->name[sizeof(info->name)-1] != '\0' ||
+	    memchr(info->name, '/', sizeof(info->name)) != NULL) {
+		pr_info("name not allowed or too long: \"%.*s\"\n",
+			(unsigned int)sizeof(info->name), info->name);
+		return -EINVAL;
+	}
+
+	var = xt_condition_insert(info->name);
+	if (var == NULL)
+		return -ENOMEM;
+
+	info->condvar = var;
+	return 0;
+}
+
+static void condition_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	const struct condition_tg_info *info = par->targinfo;
+
+	pr_debug("destroy %s\n", info->name);
+
+	xt_condition_put(info->condvar);
+}
+
+static struct xt_target condition_tg_reg __read_mostly = {
+	.name		= "CONDITION",
+	.family		= NFPROTO_UNSPEC,
+	.target		= condition_tg_target,
+	.targetsize     = sizeof(struct condition_tg_info),
+	.checkentry	= condition_tg_checkentry,
+	.destroy        = condition_tg_destroy,
+	.me		= THIS_MODULE,
+};
+
 static struct xt_match condition_mt_reg __read_mostly = {
 	.name       = "condition",
 	.revision   = 1,
@@ -185,24 +258,24 @@ static struct xt_match condition_mt_reg __read_mostly = {
 
 static const char *const dir_name = "nf_condition";
 
-static int __net_init condnet_mt_init(struct net *net)
+static int __net_init condnet_init(struct net *net)
 {
 	proc_net_condition = proc_mkdir(dir_name, net->proc_net);
 
 	return (proc_net_condition == NULL) ? -EACCES : 0;
 }
 
-static void __net_exit condnet_mt_exit(struct net *net)
+static void __net_exit condnet_exit(struct net *net)
 {
 	remove_proc_entry(dir_name, net->proc_net);
 }
 
-static struct pernet_operations condition_mt_netops = {
-	.init = condnet_mt_init,
-	.exit = condnet_mt_exit,
+static struct pernet_operations condition_netops = {
+	.init = condnet_init,
+	.exit = condnet_exit,
 };
 
-static int __init condition_mt_init(void)
+static int __init condition_init(void)
 {
 	int ret;
 
@@ -211,8 +284,15 @@ static int __init condition_mt_init(void)
 	if (ret < 0)
 		return ret;
 
-	ret = register_pernet_subsys(&condition_mt_netops);
+	ret =  xt_register_target(&condition_tg_reg);
+	if (ret < 0) {
+		xt_unregister_match(&condition_mt_reg);
+		return ret;
+	}
+
+	ret = register_pernet_subsys(&condition_netops);
 	if (ret < 0) {
+		xt_unregister_target(&condition_tg_reg);
 		xt_unregister_match(&condition_mt_reg);
 		return ret;
 	}
@@ -220,11 +300,12 @@ static int __init condition_mt_init(void)
 	return 0;
 }
 
-static void __exit condition_mt_exit(void)
+static void __exit condition_exit(void)
 {
-	unregister_pernet_subsys(&condition_mt_netops);
+	unregister_pernet_subsys(&condition_netops);
+	xt_unregister_target(&condition_tg_reg);
 	xt_unregister_match(&condition_mt_reg);
 }
 
-module_init(condition_mt_init);
-module_exit(condition_mt_exit);
+module_init(condition_init);
+module_exit(condition_exit);
-- 
1.7.0.4

