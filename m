From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/7] sysfs: make attr namespace interface less convoluted
Date: Wed, 11 Sep 2013 22:29:04 -0400
Message-ID: <1378952949-7900-3-git-send-email-tj@kernel.org>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, kay@vrfy.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lizefan@huawei.com,
	Tejun Heo <tj@kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378952949-7900-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sysfs ns (namespace) implementation became more convoluted than
necessary while trying to hide ns information from visible interface.
The relatively recent attr ns support is a good example.

* attr ns tag is determined by sysfs_ops->namespace() callback while
  dir tag is determined by kobj_type->namespace().  The placement is
  arbitrary.

* Instead of performing operations with explicit ns tag, the namespace
  callback is routed through sysfs_attr_ns(), sysfs_ops->namespace(),
  class_attr_namespace(), class_attr->namespace().  It's not simpler
  in any sense.  The only thing this convolution does is traversing
  the whole stack backwards.

The namespace callbacks are unncessary because the operations involved
are inherently synchronous.  The information can be provided in in
straight-forward top-down direction and reversing that direction is
unnecessary and against basic design principles.

This backward interface is unnecessarily convoluted and hinders
properly separating out sysfs from driver model / kobject for proper
layering.  This patch updates attr ns support such that

* sysfs_ops->namespace() and class_attr->namespace() are dropped.

* sysfs_{create|remove}_file_ns(), which take explicit @ns param, are
  added and sysfs_{create|remove}_file() are now simple wrappers
  around the ns aware functions.

* ns handling is dropped from sysfs_chmod_file().  Nobody uses it at
  this point.  sysfs_chmod_file_ns() can be added later if necessary.

* Explicit @ns is propagated through class_{create|remove}_file_ns()
  and netdev_class_{create|remove}_file_ns().

* driver/net/bonding which is currently the only user of attr
  namespace is updated to use netdev_class_{create|remove}_file_ns()
  with @bh->net as the ns tag instead of using the namespace callback.

This patch should be an equivalent conversion without any functional
difference.  It makes the code easier to follow, reduces lines of code
a bit and helps proper separation and layering.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Kay Sievers <kay@vrfy.org>
---
 drivers/base/class.c             | 29 ++++--------
 drivers/net/bonding/bond_sysfs.c | 14 ++----
 fs/sysfs/file.c                  | 95 ++++++++++------------------------------
 fs/sysfs/group.c                 |  7 +--
 fs/sysfs/sysfs.h                 |  5 ++-
 include/linux/device.h           | 24 +++++++---
 include/linux/netdevice.h        | 16 ++++++-
 include/linux/sysfs.h            | 31 +++++++++----
 net/core/net-sysfs.c             | 14 +++---
 9 files changed, 106 insertions(+), 129 deletions(-)

