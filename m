From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 078/115] sysctl: alloc ctl_table_header with kmem_cache
Date: Mon,  9 May 2011 00:39:30 +0200
Message-ID: <1304894407-32201-79-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because now ctl_table_header objects are allocated with a fixed size
buffer (sizeof(struct ctl_table_header)) we can do the allocations
with kmem_cache.

Also, by making sure that the objects that are returned to the cache
are in a sane state we don't waste time reinitializing every field
after kmem_cache_alloc. We only initialize fields that were not left
with a sane value before returning an object to the cache.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 kernel/sysctl.c |   48 +++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d777e89..c207c19 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -198,6 +198,9 @@ static int sysrq_sysctl_handler(ctl_table *table, int write,
 
 #endif
 
+/* cache for ctl_table_header objects */
+static struct kmem_cache *sysctl_header_cachep;
+
 /* uses default ops */
 static const struct ctl_table_group_ops root_table_group_ops = { };
 
@@ -1553,7 +1556,9 @@ void sysctl_proc_inode_get(struct ctl_table_header *head)
 
 static void free_head(struct rcu_head *rcu)
 {
-	kfree(container_of(rcu, struct ctl_table_header, rcu));
+	struct ctl_table_header *header;
+	header = container_of(rcu, struct ctl_table_header, rcu);
+	kmem_cache_free(sysctl_header_cachep, header);
 }
 
 void sysctl_proc_inode_put(struct ctl_table_header *head)
@@ -1664,6 +1669,8 @@ int sysctl_perm(struct ctl_table_group *group, struct ctl_table *table, int op)
 	return test_perm(mode, op);
 }
 
+static void sysctl_header_ctor(void *data);
+
 __init int sysctl_init(void)
 {
 	struct ctl_table_header *kern_header, *vm_header, *fs_header,
@@ -1672,6 +1679,12 @@ __init int sysctl_init(void)
 	struct ctl_table_header *binfmt_misc_header;
 #endif
 
+	sysctl_header_cachep = kmem_cache_create("sysctl_header_cachep",
+					       sizeof(struct ctl_table_header),
+					       0, 0, &sysctl_header_ctor);
+	if (!sysctl_header_cachep)
+		goto fail_alloc_cachep;
+
 	kern_header = register_sysctl_paths(kern_path, kern_table);
 	if (kern_header == NULL)
 		goto fail_register_kern;
@@ -1715,6 +1728,8 @@ fail_register_fs:
 fail_register_vm:
 	unregister_sysctl_table(kern_header);
 fail_register_kern:
+	kmem_cache_destroy(sysctl_header_cachep);
+fail_alloc_cachep:
 	return -ENOMEM;
 }
 
@@ -1735,19 +1750,34 @@ static int ctl_path_items(const struct ctl_path *path)
 	return n;
 }
 
+static void sysctl_header_ctor(void *data)
+{
+	struct ctl_table_header *h = data;
+
+	h->ctl_use_refs = 0;
+	h->ctl_procfs_refs = 0;
+	h->ctl_header_refs = 0;
+
+	INIT_LIST_HEAD(&h->ctl_entry);
+	INIT_LIST_HEAD(&h->ctl_subdirs);
+	INIT_LIST_HEAD(&h->ctl_tables);
+}
 
 static struct ctl_table_header *alloc_sysctl_header(struct ctl_table_group *group)
 {
 	struct ctl_table_header *h;
 
-	h = kzalloc(sizeof(*h), GFP_KERNEL);
+	h = kmem_cache_alloc(sysctl_header_cachep, GFP_KERNEL);
 	if (!h)
 		return NULL;
 
+	/* - all _refs members are zero before freeing
+	 * - all list_head members point to themselves (empty lists) */
+
+	h->ctl_table_arg = NULL;
+	h->unregistering = NULL;
 	h->ctl_group = group;
-	INIT_LIST_HEAD(&h->ctl_entry);
-	INIT_LIST_HEAD(&h->ctl_subdirs);
-	INIT_LIST_HEAD(&h->ctl_tables);
+
 	return h;
 }
 
@@ -1905,12 +1935,12 @@ static struct ctl_table_header *sysctl_mkdirs(struct ctl_table_header *parent,
 		parent = mkdir_netns_corresp(parent, group, &__netns_corresp);
 
 	if (__netns_corresp)
-		kfree(__netns_corresp);
+		kmem_cache_free(sysctl_header_cachep, __netns_corresp);
 
 	/* free unused pre-allocated entries */
 	for (i = 0; i < nr_dirs; i++)
 		if (dirs[i])
-			kfree(dirs[i]);
+			kmem_cache_free(sysctl_header_cachep, dirs[i]);
 
 	return parent;
 
@@ -1918,7 +1948,7 @@ err_alloc_coresp:
 	i = nr_dirs;
 err_alloc_dir:
 	for (i--; i >= 0; i--)
-		kfree(dirs[i]);
+		kmem_cache_free(sysctl_header_cachep, dirs[i]);
 	return NULL;
 
 }
@@ -1991,7 +2021,7 @@ struct ctl_table_header *__register_sysctl_paths(struct ctl_table_group *group,
 
 	header->parent = sysctl_mkdirs(&root_table_header, group, path, nr_dirs);
 	if (!header->parent) {
-		kfree(header);
+		kmem_cache_free(sysctl_header_cachep, header);
 		return NULL;
 	}
 
-- 
1.7.5.134.g1c08b
