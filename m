From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 09/47] Bluetooth: Add debugfs support to btmrvl driver
Date: Sun, 30 Aug 2009 01:50:23 -0700
Message-ID: <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53273 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787AbZH3IwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:01 -0400
In-Reply-To: <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bing Zhao <bzhao@marvell.com>

/debug/btmrvl/config/
/debug/btmrvl/status/

See Documentation/btmrvl.txt for details.

This patch incorporates a lot of comments given by
Nicolas Pitre <nico@marvell.com>. Many thanks to Nicolas Pitre.

Signed-off-by: Rahul Tank <rahult@marvell.com>
Signed-off-by: Bing Zhao <bzhao@marvell.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/Kconfig          |    1 +
 drivers/bluetooth/Makefile         |    2 +-
 drivers/bluetooth/btmrvl_debugfs.c |  469 ++++++++++++++++++++++++++++++++++++
 drivers/bluetooth/btmrvl_drv.h     |    8 +
 drivers/bluetooth/btmrvl_main.c    |    8 +
 5 files changed, 487 insertions(+), 1 deletions(-)
 create mode 100644 drivers/bluetooth/btmrvl_debugfs.c

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index 8c89bd4..5f04014 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -173,6 +173,7 @@ config BT_HCIVHCI
 config BT_MRVL
 	tristate "Marvell Bluetooth driver support"
 	select FW_LOADER
+	select DEBUG_FS
 	help
 	  The core driver to support Marvell Bluetooth devices.
 
diff --git a/drivers/bluetooth/Makefile b/drivers/bluetooth/Makefile
index 2dc12e7..75f70e0 100644
--- a/drivers/bluetooth/Makefile
+++ b/drivers/bluetooth/Makefile
@@ -15,7 +15,7 @@ obj-$(CONFIG_BT_HCIBTUART)	+= btuart_cs.o
 obj-$(CONFIG_BT_HCIBTUSB)	+= btusb.o
 obj-$(CONFIG_BT_HCIBTSDIO)	+= btsdio.o
 
-btmrvl-objs			:= btmrvl_main.o
+btmrvl-objs			:= btmrvl_main.o btmrvl_debugfs.o
 obj-$(CONFIG_BT_MRVL)		+= btmrvl.o
 obj-$(CONFIG_BT_MRVL_SDIO)	+= btmrvl_sdio.o
 
