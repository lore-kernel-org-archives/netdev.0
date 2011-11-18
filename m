From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH] Change mii to ethtool advertisement function names
Date: Thu, 17 Nov 2011 16:30:55 -0800
Message-ID: <1321576255-29827-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1300 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266Ab1KRAaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 19:30:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements advice by Ben Hutchings to change the mii side of
the function names to look more like the register whose values they
convert.  New LPA translation functions have been added as well.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   20 +++++-----
 drivers/net/ethernet/broadcom/tg3.c  |   10 +++---
 drivers/net/ethernet/sun/niu.c       |    4 +-
 drivers/net/mii.c                    |   15 ++++----
 drivers/net/phy/phy_device.c         |    4 +-
 include/linux/mii.h                  |   64 ++++++++++++++++++++++++++--------
 6 files changed, 75 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 6b7cd1e..0bc39e6 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2054,8 +2054,8 @@ __acquires(&bp->phy_lock)
 
 	if (bp->autoneg & AUTONEG_SPEED) {
 		u32 adv_reg, adv1000_reg;
-		u32 new_adv_reg = 0;
-		u32 new_adv1000_reg = 0;
+		u32 new_adv = 0;
+		u32 new_adv1000 = 0;
 
 		bnx2_read_phy(bp, bp->mii_adv, &adv_reg);
 		adv_reg &= (PHY_ALL_10_100_SPEED | ADVERTISE_PAUSE_CAP |
@@ -2064,18 +2064,18 @@ __acquires(&bp->phy_lock)
 		bnx2_read_phy(bp, MII_CTRL1000, &adv1000_reg);
 		adv1000_reg &= PHY_ALL_1000_SPEED;
 
-		new_adv_reg = ethtool_adv_to_mii_100bt(bp->advertising);
-		new_adv_reg |= ADVERTISE_CSMA;
-		new_adv_reg |= bnx2_phy_get_pause_adv(bp);
+		new_adv = ethtool_adv_to_mii_adv_t(bp->advertising);
+		new_adv |= ADVERTISE_CSMA;
+		new_adv |= bnx2_phy_get_pause_adv(bp);
 
-		new_adv1000_reg |= ethtool_adv_to_mii_1000T(bp->advertising);
+		new_adv1000 |= ethtool_adv_to_mii_ctrl1000_t(bp->advertising);
 
-		if ((adv1000_reg != new_adv1000_reg) ||
-			(adv_reg != new_adv_reg) ||
+		if ((adv1000_reg != new_adv1000) ||
+			(adv_reg != new_adv) ||
 			((bmcr & BMCR_ANENABLE) == 0)) {
 
-			bnx2_write_phy(bp, bp->mii_adv, new_adv_reg);
-			bnx2_write_phy(bp, MII_CTRL1000, new_adv1000_reg);
+			bnx2_write_phy(bp, bp->mii_adv, new_adv);
+			bnx2_write_phy(bp, MII_CTRL1000, new_adv1000);
 			bnx2_write_phy(bp, bp->mii_bmcr, BMCR_ANRESTART |
 				BMCR_ANENABLE);
 		}
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 024ca1d..47c0e3a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3594,7 +3594,7 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 	u32 val, new_adv;
 
 	new_adv = ADVERTISE_CSMA;
-	new_adv |= ethtool_adv_to_mii_100bt(advertise);
+	new_adv |= ethtool_adv_to_mii_adv_t(advertise);
 	new_adv |= tg3_advert_flowctrl_1000T(flowctrl);
 
 	err = tg3_writephy(tp, MII_ADVERTISE, new_adv);
@@ -3604,7 +3604,7 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u32 advertise, u32 flowctrl)
 	if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
 		goto done;
 
-	new_adv = ethtool_adv_to_mii_1000T(advertise);
+	new_adv = ethtool_adv_to_mii_ctrl1000_t(advertise);
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5701_A0 ||
 	    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0)
@@ -3778,7 +3778,7 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 {
 	u32 adv_reg, all_mask = 0;
 
-	all_mask = ethtool_adv_to_mii_100bt(mask);
+	all_mask = ethtool_adv_to_mii_adv_t(mask);
 
 	if (tg3_readphy(tp, MII_ADVERTISE, &adv_reg))
 		return 0;
@@ -3789,7 +3789,7 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
 		u32 tg3_ctrl;
 
-		all_mask = ethtool_adv_to_mii_1000T(mask);
+		all_mask = ethtool_adv_to_mii_ctrl1000_t(mask);
 
 		if (tg3_readphy(tp, MII_CTRL1000, &tg3_ctrl))
 			return 0;
@@ -4889,7 +4889,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 				 ADVERTISE_SLCT);
 
 		newadv |= tg3_advert_flowctrl_1000X(tp->link_config.flowctrl);
-		newadv |= ethtool_adv_to_mii_1000X(tp->link_config.advertising);
+		newadv |= ethtool_adv_to_mii_adv_x(tp->link_config.advertising);
 
 		if ((newadv != adv) || !(bmcr & BMCR_ANENABLE)) {
 			tg3_writephy(tp, MII_ADVERTISE, newadv);
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 9997be5..680b107 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -1151,8 +1151,8 @@ static int link_status_mii(struct niu *np, int *link_up_p)
 		supported |= SUPPORTED_1000baseT_Full;
 	lp->supported = supported;
 
-	advertising = mii_adv_to_ethtool_100bt(advert);
-	advertising |= mii_adv_to_ethtool_1000T(ctrl1000);
+	advertising = mii_adv_to_ethtool_adv_t(advert);
+	advertising |= mii_ctrl1000_to_ethtool_adv_t(ctrl1000);
 
 	if (bmcr & BMCR_ANENABLE) {
 		int neg, neg1000;
diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index d0a2962..c70c233 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -35,14 +35,11 @@
 
 static u32 mii_get_an(struct mii_if_info *mii, u16 addr)
 {
-	u32 result = 0;
 	int advert;
 
 	advert = mii->mdio_read(mii->dev, mii->phy_id, addr);
-	if (advert & LPA_LPACK)
-		result |= ADVERTISED_Autoneg;
 
-	return result | mii_adv_to_ethtool_100bt(advert);
+	return mii_lpa_to_ethtool_lpa_t(advert);
 }
 
 /**
@@ -93,12 +90,13 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 
 		ecmd->advertising |= mii_get_an(mii, MII_ADVERTISE);
 		if (mii->supports_gmii)
-			ecmd->advertising |= mii_adv_to_ethtool_1000T(ctrl1000);
+			ecmd->advertising |=
+					mii_ctrl1000_to_ethtool_adv_t(ctrl1000);
 
 		if (bmsr & BMSR_ANEGCOMPLETE) {
 			ecmd->lp_advertising = mii_get_an(mii, MII_LPA);
 			ecmd->lp_advertising |=
-					     mii_lpa_to_ethtool_1000T(stat1000);
+					mii_stat1000_to_ethtool_lpa_t(stat1000);
 		} else {
 			ecmd->lp_advertising = 0;
 		}
@@ -186,10 +184,11 @@ int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 			advert2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
 			tmp2 = advert2 & ~(ADVERTISE_1000HALF | ADVERTISE_1000FULL);
 		}
-		tmp |= ethtool_adv_to_mii_100bt(ecmd->advertising);
+		tmp |= ethtool_adv_to_mii_adv_t(ecmd->advertising);
 
 		if (mii->supports_gmii)
-			tmp2 |= ethtool_adv_to_mii_1000T(ecmd->advertising);
+			tmp2 |=
+			      ethtool_adv_to_mii_ctrl1000_t(ecmd->advertising);
 		if (advert != tmp) {
 			mii->mdio_write(dev, mii->phy_id, MII_ADVERTISE, tmp);
 			mii->advertising = tmp;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index edb905f..f320f46 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -565,7 +565,7 @@ static int genphy_config_advert(struct phy_device *phydev)
 
 	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP |
 		 ADVERTISE_PAUSE_ASYM);
-	adv |= ethtool_adv_to_mii_100bt(advertise);
+	adv |= ethtool_adv_to_mii_adv_t(advertise);
 
 	if (adv != oldadv) {
 		err = phy_write(phydev, MII_ADVERTISE, adv);
@@ -584,7 +584,7 @@ static int genphy_config_advert(struct phy_device *phydev)
 			return adv;
 
 		adv &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
-		adv |= ethtool_adv_to_mii_1000T(advertise);
+		adv |= ethtool_adv_to_mii_ctrl1000_t(advertise);
 
 		if (adv != oldadv) {
 			err = phy_write(phydev, MII_CTRL1000, adv);
diff --git a/include/linux/mii.h b/include/linux/mii.h
index 6697b91..2783eca 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -241,14 +241,14 @@ static inline unsigned int mii_duplex (unsigned int duplex_lock,
 }
 
 /**
- * ethtool_adv_to_mii_100bt
+ * ethtool_adv_to_mii_adv_t
  * @ethadv: the ethtool advertisement settings
  *
  * A small helper function that translates ethtool advertisement
  * settings to phy autonegotiation advertisements for the
  * MII_ADVERTISE register.
  */
-static inline u32 ethtool_adv_to_mii_100bt(u32 ethadv)
+static inline u32 ethtool_adv_to_mii_adv_t(u32 ethadv)
 {
 	u32 result = 0;
 
@@ -269,13 +269,13 @@ static inline u32 ethtool_adv_to_mii_100bt(u32 ethadv)
 }
 
 /**
- * mii_adv_to_ethtool_100bt
+ * mii_adv_to_ethtool_adv_t
  * @adv: value of the MII_ADVERTISE register
  *
  * A small helper function that translates MII_ADVERTISE bits
  * to ethtool advertisement settings.
  */
-static inline u32 mii_adv_to_ethtool_100bt(u32 adv)
+static inline u32 mii_adv_to_ethtool_adv_t(u32 adv)
 {
 	u32 result = 0;
 
@@ -296,14 +296,14 @@ static inline u32 mii_adv_to_ethtool_100bt(u32 adv)
 }
 
 /**
- * ethtool_adv_to_mii_1000T
+ * ethtool_adv_to_mii_ctrl1000_t
  * @ethadv: the ethtool advertisement settings
  *
  * A small helper function that translates ethtool advertisement
  * settings to phy autonegotiation advertisements for the
  * MII_CTRL1000 register when in 1000T mode.
  */
-static inline u32 ethtool_adv_to_mii_1000T(u32 ethadv)
+static inline u32 ethtool_adv_to_mii_ctrl1000_t(u32 ethadv)
 {
 	u32 result = 0;
 
@@ -316,14 +316,14 @@ static inline u32 ethtool_adv_to_mii_1000T(u32 ethadv)
 }
 
 /**
- * mii_adv_to_ethtool_1000T
+ * mii_ctrl1000_to_ethtool_adv_t
  * @adv: value of the MII_CTRL1000 register
  *
  * A small helper function that translates MII_CTRL1000
  * bits, when in 1000Base-T mode, to ethtool
  * advertisement settings.
  */
-static inline u32 mii_adv_to_ethtool_1000T(u32 adv)
+static inline u32 mii_ctrl1000_to_ethtool_adv_t(u32 adv)
 {
 	u32 result = 0;
 
@@ -335,17 +335,33 @@ static inline u32 mii_adv_to_ethtool_1000T(u32 adv)
 	return result;
 }
 
-#define mii_lpa_to_ethtool_100bt(lpa)	mii_adv_to_ethtool_100bt(lpa)
+/**
+ * mii_lpa_to_ethtool_lpa_t
+ * @adv: value of the MII_LPA register
+ *
+ * A small helper function that translates MII_LPA
+ * bits, when in 1000Base-T mode, to ethtool
+ * LP advertisement settings.
+ */
+static inline u32 mii_lpa_to_ethtool_lpa_t(u32 lpa)
+{
+	u32 result = 0;
+
+	if (lpa & LPA_LPACK)
+		result |= ADVERTISED_Autoneg;
+
+	return result | mii_adv_to_ethtool_adv_t(lpa);
+}
 
 /**
- * mii_lpa_to_ethtool_1000T
+ * mii_stat1000_to_ethtool_lpa_t
  * @adv: value of the MII_STAT1000 register
  *
  * A small helper function that translates MII_STAT1000
  * bits, when in 1000Base-T mode, to ethtool
  * advertisement settings.
  */
-static inline u32 mii_lpa_to_ethtool_1000T(u32 lpa)
+static inline u32 mii_stat1000_to_ethtool_lpa_t(u32 lpa)
 {
 	u32 result = 0;
 
@@ -358,14 +374,14 @@ static inline u32 mii_lpa_to_ethtool_1000T(u32 lpa)
 }
 
 /**
- * ethtool_adv_to_mii_1000X
+ * ethtool_adv_to_mii_adv_x
  * @ethadv: the ethtool advertisement settings
  *
  * A small helper function that translates ethtool advertisement
  * settings to phy autonegotiation advertisements for the
  * MII_CTRL1000 register when in 1000Base-X mode.
  */
-static inline u32 ethtool_adv_to_mii_1000X(u32 ethadv)
+static inline u32 ethtool_adv_to_mii_adv_x(u32 ethadv)
 {
 	u32 result = 0;
 
@@ -382,14 +398,14 @@ static inline u32 ethtool_adv_to_mii_1000X(u32 ethadv)
 }
 
 /**
- * mii_adv_to_ethtool_1000X
+ * mii_adv_to_ethtool_adv_x
  * @adv: value of the MII_CTRL1000 register
  *
  * A small helper function that translates MII_CTRL1000
  * bits, when in 1000Base-X mode, to ethtool
  * advertisement settings.
  */
-static inline u32 mii_adv_to_ethtool_1000X(u32 adv)
+static inline u32 mii_adv_to_ethtool_adv_x(u32 adv)
 {
 	u32 result = 0;
 
@@ -406,6 +422,24 @@ static inline u32 mii_adv_to_ethtool_1000X(u32 adv)
 }
 
 /**
+ * mii_lpa_to_ethtool_lpa_x
+ * @adv: value of the MII_LPA register
+ *
+ * A small helper function that translates MII_LPA
+ * bits, when in 1000Base-X mode, to ethtool
+ * LP advertisement settings.
+ */
+static inline u32 mii_lpa_to_ethtool_lpa_x(u32 lpa)
+{
+	u32 result = 0;
+
+	if (lpa & LPA_LPACK)
+		result |= ADVERTISED_Autoneg;
+
+	return result | mii_adv_to_ethtool_adv_x(lpa);
+}
+
+/**
  * mii_advertise_flowctrl - get flow control advertisement flags
  * @cap: Flow control capabilities (FLOW_CTRL_RX, FLOW_CTRL_TX or both)
  */
-- 
1.7.3.4
