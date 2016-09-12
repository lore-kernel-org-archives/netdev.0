From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] mlxsw: spectrum: Add support for new ethtool API
Date: Mon, 12 Sep 2016 13:26:27 +0200
Message-ID: <1473679587-9112-6-git-send-email-jiri@resnulli.us>
References: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34506 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755984AbcILL0g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 07:26:36 -0400
Received: by mail-wm0-f68.google.com with SMTP id g141so2138432wmd.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 04:26:35 -0700 (PDT)
In-Reply-To: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Remove the deprecated {get,set}_settings callbacks and instead add
{get,set}_link_ksettings along with support for newly available speeds.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      |   1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 344 +++++++++++++------------
 2 files changed, 185 insertions(+), 160 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 43ce27f..4e2354c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2164,6 +2164,7 @@ MLXSW_ITEM32(reg, ptys, an_status, 0x04, 28, 4);
 #define MLXSW_REG_PTYS_ETH_SPEED_10GBASE_ER_LR		BIT(14)
 #define MLXSW_REG_PTYS_ETH_SPEED_40GBASE_SR4		BIT(15)
 #define MLXSW_REG_PTYS_ETH_SPEED_40GBASE_LR4_ER4	BIT(16)
+#define MLXSW_REG_PTYS_ETH_SPEED_50GBASE_SR2		BIT(18)
 #define MLXSW_REG_PTYS_ETH_SPEED_50GBASE_KR4		BIT(19)
 #define MLXSW_REG_PTYS_ETH_SPEED_100GBASE_CR4		BIT(20)
 #define MLXSW_REG_PTYS_ETH_SPEED_100GBASE_SR4		BIT(21)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index f7db669..47f2a41 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1598,158 +1598,179 @@ static int mlxsw_sp_port_get_sset_count(struct net_device *dev, int sset)
 }
 
 struct mlxsw_sp_port_link_mode {
+	enum ethtool_link_mode_bit_indices mask_ethtool;
 	u32 mask;
-	u32 supported;
-	u32 advertised;
 	u32 speed;
 };
 
 static const struct mlxsw_sp_port_link_mode mlxsw_sp_port_link_mode[] = {
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_100BASE_T,
-		.supported	= SUPPORTED_100baseT_Full,
-		.advertised	= ADVERTISED_100baseT_Full,
-		.speed		= 100,
-	},
-	{
-		.mask		= MLXSW_REG_PTYS_ETH_SPEED_100BASE_TX,
-		.speed		= 100,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_100baseT_Full_BIT,
+		.speed		= SPEED_100,
 	},
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_SGMII |
 				  MLXSW_REG_PTYS_ETH_SPEED_1000BASE_KX,
-		.supported	= SUPPORTED_1000baseKX_Full,
-		.advertised	= ADVERTISED_1000baseKX_Full,
-		.speed		= 1000,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_1000baseKX_Full_BIT,
+		.speed		= SPEED_1000,
 	},
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_10GBASE_T,
-		.supported	= SUPPORTED_10000baseT_Full,
-		.advertised	= ADVERTISED_10000baseT_Full,
-		.speed		= 10000,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_10000baseT_Full_BIT,
+		.speed		= SPEED_10000,
 	},
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_10GBASE_CX4 |
 				  MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KX4,
-		.supported	= SUPPORTED_10000baseKX4_Full,
-		.advertised	= ADVERTISED_10000baseKX4_Full,
-		.speed		= 10000,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT,
+		.speed		= SPEED_10000,
 	},
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KR |
 				  MLXSW_REG_PTYS_ETH_SPEED_10GBASE_CR |
 				  MLXSW_REG_PTYS_ETH_SPEED_10GBASE_SR |
 				  MLXSW_REG_PTYS_ETH_SPEED_10GBASE_ER_LR,
