From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/7] sysfs: remove ktype->namespace() invocations in directory code
Date: Wed, 11 Sep 2013 22:29:05 -0400
Message-ID: <1378952949-7900-4-git-send-email-tj@kernel.org>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, kay@vrfy.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lizefan@huawei.com,
	Tejun Heo <tj@kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378952949-7900-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For some unrecognizable reason, namespace information is communicated
to sysfs through ktype->namespace() callback when there's *nothing*
which needs the use of a callback.  The whole sequence of operations
is completely synchronous and sysfs operations simply end up calling
back into the layer which just invoked it in order to find out the
namespace information, which is completely backwards, obfuscates
what's going on and unnecessarily tangles two separate layers.

This patch doesn't remove ktype->namespace() but shifts its handling
to kobject layer.  We probably want to get rid of the callback in the
long term.

This patch adds an explicit param to sysfs_{create|rename|move}_dir()
and renames them to sysfs_{create|rename|move}_dir_ns(), respectively.
ktype->namespace() invocations are moved to the calling sites of the
above functions.  A new helper kboject_namespace() is introduced which
directly tests kobj_ns_type_operations->type which should give the
same result as testing sysfs_fs_type(parent_sd) and returns @kobj's
namespace tag as necessary.  kobject_namespace() is extern as it will
be used from another file in the following patches.

This patch should be an equivalent conversion without any functional
difference.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Kay Sievers <kay@vrfy.org>
---
 fs/sysfs/dir.c          | 23 ++++++++---------------
 include/linux/kobject.h |  1 +
 include/linux/sysfs.h   | 20 ++++++++++++--------
 lib/kobject.c           | 28 ++++++++++++++++++++++++----
 4 files changed, 45 insertions(+), 27 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 834c64c..878ac3a 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -730,14 +730,14 @@ static enum kobj_ns_type sysfs_read_ns_type(struct kobject *kobj)
 }
 
 /**
- *	sysfs_create_dir - create a directory for an object.
- *	@kobj:		object we're creating directory for.
+ * sysfs_create_dir_ns - create a directory for an object with a namespace tag
+ * @kobj: object we're creating directory for
+ * @ns: the namespace tag to use
  */
