From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 090/115] sysctl: warn if registration/unregistration order is not respected
Date: Mon,  9 May 2011 00:39:42 +0200
Message-ID: <1304894407-32201-91-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40833 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932617Ab1EHWmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:42:15 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sends a warning for each sysctl unregistration that cannot
delete all the directories that it created.

For example:
- register   /existingdir/newdir/file-a
- register   /existingdir/newdir/dir3/file-b
- unregister /existingdir/newdir/file-a
- unregister /existingdir/newdir/dir3/file-b

Here the order is violated because the first unregister operation
cannot delete all the directories it has created (namely 'newdir')
because they are used by another registered path.

This rule violation can be fixed in (at least) two ways:

- enforce order of unregistration:
  - register   /existingdir/newdir/file-a
  - register   /existingdir/newdir/dir3/file-b
  - unregister /existingdir/newdir/dir3/file-b
  - unregister /existingdir/newdir/file-a

- have a third party register the common part:
  - register   /existingdir/newdir/
  - register   /existingdir/newdir/file-a
  - register   /existingdir/newdir/dir3/file-b
  - unregister /existingdir/newdir/file-a
  - unregister /existingdir/newdir/dir3/file-b
  - unregister /existingdir/newdir/

The current implementation works well regardless of this order being
respected. In the future, other sysctl implementations may only work
if this rule is respected.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/sysctl.h |   15 ++++++++++++---
 kernel/sysctl.c        |   39 +++++++++++++++++++++++++++++++++++----
 2 files changed, 47 insertions(+), 7 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index d5d9b66f..322246d 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1036,12 +1036,14 @@ struct ctl_table_group_ops {
 };
 
 struct ctl_table_group {
+	/* has initialization for this group finished? */
+	int is_initialized:1;
+	/* does this group use the @corresp_list? */
+	int has_netns_corresp:1;
+	struct list_head corresp_list;
 	const struct ctl_table_group_ops *ctl_ops;
 	/* A list of ctl_table_header elements that represent the
 	 * netns-specific correspondents of some sysctl directories */
-	struct list_head corresp_list;
-	/* binary: whether this group uses the @corresp_list */
-	char has_netns_corresp;
 };
 
 /* struct ctl_table_header is used to maintain dynamic lists of
@@ -1069,6 +1071,13 @@ struct ctl_table_header {
 			 * the max value of this is the number of files in the
 			 * ctl_table array, or 1 for directories. */
 			u8 ctl_procfs_refs;