-		.supported	= SUPPORTED_10000baseKR_Full,
-		.advertised	= ADVERTISED_10000baseKR_Full,
-		.speed		= 10000,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_10000baseKR_Full_BIT,
+		.speed		= SPEED_10000,
 	},
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_20GBASE_KR2,
-		.supported	= SUPPORTED_20000baseKR2_Full,
-		.advertised	= ADVERTISED_20000baseKR2_Full,
-		.speed		= 20000,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_20000baseKR2_Full_BIT,
+		.speed		= SPEED_20000,
 	},
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_40GBASE_CR4,
-		.supported	= SUPPORTED_40000baseCR4_Full,
-		.advertised	= ADVERTISED_40000baseCR4_Full,
-		.speed		= 40000,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_40000baseCR4_Full_BIT,
+		.speed		= SPEED_40000,
 	},
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_40GBASE_KR4,
-		.supported	= SUPPORTED_40000baseKR4_Full,
-		.advertised	= ADVERTISED_40000baseKR4_Full,
-		.speed		= 40000,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_40000baseKR4_Full_BIT,
+		.speed		= SPEED_40000,
 	},
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_40GBASE_SR4,
-		.supported	= SUPPORTED_40000baseSR4_Full,
-		.advertised	= ADVERTISED_40000baseSR4_Full,
-		.speed		= 40000,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_40000baseSR4_Full_BIT,
+		.speed		= SPEED_40000,
 	},
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_40GBASE_LR4_ER4,
-		.supported	= SUPPORTED_40000baseLR4_Full,
-		.advertised	= ADVERTISED_40000baseLR4_Full,
-		.speed		= 40000,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_40000baseLR4_Full_BIT,
+		.speed		= SPEED_40000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_25GBASE_CR,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_25000baseCR_Full_BIT,
+		.speed		= SPEED_25000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_25GBASE_KR,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_25000baseKR_Full_BIT,
+		.speed		= SPEED_25000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_25GBASE_SR,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_25000baseSR_Full_BIT,
+		.speed		= SPEED_25000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_25GBASE_SR,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_25000baseSR_Full_BIT,
+		.speed		= SPEED_25000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_50GBASE_CR2,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT,
+		.speed		= SPEED_50000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_50GBASE_KR2,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT,
+		.speed		= SPEED_50000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_50GBASE_SR2,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT,
+		.speed		= SPEED_50000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_56GBASE_R4,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_56000baseKR4_Full_BIT,
+		.speed		= SPEED_56000,
 	},
 	{
-		.mask		= MLXSW_REG_PTYS_ETH_SPEED_25GBASE_CR |
-				  MLXSW_REG_PTYS_ETH_SPEED_25GBASE_KR |
-				  MLXSW_REG_PTYS_ETH_SPEED_25GBASE_SR,
-		.speed		= 25000,
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_56GBASE_R4,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT,
+		.speed		= SPEED_56000,
 	},
 	{
-		.mask		= MLXSW_REG_PTYS_ETH_SPEED_50GBASE_KR4 |
-				  MLXSW_REG_PTYS_ETH_SPEED_50GBASE_CR2 |
-				  MLXSW_REG_PTYS_ETH_SPEED_50GBASE_KR2,
-		.speed		= 50000,
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_56GBASE_R4,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT,
+		.speed		= SPEED_56000,
 	},
 	{
 		.mask		= MLXSW_REG_PTYS_ETH_SPEED_56GBASE_R4,
-		.supported	= SUPPORTED_56000baseKR4_Full,
-		.advertised	= ADVERTISED_56000baseKR4_Full,
-		.speed		= 56000,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
+		.speed		= SPEED_56000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_100GBASE_CR4,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT,
+		.speed		= SPEED_100000,
 	},
 	{
-		.mask		= MLXSW_REG_PTYS_ETH_SPEED_100GBASE_CR4 |
-				  MLXSW_REG_PTYS_ETH_SPEED_100GBASE_SR4 |
-				  MLXSW_REG_PTYS_ETH_SPEED_100GBASE_KR4 |
-				  MLXSW_REG_PTYS_ETH_SPEED_100GBASE_LR4_ER4,
-		.speed		= 100000,
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_100GBASE_SR4,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT,
+		.speed		= SPEED_100000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_100GBASE_KR4,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT,
+		.speed		= SPEED_100000,
+	},
+	{
+		.mask		= MLXSW_REG_PTYS_ETH_SPEED_100GBASE_LR4_ER4,
+		.mask_ethtool	= ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
+		.speed		= SPEED_100000,
 	},
 };
 
 #define MLXSW_SP_PORT_LINK_MODE_LEN ARRAY_SIZE(mlxsw_sp_port_link_mode)
 
