From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/7] tg3: Add code to verify RODATA checksum of VPD
Date: Wed, 9 Mar 2011 18:58:21 -0800
Message-ID: <1299725905-8498-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2003 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259Ab1CJC6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 21:58:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to verify the checksum stored in the "RV" info
keyword of the RODATA VPD section.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c   |   35 +++++++++++++++++++++++++++++++++++
 include/linux/pci.h |    1 +
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8f71608..ffb0979 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10499,6 +10499,41 @@ static int tg3_test_nvram(struct tg3 *tp)
 	if (csum != le32_to_cpu(buf[0xfc/4]))
 		goto out;
 
+	for (i = 0; i < TG3_NVM_VPD_LEN; i += 4) {
+		/* The data is in little-endian format in NVRAM.
+		 * Use the big-endian read routines to preserve
+		 * the byte order as it exists in NVRAM.
+		 */
+		if (tg3_nvram_read_be32(tp, TG3_NVM_VPD_OFF + i, &buf[i/4]))
+			goto out;
+	}
+
+	i = pci_vpd_find_tag((u8 *)buf, 0, TG3_NVM_VPD_LEN,
+			     PCI_VPD_LRDT_RO_DATA);
+	if (i > 0) {
+		j = pci_vpd_lrdt_size(&((u8 *)buf)[i]);
+		if (j < 0)
+			goto out;
+
+		if (i + PCI_VPD_LRDT_TAG_SIZE + j > TG3_NVM_VPD_LEN)
+			goto out;
+
+		i += PCI_VPD_LRDT_TAG_SIZE;
+		j = pci_vpd_find_info_keyword((u8 *)buf, i, j,
+					      PCI_VPD_RO_KEYWORD_CHKSUM);
+		if (j > 0) {
+			u8 csum8 = 0;
+
+			j += PCI_VPD_INFO_FLD_HDR_SIZE;
+
+			for (i = 0; i <= j; i++)
+				csum8 += ((u8 *)buf)[i];
+
+			if (csum8)
+				goto out;
+		}
+	}
+
 	err = 0;
 
 out:
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 559d028..ff5bccb 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1479,6 +1479,7 @@ void pci_request_acs(void);
 #define PCI_VPD_RO_KEYWORD_PARTNO	"PN"
 #define PCI_VPD_RO_KEYWORD_MFR_ID	"MN"
 #define PCI_VPD_RO_KEYWORD_VENDOR0	"V0"
+#define PCI_VPD_RO_KEYWORD_CHKSUM	"RV"
 
 /**
  * pci_vpd_lrdt_size - Extracts the Large Resource Data Type length
-- 
1.7.3.4


