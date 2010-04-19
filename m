From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next-2.6 2/11] bnx2x: Use VPD-R V0 entry to display
 firmware revision
Date: Mon, 19 Apr 2010 14:13:23 +0300
Message-ID: <1271675603.6900.267.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>, dmitry@broadcom.com
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4765 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754508Ab0DSLN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 07:13:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Author: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    4 ++
 drivers/net/bnx2x_main.c |   71 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 73 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index ae9c89e..c2bef7a 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1075,6 +1075,7 @@ struct bnx2x {
 #define INIT_CSEM_INT_TABLE_DATA(bp)	(bp->csem_int_table_data)
 #define INIT_CSEM_PRAM_DATA(bp)		(bp->csem_pram_data)
 
+	char			fw_ver[32];
 	const struct firmware	*firmware;
 };
 
@@ -1333,6 +1334,9 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define PXP2_REG_PXP2_INT_STS		PXP2_REG_PXP2_INT_STS_0
 #endif
 
+#define BNX2X_VPD_LEN			128
+#define VENDOR_ID_LEN			4
+
 /* MISC_REG_RESET_REG - this is here for the hsi to work don't touch */
 
 #endif /* bnx2x.h */
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 63a17d6..278e128 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8896,6 +8896,70 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	return rc;
 }
 
+static void __devinit bnx2x_read_fwinfo(struct bnx2x *bp)
+{
+	int cnt, i, block_end, rodi;
+	char vpd_data[BNX2X_VPD_LEN+1];
+	char str_id_reg[VENDOR_ID_LEN+1];
+	char str_id_cap[VENDOR_ID_LEN+1];
+	u8 len;
+
+	cnt = pci_read_vpd(bp->pdev, 0, BNX2X_VPD_LEN, vpd_data);
+	memset(bp->fw_ver, 0, sizeof(bp->fw_ver));
+
+	if (cnt < BNX2X_VPD_LEN)
+		goto out_not_found;
+
+	i = pci_vpd_find_tag(vpd_data, 0, BNX2X_VPD_LEN,
+			     PCI_VPD_LRDT_RO_DATA);
+	if (i < 0)
+		goto out_not_found;
+
+
+	block_end = i + PCI_VPD_LRDT_TAG_SIZE +
+		    pci_vpd_lrdt_size(&vpd_data[i]);
+
+	i += PCI_VPD_LRDT_TAG_SIZE;
+
+	if (block_end > BNX2X_VPD_LEN)
+		goto out_not_found;
+
+	rodi = pci_vpd_find_info_keyword(vpd_data, i, block_end,
+				   PCI_VPD_RO_KEYWORD_MFR_ID);
+	if (rodi < 0)
+		goto out_not_found;
+
+	len = pci_vpd_info_field_size(&vpd_data[rodi]);
+
+	if (len != VENDOR_ID_LEN)
+		goto out_not_found;
+
+	rodi += PCI_VPD_INFO_FLD_HDR_SIZE;
+
+	/* vendor specific info */
+	snprintf(str_id_reg, VENDOR_ID_LEN + 1, "%04x", PCI_VENDOR_ID_DELL);
+	snprintf(str_id_cap, VENDOR_ID_LEN + 1, "%04X", PCI_VENDOR_ID_DELL);
+	if (!strncmp(str_id_reg, &vpd_data[rodi], VENDOR_ID_LEN) ||
+	    !strncmp(str_id_cap, &vpd_data[rodi], VENDOR_ID_LEN)) {
+
+		rodi = pci_vpd_find_info_keyword(vpd_data, i, block_end,
+						PCI_VPD_RO_KEYWORD_VENDOR0);
+		if (rodi >= 0) {
+			len = pci_vpd_info_field_size(&vpd_data[rodi]);
+
+			rodi += PCI_VPD_INFO_FLD_HDR_SIZE;
+
+			if (len < 32 && (len + rodi) <= BNX2X_VPD_LEN) {
+				memcpy(bp->fw_ver, &vpd_data[rodi], len);
+				bp->fw_ver[len] = ' ';
+			}
+		}
+		return;
+	}
+out_not_found:
+	return;
+}
+
 static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
@@ -8917,6 +8981,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 
 	rc = bnx2x_get_hwinfo(bp);
 
+	bnx2x_read_fwinfo(bp);
 	/* need to reset chip if undi was active */
 	if (!BP_NOMCP(bp))
 		bnx2x_undi_unload(bp);
@@ -9307,11 +9372,13 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
 		bnx2x_release_phy_lock(bp);
 	}
 
-	snprintf(info->fw_version, 32, "BC:%d.%d.%d%s%s",
+	strncpy(info->fw_version, bp->fw_ver, 32);
+	snprintf(info->fw_version + strlen(bp->fw_ver), 32 - strlen(bp->fw_ver),
+		 "bc %d.%d.%d%s%s",
 		 (bp->common.bc_ver & 0xff0000) >> 16,
 		 (bp->common.bc_ver & 0xff00) >> 8,
 		 (bp->common.bc_ver & 0xff),
-		 ((phy_fw_ver[0] != '\0') ? " PHY:" : ""), phy_fw_ver);
+		 ((phy_fw_ver[0] != '\0') ? " phy " : ""), phy_fw_ver);
 	strcpy(info->bus_info, pci_name(bp->pdev));
 	info->n_stats = BNX2X_NUM_STATS;
 	info->testinfo_len = BNX2X_NUM_TESTS;
-- 
1.6.3.3




