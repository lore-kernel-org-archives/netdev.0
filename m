From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 2/9] bnxt_en: Retry failed NVM_INSTALL_UPDATE with defragmentation flag.
Date: Sun, 12 Feb 2017 19:18:11 -0500
Message-ID: <1486945098-4086-3-git-send-email-michael.chan@broadcom.com>
References: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:32810 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751114AbdBMASv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 19:18:51 -0500
Received: by mail-it0-f47.google.com with SMTP id d9so2879805itc.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 16:18:51 -0800 (PST)
In-Reply-To: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kshitij Soni <kshitij.soni@broadcom.com>

If the HWRM_NVM_INSTALL_UPDATE command fails with the error code
NVM_INSTALL_UPDATE_CMD_ERR_CODE_FRAG_ERR, retry the command with
a new flag to allow defragmentation.  Since we are checking the
response for error code, we also need to take the mutex until
we finish reading the response.

Signed-off-by: Kshitij Soni <kshitij.soni@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 32 ++++++++++++++++++-----
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 7aa248d..4b45b88 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1578,17 +1578,37 @@ static int bnxt_flash_package_from_file(struct net_device *dev,
 	bnxt_hwrm_cmd_hdr_init(bp, &install, HWRM_NVM_INSTALL_UPDATE, -1, -1);
 	install.install_type = cpu_to_le32(install_type);
 
-	rc = hwrm_send_message(bp, &install, sizeof(install),
-			       INSTALL_PACKAGE_TIMEOUT);
-	if (rc)
-		return -EOPNOTSUPP;
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &install, sizeof(install),
+				INSTALL_PACKAGE_TIMEOUT);
+	if (rc) {
+		rc = -EOPNOTSUPP;
+		goto flash_pkg_exit;
+	}
+
+	if (resp->error_code) {
+		u8 error_code = ((struct hwrm_err_output *)resp)->cmd_err;
+
+		if (error_code == NVM_INSTALL_UPDATE_CMD_ERR_CODE_FRAG_ERR) {
+			install.flags |= cpu_to_le16(
+			       NVM_INSTALL_UPDATE_REQ_FLAGS_ALLOWED_TO_DEFRAG);
+			rc = _hwrm_send_message(bp, &install, sizeof(install),
+						INSTALL_PACKAGE_TIMEOUT);
+			if (rc) {
+				rc = -EOPNOTSUPP;
+				goto flash_pkg_exit;
+			}
+		}
+	}
 
 	if (resp->result) {
 		netdev_err(dev, "PKG install error = %d, problem_item = %d\n",
 			   (s8)resp->result, (int)resp->problem_item);
-		return -ENOPKG;
+		rc = -ENOPKG;
 	}
-	return 0;
+flash_pkg_exit:
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
 }
 
 static int bnxt_flash_device(struct net_device *dev,
-- 
1.8.3.1
