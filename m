From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 074/115] sysctl: introduce ctl_table_group
Date: Mon,  9 May 2011 00:39:26 +0200
Message-ID: <1304894407-32201-75-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49055 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932599Ab1EHWl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:57 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ctl_table_group will replace in the future ctl_table_root and
ctl_table_set. For now it only takes from ctl_table_root the ctl_ops
field.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c  |    4 ++--
 include/linux/sysctl.h |   16 ++++++++++++----
 kernel/sysctl.c        |   18 ++++++++++++------
 net/sysctl_net.c       |   13 +++++++++----
 4 files changed, 35 insertions(+), 16 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 55c9bd1..375d145 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -131,7 +131,7 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 	 * and won't be until we finish.
 	 */
 	error = -EPERM;
-	if (sysctl_perm(head->root->ctl_ops, table, write ? MAY_WRITE : MAY_READ))
+	if (sysctl_perm(head->ctl_group, table, write ? MAY_WRITE : MAY_READ))
 		goto out;
 
 	/* if that can happen at all, it should be -EINVAL, not -EISDIR */
@@ -305,7 +305,7 @@ static int proc_sys_permission(struct inode *inode, int mask,unsigned int flags)
 	if (!table) /* global root - r-xr-xr-x */
 		error = mask & MAY_WRITE ? -EACCES : 0;
 	else /* Use the permissions on the sysctl table entry */
-		error = sysctl_perm(head->root->ctl_ops, table, mask);
+		error = sysctl_perm(head->ctl_group, table, mask);
 
 	sysctl_unuse_header(head);
 	return error;
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 8209d75..a12ab12 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -935,6 +935,7 @@ enum
 /* For the /proc/sys support */
 struct ctl_table;
 struct ctl_table_header;
+struct ctl_table_group;
 struct ctl_table_group_ops;
 struct nsproxy;
 struct ctl_table_root;
@@ -961,7 +962,7 @@ extern struct ctl_table_header *sysctl_use_next_header(struct ctl_table_header *
 extern struct ctl_table_header *__sysctl_use_next_header(struct nsproxy *namespaces,
 						struct ctl_table_header *prev);
 extern void sysctl_unuse_header(struct ctl_table_header *prev);
-extern int sysctl_perm(const struct ctl_table_group_ops *ops,
+extern int sysctl_perm(struct ctl_table_group *group,
 		       struct ctl_table *table, int op);
 
 typedef struct ctl_table ctl_table;
@@ -1041,12 +1042,15 @@ struct ctl_table_group_ops {
 	int (*permissions)(struct ctl_table *table);
 };
 
+struct ctl_table_group {
+	const struct ctl_table_group_ops *ctl_ops;
+};
+
 struct ctl_table_root {
 	struct list_head root_list;
 	struct ctl_table_set default_set;
 	struct ctl_table_set *(*lookup)(struct ctl_table_root *root,
 					   struct nsproxy *namespaces);
-	const struct ctl_table_group_ops *ctl_ops;
 };
 
 /* struct ctl_table_header is used to maintain dynamic lists of
@@ -1073,6 +1077,7 @@ struct ctl_table_header
 	struct completion *unregistering;
 	struct ctl_table *ctl_table_arg;
 	struct ctl_table_root *root;
+	struct ctl_table_group *ctl_group;
 	struct ctl_table_set *set;
 	struct ctl_table *attached_by;
 	struct ctl_table *attached_to;
@@ -1086,8 +1091,11 @@ struct ctl_path {
 
 void register_sysctl_root(struct ctl_table_root *root);
 struct ctl_table_header *__register_sysctl_paths(
-	struct ctl_table_root *root, struct nsproxy *namespaces,
-	const struct ctl_path *path, struct ctl_table *table);
+	struct ctl_table_root *root,
+	struct ctl_table_group *group,
+	struct nsproxy *namespaces,
+	const struct ctl_path *path,
+	struct ctl_table *table);
 struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						struct ctl_table *table);
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 0f00b87..8dde087 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -200,6 +200,10 @@ static int sysrq_sysctl_handler(ctl_table *table, int write,
 /* uses default ops */
 static const struct ctl_table_group_ops root_table_group_ops = { };
 
+static struct ctl_table_group root_table_group = {
+	.ctl_ops = &root_table_group_ops,
+};
+
 static struct ctl_table root_table[];
 static struct ctl_table_root sysctl_table_root;
 static struct ctl_table_header root_table_header = {
@@ -207,11 +211,11 @@ static struct ctl_table_header root_table_header = {
 	.ctl_table = root_table,
 	.ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.list),}},
 	.root = &sysctl_table_root,
+	.ctl_group = &root_table_group,
 	.set = &sysctl_table_root.default_set,
 };
 
 static struct ctl_table_root sysctl_table_root = {
-	.ctl_ops = &root_table_group_ops,
 	.root_list = LIST_HEAD_INIT(sysctl_table_root.root_list),
 	.default_set.list = LIST_HEAD_INIT(root_table_header.ctl_entry),
 };
