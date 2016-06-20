From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/23] mlxsw: spectrum: Use join / leave functions for vFID operations
Date: Mon, 20 Jun 2016 23:04:13 +0200
Message-ID: <1466456661-5260-16-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36744 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbcFTVQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:16:19 -0400
Received: by mail-lf0-f65.google.com with SMTP id a2so6820575lfe.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:16:12 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a vPort is created or when it joins a bridge we always do the same
set of operations:

1) Create the vFID, if not already created
2) Setup flooding for the vFID
3) Map the {Port, VID} to the vFID

When a vPort is destroyed or when it leaves a bridge the reverse is
performed.

Encapsulate the above in join / leave functions and simplify the code.
FIDs and rFIDs will use a similar set of functions.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 304 ++++++++++---------------
 1 file changed, 126 insertions(+), 178 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 8ef8d0b..ad8e447 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -712,8 +712,7 @@ static void mlxsw_sp_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
 }
 
 static struct mlxsw_sp_port *
-mlxsw_sp_port_vport_create(struct mlxsw_sp_port *mlxsw_sp_port,
-			   struct mlxsw_sp_fid *f)
+mlxsw_sp_port_vport_create(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
 {
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 
@@ -731,8 +730,7 @@ mlxsw_sp_port_vport_create(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_vport->stp_state = BR_STATE_FORWARDING;
 	mlxsw_sp_vport->lagged = mlxsw_sp_port->lagged;
 	mlxsw_sp_vport->lag_id = mlxsw_sp_port->lag_id;
-	mlxsw_sp_vport->vport.f = f;
-	mlxsw_sp_vport->vport.vid = f->vid;
+	mlxsw_sp_vport->vport.vid = vid;
 
 	list_add(&mlxsw_sp_vport->vport.list, &mlxsw_sp_port->vports_list);
 
@@ -755,13 +753,62 @@ static int mlxsw_sp_vport_fid_map(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 					    vid);
 }
 
+static int mlxsw_sp_vport_vfid_join(struct mlxsw_sp_port *mlxsw_sp_vport)
+{
+	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+	struct mlxsw_sp_fid *f;
+	int err;
+
+	f = mlxsw_sp_vfid_find(mlxsw_sp_vport->mlxsw_sp, vid);
+	if (!f) {
+		f = mlxsw_sp_vfid_create(mlxsw_sp_vport->mlxsw_sp, vid);
+		if (IS_ERR(f))
+			return PTR_ERR(f);
+	}
+
+	if (!f->ref_count) {
+		err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, true);
+		if (err)
+			goto err_vport_flood_set;
+	}
+
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, true);
+	if (err)
+		goto err_vport_fid_map;
+
+	mlxsw_sp_vport->vport.f = f;
+	f->ref_count++;
+
+	return 0;
+
+err_vport_fid_map:
+	if (!f->ref_count)
+		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
+err_vport_flood_set:
+	if (!f->ref_count)
+		mlxsw_sp_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
+	return err;
+}
+
+static void mlxsw_sp_vport_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
+{
+	struct mlxsw_sp_fid *f = mlxsw_sp_vport->vport.f;
+
+	mlxsw_sp_vport->vport.f = NULL;
+
+	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
+
+	if (--f->ref_count == 0) {
+		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
+		mlxsw_sp_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
+	}
+}
+
 int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 			  u16 vid)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_port *mlxsw_sp_vport;
