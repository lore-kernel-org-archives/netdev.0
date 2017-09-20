From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/16] mlxsw: spectrum_switchdev: Update the mdb of mrouter port change
Date: Wed, 20 Sep 2017 16:15:14 +0200
Message-ID: <20170920141516.1402-15-jiri@resnulli.us>
References: <20170920141516.1402-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37630 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751778AbdITOPb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 10:15:31 -0400
Received: by mail-wm0-f65.google.com with SMTP id f4so2564226wmh.4
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 07:15:30 -0700 (PDT)
In-Reply-To: <20170920141516.1402-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Whenever a port starts / stops being mrouter, update all the mdb entries
in the HW to flood / stop flooding mc packets there.
The change should happen only if the port is not in the mid. (If it is,
the mid should flood mc packets to this port anyway)

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 23 ++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 146beaa..bf1a175 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -130,6 +130,11 @@ mlxsw_sp_bridge_mdb_mc_enable_sync(struct mlxsw_sp_port *mlxsw_sp_port,
 				   struct mlxsw_sp_bridge_device
 				   *bridge_device);
 
+static void
+mlxsw_sp_port_mrouter_update_mdb(struct mlxsw_sp_port *mlxsw_sp_port,
+				 struct mlxsw_sp_bridge_port *bridge_port,
+				 bool add);
+
 static struct mlxsw_sp_bridge_device *
 mlxsw_sp_bridge_device_find(const struct mlxsw_sp_bridge *bridge,
 			    const struct net_device *br_dev)
@@ -747,6 +752,8 @@ static int mlxsw_sp_port_attr_mrouter_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (err)
 		return err;
 
+	mlxsw_sp_port_mrouter_update_mdb(mlxsw_sp_port, bridge_port,
+					 is_port_mrouter);
 out:
 	bridge_port->mrouter = is_port_mrouter;
 	return 0;
@@ -1517,6 +1524,22 @@ mlxsw_sp_bridge_mdb_mc_enable_sync(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 }
 
+static void
+mlxsw_sp_port_mrouter_update_mdb(struct mlxsw_sp_port *mlxsw_sp_port,
+				 struct mlxsw_sp_bridge_port *bridge_port,
+				 bool add)
+{
+	struct mlxsw_sp_bridge_device *bridge_device;
+	struct mlxsw_sp_mid *mid;
+
+	bridge_device = bridge_port->bridge_device;
+
+	list_for_each_entry(mid, &bridge_device->mids_list, list) {
+		if (!test_bit(mlxsw_sp_port->local_port, mid->ports_in_mid))
+			mlxsw_sp_port_smid_set(mlxsw_sp_port, mid->mid, add);
+	}
+}
+
 static int mlxsw_sp_port_obj_add(struct net_device *dev,
 				 const struct switchdev_obj *obj,
 				 struct switchdev_trans *trans)
-- 
2.9.5
