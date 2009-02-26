From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 10/14] tg3: Add legacy bootcode version decoding
Date: Wed, 25 Feb 2009 16:26:58 -0800
Message-ID: <1235616377.16022@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1837 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753709AbZBZCqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to obtain the bootcode version for versions
of bootcode that do not use the new method.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   39 +++++++++++++++++++++++++++++++--------
 drivers/net/tg3.h |    4 ++++
 2 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2e83755..43859e4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11463,8 +11463,9 @@ static int __devinit tg3_fw_img_is_valid(struct tg3 *tp, u32 offset)
 
 static void __devinit tg3_read_bc_ver(struct tg3 *tp)
 {
-	u32 offset, start, ver_offset;
+	u32 val, offset, start, ver_offset;
 	int i;
+	bool newver = false;
 
 	if (tg3_nvram_read(tp, 0xc, &offset) ||
 	    tg3_nvram_read(tp, 0x4, &start))
@@ -11472,17 +11473,39 @@ static void __devinit tg3_read_bc_ver(struct tg3 *tp)
 
 	offset = tg3_nvram_logical_addr(tp, offset);
 
-	if (!tg3_fw_img_is_valid(tp, offset) ||
-	    tg3_nvram_read(tp, offset + 8, &ver_offset))
+	if (tg3_nvram_read(tp, offset, &val))
 		return;
 
-	offset = offset + ver_offset - start;
-	for (i = 0; i < 16; i += 4) {
-		__be32 v;
-		if (tg3_nvram_read_be32(tp, offset + i, &v))
+	if ((val & 0xfc000000) == 0x0c000000) {
+		if (tg3_nvram_read(tp, offset + 4, &val))
+			return;
+
+		if (val == 0)
+			newver = true;
+	}
+
+	if (newver) {
+		if (tg3_nvram_read(tp, offset + 8, &ver_offset))
+			return;
+
+		offset = offset + ver_offset - start;
+		for (i = 0; i < 16; i += 4) {
+			__be32 v;
+			if (tg3_nvram_read_be32(tp, offset + i, &v))
+				return;
+
+			memcpy(tp->fw_ver + i, &v, sizeof(v));
+		}
+	} else {
+		u32 major, minor;
+
+		if (tg3_nvram_read(tp, TG3_NVM_PTREV_BCVER, &ver_offset))
 			return;
 
-		memcpy(tp->fw_ver + i, &v, sizeof(v));
+		major = (ver_offset & TG3_NVM_BCVER_MAJMSK) >>
+			TG3_NVM_BCVER_MAJSFT;
+		minor = ver_offset & TG3_NVM_BCVER_MINMSK;
+		snprintf(&tp->fw_ver[0], 32, "v%d.%02d", major, minor);
 	}
 }
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 508def3..34dfaaa 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1737,6 +1737,10 @@
 #define TG3_NVM_DIRENT_SIZE		0xc
 #define TG3_NVM_DIRTYPE_SHIFT		24
 #define TG3_NVM_DIRTYPE_ASFINI		1
+#define TG3_NVM_PTREV_BCVER		0x94
+#define TG3_NVM_BCVER_MAJMSK		0x0000ff00
+#define TG3_NVM_BCVER_MAJSFT		8
+#define TG3_NVM_BCVER_MINMSK		0x000000ff
 
 #define TG3_EEPROM_SB_F1R0_EDH_OFF	0x10
 #define TG3_EEPROM_SB_F1R2_EDH_OFF	0x14
-- 
1.6.0.6


