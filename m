From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 13/20] sfc: SFX7101/SFT9001: Fix AN advertisements
Date: Thu, 29 Jan 2009 19:20:24 +0000
Message-ID: <1233256824.3656.37.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:34073 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753887AbZA2TU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:20:27 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All 10Xpress PHYs require autonegotiation all the time; enforce this
in the set_settings() method and do not treat it as a workaround.

Remove claimed support for 100M HD mode since it is not supported by
current firmware.

Do not set speed override bits when AN is enabled, and do not use
register 1.49192 for AN configuration as it can override what we set
elsewhere.

Always set the AN selector bits to 1 (802.3).

Fix confusion between Next Page and Extended Next Page.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c     |    3 -
 drivers/net/sfc/mdio_10g.c    |  177 ++++++++++++++++++-----------------------
 drivers/net/sfc/mdio_10g.h    |    3 +-
 drivers/net/sfc/net_driver.h  |    4 +-
 drivers/net/sfc/tenxpress.c   |  151 +++++++++++++---------------------
 drivers/net/sfc/workarounds.h |    4 -
 6 files changed, 141 insertions(+), 201 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 53d259e..7b5924c 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -219,9 +219,6 @@ int efx_ethtool_set_settings(struct net_device *net_dev,
 	struct efx_nic *efx = netdev_priv(net_dev);
 	int rc;
 
-	if (EFX_WORKAROUND_13963(efx) && !ecmd->autoneg)
-		return -EINVAL;
-
 	/* Falcon GMAC does not support 1000Mbps HD */
 	if (ecmd->speed == SPEED_1000 && ecmd->duplex != DUPLEX_FULL) {
 		EFX_LOG(efx, "rejecting unsupported 1000Mbps HD"
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index c1a6b26..4462fb5 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -267,7 +267,7 @@ void mdio_clause45_set_mmds_lpower(struct efx_nic *efx,
 	}
 }
 
-static u32 mdio_clause45_get_an(struct efx_nic *efx, u16 addr, u32 xnp)
+static u32 mdio_clause45_get_an(struct efx_nic *efx, u16 addr)
 {
 	int phy_id = efx->mii.phy_id;
 	u32 result = 0;
@@ -282,9 +282,6 @@ static u32 mdio_clause45_get_an(struct efx_nic *efx, u16 addr, u32 xnp)
 		result |= ADVERTISED_100baseT_Half;
 	if (reg & ADVERTISE_100FULL)
 		result |= ADVERTISED_100baseT_Full;
-	if (reg & LPA_RESV)
-		result |= xnp;
-
 	return result;
 }
 
@@ -314,7 +311,7 @@ void mdio_clause45_get_settings(struct efx_nic *efx,
  */
 void mdio_clause45_get_settings_ext(struct efx_nic *efx,
 				    struct ethtool_cmd *ecmd,
-				    u32 xnp, u32 xnp_lpa)
+				    u32 npage_adv, u32 npage_lpa)
 {
 	int phy_id = efx->mii.phy_id;
 	int reg;
@@ -365,8 +362,8 @@ void mdio_clause45_get_settings_ext(struct efx_nic *efx,
 			ecmd->autoneg = AUTONEG_ENABLE;
 			ecmd->advertising |=
 				ADVERTISED_Autoneg |
-				mdio_clause45_get_an(efx,
-						     MDIO_AN_ADVERTISE, xnp);
+				mdio_clause45_get_an(efx, MDIO_AN_ADVERTISE) |
+				npage_adv;
 		} else
 			ecmd->autoneg = AUTONEG_DISABLE;
 	} else
@@ -375,27 +372,30 @@ void mdio_clause45_get_settings_ext(struct efx_nic *efx,
 	if (ecmd->autoneg) {
 		/* If AN is complete, report best common mode,
 		 * otherwise report best advertised mode. */
-		u32 common = ecmd->advertising;
+		u32 modes = 0;
 		if (mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
 				       MDIO_MMDREG_STAT1) &
-		    (1 << MDIO_AN_STATUS_AN_DONE_LBN)) {
-			common &= mdio_clause45_get_an(efx, MDIO_AN_LPA,
-						       xnp_lpa);
-		}
-		if (common & ADVERTISED_10000baseT_Full) {
+		    (1 << MDIO_AN_STATUS_AN_DONE_LBN))
+			modes = (ecmd->advertising &
+				 (mdio_clause45_get_an(efx, MDIO_AN_LPA) |
+				  npage_lpa));
+		if (modes == 0)
+			modes = ecmd->advertising;
+
+		if (modes & ADVERTISED_10000baseT_Full) {
 			ecmd->speed = SPEED_10000;
 			ecmd->duplex = DUPLEX_FULL;
-		} else if (common & (ADVERTISED_1000baseT_Full |
-				     ADVERTISED_1000baseT_Half)) {
+		} else if (modes & (ADVERTISED_1000baseT_Full |
+				    ADVERTISED_1000baseT_Half)) {
 			ecmd->speed = SPEED_1000;
-			ecmd->duplex = !!(common & ADVERTISED_1000baseT_Full);
-		} else if (common & (ADVERTISED_100baseT_Full |
-				     ADVERTISED_100baseT_Half)) {
+			ecmd->duplex = !!(modes & ADVERTISED_1000baseT_Full);
+		} else if (modes & (ADVERTISED_100baseT_Full |
+				    ADVERTISED_100baseT_Half)) {
 			ecmd->speed = SPEED_100;
-			ecmd->duplex = !!(common & ADVERTISED_100baseT_Full);
+			ecmd->duplex = !!(modes & ADVERTISED_100baseT_Full);
 		} else {
 			ecmd->speed = SPEED_10;
-			ecmd->duplex = !!(common & ADVERTISED_10baseT_Full);
+			ecmd->duplex = !!(modes & ADVERTISED_10baseT_Full);
 		}
 	} else {
 		/* Report forced settings */
@@ -419,7 +419,7 @@ int mdio_clause45_set_settings(struct efx_nic *efx,
 	int phy_id = efx->mii.phy_id;
 	struct ethtool_cmd prev;
 	u32 required;
-	int ctrl1_bits, reg;
+	int reg;
 
 	efx->phy_op->get_settings(efx, &prev);
 
@@ -434,102 +434,83 @@ int mdio_clause45_set_settings(struct efx_nic *efx,
 	if (prev.port != PORT_TP || ecmd->port != PORT_TP)
 		return -EINVAL;
 
-	/* Check that PHY supports these settings and work out the
-	 * basic control bits */
-	if (ecmd->duplex) {
+	/* Check that PHY supports these settings */
+	if (ecmd->autoneg) {
+		required = SUPPORTED_Autoneg;
+	} else if (ecmd->duplex) {
 		switch (ecmd->speed) {
-		case SPEED_10:
-			ctrl1_bits = BMCR_FULLDPLX;
-			required = SUPPORTED_10baseT_Full;
-			break;
-		case SPEED_100:
-			ctrl1_bits = BMCR_SPEED100 | BMCR_FULLDPLX;
-			required = SUPPORTED_100baseT_Full;
-			break;
-		case SPEED_1000:
-			ctrl1_bits = BMCR_SPEED1000 | BMCR_FULLDPLX;
-			required = SUPPORTED_1000baseT_Full;
-			break;
-		case SPEED_10000:
-			ctrl1_bits = (BMCR_SPEED1000 | BMCR_SPEED100 |
-				      BMCR_FULLDPLX);
-			required = SUPPORTED_10000baseT_Full;
-			break;
-		default:
-			return -EINVAL;
+		case SPEED_10:  required = SUPPORTED_10baseT_Full;  break;
+		case SPEED_100: required = SUPPORTED_100baseT_Full; break;
+		default:        return -EINVAL;
 		}
 	} else {
 		switch (ecmd->speed) {
-		case SPEED_10:
-			ctrl1_bits = 0;
-			required = SUPPORTED_10baseT_Half;
-			break;
-		case SPEED_100:
-			ctrl1_bits = BMCR_SPEED100;
-			required = SUPPORTED_100baseT_Half;
-			break;
-		case SPEED_1000:
-			ctrl1_bits = BMCR_SPEED1000;
-			required = SUPPORTED_1000baseT_Half;
-			break;
-		default:
-			return -EINVAL;
+		case SPEED_10:  required = SUPPORTED_10baseT_Half;  break;
+		case SPEED_100: required = SUPPORTED_100baseT_Half; break;
+		default:        return -EINVAL;
 		}
 	}
-	if (ecmd->autoneg)
-		required |= SUPPORTED_Autoneg;
 	required |= ecmd->advertising;
 	if (required & ~prev.supported)
 		return -EINVAL;
 
-	/* Set the basic control bits */
-	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-				 MDIO_MMDREG_CTRL1);
-	reg &= ~(BMCR_SPEED1000 | BMCR_SPEED100 | BMCR_FULLDPLX | 0x003c);
-	reg |= ctrl1_bits;
-	mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD, MDIO_MMDREG_CTRL1,
-			    reg);
-
-	/* Set the AN registers */
-	if (ecmd->autoneg != prev.autoneg ||
-	    ecmd->advertising != prev.advertising) {
-		bool xnp = false;
-
-		if (efx->phy_op->set_xnp_advertise)
-			xnp = efx->phy_op->set_xnp_advertise(efx,
-							     ecmd->advertising);
-
-		if (ecmd->autoneg) {
-			reg = 0;
-			if (ecmd->advertising & ADVERTISED_10baseT_Half)
-				reg |= ADVERTISE_10HALF;
-			if (ecmd->advertising & ADVERTISED_10baseT_Full)
-				reg |= ADVERTISE_10FULL;
-			if (ecmd->advertising & ADVERTISED_100baseT_Half)
-				reg |= ADVERTISE_100HALF;
-			if (ecmd->advertising & ADVERTISED_100baseT_Full)
-				reg |= ADVERTISE_100FULL;
-			if (xnp)
-				reg |= ADVERTISE_RESV;
-			mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
-					    MDIO_AN_ADVERTISE, reg);
-		}
+	if (ecmd->autoneg) {
+		bool xnp = (ecmd->advertising & ADVERTISED_10000baseT_Full
+			    || EFX_WORKAROUND_13204(efx));
+
+		/* Set up the base page */
+		reg = ADVERTISE_CSMA;
+		if (ecmd->advertising & ADVERTISED_10baseT_Half)
+			reg |= ADVERTISE_10HALF;
+		if (ecmd->advertising & ADVERTISED_10baseT_Full)
+			reg |= ADVERTISE_10FULL;
+		if (ecmd->advertising & ADVERTISED_100baseT_Half)
+			reg |= ADVERTISE_100HALF;
+		if (ecmd->advertising & ADVERTISED_100baseT_Full)
+			reg |= ADVERTISE_100FULL;
+		if (xnp)
+			reg |= ADVERTISE_RESV;
+		else if (ecmd->advertising & (ADVERTISED_1000baseT_Half |
+					      ADVERTISED_1000baseT_Full))
+			reg |= ADVERTISE_NPAGE;
+		reg |= efx_fc_advertise(efx->wanted_fc);
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
+				    MDIO_AN_ADVERTISE, reg);
+
+		/* Set up the (extended) next page if necessary */
+		if (efx->phy_op->set_npage_adv)
+			efx->phy_op->set_npage_adv(efx, ecmd->advertising);
 
+		/* Enable and restart AN */
 		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
 					 MDIO_MMDREG_CTRL1);
-		if (ecmd->autoneg)
-			reg |= BMCR_ANENABLE | BMCR_ANRESTART;
-		else
-			reg &= ~BMCR_ANENABLE;
-		if (EFX_WORKAROUND_15195(efx)
-		    && LOOPBACK_MASK(efx) & efx->phy_op->loopbacks)
-			reg &= ~BMCR_ANRESTART;
+		reg |= BMCR_ANENABLE;
+		if (!(EFX_WORKAROUND_15195(efx) &&
+		      LOOPBACK_MASK(efx) & efx->phy_op->loopbacks))
+			reg |= BMCR_ANRESTART;
 		if (xnp)
 			reg |= 1 << MDIO_AN_CTRL_XNP_LBN;
 		else
 			reg &= ~(1 << MDIO_AN_CTRL_XNP_LBN);
 		mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
 				    MDIO_MMDREG_CTRL1, reg);
+	} else {
+		/* Disable AN */
+		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_AN,
+				       MDIO_MMDREG_CTRL1,
+				       __ffs(BMCR_ANENABLE), false);
+
+		/* Set the basic control bits */
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+					 MDIO_MMDREG_CTRL1);
+		reg &= ~(BMCR_SPEED1000 | BMCR_SPEED100 | BMCR_FULLDPLX |
+			 0x003c);
+		if (ecmd->speed == SPEED_100)
+			reg |= BMCR_SPEED100;
+		if (ecmd->duplex)
+			reg |= BMCR_FULLDPLX;
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
+				    MDIO_MMDREG_CTRL1, reg);
 	}
 
 	return 0;
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 09bf801..8ba4977 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -155,7 +155,8 @@
 #define MDIO_AN_XNP			22
 #define MDIO_AN_LPA_XNP			25
 