-	struct mlxsw_sp_fid *f;
 	int err;
 
 	/* VLAN 0 is added to HW filter when device goes up, but it is
@@ -775,30 +822,10 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		return 0;
 	}
 
-	f = mlxsw_sp_vfid_find(mlxsw_sp, vid);
-	if (!f) {
-		f = mlxsw_sp_vfid_create(mlxsw_sp, vid);
-		if (IS_ERR(f)) {
-			netdev_err(dev, "Failed to create vFID for VID=%d\n",
-				   vid);
-			return PTR_ERR(f);
-		}
-	}
-
-	mlxsw_sp_vport = mlxsw_sp_port_vport_create(mlxsw_sp_port, f);
+	mlxsw_sp_vport = mlxsw_sp_port_vport_create(mlxsw_sp_port, vid);
 	if (!mlxsw_sp_vport) {
 		netdev_err(dev, "Failed to create vPort for VID=%d\n", vid);
-		err = -ENOMEM;
-		goto err_port_vport_create;
-	}
-
-	if (!f->ref_count) {
-		err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, true);
-		if (err) {
-			netdev_err(dev, "Failed to setup flooding for FID=%d\n",
-				   f->fid);
-			goto err_vport_flood_set;
-		}
+		return -ENOMEM;
 	}
 
 	/* When adding the first VLAN interface on a bridged port we need to
@@ -813,11 +840,10 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		}
 	}
 
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, true);
+	err = mlxsw_sp_vport_vfid_join(mlxsw_sp_vport);
 	if (err) {
-		netdev_err(dev, "Failed to map {Port, VID=%d} to FID=%d\n",
-			   vid, f->fid);
-		goto err_vport_fid_map;
+		netdev_err(dev, "Failed to join vFID\n");
+		goto err_vport_vfid_join;
 	}
 
 	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
@@ -840,8 +866,6 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		goto err_port_stp_state_set;
 	}
 
-	f->ref_count++;
-
 	return 0;
 
 err_port_stp_state_set:
@@ -849,18 +873,12 @@ err_port_stp_state_set:
 err_port_add_vid:
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
 err_port_vid_learning_set:
-	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
-err_vport_fid_map:
+	mlxsw_sp_vport_vfid_leave(mlxsw_sp_vport);
+err_vport_vfid_join:
 	if (list_is_singular(&mlxsw_sp_port->vports_list))
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 err_port_vp_mode_trans:
-	if (!f->ref_count)
-		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
-err_vport_flood_set:
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
-err_port_vport_create:
-	if (!f->ref_count)
-		mlxsw_sp_vfid_destroy(mlxsw_sp, f);
 	return err;
 }
 
@@ -869,7 +887,6 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port *mlxsw_sp_vport;
-	struct mlxsw_sp_fid *f;
 	int err;
 
 	/* VLAN 0 is removed from HW filter when device goes down, but
@@ -884,8 +901,6 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 		return 0;
 	}
 
-	f = mlxsw_sp_vport->vport.f;
-
 	err = mlxsw_sp_port_stp_state_set(mlxsw_sp_vport, vid,
 					  MLXSW_REG_SPMS_STATE_DISCARDING);
 	if (err) {
@@ -906,12 +921,7 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 		return err;
 	}
 
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
-	if (err) {
-		netdev_err(dev, "Failed to invalidate {Port, VID=%d} to FID=%d mapping\n",
-			   vid, f->fid);
-		return err;
-	}
+	mlxsw_sp_vport_vfid_leave(mlxsw_sp_vport);
 
 	/* When removing the last VLAN interface on a bridged port we need to
 	 * transition all active 802.1Q bridge VLANs to use VID to FID
@@ -925,13 +935,8 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 		}
 	}
 
-	f->ref_count--;
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
 
-	/* Destroy the vFID if no vPorts are assigned to it anymore. */
-	if (!f->ref_count)
-		mlxsw_sp_vfid_destroy(mlxsw_sp_port->mlxsw_sp, f);
-
 	return 0;
 }
 
@@ -2625,10 +2630,9 @@ static int mlxsw_sp_port_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_port)
 			return mlxsw_sp_port_fdb_flush_by_port(mlxsw_sp_port);
 }
 
-static int mlxsw_sp_vport_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_vport)
+static int mlxsw_sp_vport_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_vport,
+				    u16 fid)
 {
-	u16 fid = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
-
 	if (mlxsw_sp_vport->lagged)
 		return mlxsw_sp_port_fdb_flush_by_lag_id_fid(mlxsw_sp_vport,
 							     fid);
@@ -3203,118 +3207,66 @@ static void mlxsw_sp_br_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
 	kfree(f);
 }
 
