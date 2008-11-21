From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 05/10] tg3: Extract FW ver from alt NVRAM formats
Date: Fri, 21 Nov 2008 11:01:34 -0800
Message-ID: <1227295576.5620@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4671 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026AbYKUT0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:26:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extracts the bootcode firmware version from the alternate
selfboot patch NVRAM format.  This format is used on the 5784, 5761 and
some newer devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/tg3.h |   11 +++++++++++
 2 files changed, 61 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6972fe5..2b70b0f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11951,6 +11951,51 @@ static int __devinit tg3_fw_img_is_valid(struct tg3 *tp, u32 offset)
 	return 1;
 }
 
+static void __devinit tg3_read_sb_ver(struct tg3 *tp, u32 val)
+{
+	u32 offset, major, minor, build;
+
+	tp->fw_ver[0] = 's';
+	tp->fw_ver[1] = 'b';
+	tp->fw_ver[2] = '\0';
+
+	if ((val & TG3_EEPROM_SB_FORMAT_MASK) != TG3_EEPROM_SB_FORMAT_1)
+		return;
+
+	switch (val & TG3_EEPROM_SB_REVISION_MASK) {
+	case TG3_EEPROM_SB_REVISION_0:
+		offset = TG3_EEPROM_SB_F1R0_EDH_OFF;
+		break;
+	case TG3_EEPROM_SB_REVISION_2:
+		offset = TG3_EEPROM_SB_F1R2_EDH_OFF;
+		break;
+	case TG3_EEPROM_SB_REVISION_3:
+		offset = TG3_EEPROM_SB_F1R3_EDH_OFF;
+		break;
+	default:
+		return;
+	}
+
+	if (tg3_nvram_read_swab(tp, offset, &val))
+		return;
+
+	build = (val & TG3_EEPROM_SB_EDH_BLD_MASK) >>
+		TG3_EEPROM_SB_EDH_BLD_SHFT;
+	major = (val & TG3_EEPROM_SB_EDH_MAJ_MASK) >>
+		TG3_EEPROM_SB_EDH_MAJ_SHFT;
+	minor =  val & TG3_EEPROM_SB_EDH_MIN_MASK;
+
+	if (minor > 99 || build > 26)
+		return;
+
+	snprintf(&tp->fw_ver[2], 30, " v%d.%02d", major, minor);
+
+	if (build > 0) {
+		tp->fw_ver[8] = 'a' + build - 1;
+		tp->fw_ver[9] = '\0';
+	}
+}
+
 static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 {
 	u32 val, offset, start;
@@ -11960,8 +12005,12 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 	if (tg3_nvram_read_swab(tp, 0, &val))
 		return;
 
-	if (val != TG3_EEPROM_MAGIC)
+	if (val != TG3_EEPROM_MAGIC) {
+		if ((val & TG3_EEPROM_MAGIC_FW_MSK) == TG3_EEPROM_MAGIC_FW)
+			tg3_read_sb_ver(tp, val);
+
 		return;
+	}
 
 	if (tg3_nvram_read_swab(tp, 0xc, &offset) ||
 	    tg3_nvram_read_swab(tp, 0x4, &start))
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index eba62e2..42f60ef 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1747,6 +1747,17 @@
 #define TG3_NVM_DIRTYPE_SHIFT		24
 #define TG3_NVM_DIRTYPE_ASFINI		1
 
+#define TG3_EEPROM_SB_F1R0_EDH_OFF	0x10
+#define TG3_EEPROM_SB_F1R2_EDH_OFF	0x14
+#define TG3_EEPROM_SB_F1R2_MBA_OFF	0x10
+#define TG3_EEPROM_SB_F1R3_EDH_OFF	0x18
+#define TG3_EEPROM_SB_EDH_MAJ_MASK	0x00000700
+#define TG3_EEPROM_SB_EDH_MAJ_SHFT	8
+#define TG3_EEPROM_SB_EDH_MIN_MASK	0x000000ff
+#define TG3_EEPROM_SB_EDH_BLD_MASK	0x0000f800
+#define TG3_EEPROM_SB_EDH_BLD_SHFT	11
+
+
 /* 32K Window into NIC internal memory */
 #define NIC_SRAM_WIN_BASE		0x00008000
 
-- 
1.5.6.4



