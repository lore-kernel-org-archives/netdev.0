From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 05/15] tg3: Reclaim TG3_FLG3_5761_5784_AX_FIXES flag
Date: Mon, 3 Nov 2008 02:11:42 -0800
Message-ID: <1225751621.6178@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4895 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756678AbYKCWdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reclaims the TG3_FLG3_5761_5784_AX_FIXES flag.  It only
used twice in non-fast paths.  This patch also consolidates some other
places where specific 5784 AX chip revisions can be generalized.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   21 +++++++--------------
 drivers/net/tg3.h |    1 -
 2 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9bd1be4..45fcbc3 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1742,7 +1742,8 @@ static int tg3_phy_reset(struct tg3 *tp)
 		tw32(TG3_CPMU_CTRL, cpmuctrl);
 	}
 
-	if (tp->tg3_flags3 & TG3_FLG3_5761_5784_AX_FIXES) {
+	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5784_AX ||
+	    GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5761_AX) {
 		u32 val;
 
 		val = tr32(TG3_CPMU_LSPD_1000MB_CLK);
@@ -2004,7 +2005,8 @@ static void tg3_power_down_phy(struct tg3 *tp)
 	     (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)))
 		return;
 
-	if (tp->tg3_flags3 & TG3_FLG3_5761_5784_AX_FIXES) {
+	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5784_AX ||
+	    GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5761_AX) {
 		val = tr32(TG3_CPMU_LSPD_1000MB_CLK);
 		val &= ~CPMU_LSPD_1000MB_MACCLK_MASK;
 		val |= CPMU_LSPD_1000MB_MACCLK_12_5;
@@ -3815,8 +3817,7 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 		err = tg3_setup_copper_phy(tp, force_reset);
 	}
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
-	    tp->pci_chip_rev_id == CHIPREV_ID_5784_A1) {
+	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5784_AX) {
 		u32 val, scale;
 
 		val = tr32(TG3_CPMU_CLCK_STAT) & CPMU_CLCK_STAT_MAC_CLCK_MASK;
@@ -7044,8 +7045,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tg3_write_sig_legacy(tp, RESET_KIND_INIT);
 
-	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
-	    tp->pci_chip_rev_id == CHIPREV_ID_5784_A1) {
+	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5784_AX) {
 		val = tr32(TG3_CPMU_CTRL);
 		val &= ~(CPMU_CTRL_LINK_AWARE_MODE | CPMU_CTRL_LINK_IDLE_MODE);
 		tw32(TG3_CPMU_CTRL, val);
@@ -12283,16 +12283,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
-		if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0 ||
-		    tp->pci_chip_rev_id == CHIPREV_ID_5784_A1 ||
-		    tp->pci_chip_rev_id == CHIPREV_ID_5761_A0 ||
-		    tp->pci_chip_rev_id == CHIPREV_ID_5761_A1)
-			tp->tg3_flags3 |= TG3_FLG3_5761_5784_AX_FIXES;
-	}
-
 	/* Set up tp->grc_local_ctrl before calling tg3_set_power_state().
 	 * GPIO1 driven high will bring 5700's external PHY out of reset.
 	 * It is also used as eeprom write protect on LOMs.
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 65b5ff4..417de07 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2510,7 +2510,6 @@ struct tg3 {
 	u32				tg3_flags3;
 #define TG3_FLG3_NO_NVRAM_ADDR_TRANS	0x00000001
 #define TG3_FLG3_ENABLE_APE		0x00000002
-#define TG3_FLG3_5761_5784_AX_FIXES	0x00000004
 #define TG3_FLG3_5701_DMA_BUG		0x00000008
 #define TG3_FLG3_USE_PHYLIB		0x00000010
 #define TG3_FLG3_MDIOBUS_INITED		0x00000020
-- 
1.5.6.4



