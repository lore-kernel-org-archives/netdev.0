From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [RFC][PATCH] Very basic sysfs support for ATM devices (updated)
Date: Fri, 04 Feb 2005 13:11:25 -0500
Message-ID: <200502041811.j14IBOna020338@ginger.cmf.nrl.navy.mil>
References: <rkagan@mail.ru>
Cc: netdev@oss.sgi.com, linux-atm-general@lists.sourceforge.net,
        usbatm@lists.infradead.org
To: Roman Kagan <rkagan@mail.ru>
In-Reply-To: Message from Roman Kagan <rkagan@mail.ru>
   of "Fri, 21 Jan 2005 11:51:23 +0300." <20050121085123.GA2471@katya>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20050121085123.GA2471@katya>,Roman Kagan writes:
>The patch is against 2.6.10.  Please comment.

i guess i would prefer that entries be named typeN, like he0
instead of just a number.

you were printing 7 octets for the address.

if !CONFIG_SYSFS, then __free_atm_dev() is going to need to do the
kfree.

i added some other fields that i think are interesting.

comments?


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/04 13:05:34-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: basic sysfs support for ATM devices (from Roman Kagan <rkagan@mail.ru>)
# 
# net/atm/atm_sysfs.c
#   2005/02/04 13:05:17-05:00 chas@relax.cmf.nrl.navy.mil +181 -0
# 
# net/atm/resources.h
#   2005/02/04 13:05:17-05:00 chas@relax.cmf.nrl.navy.mil +3 -0
#   [ATM]: basic sysfs support for ATM devices (from Roman Kagan <rkagan@mail.ru>)
# 
# net/atm/resources.c
#   2005/02/04 13:05:17-05:00 chas@relax.cmf.nrl.navy.mil +22 -6
#   [ATM]: basic sysfs support for ATM devices (from Roman Kagan <rkagan@mail.ru>)
# 
# net/atm/atm_sysfs.c
#   2005/02/04 13:05:17-05:00 chas@relax.cmf.nrl.navy.mil +0 -0
#   BitKeeper file /scratch/chas/LATEST/2.6/net/atm/atm_sysfs.c
# 
# net/atm/common.h
#   2005/02/04 13:05:16-05:00 chas@relax.cmf.nrl.navy.mil +2 -0
#   [ATM]: basic sysfs support for ATM devices (from Roman Kagan <rkagan@mail.ru>)
# 
# net/atm/common.c
#   2005/02/04 13:05:16-05:00 chas@relax.cmf.nrl.navy.mil +6 -1
#   [ATM]: basic sysfs support for ATM devices (from Roman Kagan <rkagan@mail.ru>)
# 
# net/atm/Makefile
#   2005/02/04 13:05:16-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: basic sysfs support for ATM devices (from Roman Kagan <rkagan@mail.ru>)
# 
# include/linux/atmdev.h
#   2005/02/04 13:05:16-05:00 chas@relax.cmf.nrl.navy.mil +2 -0
#   [ATM]: basic sysfs support for ATM devices (from Roman Kagan <rkagan@mail.ru>)
# 
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	2005-02-04 13:06:48 -05:00
+++ b/include/linux/atmdev.h	2005-02-04 13:06:48 -05:00
@@ -8,6 +8,7 @@
 
 
 #include <linux/config.h>
+#include <linux/device.h>
 #include <linux/atmapi.h>
 #include <linux/atm.h>
 #include <linux/atmioc.h>
@@ -345,6 +346,7 @@
 	struct proc_dir_entry *proc_entry; /* proc entry */
 	char *proc_name;		/* proc entry name */
 #endif
+	struct class_device class_dev;	/* sysfs class device */
 	struct list_head dev_list;	/* linkage */
 };
 
diff -Nru a/net/atm/Makefile b/net/atm/Makefile
--- a/net/atm/Makefile	2005-02-04 13:06:48 -05:00
+++ b/net/atm/Makefile	2005-02-04 13:06:48 -05:00
@@ -2,7 +2,7 @@
 # Makefile for the ATM Protocol Families.
 #
 
-atm-y		:= addr.o pvc.o signaling.o svc.o ioctl.o common.o atm_misc.o raw.o resources.o
+atm-y		:= addr.o pvc.o signaling.o svc.o ioctl.o common.o atm_misc.o raw.o resources.o atm_sysfs.o
 mpoa-objs	:= mpc.o mpoa_caches.o mpoa_proc.o
 
 obj-$(CONFIG_ATM) += atm.o
