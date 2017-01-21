From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: broadcom: bnx2x: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 21 Jan 2017 12:55:03 +0100
Message-ID: <1484999703-22903-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: Yuval.Mintz@cavium.com, ariel.elior@cavium.com,
        everest-linux-l2@cavium.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  156 +++++++++++---------
 1 files changed, 86 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 5f19427..9d02a14 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -253,128 +253,144 @@ static int bnx2x_get_vf_settings(struct net_device *dev,
 	return 0;
 }
 
-static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int bnx2x_get_link_ksettings(struct net_device *dev,
+				    struct ethtool_link_ksettings *cmd)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	int cfg_idx = bnx2x_get_link_cfg_idx(bp);
 	u32 media_type;
+	u32 supported, advertising, lp_advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&lp_advertising,
+						cmd->link_modes.lp_advertising);
 
 	/* Dual Media boards present all available port types */
-	cmd->supported = bp->port.supported[cfg_idx] |
+	supported = bp->port.supported[cfg_idx] |
 		(bp->port.supported[cfg_idx ^ 1] &
 		 (SUPPORTED_TP | SUPPORTED_FIBRE));
-	cmd->advertising = bp->port.advertising[cfg_idx];
+	advertising = bp->port.advertising[cfg_idx];
 	media_type = bp->link_params.phy[bnx2x_get_cur_phy_idx(bp)].media_type;
 	if (media_type == ETH_PHY_SFP_1G_FIBER) {
-		cmd->supported &= ~(SUPPORTED_10000baseT_Full);
-		cmd->advertising &= ~(ADVERTISED_10000baseT_Full);
+		supported &= ~(SUPPORTED_10000baseT_Full);
+		advertising &= ~(ADVERTISED_10000baseT_Full);
 	}
 
 	if ((bp->state == BNX2X_STATE_OPEN) && bp->link_vars.link_up &&
 	    !(bp->flags & MF_FUNC_DIS)) {
-		cmd->duplex = bp->link_vars.duplex;
+		cmd->base.duplex = bp->link_vars.duplex;
 
 		if (IS_MF(bp) && !BP_NOMCP(bp))
-			ethtool_cmd_speed_set(cmd, bnx2x_get_mf_speed(bp));
+			cmd->base.speed = bnx2x_get_mf_speed(bp);
 		else
-			ethtool_cmd_speed_set(cmd, bp->link_vars.line_speed);
+			cmd->base.speed = bp->link_vars.line_speed;
 	} else {
-		cmd->duplex = DUPLEX_UNKNOWN;
-		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+		cmd->base.duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
 	}
 
-	cmd->port = bnx2x_get_port_type(bp);
+	cmd->base.port = bnx2x_get_port_type(bp);
 
-	cmd->phy_address = bp->mdio.prtad;
-	cmd->transceiver = XCVR_INTERNAL;
+	cmd->base.phy_address = bp->mdio.prtad;
 
 	if (bp->link_params.req_line_speed[cfg_idx] == SPEED_AUTO_NEG)
