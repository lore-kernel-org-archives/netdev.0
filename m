From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [PATCH RESEND 3/3] netfilter: xt_condition: add condition target support
Date: Tue, 17 Aug 2010 11:36:53 +0300
Message-ID: <1282034213-1829-4-git-send-email-luciano.coelho@nokia.com>
References: <1282034213-1829-1-git-send-email-luciano.coelho@nokia.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jengelh@medozas.de, sameo@linux.intel.com, janne.ylalehto@nokia.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1282034213-1829-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements a condition target to the xt_condition module,
which let's the user set netfilter rules that change the variables
used by the condition match.  Originally, the condition match only
allowed the variable to be changed via procfs.  This new target makes
it easy to change the condition value depending on the rules set.

Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
---
 include/linux/netfilter/xt_condition.h |   13 ++-
 net/netfilter/Kconfig                  |   19 ++--
 net/netfilter/Makefile                 |    2 +-
 net/netfilter/xt_condition.c           |  194 +++++++++++++++++++++++---------
 4 files changed, 165 insertions(+), 63 deletions(-)

diff --git a/include/linux/netfilter/xt_condition.h b/include/linux/netfilter/xt_condition.h
index c4fe899..946d43a 100644
--- a/include/linux/netfilter/xt_condition.h
+++ b/include/linux/netfilter/xt_condition.h
@@ -3,8 +3,10 @@
 
 #include <linux/types.h>
 
+#define XT_CONDITION_MAX_NAME_SIZE 27
+
 struct xt_condition_mtinfo {
-	char name[27];
+	char name[XT_CONDITION_MAX_NAME_SIZE];
 	__u8 invert;
 	__u32 value;
 
@@ -12,4 +14,13 @@ struct xt_condition_mtinfo {
 	void *condvar __attribute__((aligned(8)));
 };
 
+struct condition_tginfo {
+	char name[XT_CONDITION_MAX_NAME_SIZE];
+	__u8 padding;
+	__u32 value;
+
+	/* Used internally by the kernel */
+	void *condvar __attribute__((aligned(8)));
+};
+
 #endif /* _XT_CONDITION_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 5044dd6..d9a17eb 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -310,6 +310,17 @@ config NETFILTER_XT_MARK
 	"Use netfilter MARK value as routing key") and can also be used by
 	other subsystems to change their behavior.
 
+config NETFILTER_XT_CONDITION
+       tristate '"condition" match and target support'
+       depends on NETFILTER_ADVANCED
+       depends on PROC_FS
+       ---help---
+       This option adds the "CONDITION" target and "condition" match.
+
+       It allows you to match rules against condition variables
+       stored in the /proc/net/nf_condition directory. It also allows
+       you to set the variables using the target.
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
index bbf72bb..146a05f 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -43,6 +43,7 @@ obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
 # combos
 obj-$(CONFIG_NETFILTER_XT_MARK) += xt_mark.o
 obj-$(CONFIG_NETFILTER_XT_CONNMARK) += xt_connmark.o
+obj-$(CONFIG_NETFILTER_XT_CONDITION) += xt_condition.o
 
 # targets
 obj-$(CONFIG_NETFILTER_XT_TARGET_CHECKSUM) += xt_CHECKSUM.o
@@ -67,7 +68,6 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) += xt_IDLETIMER.o
 # matches
 obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) += xt_cluster.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
-obj-$(CONFIG_NETFILTER_XT_MATCH_CONDITION) += xt_condition.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) += xt_connbytes.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNLIMIT) += xt_connlimit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNTRACK) += xt_conntrack.o
diff --git a/net/netfilter/xt_condition.c b/net/netfilter/xt_condition.c
index cc9ada9..06205aa 100644
--- a/net/netfilter/xt_condition.c
+++ b/net/netfilter/xt_condition.c
@@ -2,15 +2,20 @@
  *	"condition" match extension for Xtables
  *
  *	Description: This module allows firewall rules to match using
