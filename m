From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 4/8] driver core: Implement tagged directory support for device classes.
Date: Wed, 20 Aug 2008 23:37:55 -0700
Message-ID: <m1zln6zxdo.fsf_-_@frodo.ebiederm.org>
References: <m1y74iiidz.fsf_-_@frodo.ebiederm.org>
	<m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
	<m1prpuihjb.fsf_-_@frodo.ebiederm.org>
	<m1lk0iihhp.fsf_-_@frodo.ebiederm.org>
	<m1hcb6ihfz.fsf_-_@frodo.ebiederm.org>
	<m1d4luihea.fsf_-_@frodo.ebiederm.org>
	<m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>
	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>
	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>
	<20080820021754.GA25182@kroah.com>
	<m1od3m282j.fsf_-_@frodo.ebiederm.org>
	<m1hc9e27ya.fsf_-_@frodo.ebiederm.org>
	<m1d4k227wg.fsf_-_@frodo.ebiederm.org>
	<m18wuq27uj.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:50460 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756156AbYHUGoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 02:44:10 -0400
In-Reply-To: <m18wuq27uj.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 20 Aug 2008 23:35:48 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch enables tagging on every class directory if struct class
has a tag_type.

In addition device_del and device_rename were modified to use
sysfs_delete_link and sysfs_rename_link respectively to ensure
when these operations happen on devices whose classes have
tag_ops that they work properly.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 drivers/base/class.c   |   30 ++++++++++++++++++++++---
 drivers/base/core.c    |   56 ++++++++++++++++++++++++++++++------------------
 include/linux/device.h |    3 ++
 3 files changed, 64 insertions(+), 25 deletions(-)

diff --git a/drivers/base/class.c b/drivers/base/class.c
index cc5e28c..0cd5704 100644
--- a/drivers/base/class.c
+++ b/drivers/base/class.c
@@ -135,6 +135,17 @@ static void remove_class_attrs(struct class *cls)
 	}
 }
 
+static int class_setup_tagging(struct class *cls)
+{
+	enum sysfs_tag_type type;
+
+	type = cls->tag_type;
+	if (type == SYSFS_TAG_TYPE_NONE)
+		return 0;
+
+	return sysfs_make_tagged_dir(&cls->p->class_subsys.kobj, type);
+}
+
 int __class_register(struct class *cls, struct lock_class_key *key)
 {
 	struct class_private *cp;
@@ -171,13 +182,24 @@ int __class_register(struct class *cls, struct lock_class_key *key)
 	cls->p = cp;
 
 	error = kset_register(&cp->class_subsys);
-	if (error) {
-		kfree(cp);
-		return error;
-	}
+	if (error)
+		goto out_free_cp;
+
+	error = class_setup_tagging(cls);
+	if (error)
+		goto out_unregister;
+
 	error = add_class_attrs(class_get(cls));
 	class_put(cls);
+	if (error)
+		goto out_unregister;
+out:
 	return error;
+out_unregister:
+	kset_unregister(&cp->class_subsys);
+out_free_cp:
+	kfree(cp);
+	goto out;
 }
 EXPORT_SYMBOL_GPL(__class_register);
 
diff --git a/drivers/base/core.c b/drivers/base/core.c
index 2bf7116..4fb9b00 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -122,9 +122,21 @@ static void device_release(struct kobject *kobj)
 			dev->bus_id);
 }
 
+static const void *device_sysfs_tag(struct kobject *kobj)
+{
+	struct device *dev = to_dev(kobj);
+	const void *tag = NULL;
+
+	if (dev->class && dev->class->tag_type)
+		tag = dev->class->sysfs_tag(dev);
+
+	return tag;
+}
+
 static struct kobj_type device_ktype = {
 	.release	= device_release,
 	.sysfs_ops	= &dev_sysfs_ops,
+	.sysfs_tag	= device_sysfs_tag,
 };
 
 
@@ -617,6 +629,10 @@ static struct kobject *get_device_parent(struct device *dev,
 			kobject_put(k);
 			return NULL;
 		}
