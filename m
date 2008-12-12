From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 20/33] sfc: Implement auto-negotiation
Date: Fri, 12 Dec 2008 12:55:10 +0000
Message-ID: <20081212125509.GT10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:42318 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757501AbYLLMzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:55:14 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add infrastructure for auto-negotiation of speed, duplex and flow
control.

When using 10Xpress, auto-negotiate flow control.  While we're
at it, clean up the code to warn when partner is not 10GBASE-T
capable.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c     |   57 ++++++-
 drivers/net/sfc/falcon.c      |    6 +-
 drivers/net/sfc/falcon_gmac.c |    4 +-
 drivers/net/sfc/falcon_xmac.c |    2 +-
 drivers/net/sfc/mdio_10g.c    |  348 ++++++++++++++++++++++++++++++++---------
 drivers/net/sfc/mdio_10g.h    |   32 ++++
 drivers/net/sfc/net_driver.h  |   38 +++++-
 drivers/net/sfc/tenxpress.c   |  138 +++++++++--------
 drivers/net/sfc/xfp_phy.c     |    1 +
 9 files changed, 472 insertions(+), 154 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 1b33f89..0e81af6 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -12,11 +12,13 @@
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
 #include "net_driver.h"
+#include "workarounds.h"
 #include "selftest.h"
 #include "efx.h"
 #include "ethtool.h"
 #include "falcon.h"
 #include "spi.h"
+#include "mdio_10g.h"
 
 const char *efx_loopback_mode_names[] = {
 	[LOOPBACK_NONE]		= "NONE",
@@ -674,14 +676,51 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 				      struct ethtool_pauseparam *pause)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	enum efx_fc_type flow_control = efx->flow_control;
+	enum efx_fc_type wanted_fc;
+	bool reset;
 
-	flow_control &= ~(EFX_FC_RX | EFX_FC_TX | EFX_FC_AUTO);
-	flow_control |= pause->rx_pause ? EFX_FC_RX : 0;
-	flow_control |= pause->tx_pause ? EFX_FC_TX : 0;
-	flow_control |= pause->autoneg ? EFX_FC_AUTO : 0;
+	wanted_fc = ((pause->rx_pause ? EFX_FC_RX : 0) |
+		     (pause->tx_pause ? EFX_FC_TX : 0) |
+		     (pause->autoneg ? EFX_FC_AUTO : 0));
+
+	if ((wanted_fc & EFX_FC_TX) && !(wanted_fc & EFX_FC_RX)) {
+		EFX_LOG(efx, "Flow control unsupported: tx ON rx OFF\n");
+		return -EINVAL;
+	}
+
+	if (!(efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_AN)) &&
+	    (wanted_fc & EFX_FC_AUTO)) {
+		EFX_LOG(efx, "PHY does not support flow control "
+			"autonegotiation\n");
+		return -EINVAL;
+	}
+
+	/* TX flow control may automatically turn itself off if the
+	 * link partner (intermittently) stops responding to pause
+	 * frames. There isn't any indication that this has happened,
+	 * so the best we do is leave it up to the user to spot this
+	 * and fix it be cycling transmit flow control on this end. */
+	reset = (wanted_fc & EFX_FC_TX) && !(efx->wanted_fc & EFX_FC_TX);
+	if (EFX_WORKAROUND_11482(efx) && reset) {
+		if (falcon_rev(efx) >= FALCON_REV_B0) {
+			/* Recover by resetting the EM block */
+			if (efx->link_up)
+				falcon_drain_tx_fifo(efx);
+		} else {
+			/* Schedule a reset to recover */
+			efx_schedule_reset(efx, RESET_TYPE_INVISIBLE);
+		}
+	}
+
+	/* Try to push the pause parameters */
+	mutex_lock(&efx->mac_lock);
+
+	efx->wanted_fc = wanted_fc;
+	mdio_clause45_set_pause(efx);
+	__efx_reconfigure_port(efx);
+
+	mutex_unlock(&efx->mac_lock);
 
-	efx_reconfigure_port(efx);
 	return 0;
 }
 
@@ -690,9 +729,9 @@ static void efx_ethtool_get_pauseparam(struct net_device *net_dev,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	pause->rx_pause = !!(efx->flow_control & EFX_FC_RX);
-	pause->tx_pause = !!(efx->flow_control & EFX_FC_TX);
-	pause->autoneg = !!(efx->flow_control & EFX_FC_AUTO);
+	pause->rx_pause = !!(efx->wanted_fc & EFX_FC_RX);
+	pause->tx_pause = !!(efx->wanted_fc & EFX_FC_TX);
+	pause->autoneg = !!(efx->wanted_fc & EFX_FC_AUTO);
 }
 
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 22419a0..60b3b95 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2009,7 +2009,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	/* Transmission of pause frames when RX crosses the threshold is
 	 * covered by RX_XOFF_MAC_EN and XM_TX_CFG_REG:XM_FCNTL.
 	 * Action on receipt of pause frames is controller by XM_DIS_FCNTL */
-	tx_fc = !!(efx->flow_control & EFX_FC_TX);
+	tx_fc = !!(efx->link_fc & EFX_FC_TX);
 	falcon_read(efx, &reg, RX_CFG_REG_KER);
 	EFX_SET_OWORD_FIELD_VER(efx, reg, RX_XOFF_MAC_EN, tx_fc);
 