-		cmd->autoneg = AUTONEG_ENABLE;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	else
-		cmd->autoneg = AUTONEG_DISABLE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 
 	/* Publish LP advertised speeds and FC */
 	if (bp->link_vars.link_status & LINK_STATUS_AUTO_NEGOTIATE_COMPLETE) {
 		u32 status = bp->link_vars.link_status;
 
-		cmd->lp_advertising |= ADVERTISED_Autoneg;
+		lp_advertising |= ADVERTISED_Autoneg;
 		if (status & LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE)
-			cmd->lp_advertising |= ADVERTISED_Pause;
+			lp_advertising |= ADVERTISED_Pause;
 		if (status & LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE)
-			cmd->lp_advertising |= ADVERTISED_Asym_Pause;
+			lp_advertising |= ADVERTISED_Asym_Pause;
 
 		if (status & LINK_STATUS_LINK_PARTNER_10THD_CAPABLE)
-			cmd->lp_advertising |= ADVERTISED_10baseT_Half;
+			lp_advertising |= ADVERTISED_10baseT_Half;
 		if (status & LINK_STATUS_LINK_PARTNER_10TFD_CAPABLE)
-			cmd->lp_advertising |= ADVERTISED_10baseT_Full;
+			lp_advertising |= ADVERTISED_10baseT_Full;
 		if (status & LINK_STATUS_LINK_PARTNER_100TXHD_CAPABLE)
-			cmd->lp_advertising |= ADVERTISED_100baseT_Half;
+			lp_advertising |= ADVERTISED_100baseT_Half;
 		if (status & LINK_STATUS_LINK_PARTNER_100TXFD_CAPABLE)
-			cmd->lp_advertising |= ADVERTISED_100baseT_Full;
+			lp_advertising |= ADVERTISED_100baseT_Full;
 		if (status & LINK_STATUS_LINK_PARTNER_1000THD_CAPABLE)
-			cmd->lp_advertising |= ADVERTISED_1000baseT_Half;
+			lp_advertising |= ADVERTISED_1000baseT_Half;
 		if (status & LINK_STATUS_LINK_PARTNER_1000TFD_CAPABLE) {
 			if (media_type == ETH_PHY_KR) {
-				cmd->lp_advertising |=
+				lp_advertising |=
 					ADVERTISED_1000baseKX_Full;
 			} else {
-				cmd->lp_advertising |=
+				lp_advertising |=
 					ADVERTISED_1000baseT_Full;
 			}
 		}
 		if (status & LINK_STATUS_LINK_PARTNER_2500XFD_CAPABLE)
-			cmd->lp_advertising |= ADVERTISED_2500baseX_Full;
+			lp_advertising |= ADVERTISED_2500baseX_Full;
 		if (status & LINK_STATUS_LINK_PARTNER_10GXFD_CAPABLE) {
 			if (media_type == ETH_PHY_KR) {
-				cmd->lp_advertising |=
+				lp_advertising |=
 					ADVERTISED_10000baseKR_Full;
 			} else {
-				cmd->lp_advertising |=
+				lp_advertising |=
 					ADVERTISED_10000baseT_Full;
 			}
 		}
 		if (status & LINK_STATUS_LINK_PARTNER_20GXFD_CAPABLE)
-			cmd->lp_advertising |= ADVERTISED_20000baseKR2_Full;
+			lp_advertising |= ADVERTISED_20000baseKR2_Full;
 	}
 
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.lp_advertising,
+						lp_advertising);
 
 	DP(BNX2X_MSG_ETHTOOL, "ethtool_cmd: cmd %d\n"
 	   "  supported 0x%x  advertising 0x%x  speed %u\n"
-	   "  duplex %d  port %d  phy_address %d  transceiver %d\n"
-	   "  autoneg %d  maxtxpkt %d  maxrxpkt %d\n",
-	   cmd->cmd, cmd->supported, cmd->advertising,
-	   ethtool_cmd_speed(cmd),
-	   cmd->duplex, cmd->port, cmd->phy_address, cmd->transceiver,
-	   cmd->autoneg, cmd->maxtxpkt, cmd->maxrxpkt);
+	   "  duplex %d  port %d  phy_address %d\n"
+	   "  autoneg %d\n",
+	   cmd->base.cmd, supported, advertising,
+	   cmd->base.speed,
+	   cmd->base.duplex, cmd->base.port, cmd->base.phy_address,
+	   cmd->base.autoneg);
 
 	return 0;
 }
 
-static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int bnx2x_set_link_ksettings(struct net_device *dev,
+				    const struct ethtool_link_ksettings *cmd)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	u32 advertising, cfg_idx, old_multi_phy_config, new_multi_phy_config;
 	u32 speed, phy_idx;
