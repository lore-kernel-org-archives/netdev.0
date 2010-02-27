From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH v3 5/7] pci: Add helper to search for VPD keywords
Date: Fri, 26 Feb 2010 16:04:43 -0800
Message-ID: <1267229085-21303-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: jbarnes@virtuousgeek.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1804 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966641Ab0B0AE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 19:04:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the pci_vpd_find_info_keyword() helper function to
find information field keywords within read-only and read-write large
resource data type sections.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c  |   54 ++++++++++++++++++++++++++++----------------------
 drivers/net/tg3.c   |   32 ++++++++++++-----------------
 drivers/pci/vpd.c   |   18 +++++++++++++++++
 include/linux/pci.h |   17 ++++++++++++++++
 4 files changed, 78 insertions(+), 43 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 5909d1a..9feab11 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7759,48 +7759,54 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 	}
 
 	for (i = 0; i <= BNX2_VPD_LEN - 3; ) {
-		unsigned int block_end;
+		int j;
+		unsigned int block_end, rosize;
 
 		i = pci_vpd_find_tag(data, i, BNX2_VPD_LEN,
 				     PCI_VPD_LRDT_RO_DATA);
 		if (i < 0)
 			break;
 
-		block_end = (i + PCI_VPD_LRDT_TAG_SIZE +
-			    pci_vpd_lrdt_size(&data[i]));
+		rosize = pci_vpd_lrdt_size(&data[i]);
+		block_end = i + PCI_VPD_LRDT_TAG_SIZE + rosize;
 		i += PCI_VPD_LRDT_TAG_SIZE;
 
 		if (block_end > BNX2_VPD_LEN)
 			goto vpd_done;
 
-		while (i < (block_end - 2)) {
-			int len = pci_vpd_info_field_size(&data[i]);
+		j = pci_vpd_find_info_keyword(data, i, rosize,
+					      PCI_VPD_RO_KEYWORD_MFR_ID);
+		if (j > 0) {
+			int len = pci_vpd_info_field_size(&data[j]);
 
-			if (i + PCI_VPD_INFO_FLD_HDR_SIZE + len > block_end)
+			if (j + PCI_VPD_INFO_FLD_HDR_SIZE + len > block_end ||
+			    len != 4 ||
+			    memcmp(&data[j + PCI_VPD_INFO_FLD_HDR_SIZE],
+				   "1028", 4))
 				goto vpd_done;
 
-			if (data[i] == 'M' && data[i + 1] == 'N') {
-				if (len != 4 ||
-				    memcmp(&data[i + PCI_VPD_INFO_FLD_HDR_SIZE],
-					   "1028", 4))
-					goto vpd_done;
-				mn_match = true;
+			mn_match = true;
+		}
 
-			} else if (data[i] == 'V' && data[i + 1] == '0') {
-				if (len > BNX2_MAX_VER_SLEN)
-					goto vpd_done;
+		j = pci_vpd_find_info_keyword(data, i, rosize,
+					      PCI_VPD_RO_KEYWORD_VENDOR0);
+		if (j > 0) {
+			int len = pci_vpd_info_field_size(&data[j]);
 
-				v0_len = len;
-				v0_str = &data[i + PCI_VPD_INFO_FLD_HDR_SIZE];
-			}
-			i += PCI_VPD_INFO_FLD_HDR_SIZE + len;
-
-			if (mn_match && v0_str) {
-				memcpy(bp->fw_version, v0_str, v0_len);
-				bp->fw_version[v0_len] = ' ';
+			j += PCI_VPD_INFO_FLD_HDR_SIZE;
+			if (j + len > block_end || len > BNX2_MAX_VER_SLEN)
 				goto vpd_done;
-			}
+
+			v0_len = len;
+			v0_str = &data[j];
 		}
+
+		if (mn_match && v0_str) {
+			memcpy(bp->fw_version, v0_str, v0_len);
+			bp->fw_version[v0_len] = ' ';
+			goto vpd_done;
+		}
+
 		goto vpd_done;
 	}
 
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index fc510dc..731ba67 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12479,39 +12479,33 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 
 	/* Now parse and find the part number. */
 	for (i = 0; i < TG3_NVM_VPD_LEN - 2; ) {
-		unsigned int block_end;
+		unsigned int block_end, rosize;
 
 		i = pci_vpd_find_tag(vpd_data, i, TG3_NVM_VPD_LEN,
 				     PCI_VPD_LRDT_RO_DATA);
 		if (i < 0)
 			break;
 
-		block_end = i + PCI_VPD_LRDT_TAG_SIZE +
-			    pci_vpd_lrdt_size(&vpd_data[i]);
-
+		rosize = pci_vpd_lrdt_size(&vpd_data[i]);
+		block_end = i + PCI_VPD_LRDT_TAG_SIZE + rosize;
 		i += PCI_VPD_LRDT_TAG_SIZE;
 
 		if (block_end > TG3_NVM_VPD_LEN)
 			goto out_not_found;
 
-		while (i < (block_end - 2)) {
-			if (vpd_data[i + 0] == 'P' &&
-			    vpd_data[i + 1] == 'N') {
-				int partno_len = pci_vpd_info_field_size(&vpd_data[i]);
+		i = pci_vpd_find_info_keyword(vpd_data, i, rosize,
+					      PCI_VPD_RO_KEYWORD_PARTNO);
+		if (i > 0) {
+			u8 len = pci_vpd_info_field_size(&vpd_data[i]);
 
-				i += PCI_VPD_INFO_FLD_HDR_SIZE;
-				if (partno_len > TG3_BPN_SIZE ||
-				    (partno_len + i) > TG3_NVM_VPD_LEN)
-					goto out_not_found;
+			i += PCI_VPD_INFO_FLD_HDR_SIZE;
+			if (len > TG3_BPN_SIZE ||
+			    (len + i) > TG3_NVM_VPD_LEN)
+				break;
 
-				memcpy(tp->board_part_number,
-				       &vpd_data[i], partno_len);
+			memcpy(tp->board_part_number, &vpd_data[i], len);
 
-				/* Success. */
-				return;
-			}
-			i += PCI_VPD_INFO_FLD_HDR_SIZE +
-			     pci_vpd_info_field_size(&vpd_data[i]);
+			return;
 		}
 
 		/* Part number not found. */
diff --git a/drivers/pci/vpd.c b/drivers/pci/vpd.c
index 6bc5545..a5a5ca1 100644
--- a/drivers/pci/vpd.c
+++ b/drivers/pci/vpd.c
@@ -41,3 +41,21 @@ int pci_vpd_find_tag(const u8 *buf, unsigned int off, unsigned int len, u8 rdt)
 	return -ENOENT;
 }
 EXPORT_SYMBOL_GPL(pci_vpd_find_tag);
+
+int pci_vpd_find_info_keyword(const u8 *buf, unsigned int off,
+			      unsigned int len, const char *kw)
+{
+	int i;
+
+	for (i = off; i + PCI_VPD_INFO_FLD_HDR_SIZE <= off + len;) {
+		if (buf[i + 0] == kw[0] &&
+		    buf[i + 1] == kw[1])
+			return i;
+
+		i += PCI_VPD_INFO_FLD_HDR_SIZE +
+		     pci_vpd_info_field_size(&buf[i]);
+	}
+
+	return -ENOENT;
+}
+EXPORT_SYMBOL_GPL(pci_vpd_find_info_keyword);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index ead2492..7a7c7c3 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1364,6 +1364,10 @@ void pci_request_acs(void);
 
 #define PCI_VPD_INFO_FLD_HDR_SIZE	3
 
+#define PCI_VPD_RO_KEYWORD_PARTNO	"PN"
+#define PCI_VPD_RO_KEYWORD_MFR_ID	"MN"
+#define PCI_VPD_RO_KEYWORD_VENDOR0	"V0"
+
 /**
  * pci_vpd_lrdt_size - Extracts the Large Resource Data Type length
  * @lrdt: Pointer to the beginning of the Large Resource Data Type tag
@@ -1409,5 +1413,18 @@ static inline u8 pci_vpd_info_field_size(const u8 *info_field)
  */
 int pci_vpd_find_tag(const u8 *buf, unsigned int off, unsigned int len, u8 rdt);
 
+/**
+ * pci_vpd_find_info_keyword - Locates an information field keyword in the VPD
+ * @buf: Pointer to buffered vpd data
+ * @off: The offset into the buffer at which to begin the search
+ * @len: The length of the buffer area, relative to off, in which to search
+ * @kw: The keyword to search for
+ *
+ * Returns the index where the information field keyword was found or
+ * -ENOENT otherwise.
+ */
+int pci_vpd_find_info_keyword(const u8 *buf, unsigned int off,
+			      unsigned int len, const char *kw);
+
 #endif /* __KERNEL__ */
 #endif /* LINUX_PCI_H */
-- 
1.6.4.4


