From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/23] mlxsw: spectrum: Make vFID struct generic
Date: Mon, 20 Jun 2016 23:04:12 +0200
Message-ID: <1466456661-5260-15-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33496 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbcFTVQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:16:20 -0400
Received: by mail-lf0-f68.google.com with SMTP id l188so6838926lfe.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:15:58 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now we had a dedicated struct only for vFIDs, but before
introducing support for L3 interfaces we need to make it generic and
use it for all three types of FIDs:

1) FIDs - 0..4K-1, used for the VLAN-aware bridge
2) vFIDs - 4K..15K-1, used for VLAN-unaware bridges
3) rFIDs - 15K..16K-1, used to direct traffic to / from the router in
the device. Will be introduced later in the series.

The three types of L3 interfaces - Router InterFaces, RIFs - that will
be introduced correspond to the three types of FIDs and are configured
using them. Therefore, we'll need to store the links between them as
well as a reference count on the underlying FID, so that the
corresponding RIF will be destroyed when it reaches zero.

Note that the lower 0.5K vFIDs are currently used for for non-bridged
netdevs, so that traffic could be flooded to the CPU port. However, when
rFIDs will be introduced we'll no longer need these and they too will be
used for VLAN-unaware bridges.

Make the vFID struct generic by renaming it and some of its fields. FIDs
will be converted to use it later in the series.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 229 ++++++++++-----------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  24 +--
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  28 +--
 3 files changed, 131 insertions(+), 150 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 7a75a45..8ef8d0b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -633,14 +633,14 @@ static int mlxsw_sp_port_vlan_mode_trans(struct mlxsw_sp_port *mlxsw_sp_port)
 	return 0;
 }
 
-static struct mlxsw_sp_vfid *
+static struct mlxsw_sp_fid *
 mlxsw_sp_vfid_find(const struct mlxsw_sp *mlxsw_sp, u16 vid)
 {
-	struct mlxsw_sp_vfid *vfid;
+	struct mlxsw_sp_fid *f;
 
-	list_for_each_entry(vfid, &mlxsw_sp->port_vfids.list, list) {
-		if (vfid->vid == vid)
-			return vfid;
+	list_for_each_entry(f, &mlxsw_sp->port_vfids.list, list) {
+		if (f->vid == vid)
+			return f;
 	}
 
 	return NULL;
@@ -660,11 +660,11 @@ static int mlxsw_sp_vfid_op(struct mlxsw_sp *mlxsw_sp, u16 fid, bool create)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
 }
 
-static struct mlxsw_sp_vfid *mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp,
-						  u16 vid)
+static struct mlxsw_sp_fid *mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp,
+						 u16 vid)
 {
 	struct device *dev = mlxsw_sp->bus_info->dev;
-	struct mlxsw_sp_vfid *f;
+	struct mlxsw_sp_fid *f;
 	u16 vfid, fid;
 	int err;
 
@@ -685,7 +685,7 @@ static struct mlxsw_sp_vfid *mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp,
 	if (!f)
 		goto err_allocate_vfid;
 
-	f->vfid = vfid;
+	f->fid = fid;
 	f->vid = vid;
 
 	list_add(&f->list, &mlxsw_sp->port_vfids.list);
@@ -699,21 +699,21 @@ err_allocate_vfid:
 }
 
 static void mlxsw_sp_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
