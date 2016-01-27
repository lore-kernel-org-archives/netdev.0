From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 07/11] mlxsw: spectrum: Don't report VLAN for 802.1D FDB entries
Date: Wed, 27 Jan 2016 15:20:22 +0100
Message-ID: <1453904426-4960-8-git-send-email-jiri@resnulli.us>
References: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38323 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932784AbcA0OUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:39 -0500
Received: by mail-wm0-f45.google.com with SMTP id p63so28698305wmp.1
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:38 -0800 (PST)
In-Reply-To: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When dumping the hardware FDB we should report entries pointing to VLAN
devices with VLAN 0, as packets coming into the bridge are untagged.
Likewise, pass FDB_{ADD,DEL} notifications with VLAN 0 for these
devices.

Fixes: 54a732018d8e ("mlxsw: spectrum: Adjust switchdev ops for VLAN devices")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 31 +++++++++++-----------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 7d4789e..594fc60 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1052,7 +1052,7 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 				  switchdev_obj_dump_cb_t *cb)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	u16 vport_vid = 0, vport_fid = 0;
+	u16 vport_fid = 0;
 	char *sfd_pl;
 	char mac[ETH_ALEN];
 	u16 fid;
@@ -1072,7 +1072,6 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 
 		tmp = mlxsw_sp_vport_vfid_get(mlxsw_sp_port);
 		vport_fid = mlxsw_sp_vfid_to_fid(tmp);
-		vport_vid = mlxsw_sp_vport_vid_get(mlxsw_sp_port);
 	}
 
 	mlxsw_reg_sfd_pack(sfd_pl, MLXSW_REG_SFD_OP_QUERY_DUMP, 0);
@@ -1096,12 +1095,13 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 				mlxsw_reg_sfd_uc_unpack(sfd_pl, i, mac, &fid,
 							&local_port);
 				if (local_port == mlxsw_sp_port->local_port) {
-					if (vport_fid && vport_fid != fid)
-						continue;
-					else if (vport_fid)
-						fdb->vid = vport_vid;
-					else
+					if (vport_fid && vport_fid == fid)
+						fdb->vid = 0;
+					else if (!vport_fid &&
+						 !mlxsw_sp_fid_is_vfid(fid))
 						fdb->vid = fid;
+					else
+						continue;
 					ether_addr_copy(fdb->addr, mac);
 					fdb->ndm_state = NUD_REACHABLE;
 					err = cb(&fdb->obj);
@@ -1114,12 +1114,13 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 							    mac, &fid, &lag_id);
 				if (mlxsw_sp_port ==
 				    mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id)) {
-					if (vport_fid && vport_fid != fid)
-						continue;
-					else if (vport_fid)
-						fdb->vid = vport_vid;
-					else
+					if (vport_fid && vport_fid == fid)
+						fdb->vid = 0;
+					else if (!vport_fid &&
+						 !mlxsw_sp_fid_is_vfid(fid))
 						fdb->vid = fid;
+					else
+						continue;
 					ether_addr_copy(fdb->addr, mac);
 					fdb->ndm_state = NUD_REACHABLE;
 					err = cb(&fdb->obj);
@@ -1244,7 +1245,7 @@ static void mlxsw_sp_fdb_notify_mac_process(struct mlxsw_sp *mlxsw_sp,
 			netdev_err(mlxsw_sp_port->dev, "Failed to find a matching vPort following FDB notification\n");
 			goto just_remove;
 		}
-		vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+		vid = 0;
 		/* Override the physical port with the vPort. */
 		mlxsw_sp_port = mlxsw_sp_vport;
 	} else {
@@ -1304,8 +1305,8 @@ static void mlxsw_sp_fdb_notify_mac_lag_process(struct mlxsw_sp *mlxsw_sp,
 			goto just_remove;
 		}
 
-		vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
-		lag_vid = vid;
+		lag_vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+		vid = 0;
 		/* Override the physical port with the vPort. */
 		mlxsw_sp_port = mlxsw_sp_vport;
 	} else {
-- 
1.9.3
