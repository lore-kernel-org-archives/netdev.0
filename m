From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 3/9] mlxsw: spectrum: Create PVID vPort before registering netdevice
Date: Mon, 15 Aug 2016 16:37:47 +0200
Message-ID: <1471271873-4389-4-git-send-email-jiri@resnulli.us>
References: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33614 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173AbcHOOiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 10:38:06 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so11487334wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 07:38:05 -0700 (PDT)
In-Reply-To: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

After registering a netdevice it's possible for user space applications
to configure an IP address on it. From the driver's perspective, this
means a router interface (RIF) should be created for the PVID vPort.

Therefore, we must create the PVID vPort before registering the
netdevice.

Fixes: 99724c18fc66 ("mlxsw: spectrum: Introduce support for router interfaces")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 33 +++++++++++++-----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  2 --
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 40 +++-------------------
 3 files changed, 29 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index a9281afc..0677f3f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -942,8 +942,8 @@ static void mlxsw_sp_port_vport_destroy(struct mlxsw_sp_port *mlxsw_sp_vport)
 	kfree(mlxsw_sp_vport);
 }
 
-int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
-			  u16 vid)
+static int mlxsw_sp_port_add_vid(struct net_device *dev,
+				 __be16 __always_unused proto, u16 vid)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port *mlxsw_sp_vport;
@@ -2048,6 +2048,18 @@ static int mlxsw_sp_port_ets_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	return 0;
 }
 
+static int mlxsw_sp_port_pvid_vport_create(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	mlxsw_sp_port->pvid = 1;
+
+	return mlxsw_sp_port_add_vid(mlxsw_sp_port->dev, 0, 1);
+}
+
+static int mlxsw_sp_port_pvid_vport_destroy(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	return mlxsw_sp_port_kill_vid(mlxsw_sp_port->dev, 0, 1);
+}
+
 static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				bool split, u8 module, u8 width, u8 lane)
 {
@@ -2163,6 +2175,13 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_port_dcb_init;
 	}
 
+	err = mlxsw_sp_port_pvid_vport_create(mlxsw_sp_port);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Port %d: Failed to create PVID vPort\n",
+			mlxsw_sp_port->local_port);
+		goto err_port_pvid_vport_create;
+	}
+
 	mlxsw_sp_port_switchdev_init(mlxsw_sp_port);
 	err = register_netdev(dev);
 	if (err) {
@@ -2180,18 +2199,14 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_core_port_init;
 	}
 
-	err = mlxsw_sp_port_vlan_init(mlxsw_sp_port);
-	if (err)
-		goto err_port_vlan_init;
-
 	mlxsw_sp->ports[local_port] = mlxsw_sp_port;
 	return 0;
 
-err_port_vlan_init:
-	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
 err_core_port_init:
 	unregister_netdev(dev);
 err_register_netdev:
+	mlxsw_sp_port_pvid_vport_destroy(mlxsw_sp_port);
+err_port_pvid_vport_create:
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
 err_port_dcb_init:
 err_port_ets_init:
@@ -2221,8 +2236,8 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp->ports[local_port] = NULL;
 	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
+	mlxsw_sp_port_pvid_vport_destroy(mlxsw_sp_port);
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
-	mlxsw_sp_port_kill_vid(mlxsw_sp_port->dev, 0, 1);
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 	mlxsw_sp_port_module_unmap(mlxsw_sp, mlxsw_sp_port->local_port);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index f69aa37..ab3feb8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -536,8 +536,6 @@ int mlxsw_sp_port_vid_to_fid_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				 u16 vid);
 int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
 			   u16 vid_end, bool is_member, bool untagged);
-int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
-			  u16 vid);
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 			     bool set);
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index a1ad5e6..b5e864d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -997,13 +997,13 @@ static int mlxsw_sp_port_obj_add(struct net_device *dev,
 }
 
 static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
-				     u16 vid_begin, u16 vid_end, bool init)
+				     u16 vid_begin, u16 vid_end)
 {
 	struct net_device *dev = mlxsw_sp_port->dev;
 	u16 vid, pvid;
 	int err;
 
-	if (!init && !mlxsw_sp_port->bridged)
+	if (!mlxsw_sp_port->bridged)
 		return -EINVAL;
 
 	err = __mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end,
@@ -1014,9 +1014,6 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 		return err;
 	}
 
-	if (init)
-		goto out;
-
 	pvid = mlxsw_sp_port->pvid;
 	if (pvid >= vid_begin && pvid <= vid_end) {
 		err = mlxsw_sp_port_pvid_set(mlxsw_sp_port, 0);
@@ -1028,7 +1025,6 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 
 	mlxsw_sp_port_fid_leave(mlxsw_sp_port, vid_begin, vid_end);
 
-out:
 	/* Changing activity bits only if HW operation succeded */
 	for (vid = vid_begin; vid <= vid_end; vid++)
 		clear_bit(vid, mlxsw_sp_port->active_vlans);
@@ -1039,8 +1035,8 @@ out:
 static int mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 				   const struct switchdev_obj_port_vlan *vlan)
 {
-	return __mlxsw_sp_port_vlans_del(mlxsw_sp_port,
-					 vlan->vid_begin, vlan->vid_end, false);
+	return __mlxsw_sp_port_vlans_del(mlxsw_sp_port, vlan->vid_begin,
+					 vlan->vid_end);
 }
 
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port)
@@ -1048,7 +1044,7 @@ void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port)
 	u16 vid;
 
 	for_each_set_bit(vid, mlxsw_sp_port->active_vlans, VLAN_N_VID)
-		__mlxsw_sp_port_vlans_del(mlxsw_sp_port, vid, vid, false);
+		__mlxsw_sp_port_vlans_del(mlxsw_sp_port, vid, vid);
 }
 
 static int
@@ -1546,32 +1542,6 @@ void mlxsw_sp_switchdev_fini(struct mlxsw_sp *mlxsw_sp)
 	mlxsw_sp_fdb_fini(mlxsw_sp);
 }
 
-int mlxsw_sp_port_vlan_init(struct mlxsw_sp_port *mlxsw_sp_port)
-{
-	struct net_device *dev = mlxsw_sp_port->dev;
-	int err;
-
-	/* Allow only untagged packets to ingress and tag them internally
-	 * with VID 1.
-	 */
-	mlxsw_sp_port->pvid = 1;
-	err = __mlxsw_sp_port_vlans_del(mlxsw_sp_port, 0, VLAN_N_VID - 1,
-					true);
-	if (err) {
-		netdev_err(dev, "Unable to init VLANs\n");
-		return err;
-	}
-
-	/* Add implicit VLAN interface in the device, so that untagged
-	 * packets will be classified to the default vFID.
-	 */
-	err = mlxsw_sp_port_add_vid(dev, 0, 1);
-	if (err)
-		netdev_err(dev, "Failed to configure default vFID\n");
-
-	return err;
-}
-
 void mlxsw_sp_port_switchdev_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
 	mlxsw_sp_port->dev->switchdev_ops = &mlxsw_sp_port_switchdev_ops;
-- 
2.5.5