diff --git a/drivers/bluetooth/btmrvl_debugfs.c b/drivers/bluetooth/btmrvl_debugfs.c
new file mode 100644
index 0000000..747bb0c
--- /dev/null
+++ b/drivers/bluetooth/btmrvl_debugfs.c
@@ -0,0 +1,469 @@
+/**
+ * Marvell Bluetooth driver: debugfs related functions
+ *
+ * Copyright (C) 2009, Marvell International Ltd.
+ *
+ * This software file (the "File") is distributed by Marvell International
+ * Ltd. under the terms of the GNU General Public License Version 2, June 1991
+ * (the "License").  You may use, redistribute and/or modify this File in
+ * accordance with the terms and conditions of the License, a copy of which
+ * is available by writing to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or on the
+ * worldwide web at http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
+ *
+ *
+ * THE FILE IS DISTRIBUTED AS-IS, WITHOUT WARRANTY OF ANY KIND, AND THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE
+ * ARE EXPRESSLY DISCLAIMED.  The License provides additional details about
+ * this warranty disclaimer.
+ **/
+
+#include <linux/debugfs.h>
+
+#include <net/bluetooth/bluetooth.h>
+#include <net/bluetooth/hci_core.h>
+
+#include "btmrvl_drv.h"
+
+struct btmrvl_debugfs_data {
+	struct dentry *root_dir, *config_dir, *status_dir;
+
+	/* config */
+	struct dentry *drvdbg;
+	struct dentry *psmode;
+	struct dentry *pscmd;
+	struct dentry *hsmode;
+	struct dentry *hscmd;
+	struct dentry *gpiogap;
+	struct dentry *hscfgcmd;
+
+	/* status */
+	struct dentry *curpsmode;
+	struct dentry *hsstate;
+	struct dentry *psstate;
+	struct dentry *txdnldready;
+};
+
+static int btmrvl_open_generic(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static ssize_t btmrvl_hscfgcmd_write(struct file *file,
+					const char __user *ubuf,
+					size_t count,
+					loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+
+	long result, ret;
+	char buf[16];
+
+	memset(buf, 0, sizeof(buf));
+
+	if (copy_from_user(&buf, ubuf,
+				min_t(size_t, sizeof(buf) - 1, count)))
+		return -EFAULT;
+
+	ret = strict_strtol(buf, 10, &result);
+
+	priv->btmrvl_dev.hscfgcmd = result;
+
+	if (priv->btmrvl_dev.hscfgcmd) {
+		btmrvl_prepare_command(priv);
+		wake_up_interruptible(&priv->main_thread.wait_q);
+	}
+
+	return count;
+}
+
+static ssize_t btmrvl_hscfgcmd_read(struct file *file, char __user * userbuf,
+				    size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	int ret;
+	char buf[16];
+
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
+			priv->btmrvl_dev.hscfgcmd);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+}
+
+static const struct file_operations btmrvl_hscfgcmd_fops = {
+	.read = btmrvl_hscfgcmd_read,
+	.write = btmrvl_hscfgcmd_write,
+	.open = btmrvl_open_generic,
+};
+
+static ssize_t btmrvl_psmode_write(struct file *file, const char __user *ubuf,
+				   size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	long result, ret;
+	char buf[16];
+
+	memset(buf, 0, sizeof(buf));
+
+	if (copy_from_user(&buf, ubuf,
+				min_t(size_t, sizeof(buf) - 1, count)))
+		return -EFAULT;
+
+	ret = strict_strtol(buf, 10, &result);
+
+	priv->btmrvl_dev.psmode = result;
+
+	return count;
+}
+
+static ssize_t btmrvl_psmode_read(struct file *file, char __user * userbuf,
+				  size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	int ret;
+	char buf[16];
+
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
+			priv->btmrvl_dev.psmode);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+}
+
+static const struct file_operations btmrvl_psmode_fops = {
+	.read = btmrvl_psmode_read,
+	.write = btmrvl_psmode_write,
+	.open = btmrvl_open_generic,
+};
+
+static ssize_t btmrvl_pscmd_write(struct file *file, const char __user *ubuf,
+				  size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	long result, ret;
+	char buf[16];
+
+	memset(buf, 0, sizeof(buf));
+
+	if (copy_from_user(&buf, ubuf,
+				min_t(size_t, sizeof(buf) - 1, count)))
+		return -EFAULT;
+
+	ret = strict_strtol(buf, 10, &result);
+
+	priv->btmrvl_dev.pscmd = result;
+
+	if (priv->btmrvl_dev.pscmd) {
+		btmrvl_prepare_command(priv);
+		wake_up_interruptible(&priv->main_thread.wait_q);
+	}
+
+	return count;
+
+}
+
+static ssize_t btmrvl_pscmd_read(struct file *file, char __user * userbuf,
+				 size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	int ret;
+	char buf[16];
+
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n", priv->btmrvl_dev.pscmd);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+}
+
+static const struct file_operations btmrvl_pscmd_fops = {
+	.read = btmrvl_pscmd_read,
+	.write = btmrvl_pscmd_write,
+	.open = btmrvl_open_generic,
+};
+
+static ssize_t btmrvl_gpiogap_write(struct file *file, const char __user *ubuf,
+				    size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	long result, ret;
+	char buf[16];
+
+	memset(buf, 0, sizeof(buf));
+
+	if (copy_from_user(&buf, ubuf,
+				min_t(size_t, sizeof(buf) - 1, count)))
+		return -EFAULT;
+
+	ret = strict_strtol(buf, 16, &result);
+
+	priv->btmrvl_dev.gpio_gap = result;
+
+	return count;
+}
+
+static ssize_t btmrvl_gpiogap_read(struct file *file, char __user * userbuf,
+				   size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	int ret;
+	char buf[16];
+
+	ret = snprintf(buf, sizeof(buf) - 1, "0x%x\n",
+			priv->btmrvl_dev.gpio_gap);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+}
+
+static const struct file_operations btmrvl_gpiogap_fops = {
+	.read = btmrvl_gpiogap_read,
+	.write = btmrvl_gpiogap_write,
+	.open = btmrvl_open_generic,
+};
+
+static ssize_t btmrvl_hscmd_write(struct file *file, const char __user *ubuf,
+				  size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	long result, ret;
+	char buf[16];
+
+	memset(buf, 0, sizeof(buf));
+
+	if (copy_from_user(&buf, ubuf,
+				min_t(size_t, sizeof(buf) - 1, count)))
+		return -EFAULT;
+
+	ret = strict_strtol(buf, 10, &result);
+
+	priv->btmrvl_dev.hscmd = result;
+	if (priv->btmrvl_dev.hscmd) {
+		btmrvl_prepare_command(priv);
+		wake_up_interruptible(&priv->main_thread.wait_q);
+	}
+
+	return count;
+}
+
+static ssize_t btmrvl_hscmd_read(struct file *file, char __user * userbuf,
+				 size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	int ret;
+	char buf[16];
+
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n", priv->btmrvl_dev.hscmd);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+}
+
+static const struct file_operations btmrvl_hscmd_fops = {
+	.read = btmrvl_hscmd_read,
+	.write = btmrvl_hscmd_write,
+	.open = btmrvl_open_generic,
+};
+
+static ssize_t btmrvl_hsmode_write(struct file *file, const char __user *ubuf,
+				   size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	long result, ret;
+	char buf[16];
+
+	memset(buf, 0, sizeof(buf));
+
+	if (copy_from_user(&buf, ubuf,
+				min_t(size_t, sizeof(buf) - 1, count)))
+		return -EFAULT;
+
+	ret = strict_strtol(buf, 10, &result);
+
+	priv->btmrvl_dev.hsmode = result;
+
+	return count;
+}
+
+static ssize_t btmrvl_hsmode_read(struct file *file, char __user * userbuf,
+				  size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	int ret;
+	char buf[16];
+
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
+			priv->btmrvl_dev.hsmode);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+}
+
+static const struct file_operations btmrvl_hsmode_fops = {
+	.read = btmrvl_hsmode_read,
+	.write = btmrvl_hsmode_write,
+	.open = btmrvl_open_generic,
+};
+
+static ssize_t btmrvl_curpsmode_read(struct file *file, char __user * userbuf,
+				     size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	int ret;
+	char buf[16];
+
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n", priv->adapter->psmode);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+}
+
+static const struct file_operations btmrvl_curpsmode_fops = {
+	.read = btmrvl_curpsmode_read,
+	.open = btmrvl_open_generic,
+};
+
+static ssize_t btmrvl_psstate_read(struct file *file, char __user * userbuf,
+				   size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	int ret;
+	char buf[16];
+
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
+			priv->adapter->ps_state);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+}
+
+static const struct file_operations btmrvl_psstate_fops = {
+	.read = btmrvl_psstate_read,
+	.open = btmrvl_open_generic,
+};
+
+static ssize_t btmrvl_hsstate_read(struct file *file, char __user * userbuf,
+				   size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	int ret;
+	char buf[16];
+
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
+			priv->adapter->hs_state);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+}
+
+static const struct file_operations btmrvl_hsstate_fops = {
+	.read = btmrvl_hsstate_read,
+	.open = btmrvl_open_generic,
+};
+
+static ssize_t btmrvl_txdnldready_read(struct file *file, char __user * userbuf,
+				       size_t count, loff_t *ppos)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) file->private_data;
+	int ret;
+	char buf[16];
+
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
+			priv->btmrvl_dev.tx_dnld_rdy);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+}
+
+static const struct file_operations btmrvl_txdnldready_fops = {
+	.read = btmrvl_txdnldready_read,
+	.open = btmrvl_open_generic,
+};
+
+void btmrvl_debugfs_init(struct hci_dev *hdev)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) hdev->driver_data;
+	struct btmrvl_debugfs_data *dbg;
+
+	dbg = kzalloc(sizeof(*dbg), GFP_KERNEL);
+	priv->debugfs_data = dbg;
+
+	if (!dbg) {
+		BT_ERR("Can not allocate memory for btmrvl_debugfs_data.");
+		return;
+	}
+
+	dbg->root_dir = debugfs_create_dir("btmrvl", NULL);
+
+	dbg->config_dir = debugfs_create_dir("config", dbg->root_dir);
+
+	dbg->psmode = debugfs_create_file("psmode", 0644, dbg->config_dir,
+					  hdev->driver_data,
+					  &btmrvl_psmode_fops);
+	dbg->pscmd =
+	    debugfs_create_file("pscmd", 0644, dbg->config_dir,
+				hdev->driver_data, &btmrvl_pscmd_fops);
+	dbg->gpiogap =
+	    debugfs_create_file("gpiogap", 0644, dbg->config_dir,
+				hdev->driver_data, &btmrvl_gpiogap_fops);
+	dbg->hsmode =
+	    debugfs_create_file("hsmode", 0644, dbg->config_dir,
+				hdev->driver_data, &btmrvl_hsmode_fops);
+	dbg->hscmd =
+	    debugfs_create_file("hscmd", 0644, dbg->config_dir,
+				hdev->driver_data, &btmrvl_hscmd_fops);
+	dbg->hscfgcmd =
+	    debugfs_create_file("hscfgcmd", 0644, dbg->config_dir,
+				hdev->driver_data, &btmrvl_hscfgcmd_fops);
+
+	dbg->status_dir = debugfs_create_dir("status", dbg->root_dir);
+	dbg->curpsmode = debugfs_create_file("curpsmode", 0444,
+						dbg->status_dir,
+						hdev->driver_data,
+						&btmrvl_curpsmode_fops);
+	dbg->psstate =
+	    debugfs_create_file("psstate", 0444, dbg->status_dir,
+				hdev->driver_data, &btmrvl_psstate_fops);
+	dbg->hsstate =
+	    debugfs_create_file("hsstate", 0444, dbg->status_dir,
+				hdev->driver_data, &btmrvl_hsstate_fops);
+	dbg->txdnldready =
+	    debugfs_create_file("txdnldready", 0444, dbg->status_dir,
+				hdev->driver_data, &btmrvl_txdnldready_fops);
+}
+
+void btmrvl_debugfs_remove(struct hci_dev *hdev)
+{
+	struct btmrvl_private *priv =
+				(struct btmrvl_private *) hdev->driver_data;
+	struct btmrvl_debugfs_data *dbg = priv->debugfs_data;
+
+	if (!dbg)
+		return;
+
+	debugfs_remove(dbg->psmode);
+	debugfs_remove(dbg->pscmd);
+	debugfs_remove(dbg->gpiogap);
+	debugfs_remove(dbg->hsmode);
+	debugfs_remove(dbg->hscmd);
+	debugfs_remove(dbg->hscfgcmd);
+	debugfs_remove(dbg->config_dir);
+
+	debugfs_remove(dbg->curpsmode);
+	debugfs_remove(dbg->psstate);
+	debugfs_remove(dbg->hsstate);
+	debugfs_remove(dbg->txdnldready);
+	debugfs_remove(dbg->status_dir);
+
+	debugfs_remove(dbg->root_dir);
+
+	kfree(dbg);
+}
diff --git a/drivers/bluetooth/btmrvl_drv.h b/drivers/bluetooth/btmrvl_drv.h
index 9ad71f4..7a12f68 100644
--- a/drivers/bluetooth/btmrvl_drv.h
+++ b/drivers/bluetooth/btmrvl_drv.h
@@ -79,6 +79,9 @@ struct btmrvl_private {
 				u8 *payload, u16 nb);
 	int (*hw_wakeup_firmware) (struct btmrvl_private *priv);
 	spinlock_t driver_lock;		/* spinlock used by driver */
