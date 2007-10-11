From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/5] tg3: Add new 5761 NVRAM decode routines
Date: Wed, 10 Oct 2007 17:45:19 -0700
Message-ID: <1192063520.4878.183.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1619 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757092AbXJKApg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 20:45:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new 5761-specific NVRAM strapping decode routine.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 1e0c9e0..3200c9c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9581,6 +9581,81 @@ static void __devinit tg3_get_5787_nvram_info(struct tg3 *tp)
 	}
 }
 
+static void __devinit tg3_get_5761_nvram_info(struct tg3 *tp)
+{
+	u32 nvcfg1, protect = 0;
+
+	nvcfg1 = tr32(NVRAM_CFG1);
+
+	/* NVRAM protection for TPM */
+	if (nvcfg1 & (1 << 27)) {
+		tp->tg3_flags2 |= TG3_FLG2_PROTECTED_NVRAM;
+		protect = 1;
+	}
+
+	nvcfg1 &= NVRAM_CFG1_5752VENDOR_MASK;
+	switch (nvcfg1) {
+		case FLASH_5761VENDOR_ATMEL_ADB021D:
+		case FLASH_5761VENDOR_ATMEL_ADB041D:
+		case FLASH_5761VENDOR_ATMEL_ADB081D:
+		case FLASH_5761VENDOR_ATMEL_ADB161D:
+		case FLASH_5761VENDOR_ATMEL_MDB021D:
+		case FLASH_5761VENDOR_ATMEL_MDB041D:
+		case FLASH_5761VENDOR_ATMEL_MDB081D:
+		case FLASH_5761VENDOR_ATMEL_MDB161D:
+			tp->nvram_jedecnum = JEDEC_ATMEL;
+			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+			tp->tg3_flags2 |= TG3_FLG2_FLASH;
+			tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+			tp->nvram_pagesize = 256;
+			break;
+		case FLASH_5761VENDOR_ST_A_M45PE20:
+		case FLASH_5761VENDOR_ST_A_M45PE40:
+		case FLASH_5761VENDOR_ST_A_M45PE80:
+		case FLASH_5761VENDOR_ST_A_M45PE16:
+		case FLASH_5761VENDOR_ST_M_M45PE20:
+		case FLASH_5761VENDOR_ST_M_M45PE40:
+		case FLASH_5761VENDOR_ST_M_M45PE80:
+		case FLASH_5761VENDOR_ST_M_M45PE16:
+			tp->nvram_jedecnum = JEDEC_ST;
+			tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+			tp->tg3_flags2 |= TG3_FLG2_FLASH;
+			tp->nvram_pagesize = 256;
+			break;
+	}
+
+	if (protect) {
+		tp->nvram_size = tr32(NVRAM_ADDR_LOCKOUT);
+	} else {
+		switch (nvcfg1) {
+			case FLASH_5761VENDOR_ATMEL_ADB161D:
+			case FLASH_5761VENDOR_ATMEL_MDB161D:
+			case FLASH_5761VENDOR_ST_A_M45PE16:
+			case FLASH_5761VENDOR_ST_M_M45PE16:
+				tp->nvram_size = 0x100000;
+				break;
+			case FLASH_5761VENDOR_ATMEL_ADB081D:
+			case FLASH_5761VENDOR_ATMEL_MDB081D:
+			case FLASH_5761VENDOR_ST_A_M45PE80:
+			case FLASH_5761VENDOR_ST_M_M45PE80:
+				tp->nvram_size = 0x80000;
+				break;
+			case FLASH_5761VENDOR_ATMEL_ADB041D:
+			case FLASH_5761VENDOR_ATMEL_MDB041D:
+			case FLASH_5761VENDOR_ST_A_M45PE40:
+			case FLASH_5761VENDOR_ST_M_M45PE40:
+				tp->nvram_size = 0x40000;
+				break;
+			case FLASH_5761VENDOR_ATMEL_ADB021D:
+			case FLASH_5761VENDOR_ATMEL_MDB021D:
+			case FLASH_5761VENDOR_ST_A_M45PE20:
+			case FLASH_5761VENDOR_ST_M_M45PE20:
+				tp->nvram_size = 0x20000;
+				break;
+		}
+	}
+}
+
 static void __devinit tg3_get_5906_nvram_info(struct tg3 *tp)
 {
 	tp->nvram_jedecnum = JEDEC_ATMEL;
@@ -9623,6 +9698,8 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
 			tg3_get_5787_nvram_info(tp);
+		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+			tg3_get_5761_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 			tg3_get_5906_nvram_info(tp);
 		else
@@ -9700,6 +9777,7 @@ static u32 tg3_nvram_phys_addr(struct tg3 *tp, u32 addr)
 	if ((tp->tg3_flags & TG3_FLAG_NVRAM) &&
 	    (tp->tg3_flags & TG3_FLAG_NVRAM_BUFFERED) &&
 	    (tp->tg3_flags2 & TG3_FLG2_FLASH) &&
+	   !(tp->tg3_flags3 & TG3_FLG3_NO_NVRAM_ADDR_TRANS) &&
 	    (tp->nvram_jedecnum == JEDEC_ATMEL))
 
 		addr = ((addr / tp->nvram_pagesize) <<
@@ -9714,6 +9792,7 @@ static u32 tg3_nvram_logical_addr(struct tg3 *tp, u32 addr)
 	if ((tp->tg3_flags & TG3_FLAG_NVRAM) &&
 	    (tp->tg3_flags & TG3_FLAG_NVRAM_BUFFERED) &&
 	    (tp->tg3_flags2 & TG3_FLG2_FLASH) &&
+	   !(tp->tg3_flags3 & TG3_FLG3_NO_NVRAM_ADDR_TRANS) &&
 	    (tp->nvram_jedecnum == JEDEC_ATMEL))
 
 		addr = ((addr >> ATMEL_AT45DB0X1B_PAGE_POS) *
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d8e829f..88d08f3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -124,6 +124,7 @@
 #define   ASIC_REV_5906			 0x0c
 #define   ASIC_REV_USE_PROD_ID_REG	 0x0f
 #define   ASIC_REV_5784			 0x5784
+#define   ASIC_REV_5761			 0x5761
 #define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
@@ -1463,6 +1464,22 @@
 #define  FLASH_5787VENDOR_ATMEL_EEPROM_376KHZ	 0x03000002
 #define  FLASH_5787VENDOR_MICRO_EEPROM_64KHZ	 0x03000000
 #define  FLASH_5787VENDOR_MICRO_EEPROM_376KHZ	 0x02000000
+#define  FLASH_5761VENDOR_ATMEL_MDB021D	 0x00800003
+#define  FLASH_5761VENDOR_ATMEL_MDB041D	 0x00800000
+#define  FLASH_5761VENDOR_ATMEL_MDB081D	 0x00800002
+#define  FLASH_5761VENDOR_ATMEL_MDB161D	 0x00800001
+#define  FLASH_5761VENDOR_ATMEL_ADB021D	 0x00000003
+#define  FLASH_5761VENDOR_ATMEL_ADB041D	 0x00000000
+#define  FLASH_5761VENDOR_ATMEL_ADB081D	 0x00000002
+#define  FLASH_5761VENDOR_ATMEL_ADB161D	 0x00000001
+#define  FLASH_5761VENDOR_ST_M_M45PE20	 0x02800001
+#define  FLASH_5761VENDOR_ST_M_M45PE40	 0x02800000
+#define  FLASH_5761VENDOR_ST_M_M45PE80	 0x02800002
+#define  FLASH_5761VENDOR_ST_M_M45PE16	 0x02800003
+#define  FLASH_5761VENDOR_ST_A_M45PE20	 0x02000001
+#define  FLASH_5761VENDOR_ST_A_M45PE40	 0x02000000
+#define  FLASH_5761VENDOR_ST_A_M45PE80	 0x02000002
+#define  FLASH_5761VENDOR_ST_A_M45PE16	 0x02000003
 #define  NVRAM_CFG1_5752PAGE_SIZE_MASK	 0x70000000
 #define  FLASH_5752PAGE_SIZE_256	 0x00000000
 #define  FLASH_5752PAGE_SIZE_512	 0x10000000
@@ -1493,9 +1510,11 @@
 #define  ACCESS_ENABLE			 0x00000001
 #define  ACCESS_WR_ENABLE		 0x00000002
 #define NVRAM_WRITE1			0x00007028
-/* 0x702c --> 0x7400 unused */
+/* 0x702c unused */
+
+#define NVRAM_ADDR_LOCKOUT		0x00007030
+/* 0x7034 --> 0x7c00 unused */
 
-/* 0x7400 --> 0x7c00 unused */
 #define PCIE_TRANSACTION_CFG		0x00007c04
 #define PCIE_TRANS_CFG_1SHOT_MSI	 0x20000000
 #define PCIE_TRANS_CFG_LOM		 0x00000020
@@ -2269,6 +2288,8 @@ struct tg3 {
 #define TG3_FLG2_PHY_JITTER_BUG		0x20000000
 #define TG3_FLG2_NO_FWARE_REPORTED	0x40000000
 #define TG3_FLG2_PHY_ADJUST_TRIM	0x80000000
+	u32				tg3_flags3;
+#define TG3_FLG3_NO_NVRAM_ADDR_TRANS	0x00000001
 
 	struct timer_list		timer;
 	u16				timer_counter;


