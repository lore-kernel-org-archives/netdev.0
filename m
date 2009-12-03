From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] bnx2: Refine VPD logic.
Date: Thu, 3 Dec 2009 15:07:36 -0800
Message-ID: <1259881656-6693-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1943 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754315AbZLCXAg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 18:00:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Replace magic values with constants
- Simplify length calculation and fix a bug

Based on valuable feedback from Ben Hutchings <bhutchings@solarflare.com>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   49 +++++++++++++++++++++----------------------------
 1 files changed, 21 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index cf4322d..4bfc808 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7730,24 +7730,27 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 	u8 *v0_str = NULL;
 	bool mn_match = false;
 
+#define BNX2_VPD_NVRAM_OFFSET	0x300
+#define BNX2_VPD_LEN		128
 #define BNX2_MAX_VER_SLEN	30
 
 	data = kmalloc(256, GFP_KERNEL);
 	if (!data)
 		return;
 
-	rc = bnx2_nvram_read(bp, 0x300, data + 128, 128);
+	rc = bnx2_nvram_read(bp, BNX2_VPD_NVRAM_OFFSET, data + BNX2_VPD_LEN,
+			     BNX2_VPD_LEN);
 	if (rc)
 		goto vpd_done;
 
-	for (i = 0; i < 128; i += 4) {
-		data[i] = data[i + 131];
-		data[i + 1] = data[i + 130];
-		data[i + 2] = data[i + 129];
-		data[i + 3] = data[i + 128];
+	for (i = 0; i < BNX2_VPD_LEN; i += 4) {
+		data[i] = data[i + BNX2_VPD_LEN + 3];
+		data[i + 1] = data[i + BNX2_VPD_LEN + 2];
+		data[i + 2] = data[i + BNX2_VPD_LEN + 1];
+		data[i + 3] = data[i + BNX2_VPD_LEN];
 	}
 
-	for (i = 0; i < 128; ) {
+	for (i = 0; i <= BNX2_VPD_LEN - 3; ) {
 		unsigned char val = data[i];
 		unsigned int block_end;
 
@@ -7762,39 +7765,29 @@ bnx2_read_vpd_fw_ver(struct bnx2 *bp)
 		block_end = (i + 3 + (data[i + 1] + (data[i + 2] << 8)));
 		i += 3;
 
-		if (block_end > 128)
+		if (block_end > BNX2_VPD_LEN)
 			goto vpd_done;
 
 		while (i < (block_end - 2)) {
-			if (data[i] == 'M' && data[i + 1] == 'N') {
-				int mn_len = data[i + 2];
+			int len = data[i + 2];
 
-				if (mn_len != 4)
-					goto vpd_done;
+			if (i + 3 + len > block_end)
+				goto vpd_done;
 
-				i += 3;
-				if (memcmp(&data[i], "1028", 4))
+			if (data[i] == 'M' && data[i + 1] == 'N') {
+				if (len != 4 ||
+				    memcmp(&data[i + 3], "1028", 4))
 					goto vpd_done;
 				mn_match = true;
-				i += 4;
 
 			} else if (data[i] == 'V' && data[i + 1] == '0') {
-				v0_len = data[i + 2];
-
-				i += 3;
-				if (v0_len > BNX2_MAX_VER_SLEN ||
-				    (v0_len + i) > 128)
+				if (len > BNX2_MAX_VER_SLEN)
 					goto vpd_done;
 
-				if (v0_len > BNX2_MAX_VER_SLEN)
-					v0_len = BNX2_MAX_VER_SLEN;
-
-				v0_str = &data[i];
-				i += data[i + 2];
-
-			} else {
-				i += 3 + data[i + 2];
+				v0_len = len;
+				v0_str = &data[i + 3];
 			}
+			i += 3 + len;
 
 			if (mn_match && v0_str) {
 				memcpy(bp->fw_version, v0_str, v0_len);
-- 
1.6.4.GIT


