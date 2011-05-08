From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 073/115] sysctl: group root-specific operations
Date: Mon,  9 May 2011 00:39:25 +0200
Message-ID: <1304894407-32201-74-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51704 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932506Ab1EHWl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:56 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No functional change, just moved stuff around.

->lookup was not moved to _ops because we'll get rid of it later.

This makes ctl_table_set occupy less space (the pointer to is_seen),
and that will means N*sizeof(void*) saved for N network
namespaces, but I don't that will impress anyone.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c  |    4 ++--
 include/linux/sysctl.h |   26 +++++++++++++++++++-------
 kernel/sysctl.c        |   25 ++++++++++++++-----------
 net/sysctl_net.c       |   20 ++++++++++++++------
 4 files changed, 49 insertions(+), 26 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 125b679..55c9bd1 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -131,7 +131,7 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 	 * and won't be until we finish.
 	 */
 	error = -EPERM;
-	if (sysctl_perm(head->root, table, write ? MAY_WRITE : MAY_READ))
+	if (sysctl_perm(head->root->ctl_ops, table, write ? MAY_WRITE : MAY_READ))
 		goto out;
 
 	/* if that can happen at all, it should be -EINVAL, not -EISDIR */
@@ -305,7 +305,7 @@ static int proc_sys_permission(struct inode *inode, int mask,unsigned int flags)
 	if (!table) /* global root - r-xr-xr-x */
 		error = mask & MAY_WRITE ? -EACCES : 0;
 	else /* Use the permissions on the sysctl table entry */
-		error = sysctl_perm(head->root, table, mask);
+		error = sysctl_perm(head->root->ctl_ops, table, mask);
 
 	sysctl_unuse_header(head);
 	return error;
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 1af4ed5..8209d75 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -934,22 +934,21 @@ enum
 
 /* For the /proc/sys support */
 struct ctl_table;
+struct ctl_table_header;
+struct ctl_table_group_ops;
 struct nsproxy;
 struct ctl_table_root;
 
 struct ctl_table_set {
 	struct list_head list;
 	struct ctl_table_set *parent;
-	int (*is_seen)(struct ctl_table_set *);
 };
 
 extern __init int sysctl_init(void);
 
 extern void setup_sysctl_set(struct ctl_table_set *p,
-	struct ctl_table_set *parent,
-	int (*is_seen)(struct ctl_table_set *));
+			     struct ctl_table_set *parent);
 
-struct ctl_table_header;
 
 /* get/put a reference to this header that
  * will be/was embedded in a procfs proc_inode */
@@ -962,8 +961,8 @@ extern struct ctl_table_header *sysctl_use_next_header(struct ctl_table_header *
 extern struct ctl_table_header *__sysctl_use_next_header(struct nsproxy *namespaces,
 						struct ctl_table_header *prev);
 extern void sysctl_unuse_header(struct ctl_table_header *prev);
-extern int sysctl_perm(struct ctl_table_root *root,
-		struct ctl_table *table, int op);
+extern int sysctl_perm(const struct ctl_table_group_ops *ops,
+		       struct ctl_table *table, int op);
 
 typedef struct ctl_table ctl_table;
 
@@ -1029,12 +1028,25 @@ struct ctl_table
 	void *extra2;
 };
 
+struct ctl_table_group_ops {
+	/* some sysctl entries are visible only in some situations.
+	 * E.g.: /proc/sys/net/ipv4/conf/eth0/ is only visible in the
+	 * netns in which that eth0 interface lives.
+	 *
+	 * If this hook is not set, then all the sysctl entries in
+	 * this set are always visible. */
+	int (*is_seen)(struct ctl_table_set *set);
+
+	/* hook to alter permissions for some sysctl nodes at runtime */
+	int (*permissions)(struct ctl_table *table);
+};
+
 struct ctl_table_root {
 	struct list_head root_list;
 	struct ctl_table_set default_set;
 	struct ctl_table_set *(*lookup)(struct ctl_table_root *root,
 					   struct nsproxy *namespaces);
-	int (*permissions)(struct ctl_table *table);
+	const struct ctl_table_group_ops *ctl_ops;
 };
 
 /* struct ctl_table_header is used to maintain dynamic lists of
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6e4e32b..0f00b87 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -197,6 +197,9 @@ static int sysrq_sysctl_handler(ctl_table *table, int write,
 
 #endif
 
+/* uses default ops */
+static const struct ctl_table_group_ops root_table_group_ops = { };
+
 static struct ctl_table root_table[];
 static struct ctl_table_root sysctl_table_root;
 static struct ctl_table_header root_table_header = {
@@ -206,7 +209,9 @@ static struct ctl_table_header root_table_header = {
 	.root = &sysctl_table_root,
 	.set = &sysctl_table_root.default_set,
 };
+
 static struct ctl_table_root sysctl_table_root = {
+	.ctl_ops = &root_table_group_ops,
 	.root_list = LIST_HEAD_INIT(sysctl_table_root.root_list),
 	.default_set.list = LIST_HEAD_INIT(root_table_header.ctl_entry),
 };
@@ -1659,12 +1664,13 @@ static int test_perm(int mode, int op)
 	return -EACCES;
 }
 
