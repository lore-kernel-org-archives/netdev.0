From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 1/9] sysctl: add ctl_header_cookie
Date: Fri, 25 Feb 2011 20:52:33 +0200
Message-ID: <1298659961-23863-2-git-send-email-lucian.grijincu@gmail.com>
References: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>, netdev@vger.kernel.org,
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/sysctl.h |    5 ++++-
 kernel/sysctl.c        |   12 ++++++++----
 net/sysctl_net.c       |    6 +++---
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 7bb5cb6..43fed29 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1048,6 +1048,9 @@ struct ctl_table_header
 	struct ctl_table *attached_by;
 	struct ctl_table *attached_to;
 	struct ctl_table_header *parent;
+	/* Pointer to data that outlives this ctl_table_header.
+	 * Caller responsible to free the cookie. */
+	void *ctl_header_cookie;
 };
 
 /* struct ctl_path describes where in the hierarchy a table is added */
@@ -1058,7 +1061,7 @@ struct ctl_path {
 void register_sysctl_root(struct ctl_table_root *root);
 struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table_root *root, struct nsproxy *namespaces,
-	const struct ctl_path *path, struct ctl_table *table);
+	const struct ctl_path *path, struct ctl_table *table, void *cookie);
 struct ctl_table_header *register_sysctl_table(struct ctl_table * table);
 struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						struct ctl_table *table);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 0f1bd83..31fd587 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -199,6 +199,7 @@ static struct ctl_table_header root_table_header = {
 	.ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.list),
 	.root = &sysctl_table_root,
 	.set = &sysctl_table_root.default_set,
+	.ctl_header_cookie = NULL,
 };
 static struct ctl_table_root sysctl_table_root = {
 	.root_list = LIST_HEAD_INIT(sysctl_table_root.root_list),
@@ -1774,6 +1775,9 @@ static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
  * @namespaces: Data to compute which lists of sysctl entries are visible
  * @path: The path to the directory the sysctl table is in.
  * @table: the top-level table structure
+ * @cookie: Pointer to user provided data that must be accessible
+ *  until unregister_sysctl_table. This cookie will be passed to the
+ *  proc_handler.
  *
  * Register a sysctl table hierarchy. @table should be a filled in ctl_table
  * array. A completely 0 filled entry terminates the table.
@@ -1822,9 +1826,8 @@ static void try_attach(struct ctl_table_header *p, struct ctl_table_header *q)
  * to the table header on success.
  */
 struct ctl_table_header *__register_sysctl_paths(
-	struct ctl_table_root *root,
-	struct nsproxy *namespaces,
-	const struct ctl_path *path, struct ctl_table *table)
+	struct ctl_table_root *root, struct nsproxy *namespaces,
+	const struct ctl_path *path, struct ctl_table *table, void *cookie)
 {
 	struct ctl_table_header *header;
 	struct ctl_table *new, **prevp;
@@ -1871,6 +1874,7 @@ struct ctl_table_header *__register_sysctl_paths(
 	header->root = root;
 	sysctl_set_parent(NULL, header->ctl_table);
 	header->count = 1;
+	header->ctl_header_cookie = cookie;
 #ifdef CONFIG_SYSCTL_SYSCALL_CHECK
 	if (sysctl_check_table(namespaces, header->ctl_table)) {
 		kfree(header);
@@ -1911,7 +1915,7 @@ struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						struct ctl_table *table)
 {
 	return __register_sysctl_paths(&sysctl_table_root, current->nsproxy,
-					path, table);
+				       path, table, NULL);
 }
 
 /**
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index ca84212..9dadd17 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -109,8 +109,8 @@ struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	struct nsproxy namespaces;
 	namespaces = *current->nsproxy;
 	namespaces.net_ns = net;
-	return __register_sysctl_paths(&net_sysctl_root,
-					&namespaces, path, table);
+	return __register_sysctl_paths(&net_sysctl_root, &namespaces, path,
+				       table, NULL);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_table);
 
@@ -118,7 +118,7 @@ struct ctl_table_header *register_net_sysctl_rotable(const
 		struct ctl_path *path, struct ctl_table *table)
 {
 	return __register_sysctl_paths(&net_sysctl_ro_root,
-			&init_nsproxy, path, table);
+				       &init_nsproxy, path, table, NULL);
 }
 EXPORT_SYMBOL_GPL(register_net_sysctl_rotable);
 
-- 
1.7.4.rc1.7.g2cf08.dirty
