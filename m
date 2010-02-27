From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v3 7/7] tg3: Remove now useless VPD code
Date: Fri, 26 Feb 2010 16:04:45 -0800
Message-ID: <1267229085-21303-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	andy@greyhouse.net, mcarlson@broadcom.com
To: jbarnes@virtuousgeek.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1950 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966615Ab0B0AEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 19:04:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the VPD searching code is abstracted away, the outer loop used
to detect the read-only large resource data type section is useless.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   52 +++++++++++++++++++++++-----------------------------
 1 files changed, 23 insertions(+), 29 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 731ba67..6e5feb6 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12440,7 +12440,8 @@ skip_phy_reset:
 static void __devinit tg3_read_partno(struct tg3 *tp)
 {
 	unsigned char vpd_data[TG3_NVM_VPD_LEN];   /* in little-endian format */
-	int i;
+	unsigned int block_end, rosize, len;
+	int i = 0;
 	u32 magic;
 
 	if ((tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) ||
@@ -12462,7 +12463,7 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 		}
 	} else {
 		ssize_t cnt;
-		unsigned int pos = 0, i = 0;
+		unsigned int pos = 0;
 
 		for (; pos < TG3_NVM_VPD_LEN && i < 3; i++, pos += cnt) {
 			cnt = pci_read_vpd(tp->pdev, pos,
@@ -12477,40 +12478,33 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 			goto out_not_found;
 	}
 
-	/* Now parse and find the part number. */
-	for (i = 0; i < TG3_NVM_VPD_LEN - 2; ) {
-		unsigned int block_end, rosize;
+	i = pci_vpd_find_tag(vpd_data, 0, TG3_NVM_VPD_LEN,
+			     PCI_VPD_LRDT_RO_DATA);
+	if (i < 0)
+		goto out_not_found;
 
-		i = pci_vpd_find_tag(vpd_data, i, TG3_NVM_VPD_LEN,
-				     PCI_VPD_LRDT_RO_DATA);
-		if (i < 0)
-			break;
+	rosize = pci_vpd_lrdt_size(&vpd_data[i]);
+	block_end = i + PCI_VPD_LRDT_TAG_SIZE + rosize;
+	i += PCI_VPD_LRDT_TAG_SIZE;
 
-		rosize = pci_vpd_lrdt_size(&vpd_data[i]);
-		block_end = i + PCI_VPD_LRDT_TAG_SIZE + rosize;
-		i += PCI_VPD_LRDT_TAG_SIZE;
+	if (block_end > TG3_NVM_VPD_LEN)
+		goto out_not_found;
 
-		if (block_end > TG3_NVM_VPD_LEN)
-			goto out_not_found;
+	i = pci_vpd_find_info_keyword(vpd_data, i, rosize,
+				      PCI_VPD_RO_KEYWORD_PARTNO);
+	if (i < 0)
+		goto out_not_found;
 
-		i = pci_vpd_find_info_keyword(vpd_data, i, rosize,
-					      PCI_VPD_RO_KEYWORD_PARTNO);
-		if (i > 0) {
-			u8 len = pci_vpd_info_field_size(&vpd_data[i]);
+	len = pci_vpd_info_field_size(&vpd_data[i]);
 
-			i += PCI_VPD_INFO_FLD_HDR_SIZE;
-			if (len > TG3_BPN_SIZE ||
-			    (len + i) > TG3_NVM_VPD_LEN)
-				break;
-
-			memcpy(tp->board_part_number, &vpd_data[i], len);
+	i += PCI_VPD_INFO_FLD_HDR_SIZE;
+	if (len > TG3_BPN_SIZE ||
+	    (len + i) > TG3_NVM_VPD_LEN)
+		goto out_not_found;
 
-			return;
-		}
+	memcpy(tp->board_part_number, &vpd_data[i], len);
 
-		/* Part number not found. */
-		goto out_not_found;
-	}
+	return;
 
 out_not_found:
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-- 
1.6.4.4


