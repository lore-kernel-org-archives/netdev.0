From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2 1/2] net: mdio: add mdio45_ethtool_ksettings_get
Date: Sun,  1 Jan 2017 19:02:45 +0100
Message-ID: <1483293766-4581-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com, davem@davemloft.net, andrew@lunn.ch,
        f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a function in mdio for the old ethtool api gset.
We add a new function mdio45_ethtool_ksettings_get for the
new ethtool api glinksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Changelog:
v2:
- simplify the code of ef4_ethtool_get_link_ksettings
  (feedback from Bert Kenward)

 drivers/net/mdio.c   |  178 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mdio.h |   21 ++++++
 2 files changed, 199 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index 3e027ed..077364c 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -342,6 +342,184 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 EXPORT_SYMBOL(mdio45_ethtool_gset_npage);
 
 /**
+ * mdio45_ethtool_ksettings_get_npage - get settings for ETHTOOL_GLINKSETTINGS
+ * @mdio: MDIO interface
+ * @cmd: Ethtool request structure
+ * @npage_adv: Modes currently advertised on next pages
+ * @npage_lpa: Modes advertised by link partner on next pages
+ *
+ * The @cmd parameter is expected to have been cleared before calling
+ * mdio45_ethtool_ksettings_get_npage().
+ *
+ * Since the CSRs for auto-negotiation using next pages are not fully
+ * standardised, this function does not attempt to decode them.  The
+ * caller must pass them in.
+ */
+void mdio45_ethtool_ksettings_get_npage(const struct mdio_if_info *mdio,
+					struct ethtool_link_ksettings *cmd,
+					u32 npage_adv, u32 npage_lpa)
+{
+	int reg;
+	u32 speed, supported = 0, advertising = 0, lp_advertising = 0;
+
+	BUILD_BUG_ON(MDIO_SUPPORTS_C22 != ETH_MDIO_SUPPORTS_C22);
+	BUILD_BUG_ON(MDIO_SUPPORTS_C45 != ETH_MDIO_SUPPORTS_C45);
+
+	cmd->base.phy_address = mdio->prtad;
+	cmd->base.mdio_support =
+		mdio->mode_support & (MDIO_SUPPORTS_C45 | MDIO_SUPPORTS_C22);
+
+	reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+			      MDIO_CTRL2);
+	switch (reg & MDIO_PMA_CTRL2_TYPE) {
+	case MDIO_PMA_CTRL2_10GBT:
+	case MDIO_PMA_CTRL2_1000BT:
+	case MDIO_PMA_CTRL2_100BTX:
+	case MDIO_PMA_CTRL2_10BT:
+		cmd->base.port = PORT_TP;
+		supported = SUPPORTED_TP;
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+				      MDIO_SPEED);
+		if (reg & MDIO_SPEED_10G)
+			supported |= SUPPORTED_10000baseT_Full;
+		if (reg & MDIO_PMA_SPEED_1000)
+			supported |= (SUPPORTED_1000baseT_Full |
+					    SUPPORTED_1000baseT_Half);
+		if (reg & MDIO_PMA_SPEED_100)
+			supported |= (SUPPORTED_100baseT_Full |
+					    SUPPORTED_100baseT_Half);
+		if (reg & MDIO_PMA_SPEED_10)
+			supported |= (SUPPORTED_10baseT_Full |
+					    SUPPORTED_10baseT_Half);
+		advertising = ADVERTISED_TP;
+		break;
+
+	case MDIO_PMA_CTRL2_10GBCX4:
+		cmd->base.port = PORT_OTHER;
+		supported = 0;
+		advertising = 0;
+		break;
+
+	case MDIO_PMA_CTRL2_10GBKX4:
+	case MDIO_PMA_CTRL2_10GBKR:
+	case MDIO_PMA_CTRL2_1000BKX:
+		cmd->base.port = PORT_OTHER;
+		supported = SUPPORTED_Backplane;
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+				      MDIO_PMA_EXTABLE);
+		if (reg & MDIO_PMA_EXTABLE_10GBKX4)
+			supported |= SUPPORTED_10000baseKX4_Full;
+		if (reg & MDIO_PMA_EXTABLE_10GBKR)
+			supported |= SUPPORTED_10000baseKR_Full;
+		if (reg & MDIO_PMA_EXTABLE_1000BKX)
+			supported |= SUPPORTED_1000baseKX_Full;
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+				      MDIO_PMA_10GBR_FECABLE);
+		if (reg & MDIO_PMA_10GBR_FECABLE_ABLE)
+			supported |= SUPPORTED_10000baseR_FEC;
+		advertising = ADVERTISED_Backplane;
+		break;
+
+	/* All the other defined modes are flavours of optical */
+	default:
+		cmd->base.port = PORT_FIBRE;
+		supported = SUPPORTED_FIBRE;
+		advertising = ADVERTISED_FIBRE;
+		break;
+	}
+
+	if (mdio->mmds & MDIO_DEVS_AN) {
+		supported |= SUPPORTED_Autoneg;
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN,
+				      MDIO_CTRL1);
+		if (reg & MDIO_AN_CTRL1_ENABLE) {
+			cmd->base.autoneg = AUTONEG_ENABLE;
+			advertising |=
+				ADVERTISED_Autoneg |
+				mdio45_get_an(mdio, MDIO_AN_ADVERTISE) |
+				npage_adv;
+		} else {
+			cmd->base.autoneg = AUTONEG_DISABLE;
+		}
+	} else {
+		cmd->base.autoneg = AUTONEG_DISABLE;
+	}
+
+	if (cmd->base.autoneg) {
+		u32 modes = 0;
+		int an_stat = mdio->mdio_read(mdio->dev, mdio->prtad,
+					      MDIO_MMD_AN, MDIO_STAT1);
+
+		/* If AN is complete and successful, report best common
+		 * mode, otherwise report best advertised mode.
+		 */
+		if (an_stat & MDIO_AN_STAT1_COMPLETE) {
+			lp_advertising =
+				mdio45_get_an(mdio, MDIO_AN_LPA) | npage_lpa;
+			if (an_stat & MDIO_AN_STAT1_LPABLE)
+				lp_advertising |= ADVERTISED_Autoneg;
+			modes = advertising & lp_advertising;
+		}
+		if ((modes & ~ADVERTISED_Autoneg) == 0)
+			modes = advertising;
+
+		if (modes & (ADVERTISED_10000baseT_Full |
+			     ADVERTISED_10000baseKX4_Full |
+			     ADVERTISED_10000baseKR_Full)) {
+			speed = SPEED_10000;
+			cmd->base.duplex = DUPLEX_FULL;
+		} else if (modes & (ADVERTISED_1000baseT_Full |
+				    ADVERTISED_1000baseT_Half |
+				    ADVERTISED_1000baseKX_Full)) {
+			speed = SPEED_1000;
+			cmd->base.duplex = !(modes & ADVERTISED_1000baseT_Half);
+		} else if (modes & (ADVERTISED_100baseT_Full |
+				    ADVERTISED_100baseT_Half)) {
+			speed = SPEED_100;
+			cmd->base.duplex = !!(modes & ADVERTISED_100baseT_Full);
+		} else {
+			speed = SPEED_10;
+			cmd->base.duplex = !!(modes & ADVERTISED_10baseT_Full);
+		}
+	} else {
+		/* Report forced settings */
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+				      MDIO_CTRL1);
+		speed = (((reg & MDIO_PMA_CTRL1_SPEED1000) ? 100 : 1)
+			 * ((reg & MDIO_PMA_CTRL1_SPEED100) ? 100 : 10));
+		cmd->base.duplex = (reg & MDIO_CTRL1_FULLDPLX ||
+				    speed == SPEED_10000);
+	}
+
+	cmd->base.speed = speed;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.lp_advertising,
+						lp_advertising);
+
+	/* 10GBASE-T MDI/MDI-X */
+	if (cmd->base.port == PORT_TP && (cmd->base.speed == SPEED_10000)) {
+		switch (mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+					MDIO_PMA_10GBT_SWAPPOL)) {
+		case MDIO_PMA_10GBT_SWAPPOL_ABNX | MDIO_PMA_10GBT_SWAPPOL_CDNX:
+			cmd->base.eth_tp_mdix = ETH_TP_MDI;
+			break;
+		case 0:
+			cmd->base.eth_tp_mdix = ETH_TP_MDI_X;
+			break;
+		default:
+			/* It's complicated... */
+			cmd->base.eth_tp_mdix = ETH_TP_MDI_INVALID;
+			break;
+		}
+	}
+}
+EXPORT_SYMBOL(mdio45_ethtool_ksettings_get_npage);
+
+/**
  * mdio_mii_ioctl - MII ioctl interface for MDIO (clause 22 or 45) PHYs
  * @mdio: MDIO interface
  * @mii_data: MII ioctl data structure
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index bf9d1d7..b6587a4 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -130,6 +130,10 @@ extern int mdio_set_flag(const struct mdio_if_info *mdio,
 extern void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 				      struct ethtool_cmd *ecmd,
 				      u32 npage_adv, u32 npage_lpa);
+extern void
+mdio45_ethtool_ksettings_get_npage(const struct mdio_if_info *mdio,
+				   struct ethtool_link_ksettings *cmd,
+				   u32 npage_adv, u32 npage_lpa);
 
 /**
  * mdio45_ethtool_gset - get settings for ETHTOOL_GSET
@@ -147,6 +151,23 @@ static inline void mdio45_ethtool_gset(const struct mdio_if_info *mdio,
 	mdio45_ethtool_gset_npage(mdio, ecmd, 0, 0);
 }
 
+/**
+ * mdio45_ethtool_ksettings_get - get settings for ETHTOOL_GLINKSETTINGS
+ * @mdio: MDIO interface
+ * @cmd: Ethtool request structure
+ *
+ * Since the CSRs for auto-negotiation using next pages are not fully
+ * standardised, this function does not attempt to decode them.  Use
+ * mdio45_ethtool_ksettings_get_npage() to specify advertisement bits
+ * from next pages.
+ */
+static inline void
+mdio45_ethtool_ksettings_get(const struct mdio_if_info *mdio,
+			     struct ethtool_link_ksettings *cmd)
+{
+	mdio45_ethtool_ksettings_get_npage(mdio, cmd, 0, 0);
+}
+
 extern int mdio_mii_ioctl(const struct mdio_if_info *mdio,
 			  struct mii_ioctl_data *mii_data, int cmd);
 
-- 
1.7.4.4
