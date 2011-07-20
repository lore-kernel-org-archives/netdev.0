From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/8] tg3: Fix link down notify failure when EEE
 disabled
Date: Wed, 20 Jul 2011 13:20:52 -0700
Message-ID: <1311193257-20531-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2264 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751697Ab1GTUTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 16:19:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Occasionally, when the network cable is removed after a successful
autonegotiation, the device will not send a link down interrupt to the
driver.  This happens because of a bad interaction of an EEE
workaround.  The fix is to adjust the code so that the root cause
condition does not happen.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   38 +++++++++++++++++++++++++-------------
 1 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2a9ab99..e0413bc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1858,6 +1858,12 @@ static void tg3_phy_eee_adjust(struct tg3 *tp, u32 current_link_up)
 	}
 
 	if (!tp->setlpicnt) {
+		if (current_link_up == 1 &&
+		   !TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
+			tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, 0x0000);
+			TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+		}
+
 		val = tr32(TG3_CPMU_EEE_MODE);
 		tw32(TG3_CPMU_EEE_MODE, val & ~TG3_CPMU_EEEMD_LPI_ENABLE);
 	}
@@ -1872,7 +1878,9 @@ static void tg3_phy_eee_enable(struct tg3 *tp)
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) &&
 	    !TG3_PHY_AUXCTL_SMDSP_ENABLE(tp)) {
-		tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, 0x0003);
+		val = MII_TG3_DSP_TAP26_ALNOKO |
+		      MII_TG3_DSP_TAP26_RMRXSTO;
+		tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, val);
 		TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
 	}
 
@@ -3128,13 +3136,26 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 	if (!err) {
 		u32 err2;
 
+		val = 0;
+		/* Advertise 100-BaseTX EEE ability */
+		if (advertise & ADVERTISED_100baseT_Full)
+			val |= MDIO_AN_EEE_ADV_100TX;
+		/* Advertise 1000-BaseT EEE ability */
+		if (advertise & ADVERTISED_1000baseT_Full)
+			val |= MDIO_AN_EEE_ADV_1000T;
+		err = tg3_phy_cl45_write(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, val);
+		if (err)
+			val = 0;
+
 		switch (GET_ASIC_REV(tp->pci_chip_rev_id)) {
 		case ASIC_REV_5717:
 		case ASIC_REV_57765:
 		case ASIC_REV_5719:
-			val = MII_TG3_DSP_TAP26_ALNOKO |
-			      MII_TG3_DSP_TAP26_RMRXSTO |
-			      MII_TG3_DSP_TAP26_OPCSINPT;
+			/* If we advertised any eee advertisements above... */
+			if (val)
+				val = MII_TG3_DSP_TAP26_ALNOKO |
+				      MII_TG3_DSP_TAP26_RMRXSTO |
+				      MII_TG3_DSP_TAP26_OPCSINPT;
 			tg3_phydsp_write(tp, MII_TG3_DSP_TAP26, val);
 			/* Fall through */
 		case ASIC_REV_5720:
@@ -3143,15 +3164,6 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 						 MII_TG3_DSP_CH34TP2_HIBW01);
 		}
 
-		val = 0;
-		/* Advertise 100-BaseTX EEE ability */
-		if (advertise & ADVERTISED_100baseT_Full)
-			val |= MDIO_AN_EEE_ADV_100TX;
-		/* Advertise 1000-BaseT EEE ability */
-		if (advertise & ADVERTISED_1000baseT_Full)
-			val |= MDIO_AN_EEE_ADV_1000T;
-		err = tg3_phy_cl45_write(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, val);
-
 		err2 = TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
 		if (!err)
 			err = err2;
-- 
1.7.3.4


