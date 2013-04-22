From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v4 net-next 1/6] bnx2x: refactor nvram read procedure
Date: Mon, 22 Apr 2013 16:48:06 +0300
Message-ID: <1366638491-27184-2-git-send-email-dmitry@broadcom.com>
References: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romieu@fz.zoreil.com, "Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2702 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683Ab3DVNsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 09:48:25 -0400
In-Reply-To: <1366638491-27184-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduce a procedure to read in u32 granularity.

CC: Francious Romieu <romieu@fz.zoreil.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    | 28 ++++++++++++++++------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 129d6b2..f04eddf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1364,6 +1364,23 @@ static int bnx2x_nvram_read(struct bnx2x *bp, u32 offset, u8 *ret_buf,
 	return rc;
 }
 
+static int bnx2x_nvram_read32(struct bnx2x *bp, u32 offset, u32 *buf,
+			      int buf_size)
+{
+	int rc;
+
+	rc = bnx2x_nvram_read(bp, offset, (u8 *)buf, buf_size);
+
+	if (!rc) {
+		__be32 *be = (__be32 *)buf;
+
+		while ((buf_size -= 4) >= 0)
+			*buf++ = be32_to_cpu(*be++);
+	}
+
+	return rc;
+}
+
 static int bnx2x_get_eeprom(struct net_device *dev,
 			    struct ethtool_eeprom *eeprom, u8 *eebuf)
 {
@@ -2598,8 +2615,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 		{ 0x708,  0x70 }, /* manuf_key_info */
 		{     0,     0 }
 	};
-	__be32 *buf;
-	u8 *data;
+	u8 *buf;
 	int i, rc;
 	u32 magic, crc;
 
@@ -2612,16 +2628,14 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 		rc = -ENOMEM;
 		goto test_nvram_exit;
 	}
-	data = (u8 *)buf;
 
-	rc = bnx2x_nvram_read(bp, 0, data, 4);
+	rc = bnx2x_nvram_read32(bp, 0, &magic, sizeof(magic));
 	if (rc) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
 		   "magic value read (rc %d)\n", rc);
 		goto test_nvram_exit;
 	}
 
-	magic = be32_to_cpu(buf[0]);
 	if (magic != 0x669955aa) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
 		   "wrong magic value (0x%08x)\n", magic);
@@ -2631,7 +2645,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 
 	for (i = 0; nvram_tbl[i].size; i++) {
 
-		rc = bnx2x_nvram_read(bp, nvram_tbl[i].offset, data,
+		rc = bnx2x_nvram_read(bp, nvram_tbl[i].offset, buf,
 				      nvram_tbl[i].size);
 		if (rc) {
 			DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
@@ -2639,7 +2653,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 			goto test_nvram_exit;
 		}
 
-		crc = ether_crc_le(nvram_tbl[i].size, data);
+		crc = ether_crc_le(nvram_tbl[i].size, buf);
 		if (crc != CRC32_RESIDUAL) {
 			DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
 			   "nvram_tbl[%d] wrong crc value (0x%08x)\n", i, crc);
-- 
1.8.1.4
