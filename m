From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/11][TG3]: Improve NVRAM sizing.
Date: Fri, 04 May 2007 17:52:26 -0700
Message-ID: <1178326346.4859.18.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3589 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767923AbXEEAFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:05:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Improve NVRAM sizing.

This patch changes the NVRAM sizing procedure so that the driver can
take advantage of devices with 1:1 NVRAM strapping configurations.  This
is useful in cases where the traditional NVRAM sizing method fails.  In
the event that the flash size cannot be determined, the largest known
NVRAM size is used.  The patch also removes support for 5755 NVRAM
devices that are not supported by Broadcom and adds explicit sizing for
this device.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b8141be..c01bd86 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9286,7 +9286,7 @@ static void __devinit tg3_get_nvram_size(struct tg3 *tp)
 			return;
 		}
 	}
-	tp->nvram_size = 0x20000;
+	tp->nvram_size = 0x80000;
 }
 
 static void __devinit tg3_get_nvram_info(struct tg3 *tp)
@@ -9405,33 +9405,31 @@ static void __devinit tg3_get_5752_nvram_info(struct tg3 *tp)
 
 static void __devinit tg3_get_5755_nvram_info(struct tg3 *tp)
 {
-	u32 nvcfg1;
+	u32 nvcfg1, protect = 0;
 
 	nvcfg1 = tr32(NVRAM_CFG1);
 
 	/* NVRAM protection for TPM */
-	if (nvcfg1 & (1 << 27))
+	if (nvcfg1 & (1 << 27)) {
 		tp->tg3_flags2 |= TG3_FLG2_PROTECTED_NVRAM;
+		protect = 1;
+	}
 
-	switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
-		case FLASH_5755VENDOR_ATMEL_EEPROM_64KHZ:
-		case FLASH_5755VENDOR_ATMEL_EEPROM_376KHZ:
-			tp->nvram_jedecnum = JEDEC_ATMEL;
-			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
-			tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
-
-			nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
-			tw32(NVRAM_CFG1, nvcfg1);
-			break;
-		case FLASH_5752VENDOR_ATMEL_FLASH_BUFFERED:
+	nvcfg1 &= NVRAM_CFG1_5752VENDOR_MASK;
+	switch (nvcfg1) {
 		case FLASH_5755VENDOR_ATMEL_FLASH_1:
 		case FLASH_5755VENDOR_ATMEL_FLASH_2:
 		case FLASH_5755VENDOR_ATMEL_FLASH_3:
-		case FLASH_5755VENDOR_ATMEL_FLASH_4:
 			tp->nvram_jedecnum = JEDEC_ATMEL;
 			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
 			tp->tg3_flags2 |= TG3_FLG2_FLASH;
 			tp->nvram_pagesize = 264;
+			if (nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_1)
+				tp->nvram_size = (protect ? 0x3e200 : 0x80000);
+			else if (nvcfg1 == FLASH_5755VENDOR_ATMEL_FLASH_2)
+				tp->nvram_size = (protect ? 0x1f200 : 0x40000);
+			else
+				tp->nvram_size = (protect ? 0x1f200 : 0x20000);
 			break;
 		case FLASH_5752VENDOR_ST_M45PE10:
 		case FLASH_5752VENDOR_ST_M45PE20:
@@ -9440,6 +9438,12 @@ static void __devinit tg3_get_5755_nvram_info(struct tg3 *tp)
 			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
 			tp->tg3_flags2 |= TG3_FLG2_FLASH;
 			tp->nvram_pagesize = 256;
+			if (nvcfg1 == FLASH_5752VENDOR_ST_M45PE10)
+				tp->nvram_size = (protect ? 0x10000 : 0x20000);
+			else if (nvcfg1 == FLASH_5752VENDOR_ST_M45PE20)
+				tp->nvram_size = (protect ? 0x10000 : 0x40000);
+			else
+				tp->nvram_size = (protect ? 0x20000 : 0x80000);
 			break;
 	}
 }
@@ -9515,6 +9519,8 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 		}
 		tg3_enable_nvram_access(tp);
 
+		tp->nvram_size = 0;
+
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
 			tg3_get_5752_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
@@ -9526,7 +9532,8 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 		else
 			tg3_get_nvram_info(tp);
 
-		tg3_get_nvram_size(tp);
+		if (tp->nvram_size == 0)
+			tg3_get_nvram_size(tp);
 
 		tg3_disable_nvram_access(tp);
 		tg3_nvram_unlock(tp);


