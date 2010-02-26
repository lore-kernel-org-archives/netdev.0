From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v2 1/7] pci: Add PCI LRDT tag size and section size
Date: Fri, 26 Feb 2010 12:40:32 -0800
Message-ID: <1267216838-19459-2-git-send-email-mcarlson@broadcom.com>
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

This patch adds a preprocessor constant to describe the PCI VPD large
resource data type tag size and an inline function to extract the large
resource section size from the large resource data type tag.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c  |    8 +++++---
 drivers/net/tg3.c   |   13 ++++++-------
 include/linux/pci.h |   14 ++++++++++++++
 3 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 65df1de..d466208 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7763,15 +7763,17 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 		unsigned int block_end;
 
 		if (val == 0x82 || val == 0x91) {
-			i = (i + 3 + (data[i + 1] + (data[i + 2] << 8)));
+			i += PCI_VPD_LRDT_TAG_SIZE +
+			     pci_vpd_lrdt_size(&data[i]);
 			continue;
 		}
 
 		if (val != 0x90)
 			goto vpd_done;
 
-		block_end = (i + 3 + (data[i + 1] + (data[i + 2] << 8)));
-		i += 3;
+		block_end = (i + PCI_VPD_LRDT_TAG_SIZE +
+			    pci_vpd_lrdt_size(&data[i]));
+		i += PCI_VPD_LRDT_TAG_SIZE;
 
 		if (block_end > BNX2_VPD_LEN)
 			goto vpd_done;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 7f82b02..d01e133 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12483,19 +12483,18 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 		unsigned int block_end;
 
 		if (val == 0x82 || val == 0x91) {
-			i = (i + 3 +
-			     (vpd_data[i + 1] +
-			      (vpd_data[i + 2] << 8)));
+			i += PCI_VPD_LRDT_TAG_SIZE +
+			     pci_vpd_lrdt_size(&vpd_data[i]);
 			continue;
 		}
 
 		if (val != 0x90)
 			goto out_not_found;
 
-		block_end = (i + 3 +
-			     (vpd_data[i + 1] +
-			      (vpd_data[i + 2] << 8)));
-		i += 3;
+		block_end = i + PCI_VPD_LRDT_TAG_SIZE +
+			    pci_vpd_lrdt_size(&vpd_data[i]);
+
+		i += PCI_VPD_LRDT_TAG_SIZE;
 
 		if (block_end > TG3_NVM_VPD_LEN)
 			goto out_not_found;
diff --git a/include/linux/pci.h b/include/linux/pci.h
index c1968f4..b46669b 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1338,5 +1338,19 @@ static inline bool pci_is_pcie(struct pci_dev *dev)
 
 void pci_request_acs(void);
 
+
+#define PCI_VPD_LRDT_TAG_SIZE	3
+
+/**
+ * pci_vpd_lrdt_size - Extracts the Large Resource Data Type length
+ * @lrdt: Pointer to the beginning of the Large Resource Data Type tag
+ *
+ * Returns the extracted Large Resource Data Type length.
+ */
+static inline u16 pci_vpd_lrdt_size(u8 *lrdt)
+{
+	return (u16)lrdt[1] + ((u16)lrdt[2] << 8);
+}
+
 #endif /* __KERNEL__ */
 #endif /* LINUX_PCI_H */
-- 
1.6.4.4