diff -Nru a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/atm/atm_sysfs.c	2005-02-04 13:06:48 -05:00
@@ -0,0 +1,181 @@
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
+	char *pos = buf;
+	struct atm_dev *adev = to_atm_dev(cdev);
+	int i;
+
+	for (i = 0; i < (ESI_LEN - 1); i++)
+		pos += sprintf(pos, "%02x:", adev->esi[i]);
+	pos += sprintf(pos, "%02x\n", adev->esi[i]);
+
+	return pos - buf;
+}
+
+static ssize_t show_atmaddress(struct class_device *cdev, char *buf)
+{
+        unsigned long flags;
+	char *pos = buf;
+	struct atm_dev *adev = to_atm_dev(cdev);
+        struct atm_dev_addr *aaddr;
+	int bin[] = { 1, 2, 10, 6, 1 }, *fmt = bin;
+	int i, j;
+
+        spin_lock_irqsave(&adev->lock, flags);
+        list_for_each_entry(aaddr, &adev->local, entry) {
+		for(i = 0, j = 0; i < ATM_ESA_LEN; ++i, ++j) {
+			if (j == *fmt) {
+				pos += sprintf(pos, ".");
+				++fmt;
+				j = 0;
+			}
+			pos += sprintf(pos, "%02x", aaddr->addr.sas_addr.prv[i]);
+		}
+		pos += sprintf(pos, "\n");
+	}
+        spin_unlock_irqrestore(&adev->lock, flags);
+
+	return pos - buf;
+}
+
+static ssize_t show_carrier(struct class_device *cdev, char *buf)
+{
+	char *pos = buf;
+	struct atm_dev *adev = to_atm_dev(cdev);
+
+	pos += sprintf(pos, "%d\n",
+		       adev->signal == ATM_PHY_SIG_LOST ? 0 : 1);
+		
+	return pos - buf;
+}
+
+static ssize_t show_link_rate(struct class_device *cdev, char *buf)
+{
+	char *pos = buf;
+	struct atm_dev *adev = to_atm_dev(cdev);
+	int link_rate;
+
+	/* show the link rate, not the data rate */
+	switch (adev->link_rate) {
+		case ATM_OC3_PCR:
+			link_rate = 155520000;
+			break;
+		case ATM_OC12_PCR:
+			link_rate = 622080000;
+			break;
+		case ATM_25_PCR:
+			link_rate = 25600000;
+			break;
+		default:
+			link_rate = adev->link_rate * 8 * 53;
+	}
+	pos += sprintf(pos, "%d\n", link_rate);
+		
+	return pos - buf;
+}
+
+static CLASS_DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
+static CLASS_DEVICE_ATTR(atmaddress, S_IRUGO, show_atmaddress, NULL);
+static CLASS_DEVICE_ATTR(carrier, S_IRUGO, show_carrier, NULL);
+static CLASS_DEVICE_ATTR(type, S_IRUGO, show_type, NULL);
+static CLASS_DEVICE_ATTR(link_rate, S_IRUGO, show_link_rate, NULL);
+
+static struct class_device_attribute *atm_attrs[] = {
+	&class_device_attr_atmaddress,
+	&class_device_attr_address,
+	&class_device_attr_carrier,
+	&class_device_attr_type,
+	&class_device_attr_link_rate,
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
+				"INTERFACE=%s%d", adev->type, adev->number))
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
+	snprintf(cdev->class_id, BUS_ID_SIZE, "%s%d", adev->type, adev->number);
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
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	2005-02-04 13:06:48 -05:00
+++ b/net/atm/common.c	2005-02-04 13:06:48 -05:00
@@ -793,6 +793,10 @@
 		printk(KERN_ERR "atm_proc_init() failed with %d\n",error);
 		goto failure;
 	}
+        if ((error = atm_sysfs_init()) < 0) {
+		printk(KERN_ERR "atm_sysfs_init() failed with %d\n",error);
+		goto failure;
+	}
 	return 0;
 
 failure:
@@ -804,11 +808,12 @@
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
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	2005-02-04 13:06:48 -05:00
+++ b/net/atm/common.h	2005-02-04 13:06:48 -05:00
@@ -28,6 +28,8 @@
 void atmpvc_exit(void);
 int atmsvc_init(void);
 void atmsvc_exit(void);
+int atm_sysfs_init(void);
+void atm_sysfs_exit(void);
 
 #ifdef CONFIG_PROC_FS
 int atm_proc_init(void);
diff -Nru a/net/atm/resources.c b/net/atm/resources.c
--- a/net/atm/resources.c	2005-02-04 13:06:48 -05:00
+++ b/net/atm/resources.c	2005-02-04 13:06:48 -05:00
@@ -47,7 +47,11 @@
 
 static void __free_atm_dev(struct atm_dev *dev)
 {
+#ifdef CONFIG_SYSFS
+	class_device_put(&dev->class_dev);
+#else
 	kfree(dev);
+#endif
 }
 
 static struct atm_dev *__atm_dev_lookup(int number)
@@ -91,7 +95,7 @@
 		if ((inuse = __atm_dev_lookup(number))) {
 			atm_dev_put(inuse);
 			spin_unlock(&atm_dev_lock);
-			__free_atm_dev(dev);
+			kfree(dev);
 			return NULL;
 		}
 		dev->number = number;
@@ -117,14 +121,25 @@
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
+	kfree(dev);
+	return NULL;
 }
 
 
@@ -132,6 +147,7 @@
 {
 	unsigned long warning_time;
 
+	atm_unregister_sysfs(dev);
 	atm_proc_dev_deregister(dev);
 
 	spin_lock(&atm_dev_lock);
diff -Nru a/net/atm/resources.h b/net/atm/resources.h
--- a/net/atm/resources.h	2005-02-04 13:06:48 -05:00
+++ b/net/atm/resources.h	2005-02-04 13:06:48 -05:00
@@ -43,4 +43,7 @@
 
 #endif /* CONFIG_PROC_FS */
 
+int atm_register_sysfs(struct atm_dev *adev);
+void atm_unregister_sysfs(struct atm_dev *adev);
+
 #endif