-int sysctl_perm(struct ctl_table_root *root, struct ctl_table *table, int op)
+int sysctl_perm(const struct ctl_table_group_ops *ops,
+		struct ctl_table *table, int op)
 {
 	int mode;
 
-	if (root->permissions)
-		mode = root->permissions(table);
+	if (ops->permissions)
+		mode = ops->permissions(table);
 	else
 		mode = table->mode;
 
@@ -1950,26 +1956,24 @@ void unregister_sysctl_table(struct ctl_table_header * header)
 
 int sysctl_is_seen(struct ctl_table_header *p)
 {
-	struct ctl_table_set *set = p->set;
+	const struct ctl_table_group_ops *ops = p->root->ctl_ops;
 	int res;
 	spin_lock(&sysctl_lock);
 	if (p->unregistering)
 		res = 0;
-	else if (!set->is_seen)
+	else if (!ops->is_seen)
 		res = 1;
 	else
-		res = set->is_seen(set);
+		res = ops->is_seen(p->set);
 	spin_unlock(&sysctl_lock);
 	return res;
 }
 
 void setup_sysctl_set(struct ctl_table_set *p,
-	struct ctl_table_set *parent,
-	int (*is_seen)(struct ctl_table_set *))
+		      struct ctl_table_set *parent)
 {
 	INIT_LIST_HEAD(&p->list);
 	p->parent = parent ? parent : &sysctl_table_root.default_set;
-	p->is_seen = is_seen;
 }
 
 #else /* !CONFIG_SYSCTL */
@@ -1984,8 +1988,7 @@ void unregister_sysctl_table(struct ctl_table_header * table)
 }
 
 void setup_sysctl_set(struct ctl_table_set *p,
-	struct ctl_table_set *parent,
-	int (*is_seen)(struct ctl_table_set *))
+		      struct ctl_table_set *parent)
 {
 }
 
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 1c0cb57..c0d7140 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -51,12 +51,17 @@ static int net_ctl_permissions(struct ctl_table *table)
 	return table->mode;
 }
 
+static const struct ctl_table_group_ops net_sysctl_group_ops = {
+	.is_seen = is_seen,
+	.permissions = net_ctl_permissions,
+};
+
 static struct ctl_table_root net_sysctl_root = {
 	.lookup = net_ctl_header_lookup,
-	.permissions = net_ctl_permissions,
+	.ctl_ops = &net_sysctl_group_ops,
 };
 
-static int net_ctl_ro_header_perms(ctl_table *table)
+static int net_ctl_ro_header_permissions(ctl_table *table)
 {
 	if (net_eq(current->nsproxy->net_ns, &init_net))
 		return table->mode;
@@ -64,15 +69,18 @@ static int net_ctl_ro_header_perms(ctl_table *table)
 		return table->mode & ~0222;
 }
 
+static const struct ctl_table_group_ops net_sysctl_ro_group_ops = {
+	.permissions = net_ctl_ro_header_permissions,
+};
+
 static struct ctl_table_root net_sysctl_ro_root = {
-	.permissions = net_ctl_ro_header_perms,
+	.ctl_ops = &net_sysctl_ro_group_ops,
 };
 
 static int __net_init sysctl_net_init(struct net *net)
 {
 	setup_sysctl_set(&net->sysctls,
-			 &net_sysctl_ro_root.default_set,
-			 is_seen);
+			 &net_sysctl_ro_root.default_set);
 	return 0;
 }
 
@@ -93,7 +101,7 @@ static __init int net_sysctl_init(void)
 	if (ret)
 		goto out;
 	register_sysctl_root(&net_sysctl_root);
-	setup_sysctl_set(&net_sysctl_ro_root.default_set, NULL, NULL);
+	setup_sysctl_set(&net_sysctl_ro_root.default_set, NULL);
 	register_sysctl_root(&net_sysctl_ro_root);
 out:
 	return ret;
-- 
1.7.5.134.g1c08b

