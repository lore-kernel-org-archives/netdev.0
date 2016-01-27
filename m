From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 01/11] mlxsw: spectrum: Handle port leaving LAG while bridged
Date: Wed, 27 Jan 2016 15:20:16 +0100
Message-ID: <1453904426-4960-2-git-send-email-jiri@resnulli.us>
References: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38139 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519AbcA0OUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:31 -0500
Received: by mail-wm0-f49.google.com with SMTP id p63so28692191wmp.1
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:30 -0800 (PST)
In-Reply-To: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

It is possible for a user to remove a port from a LAG device, while the
LAG device or VLAN devices on top of it are bridged. In these cases,
bridge's teardown sequence is never issued, so we need to take care of
it ourselves.

When LAG's unlinking event is received by port netdev:

1) Traverse its vPorts list and make those member in a bridge leave it.
   They will be deleted later by LAG code.

2) Make the port netdev itself leave its bridge if member in one.

Fixes: 0d65fc13042f ("mlxsw: spectrum: Implement LAG port join/leave")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 30 +++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  1 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  8 ++++++
 3 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index ce6845d..637a9d7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2200,10 +2200,14 @@ err_col_port_enable:
 	return err;
 }
 
+static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
+				       struct net_device *br_dev);
+
 static int mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 				   struct net_device *lag_dev)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_port *mlxsw_sp_vport;
 	struct mlxsw_sp_upper *lag;
 	u16 lag_id = mlxsw_sp_port->lag_id;
 	int err;
@@ -2220,6 +2224,29 @@ static int mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (err)
 		return err;
 
+	/* In case we leave a LAG device that has bridges built on top,
+	 * then their teardown sequence is never issued and we need to
+	 * invoke the necessary cleanup routines ourselves.
+	 */
+	list_for_each_entry(mlxsw_sp_vport, &mlxsw_sp_port->vports_list,
+			    vport.list) {
+		struct net_device *br_dev;
+
+		if (!mlxsw_sp_vport->bridged)
+			continue;
+
+		br_dev = mlxsw_sp_vport_br_get(mlxsw_sp_vport);
+		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport, br_dev);
+	}
+
+	if (mlxsw_sp_port->bridged) {
+		mlxsw_sp_port_active_vlans_del(mlxsw_sp_port);
+		mlxsw_sp_port_bridge_leave(mlxsw_sp_port);
+
+		if (lag->ref_count == 1)
+			mlxsw_sp_master_bridge_dec(mlxsw_sp, NULL);
+	}
+
 	if (lag->ref_count == 1) {
 		err = mlxsw_sp_lag_destroy(mlxsw_sp, lag_id);
 		if (err)
@@ -2272,9 +2299,6 @@ static int mlxsw_sp_port_lag_changed(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_sp_port_lag_tx_en_set(mlxsw_sp_port, info->tx_enabled);
 }
 
-static int mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
-				       struct net_device *br_dev);
-
 static int mlxsw_sp_port_vlan_link(struct mlxsw_sp_port *mlxsw_sp_port,
 				   struct net_device *vlan_dev)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 199f91a..7f42eb1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -253,5 +253,6 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 			   __be16 __always_unused proto, u16 vid);
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 vfid,
 			     bool set, bool only_uc);
+void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
 
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 54d25af..f627165 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -937,6 +937,14 @@ static int mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 					 vlan->vid_begin, vlan->vid_end, false);
 }
 
+void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	u16 vid;
+
+	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID)
+		__mlxsw_sp_port_vlans_del(mlxsw_sp_port, vid, vid, false);
+}
+
 static int
 mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
 			     const struct switchdev_obj_port_fdb *fdb)
-- 
1.9.3
