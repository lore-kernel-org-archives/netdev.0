From: "Barak Witkowski" <barak@broadcom.com>
Subject: [PATCH net-next 1/1] bnx2x: handle vpd data longer than 128
 bytes
Date: Wed, 14 Dec 2011 12:14:53 +0200
Message-ID: <1323857693-24527-1-git-send-email-barak@broadcom.com>
References: <Barak Witkowski <barak@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Barak Witkowski" <barak@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3557 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106Ab1LNKPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 05:15:05 -0500
In-Reply-To: <Barak Witkowski <barak@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   35 +++++++++++++++++----
 1 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b45baf9..ffeaaa9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9931,30 +9931,49 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 static void __devinit bnx2x_read_fwinfo(struct bnx2x *bp)
 {
 	int cnt, i, block_end, rodi;
-	char vpd_data[BNX2X_VPD_LEN+1];
+	char vpd_start[BNX2X_VPD_LEN+1];
 	char str_id_reg[VENDOR_ID_LEN+1];
 	char str_id_cap[VENDOR_ID_LEN+1];
+	char *vpd_data;
+	char *vpd_extended_data = NULL;
 	u8 len;
 
-	cnt = pci_read_vpd(bp->pdev, 0, BNX2X_VPD_LEN, vpd_data);
+	cnt = pci_read_vpd(bp->pdev, 0, BNX2X_VPD_LEN, vpd_start);
 	memset(bp->fw_ver, 0, sizeof(bp->fw_ver));
 
 	if (cnt < BNX2X_VPD_LEN)
 		goto out_not_found;
 
-	i = pci_vpd_find_tag(vpd_data, 0, BNX2X_VPD_LEN,
+	/* VPD RO tag should be first tag after identifier string, hence
+	 * we should be able to find it in first BNX2X_VPD_LEN chars
+	 */
+	i = pci_vpd_find_tag(vpd_start, 0, BNX2X_VPD_LEN,
 			     PCI_VPD_LRDT_RO_DATA);
 	if (i < 0)
 		goto out_not_found;
 
-
 	block_end = i + PCI_VPD_LRDT_TAG_SIZE +
-		    pci_vpd_lrdt_size(&vpd_data[i]);
+		    pci_vpd_lrdt_size(&vpd_start[i]);
 
 	i += PCI_VPD_LRDT_TAG_SIZE;
 
-	if (block_end > BNX2X_VPD_LEN)
-		goto out_not_found;
+	if (block_end > BNX2X_VPD_LEN) {
+		vpd_extended_data = kmalloc(block_end, GFP_KERNEL);
+		if (vpd_extended_data  == NULL)
+			goto out_not_found;
+
+		/* read rest of vpd image into vpd_extended_data */
+		memcpy(vpd_extended_data, vpd_start, BNX2X_VPD_LEN);
+		cnt = pci_read_vpd(bp->pdev, BNX2X_VPD_LEN,
+				   block_end - BNX2X_VPD_LEN,
+				   vpd_extended_data + BNX2X_VPD_LEN);
+		if (cnt < (block_end - BNX2X_VPD_LEN))
+			goto out_not_found;
+		vpd_data = vpd_extended_data;
+	} else
+		vpd_data = vpd_start;
+
+	/* now vpd_data holds full vpd content in both cases */
 
 	rodi = pci_vpd_find_info_keyword(vpd_data, i, block_end,
 				   PCI_VPD_RO_KEYWORD_MFR_ID);
@@ -9986,9 +10005,11 @@ static void __devinit bnx2x_read_fwinfo(struct bnx2x *bp)
 				bp->fw_ver[len] = ' ';
 			}
 		}
+		kfree(vpd_extended_data);
 		return;
 	}
 out_not_found:
+	kfree(vpd_extended_data);
 	return;
 }
 
-- 
1.7.7.4
