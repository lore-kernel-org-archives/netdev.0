From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 08/10] bnxt_en: Provide NVM information via Ethtool GEEPROM
Date: Tue,  5 Apr 2016 04:22:40 -0400
Message-ID: <1459844562-24576-9-git-send-email-michael.chan@broadcom.com>
References: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:8221 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757504AbcDEIWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:22:47 -0400
In-Reply-To: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Swindell <swindell@broadcom.com>

Provide details about the NVM device and the firmware version, etc, via
the Ethtool GEEPROM command.

Signed-off-by: Rob Swindell <rob.swindell@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 60 +++++++++++++++++++++--
 1 file changed, 55 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 3d5c64f..3b4db00 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1311,8 +1311,18 @@ static int bnxt_get_eeprom(struct net_device *dev,
 			   struct ethtool_eeprom *eeprom,
 			   u8 *data)
 {
+	int i;
+	int rc;
 	u32 index;
 	u32 offset;
+	u32 size;
+	struct bnxt *bp = netdev_priv(dev);
+	struct hwrm_fw_qstatus_input fw_status_req = {0};
+	struct hwrm_fw_qstatus_output *fw_status_resp = bp->hwrm_cmd_resp_addr;
+	struct hwrm_nvm_get_dev_info_input dev_info_req = {0};
+
+	if (eeprom->len < 1)
+		return -EINVAL;
 
 	if (eeprom->offset == 0) /* special offset value to get directory */
 		return bnxt_get_nvram_directory(dev, eeprom->len, data);
@@ -1320,12 +1330,52 @@ static int bnxt_get_eeprom(struct net_device *dev,
 	index = eeprom->offset >> 24;
 	offset = eeprom->offset & 0xffffff;
 
-	if (index == 0) {
-		netdev_err(dev, "unsupported index value: %d\n", index);
-		return -EINVAL;
-	}
+	if (index != 0)
+		return bnxt_get_nvram_item(dev, index - 1, offset, eeprom->len,
+					   data);
 
-	return bnxt_get_nvram_item(dev, index - 1, offset, eeprom->len, data);
+	switch (offset) {
+	case 1:	/* Query firmware reset status */
+		if (eeprom->len < 5)
+			return -EINVAL;
+		size = 4; /* procs: BOOT, MGMT, NETCTRL, and ROCE */
+		*(data++) = size;
+		mutex_lock(&bp->hwrm_cmd_lock);
+		for (i = 0; i < size; i++) {
+			bnxt_hwrm_cmd_hdr_init(bp, &fw_status_req,
+					       HWRM_FW_QSTATUS, -1, -1);
+			fw_status_req.embedded_proc_type = i;
+			rc = _hwrm_send_message(bp, &fw_status_req,
+						sizeof(fw_status_req),
+						HWRM_CMD_TIMEOUT);
+			if (rc == 0)
+				*(data++) = fw_status_resp->selfrst_status;
+			else
+				break;
+		}
+		mutex_unlock(&bp->hwrm_cmd_lock);
+		return rc;
+	case 2: /* Query firmware version information */
+		size = sizeof(bp->ver_resp);
+		*(data++) = size;
+		memcpy(data, &bp->ver_resp, min(size, eeprom->len - 1));
+		return 0;
+	case 3: /* Query NVM device information */
+		bnxt_hwrm_cmd_hdr_init(bp, &dev_info_req,
+				       HWRM_NVM_GET_DEV_INFO, -1, -1);
+		mutex_lock(&bp->hwrm_cmd_lock);
+		rc = _hwrm_send_message(bp, &dev_info_req, sizeof(dev_info_req),
+					HWRM_CMD_TIMEOUT);
+		if (rc == 0) {
+			size = sizeof(struct hwrm_nvm_get_dev_info_output);
+			*(data++) = size;
+			memcpy(data, bp->hwrm_cmd_resp_addr,
+			       min(size, eeprom->len - 1));
+		}
+		mutex_unlock(&bp->hwrm_cmd_lock);
+		return rc;
+	}
+	return -EINVAL;
 }
 
 static int bnxt_erase_nvram_directory(struct net_device *dev, u8 index)
-- 
1.8.3.1