@@ -2339,9 +2339,9 @@ int falcon_probe_port(struct efx_nic *efx)
 
 	/* Hardware flow ctrl. FalconA RX FIFO too small for pause generation */
 	if (falcon_rev(efx) >= FALCON_REV_B0)
-		efx->flow_control = EFX_FC_RX | EFX_FC_TX;
+		efx->wanted_fc = EFX_FC_RX | EFX_FC_TX;
 	else
-		efx->flow_control = EFX_FC_RX;
+		efx->wanted_fc = EFX_FC_RX;
 
 	/* Allocate buffer for stats */
 	rc = falcon_alloc_buffer(efx, &efx->stats_buffer,
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gmac.c
index 247f802..b6e6eb9 100644
--- a/drivers/net/sfc/falcon_gmac.c
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -31,8 +31,8 @@ static void falcon_reconfigure_gmac(struct efx_nic *efx)
 	efx_oword_t reg;
 
 	/* Configuration register 1 */
-	tx_fc = (efx->flow_control & EFX_FC_TX) || !efx->link_fd;
-	rx_fc = !!(efx->flow_control & EFX_FC_RX);
+	tx_fc = (efx->link_fc & EFX_FC_TX) || !efx->link_fd;
+	rx_fc = !!(efx->link_fc & EFX_FC_RX);
 	loopback = (efx->loopback_mode == LOOPBACK_GMAC);
 	bytemode = (efx->link_speed == 1000);
 
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 2206ead..0ce8f01 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -142,7 +142,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 {
 	unsigned int max_frame_len;
 	efx_oword_t reg;
-	bool rx_fc = !!(efx->flow_control & EFX_FC_RX);
+	bool rx_fc = !!(efx->link_fc & EFX_FC_RX);
 
 	/* Configure MAC  - cut-thru mode is hard wired on */
 	EFX_POPULATE_DWORD_3(reg,
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 8d91131..037601e 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -47,13 +47,16 @@ static int mdio_clause45_check_mmd(struct efx_nic *efx, int mmd,
 	if (LOOPBACK_INTERNAL(efx))
 		return 0;
 
-	/* Read MMD STATUS2 to check it is responding. */
-	status = mdio_clause45_read(efx, phy_id, mmd, MDIO_MMDREG_STAT2);
-	if (((status >> MDIO_MMDREG_STAT2_PRESENT_LBN) &
-	     ((1 << MDIO_MMDREG_STAT2_PRESENT_WIDTH) - 1)) !=
-	    MDIO_MMDREG_STAT2_PRESENT_VAL) {
-		EFX_ERR(efx, "PHY MMD %d not responding.\n", mmd);
-		return -EIO;
+	if (mmd != MDIO_MMD_AN) {
+		/* Read MMD STATUS2 to check it is responding. */
+		status = mdio_clause45_read(efx, phy_id, mmd,
+					    MDIO_MMDREG_STAT2);
+		if (((status >> MDIO_MMDREG_STAT2_PRESENT_LBN) &
+		     ((1 << MDIO_MMDREG_STAT2_PRESENT_WIDTH) - 1)) !=
+		    MDIO_MMDREG_STAT2_PRESENT_VAL) {
+			EFX_ERR(efx, "PHY MMD %d not responding.\n", mmd);
+			return -EIO;
+		}
 	}
 
 	/* Read MMD STATUS 1 to check for fault. */
@@ -179,12 +182,15 @@ bool mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
 	else if (efx->loopback_mode == LOOPBACK_PHYXS)
 		mmd_mask &= ~(MDIO_MMDREG_DEVS_PHYXS |
 			      MDIO_MMDREG_DEVS_PCS |
-			      MDIO_MMDREG_DEVS_PMAPMD);
+			      MDIO_MMDREG_DEVS_PMAPMD |
+			      MDIO_MMDREG_DEVS_AN);
 	else if (efx->loopback_mode == LOOPBACK_PCS)
 		mmd_mask &= ~(MDIO_MMDREG_DEVS_PCS |
-			      MDIO_MMDREG_DEVS_PMAPMD);
+			      MDIO_MMDREG_DEVS_PMAPMD |
+			      MDIO_MMDREG_DEVS_AN);
 	else if (efx->loopback_mode == LOOPBACK_PMAPMD)
-		mmd_mask &= ~MDIO_MMDREG_DEVS_PMAPMD;
+		mmd_mask &= ~(MDIO_MMDREG_DEVS_PMAPMD |
+			      MDIO_MMDREG_DEVS_AN);
 
 	while (mmd_mask) {
 		if (mmd_mask & 1) {
@@ -244,6 +250,7 @@ void mdio_clause45_set_mmds_lpower(struct efx_nic *efx,
 				   int low_power, unsigned int mmd_mask)
 {
 	int mmd = 0;
+	mmd_mask &= ~MDIO_MMDREG_DEVS_AN;
 	while (mmd_mask) {
 		if (mmd_mask & 1)
 			mdio_clause45_set_mmd_lpower(efx, low_power, mmd);
@@ -252,103 +259,302 @@ void mdio_clause45_set_mmds_lpower(struct efx_nic *efx,
 	}
 }
 
+static u32 mdio_clause45_get_an(struct efx_nic *efx, u16 addr, u32 xnp)
+{
+	int phy_id = efx->mii.phy_id;
+	u32 result = 0;
+	int reg;
+
+	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN, addr);
+	if (reg & ADVERTISE_10HALF)
+		result |= ADVERTISED_10baseT_Half;
+	if (reg & ADVERTISE_10FULL)
+		result |= ADVERTISED_10baseT_Full;
+	if (reg & ADVERTISE_100HALF)
+		result |= ADVERTISED_100baseT_Half;
+	if (reg & ADVERTISE_100FULL)
+		result |= ADVERTISED_100baseT_Full;
+	if (reg & LPA_RESV)
+		result |= xnp;
+
+	return result;
+}
+
 /**
  * mdio_clause45_get_settings - Read (some of) the PHY settings over MDIO.
  * @efx:		Efx NIC
  * @ecmd: 		Buffer for settings
  *
  * On return the 'port', 'speed', 'supported' and 'advertising' fields of
- * ecmd have been filled out based on the PMA type.
+ * ecmd have been filled out.
  */
 void mdio_clause45_get_settings(struct efx_nic *efx,
 				struct ethtool_cmd *ecmd)
 {
-	int pma_type;
+	mdio_clause45_get_settings_ext(efx, ecmd, 0, 0);
+}
 
-	/* If no PMA is present we are presumably talking something XAUI-ish
-	 * like CX4. Which we report as FIBRE (see below) */
-	if ((efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_PMAPMD)) == 0) {
-		ecmd->speed = SPEED_10000;
-		ecmd->port = PORT_FIBRE;
-		ecmd->supported = SUPPORTED_FIBRE;
-		ecmd->advertising = ADVERTISED_FIBRE;
-		return;
-	}
+/**
+ * mdio_clause45_get_settings_ext - Read (some of) the PHY settings over MDIO.
+ * @efx:		Efx NIC
+ * @ecmd: 		Buffer for settings
+ * @xnp:		Advertised Extended Next Page state
+ * @xnp_lpa:		Link Partner's advertised XNP state
+ *
+ * On return the 'port', 'speed', 'supported' and 'advertising' fields of
+ * ecmd have been filled out.
+ */
+void mdio_clause45_get_settings_ext(struct efx_nic *efx,
+				    struct ethtool_cmd *ecmd,
+				    u32 xnp, u32 xnp_lpa)
+{
+	int phy_id = efx->mii.phy_id;
+	int reg;
 
-	pma_type = mdio_clause45_read(efx, efx->mii.phy_id,
-				      MDIO_MMD_PMAPMD, MDIO_MMDREG_CTRL2);
-	pma_type &= MDIO_PMAPMD_CTRL2_TYPE_MASK;
+	ecmd->transceiver = XCVR_INTERNAL;
+	ecmd->phy_address = phy_id;
 
-	switch (pma_type) {
-		/* We represent CX4 as fibre in the absence of anything
-		   better. */
-	case MDIO_PMAPMD_CTRL2_10G_CX4:
-		ecmd->speed = SPEED_10000;
-		ecmd->port = PORT_FIBRE;
-		ecmd->supported = SUPPORTED_FIBRE;
-		ecmd->advertising = ADVERTISED_FIBRE;
-		break;
-		/* 10G Base-T */
+	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+				 MDIO_MMDREG_CTRL2);
+	switch (reg & MDIO_PMAPMD_CTRL2_TYPE_MASK) {
 	case MDIO_PMAPMD_CTRL2_10G_BT:
-		ecmd->speed = SPEED_10000;
-		ecmd->port = PORT_TP;
-		ecmd->supported = SUPPORTED_TP | SUPPORTED_10000baseT_Full;
-		ecmd->advertising = (ADVERTISED_FIBRE
-				     | ADVERTISED_10000baseT_Full);
-		break;
 	case MDIO_PMAPMD_CTRL2_1G_BT:
-		ecmd->speed = SPEED_1000;
-		ecmd->port = PORT_TP;
-		ecmd->supported = SUPPORTED_TP | SUPPORTED_1000baseT_Full;
-		ecmd->advertising = (ADVERTISED_FIBRE
-				     | ADVERTISED_1000baseT_Full);
-		break;
 	case MDIO_PMAPMD_CTRL2_100_BT:
-		ecmd->speed = SPEED_100;
-		ecmd->port = PORT_TP;
-		ecmd->supported = SUPPORTED_TP | SUPPORTED_100baseT_Full;
-		ecmd->advertising = (ADVERTISED_FIBRE
-				     | ADVERTISED_100baseT_Full);
-		break;
 	case MDIO_PMAPMD_CTRL2_10_BT:
-		ecmd->speed = SPEED_10;
 		ecmd->port = PORT_TP;
-		ecmd->supported = SUPPORTED_TP | SUPPORTED_10baseT_Full;
-		ecmd->advertising = ADVERTISED_FIBRE | ADVERTISED_10baseT_Full;
+		ecmd->supported = SUPPORTED_TP;
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+					 MDIO_MMDREG_SPEED);
+		if (reg & (1 << MDIO_MMDREG_SPEED_10G_LBN))
+			ecmd->supported |= SUPPORTED_10000baseT_Full;
+		if (reg & (1 << MDIO_MMDREG_SPEED_1000M_LBN))
+			ecmd->supported |= (SUPPORTED_1000baseT_Full |
+					    SUPPORTED_1000baseT_Half);
+		if (reg & (1 << MDIO_MMDREG_SPEED_100M_LBN))
+			ecmd->supported |= (SUPPORTED_100baseT_Full |
+					    SUPPORTED_100baseT_Half);
+		if (reg & (1 << MDIO_MMDREG_SPEED_10M_LBN))
+			ecmd->supported |= (SUPPORTED_10baseT_Full |
+					    SUPPORTED_10baseT_Half);
+		ecmd->advertising = ADVERTISED_TP;
 		break;
-	/* All the other defined modes are flavours of
-	 * 10G optical */
+
+	/* We represent CX4 as fibre in the absence of anything better */
+	case MDIO_PMAPMD_CTRL2_10G_CX4:
+	/* All the other defined modes are flavours of optical */
 	default:
-		ecmd->speed = SPEED_10000;
 		ecmd->port = PORT_FIBRE;
 		ecmd->supported = SUPPORTED_FIBRE;
 		ecmd->advertising = ADVERTISED_FIBRE;
 		break;
 	}
+
+	if (efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_AN)) {
+		ecmd->supported |= SUPPORTED_Autoneg;
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
+					 MDIO_MMDREG_CTRL1);
+		if (reg & BMCR_ANENABLE) {
+			ecmd->autoneg = AUTONEG_ENABLE;
+			ecmd->advertising |=
+				ADVERTISED_Autoneg |
+				mdio_clause45_get_an(efx,
+						     MDIO_AN_ADVERTISE, xnp);
+		} else
+			ecmd->autoneg = AUTONEG_DISABLE;
+	} else
+		ecmd->autoneg = AUTONEG_DISABLE;
+
+	/* If AN is enabled and complete, report best common mode */
+	if (ecmd->autoneg &&
+	    (mdio_clause45_read(efx, phy_id, MDIO_MMD_AN, MDIO_MMDREG_STAT1) &
+	     (1 << MDIO_AN_STATUS_AN_DONE_LBN))) {
+		u32 common, lpa;
+		lpa = mdio_clause45_get_an(efx, MDIO_AN_LPA, xnp_lpa);
+		common = ecmd->advertising & lpa;
+		if (common & ADVERTISED_10000baseT_Full) {
+			ecmd->speed = SPEED_10000;
+			ecmd->duplex = DUPLEX_FULL;
+		} else if (common & (ADVERTISED_1000baseT_Full |
+				     ADVERTISED_1000baseT_Half)) {
+			ecmd->speed = SPEED_1000;
+			ecmd->duplex = !!(common & ADVERTISED_1000baseT_Full);
+		} else if (common & (ADVERTISED_100baseT_Full |
+				     ADVERTISED_100baseT_Half)) {
+			ecmd->speed = SPEED_100;
+			ecmd->duplex = !!(common & ADVERTISED_100baseT_Full);
+		} else {
+			ecmd->speed = SPEED_10;
+			ecmd->duplex = !!(common & ADVERTISED_10baseT_Full);
+		}
+	} else {
+		/* Report forced settings */
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+					 MDIO_MMDREG_CTRL1);
+		ecmd->speed = (((reg & BMCR_SPEED1000) ? 100 : 1) *
+			       ((reg & BMCR_SPEED100) ? 100 : 10));
+		ecmd->duplex = (reg & BMCR_FULLDPLX ||
+				ecmd->speed == SPEED_10000);
+	}
 }
 
 /**
  * mdio_clause45_set_settings - Set (some of) the PHY settings over MDIO.
  * @efx:		Efx NIC
  * @ecmd: 		New settings
- *
- * Currently this just enforces that we are _not_ changing the
- * 'port', 'speed', 'supported' or 'advertising' settings as these
- * cannot be changed on any currently supported PHY.
  */
 int mdio_clause45_set_settings(struct efx_nic *efx,
 			       struct ethtool_cmd *ecmd)
 {
-	struct ethtool_cmd tmpcmd;
-	mdio_clause45_get_settings(efx, &tmpcmd);
-	/* None of the current PHYs support more than one mode
-	 * of operation (and only 10GBT ever will), so keep things
-	 * simple for now */
-	if ((ecmd->speed == tmpcmd.speed) && (ecmd->port == tmpcmd.port) &&
-	    (ecmd->supported == tmpcmd.supported) &&
-	    (ecmd->advertising == tmpcmd.advertising))
+	int phy_id = efx->mii.phy_id;
+	struct ethtool_cmd prev;
+	u32 required;
+	int ctrl1_bits, reg;
+
+	efx->phy_op->get_settings(efx, &prev);
+
+	if (ecmd->advertising == prev.advertising &&
+	    ecmd->speed == prev.speed &&
+	    ecmd->duplex == prev.duplex &&
+	    ecmd->port == prev.port &&
+	    ecmd->autoneg == prev.autoneg)
 		return 0;
-	return -EOPNOTSUPP;
+
+	/* We can only change these settings for -T PHYs */
+	if (prev.port != PORT_TP || ecmd->port != PORT_TP)
+		return -EINVAL;
+
+	/* Check that PHY supports these settings and work out the
+	 * basic control bits */
+	if (ecmd->duplex) {
+		switch (ecmd->speed) {
+		case SPEED_10:
+			ctrl1_bits = BMCR_FULLDPLX;
+			required = SUPPORTED_10baseT_Full;
+			break;
+		case SPEED_100:
+			ctrl1_bits = BMCR_SPEED100 | BMCR_FULLDPLX;
+			required = SUPPORTED_100baseT_Full;
+			break;
+		case SPEED_1000:
+			ctrl1_bits = BMCR_SPEED1000 | BMCR_FULLDPLX;
+			required = SUPPORTED_1000baseT_Full;
+			break;
+		case SPEED_10000:
+			ctrl1_bits = (BMCR_SPEED1000 | BMCR_SPEED100 |
+				      BMCR_FULLDPLX);
+			required = SUPPORTED_10000baseT_Full;
+			break;
+		default:
+			return -EINVAL;
+		}
+	} else {
+		switch (ecmd->speed) {
+		case SPEED_10:
+			ctrl1_bits = 0;
+			required = SUPPORTED_10baseT_Half;
+			break;
+		case SPEED_100:
+			ctrl1_bits = BMCR_SPEED100;
+			required = SUPPORTED_100baseT_Half;
+			break;
+		case SPEED_1000:
+			ctrl1_bits = BMCR_SPEED1000;
+			required = SUPPORTED_1000baseT_Half;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+	if (ecmd->autoneg)
+		required |= SUPPORTED_Autoneg;
+	required |= ecmd->advertising;
+	if (required & ~prev.supported)
+		return -EINVAL;
+
+	/* Set the basic control bits */
+	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+				 MDIO_MMDREG_CTRL1);
+	reg &= ~(BMCR_SPEED1000 | BMCR_SPEED100 | BMCR_FULLDPLX | 0x003c);
+	reg |= ctrl1_bits;
+	mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD, MDIO_MMDREG_CTRL1,
+			    reg);
+
+	/* Set the AN registers */
+	if (ecmd->autoneg != prev.autoneg ||
+	    ecmd->advertising != prev.advertising) {
+		bool xnp = false;
+
+		if (efx->phy_op->set_xnp_advertise)
+			xnp = efx->phy_op->set_xnp_advertise(efx,
+							     ecmd->advertising);
+
+		if (ecmd->autoneg) {
+			reg = 0;
+			if (ecmd->advertising & ADVERTISED_10baseT_Half)
+				reg |= ADVERTISE_10HALF;
+			if (ecmd->advertising & ADVERTISED_10baseT_Full)
+				reg |= ADVERTISE_10FULL;
+			if (ecmd->advertising & ADVERTISED_100baseT_Half)
+				reg |= ADVERTISE_100HALF;
+			if (ecmd->advertising & ADVERTISED_100baseT_Full)
+				reg |= ADVERTISE_100FULL;
+			if (xnp)
+				reg |= ADVERTISE_RESV;
+			mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
+					    MDIO_AN_ADVERTISE, reg);
+		}
+
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
+					 MDIO_MMDREG_CTRL1);
+		if (ecmd->autoneg)
+			reg |= BMCR_ANENABLE | BMCR_ANRESTART;
+		else
+			reg &= ~BMCR_ANENABLE;
+		if (xnp)
+			reg |= 1 << MDIO_AN_CTRL_XNP_LBN;
+		else
+			reg &= ~(1 << MDIO_AN_CTRL_XNP_LBN);
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
+				    MDIO_MMDREG_CTRL1, reg);
+	}
+
+	return 0;
+}
+
+void mdio_clause45_set_pause(struct efx_nic *efx)
+{
+	int phy_id = efx->mii.phy_id;
+	int reg;
+
+	if (efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_AN)) {
+		/* Set pause capability advertising */
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
+					 MDIO_AN_ADVERTISE);
+		reg &= ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
+		reg |= efx_fc_advertise(efx->wanted_fc);
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
+				    MDIO_AN_ADVERTISE, reg);
+
+		/* Restart auto-negotiation */
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
+					 MDIO_MMDREG_CTRL1);
+		if (reg & BMCR_ANENABLE) {
+			reg |= BMCR_ANRESTART;
+			mdio_clause45_write(efx, phy_id, MDIO_MMD_AN,
+					    MDIO_MMDREG_CTRL1, reg);
+		}
+	}
+}
+
+enum efx_fc_type mdio_clause45_get_pause(struct efx_nic *efx)
+{
+	int phy_id = efx->mii.phy_id;
+	int lpa;
+
+	if (!(efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_AN)))
+		return efx->wanted_fc;
+	lpa = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN, MDIO_AN_LPA);
+	return efx_fc_resolve(efx->wanted_fc, lpa);
 }
 
 void mdio_clause45_set_flag(struct efx_nic *efx, u8 prt, u8 dev,
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 4830e0c..80c63dd 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -81,6 +81,17 @@
 #define MDIO_MMDREG_DEVS_PHYXS	DEV_PRESENT_BIT(MDIO_MMD_PHYXS)
 #define MDIO_MMDREG_DEVS_PCS	DEV_PRESENT_BIT(MDIO_MMD_PCS)
 #define MDIO_MMDREG_DEVS_PMAPMD	DEV_PRESENT_BIT(MDIO_MMD_PMAPMD)
+#define MDIO_MMDREG_DEVS_AN	DEV_PRESENT_BIT(MDIO_MMD_AN)
+
+/* Bits in MMDREG_SPEED */
+#define MDIO_MMDREG_SPEED_10G_LBN	0
+#define MDIO_MMDREG_SPEED_10G_WIDTH	1
+#define MDIO_MMDREG_SPEED_1000M_LBN	4
+#define MDIO_MMDREG_SPEED_1000M_WIDTH	1
+#define MDIO_MMDREG_SPEED_100M_LBN	5
+#define MDIO_MMDREG_SPEED_100M_WIDTH	1
+#define MDIO_MMDREG_SPEED_10M_LBN	6
+#define MDIO_MMDREG_SPEED_10M_WIDTH	1
 
 /* Bits in MMDREG_STAT2 */
 #define MDIO_MMDREG_STAT2_PRESENT_VAL	(2)
@@ -119,12 +130,20 @@
 #define MDIO_PHYXS_LANE_ALIGNED_LBN	(12)
 
 /* AN registers */
+#define MDIO_AN_CTRL_XNP_LBN		13
 #define MDIO_AN_STATUS			(1)
 #define MDIO_AN_STATUS_XNP_LBN		(7)
 #define MDIO_AN_STATUS_PAGE_LBN		(6)
 #define MDIO_AN_STATUS_AN_DONE_LBN	(5)
 #define MDIO_AN_STATUS_LP_AN_CAP_LBN	(0)
 
+#define MDIO_AN_ADVERTISE		16
+#define MDIO_AN_ADVERTISE_XNP_LBN	12
+#define MDIO_AN_LPA			19
+#define MDIO_AN_XNP			22
+#define MDIO_AN_LPA_XNP			25
+
+#define MDIO_AN_10GBT_ADVERTISE		32
 #define MDIO_AN_10GBT_STATUS		(33)
 #define MDIO_AN_10GBT_STATUS_MS_FLT_LBN (15) /* MASTER/SLAVE config fault */
 #define MDIO_AN_10GBT_STATUS_MS_LBN     (14) /* MASTER/SLAVE config */
@@ -251,10 +270,23 @@ extern void mdio_clause45_set_mmds_lpower(struct efx_nic *efx,
 extern void mdio_clause45_get_settings(struct efx_nic *efx,
 				       struct ethtool_cmd *ecmd);
 
+/* Read (some of) the PHY settings over MDIO */
+extern void
+mdio_clause45_get_settings_ext(struct efx_nic *efx, struct ethtool_cmd *ecmd,
+			       u32 xnp, u32 xnp_lpa);
+
 /* Set (some of) the PHY settings over MDIO */
 extern int mdio_clause45_set_settings(struct efx_nic *efx,
 				      struct ethtool_cmd *ecmd);
 
+/* Set pause parameters to be advertised through AN (if available) */
+extern void mdio_clause45_set_pause(struct efx_nic *efx);
+
+/* Get pause parameters from AN if available (otherwise return
+ * requested pause parameters)
+ */
+enum efx_fc_type mdio_clause45_get_pause(struct efx_nic *efx);
+
 /* Wait for specified MMDs to exit reset within a timeout */
 extern int mdio_clause45_wait_reset_mmds(struct efx_nic *efx,
 					 unsigned int mmd_mask);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 883086e..fb8d725 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -511,6 +511,35 @@ enum efx_mac_type {
 	EFX_XMAC = 2,
 };
 
+static inline unsigned int efx_fc_advertise(enum efx_fc_type wanted_fc)
+{
+	unsigned int adv = 0;
+	if (wanted_fc & EFX_FC_RX)
+		adv = ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
+	if (wanted_fc & EFX_FC_TX)
+		adv ^= ADVERTISE_PAUSE_ASYM;
+	return adv;
+}
+
+static inline enum efx_fc_type efx_fc_resolve(enum efx_fc_type wanted_fc,
+					      unsigned int lpa)
+{
+	unsigned int adv = efx_fc_advertise(wanted_fc);
+
+	if (!(wanted_fc & EFX_FC_AUTO))
+		return wanted_fc;
+
+	if (adv & lpa & ADVERTISE_PAUSE_CAP)
+		return EFX_FC_RX | EFX_FC_TX;
+	if (adv & lpa & ADVERTISE_PAUSE_ASYM) {
+		if (adv & ADVERTISE_PAUSE_CAP)
+			return EFX_FC_RX;
+		if (lpa & ADVERTISE_PAUSE_CAP)
+			return EFX_FC_TX;
+	}
+	return 0;
+}
+
 /**
  * struct efx_mac_operations - Efx MAC operations table
  * @reconfigure: Reconfigure MAC. Serialised by the mac_lock
@@ -533,6 +562,8 @@ struct efx_mac_operations {
  * @check_hw: Check hardware
  * @get_settings: Get ethtool settings. Serialised by the mac_lock.
  * @set_settings: Set ethtool settings. Serialised by the mac_lock.
+ * @set_xnp_advertise: Set abilities advertised in Extended Next Page
+ *	(only needed where AN bit is set in mmds)
  * @mmds: MMD presence mask
  * @loopbacks: Supported loopback modes mask
  */
@@ -548,6 +579,7 @@ struct efx_phy_operations {
 			      struct ethtool_cmd *ecmd);
 	int (*set_settings) (struct efx_nic *efx,
 			     struct ethtool_cmd *ecmd);
+	bool (*set_xnp_advertise) (struct efx_nic *efx, u32);
 	int mmds;
 	unsigned loopbacks;
 };
@@ -724,11 +756,12 @@ union efx_multicast_hash {
  * @mac_up: MAC link state
  * @link_up: Link status
  * @link_fd: Link is full duplex
+ * @link_fc: Actualy flow control flags
  * @link_speed: Link speed (Mbps)
  * @n_link_state_changes: Number of times the link has changed state
  * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
  * @multicast_hash: Multicast hash table
- * @flow_control: Flow control flags - separate RX/TX so can't use link_options
+ * @wanted_fc: Wanted flow control flags
  * @reconfigure_work: work item for dealing with PHY events
  * @loopback_mode: Loopback status
  * @loopback_modes: Supported loopback mode bitmask
@@ -805,12 +838,13 @@ struct efx_nic {
 	bool mac_up;
 	bool link_up;
 	bool link_fd;
+	enum efx_fc_type link_fc;
 	unsigned int link_speed;
 	unsigned int n_link_state_changes;
 
 	bool promiscuous;
 	union efx_multicast_hash multicast_hash;
-	enum efx_fc_type flow_control;
+	enum efx_fc_type wanted_fc;
 	struct work_struct reconfigure_work;
 
 	atomic_t rx_reset;
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index d60353b..634ff91 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -17,10 +17,10 @@
 #include "boards.h"
 
 /* We expect these MMDs to be in the package */
-/* AN not here as mdio_check_mmds() requires STAT2 support */
 #define TENXPRESS_REQUIRED_DEVS (MDIO_MMDREG_DEVS_PMAPMD	| \
 				 MDIO_MMDREG_DEVS_PCS		| \
-				 MDIO_MMDREG_DEVS_PHYXS)
+				 MDIO_MMDREG_DEVS_PHYXS		| \
+				 MDIO_MMDREG_DEVS_AN)
 
 #define TENXPRESS_LOOPBACKS ((1 << LOOPBACK_PHYXS) |	\
 			     (1 << LOOPBACK_PCS) |	\
@@ -57,6 +57,7 @@
 #define	PMA_PMD_LED_ON		(1)
 #define	PMA_PMD_LED_OFF		(2)
 #define PMA_PMD_LED_FLASH	(3)
+#define PMA_PMD_LED_MASK	3
 /* All LEDs under hardware control */
 #define PMA_PMD_LED_FULL_AUTO	(0)
 /* Green and Amber under hardware control, Red off */
@@ -242,78 +243,60 @@ unlock:
 	return rc;
 }
 
