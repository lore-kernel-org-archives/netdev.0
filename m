From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH] bnx2x: cache-in compressed fw image
Date: Wed, 16 Nov 2011 00:07:33 +0200
Message-ID: <1321394853-14807-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3573 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932190Ab1KOWHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 17:07:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-request fw from fs may fail for different reasons, once the fw was
loaded we won't release it until driver is removed.

This also resolves the boot problem when initial fw is located on initrd,
but rootfs is still unavailable, in this case device reset will fail due
to absence of fw files.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   50 +++++++++++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c   |   15 +++----
 2 files changed, 35 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9090afc..f6d21fa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10574,33 +10574,38 @@ do {									\
 
 int bnx2x_init_firmware(struct bnx2x *bp)
 {
-	const char *fw_file_name;
 	struct bnx2x_fw_file_hdr *fw_hdr;
 	int rc;
 
-	if (CHIP_IS_E1(bp))
-		fw_file_name = FW_FILE_NAME_E1;
-	else if (CHIP_IS_E1H(bp))
-		fw_file_name = FW_FILE_NAME_E1H;
-	else if (!CHIP_IS_E1x(bp))
-		fw_file_name = FW_FILE_NAME_E2;
-	else {
-		BNX2X_ERR("Unsupported chip revision\n");
-		return -EINVAL;
-	}
 
-	BNX2X_DEV_INFO("Loading %s\n", fw_file_name);
+	if (!bp->firmware) {
+		const char *fw_file_name;
 
-	rc = request_firmware(&bp->firmware, fw_file_name, &bp->pdev->dev);
-	if (rc) {
-		BNX2X_ERR("Can't load firmware file %s\n", fw_file_name);
-		goto request_firmware_exit;
-	}
+		if (CHIP_IS_E1(bp))
+			fw_file_name = FW_FILE_NAME_E1;
+		else if (CHIP_IS_E1H(bp))
+			fw_file_name = FW_FILE_NAME_E1H;
+		else if (!CHIP_IS_E1x(bp))
+			fw_file_name = FW_FILE_NAME_E2;
+		else {
+			BNX2X_ERR("Unsupported chip revision\n");
+			return -EINVAL;
+		}
+		BNX2X_DEV_INFO("Loading %s\n", fw_file_name);
 
-	rc = bnx2x_check_firmware(bp);
-	if (rc) {
-		BNX2X_ERR("Corrupt firmware file %s\n", fw_file_name);
-		goto request_firmware_exit;
+		rc = request_firmware(&bp->firmware, fw_file_name,
+				      &bp->pdev->dev);
+		if (rc) {
+			BNX2X_ERR("Can't load firmware file %s\n",
+				  fw_file_name);
+			goto request_firmware_exit;
+		}
+
+		rc = bnx2x_check_firmware(bp);
+		if (rc) {
+			BNX2X_ERR("Corrupt firmware file %s\n", fw_file_name);
+			goto request_firmware_exit;
+		}
 	}
 
 	fw_hdr = (struct bnx2x_fw_file_hdr *)bp->firmware->data;
@@ -10656,6 +10661,7 @@ static void bnx2x_release_firmware(struct bnx2x *bp)
 	kfree(bp->init_ops);
 	kfree(bp->init_data);
 	release_firmware(bp->firmware);
+	bp->firmware = NULL;
 }
 
 
@@ -10951,6 +10957,8 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	if (bp->doorbells)
 		iounmap(bp->doorbells);
 
+	bnx2x_release_firmware(bp);
+
 	bnx2x_free_mem_bp(bp);
 
 	free_netdev(dev);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 0440425..1451769 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -5380,7 +5380,7 @@ static int bnx2x_func_hw_init(struct bnx2x *bp,
 	rc = drv->init_fw(bp);
 	if (rc) {
 		BNX2X_ERR("Error loading firmware\n");
-		goto fw_init_err;
+		goto init_err;
 	}
 
 	/* Handle the beginning of COMMON_XXX pases separatelly... */
@@ -5388,25 +5388,25 @@ static int bnx2x_func_hw_init(struct bnx2x *bp,
 	case FW_MSG_CODE_DRV_LOAD_COMMON_CHIP:
 		rc = bnx2x_func_init_cmn_chip(bp, drv);
 		if (rc)
-			goto init_hw_err;
+			goto init_err;
 
 		break;
 	case FW_MSG_CODE_DRV_LOAD_COMMON:
 		rc = bnx2x_func_init_cmn(bp, drv);
 		if (rc)
-			goto init_hw_err;
+			goto init_err;
 
 		break;
 	case FW_MSG_CODE_DRV_LOAD_PORT:
 		rc = bnx2x_func_init_port(bp, drv);
 		if (rc)
-			goto init_hw_err;
+			goto init_err;
 
 		break;
 	case FW_MSG_CODE_DRV_LOAD_FUNCTION:
 		rc = bnx2x_func_init_func(bp, drv);
 		if (rc)
-			goto init_hw_err;
+			goto init_err;
 
 		break;
 	default:
@@ -5414,10 +5414,7 @@ static int bnx2x_func_hw_init(struct bnx2x *bp,
 		rc = -EINVAL;
 	}
 
-init_hw_err:
-	drv->release_fw(bp);
-
-fw_init_err:
+init_err:
 	drv->gunzip_end(bp);
 
 	/* In case of success, complete the comand immediatelly: no ramrods
-- 
1.7.7.2
