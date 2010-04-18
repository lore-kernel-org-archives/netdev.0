From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 2/13] bnx2x: Use VPD-R V0 entry to display firmware
 revision
Date: Sun, 18 Apr 2010 17:48:13 +0300
Message-ID: <1271602093.27235.179.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dmitry@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3308 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754557Ab0DROsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 10:48:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use VPD-R V0 entry to display firmware revision

Author: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   34 +++++++++++
 drivers/net/bnx2x_main.c |  141 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 173 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 3589f8b..0706c2c 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1086,6 +1086,7 @@ struct bnx2x {
 #define INIT_CSEM_INT_TABLE_DATA(bp)	(bp->csem_int_table_data)
 #define INIT_CSEM_PRAM_DATA(bp)		(bp->csem_pram_data)
 
+	char			fw_ver[32];
 	const struct firmware	*firmware;
 };
 
@@ -1349,6 +1350,39 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define PXP2_REG_PXP2_INT_STS		PXP2_REG_PXP2_INT_STS_0
 #endif
 
+#define BNX2X_VPD_LEN			128
+#define BNX2X_VPD_LRDT			0x80	/* Large Resource Data Type */
+#define BNX2X_VPD_LRDT_ID(x)		(x | BNX2X_VPD_LRDT)
+
+/* Large Resource Data Type Item Names */
+#define BNX2X_VPD_LRDT_LIN_ID_STRING	0x02	/* Identifier String */
+#define BNX2X_VPD_LRDT_LIN_RO_DATA	0x10	/* Read-Only Data */
+#define BNX2X_VPD_LRDT_LIN_RW_DATA	0x11	/* Read-Write Data */
+
+#define BNX2X_VPD_LRDT_ID_STRING \
+	BNX2X_VPD_LRDT_ID(BNX2X_VPD_LRDT_LIN_ID_STRING)
+#define BNX2X_VPD_LRDT_RO_DATA \
+	BNX2X_VPD_LRDT_ID(BNX2X_VPD_LRDT_LIN_RO_DATA)
+#define BNX2X_VPD_LRDT_RW_DATA \
+	BNX2X_VPD_LRDT_ID(BNX2X_VPD_LRDT_LIN_RW_DATA)
+
+/* Small Resource Data Type Item Names */
+#define BNX2X_VPD_SRDT_SIN_END		0x78	/* End */
+
+#define BNX2X_VPD_SRDT_END		BNX2X_VPD_SRDT_SIN_END
+
+#define BNX2X_VPD_RO_KEYWORD_PARTNO	"PN"
+#define BNX2X_VPD_RO_KEYWORD_VENDOR0	"V0"
+#define BNX2X_VPD_RO_KEYWORD_MANUFACTURERNO	"MN"
+
+#define BNX2X_VPD_SRDT_SIN_MASK		0x78
+#define BNX2X_VPD_SRDT_LEN_MASK		0x07
+
+#define BNX2X_VPD_LRDT_TAG_SIZE		3
+#define BNX2X_VPD_SRDT_TAG_SIZE		1
+#define BNX2X_VPD_INFO_FLD_HDR_SIZE	3
+#define VENDOR_ID_LEN			4
+
 /* MISC_REG_RESET_REG - this is here for the hsi to work don't touch */
 
 #endif /* bnx2x.h */
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5a2e213..33d7484 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9758,6 +9758,140 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	return rc;
 }
 
