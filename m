From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/7] tg3: Add 5720 NVRAM detection
Date: Mon, 4 Apr 2011 11:24:50 -0700
Message-ID: <1301941495-8069-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1313 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754907Ab1DDSTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:19:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5720's NVRAM pinstrappings are different than previous revisions of
the chip.  This patch adds support for the new layout.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |  117 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/tg3.h |   36 ++++++++++++++++
 2 files changed, 151 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b105cdd..f9bf9e8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11908,6 +11908,118 @@ static void __devinit tg3_get_5717_nvram_info(struct tg3 *tp)
 		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
 }
 
+static void __devinit tg3_get_5720_nvram_info(struct tg3 *tp)
+{
+	u32 nvcfg1, nvm_pinstrp;
+
+	nvcfg1 = tr32(NVRAM_CFG1);
+	nvm_pinstrp = nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK;
+
+	switch (nvm_pinstrp) {
+	case FLASH_5720_EEPROM_HD:
+	case FLASH_5720_EEPROM_LD:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+
+		nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
+		tw32(NVRAM_CFG1, nvcfg1);
+		if ((nvm_pinstrp) == FLASH_5720_EEPROM_HD)
+			tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
+		else
+			tp->nvram_pagesize = ATMEL_AT24C02_CHIP_SIZE;
+		return;
+	case FLASH_5720VENDOR_M_ATMEL_DB011D:
+	case FLASH_5720VENDOR_A_ATMEL_DB011B:
+	case FLASH_5720VENDOR_A_ATMEL_DB011D:
+	case FLASH_5720VENDOR_M_ATMEL_DB021D:
+	case FLASH_5720VENDOR_A_ATMEL_DB021B:
+	case FLASH_5720VENDOR_A_ATMEL_DB021D:
+	case FLASH_5720VENDOR_M_ATMEL_DB041D:
+	case FLASH_5720VENDOR_A_ATMEL_DB041B:
+	case FLASH_5720VENDOR_A_ATMEL_DB041D:
+	case FLASH_5720VENDOR_M_ATMEL_DB081D:
+	case FLASH_5720VENDOR_A_ATMEL_DB081D:
+	case FLASH_5720VENDOR_ATMEL_45USPT:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+
+		switch (nvm_pinstrp) {
+		case FLASH_5720VENDOR_M_ATMEL_DB021D:
+		case FLASH_5720VENDOR_A_ATMEL_DB021B:
+		case FLASH_5720VENDOR_A_ATMEL_DB021D:
+			tp->nvram_size = TG3_NVRAM_SIZE_256KB;
+			break;
+		case FLASH_5720VENDOR_M_ATMEL_DB041D:
+		case FLASH_5720VENDOR_A_ATMEL_DB041B:
+		case FLASH_5720VENDOR_A_ATMEL_DB041D:
+			tp->nvram_size = TG3_NVRAM_SIZE_512KB;
+			break;
+		case FLASH_5720VENDOR_M_ATMEL_DB081D:
+		case FLASH_5720VENDOR_A_ATMEL_DB081D:
+			tp->nvram_size = TG3_NVRAM_SIZE_1MB;
+			break;
+		default:
+			tp->nvram_size = TG3_NVRAM_SIZE_128KB;
+			break;
+		}
+		break;
+	case FLASH_5720VENDOR_M_ST_M25PE10:
+	case FLASH_5720VENDOR_M_ST_M45PE10:
+	case FLASH_5720VENDOR_A_ST_M25PE10:
+	case FLASH_5720VENDOR_A_ST_M45PE10:
+	case FLASH_5720VENDOR_M_ST_M25PE20:
+	case FLASH_5720VENDOR_M_ST_M45PE20:
+	case FLASH_5720VENDOR_A_ST_M25PE20:
+	case FLASH_5720VENDOR_A_ST_M45PE20:
+	case FLASH_5720VENDOR_M_ST_M25PE40:
+	case FLASH_5720VENDOR_M_ST_M45PE40:
+	case FLASH_5720VENDOR_A_ST_M25PE40:
+	case FLASH_5720VENDOR_A_ST_M45PE40:
+	case FLASH_5720VENDOR_M_ST_M25PE80:
+	case FLASH_5720VENDOR_M_ST_M45PE80:
+	case FLASH_5720VENDOR_A_ST_M25PE80:
+	case FLASH_5720VENDOR_A_ST_M45PE80:
+	case FLASH_5720VENDOR_ST_25USPT:
+	case FLASH_5720VENDOR_ST_45USPT:
+		tp->nvram_jedecnum = JEDEC_ST;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+
+		switch (nvm_pinstrp) {
+		case FLASH_5720VENDOR_M_ST_M25PE20:
+		case FLASH_5720VENDOR_M_ST_M45PE20:
+		case FLASH_5720VENDOR_A_ST_M25PE20:
+		case FLASH_5720VENDOR_A_ST_M45PE20:
+			tp->nvram_size = TG3_NVRAM_SIZE_256KB;
+			break;
+		case FLASH_5720VENDOR_M_ST_M25PE40:
+		case FLASH_5720VENDOR_M_ST_M45PE40:
+		case FLASH_5720VENDOR_A_ST_M25PE40:
+		case FLASH_5720VENDOR_A_ST_M45PE40:
+			tp->nvram_size = TG3_NVRAM_SIZE_512KB;
+			break;
+		case FLASH_5720VENDOR_M_ST_M25PE80:
+		case FLASH_5720VENDOR_M_ST_M45PE80:
+		case FLASH_5720VENDOR_A_ST_M25PE80:
+		case FLASH_5720VENDOR_A_ST_M45PE80:
+			tp->nvram_size = TG3_NVRAM_SIZE_1MB;
+			break;
+		default:
+			tp->nvram_size = TG3_NVRAM_SIZE_128KB;
+			break;
+		}
+		break;
+	default:
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM;
+		return;
+	}
+
+	tg3_nvram_get_pagesize(tp, nvcfg1);
+	if (tp->nvram_pagesize != 264 && tp->nvram_pagesize != 528)
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+}
+
 /* Chips other than 5700/5701 use the NVRAM for fetching info. */
 static void __devinit tg3_nvram_init(struct tg3 *tp)
 {
@@ -11953,9 +12065,10 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
 			tg3_get_57780_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
-			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
+			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719)
 			tg3_get_5717_nvram_info(tp);
