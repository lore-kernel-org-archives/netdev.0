From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/7] pci: Add VPD information field helper functions
Date: Thu, 25 Feb 2010 10:19:19 -0800
Message-ID: <1267121962-6077-5-git-send-email-mcarlson@broadcom.com>
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
 drivers/net/bnx2.c      |   11 ++++++-----
 drivers/net/tg3.c       |    7 ++++---
 include/linux/pci-vpd.h |    6 ++++++
 3 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2de3576..c3e5182 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7775,14 +7775,15 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
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
 
@@ -7791,9 +7792,9 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
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
index eaf178b..500a145 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12498,9 +12498,9 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
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
@@ -12511,7 +12511,8 @@ static void __devinit tg3_read_partno(struct tg3 *tp)
 				/* Success. */
 				return;
 			}
-			i += 3 + vpd_data[i + 2];
+			i += PCI_VPD_INFO_FLD_HDR_SIZE +
+			     pci_vpd_info_field_size(&vpd_data[i]);
 		}
 
 		/* Part number not found. */
diff --git a/include/linux/pci-vpd.h b/include/linux/pci-vpd.h
index 04eb87e..ebde9b9 100644
--- a/include/linux/pci-vpd.h
+++ b/include/linux/pci-vpd.h
@@ -38,6 +38,7 @@
 
 #define PCI_VPD_LRDT_TAG_SIZE		3
 #define PCI_VPD_SRDT_TAG_SIZE		1
+#define PCI_VPD_INFO_FLD_HDR_SIZE	3
 
 static inline u16 pci_vpd_lrdt_size(u8 *lrdt)
 {
@@ -51,4 +52,9 @@ static inline u8 pci_vpd_srdt_size(u8 *srdt)
 
 int pci_vpd_find_tag(u8 *data, unsigned int start, unsigned int len, u8 tagid);
 
+static inline u8 pci_vpd_info_field_size(u8 *info_field)
+{
+	return info_field[2];
+}
+
 #endif /* LINUX_PCI_VPD_H */
-- 
1.6.4.4
