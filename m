From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH 2/5] sysfs, kobject: allow creating kobject belonging to arbitrary users
Date: Tue, 16 Aug 2016 15:33:12 -0700
Message-ID: <1471386795-32918-3-git-send-email-dmitry.torokhov@gmail.com>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36511 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbcHPWdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 18:33:20 -0400
In-Reply-To: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Normally kobjects and their sysfs representation belong to global root,
however it is not necessarily the case for objects in separate namespaces.
For example, objects in separate network namespace logically belong to the
container's root and not global root.

This change lays groundwork for allowing network namespace objects
ownership to be transferred to container's root user by defining
get_ownership() callback in ktype structure and using it in sysfs code to
retrieve desired uid/gid when creating sysfs objects for given kobject.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 fs/sysfs/dir.c          |  7 +++++--
 fs/sysfs/file.c         | 32 ++++++++++++++++++++------------
 fs/sysfs/group.c        | 23 +++++++++++++++++------
 fs/sysfs/sysfs.h        |  3 ++-
 include/linux/kobject.h |  4 ++++
 lib/kobject.c           | 19 +++++++++++++++++++
 6 files changed, 67 insertions(+), 21 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index d6a2b76..7ef6524 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -41,6 +41,8 @@ void sysfs_warn_dup(struct kernfs_node *parent, const char *name)
 int sysfs_create_dir_ns(struct kobject *kobj, const void *ns)
 {
 	struct kernfs_node *parent, *kn;
+	kuid_t uid;
+	kgid_t gid;
 
 	BUG_ON(!kobj);
 
@@ -52,9 +54,10 @@ int sysfs_create_dir_ns(struct kobject *kobj, const void *ns)
 	if (!parent)
 		return -ENOENT;
 
+	kobject_get_ownership(kobj, &uid, &gid);
+
 	kn = kernfs_create_dir_ns(parent, kobject_name(kobj),
-				  S_IRWXU | S_IRUGO | S_IXUGO,
-				  GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
+				  S_IRWXU | S_IRUGO | S_IXUGO, uid, gid,
 				  kobj, ns);
 	if (IS_ERR(kn)) {
 		if (PTR_ERR(kn) == -EEXIST)
diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index 0241830..8411e7c 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -239,7 +239,7 @@ static const struct kernfs_ops sysfs_bin_kfops_mmap = {
 
 int sysfs_add_file_mode_ns(struct kernfs_node *parent,
 			   const struct attribute *attr, bool is_bin,
-			   umode_t mode, const void *ns)
+			   umode_t mode, kuid_t uid, kgid_t gid, const void *ns)
 {
 	struct lock_class_key *key = NULL;
 	const struct kernfs_ops *ops;
@@ -296,8 +296,8 @@ int sysfs_add_file_mode_ns(struct kernfs_node *parent,
 	if (!attr->ignore_lockdep)
 		key = attr->key ?: (struct lock_class_key *)&attr->skey;
 #endif
-	kn = __kernfs_create_file(parent, attr->name,
-				  mode & 0777, GLOBAL_ROOT_UID, GLOBAL_ROOT_GID,
+
+	kn = __kernfs_create_file(parent, attr->name, mode & 0777, uid, gid,
 				  size, ops, (void *)attr, ns, key);
 	if (IS_ERR(kn)) {
 		if (PTR_ERR(kn) == -EEXIST)
@@ -307,12 +307,6 @@ int sysfs_add_file_mode_ns(struct kernfs_node *parent,
 	return 0;
 }
 
-int sysfs_add_file(struct kernfs_node *parent, const struct attribute *attr,
-		   bool is_bin)
-{
-	return sysfs_add_file_mode_ns(parent, attr, is_bin, attr->mode, NULL);
-}
-
 /**
  * sysfs_create_file_ns - create an attribute file for an object with custom ns
  * @kobj: object we're creating for
@@ -322,9 +316,14 @@ int sysfs_add_file(struct kernfs_node *parent, const struct attribute *attr,
 int sysfs_create_file_ns(struct kobject *kobj, const struct attribute *attr,
 			 const void *ns)
 {
+	kuid_t uid;
+	kgid_t gid;
+
 	BUG_ON(!kobj || !kobj->sd || !attr);
 
-	return sysfs_add_file_mode_ns(kobj->sd, attr, false, attr->mode, ns);
+	kobject_get_ownership(kobj, &uid, &gid);
+	return sysfs_add_file_mode_ns(kobj->sd, attr, false, attr->mode,
+				      uid, gid, ns);
 
 }
 EXPORT_SYMBOL_GPL(sysfs_create_file_ns);
@@ -353,6 +352,8 @@ int sysfs_add_file_to_group(struct kobject *kobj,
 		const struct attribute *attr, const char *group)
 {
 	struct kernfs_node *parent;
+	kuid_t uid;
+	kgid_t gid;
 	int error;
 
 	if (group) {
@@ -365,7 +366,9 @@ int sysfs_add_file_to_group(struct kobject *kobj,
 	if (!parent)
 		return -ENOENT;
 
-	error = sysfs_add_file(parent, attr, false);
+	kobject_get_ownership(kobj, &uid, &gid);
+	error = sysfs_add_file_mode_ns(kobj->sd, attr, false,
+				       attr->mode, uid, gid, NULL);
 	kernfs_put(parent);
 
 	return error;
@@ -481,9 +484,14 @@ EXPORT_SYMBOL_GPL(sysfs_remove_file_from_group);
 int sysfs_create_bin_file(struct kobject *kobj,
 			  const struct bin_attribute *attr)
 {
+	kuid_t uid;
+	kgid_t gid;
+
 	BUG_ON(!kobj || !kobj->sd || !attr);
 
-	return sysfs_add_file(kobj->sd, &attr->attr, true);
+	kobject_get_ownership(kobj, &uid, &gid);
+	return sysfs_add_file_mode_ns(kobj->sd, &attr->attr, true,
+				      attr->attr.mode, uid, gid, NULL);
 }
 EXPORT_SYMBOL_GPL(sysfs_create_bin_file);
 
diff --git a/fs/sysfs/group.c b/fs/sysfs/group.c
index 5e98639..0d4798c 100644
--- a/fs/sysfs/group.c
+++ b/fs/sysfs/group.c
@@ -34,6 +34,7 @@ static void remove_files(struct kernfs_node *parent,
 }
 
 static int create_files(struct kernfs_node *parent, struct kobject *kobj,
+			kuid_t uid, kgid_t gid,
 			const struct attribute_group *grp, int update)
 {
 	struct attribute *const *attr;
@@ -63,7 +64,7 @@ static int create_files(struct kernfs_node *parent, struct kobject *kobj,
 
 			mode &= SYSFS_PREALLOC | 0664;
 			error = sysfs_add_file_mode_ns(parent, *attr, false,
-						       mode, NULL);
+						       mode, uid, gid, NULL);
 			if (unlikely(error))
 				break;
 		}
@@ -93,7 +94,8 @@ static int create_files(struct kernfs_node *parent, struct kobject *kobj,
 			mode &= SYSFS_PREALLOC | 0664;
 			error = sysfs_add_file_mode_ns(parent,
 					&(*bin_attr)->attr, true,
-					mode, NULL);
+					mode,
+					uid, gid, NULL);
 			if (error)
 				break;
 		}
@@ -109,6 +111,8 @@ static int internal_create_group(struct kobject *kobj, int update,
 				 const struct attribute_group *grp)
 {
 	struct kernfs_node *kn;
+	kuid_t uid;
+	kgid_t gid;
 	int error;
 
 	BUG_ON(!kobj || (!update && !kobj->sd));
@@ -121,9 +125,11 @@ static int internal_create_group(struct kobject *kobj, int update,
 			kobj->name, grp->name ?: "");
 		return -EINVAL;
 	}
+	kobject_get_ownership(kobj, &uid, &gid);
 	if (grp->name) {
-		kn = kernfs_create_dir(kobj->sd, grp->name,
-				       S_IRWXU | S_IRUGO | S_IXUGO, kobj);
+		kn = kernfs_create_dir_ns(kobj->sd, grp->name,
+					  S_IRWXU | S_IRUGO | S_IXUGO,
+					  uid, gid, kobj, NULL);
 		if (IS_ERR(kn)) {
 			if (PTR_ERR(kn) == -EEXIST)
 				sysfs_warn_dup(kobj->sd, grp->name);
@@ -132,7 +138,7 @@ static int internal_create_group(struct kobject *kobj, int update,
 	} else
 		kn = kobj->sd;
 	kernfs_get(kn);
-	error = create_files(kn, kobj, grp, update);
+	error = create_files(kn, kobj, uid, gid, grp, update);
 	if (error) {
 		if (grp->name)
 			kernfs_remove(kn);
@@ -284,6 +290,8 @@ int sysfs_merge_group(struct kobject *kobj,
 		       const struct attribute_group *grp)
 {
 	struct kernfs_node *parent;
+	kuid_t uid;
+	kgid_t gid;
 	int error = 0;
 	struct attribute *const *attr;
 	int i;
@@ -292,8 +300,11 @@ int sysfs_merge_group(struct kobject *kobj,
 	if (!parent)
 		return -ENOENT;
 
+	kobject_get_ownership(kobj, &uid, &gid);
+
 	for ((i = 0, attr = grp->attrs); *attr && !error; (++i, ++attr))
-		error = sysfs_add_file(parent, *attr, false);
+		error = sysfs_add_file_mode_ns(parent, *attr, false,
+					       (*attr)->mode, uid, gid, NULL);
 	if (error) {
 		while (--i >= 0)
 			kernfs_remove_by_name(parent, (*--attr)->name);
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 0e2f1cc..9a38568 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -32,7 +32,8 @@ int sysfs_add_file(struct kernfs_node *parent,
 		   const struct attribute *attr, bool is_bin);
 int sysfs_add_file_mode_ns(struct kernfs_node *parent,
 			   const struct attribute *attr, bool is_bin,
-			   umode_t amode, const void *ns);
+			   umode_t amode, kuid_t uid, kgid_t gid,
+			   const void *ns);
 
 /*
  * symlink.c
diff --git a/include/linux/kobject.h b/include/linux/kobject.h
index e628459..3c8a689 100644
--- a/include/linux/kobject.h
+++ b/include/linux/kobject.h
@@ -27,6 +27,7 @@
 #include <linux/wait.h>
 #include <linux/atomic.h>
 #include <linux/workqueue.h>
+#include <linux/uidgid.h>
 
 #define UEVENT_HELPER_PATH_LEN		256
 #define UEVENT_NUM_ENVP			32	/* number of env pointers */
@@ -111,6 +112,8 @@ extern struct kobject *kobject_get(struct kobject *kobj);
 extern void kobject_put(struct kobject *kobj);
 
 extern const void *kobject_namespace(struct kobject *kobj);
+extern void kobject_get_ownership(struct kobject *kobj,
+				  kuid_t *uid, kgid_t *gid);
 extern char *kobject_get_path(struct kobject *kobj, gfp_t flag);
 
 struct kobj_type {
@@ -119,6 +122,7 @@ struct kobj_type {
 	struct attribute **default_attrs;
 	const struct kobj_ns_type_operations *(*child_ns_type)(struct kobject *kobj);
 	const void *(*namespace)(struct kobject *kobj);
+	void (*get_ownership)(struct kobject *kobj, kuid_t *uid, kgid_t *gid);
 };
 
 struct kobj_uevent_env {
diff --git a/lib/kobject.c b/lib/kobject.c
index 445dcae..7d516d9 100644
--- a/lib/kobject.c
+++ b/lib/kobject.c
@@ -37,6 +37,25 @@ const void *kobject_namespace(struct kobject *kobj)
 	return kobj->ktype->namespace(kobj);
 }
 
+/**
+ * kobject_get_ownership - get sysfs ownership data for @kobj
+ * @kobj: kobject in question
+ * @uid: kernel user ID for sysfs objects
+ * @gid: kernel group ID for sysfs objects
+ *
+ * Returns initial uid/gid pair that should be used when creating sysfs
+ * representation of given kobject. Normally used to adjust ownership of
+ * objects in a container.
+ */
+void kobject_get_ownership(struct kobject *kobj, kuid_t *uid, kgid_t *gid)
+{
+	*uid = GLOBAL_ROOT_UID;
+	*gid = GLOBAL_ROOT_GID;
+
+	if (kobj->ktype->get_ownership)
+		kobj->ktype->get_ownership(kobj, uid, gid);
+}
+
 /*
  * populate_dir - populate directory with attributes.
  * @kobj: object we're working on.
-- 
2.8.0.rc3.226.g39d4020
