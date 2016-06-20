From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/23] mlxsw: spectrum: Create a function to map vPort's FID
Date: Mon, 20 Jun 2016 23:04:10 +0200
Message-ID: <1466456661-5260-13-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35676 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932932AbcFTVTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:19:04 -0400
Received: by mail-lf0-f67.google.com with SMTP id w130so6843493lfd.2
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:19:03 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

A FID used by a vPort (vFID, but also rFID later in the series) is
always mapped using {Port, VID} and not only VID as with the 4K FIDs of
the VLAN-aware bridge.

Instead of specifying all the arguments each time, just wrap this
operation using a dedicated function and simplify the code.

As before, the function takes FID as its argument in preparation for a
generic FID struct.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 84 ++++++++++++--------------
 1 file changed, 38 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4f53dd2..6df944b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -745,6 +745,16 @@ static void mlxsw_sp_port_vport_destroy(struct mlxsw_sp_port *mlxsw_sp_vport)
 	kfree(mlxsw_sp_vport);
 }
 
+static int mlxsw_sp_vport_fid_map(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
+				  bool valid)
+{
+	enum mlxsw_reg_svfa_mt mt = MLXSW_REG_SVFA_MT_PORT_VID_TO_FID;
+	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+
+	return mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport, mt, valid, fid,
+					    vid);
+}
+
 int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 			  u16 vid)
 {
@@ -752,6 +762,7 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	struct mlxsw_sp_vfid *vfid;
+	u16 fid;
 	int err;
 
 	/* VLAN 0 is added to HW filter when device goes up, but it is
@@ -804,15 +815,12 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		}
 	}
 
-	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
-					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
-					   true,
-					   mlxsw_sp_vfid_to_fid(vfid->vfid),
-					   vid);
+	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, true);
 	if (err) {
 		netdev_err(dev, "Failed to map {Port, VID=%d} to vFID=%d\n",
 			   vid, vfid->vfid);
-		goto err_port_vid_to_fid_set;
+		goto err_vport_fid_map;
 	}
 
 	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
@@ -844,10 +852,8 @@ err_port_stp_state_set:
 err_port_add_vid:
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, true);
 err_port_vid_learning_set:
-	mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
-				     MLXSW_REG_SVFA_MT_PORT_VID_TO_FID, false,
-				     mlxsw_sp_vfid_to_fid(vfid->vfid), vid);
-err_port_vid_to_fid_set:
+	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, false);
+err_vport_fid_map:
 	if (list_is_singular(&mlxsw_sp_port->vports_list))
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 err_port_vp_mode_trans:
@@ -867,6 +873,7 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	struct mlxsw_sp_vfid *vfid;
+	u16 fid;
 	int err;
 
 	/* VLAN 0 is removed from HW filter when device goes down, but
@@ -903,11 +910,8 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 		return err;
 	}
 
-	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
-					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
-					   false,
-					   mlxsw_sp_vfid_to_fid(vfid->vfid),
-					   vid);
+	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, false);
 	if (err) {
 		netdev_err(dev, "Failed to invalidate {Port, VID=%d} to vFID=%d mapping\n",
 			   vid, vfid->vfid);
@@ -3213,6 +3217,7 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 	struct net_device *dev = mlxsw_sp_vport->dev;
 	struct mlxsw_sp_vfid *vfid, *new_vfid;
+	u16 fid, new_fid;
 	int err;
 
 	vfid = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
@@ -3233,26 +3238,20 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 	/* Invalidate existing {Port, VID} to vFID mapping and create a new
 	 * one for the new vFID.
 	 */
-	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
-					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
-					   false,
-					   mlxsw_sp_vfid_to_fid(vfid->vfid),
-					   vid);
+	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, false);
 	if (err) {
 		netdev_err(dev, "Failed to invalidate {Port, VID} to vFID=%d mapping\n",
 			   vfid->vfid);
-		goto err_port_vid_to_fid_invalidate;
+		goto err_vport_fid_unmap;
 	}
 
-	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
-					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
-					   true,
-					   mlxsw_sp_vfid_to_fid(new_vfid->vfid),
-					   vid);
+	new_fid = mlxsw_sp_vfid_to_fid(new_vfid->vfid);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, new_fid, true);
 	if (err) {
 		netdev_err(dev, "Failed to map {Port, VID} to vFID=%d\n",
 			   new_vfid->vfid);
-		goto err_port_vid_to_fid_validate;
+		goto err_vport_fid_map;
 	}
 
 	err = mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
@@ -3294,8 +3293,8 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 err_port_stp_state_set:
 err_vport_flood_set:
 err_port_vid_learning_set:
-err_port_vid_to_fid_validate:
-err_port_vid_to_fid_invalidate:
+err_vport_fid_map:
+err_vport_fid_unmap:
 	/* Rollback vFID only if new. */
 	if (!new_vfid->nr_vports)
 		mlxsw_sp_vfid_destroy(mlxsw_sp, new_vfid);
@@ -3309,6 +3308,7 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
 	struct net_device *dev = mlxsw_sp_vport->dev;
 	struct mlxsw_sp_vfid *vfid;
+	u16 fid, old_fid;
 	int err;
 
 	vfid = mlxsw_sp_br_vfid_find(mlxsw_sp, br_dev);
@@ -3336,26 +3336,20 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	/* We need to invalidate existing {Port, VID} to vFID mapping and
 	 * create a new one for the bridge's vFID.
 	 */
-	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
-					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
-					   false,
-					   mlxsw_sp_vfid_to_fid(old_vfid->vfid),
-					   vid);
+	old_fid = mlxsw_sp_vfid_to_fid(old_vfid->vfid);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, old_fid, false);
 	if (err) {
 		netdev_err(dev, "Failed to invalidate {Port, VID} to vFID=%d mapping\n",
 			   old_vfid->vfid);
-		goto err_port_vid_to_fid_invalidate;
+		goto err_vport_fid_unmap;
 	}
 
-	err = mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
-					   MLXSW_REG_SVFA_MT_PORT_VID_TO_FID,
-					   true,
-					   mlxsw_sp_vfid_to_fid(vfid->vfid),
-					   vid);
+	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
+	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, true);
 	if (err) {
 		netdev_err(dev, "Failed to map {Port, VID} to vFID=%d\n",
 			   vfid->vfid);
-		goto err_port_vid_to_fid_validate;
+		goto err_vport_fid_map;
 	}
 
 	/* Switch between the vFIDs and destroy the old one if needed. */
@@ -3372,11 +3366,9 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 	return 0;
 
-err_port_vid_to_fid_validate:
-	mlxsw_sp_port_vid_to_fid_set(mlxsw_sp_vport,
-				     MLXSW_REG_SVFA_MT_PORT_VID_TO_FID, false,
-				     mlxsw_sp_vfid_to_fid(old_vfid->vfid), vid);
-err_port_vid_to_fid_invalidate:
+err_vport_fid_map:
+	mlxsw_sp_vport_fid_map(mlxsw_sp_vport, old_fid, true);
+err_vport_fid_unmap:
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
 err_port_vid_learning_set:
 	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false);
-- 
2.5.5
