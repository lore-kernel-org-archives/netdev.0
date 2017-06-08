From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 12/19] mlxsw: spectrum: Remove support for bridge bypass FDB add/del
Date: Thu,  8 Jun 2017 08:44:21 +0200
Message-ID: <20170608064428.4785-13-jiri@resnulli.us>
References: <20170608064428.4785-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com,
        nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36526 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751595AbdFHGox (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:44:53 -0400
Received: by mail-wr0-f196.google.com with SMTP id e23so2899702wre.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:44:48 -0700 (PDT)
In-Reply-To: <20170608064428.4785-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The FDB add/del are now done through the notification chain. The FDBs
are synced with the bridge and there is no need for extra dumping.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   3 -
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 200 ---------------------
 2 files changed, 203 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 93530ab..85c6c49 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1752,9 +1752,6 @@ static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_get_offload_stats	= mlxsw_sp_port_get_offload_stats,
 	.ndo_vlan_rx_add_vid	= mlxsw_sp_port_add_vid,
 	.ndo_vlan_rx_kill_vid	= mlxsw_sp_port_kill_vid,
-	.ndo_fdb_add		= switchdev_port_fdb_add,
-	.ndo_fdb_del		= switchdev_port_fdb_del,
-	.ndo_fdb_dump		= switchdev_port_fdb_dump,
 	.ndo_get_phys_port_name	= mlxsw_sp_port_get_phys_port_name,
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 0297c13..cd89a3e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1141,47 +1141,6 @@ static int mlxsw_sp_port_fdb_uc_lag_op(struct mlxsw_sp *mlxsw_sp, u16 lag_id,
 }
 
 static int
-mlxsw_sp_port_fdb_static_add(struct mlxsw_sp_port *mlxsw_sp_port,
-			     const struct switchdev_obj_port_fdb *fdb,
-			     struct switchdev_trans *trans)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct net_device *orig_dev = fdb->obj.orig_dev;
-	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
-	struct mlxsw_sp_bridge_device *bridge_device;
-	struct mlxsw_sp_bridge_port *bridge_port;
-	u16 fid_index, vid;
-
-	if (switchdev_trans_ph_prepare(trans))
-		return 0;
-
-	bridge_port = mlxsw_sp_bridge_port_find(mlxsw_sp->bridge, orig_dev);
-	if (WARN_ON(!bridge_port))
-		return -EINVAL;
-
-	bridge_device = bridge_port->bridge_device;
-	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_bridge(mlxsw_sp_port,
-							       bridge_device,
-							       fdb->vid);
-	if (!mlxsw_sp_port_vlan)
-		return 0;
-
-	fid_index = mlxsw_sp_fid_index(mlxsw_sp_port_vlan->fid);
-	vid = mlxsw_sp_port_vlan->vid;
-
-	if (!mlxsw_sp_port->lagged)
-		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp,
-					       mlxsw_sp_port->local_port,
-					       fdb->addr, fid_index, true,
-					       false);
-	else
-		return mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp,
-						   mlxsw_sp_port->lag_id,
-						   fdb->addr, fid_index, vid,
-						   true, false);
-}
-
-static int
 mlxsw_sp_port_fdb_set(struct mlxsw_sp_port *mlxsw_sp_port,
 		      struct switchdev_notifier_fdb_info *fdb_info, bool adding)
 {
@@ -1385,11 +1344,6 @@ static int mlxsw_sp_port_obj_add(struct net_device *dev,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj),
 					      trans);
 		break;
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = mlxsw_sp_port_fdb_static_add(mlxsw_sp_port,
-						   SWITCHDEV_OBJ_PORT_FDB(obj),
-						   trans);
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = mlxsw_sp_port_mdb_add(mlxsw_sp_port,
 					    SWITCHDEV_OBJ_PORT_MDB(obj),
@@ -1441,43 +1395,6 @@ static int mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
-static int
-mlxsw_sp_port_fdb_static_del(struct mlxsw_sp_port *mlxsw_sp_port,
-			     const struct switchdev_obj_port_fdb *fdb)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct net_device *orig_dev = fdb->obj.orig_dev;
-	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
-	struct mlxsw_sp_bridge_device *bridge_device;
-	struct mlxsw_sp_bridge_port *bridge_port;
-	u16 fid_index, vid;
-
-	bridge_port = mlxsw_sp_bridge_port_find(mlxsw_sp->bridge, orig_dev);
-	if (WARN_ON(!bridge_port))
-		return -EINVAL;
-
-	bridge_device = bridge_port->bridge_device;
-	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_bridge(mlxsw_sp_port,
-							       bridge_device,
-							       fdb->vid);
-	if (!mlxsw_sp_port_vlan)
-		return 0;
-
-	fid_index = mlxsw_sp_fid_index(mlxsw_sp_port_vlan->fid);
-	vid = mlxsw_sp_port_vlan->vid;
-
-	if (!mlxsw_sp_port->lagged)
-		return mlxsw_sp_port_fdb_uc_op(mlxsw_sp,
-					       mlxsw_sp_port->local_port,
-					       fdb->addr, fid_index, false,
-					       false);
-	else
-		return mlxsw_sp_port_fdb_uc_lag_op(mlxsw_sp,
-						   mlxsw_sp_port->lag_id,
-						   fdb->addr, fid_index, vid,
-						   false, false);
-}
-
 static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 				 const struct switchdev_obj_port_mdb *mdb)
 {
@@ -1537,10 +1454,6 @@ static int mlxsw_sp_port_obj_del(struct net_device *dev,
 		err = mlxsw_sp_port_vlans_del(mlxsw_sp_port,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = mlxsw_sp_port_fdb_static_del(mlxsw_sp_port,
-						   SWITCHDEV_OBJ_PORT_FDB(obj));
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_MDB:
 		err = mlxsw_sp_port_mdb_del(mlxsw_sp_port,
 					    SWITCHDEV_OBJ_PORT_MDB(obj));
@@ -1570,124 +1483,11 @@ static struct mlxsw_sp_port *mlxsw_sp_lag_rep_port(struct mlxsw_sp *mlxsw_sp,
 	return NULL;
 }
 
-static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
-				  struct switchdev_obj_port_fdb *fdb,
-				  switchdev_obj_dump_cb_t *cb)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct net_device *orig_dev = fdb->obj.orig_dev;
-	struct mlxsw_sp_bridge_port *bridge_port;
-	u16 lag_id, fid_index;
-	char mac[ETH_ALEN];
-	int stored_err = 0;
-	char *sfd_pl;
-	u8 num_rec;
-	int err;
-
-	bridge_port = mlxsw_sp_bridge_port_find(mlxsw_sp->bridge, orig_dev);
-	if (!bridge_port)
-		return 0;
-
-	sfd_pl = kmalloc(MLXSW_REG_SFD_LEN, GFP_KERNEL);
-	if (!sfd_pl)
-		return -ENOMEM;
-
-	mlxsw_reg_sfd_pack(sfd_pl, MLXSW_REG_SFD_OP_QUERY_DUMP, 0);
-	do {
-		struct mlxsw_sp_port *tmp;
-		u8 local_port;
-		int i;
-
-		mlxsw_reg_sfd_num_rec_set(sfd_pl, MLXSW_REG_SFD_REC_MAX_COUNT);
-		err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(sfd), sfd_pl);
-		if (err)
-			goto out;
-
-		num_rec = mlxsw_reg_sfd_num_rec_get(sfd_pl);
-
-		/* Even in case of error, we have to run the dump to the end
-		 * so the session in firmware is finished.
-		 */
-		if (stored_err)
-			continue;
-
-		for (i = 0; i < num_rec; i++) {
-			switch (mlxsw_reg_sfd_rec_type_get(sfd_pl, i)) {
-			case MLXSW_REG_SFD_REC_TYPE_UNICAST:
-				mlxsw_reg_sfd_uc_unpack(sfd_pl, i, mac,
-							&fid_index,
-							&local_port);
-				if (bridge_port->lagged)
-					continue;
-				if (bridge_port->system_port != local_port)
-					continue;
-				if (bridge_port->bridge_device->vlan_enabled)
-					fdb->vid = fid_index;
-				else
-					fdb->vid = 0;
-				ether_addr_copy(fdb->addr, mac);
-				fdb->ndm_state = NUD_REACHABLE;
-				err = cb(&fdb->obj);
-				if (err)
-					stored_err = err;
-				break;
-			case MLXSW_REG_SFD_REC_TYPE_UNICAST_LAG:
-				mlxsw_reg_sfd_uc_lag_unpack(sfd_pl, i,
-							    mac, &fid_index,
-							    &lag_id);
-				if (!bridge_port->lagged)
-					continue;
-				if (bridge_port->lag_id != lag_id)
-					continue;
-				tmp = mlxsw_sp_lag_rep_port(mlxsw_sp, lag_id);
-				if (tmp->local_port !=
-				    mlxsw_sp_port->local_port)
-					continue;
-				if (bridge_port->bridge_device->vlan_enabled)
-					fdb->vid = fid_index;
-				else
-					fdb->vid = 0;
-				ether_addr_copy(fdb->addr, mac);
-				fdb->ndm_state = NUD_REACHABLE;
-				err = cb(&fdb->obj);
-				if (err)
-					stored_err = err;
-				break;
-			}
-		}
-	} while (num_rec == MLXSW_REG_SFD_REC_MAX_COUNT);
-
-out:
-	kfree(sfd_pl);
-	return stored_err ? stored_err : err;
-}
-
-static int mlxsw_sp_port_obj_dump(struct net_device *dev,
-				  struct switchdev_obj *obj,
-				  switchdev_obj_dump_cb_t *cb)
-{
-	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
-	int err = 0;
-
-	switch (obj->id) {
-	case SWITCHDEV_OBJ_ID_PORT_FDB:
-		err = mlxsw_sp_port_fdb_dump(mlxsw_sp_port,
-					     SWITCHDEV_OBJ_PORT_FDB(obj), cb);
-		break;
-	default:
-		err = -EOPNOTSUPP;
-		break;
-	}
-
-	return err;
-}
-
 static const struct switchdev_ops mlxsw_sp_port_switchdev_ops = {
 	.switchdev_port_attr_get	= mlxsw_sp_port_attr_get,
 	.switchdev_port_attr_set	= mlxsw_sp_port_attr_set,
 	.switchdev_port_obj_add		= mlxsw_sp_port_obj_add,
 	.switchdev_port_obj_del		= mlxsw_sp_port_obj_del,
-	.switchdev_port_obj_dump	= mlxsw_sp_port_obj_dump,
 };
 
 static int
-- 
2.9.3
