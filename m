From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 2/2] bnxt_en: Reset embedded processor after applying firmware upgrade
Date: Thu, 7 Jan 2016 19:56:58 -0500
Message-ID: <1452214618-15519-3-git-send-email-mchan@broadcom.com>
References: <1452214618-15519-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:7070 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801AbcAHA5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 19:57:07 -0500
In-Reply-To: <1452214618-15519-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Swindell <swindell@broadcom.com>

Use HWRM_FW_RESET command to request a self-reset of the embedded
processor(s) after successfully applying a firmware update. For boot
processor, the self-reset is currently deferred until the next PCIe reset.

Signed-off-by: Rob Swindell <swindell@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 46 +++++++++++++++++++++--
 1 file changed, 42 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 4f62c9f..922b898 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -837,6 +837,45 @@ static int bnxt_flash_nvram(struct net_device *dev,
 	return rc;
 }
 
+static int bnxt_firmware_reset(struct net_device *dev,
+			       u16 dir_type)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	struct hwrm_fw_reset_input req = {0};
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FW_RESET, -1, -1);
+
+	/* TODO: Support ASAP ChiMP self-reset (e.g. upon PF driver unload) */
+	/* TODO: Address self-reset of APE/KONG/BONO/TANG or ungraceful reset */
+	/*       (e.g. when firmware isn't already running) */
+	switch (dir_type) {
+	case BNX_DIR_TYPE_CHIMP_PATCH:
+	case BNX_DIR_TYPE_BOOTCODE:
+	case BNX_DIR_TYPE_BOOTCODE_2:
+		req.embedded_proc_type = FW_RESET_REQ_EMBEDDED_PROC_TYPE_BOOT;
+		/* Self-reset ChiMP upon next PCIe reset: */
+		req.selfrst_status = FW_RESET_REQ_SELFRST_STATUS_SELFRSTPCIERST;
+		break;
+	case BNX_DIR_TYPE_APE_FW:
+	case BNX_DIR_TYPE_APE_PATCH:
+		req.embedded_proc_type = FW_RESET_REQ_EMBEDDED_PROC_TYPE_MGMT;
+		break;
+	case BNX_DIR_TYPE_KONG_FW:
+	case BNX_DIR_TYPE_KONG_PATCH:
+		req.embedded_proc_type =
+			FW_RESET_REQ_EMBEDDED_PROC_TYPE_NETCTRL;
+		break;
+	case BNX_DIR_TYPE_BONO_FW:
+	case BNX_DIR_TYPE_BONO_PATCH:
+		req.embedded_proc_type = FW_RESET_REQ_EMBEDDED_PROC_TYPE_ROCE;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+}
+
 static int bnxt_flash_firmware(struct net_device *dev,
 			       u16 dir_type,
 			       const u8 *fw_data,
@@ -894,10 +933,9 @@ static int bnxt_flash_firmware(struct net_device *dev,
 	/* TODO: Validate digital signature (RSA-encrypted SHA-256 hash) here */
 	rc = bnxt_flash_nvram(dev, dir_type, BNX_DIR_ORDINAL_FIRST,
 			      0, 0, fw_data, fw_size);
-	if (rc == 0) {	/* Firmware update successful */
-		/* TODO: Notify processor it needs to reset itself
-		 */
-	}
+	if (rc == 0)	/* Firmware update successful */
+		rc = bnxt_firmware_reset(dev, dir_type);
+
 	return rc;
 }
 
-- 
1.8.3.1
