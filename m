From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 4/4][ATM]: basic sysfs support for ATM devices
Date: Wed, 28 Jun 2006 09:45:42 -0400
Message-ID: <200606281345.k5SDjgh9008958@relax.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:19681 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S932802AbWF1Npx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 09:45:53 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: basic sysfs support for ATM devices

From: Roman Kagan <rkagan@mail.ru>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit 034e4008acda89bc2422541e077f2dbfd530b717
tree e528e0e6f2d69c729f2daf6618df22133b3e4818
parent 4768199f3a5582378164820cc74251e485a01292
author chas williams <chas@relax.cmf.nrl.navy.mil> Mon, 26 Jun 2006 20:24:44 -0400
committer chas williams <chas@relax.cmf.nrl.navy.mil> Mon, 26 Jun 2006 20:24:44 -0400

 include/linux/atmdev.h |    4 +
 net/atm/Makefile       |    2 -
 net/atm/atm_sysfs.c    |  176 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/atm/common.c       |    7 ++
 net/atm/common.h       |    2 +
 net/atm/resources.c    |   22 +++++-
 net/atm/resources.h    |    2 +
 7 files changed, 209 insertions(+), 6 deletions(-)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 1eb238a..41788a3 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -7,6 +7,7 @@ #ifndef LINUX_ATMDEV_H
 #define LINUX_ATMDEV_H
 
 
+#include <linux/device.h>
 #include <linux/atmapi.h>
 #include <linux/atm.h>
 #include <linux/atmioc.h>
@@ -358,6 +359,7 @@ #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *proc_entry; /* proc entry */
 	char *proc_name;		/* proc entry name */
 #endif
+	struct class_device class_dev;	/* sysfs class device */
 	struct list_head dev_list;	/* linkage */
 };
 
@@ -459,7 +461,7 @@ static inline void atm_dev_put(struct at
 		BUG_ON(!test_bit(ATM_DF_REMOVED, &dev->flags));
 		if (dev->ops->dev_close)
 			dev->ops->dev_close(dev);
-		kfree(dev);
+		class_device_put(&dev->class_dev);
 	}
 }
 
diff --git a/net/atm/Makefile b/net/atm/Makefile
index d581875..89656d6 100644
--- a/net/atm/Makefile
+++ b/net/atm/Makefile
@@ -2,7 +2,7 @@ #
 # Makefile for the ATM Protocol Families.
 #
 
-atm-y		:= addr.o pvc.o signaling.o svc.o ioctl.o common.o atm_misc.o raw.o resources.o
+atm-y		:= addr.o pvc.o signaling.o svc.o ioctl.o common.o atm_misc.o raw.o resources.o atm_sysfs.o
 mpoa-objs	:= mpc.o mpoa_caches.o mpoa_proc.o
 
 obj-$(CONFIG_ATM) += atm.o
diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
new file mode 100644
index 0000000..5df4b9a
--- /dev/null
+++ b/net/atm/atm_sysfs.c
@@ -0,0 +1,176 @@
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
+static int atm_uevent(struct class_device *cdev, char **envp, int num_envp, char *buf, int size)
+{
+	struct atm_dev *adev;
+	int i = 0, len = 0;
+
+	if (!cdev)
+		return -ENODEV;
+
+	adev = to_atm_dev(cdev);
+	if (!adev)
+		return -ENODEV;
+
+	if (add_uevent_var(envp, num_envp, &i, buf, size, &len,
+			   "NAME=%s%d", adev->type, adev->number))
+		return -ENOMEM;
+
+	envp[i] = NULL;
+	return 0;
+}
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
+	.uevent		= atm_uevent,
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
diff --git a/net/atm/common.c b/net/atm/common.c
index ae00222..35ab1a6 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -791,8 +791,14 @@ static int __init atm_init(void)
 		printk(KERN_ERR "atm_proc_init() failed with %d\n",error);
 		goto out_atmsvc_exit;
 	}
+        if ((error = atm_sysfs_init()) < 0) {
+		printk(KERN_ERR "atm_sysfs_init() failed with %d\n",error);
+		goto out_atmproc_exit;
+	}
 out:
 	return error;
+out_atmproc_exit:
+	atm_proc_exit();
 out_atmsvc_exit:
 	atmsvc_exit();
 out_atmpvc_exit:
@@ -805,6 +811,7 @@ out_unregister_vcc_proto:
 static void __exit atm_exit(void)
 {
 	atm_proc_exit();
+	atm_sysfs_exit();
 	atmsvc_exit();
 	atmpvc_exit();
 	proto_unregister(&vcc_proto);
diff --git a/net/atm/common.h b/net/atm/common.h
index 4887c31..a422da7 100644
--- a/net/atm/common.h
+++ b/net/atm/common.h
@@ -28,6 +28,8 @@ int atmpvc_init(void);
 void atmpvc_exit(void);
 int atmsvc_init(void);
 void atmsvc_exit(void);
+int atm_sysfs_init(void);
+void atm_sysfs_exit(void);
 
 #ifdef CONFIG_PROC_FS
 int atm_proc_init(void);
diff --git a/net/atm/resources.c b/net/atm/resources.c
index 18ac806..534baf7 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -114,14 +114,27 @@ struct atm_dev *atm_dev_register(const c
 		printk(KERN_ERR "atm_dev_register: "
 		       "atm_proc_dev_register failed for dev %s\n",
 		       type);
-		mutex_unlock(&atm_dev_mutex);
-		kfree(dev);
-		return NULL;
+		goto out_fail;
+	}
+
+	if (atm_register_sysfs(dev) < 0) {
+		printk(KERN_ERR "atm_dev_register: "
+		       "atm_register_sysfs failed for dev %s\n",
+		       type);
+		atm_proc_dev_deregister(dev);
+		goto out_fail;
 	}
+
 	list_add_tail(&dev->dev_list, &atm_devs);
-	mutex_unlock(&atm_dev_mutex);
 
+out:
+	mutex_unlock(&atm_dev_mutex);
 	return dev;
+
+out_fail:
+	kfree(dev);
+	dev = NULL;
+	goto out;
 }
 
 
@@ -140,6 +153,7 @@ void atm_dev_deregister(struct atm_dev *
 	mutex_unlock(&atm_dev_mutex);
 
 	atm_dev_release_vccs(dev);
+	atm_unregister_sysfs(dev);
 	atm_proc_dev_deregister(dev);
 
 	atm_dev_put(dev);
diff --git a/net/atm/resources.h b/net/atm/resources.h
index ac7222f..6449899 100644
--- a/net/atm/resources.h
+++ b/net/atm/resources.h
@@ -43,4 +43,6 @@ static inline void atm_proc_dev_deregist
 
 #endif /* CONFIG_PROC_FS */
 
+int atm_register_sysfs(struct atm_dev *adev);
+void atm_unregister_sysfs(struct atm_dev *adev);
 #endif