+	u32 supported;
+	u8 duplex = cmd->base.duplex;
+
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						cmd->link_modes.supported);
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	if (IS_MF_SD(bp))
 		return 0;
 
 	DP(BNX2X_MSG_ETHTOOL, "ethtool_cmd: cmd %d\n"
 	   "  supported 0x%x  advertising 0x%x  speed %u\n"
-	   "  duplex %d  port %d  phy_address %d  transceiver %d\n"
-	   "  autoneg %d  maxtxpkt %d  maxrxpkt %d\n",
-	   cmd->cmd, cmd->supported, cmd->advertising,
-	   ethtool_cmd_speed(cmd),
-	   cmd->duplex, cmd->port, cmd->phy_address, cmd->transceiver,
-	   cmd->autoneg, cmd->maxtxpkt, cmd->maxrxpkt);
+	   "  duplex %d  port %d  phy_address %d\n"
+	   "  autoneg %d\n",
+	   cmd->base.cmd, supported, advertising,
+	   cmd->base.speed,
+	   cmd->base.duplex, cmd->base.port, cmd->base.phy_address,
+	   cmd->base.autoneg);
 
-	speed = ethtool_cmd_speed(cmd);
+	speed = cmd->base.speed;
 
 	/* If received a request for an unknown duplex, assume full*/
