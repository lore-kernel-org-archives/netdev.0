From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 09/14] tg3: Refactor firmware version routines
Date: Wed, 25 Feb 2009 16:26:33 -0800
Message-ID: <1235616376.16019@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3026 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753918AbZBZCq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reorganizes the firmware version routines in preparation for
the following patches.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   98 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 55 insertions(+), 43 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9453918..2e83755 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11461,6 +11461,31 @@ static int __devinit tg3_fw_img_is_valid(struct tg3 *tp, u32 offset)
 	return 1;
 }
 
+static void __devinit tg3_read_bc_ver(struct tg3 *tp)
+{
+	u32 offset, start, ver_offset;
+	int i;
+
+	if (tg3_nvram_read(tp, 0xc, &offset) ||
+	    tg3_nvram_read(tp, 0x4, &start))
+		return;
+
+	offset = tg3_nvram_logical_addr(tp, offset);
+
+	if (!tg3_fw_img_is_valid(tp, offset) ||
+	    tg3_nvram_read(tp, offset + 8, &ver_offset))
+		return;
+
+	offset = offset + ver_offset - start;
+	for (i = 0; i < 16; i += 4) {
+		__be32 v;
+		if (tg3_nvram_read_be32(tp, offset + i, &v))
+			return;
+
+		memcpy(tp->fw_ver + i, &v, sizeof(v));
+	}
+}
+
 static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
 {
 	u32 offset, major, minor, build;
@@ -11506,44 +11531,10 @@ static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
 	}
 }
 
-static void __devinit tg3_read_fw_ver(struct tg3 *tp)
+static void __devinit tg3_read_mgmtfw_ver(struct tg3 *tp)
 {
 	u32 val, offset, start;
-	u32 ver_offset;
-	int i, bcnt;
-
-	if (tg3_nvram_read(tp, 0, &val))
-		return;
-
-	if (val != TG3_EEPROM_MAGIC) {
-		if ((val & TG3_EEPROM_MAGIC_FW_MSK) == TG3_EEPROM_MAGIC_FW)
-			tg3_read_sb_ver(tp, val);
-
-		return;
-	}
-
-	if (tg3_nvram_read(tp, 0xc, &offset) ||
-	    tg3_nvram_read(tp, 0x4, &start))
-		return;
-
-	offset = tg3_nvram_logical_addr(tp, offset);
-
-	if (!tg3_fw_img_is_valid(tp, offset) ||
-	    tg3_nvram_read(tp, offset + 8, &ver_offset))
-		return;
-
-	offset = offset + ver_offset - start;
-	for (i = 0; i < 16; i += 4) {
-		__be32 v;
-		if (tg3_nvram_read_be32(tp, offset + i, &v))
-			return;
-
-		memcpy(tp->fw_ver + i, &v, 4);
-	}
-
-	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
-	     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
-		return;
+	int i, vlen;
 
 	for (offset = TG3_NVM_DIR_START;
 	     offset < TG3_NVM_DIR_END;
@@ -11570,10 +11561,10 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 
 	offset += val - start;
 
-	bcnt = strlen(tp->fw_ver);
+	vlen = strlen(tp->fw_ver);
 
-	tp->fw_ver[bcnt++] = ',';
-	tp->fw_ver[bcnt++] = ' ';
+	tp->fw_ver[vlen++] = ',';
+	tp->fw_ver[vlen++] = ' ';
 
 	for (i = 0; i < 4; i++) {
 		__be32 v;
@@ -11582,14 +11573,35 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 
 		offset += sizeof(v);
 
-		if (bcnt > TG3_VER_SIZE - sizeof(v)) {
-			memcpy(&tp->fw_ver[bcnt], &v, TG3_VER_SIZE - bcnt);
+		if (vlen > TG3_VER_SIZE - sizeof(v)) {
+			memcpy(&tp->fw_ver[vlen], &v, TG3_VER_SIZE - vlen);
 			break;
 		}
 
-		memcpy(&tp->fw_ver[bcnt], &v, sizeof(v));
-		bcnt += sizeof(v);
+		memcpy(&tp->fw_ver[vlen], &v, sizeof(v));
+		vlen += sizeof(v);
 	}
+}
+
+static void __devinit tg3_read_fw_ver(struct tg3 *tp)
+{
+	u32 val;
+
+	if (tg3_nvram_read(tp, 0, &val))
+		return;
+
+	if (val == TG3_EEPROM_MAGIC)
+		tg3_read_bc_ver(tp);
+	else if ((val & TG3_EEPROM_MAGIC_FW_MSK) == TG3_EEPROM_MAGIC_FW)
+		tg3_read_sb_ver(tp, val);
+	else
+		return;
+
+	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
+	     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
+		return;
+
+	tg3_read_mgmtfw_ver(tp);
 
 	tp->fw_ver[TG3_VER_SIZE - 1] = 0;
 }
-- 
1.6.0.6