-				  struct mlxsw_sp_vfid *vfid)
+				  struct mlxsw_sp_fid *f)
 {
-	u16 fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
+	u16 vfid = mlxsw_sp_fid_to_vfid(f->fid);
 
-	clear_bit(vfid->vfid, mlxsw_sp->port_vfids.mapped);
-	list_del(&vfid->list);
+	clear_bit(vfid, mlxsw_sp->port_vfids.mapped);
+	list_del(&f->list);
 
-	mlxsw_sp_vfid_op(mlxsw_sp, fid, false);
+	mlxsw_sp_vfid_op(mlxsw_sp, f->fid, false);
 
-	kfree(vfid);
+	kfree(f);
 }
 
 static struct mlxsw_sp_port *
 mlxsw_sp_port_vport_create(struct mlxsw_sp_port *mlxsw_sp_port,
-			   struct mlxsw_sp_vfid *vfid)
+			   struct mlxsw_sp_fid *f)
 {
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 
@@ -731,8 +731,8 @@ mlxsw_sp_port_vport_create(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_vport->stp_state = BR_STATE_FORWARDING;
 	mlxsw_sp_vport->lagged = mlxsw_sp_port->lagged;
 	mlxsw_sp_vport->lag_id = mlxsw_sp_port->lag_id;
-	mlxsw_sp_vport->vport.vfid = vfid;
-	mlxsw_sp_vport->vport.vid = vfid->vid;
+	mlxsw_sp_vport->vport.f = f;
+	mlxsw_sp_vport->vport.vid = f->vid;
 
 	list_add(&mlxsw_sp_vport->vport.list, &mlxsw_sp_port->vports_list);
 
@@ -761,8 +761,7 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_port *mlxsw_sp_vport;
-	struct mlxsw_sp_vfid *vfid;
-	u16 fid;
+	struct mlxsw_sp_fid *f;
 	int err;
 
 	/* VLAN 0 is added to HW filter when device goes up, but it is
@@ -776,29 +775,28 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		return 0;
 	}
 
-	vfid = mlxsw_sp_vfid_find(mlxsw_sp, vid);
-	if (!vfid) {
-		vfid = mlxsw_sp_vfid_create(mlxsw_sp, vid);
-		if (IS_ERR(vfid)) {
+	f = mlxsw_sp_vfid_find(mlxsw_sp, vid);
+	if (!f) {
+		f = mlxsw_sp_vfid_create(mlxsw_sp, vid);
+		if (IS_ERR(f)) {
 			netdev_err(dev, "Failed to create vFID for VID=%d\n",
 				   vid);
-			return PTR_ERR(vfid);
+			return PTR_ERR(f);
 		}
 	}
 
-	mlxsw_sp_vport = mlxsw_sp_port_vport_create(mlxsw_sp_port, vfid);
+	mlxsw_sp_vport = mlxsw_sp_port_vport_create(mlxsw_sp_port, f);
 	if (!mlxsw_sp_vport) {
 		netdev_err(dev, "Failed to create vPort for VID=%d\n", vid);
 		err = -ENOMEM;
 		goto err_port_vport_create;
 	}
 
-	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
-	if (!vfid->nr_vports) {
-		err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, fid, true);
+	if (!f->ref_count) {
+		err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, true);
 		if (err) {
-			netdev_err(dev, "Failed to setup flooding for vFID=%d\n",
-				   vfid->vfid);
+			netdev_err(dev, "Failed to setup flooding for FID=%d\n",
+				   f->fid);
 			goto err_vport_flood_set;
 		}
 	}
@@ -815,10 +813,10 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		}
 	}
 
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, true);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, true);
 	if (err) {
-		netdev_err(dev, "Failed to map {Port, VID=%d} to vFID=%d\n",
-			   vid, vfid->vfid);
+		netdev_err(dev, "Failed to map {Port, VID=%d} to FID=%d\n",
+			   vid, f->fid);
 		goto err_vport_fid_map;
 	}
 
@@ -842,7 +840,7 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		goto err_port_stp_state_set;
 	}
 
-	vfid->nr_vports++;
+	f->ref_count++;
 
 	return 0;
 
@@ -851,18 +849,18 @@ err_port_stp_state_set:
 err_port_add_vid:
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
 err_port_vid_learning_set:
-	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, false);
+	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
 err_vport_fid_map:
 	if (list_is_singular(&mlxsw_sp_port->vports_list))
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 err_port_vp_mode_trans:
-	if (!vfid->nr_vports)
-		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, fid, false);
+	if (!f->ref_count)
+		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
 err_vport_flood_set:
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
 err_port_vport_create:
-	if (!vfid->nr_vports)
-		mlxsw_sp_vfid_destroy(mlxsw_sp, vfid);
+	if (!f->ref_count)
+		mlxsw_sp_vfid_destroy(mlxsw_sp, f);
 	return err;
 }
 
@@ -871,8 +869,7 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port *mlxsw_sp_vport;
-	struct mlxsw_sp_vfid *vfid;
-	u16 fid;
+	struct mlxsw_sp_fid *f;
 	int err;
 
 	/* VLAN 0 is removed from HW filter when device goes down, but
@@ -887,7 +884,7 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 		return 0;
 	}
 
-	vfid = mlxsw_sp_vport->vport.vfid;
+	f = mlxsw_sp_vport->vport.f;
 
 	err = mlxsw_sp_port_stp_state_set(mlxsw_sp_vport, vid,
 					  MLXSW_REG_SPMS_STATE_DISCARDING);
@@ -909,11 +906,10 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 		return err;
 	}
 
-	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, false);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
 	if (err) {
-		netdev_err(dev, "Failed to invalidate {Port, VID=%d} to vFID=%d mapping\n",
-			   vid, vfid->vfid);
+		netdev_err(dev, "Failed to invalidate {Port, VID=%d} to FID=%d mapping\n",
+			   vid, f->fid);
 		return err;
 	}
 
@@ -929,12 +925,12 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 		}
 	}
 
-	vfid->nr_vports--;
+	f->ref_count--;
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
 
 	/* Destroy the vFID if no vPorts are assigned to it anymore. */
-	if (!vfid->nr_vports)
-		mlxsw_sp_vfid_destroy(mlxsw_sp_port->mlxsw_sp, vfid);
+	if (!f->ref_count)
+		mlxsw_sp_vfid_destroy(mlxsw_sp_port->mlxsw_sp, f);
 
 	return 0;
 }
@@ -2631,8 +2627,7 @@ static int mlxsw_sp_port_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_port)
 
 static int mlxsw_sp_vport_fdb_flush(struct mlxsw_sp_port *mlxsw_sp_vport)
 {
-	u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_vport);
-	u16 fid = mlxsw_sp_vfid_to_fid(vfid);
+	u16 fid = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
 	if (mlxsw_sp_vport->lagged)
 		return mlxsw_sp_port_fdb_flush_by_lag_id_fid(mlxsw_sp_vport,
@@ -3126,15 +3121,15 @@ static int mlxsw_sp_netdevice_lag_event(struct net_device *lag_dev,
 	return 0;
 }
 
-static struct mlxsw_sp_vfid *
+static struct mlxsw_sp_fid *
 mlxsw_sp_br_vfid_find(const struct mlxsw_sp *mlxsw_sp,
 		      const struct net_device *br_dev)
 {
-	struct mlxsw_sp_vfid *vfid;
+	struct mlxsw_sp_fid *f;
 
-	list_for_each_entry(vfid, &mlxsw_sp->br_vfids.list, list) {
-		if (vfid->br_dev == br_dev)
-			return vfid;
+	list_for_each_entry(f, &mlxsw_sp->br_vfids.list, list) {
+		if (f->dev == br_dev)
+			return f;
 	}
 
 	return NULL;
@@ -3156,11 +3151,11 @@ static u16 mlxsw_sp_avail_br_vfid_get(const struct mlxsw_sp *mlxsw_sp)
 				   MLXSW_SP_VFID_BR_MAX);
 }
 
-static struct mlxsw_sp_vfid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
-						     struct net_device *br_dev)
+static struct mlxsw_sp_fid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
+						    struct net_device *br_dev)
 {
 	struct device *dev = mlxsw_sp->bus_info->dev;
-	struct mlxsw_sp_vfid *f;
+	struct mlxsw_sp_fid *f;
 	u16 vfid, fid;
 	int err;
 
@@ -3181,8 +3176,8 @@ static struct mlxsw_sp_vfid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
 	if (!f)
 		goto err_allocate_vfid;
 
-	f->vfid = vfid;
-	f->br_dev = br_dev;
+	f->fid = fid;
+	f->dev = br_dev;
 
 	list_add(&f->list, &mlxsw_sp->br_vfids.list);
 	set_bit(mlxsw_sp_vfid_to_br_vfid(vfid), mlxsw_sp->br_vfids.mapped);
@@ -3195,17 +3190,17 @@ err_allocate_vfid:
 }
 
 static void mlxsw_sp_br_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