-static u32 mlxsw_sp_from_ptys_supported_port(u32 ptys_eth_proto)
+static void
+mlxsw_sp_from_ptys_supported_port(u32 ptys_eth_proto,
+				  struct ethtool_link_ksettings *cmd)
 {
-	u32 modes = 0;
-
 	if (ptys_eth_proto & (MLXSW_REG_PTYS_ETH_SPEED_10GBASE_CR |
 			      MLXSW_REG_PTYS_ETH_SPEED_10GBASE_SR |
 			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_CR4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_SR4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_100GBASE_SR4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_SGMII))
-		modes |= SUPPORTED_FIBRE;
+		ethtool_link_ksettings_add_link_mode(cmd, supported, FIBRE);
 
 	if (ptys_eth_proto & (MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KR |
 			      MLXSW_REG_PTYS_ETH_SPEED_10GBASE_KX4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_KR4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_100GBASE_KR4 |
 			      MLXSW_REG_PTYS_ETH_SPEED_1000BASE_KX))
-		modes |= SUPPORTED_Backplane;
-	return modes;
+		ethtool_link_ksettings_add_link_mode(cmd, supported, Backplane);
 }
 
-static u32 mlxsw_sp_from_ptys_supported_link(u32 ptys_eth_proto)
+static void mlxsw_sp_from_ptys_link(u32 ptys_eth_proto, unsigned long *mode)
 {
-	u32 modes = 0;
 	int i;
 
 	for (i = 0; i < MLXSW_SP_PORT_LINK_MODE_LEN; i++) {
 		if (ptys_eth_proto & mlxsw_sp_port_link_mode[i].mask)
-			modes |= mlxsw_sp_port_link_mode[i].supported;
+			__set_bit(mlxsw_sp_port_link_mode[i].mask_ethtool,
+				  mode);
 	}
-	return modes;
-}
-
-static u32 mlxsw_sp_from_ptys_advert_link(u32 ptys_eth_proto)
-{
-	u32 modes = 0;
-	int i;
-
-	for (i = 0; i < MLXSW_SP_PORT_LINK_MODE_LEN; i++) {
-		if (ptys_eth_proto & mlxsw_sp_port_link_mode[i].mask)
-			modes |= mlxsw_sp_port_link_mode[i].advertised;
-	}
-	return modes;
 }
 
 static void mlxsw_sp_from_ptys_speed_duplex(bool carrier_ok, u32 ptys_eth_proto,
-					    struct ethtool_cmd *cmd)
+					    struct ethtool_link_ksettings *cmd)
 {
 	u32 speed = SPEED_UNKNOWN;
 	u8 duplex = DUPLEX_UNKNOWN;
@@ -1766,8 +1787,8 @@ static void mlxsw_sp_from_ptys_speed_duplex(bool carrier_ok, u32 ptys_eth_proto,
 		}
 	}
 out:
-	ethtool_cmd_speed_set(cmd, speed);
-	cmd->duplex = duplex;
+	cmd->base.speed = speed;
+	cmd->base.duplex = duplex;
 }
 
 static u8 mlxsw_sp_port_connector_port(u32 ptys_eth_proto)
@@ -1792,60 +1813,15 @@ static u8 mlxsw_sp_port_connector_port(u32 ptys_eth_proto)
 	return PORT_OTHER;
 }
 
