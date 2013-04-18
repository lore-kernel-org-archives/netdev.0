From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v2 net-next 2/4] bnx2x: add additional regions for CRC
 memory test
Date: Thu, 18 Apr 2013 13:27:08 +0300
Message-ID: <1366280830-26034-3-git-send-email-dmitry@broadcom.com>
References: <1366280830-26034-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2452 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965815Ab3DRK1x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 06:27:53 -0400
In-Reply-To: <1366280830-26034-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

a. Common tree of `dir` structures.
b. Multi-port devices structures.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |   7 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    | 171 ++++++++++++++++++---
 2 files changed, 155 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index c630342..87629fd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -850,6 +850,9 @@ struct bnx2x_common {
 #define CHIP_IS_57840_VF(bp)		(CHIP_NUM(bp) == CHIP_NUM_57840_VF)
 #define CHIP_IS_E1H(bp)			(CHIP_IS_57711(bp) || \
 					 CHIP_IS_57711E(bp))
+#define CHIP_IS_57811xx(bp)		(CHIP_IS_57811(bp) || \
+					 CHIP_IS_57811_MF(bp) || \
+					 CHIP_IS_57811_VF(bp))
 #define CHIP_IS_E2(bp)			(CHIP_IS_57712(bp) || \
 					 CHIP_IS_57712_MF(bp) || \
 					 CHIP_IS_57712_VF(bp))
@@ -859,9 +862,7 @@ struct bnx2x_common {
 					 CHIP_IS_57810(bp) || \
 					 CHIP_IS_57810_MF(bp) || \
 					 CHIP_IS_57810_VF(bp) || \
-					 CHIP_IS_57811(bp) || \
-					 CHIP_IS_57811_MF(bp) || \
-					 CHIP_IS_57811_VF(bp) || \
+					 CHIP_IS_57811xx(bp) || \
 					 CHIP_IS_57840(bp) || \
 					 CHIP_IS_57840_MF(bp) || \
 					 CHIP_IS_57840_VF(bp))
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index e7e0ac1..65ac870 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2593,14 +2593,138 @@ static int bnx2x_test_ext_loopback(struct bnx2x *bp)
 	return rc;
 }
 
+struct code_entry {
+	u32 sram_start_addr;
+	u32 code_attribute;
+#define CODE_IMAGE_TYPE_MASK			0xf0800003
+#define CODE_IMAGE_VNTAG_PROFILES_DATA		0xd0000003
+#define CODE_IMAGE_LENGTH_MASK			0x007ffffc
+#define CODE_IMAGE_TYPE_EXTENDED_DIR		0xe0000000
+	u32 nvm_start_addr;
+};
+
+#define CODE_ENTRY_MAX			16
+#define CODE_ENTRY_EXTENDED_DIR_IDX	15
+#define MAX_IMAGES_IN_EXTENDED_DIR	64
+
 #define CRC32_RESIDUAL			0xdebb20e3
