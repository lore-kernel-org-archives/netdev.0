From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 16/18] tg3: Add 5717 NVRAM detection routines
Date: Tue, 1 Sep 2009 16:20:17 -0700
Message-ID: <1251867315.5959@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4113 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932148AbZIBEz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds NVRAM detection routines for the 5717.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |  154 +++++++++++++++++++++++++++++++++++++----------------
 drivers/net/tg3.h |   23 ++++++++-
 2 files changed, 130 insertions(+), 47 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2310e56..bc9c13a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10853,6 +10853,33 @@ static void __devinit tg3_get_nvram_info(struct tg3 *tp)
 	}
 }
 
+static void __devinit tg3_nvram_get_pagesize(struct tg3 *tp, u32 nvmcfg1)
+{
+	switch (nvmcfg1 & NVRAM_CFG1_5752PAGE_SIZE_MASK) {
+	case FLASH_5752PAGE_SIZE_256:
+		tp->nvram_pagesize = 256;
+		break;
+	case FLASH_5752PAGE_SIZE_512:
+		tp->nvram_pagesize = 512;
+		break;
+	case FLASH_5752PAGE_SIZE_1K:
+		tp->nvram_pagesize = 1024;
+		break;
+	case FLASH_5752PAGE_SIZE_2K:
+		tp->nvram_pagesize = 2048;
+		break;
+	case FLASH_5752PAGE_SIZE_4K:
+		tp->nvram_pagesize = 4096;
+		break;
+	case FLASH_5752PAGE_SIZE_264:
+		tp->nvram_pagesize = 264;
+		break;
+	case FLASH_5752PAGE_SIZE_528:
+		tp->nvram_pagesize = 528;
+		break;
+	}
+}
+
 static void __devinit tg3_get_5752_nvram_info(struct tg3 *tp)
 {
 	u32 nvcfg1;
@@ -10884,26 +10911,7 @@ static void __devinit tg3_get_5752_nvram_info(struct tg3 *tp)
 	}
 
 	if (tp->tg3_flags2 & TG3_FLG2_FLASH) {
-		switch (nvcfg1 & NVRAM_CFG1_5752PAGE_SIZE_MASK) {
-		case FLASH_5752PAGE_SIZE_256:
-			tp->nvram_pagesize = 256;
-			break;
-		case FLASH_5752PAGE_SIZE_512:
-			tp->nvram_pagesize = 512;
-			break;
-		case FLASH_5752PAGE_SIZE_1K:
-			tp->nvram_pagesize = 1024;
-			break;
-		case FLASH_5752PAGE_SIZE_2K:
-			tp->nvram_pagesize = 2048;
-			break;
-		case FLASH_5752PAGE_SIZE_4K:
-			tp->nvram_pagesize = 4096;
-			break;
-		case FLASH_5752PAGE_SIZE_264:
-			tp->nvram_pagesize = 264;
-			break;
-		}
+		tg3_nvram_get_pagesize(tp, nvcfg1);
 	} else {
 		/* For eeprom, set pagesize to maximum eeprom size */
 		tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
@@ -11156,34 +11164,84 @@ static void __devinit tg3_get_57780_nvram_info(struct tg3 *tp)
 		return;
 	}
 
-	switch (nvcfg1 & NVRAM_CFG1_5752PAGE_SIZE_MASK) {
-	case FLASH_5752PAGE_SIZE_256:
+	tg3_nvram_get_pagesize(tp, nvcfg1);
+	if (tp->nvram_pagesize != 264 && tp->nvram_pagesize != 528)
 		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
-		tp->nvram_pagesize = 256;
-		break;
-	case FLASH_5752PAGE_SIZE_512:
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
-		tp->nvram_pagesize = 512;
-		break;
-	case FLASH_5752PAGE_SIZE_1K:
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
-		tp->nvram_pagesize = 1024;
-		break;
-	case FLASH_5752PAGE_SIZE_2K:
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
-		tp->nvram_pagesize = 2048;
-		break;
-	case FLASH_5752PAGE_SIZE_4K:
-		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
-		tp->nvram_pagesize = 4096;
-		break;
-	case FLASH_5752PAGE_SIZE_264:
-		tp->nvram_pagesize = 264;
+}
+
+
+static void __devinit tg3_get_5717_nvram_info(struct tg3 *tp)
+{
+	u32 nvcfg1;
+
+	nvcfg1 = tr32(NVRAM_CFG1);
+
+	switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
+	case FLASH_5717VENDOR_ATMEL_EEPROM:
+	case FLASH_5717VENDOR_MICRO_EEPROM:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
+
+		nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
+		tw32(NVRAM_CFG1, nvcfg1);
+		return;
+	case FLASH_5717VENDOR_ATMEL_MDB011D:
+	case FLASH_5717VENDOR_ATMEL_ADB011B:
+	case FLASH_5717VENDOR_ATMEL_ADB011D:
+	case FLASH_5717VENDOR_ATMEL_MDB021D:
+	case FLASH_5717VENDOR_ATMEL_ADB021B:
+	case FLASH_5717VENDOR_ATMEL_ADB021D:
+	case FLASH_5717VENDOR_ATMEL_45USPT:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+
+		switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
+		case FLASH_5717VENDOR_ATMEL_MDB021D:
+		case FLASH_5717VENDOR_ATMEL_ADB021B:
+		case FLASH_5717VENDOR_ATMEL_ADB021D:
+			tp->nvram_size = TG3_NVRAM_SIZE_256KB;
+			break;
+		default:
+			tp->nvram_size = TG3_NVRAM_SIZE_128KB;
+			break;
+		}
 		break;
