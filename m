From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/2 net] tg3: Fix crc errors on jumbo frame receive
Date: Mon, 14 Jan 2013 19:11:00 -0800
Message-ID: <1358219460-5993-2-git-send-email-mchan@broadcom.com>
References: <1358219460-5993-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3378 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756105Ab3AOCyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 21:54:35 -0500
In-Reply-To: <1358219460-5993-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Nayak Sujir <nsujir@broadcom.com>

TG3_PHY_AUXCTL_SMDSP_ENABLE/DISABLE macros do a blind write to the phy
auxiliary control register and overwrite the EXT_PKT_LEN (bit 14) resulting
in intermittent crc errors on jumbo frames with some link partners. Change
the code to do a read/modify/write.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
---
 drivers/net/ethernet/broadcom/tg3.c |   58 +++++++++++++++++++++--------------
 1 files changed, 35 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d326d92..bdb0869 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1283,14 +1283,26 @@ static int tg3_phy_auxctl_write(struct tg3 *tp, int reg, u32 set)
 	return tg3_writephy(tp, MII_TG3_AUX_CTRL, set | reg);
 }
 
-#define TG3_PHY_AUXCTL_SMDSP_ENABLE(tp) \
-	tg3_phy_auxctl_write((tp), MII_TG3_AUXCTL_SHDWSEL_AUXCTL, \
-			     MII_TG3_AUXCTL_ACTL_SMDSP_ENA | \
-			     MII_TG3_AUXCTL_ACTL_TX_6DB)
+static int tg3_phy_toggle_auxctl_smdsp(struct tg3 *tp, bool enable)
+{
+	u32 val;
+	int err;
+
+	err = tg3_phy_auxctl_read(tp, MII_TG3_AUXCTL_SHDWSEL_AUXCTL, &val);
 
-#define TG3_PHY_AUXCTL_SMDSP_DISABLE(tp) \
-	tg3_phy_auxctl_write((tp), MII_TG3_AUXCTL_SHDWSEL_AUXCTL, \
-			     MII_TG3_AUXCTL_ACTL_TX_6DB);
+	if (err)
+		return err;
+	if (enable)
+
+		val |= MII_TG3_AUXCTL_ACTL_SMDSP_ENA;
+	else
+		val &= ~MII_TG3_AUXCTL_ACTL_SMDSP_ENA;
+
+	err = tg3_phy_auxctl_write((tp), MII_TG3_AUXCTL_SHDWSEL_AUXCTL,
+				   val | MII_TG3_AUXCTL_ACTL_TX_6DB);
+
+	return err;
+}
 
 static int tg3_bmcr_reset(struct tg3 *tp)
 {
@@ -2223,7 +2235,7 @@ static void tg3_phy_apply_otp(struct tg3 *tp)
 
 	otp = tp->phy_otp;
 
-	if (TG3_PHY_AUXCTL_SMDSP_ENABLE(tp))
+	if (tg3_phy_toggle_auxctl_smdsp(tp, true))
 		return;
 
 	phy = ((otp & TG3_OTP_AGCTGT_MASK) >> TG3_OTP_AGCTGT_SHIFT);
@@ -2248,7 +2260,7 @@ static void tg3_phy_apply_otp(struct tg3 *tp)
 	      ((otp & TG3_OTP_RCOFF_MASK) >> TG3_OTP_RCOFF_SHIFT);
 	tg3_phydsp_write(tp, MII_TG3_DSP_EXP97, phy);
 
-	TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+	tg3_phy_toggle_auxctl_smdsp(tp, false);
 }
 
 static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
@@ -2284,9 +2296,9 @@ static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
 
 	if (!tp->setlpicnt) {
 		if (current_link_up == 1 &&
-		   !TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
+		   !tg3_phy_toggle_auxctl_smdsp(tp, true)) {
 			tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, 0x0000);
-			TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+			tg3_phy_toggle_auxctl_smdsp(tp, false);
 		}
 
 		val = tr32(TG3_CPMU_EEE_MODE);