+		/* If we created a new class-directory setup tagging */
+		if (dev->class->tag_type)
+			sysfs_make_tagged_dir(k, dev->class->tag_type);
+
 		/* do not emit an uevent for this simple "glue" directory */
 		return k;
 	}
@@ -707,7 +723,7 @@ out_device:
 out_busid:
 	if (dev->kobj.parent != &dev->class->p->class_subsys.kobj &&
 	    device_is_not_partition(dev))
-		sysfs_remove_link(&dev->class->p->class_subsys.kobj,
+		sysfs_delete_link(&dev->class->p->class_subsys.kobj, &dev->kobj,
 				  dev->bus_id);
 #else
 	/* link in the class directory pointing to the device */
@@ -725,7 +741,7 @@ out_busid:
 	return 0;
 
 out_busid:
-	sysfs_remove_link(&dev->class->p->class_subsys.kobj, dev->bus_id);
+	sysfs_delete_link(&dev->class->p->class_subsys.kobj, &dev->kobj, dev->bus_id);
 #endif
 
 out_subsys:
@@ -753,13 +769,13 @@ static void device_remove_class_symlinks(struct device *dev)
 
 	if (dev->kobj.parent != &dev->class->p->class_subsys.kobj &&
 	    device_is_not_partition(dev))
-		sysfs_remove_link(&dev->class->p->class_subsys.kobj,
+		sysfs_delete_link(&dev->class->p->class_subsys.kobj, &dev->kobj,
 				  dev->bus_id);
 #else
 	if (dev->parent && device_is_not_partition(dev))
 		sysfs_remove_link(&dev->kobj, "device");
 
-	sysfs_remove_link(&dev->class->p->class_subsys.kobj, dev->bus_id);
+	sysfs_delete_link(&dev->class->p->class_subsys.kobj, &dev->kobj, dev->bus_id);
 #endif
 
 	sysfs_remove_link(&dev->kobj, "subsystem");
@@ -1347,6 +1363,15 @@ int device_rename(struct device *dev, char *new_name)
 	strlcpy(old_device_name, dev->bus_id, BUS_ID_SIZE);
 	strlcpy(dev->bus_id, new_name, BUS_ID_SIZE);
 
+#ifndef CONFIG_SYSFS_DEPRECATED
+	if (dev->class) {
+		error = sysfs_rename_link(&dev->class->p->class_subsys.kobj,
+			&dev->kobj, old_device_name, new_name);
+		if (error)
+			goto out;
+	}
+#endif
+
 	error = kobject_rename(&dev->kobj, new_name);
 	if (error) {
 		strlcpy(dev->bus_id, old_device_name, BUS_ID_SIZE);
@@ -1355,24 +1380,13 @@ int device_rename(struct device *dev, char *new_name)
 
 #ifdef CONFIG_SYSFS_DEPRECATED
 	if (old_class_name) {
+		error = -ENOMEM;
 		new_class_name = make_class_name(dev->class->name, &dev->kobj);
-		if (new_class_name) {
-			error = sysfs_create_link_nowarn(&dev->parent->kobj,
-							 &dev->kobj,
-							 new_class_name);
-			if (error)
-				goto out;
-			sysfs_remove_link(&dev->parent->kobj, old_class_name);
-		}
-	}
-#else
-	if (dev->class) {
-		error = sysfs_create_link_nowarn(&dev->class->p->class_subsys.kobj,
-						 &dev->kobj, dev->bus_id);
-		if (error)
-			goto out;
-		sysfs_remove_link(&dev->class->p->class_subsys.kobj,
-				  old_device_name);
+		if (new_class_name)
+			error = sysfs_rename_link(&dev->parent->kobj,
+						  &dev->kobj,
+						  old_class_name,
+						  new_class_name);
 	}
 #endif
 
diff --git a/include/linux/device.h b/include/linux/device.h
index d6fdd60..8d65016 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -195,6 +195,9 @@ struct class {
 	int (*suspend)(struct device *dev, pm_message_t state);
 	int (*resume)(struct device *dev);
 
+	enum sysfs_tag_type tag_type;
+	const void *(*sysfs_tag)(struct device *dev);
+
 	struct pm_ops *pm;
 	struct class_private *p;
 };
-- 
1.5.3.rc6.17.g1911