+#ifdef CONFIG_DEBUG_FS
+	void *debugfs_data;
+#endif
 };
 
 #define MRVL_VENDOR_PKT			0xFE
@@ -135,4 +138,9 @@ int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb);
 int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd);
 int btmrvl_prepare_command(struct btmrvl_private *priv);
 
+#ifdef CONFIG_DEBUG_FS
+void btmrvl_debugfs_init(struct hci_dev *hdev);
+void btmrvl_debugfs_remove(struct hci_dev *hdev);
+#endif
+
 #endif /* _BTMRVL_DRV_H_ */
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index 11c2f2c..b4f4445 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -658,6 +658,10 @@ struct btmrvl_private *btmrvl_add_card(void *card)
 		goto err_hci_register_dev;
 	}
 
+#ifdef CONFIG_DEBUG_FS
+	btmrvl_debugfs_init(hdev);
+#endif
+
 	BT_DBG("Leave");
 	return priv;
 
@@ -692,6 +696,10 @@ int btmrvl_remove_card(struct btmrvl_private *priv)
 
 	kthread_stop(priv->main_thread.task);
 
+#ifdef CONFIG_DEBUG_FS
+	btmrvl_debugfs_remove(hdev);
+#endif
+
 	hci_unregister_dev(hdev);
 
 	hci_free_dev(hdev);
-- 
1.6.2.5

