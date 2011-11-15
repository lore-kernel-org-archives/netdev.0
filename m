From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH] Add ethtool to mii advertisment conversion helpers
Date: Tue, 15 Nov 2011 14:00:53 -0800
Message-ID: <1321394453-21076-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3963 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757450Ab1KOWBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 17:01:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Translating between ethtool advertisement settings and MII
advertisements are common operations for ethernet drivers.  This patch
adds a set of helper functions that implements the conversion.  The
patch then modifies a couple of the drivers to use the new functions.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   15 +---
 drivers/net/ethernet/broadcom/tg3.c  |   53 +++--------
 drivers/net/ethernet/sun/niu.c       |   15 +---
 drivers/net/mii.c                    |   48 ++--------
 drivers/net/phy/phy_device.c         |   20 +----
 include/linux/mii.h                  |  165 ++++++++++++++++++++++++++++++++++
 6 files changed, 196 insertions(+), 120 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 32d1f92..e82b981 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2064,21 +2064,12 @@ __acquires(&bp->phy_lock)
 		bnx2_read_phy(bp, MII_CTRL1000, &adv1000_reg);
 		adv1000_reg &= PHY_ALL_1000_SPEED;
 
-		if (bp->advertising & ADVERTISED_10baseT_Half)
-			new_adv_reg |= ADVERTISE_10HALF;
-		if (bp->advertising & ADVERTISED_10baseT_Full)
-			new_adv_reg |= ADVERTISE_10FULL;
-		if (bp->advertising & ADVERTISED_100baseT_Half)
-			new_adv_reg |= ADVERTISE_100HALF;
-		if (bp->advertising & ADVERTISED_100baseT_Full)
-			new_adv_reg |= ADVERTISE_100FULL;
-		if (bp->advertising & ADVERTISED_1000baseT_Full)
-			new_adv1000_reg |= ADVERTISE_1000FULL;
-
+		new_adv_reg = ethtool_adv_to_mii_100bt(bp->advertising);
 		new_adv_reg |= ADVERTISE_CSMA;
-
 		new_adv_reg |= bnx2_phy_get_pause_adv(bp);
 
+		new_adv1000_reg |= ethtool_adv_to_mii_1000T(bp->advertising);
+
 		if ((adv1000_reg != new_adv1000_reg) ||
 			(adv_reg != new_adv_reg) ||
 			((bmcr & BMCR_ANENABLE) == 0)) {
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index cd36234..b329459 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3594,15 +3594,7 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 	u32 val, new_adv;
 
 	new_adv = ADVERTISE_CSMA;
-	if (advertise & ADVERTISED_10baseT_Half)
-		new_adv |= ADVERTISE_10HALF;
-	if (advertise & ADVERTISED_10baseT_Full)
-		new_adv |= ADVERTISE_10FULL;
-	if (advertise & ADVERTISED_100baseT_Half)
-		new_adv |= ADVERTISE_100HALF;
-	if (advertise & ADVERTISED_100baseT_Full)
-		new_adv |= ADVERTISE_100FULL;
-
+	new_adv |= ethtool_adv_to_mii_100bt(advertise);
 	new_adv |= tg3_advert_flowctrl_1000T(flowctrl);
 
 	err = tg3_writephy(tp, MII_ADVERTISE, new_adv);
@@ -3612,11 +3604,7 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 	if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
 		goto done;
 
-	new_adv = 0;
-	if (advertise & ADVERTISED_1000baseT_Half)
-		new_adv |= ADVERTISE_1000HALF;
-	if (advertise & ADVERTISED_1000baseT_Full)
-		new_adv |= ADVERTISE_1000FULL;
+	new_adv = ethtool_adv_to_mii_1000T(advertise);
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
 	    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0)