+#define CRC_BUFF_SIZE			256
+
+static int bnx2x_nvram_crc(struct bnx2x *bp,
+			   int offset,
+			   int size,
+			   u8 *buff)
+{
+	u32 crc = ~0;
+	int done = 0;
+
+	DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
+	   "NVRAM CRC from 0x%08x to 0x%08x\n", offset, offset + size);
+
+	while (done < size) {
+		int count = min_t(int, size - done, CRC_BUFF_SIZE);
+
+		if (bnx2x_nvram_read(bp, offset + done, buff, count))
+			return -EIO;
+		crc = crc32_le(crc, buff, count);
+		done += count;
+	}
+
+	if (crc != CRC32_RESIDUAL)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int bnx2x_test_nvram_dir(struct bnx2x *bp,
+				struct code_entry *entry,
+				u8 *buff)
+{
+	size_t size = entry->code_attribute & CODE_IMAGE_LENGTH_MASK;
+	u32 type = entry->code_attribute & CODE_IMAGE_TYPE_MASK;
+	int rc = 0;
+
+	/* Zero-length images and AFEX profiles do not have CRC */
+	if (size == 0 || type == CODE_IMAGE_VNTAG_PROFILES_DATA)
+		return 0;
+
+	rc = bnx2x_nvram_crc(bp, entry->nvm_start_addr, size, buff);
+	if (rc == -EIO)
+		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
+		   "Unable to read image %x\n", type);
+	else if (rc)
+		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
+		   "image %x has wrong crc value\n", type);
+
+	return rc;
+}
+
+static int bnx2x_test_nvram_dirs(struct bnx2x *bp, u8 *buff)
+{
+	u32 res = 0, ext_cnt, dir_offset = 0x14;
+	struct code_entry entry;
+	int i;
+
+	DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM, "NVRAM DIRS CRC test-set\n");
+
+	for (i = 0; i < CODE_ENTRY_EXTENDED_DIR_IDX; i++) {
+		bnx2x_nvram_read32(bp, dir_offset + sizeof(entry) * i,
+				   (u32 *)&entry, sizeof(entry));
+		res |= bnx2x_test_nvram_dir(bp, &entry, buff);
+	}
+
+	bnx2x_nvram_read32(bp, dir_offset +
+			       sizeof(entry) * CODE_ENTRY_EXTENDED_DIR_IDX,
+			   (u32 *)&entry, sizeof(entry));
+	if ((entry.code_attribute & CODE_IMAGE_TYPE_MASK)
+		!= CODE_IMAGE_TYPE_EXTENDED_DIR ||
+	    (entry.code_attribute & CODE_IMAGE_LENGTH_MASK) == 0)
+		return res;
+
+	/* handle extended dir */
+	bnx2x_nvram_read32(bp, entry.nvm_start_addr, (u32 *)&ext_cnt,
+			   sizeof(u32));
+
+	dir_offset = entry.nvm_start_addr + 8;
+	for (i = 0; i < ext_cnt && i < MAX_IMAGES_IN_EXTENDED_DIR; i++) {
+		bnx2x_nvram_read32(bp, dir_offset + sizeof(entry) * i,
+				   (u32 *)&entry, sizeof(entry));
+		res |= bnx2x_test_nvram_dir(bp, &entry, buff);
+	}
+
+	return res;
+}
+
+struct crc_pair {
+	int offset;
+	int size;
+};
+
+static int bnx2x_test_nvram_tbl(struct bnx2x *bp,
+				const struct crc_pair *nvram_tbl, u8 *buf)
+{
+	int i;
+
+	for (i = 0; nvram_tbl[i].size; i++) {
+		int res = bnx2x_nvram_crc(bp, nvram_tbl[i].offset,
+					  nvram_tbl[i].size, buf);
+		if (res == -EIO) {
+			DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
+			   "nvram_tbl[%d] unable to read section\n", i);
+			return -EINVAL;
+		} else if (res) {
+			DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
+			   "nvram_tbl[%d] wrong crc value\n", i);
+			return -ENODEV;
+		}
+	}
+
+	return 0;
+}
 
 static int bnx2x_test_nvram(struct bnx2x *bp)
 {
-	static const struct {
-		int offset;
-		int size;
-	} nvram_tbl[] = {
+	const struct crc_pair nvram_tbl[] = {
 		{     0,  0x14 }, /* bootstrap */
 		{  0x14,  0xec }, /* dir */
 		{ 0x100, 0x350 }, /* manuf_info */
@@ -2609,14 +2733,20 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 		{ 0x708,  0x70 }, /* manuf_key_info */
 		{     0,     0 }
 	};
+	const struct crc_pair nvram_tbl2[] = {
+		{ 0x7e8, 0x350 }, /* manuf_info2 */
+		{ 0xb38,  0xf0 }, /* feature_info */
+		{     0,     0 }
+	};
+
 	u8 *buf;
-	int i, rc;
-	u32 magic, crc;
+	int rc;
+	u32 magic;
 
 	if (BP_NOMCP(bp))
 		return 0;
 
-	buf = kmalloc(0x350, GFP_KERNEL);
+	buf = kmalloc(CRC_BUFF_SIZE, GFP_KERNEL);
 	if (!buf) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM, "kmalloc failed\n");
 		rc = -ENOMEM;
@@ -2637,25 +2767,26 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 		goto test_nvram_exit;
 	}
 
-	for (i = 0; nvram_tbl[i].size; i++) {
+	DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM, "Port 0 CRC test-set\n");
+	rc = bnx2x_test_nvram_tbl(bp, nvram_tbl, buf);
+	if (rc)
+		goto test_nvram_exit;
 
-		rc = bnx2x_nvram_read(bp, nvram_tbl[i].offset, buf,
-				      nvram_tbl[i].size);
-		if (rc) {
-			DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
-			   "nvram_tbl[%d] read data (rc %d)\n", i, rc);
-			goto test_nvram_exit;
-		}
+	if (!CHIP_IS_E1x(bp) && !CHIP_IS_57811xx(bp)) {
+		u32 hide = SHMEM_RD(bp, dev_info.shared_hw_config.config2) &
+			   SHARED_HW_CFG_HIDE_PORT1;
 
-		crc = ether_crc_le(nvram_tbl[i].size, buf);
-		if (crc != CRC32_RESIDUAL) {
+		if (!hide) {
 			DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
-			   "nvram_tbl[%d] wrong crc value (0x%08x)\n", i, crc);
-			rc = -ENODEV;
-			goto test_nvram_exit;
+			   "Port 1 CRC test-set\n");
+			rc = bnx2x_test_nvram_tbl(bp, nvram_tbl2, buf);
+			if (rc)
+				goto test_nvram_exit;
 		}
 	}
 
+	rc = bnx2x_test_nvram_dirs(bp, buf);
+
 test_nvram_exit:
 	kfree(buf);
 	return rc;
-- 
1.8.1.4