- *	condition variables available through procfs.
+ *	condition variables available through procfs.  It also allows
+ *	target rules to set the condition variable.
  *
  *	Authors:
  *	Stephane Ouellette <ouellettes [at] videotron ca>, 2002-10-22
  *	Massimiliano Hofer <max [at] nucleus it>, 2006-05-15
+ *	Luciano Coelho <luciano.coelho@nokia.com>, 2010-08-11
  *
  *	This program is free software; you can redistribute it and/or modify it
  *	under the terms of the GNU General Public License; either version 2
  *	or 3 of the License, as published by the Free Software Foundation.
+ *
+ *	Portion Copyright 2010 Nokia Corporation and/or its subsidiary(-ies).
+ *	File modified on 2010-08-11.
  */
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/kernel.h>
@@ -33,7 +38,8 @@ static unsigned int condition_gid_perms = 0;
 MODULE_AUTHOR("Stephane Ouellette <ouellettes@videotron.ca>");
 MODULE_AUTHOR("Massimiliano Hofer <max@nucleus.it>");
 MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
-MODULE_DESCRIPTION("Allows rules to match against condition variables");
+MODULE_AUTHOR("Luciano Coelho <luciano.coelho@nokia.com>");
+MODULE_DESCRIPTION("Allows rules to set and match condition variables");
 MODULE_LICENSE("GPL");
 module_param(condition_list_perms, uint, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(condition_list_perms, "default permissions on /proc/net/nf_condition/* files");
@@ -104,29 +110,11 @@ static int condition_proc_write(struct file *file, const char __user *input,
 	return length;
 }
 
-static bool
-condition_mt(const struct sk_buff *skb, struct xt_action_param *par)
-{
-	const struct xt_condition_mtinfo *info = par->matchinfo;
-	const struct condition_variable *var   = info->condvar;
-
-	return (var->value == info->value) ^ info->invert;
-}
-
-static int condition_mt_check(const struct xt_mtchk_param *par)
+static struct
+condition_variable *xt_condition_insert(const char *name,
+					struct condition_net *cond_net)
 {
-	struct xt_condition_mtinfo *info = par->matchinfo;
 	struct condition_variable *var;
-	struct condition_net *cond_net = condition_pernet(par->net);
-
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
@@ -134,29 +122,24 @@ static int condition_mt_check(const struct xt_mtchk_param *par)
 	 */
 	mutex_lock(&proc_lock);
 	list_for_each_entry(var, &cond_net->list, list) {
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
-	var->status_proc = create_proc_entry(info->name,
-					     condition_list_perms,
+	var->status_proc = create_proc_entry(name, condition_list_perms,
 					     cond_net->proc_dir);
 	if (var->status_proc == NULL) {
 		kfree(var);
-		mutex_unlock(&proc_lock);
-		return -ENOMEM;
+		var = NULL;
+		goto out;
 	}
 
 	var->refcount = 1;
@@ -167,17 +150,14 @@ static int condition_mt_check(const struct xt_mtchk_param *par)
 	var->status_proc->uid        = condition_uid_perms;
 	var->status_proc->gid        = condition_gid_perms;
 	list_add(&var->list, &cond_net->list);
+out:
 	mutex_unlock(&proc_lock);
-	info->condvar = var;
-	return 0;
+	return var;
 }
 
-static void condition_mt_destroy(const struct xt_mtdtor_param *par)
+static void xt_condition_put(struct condition_variable *var,
+			     struct condition_net *cond_net)
 {
-	const struct xt_condition_mtinfo *info = par->matchinfo;
-	struct condition_variable *var = info->condvar;
-	struct condition_net *cond_net = condition_pernet(par->net);
-
 	mutex_lock(&proc_lock);
 	if (--var->refcount == 0) {
 		list_del(&var->list);
@@ -192,6 +172,106 @@ static void condition_mt_destroy(const struct xt_mtdtor_param *par)
 	mutex_unlock(&proc_lock);
 }
 
+static bool
+condition_mt(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_condition_mtinfo *info = par->matchinfo;
+	const struct condition_variable *var   = info->condvar;
+
+	return (var->value == info->value) ^ info->invert;
+}
+
+static int condition_mt_check(const struct xt_mtchk_param *par)
+{
+	struct xt_condition_mtinfo *info = par->matchinfo;
+	struct condition_variable *var;
+	struct condition_net *cond_net = condition_pernet(par->net);
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
+	var = xt_condition_insert(info->name, cond_net);
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
+	struct condition_net *cond_net = condition_pernet(par->net);
+
+	xt_condition_put(info->condvar, cond_net);
+}
+
+static unsigned int condition_tg_target(struct sk_buff *skb,
+					const struct xt_action_param *par)
+{
+	const struct condition_tginfo *info = par->targinfo;
+	struct condition_variable *var = info->condvar;
+
+	pr_debug("setting condition %s, value %d\n",
+		 info->name, info->value);
+
+	var->value = info->value;
+
+	return XT_CONTINUE;
+}
+
+static int condition_tg_checkentry(const struct xt_tgchk_param *par)
+{
+	struct condition_tginfo *info = par->targinfo;
+	struct condition_variable *var;
+	struct condition_net *cond_net = condition_pernet(par->net);
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
+	var = xt_condition_insert(info->name, cond_net);
+	if (var == NULL)
+		return -ENOMEM;
+
+	info->condvar = var;
+	return 0;
+}
+
+static void condition_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	const struct condition_tginfo *info = par->targinfo;
+	struct condition_net *cond_net = condition_pernet(par->net);
+
+	pr_debug("destroy %s\n", info->name);
+
+	xt_condition_put(info->condvar, cond_net);
+}
+
+static struct xt_target condition_tg_reg __read_mostly = {
+	.name           = "CONDITION",
+	.revision       = 0,
+	.family         = NFPROTO_UNSPEC,
+	.target         = condition_tg_target,
+	.targetsize     = sizeof(struct condition_tginfo),
+	.checkentry     = condition_tg_checkentry,
+	.destroy        = condition_tg_destroy,
+	.me             = THIS_MODULE,
+};
+
 static struct xt_match condition_mt_reg __read_mostly = {
 	.name       = "condition",
 	.revision   = 2,
@@ -205,7 +285,7 @@ static struct xt_match condition_mt_reg __read_mostly = {
 
 static const char *const dir_name = "nf_condition";
 
-static int __net_init condnet_mt_init(struct net *net)
+static int __net_init condnet_init(struct net *net)
 {
 	struct condition_net *cond_net = condition_pernet(net);
 
@@ -216,7 +296,7 @@ static int __net_init condnet_mt_init(struct net *net)
 	return (cond_net->proc_dir == NULL) ? -EACCES : 0;
 }
 
-static void __net_exit condnet_mt_exit(struct net *net)
+static void __net_exit condnet_exit(struct net *net)
 {
 	struct condition_net *cond_net = condition_pernet(net);
 	struct condition_variable *var, *tmp;
@@ -234,14 +314,14 @@ static void __net_exit condnet_mt_exit(struct net *net)
 	remove_proc_entry(dir_name, net->proc_net);
 }
 
-static struct pernet_operations condition_mt_netops = {
-	.init = condnet_mt_init,
-	.exit = condnet_mt_exit,
+static struct pernet_operations condition_netops = {
+	.init = condnet_init,
+	.exit = condnet_exit,
 	.id   = &condition_net_id,
 	.size = sizeof(struct condition_net),
 };
 
-static int __init condition_mt_init(void)
+static int __init condition_init(void)
 {
 	int ret;
 
@@ -250,8 +330,15 @@ static int __init condition_mt_init(void)
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
@@ -259,11 +346,12 @@ static int __init condition_mt_init(void)
 	return 0;
 }
 
-static void __exit condition_mt_exit(void)
+static void __exit condition_exit(void)
 {
-	unregister_pernet_subsys(&condition_mt_netops);
+	unregister_pernet_subsys(&condition_netops);
 	xt_unregister_match(&condition_mt_reg);
+	xt_unregister_target(&condition_tg_reg);
 }
 
-module_init(condition_mt_init);
-module_exit(condition_mt_exit);
+module_init(condition_init);
+module_exit(condition_exit);
-- 
1.7.0.4

