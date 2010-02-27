From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 5/9] Bluetooth: Convert inquiry cache to use debugfs instead of sysfs
Date: Sat, 27 Feb 2010 23:38:34 +0100
Message-ID: <ca325f698996c1a0770a67f41e7dc97a007d8bc2.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
 <8e5b2308489dbca27c104fc6a557d4c9348552e5.1267276098.git.marcel@holtmann.org>
 <8978111e2d148f75bd5e329a14600feadc567381.1267276098.git.marcel@holtmann.org>
 <10f7891f998e84acfa31ac9c5a0fea052c39ecb8.1267276098.git.marcel@holtmann.org>
 <c13854cef4751000b968d4e8ac95796562d5b96f.1267276098.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54696 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936366Ab0B0WkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:40:21 -0500
In-Reply-To: <c13854cef4751000b968d4e8ac95796562d5b96f.1267276098.git.marcel@holtmann.org>
In-Reply-To: <cover.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The output of the inquiry cache is only useful for debugging purposes
and so move it into debugfs.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/hci_core.h |    2 +
 net/bluetooth/hci_sysfs.c        |   92 +++++++++++++++++++++++++------------
 2 files changed, 64 insertions(+), 30 deletions(-)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 7e65885..4c94c1e 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -134,6 +134,8 @@ struct hci_dev {
 
 	atomic_t 		promisc;
 
+	struct dentry		*debugfs;
+
 	struct device		*parent;
 	struct device		dev;
 
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index 9b5f376..f9d93f9 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -2,6 +2,7 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include <linux/debugfs.h>
 
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
@@ -9,6 +10,9 @@
 struct class *bt_class = NULL;
 EXPORT_SYMBOL_GPL(bt_class);
 
+struct dentry *bt_debugfs = NULL;
+EXPORT_SYMBOL_GPL(bt_debugfs);
+
 static struct workqueue_struct *bt_workq;
 
 static inline char *link_typetostr(int type)
@@ -251,32 +255,6 @@ static ssize_t show_hci_revision(struct device *dev, struct device_attribute *at
 	return sprintf(buf, "%d\n", hdev->hci_rev);
 }
 
-static ssize_t show_inquiry_cache(struct device *dev, struct device_attribute *attr, char *buf)
-{
-	struct hci_dev *hdev = dev_get_drvdata(dev);
-	struct inquiry_cache *cache = &hdev->inq_cache;
-	struct inquiry_entry *e;
-	int n = 0;
-
-	hci_dev_lock_bh(hdev);
-
-	for (e = cache->list; e; e = e->next) {
-		struct inquiry_data *data = &e->data;
-		bdaddr_t bdaddr;
-		baswap(&bdaddr, &data->bdaddr);
-		n += sprintf(buf + n, "%s %d %d %d 0x%.2x%.2x%.2x 0x%.4x %d %d %u\n",
-				batostr(&bdaddr),
-				data->pscan_rep_mode, data->pscan_period_mode,
-				data->pscan_mode, data->dev_class[2],
-				data->dev_class[1], data->dev_class[0],
-				__le16_to_cpu(data->clock_offset),
-				data->rssi, data->ssp_mode, e->timestamp);
-	}
-
-	hci_dev_unlock_bh(hdev);
-	return n;
-}
-
 static ssize_t show_idle_timeout(struct device *dev, struct device_attribute *attr, char *buf)
 {
 	struct hci_dev *hdev = dev_get_drvdata(dev);
@@ -363,7 +341,6 @@ static DEVICE_ATTR(features, S_IRUGO, show_features, NULL);
 static DEVICE_ATTR(manufacturer, S_IRUGO, show_manufacturer, NULL);
 static DEVICE_ATTR(hci_version, S_IRUGO, show_hci_version, NULL);
 static DEVICE_ATTR(hci_revision, S_IRUGO, show_hci_revision, NULL);
-static DEVICE_ATTR(inquiry_cache, S_IRUGO, show_inquiry_cache, NULL);
 
 static DEVICE_ATTR(idle_timeout, S_IRUGO | S_IWUSR,
 				show_idle_timeout, store_idle_timeout);
@@ -381,7 +358,6 @@ static struct attribute *bt_host_attrs[] = {
 	&dev_attr_manufacturer.attr,
 	&dev_attr_hci_version.attr,
 	&dev_attr_hci_revision.attr,
-	&dev_attr_inquiry_cache.attr,
 	&dev_attr_idle_timeout.attr,
 	&dev_attr_sniff_max_interval.attr,
 	&dev_attr_sniff_min_interval.attr,
@@ -409,6 +385,46 @@ static struct device_type bt_host = {
 	.release = bt_host_release,
 };
 
+static int inquiry_cache_open(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static ssize_t inquiry_cache_read(struct file *file, char __user *userbuf,
+						size_t count, loff_t *ppos)
+{
+	struct hci_dev *hdev = file->private_data;
+	struct inquiry_cache *cache = &hdev->inq_cache;
+	struct inquiry_entry *e;
+	char buf[4096];
+	int n = 0;
+
+	hci_dev_lock_bh(hdev);
+
+	for (e = cache->list; e; e = e->next) {
+		struct inquiry_data *data = &e->data;
+		bdaddr_t bdaddr;
+		baswap(&bdaddr, &data->bdaddr);
+		n += sprintf(buf + n, "%s %d %d %d 0x%.2x%.2x%.2x 0x%.4x %d %d %u\n",
+				batostr(&bdaddr),
+				data->pscan_rep_mode, data->pscan_period_mode,
+				data->pscan_mode, data->dev_class[2],
+				data->dev_class[1], data->dev_class[0],
+				__le16_to_cpu(data->clock_offset),
+				data->rssi, data->ssp_mode, e->timestamp);
+	}
+
+	hci_dev_unlock_bh(hdev);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, n);
+}
+
+static const struct file_operations inquiry_cache_fops = {
+	.open = inquiry_cache_open,
+	.read = inquiry_cache_read,
+};
+
 int hci_register_sysfs(struct hci_dev *hdev)
 {
 	struct device *dev = &hdev->dev;
@@ -428,6 +444,16 @@ int hci_register_sysfs(struct hci_dev *hdev)
 	if (err < 0)
 		return err;
 
+	if (!bt_debugfs)
+		return 0;
+
+	hdev->debugfs = debugfs_create_dir(hdev->name, bt_debugfs);
+	if (!hdev->debugfs)
+		return 0;
+
+	debugfs_create_file("inquiry_cache", 0444, hdev->debugfs,
+						hdev, &inquiry_cache_fops);
+
 	return 0;
 }
 
@@ -435,6 +461,8 @@ void hci_unregister_sysfs(struct hci_dev *hdev)
 {
 	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
 
+	debugfs_remove_recursive(hdev->debugfs);
+
 	device_del(&hdev->dev);
 }
 
@@ -444,6 +472,8 @@ int __init bt_sysfs_init(void)
 	if (!bt_workq)
 		return -ENOMEM;
 
+	bt_debugfs = debugfs_create_dir("bluetooth", NULL);
+
 	bt_class = class_create(THIS_MODULE, "bluetooth");
 	if (IS_ERR(bt_class)) {
 		destroy_workqueue(bt_workq);
@@ -455,7 +485,9 @@ int __init bt_sysfs_init(void)
 
 void bt_sysfs_cleanup(void)
 {
-	destroy_workqueue(bt_workq);
-
 	class_destroy(bt_class);
+
+	debugfs_remove_recursive(bt_debugfs);
+
+	destroy_workqueue(bt_workq);
 }
-- 
1.6.6

