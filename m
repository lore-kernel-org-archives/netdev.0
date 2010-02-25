From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/7] bnx2: Remove now useless VPD code
Date: Thu, 25 Feb 2010 10:19:21 -0800
Message-ID: <1267121962-6077-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	andy@greyhouse.net, mcarlson@broadcom.com
To: jbarnes@virtuousgeek.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the VPD searching code is abstracted away, the outer loop used
to detect the read-only large resource data type section is useless.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/bnx2.c |   74 ++++++++++++++++++++-------------------------------
 1 files changed, 29 insertions(+), 45 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index fa4dc85..f2f984a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7734,10 +7734,9 @@ bnx2_get_pci_speed(struct bnx2 *bp)
 static void __devinit
 bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 {
-	int rc, i, v0_len = 0;
+	int rc, i, j;
 	u8 *data;
-	u8 *v0_str = NULL;
-	bool mn_match = false;
+	unsigned int block_end, rosize, len;
 
 #define BNX2_VPD_NVRAM_OFFSET	0x300
 #define BNX2_VPD_LEN		128
@@ -7759,57 +7758,42 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 		data[i + 3] = data[i + BNX2_VPD_LEN];
 	}
 
-	for (i = 0; i <= BNX2_VPD_LEN - 3; ) {
-		int j;
-		unsigned int block_end, rosize;
-
-		i = pci_vpd_find_tag(data, i, BNX2_VPD_LEN,
-				     PCI_VPD_LRDT_RO_DATA);
-		if (i < 0)
-			break;
-
-		rosize = pci_vpd_lrdt_size(&data[i]);
-		block_end = i + PCI_VPD_LRDT_TAG_SIZE + rosize;
-		i += PCI_VPD_LRDT_TAG_SIZE;
-
-		if (block_end > BNX2_VPD_LEN)
-			goto vpd_done;
+	i = pci_vpd_find_tag(data, 0, BNX2_VPD_LEN, PCI_VPD_LRDT_RO_DATA);
+	if (i < 0)
+		goto vpd_done;
 
-		j = pci_vpd_find_info_keyword(data, i, rosize,
-					      PCI_VPD_RO_KEYWORD_MFR_ID);
-		if (j > 0) {
-			int len = pci_vpd_info_field_size(&data[j]);
+	rosize = pci_vpd_lrdt_size(&data[i]);
+	i += PCI_VPD_LRDT_TAG_SIZE;
+	block_end = i + rosize;
 
-			if (j + PCI_VPD_INFO_FLD_HDR_SIZE + len > block_end ||
-			    len != 4 ||
-			    memcmp(&data[j + PCI_VPD_INFO_FLD_HDR_SIZE],
-				   "1028", 4))
-				goto vpd_done;
+	if (block_end > BNX2_VPD_LEN)
+		goto vpd_done;
 
-			mn_match = true;
-		}
+	j = pci_vpd_find_info_keyword(data, i, rosize,
+				      PCI_VPD_RO_KEYWORD_MFR_ID);
+	if (j < 0)
+		goto vpd_done;
 
-		j = pci_vpd_find_info_keyword(data, i, rosize,
-					      PCI_VPD_RO_KEYWORD_VENDOR0);
-		if (j > 0) {
-			int len = pci_vpd_info_field_size(&data[j]);
+	len = pci_vpd_info_field_size(&data[j]);
 
-			j += PCI_VPD_INFO_FLD_HDR_SIZE;
-			if (j + len > block_end || len > BNX2_MAX_VER_SLEN)
-				goto vpd_done;
+	j += PCI_VPD_INFO_FLD_HDR_SIZE;
+	if (j + len > block_end || len != 4 ||
+	    memcmp(&data[j], "1028", 4))
+		goto vpd_done;
 
-			v0_len = len;
-			v0_str = &data[j];
-		}
+	j = pci_vpd_find_info_keyword(data, i, rosize,
+				      PCI_VPD_RO_KEYWORD_VENDOR0);
+	if (j < 0)
+		goto vpd_done;
 
-		if (mn_match && v0_str) {
-			memcpy(bp->fw_version, v0_str, v0_len);
-			bp->fw_version[v0_len] = ' ';
-			goto vpd_done;
-		}
+	len = pci_vpd_info_field_size(&data[j]);
 
+	j += PCI_VPD_INFO_FLD_HDR_SIZE;
+	if (j + len > block_end || len > BNX2_MAX_VER_SLEN)
 		goto vpd_done;
-	}
+
+	memcpy(bp->fw_version, &data[j], len);
+	bp->fw_version[len] = ' ';
 
 vpd_done:
 	kfree(data);
-- 
1.6.4.4
