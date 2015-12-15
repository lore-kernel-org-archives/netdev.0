From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/14] mlxsw: spectrum: Enable FDB records for VLAN devices on top of LAG
Date: Tue, 15 Dec 2015 16:03:46 +0100
Message-ID: <1450191827-6679-14-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38832 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964837AbbLOPEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:04:10 -0500
Received: by mail-wm0-f48.google.com with SMTP id p66so29769579wmp.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:04:09 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When adding or removing FDB records of VLAN devices on top of LAG we
should set the lag_vid parameter to the VLAN ID of the VLAN device. It
is reserved otherwise.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c    | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 3eed8d7..9476ff9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -588,8 +588,8 @@ static int mlxsw_sp_port_fdb_uc_op(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int mlxsw_sp_port_fdb_uc_lag_op(struct mlxsw_sp *mlxsw_sp, u16 lag_id,
-				       const char *mac, u16 fid, bool adding,
-				       bool dynamic)
+				       const char *mac, u16 fid, u16 lag_vid,
+				       bool adding, bool dynamic)
 {
 	char *sfd_pl;
 	int err;
@@ -600,8 +600,8 @@ static int mlxsw_sp_port_fdb_uc_lag_op(struct mlxsw_sp *mlxsw_sp, u16 lag_id,
 
 	mlxsw_reg_sfd_pack(sfd_pl, mlxsw_sp_sfd_op(adding), 0);
 	mlxsw_reg_sfd_uc_lag_pack(sfd_pl, 0, mlxsw_sp_sfd_rec_policy(dynamic),
-				  mac, fid, MLXSW_REG_SFD_REC_ACTION_NOP, 0,
-				  lag_id);
+				  mac, fid, MLXSW_REG_SFD_REC_ACTION_NOP,
+				  lag_vid, lag_id);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
 	kfree(sfd_pl);
 
@@ -614,6 +614,7 @@ mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
 			     struct switchdev_trans *trans)
 {
 	u16 fid = fdb->vid;
+	u16 lag_vid = 0;
 
 	if (switchdev_trans_ph_prepare(trans))
 		return 0;
@@ -622,6 +623,7 @@ mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
 		u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
 
 		fid = mlxsw_sp_vfid_to_fid(vfid);
+		lag_vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
 	}
 
 	if (!fid)
@@ -633,7 +635,8 @@ mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	else
 		return mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp_port->mlxsw_sp,
 						   mlxsw_sp_port->lag_id,
-						   fdb->addr, fid, true, false);
+						   fdb->addr, fid, lag_vid,
+						   true, false);
 }
 
 static int mlxsw_sp_port_obj_add(struct net_device *dev,
@@ -756,11 +759,13 @@ mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
 			     const struct switchdev_obj_port_fdb *fdb)
 {
 	u16 fid = fdb->vid;
+	u16 lag_vid = 0;
 
 	if (mlxsw_sp_port_is_vport(mlxsw_sp_port)) {
 		u16 vfid = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
 
 		fid = mlxsw_sp_vfid_to_fid(vfid);
+		lag_vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
 	}
 
 	if (!mlxsw_sp_port->lagged)
@@ -770,7 +775,7 @@ mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	else
 		return mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp_port->mlxsw_sp,
 						   mlxsw_sp_port->lag_id,
-						   fdb->addr, fid,
+						   fdb->addr, fid, lag_vid,
 						   false, false);
 }
 
@@ -1039,6 +1044,7 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 {
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	char mac[ETH_ALEN];
+	u16 lag_vid = 0;
 	u16 lag_id;
 	u16 vid, fid;
 	int err;
@@ -1062,13 +1068,14 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 		}
 
 		vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+		lag_vid = vid;
 		/* Override the physical port with the vPort. */
 		mlxsw_sp_port = mlxsw_sp_vport;
 	} else {
 		vid = fid;
 	}
 
-	err = mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp, lag_id, mac, fid,
+	err = mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp, lag_id, mac, fid, lag_vid,
 					  adding && mlxsw_sp_port->learning,
 					  true);
 	if (err) {
-- 
1.9.3
