From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/4][TG3]: ASIC decoding and basic CPMU support.
Date: Fri, 05 Oct 2007 20:37:38 -0700
Message-ID: <1191641858.17453.7.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4563 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754760AbXJFCiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 22:38:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: ASIC decoding and basic CPMU support.

Newer products change the way the ASIC revision is obtained.  This patch
implements how the driver will extract the revision number.

This patch also adds preliminary CPMU support.  CPMU stands for Central
Power Management Unit.  The CPMU's role is to put the chip into lower
power states when the operating conditions allow it.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4f9fbe2..482b7df 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -595,7 +595,8 @@ static void tg3_switch_clocks(struct tg3 *tp)
 	u32 clock_ctrl = tr32(TG3PCI_CLOCK_CTRL);
 	u32 orig_clock_ctrl;
 
-	if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)
+	if ((tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) ||
+	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		return;
 
 	orig_clock_ctrl = clock_ctrl;
@@ -1400,6 +1401,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 		tw32_wait_f(TG3PCI_CLOCK_CTRL, base_val | CLOCK_CTRL_ALTCLK |
 			    CLOCK_CTRL_PWRDOWN_PLL133, 40);
 	} else if ((tp->tg3_flags2 & TG3_FLG2_5780_CLASS) ||
+		   (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) ||
 		   (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)) {
 		/* do nothing */
 	} else if (!((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
@@ -6147,11 +6149,13 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	/* This works around an issue with Athlon chipsets on
 	 * B3 tigon3 silicon.  This bit has no effect on any
 	 * other revision.  But do not set this on PCI Express
-	 * chips.
+	 * chips and don't even touch the clocks if the CPMU is present.
 	 */
-	if (!(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS))
-		tp->pci_clock_ctrl |= CLOCK_CTRL_DELAY_PCI_GRANT;
-	tw32_f(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl);
+	if (!(tp->tg3_flags & TG3_FLAG_CPMU_PRESENT)) {
+		if (!(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS))
+			tp->pci_clock_ctrl |= CLOCK_CTRL_DELAY_PCI_GRANT;
+		tw32_f(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl);
+	}
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0 &&
 	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE)) {
@@ -10527,6 +10531,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	tp->pci_chip_rev_id = (misc_ctrl_reg >>
 			       MISC_HOST_CTRL_CHIPREV_SHIFT);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_USE_PROD_ID_REG) {
+		u32 prod_id_asic_rev;
+
+		pci_read_config_dword(tp->pdev, TG3PCI_PRODID_ASICREV,
+				      &prod_id_asic_rev);
+		tp->pci_chip_rev_id = prod_id_asic_rev & PROD_ID_ASIC_REV_MASK;
+	}
 
 	/* Wrong chip ID in 5752 A0. This code can be removed later
 	 * as A0 is not in production.
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index c4f845d..79ce68c 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -121,6 +121,7 @@
 #define   ASIC_REV_5755			 0x0a
 #define   ASIC_REV_5787			 0x0b
 #define   ASIC_REV_5906			 0x0c
+#define   ASIC_REV_USE_PROD_ID_REG	 0x0f
 #define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
@@ -214,7 +215,9 @@
 #define TG3PCI_DUAL_MAC_CTRL		0x000000b8
 #define  DUAL_MAC_CTRL_CH_MASK		 0x00000003
 #define  DUAL_MAC_CTRL_ID		 0x00000004
-/* 0xbc --> 0x100 unused */
+#define TG3PCI_PRODID_ASICREV		0x000000bc
+#define  PROD_ID_ASIC_REV_MASK		 0x0fffffff
+/* 0xc0 --> 0x100 unused */
 
 /* 0x100 --> 0x200 unused */
 
@@ -2213,7 +2216,7 @@ struct tg3 {
 #define TG3_FLAG_JUMBO_RING_ENABLE	0x00800000
 #define TG3_FLAG_10_100_ONLY		0x01000000
 #define TG3_FLAG_PAUSE_AUTONEG		0x02000000
-
+#define TG3_FLAG_CPMU_PRESENT		0x04000000
 #define TG3_FLAG_40BIT_DMA_BUG		0x08000000
 #define TG3_FLAG_BROKEN_CHECKSUMS	0x10000000
 #define TG3_FLAG_SUPPORT_MSI		0x20000000
@@ -2285,7 +2288,7 @@ struct tg3 {
 	u32				pwrmgmt_thresh;
 
 	/* PCI block */
-	u16				pci_chip_rev_id;
+	u32				pci_chip_rev_id;
 	u8				pci_cacheline_sz;
 	u8				pci_lat_timer;
 	u8				pci_hdr_type;


