From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/13] tg3: Fix nvram selftest failures
Date: Fri, 09 Nov 2007 16:38:49 -0800
Message-ID: <1194655129.5745.267.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2644 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753194AbXKJAjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Newer devices contain bootcode in the chip's private ROM area.  This
bootcode is called selfboot.  Selfboot can be patched in the device's
NVRAM and the patches can have several formats.  In one particular
format, the checksum calculation needs to be slightly modified.  This
patch adjusts the NVRAM test code for that case, and add support for the
missing formats.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b865c5d..ef849b1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8701,7 +8701,9 @@ static void tg3_get_ethtool_stats (struct net_device *dev,
 }
 
 #define NVRAM_TEST_SIZE 0x100
-#define NVRAM_SELFBOOT_FORMAT1_SIZE 0x14
+#define NVRAM_SELFBOOT_FORMAT1_0_SIZE	0x14
+#define NVRAM_SELFBOOT_FORMAT1_2_SIZE	0x18
+#define NVRAM_SELFBOOT_FORMAT1_3_SIZE	0x1c
 #define NVRAM_SELFBOOT_HW_SIZE 0x20
 #define NVRAM_SELFBOOT_DATA_SIZE 0x1c
 
@@ -8716,9 +8718,22 @@ static int tg3_test_nvram(struct tg3 *tp)
 	if (magic == TG3_EEPROM_MAGIC)
 		size = NVRAM_TEST_SIZE;
 	else if ((magic & TG3_EEPROM_MAGIC_FW_MSK) == TG3_EEPROM_MAGIC_FW) {
-		if ((magic & 0xe00000) == 0x200000)
-			size = NVRAM_SELFBOOT_FORMAT1_SIZE;
-		else
+		if ((magic & TG3_EEPROM_SB_FORMAT_MASK) ==
+		    TG3_EEPROM_SB_FORMAT_1) {
+			switch (magic & TG3_EEPROM_SB_REVISION_MASK) {
+			case TG3_EEPROM_SB_REVISION_0:
+				size = NVRAM_SELFBOOT_FORMAT1_0_SIZE;
+				break;
+			case TG3_EEPROM_SB_REVISION_2:
+				size = NVRAM_SELFBOOT_FORMAT1_2_SIZE;
+				break;
+			case TG3_EEPROM_SB_REVISION_3:
+				size = NVRAM_SELFBOOT_FORMAT1_3_SIZE;
+				break;
+			default:
+				return 0;
+			}
+		} else
 			return 0;
 	} else if ((magic & TG3_EEPROM_MAGIC_HW_MSK) == TG3_EEPROM_MAGIC_HW)
 		size = NVRAM_SELFBOOT_HW_SIZE;
@@ -8745,8 +8760,17 @@ static int tg3_test_nvram(struct tg3 *tp)
 	    TG3_EEPROM_MAGIC_FW) {
 		u8 *buf8 = (u8 *) buf, csum8 = 0;
 
-		for (i = 0; i < size; i++)
-			csum8 += buf8[i];
+		if ((cpu_to_be32(buf[0]) & TG3_EEPROM_SB_REVISION_MASK) ==
+		    TG3_EEPROM_SB_REVISION_2) {
+			/* For rev 2, the csum doesn't include the MBA. */
+			for (i = 0; i < TG3_EEPROM_SB_F1R2_MBA_OFF; i++)
+				csum8 += buf8[i];
+			for (i = TG3_EEPROM_SB_F1R2_MBA_OFF + 4; i < size; i++)
+				csum8 += buf8[i];
+		} else {
+			for (i = 0; i < size; i++)
+				csum8 += buf8[i];
+		}
 
 		if (csum8 == 0) {
 			err = 0;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index c6aad49..f715b35 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1555,6 +1555,12 @@
 #define TG3_EEPROM_MAGIC		0x669955aa
 #define TG3_EEPROM_MAGIC_FW		0xa5000000
 #define TG3_EEPROM_MAGIC_FW_MSK		0xff000000
+#define TG3_EEPROM_SB_FORMAT_MASK	0x00e00000
+#define TG3_EEPROM_SB_FORMAT_1		0x00200000
+#define TG3_EEPROM_SB_REVISION_MASK	0x001f0000
+#define TG3_EEPROM_SB_REVISION_0	0x00000000
+#define TG3_EEPROM_SB_REVISION_2	0x00020000
+#define TG3_EEPROM_SB_REVISION_3	0x00030000
 #define TG3_EEPROM_MAGIC_HW		0xabcd
 #define TG3_EEPROM_MAGIC_HW_MSK		0xffff
 
@@ -1765,6 +1771,8 @@
 /* APE convenience enumerations. */
 #define TG3_APE_LOCK_MEM                4
 
+#define TG3_EEPROM_SB_F1R2_MBA_OFF	0x10
+
 
 /* There are two ways to manage the TX descriptors on the tigon3.
  * Either the descriptors are in host DMA'able memory, or they