-#define MDIO_AN_10GBT_ADVERTISE		32
+#define MDIO_AN_10GBT_CTRL		32
+#define MDIO_AN_10GBT_CTRL_ADV_10G_LBN	12
 #define MDIO_AN_10GBT_STATUS		(33)
 #define MDIO_AN_10GBT_STATUS_MS_FLT_LBN (15) /* MASTER/SLAVE config fault */
 #define MDIO_AN_10GBT_STATUS_MS_LBN     (14) /* MASTER/SLAVE config */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 5f255f7..8eb411a 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -566,7 +566,7 @@ struct efx_mac_operations {
  * @poll: Poll for hardware state. Serialised by the mac_lock.
  * @get_settings: Get ethtool settings. Serialised by the mac_lock.
  * @set_settings: Set ethtool settings. Serialised by the mac_lock.
- * @set_xnp_advertise: Set abilities advertised in Extended Next Page
+ * @set_npage_adv: Set abilities advertised in (Extended) Next Page
  *	(only needed where AN bit is set in mmds)
  * @num_tests: Number of PHY-specific tests/results
  * @test_names: Names of the tests/results
@@ -586,7 +586,7 @@ struct efx_phy_operations {
 			      struct ethtool_cmd *ecmd);
 	int (*set_settings) (struct efx_nic *efx,
 			     struct ethtool_cmd *ecmd);
