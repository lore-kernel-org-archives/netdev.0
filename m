From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/16] mlxsw: spectrum_switchdev: Flood all mc packets to mrouter ports
Date: Wed, 20 Sep 2017 16:15:13 +0200
Message-ID: <20170920141516.1402-14-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34418 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751772AbdITOPa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:30 -0400
Received: by mail-wr0-f195.google.com with SMTP id k20so1585445wre.1
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:29 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

When mc is enabled, whenever a mc packet doesn't hit any mdb entry it is
being flood to the ports marked as mrouters. However, all mc packets should
be flooded to them even if they match an entry in the mdb.
This patch adds the mrouter ports to every mdb entry that is being written
to the HW.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 65 ++++++++++++++++++++--
 1 file changed, 60 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index bc07873..146beaa 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1288,10 +1288,55 @@ mlxsw_sp_mid *__mlxsw_sp_mc_get(struct mlxsw_sp_bridge_device *bridge_device,
 	return NULL;
 }
 
+static void
+mlxsw_sp_bridge_port_get_ports_bitmap(struct mlxsw_sp *mlxsw_sp,
+				      struct mlxsw_sp_bridge_port *bridge_port,
+				      unsigned long *ports_bitmap)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	u64 max_lag_members, i;
+	int lag_id;
+
+	if (!bridge_port->lagged) {
+		set_bit(bridge_port->system_port, ports_bitmap);
+	} else {
+		max_lag_members = MLXSW_CORE_RES_GET(mlxsw_sp->core,
+						     MAX_LAG_MEMBERS);
+		lag_id = bridge_port->lag_id;
+		for (i = 0; i < max_lag_members; i++) {
+			mlxsw_sp_port = mlxsw_sp_port_lagged_get(mlxsw_sp,
+								 lag_id, i);
+			if (mlxsw_sp_port)
+				set_bit(mlxsw_sp_port->local_port,
+					ports_bitmap);
+		}
+	}
+}
+
+static void
+mlxsw_sp_mc_get_mrouters_bitmap(unsigned long *flood_bitmap,
+				struct mlxsw_sp_bridge_device *bridge_device,
+				struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_bridge_port *bridge_port;
+
+	list_for_each_entry(bridge_port, &bridge_device->ports_list, list) {
+		if (bridge_port->mrouter) {
+			mlxsw_sp_bridge_port_get_ports_bitmap(mlxsw_sp,
+							      bridge_port,
+							      flood_bitmap);
+		}
+	}
+}
+
 static bool
 mlxsw_sp_mc_write_mdb_entry(struct mlxsw_sp *mlxsw_sp,
-			    struct mlxsw_sp_mid *mid)
+			    struct mlxsw_sp_mid *mid,
+			    struct mlxsw_sp_bridge_device *bridge_device)
 {
+	long *flood_bitmap;
+	int num_of_ports;
+	int alloc_size;
 	u16 mid_idx;
 	int err;
 
@@ -1300,9 +1345,18 @@ mlxsw_sp_mc_write_mdb_entry(struct mlxsw_sp *mlxsw_sp,
 	if (mid_idx == MLXSW_SP_MID_MAX)
 		return false;
 
+	num_of_ports = mlxsw_core_max_ports(mlxsw_sp->core);
+	alloc_size = sizeof(long) * BITS_TO_LONGS(num_of_ports);
+	flood_bitmap = kzalloc(alloc_size, GFP_KERNEL);
+	if (!flood_bitmap)
+		return false;
+
+	bitmap_copy(flood_bitmap,  mid->ports_in_mid, num_of_ports);
+	mlxsw_sp_mc_get_mrouters_bitmap(flood_bitmap, bridge_device, mlxsw_sp);
+
 	mid->mid = mid_idx;
-	err = mlxsw_sp_port_smid_full_entry(mlxsw_sp, mid_idx,
-					    mid->ports_in_mid);
+	err = mlxsw_sp_port_smid_full_entry(mlxsw_sp, mid_idx, flood_bitmap);
+	kfree(flood_bitmap);
 	if (err)
 		return false;
 
@@ -1355,7 +1409,7 @@ mlxsw_sp_mid *__mlxsw_sp_mc_alloc(struct mlxsw_sp *mlxsw_sp,
 	if (!bridge_device->multicast_enabled)
 		goto out;
 
-	if (!mlxsw_sp_mc_write_mdb_entry(mlxsw_sp, mid))
+	if (!mlxsw_sp_mc_write_mdb_entry(mlxsw_sp, mid, bridge_device))
 		goto err_write_mdb_entry;
 
 out:
@@ -1456,7 +1510,8 @@ mlxsw_sp_bridge_mdb_mc_enable_sync(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	list_for_each_entry(mid, &bridge_device->mids_list, list) {
 		if (mc_enabled)
-			mlxsw_sp_mc_write_mdb_entry(mlxsw_sp, mid);
+			mlxsw_sp_mc_write_mdb_entry(mlxsw_sp, mid,
+						    bridge_device);
 		else
 			mlxsw_sp_mc_remove_mdb_entry(mlxsw_sp, mid);
 	}
-- 
2.9.5
