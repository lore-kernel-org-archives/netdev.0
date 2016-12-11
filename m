From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: chelsio: cxgb2: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 11 Dec 2016 22:47:50 +0100
Message-ID: <1481492870-12222-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c |   64 +++++++++++++++++------------
 1 files changed, 37 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index 81d1d0b..3a05f90 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -568,28 +568,33 @@ static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	reg_block_dump(ap, buf, A_MC5_CONFIG, A_MC5_MASK_WRITE_CMD);
 }
 
-static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int get_link_ksettings(struct net_device *dev,
+			      struct ethtool_link_ksettings *cmd)
 {
 	struct adapter *adapter = dev->ml_priv;
 	struct port_info *p = &adapter->port[dev->if_port];
+	u32 supported, advertising;
 
-	cmd->supported = p->link_config.supported;
-	cmd->advertising = p->link_config.advertising;
+	supported = p->link_config.supported;
+	advertising = p->link_config.advertising;
 
 	if (netif_carrier_ok(dev)) {
-		ethtool_cmd_speed_set(cmd, p->link_config.speed);
-		cmd->duplex = p->link_config.duplex;
+		cmd->base.speed = p->link_config.speed;
+		cmd->base.duplex = p->link_config.duplex;
 	} else {
-		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
-		cmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
-	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
-	cmd->phy_address = p->phy->mdio.prtad;
-	cmd->transceiver = XCVR_EXTERNAL;
-	cmd->autoneg = p->link_config.autoneg;
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
+	cmd->base.port = (supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
+	cmd->base.phy_address = p->phy->mdio.prtad;
+	cmd->base.autoneg = p->link_config.autoneg;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
@@ -628,36 +633,41 @@ static int speed_duplex_to_caps(int speed, int duplex)
 		      ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full | \
 		      ADVERTISED_10000baseT_Full)
 
-static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int set_link_ksettings(struct net_device *dev,
+			      const struct ethtool_link_ksettings *cmd)
 {
 	struct adapter *adapter = dev->ml_priv;
 	struct port_info *p = &adapter->port[dev->if_port];
 	struct link_config *lc = &p->link_config;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	if (!(lc->supported & SUPPORTED_Autoneg))
 		return -EOPNOTSUPP;             /* can't change speed/duplex */
 
-	if (cmd->autoneg == AUTONEG_DISABLE) {
-		u32 speed = ethtool_cmd_speed(cmd);
-		int cap = speed_duplex_to_caps(speed, cmd->duplex);
+	if (cmd->base.autoneg == AUTONEG_DISABLE) {
+		u32 speed = cmd->base.speed;
+		int cap = speed_duplex_to_caps(speed, cmd->base.duplex);
 
 		if (!(lc->supported & cap) || (speed == SPEED_1000))
 			return -EINVAL;
 		lc->requested_speed = speed;
-		lc->requested_duplex = cmd->duplex;
+		lc->requested_duplex = cmd->base.duplex;
 		lc->advertising = 0;
 	} else {
-		cmd->advertising &= ADVERTISED_MASK;
-		if (cmd->advertising & (cmd->advertising - 1))
-			cmd->advertising = lc->supported;
-		cmd->advertising &= lc->supported;
-		if (!cmd->advertising)
+		advertising &= ADVERTISED_MASK;
+		if (advertising & (advertising - 1))
+			advertising = lc->supported;
+		advertising &= lc->supported;
+		if (!advertising)
 			return -EINVAL;
 		lc->requested_speed = SPEED_INVALID;
 		lc->requested_duplex = DUPLEX_INVALID;
-		lc->advertising = cmd->advertising | ADVERTISED_Autoneg;
+		lc->advertising = advertising | ADVERTISED_Autoneg;
 	}
-	lc->autoneg = cmd->autoneg;
+	lc->autoneg = cmd->base.autoneg;
 	if (netif_running(dev))
 		t1_link_start(p->phy, p->mac, lc);
 	return 0;
@@ -788,8 +798,6 @@ static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
 }
 
 static const struct ethtool_ops t1_ethtool_ops = {
-	.get_settings      = get_settings,
-	.set_settings      = set_settings,
 	.get_drvinfo       = get_drvinfo,
 	.get_msglevel      = get_msglevel,
 	.set_msglevel      = set_msglevel,
@@ -807,6 +815,8 @@ static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
 	.get_ethtool_stats = get_stats,
 	.get_regs_len      = get_regs_len,
 	.get_regs          = get_regs,
+	.get_link_ksettings = get_link_ksettings,
+	.set_link_ksettings = set_link_ksettings,
 };
 
 static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
-- 
1.7.4.4
