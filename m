From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/7] pci: Add large and small resource data type code
Date: Thu, 25 Feb 2010 10:19:17 -0800
Message-ID: <1267121962-6077-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: jbarnes@virtuousgeek.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2641 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933231Ab0BYSUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 13:20:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces more VPD preprocessor definitions to identify some
small and large resource data type item names.  The patch then continues
to correct how the tg3 and bnx2 drivers search for the "read-only data"
large resource data type.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c      |   23 +++++++++++++++++------
 drivers/net/tg3.c       |   23 +++++++++++++++++------
 include/linux/pci-vpd.h |   28 +++++++++++++++++++++++++++-
 3 files changed, 61 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 9f5b0fc..1c48d4a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7763,15 +7763,26 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 		unsigned char val = data[i];
 		unsigned int block_end;
 
-		if (val == 0x82 || val == 0x91) {
-			i += PCI_VPD_LRDT_TAG_SIZE +
-			     pci_vpd_lrdt_size(&data[i]);
+		if (val & PCI_VPD_LRDT) {
+			if (i + PCI_VPD_LRDT_TAG_SIZE > BNX2_VPD_LEN)
+				break;
+
+			if (val != PCI_VPD_LRDT_RO_DATA) {
+				i += PCI_VPD_LRDT_TAG_SIZE +
+				     pci_vpd_lrdt_size(&data[i]);
+
+				continue;
+			}
+		} else {
+			if ((val & PCI_VPD_SRDT_TIN_MASK) == PCI_VPD_STIN_END)
+				break;
+
+			i += PCI_VPD_SRDT_TAG_SIZE +
+			     pci_vpd_srdt_size(&data[i]);
+
 			continue;
 		}
 
-		if (val != 0x90)
-			goto vpd_done;
-
 		block_end = (i + PCI_VPD_LRDT_TAG_SIZE +
 			    pci_vpd_lrdt_size(&data[i]));
 		i += PCI_VPD_LRDT_TAG_SIZE;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6cab97f..2ec6eca 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12483,15 +12483,26 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 		unsigned char val = vpd_data[i];
 		unsigned int block_end;
 
-		if (val == 0x82 || val == 0x91) {
-			i += PCI_VPD_LRDT_TAG_SIZE +
-			     pci_vpd_lrdt_size(&vpd_data[i]);
+		if (val & PCI_VPD_LRDT) {
+			if (i + PCI_VPD_LRDT_TAG_SIZE > TG3_NVM_VPD_LEN)
+				break;
+
+			if (val != PCI_VPD_LRDT_RO_DATA) {
+				i += PCI_VPD_LRDT_TAG_SIZE +
+				     pci_vpd_lrdt_size(&vpd_data[i]);
+
+				continue;
+			}
+		} else {
+			if ((val & PCI_VPD_SRDT_TIN_MASK) == PCI_VPD_STIN_END)
+				break;
+
+			i += PCI_VPD_SRDT_TAG_SIZE +
+			     pci_vpd_srdt_size(&vpd_data[i]);
+
 			continue;
 		}
 
-		if (val != 0x90)
-			goto out_not_found;
-
 		block_end = i + PCI_VPD_LRDT_TAG_SIZE +
 			    pci_vpd_lrdt_size(&vpd_data[i]);
 
diff --git a/include/linux/pci-vpd.h b/include/linux/pci-vpd.h
index c077369..b80d5c0 100644
--- a/include/linux/pci-vpd.h
+++ b/include/linux/pci-vpd.h
@@ -16,11 +16,37 @@
 
 #include <linux/pci.h>
 
-#define PCI_VPD_LRDT_TAG_SIZE	3
+#define PCI_VPD_LRDT			0x80	/* Large Resource Data Type */
+#define PCI_VPD_LRDT_ID(x)		(x | PCI_VPD_LRDT)
+
+/* Large Resource Data Type Tag Item Names */
+#define PCI_VPD_LTIN_ID_STRING		0x02	/* Identifier String */
+#define PCI_VPD_LTIN_RO_DATA		0x10	/* Read-Only Data */
+#define PCI_VPD_LTIN_RW_DATA		0x11	/* Read-Write Data */
+
+#define PCI_VPD_LRDT_ID_STRING		PCI_VPD_LRDT_ID(PCI_VPD_LTIN_ID_STRING)
+#define PCI_VPD_LRDT_RO_DATA		PCI_VPD_LRDT_ID(PCI_VPD_LTIN_RO_DATA)
+#define PCI_VPD_LRDT_RW_DATA		PCI_VPD_LRDT_ID(PCI_VPD_LTIN_RW_DATA)
+
+/* Small Resource Data Type Tag Item Names */
+#define PCI_VPD_STIN_END		0x78	/* End */
+
+#define PCI_VPD_SRDT_END		PCI_VPD_STIN_END
+
+#define PCI_VPD_SRDT_TIN_MASK		0x78
+#define PCI_VPD_SRDT_LEN_MASK		0x07
+
+#define PCI_VPD_LRDT_TAG_SIZE		3
+#define PCI_VPD_SRDT_TAG_SIZE		1
 
 static inline u16 pci_vpd_lrdt_size(u8 *lrdt)
 {
 	return (u16)lrdt[1] + ((u16)lrdt[2] << 8);
 }
 
+static inline u8 pci_vpd_srdt_size(u8 *srdt)
+{
+	return (*srdt) & PCI_VPD_SRDT_LEN_MASK;
+}
+
 #endif /* LINUX_PCI_VPD_H */
-- 
1.6.4.4


