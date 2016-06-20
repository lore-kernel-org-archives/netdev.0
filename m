From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 21/23] mlxsw: spectrum: Refactor FDB flushing logic
Date: Mon, 20 Jun 2016 23:04:19 +0200
Message-ID: <1466456661-5260-22-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:35811 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbcFTVWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:22:06 -0400
Received: by mail-lb0-f193.google.com with SMTP id td3so252379lbb.2
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:20:44 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

FDB entries are learned using {Port / LAG ID, FID} and therefore should
be flushed whenever a port (vPort) leaves its FID (vFID).

However, when the bridge port is a LAG device (or a VLAN device on top),
then FDB flushing is conditional. Ports removed from such LAG
configurations must not trigger flushing, as other ports might still be
members in the LAG and therefore the bridge port is still active.

The decision whether to flush or not was previously computed in the
netdevice notification block, but in order to flush the entries when a
port leaves its FID this decision should be computed there.

Strip the notification block from this logic and instead move it to one
FDB flushing function that is invoked from both the FID / vFID leave
functions.

When port isn't member in LAG, FDB flushing should always occur.
Otherwise, it should occur only when the last port (vPort) member in the
LAG leaves the FID (vFID).

This will allow us - in the next patch - to simplify the cleanup code
paths that are hit whenever the topology above the port netdevs changes.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 133 +++++++--------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   1 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   2 +
 3 files changed, 47 insertions(+), 89 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 0c42515..2b1748d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2535,16 +2535,37 @@ static struct mlxsw_driver mlxsw_sp_driver = {
 	.profile			= &mlxsw_sp_config_profile,
 };
 
-static int
-mlxsw_sp_port_fdb_flush_by_port(const struct mlxsw_sp_port *mlxsw_sp_port)
+static bool mlxsw_sp_lag_port_fid_member(struct mlxsw_sp_port *lag_port,
+					 u16 fid)
+{
+	if (mlxsw_sp_fid_is_vfid(fid))
+		return mlxsw_sp_port_vport_find_by_fid(lag_port, fid);
+	else
+		return test_bit(fid, lag_port->active_vlans);
+}
+
+static bool mlxsw_sp_port_fdb_should_flush(struct mlxsw_sp_port *mlxsw_sp_port,
+					   u16 fid)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	char sfdf_pl[MLXSW_REG_SFDF_LEN];
+	u8 local_port = mlxsw_sp_port->local_port;
+	u16 lag_id = mlxsw_sp_port->lag_id;
+	int i, count = 0;
 
-	mlxsw_reg_sfdf_pack(sfdf_pl, MLXSW_REG_SFDF_FLUSH_PER_PORT);
-	mlxsw_reg_sfdf_system_port_set(sfdf_pl, mlxsw_sp_port->local_port);
+	if (!mlxsw_sp_port->lagged)
+		return true;
 
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfdf), sfdf_pl);
+	for (i = 0; i < MLXSW_SP_PORT_PER_LAG_MAX; i++) {
+		struct mlxsw_sp_port *lag_port;
+
+		lag_port = mlxsw_sp_port_lagged_get(mlxsw_sp, lag_id, i);
+		if (!lag_port || lag_port->local_port == local_port)
+			continue;
+		if (mlxsw_sp_lag_port_fid_member(lag_port, fid))
+			count++;
+	}
+
+	return !count;
 }
 
 static int
@@ -2563,18 +2584,6 @@ mlxsw_sp_port_fdb_flush_by_port_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int
-mlxsw_sp_port_fdb_flush_by_lag_id(const struct mlxsw_sp_port *mlxsw_sp_port)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	char sfdf_pl[MLXSW_REG_SFDF_LEN];
-
-	mlxsw_reg_sfdf_pack(sfdf_pl, MLXSW_REG_SFDF_FLUSH_PER_LAG);
-	mlxsw_reg_sfdf_lag_id_set(sfdf_pl, mlxsw_sp_port->lag_id);
-
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfdf), sfdf_pl);
-}
-
-static int
 mlxsw_sp_port_fdb_flush_by_lag_id_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
 				      u16 fid)
 {
@@ -2588,59 +2597,16 @@ mlxsw_sp_port_fdb_flush_by_lag_id_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfdf), sfdf_pl);
 }
 
-static int
-__mlxsw_sp_port_fdb_flush(const struct mlxsw_sp_port *mlxsw_sp_port)
-{
-	int err, last_err = 0;
-	u16 vid;
-
-	for (vid = 1; vid < VLAN_N_VID - 1; vid++) {
-		err = mlxsw_sp_port_fdb_flush_by_port_fid(mlxsw_sp_port, vid);
-		if (err)
-			last_err = err;
-	}
-
-	return last_err;
-}
-
-static int
-__mlxsw_sp_port_fdb_flush_lagged(const struct mlxsw_sp_port *mlxsw_sp_port)
+int mlxsw_sp_port_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid)
 {
-	int err, last_err = 0;
-	u16 vid;
-
-	for (vid = 1; vid < VLAN_N_VID - 1; vid++) {
-		err = mlxsw_sp_port_fdb_flush_by_lag_id_fid(mlxsw_sp_port, vid);
-		if (err)
-			last_err = err;
-	}
-
-	return last_err;
-}
-
-static int mlxsw_sp_port_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_port)
-{
-	if (!list_empty(&mlxsw_sp_port->vports_list))
-		if (mlxsw_sp_port->lagged)
-			return __mlxsw_sp_port_fdb_flush_lagged(mlxsw_sp_port);
-		else
-			return __mlxsw_sp_port_fdb_flush(mlxsw_sp_port);
-	else
-		if (mlxsw_sp_port->lagged)
-			return mlxsw_sp_port_fdb_flush_by_lag_id(mlxsw_sp_port);
-		else
-			return mlxsw_sp_port_fdb_flush_by_port(mlxsw_sp_port);
-}
+	if (!mlxsw_sp_port_fdb_should_flush(mlxsw_sp_port, fid))
+		return 0;
 