-	bool (*set_xnp_advertise) (struct efx_nic *efx, u32);
+	void (*set_npage_adv) (struct efx_nic *efx, u32);
 	u32 num_tests;
 	const char *const *test_names;
 	int (*run_tests) (struct efx_nic *efx, int *results, unsigned flags);
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 1ab14d5..b56617f 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -181,11 +181,13 @@
 #define C22EXT_STATUS_LINK_LBN  2
 #define C22EXT_STATUS_LINK_WIDTH 1
 
-#define C22EXT_MSTSLV_REG       49162
-#define C22EXT_MSTSLV_1000_HD_LBN 10
-#define C22EXT_MSTSLV_1000_HD_WIDTH 1
-#define C22EXT_MSTSLV_1000_FD_LBN 11
-#define C22EXT_MSTSLV_1000_FD_WIDTH 1
+#define C22EXT_MSTSLV_CTRL			49161
+#define C22EXT_MSTSLV_CTRL_ADV_1000_HD_LBN	8
+#define C22EXT_MSTSLV_CTRL_ADV_1000_FD_LBN	9
+
+#define C22EXT_MSTSLV_STATUS			49162
+#define C22EXT_MSTSLV_STATUS_LP_1000_HD_LBN	10
+#define C22EXT_MSTSLV_STATUS_LP_1000_FD_LBN	11
 
 /* Time to wait between powering down the LNPGA and turning off the power
  * rails */
