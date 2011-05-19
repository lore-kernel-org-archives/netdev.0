From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 06/13] tg3: Consolidate autoneg advertisement
 setup code
Date: Thu, 19 May 2011 15:12:49 -0700
Message-ID: <1305843176-32358-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1108 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934899Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Autonegotiation setup has gotten a little more complicated since the tg3
driver was created.  This patch consolidates autoneg setup into one
routine and modifies the call sites accordingly.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |  217 ++++++++++++++++++++++++-----------------------------
 1 files changed, 99 insertions(+), 118 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 695dab2..7675231 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2929,102 +2929,54 @@ static void tg3_aux_stat_to_speed_duplex(struct tg3 *tp, u32 val, u16 *speed, u8
 	}
 }
 
-static void tg3_phy_copper_begin(struct tg3 *tp)
+static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 {
-	u32 new_adv;
-	int i;
-
-	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) {
-		/* Entering low power mode.  Disable gigabit and
-		 * 100baseT advertisements.
-		 */
-		tg3_writephy(tp, MII_TG3_CTRL, 0);
+	int err = 0;
+	u32 val, new_adv;
 
-		new_adv = (ADVERTISE_10HALF | ADVERTISE_10FULL |
-			   ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
-		if (tg3_flag(tp, WOL_SPEED_100MB))
-			new_adv |= (ADVERTISE_100HALF | ADVERTISE_100FULL);
+	new_adv = ADVERTISE_CSMA;
+	if (advertise & ADVERTISED_10baseT_Half)
+		new_adv |= ADVERTISE_10HALF;
+	if (advertise & ADVERTISED_10baseT_Full)
+		new_adv |= ADVERTISE_10FULL;
+	if (advertise & ADVERTISED_100baseT_Half)
+		new_adv |= ADVERTISE_100HALF;
+	if (advertise & ADVERTISED_100baseT_Full)
+		new_adv |= ADVERTISE_100FULL;
 
-		tg3_writephy(tp, MII_ADVERTISE, new_adv);
-	} else if (tp->link_config.speed == SPEED_INVALID) {
-		if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
-			tp->link_config.advertising &=
-				~(ADVERTISED_1000baseT_Half |
-				  ADVERTISED_1000baseT_Full);
+	new_adv |= tg3_advert_flowctrl_1000T(flowctrl);
 
-		new_adv = ADVERTISE_CSMA;
-		if (tp->link_config.advertising & ADVERTISED_10baseT_Half)
-			new_adv |= ADVERTISE_10HALF;
-		if (tp->link_config.advertising & ADVERTISED_10baseT_Full)
-			new_adv |= ADVERTISE_10FULL;
-		if (tp->link_config.advertising & ADVERTISED_100baseT_Half)
-			new_adv |= ADVERTISE_100HALF;
-		if (tp->link_config.advertising & ADVERTISED_100baseT_Full)
-			new_adv |= ADVERTISE_100FULL;
-
-		new_adv |= tg3_advert_flowctrl_1000T(tp->link_config.flowctrl);
-
-		tg3_writephy(tp, MII_ADVERTISE, new_adv);
-
-		if (tp->link_config.advertising &
-		    (ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full)) {
-			new_adv = 0;
-			if (tp->link_config.advertising & ADVERTISED_1000baseT_Half)
-				new_adv |= MII_TG3_CTRL_ADV_1000_HALF;
-			if (tp->link_config.advertising & ADVERTISED_1000baseT_Full)
-				new_adv |= MII_TG3_CTRL_ADV_1000_FULL;
-			if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY) &&
-			    (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
-			     tp->pci_chip_rev_id == CHIPREV_ID_5701_B0))
-				new_adv |= (MII_TG3_CTRL_AS_MASTER |
-					    MII_TG3_CTRL_ENABLE_AS_MASTER);
-			tg3_writephy(tp, MII_TG3_CTRL, new_adv);
-		} else {
-			tg3_writephy(tp, MII_TG3_CTRL, 0);
-		}
-	} else {
-		new_adv = tg3_advert_flowctrl_1000T(tp->link_config.flowctrl);
-		new_adv |= ADVERTISE_CSMA;
+	err = tg3_writephy(tp, MII_ADVERTISE, new_adv);
+	if (err)
+		goto done;
 
-		/* Asking for a specific link mode. */
-		if (tp->link_config.speed == SPEED_1000) {
-			tg3_writephy(tp, MII_ADVERTISE, new_adv);
+	if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
+		goto done;
 
-			if (tp->link_config.duplex == DUPLEX_FULL)
-				new_adv = MII_TG3_CTRL_ADV_1000_FULL;
-			else
-				new_adv = MII_TG3_CTRL_ADV_1000_HALF;
-			if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
-			    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0)
-				new_adv |= (MII_TG3_CTRL_AS_MASTER |
-					    MII_TG3_CTRL_ENABLE_AS_MASTER);
-		} else {
-			if (tp->link_config.speed == SPEED_100) {
-				if (tp->link_config.duplex == DUPLEX_FULL)
-					new_adv |= ADVERTISE_100FULL;
-				else
-					new_adv |= ADVERTISE_100HALF;
-			} else {
-				if (tp->link_config.duplex == DUPLEX_FULL)
-					new_adv |= ADVERTISE_10FULL;
-				else
-					new_adv |= ADVERTISE_10HALF;
-			}
-			tg3_writephy(tp, MII_ADVERTISE, new_adv);
+	new_adv = 0;
+	if (advertise & ADVERTISED_1000baseT_Half)
+		new_adv |= MII_TG3_CTRL_ADV_1000_HALF;
+	if (advertise & ADVERTISED_1000baseT_Full)
+		new_adv |= MII_TG3_CTRL_ADV_1000_FULL;
 
-			new_adv = 0;
-		}
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
+	    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0)
+		new_adv |= (MII_TG3_CTRL_AS_MASTER |
+			    MII_TG3_CTRL_ENABLE_AS_MASTER);
 