+
+static inline u16 bnx2x_vpd_lrdt_size(u8 *lrdt)
+{
+	return (u16)lrdt[1] + ((u16)lrdt[2] << 8);
+}
+
+static inline u8 bnx2x_vpd_srdt_size(u8 *srdt)
+{
+	return (*srdt) & BNX2X_VPD_SRDT_LEN_MASK;
+}
+
+static int __devinit bnx2x_vpd_find_tag(u8 *data, unsigned int start,
+				      unsigned int len, u8 tagid)
+{
+	int i;
+
+	for (i = start; i < len; ) {
+		u8 val = data[i];
+
+		if (val & BNX2X_VPD_LRDT) {
+			/* Don't return success of the tag isn't complete */
+			if (i + BNX2X_VPD_LRDT_TAG_SIZE > len)
+				break;
+
+			if (val == tagid)
+				return i;
+
+			i += BNX2X_VPD_LRDT_TAG_SIZE +
+			     bnx2x_vpd_lrdt_size(&data[i]);
+		} else {
+			u8 tag = val & ~BNX2X_VPD_SRDT_LEN_MASK;
+
+			if (tag == tagid)
+				return i;
+
+			if (tag == BNX2X_VPD_SRDT_SIN_END)
+				break;
+
+			i += BNX2X_VPD_SRDT_TAG_SIZE +
+			     bnx2x_vpd_srdt_size(&data[i]);
+		}
+	}
+
+	return -1;
+}
+
+static inline u8 bnx2x_vpd_info_field_size(u8 *info_field)
+{
+	return info_field[2];
+}
+
+static int __devinit bnx2x_vpd_rodata_find_if_keyword(u8 *rodata,
+						    unsigned int start,
+						    unsigned int rosize,
+						    char *kw)
+{
+	int i;
+
+	for (i = start; i + BNX2X_VPD_INFO_FLD_HDR_SIZE <= start + rosize;) {
+		if (rodata[i + 0] == kw[0] &&
+		    rodata[i + 1] == kw[1])
+			return i;
+
+		i += BNX2X_VPD_INFO_FLD_HDR_SIZE +
+		     bnx2x_vpd_info_field_size(&rodata[i]);
+	}
+
+	return -1;
+}
+
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
+	i = bnx2x_vpd_find_tag(vpd_data, 0, BNX2X_VPD_LEN,
+			     BNX2X_VPD_LRDT_RO_DATA);
+	if (i < 0)
+		goto out_not_found;
+
+
+	block_end = i + BNX2X_VPD_LRDT_TAG_SIZE +
+		    bnx2x_vpd_lrdt_size(&vpd_data[i]);
+
+	i += BNX2X_VPD_LRDT_TAG_SIZE;
+
+	if (block_end > BNX2X_VPD_LEN)
+		goto out_not_found;
+
+	rodi = bnx2x_vpd_rodata_find_if_keyword(vpd_data, i, block_end,
+				   BNX2X_VPD_RO_KEYWORD_MANUFACTURERNO);
+	if (rodi < 0)
+		goto out_not_found;
+
+	len = bnx2x_vpd_info_field_size(&vpd_data[rodi]);
+
+	if (len != VENDOR_ID_LEN)
+		goto out_not_found;
+
+	rodi += BNX2X_VPD_INFO_FLD_HDR_SIZE;
+
+	/* vendor specific info */
+	snprintf(str_id_reg, VENDOR_ID_LEN + 1, "%04x", PCI_VENDOR_ID_DELL);
+	snprintf(str_id_cap, VENDOR_ID_LEN + 1, "%04X", PCI_VENDOR_ID_DELL);
+	if (!strncmp(str_id_reg, &vpd_data[rodi], VENDOR_ID_LEN) ||
+	    !strncmp(str_id_cap, &vpd_data[rodi], VENDOR_ID_LEN)) {
+
+		rodi = bnx2x_vpd_rodata_find_if_keyword(vpd_data, i, block_end,
+						BNX2X_VPD_RO_KEYWORD_VENDOR0);
+		if (rodi >= 0) {
+			len = bnx2x_vpd_info_field_size(&vpd_data[rodi]);
+
+			rodi += BNX2X_VPD_INFO_FLD_HDR_SIZE;
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
@@ -9779,6 +9913,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 
 	rc = bnx2x_get_hwinfo(bp);
 
+	bnx2x_read_fwinfo(bp);
 	/* need to reset chip if undi was active */
 	if (!BP_NOMCP(bp))
 		bnx2x_undi_unload(bp);
@@ -10167,11 +10302,13 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
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





