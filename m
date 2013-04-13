From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 1/4] bnx2x: refactor nvram read procedure
Date: Sat, 13 Apr 2013 11:56:48 +0300
Message-ID: <1365843411-27103-2-git-send-email-dmitry@broadcom.com>
References: <1365843411-27103-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2863 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751871Ab3DMI4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 04:56:47 -0400
In-Reply-To: <1365843411-27103-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduce a parameter to allow nvram read to return
data in BE or cpu order.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   53 +++++++++-----------
 1 files changed, 24 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 129d6b2..900c0d7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1261,11 +1261,12 @@ static void bnx2x_disable_nvram_access(struct bnx2x *bp)
 			MCPR_NVM_ACCESS_ENABLE_WR_EN)));
 }
 
-static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, __be32 *ret_val,
-				  u32 cmd_flags)
+static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, u32 *ret_val,
+				  u32 cmd_flags, bool to_be)
 {
 	int count, i, rc;
 	u32 val;
+	__be32 *be_val = (__be32 *)ret_val;
 
 	/* build the command word */
 	cmd_flags |= MCPR_NVM_COMMAND_DOIT;
@@ -1295,10 +1296,14 @@ static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, __be32 *ret_val,
 		if (val & MCPR_NVM_COMMAND_DONE) {
 			val = REG_RD(bp, MCP_REG_MCPR_NVM_READ);
 			/* we read nvram data in cpu order
-			 * but ethtool sees it as an array of bytes
+			 * but ethtool uses it as an array of bytes
 			 * converting to big-endian will do the work
+			 * if requested.
 			 */
-			*ret_val = cpu_to_be32(val);
+			if (to_be)
+				*be_val = cpu_to_be32(val);
+			else
+				*ret_val = val;
 			rc = 0;
 			break;
 		}
@@ -1310,11 +1315,10 @@ static int bnx2x_nvram_read_dword(struct bnx2x *bp, u32 offset, __be32 *ret_val,
 }
 
 static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
-			    int buf_size)
+			    int buf_size, bool to_be)
 {
 	int rc;
-	u32 cmd_flags;
-	__be32 val;
+	u32 cmd_flags, val;
 
 	if ((offset & 0x03) || (buf_size & 0x03) || (buf_size == 0)) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
@@ -1341,7 +1345,7 @@ static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
 	/* read the first word(s) */
 	cmd_flags = MCPR_NVM_COMMAND_FIRST;
 	while ((buf_size > sizeof(u32)) && (rc == 0)) {
-		rc = bnx2x_nvram_read_dword(bp, offset, &val, cmd_flags);
+		rc = bnx2x_nvram_read_dword(bp, offset, &val, cmd_flags, to_be);
 		memcpy(ret_buf, &val, 4);
 
 		/* advance to the next dword */
@@ -1353,7 +1357,7 @@ static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
 
 	if (rc == 0) {
 		cmd_flags |= MCPR_NVM_COMMAND_LAST;
-		rc = bnx2x_nvram_read_dword(bp, offset, &val, cmd_flags);
+		rc = bnx2x_nvram_read_dword(bp, offset, &val, cmd_flags, to_be);
 		memcpy(ret_buf, &val, 4);
 	}
 
@@ -1383,7 +1387,7 @@ static int bnx2x_get_eeprom(struct net_device *dev,
 
 	/* parameters already validated in ethtool_get_eeprom */
 
-	rc = bnx2x_nvram_read(bp, eeprom->offset, eebuf, eeprom->len);
+	rc = bnx2x_nvram_read(bp, eeprom->offset, eebuf, eeprom->len, true);
 
 	return rc;
 }
@@ -1552,9 +1556,7 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 			      int buf_size)
 {
 	int rc;
-	u32 cmd_flags;
-	u32 align_offset;
-	__be32 val;
+	u32 cmd_flags, align_offset, val;
 
 	if (offset + buf_size > bp->common.flash_size) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
@@ -1573,16 +1575,11 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 
 	cmd_flags = (MCPR_NVM_COMMAND_FIRST | MCPR_NVM_COMMAND_LAST);
 	align_offset = (offset & ~0x03);
-	rc = bnx2x_nvram_read_dword(bp, align_offset, &val, cmd_flags);
+	rc = bnx2x_nvram_read_dword(bp, align_offset, &val, cmd_flags, false);
 
 	if (rc == 0) {
-		val &= ~(0xff << BYTE_OFFSET(offset));
-		val |= (*data_buf << BYTE_OFFSET(offset));
-
-		/* nvram data is returned as an array of bytes
-		 * convert it back to cpu order
-		 */
-		val = be32_to_cpu(val);
+		val &= ~le32_to_cpu(0xff << BYTE_OFFSET(offset));
+		val |= le32_to_cpu(*data_buf << BYTE_OFFSET(offset));
 
 		rc = bnx2x_nvram_write_dword(bp, align_offset, val,
 					     cmd_flags);
@@ -2598,8 +2595,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 		{ 0x708,  0x70 }, /* manuf_key_info */
 		{     0,     0 }
 	};
-	__be32 *buf;
-	u8 *data;
+	u8 *buf;
 	int i, rc;
 	u32 magic, crc;
 
@@ -2612,16 +2608,15 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 		rc = -ENOMEM;
 		goto test_nvram_exit;
 	}
-	data = (u8 *)buf;
 
-	rc = bnx2x_nvram_read(bp, 0, data, 4);
+	rc = bnx2x_nvram_read(bp, 0, buf, 4, false);
 	if (rc) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
 		   "magic value read (rc %d)\n", rc);
 		goto test_nvram_exit;
 	}
 
-	magic = be32_to_cpu(buf[0]);
+	magic = *(u32 *)(buf);
 	if (magic != 0x669955aa) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
 		   "wrong magic value (0x%08x)\n", magic);
@@ -2631,15 +2626,15 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 
 	for (i = 0; nvram_tbl[i].size; i++) {
 
-		rc = bnx2x_nvram_read(bp, nvram_tbl[i].offset, data,
-				      nvram_tbl[i].size);
+		rc = bnx2x_nvram_read(bp, nvram_tbl[i].offset, buf,
+				      nvram_tbl[i].size, true);
 		if (rc) {
 			DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
 			   "nvram_tbl[%d] read data (rc %d)\n", i, rc);
 			goto test_nvram_exit;
 		}
 
-		crc = ether_crc_le(nvram_tbl[i].size, data);
+		crc = ether_crc_le(nvram_tbl[i].size, buf);
 		if (crc != CRC32_RESIDUAL) {
 			DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
 			   "nvram_tbl[%d] wrong crc value (0x%08x)\n", i, crc);
-- 
1.7.7.2