-				     struct mlxsw_sp_vfid *vfid)
+				     struct mlxsw_sp_fid *f)
 {
-	u16 br_vfid = mlxsw_sp_vfid_to_br_vfid(vfid->vfid);
-	u16 fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
+	u16 vfid = mlxsw_sp_fid_to_vfid(f->fid);
+	u16 br_vfid = mlxsw_sp_vfid_to_br_vfid(vfid);
 
 	clear_bit(br_vfid, mlxsw_sp->br_vfids.mapped);
-	list_del(&vfid->list);
+	list_del(&f->list);
 
-	mlxsw_sp_vfid_op(mlxsw_sp, fid, false);
+	mlxsw_sp_vfid_op(mlxsw_sp, f->fid, false);
 
-	kfree(vfid);
+	kfree(f);
 }
 
 static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
@@ -3215,19 +3210,18 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 	struct net_device *dev = mlxsw_sp_vport->dev;
-	struct mlxsw_sp_vfid *vfid, *new_vfid;
-	u16 fid, new_fid;
+	struct mlxsw_sp_fid *f, *new_f;
 	int err;
 
-	vfid = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
-	if (WARN_ON(!vfid))
+	f = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
+	if (WARN_ON(!f))
 		return;
 
 	/* We need a vFID to go back to after leaving the bridge's vFID. */
