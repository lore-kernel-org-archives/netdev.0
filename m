From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH RFC 27/48] Audit: make tree_list per user namespace
Date: Tue, 7 May 2013 10:20:48 +0800
Message-ID: <1367893269-9308-28-git-send-email-gaofeng@cn.fujitsu.com>
References: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: viro@zeniv.linux.org.uk, eparis@redhat.com, ebiederm@xmission.com,
	sgrubb@redhat.com, akpm@linux-foundation.org,
	serge.hallyn@ubuntu.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367893269-9308-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tree_list is used to list the directory releated audit rules,
it should be per user namespace.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/linux/user_namespace.h |  1 +
 kernel/audit.c                 |  2 ++
 kernel/audit.h                 |  4 ++--
 kernel/audit_tree.c            | 22 ++++++++++++----------
 kernel/auditfilter.c           |  2 +-
 5 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index c56e276..c870e28 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -32,6 +32,7 @@ struct audit_ctrl {
 	wait_queue_head_t	backlog_wait;
 #define AUDIT_INODE_BUCKETS	32
 	struct list_head	inode_hash[AUDIT_INODE_BUCKETS];
+	struct list_head	tree_list;
 	bool			ever_enabled;
 };
 #endif
diff --git a/kernel/audit.c b/kernel/audit.c
index d254827..a0544b1 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1609,6 +1609,8 @@ void audit_set_user_ns(struct user_namespace *ns)
 	for (i = 0; i < AUDIT_INODE_BUCKETS; i++)
 		INIT_LIST_HEAD(&ns->audit.inode_hash[i]);
 
+	INIT_LIST_HEAD(&ns->audit.tree_list);
+
 	ns->audit.initialized = AUDIT_INITIALIZED;
 }
 
diff --git a/kernel/audit.h b/kernel/audit.h
index a01c892..a509796 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -122,7 +122,7 @@ extern struct audit_chunk *audit_tree_lookup(const struct inode *);
 extern void audit_put_chunk(struct audit_chunk *);
 extern int audit_tree_match(struct audit_chunk *, struct audit_tree *);
 extern int audit_make_tree(struct audit_krule *, char *, u32);
-extern int audit_add_tree_rule(struct audit_krule *);
+extern int audit_add_tree_rule(struct user_namespace *ns, struct audit_krule *);
 extern int audit_remove_tree_rule(struct audit_krule *);
 extern void audit_trim_trees(void);
 extern int audit_tag_tree(char *old, char *new);
@@ -131,7 +131,7 @@ extern void audit_put_tree(struct audit_tree *);
 extern void audit_kill_trees(struct list_head *);
 #else
 #define audit_remove_tree_rule(rule) BUG()
-#define audit_add_tree_rule(rule) -EINVAL
+#define audit_add_tree_rule(ns, rule) -EINVAL
 #define audit_make_tree(rule, str, op) -EINVAL
 #define audit_trim_trees() (void)0
 #define audit_put_tree(tree) (void)0
diff --git a/kernel/audit_tree.c b/kernel/audit_tree.c
index a291aa2..4531d73 100644
--- a/kernel/audit_tree.c
+++ b/kernel/audit_tree.c
@@ -35,7 +35,6 @@ struct audit_chunk {
 	} owners[];
 };
 
-static LIST_HEAD(tree_list);
 static LIST_HEAD(prune_list);
 
 /*
@@ -581,10 +580,11 @@ static int compare_root(struct vfsmount *mnt, void *arg)
 void audit_trim_trees(void)
 {
 	struct list_head cursor;
+	struct list_head *tree_list = &current_user_ns()->audit.tree_list;
 
 	mutex_lock(&audit_filter_mutex);
-	list_add(&cursor, &tree_list);
-	while (cursor.next != &tree_list) {
+	list_add(&cursor, tree_list);
+	while (cursor.next != tree_list) {
 		struct audit_tree *tree;
 		struct path path;
 		struct vfsmount *root_mnt;
@@ -651,14 +651,14 @@ static int tag_mount(struct vfsmount *mnt, void *arg)
 }
 
 /* called with audit_filter_mutex */
-int audit_add_tree_rule(struct audit_krule *rule)
+int audit_add_tree_rule(struct user_namespace *ns, struct audit_krule *rule)
 {
 	struct audit_tree *seed = rule->tree, *tree;
 	struct path path;
 	struct vfsmount *mnt;
 	int err;
 
-	list_for_each_entry(tree, &tree_list, list) {
+	list_for_each_entry(tree, &ns->audit.tree_list, list) {
 		if (!strcmp(seed->pathname, tree->pathname)) {
 			put_tree(seed);
 			rule->tree = tree;
@@ -667,7 +667,7 @@ int audit_add_tree_rule(struct audit_krule *rule)
 		}
 	}
 	tree = seed;
-	list_add(&tree->list, &tree_list);
+	list_add(&tree->list, &ns->audit.tree_list);
 	list_add(&rule->rlist, &tree->rules);
 	/* do not set rule->tree yet */
 	mutex_unlock(&audit_filter_mutex);
@@ -720,6 +720,8 @@ int audit_tag_tree(char *old, char *new)
 	int failed = 0;
 	struct path path1, path2;
 	struct vfsmount *tagged;
+	struct user_namespace *ns = current_user_ns();
+	struct list_head *tree_list = &ns->audit.tree_list;
 	int err;
 
 	err = kern_path(new, 0, &path2);
@@ -737,10 +739,10 @@ int audit_tag_tree(char *old, char *new)
 	}
 
 	mutex_lock(&audit_filter_mutex);
-	list_add(&barrier, &tree_list);
+	list_add(&barrier, tree_list);
 	list_add(&cursor, &barrier);
 
-	while (cursor.next != &tree_list) {
+	while (cursor.next != tree_list) {
 		struct audit_tree *tree;
 		int good_one = 0;
 
@@ -773,13 +775,13 @@ int audit_tag_tree(char *old, char *new)
 		spin_lock(&hash_lock);
 		if (!tree->goner) {
 			list_del(&tree->list);
-			list_add(&tree->list, &tree_list);
+			list_add(&tree->list, tree_list);
 		}
 		spin_unlock(&hash_lock);
 		put_tree(tree);
 	}
 
-	while (barrier.prev != &tree_list) {
+	while (barrier.prev != tree_list) {
 		struct audit_tree *tree;
 
 		tree = container_of(barrier.prev, struct audit_tree, list);
diff --git a/kernel/auditfilter.c b/kernel/auditfilter.c
index 573385b..3c8fb2e 100644
--- a/kernel/auditfilter.c
+++ b/kernel/auditfilter.c
@@ -962,7 +962,7 @@ static inline int audit_add_rule(struct user_namespace *ns,
 		}
 	}
 	if (tree) {
-		err = audit_add_tree_rule(&entry->rule);
+		err = audit_add_tree_rule(ns, &entry->rule);
 		if (err) {
 			mutex_unlock(&audit_filter_mutex);
 			goto error;
-- 
1.8.1.4