-	case FLASH_5752PAGE_SIZE_528:
-		tp->nvram_pagesize = 528;
+	case FLASH_5717VENDOR_ST_M_M25PE10:
+	case FLASH_5717VENDOR_ST_A_M25PE10:
+	case FLASH_5717VENDOR_ST_M_M45PE10:
+	case FLASH_5717VENDOR_ST_A_M45PE10:
+	case FLASH_5717VENDOR_ST_M_M25PE20:
+	case FLASH_5717VENDOR_ST_A_M25PE20:
+	case FLASH_5717VENDOR_ST_M_M45PE20:
+	case FLASH_5717VENDOR_ST_A_M45PE20:
+	case FLASH_5717VENDOR_ST_25USPT:
+	case FLASH_5717VENDOR_ST_45USPT:
+		tp->nvram_jedecnum = JEDEC_ST;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+
+		switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
+		case FLASH_5717VENDOR_ST_M_M25PE20:
+		case FLASH_5717VENDOR_ST_A_M25PE20:
+		case FLASH_5717VENDOR_ST_M_M45PE20:
+		case FLASH_5717VENDOR_ST_A_M45PE20:
+			tp->nvram_size = TG3_NVRAM_SIZE_256KB;
+			break;
+		default:
+			tp->nvram_size = TG3_NVRAM_SIZE_128KB;
+			break;
+		}
 		break;
+	default:
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM;
+		return;
 	}
+
+	tg3_nvram_get_pagesize(tp, nvcfg1);
+	if (tp->nvram_pagesize != 264 && tp->nvram_pagesize != 528)
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
 }
 
 /* Chips other than 5700/5701 use the NVRAM for fetching info. */
@@ -11228,6 +11286,8 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 			tg3_get_5906_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 			tg3_get_57780_nvram_info(tp);
+		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+			tg3_get_5717_nvram_info(tp);
 		else
 			tg3_get_nvram_info(tp);
 
@@ -13074,8 +13134,10 @@ static int __devinit tg3_get_device_address(struct tg3 *tp)
 			tw32_f(NVRAM_CMD, NVRAM_CMD_RESET);
 		else
 			tg3_nvram_unlock(tp);
-	}
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
+		if (tr32(TG3_CPMU_STATUS) & TG3_CPMU_STATUS_PCIE_FUNC)
+			mac_offset = 0xcc;
+	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		mac_offset = 0x10;
 
 	/* First try to get it from MAC address mailbox. */
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 5994476..ea57a3a 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1027,8 +1027,10 @@
 #define TG3_CPMU_HST_ACC		0x0000361c
 #define  CPMU_HST_ACC_MACCLK_MASK	 0x001f0000
 #define  CPMU_HST_ACC_MACCLK_6_25	 0x00130000
-/* 0x3620 --> 0x3630 unused */
+/* 0x3620 --> 0x362c unused */
 
+#define TG3_CPMU_STATUS			0x0000362c
+#define  TG3_CPMU_STATUS_PCIE_FUNC	 0x20000000
 #define TG3_CPMU_CLCK_STAT		0x00003630
 #define  CPMU_CLCK_STAT_MAC_CLCK_MASK	 0x001f0000
 #define  CPMU_CLCK_STAT_MAC_CLCK_62_5	 0x00000000
@@ -1692,6 +1694,25 @@
 #define  FLASH_57780VENDOR_ATMEL_AT45DB021B 0x03400002
 #define  FLASH_57780VENDOR_ATMEL_AT45DB041D 0x00400001
 #define  FLASH_57780VENDOR_ATMEL_AT45DB041B 0x03400001
+#define  FLASH_5717VENDOR_ATMEL_EEPROM	 0x02000001
+#define  FLASH_5717VENDOR_MICRO_EEPROM	 0x02000003
+#define  FLASH_5717VENDOR_ATMEL_MDB011D	 0x01000001
+#define  FLASH_5717VENDOR_ATMEL_MDB021D	 0x01000003
+#define  FLASH_5717VENDOR_ST_M_M25PE10	 0x02000000
+#define  FLASH_5717VENDOR_ST_M_M25PE20	 0x02000002
+#define  FLASH_5717VENDOR_ST_M_M45PE10	 0x00000001
+#define  FLASH_5717VENDOR_ST_M_M45PE20	 0x00000003
+#define  FLASH_5717VENDOR_ATMEL_ADB011B	 0x01400000
+#define  FLASH_5717VENDOR_ATMEL_ADB021B	 0x01400002
+#define  FLASH_5717VENDOR_ATMEL_ADB011D	 0x01400001
+#define  FLASH_5717VENDOR_ATMEL_ADB021D	 0x01400003
+#define  FLASH_5717VENDOR_ST_A_M25PE10	 0x02400000
+#define  FLASH_5717VENDOR_ST_A_M25PE20	 0x02400002
+#define  FLASH_5717VENDOR_ST_A_M45PE10	 0x02400001
+#define  FLASH_5717VENDOR_ST_A_M45PE20	 0x02400003
+#define  FLASH_5717VENDOR_ATMEL_45USPT	 0x03400000
+#define  FLASH_5717VENDOR_ST_25USPT	 0x03400002
+#define  FLASH_5717VENDOR_ST_45USPT	 0x03400001
 #define  NVRAM_CFG1_5752PAGE_SIZE_MASK	 0x70000000
 #define  FLASH_5752PAGE_SIZE_256	 0x00000000
 #define  FLASH_5752PAGE_SIZE_512	 0x10000000
-- 
1.6.3.3


