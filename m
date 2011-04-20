From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 8/9] tg3: Add macro for SMDSP toggling
Date: Wed, 20 Apr 2011 10:57:42 -0700
Message-ID: <1303322263-18991-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4142 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755476Ab1DTRs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:48:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A common AUX CTRL operation in the driver is to enable and disable the
SMDSP.  This patch consolidates the code so that the details of the
operation are in one place.  This patch also adds code to make sure the
SMDSP is enabled before executing code that relies on it.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |  102 ++++++++++++++++++++++++-----------------------------
 1 files changed, 46 insertions(+), 56 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 69cd7cf..9ed6bfb 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -970,6 +970,15 @@ static int tg3_phy_auxctl_write(struct tg3 *tp, int reg, u32 set)
 	return tg3_writephy(tp, MII_TG3_AUX_CTRL, set | reg);
 }
 
+#define TG3_PHY_AUXCTL_SMDSP_ENABLE(tp) \
+	tg3_phy_auxctl_write((tp), MII_TG3_AUXCTL_SHDWSEL_AUXCTL, \
+			     MII_TG3_AUXCTL_ACTL_SMDSP_ENA | \
+			     MII_TG3_AUXCTL_ACTL_TX_6DB)
+
+#define TG3_PHY_AUXCTL_SMDSP_DISABLE(tp) \
+	tg3_phy_auxctl_write((tp), MII_TG3_AUXCTL_SHDWSEL_AUXCTL, \
+			     MII_TG3_AUXCTL_ACTL_TX_6DB);
+
 static int tg3_bmcr_reset(struct tg3 *tp)
 {
 	u32 phy_control;
@@ -1738,11 +1747,8 @@ static void tg3_phy_apply_otp(struct tg3 *tp)
 
 	otp = tp->phy_otp;
 
-	/* Enable SM_DSP clock and tx 6dB coding. */
-	phy = MII_TG3_AUXCTL_SHDWSEL_AUXCTL |
-	      MII_TG3_AUXCTL_ACTL_SMDSP_ENA |
-	      MII_TG3_AUXCTL_ACTL_TX_6DB;
-	tg3_writephy(tp, MII_TG3_AUX_CTRL, phy);
+	if (TG3_PHY_AUXCTL_SMDSP_ENABLE(tp))
+		return;
 
 	phy = ((otp & TG3_OTP_AGCTGT_MASK) >> TG3_OTP_AGCTGT_SHIFT);
 	phy |= MII_TG3_DSP_TAP1_AGCTGT_DFLT;
@@ -1766,10 +1772,7 @@ static void tg3_phy_apply_otp(struct tg3 *tp)
 	      ((otp & TG3_OTP_RCOFF_MASK) >> TG3_OTP_RCOFF_SHIFT);
 	tg3_phydsp_write(tp, MII_TG3_DSP_EXP97, phy);
 
-	/* Turn off SM_DSP clock. */
-	phy = MII_TG3_AUXCTL_SHDWSEL_AUXCTL |
-	      MII_TG3_AUXCTL_ACTL_TX_6DB;
-	tg3_writephy(tp, MII_TG3_AUX_CTRL, phy);
+	TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
 }
 
 static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
@@ -1804,18 +1807,11 @@ static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
 			case ASIC_REV_5717:
 			case ASIC_REV_5719:
 			case ASIC_REV_57765:
-				/* Enable SM_DSP clock and tx 6dB coding. */
-				val = MII_TG3_AUXCTL_SHDWSEL_AUXCTL |
-				      MII_TG3_AUXCTL_ACTL_SMDSP_ENA |
-				      MII_TG3_AUXCTL_ACTL_TX_6DB;
-				tg3_writephy(tp, MII_TG3_AUX_CTRL, val);
-
-				tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, 0x0000);
-
-				/* Turn off SM_DSP clock. */
-				val = MII_TG3_AUXCTL_SHDWSEL_AUXCTL |
-				      MII_TG3_AUXCTL_ACTL_TX_6DB;
-				tg3_writephy(tp, MII_TG3_AUX_CTRL, val);
+				if (!TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
+					tg3_phydsp_write(tp, MII_TG3_DSP_TAP26,
+							 0x0000);
+					TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+				}
 			}
 			/* Fallthrough */
 		case TG3_CL45_D7_EEERES_STAT_LP_100TX:
@@ -1967,8 +1963,9 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 			     (MII_TG3_CTRL_AS_MASTER |
 			      MII_TG3_CTRL_ENABLE_AS_MASTER));
 