+			/* how many dirs were created when this header was
+			 * registered. Rule: the header which created a directory
+			 * should be the one that deletes it. This counter is
+			 * used to signal violations of this rule. The counter's
+			 * max value is CTL_MAXNAME (currently=10) so we use
+			 * only 4 bits of the 8 available. */
+			u8 ctl_owned_dirs_refs;
 		};
 		struct rcu_head rcu;
 	};
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 3e30e78..94fff4e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -204,8 +204,9 @@ static struct kmem_cache *sysctl_header_cachep;
 static const struct ctl_table_group_ops root_table_group_ops = { };
 
 static struct ctl_table_group root_table_group = {
-	.has_netns_corresp = 0,
-	.ctl_ops = &root_table_group_ops,
+	.is_initialized		= 1,
+	.has_netns_corresp	= 0,
+	.ctl_ops		= &root_table_group_ops,
 };
 
 static struct ctl_table_header root_table_header = {
@@ -1617,6 +1618,14 @@ out:
 struct ctl_table_header *sysctl_use_netns_corresp(struct ctl_table_header *h)
 {
 	struct ctl_table_group *g = &current->nsproxy->net_ns->netns_ctl_group;
+
+	/* this function may be called to check whether the
+	 * netns-specific vs. non-netns-specific registration order is
+	 * respected. Those checks may be done early during init when
+	 * nor init_net is not initialized, nor it's netns-specific group. */
+	if (!g->is_initialized)
+		return NULL;
+
 	/* dflt == NULL means: if there's a netns corresp return it,
 	 *                     if there isn't, just return NULL */
 	return sysctl_use_netns_corresp_dflt(g, h, NULL);
@@ -1869,13 +1878,14 @@ static struct ctl_table_header *mkdir_new_dir(struct ctl_table_header *parent,
 static struct ctl_table_header *sysctl_mkdirs(struct ctl_table_header *parent,
 					      struct ctl_table_group *group,
 					      const struct ctl_path *path,
-					      int nr_dirs)
+					      int nr_dirs, int *p_dirs_created)
 {
 	struct ctl_table_header *dirs[CTL_MAXNAME];
 	struct ctl_table_header *__netns_corresp = NULL;
 	int create_first_netns_corresp = group->has_netns_corresp;
 	int i;
 
+	*p_dirs_created = 0;
 	/* We create excess ctl_table_header for directory entries.
 	 * We do so because we may need new headers while under a lock
 	 * where we will not be able to allocate entries (sleeping).
@@ -1929,6 +1939,7 @@ static struct ctl_table_header *sysctl_mkdirs(struct ctl_table_header *parent,
 				goto err_check_netns_correspondents;
 			}
 #endif
+			(*p_dirs_created)++;
 			continue;
 		}
 
@@ -1945,8 +1956,12 @@ static struct ctl_table_header *sysctl_mkdirs(struct ctl_table_header *parent,
 	if (create_first_netns_corresp)
 		parent = mkdir_netns_corresp(parent, group, &__netns_corresp);
 
+	/* if mkdir_netns_corresp used it, it's NULL */
 	if (__netns_corresp)
 		kmem_cache_free(sysctl_header_cachep, __netns_corresp);
+	else
+		(*p_dirs_created)++;
+
 
 	/* free unused pre-allocated entries */
 	for (i = 0; i < nr_dirs; i++)
@@ -2027,6 +2042,7 @@ struct ctl_table_header *__register_sysctl_paths(struct ctl_table_group *group,
 	struct ctl_table_header *header;
 	int failed_duplicate_check = 0;
 	int nr_dirs = ctl_path_items(path);
+	int dirs_created = 0;
 
 #ifdef CONFIG_SYSCTL_SYSCALL_CHECK
 	if (sysctl_check_table(path, nr_dirs, table))
@@ -2037,7 +2053,8 @@ struct ctl_table_header *__register_sysctl_paths(struct ctl_table_group *group,
 	if (!header)
 		return NULL;
 
-	header->parent = sysctl_mkdirs(&root_table_header, group, path, nr_dirs);
+	header->parent = sysctl_mkdirs(&root_table_header, group, path,
+				       nr_dirs, &dirs_created);
 	if (!header->parent) {
 		kmem_cache_free(sysctl_header_cachep, header);
 		return NULL;
@@ -2045,6 +2062,7 @@ struct ctl_table_header *__register_sysctl_paths(struct ctl_table_group *group,
 
 	header->ctl_table_arg = table;
 	header->ctl_header_refs = 1;
+	header->ctl_owned_dirs_refs = dirs_created;
 
 	sysctl_write_lock_head(header->parent);
 
@@ -2089,6 +2107,7 @@ struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
  */
 void unregister_sysctl_table(struct ctl_table_header *header)
 {
+	int dirs_to_delete = header->ctl_owned_dirs_refs;
 	might_sleep();
 
 	while(header->parent) {
@@ -2098,6 +2117,13 @@ void unregister_sysctl_table(struct ctl_table_header *header)
 		 * and ctl_use_refs) are protected by the spin lock. */
 		spin_lock(&sysctl_lock);
 		if (header->ctl_header_refs > 1) {
+			if (WARN(dirs_to_delete != 0, "directory that we "
+				 "created is still used by another header.")) {
+				/* if one element of the path is still used it's
+				 * parents will be too. Stop sending warnings */
+				dirs_to_delete = 0;
+			}
+
 			/* other headers need a reference to this one. Just
 			 * mark that we don't need it and leave it as it is. */
 			header->ctl_header_refs --;
@@ -2116,6 +2142,10 @@ void unregister_sysctl_table(struct ctl_table_header *header)
 		start_unregistering(header);
 		spin_unlock(&sysctl_lock);
 
+		/* don't go negative */
+		if (dirs_to_delete)
+			dirs_to_delete --;
+
 		if (!header->ctl_dirname) {
 			/* the header is a netns correspondent of it's
 			 * parent. It is a member of it's netns
@@ -2173,6 +2203,7 @@ void sysctl_init_group(struct ctl_table_group *group,
 	group->has_netns_corresp = has_netns_corresp;
 	if (has_netns_corresp)
 		INIT_LIST_HEAD(&group->corresp_list);
+	group->is_initialized = 1;
 }
 
 #else /* !CONFIG_SYSCTL */
-- 
1.7.5.134.g1c08b