-		tg3_writephy(tp, MII_TG3_CTRL, new_adv);
-	}
+	err = tg3_writephy(tp, MII_TG3_CTRL, new_adv);
+	if (err)
+		goto done;
 
-	if (tp->phy_flags & TG3_PHYFLG_EEE_CAP) {
-		u32 val;
+	if (!(tp->phy_flags & TG3_PHYFLG_EEE_CAP))
+		goto done;
 
-		tw32(TG3_CPMU_EEE_MODE,
-		     tr32(TG3_CPMU_EEE_MODE) & ~TG3_CPMU_EEEMD_LPI_ENABLE);
+	tw32(TG3_CPMU_EEE_MODE,
+	     tr32(TG3_CPMU_EEE_MODE) & ~TG3_CPMU_EEEMD_LPI_ENABLE);
 
-		TG3_PHY_AUXCTL_SMDSP_ENABLE(tp);
+	err = TG3_PHY_AUXCTL_SMDSP_ENABLE(tp);
+	if (!err) {
+		u32 err2;
 
 		switch (GET_ASIC_REV(tp->pci_chip_rev_id)) {
 		case ASIC_REV_5717:
@@ -3041,19 +2993,66 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 		}
 
 		val = 0;
-		if (tp->link_config.autoneg == AUTONEG_ENABLE) {
-			/* Advertise 100-BaseTX EEE ability */
-			if (tp->link_config.advertising &
-			    ADVERTISED_100baseT_Full)
-				val |= MDIO_AN_EEE_ADV_100TX;
-			/* Advertise 1000-BaseT EEE ability */
-			if (tp->link_config.advertising &
-			    ADVERTISED_1000baseT_Full)
-				val |= MDIO_AN_EEE_ADV_1000T;
+		/* Advertise 100-BaseTX EEE ability */
+		if (advertise & ADVERTISED_100baseT_Full)
+			val |= MDIO_AN_EEE_ADV_100TX;
+		/* Advertise 1000-BaseT EEE ability */
+		if (advertise & ADVERTISED_1000baseT_Full)
+			val |= MDIO_AN_EEE_ADV_1000T;
+		err = tg3_phy_cl45_write(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, val);
+
+		err2 = TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+		if (!err)
+			err = err2;
+	}
+
+done:
+	return err;
+}
+
+static void tg3_phy_copper_begin(struct tg3 *tp)
+{
+	u32 new_adv;
+	int i;
+
+	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) {
+		new_adv = ADVERTISED_10baseT_Half |
+			  ADVERTISED_10baseT_Full;
+		if (tg3_flag(tp, WOL_SPEED_100MB))
+			new_adv |= ADVERTISED_100baseT_Half |
+				   ADVERTISED_100baseT_Full;
+
+		tg3_phy_autoneg_cfg(tp, new_adv,
+				    FLOW_CTRL_TX | FLOW_CTRL_RX);
+	} else if (tp->link_config.speed == SPEED_INVALID) {
+		if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
+			tp->link_config.advertising &=
+				~(ADVERTISED_1000baseT_Half |
+				  ADVERTISED_1000baseT_Full);
+
+		tg3_phy_autoneg_cfg(tp, tp->link_config.advertising,
+				    tp->link_config.flowctrl);
+	} else {
+		/* Asking for a specific link mode. */
+		if (tp->link_config.speed == SPEED_1000) {
+			if (tp->link_config.duplex == DUPLEX_FULL)
+				new_adv = ADVERTISED_1000baseT_Full;
+			else
+				new_adv = ADVERTISED_1000baseT_Half;
+		} else if (tp->link_config.speed == SPEED_100) {
+			if (tp->link_config.duplex == DUPLEX_FULL)
+				new_adv = ADVERTISED_100baseT_Full;
+			else
+				new_adv = ADVERTISED_100baseT_Half;
+		} else {
+			if (tp->link_config.duplex == DUPLEX_FULL)
+				new_adv = ADVERTISED_10baseT_Full;
+			else
+				new_adv = ADVERTISED_10baseT_Half;
 		}
-		tg3_phy_cl45_write(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, val);
 
-		TG3_PHY_AUXCTL_SMDSP_DISABLE(tp);
+		tg3_phy_autoneg_cfg(tp, new_adv,
+				    tp->link_config.flowctrl);
 	}
 
 	if (tp->link_config.autoneg == AUTONEG_DISABLE &&
@@ -12953,7 +12952,7 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES) &&
 	    !tg3_flag(tp, ENABLE_APE) &&
 	    !tg3_flag(tp, ENABLE_ASF)) {
-		u32 bmsr, adv_reg, tg3_ctrl, mask;
+		u32 bmsr, mask;
 
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		if (!tg3_readphy(tp, MII_BMSR, &bmsr) &&
@@ -12964,36 +12963,18 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 		if (err)
 			return err;
 
-		adv_reg = (ADVERTISE_10HALF | ADVERTISE_10FULL |
-			   ADVERTISE_100HALF | ADVERTISE_100FULL |
-			   ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
-		tg3_ctrl = 0;
-		if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
-			tg3_ctrl = (MII_TG3_CTRL_ADV_1000_HALF |
-				    MII_TG3_CTRL_ADV_1000_FULL);
-			if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
-			    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0)
-				tg3_ctrl |= (MII_TG3_CTRL_AS_MASTER |
-					     MII_TG3_CTRL_ENABLE_AS_MASTER);
-		}
+		tg3_phy_set_wirespeed(tp);
 
 		mask = (ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
 			ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
 			ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full);
 		if (!tg3_copper_is_advertising_all(tp, mask)) {
-			tg3_writephy(tp, MII_ADVERTISE, adv_reg);
-
-			if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY))
-				tg3_writephy(tp, MII_TG3_CTRL, tg3_ctrl);
+			tg3_phy_autoneg_cfg(tp, tp->link_config.advertising,
+					    tp->link_config.flowctrl);
 
 			tg3_writephy(tp, MII_BMCR,
 				     BMCR_ANENABLE | BMCR_ANRESTART);
 		}
-		tg3_phy_set_wirespeed(tp);
-
-		tg3_writephy(tp, MII_ADVERTISE, adv_reg);
-		if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY))
-			tg3_writephy(tp, MII_TG3_CTRL, tg3_ctrl);
 	}
 
 skip_phy_reset:
-- 
1.7.3.4


