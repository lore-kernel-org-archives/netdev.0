From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v2 4/7] pci: Add VPD information field helper functions
Date: Fri, 26 Feb 2010 12:40:35 -0800
Message-ID: <1267216838-19459-5-git-send-email-mcarlson@broadcom.com>
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

This patch adds a preprocessor constant to describe the PCI VPD
information field header size and an inline function to extract the
size of the information field itself.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c  |   11 ++++++-----
 drivers/net/tg3.c   |    7 ++++---
 include/linux/pci.h |   13 +++++++++++++
 3 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 02809da..5909d1a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7774,14 +7774,15 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 			goto vpd_done;
 
 		while (i < (block_end - 2)) {
-			int len = data[i + 2];
+			int len = pci_vpd_info_field_size(&data[i]);
 
-			if (i + 3 + len > block_end)
+			if (i + PCI_VPD_INFO_FLD_HDR_SIZE + len > block_end)
 				goto vpd_done;
 
 			if (data[i] == 'M' && data[i + 1] == 'N') {
 				if (len != 4 ||
-				    memcmp(&data[i + 3], "1028", 4))
+				    memcmp(&data[i + PCI_VPD_INFO_FLD_HDR_SIZE],
+					   "1028", 4))
 					goto vpd_done;
 				mn_match = true;
 
@@ -7790,9 +7791,9 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 					goto vpd_done;
 
 				v0_len = len;
-				v0_str = &data[i + 3];
+				v0_str = &data[i + PCI_VPD_INFO_FLD_HDR_SIZE];
 			}
-			i += 3 + len;
+			i += PCI_VPD_INFO_FLD_HDR_SIZE + len;
 
 			if (mn_match && v0_str) {
 				memcpy(bp->fw_version, v0_str, v0_len);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3e5696b..fc510dc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12497,9 +12497,9 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 		while (i < (block_end - 2)) {
 			if (vpd_data[i + 0] == 'P' &&
 			    vpd_data[i + 1] == 'N') {
-				int partno_len = vpd_data[i + 2];
+				int partno_len = pci_vpd_info_field_size(&vpd_data[i]);
 
-				i += 3;
+				i += PCI_VPD_INFO_FLD_HDR_SIZE;
 				if (partno_len > TG3_BPN_SIZE ||
 				    (partno_len + i) > TG3_NVM_VPD_LEN)
 					goto out_not_found;
@@ -12510,7 +12510,8 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 				/* Success. */
 				return;
 			}
-			i += 3 + vpd_data[i + 2];
+			i += PCI_VPD_INFO_FLD_HDR_SIZE +
+			     pci_vpd_info_field_size(&vpd_data[i]);
 		}
 
 		/* Part number not found. */
diff --git a/include/linux/pci.h b/include/linux/pci.h
index e158da4..1c86d29 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1362,6 +1362,8 @@ void pci_request_acs(void);
 #define PCI_VPD_LRDT_TAG_SIZE		3
 #define PCI_VPD_SRDT_TAG_SIZE		1
 
+#define PCI_VPD_INFO_FLD_HDR_SIZE	3
+
 /**
  * pci_vpd_lrdt_size - Extracts the Large Resource Data Type length
  * @lrdt: Pointer to the beginning of the Large Resource Data Type tag
@@ -1385,6 +1387,17 @@ static inline u8 pci_vpd_srdt_size(u8 *srdt)
 }
 
 /**
+ * pci_vpd_info_field_size - Extracts the information field length
+ * @lrdt: Pointer to the beginning of an information field header
+ *
+ * Returns the extracted information field length.
+ */
+static inline u8 pci_vpd_info_field_size(u8 *info_field)
+{
+	return info_field[2];
+}
+
+/**
  * pci_vpd_find_tag - Locates the Resource Data Type tag provided
  * @buf: Pointer to buffered vpd data
  * @off: The offset into the buffer at which to begin the search
-- 
1.6.4.4
