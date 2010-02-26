From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v2 2/7] pci: Add large and small resource data type code
Date: Fri, 26 Feb 2010 12:40:33 -0800
Message-ID: <1267216838-19459-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: jbarnes@virtuousgeek.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces more VPD preprocessor definitions to identify some
small and large resource data type item names.  The patch then continues
to correct how the tg3 and bnx2 drivers search for the "read-only data"
large resource data type.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c  |   23 +++++++++++++++++------
 drivers/net/tg3.c   |   23 +++++++++++++++++------
 include/linux/pci.h |   34 +++++++++++++++++++++++++++++++++-
 3 files changed, 67 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d466208..7caa98d 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7762,15 +7762,26 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
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
index d01e133..4c24998 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12482,15 +12482,26 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
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
 
diff --git a/include/linux/pci.h b/include/linux/pci.h
index b46669b..a14b086 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1339,7 +1339,28 @@ static inline bool pci_is_pcie(struct pci_dev *dev)
 void pci_request_acs(void);
 
 
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
 
 /**
  * pci_vpd_lrdt_size - Extracts the Large Resource Data Type length
@@ -1352,5 +1373,16 @@ static inline u16 pci_vpd_lrdt_size(u8 *lrdt)
 	return (u16)lrdt[1] + ((u16)lrdt[2] << 8);
 }
 
+/**
+ * pci_vpd_srdt_size - Extracts the Small Resource Data Type length
+ * @lrdt: Pointer to the beginning of the Small Resource Data Type tag
+ *
+ * Returns the extracted Small Resource Data Type length.
+ */
+static inline u8 pci_vpd_srdt_size(u8 *srdt)
+{
+	return (*srdt) & PCI_VPD_SRDT_LEN_MASK;
+}
+
 #endif /* __KERNEL__ */
 #endif /* LINUX_PCI_H */
-- 
1.6.4.4