-static void tenxpress_set_bad_lp(struct efx_nic *efx, bool bad_lp)
+static void tenxpress_check_bad_lp(struct efx_nic *efx, bool link_ok)
 {
 	struct tenxpress_phy_data *pd = efx->phy_data;
+	int phy_id = efx->mii.phy_id;
+	bool bad_lp;
 	int reg;
 
+	if (link_ok) {
+		bad_lp = false;
+	} else {
+		/* Check that AN has started but not completed. */
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
+					 MDIO_AN_STATUS);
+		if (!(reg & (1 << MDIO_AN_STATUS_LP_AN_CAP_LBN)))
+			return; /* LP status is unknown */
+		bad_lp = !(reg & (1 << MDIO_AN_STATUS_AN_DONE_LBN));
+		if (bad_lp)
+			pd->bad_lp_tries++;
+	}
+
 	/* Nothing to do if all is well and was previously so. */
-	if (!(bad_lp || pd->bad_lp_tries))
+	if (!pd->bad_lp_tries)
 		return;
 
-	reg = mdio_clause45_read(efx, efx->mii.phy_id,
-				 MDIO_MMD_PMAPMD, PMA_PMD_LED_OVERR_REG);
-
-	if (bad_lp)
-		pd->bad_lp_tries++;
-	else
-		pd->bad_lp_tries = 0;
-
-	if (pd->bad_lp_tries == MAX_BAD_LP_TRIES) {
-		pd->bad_lp_tries = 0;	/* Restart count */
-		reg &= ~(PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN);
-		reg |= (PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN);
-		EFX_ERR(efx, "This NIC appears to be plugged into"
-			" a port that is not 10GBASE-T capable.\n"
-			" This PHY is 10GBASE-T ONLY, so no link can"
-			" be established.\n");
-	} else {
-		reg |= (PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN);
+	/* Use the RX (red) LED as an error indicator once we've seen AN
+	 * failure several times in a row, and also log a message. */
+	if (!bad_lp || pd->bad_lp_tries == MAX_BAD_LP_TRIES) {
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+					 PMA_PMD_LED_OVERR_REG);
+		reg &= ~(PMA_PMD_LED_MASK << PMA_PMD_LED_RX_LBN);
+		if (!bad_lp) {
+			reg |= PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN;
+		} else {
+			reg |= PMA_PMD_LED_FLASH << PMA_PMD_LED_RX_LBN;
+			EFX_ERR(efx, "appears to be plugged into a port"
+				" that is not 10GBASE-T capable. The PHY"
+				" supports 10GBASE-T ONLY, so no link can"
+				" be established\n");
+		}
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
+				    PMA_PMD_LED_OVERR_REG, reg);
+		pd->bad_lp_tries = bad_lp;
 	}