@@ -764,114 +766,76 @@ out:
 	return rc;
 }
 
-static u32 tenxpress_get_xnp_lpa(struct efx_nic *efx)
+static void
+tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
-	int phy = efx->mii.phy_id;
-	u32 lpa = 0;
+	int phy_id = efx->mii.phy_id;
+	u32 adv = 0, lpa = 0;
 	int reg;
 
 	if (efx->phy_type != PHY_TYPE_SFX7101) {
-		reg = mdio_clause45_read(efx, phy, MDIO_MMD_C22EXT,
-					 C22EXT_MSTSLV_REG);
-		if (reg & (1 << C22EXT_MSTSLV_1000_HD_LBN))
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_C22EXT,
+					 C22EXT_MSTSLV_CTRL);
+		if (reg & (1 << C22EXT_MSTSLV_CTRL_ADV_1000_FD_LBN))
+			adv |= ADVERTISED_1000baseT_Full;
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_C22EXT,
+					 C22EXT_MSTSLV_STATUS);
+		if (reg & (1 << C22EXT_MSTSLV_STATUS_LP_1000_HD_LBN))
 			lpa |= ADVERTISED_1000baseT_Half;
-		if (reg & (1 << C22EXT_MSTSLV_1000_FD_LBN))
+		if (reg & (1 << C22EXT_MSTSLV_STATUS_LP_1000_FD_LBN))
 			lpa |= ADVERTISED_1000baseT_Full;
 	}
