From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/23] mlxsw: spectrum: Make unlinking functions return void
Date: Mon, 20 Jun 2016 23:04:04 +0200
Message-ID: <1466456661-5260-7-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:36049 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbcFTWHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 18:07:20 -0400
Received: by mail-lb0-f193.google.com with SMTP id z2so346664lbu.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 15:06:29 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When responding to unlinking CHANGEUPPER notifications we shouldn't
return any value, as it's not checked by upper layers.

In addition, there's nothing the driver can do in case of failure, so it
should simply continue and try to free as much resources as possible and
not stop on first error.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 68 +++++++++++---------------
 1 file changed, 28 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index f297b10..3500a72 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2673,8 +2673,8 @@ static int mlxsw_sp_port_bridge_join(struct mlxsw_sp_port *mlxsw_sp_port)
 	return 0;
 }
 
-static int mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
-				      bool flush_fdb)
+static void mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
+				       bool flush_fdb)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
 
@@ -2691,7 +2691,7 @@ static int mlxsw_sp_port_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	/* Add implicit VLAN interface in the device, so that untagged
 	 * packets will be classified to the default vFID.
 	 */
-	return mlxsw_sp_port_add_vid(dev, 0, 1);
+	mlxsw_sp_port_add_vid(dev, 0, 1);
 }
 
 static bool mlxsw_sp_master_bridge_check(struct mlxsw_sp *mlxsw_sp,
@@ -2873,30 +2873,25 @@ err_col_port_add:
 	return err;
 }
 
-static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
-				       struct net_device *br_dev,
-				       bool flush_fdb);
+static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
+					struct net_device *br_dev,
+					bool flush_fdb);
 
-static int mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
-				   struct net_device *lag_dev)
+static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
+				    struct net_device *lag_dev)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	struct mlxsw_sp_upper *lag;
 	u16 lag_id = mlxsw_sp_port->lag_id;
-	int err;
 
 	if (!mlxsw_sp_port->lagged)
-		return 0;
+		return;
 	lag = mlxsw_sp_lag_get(mlxsw_sp, lag_id);
 	WARN_ON(lag->ref_count == 0);
 
