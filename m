From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 7/7] sysfs: @name comes before @ns
Date: Wed, 11 Sep 2013 22:29:09 -0400
Message-ID: <1378952949-7900-8-git-send-email-tj@kernel.org>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, kay@vrfy.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lizefan@huawei.com,
	Tejun Heo <tj@kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378952949-7900-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some internal sysfs functions which take explicit namespace argument
are weird in that they place the optional @ns in front of @name which
is contrary to the established convention.  This is confusing and
error-prone especially as @ns and @name may be interchanged without
causing compilation warning.

Swap the positions of @name and @ns in the following internal
functions.

 sysfs_find_dirent()
 sysfs_rename()
 sysfs_hash_and_remove()
 sysfs_name_hash()
 sysfs_name_compare()
 create_dir()

This patch doesn't introduce any functional changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Kay Sievers <kay@vrfy.org>
---
 fs/sysfs/bin.c     |  2 +-
 fs/sysfs/dir.c     | 45 +++++++++++++++++++++++----------------------
 fs/sysfs/file.c    | 10 +++++-----
 fs/sysfs/group.c   | 12 ++++++------
 fs/sysfs/inode.c   |  6 +++---
 fs/sysfs/symlink.c |  6 +++---
 fs/sysfs/sysfs.h   | 10 +++++-----
 7 files changed, 46 insertions(+), 45 deletions(-)

diff --git a/fs/sysfs/bin.c b/fs/sysfs/bin.c
index c590cab..d49e6ca 100644
--- a/fs/sysfs/bin.c
+++ b/fs/sysfs/bin.c
@@ -497,6 +497,6 @@ EXPORT_SYMBOL_GPL(sysfs_create_bin_file);
 void sysfs_remove_bin_file(struct kobject *kobj,
 			   const struct bin_attribute *attr)
 {
-	sysfs_hash_and_remove(kobj->sd, NULL, attr->attr.name);
+	sysfs_hash_and_remove(kobj->sd, attr->attr.name, NULL);
 }
 EXPORT_SYMBOL_GPL(sysfs_remove_bin_file);
diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 3dacce0..d41b555 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -35,12 +35,12 @@ static DEFINE_IDA(sysfs_ino_ida);
 
 /**
  *	sysfs_name_hash
- *	@ns:   Namespace tag to hash
  *	@name: Null terminated string to hash
+ *	@ns:   Namespace tag to hash
  *
  *	Returns 31 bit hash of ns + name (so it fits in an off_t )
  */
-static unsigned int sysfs_name_hash(const void *ns, const char *name)
+static unsigned int sysfs_name_hash(const char *name, const void *ns)
 {
 	unsigned long hash = init_name_hash();
 	unsigned int len = strlen(name);
@@ -56,8 +56,8 @@ static unsigned int sysfs_name_hash(const void *ns, const char *name)
 	return hash;
 }
 
