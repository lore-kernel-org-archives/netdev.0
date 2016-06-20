From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/23] mlxsw: spectrum: Use FID instead of vFID to setup flooding
Date: Mon, 20 Jun 2016 23:04:11 +0200
Message-ID: <1466456661-5260-14-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33265 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbcFTVSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:18:18 -0400
Received: by mail-lf0-f65.google.com with SMTP id l188so6847033lfe.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:18:01 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Use a FID index instead of vFID and ease the transition towards a
generic FID struct.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           | 15 +++++++--------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c |  5 ++++-
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6df944b..7a75a45 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -793,9 +793,9 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		goto err_port_vport_create;
 	}
 
+	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
 	if (!vfid->nr_vports) {
-		err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid,
-					       true);
+		err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, fid, true);
 		if (err) {
 			netdev_err(dev, "Failed to setup flooding for vFID=%d\n",
 				   vfid->vfid);
@@ -815,7 +815,6 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 		}
 	}
 
-	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
 	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, true);
 	if (err) {
 		netdev_err(dev, "Failed to map {Port, VID=%d} to vFID=%d\n",
@@ -858,7 +857,7 @@ err_vport_fid_map:
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 err_port_vp_mode_trans:
 	if (!vfid->nr_vports)
-		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false);
+		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, fid, false);
 err_vport_flood_set:
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
 err_port_vport_create:
@@ -3260,7 +3259,7 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport,
 		goto err_port_vid_learning_set;
 	}
 
-	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false);
+	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, fid, false);
 	if (err) {
 		netdev_err(dev, "Failed clear to clear flooding\n");
 		goto err_vport_flood_set;
@@ -3320,7 +3319,8 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 		}
 	}
 
-	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, true);
+	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
+	err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, fid, true);
 	if (err) {
 		netdev_err(dev, "Failed to setup flooding for vFID=%d\n",
 			   vfid->vfid);
@@ -3344,7 +3344,6 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 		goto err_vport_fid_unmap;
 	}
 
-	fid = mlxsw_sp_vfid_to_fid(vfid->vfid);
 	err = mlxsw_sp_vport_fid_map(mlxsw_sp_vport, fid, true);
 	if (err) {
 		netdev_err(dev, "Failed to map {Port, VID} to vFID=%d\n",
@@ -3371,7 +3370,7 @@ err_vport_fid_map:
 err_vport_fid_unmap:
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
 err_port_vid_learning_set:
-	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false);
+	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, fid, false);
 err_port_flood_set:
 	if (!vfid->nr_vports)
 		mlxsw_sp_br_vfid_destroy(mlxsw_sp, vfid);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 58a2a5d..0ae929e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -366,7 +366,7 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 			  u16 vid);
 int mlxsw_sp_port_kill_vid(struct net_device *dev,
 			   __be16 __always_unused proto, u16 vid);
-int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 vfid,
+int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 			     bool set);
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
 int mlxsw_sp_port_pvid_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 02c126c..76f53c2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -260,12 +260,15 @@ err_port_flood_set:
 	return err;
 }
 
-int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 vfid,
+int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 			     bool set)
 {
+	u16 vfid;
+
 	/* In case of vFIDs, index into the flooding table is relative to
 	 * the start of the vFIDs range.
 	 */
+	vfid = mlxsw_sp_fid_to_vfid(fid);
 	return __mlxsw_sp_port_flood_set(mlxsw_sp_vport, vfid, vfid, set,
 					 false);
 }
-- 
2.5.5