-	new_vfid = mlxsw_sp_vfid_find(mlxsw_sp, vid);
-	if (!new_vfid) {
-		new_vfid = mlxsw_sp_vfid_create(mlxsw_sp, vid);
-		if (IS_ERR(new_vfid)) {
+	new_f = mlxsw_sp_vfid_find(mlxsw_sp, vid);
+	if (!new_f) {
+		new_f = mlxsw_sp_vfid_create(mlxsw_sp, vid);
+		if (IS_ERR(new_f)) {
 			netdev_err(dev, "Failed to create vFID for VID=%d\n",
 				   vid);
 			return;
@@ -3237,19 +3231,17 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 	/* Invalidate existing {Port, VID} to vFID mapping and create a new
 	 * one for the new vFID.
 	 */
-	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, false);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, false);
 	if (err) {
-		netdev_err(dev, "Failed to invalidate {Port, VID} to vFID=%d mapping\n",
-			   vfid->vfid);
+		netdev_err(dev, "Failed to invalidate {Port, VID} to FID=%d mapping\n",
+			   f->fid);
 		goto err_vport_fid_unmap;
 	}
 
-	new_fid = mlxsw_sp_vfid_to_fid(new_vfid->vfid);
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, new_fid, true);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, new_f->fid, true);
 	if (err) {
-		netdev_err(dev, "Failed to map {Port, VID} to vFID=%d\n",
-			   new_vfid->vfid);
+		netdev_err(dev, "Failed to map {Port, VID} to FID=%d\n",
+			   new_f->fid);
 		goto err_vport_fid_map;
 	}
 
@@ -3259,7 +3251,7 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 		goto err_port_vid_learning_set;
 	}
 
-	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, fid, false);
+	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
 	if (err) {
 		netdev_err(dev, "Failed clear to clear flooding\n");
 		goto err_vport_flood_set;
@@ -3276,11 +3268,11 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 		netdev_err(dev, "Failed to flush FDB\n");
 
 	/* Switch between the vFIDs and destroy the old one if needed. */
-	new_vfid->nr_vports++;
-	mlxsw_sp_vport->vport.vfid = new_vfid;
-	vfid->nr_vports--;
-	if (!vfid->nr_vports)
-		mlxsw_sp_br_vfid_destroy(mlxsw_sp, vfid);
+	new_f->ref_count++;
+	mlxsw_sp_vport->vport.f = new_f;
+	f->ref_count--;
+	if (!f->ref_count)
+		mlxsw_sp_br_vfid_destroy(mlxsw_sp, f);
 
 	mlxsw_sp_vport->learning = 0;
 	mlxsw_sp_vport->learning_sync = 0;
@@ -3295,35 +3287,33 @@ err_port_vid_learning_set:
 err_vport_fid_map:
 err_vport_fid_unmap:
 	/* Rollback vFID only if new. */
-	if (!new_vfid->nr_vports)
-		mlxsw_sp_vfid_destroy(mlxsw_sp, new_vfid);
+	if (!new_f->ref_count)
+		mlxsw_sp_vfid_destroy(mlxsw_sp, new_f);
 }
 
 static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 				      struct net_device *br_dev)
 {
-	struct mlxsw_sp_vfid *old_vfid = mlxsw_sp_vport->vport.vfid;
+	struct mlxsw_sp_fid *old_f = mlxsw_sp_vport->vport.f;
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 	struct net_device *dev = mlxsw_sp_vport->dev;
-	struct mlxsw_sp_vfid *vfid;
-	u16 fid, old_fid;
+	struct mlxsw_sp_fid *f;
 	int err;
 
-	vfid = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
-	if (!vfid) {
-		vfid = mlxsw_sp_br_vfid_create(mlxsw_sp, br_dev);
-		if (IS_ERR(vfid)) {
+	f = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
+	if (!f) {
+		f = mlxsw_sp_br_vfid_create(mlxsw_sp, br_dev);
+		if (IS_ERR(f)) {
 			netdev_err(dev, "Failed to create bridge vFID\n");
-			return PTR_ERR(vfid);
+			return PTR_ERR(f);
 		}
 	}
 
-	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
-	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, fid, true);
+	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, true);
 	if (err) {
-		netdev_err(dev, "Failed to setup flooding for vFID=%d\n",
-			   vfid->vfid);
+		netdev_err(dev, "Failed to setup flooding for FID=%d\n",
+			   f->fid);
 		goto err_port_flood_set;
 	}
 
@@ -3336,27 +3326,26 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	/* We need to invalidate existing {Port, VID} to vFID mapping and
 	 * create a new one for the bridge's vFID.
 	 */
-	old_fid = mlxsw_sp_vfid_to_fid(old_vfid->vfid);
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, old_fid, false);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, old_f->fid, false);
 	if (err) {
-		netdev_err(dev, "Failed to invalidate {Port, VID} to vFID=%d mapping\n",
-			   old_vfid->vfid);
+		netdev_err(dev, "Failed to invalidate {Port, VID} to FID=%d mapping\n",
+			   old_f->fid);
 		goto err_vport_fid_unmap;
 	}
 
