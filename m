From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/16] mlxsw: switchx2: Fix port speed configuration
Date: Fri, 28 Oct 2016 21:35:51 +0200
Message-ID: <1477683361-8011-6-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32966 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760047AbcJ1Tng (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:43:36 -0400
Received: by mail-wm0-f67.google.com with SMTP id m83so8766273wmc.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:43:35 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

In SwitchX-2 we configure the port speed to negotiate with 40G link only.
Add support for all other supported speeds.

Fixes: 31557f0f9755 ("mlxsw: Introduce Mellanox SwitchX-2 ASIC support")
Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 30 ++++++++++++++++++++------
 1 file changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 941393b..44dae8d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -662,6 +662,7 @@ static const struct mlxsw_sx_port_link_mode mlxsw_sx_port_link_mode[] = {
 };
 
 #define MLXSW_SX_PORT_LINK_MODE_LEN ARRAY_SIZE(mlxsw_sx_port_link_mode)
+#define MLXSW_SX_PORT_BASE_SPEED 10000 /* Mb/s */
 
 static u32 mlxsw_sx_from_ptys_supported_port(u32 ptys_eth_proto)
 {
@@ -809,6 +810,18 @@ static u32 mlxsw_sx_to_ptys_speed(u32 speed)
 	return ptys_proto;
 }
 
+static u32 mlxsw_sx_to_ptys_upper_speed(u32 upper_speed)
+{
+	u32 ptys_proto = 0;
+	int i;
+
+	for (i = 0; i < MLXSW_SX_PORT_LINK_MODE_LEN; i++) {
+		if (mlxsw_sx_port_link_mode[i].speed <= upper_speed)
+			ptys_proto |= mlxsw_sx_port_link_mode[i].mask;
+	}
+	return ptys_proto;
+}
+
 static int mlxsw_sx_port_set_settings(struct net_device *dev,
 				      struct ethtool_cmd *cmd)
 {
@@ -955,13 +968,17 @@ static int mlxsw_sx_port_stp_state_set(struct mlxsw_sx_port *mlxsw_sx_port,
 	return err;
 }
 
-static int mlxsw_sx_port_speed_set(struct mlxsw_sx_port *mlxsw_sx_port,
-				   u32 speed)
+static int
+mlxsw_sx_port_speed_by_width_set(struct mlxsw_sx_port *mlxsw_sx_port, u8 width)
 {
 	struct mlxsw_sx *mlxsw_sx = mlxsw_sx_port->mlxsw_sx;
+	u32 upper_speed = MLXSW_SX_PORT_BASE_SPEED * width;
 	char ptys_pl[MLXSW_REG_PTYS_LEN];
+	u32 eth_proto_admin;
 
-	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sx_port->local_port, speed);
+	eth_proto_admin = mlxsw_sx_to_ptys_upper_speed(upper_speed);
+	mlxsw_reg_ptys_pack(ptys_pl, mlxsw_sx_port->local_port,
+			    eth_proto_admin);
 	return mlxsw_reg_write(mlxsw_sx->core, MLXSW_REG(ptys), ptys_pl);
 }
 
@@ -977,7 +994,7 @@ mlxsw_sx_port_mac_learning_mode_set(struct mlxsw_sx_port *mlxsw_sx_port,
 }
 
 static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
-				u8 module)
+				u8 module, u8 width)
 {
 	struct mlxsw_sx_port *mlxsw_sx_port;
 	struct net_device *dev;
@@ -1038,8 +1055,7 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port,
 		goto err_port_swid_set;
 	}
 
-	err = mlxsw_sx_port_speed_set(mlxsw_sx_port,
-				      MLXSW_REG_PTYS_ETH_SPEED_40GBASE_CR4);
+	err = mlxsw_sx_port_speed_by_width_set(mlxsw_sx_port, width);
 	if (err) {
 		dev_err(mlxsw_sx->bus_info->dev, "Port %d: Failed to set speed\n",
 			mlxsw_sx_port->local_port);
@@ -1156,7 +1172,7 @@ static int mlxsw_sx_ports_create(struct mlxsw_sx *mlxsw_sx)
 			goto err_port_module_info_get;
 		if (!width)
 			continue;
-		err = mlxsw_sx_port_create(mlxsw_sx, i, module);
+		err = mlxsw_sx_port_create(mlxsw_sx, i, module, width);
 		if (err)
 			goto err_port_create;
 	}
-- 
2.5.5
