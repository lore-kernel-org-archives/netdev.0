From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH 1/5] kernfs: allow creating kernfs objects with arbitrary uid/gid
Date: Tue, 16 Aug 2016 15:33:11 -0700
Message-ID: <1471386795-32918-2-git-send-email-dmitry.torokhov@gmail.com>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change allows creating kernfs files and directories with arbitrary
uid/gid instead of always using GLOBAL_ROOT_UID/GID by extending
kernfs_create_dir_ns() and kernfs_create_file_ns() with uid/gid arguments.
The "simple" kernfs_create_file() and kernfs_create_dir() are left alone
and always create objects belonging to the global root.

When creating symlinks ownership (uid/gid) is taken from the target kernfs
object.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 fs/kernfs/dir.c             | 29 ++++++++++++++++++++++++++---
 fs/kernfs/file.c            |  8 ++++++--
 fs/kernfs/inode.c           |  2 +-
 fs/kernfs/kernfs-internal.h |  2 ++
 fs/kernfs/symlink.c         | 11 ++++++++++-
 fs/sysfs/dir.c              |  4 +++-
 fs/sysfs/file.c             |  5 +++--
 include/linux/kernfs.h      | 28 +++++++++++++++++++---------
 kernel/cgroup.c             |  4 +++-
 9 files changed, 73 insertions(+), 20 deletions(-)