-int sysfs_create_dir(struct kobject *kobj)
+int sysfs_create_dir_ns(struct kobject *kobj, const void *ns)
 {
 	enum kobj_ns_type type;
 	struct sysfs_dirent *parent_sd, *sd;
-	const void *ns = NULL;
 	int error = 0;
 
 	BUG_ON(!kobj);
@@ -750,8 +750,6 @@ int sysfs_create_dir(struct kobject *kobj)
 	if (!parent_sd)
 		return -ENOENT;
 
-	if (sysfs_ns_type(parent_sd))
-		ns = kobj->ktype->namespace(kobj);
 	type = sysfs_read_ns_type(kobj);
 
 	error = create_dir(kobj, parent_sd, type, ns, kobject_name(kobj), &sd);
@@ -909,26 +907,21 @@ int sysfs_rename(struct sysfs_dirent *sd,
 	return error;
 }
 
-int sysfs_rename_dir(struct kobject *kobj, const char *new_name)
+int sysfs_rename_dir_ns(struct kobject *kobj, const char *new_name,
+			const void *new_ns)
 {
 	struct sysfs_dirent *parent_sd = kobj->sd->s_parent;
-	const void *new_ns = NULL;
-
-	if (sysfs_ns_type(parent_sd))
-		new_ns = kobj->ktype->namespace(kobj);
 
 	return sysfs_rename(kobj->sd, parent_sd, new_ns, new_name);
 }
 
-int sysfs_move_dir(struct kobject *kobj, struct kobject *new_parent_kobj)
+int sysfs_move_dir_ns(struct kobject *kobj, struct kobject *new_parent_kobj,
+		      const void *new_ns)
 {
 	struct sysfs_dirent *sd = kobj->sd;
 	struct sysfs_dirent *new_parent_sd;
-	const void *new_ns = NULL;
 
 	BUG_ON(!sd->s_parent);
-	if (sysfs_ns_type(sd->s_parent))
-		new_ns = kobj->ktype->namespace(kobj);
 	new_parent_sd = new_parent_kobj && new_parent_kobj->sd ?
 		new_parent_kobj->sd : &sysfs_root;
 
diff --git a/include/linux/kobject.h b/include/linux/kobject.h
index de6dcbcc..e7ba650 100644
--- a/include/linux/kobject.h
+++ b/include/linux/kobject.h
@@ -107,6 +107,7 @@ extern int __must_check kobject_move(struct kobject *, struct kobject *);
 extern struct kobject *kobject_get(struct kobject *kobj);
 extern void kobject_put(struct kobject *kobj);
 
+extern const void *kobject_namespace(struct kobject *kobj);
 extern char *kobject_get_path(struct kobject *kobj, gfp_t flag);
 
 struct kobj_type {
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index 82f7fac..7f56bad 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -182,11 +182,13 @@ struct sysfs_dirent;
 int sysfs_schedule_callback(struct kobject *kobj, void (*func)(void *),
 			    void *data, struct module *owner);
 
-int __must_check sysfs_create_dir(struct kobject *kobj);
+int __must_check sysfs_create_dir_ns(struct kobject *kobj, const void *ns);
 void sysfs_remove_dir(struct kobject *kobj);
-int __must_check sysfs_rename_dir(struct kobject *kobj, const char *new_name);
-int __must_check sysfs_move_dir(struct kobject *kobj,
-				struct kobject *new_parent_kobj);
+int __must_check sysfs_rename_dir_ns(struct kobject *kobj, const char *new_name,
+				     const void *new_ns);
+int __must_check sysfs_move_dir_ns(struct kobject *kobj,
+				   struct kobject *new_parent_kobj,
+				   const void *new_ns);
 
 int __must_check sysfs_create_file_ns(struct kobject *kobj,
 				      const struct attribute *attr,
@@ -258,7 +260,7 @@ static inline int sysfs_schedule_callback(struct kobject *kobj,
 	return -ENOSYS;
 }
 
-static inline int sysfs_create_dir(struct kobject *kobj)
+static inline int sysfs_create_dir_ns(struct kobject *kobj, const void *ns)
 {
 	return 0;
 }
@@ -267,13 +269,15 @@ static inline void sysfs_remove_dir(struct kobject *kobj)
 {
 }
 
-static inline int sysfs_rename_dir(struct kobject *kobj, const char *new_name)
+static inline int sysfs_rename_dir_ns(struct kobject *kobj,
+				      const char *new_name, const void *new_ns)
 {
 	return 0;
 }
 
-static inline int sysfs_move_dir(struct kobject *kobj,
-				 struct kobject *new_parent_kobj)
+static inline int sysfs_move_dir_ns(struct kobject *kobj,
+				    struct kobject *new_parent_kobj,
+				    const void *new_ns)
 {
 	return 0;
 }
diff --git a/lib/kobject.c b/lib/kobject.c
index 9621751..85fb3a1 100644
--- a/lib/kobject.c
+++ b/lib/kobject.c
@@ -18,6 +18,24 @@
 #include <linux/stat.h>
 #include <linux/slab.h>
 
+/**
+ * kobject_namespace - return @kobj's namespace tag
+ * @kobj: kobject in question
+ *
+ * Returns namespace tag of @kobj if its parent has namespace ops enabled
+ * and thus @kobj should have a namespace tag associated with it.  Returns
+ * %NULL otherwise.
+ */
+const void *kobject_namespace(struct kobject *kobj)
+{
+	const struct kobj_ns_type_operations *ns_ops = kobj_ns_ops(kobj);
+
+	if (!ns_ops || ns_ops->type == KOBJ_NS_TYPE_NONE)
+		return NULL;
+
+	return kobj->ktype->namespace(kobj);
+}
+
 /*
  * populate_dir - populate directory with attributes.
  * @kobj: object we're working on.
@@ -46,8 +64,9 @@ static int populate_dir(struct kobject *kobj)
 
 static int create_dir(struct kobject *kobj)
 {
-	int error = 0;
-	error = sysfs_create_dir(kobj);
+	int error;
+
+	error = sysfs_create_dir_ns(kobj, kobject_namespace(kobj));
 	if (!error) {
 		error = populate_dir(kobj);
 		if (error)
@@ -428,7 +447,7 @@ int kobject_rename(struct kobject *kobj, const char *new_name)
 		goto out;
 	}
 
-	error = sysfs_rename_dir(kobj, new_name);
+	error = sysfs_rename_dir_ns(kobj, new_name, kobject_namespace(kobj));
 	if (error)
 		goto out;
 
@@ -472,6 +491,7 @@ int kobject_move(struct kobject *kobj, struct kobject *new_parent)
 		if (kobj->kset)
 			new_parent = kobject_get(&kobj->kset->kobj);
 	}
+
 	/* old object path */
 	devpath = kobject_get_path(kobj, GFP_KERNEL);
 	if (!devpath) {
@@ -486,7 +506,7 @@ int kobject_move(struct kobject *kobj, struct kobject *new_parent)
 	sprintf(devpath_string, "DEVPATH_OLD=%s", devpath);
 	envp[0] = devpath_string;
 	envp[1] = NULL;
-	error = sysfs_move_dir(kobj, new_parent);
+	error = sysfs_move_dir_ns(kobj, new_parent, kobject_namespace(kobj));
 	if (error)
 		goto out;
 	old_parent = kobj->parent;
-- 
1.8.3.1
