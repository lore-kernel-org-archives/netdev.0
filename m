From: Roman Kagan <rkagan@mail.ru>
Subject: [RFC][PATCH] Very basic sysfs support for ATM devices (updated)
Date: Fri, 21 Jan 2005 11:51:23 +0300
Message-ID: <20050121085123.GA2471@katya>
References: <20050119174543.GA2418@katya>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: usbatm@lists.infradead.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-atm-general@lists.sourceforge.net
Content-Disposition: inline
In-Reply-To: <20050119174543.GA2418@katya>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  Hi,

Here's a quick patch to add very basic sysfs support to ATM devices.  It
creates class/atm and provides a couple of attributes for each ATM
device and hotplug callout for device addition/removal, which was the
main motivation for me to write it up.

With this patch, an utility to set up a network interface on the newly
registered ATM device can be called automatically via hotplug, just as
it is done with net_device.

Compared to the first version sent to linux-atm-general mailing list, it
fixes the accidentally sneaked in bug using class_device_unregister
instead of class_device_del, and replaces mutual references of
class_device and atm_dev with container_of.

The patch is against 2.6.10.  Please comment.

Thanks,
  Roman.

 include/linux/atmdev.h |    2
 net/atm/Makefile       |    2
 net/atm/atm_sysfs.c    |  113 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/atm/common.c       |    7 ++-
 net/atm/common.h       |    2
 net/atm/resources.c    |   31 ++++++++++---
 net/atm/resources.h    |    3 +
 7 files changed, 152 insertions(+), 8 deletions(-)


diff -rupN -x '*~' linux-2.6.10.orig/include/linux/atmdev.h linux-2.6.10/include/linux/atmdev.h
--- linux-2.6.10.orig/include/linux/atmdev.h	2004-12-25 00:35:24.000000000 +0300
+++ linux-2.6.10/include/linux/atmdev.h	2005-01-19 16:44:09.000000000 +0300
@@ -8,6 +8,7 @@
 
 
 #include <linux/config.h>
+#include <linux/device.h>
 #include <linux/atmapi.h>
 #include <linux/atm.h>
 #include <linux/atmioc.h>
@@ -337,6 +338,7 @@ struct atm_dev {
 	struct proc_dir_entry *proc_entry; /* proc entry */
 	char *proc_name;		/* proc entry name */
 #endif
+	struct class_device class_dev;	/* sysfs class device */
 	struct list_head dev_list;	/* linkage */
 };
 
