From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 5/7] sysfs: drop kobj_ns_type handling
Date: Wed, 11 Sep 2013 22:29:07 -0400
Message-ID: <1378952949-7900-6-git-send-email-tj@kernel.org>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, kay@vrfy.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lizefan@huawei.com,
	Tejun Heo <tj@kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:56256 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757614Ab3ILC31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 22:29:27 -0400
In-Reply-To: <1378952949-7900-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The way namespace tags are implemented in sysfs is more complicated
than necessary.  As each tag is a pointer value and required to be
non-NULL under a namespace enabled parent, there's no need to record
separately what type each tag is or where namespace is enabled.

If multiple namespace types are needed, which currently aren't, we can
simply compare the tag to a set of allowed tags in the superblock
assuming that the tags, being pointers, won't have the same value
across multiple types.  Also, whether to filter by namespace tag or
not can be trivially determined by whether the node has any tagged
children or not.

This patch rips out kobj_ns_type handling from sysfs.  sysfs no longer
cares whether specific type of namespace is enabled or not.  If a
sysfs_dirent has a non-NULL tag, the parent is marked as needing
namespace filtering and the value is tested against the allowed set of
tags for the superblock (currently only one but increasing this number
isn't difficult) and the sysfs_dirent is ignored if it doesn't match.

This removes most kobject namespace knowledge from sysfs proper which
will enable proper separation and layering of sysfs.  The namespace
sanity checks in fs/sysfs/dir.c are replaced by the new sanity check
in kobject_namespace().  As this is the only place ktype->namespace()
is called for sysfs, this doesn't weaken the sanity check
significantly.  I omitted converting the sanity check in
sysfs_do_create_link_sd().  While the check can be shifted to upper
layer, mistakes there are well contained and should be easily visible
anyway.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Kay Sievers <kay@vrfy.org>
---
 fs/sysfs/dir.c     | 90 +++++++++++++++---------------------------------------
 fs/sysfs/mount.c   | 24 ++++-----------
 fs/sysfs/symlink.c | 27 ++++------------
 fs/sysfs/sysfs.h   | 25 +++++----------
 lib/kobject.c      |  5 ++-
 5 files changed, 48 insertions(+), 123 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 878ac3a..1dfb4aa 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -111,6 +111,11 @@ static int sysfs_link_sibling(struct sysfs_dirent *sd)
 	/* add new node and rebalance the tree */
 	rb_link_node(&sd->s_rb, parent, node);
 	rb_insert_color(&sd->s_rb, &sd->s_parent->s_dir.children);
+
+	/* if @sd has ns tag, mark the parent to enable ns filtering */
+	if (sd->s_ns)
+		sd->s_parent->s_flags |= SYSFS_FLAG_HAS_NS;
+
 	return 0;
 }
 
@@ -130,6 +135,13 @@ static void sysfs_unlink_sibling(struct sysfs_dirent *sd)
 		sd->s_parent->s_dir.subdirs--;
 
 	rb_erase(&sd->s_rb, &sd->s_parent->s_dir.children);
+
+	/*
+	 * Either all or none of the children have tags.  Clearing HAS_NS
+	 * when there's no child left is enough to keep the flag synced.
+	 */
+	if (RB_EMPTY_ROOT(&sd->s_parent->s_dir.children))
+		sd->s_parent->s_flags &= ~SYSFS_FLAG_HAS_NS;
 }
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
@@ -297,7 +309,6 @@ static int sysfs_dentry_delete(const struct dentry *dentry)
 static int sysfs_dentry_revalidate(struct dentry *dentry, unsigned int flags)
 {
 	struct sysfs_dirent *sd;
-	int type;
 
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
@@ -318,13 +329,8 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, unsigned int flags)
 		goto out_bad;
 
 	/* The sysfs dirent has been moved to a different namespace */
-	type = KOBJ_NS_TYPE_NONE;
-	if (sd->s_parent) {
-		type = sysfs_ns_type(sd->s_parent);
-		if (type != KOBJ_NS_TYPE_NONE &&
-				sysfs_info(dentry->d_sb)->ns[type] != sd->s_ns)
-			goto out_bad;
-	}
+	if (sd->s_ns && sd->s_ns != sysfs_info(dentry->d_sb)->ns)
+		goto out_bad;
 
 	mutex_unlock(&sysfs_mutex);
 out_valid:
@@ -445,13 +451,6 @@ int __sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
 	struct sysfs_inode_attrs *ps_iattr;
 	int ret;
 
-	if (!!sysfs_ns_type(acxt->parent_sd) != !!sd->s_ns) {
-		WARN(1, KERN_WARNING "sysfs: ns %s in '%s' for '%s'\n",
-			sysfs_ns_type(acxt->parent_sd) ? "required" : "invalid",
-			acxt->parent_sd->s_name, sd->s_name);
-		return -EINVAL;
-	}
-
 	sd->s_hash = sysfs_name_hash(sd->s_ns, sd->s_name);
 	sd->s_parent = sysfs_get(acxt->parent_sd);
 