@@ -1664,10 +1668,10 @@ static int test_perm(int mode, int op)
 	return -EACCES;
 }
 
-int sysctl_perm(const struct ctl_table_group_ops *ops,
-		struct ctl_table *table, int op)
+int sysctl_perm(struct ctl_table_group *group, struct ctl_table *table, int op)
 {
 	int mode;
+	const struct ctl_table_group_ops *ops = group->ctl_ops;
 
 	if (ops->permissions)
 		mode = ops->permissions(table);
@@ -1838,6 +1842,7 @@ static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
  */
 struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table_root *root,
+	struct ctl_table_group *group,
 	struct nsproxy *namespaces,
 	const struct ctl_path *path, struct ctl_table *table)
 {
@@ -1883,6 +1888,7 @@ struct ctl_table_header *__register_sysctl_paths(
 	INIT_LIST_HEAD(&header->ctl_entry);
 	header->unregistering = NULL;
 	header->root = root;
+	header->ctl_group = group;
 	header->ctl_header_refs = 1;
 #ifdef CONFIG_SYSCTL_SYSCALL_CHECK
 	if (sysctl_check_table(namespaces, header->ctl_table)) {
@@ -1923,8 +1929,8 @@ struct ctl_table_header *__register_sysctl_paths(
 struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						struct ctl_table *table)
 {
-	return __register_sysctl_paths(&sysctl_table_root, current->nsproxy,
-					path, table);
+	return __register_sysctl_paths(&sysctl_table_root, &root_table_group,
+				       current->nsproxy, path, table);
 }
 
 /**
@@ -1956,7 +1962,7 @@ void unregister_sysctl_table(struct ctl_table_header * header)
 
 int sysctl_is_seen(struct ctl_table_header *p)
 {
-	const struct ctl_table_group_ops *ops = p->root->ctl_ops;
+	const struct ctl_table_group_ops *ops = p->ctl_group->ctl_ops;
 	int res;
 	spin_lock(&sysctl_lock);
 	if (p->unregistering)
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index c0d7140..5009d4e 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -56,9 +56,12 @@ static const struct ctl_table_group_ops net_sysctl_group_ops = {
 	.permissions = net_ctl_permissions,
 };
 
+static struct ctl_table_group net_sysctl_group = {
+	.ctl_ops = &net_sysctl_group_ops,
+};
+
 static struct ctl_table_root net_sysctl_root = {
 	.lookup = net_ctl_header_lookup,
-	.ctl_ops = &net_sysctl_group_ops,
 };
 
 static int net_ctl_ro_header_permissions(ctl_table *table)
@@ -73,10 +76,12 @@ static const struct ctl_table_group_ops net_sysctl_ro_group_ops = {
 	.permissions = net_ctl_ro_header_permissions,
 };
 
-static struct ctl_table_root net_sysctl_ro_root = {
+static struct ctl_table_group net_sysctl_ro_group = {
 	.ctl_ops = &net_sysctl_ro_group_ops,
 };
 
+static struct ctl_table_root net_sysctl_ro_root = { };
+
 static int __net_init sysctl_net_init(struct net *net)
 {
 	setup_sysctl_set(&net->sysctls,
@@ -114,7 +119,7 @@ struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	struct nsproxy namespaces;
 	namespaces = *current->nsproxy;
 	namespaces.net_ns = net;
-	return __register_sysctl_paths(&net_sysctl_root,
+	return __register_sysctl_paths(&net_sysctl_root, &net_sysctl_group,
 					&namespaces, path, table);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_table);
@@ -122,7 +127,7 @@ EXPORT_SYMBOL_GPL(register_net_sysctl_table);
 struct ctl_table_header *register_net_sysctl_rotable(const
 		struct ctl_path *path, struct ctl_table *table)
 {
-	return __register_sysctl_paths(&net_sysctl_ro_root,
+	return __register_sysctl_paths(&net_sysctl_ro_root, &net_sysctl_ro_group,
 			&init_nsproxy, path, table);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_rotable);
-- 
1.7.5.134.g1c08b