diff -rupN -x '*~' linux-2.6.10.orig/net/atm/atm_sysfs.c linux-2.6.10/net/atm/atm_sysfs.c
--- linux-2.6.10.orig/net/atm/atm_sysfs.c	1970-01-01 03:00:00.000000000 +0300
+++ linux-2.6.10/net/atm/atm_sysfs.c	2005-01-21 04:03:46.000000000 +0300
@@ -0,0 +1,113 @@
+/* ATM driver model support. */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/kobject.h>
+#include <linux/atmdev.h>
+#include "common.h"
+#include "resources.h"
+
+#define to_atm_dev(cldev) container_of(cldev, struct atm_dev, class_dev)
+
+static ssize_t show_type(struct class_device *cdev, char *buf)
+{
+	struct atm_dev *adev = to_atm_dev(cdev);
+	return sprintf(buf, "%s\n", adev->type);
+}
+
+static ssize_t show_address(struct class_device *cdev, char *buf)
+{
+	int i;
+	char *pos = buf;
+	struct atm_dev *adev = to_atm_dev(cdev);
+
+	for (i = 0; i < sizeof(adev->esi); i++)
+		pos += sprintf(pos, "%02x:", adev->esi[i]);
+	pos += sprintf(pos, "%02x\n", adev->esi[i]);
+
+	return pos - buf;
+}
+
+static CLASS_DEVICE_ATTR(type, S_IRUGO, show_type, NULL);
+static CLASS_DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
+
+static struct class_device_attribute *atm_attrs[] = {
+	&class_device_attr_type,
+	&class_device_attr_address,
+	NULL
+};
+
+#ifdef CONFIG_HOTPLUG
+static int atm_hotplug(struct class_device *cdev, char **envp, int num_envp, char *buf, int size)
+{
+	struct atm_dev *adev;
+	int i = 0;
+	int length = 0;
+
+	if (!cdev)
+		return -ENODEV;
+
+	adev = to_atm_dev(cdev);
+	if (!adev)
+		return -ENODEV;
+
+        if (add_hotplug_env_var(envp, num_envp, &i, buf, size, &length,
+				"INTERFACE=%d", adev->number))
+		return -ENOMEM;
+
+	envp[i] = NULL;
+	return 0;
+}
+#endif
+
+static void atm_release(struct class_device *cdev)
+{
+	struct atm_dev *adev = to_atm_dev(cdev);
+
+	kfree(adev);
+}
+
+static struct class atm_class = {
+	.name		= "atm",
+	.release	= atm_release,
+#ifdef CONFIG_HOTPLUG
+	.hotplug	= atm_hotplug,
+#endif
+};
+
+int atm_register_sysfs(struct atm_dev *adev)
+{
+	struct class_device *cdev = &adev->class_dev;
+	int i, err;
+
+	cdev->class = &atm_class;
+	class_set_devdata(cdev, adev);
+
+	snprintf(cdev->class_id, BUS_ID_SIZE, "%d", adev->number);
+	err = class_device_register(cdev);
+	if (err < 0)
+		return err;
+
+	for (i = 0; atm_attrs[i]; i++)
+		class_device_create_file(cdev, atm_attrs[i]);
+
+	return 0;
+}
+
+void atm_unregister_sysfs(struct atm_dev *adev)
+{
+	struct class_device *cdev = &adev->class_dev;
+
+	class_device_del(cdev);
+}
+
+int __init atm_sysfs_init(void)
+{
+	return class_register(&atm_class);
+}
+
+void __exit atm_sysfs_exit(void)
+{
+	class_unregister(&atm_class);
+}
diff -rupN -x '*~' linux-2.6.10.orig/net/atm/common.c linux-2.6.10/net/atm/common.c
--- linux-2.6.10.orig/net/atm/common.c	2004-12-25 00:35:50.000000000 +0300
+++ linux-2.6.10/net/atm/common.c	2005-01-19 17:01:26.000000000 +0300
@@ -793,6 +793,10 @@ static int __init atm_init(void)
 		printk(KERN_ERR "atm_proc_init() failed with %d\n",error);
 		goto failure;
 	}
+        if ((error = atm_sysfs_init()) < 0) {
+		printk(KERN_ERR "atm_sysfs_init() failed with %d\n",error);
+		goto failure;
+	}
 	return 0;
 
 failure:
@@ -804,11 +808,12 @@ failure:
 static void __exit atm_exit(void)
 {
 	atm_proc_exit();
+	atm_sysfs_exit();
 	atmsvc_exit();
 	atmpvc_exit();
 }
 
-module_init(atm_init);
+subsys_initcall(atm_init);
 module_exit(atm_exit);
 
 MODULE_LICENSE("GPL");
diff -rupN -x '*~' linux-2.6.10.orig/net/atm/common.h linux-2.6.10/net/atm/common.h
--- linux-2.6.10.orig/net/atm/common.h	2004-12-25 00:35:23.000000000 +0300
+++ linux-2.6.10/net/atm/common.h	2005-01-19 16:09:16.000000000 +0300
@@ -28,6 +28,8 @@ int atmpvc_init(void);
 void atmpvc_exit(void);
 int atmsvc_init(void);
 void atmsvc_exit(void);
+int atm_sysfs_init(void);
+void atm_sysfs_exit(void);
 
 #ifdef CONFIG_PROC_FS
 int atm_proc_init(void);