@@ -613,13 +612,6 @@ struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
 	struct rb_node *node = parent_sd->s_dir.children.rb_node;
 	unsigned int hash;
 
-	if (!!sysfs_ns_type(parent_sd) != !!ns) {
-		WARN(1, KERN_WARNING "sysfs: ns %s in '%s' for '%s'\n",
-			sysfs_ns_type(parent_sd) ? "required" : "invalid",
-			parent_sd->s_name, name);
-		return NULL;
-	}
-
 	hash = sysfs_name_hash(ns, name);
 	while (node) {
 		struct sysfs_dirent *sd;
@@ -667,8 +659,7 @@ struct sysfs_dirent *sysfs_get_dirent(struct sysfs_dirent *parent_sd,
 EXPORT_SYMBOL_GPL(sysfs_get_dirent);
 
 static int create_dir(struct kobject *kobj, struct sysfs_dirent *parent_sd,
-	enum kobj_ns_type type, const void *ns, const char *name,
-	struct sysfs_dirent **p_sd)
+	const void *ns, const char *name, struct sysfs_dirent **p_sd)
 {
 	umode_t mode = S_IFDIR | S_IRWXU | S_IRUGO | S_IXUGO;
 	struct sysfs_addrm_cxt acxt;
@@ -680,7 +671,6 @@ static int create_dir(struct kobject *kobj, struct sysfs_dirent *parent_sd,
 	if (!sd)
 		return -ENOMEM;
 
-	sd->s_flags |= (type << SYSFS_NS_TYPE_SHIFT);
 	sd->s_ns = ns;
 	sd->s_dir.kobj = kobj;
 
@@ -700,33 +690,7 @@ static int create_dir(struct kobject *kobj, struct sysfs_dirent *parent_sd,
 int sysfs_create_subdir(struct kobject *kobj, const char *name,
 			struct sysfs_dirent **p_sd)
 {
-	return create_dir(kobj, kobj->sd,
-			  KOBJ_NS_TYPE_NONE, NULL, name, p_sd);
-}
-
-/**
- *	sysfs_read_ns_type: return associated ns_type
- *	@kobj: the kobject being queried
- *
- *	Each kobject can be tagged with exactly one namespace type
- *	(i.e. network or user).  Return the ns_type associated with
- *	this object if any
- */
-static enum kobj_ns_type sysfs_read_ns_type(struct kobject *kobj)
-{
-	const struct kobj_ns_type_operations *ops;
-	enum kobj_ns_type type;
-
-	ops = kobj_child_ns_ops(kobj);
-	if (!ops)
-		return KOBJ_NS_TYPE_NONE;
-
-	type = ops->type;
-	BUG_ON(type <= KOBJ_NS_TYPE_NONE);
-	BUG_ON(type >= KOBJ_NS_TYPES);
-	BUG_ON(!kobj_ns_type_registered(type));
-
-	return type;
+	return create_dir(kobj, kobj->sd, NULL, name, p_sd);
 }
 
 /**
@@ -736,7 +700,6 @@ static enum kobj_ns_type sysfs_read_ns_type(struct kobject *kobj)
  */
 int sysfs_create_dir_ns(struct kobject *kobj, const void *ns)
 {
-	enum kobj_ns_type type;
 	struct sysfs_dirent *parent_sd, *sd;
 	int error = 0;
 
@@ -750,9 +713,7 @@ int sysfs_create_dir_ns(struct kobject *kobj, const void *ns)
 	if (!parent_sd)
 		return -ENOENT;
 
-	type = sysfs_read_ns_type(kobj);
-
-	error = create_dir(kobj, parent_sd, type, ns, kobject_name(kobj), &sd);
+	error = create_dir(kobj, parent_sd, ns, kobject_name(kobj), &sd);
 	if (!error)
 		kobj->sd = sd;
 	return error;
@@ -766,13 +727,12 @@ static struct dentry *sysfs_lookup(struct inode *dir, struct dentry *dentry,
 	struct sysfs_dirent *parent_sd = parent->d_fsdata;
 	struct sysfs_dirent *sd;
 	struct inode *inode;
-	enum kobj_ns_type type;
-	const void *ns;
+	const void *ns = NULL;
 
 	mutex_lock(&sysfs_mutex);
 
-	type = sysfs_ns_type(parent_sd);
-	ns = sysfs_info(dir->i_sb)->ns[type];
+	if (parent_sd->s_flags & SYSFS_FLAG_HAS_NS)
+		ns = sysfs_info(dir->i_sb)->ns;
 
 	sd = sysfs_find_dirent(parent_sd, ns, dentry->d_name.name);
 
@@ -995,15 +955,15 @@ static int sysfs_readdir(struct file *file, struct dir_context *ctx)
 	struct dentry *dentry = file->f_path.dentry;
 	struct sysfs_dirent *parent_sd = dentry->d_fsdata;
 	struct sysfs_dirent *pos = file->private_data;
-	enum kobj_ns_type type;
-	const void *ns;
-
-	type = sysfs_ns_type(parent_sd);
-	ns = sysfs_info(dentry->d_sb)->ns[type];
+	const void *ns = NULL;
 
 	if (!dir_emit_dots(file, ctx))
 		return 0;
 	mutex_lock(&sysfs_mutex);
+
+	if (parent_sd->s_flags & SYSFS_FLAG_HAS_NS)
+		ns = sysfs_info(dentry->d_sb)->ns;
+
 	for (pos = sysfs_dir_pos(ns, parent_sd, ctx->pos, pos);
 	     pos;
 	     pos = sysfs_dir_next_pos(ns, parent_sd, ctx->pos, pos)) {
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index 834ec2c..8c24bce 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -36,7 +36,7 @@ static const struct super_operations sysfs_ops = {
 struct sysfs_dirent sysfs_root = {
 	.s_name		= "",
 	.s_count	= ATOMIC_INIT(1),
-	.s_flags	= SYSFS_DIR | (KOBJ_NS_TYPE_NONE << SYSFS_NS_TYPE_SHIFT),
+	.s_flags	= SYSFS_DIR,
 	.s_mode		= S_IFDIR | S_IRUGO | S_IXUGO,
 	.s_ino		= 1,
 };
@@ -77,14 +77,8 @@ static int sysfs_test_super(struct super_block *sb, void *data)
 {
 	struct sysfs_super_info *sb_info = sysfs_info(sb);
 	struct sysfs_super_info *info = data;
-	enum kobj_ns_type type;
-	int found = 1;
 
-	for (type = KOBJ_NS_TYPE_NONE; type < KOBJ_NS_TYPES; type++) {
-		if (sb_info->ns[type] != info->ns[type])
-			found = 0;
-	}
-	return found;
+	return sb_info->ns == info->ns;
 }
 
 static int sysfs_set_super(struct super_block *sb, void *data)
@@ -98,9 +92,7 @@ static int sysfs_set_super(struct super_block *sb, void *data)
 
 static void free_sysfs_super_info(struct sysfs_super_info *info)
 {
-	int type;
-	for (type = KOBJ_NS_TYPE_NONE; type < KOBJ_NS_TYPES; type++)
-		kobj_ns_drop(type, info->ns[type]);
+	kobj_ns_drop(KOBJ_NS_TYPE_NET, info->ns);
 	kfree(info);
 }
 
@@ -108,7 +100,6 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
 	struct sysfs_super_info *info;
-	enum kobj_ns_type type;
 	struct super_block *sb;
 	int error;
 
@@ -116,18 +107,15 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
 		if (!capable(CAP_SYS_ADMIN) && !fs_fully_visible(fs_type))
 			return ERR_PTR(-EPERM);
 
-		for (type = KOBJ_NS_TYPE_NONE; type < KOBJ_NS_TYPES; type++) {
-			if (!kobj_ns_current_may_mount(type))
-				return ERR_PTR(-EPERM);
-		}
+		if (!kobj_ns_current_may_mount(KOBJ_NS_TYPE_NET))
+			return ERR_PTR(-EPERM);
 	}
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info)
 		return ERR_PTR(-ENOMEM);
 
-	for (type = KOBJ_NS_TYPE_NONE; type < KOBJ_NS_TYPES; type++)
-		info->ns[type] = kobj_ns_grab_current(type);
+	info->ns = kobj_ns_grab_current(KOBJ_NS_TYPE_NET);
 
 	sb = sget(fs_type, sysfs_test_super, sysfs_set_super, flags, info);
 	if (IS_ERR(sb) || sb->s_fs_info != info)
diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index 12d58ad..7d981ce 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -28,7 +28,6 @@ static int sysfs_do_create_link_sd(struct sysfs_dirent *parent_sd,
 	struct sysfs_dirent *target_sd = NULL;
 	struct sysfs_dirent *sd = NULL;
 	struct sysfs_addrm_cxt acxt;
-	enum kobj_ns_type ns_type;
 	int error;
 
 	BUG_ON(!name || !parent_sd);
@@ -50,29 +49,15 @@ static int sysfs_do_create_link_sd(struct sysfs_dirent *parent_sd,
 	if (!sd)
 		goto out_put;
 
-	ns_type = sysfs_ns_type(parent_sd);
-	if (ns_type)
-		sd->s_ns = target_sd->s_ns;
+	sd->s_ns = target_sd->s_ns;
 	sd->s_symlink.target_sd = target_sd;
 	target_sd = NULL;	/* reference is now owned by the symlink */
 
 	sysfs_addrm_start(&acxt, parent_sd);
-	/* Symlinks must be between directories with the same ns_type */
-	if (!ns_type ||
-	    (ns_type == sysfs_ns_type(sd->s_symlink.target_sd->s_parent))) {
-		if (warn)
-			error = sysfs_add_one(&acxt, sd);
-		else
-			error = __sysfs_add_one(&acxt, sd);
-	} else {
-		error = -EINVAL;
-		WARN(1, KERN_WARNING
-			"sysfs: symlink across ns_types %s/%s -> %s/%s\n",
-			parent_sd->s_name,
-			sd->s_name,
-			sd->s_symlink.target_sd->s_parent->s_name,
-			sd->s_symlink.target_sd->s_name);
-	}
+	if (warn)
+		error = sysfs_add_one(&acxt, sd);
+	else
+		error = __sysfs_add_one(&acxt, sd);
 	sysfs_addrm_finish(&acxt);
 
 	if (error)
@@ -156,7 +141,7 @@ void sysfs_delete_link(struct kobject *kobj, struct kobject *targ,
 {
 	const void *ns = NULL;
 	spin_lock(&sysfs_assoc_lock);
-	if (targ->sd && sysfs_ns_type(kobj->sd))
+	if (targ->sd)
 		ns = targ->sd->s_ns;
 	spin_unlock(&sysfs_assoc_lock);
 	sysfs_hash_and_remove(kobj->sd, ns, name);
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index a96da25..7664d1b 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -93,11 +93,8 @@ struct sysfs_dirent {
 #define SYSFS_COPY_NAME			(SYSFS_DIR | SYSFS_KOBJ_LINK)
 #define SYSFS_ACTIVE_REF		(SYSFS_KOBJ_ATTR | SYSFS_KOBJ_BIN_ATTR)
 
-/* identify any namespace tag on sysfs_dirents */
-#define SYSFS_NS_TYPE_MASK		0xf00
-#define SYSFS_NS_TYPE_SHIFT		8
-
-#define SYSFS_FLAG_MASK			~(SYSFS_NS_TYPE_MASK|SYSFS_TYPE_MASK)
+#define SYSFS_FLAG_MASK			~SYSFS_TYPE_MASK
+#define SYSFS_FLAG_HAS_NS		0x01000
 #define SYSFS_FLAG_REMOVED		0x02000
 
 static inline unsigned int sysfs_type(struct sysfs_dirent *sd)
@@ -105,15 +102,6 @@ static inline unsigned int sysfs_type(struct sysfs_dirent *sd)
 	return sd->s_flags & SYSFS_TYPE_MASK;
 }
 
-/*
- * Return any namespace tags on this dirent.
- * enum kobj_ns_type is defined in linux/kobject.h
- */
-static inline enum kobj_ns_type sysfs_ns_type(struct sysfs_dirent *sd)
-{
-	return (sd->s_flags & SYSFS_NS_TYPE_MASK) >> SYSFS_NS_TYPE_SHIFT;
-}
-
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 #define sysfs_dirent_init_lockdep(sd)				\
 do {								\
@@ -141,12 +129,13 @@ struct sysfs_addrm_cxt {
  */
 
 /*
- * Each sb is associated with a set of namespace tags (i.e.
- * the network namespace of the task which mounted this sysfs
- * instance).
+ * Each sb is associated with one namespace tag, currently the network
+ * namespace of the task which mounted this sysfs instance.  If multiple
+ * tags become necessary, make the following an array and compare
+ * sysfs_dirent tag against every entry.
  */
 struct sysfs_super_info {
-	void *ns[KOBJ_NS_TYPES];
+	void *ns;
 };
 #define sysfs_info(SB) ((struct sysfs_super_info *)(SB->s_fs_info))
 extern struct sysfs_dirent sysfs_root;
diff --git a/lib/kobject.c b/lib/kobject.c
index 85fb3a1..e769ee3 100644
--- a/lib/kobject.c
+++ b/lib/kobject.c
@@ -29,11 +29,14 @@
 const void *kobject_namespace(struct kobject *kobj)
 {
 	const struct kobj_ns_type_operations *ns_ops = kobj_ns_ops(kobj);
+	const void *ns;
 
 	if (!ns_ops || ns_ops->type == KOBJ_NS_TYPE_NONE)
 		return NULL;
 
-	return kobj->ktype->namespace(kobj);
+	ns = kobj->ktype->namespace(kobj);
+	WARN_ON(!ns);	/* @kobj in a namespace is required to have !NULL tag */
+	return ns;
 }
 
 /*
-- 
1.8.3.1