+		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
+			tg3_get_5720_nvram_info(tp);
 		else
 			tg3_get_nvram_info(tp);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 9027032..43776fe 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1823,6 +1823,38 @@
 #define  FLASH_5717VENDOR_ATMEL_45USPT	 0x03400000
 #define  FLASH_5717VENDOR_ST_25USPT	 0x03400002
 #define  FLASH_5717VENDOR_ST_45USPT	 0x03400001
+#define  FLASH_5720_EEPROM_HD		 0x00000001
+#define  FLASH_5720_EEPROM_LD		 0x00000003
+#define  FLASH_5720VENDOR_M_ATMEL_DB011D 0x01000000
+#define  FLASH_5720VENDOR_M_ATMEL_DB021D 0x01000002
+#define  FLASH_5720VENDOR_M_ATMEL_DB041D 0x01000001
+#define  FLASH_5720VENDOR_M_ATMEL_DB081D 0x01000003
+#define  FLASH_5720VENDOR_M_ST_M25PE10	 0x02000000
+#define  FLASH_5720VENDOR_M_ST_M25PE20	 0x02000002
+#define  FLASH_5720VENDOR_M_ST_M25PE40	 0x02000001
+#define  FLASH_5720VENDOR_M_ST_M25PE80	 0x02000003
+#define  FLASH_5720VENDOR_M_ST_M45PE10	 0x03000000
+#define  FLASH_5720VENDOR_M_ST_M45PE20	 0x03000002
+#define  FLASH_5720VENDOR_M_ST_M45PE40	 0x03000001
+#define  FLASH_5720VENDOR_M_ST_M45PE80	 0x03000003
+#define  FLASH_5720VENDOR_A_ATMEL_DB011B 0x01800000
+#define  FLASH_5720VENDOR_A_ATMEL_DB021B 0x01800002
+#define  FLASH_5720VENDOR_A_ATMEL_DB041B 0x01800001
+#define  FLASH_5720VENDOR_A_ATMEL_DB011D 0x01c00000
+#define  FLASH_5720VENDOR_A_ATMEL_DB021D 0x01c00002
+#define  FLASH_5720VENDOR_A_ATMEL_DB041D 0x01c00001
+#define  FLASH_5720VENDOR_A_ATMEL_DB081D 0x01c00003
+#define  FLASH_5720VENDOR_A_ST_M25PE10	 0x02800000
+#define  FLASH_5720VENDOR_A_ST_M25PE20	 0x02800002
+#define  FLASH_5720VENDOR_A_ST_M25PE40	 0x02800001
+#define  FLASH_5720VENDOR_A_ST_M25PE80	 0x02800003
+#define  FLASH_5720VENDOR_A_ST_M45PE10	 0x02c00000
+#define  FLASH_5720VENDOR_A_ST_M45PE20	 0x02c00002
+#define  FLASH_5720VENDOR_A_ST_M45PE40	 0x02c00001
+#define  FLASH_5720VENDOR_A_ST_M45PE80	 0x02c00003
+#define  FLASH_5720VENDOR_ATMEL_45USPT	 0x03c00000
+#define  FLASH_5720VENDOR_ST_25USPT	 0x03c00002
+#define  FLASH_5720VENDOR_ST_45USPT	 0x03c00001
 #define  NVRAM_CFG1_5752PAGE_SIZE_MASK	 0x70000000
 #define  FLASH_5752PAGE_SIZE_256	 0x00000000
 #define  FLASH_5752PAGE_SIZE_512	 0x10000000
@@ -3054,6 +3086,7 @@ struct tg3 {
 
 	int				nvram_lock_cnt;
 	u32				nvram_size;
+#define TG3_NVRAM_SIZE_2KB		0x00000800
 #define TG3_NVRAM_SIZE_64KB		0x00010000
 #define TG3_NVRAM_SIZE_128KB		0x00020000
 #define TG3_NVRAM_SIZE_256KB		0x00040000
@@ -3069,6 +3102,9 @@ struct tg3 {
 #define JEDEC_SAIFUN			0x4f
 #define JEDEC_SST			0xbf
 
+#define ATMEL_AT24C02_CHIP_SIZE		TG3_NVRAM_SIZE_2KB
+#define ATMEL_AT24C02_PAGE_SIZE		(8)
+
 #define ATMEL_AT24C64_CHIP_SIZE		TG3_NVRAM_SIZE_64KB
 #define ATMEL_AT24C64_PAGE_SIZE		(32)
 
-- 
1.7.3.4