-		/* Enable SM_DSP_CLOCK and 6dB.  */
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
+		err = TG3_PHY_AUXCTL_SMDSP_ENABLE(tp);
+		if (err)
+			return err;
 
 		/* Block the PHY control access.  */
 		tg3_phydsp_write(tp, 0x8005, 0x0800);
@@ -1987,13 +1984,7 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 	tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x8200);
 	tg3_writephy(tp, MII_TG3_DSP_CONTROL, 0x0000);
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
-		/* Set Extended packet length bit for jumbo frames */
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x4400);
-	} else {
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
-	}
+	TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
 
 	tg3_writephy(tp, MII_TG3_CTRL, phy9_orig);
 
@@ -2081,33 +2072,39 @@ static int tg3_phy_reset(struct tg3 *tp)
 		tg3_phy_toggle_apd(tp, false);
 
 out:
-	if (tp->phy_flags & TG3_PHYFLG_ADC_BUG) {
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
+	if ((tp->phy_flags & TG3_PHYFLG_ADC_BUG) &&
+	    !TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
 		tg3_phydsp_write(tp, 0x201f, 0x2aaa);
 		tg3_phydsp_write(tp, 0x000a, 0x0323);
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
+		TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
 	}
+
 	if (tp->phy_flags & TG3_PHYFLG_5704_A0_BUG) {
 		tg3_writephy(tp, MII_TG3_MISC_SHDW, 0x8d68);
 		tg3_writephy(tp, MII_TG3_MISC_SHDW, 0x8d68);
 	}
+
 	if (tp->phy_flags & TG3_PHYFLG_BER_BUG) {
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
-		tg3_phydsp_write(tp, 0x000a, 0x310b);
-		tg3_phydsp_write(tp, 0x201f, 0x9506);
-		tg3_phydsp_write(tp, 0x401f, 0x14e2);
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
+		if (!TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
+			tg3_phydsp_write(tp, 0x000a, 0x310b);
+			tg3_phydsp_write(tp, 0x201f, 0x9506);
+			tg3_phydsp_write(tp, 0x401f, 0x14e2);
+			TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+		}
 	} else if (tp->phy_flags & TG3_PHYFLG_JITTER_BUG) {
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0c00);
-		tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x000a);
-		if (tp->phy_flags & TG3_PHYFLG_ADJUST_TRIM) {
-			tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x110b);
-			tg3_writephy(tp, MII_TG3_TEST1,
-				     MII_TG3_TEST1_TRIM_EN | 0x4);
-		} else
-			tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x010b);
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, 0x0400);
+		if (!TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
+			tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x000a);
+			if (tp->phy_flags & TG3_PHYFLG_ADJUST_TRIM) {
+				tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x110b);
+				tg3_writephy(tp, MII_TG3_TEST1,
+					     MII_TG3_TEST1_TRIM_EN | 0x4);
+			} else
+				tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x010b);
+
+			TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+		}
 	}
+
 	/* Set Extended packet length bit (bit 14) on all chips that */
 	/* support jumbo frames */
 	if ((tp->phy_id & TG3_PHY_ID_MASK) == TG3_PHY_ID_BCM5401) {
@@ -3011,11 +3008,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 		tw32(TG3_CPMU_EEE_MODE,
 		     tr32(TG3_CPMU_EEE_MODE) & ~TG3_CPMU_EEEMD_LPI_ENABLE);
 
-		/* Enable SM_DSP clock and tx 6dB coding. */
-		val = MII_TG3_AUXCTL_SHDWSEL_AUXCTL |
-		      MII_TG3_AUXCTL_ACTL_SMDSP_ENA |
-		      MII_TG3_AUXCTL_ACTL_TX_6DB;
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, val);
+		TG3_PHY_AUXCTL_SMDSP_ENABLE(tp);
 
 		switch (GET_ASIC_REV(tp->pci_chip_rev_id)) {
 		case ASIC_REV_5717:
@@ -3044,10 +3037,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 		}
 		tg3_phy_cl45_write(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, val);
 
-		/* Turn off SM_DSP clock. */
-		val = MII_TG3_AUXCTL_SHDWSEL_AUXCTL |
-		      MII_TG3_AUXCTL_ACTL_TX_6DB;
-		tg3_writephy(tp, MII_TG3_AUX_CTRL, val);
+		TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
 	}
 
 	if (tp->link_config.autoneg == AUTONEG_DISABLE &&
-- 
1.7.3.4


