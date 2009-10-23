From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 26/27] sfc: Remove unused code for non-autoneg speed/duplex
	switching
Date: Fri, 23 Oct 2009 19:33:27 +0100
Message-ID: <1256322807.2785.55.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8995 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036AbZJWSdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:33:25 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only multi-speed PHY driver using this is 10Xpress, and it does
not support non-autoneg operation.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c |  108 ++++++++++++++++----------------------------
 1 files changed, 39 insertions(+), 69 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 25fb20a..231e580 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -248,7 +248,7 @@ void efx_mdio_set_mmds_lpower(struct efx_nic *efx,
 int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
 	struct ethtool_cmd prev;
-	u32 required;
+	bool xnp;
 	int reg;
 
 	efx->phy_op->get_settings(efx, &prev);
@@ -265,76 +265,46 @@ int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 		return -EINVAL;
 
 	/* Check that PHY supports these settings */
-	if (ecmd->autoneg) {
-		required = SUPPORTED_Autoneg;
-	} else if (ecmd->duplex) {
-		switch (ecmd->speed) {
-		case SPEED_10:  required = SUPPORTED_10baseT_Full;  break;
-		case SPEED_100: required = SUPPORTED_100baseT_Full; break;
-		default:        return -EINVAL;
-		}
-	} else {
-		switch (ecmd->speed) {
-		case SPEED_10:  required = SUPPORTED_10baseT_Half;  break;
-		case SPEED_100: required = SUPPORTED_100baseT_Half; break;
-		default:        return -EINVAL;
-		}
-	}
-	required |= ecmd->advertising;
-	if (required & ~prev.supported)
+	if (!ecmd->autoneg ||
+	    (ecmd->advertising | SUPPORTED_Autoneg) & ~prev.supported)
 		return -EINVAL;
 
-	if (ecmd->autoneg) {
-		bool xnp = (ecmd->advertising & ADVERTISED_10000baseT_Full
-			    || EFX_WORKAROUND_13204(efx));
-
-		/* Set up the base page */
-		reg = ADVERTISE_CSMA;
-		if (ecmd->advertising & ADVERTISED_10baseT_Half)
-			reg |= ADVERTISE_10HALF;
-		if (ecmd->advertising & ADVERTISED_10baseT_Full)
-			reg |= ADVERTISE_10FULL;
-		if (ecmd->advertising & ADVERTISED_100baseT_Half)
-			reg |= ADVERTISE_100HALF;
-		if (ecmd->advertising & ADVERTISED_100baseT_Full)
-			reg |= ADVERTISE_100FULL;
-		if (xnp)
-			reg |= ADVERTISE_RESV;
-		else if (ecmd->advertising & (ADVERTISED_1000baseT_Half |
-					      ADVERTISED_1000baseT_Full))
-			reg |= ADVERTISE_NPAGE;
-		reg |= mii_advertise_flowctrl(efx->wanted_fc);
-		efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, reg);
-
-		/* Set up the (extended) next page if necessary */
-		if (efx->phy_op->set_npage_adv)
-			efx->phy_op->set_npage_adv(efx, ecmd->advertising);
-
-		/* Enable and restart AN */
-		reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_CTRL1);
-		reg |= MDIO_AN_CTRL1_ENABLE;
-		if (!(EFX_WORKAROUND_15195(efx) &&
-		      LOOPBACK_MASK(efx) & efx->phy_op->loopbacks))
-			reg |= MDIO_AN_CTRL1_RESTART;
-		if (xnp)
-			reg |= MDIO_AN_CTRL1_XNP;
-		else
-			reg &= ~MDIO_AN_CTRL1_XNP;
-		efx_mdio_write(efx, MDIO_MMD_AN, MDIO_CTRL1, reg);
-	} else {
-		/* Disable AN */
-		efx_mdio_set_flag(efx, MDIO_MMD_AN, MDIO_CTRL1,
-				  MDIO_AN_CTRL1_ENABLE, false);
-
-		/* Set the basic control bits */
-		reg = efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1);
-		reg &= ~(MDIO_CTRL1_SPEEDSEL | MDIO_CTRL1_FULLDPLX);
-		if (ecmd->speed == SPEED_100)
-			reg |= MDIO_PMA_CTRL1_SPEED100;
-		if (ecmd->duplex)
-			reg |= MDIO_CTRL1_FULLDPLX;
-		efx_mdio_write(efx, MDIO_MMD_PMAPMD, MDIO_CTRL1, reg);
-	}
+	xnp = (ecmd->advertising & ADVERTISED_10000baseT_Full
+	       || EFX_WORKAROUND_13204(efx));
+
+	/* Set up the base page */
+	reg = ADVERTISE_CSMA;
+	if (ecmd->advertising & ADVERTISED_10baseT_Half)
+		reg |= ADVERTISE_10HALF;
+	if (ecmd->advertising & ADVERTISED_10baseT_Full)
+		reg |= ADVERTISE_10FULL;
+	if (ecmd->advertising & ADVERTISED_100baseT_Half)
+		reg |= ADVERTISE_100HALF;
+	if (ecmd->advertising & ADVERTISED_100baseT_Full)
+		reg |= ADVERTISE_100FULL;
+	if (xnp)
+		reg |= ADVERTISE_RESV;
+	else if (ecmd->advertising & (ADVERTISED_1000baseT_Half |
+				      ADVERTISED_1000baseT_Full))
+		reg |= ADVERTISE_NPAGE;
+	reg |= mii_advertise_flowctrl(efx->wanted_fc);
+	efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, reg);
+
+	/* Set up the (extended) next page if necessary */
+	if (efx->phy_op->set_npage_adv)
+		efx->phy_op->set_npage_adv(efx, ecmd->advertising);
+
+	/* Enable and restart AN */
+	reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_CTRL1);
+	reg |= MDIO_AN_CTRL1_ENABLE;
+	if (!(EFX_WORKAROUND_15195(efx) &&
+	      LOOPBACK_MASK(efx) & efx->phy_op->loopbacks))
+		reg |= MDIO_AN_CTRL1_RESTART;
+	if (xnp)
+		reg |= MDIO_AN_CTRL1_XNP;
+	else
+		reg &= ~MDIO_AN_CTRL1_XNP;
+	efx_mdio_write(efx, MDIO_MMD_AN, MDIO_CTRL1, reg);
 
 	return 0;
 }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