diff -rupN -x '*~' linux-2.6.10.orig/net/atm/Makefile linux-2.6.10/net/atm/Makefile
--- linux-2.6.10.orig/net/atm/Makefile	2004-12-25 00:34:00.000000000 +0300
+++ linux-2.6.10/net/atm/Makefile	2005-01-19 17:04:29.000000000 +0300
@@ -2,7 +2,7 @@
 # Makefile for the ATM Protocol Families.
 #
 
-atm-y		:= addr.o pvc.o signaling.o svc.o ioctl.o common.o atm_misc.o raw.o resources.o
+atm-y		:= addr.o pvc.o signaling.o svc.o ioctl.o common.o atm_misc.o raw.o resources.o atm_sysfs.o
 mpoa-objs	:= mpc.o mpoa_caches.o mpoa_proc.o
 
 obj-$(CONFIG_ATM) += atm.o
diff -rupN -x '*~' linux-2.6.10.orig/net/atm/resources.c linux-2.6.10/net/atm/resources.c
--- linux-2.6.10.orig/net/atm/resources.c	2004-12-25 00:35:29.000000000 +0300
+++ linux-2.6.10/net/atm/resources.c	2005-01-21 04:03:01.000000000 +0300
@@ -47,6 +47,12 @@ static void __free_atm_dev(struct atm_de
 	kfree(dev);
 }
 
+static void release_atm_dev(struct atm_dev *dev)
+{
+	/* will free via class release */
+	class_device_put(&dev->class_dev);
+}
+
 static struct atm_dev *__atm_dev_lookup(int number)
 {
 	struct atm_dev *dev;
@@ -114,14 +120,25 @@ struct atm_dev *atm_dev_register(const c
 		printk(KERN_ERR "atm_dev_register: "
 		       "atm_proc_dev_register failed for dev %s\n",
 		       type);
-		spin_lock(&atm_dev_lock);
-		list_del(&dev->dev_list);
-		spin_unlock(&atm_dev_lock);
-		__free_atm_dev(dev);
-		return NULL;
+		goto reg_fail;
+	}
+
+	if (atm_register_sysfs(dev) < 0) {
+		printk(KERN_ERR "atm_dev_register: "
+		       "atm_register_sysfs failed for dev %s\n",
+		       type);
+		atm_proc_dev_deregister(dev);
+		goto reg_fail;
 	}
 
 	return dev;
+	
+reg_fail:
+	spin_lock(&atm_dev_lock);
+	list_del(&dev->dev_list);
+	spin_unlock(&atm_dev_lock);
+	__free_atm_dev(dev);
+	return NULL;
 }
 
 
@@ -129,6 +146,8 @@ void atm_dev_deregister(struct atm_dev *
 {
 	unsigned long warning_time;
 
+	atm_unregister_sysfs(dev);
+
 	atm_proc_dev_deregister(dev);
 
 	spin_lock(&atm_dev_lock);
@@ -147,7 +166,7 @@ void atm_dev_deregister(struct atm_dev *
                 }
         }
 
-	__free_atm_dev(dev);
+	release_atm_dev(dev);
 }
 
 void shutdown_atm_dev(struct atm_dev *dev)
diff -rupN -x '*~' linux-2.6.10.orig/net/atm/resources.h linux-2.6.10/net/atm/resources.h
--- linux-2.6.10.orig/net/atm/resources.h	2004-12-25 00:36:01.000000000 +0300
+++ linux-2.6.10/net/atm/resources.h	2005-01-19 16:55:20.000000000 +0300
@@ -43,4 +43,7 @@ static inline void atm_proc_dev_deregist
 
 #endif /* CONFIG_PROC_FS */
 
+int atm_register_sysfs(struct atm_dev *adev);
+void atm_unregister_sysfs(struct atm_dev *adev);
+
 #endif