-static int sysfs_name_compare(unsigned int hash, const void *ns,
-	const char *name, const struct sysfs_dirent *sd)
+static int sysfs_name_compare(unsigned int hash, const char *name,
+			      const void *ns, const struct sysfs_dirent *sd)
 {
 	if (hash != sd->s_hash)
 		return hash - sd->s_hash;
@@ -69,7 +69,7 @@ static int sysfs_name_compare(unsigned int hash, const void *ns,
 static int sysfs_sd_compare(const struct sysfs_dirent *left,
 			    const struct sysfs_dirent *right)
 {
-	return sysfs_name_compare(left->s_hash, left->s_ns, left->s_name,
+	return sysfs_name_compare(left->s_hash, left->s_name, left->s_ns,
 				  right);
 }
 
@@ -451,7 +451,7 @@ int __sysfs_add_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
 	struct sysfs_inode_attrs *ps_iattr;
 	int ret;
 
-	sd->s_hash = sysfs_name_hash(sd->s_ns, sd->s_name);
+	sd->s_hash = sysfs_name_hash(sd->s_name, sd->s_ns);
 	sd->s_parent = sysfs_get(acxt->parent_sd);
 
 	ret = sysfs_link_sibling(sd);
@@ -596,6 +596,7 @@ void sysfs_addrm_finish(struct sysfs_addrm_cxt *acxt)
  *	sysfs_find_dirent - find sysfs_dirent with the given name
  *	@parent_sd: sysfs_dirent to search under
  *	@name: name to look for
+ *	@ns: the namespace tag to use
  *
  *	Look for sysfs_dirent with name @name under @parent_sd.
  *
@@ -606,19 +607,19 @@ void sysfs_addrm_finish(struct sysfs_addrm_cxt *acxt)
  *	Pointer to sysfs_dirent if found, NULL if not.
  */
 struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
-				       const void *ns,
-				       const unsigned char *name)
+				       const unsigned char *name,
+				       const void *ns)
 {
 	struct rb_node *node = parent_sd->s_dir.children.rb_node;
 	unsigned int hash;
 
-	hash = sysfs_name_hash(ns, name);
+	hash = sysfs_name_hash(name, ns);
 	while (node) {
 		struct sysfs_dirent *sd;
 		int result;
 
 		sd = to_sysfs_dirent(node);
-		result = sysfs_name_compare(hash, ns, name, sd);
+		result = sysfs_name_compare(hash, name, ns, sd);
 		if (result < 0)
 			node = node->rb_left;
 		else if (result > 0)
@@ -651,7 +652,7 @@ struct sysfs_dirent *sysfs_get_dirent_ns(struct sysfs_dirent *parent_sd,
 	struct sysfs_dirent *sd;
 
 	mutex_lock(&sysfs_mutex);
-	sd = sysfs_find_dirent(parent_sd, ns, name);
+	sd = sysfs_find_dirent(parent_sd, name, ns);
 	sysfs_get(sd);
 	mutex_unlock(&sysfs_mutex);
 
@@ -660,7 +661,8 @@ struct sysfs_dirent *sysfs_get_dirent_ns(struct sysfs_dirent *parent_sd,
 EXPORT_SYMBOL_GPL(sysfs_get_dirent);
 
 static int create_dir(struct kobject *kobj, struct sysfs_dirent *parent_sd,
-	const void *ns, const char *name, struct sysfs_dirent **p_sd)
+		      const char *name, const void *ns,
+		      struct sysfs_dirent **p_sd)
 {
 	umode_t mode = S_IFDIR | S_IRWXU | S_IRUGO | S_IXUGO;
 	struct sysfs_addrm_cxt acxt;
@@ -691,7 +693,7 @@ static int create_dir(struct kobject *kobj, struct sysfs_dirent *parent_sd,
 int sysfs_create_subdir(struct kobject *kobj, const char *name,
 			struct sysfs_dirent **p_sd)
 {
-	return create_dir(kobj, kobj->sd, NULL, name, p_sd);
+	return create_dir(kobj, kobj->sd, name, NULL, p_sd);
 }
 
 /**
@@ -714,7 +716,7 @@ int sysfs_create_dir_ns(struct kobject *kobj, const void *ns)
 	if (!parent_sd)
 		return -ENOENT;
 
-	error = create_dir(kobj, parent_sd, ns, kobject_name(kobj), &sd);
+	error = create_dir(kobj, parent_sd, kobject_name(kobj), ns, &sd);
 	if (!error)
 		kobj->sd = sd;
 	return error;
@@ -735,7 +737,7 @@ static struct dentry *sysfs_lookup(struct inode *dir, struct dentry *dentry,
 	if (parent_sd->s_flags & SYSFS_FLAG_HAS_NS)
 		ns = sysfs_info(dir->i_sb)->ns;
 
-	sd = sysfs_find_dirent(parent_sd, ns, dentry->d_name.name);
+	sd = sysfs_find_dirent(parent_sd, dentry->d_name.name, ns);
 
 	/* no such entry */
 	if (!sd) {
@@ -823,9 +825,8 @@ void sysfs_remove_dir(struct kobject *kobj)
 	__sysfs_remove_dir(sd);
 }
 
-int sysfs_rename(struct sysfs_dirent *sd,
-	struct sysfs_dirent *new_parent_sd, const void *new_ns,
-	const char *new_name)
+int sysfs_rename(struct sysfs_dirent *sd, struct sysfs_dirent *new_parent_sd,
+		 const char *new_name, const void *new_ns)
 {
 	int error;
 
@@ -837,7 +838,7 @@ int sysfs_rename(struct sysfs_dirent *sd,
 		goto out;	/* nothing to rename */
 
 	error = -EEXIST;
-	if (sysfs_find_dirent(new_parent_sd, new_ns, new_name))
+	if (sysfs_find_dirent(new_parent_sd, new_name, new_ns))
 		goto out;
 
 	/* rename sysfs_dirent */
@@ -858,7 +859,7 @@ int sysfs_rename(struct sysfs_dirent *sd,
 	sysfs_get(new_parent_sd);
 	sysfs_put(sd->s_parent);
 	sd->s_ns = new_ns;
-	sd->s_hash = sysfs_name_hash(sd->s_ns, sd->s_name);
+	sd->s_hash = sysfs_name_hash(sd->s_name, sd->s_ns);
 	sd->s_parent = new_parent_sd;
 	sysfs_link_sibling(sd);
 
@@ -873,7 +874,7 @@ int sysfs_rename_dir_ns(struct kobject *kobj, const char *new_name,
 {
 	struct sysfs_dirent *parent_sd = kobj->sd->s_parent;
 
-	return sysfs_rename(kobj->sd, parent_sd, new_ns, new_name);
+	return sysfs_rename(kobj->sd, parent_sd, new_name, new_ns);
 }
 
 int sysfs_move_dir_ns(struct kobject *kobj, struct kobject *new_parent_kobj,
@@ -886,7 +887,7 @@ int sysfs_move_dir_ns(struct kobject *kobj, struct kobject *new_parent_kobj,
 	new_parent_sd = new_parent_kobj && new_parent_kobj->sd ?
 		new_parent_kobj->sd : &sysfs_root;
 
-	return sysfs_rename(sd, new_parent_sd, new_ns, sd->s_name);
+	return sysfs_rename(sd, new_parent_sd, sd->s_name, new_ns);
 }
 
 /* Relationship between s_mode and the DT_xxx types */
diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index 0f3214a..4697019 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -466,9 +466,9 @@ void sysfs_notify(struct kobject *k, const char *dir, const char *attr)
 	mutex_lock(&sysfs_mutex);
 
 	if (sd && dir)
-		sd = sysfs_find_dirent(sd, NULL, dir);
+		sd = sysfs_find_dirent(sd, dir, NULL);
 	if (sd && attr)
-		sd = sysfs_find_dirent(sd, NULL, attr);
+		sd = sysfs_find_dirent(sd, attr, NULL);
 	if (sd)
 		sysfs_notify_dirent(sd);
 
@@ -594,7 +594,7 @@ int sysfs_chmod_file(struct kobject *kobj, const struct attribute *attr,
 	mutex_lock(&sysfs_mutex);
 
 	rc = -ENOENT;
-	sd = sysfs_find_dirent(kobj->sd, NULL, attr->name);
+	sd = sysfs_find_dirent(kobj->sd, attr->name, NULL);
 	if (!sd)
 		goto out;
 
@@ -621,7 +621,7 @@ void sysfs_remove_file_ns(struct kobject *kobj, const struct attribute *attr,
 {
 	struct sysfs_dirent *dir_sd = kobj->sd;
 
-	sysfs_hash_and_remove(dir_sd, ns, attr->name);
+	sysfs_hash_and_remove(dir_sd, attr->name, ns);
 }
 EXPORT_SYMBOL_GPL(sysfs_remove_file_ns);
 
@@ -649,7 +649,7 @@ void sysfs_remove_file_from_group(struct kobject *kobj,
 	else
 		dir_sd = sysfs_get(kobj->sd);
 	if (dir_sd) {
-		sysfs_hash_and_remove(dir_sd, NULL, attr->name);
+		sysfs_hash_and_remove(dir_sd, attr->name, NULL);
 		sysfs_put(dir_sd);
 	}
 }
diff --git a/fs/sysfs/group.c b/fs/sysfs/group.c
index 2110215..2dae55c 100644
--- a/fs/sysfs/group.c
+++ b/fs/sysfs/group.c
@@ -26,7 +26,7 @@ static void remove_files(struct sysfs_dirent *dir_sd, struct kobject *kobj,
 
 	if (grp->attrs)
 		for (attr = grp->attrs; *attr; attr++)
-			sysfs_hash_and_remove(dir_sd, NULL, (*attr)->name);
+			sysfs_hash_and_remove(dir_sd, (*attr)->name, NULL);
 	if (grp->bin_attrs)
 		for (bin_attr = grp->bin_attrs; *bin_attr; bin_attr++)
 			sysfs_remove_bin_file(kobj, *bin_attr);
@@ -49,8 +49,8 @@ static int create_files(struct sysfs_dirent *dir_sd, struct kobject *kobj,
 			 * re-adding (if required) the file.
 			 */
 			if (update)
-				sysfs_hash_and_remove(dir_sd, NULL,
-						      (*attr)->name);
+				sysfs_hash_and_remove(dir_sd, (*attr)->name,
+						      NULL);
 			if (grp->is_visible) {
 				mode = grp->is_visible(kobj, *attr, i);
 				if (!mode)
@@ -270,7 +270,7 @@ int sysfs_merge_group(struct kobject *kobj,
 		error = sysfs_add_file(dir_sd, *attr, SYSFS_KOBJ_ATTR);
 	if (error) {
 		while (--i >= 0)
-			sysfs_hash_and_remove(dir_sd, NULL, (*--attr)->name);
+			sysfs_hash_and_remove(dir_sd, (*--attr)->name, NULL);
 	}
 	sysfs_put(dir_sd);
 
@@ -292,7 +292,7 @@ void sysfs_unmerge_group(struct kobject *kobj,
 	dir_sd = sysfs_get_dirent(kobj->sd, grp->name);
 	if (dir_sd) {
 		for (attr = grp->attrs; *attr; ++attr)
-			sysfs_hash_and_remove(dir_sd, NULL, (*attr)->name);
+			sysfs_hash_and_remove(dir_sd, (*attr)->name, NULL);
 		sysfs_put(dir_sd);
 	}
 }
@@ -335,7 +335,7 @@ void sysfs_remove_link_from_group(struct kobject *kobj, const char *group_name,
 
 	dir_sd = sysfs_get_dirent(kobj->sd, group_name);
 	if (dir_sd) {
-		sysfs_hash_and_remove(dir_sd, NULL, link_name);
+		sysfs_hash_and_remove(dir_sd, link_name, NULL);
 		sysfs_put(dir_sd);
 	}
 }
diff --git a/fs/sysfs/inode.c b/fs/sysfs/inode.c
index 963f910..07193d7 100644
--- a/fs/sysfs/inode.c
+++ b/fs/sysfs/inode.c
@@ -314,8 +314,8 @@ void sysfs_evict_inode(struct inode *inode)
 	sysfs_put(sd);
 }
 
-int sysfs_hash_and_remove(struct sysfs_dirent *dir_sd, const void *ns,
-			  const char *name)
+int sysfs_hash_and_remove(struct sysfs_dirent *dir_sd, const char *name,
+			  const void *ns)
 {
 	struct sysfs_addrm_cxt acxt;
 	struct sysfs_dirent *sd;
@@ -328,7 +328,7 @@ int sysfs_hash_and_remove(struct sysfs_dirent *dir_sd, const void *ns,
 
 	sysfs_addrm_start(&acxt, dir_sd);
 
-	sd = sysfs_find_dirent(dir_sd, ns, name);
+	sd = sysfs_find_dirent(dir_sd, name, ns);
 	if (sd)
 		sysfs_remove_one(&acxt, sd);
 
diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index c96b31a..88c8bc5 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -144,7 +144,7 @@ void sysfs_delete_link(struct kobject *kobj, struct kobject *targ,
 	if (targ->sd)
 		ns = targ->sd->s_ns;
 	spin_unlock(&sysfs_assoc_lock);
-	sysfs_hash_and_remove(kobj->sd, ns, name);
+	sysfs_hash_and_remove(kobj->sd, name, ns);
 }
 
 /**
@@ -161,7 +161,7 @@ void sysfs_remove_link(struct kobject *kobj, const char *name)
 	else
 		parent_sd = kobj->sd;
 
-	sysfs_hash_and_remove(parent_sd, NULL, name);
+	sysfs_hash_and_remove(parent_sd, name, NULL);
 }
 EXPORT_SYMBOL_GPL(sysfs_remove_link);
 
@@ -201,7 +201,7 @@ int sysfs_rename_link_ns(struct kobject *kobj, struct kobject *targ,
 	if (sd->s_symlink.target_sd->s_dir.kobj != targ)
 		goto out;
 
-	result = sysfs_rename(sd, parent_sd, new_ns, new);
+	result = sysfs_rename(sd, parent_sd, new, new_ns);
 
 out:
 	sysfs_put(sd);
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 6faacaf..ee44fde 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -162,8 +162,8 @@ void sysfs_remove_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd);
 void sysfs_addrm_finish(struct sysfs_addrm_cxt *acxt);
 
 struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
-				       const void *ns,
-				       const unsigned char *name);
+				       const unsigned char *name,
+				       const void *ns);
 struct sysfs_dirent *sysfs_new_dirent(const char *name, umode_t mode, int type);
 
 void release_sysfs_dirent(struct sysfs_dirent *sd);
@@ -173,7 +173,7 @@ int sysfs_create_subdir(struct kobject *kobj, const char *name,
 void sysfs_remove_subdir(struct sysfs_dirent *sd);
 
 int sysfs_rename(struct sysfs_dirent *sd, struct sysfs_dirent *new_parent_sd,
-		 const void *ns, const char *new_name);
+		 const char *new_name, const void *new_ns);
 
 static inline struct sysfs_dirent *__sysfs_get(struct sysfs_dirent *sd)
 {
@@ -204,8 +204,8 @@ int sysfs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 		  struct kstat *stat);
 int sysfs_setxattr(struct dentry *dentry, const char *name, const void *value,
 		   size_t size, int flags);
-int sysfs_hash_and_remove(struct sysfs_dirent *dir_sd, const void *ns,
-			  const char *name);
+int sysfs_hash_and_remove(struct sysfs_dirent *dir_sd, const char *name,
+			  const void *ns);
 int sysfs_inode_init(void);
 
 /*
-- 
1.8.3.1
