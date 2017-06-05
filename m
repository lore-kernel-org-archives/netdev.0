From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/19] mlxsw: spectrum: Remove support for bypass bridge port attributes/vlan set
Date: Mon,  5 Jun 2017 11:20:33 +0200
Message-ID: <20170605092043.3523-10-jiri@resnulli.us>
References: <20170605092043.3523-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34851 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdFEJU6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 05:20:58 -0400
Received: by mail-wr0-f193.google.com with SMTP id g76so6833892wrd.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 02:20:57 -0700 (PDT)
In-Reply-To: <20170605092043.3523-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The bridge port attributes/vlan for mlxsw devices should be set only
from bridge code. The vlans are synced totally with the bridge so
there is no need to special dump support.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  3 --
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 41 ----------------------
 2 files changed, 44 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 84b6f36..a2ec42e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1755,9 +1755,6 @@ static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_fdb_add		= switchdev_port_fdb_add,
 	.ndo_fdb_del		= switchdev_port_fdb_del,
 	.ndo_fdb_dump		= switchdev_port_fdb_dump,
-	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
-	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
-	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_get_phys_port_name	= mlxsw_sp_port_get_phys_port_name,
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 0333493..6257b0b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -102,8 +102,6 @@ struct mlxsw_sp_bridge_vlan {
 	struct list_head list;
 	struct list_head port_vlan_list;
 	u16 vid;
-	u8 egress_untagged:1,
-	   pvid:1;
 };
 
 struct mlxsw_sp_bridge_ops {
@@ -1003,8 +1001,6 @@ mlxsw_sp_bridge_port_vlan_add(struct mlxsw_sp_port *mlxsw_sp_port,
 		goto err_port_vlan_bridge_join;
 
 	bridge_vlan = mlxsw_sp_bridge_vlan_find(bridge_port, vid);
-	bridge_vlan->egress_untagged = is_untagged;
-	bridge_vlan->pvid = is_pvid;
 
 	return 0;
 
@@ -1629,39 +1625,6 @@ static int mlxsw_sp_port_fdb_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 	return stored_err ? stored_err : err;
 }
 
-static int mlxsw_sp_port_vlan_dump(struct mlxsw_sp_port *mlxsw_sp_port,
-				   struct switchdev_obj_port_vlan *vlan,
-				   switchdev_obj_dump_cb_t *cb)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct net_device *orig_dev = vlan->obj.orig_dev;
-	struct mlxsw_sp_bridge_port *bridge_port;
-	struct mlxsw_sp_bridge_vlan *bridge_vlan;
-	int err = 0;
-
-	bridge_port = mlxsw_sp_bridge_port_find(mlxsw_sp->bridge, orig_dev);
-	if (WARN_ON(!bridge_port))
-		return -EINVAL;
-
-	if (!bridge_port->bridge_device->vlan_enabled)
-		return 0;
-
-	list_for_each_entry(bridge_vlan, &bridge_port->vlans_list, list) {
-		vlan->flags = 0;
-		if (bridge_vlan->pvid)
-			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
-		if (bridge_vlan->egress_untagged)
-			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
-		vlan->vid_begin = bridge_vlan->vid;
-		vlan->vid_end = bridge_vlan->vid;
-		err = cb(&vlan->obj);
-		if (err)
-			break;
-	}
-
-	return err;
-}
-
 static int mlxsw_sp_port_obj_dump(struct net_device *dev,
 				  struct switchdev_obj *obj,
 				  switchdev_obj_dump_cb_t *cb)
@@ -1670,10 +1633,6 @@ static int mlxsw_sp_port_obj_dump(struct net_device *dev,
 	int err = 0;
 
 	switch (obj->id) {
-	case SWITCHDEV_OBJ_ID_PORT_VLAN:
-		err = mlxsw_sp_port_vlan_dump(mlxsw_sp_port,
-					      SWITCHDEV_OBJ_PORT_VLAN(obj), cb);
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = mlxsw_sp_port_fdb_dump(mlxsw_sp_port,
 					     SWITCHDEV_OBJ_PORT_FDB(obj), cb);
-- 
2.9.3
