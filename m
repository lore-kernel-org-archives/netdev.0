From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 13/16] sfc: Use generic MDIO flow control auto-negotiation
	functions
Date: Wed, 29 Apr 2009 19:20:37 +0100
Message-ID: <1241029237.3246.64.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:56437 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757839AbZD2SUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:20:39 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c    |    3 ++-
 drivers/net/sfc/mdio_10g.c   |   22 +---------------------
 drivers/net/sfc/mdio_10g.h   |    3 ---
 drivers/net/sfc/net_driver.h |   26 ++++----------------------
 drivers/net/sfc/tenxpress.c  |    1 -
 5 files changed, 7 insertions(+), 48 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 1c7b684..997ea2a 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -711,7 +711,8 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 	mutex_lock(&efx->mac_lock);
 
 	efx->wanted_fc = wanted_fc;
-	efx_mdio_set_pause(efx);
+	if (efx->phy_op->mmds & MDIO_DEVS_AN)
+		mdio45_ethtool_spauseparam_an(&efx->mdio, pause);
 	__efx_reconfigure_port(efx);
 
 	mutex_unlock(&efx->mac_lock);
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 11c231a..6c33459 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -304,7 +304,7 @@ int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 		else if (ecmd->advertising & (ADVERTISED_1000baseT_Half |
 					      ADVERTISED_1000baseT_Full))
 			reg |= ADVERTISE_NPAGE;
-		reg |= efx_fc_advertise(efx->wanted_fc);
+		reg |= mii_advertise_flowctrl(efx->wanted_fc);
 		efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, reg);
 
 		/* Set up the (extended) next page if necessary */
@@ -340,26 +340,6 @@ int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	return 0;
 }
 
-void efx_mdio_set_pause(struct efx_nic *efx)
-{
-	int reg;
-
-	if (efx->phy_op->mmds & MDIO_DEVS_AN) {
-		/* Set pause capability advertising */
-		reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE);
-		reg &= ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
-		reg |= efx_fc_advertise(efx->wanted_fc);
-		efx_mdio_write(efx, MDIO_MMD_AN, MDIO_AN_ADVERTISE, reg);
-
-		/* Restart auto-negotiation */
-		reg = efx_mdio_read(efx, MDIO_MMD_AN, MDIO_CTRL1);
-		if (reg & MDIO_AN_CTRL1_ENABLE) {
-			reg |= MDIO_AN_CTRL1_RESTART;
-			efx_mdio_write(efx, MDIO_MMD_AN, MDIO_CTRL1, reg);
-		}
-	}
-}
-
 enum efx_fc_type efx_mdio_get_pause(struct efx_nic *efx)
 {
 	int lpa;
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index ea4587d..6b14421 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -87,9 +87,6 @@ extern void efx_mdio_set_mmds_lpower(struct efx_nic *efx,
 /* Set (some of) the PHY settings over MDIO */
 extern int efx_mdio_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd);
 
-/* Set pause parameters to be advertised through AN (if available) */
-extern void efx_mdio_set_pause(struct efx_nic *efx);
-
 /* Get pause parameters from AN if available (otherwise return
  * requested pause parameters)
  */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 457e2f1..5eabede 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -495,8 +495,8 @@ struct efx_nic;
 
 /* Pseudo bit-mask flow control field */
 enum efx_fc_type {
-	EFX_FC_RX = 1,
-	EFX_FC_TX = 2,
+	EFX_FC_RX = FLOW_CTRL_RX,
+	EFX_FC_TX = FLOW_CTRL_TX,
 	EFX_FC_AUTO = 4,
 };
 
@@ -506,33 +506,15 @@ enum efx_mac_type {
 	EFX_XMAC = 2,
 };
 
-static inline unsigned int efx_fc_advertise(enum efx_fc_type wanted_fc)
-{
-	unsigned int adv = 0;
-	if (wanted_fc & EFX_FC_RX)
-		adv = ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
-	if (wanted_fc & EFX_FC_TX)
-		adv ^= ADVERTISE_PAUSE_ASYM;
-	return adv;
-}
-
 static inline enum efx_fc_type efx_fc_resolve(enum efx_fc_type wanted_fc,
 					      unsigned int lpa)
 {
-	unsigned int adv = efx_fc_advertise(wanted_fc);
+	BUILD_BUG_ON(EFX_FC_AUTO & (EFX_FC_RX | EFX_FC_TX));
 
 	if (!(wanted_fc & EFX_FC_AUTO))
 		return wanted_fc;
 
-	if (adv & lpa & ADVERTISE_PAUSE_CAP)
-		return EFX_FC_RX | EFX_FC_TX;
-	if (adv & lpa & ADVERTISE_PAUSE_ASYM) {
-		if (adv & ADVERTISE_PAUSE_CAP)
-			return EFX_FC_RX;
-		if (lpa & ADVERTISE_PAUSE_CAP)
-			return EFX_FC_TX;
-	}
-	return 0;
+	return mii_resolve_flowctrl_fdx(mii_advertise_flowctrl(wanted_fc), lpa);
 }
 
 /**
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 403f7d7..0421190 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -343,7 +343,6 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	rc = tenxpress_init(efx);
 	if (rc < 0)
 		goto fail;
-	efx_mdio_set_pause(efx);
 
 	if (efx->phy_type == PHY_TYPE_SFT9001B) {
 		rc = device_create_file(&efx->pci_dev->dev,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