@@ -3790,14 +3778,7 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 {
 	u32 adv_reg, all_mask = 0;
 
-	if (mask & ADVERTISED_10baseT_Half)
-		all_mask |= ADVERTISE_10HALF;
-	if (mask & ADVERTISED_10baseT_Full)
-		all_mask |= ADVERTISE_10FULL;
-	if (mask & ADVERTISED_100baseT_Half)
-		all_mask |= ADVERTISE_100HALF;
-	if (mask & ADVERTISED_100baseT_Full)
-		all_mask |= ADVERTISE_100FULL;
+	all_mask = ethtool_adv_to_mii_100bt(mask);
 
 	if (tg3_readphy(tp, MII_ADVERTISE, &adv_reg))
 		return 0;
@@ -3808,11 +3789,7 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
 		u32 tg3_ctrl;
 
-		all_mask = 0;
-		if (mask & ADVERTISED_1000baseT_Half)
-			all_mask |= ADVERTISE_1000HALF;
-		if (mask & ADVERTISED_1000baseT_Full)
-			all_mask |= ADVERTISE_1000FULL;
+		all_mask = ethtool_adv_to_mii_1000T(mask);
 
 		if (tg3_readphy(tp, MII_CTRL1000, &tg3_ctrl))
 			return 0;
@@ -4903,23 +4880,19 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 	    (tp->phy_flags & TG3_PHYFLG_PARALLEL_DETECT)) {
 		/* do nothing, just check for link up at the end */
 	} else if (tp->link_config.autoneg == AUTONEG_ENABLE) {
-		u32 adv, new_adv;
+		u32 adv, newadv;
 
 		err |= tg3_readphy(tp, MII_ADVERTISE, &adv);
-		new_adv = adv & ~(ADVERTISE_1000XFULL | ADVERTISE_1000XHALF |
-				  ADVERTISE_1000XPAUSE |
-				  ADVERTISE_1000XPSE_ASYM |
-				  ADVERTISE_SLCT);
-
-		new_adv |= tg3_advert_flowctrl_1000X(tp->link_config.flowctrl);
+		newadv = adv & ~(ADVERTISE_1000XFULL | ADVERTISE_1000XHALF |
+				 ADVERTISE_1000XPAUSE |
+				 ADVERTISE_1000XPSE_ASYM |
+				 ADVERTISE_SLCT);
 
-		if (tp->link_config.advertising & ADVERTISED_1000baseT_Half)
-			new_adv |= ADVERTISE_1000XHALF;
-		if (tp->link_config.advertising & ADVERTISED_1000baseT_Full)
-			new_adv |= ADVERTISE_1000XFULL;
+		newadv |= tg3_advert_flowctrl_1000X(tp->link_config.flowctrl);
+		newadv |= ethtool_adv_to_mii_1000X(tp->link_config.advertising);
 
-		if ((new_adv != adv) || !(bmcr & BMCR_ANENABLE)) {
-			tg3_writephy(tp, MII_ADVERTISE, new_adv);
+		if ((newadv != adv) || !(bmcr & BMCR_ANENABLE)) {
+			tg3_writephy(tp, MII_ADVERTISE, newadv);
 			bmcr |= BMCR_ANENABLE | BMCR_ANRESTART;
 			tg3_writephy(tp, MII_BMCR, bmcr);
 
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 3ebeb9d..9997be5 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -1151,19 +1151,8 @@ static int link_status_mii(struct niu *np, int *link_up_p)
 		supported |= SUPPORTED_1000baseT_Full;
 	lp->supported = supported;
 
-	advertising = 0;
-	if (advert & ADVERTISE_10HALF)
-		advertising |= ADVERTISED_10baseT_Half;
-	if (advert & ADVERTISE_10FULL)
-		advertising |= ADVERTISED_10baseT_Full;
-	if (advert & ADVERTISE_100HALF)
-		advertising |= ADVERTISED_100baseT_Half;
-	if (advert & ADVERTISE_100FULL)
-		advertising |= ADVERTISED_100baseT_Full;
-	if (ctrl1000 & ADVERTISE_1000HALF)
-		advertising |= ADVERTISED_1000baseT_Half;
-	if (ctrl1000 & ADVERTISE_1000FULL)
-		advertising |= ADVERTISED_1000baseT_Full;
+	advertising = mii_adv_to_ethtool_100bt(advert);
+	advertising |= mii_adv_to_ethtool_1000T(ctrl1000);
 
 	if (bmcr & BMCR_ANENABLE) {
 		int neg, neg1000;
diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index c62e781..d0a2962 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -41,20 +41,8 @@ static u32 mii_get_an(struct mii_if_info *mii, u16 addr)
 	advert = mii->mdio_read(mii->dev, mii->phy_id, addr);
 	if (advert & LPA_LPACK)
 		result |= ADVERTISED_Autoneg;
-	if (advert & ADVERTISE_10HALF)
-		result |= ADVERTISED_10baseT_Half;
-	if (advert & ADVERTISE_10FULL)
-		result |= ADVERTISED_10baseT_Full;
-	if (advert & ADVERTISE_100HALF)
-		result |= ADVERTISED_100baseT_Half;
-	if (advert & ADVERTISE_100FULL)
-		result |= ADVERTISED_100baseT_Full;
-	if (advert & ADVERTISE_PAUSE_CAP)
-		result |= ADVERTISED_Pause;
-	if (advert & ADVERTISE_PAUSE_ASYM)
-		result |= ADVERTISED_Asym_Pause;
-
-	return result;
+
+	return result | mii_adv_to_ethtool_100bt(advert);
 }
 
 /**
@@ -104,19 +92,13 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 		ecmd->autoneg = AUTONEG_ENABLE;
 
 		ecmd->advertising |= mii_get_an(mii, MII_ADVERTISE);
-		if (ctrl1000 & ADVERTISE_1000HALF)
-			ecmd->advertising |= ADVERTISED_1000baseT_Half;
-		if (ctrl1000 & ADVERTISE_1000FULL)
-			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		if (mii->supports_gmii)
+			ecmd->advertising |= mii_adv_to_ethtool_1000T(ctrl1000);
 
 		if (bmsr & BMSR_ANEGCOMPLETE) {
 			ecmd->lp_advertising = mii_get_an(mii, MII_LPA);
-			if (stat1000 & LPA_1000HALF)
-				ecmd->lp_advertising |=
-					ADVERTISED_1000baseT_Half;
-			if (stat1000 & LPA_1000FULL)
-				ecmd->lp_advertising |=
-					ADVERTISED_1000baseT_Full;
+			ecmd->lp_advertising |=
+					     mii_lpa_to_ethtool_1000T(stat1000);
 		} else {
 			ecmd->lp_advertising = 0;
 		}
@@ -204,20 +186,10 @@ int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 			advert2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
 			tmp2 = advert2 & ~(ADVERTISE_1000HALF | ADVERTISE_1000FULL);
 		}
-		if (ecmd->advertising & ADVERTISED_10baseT_Half)
-			tmp |= ADVERTISE_10HALF;
-		if (ecmd->advertising & ADVERTISED_10baseT_Full)
-			tmp |= ADVERTISE_10FULL;
-		if (ecmd->advertising & ADVERTISED_100baseT_Half)
-			tmp |= ADVERTISE_100HALF;
-		if (ecmd->advertising & ADVERTISED_100baseT_Full)
-			tmp |= ADVERTISE_100FULL;
-		if (mii->supports_gmii) {
-			if (ecmd->advertising & ADVERTISED_1000baseT_Half)
-				tmp2 |= ADVERTISE_1000HALF;
-			if (ecmd->advertising & ADVERTISED_1000baseT_Full)
-				tmp2 |= ADVERTISE_1000FULL;
-		}
+		tmp |= ethtool_adv_to_mii_100bt(ecmd->advertising);
+
+		if (mii->supports_gmii)
+			tmp2 |= ethtool_adv_to_mii_1000T(ecmd->advertising);
 		if (advert != tmp) {
 			mii->mdio_write(dev, mii->phy_id, MII_ADVERTISE, tmp);
 			mii->advertising = tmp;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 83a5a5a..edb905f 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -563,20 +563,9 @@ static int genphy_config_advert(struct phy_device *phydev)
 	if (adv < 0)
 		return adv;
 
-	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP | 
+	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP |
 		 ADVERTISE_PAUSE_ASYM);
-	if (advertise & ADVERTISED_10baseT_Half)
-		adv |= ADVERTISE_10HALF;
-	if (advertise & ADVERTISED_10baseT_Full)
-		adv |= ADVERTISE_10FULL;
-	if (advertise & ADVERTISED_100baseT_Half)
-		adv |= ADVERTISE_100HALF;
-	if (advertise & ADVERTISED_100baseT_Full)
-		adv |= ADVERTISE_100FULL;
-	if (advertise & ADVERTISED_Pause)
-		adv |= ADVERTISE_PAUSE_CAP;
-	if (advertise & ADVERTISED_Asym_Pause)
-		adv |= ADVERTISE_PAUSE_ASYM;
+	adv |= ethtool_adv_to_mii_100bt(advertise);
 
 	if (adv != oldadv) {
 		err = phy_write(phydev, MII_ADVERTISE, adv);
@@ -595,10 +584,7 @@ static int genphy_config_advert(struct phy_device *phydev)
 			return adv;
 
 		adv &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
-		if (advertise & SUPPORTED_1000baseT_Half)
-			adv |= ADVERTISE_1000HALF;
-		if (advertise & SUPPORTED_1000baseT_Full)
-			adv |= ADVERTISE_1000FULL;
+		adv |= ethtool_adv_to_mii_1000T(advertise);
 
 		if (adv != oldadv) {
 			err = phy_write(phydev, MII_CTRL1000, adv);
diff --git a/include/linux/mii.h b/include/linux/mii.h
index 2774823..ac49406 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -240,6 +240,171 @@ static inline unsigned int mii_duplex (unsigned int duplex_lock,
 }
 
 /**
+ * ethtool_adv_to_mii_100bt
+ * @ethadv: the ethtool advertisement settings
+ *
+ * A small helper function that translates ethtool advertisement
+ * settings to phy autonegotiation advertisements for the
+ * MII_ADVERTISE register.
+ */
+static inline u32 ethtool_adv_to_mii_100bt(u32 ethadv)
+{
+	u32 result = 0;
+
+	if (ethadv & ADVERTISED_10baseT_Half)
+		result |= ADVERTISE_10HALF;
+	if (ethadv & ADVERTISED_10baseT_Full)
+		result |= ADVERTISE_10FULL;
+	if (ethadv & ADVERTISED_100baseT_Half)
+		result |= ADVERTISE_100HALF;
+	if (ethadv & ADVERTISED_100baseT_Full)
+		result |= ADVERTISE_100FULL;
+	if (ethadv & ADVERTISED_Pause)
+		result |= ADVERTISE_PAUSE_CAP;
+	if (ethadv & ADVERTISED_Asym_Pause)
+		result |= ADVERTISE_PAUSE_ASYM;
+
+	return result;
+}
+
+/**
+ * mii_adv_to_ethtool_100bt
+ * @adv: value of the MII_ADVERTISE register
+ *
+ * A small helper function that translates MII_ADVERTISE bits
+ * to ethtool advertisement settings.
+ */
+static inline u32 mii_adv_to_ethtool_100bt(u32 adv)
+{
+	u32 result = 0;
+
+	if (adv & ADVERTISE_10HALF)
+		result |= ADVERTISED_10baseT_Half;
+	if (adv & ADVERTISE_10FULL)
+		result |= ADVERTISED_10baseT_Full;
+	if (adv & ADVERTISE_100HALF)
+		result |= ADVERTISED_100baseT_Half;
+	if (adv & ADVERTISE_100FULL)
+		result |= ADVERTISED_100baseT_Full;
+	if (adv & ADVERTISE_PAUSE_CAP)
+		result |= ADVERTISED_Pause;
+	if (adv & ADVERTISE_PAUSE_ASYM)
+		result |= ADVERTISED_Asym_Pause;
+
+	return result;
+}
+
+/**
+ * ethtool_adv_to_mii_1000T
+ * @ethadv: the ethtool advertisement settings
+ *
+ * A small helper function that translates ethtool advertisement
+ * settings to phy autonegotiation advertisements for the
+ * MII_CTRL1000 register when in 1000T mode.
+ */
+static inline u32 ethtool_adv_to_mii_1000T(u32 ethadv)
+{
+	u32 result = 0;
+
+	if (ethadv & ADVERTISED_1000baseT_Half)
+		result |= ADVERTISE_1000HALF;
+	if (ethadv & ADVERTISED_1000baseT_Full)
+		result |= ADVERTISE_1000FULL;
+
+	return result;
+}
+
+/**
+ * mii_adv_to_ethtool_1000T
+ * @adv: value of the MII_CTRL1000 register
+ *
+ * A small helper function that translates MII_CTRL1000
+ * bits, when in 1000Base-T mode, to ethtool
+ * advertisement settings.
+ */
+static inline u32 mii_adv_to_ethtool_1000T(u32 adv)
+{
+	u32 result = 0;
+
+	if (adv & ADVERTISE_1000HALF)
+		result |= ADVERTISED_1000baseT_Half;
+	if (adv & ADVERTISE_1000FULL)
+		result |= ADVERTISED_1000baseT_Full;
+
+	return result;
+}
+
+#define mii_lpa_to_ethtool_100bt(lpa)	mii_adv_to_ethtool_100bt(lpa)
+
+/**
+ * mii_lpa_to_ethtool_1000T
+ * @adv: value of the MII_STAT1000 register
+ *
+ * A small helper function that translates MII_STAT1000
+ * bits, when in 1000Base-T mode, to ethtool
+ * advertisement settings.
+ */
+static inline u32 mii_lpa_to_ethtool_1000T(u32 lpa)
+{
+	u32 result = 0;
+
+	if (lpa & LPA_1000HALF)
+		result |= ADVERTISED_1000baseT_Half;
+	if (lpa & LPA_1000FULL)
+		result |= ADVERTISED_1000baseT_Full;
+
+	return result;
+}
+
+/**
+ * ethtool_adv_to_mii_1000X
+ * @ethadv: the ethtool advertisement settings
+ *
+ * A small helper function that translates ethtool advertisement
+ * settings to phy autonegotiation advertisements for the
+ * MII_CTRL1000 register when in 1000Base-X mode.
+ */
+static inline u32 ethtool_adv_to_mii_1000X(u32 ethadv)
+{
+	u32 result = 0;
+
+	if (ethadv & ADVERTISED_1000baseT_Half)
+		result |= ADVERTISE_1000XHALF;
+	if (ethadv & ADVERTISED_1000baseT_Full)
+		result |= ADVERTISE_1000XFULL;
+	if (ethadv & ADVERTISED_Pause)
+		result |= ADVERTISE_1000XPAUSE;
+	if (ethadv & ADVERTISED_Asym_Pause)
+		result |= ADVERTISE_1000XPSE_ASYM;
+
+	return result;
+}
+
+/**
+ * mii_adv_to_ethtool_1000X
+ * @adv: value of the MII_CTRL1000 register
+ *
+ * A small helper function that translates MII_CTRL1000
+ * bits, when in 1000Base-X mode, to ethtool
+ * advertisement settings.
+ */
+static inline u32 mii_adv_to_ethtool_1000X(u32 adv)
+{
+	u32 result = 0;
+
+	if (adv & ADVERTISE_1000XHALF)
+		result |= ADVERTISED_1000baseT_Half;
+	if (adv & ADVERTISE_1000XFULL)
+		result |= ADVERTISED_1000baseT_Full;
+	if (adv & ADVERTISE_1000XPAUSE)
+		result |= ADVERTISED_Pause;
+	if (adv & ADVERTISE_1000XPSE_ASYM)
+		result |= ADVERTISED_Asym_Pause;
+
+	return result;
+}
+
+/**
  * mii_advertise_flowctrl - get flow control advertisement flags
  * @cap: Flow control capabilities (FLOW_CTRL_RX, FLOW_CTRL_TX or both)
  */
-- 
1.7.3.4
