From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: mellanox: switchx2: use new api ethtool_{get|set}_link_ksettings
Date: Wed,  8 Feb 2017 00:07:33 +0100
Message-ID: <1486508853-29623-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: jiri@mellanox.com, idosch@mellanox.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |   47 +++++++++++++++---------
 1 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 169193e..ec1e886 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -733,7 +733,7 @@ static u32 mlxsw_sx_from_ptys_advert_link(u32 ptys_eth_proto)
 }
 
 static void mlxsw_sx_from_ptys_speed_duplex(bool carrier_ok, u32 ptys_eth_proto,
-					    struct ethtool_cmd *cmd)
+					    struct ethtool_link_ksettings *cmd)
 {
 	u32 speed = SPEED_UNKNOWN;
 	u8 duplex = DUPLEX_UNKNOWN;
@@ -750,8 +750,8 @@ static void mlxsw_sx_from_ptys_speed_duplex(bool carrier_ok, u32 ptys_eth_proto,
 		}
 	}
 out:
-	ethtool_cmd_speed_set(cmd, speed);
-	cmd->duplex = duplex;
+	cmd->base.speed = speed;
+	cmd->base.duplex = duplex;
 }
 
 static u8 mlxsw_sx_port_connector_port(u32 ptys_eth_proto)
@@ -776,8 +776,9 @@ static u8 mlxsw_sx_port_connector_port(u32 ptys_eth_proto)
 	return PORT_OTHER;
 }
 
-static int mlxsw_sx_port_get_settings(struct net_device *dev,
-				      struct ethtool_cmd *cmd)
+static int
+mlxsw_sx_port_get_link_ksettings(struct net_device *dev,
+				 struct ethtool_link_ksettings *cmd)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
 	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
@@ -785,6 +786,7 @@ static int mlxsw_sx_port_get_settings(struct net_device *dev,
 	u32 eth_proto_cap;
 	u32 eth_proto_admin;
 	u32 eth_proto_oper;
+	u32 supported, advertising, lp_advertising;
 	int err;
 
 	mlxsw_reg_ptys_eth_pack(ptys_pl, mlxsw_sx_port->local_port, 0);
@@ -796,18 +798,24 @@ static int mlxsw_sx_port_get_settings(struct net_device *dev,
 	mlxsw_reg_ptys_eth_unpack(ptys_pl, &eth_proto_cap,
 				  &eth_proto_admin, &eth_proto_oper);
 
-	cmd->supported = mlxsw_sx_from_ptys_supported_port(eth_proto_cap) |
+	supported = mlxsw_sx_from_ptys_supported_port(eth_proto_cap) |
 			 mlxsw_sx_from_ptys_supported_link(eth_proto_cap) |
 			 SUPPORTED_Pause | SUPPORTED_Asym_Pause;
-	cmd->advertising = mlxsw_sx_from_ptys_advert_link(eth_proto_admin);
+	advertising = mlxsw_sx_from_ptys_advert_link(eth_proto_admin);
 	mlxsw_sx_from_ptys_speed_duplex(netif_carrier_ok(dev),
 					eth_proto_oper, cmd);
 
 	eth_proto_oper = eth_proto_oper ? eth_proto_oper : eth_proto_cap;
-	cmd->port = mlxsw_sx_port_connector_port(eth_proto_oper);
-	cmd->lp_advertising = mlxsw_sx_from_ptys_advert_link(eth_proto_oper);
+	cmd->base.port = mlxsw_sx_port_connector_port(eth_proto_oper);
+	lp_advertising = mlxsw_sx_from_ptys_advert_link(eth_proto_oper);
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.lp_advertising,
+						lp_advertising);
 
-	cmd->transceiver = XCVR_INTERNAL;
 	return 0;
 }
 
@@ -847,8 +855,9 @@ static u32 mlxsw_sx_to_ptys_upper_speed(u32 upper_speed)
 	return ptys_proto;
 }
 
-static int mlxsw_sx_port_set_settings(struct net_device *dev,
-				      struct ethtool_cmd *cmd)
+static int
+mlxsw_sx_port_set_link_ksettings(struct net_device *dev,
+				 const struct ethtool_link_ksettings *cmd)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port = netdev_priv(dev);
 	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
@@ -857,13 +866,17 @@ static int mlxsw_sx_port_set_settings(struct net_device *dev,
 	u32 eth_proto_new;
 	u32 eth_proto_cap;
 	u32 eth_proto_admin;
+	u32 advertising;
 	bool is_up;
 	int err;
 
-	speed = ethtool_cmd_speed(cmd);
+	speed = cmd->base.speed;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
-	eth_proto_new = cmd->autoneg == AUTONEG_ENABLE ?
-		mlxsw_sx_to_ptys_advert_link(cmd->advertising) :
+	eth_proto_new = cmd->base.autoneg == AUTONEG_ENABLE ?
+		mlxsw_sx_to_ptys_advert_link(advertising) :
 		mlxsw_sx_to_ptys_speed(speed);
 
 	mlxsw_reg_ptys_eth_pack(ptys_pl, mlxsw_sx_port->local_port, 0);
@@ -920,8 +933,8 @@ static int mlxsw_sx_port_set_settings(struct net_device *dev,
 	.get_strings		= mlxsw_sx_port_get_strings,
 	.get_ethtool_stats	= mlxsw_sx_port_get_stats,
 	.get_sset_count		= mlxsw_sx_port_get_sset_count,
-	.get_settings		= mlxsw_sx_port_get_settings,
-	.set_settings		= mlxsw_sx_port_set_settings,
+	.get_link_ksettings	= mlxsw_sx_port_get_link_ksettings,
+	.set_link_ksettings	= mlxsw_sx_port_set_link_ksettings,
 };
 
 static int mlxsw_sx_port_attr_get(struct net_device *dev,
-- 
1.7.4.4