-	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			    PMA_PMD_LED_OVERR_REG, reg);
 }
 
-/* Check link status and return a boolean OK value. If the link is NOT
- * OK we have a quick rummage round to see if we appear to be plugged
- * into a non-10GBT port and if so warn the user that they won't get
- * link any time soon as we are 10GBT only, unless caller specified
- * not to do this check (it isn't useful in loopback) */
-static bool tenxpress_link_ok(struct efx_nic *efx, bool check_lp)
+static bool tenxpress_link_ok(struct efx_nic *efx)
 {
-	bool ok = mdio_clause45_links_ok(efx, TENXPRESS_REQUIRED_DEVS);
-
-	if (ok) {
-		tenxpress_set_bad_lp(efx, false);
-	} else if (check_lp) {
-		/* Are we plugged into the wrong sort of link? */
-		bool bad_lp = false;
-		int phy_id = efx->mii.phy_id;
-		int an_stat = mdio_clause45_read(efx, phy_id, MDIO_MMD_AN,
-						 MDIO_AN_STATUS);
-		int xphy_stat = mdio_clause45_read(efx, phy_id,
-						   MDIO_MMD_PMAPMD,
-						   PMA_PMD_XSTATUS_REG);
-		/* Are we plugged into anything that sends FLPs? If
-		 * not we can't distinguish between not being plugged
-		 * in and being plugged into a non-AN antique. The FLP
-		 * bit has the advantage of not clearing when autoneg
-		 * restarts. */
-		if (!(xphy_stat & (1 << PMA_PMD_XSTAT_FLP_LBN))) {
-			tenxpress_set_bad_lp(efx, false);
-			return ok;
-		}
-
-		/* If it can do 10GBT it must be XNP capable */
-		bad_lp = !(an_stat & (1 << MDIO_AN_STATUS_XNP_LBN));
-		if (!bad_lp && (an_stat & (1 << MDIO_AN_STATUS_PAGE_LBN))) {
-			bad_lp = !(mdio_clause45_read(efx, phy_id,
-					MDIO_MMD_AN, MDIO_AN_10GBT_STATUS) &
-					(1 << MDIO_AN_10GBT_STATUS_LP_10G_LBN));
-		}
-		tenxpress_set_bad_lp(efx, bad_lp);
-	}
-	return ok;
+	if (efx->loopback_mode == LOOPBACK_NONE)
+		return mdio_clause45_links_ok(efx, MDIO_MMDREG_DEVS_AN);
+	else
+		return mdio_clause45_links_ok(efx,
+					      MDIO_MMDREG_DEVS_PMAPMD |
+					      MDIO_MMDREG_DEVS_PCS |
+					      MDIO_MMDREG_DEVS_PHYXS);
 }
 
 static void tenxpress_phyxs_loopback(struct efx_nic *efx)
