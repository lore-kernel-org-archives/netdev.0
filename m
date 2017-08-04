From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum_switchdev: Don't warn about valid situations
Date: Fri,  4 Aug 2017 14:12:29 +0200
Message-ID: <20170804121230.2144-2-jiri@resnulli.us>
References: <20170804121230.2144-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34118 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752547AbdHDMMg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:12:36 -0400
Received: by mail-wm0-f68.google.com with SMTP id x64so5503022wmg.1
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:12:35 -0700 (PDT)
In-Reply-To: <20170804121230.2144-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Some operations in the bridge driver such as MDB deletion are preformed
in an atomic context and thus deferred to a process context by the
switchdev infrastructure.

Therefore, by the time the operation is performed by the underlying
device driver it's possible the bridge port context is already gone.
This is especially true for removal flows, but theoretically can also be
invoked during addition.

Remove the warnings in such situations and return normally.

Fixes: c57529e1d5d8 ("mlxsw: spectrum: Replace vPorts with Port-VLAN")
Fixes: 3922285d96e7 ("net: bridge: Add support for offloading port attributes")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 24 +++++++++++-----------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 656b2d3..73d54df 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -626,8 +626,8 @@ static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	bridge_port = mlxsw_sp_bridge_port_find(mlxsw_sp_port->mlxsw_sp->bridge,
 						orig_dev);
-	if (WARN_ON(!bridge_port))
-		return -EINVAL;
+	if (!bridge_port)
+		return 0;
 
 	err = mlxsw_sp_bridge_port_flood_table_set(mlxsw_sp_port, bridge_port,
 						   MLXSW_SP_FLOOD_TYPE_UC,
@@ -711,8 +711,8 @@ static int mlxsw_sp_port_attr_mc_router_set(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	bridge_port = mlxsw_sp_bridge_port_find(mlxsw_sp_port->mlxsw_sp->bridge,
 						orig_dev);
-	if (WARN_ON(!bridge_port))
-		return -EINVAL;
+	if (!bridge_port)
+		return 0;
 
 	if (!bridge_port->bridge_device->multicast_enabled)
 		return 0;
@@ -1283,15 +1283,15 @@ static int mlxsw_sp_port_mdb_add(struct mlxsw_sp_port *mlxsw_sp_port,
 		return 0;
 
 	bridge_port = mlxsw_sp_bridge_port_find(mlxsw_sp->bridge, orig_dev);
-	if (WARN_ON(!bridge_port))
-		return -EINVAL;
+	if (!bridge_port)
+		return 0;
 
 	bridge_device = bridge_port->bridge_device;
 	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_bridge(mlxsw_sp_port,
 							       bridge_device,
 							       mdb->vid);
-	if (WARN_ON(!mlxsw_sp_port_vlan))
-		return -EINVAL;
+	if (!mlxsw_sp_port_vlan)
+		return 0;
 
 	fid_index = mlxsw_sp_fid_index(mlxsw_sp_port_vlan->fid);
 
@@ -1407,15 +1407,15 @@ static int mlxsw_sp_port_mdb_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	int err = 0;
 
 	bridge_port = mlxsw_sp_bridge_port_find(mlxsw_sp->bridge, orig_dev);
-	if (WARN_ON(!bridge_port))
-		return -EINVAL;
+	if (!bridge_port)
+		return 0;
 
 	bridge_device = bridge_port->bridge_device;
 	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_bridge(mlxsw_sp_port,
 							       bridge_device,
 							       mdb->vid);
-	if (WARN_ON(!mlxsw_sp_port_vlan))
-		return -EINVAL;
+	if (!mlxsw_sp_port_vlan)
+		return 0;
 
 	fid_index = mlxsw_sp_fid_index(mlxsw_sp_port_vlan->fid);
 
-- 
2.9.3
