From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/7] sysfs: remove ktype->namespace() invocations in symlink code
Date: Wed, 11 Sep 2013 22:29:06 -0400
Message-ID: <1378952949-7900-5-git-send-email-tj@kernel.org>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, kay@vrfy.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lizefan@huawei.com,
	Tejun Heo <tj@kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378952949-7900-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no reason for sysfs to be calling ktype->namespace().  It is
backwards, obfuscates what's going on and unnecessarily tangles two
separate layers.

There are two places where symlink code calls ktype->namespace().

* sysfs_do_create_link_sd() calls it to find out the namespace tag of
  the target directory.  Unless symlinking races with cross-namespace
  renaming, this equals @target_sd->s_ns.

* sysfs_rename_link() uses it to find out the new namespace to rename
  to and the new namespace can be different from the existing one.
  The function is renamed to sysfs_rename_link_ns() with an explicit
  @ns argument and the ktype->namespace() invocation is shifted to the
  device layer.

While this patch replaces ktype->namespace() invocation with the
recorded result in @target_sd, this shouldn't result in any behvior
difference.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Kay Sievers <kay@vrfy.org>
---
 drivers/base/core.c   |  8 +++++---
 fs/sysfs/symlink.c    | 16 +++++++---------
 include/linux/sysfs.h | 16 ++++++++++++----
 3 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index c7cfadc..3335000 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1881,6 +1881,7 @@ EXPORT_SYMBOL_GPL(device_destroy);
  */
 int device_rename(struct device *dev, const char *new_name)
 {
+	struct kobject *kobj = &dev->kobj;
 	char *old_device_name = NULL;
 	int error;
 
@@ -1898,13 +1899,14 @@ int device_rename(struct device *dev, const char *new_name)
 	}
 
 	if (dev->class) {
-		error = sysfs_rename_link(&dev->class->p->subsys.kobj,
-			&dev->kobj, old_device_name, new_name);
+		error = sysfs_rename_link_ns(&dev->class->p->subsys.kobj,
+					     kobj, old_device_name,
+					     new_name, kobject_namespace(kobj));
 		if (error)
 			goto out;
 	}
 
-	error = kobject_rename(&dev->kobj, new_name);
+	error = kobject_rename(kobj, new_name);
 	if (error)
 		goto out;
 
diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index 2dd4507..12d58ad 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -52,7 +52,7 @@ static int sysfs_do_create_link_sd(struct sysfs_dirent *parent_sd,
 
 	ns_type = sysfs_ns_type(parent_sd);
 	if (ns_type)
-		sd->s_ns = target->ktype->namespace(target);
+		sd->s_ns = target_sd->s_ns;
 	sd->s_symlink.target_sd = target_sd;
 	target_sd = NULL;	/* reference is now owned by the symlink */
 
@@ -181,19 +181,20 @@ void sysfs_remove_link(struct kobject *kobj, const char *name)
 EXPORT_SYMBOL_GPL(sysfs_remove_link);
 
 /**
- *	sysfs_rename_link - rename symlink in object's directory.
+ *	sysfs_rename_link_ns - rename symlink in object's directory.
  *	@kobj:	object we're acting for.
  *	@targ:	object we're pointing to.
  *	@old:	previous name of the symlink.
  *	@new:	new name of the symlink.
+ *	@new_ns: new namespace of the symlink.
  *
  *	A helper function for the common rename symlink idiom.
  */
-int sysfs_rename_link(struct kobject *kobj, struct kobject *targ,
-			const char *old, const char *new)
+int sysfs_rename_link_ns(struct kobject *kobj, struct kobject *targ,
+			 const char *old, const char *new, const void *new_ns)
 {
 	struct sysfs_dirent *parent_sd, *sd = NULL;
-	const void *old_ns = NULL, *new_ns = NULL;
+	const void *old_ns = NULL;
 	int result;
 
 	if (!kobj)
@@ -215,16 +216,13 @@ int sysfs_rename_link(struct kobject *kobj, struct kobject *targ,
 	if (sd->s_symlink.target_sd->s_dir.kobj != targ)
 		goto out;
 
-	if (sysfs_ns_type(parent_sd))
-		new_ns = targ->ktype->namespace(targ);
-
 	result = sysfs_rename(sd, parent_sd, new_ns, new);
 
 out:
 	sysfs_put(sd);
 	return result;
 }
-EXPORT_SYMBOL_GPL(sysfs_rename_link);
+EXPORT_SYMBOL_GPL(sysfs_rename_link_ns);
 
 static int sysfs_get_target_path(struct sysfs_dirent *parent_sd,
 				 struct sysfs_dirent *target_sd, char *path)
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index 7f56bad..c792f73 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -213,8 +213,9 @@ int __must_check sysfs_create_link_nowarn(struct kobject *kobj,
 					  const char *name);
 void sysfs_remove_link(struct kobject *kobj, const char *name);
 
-int sysfs_rename_link(struct kobject *kobj, struct kobject *target,
-			const char *old_name, const char *new_name);
+int sysfs_rename_link_ns(struct kobject *kobj, struct kobject *target,
+			 const char *old_name, const char *new_name,
+			 const void *new_ns);
 
 void sysfs_delete_link(struct kobject *dir, struct kobject *targ,
 			const char *name);
@@ -340,8 +341,9 @@ static inline void sysfs_remove_link(struct kobject *kobj, const char *name)
 {
 }
 
-static inline int sysfs_rename_link(struct kobject *k, struct kobject *t,
-				    const char *old_name, const char *new_name)
+static inline int sysfs_rename_link_ns(struct kobject *k, struct kobject *t,
+				       const char *old_name,
+				       const char *new_name, const void *ns)
 {
 	return 0;
 }
@@ -454,4 +456,10 @@ static inline void sysfs_remove_file(struct kobject *kobj,
 	return sysfs_remove_file_ns(kobj, attr, NULL);
 }
 
+static inline int sysfs_rename_link(struct kobject *kobj, struct kobject *target,
+				    const char *old_name, const char *new_name)
+{
+	return sysfs_rename_link_ns(kobj, target, old_name, new_name, NULL);
+}
+
 #endif /* _SYSFS_H_ */
-- 
1.8.3.1