-	err = mlxsw_sp_lag_col_port_disable(mlxsw_sp_port, lag_id);
-	if (err)
-		return err;
-	err = mlxsw_sp_lag_col_port_remove(mlxsw_sp_port, lag_id);
-	if (err)
-		return err;
+	mlxsw_sp_lag_col_port_disable(mlxsw_sp_port, lag_id);
+	mlxsw_sp_lag_col_port_remove(mlxsw_sp_port, lag_id);
 
 	/* In case we leave a LAG device that has bridges built on top,
 	 * then their teardown sequence is never issued and we need to
@@ -2922,16 +2917,13 @@ static int mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (lag->ref_count == 1) {
 		if (mlxsw_sp_port_fdb_flush_by_lag_id(mlxsw_sp_port))
 			netdev_err(mlxsw_sp_port->dev, "Failed to flush FDB\n");
-		err = mlxsw_sp_lag_destroy(mlxsw_sp, lag_id);
-		if (err)
-			return err;
+		mlxsw_sp_lag_destroy(mlxsw_sp, lag_id);
 	}
 
 	mlxsw_core_lag_mapping_clear(mlxsw_sp->core, lag_id,
 				     mlxsw_sp_port->local_port);
 	mlxsw_sp_port->lagged = 0;
 	lag->ref_count--;
-	return 0;
 }
 
 static int mlxsw_sp_lag_dist_port_add(struct mlxsw_sp_port *mlxsw_sp_port,
@@ -2988,15 +2980,15 @@ static int mlxsw_sp_port_vlan_link(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
-static int mlxsw_sp_port_vlan_unlink(struct mlxsw_sp_port *mlxsw_sp_port,
-				     struct net_device *vlan_dev)
+static void mlxsw_sp_port_vlan_unlink(struct mlxsw_sp_port *mlxsw_sp_port,
+				      struct net_device *vlan_dev)
 {
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	u16 vid = vlan_dev_vlan_id(vlan_dev);
 
 	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
 	if (WARN_ON(!mlxsw_sp_vport))
-		return -EINVAL;
+		return;
 
 	/* When removing a VLAN device while still bridged we should first
 	 * remove it from the bridge, as we receive the bridge's notification
@@ -3010,8 +3002,6 @@ static int mlxsw_sp_port_vlan_unlink(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 
 	mlxsw_sp_vport->dev = mlxsw_sp_port->dev;
-
-	return 0;
 }
 
 static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
@@ -3057,15 +3047,14 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 				err = mlxsw_sp_port_vlan_link(mlxsw_sp_port,
 							      upper_dev);
 			else
-				err = mlxsw_sp_port_vlan_unlink(mlxsw_sp_port,
-								upper_dev);
+				 mlxsw_sp_port_vlan_unlink(mlxsw_sp_port,
+							   upper_dev);
 		} else if (netif_is_bridge_master(upper_dev)) {
 			if (info->linking) {
 				err = mlxsw_sp_port_bridge_join(mlxsw_sp_port);
 				mlxsw_sp_master_bridge_inc(mlxsw_sp, upper_dev);
 			} else {
-				err = mlxsw_sp_port_bridge_leave(mlxsw_sp_port,
-								 true);
+				mlxsw_sp_port_bridge_leave(mlxsw_sp_port, true);
 				mlxsw_sp_master_bridge_dec(mlxsw_sp, upper_dev);
 			}
 		} else if (netif_is_lag_master(upper_dev)) {
@@ -3073,8 +3062,8 @@ static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
 				err = mlxsw_sp_port_lag_join(mlxsw_sp_port,
 							     upper_dev);
 			else
-				err = mlxsw_sp_port_lag_leave(mlxsw_sp_port,
-							      upper_dev);
+				mlxsw_sp_port_lag_leave(mlxsw_sp_port,
+							upper_dev);
 		} else {
 			err = -EINVAL;
 			WARN_ON(1);
@@ -3221,9 +3210,9 @@ static void mlxsw_sp_br_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
 	kfree(vfid);
 }
 
-static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
-				       struct net_device *br_dev,
-				       bool flush_fdb)
+static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
+					struct net_device *br_dev,
+					bool flush_fdb)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
@@ -3233,7 +3222,7 @@ static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 	vfid = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
 	if (WARN_ON(!vfid))
-		return -EINVAL;
+		return;
 
 	/* We need a vFID to go back to after leaving the bridge's vFID. */
 	new_vfid = mlxsw_sp_vfid_find(mlxsw_sp, vid);
@@ -3242,7 +3231,7 @@ static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 		if (IS_ERR(new_vfid)) {
 			netdev_err(dev, "Failed to create vFID for VID=%d\n",
 				   vid);
-			return PTR_ERR(new_vfid);
+			return;
 		}
 	}
 
@@ -3306,7 +3295,7 @@ static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 	mlxsw_sp_vport->uc_flood = 0;
 	mlxsw_sp_vport->bridged = 0;
 
-	return 0;
+	return;
 
 err_port_stp_state_set:
 err_vport_flood_set:
@@ -3316,7 +3305,6 @@ err_port_vid_to_fid_invalidate:
 	/* Rollback vFID only if new. */
 	if (!new_vfid->nr_vports)
 		mlxsw_sp_vfid_destroy(mlxsw_sp, new_vfid);
-	return err;
 }
 
 static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
@@ -3459,8 +3447,8 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 			 */
 			if (!mlxsw_sp_vport)
 				return 0;
-			err = mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport,
-							  upper_dev, true);
+			mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, upper_dev,
+						    true);
 		}
 	}
 
-- 
2.5.5
