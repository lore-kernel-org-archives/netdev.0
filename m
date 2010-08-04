From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: Load firmware in open() instead of
 probe()
Date: Wed, 4 Aug 2010 10:49:40 +0300
Message-ID: <1280908180.4712.3.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4088 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755725Ab0HDHt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 03:49:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Loading firmware when actually bringing eth device up.
This also will allow driver to be insmoded when filesystem with
firmware files is not available yet.

Suggested by Stephen Hemminger <shemminger@vyatta.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c  |   20 ++++++++++++++++++++
 drivers/net/bnx2x/bnx2x_cmn.h  |    9 +++++++++
 drivers/net/bnx2x/bnx2x_main.c |   26 +++++++-------------------
 3 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 02bf710..da96d1a 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -20,6 +20,7 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <net/ip6_checksum.h>
+#include <linux/firmware.h>
 #include "bnx2x_cmn.h"
 
 #ifdef BCM_VLAN
@@ -1206,12 +1207,27 @@ static int bnx2x_set_num_queues(struct bnx2x *bp)
 	return rc;
 }
 
+static void bnx2x_release_firmware(struct bnx2x *bp)
+{
+	kfree(bp->init_ops_offsets);
+	kfree(bp->init_ops);
+	kfree(bp->init_data);
+	release_firmware(bp->firmware);
+}
+
 /* must be called with rtnl_lock */
 int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 {
 	u32 load_code;
 	int i, rc;
 
+	/* Set init arrays */
+	rc = bnx2x_init_firmware(bp);
+	if (rc) {
+		BNX2X_ERR("Error loading firmware\n");
+		return rc;
+	}
+
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return -EPERM;
@@ -1427,6 +1443,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 #endif
 	bnx2x_inc_load_cnt(bp);
 
+	bnx2x_release_firmware(bp);
+
 	return 0;
 
 #ifdef BCM_CNIC
@@ -1454,6 +1472,8 @@ load_error1:
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 	bnx2x_free_mem(bp);
 
+	bnx2x_release_firmware(bp);
+
 	return rc;
 }
 
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index d1979b1..32543c3 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -115,6 +115,15 @@ void bnx2x_int_enable(struct bnx2x *bp);
 void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw);
 
 /**
+ * Loads device firmware
+ *
+ * @param bp
+ *
+ * @return int
+ */
+int bnx2x_init_firmware(struct bnx2x *bp);
+
+/**
  * Init HW blocks according to current initialization stage:
  * COMMON, PORT or FUNCTION.
  *
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index b4ec2b0..13309f1 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -7254,7 +7254,7 @@ static void __devinit bnx2x_get_pcie_width_speed(struct bnx2x *bp,
 	*speed = (val & PCICFG_LINK_SPEED) >> PCICFG_LINK_SPEED_SHIFT;
 }
 
-static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
+static int bnx2x_check_firmware(struct bnx2x *bp)
 {
 	const struct firmware *firmware = bp->firmware;
 	struct bnx2x_fw_file_hdr *fw_hdr;
@@ -7365,7 +7365,7 @@ do {									\
 	     (u8 *)bp->arr, len);					\
 } while (0)
 
-static int __devinit bnx2x_init_firmware(struct bnx2x *bp, struct device *dev)
+int bnx2x_init_firmware(struct bnx2x *bp)
 {
 	const char *fw_file_name;
 	struct bnx2x_fw_file_hdr *fw_hdr;
@@ -7376,21 +7376,21 @@ static int __devinit bnx2x_init_firmware(struct bnx2x *bp, struct device *dev)
 	else if (CHIP_IS_E1H(bp))
 		fw_file_name = FW_FILE_NAME_E1H;
 	else {
-		dev_err(dev, "Unsupported chip revision\n");
+		BNX2X_ERR("Unsupported chip revision\n");
 		return -EINVAL;
 	}
 
-	dev_info(dev, "Loading %s\n", fw_file_name);
+	BNX2X_DEV_INFO("Loading %s\n", fw_file_name);
 
-	rc = request_firmware(&bp->firmware, fw_file_name, dev);
+	rc = request_firmware(&bp->firmware, fw_file_name, &bp->pdev->dev);
 	if (rc) {
-		dev_err(dev, "Can't load firmware file %s\n", fw_file_name);
+		BNX2X_ERR("Can't load firmware file %s\n", fw_file_name);
 		goto request_firmware_exit;
 	}
 
 	rc = bnx2x_check_firmware(bp);
 	if (rc) {
-		dev_err(dev, "Corrupt firmware file %s\n", fw_file_name);
+		BNX2X_ERR("Corrupt firmware file %s\n", fw_file_name);
 		goto request_firmware_exit;
 	}
 
@@ -7468,13 +7468,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	if (rc)
 		goto init_one_exit;
 
-	/* Set init arrays */
-	rc = bnx2x_init_firmware(bp, &pdev->dev);
-	if (rc) {
-		dev_err(&pdev->dev, "Error loading firmware\n");
-		goto init_one_exit;
-	}
-
 	rc = register_netdev(dev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
@@ -7525,11 +7518,6 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	/* Make sure RESET task is not scheduled before continuing */
 	cancel_delayed_work_sync(&bp->reset_task);
 
-	kfree(bp->init_ops_offsets);
-	kfree(bp->init_ops);
-	kfree(bp->init_data);
-	release_firmware(bp->firmware);
-
 	if (bp->regview)
 		iounmap(bp->regview);
 
-- 
1.7.1




