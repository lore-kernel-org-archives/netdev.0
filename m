From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 07/12] tg3: Use VPD fw version when present
Date: Mon, 5 Apr 2010 13:19:25 -0700
Message-ID: <1270498770-23765-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2515 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756219Ab0DEUTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 16:19:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extracts the firmware version from the VPD area and changes
the code to prefer that version version over the manually extracted
version.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   34 ++++++++++++++++++++++++++++++----
 1 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5d65513..80df3e8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12563,11 +12563,11 @@ skip_phy_reset:
 	return err;
 }
 
-static void __devinit tg3_read_partno(struct tg3 *tp)
+static void __devinit tg3_read_vpd(struct tg3 *tp)
 {
-	unsigned char vpd_data[TG3_NVM_VPD_LEN];   /* in little-endian format */
+	u8 vpd_data[TG3_NVM_VPD_LEN];
 	unsigned int block_end, rosize, len;
-	int i = 0;
+	int j, i = 0;
 	u32 magic;
 
 	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
@@ -12616,6 +12616,32 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 	if (block_end > TG3_NVM_VPD_LEN)
 		goto out_not_found;
 
+	j = pci_vpd_find_info_keyword(vpd_data, i, rosize,
+				      PCI_VPD_RO_KEYWORD_MFR_ID);
+	if (j > 0) {
+		len = pci_vpd_info_field_size(&vpd_data[j]);
+
+		j += PCI_VPD_INFO_FLD_HDR_SIZE;
+		if (j + len > block_end || len != 4 ||
+		    memcmp(&vpd_data[j], "1028", 4))
+			goto partno;
+
+		j = pci_vpd_find_info_keyword(vpd_data, i, rosize,
+					      PCI_VPD_RO_KEYWORD_VENDOR0);
+		if (j < 0)
+			goto partno;
+
+		len = pci_vpd_info_field_size(&vpd_data[j]);
+
+		j += PCI_VPD_INFO_FLD_HDR_SIZE;
+		if (j + len > block_end)
+			goto partno;
+
+		memcpy(tp->fw_ver, &vpd_data[j], len);
+		strncat(tp->fw_ver, " bc ", TG3_NVM_VPD_LEN - len - 1);
+	}
+
+partno:
 	i = pci_vpd_find_info_keyword(vpd_data, i, rosize,
 				      PCI_VPD_RO_KEYWORD_PARTNO);
 	if (i < 0)
@@ -13626,7 +13652,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tg3_mdio_fini(tp);
 	}
 
-	tg3_read_partno(tp);
+	tg3_read_vpd(tp);
 	tg3_read_fw_ver(tp);
 
 	if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) {
-- 
1.6.4.4


