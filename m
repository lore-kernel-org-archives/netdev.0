From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 2/7] uio: Allow to create custom UIO attributes
Date: Tue, 13 Aug 2013 11:08:37 +0200
Message-ID: <1376384922-8519-4-git-send-email-b.spranger@linutronix.de>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Holger Dengler <dengler@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48274 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753818Ab3HMJIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 05:08:52 -0400
In-Reply-To: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch the struct uio_attribute which represents a custom UIO
attribute. The non-standard attributes are stored in a "attr" directory.
This will be used by the flexcard driver which creates a UIO device that
is using the "uio_pdrv" and requires one additional value to be read /
written by the user.

Cc: "Hans J. Koch" <hjk@hansjkoch.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
Signed-off-by: Holger Dengler <dengler@linutronix.de>
---
 drivers/uio/uio.c          | 106 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/uio_driver.h |  36 +++++++++++----
 2 files changed, 133 insertions(+), 9 deletions(-)

diff --git a/drivers/uio/uio.c b/drivers/uio/uio.c
index 9a95220..d66784a 100644
--- a/drivers/uio/uio.c
+++ b/drivers/uio/uio.c
@@ -39,6 +39,7 @@ struct uio_device {
 	struct uio_info		*info;
 	struct kobject		*map_dir;
 	struct kobject		*portio_dir;
+	struct kobject		attr_dir;
 };
 
 static int uio_major;
@@ -252,6 +253,49 @@ static struct device_attribute uio_class_attributes[] = {
 	{}
 };
 
+static ssize_t uio_type_show(struct kobject *kobj, struct attribute *attr,
+			     char *buf)
+{
+	struct uio_device *idev;
+	struct uio_info *info;
+	struct uio_attribute *entry;
+
+	idev = container_of(kobj, struct uio_device, attr_dir);
+	info = idev->info;
+	entry = container_of(attr, struct uio_attribute, attr);
+
+	if (!entry->show)
+		return -EIO;
+
+	return entry->show(info, buf);
+}
+
+static ssize_t uio_type_store(struct kobject *kobj, struct attribute *attr,
+			      const char *buf, size_t count)
+{
+	struct uio_device *idev;
+	struct uio_info *info;
+	struct uio_attribute *entry;
+
+	idev = container_of(kobj, struct uio_device, attr_dir);
+	info = idev->info;
+	entry = container_of(attr, struct uio_attribute, attr);
+
+	if (!entry->store)
+		return -EIO;
+
+	return entry->store(info, buf, count);
+}
+
+static const struct sysfs_ops uio_sysfs_ops = {
+	.show = uio_type_show,
+	.store = uio_type_store,
+};
+
+static struct kobj_type uio_attr_type = {
+	.sysfs_ops	= &uio_sysfs_ops,
+};
+
 /* UIO class infrastructure */
 static struct class uio_class = {
 	.name = "uio",
@@ -323,8 +367,16 @@ static int uio_dev_add_attributes(struct uio_device *idev)
 			goto err_portio;
 	}
 
+	ret = kobject_init_and_add(&idev->attr_dir, &uio_attr_type,
+				   &idev->dev->kobj, "attr");
+	if (ret)
+		goto err_attr;
+
 	return 0;
 
+err_attr:
+	kobject_put(&idev->attr_dir);
+
 err_portio:
 	for (pi--; pi >= 0; pi--) {
 		port = &idev->info->port[pi];
@@ -364,6 +416,7 @@ static void uio_dev_del_attributes(struct uio_device *idev)
 		kobject_put(&port->portio->kobj);
 	}
 	kobject_put(idev->portio_dir);
+	kobject_put(&idev->attr_dir);
 }
 
 static int uio_get_minor(struct uio_device *idev)