diff --git a/drivers/base/class.c b/drivers/base/class.c
index 8b7818b..f96f704 100644
--- a/drivers/base/class.c
+++ b/drivers/base/class.c
@@ -47,18 +47,6 @@ static ssize_t class_attr_store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
-static const void *class_attr_namespace(struct kobject *kobj,
-					const struct attribute *attr)
-{
-	struct class_attribute *class_attr = to_class_attr(attr);
-	struct subsys_private *cp = to_subsys_private(kobj);
-	const void *ns = NULL;
-
-	if (class_attr->namespace)
-		ns = class_attr->namespace(cp->class, class_attr);
-	return ns;
-}
-
 static void class_release(struct kobject *kobj)
 {
 	struct subsys_private *cp = to_subsys_private(kobj);
@@ -86,7 +74,6 @@ static const struct kobj_ns_type_operations *class_child_ns_type(struct kobject
 static const struct sysfs_ops class_sysfs_ops = {
 	.show	   = class_attr_show,
 	.store	   = class_attr_store,
-	.namespace = class_attr_namespace,
 };
 
 static struct kobj_type class_ktype = {
@@ -99,21 +86,23 @@ static struct kobj_type class_ktype = {
 static struct kset *class_kset;
 
 
-int class_create_file(struct class *cls, const struct class_attribute *attr)
+int class_create_file_ns(struct class *cls, const struct class_attribute *attr,
+			 const void *ns)
 {
 	int error;
 	if (cls)
-		error = sysfs_create_file(&cls->p->subsys.kobj,
-					  &attr->attr);
+		error = sysfs_create_file_ns(&cls->p->subsys.kobj,
+					     &attr->attr, ns);
 	else
 		error = -EINVAL;
 	return error;
 }
 
-void class_remove_file(struct class *cls, const struct class_attribute *attr)
+void class_remove_file_ns(struct class *cls, const struct class_attribute *attr,
+			  const void *ns)
 {
 	if (cls)
-		sysfs_remove_file(&cls->p->subsys.kobj, &attr->attr);
+		sysfs_remove_file_ns(&cls->p->subsys.kobj, &attr->attr, ns);
 }
 
 static struct class *class_get(struct class *cls)
@@ -600,8 +589,8 @@ int __init classes_init(void)
 	return 0;
 }
 
-EXPORT_SYMBOL_GPL(class_create_file);
-EXPORT_SYMBOL_GPL(class_remove_file);
+EXPORT_SYMBOL_GPL(class_create_file_ns);
+EXPORT_SYMBOL_GPL(class_remove_file_ns);
 EXPORT_SYMBOL_GPL(class_unregister);
 EXPORT_SYMBOL_GPL(class_destroy);
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index eeab40b..72ad0a9 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -149,14 +149,6 @@ err_no_cmd:
 	return -EPERM;
 }
 
-static const void *bonding_namespace(struct class *cls,
-				     const struct class_attribute *attr)
-{
-	const struct bond_net *bn =
-		container_of(attr, struct bond_net, class_attr_bonding_masters);
-	return bn->net;
-}
-
 /* class attribute for bond_masters file.  This ends up in /sys/class/net */
 static const struct class_attribute class_attr_bonding_masters = {
 	.attr = {
@@ -165,7 +157,6 @@ static const struct class_attribute class_attr_bonding_masters = {
 	},
 	.show = bonding_show_bonds,
 	.store = bonding_store_bonds,
-	.namespace = bonding_namespace,
 };
 
 int bond_create_slave_symlinks(struct net_device *master,
@@ -1748,7 +1739,8 @@ int bond_create_sysfs(struct bond_net *bn)
 	bn->class_attr_bonding_masters = class_attr_bonding_masters;
 	sysfs_attr_init(&bn->class_attr_bonding_masters.attr);
 
-	ret = netdev_class_create_file(&bn->class_attr_bonding_masters);
+	ret = netdev_class_create_file_ns(&bn->class_attr_bonding_masters,
+					  bn->net);
 	/*
 	 * Permit multiple loads of the module by ignoring failures to
 	 * create the bonding_masters sysfs file.  Bonding devices
@@ -1778,7 +1770,7 @@ int bond_create_sysfs(struct bond_net *bn)
  */
 void bond_destroy_sysfs(struct bond_net *bn)
 {
-	netdev_class_remove_file(&bn->class_attr_bonding_masters);
+	netdev_class_remove_file_ns(&bn->class_attr_bonding_masters, bn->net);
 }
 
 /*
diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index 15ef5eb..e784340 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -485,58 +485,15 @@ const struct file_operations sysfs_file_operations = {
 	.poll		= sysfs_poll,
 };
 
-static int sysfs_attr_ns(struct kobject *kobj, const struct attribute *attr,
-			 const void **pns)
-{
-	struct sysfs_dirent *dir_sd = kobj->sd;
-	const struct sysfs_ops *ops;
-	const void *ns = NULL;
-	int err;
-
-	if (!dir_sd) {
-		WARN(1, KERN_ERR "sysfs: kobject %s without dirent\n",
-			kobject_name(kobj));
-		return -ENOENT;
-	}
-
-	err = 0;
-	if (!sysfs_ns_type(dir_sd))
-		goto out;
-
-	err = -EINVAL;
-	if (!kobj->ktype)
-		goto out;
-	ops = kobj->ktype->sysfs_ops;
-	if (!ops)
-		goto out;
-	if (!ops->namespace)
-		goto out;
-
-	err = 0;
-	ns = ops->namespace(kobj, attr);
-out:
-	if (err) {
-		WARN(1, KERN_ERR
-		     "missing sysfs namespace attribute operation for kobject: %s\n",
-		     kobject_name(kobj));
-	}
-	*pns = ns;
-	return err;
-}
-
-int sysfs_add_file_mode(struct sysfs_dirent *dir_sd,
-			const struct attribute *attr, int type, umode_t amode)
+int sysfs_add_file_mode_ns(struct sysfs_dirent *dir_sd,
+			   const struct attribute *attr, int type,
+			   umode_t amode, const void *ns)
 {
 	umode_t mode = (amode & S_IALLUGO) | S_IFREG;
 	struct sysfs_addrm_cxt acxt;
 	struct sysfs_dirent *sd;
-	const void *ns;
 	int rc;
 
-	rc = sysfs_attr_ns(dir_sd->s_dir.kobj, attr, &ns);
-	if (rc)
-		return rc;
-
 	sd = sysfs_new_dirent(attr->name, mode, type);
 	if (!sd)
 		return -ENOMEM;
@@ -559,23 +516,25 @@ int sysfs_add_file_mode(struct sysfs_dirent *dir_sd,
 int sysfs_add_file(struct sysfs_dirent *dir_sd, const struct attribute *attr,
 		   int type)
 {
-	return sysfs_add_file_mode(dir_sd, attr, type, attr->mode);
+	return sysfs_add_file_mode_ns(dir_sd, attr, type, attr->mode, NULL);
 }
 
-
 /**
- *	sysfs_create_file - create an attribute file for an object.
- *	@kobj:	object we're creating for.
- *	@attr:	attribute descriptor.
+ * sysfs_create_file_ns - create an attribute file for an object with custom ns
+ * @kobj: object we're creating for
+ * @attr: attribute descriptor
+ * @ns: namespace the new file should belong to
  */
-int sysfs_create_file(struct kobject *kobj, const struct attribute *attr)
+int sysfs_create_file_ns(struct kobject *kobj, const struct attribute *attr,
+			 const void *ns)
 {
 	BUG_ON(!kobj || !kobj->sd || !attr);
 
-	return sysfs_add_file(kobj->sd, attr, SYSFS_KOBJ_ATTR);
+	return sysfs_add_file_mode_ns(kobj->sd, attr, SYSFS_KOBJ_ATTR,
+				      attr->mode, ns);
 
 }
-EXPORT_SYMBOL_GPL(sysfs_create_file);
+EXPORT_SYMBOL_GPL(sysfs_create_file_ns);
 
 int sysfs_create_files(struct kobject *kobj, const struct attribute **ptr)
 {
@@ -630,17 +589,12 @@ int sysfs_chmod_file(struct kobject *kobj, const struct attribute *attr,
 {
 	struct sysfs_dirent *sd;
 	struct iattr newattrs;
-	const void *ns;
 	int rc;
 
-	rc = sysfs_attr_ns(kobj, attr, &ns);
-	if (rc)
-		return rc;
-
 	mutex_lock(&sysfs_mutex);
 
 	rc = -ENOENT;
-	sd = sysfs_find_dirent(kobj->sd, ns, attr->name);
+	sd = sysfs_find_dirent(kobj->sd, NULL, attr->name);
 	if (!sd)
 		goto out;
 
@@ -655,22 +609,21 @@ int sysfs_chmod_file(struct kobject *kobj, const struct attribute *attr,
 EXPORT_SYMBOL_GPL(sysfs_chmod_file);
 
 /**
- *	sysfs_remove_file - remove an object attribute.
- *	@kobj:	object we're acting for.
- *	@attr:	attribute descriptor.
+ * sysfs_remove_file_ns - remove an object attribute with a custom ns tag
+ * @kobj: object we're acting for
+ * @attr: attribute descriptor
+ * @ns: namespace tag of the file to remove
  *
- *	Hash the attribute name and kill the victim.
+ * Hash the attribute name and namespace tag and kill the victim.
  */
-void sysfs_remove_file(struct kobject *kobj, const struct attribute *attr)
+void sysfs_remove_file_ns(struct kobject *kobj, const struct attribute *attr,
+			  const void *ns)
 {
-	const void *ns;
-
-	if (sysfs_attr_ns(kobj, attr, &ns))
-		return;
+	struct sysfs_dirent *dir_sd = kobj->sd;
 
-	sysfs_hash_and_remove(kobj->sd, ns, attr->name);
+	sysfs_hash_and_remove(dir_sd, ns, attr->name);
 }
-EXPORT_SYMBOL_GPL(sysfs_remove_file);
+EXPORT_SYMBOL_GPL(sysfs_remove_file_ns);
 
 void sysfs_remove_files(struct kobject *kobj, const struct attribute **ptr)
 {
diff --git a/fs/sysfs/group.c b/fs/sysfs/group.c
index 5f92cd2..25c78f2 100644
--- a/fs/sysfs/group.c
+++ b/fs/sysfs/group.c
@@ -56,9 +56,10 @@ static int create_files(struct sysfs_dirent *dir_sd, struct kobject *kobj,
 				if (!mode)
 					continue;
 			}
-			error = sysfs_add_file_mode(dir_sd, *attr,
-						    SYSFS_KOBJ_ATTR,
-						    (*attr)->mode | mode);
+			error = sysfs_add_file_mode_ns(dir_sd, *attr,
+						       SYSFS_KOBJ_ATTR,
+						       (*attr)->mode | mode,
+						       NULL);
 			if (unlikely(error))
 				break;
 		}
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index b6deca3..a96da25 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -230,8 +230,9 @@ extern const struct file_operations sysfs_file_operations;
 int sysfs_add_file(struct sysfs_dirent *dir_sd,
 		   const struct attribute *attr, int type);
 
-int sysfs_add_file_mode(struct sysfs_dirent *dir_sd,
-			const struct attribute *attr, int type, umode_t amode);
+int sysfs_add_file_mode_ns(struct sysfs_dirent *dir_sd,
+			   const struct attribute *attr, int type,
+			   umode_t amode, const void *ns);
 /*
  * bin.c
  */
diff --git a/include/linux/device.h b/include/linux/device.h
index 2a9d6ed..ce690ea 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -427,8 +427,6 @@ struct class_attribute {
 			char *buf);
 	ssize_t (*store)(struct class *class, struct class_attribute *attr,
 			const char *buf, size_t count);
-	const void *(*namespace)(struct class *class,
-				 const struct class_attribute *attr);
 };
 
 #define CLASS_ATTR(_name, _mode, _show, _store) \
@@ -438,10 +436,24 @@ struct class_attribute {
 #define CLASS_ATTR_RO(_name) \
 	struct class_attribute class_attr_##_name = __ATTR_RO(_name)
 
-extern int __must_check class_create_file(struct class *class,
-					  const struct class_attribute *attr);
-extern void class_remove_file(struct class *class,
-			      const struct class_attribute *attr);
+extern int __must_check class_create_file_ns(struct class *class,
+					     const struct class_attribute *attr,
+					     const void *ns);
+extern void class_remove_file_ns(struct class *class,
+				 const struct class_attribute *attr,
+				 const void *ns);
+
+static inline int __must_check class_create_file(struct class *class,
+					const struct class_attribute *attr)
+{
+	return class_create_file_ns(class, attr, NULL);
+}
+
+static inline void class_remove_file(struct class *class,
+				     const struct class_attribute *attr)
+{
+	return class_remove_file_ns(class, attr, NULL);
+}
 
 /* Simple class attribute that is just a static string */
 struct class_attribute_string {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 041b42a..d551624 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2873,8 +2873,20 @@ extern int __init dev_proc_init(void);
 #define dev_proc_init() 0
 #endif
 
-extern int netdev_class_create_file(struct class_attribute *class_attr);
-extern void netdev_class_remove_file(struct class_attribute *class_attr);
+extern int netdev_class_create_file_ns(struct class_attribute *class_attr,
+				       const void *ns);
+extern void netdev_class_remove_file_ns(struct class_attribute *class_attr,
+					const void *ns);
+
+static inline int netdev_class_create_file(struct class_attribute *class_attr)
+{
+	return netdev_class_create_file_ns(class_attr, NULL);
+}
+
+static inline void netdev_class_remove_file(struct class_attribute *class_attr)
+{
+	netdev_class_remove_file_ns(class_attr, NULL);
+}
 
 extern struct kobj_ns_type_operations net_ns_type_operations;
 
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index 11baec7..82f7fac 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -173,7 +173,6 @@ struct bin_attribute bin_attr_##_name = __BIN_ATTR_RW(_name, _size)
 struct sysfs_ops {
 	ssize_t	(*show)(struct kobject *, struct attribute *, char *);
 	ssize_t	(*store)(struct kobject *, struct attribute *, const char *, size_t);
-	const void *(*namespace)(struct kobject *, const struct attribute *);
 };
 
 struct sysfs_dirent;
@@ -189,13 +188,15 @@ int __must_check sysfs_rename_dir(struct kobject *kobj, const char *new_name);
 int __must_check sysfs_move_dir(struct kobject *kobj,
 				struct kobject *new_parent_kobj);
 
-int __must_check sysfs_create_file(struct kobject *kobj,
-				   const struct attribute *attr);
+int __must_check sysfs_create_file_ns(struct kobject *kobj,
+				      const struct attribute *attr,
+				      const void *ns);
 int __must_check sysfs_create_files(struct kobject *kobj,
 				   const struct attribute **attr);
 int __must_check sysfs_chmod_file(struct kobject *kobj,
 				  const struct attribute *attr, umode_t mode);
-void sysfs_remove_file(struct kobject *kobj, const struct attribute *attr);
+void sysfs_remove_file_ns(struct kobject *kobj, const struct attribute *attr,
+			  const void *ns);
 void sysfs_remove_files(struct kobject *kobj, const struct attribute **attr);
 
 int __must_check sysfs_create_bin_file(struct kobject *kobj,
@@ -277,8 +278,9 @@ static inline int sysfs_move_dir(struct kobject *kobj,
 	return 0;
 }
 
-static inline int sysfs_create_file(struct kobject *kobj,
-				    const struct attribute *attr)
+static inline int sysfs_create_file_ns(struct kobject *kobj,
+				       const struct attribute *attr,
+				       const void *ns)
 {
 	return 0;
 }
@@ -295,8 +297,9 @@ static inline int sysfs_chmod_file(struct kobject *kobj,
 	return 0;
 }
 
-static inline void sysfs_remove_file(struct kobject *kobj,
-				     const struct attribute *attr)
+static inline void sysfs_remove_file_ns(struct kobject *kobj,
+					const struct attribute *attr,
+					const void *ns)
 {
 }
 
@@ -435,4 +438,16 @@ static inline int __must_check sysfs_init(void)
 
 #endif /* CONFIG_SYSFS */
 
+static inline int __must_check sysfs_create_file(struct kobject *kobj,
+						 const struct attribute *attr)
+{
+	return sysfs_create_file_ns(kobj, attr, NULL);
+}
+
+static inline void sysfs_remove_file(struct kobject *kobj,
+				     const struct attribute *attr)
+{
+	return sysfs_remove_file_ns(kobj, attr, NULL);
+}
+
 #endif /* _SYSFS_H_ */
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index d954b56..325dee8 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1344,17 +1344,19 @@ int netdev_register_kobject(struct net_device *net)
 	return error;
 }
 
-int netdev_class_create_file(struct class_attribute *class_attr)
+int netdev_class_create_file_ns(struct class_attribute *class_attr,
+				const void *ns)
 {
-	return class_create_file(&net_class, class_attr);
+	return class_create_file_ns(&net_class, class_attr, ns);
 }
-EXPORT_SYMBOL(netdev_class_create_file);
+EXPORT_SYMBOL(netdev_class_create_file_ns);
 
-void netdev_class_remove_file(struct class_attribute *class_attr)
+void netdev_class_remove_file_ns(struct class_attribute *class_attr,
+				 const void *ns)
 {
-	class_remove_file(&net_class, class_attr);
+	class_remove_file_ns(&net_class, class_attr, ns);
 }
-EXPORT_SYMBOL(netdev_class_remove_file);
+EXPORT_SYMBOL(netdev_class_remove_file_ns);
 
 int netdev_kobject_init(void)
 {
-- 
1.8.3.1