-static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
-					struct net_device *br_dev,
-					bool flush_fdb)
+static int mlxsw_sp_vport_br_vfid_join(struct mlxsw_sp_port *mlxsw_sp_vport,
+				       struct net_device *br_dev)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
-	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
-	struct net_device *dev = mlxsw_sp_vport->dev;
-	struct mlxsw_sp_fid *f, *new_f;
+	struct mlxsw_sp_fid *f;
 	int err;
 
-	f = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
-	if (WARN_ON(!f))
-		return;
-
-	/* We need a vFID to go back to after leaving the bridge's vFID. */
-	new_f = mlxsw_sp_vfid_find(mlxsw_sp, vid);
-	if (!new_f) {
-		new_f = mlxsw_sp_vfid_create(mlxsw_sp, vid);
-		if (IS_ERR(new_f)) {
-			netdev_err(dev, "Failed to create vFID for VID=%d\n",
-				   vid);
-			return;
-		}
+	f = mlxsw_sp_br_vfid_find(mlxsw_sp_vport->mlxsw_sp, br_dev);
+	if (!f) {
+		f = mlxsw_sp_br_vfid_create(mlxsw_sp_vport->mlxsw_sp, br_dev);
+		if (IS_ERR(f))
+			return PTR_ERR(f);
 	}
 
-	/* Invalidate existing {Port, VID} to vFID mapping and create a new
-	 * one for the new vFID.
-	 */
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
-	if (err) {
-		netdev_err(dev, "Failed to invalidate {Port, VID} to FID=%d mapping\n",
-			   f->fid);
-		goto err_vport_fid_unmap;
-	}
+	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, true);
+	if (err)
+		goto err_vport_flood_set;
 
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, new_f->fid, true);
-	if (err) {
-		netdev_err(dev, "Failed to map {Port, VID} to FID=%d\n",
-			   new_f->fid);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, true);
+	if (err)
 		goto err_vport_fid_map;
-	}
-
-	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
-	if (err) {
-		netdev_err(dev, "Failed to disable learning\n");
-		goto err_port_vid_learning_set;
-	}
 
-	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
-	if (err) {
-		netdev_err(dev, "Failed clear to clear flooding\n");
-		goto err_vport_flood_set;
-	}
-
-	err = mlxsw_sp_port_stp_state_set(mlxsw_sp_vport, vid,
-					  MLXSW_REG_SPMS_STATE_FORWARDING);
-	if (err) {
-		netdev_err(dev, "Failed to set STP state\n");
-		goto err_port_stp_state_set;
-	}
+	mlxsw_sp_vport->vport.f = f;
+	f->ref_count++;
 
-	if (flush_fdb && mlxsw_sp_vport_fdb_flush(mlxsw_sp_vport))
-		netdev_err(dev, "Failed to flush FDB\n");
+	return 0;
 
-	/* Switch between the vFIDs and destroy the old one if needed. */
-	new_f->ref_count++;
-	mlxsw_sp_vport->vport.f = new_f;
-	f->ref_count--;
+err_vport_fid_map:
+	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
+err_vport_flood_set:
 	if (!f->ref_count)
-		mlxsw_sp_br_vfid_destroy(mlxsw_sp, f);
+		mlxsw_sp_br_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
+	return err;
+}
 