@@ -391,6 +444,50 @@ static void uio_free_minor(struct uio_device *idev)
 }
 
 /**
+ * uio_add_user_attributes - add an extra UIO attribute
+ * @info: UIO device capabilities
+ */
+static int uio_add_user_attributes(struct uio_info *info)
+{
+	struct uio_device *idev = info->uio_dev;
+	const struct uio_attribute **uio_attr;
+	int i;
+	int ret = 0;
+
+	uio_attr = info->attributes;
+	if (!uio_attr)
+		return 0;
+
+	for (i = 0; uio_attr[i]; i++) {
+
+		ret = sysfs_create_file(&idev->attr_dir, &uio_attr[i]->attr);
+		if (ret)
+			break;
+	}
+	if (ret) {
+		while (--i >= 0)
+			sysfs_remove_file(&idev->attr_dir, &uio_attr[i]->attr);
+	}
+	return ret;
+}
+
+/**
+ * uio_del_user_attributes - delete an extra UIO attribute
+ * @info: UIO device capabilities
+ */
+static void uio_del_user_attributes(struct uio_info *info)
+{
+	struct uio_device *idev = info->uio_dev;
+	const struct uio_attribute **uio_attr;
+	int i;
+
+	uio_attr = info->attributes;
+
+	for (i = 0; uio_attr[i]; i++)
+		sysfs_remove_file(&idev->attr_dir, &uio_attr[i]->attr);
+}
+
+/**
  * uio_event_notify - trigger an interrupt event
  * @info: UIO device capabilities
  */
@@ -846,8 +943,14 @@ int __uio_register_device(struct module *owner,
 			goto err_request_irq;
 	}
 
-	return 0;
+	ret = uio_add_user_attributes(info);
+	if (ret)
+		goto err_free_irq;
 
+	return 0;
+err_free_irq:
+	if (info->irq && (info->irq != UIO_IRQ_CUSTOM))
+		free_irq(info->irq, idev);
 err_request_irq:
 	uio_dev_del_attributes(idev);
 err_uio_dev_add_attributes:
@@ -881,6 +984,7 @@ void uio_unregister_device(struct uio_info *info)
 		free_irq(info->irq, idev);
 
 	uio_dev_del_attributes(idev);
+	uio_del_user_attributes(idev->info);
 
 	device_destroy(&uio_class, MKDEV(uio_major, idev->minor));
 	kfree(idev);
diff --git a/include/linux/uio_driver.h b/include/linux/uio_driver.h
index 99f1696..2e7543e 100644
--- a/include/linux/uio_driver.h
+++ b/include/linux/uio_driver.h
@@ -64,6 +64,7 @@ struct uio_port {
 #define MAX_UIO_PORT_REGIONS	5
 
 struct uio_device;
+struct uio_attribute;
 
 /**
  * struct uio_info - UIO device capabilities
@@ -72,6 +73,7 @@ struct uio_device;
  * @version:		device driver version
  * @mem:		list of mappable memory regions, size==0 for end of list
  * @port:		list of port regions, size==0 for end of list
+ * @attributes:		list of additional attributes, NULL for end of list
  * @irq:		interrupt number or UIO_IRQ_CUSTOM
  * @irq_flags:		flags for request_irq()
  * @priv:		optional private data
@@ -83,14 +85,15 @@ struct uio_device;
  * @owner:		module which created the uio device incase
  */
 struct uio_info {
-	struct uio_device	*uio_dev;
-	const char		*name;
-	const char		*version;
-	struct uio_mem		mem[MAX_UIO_MAPS];
-	struct uio_port		port[MAX_UIO_PORT_REGIONS];
-	long			irq;
-	unsigned long		irq_flags;
-	void			*priv;
+	struct uio_device		*uio_dev;
+	const char			*name;
+	const char			*version;
+	struct uio_mem			mem[MAX_UIO_MAPS];
+	struct uio_port			port[MAX_UIO_PORT_REGIONS];
+	const struct uio_attribute	**attributes;
+	long				irq;
+	unsigned long			irq_flags;
+	void				*priv;
 	irqreturn_t (*handler)(int irq, struct uio_info *dev_info);
 	int (*mmap)(struct uio_info *info, struct vm_area_struct *vma);
 	int (*open)(struct uio_info *info, struct inode *inode);
@@ -99,6 +102,23 @@ struct uio_info {
 	struct module			*owner;
 };
 
+/**
+ * struct uio_attribute - UIO attribute
+ * @attr:		the attribute
+ * @show:		attribute show function
+ * @store:		attribute store function
+ */
+struct uio_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct uio_info *info, char *buf);
+	ssize_t (*store)(struct uio_info *info, const char *buf, size_t count);
+};
+
+#define UIO_ATTR(_name, _mode, _show, _store)   \
+	struct uio_attribute uio_attr_##_name = \
+		__ATTR(_name, _mode, _show, _store)
+
+
 extern int __must_check
 	__uio_register_device(struct module *owner,
 			      struct device *parent,
-- 
1.8.4.rc2