@@ -359,9 +342,10 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 
 	phy_data->loopback_mode = efx->loopback_mode;
 	phy_data->phy_mode = efx->phy_mode;
-	efx->link_up = tenxpress_link_ok(efx, false);
+	efx->link_up = tenxpress_link_ok(efx);
 	efx->link_speed = 10000;
 	efx->link_fd = true;
+	efx->link_fc = mdio_clause45_get_pause(efx);
 }
 
 static void tenxpress_phy_clear_interrupt(struct efx_nic *efx)
@@ -377,7 +361,8 @@ static int tenxpress_phy_check_hw(struct efx_nic *efx)
 	bool link_ok;
 	int rc = 0;
 
-	link_ok = tenxpress_link_ok(efx, true);
+	link_ok = tenxpress_link_ok(efx);
+	tenxpress_check_bad_lp(efx, link_ok);
 
 	if (link_ok != efx->link_up)
 		falcon_sim_phy_event(efx);
@@ -451,6 +436,27 @@ static int tenxpress_phy_test(struct efx_nic *efx)
 	return tenxpress_special_reset(efx);
 }
 
+static u32 tenxpress_get_xnp_lpa(struct efx_nic *efx)
+{
+	int phy = efx->mii.phy_id;
+	u32 lpa = 0;
+	int reg;
+
+	reg = mdio_clause45_read(efx, phy, MDIO_MMD_AN, MDIO_AN_10GBT_STATUS);
+	if (reg & (1 << MDIO_AN_10GBT_STATUS_LP_10G_LBN))
+		lpa |= ADVERTISED_10000baseT_Full;
+	return lpa;
+}
+
+static void
+tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+{
+	mdio_clause45_get_settings_ext(efx, ecmd, ADVERTISED_10000baseT_Full,
+				       tenxpress_get_xnp_lpa(efx));
+	ecmd->supported |= SUPPORTED_10000baseT_Full;
+	ecmd->advertising |= ADVERTISED_10000baseT_Full;
+}
+
 struct efx_phy_operations falcon_tenxpress_phy_ops = {
 	.macs		  = EFX_XMAC,
 	.init             = tenxpress_phy_init,
@@ -459,7 +465,7 @@ struct efx_phy_operations falcon_tenxpress_phy_ops = {
 	.fini             = tenxpress_phy_fini,
 	.clear_interrupt  = tenxpress_phy_clear_interrupt,
 	.test             = tenxpress_phy_test,
-	.get_settings	  = mdio_clause45_get_settings,
+	.get_settings	  = tenxpress_get_settings,
 	.set_settings	  = mdio_clause45_set_settings,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
 	.loopbacks        = TENXPRESS_LOOPBACKS,
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index d4e203d..fbe8e25 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -155,6 +155,7 @@ static void xfp_phy_reconfigure(struct efx_nic *efx)
 	efx->link_up = xfp_link_ok(efx);
 	efx->link_speed = 10000;
 	efx->link_fd = true;
+	efx->link_fc = efx->wanted_fc;
 }
 
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