-	mlxsw_sp_vport->learning = 0;
-	mlxsw_sp_vport->learning_sync = 0;
-	mlxsw_sp_vport->uc_flood = 0;
-	mlxsw_sp_vport->bridged = 0;
+static void mlxsw_sp_vport_br_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
+{
+	struct mlxsw_sp_fid *f = mlxsw_sp_vport->vport.f;
 
-	return;
+	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
 
-err_port_stp_state_set:
-err_vport_flood_set:
-err_port_vid_learning_set:
-err_vport_fid_map:
-err_vport_fid_unmap:
-	/* Rollback vFID only if new. */
-	if (!new_f->ref_count)
-		mlxsw_sp_vfid_destroy(mlxsw_sp, new_f);
+	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
+
+	mlxsw_sp_vport->vport.f = NULL;
+	if (--f->ref_count == 0)
+		mlxsw_sp_br_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
 }
 
 static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 				      struct net_device *br_dev)
 {
-	struct mlxsw_sp_fid *old_f = mlxsw_sp_vport->vport.f;
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 	struct net_device *dev = mlxsw_sp_vport->dev;
-	struct mlxsw_sp_fid *f;
 	int err;
 
-	f = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
-	if (!f) {
-		f = mlxsw_sp_br_vfid_create(mlxsw_sp, br_dev);
-		if (IS_ERR(f)) {
-			netdev_err(dev, "Failed to create bridge vFID\n");
-			return PTR_ERR(f);
-		}
-	}
+	mlxsw_sp_vport_vfid_leave(mlxsw_sp_vport);
 
-	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, true);
+	err = mlxsw_sp_vport_br_vfid_join(mlxsw_sp_vport, br_dev);
 	if (err) {
-		netdev_err(dev, "Failed to setup flooding for FID=%d\n",
-			   f->fid);
-		goto err_port_flood_set;
+		netdev_err(dev, "Failed to join vFID\n");
+		goto err_vport_br_vfid_join;
 	}
 
 	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
@@ -3323,30 +3275,6 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 		goto err_port_vid_learning_set;
 	}
 
-	/* We need to invalidate existing {Port, VID} to vFID mapping and
-	 * create a new one for the bridge's vFID.
-	 */
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, old_f->fid, false);
-	if (err) {
-		netdev_err(dev, "Failed to invalidate {Port, VID} to FID=%d mapping\n",
-			   old_f->fid);
-		goto err_vport_fid_unmap;
-	}
-
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, true);
-	if (err) {
-		netdev_err(dev, "Failed to map {Port, VID} to FID=%d\n",
-			   f->fid);
-		goto err_vport_fid_map;
-	}
-
-	/* Switch between the vFIDs and destroy the old one if needed. */
-	f->ref_count++;
-	mlxsw_sp_vport->vport.f = f;
-	old_f->ref_count--;
-	if (!old_f->ref_count)
-		mlxsw_sp_vfid_destroy(mlxsw_sp, old_f);
-
 	mlxsw_sp_vport->learning = 1;
 	mlxsw_sp_vport->learning_sync = 1;
 	mlxsw_sp_vport->uc_flood = 1;
@@ -3354,18 +3282,38 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 	return 0;
 
-err_vport_fid_map:
-	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, old_f->fid, true);
-err_vport_fid_unmap:
-	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
 err_port_vid_learning_set:
-	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
-err_port_flood_set:
-	if (!f->ref_count)
-		mlxsw_sp_br_vfid_destroy(mlxsw_sp, f);
+	mlxsw_sp_vport_br_vfid_leave(mlxsw_sp_vport);
+err_vport_br_vfid_join:
+	mlxsw_sp_vport_vfid_join(mlxsw_sp_vport);
 	return err;
 }
 
+static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
+					struct net_device *br_dev,
+					bool flush_fdb)
+{
+	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+	u16 fid = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
+
+	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
+
+	mlxsw_sp_vport_br_vfid_leave(mlxsw_sp_vport);
+
+	mlxsw_sp_vport_vfid_join(mlxsw_sp_vport);
+
+	mlxsw_sp_port_stp_state_set(mlxsw_sp_vport, vid,
+				    MLXSW_REG_SPMS_STATE_FORWARDING);
+
+	if (flush_fdb)
+		mlxsw_sp_vport_fdb_flush(mlxsw_sp_vport, fid);
+
+	mlxsw_sp_vport->learning = 0;
+	mlxsw_sp_vport->learning_sync = 0;
+	mlxsw_sp_vport->uc_flood = 0;
+	mlxsw_sp_vport->bridged = 0;
+}
+
 static bool
 mlxsw_sp_port_master_bridge_check(const struct mlxsw_sp_port *mlxsw_sp_port,
 				  const struct net_device *br_dev)
-- 
2.5.5