-	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, true);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, f->fid, true);
 	if (err) {
-		netdev_err(dev, "Failed to map {Port, VID} to vFID=%d\n",
-			   vfid->vfid);
+		netdev_err(dev, "Failed to map {Port, VID} to FID=%d\n",
+			   f->fid);
 		goto err_vport_fid_map;
 	}
 
 	/* Switch between the vFIDs and destroy the old one if needed. */
-	vfid->nr_vports++;
-	mlxsw_sp_vport->vport.vfid = vfid;
-	old_vfid->nr_vports--;
-	if (!old_vfid->nr_vports)
-		mlxsw_sp_vfid_destroy(mlxsw_sp, old_vfid);
+	f->ref_count++;
+	mlxsw_sp_vport->vport.f = f;
+	old_f->ref_count--;
+	if (!old_f->ref_count)
+		mlxsw_sp_vfid_destroy(mlxsw_sp, old_f);
 
 	mlxsw_sp_vport->learning = 1;
 	mlxsw_sp_vport->learning_sync = 1;
@@ -3366,14 +3355,14 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	return 0;
 
 err_vport_fid_map:
-	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, old_fid, true);
+	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, old_f->fid, true);
 err_vport_fid_unmap:
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
 err_port_vid_learning_set:
-	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, fid, false);
+	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
 err_port_flood_set:
-	if (!vfid->nr_vports)
-		mlxsw_sp_br_vfid_destroy(mlxsw_sp, vfid);
+	if (!f->ref_count)
+		mlxsw_sp_br_vfid_destroy(mlxsw_sp, f);
 	return err;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 0ae929e..c973ab5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -87,11 +87,11 @@ struct mlxsw_sp_upper {
 	unsigned int ref_count;
 };
 
