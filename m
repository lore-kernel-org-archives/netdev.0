From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 6/9] Bluetooth: Convert Marvell driver to use per adapter debugfs
Date: Sat, 27 Feb 2010 23:38:35 +0100
Message-ID: <b914a250e7b390c713b36a9405a39c4c11abad80.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
 <8e5b2308489dbca27c104fc6a557d4c9348552e5.1267276098.git.marcel@holtmann.org>
 <8978111e2d148f75bd5e329a14600feadc567381.1267276098.git.marcel@holtmann.org>
 <10f7891f998e84acfa31ac9c5a0fea052c39ecb8.1267276098.git.marcel@holtmann.org>
 <c13854cef4751000b968d4e8ac95796562d5b96f.1267276098.git.marcel@holtmann.org>
 <ca325f698996c1a0770a67f41e7dc97a007d8bc2.1267276098.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54698 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936367Ab0B0WkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:40:22 -0500
In-Reply-To: <ca325f698996c1a0770a67f41e7dc97a007d8bc2.1267276098.git.marcel@holtmann.org>
In-Reply-To: <cover.1267276098.git.marcel@holtmann.org>
References: <cover.1267276098.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The debugfs support of the Marvell driver is buggy. It is limited to one
controller per system. Fix this by using the controller specific debugfs
directory as parent.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_debugfs.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_debugfs.c b/drivers/bluetooth/btmrvl_debugfs.c
index d43b5cb..3126a3d 100644
--- a/drivers/bluetooth/btmrvl_debugfs.c
+++ b/drivers/bluetooth/btmrvl_debugfs.c
@@ -26,7 +26,8 @@
 #include "btmrvl_drv.h"
 
 struct btmrvl_debugfs_data {
-	struct dentry *root_dir, *config_dir, *status_dir;
+	struct dentry *config_dir;
+	struct dentry *status_dir;
 
 	/* config */
 	struct dentry *psmode;
@@ -363,6 +364,9 @@ void btmrvl_debugfs_init(struct hci_dev *hdev)
 	struct btmrvl_private *priv = hdev->driver_data;
 	struct btmrvl_debugfs_data *dbg;
 
+	if (!hdev->debugfs)
+		return;
+
 	dbg = kzalloc(sizeof(*dbg), GFP_KERNEL);
 	priv->debugfs_data = dbg;
 
@@ -371,9 +375,7 @@ void btmrvl_debugfs_init(struct hci_dev *hdev)
 		return;
 	}
 
-	dbg->root_dir = debugfs_create_dir("btmrvl", NULL);
-
-	dbg->config_dir = debugfs_create_dir("config", dbg->root_dir);
+	dbg->config_dir = debugfs_create_dir("config", hdev->debugfs);
 
 	dbg->psmode = debugfs_create_file("psmode", 0644, dbg->config_dir,
 				hdev->driver_data, &btmrvl_psmode_fops);
@@ -388,7 +390,7 @@ void btmrvl_debugfs_init(struct hci_dev *hdev)
 	dbg->hscfgcmd = debugfs_create_file("hscfgcmd", 0644, dbg->config_dir,
 				hdev->driver_data, &btmrvl_hscfgcmd_fops);
 
-	dbg->status_dir = debugfs_create_dir("status", dbg->root_dir);
+	dbg->status_dir = debugfs_create_dir("status", hdev->debugfs);
 	dbg->curpsmode = debugfs_create_file("curpsmode", 0444,
 						dbg->status_dir,
 						hdev->driver_data,
@@ -425,7 +427,5 @@ void btmrvl_debugfs_remove(struct hci_dev *hdev)
 	debugfs_remove(dbg->txdnldready);
 	debugfs_remove(dbg->status_dir);
 
-	debugfs_remove(dbg->root_dir);
-
 	kfree(dbg);
 }
-- 
1.6.6

