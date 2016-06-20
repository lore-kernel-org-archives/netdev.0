From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/23] mlxsw: spectrum: Centralize VLAN-aware bridge ref counting
Date: Mon, 20 Jun 2016 23:04:06 +0200
Message-ID: <1466456661-5260-9-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:36559 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbcFUBWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 21:22:24 -0400
Received: by mail-lb0-f196.google.com with SMTP id ur4so122602lbc.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 18:22:01 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We hold a reference count on the number of ports member in the
VLAN-aware bridge, as we only support one.

Instead of always incrementing / decrementing the reference count after
joining / leaving the bridge, simply do this accounting in the join /
leave functions.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 58 +++++++++++++-------------
 1 file changed, 30 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index cd85316..b999802 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2651,7 +2651,28 @@ static bool mlxsw_sp_port_dev_check(const struct net_device *dev)
 	return dev->netdev_ops == &mlxsw_sp_port_netdev_ops;
 }
 
-static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port)
+static bool mlxsw_sp_master_bridge_check(struct mlxsw_sp *mlxsw_sp,
+					 struct net_device *br_dev)
+{
+	return !mlxsw_sp->master_bridge.dev ||
+	       mlxsw_sp->master_bridge.dev == br_dev;
+}
+
+static void mlxsw_sp_master_bridge_inc(struct mlxsw_sp *mlxsw_sp,
+				       struct net_device *br_dev)
+{
+	mlxsw_sp->master_bridge.dev = br_dev;
+	mlxsw_sp->master_bridge.ref_count++;
+}
+
+static void mlxsw_sp_master_bridge_dec(struct mlxsw_sp *mlxsw_sp)
+{
+	if (--mlxsw_sp->master_bridge.ref_count == 0)
+		mlxsw_sp->master_bridge.dev = NULL;
+}
+
+static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port,
+				     struct net_device *br_dev)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
 	int err;
@@ -2665,6 +2686,8 @@ static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port)
 	if (err)
 		return err;
 
+	mlxsw_sp_master_bridge_inc(mlxsw_sp_port->mlxsw_sp, br_dev);
+
 	mlxsw_sp_port->learning = 1;
 	mlxsw_sp_port->learning_sync = 1;
 	mlxsw_sp_port->uc_flood = 1;
@@ -2683,6 +2706,8 @@ static void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	mlxsw_sp_port_pvid_set(mlxsw_sp_port, 1);
 
+	mlxsw_sp_master_bridge_dec(mlxsw_sp_port->mlxsw_sp);
+
 	mlxsw_sp_port->learning = 0;
 	mlxsw_sp_port->learning_sync = 0;
 	mlxsw_sp_port->uc_flood = 0;
@@ -2694,26 +2719,6 @@ static void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_port_add_vid(dev, 0, 1);
 }
 
-static bool mlxsw_sp_master_bridge_check(struct mlxsw_sp *mlxsw_sp,
-					 struct net_device *br_dev)
-{
-	return !mlxsw_sp->master_bridge.dev ||
-	       mlxsw_sp->master_bridge.dev == br_dev;
-}
-
-static void mlxsw_sp_master_bridge_inc(struct mlxsw_sp *mlxsw_sp,
-				       struct net_device *br_dev)
-{
-	mlxsw_sp->master_bridge.dev = br_dev;
-	mlxsw_sp->master_bridge.ref_count++;
-}
-
-static void mlxsw_sp_master_bridge_dec(struct mlxsw_sp *mlxsw_sp)
-{
-	if (--mlxsw_sp->master_bridge.ref_count == 0)
-		mlxsw_sp->master_bridge.dev = NULL;
-}
-
 static int mlxsw_sp_lag_create(struct mlxsw_sp *mlxsw_sp, u16 lag_id)
 {
 	char sldr_pl[MLXSW_REG_SLDR_LEN];
@@ -2910,7 +2915,6 @@ static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (mlxsw_sp_port->bridged) {
 		mlxsw_sp_port_active_vlans_del(mlxsw_sp_port);
 		mlxsw_sp_port_bridge_leave(mlxsw_sp_port, false);
-		mlxsw_sp_master_bridge_dec(mlxsw_sp);
 	}
 
 	if (lag->ref_count == 1) {
@@ -3049,13 +3053,11 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 				 mlxsw_sp_port_vlan_unlink(mlxsw_sp_port,
 							   upper_dev);
 		} else if (netif_is_bridge_master(upper_dev)) {
-			if (info->linking) {
-				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port);
-				mlxsw_sp_master_bridge_inc(mlxsw_sp, upper_dev);
-			} else {
+			if (info->linking)
+				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port,
+								upper_dev);
+			else
 				mlxsw_sp_port_bridge_leave(mlxsw_sp_port, true);
-				mlxsw_sp_master_bridge_dec(mlxsw_sp);
-			}
 		} else if (netif_is_lag_master(upper_dev)) {
 			if (info->linking)
 				err = mlxsw_sp_port_lag_join(mlxsw_sp_port,
-- 
2.5.5