-struct mlxsw_sp_vfid {
+struct mlxsw_sp_fid {
 	struct list_head list;
-	u16 nr_vports;
-	u16 vfid;	/* Starting at 0 */
-	struct net_device *br_dev;
+	unsigned int ref_count;
+	struct net_device *dev;
+	u16 fid;
 	u16 vid;
 };
 
@@ -217,7 +217,7 @@ struct mlxsw_sp_port {
 	u16 lag_id;
 	struct {
 		struct list_head list;
-		struct mlxsw_sp_vfid *vfid;
+		struct mlxsw_sp_fid *f;
 		u16 vid;
 	} vport;
 	struct {
@@ -262,13 +262,13 @@ mlxsw_sp_port_lagged_get(struct mlxsw_sp *mlxsw_sp, u16 lag_id, u8 port_index)
 static inline bool
 mlxsw_sp_port_is_vport(const struct mlxsw_sp_port *mlxsw_sp_port)
 {
-	return mlxsw_sp_port->vport.vfid;
+	return mlxsw_sp_port->vport.f;
 }
 
 static inline struct net_device *
 mlxsw_sp_vport_br_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 {
-	return mlxsw_sp_vport->vport.vfid->br_dev;
+	return mlxsw_sp_vport->vport.f->dev;
 }
 
 static inline u16
@@ -278,9 +278,9 @@ mlxsw_sp_vport_vid_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 }
 
 static inline u16
-mlxsw_sp_vport_vfid_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
+mlxsw_sp_vport_fid_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 {
-	return mlxsw_sp_vport->vport.vfid->vfid;
+	return mlxsw_sp_vport->vport.f->fid;
 }
 
 static inline struct mlxsw_sp_port *
@@ -298,14 +298,14 @@ mlxsw_sp_port_vport_find(const struct mlxsw_sp_port *mlxsw_sp_port, u16 vid)
 }
 
 static inline struct mlxsw_sp_port *
-mlxsw_sp_port_vport_find_by_vfid(const struct mlxsw_sp_port *mlxsw_sp_port,
-				 u16 vfid)
+mlxsw_sp_port_vport_find_by_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
+				u16 fid)
 {
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 
 	list_for_each_entry(mlxsw_sp_vport, &mlxsw_sp_port->vports_list,
 			    vport.list) {
-		if (mlxsw_sp_vport_vfid_get(mlxsw_sp_vport) == vfid)
+		if (mlxsw_sp_vport_fid_get(mlxsw_sp_vport) == fid)
 			return mlxsw_sp_vport;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 76f53c2..3e9ba58 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -57,11 +57,8 @@ static u16 mlxsw_sp_port_vid_to_fid_get(struct mlxsw_sp_port *mlxsw_sp_port,
 {
 	u16 fid = vid;
 
-	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
-		u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
-
-		fid = mlxsw_sp_vfid_to_fid(vfid);
-	}
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port))
+		fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port);
 
 	if (!fid)
 		fid = mlxsw_sp_port->pvid;
@@ -236,8 +233,9 @@ static int mlxsw_sp_port_uc_flood_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	int err;
 
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
-		u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
+		u16 vfid, fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port);
 
+		vfid = mlxsw_sp_fid_to_vfid(fid);
 		return  __mlxsw_sp_port_flood_set(mlxsw_sp_port, vfid, vfid,
 						  set, true);
 	}
@@ -1136,12 +1134,8 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (!sfd_pl)
 		return -ENOMEM;
 
-	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
-		u16 tmp;
-
-		tmp = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
-		vport_fid = mlxsw_sp_vfid_to_fid(tmp);
-	}
+	if (mlxsw_sp_port_is_vport(mlxsw_sp_port))
+		vport_fid = mlxsw_sp_vport_fid_get(mlxsw_sp_port);
 
 	mlxsw_reg_sfd_pack(sfd_pl, MLXSW_REG_SFD_OP_QUERY_DUMP, 0);
 	do {
@@ -1313,11 +1307,10 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 	}
 
 	if (mlxsw_sp_fid_is_vfid(fid)) {
-		u16 vfid = mlxsw_sp_fid_to_vfid(fid);
 		struct mlxsw_sp_port *mlxsw_sp_vport;
 
-		mlxsw_sp_vport = mlxsw_sp_port_vport_find_by_vfid(mlxsw_sp_port,
-								  vfid);
+		mlxsw_sp_vport = mlxsw_sp_port_vport_find_by_fid(mlxsw_sp_port,
+								 fid);
 		if (!mlxsw_sp_vport) {
 			netdev_err(mlxsw_sp_port->dev, "Failed to find a matching vPort following FDB notification\n");
 			goto just_remove;
@@ -1373,11 +1366,10 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 	}
 
 	if (mlxsw_sp_fid_is_vfid(fid)) {
-		u16 vfid = mlxsw_sp_fid_to_vfid(fid);
 		struct mlxsw_sp_port *mlxsw_sp_vport;
 
-		mlxsw_sp_vport = mlxsw_sp_port_vport_find_by_vfid(mlxsw_sp_port,
-								  vfid);
+		mlxsw_sp_vport = mlxsw_sp_port_vport_find_by_fid(mlxsw_sp_port,
+								 fid);
 		if (!mlxsw_sp_vport) {
 			netdev_err(mlxsw_sp_port->dev, "Failed to find a matching vPort following FDB notification\n");
 			goto just_remove;
-- 
2.5.5
