From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 06/12] tg3: Prepare FW version code for VPD
 versioning
Date: Mon, 5 Apr 2010 13:19:24 -0700
Message-ID: <1270498770-23765-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2522 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756498Ab0DEUTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 16:19:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code that extracts the firmware version from the device's NVRAM
assumes the firmware version member is a clean slate.  The following
patch will add code to extract the firmware version from the VPD area
of NVRAM, so this assumption will no longer be true.  This patch adjusts
the versioning code to respect the VPD version if it exists.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   39 +++++++++++++++++++++++----------------
 1 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4d96d2d..5d65513 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12685,7 +12685,7 @@ static int __devinit tg3_fw_img_is_valid(struct tg3 *tp, u32 offset)
 static void __devinit tg3_read_bc_ver(struct tg3 *tp)
 {
 	u32 val, offset, start, ver_offset;
-	int i;
+	int i, dst_off;
 	bool newver = false;
 
 	if (tg3_nvram_read(tp, 0xc, &offset) ||
@@ -12705,8 +12705,11 @@ static void __devinit tg3_read_bc_ver(struct tg3 *tp)
 			newver = true;
 	}
 
+	dst_off = strlen(tp->fw_ver);
+
 	if (newver) {
-		if (tg3_nvram_read(tp, offset + 8, &ver_offset))
+		if (TG3_VER_SIZE - dst_off < 16 ||
+		    tg3_nvram_read(tp, offset + 8, &ver_offset))
 			return;
 
 		offset = offset + ver_offset - start;
@@ -12715,7 +12718,7 @@ static void __devinit tg3_read_bc_ver(struct tg3 *tp)
 			if (tg3_nvram_read_be32(tp, offset + i, &v))
 				return;
 
-			memcpy(tp->fw_ver + i, &v, sizeof(v));
+			memcpy(tp->fw_ver + dst_off + i, &v, sizeof(v));
 		}
 	} else {
 		u32 major, minor;
@@ -12726,7 +12729,8 @@ static void __devinit tg3_read_bc_ver(struct tg3 *tp)
 		major = (ver_offset & TG3_NVM_BCVER_MAJMSK) >>
 			TG3_NVM_BCVER_MAJSFT;
 		minor = ver_offset & TG3_NVM_BCVER_MINMSK;
-		snprintf(&tp->fw_ver[0], 32, "v%d.%02d", major, minor);
+		snprintf(&tp->fw_ver[dst_off], TG3_VER_SIZE - dst_off,
+			 "v%d.%02d", major, minor);
 	}
 }
 
@@ -12750,9 +12754,7 @@ static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
 {
 	u32 offset, major, minor, build;
 
-	tp->fw_ver[0] = 's';
-	tp->fw_ver[1] = 'b';
-	tp->fw_ver[2] = '\0';
+	strncat(tp->fw_ver, "sb", TG3_VER_SIZE - strlen(tp->fw_ver) - 1);
 
 	if ((val & TG3_EEPROM_SB_FORMAT_MASK) != TG3_EEPROM_SB_FORMAT_1)
 		return;
@@ -12789,11 +12791,14 @@ static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
 	if (minor > 99 || build > 26)
 		return;
 
-	snprintf(&tp->fw_ver[2], 30, " v%d.%02d", major, minor);
+	offset = strlen(tp->fw_ver);
+	snprintf(&tp->fw_ver[offset], TG3_VER_SIZE - offset,
+		 " v%d.%02d", major, minor);
 
 	if (build > 0) {
-		tp->fw_ver[8] = 'a' + build - 1;
-		tp->fw_ver[9] = '\0';
+		offset = strlen(tp->fw_ver);
+		if (offset < TG3_VER_SIZE - 1)
+			tp->fw_ver[offset] = 'a' + build - 1;
 	}
 }
 
@@ -12880,12 +12885,13 @@ static void __devinit tg3_read_dash_ver(struct tg3 *tp)
 static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 {
 	u32 val;
+	bool vpd_vers = false;
 
-	if (tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) {
-		tp->fw_ver[0] = 's';
-		tp->fw_ver[1] = 'b';
-		tp->fw_ver[2] = '\0';
+	if (tp->fw_ver[0] != 0)
+		vpd_vers = true;
 
+	if (tp->tg3_flags3 & TG3_FLG3_NO_NVRAM) {
+		strcat(tp->fw_ver, "sb");
 		return;
 	}
 
@@ -12902,11 +12908,12 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 		return;
 
 	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF) ||
-	     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE))
-		return;
+	     (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) || vpd_vers)
+		goto done;
 
 	tg3_read_mgmtfw_ver(tp);
 
+done:
 	tp->fw_ver[TG3_VER_SIZE - 1] = 0;
 }
 
-- 
1.6.4.4