-static int mlxsw_sp_vport_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_vport,
-				    u16 fid)
-{
-	if (mlxsw_sp_vport->lagged)
-		return mlxsw_sp_port_fdb_flush_by_lag_id_fid(mlxsw_sp_vport,
+	if (mlxsw_sp_port->lagged)
+		return mlxsw_sp_port_fdb_flush_by_lag_id_fid(mlxsw_sp_port,
 							     fid);
 	else
-		return mlxsw_sp_port_fdb_flush_by_port_fid(mlxsw_sp_vport,
-							   fid);
+		return mlxsw_sp_port_fdb_flush_by_port_fid(mlxsw_sp_port, fid);
 }
 
 static bool mlxsw_sp_port_dev_check(const struct net_device *dev)
@@ -2693,14 +2659,10 @@ static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
-static void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
-				       bool flush_fdb)
+static void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
 
-	if (flush_fdb && mlxsw_sp_port_fdb_flush(mlxsw_sp_port))
-		netdev_err(mlxsw_sp_port->dev, "Failed to flush FDB\n");
-
 	mlxsw_sp_port_pvid_set(mlxsw_sp_port, 1);
 
 	mlxsw_sp_master_bridge_dec(mlxsw_sp_port->mlxsw_sp);
@@ -2874,8 +2836,7 @@ err_col_port_add:
 	return err;
 }
 
-static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
-					bool flush_fdb);
+static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
 
 static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 				    struct net_device *lag_dev)
@@ -2905,19 +2866,16 @@ static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 			continue;
 
 		br_dev = mlxsw_sp_vport_br_get(mlxsw_sp_vport);
-		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, false);
+		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
 	}
 
 	if (mlxsw_sp_port->bridged) {
 		mlxsw_sp_port_active_vlans_del(mlxsw_sp_port);
-		mlxsw_sp_port_bridge_leave(mlxsw_sp_port, false);
+		mlxsw_sp_port_bridge_leave(mlxsw_sp_port);
 	}
 
-	if (lag->ref_count == 1) {
-		if (mlxsw_sp_port_fdb_flush_by_lag_id(mlxsw_sp_port))
-			netdev_err(mlxsw_sp_port->dev, "Failed to flush FDB\n");
+	if (lag->ref_count == 1)
 		mlxsw_sp_lag_destroy(mlxsw_sp, lag_id);
-	}
 
 	mlxsw_core_lag_mapping_clear(mlxsw_sp->core, lag_id,
 				     mlxsw_sp_port->local_port);
@@ -2997,7 +2955,7 @@ static void mlxsw_sp_port_vlan_unlink(struct mlxsw_sp_port *mlxsw_sp_port,
 		struct net_device *br_dev;
 
 		br_dev = mlxsw_sp_vport_br_get(mlxsw_sp_vport);
-		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, true);
+		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
 	}
 
 	mlxsw_sp_vport->dev = mlxsw_sp_port->dev;
@@ -3053,7 +3011,7 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port,
 								upper_dev);
 			else
-				mlxsw_sp_port_bridge_leave(mlxsw_sp_port, true);
+				mlxsw_sp_port_bridge_leave(mlxsw_sp_port);
 		} else if (netif_is_lag_master(upper_dev)) {
 			if (info->linking)
 				err = mlxsw_sp_port_lag_join(mlxsw_sp_port,
@@ -3251,6 +3209,8 @@ static void mlxsw_sp_vport_br_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 
 	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
 
+	mlxsw_sp_port_fdb_flush(mlxsw_sp_vport, f->fid);
+
 	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
 	if (--f->ref_count == 0)
 		mlxsw_sp_br_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
@@ -3291,10 +3251,8 @@ err_vport_br_vfid_join:
 	return err;
 }
 
-static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
-					bool flush_fdb)
+static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 {
-	u16 fid = mlxsw_sp_vport_fid_get(mlxsw_sp_vport)->fid;
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
@@ -3306,9 +3264,6 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 	mlxsw_sp_port_stp_state_set(mlxsw_sp_vport, vid,
 				    MLXSW_REG_SPMS_STATE_FORWARDING);
 
-	if (flush_fdb)
-		mlxsw_sp_vport_fdb_flush(mlxsw_sp_vport, fid);
-
 	mlxsw_sp_vport->learning = 0;
 	mlxsw_sp_vport->learning_sync = 0;
 	mlxsw_sp_vport->uc_flood = 0;
@@ -3372,7 +3327,7 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 			 */
 			if (!mlxsw_sp_vport)
 				return 0;
-			mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, true);
+			mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
 		}
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index f419535..9122abb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -382,6 +382,7 @@ int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 			     bool set);
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
 int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
+int mlxsw_sp_port_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_port, u16 fid);
 int mlxsw_sp_port_ets_set(struct mlxsw_sp_port *mlxsw_sp_port,
 			  enum mlxsw_reg_qeec_hr hr, u8 index, u8 next_index,
 			  bool dwrr, u8 dwrr_weight);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index fc34c46..7c2b0f8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -500,6 +500,8 @@ static void __mlxsw_sp_port_fid_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (WARN_ON(!f))
 		return;
 
+	mlxsw_sp_port_fdb_flush(mlxsw_sp_port, fid);
+
 	if (--f->ref_count == 0)
 		mlxsw_sp_fid_destroy(mlxsw_sp_port->mlxsw_sp, f);
 }
-- 
2.5.5
