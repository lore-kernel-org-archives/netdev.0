From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 09/11] mlxsw: spectrum: Dump LAG FDB records only once
Date: Wed, 27 Jan 2016 15:20:24 +0100
Message-ID: <1453904426-4960-10-git-send-email-jiri@resnulli.us>
References: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37400 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519AbcA0OUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:41 -0500
Received: by mail-wm0-f45.google.com with SMTP id n5so28761892wmn.0
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:41 -0800 (PST)
In-Reply-To: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

LAG FDB records can only point to LAG devices or VLAN devices configured
on top of them. Therefore, when dumping the FDB we shouldn't associate
these records with the underlying physical ports.

Fixes: 8a1ab5d76639 ("mlxsw: spectrum: Implement FDB add/remove/dump for LAG")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 10a0270..21fc3c8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1049,7 +1049,8 @@ static struct mlxsw_sp_port *mlxsw_sp_lag_rep_port(struct mlxsw_sp *mlxsw_sp,
 
 static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 				  struct switchdev_obj_port_fdb *fdb,
-				  switchdev_obj_dump_cb_t *cb)
+				  switchdev_obj_dump_cb_t *cb,
+				  struct net_device *orig_dev)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u16 vport_fid = 0;
@@ -1114,6 +1115,12 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 							    mac, &fid, &lag_id);
 				if (mlxsw_sp_port ==
 				    mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id)) {
+					/* LAG records can only point to LAG
+					 * devices or VLAN devices on top.
+					 */
+					if (!netif_is_lag_master(orig_dev) &&
+					    !is_vlan_dev(orig_dev))
+						continue;
 					if (vport_fid && vport_fid == fid)
 						fdb->vid = 0;
 					else if (!vport_fid &&
@@ -1184,7 +1191,8 @@ static int mlxsw_sp_port_obj_dump(struct net_device *dev,
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = mlxsw_sp_port_fdb_dump(mlxsw_sp_port,
-					     SWITCHDEV_OBJ_PORT_FDB(obj), cb);
+					     SWITCHDEV_OBJ_PORT_FDB(obj), cb,
+					     obj->orig_dev);
 		break;
 	default:
 		err = -EOPNOTSUPP;
-- 
1.9.3
