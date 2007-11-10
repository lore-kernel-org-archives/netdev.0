From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 11/13] tg3: Add A1 revs
Date: Fri, 09 Nov 2007 16:39:04 -0800
Message-ID: <1194655144.5745.273.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1633 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751814AbXKJAjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:08 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the A1 revision of 5784, 5764, and 5761, and applies all
previous bugfixes.  In places where the list of devices gets too long,
the patch uses a new TG3_FLG3_5761_5784_AX_FIXES flag instead.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 72db78b..8e76092 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1106,8 +1106,7 @@ static int tg3_phy_reset(struct tg3 *tp)
 	if (err)
 		return err;
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
-	    tp->pci_chip_rev_id == CHIPREV_ID_5761_A0) {
+	if (tp->tg3_flags3 & TG3_FLG3_5761_5784_AX_FIXES) {
 		u32 val;
 
 		val = tr32(TG3_CPMU_LSPD_1000MB_CLK);
@@ -1352,8 +1351,7 @@ static void tg3_power_down_phy(struct tg3 *tp)
 	     (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)))
 		return;
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
-	    tp->pci_chip_rev_id == CHIPREV_ID_5761_A0) {
+	if (tp->tg3_flags3 & TG3_FLG3_5761_5784_AX_FIXES) {
 		val = tr32(TG3_CPMU_LSPD_1000MB_CLK);
 		val &= ~CPMU_LSPD_1000MB_MACCLK_MASK;
 		val |= CPMU_LSPD_1000MB_MACCLK_12_5;
@@ -3154,7 +3152,8 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 		err = tg3_setup_copper_phy(tp, force_reset);
 	}
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0) {
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5784_A1) {
 		u32 val, scale;
 
 		val = tr32(TG3_CPMU_CLCK_STAT) & CPMU_CLCK_STAT_MAC_CLCK_MASK;
@@ -6390,7 +6389,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tg3_write_sig_legacy(tp, RESET_KIND_INIT);
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0) {
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5784_A1) {
 		val = tr32(TG3_CPMU_CTRL);
 		val &= ~(CPMU_CTRL_LINK_AWARE_MODE | CPMU_CTRL_LINK_IDLE_MODE);
 		tw32(TG3_CPMU_CTRL, val);
@@ -9379,8 +9379,7 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (err)
 		return TG3_LOOPBACK_FAILED;
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
-	    tp->pci_chip_rev_id == CHIPREV_ID_5761_A0) {
+	if (tp->tg3_flags3 & TG3_FLG3_5761_5784_AX_FIXES) {
 		int i;
 		u32 status;
 
@@ -9407,8 +9406,7 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (tg3_run_loopback(tp, TG3_MAC_LOOPBACK))
 		err |= TG3_MAC_LOOPBACK_FAILED;
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
-	    tp->pci_chip_rev_id == CHIPREV_ID_5761_A0) {
+	if (tp->tg3_flags3 & TG3_FLG3_5761_5784_AX_FIXES) {
 		tw32(TG3_CPMU_CTRL, cpmuctrl);
 
 		/* Release the mutex */
@@ -10629,7 +10627,8 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		    tp->pdev->subsystem_vendor == PCI_VENDOR_ID_DELL)
 			tp->led_ctrl = LED_CTRL_MODE_PHY_2;
 
-		if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0)
+		if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
+		    tp->pci_chip_rev_id == CHIPREV_ID_5784_A1)
 			tp->led_ctrl = LED_CTRL_MODE_MAC;
 
 		if (nic_cfg & NIC_SRAM_DATA_CFG_EEPROM_WP) {
@@ -11401,9 +11400,16 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761) {
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
+		if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
+		    tp->pci_chip_rev_id == CHIPREV_ID_5784_A1 ||
+		    tp->pci_chip_rev_id == CHIPREV_ID_5761_A0 ||
+		    tp->pci_chip_rev_id == CHIPREV_ID_5761_A1)
+			tp->tg3_flags3 |= TG3_FLG3_5761_5784_AX_FIXES;
+	}
+
 	/* Set up tp->grc_local_ctrl before calling tg3_set_power_state().
 	 * GPIO1 driven high will bring 5700's external PHY out of reset.
 	 * It is also used as eeprom write protect on LOMs.
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index d325ab5..da18fb2 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -109,7 +109,9 @@
 #define  CHIPREV_ID_5714_A2		 0x9002
 #define  CHIPREV_ID_5906_A1		 0xc001
 #define  CHIPREV_ID_5784_A0		 0x5784000
+#define  CHIPREV_ID_5784_A1		 0x5784001
 #define  CHIPREV_ID_5761_A0		 0x5761000
+#define  CHIPREV_ID_5761_A1		 0x5761001
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
@@ -2391,6 +2393,7 @@ struct tg3 {
 	u32				tg3_flags3;
 #define TG3_FLG3_NO_NVRAM_ADDR_TRANS	0x00000001
 #define TG3_FLG3_ENABLE_APE		0x00000002
+#define TG3_FLG3_5761_5784_AX_FIXES	0x00000004
 
 	struct timer_list		timer;
 	u16				timer_counter;