-static int mlxsw_sp_port_get_settings(struct net_device *dev,
-				      struct ethtool_cmd *cmd)
-{
-	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	char ptys_pl[MLXSW_REG_PTYS_LEN];
-	u32 eth_proto_cap;
-	u32 eth_proto_admin;
-	u32 eth_proto_oper;
-	u8 autoneg_status;
-	u32 eth_proto_lp;
-	int err;
-
-	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, 0);
-	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
-	if (err) {
-		netdev_err(dev, "Failed to get proto");
-		return err;
-	}
-	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap,
-			      &eth_proto_admin, &eth_proto_oper);
-	eth_proto_lp = mlxsw_reg_ptys_eth_proto_lp_advertise_get(ptys_pl);
-	autoneg_status = mlxsw_reg_ptys_an_status_get(ptys_pl);
-
-	cmd->supported = mlxsw_sp_from_ptys_supported_port(eth_proto_cap) |
-			 mlxsw_sp_from_ptys_supported_link(eth_proto_cap) |
-			 SUPPORTED_Pause | SUPPORTED_Asym_Pause |
-			 SUPPORTED_Autoneg;
-	if (mlxsw_sp_port->link.autoneg) {
-		cmd->advertising =
-			mlxsw_sp_from_ptys_advert_link(eth_proto_admin);
-		cmd->advertising |= ADVERTISED_Autoneg;
-		cmd->autoneg = AUTONEG_ENABLE;
-	}
-	mlxsw_sp_from_ptys_speed_duplex(netif_carrier_ok(dev),
-					eth_proto_oper, cmd);
-
-	cmd->port = mlxsw_sp_port_connector_port(eth_proto_oper);
-
-	if (autoneg_status == MLXSW_REG_PTYS_AN_STATUS_OK && eth_proto_lp)
-		cmd->lp_advertising =
-			mlxsw_sp_from_ptys_advert_link(eth_proto_lp);
-
-	cmd->transceiver = XCVR_INTERNAL;
-	return 0;
-}
-
-static u32 mlxsw_sp_to_ptys_advert_link(u32 advertising)
+static u32
+mlxsw_sp_to_ptys_advert_link(const struct ethtool_link_ksettings *cmd)
 {
 	u32 ptys_proto = 0;
 	int i;
 
 	for (i = 0; i < MLXSW_SP_PORT_LINK_MODE_LEN; i++) {
-		if (advertising & mlxsw_sp_port_link_mode[i].advertised)
+		if (test_bit(mlxsw_sp_port_link_mode[i].mask_ethtool,
+			     cmd->link_modes.advertising))
 			ptys_proto |= mlxsw_sp_port_link_mode[i].mask;
 	}
 	return ptys_proto;
@@ -1875,65 +1851,113 @@ static u32 mlxsw_sp_to_ptys_upper_speed(u32 upper_speed)
 	return ptys_proto;
 }
 
-static int mlxsw_sp_port_set_settings(struct net_device *dev,
-				      struct ethtool_cmd *cmd)
+static void mlxsw_sp_port_get_link_supported(u32 eth_proto_cap,
+					     struct ethtool_link_ksettings *cmd)
+{
+	ethtool_link_ksettings_add_link_mode(cmd, supported, Asym_Pause);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, Autoneg);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, Pause);
+
+	mlxsw_sp_from_ptys_supported_port(eth_proto_cap, cmd);
+	mlxsw_sp_from_ptys_link(eth_proto_cap, cmd->link_modes.supported);
+}
+
+static void mlxsw_sp_port_get_link_advertise(u32 eth_proto_admin, bool autoneg,
+					     struct ethtool_link_ksettings *cmd)
 {
+	if (!autoneg)
+		return;
+
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, Autoneg);
+	mlxsw_sp_from_ptys_link(eth_proto_admin, cmd->link_modes.advertising);
+}
+
+static void
+mlxsw_sp_port_get_link_lp_advertise(u32 eth_proto_lp, u8 autoneg_status,
+				    struct ethtool_link_ksettings *cmd)
+{
+	if (autoneg_status != MLXSW_REG_PTYS_AN_STATUS_OK || !eth_proto_lp)
+		return;
+
+	ethtool_link_ksettings_add_link_mode(cmd, lp_advertising, Autoneg);
+	mlxsw_sp_from_ptys_link(eth_proto_lp, cmd->link_modes.lp_advertising);
+}
+
+static int mlxsw_sp_port_get_link_ksettings(struct net_device *dev,
+					    struct ethtool_link_ksettings *cmd)
+{
+	u32 eth_proto_cap, eth_proto_admin, eth_proto_oper, eth_proto_lp;
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char ptys_pl[MLXSW_REG_PTYS_LEN];
-	u32 speed;
-	u32 eth_proto_new;
-	u32 eth_proto_cap;
-	u32 eth_proto_admin;
+	u8 autoneg_status;
 	bool autoneg;
 	int err;
 
-	autoneg = cmd->autoneg == AUTONEG_ENABLE;
-	speed = ethtool_cmd_speed(cmd);
+	autoneg = mlxsw_sp_port->link.autoneg;
+	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, 0);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
+	if (err)
+		return err;
+	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap, &eth_proto_admin,
+			      &eth_proto_oper);
+
+	mlxsw_sp_port_get_link_supported(eth_proto_cap, cmd);
 
