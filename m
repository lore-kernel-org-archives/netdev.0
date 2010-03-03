From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH] Bluetooth: Use single_open() for inquiry cache within debugfs
Date: Tue,  2 Mar 2010 17:48:23 -0800
Message-ID: <1267580903-30946-1-git-send-email-marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:42939 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701Ab0CCBuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 20:50:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The inquiry cache information in debugfs should be using seq_file support
and not allocating memory on the stack for the string. Since the usage of
these information is really seldom, using single_open() for it is good
enough.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/hci_sysfs.c |   41 ++++++++++++++++++++---------------------
 1 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index 1a79a6c..cafb55b 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -3,6 +3,7 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/debugfs.h>
+#include <linux/seq_file.h>
 
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
@@ -405,20 +406,11 @@ static struct device_type bt_host = {
 	.release = bt_host_release,
 };
 
-static int inquiry_cache_open(struct inode *inode, struct file *file)
-{
-	file->private_data = inode->i_private;
-	return 0;
-}
-
-static ssize_t inquiry_cache_read(struct file *file, char __user *userbuf,
-						size_t count, loff_t *ppos)
+static int inquiry_cache_show(struct seq_file *f, void *p)
 {
-	struct hci_dev *hdev = file->private_data;
+	struct hci_dev *hdev = f->private;
 	struct inquiry_cache *cache = &hdev->inq_cache;
 	struct inquiry_entry *e;
-	char buf[4096];
-	int n = 0;
 
 	hci_dev_lock_bh(hdev);
 
@@ -426,23 +418,30 @@ static ssize_t inquiry_cache_read(struct file *file, char __user *userbuf,
 		struct inquiry_data *data = &e->data;
 		bdaddr_t bdaddr;
 		baswap(&bdaddr, &data->bdaddr);
-		n += sprintf(buf + n, "%s %d %d %d 0x%.2x%.2x%.2x 0x%.4x %d %d %u\n",
-				batostr(&bdaddr),
-				data->pscan_rep_mode, data->pscan_period_mode,
-				data->pscan_mode, data->dev_class[2],
-				data->dev_class[1], data->dev_class[0],
-				__le16_to_cpu(data->clock_offset),
-				data->rssi, data->ssp_mode, e->timestamp);
+		seq_printf(f, "%s %d %d %d 0x%.2x%.2x%.2x 0x%.4x %d %d %u\n",
+			   batostr(&bdaddr),
+			   data->pscan_rep_mode, data->pscan_period_mode,
+			   data->pscan_mode, data->dev_class[2],
+			   data->dev_class[1], data->dev_class[0],
+			   __le16_to_cpu(data->clock_offset),
+			   data->rssi, data->ssp_mode, e->timestamp);
 	}
 
 	hci_dev_unlock_bh(hdev);
 
-	return simple_read_from_buffer(userbuf, count, ppos, buf, n);
+	return 0;
+}
+
+static int inquiry_cache_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, inquiry_cache_show, inode->i_private);
 }
 
 static const struct file_operations inquiry_cache_fops = {
-	.open = inquiry_cache_open,
-	.read = inquiry_cache_read,
+	.open		= inquiry_cache_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
 };
 
 int hci_register_sysfs(struct hci_dev *hdev)
-- 
1.6.6.1

