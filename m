From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [RFC 1/2] netfilter: xt_condition: export list management code
Date: Mon, 19 Jul 2010 17:15:46 +0300
Message-ID: <1279548947-10470-2-git-send-email-luciano.coelho@nokia.com>
References: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com>
Cc: netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	sameo@linux.intel.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luciano Coelho <coelho@testbed>

This patch isolates and exports the condition list management code, in
preparation for the CONDITION target to use it.  No functional change,
just reorganization of the code.

Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
---
 include/linux/netfilter/xt_condition.h |   17 ++++++-
 net/netfilter/xt_condition.c           |   82 ++++++++++++++++++-------------
 2 files changed, 64 insertions(+), 35 deletions(-)

diff --git a/include/linux/netfilter/xt_condition.h b/include/linux/netfilter/xt_condition.h
index 4faf3ca..eebf41a 100644
--- a/include/linux/netfilter/xt_condition.h
+++ b/include/linux/netfilter/xt_condition.h
@@ -3,12 +3,27 @@
 
 #include <linux/types.h>
 
+#define XT_CONDITION_MAX_NAME_SIZE 30
+
 struct xt_condition_mtinfo {
-	char name[31];
+	char name[XT_CONDITION_MAX_NAME_SIZE + 1];
 	__u8 invert;
 
 	/* Used internally by the kernel */
 	void *condvar __attribute__((aligned(8)));
 };
 
+#ifdef __KERNEL__
+struct condition_variable {
+	struct list_head list;
+	struct proc_dir_entry *status_proc;
+	unsigned int refcount;
+	bool enabled;
+};
+
+struct condition_variable *xt_condition_insert(const char *name);
+void xt_condition_put(struct condition_variable *var);
+void xt_condition_set(struct condition_variable *var, bool enabled);
+#endif /* __KERNEL__ */
+
 #endif /* _XT_CONDITION_H */
diff --git a/net/netfilter/xt_condition.c b/net/netfilter/xt_condition.c
index a7ccea3..dec97fe 100644
--- a/net/netfilter/xt_condition.c
+++ b/net/netfilter/xt_condition.c
@@ -43,13 +43,6 @@ MODULE_PARM_DESC(condition_gid_perms, "default group owner of /proc/net/nf_condi
 MODULE_ALIAS("ipt_condition");
 MODULE_ALIAS("ip6t_condition");
 
-struct condition_variable {
-	struct list_head list;
-	struct proc_dir_entry *status_proc;
-	unsigned int refcount;
-	bool enabled;
-};
-
 /* proc_lock is a user context only semaphore used for write access */
 /*           to the conditions' list.                               */
 static DEFINE_MUTEX(proc_lock);
@@ -100,47 +93,34 @@ condition_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	return var->enabled ^ info->invert;
 }
 
-static int condition_mt_check(const struct xt_mtchk_param *par)
+struct condition_variable *xt_condition_insert(const char *name)
 {
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
@@ -151,16 +131,14 @@ static int condition_mt_check(const struct xt_mtchk_param *par)
 	var->status_proc->uid        = condition_uid_perms;
 	var->status_proc->gid        = condition_gid_perms;
 	list_add(&var->list, &conditions_list);
+out:
 	mutex_unlock(&proc_lock);
-	info->condvar = var;
-	return 0;
+	return var;
 }
+EXPORT_SYMBOL_GPL(xt_condition_insert);
 
-static void condition_mt_destroy(const struct xt_mtdtor_param *par)
+void xt_condition_put(struct condition_variable *var)
 {
-	const struct xt_condition_mtinfo *info = par->matchinfo;
-	struct condition_variable *var = info->condvar;
-
 	mutex_lock(&proc_lock);
 	if (--var->refcount == 0) {
 		list_del(&var->list);
@@ -171,6 +149,42 @@ static void condition_mt_destroy(const struct xt_mtdtor_param *par)
 	}
 	mutex_unlock(&proc_lock);
 }
+EXPORT_SYMBOL_GPL(xt_condition_put);
+
+void xt_condition_set(struct condition_variable *var, bool enabled)
+{
+	var->enabled = enabled;
+}
+EXPORT_SYMBOL_GPL(xt_condition_set);
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
 
 static struct xt_match condition_mt_reg __read_mostly = {
 	.name       = "condition",
-- 
1.7.0.4