-	reg = mdio_clause45_read(efx, phy, MDIO_MMD_AN, MDIO_AN_10GBT_STATUS);
+	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
+				 MDIO_AN_10GBT_CTRL);
+	if (reg & (1 << MDIO_AN_10GBT_CTRL_ADV_10G_LBN))
+		adv |= ADVERTISED_10000baseT_Full;
+	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
+				 MDIO_AN_10GBT_STATUS);
 	if (reg & (1 << MDIO_AN_10GBT_STATUS_LP_10G_LBN))
 		lpa |= ADVERTISED_10000baseT_Full;
-	return lpa;
-}
-
-static void sfx7101_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
-{
-	mdio_clause45_get_settings_ext(efx, ecmd, ADVERTISED_10000baseT_Full,
-				       tenxpress_get_xnp_lpa(efx));
-	ecmd->supported |= SUPPORTED_10000baseT_Full;
-	ecmd->advertising |= ADVERTISED_10000baseT_Full;
-}
-
-static void sft9001_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
-{
-	int phy_id = efx->mii.phy_id;
-	u32 xnp_adv = 0;
-	int reg;
-
-	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
-				 PMA_PMD_SPEED_ENABLE_REG);
-	if (EFX_WORKAROUND_13204(efx) && (reg & (1 << PMA_PMD_100TX_ADV_LBN)))
-		xnp_adv |= ADVERTISED_100baseT_Full;
-	if (reg & (1 << PMA_PMD_1000T_ADV_LBN))
-		xnp_adv |= ADVERTISED_1000baseT_Full;
-	if (reg & (1 << PMA_PMD_10000T_ADV_LBN))
-		xnp_adv |= ADVERTISED_10000baseT_Full;
 
-	mdio_clause45_get_settings_ext(efx, ecmd, xnp_adv,
-				       tenxpress_get_xnp_lpa(efx));
+	mdio_clause45_get_settings_ext(efx, ecmd, adv, lpa);
 
-	ecmd->supported |= (SUPPORTED_100baseT_Half |
-			    SUPPORTED_100baseT_Full |
-			    SUPPORTED_1000baseT_Full);
-
-	/* Use the vendor defined C22ext register for duplex settings */
-	if (ecmd->speed != SPEED_10000 && !ecmd->autoneg) {
-		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_C22EXT,
-					 GPHY_XCONTROL_REG);
-		ecmd->duplex = (reg & (1 << GPHY_DUPLEX_LBN) ?
-				DUPLEX_FULL : DUPLEX_HALF);
-	}
+	if (efx->phy_type != PHY_TYPE_SFX7101)
+		ecmd->supported |= (SUPPORTED_100baseT_Full |
+				    SUPPORTED_1000baseT_Full);
 
 	/* In loopback, the PHY automatically brings up the correct interface,
 	 * but doesn't advertise the correct speed. So override it */
 	if (efx->loopback_mode == LOOPBACK_GPHY)
 		ecmd->speed = SPEED_1000;
-	else if (LOOPBACK_MASK(efx) & SFT9001_LOOPBACKS)
+	else if (LOOPBACK_MASK(efx) & efx->phy_op->loopbacks)
 		ecmd->speed = SPEED_10000;
 }
 
-static int sft9001_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+static int tenxpress_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
-	int phy_id = efx->mii.phy_id;
-	int rc;
-
-	rc = mdio_clause45_set_settings(efx, ecmd);
-	if (rc)
-		return rc;
+	if (!ecmd->autoneg)
+		return -EINVAL;
 
-	if (ecmd->speed != SPEED_10000 && !ecmd->autoneg)
-		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_C22EXT,
-				       GPHY_XCONTROL_REG, GPHY_DUPLEX_LBN,
-				       ecmd->duplex == DUPLEX_FULL);
+	return mdio_clause45_set_settings(efx, ecmd);
+}
 
-	return rc;
+static void sfx7101_set_npage_adv(struct efx_nic *efx, u32 advertising)
+{
+	mdio_clause45_set_flag(efx, efx->mii.phy_id, MDIO_MMD_AN,
+			       MDIO_AN_10GBT_CTRL,
+			       MDIO_AN_10GBT_CTRL_ADV_10G_LBN,
+			       advertising & ADVERTISED_10000baseT_Full);
 }
 