-	if (cmd->duplex == DUPLEX_UNKNOWN)
-		cmd->duplex = DUPLEX_FULL;
+	if (duplex == DUPLEX_UNKNOWN)
+		duplex = DUPLEX_FULL;
 
 	if (IS_MF_SI(bp)) {
 		u32 part;
@@ -410,8 +426,8 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	cfg_idx = bnx2x_get_link_cfg_idx(bp);
 	old_multi_phy_config = bp->link_params.multi_phy_config;
-	if (cmd->port != bnx2x_get_port_type(bp)) {
-		switch (cmd->port) {
+	if (cmd->base.port != bnx2x_get_port_type(bp)) {
+		switch (cmd->base.port) {
 		case PORT_TP:
 			if (!(bp->port.supported[0] & SUPPORTED_TP ||
 			      bp->port.supported[1] & SUPPORTED_TP)) {
@@ -461,7 +477,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	bp->link_params.multi_phy_config = old_multi_phy_config;
 	DP(BNX2X_MSG_ETHTOOL, "cfg_idx = %x\n", cfg_idx);
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		u32 an_supported_speed = bp->port.supported[cfg_idx];
 		if (bp->link_params.phy[EXT_PHY1].type ==
 		    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
@@ -473,51 +489,51 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		}
 
 		/* advertise the requested speed and duplex if supported */
-		if (cmd->advertising & ~an_supported_speed) {
+		if (advertising & ~an_supported_speed) {
 			DP(BNX2X_MSG_ETHTOOL,
 			   "Advertisement parameters are not supported\n");
 			return -EINVAL;
 		}
 
 		bp->link_params.req_line_speed[cfg_idx] = SPEED_AUTO_NEG;
-		bp->link_params.req_duplex[cfg_idx] = cmd->duplex;
+		bp->link_params.req_duplex[cfg_idx] = duplex;
 		bp->port.advertising[cfg_idx] = (ADVERTISED_Autoneg |
-					 cmd->advertising);
-		if (cmd->advertising) {
+					 advertising);
+		if (advertising) {
 
 			bp->link_params.speed_cap_mask[cfg_idx] = 0;
-			if (cmd->advertising & ADVERTISED_10baseT_Half) {
+			if (advertising & ADVERTISED_10baseT_Half) {
 				bp->link_params.speed_cap_mask[cfg_idx] |=
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF;
 			}
-			if (cmd->advertising & ADVERTISED_10baseT_Full)
+			if (advertising & ADVERTISED_10baseT_Full)
 				bp->link_params.speed_cap_mask[cfg_idx] |=
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL;
 
-			if (cmd->advertising & ADVERTISED_100baseT_Full)
+			if (advertising & ADVERTISED_100baseT_Full)
 				bp->link_params.speed_cap_mask[cfg_idx] |=
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL;
 
-			if (cmd->advertising & ADVERTISED_100baseT_Half) {
+			if (advertising & ADVERTISED_100baseT_Half) {
 				bp->link_params.speed_cap_mask[cfg_idx] |=
 				     PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF;
 			}
-			if (cmd->advertising & ADVERTISED_1000baseT_Half) {
+			if (advertising & ADVERTISED_1000baseT_Half) {
 				bp->link_params.speed_cap_mask[cfg_idx] |=
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_1G;
 			}
-			if (cmd->advertising & (ADVERTISED_1000baseT_Full |
+			if (advertising & (ADVERTISED_1000baseT_Full |
 						ADVERTISED_1000baseKX_Full))
 				bp->link_params.speed_cap_mask[cfg_idx] |=
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_1G;
 
-			if (cmd->advertising & (ADVERTISED_10000baseT_Full |
+			if (advertising & (ADVERTISED_10000baseT_Full |
 						ADVERTISED_10000baseKX4_Full |
 						ADVERTISED_10000baseKR_Full))
 				bp->link_params.speed_cap_mask[cfg_idx] |=
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_10G;
 
-			if (cmd->advertising & ADVERTISED_20000baseKR2_Full)
+			if (advertising & ADVERTISED_20000baseKR2_Full)
 				bp->link_params.speed_cap_mask[cfg_idx] |=
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_20G;
 		}
@@ -525,7 +541,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		/* advertise the requested speed and duplex if supported */
 		switch (speed) {
 		case SPEED_10:
-			if (cmd->duplex == DUPLEX_FULL) {
+			if (duplex == DUPLEX_FULL) {
 				if (!(bp->port.supported[cfg_idx] &
 				      SUPPORTED_10baseT_Full)) {
 					DP(BNX2X_MSG_ETHTOOL,
@@ -549,7 +565,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			break;
 
 		case SPEED_100:
-			if (cmd->duplex == DUPLEX_FULL) {
+			if (duplex == DUPLEX_FULL) {
 				if (!(bp->port.supported[cfg_idx] &
 						SUPPORTED_100baseT_Full)) {
 					DP(BNX2X_MSG_ETHTOOL,
@@ -573,7 +589,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			break;
 
 		case SPEED_1000:
-			if (cmd->duplex != DUPLEX_FULL) {
+			if (duplex != DUPLEX_FULL) {
 				DP(BNX2X_MSG_ETHTOOL,
 				   "1G half not supported\n");
 				return -EINVAL;
@@ -596,7 +612,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			break;
 
 		case SPEED_2500:
-			if (cmd->duplex != DUPLEX_FULL) {
+			if (duplex != DUPLEX_FULL) {
 				DP(BNX2X_MSG_ETHTOOL,
 				   "2.5G half not supported\n");
 				return -EINVAL;
@@ -614,7 +630,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			break;
 
 		case SPEED_10000:
-			if (cmd->duplex != DUPLEX_FULL) {
+			if (duplex != DUPLEX_FULL) {
 				DP(BNX2X_MSG_ETHTOOL,
 				   "10G half not supported\n");
 				return -EINVAL;
@@ -644,7 +660,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		}
 
 		bp->link_params.req_line_speed[cfg_idx] = speed;
-		bp->link_params.req_duplex[cfg_idx] = cmd->duplex;
+		bp->link_params.req_duplex[cfg_idx] = duplex;
 		bp->port.advertising[cfg_idx] = advertising;
 	}
 
@@ -3605,8 +3621,6 @@ static int bnx2x_get_ts_info(struct net_device *dev,
 }
 
 static const struct ethtool_ops bnx2x_ethtool_ops = {
-	.get_settings		= bnx2x_get_settings,
-	.set_settings		= bnx2x_set_settings,
 	.get_drvinfo		= bnx2x_get_drvinfo,
 	.get_regs_len		= bnx2x_get_regs_len,
 	.get_regs		= bnx2x_get_regs,
@@ -3646,6 +3660,8 @@ static int bnx2x_get_ts_info(struct net_device *dev,
 	.get_eee		= bnx2x_get_eee,
 	.set_eee		= bnx2x_set_eee,
 	.get_ts_info		= bnx2x_get_ts_info,
+	.get_link_ksettings	= bnx2x_get_link_ksettings,
+	.set_link_ksettings	= bnx2x_set_link_ksettings,
 };
 
 static const struct ethtool_ops bnx2x_vf_ethtool_ops = {
-- 
1.7.4.4