diff --git a/fs/kernfs/dir.c b/fs/kernfs/dir.c
index 8a65240..67c276a 100644
--- a/fs/kernfs/dir.c
+++ b/fs/kernfs/dir.c
@@ -657,6 +657,7 @@ struct kernfs_node *kernfs_node_from_dentry(struct dentry *dentry)
 
 static struct kernfs_node *__kernfs_new_node(struct kernfs_root *root,
 					     const char *name, umode_t mode,
+					     kuid_t uid, kgid_t gid,
 					     unsigned flags)
 {
 	struct kernfs_node *kn;
@@ -683,8 +684,22 @@ static struct kernfs_node *__kernfs_new_node(struct kernfs_root *root,
 	kn->mode = mode;
 	kn->flags = flags;
 
+	if (!uid_eq(uid, GLOBAL_ROOT_UID) || !gid_eq(gid, GLOBAL_ROOT_GID)) {
+		struct iattr iattr = {
+			.ia_valid = ATTR_UID | ATTR_GID,
+			.ia_uid = uid,
+			.ia_gid = gid,
+		};
+
+		ret = __kernfs_setattr(kn, &iattr);
+		if (ret < 0)
+			goto err_out3;
+	}
+
 	return kn;
 
+ err_out3:
+	ida_simple_remove(&root->ino_ida, kn->ino);
  err_out2:
 	kmem_cache_free(kernfs_node_cache, kn);
  err_out1:
@@ -694,11 +709,13 @@ static struct kernfs_node *__kernfs_new_node(struct kernfs_root *root,
 
 struct kernfs_node *kernfs_new_node(struct kernfs_node *parent,
 				    const char *name, umode_t mode,
+				    kuid_t uid, kgid_t gid,
 				    unsigned flags)
 {
 	struct kernfs_node *kn;
 
-	kn = __kernfs_new_node(kernfs_root(parent), name, mode, flags);
+	kn = __kernfs_new_node(kernfs_root(parent),
+			       name, mode, uid, gid, flags);
 	if (kn) {
 		kernfs_get(parent);
 		kn->parent = parent;
@@ -919,6 +936,7 @@ struct kernfs_root *kernfs_create_root(struct kernfs_syscall_ops *scops,
 	INIT_LIST_HEAD(&root->supers);
 
 	kn = __kernfs_new_node(root, "", S_IFDIR | S_IRUGO | S_IXUGO,
+			       GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
 			       KERNFS_DIR);
 	if (!kn) {
 		ida_destroy(&root->ino_ida);
@@ -957,6 +975,8 @@ void kernfs_destroy_root(struct kernfs_root *root)
  * @parent: parent in which to create a new directory
  * @name: name of the new directory
  * @mode: mode of the new directory
+ * @uid: uid of the new directory
+ * @gid: gid of the new directory
  * @priv: opaque data associated with the new directory
  * @ns: optional namespace tag of the directory
  *
@@ -964,13 +984,15 @@ void kernfs_destroy_root(struct kernfs_root *root)
  */
 struct kernfs_node *kernfs_create_dir_ns(struct kernfs_node *parent,
 					 const char *name, umode_t mode,
+					 kuid_t uid, kgid_t gid,
 					 void *priv, const void *ns)
 {
 	struct kernfs_node *kn;
 	int rc;
 
 	/* allocate */
-	kn = kernfs_new_node(parent, name, mode | S_IFDIR, KERNFS_DIR);
+	kn = kernfs_new_node(parent, name, mode | S_IFDIR,
+			     uid, gid, KERNFS_DIR);
 	if (!kn)
 		return ERR_PTR(-ENOMEM);
 
@@ -1001,7 +1023,8 @@ struct kernfs_node *kernfs_create_empty_dir(struct kernfs_node *parent,
 	int rc;
 
 	/* allocate */
-	kn = kernfs_new_node(parent, name, S_IRUGO|S_IXUGO|S_IFDIR, KERNFS_DIR);
+	kn = kernfs_new_node(parent, name, S_IRUGO|S_IXUGO|S_IFDIR,
+			     GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, KERNFS_DIR);
 	if (!kn)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/fs/kernfs/file.c b/fs/kernfs/file.c
index e157400..736a168 100644
--- a/fs/kernfs/file.c
+++ b/fs/kernfs/file.c
@@ -904,6 +904,8 @@ const struct file_operations kernfs_file_fops = {
  * @parent: directory to create the file in
  * @name: name of the file
  * @mode: mode of the file
+ * @uid: uid of the file
+ * @gid: gid of the file
  * @size: size of the file
  * @ops: kernfs operations for the file
  * @priv: private data for the file
@@ -914,7 +916,8 @@ const struct file_operations kernfs_file_fops = {
  */
 struct kernfs_node *__kernfs_create_file(struct kernfs_node *parent,
 					 const char *name,
-					 umode_t mode, loff_t size,
+					 umode_t mode, kuid_t uid, kgid_t gid,
+					 loff_t size,
 					 const struct kernfs_ops *ops,
 					 void *priv, const void *ns,
 					 struct lock_class_key *key)
@@ -925,7 +928,8 @@ struct kernfs_node *__kernfs_create_file(struct kernfs_node *parent,
 
 	flags = KERNFS_FILE;
 
-	kn = kernfs_new_node(parent, name, (mode & S_IALLUGO) | S_IFREG, flags);
+	kn = kernfs_new_node(parent, name, (mode & S_IALLUGO) | S_IFREG,
+			     uid, gid, flags);
 	if (!kn)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/fs/kernfs/inode.c b/fs/kernfs/inode.c
index 63b925d..3d3f152 100644
--- a/fs/kernfs/inode.c
+++ b/fs/kernfs/inode.c
@@ -66,7 +66,7 @@ out_unlock:
 	return ret;
 }
 
-static int __kernfs_setattr(struct kernfs_node *kn, const struct iattr *iattr)
+int __kernfs_setattr(struct kernfs_node *kn, const struct iattr *iattr)
 {
 	struct kernfs_iattrs *attrs;
 	struct iattr *iattrs;
diff --git a/fs/kernfs/kernfs-internal.h b/fs/kernfs/kernfs-internal.h
index 3715923..80f4b5a 100644
--- a/fs/kernfs/kernfs-internal.h
+++ b/fs/kernfs/kernfs-internal.h
@@ -88,6 +88,7 @@ int kernfs_iop_removexattr(struct dentry *dentry, const char *name);
 ssize_t kernfs_iop_getxattr(struct dentry *dentry, struct inode *inode,
 			    const char *name, void *buf, size_t size);
 ssize_t kernfs_iop_listxattr(struct dentry *dentry, char *buf, size_t size);
+int __kernfs_setattr(struct kernfs_node *kn, const struct iattr *iattr);
 
 /*
  * dir.c
@@ -102,6 +103,7 @@ void kernfs_put_active(struct kernfs_node *kn);
 int kernfs_add_one(struct kernfs_node *kn);
 struct kernfs_node *kernfs_new_node(struct kernfs_node *parent,
 				    const char *name, umode_t mode,
+				    kuid_t uid, kgid_t gid,
 				    unsigned flags);
 
 /*
diff --git a/fs/kernfs/symlink.c b/fs/kernfs/symlink.c
index 117b8b3..e0847ce 100644
--- a/fs/kernfs/symlink.c
+++ b/fs/kernfs/symlink.c
@@ -21,6 +21,7 @@
  * @target: target node for the symlink to point to
  *
  * Returns the created node on success, ERR_PTR() value on error.
+ * Ownership of the link matches ownership of the target.
  */
 struct kernfs_node *kernfs_create_link(struct kernfs_node *parent,
 				       const char *name,
@@ -28,8 +29,16 @@ struct kernfs_node *kernfs_create_link(struct kernfs_node *parent,
 {
 	struct kernfs_node *kn;
 	int error;
+	kuid_t uid = GLOBAL_ROOT_UID;
+	kgid_t gid = GLOBAL_ROOT_GID;
 
-	kn = kernfs_new_node(parent, name, S_IFLNK|S_IRWXUGO, KERNFS_LINK);
+	if (target->iattr) {
+		uid = target->iattr->ia_iattr.ia_uid;
+		gid = target->iattr->ia_iattr.ia_gid;
+	}
+
+	kn = kernfs_new_node(parent, name, S_IFLNK|S_IRWXUGO, uid, gid,
+			     KERNFS_LINK);
 	if (!kn)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 94374e4..d6a2b76 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -53,7 +53,9 @@ int sysfs_create_dir_ns(struct kobject *kobj, const void *ns)
 		return -ENOENT;
 
 	kn = kernfs_create_dir_ns(parent, kobject_name(kobj),
-				  S_IRWXU | S_IRUGO | S_IXUGO, kobj, ns);
+				  S_IRWXU | S_IRUGO | S_IXUGO,
+				  GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
+				  kobj, ns);
 	if (IS_ERR(kn)) {
 		if (PTR_ERR(kn) == -EEXIST)
 			sysfs_warn_dup(parent, kobject_name(kobj));
diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index f35523d..0241830 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -296,8 +296,9 @@ int sysfs_add_file_mode_ns(struct kernfs_node *parent,
 	if (!attr->ignore_lockdep)
 		key = attr->key ?: (struct lock_class_key *)&attr->skey;
 #endif
-	kn = __kernfs_create_file(parent, attr->name, mode & 0777, size, ops,
-				  (void *)attr, ns, key);
+	kn = __kernfs_create_file(parent, attr->name,
+				  mode & 0777, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
+				  size, ops, (void *)attr, ns, key);
 	if (IS_ERR(kn)) {
 		if (PTR_ERR(kn) == -EEXIST)
 			sysfs_warn_dup(parent, attr->name);
diff --git a/include/linux/kernfs.h b/include/linux/kernfs.h
index 96356ef..0a3687d 100644
--- a/include/linux/kernfs.h
+++ b/include/linux/kernfs.h
@@ -15,6 +15,7 @@
 #include <linux/lockdep.h>
 #include <linux/rbtree.h>
 #include <linux/atomic.h>
+#include <linux/uidgid.h>
 #include <linux/wait.h>
 
 struct file;
@@ -295,12 +296,14 @@ void kernfs_destroy_root(struct kernfs_root *root);
 
 struct kernfs_node *kernfs_create_dir_ns(struct kernfs_node *parent,
 					 const char *name, umode_t mode,
+					 kuid_t uid, kgid_t gid,
 					 void *priv, const void *ns);
 struct kernfs_node *kernfs_create_empty_dir(struct kernfs_node *parent,
 					    const char *name);
 struct kernfs_node *__kernfs_create_file(struct kernfs_node *parent,
-					 const char *name,
-					 umode_t mode, loff_t size,
+					 const char *name, umode_t mode,
+					 kuid_t uid, kgid_t gid,
+					 loff_t size,
 					 const struct kernfs_ops *ops,
 					 void *priv, const void *ns,
 					 struct lock_class_key *key);
@@ -385,12 +388,14 @@ static inline void kernfs_destroy_root(struct kernfs_root *root) { }
 
 static inline struct kernfs_node *
 kernfs_create_dir_ns(struct kernfs_node *parent, const char *name,
-		     umode_t mode, void *priv, const void *ns)
+		     umode_t mode, kuid_t uid, kgid_t gid,
+		     void *priv, const void *ns)
 { return ERR_PTR(-ENOSYS); }
 
 static inline struct kernfs_node *
 __kernfs_create_file(struct kernfs_node *parent, const char *name,
-		     umode_t mode, loff_t size, const struct kernfs_ops *ops,
+		     umode_t mode, kuid_t uid, kgid_t gid,
+		     loff_t size, const struct kernfs_ops *ops,
 		     void *priv, const void *ns, struct lock_class_key *key)
 { return ERR_PTR(-ENOSYS); }
 
@@ -452,12 +457,15 @@ static inline struct kernfs_node *
 kernfs_create_dir(struct kernfs_node *parent, const char *name, umode_t mode,
 		  void *priv)
 {
-	return kernfs_create_dir_ns(parent, name, mode, priv, NULL);
+	return kernfs_create_dir_ns(parent, name, mode,
+				    GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
+				    priv, NULL);
 }
 
 static inline struct kernfs_node *
 kernfs_create_file_ns(struct kernfs_node *parent, const char *name,
-		      umode_t mode, loff_t size, const struct kernfs_ops *ops,
+		      umode_t mode, kuid_t uid, kgid_t gid,
+		      loff_t size, const struct kernfs_ops *ops,
 		      void *priv, const void *ns)
 {
 	struct lock_class_key *key = NULL;
@@ -465,15 +473,17 @@ kernfs_create_file_ns(struct kernfs_node *parent, const char *name,
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 	key = (struct lock_class_key *)&ops->lockdep_key;
 #endif
-	return __kernfs_create_file(parent, name, mode, size, ops, priv, ns,
-				    key);
+	return __kernfs_create_file(parent, name, mode, uid, gid,
+				    size, ops, priv, ns, key);
 }
 
 static inline struct kernfs_node *
 kernfs_create_file(struct kernfs_node *parent, const char *name, umode_t mode,
 		   loff_t size, const struct kernfs_ops *ops, void *priv)
 {
-	return kernfs_create_file_ns(parent, name, mode, size, ops, priv, NULL);
+	return kernfs_create_file_ns(parent, name, mode,
+				     GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
+				     size, ops, priv, NULL);
 }
 
 static inline int kernfs_remove_by_name(struct kernfs_node *parent,
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 75c0ff0..86ec412 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3634,7 +3634,9 @@ static int cgroup_add_file(struct cgroup_subsys_state *css, struct cgroup *cgrp,
 	key = &cft->lockdep_key;
 #endif
 	kn = __kernfs_create_file(cgrp->kn, cgroup_file_name(cgrp, cft, name),
-				  cgroup_file_mode(cft), 0, cft->kf_ops, cft,
+				  cgroup_file_mode(cft),
+				  GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
+				  0, cft->kf_ops, cft,
 				  NULL, key);
 	if (IS_ERR(kn))
 		return PTR_ERR(kn);
-- 
2.8.0.rc3.226.g39d4020