-static bool sft9001_set_xnp_advertise(struct efx_nic *efx, u32 advertising)
+static void sft9001_set_npage_adv(struct efx_nic *efx, u32 advertising)
 {
-	int phy = efx->mii.phy_id;
-	int reg = mdio_clause45_read(efx, phy, MDIO_MMD_PMAPMD,
-				     PMA_PMD_SPEED_ENABLE_REG);
-	bool enabled;
-
-	reg &= ~((1 << 2) | (1 << 3));
-	if (EFX_WORKAROUND_13204(efx) &&
-	    (advertising & ADVERTISED_100baseT_Full))
-		reg |= 1 << PMA_PMD_100TX_ADV_LBN;
-	if (advertising & ADVERTISED_1000baseT_Full)
-		reg |= 1 << PMA_PMD_1000T_ADV_LBN;
-	if (advertising & ADVERTISED_10000baseT_Full)
-		reg |= 1 << PMA_PMD_10000T_ADV_LBN;
-	mdio_clause45_write(efx, phy, MDIO_MMD_PMAPMD,
-			    PMA_PMD_SPEED_ENABLE_REG, reg);
-
-	enabled = (advertising &
-		   (ADVERTISED_1000baseT_Half |
-		    ADVERTISED_1000baseT_Full |
-		    ADVERTISED_10000baseT_Full));
-	if (EFX_WORKAROUND_13204(efx))
-		enabled |= (advertising & ADVERTISED_100baseT_Full);
-	return enabled;
+	int phy_id = efx->mii.phy_id;
+
+	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_C22EXT,
+			       C22EXT_MSTSLV_CTRL,
+			       C22EXT_MSTSLV_CTRL_ADV_1000_FD_LBN,
+			       advertising & ADVERTISED_1000baseT_Full);
+	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_AN,
+			       MDIO_AN_10GBT_CTRL,
+			       MDIO_AN_10GBT_CTRL_ADV_10G_LBN,
+			       advertising & ADVERTISED_10000baseT_Full);
 }
 
 struct efx_phy_operations falcon_sfx7101_phy_ops = {
@@ -881,8 +845,9 @@ struct efx_phy_operations falcon_sfx7101_phy_ops = {
 	.poll             = tenxpress_phy_poll,
 	.fini             = tenxpress_phy_fini,
 	.clear_interrupt  = efx_port_dummy_op_void,
-	.get_settings	  = sfx7101_get_settings,
-	.set_settings	  = mdio_clause45_set_settings,
+	.get_settings	  = tenxpress_get_settings,
+	.set_settings	  = tenxpress_set_settings,
+	.set_npage_adv    = sfx7101_set_npage_adv,
 	.num_tests	  = ARRAY_SIZE(sfx7101_test_names),
 	.test_names	  = sfx7101_test_names,
 	.run_tests	  = sfx7101_run_tests,
@@ -897,9 +862,9 @@ struct efx_phy_operations falcon_sft9001_phy_ops = {
 	.poll             = tenxpress_phy_poll,
 	.fini             = tenxpress_phy_fini,
 	.clear_interrupt  = efx_port_dummy_op_void,
-	.get_settings	  = sft9001_get_settings,
-	.set_settings	  = sft9001_set_settings,
-	.set_xnp_advertise = sft9001_set_xnp_advertise,
+	.get_settings	  = tenxpress_get_settings,
+	.set_settings	  = tenxpress_set_settings,
+	.set_npage_adv    = sft9001_set_npage_adv,
 	.num_tests	  = ARRAY_SIZE(sft9001_test_names),
 	.test_names	  = sft9001_test_names,
 	.run_tests	  = sft9001_run_tests,
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index b810dcd..78de68f 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -18,7 +18,6 @@
 #define EFX_WORKAROUND_ALWAYS(efx) 1
 #define EFX_WORKAROUND_FALCON_A(efx) (falcon_rev(efx) <= FALCON_REV_A1)
 #define EFX_WORKAROUND_10G(efx) EFX_IS10G(efx)
-#define EFX_WORKAROUND_SFT9001A(efx) ((efx)->phy_type == PHY_TYPE_SFT9001A)
 #define EFX_WORKAROUND_SFT9001(efx) ((efx)->phy_type == PHY_TYPE_SFT9001A || \
 				     (efx)->phy_type == PHY_TYPE_SFT9001B)
 
@@ -55,9 +54,6 @@
 
 /* Need to send XNP pages for 100BaseT */
 #define EFX_WORKAROUND_13204 EFX_WORKAROUND_SFT9001
-/* Need to keep AN enabled */
-#define EFX_WORKAROUND_13963 EFX_WORKAROUND_SFT9001A
-
 /* Don't restart AN in near-side loopback */
 #define EFX_WORKAROUND_15195 EFX_WORKAROUND_SFT9001
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

