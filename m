From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v4 net-next 2/6] bnx2x: fix byte-by-byte nvram write for
 BE machines
Date: Mon, 22 Apr 2013 16:48:07 +0300
Message-ID: <1366638491-27184-3-git-send-email-dmitry@broadcom.com>
References: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romieu@fz.zoreil.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3995 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751771Ab3DVNs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 09:48:27 -0400
In-Reply-To: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Francious Romieu <romieu@fz.zoreil.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index f04eddf..8ae51f9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1569,9 +1569,8 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 			      int buf_size)
 {
 	int rc;
-	u32 cmd_flags;
-	u32 align_offset;
-	__be32 val;
+	u32 cmd_flags, align_offset, val;
+	__be32 val_be;
 
 	if (offset + buf_size > bp->common.flash_size) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
@@ -1590,16 +1589,16 @@ static int bnx2x_nvram_write1(struct bnx2x *bp, u32 offset, u8 *data_buf,
 
 	cmd_flags = (MCPR_NVM_COMMAND_FIRST | MCPR_NVM_COMMAND_LAST);
 	align_offset = (offset & ~0x03);
-	rc = bnx2x_nvram_read_dword(bp, align_offset, &val, cmd_flags);
+	rc = bnx2x_nvram_read_dword(bp, align_offset, &val_be, cmd_flags);
 
 	if (rc == 0) {
-		val &= ~(0xff << BYTE_OFFSET(offset));
-		val |= (*data_buf << BYTE_OFFSET(offset));
-
 		/* nvram data is returned as an array of bytes
 		 * convert it back to cpu order
 		 */
-		val = be32_to_cpu(val);
+		val = be32_to_cpu(val_be);
+
+		val &= ~le32_to_cpu(0xff << BYTE_OFFSET(offset));
+		val |= le32_to_cpu(*data_buf << BYTE_OFFSET(offset));
 
 		rc = bnx2x_nvram_write_dword(bp, align_offset, val,
 					     cmd_flags);
-- 
1.8.1.4
