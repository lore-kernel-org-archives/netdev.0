From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/42] mlxsw: spectrum: Remove VLANs configuration via SELF flag
Date: Fri,  1 Jul 2016 16:04:33 +0200
Message-ID: <1467381910-3445-6-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32900 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbcGAOWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:22:31 -0400
Received: by mail-wm0-f68.google.com with SMTP id r201so5685986wme.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:21:43 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When port isn't bridged it is still possible to invoke switchdev ops and
configure the device's VLAN filters.

However, this will require us to use different Router InterFaces (RIFs)
for the same netdev, instead of one per-netdev as with any other
configuration.

Taking the above into account and the fact that this functionality is
questionable with regards to the device's normal use-case, remove it and
instead return an error.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 24 ++---------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  2 -
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 46 +---------------------
 3 files changed, 6 insertions(+), 66 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index afd06dc..4f67a8c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -890,8 +890,8 @@ err_port_vp_mode_trans:
 	return err;
 }
 
-int mlxsw_sp_port_kill_vid(struct net_device *dev,
-			   __be16 __always_unused proto, u16 vid)
+static int mlxsw_sp_port_kill_vid(struct net_device *dev,
+				  __be16 __always_unused proto, u16 vid)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port *mlxsw_sp_vport;
@@ -1845,23 +1845,6 @@ err_port_active_vlans_alloc:
 	return err;
 }
 
-static void mlxsw_sp_port_vports_fini(struct mlxsw_sp_port *mlxsw_sp_port)
-{
-	struct net_device *dev = mlxsw_sp_port->dev;
-	struct mlxsw_sp_port *mlxsw_sp_vport, *tmp;
-
-	list_for_each_entry_safe(mlxsw_sp_vport, tmp,
-				 &mlxsw_sp_port->vports_list, vport.list) {
-		u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
-
-		/* vPorts created for VLAN devices should already be gone
-		 * by now, since we unregistered the port netdev.
-		 */
-		WARN_ON(is_vlan_dev(mlxsw_sp_vport->dev));
-		mlxsw_sp_port_kill_vid(dev, 0, vid);
-	}
-}
-
 static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
@@ -1872,13 +1855,14 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_core_port_fini(&mlxsw_sp_port->core_port);
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
 	mlxsw_sp_port_dcb_fini(mlxsw_sp_port);
-	mlxsw_sp_port_vports_fini(mlxsw_sp_port);
+	mlxsw_sp_port_kill_vid(mlxsw_sp_port->dev, 0, 1);
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 	mlxsw_sp_port_module_unmap(mlxsw_sp, mlxsw_sp_port->local_port);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 	kfree(mlxsw_sp_port->untagged_vlans);
 	kfree(mlxsw_sp_port->active_vlans);
+	WARN_ON_ONCE(!list_empty(&mlxsw_sp_port->vports_list));
 	free_netdev(mlxsw_sp_port->dev);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 36c9835..05d5fcc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -377,8 +377,6 @@ int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
 			   u16 vid_end, bool is_member, bool untagged);
 int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 			  u16 vid);
-int mlxsw_sp_port_kill_vid(struct net_device *dev,
-			   __be16 __always_unused proto, u16 vid);
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 			     bool set);
 void mlxsw_sp_port_active_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index a0c7376..927117e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -633,25 +633,6 @@ err_port_allow_untagged_set:
 	return err;
 }
 
-static int mlxsw_sp_port_add_vids(struct net_device *dev, u16 vid_begin,
-				  u16 vid_end)
-{
-	u16 vid;
-	int err;
-
-	for (vid = vid_begin; vid <= vid_end; vid++) {
-		err = mlxsw_sp_port_add_vid(dev, 0, vid);
-		if (err)
-			goto err_port_add_vid;
-	}
-	return 0;
-
-err_port_add_vid:
-	for (vid--; vid >= vid_begin; vid--)
-		mlxsw_sp_port_kill_vid(dev, 0, vid);
-	return err;
-}
-
 static int __mlxsw_sp_port_vlans_set(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 vid_begin, u16 vid_end, bool is_member,
 				     bool untagged)
@@ -681,12 +662,8 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	u16 vid, old_pvid;
 	int err;
 
-	/* In case this is invoked with BRIDGE_FLAGS_SELF and port is
-	 * not bridged, then packets ingressing through the port with
-	 * the specified VIDs will be directed to CPU.
-	 */
 	if (!mlxsw_sp_port->bridged)
-		return mlxsw_sp_port_add_vids(dev, vid_begin, vid_end);
+		return -EINVAL;
 
 	err = mlxsw_sp_port_fid_join(mlxsw_sp_port, vid_begin, vid_end);
 	if (err) {
@@ -1019,21 +996,6 @@ static int mlxsw_sp_port_obj_add(struct net_device *dev,
 	return err;
 }
 
-static int mlxsw_sp_port_kill_vids(struct net_device *dev, u16 vid_begin,
-				   u16 vid_end)
-{
-	u16 vid;
-	int err;
-
-	for (vid = vid_begin; vid <= vid_end; vid++) {
-		err = mlxsw_sp_port_kill_vid(dev, 0, vid);
-		if (err)
-			return err;
-	}
-
-	return 0;
-}
-
 static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 				     u16 vid_begin, u16 vid_end, bool init)
 {
@@ -1041,12 +1003,8 @@ static int __mlxsw_sp_port_vlans_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	u16 vid, pvid;
 	int err;
 
-	/* In case this is invoked with BRIDGE_FLAGS_SELF and port is
-	 * not bridged, then prevent packets ingressing through the
-	 * port with the specified VIDs from being trapped to CPU.
-	 */
 	if (!init && !mlxsw_sp_port->bridged)
-		return mlxsw_sp_port_kill_vids(dev, vid_begin, vid_end);
+		return -EINVAL;
 
 	err = __mlxsw_sp_port_vlans_set(mlxsw_sp_port, vid_begin, vid_end,
 					false, false);
-- 
2.5.5