@@ -2302,11 +2314,11 @@ static void tg3_phy_eee_enable(struct tg3 *tp)
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 	     tg3_flag(tp, 57765_CLASS)) &&
-	    !TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
+	    !tg3_phy_toggle_auxctl_smdsp(tp, true)) {
 		val = MII_TG3_DSP_TAP26_ALNOKO |
 		      MII_TG3_DSP_TAP26_RMRXSTO;
 		tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, val);
-		TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+		tg3_phy_toggle_auxctl_smdsp(tp, false);
 	}
 
 	val = tr32(TG3_CPMU_EEE_MODE);
@@ -2450,7 +2462,7 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 		tg3_writephy(tp, MII_CTRL1000,
 			     CTL1000_AS_MASTER | CTL1000_ENABLE_MASTER);
 
-		err = TG3_PHY_AUXCTL_SMDSP_ENABLE(tp);
+		err = tg3_phy_toggle_auxctl_smdsp(tp, true);
 		if (err)
 			return err;
 
@@ -2471,7 +2483,7 @@ static int tg3_phy_reset_5703_4_5(struct tg3 *tp)
 	tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x8200);
 	tg3_writephy(tp, MII_TG3_DSP_CONTROL, 0x0000);
 
-	TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+	tg3_phy_toggle_auxctl_smdsp(tp, false);
 
 	tg3_writephy(tp, MII_CTRL1000, phy9_orig);
 
@@ -2572,10 +2584,10 @@ static int tg3_phy_reset(struct tg3 *tp)
 
 out:
 	if ((tp->phy_flags & TG3_PHYFLG_ADC_BUG) &&
-	    !TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
+	    !tg3_phy_toggle_auxctl_smdsp(tp, true)) {
 		tg3_phydsp_write(tp, 0x201f, 0x2aaa);
 		tg3_phydsp_write(tp, 0x000a, 0x0323);
-		TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+		tg3_phy_toggle_auxctl_smdsp(tp, false);
 	}
 
 	if (tp->phy_flags & TG3_PHYFLG_5704_A0_BUG) {
@@ -2584,14 +2596,14 @@ out:
 	}
 
 	if (tp->phy_flags & TG3_PHYFLG_BER_BUG) {
-		if (!TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
+		if (!tg3_phy_toggle_auxctl_smdsp(tp, true)) {
 			tg3_phydsp_write(tp, 0x000a, 0x310b);
 			tg3_phydsp_write(tp, 0x201f, 0x9506);
 			tg3_phydsp_write(tp, 0x401f, 0x14e2);
-			TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+			tg3_phy_toggle_auxctl_smdsp(tp, false);
 		}
 	} else if (tp->phy_flags & TG3_PHYFLG_JITTER_BUG) {
-		if (!TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
+		if (!tg3_phy_toggle_auxctl_smdsp(tp, true)) {
 			tg3_writephy(tp, MII_TG3_DSP_ADDRESS, 0x000a);
 			if (tp->phy_flags & TG3_PHYFLG_ADJUST_TRIM) {
 				tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x110b);
@@ -2600,7 +2612,7 @@ out:
 			} else
 				tg3_writephy(tp, MII_TG3_DSP_RW_PORT, 0x010b);
 
-			TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+			tg3_phy_toggle_auxctl_smdsp(tp, false);
 		}
 	}
 
@@ -4009,7 +4021,7 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 	tw32(TG3_CPMU_EEE_MODE,
 	     tr32(TG3_CPMU_EEE_MODE) & ~TG3_CPMU_EEEMD_LPI_ENABLE);
 
-	err = TG3_PHY_AUXCTL_SMDSP_ENABLE(tp);
+	err = tg3_phy_toggle_auxctl_smdsp(tp, true);
 	if (!err) {
 		u32 err2;
 
@@ -4042,7 +4054,7 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 						 MII_TG3_DSP_CH34TP2_HIBW01);
 		}
 
-		err2 = TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+		err2 = tg3_phy_toggle_auxctl_smdsp(tp, false);
 		if (!err)
 			err = err2;
 	}
-- 
1.7.1