-	eth_proto_new = autoneg ?
-		mlxsw_sp_to_ptys_advert_link(cmd->advertising) :
-		mlxsw_sp_to_ptys_speed(speed);
+	mlxsw_sp_port_get_link_advertise(eth_proto_admin, autoneg, cmd);
+
+	eth_proto_lp = mlxsw_reg_ptys_eth_proto_lp_advertise_get(ptys_pl);
+	autoneg_status = mlxsw_reg_ptys_an_status_get(ptys_pl);
+	mlxsw_sp_port_get_link_lp_advertise(eth_proto_lp, autoneg_status, cmd);
+
+	cmd->base.autoneg = autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+	cmd->base.port = mlxsw_sp_port_connector_port(eth_proto_oper);
+	mlxsw_sp_from_ptys_speed_duplex(netif_carrier_ok(dev), eth_proto_oper,
+					cmd);
+
+	return 0;
+}
+
+static int
+mlxsw_sp_port_set_link_ksettings(struct net_device *dev,
+				 const struct ethtool_link_ksettings *cmd)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char ptys_pl[MLXSW_REG_PTYS_LEN];
+	u32 eth_proto_cap, eth_proto_new;
+	bool autoneg;
+	int err;
 
 	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, 0);
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
-	if (err) {
-		netdev_err(dev, "Failed to get proto");
+	if (err)
 		return err;
-	}
-	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap, &eth_proto_admin, NULL);
+	mlxsw_reg_ptys_unpack(ptys_pl, &eth_proto_cap, NULL, NULL);
+
+	autoneg = cmd->base.autoneg == AUTONEG_ENABLE;
+	eth_proto_new = autoneg ?
+		mlxsw_sp_to_ptys_advert_link(cmd) :
+		mlxsw_sp_to_ptys_speed(cmd->base.speed);
 
 	eth_proto_new = eth_proto_new & eth_proto_cap;
 	if (!eth_proto_new) {
-		netdev_err(dev, "Not supported proto admin requested");
+		netdev_err(dev, "No supported speed requested\n");
 		return -EINVAL;
 	}
-	if (eth_proto_new == eth_proto_admin)
-		return 0;
 
 	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sp_port->local_port, eth_proto_new);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ptys), ptys_pl);
-	if (err) {
-		netdev_err(dev, "Failed to set proto admin");
+	if (err)
 		return err;
-	}
 
 	if (!netif_running(dev))
 		return 0;
 
 	mlxsw_sp_port->link.autoneg = autoneg;
 
-	err = mlxsw_sp_port_admin_status_set(mlxsw_sp_port, false);
-	if (err) {
-		netdev_err(dev, "Failed to set admin status");
-		return err;
-	}
-
-	err = mlxsw_sp_port_admin_status_set(mlxsw_sp_port, true);
-	if (err) {
-		netdev_err(dev, "Failed to set admin status");
-		return err;
-	}
+	mlxsw_sp_port_admin_status_set(mlxsw_sp_port, false);
+	mlxsw_sp_port_admin_status_set(mlxsw_sp_port, true);
 
 	return 0;
 }
@@ -1947,8 +1971,8 @@ static const struct ethtool_ops mlxsw_sp_port_ethtool_ops = {
 	.set_phys_id		= mlxsw_sp_port_set_phys_id,
 	.get_ethtool_stats	= mlxsw_sp_port_get_stats,
 	.get_sset_count		= mlxsw_sp_port_get_sset_count,
-	.get_settings		= mlxsw_sp_port_get_settings,
-	.set_settings		= mlxsw_sp_port_set_settings,
+	.get_link_ksettings	= mlxsw_sp_port_get_link_ksettings,
+	.set_link_ksettings	= mlxsw_sp_port_set_link_ksettings,
 };
 
 static int
-- 
2.5.5
