From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 22/23] mlxsw: spectrum: Free resources upon vPort destruction
Date: Mon, 20 Jun 2016 23:04:20 +0200
Message-ID: <1466456661-5260-23-git-send-email-jiri@resnulli.us>
References: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33331 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbcFTVWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:22:06 -0400
Received: by mail-lf0-f67.google.com with SMTP id l188so6857676lfe.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:20:31 -0700 (PDT)
In-Reply-To: <1466456661-5260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

There are situations in which a vPort is destroyed while still holding
references to device's resources such as FIDs and FDB records. This can
happen, for example, when a VLAN device is deleted while still being
bridged.

Instead of trying to make sure vPort destruction is invoked when it no
longer uses device's resources, just free them upon destruction. This
simplifies the code, as we no longer need to take different situations
into account when events are received - cleanup is taken care of in one
place.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 49 ++++++++------------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  1 +
 2 files changed, 15 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 2b1748d..9f48ec5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -660,6 +660,8 @@ static int mlxsw_sp_vfid_op(struct mlxsw_sp *mlxsw_sp, u16 fid, bool create)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
 }
 
+static void mlxsw_sp_vport_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
+
 static struct mlxsw_sp_fid *mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp,
 						 u16 vid)
 {
@@ -685,6 +687,7 @@ static struct mlxsw_sp_fid *mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp,
 	if (!f)
 		goto err_allocate_vfid;
 
+	f->leave = mlxsw_sp_vport_vfid_leave;
 	f->fid = fid;
 	f->vid = vid;
 
@@ -887,6 +890,7 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	struct mlxsw_sp_port *mlxsw_sp_vport;
+	struct mlxsw_sp_fid *f;
 	int err;
 
 	/* VLAN 0 is removed from HW filter when device goes down, but
@@ -921,7 +925,12 @@ int mlxsw_sp_port_kill_vid(struct net_device *dev,
 		return err;
 	}
 
-	mlxsw_sp_vport_vfid_leave(mlxsw_sp_vport);
+	/* Drop FID reference. If this was the last reference the
+	 * resources will be freed.
+	 */
+	f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
+	if (f && !WARN_ON(!f->leave))
+		f->leave(mlxsw_sp_vport);
 
 	/* When removing the last VLAN interface on a bridged port we need to
 	 * transition all active 802.1Q bridge VLANs to use VID to FID
@@ -2836,15 +2845,12 @@ err_col_port_add:
 	return err;
 }
 
-static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
-
 static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 				    struct net_device *lag_dev)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct mlxsw_sp_port *mlxsw_sp_vport;
-	struct mlxsw_sp_upper *lag;
 	u16 lag_id = mlxsw_sp_port->lag_id;
+	struct mlxsw_sp_upper *lag;
 
 	if (!mlxsw_sp_port->lagged)
 		return;
@@ -2854,21 +2860,6 @@ static void mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_lag_col_port_disable(mlxsw_sp_port, lag_id);
 	mlxsw_sp_lag_col_port_remove(mlxsw_sp_port, lag_id);
 
-	/* In case we leave a LAG device that has bridges built on top,
-	 * then their teardown sequence is never issued and we need to
-	 * invoke the necessary cleanup routines ourselves.
-	 */
-	list_for_each_entry(mlxsw_sp_vport, &mlxsw_sp_port->vports_list,
-			    vport.list) {
-		struct net_device *br_dev;
-
-		if (!mlxsw_sp_vport->bridged)
-			continue;
-
-		br_dev = mlxsw_sp_vport_br_get(mlxsw_sp_vport);
-		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
-	}
-
 	if (mlxsw_sp_port->bridged) {
 		mlxsw_sp_port_active_vlans_del(mlxsw_sp_port);
 		mlxsw_sp_port_bridge_leave(mlxsw_sp_port);
@@ -2947,17 +2938,6 @@ static void mlxsw_sp_port_vlan_unlink(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (WARN_ON(!mlxsw_sp_vport))
 		return;
 
-	/* When removing a VLAN device while still bridged we should first
-	 * remove it from the bridge, as we receive the bridge's notification
-	 * when the vPort is already gone.
-	 */
-	if (mlxsw_sp_vport->bridged) {
-		struct net_device *br_dev;
-
-		br_dev = mlxsw_sp_vport_br_get(mlxsw_sp_vport);
-		mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
-	}
-
 	mlxsw_sp_vport->dev = mlxsw_sp_port->dev;
 }
 
@@ -3115,6 +3095,8 @@ static u16 mlxsw_sp_avail_br_vfid_get(const struct mlxsw_sp *mlxsw_sp)
 				   MLXSW_SP_VFID_BR_MAX);
 }
 
+static void mlxsw_sp_vport_br_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
+
 static struct mlxsw_sp_fid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
 						    struct net_device *br_dev)
 {
@@ -3140,6 +3122,7 @@ static struct mlxsw_sp_fid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
 	if (!f)
 		goto err_allocate_vfid;
 
+	f->leave = mlxsw_sp_vport_br_vfid_leave;
 	f->fid = fid;
 	f->dev = br_dev;
 
@@ -3321,10 +3304,6 @@ static int mlxsw_sp_netdevice_vport_event(struct net_device *dev,
 			err = mlxsw_sp_vport_bridge_join(mlxsw_sp_vport,
 							 upper_dev);
 		} else {
-			/* We ignore bridge's unlinking notifications if vPort
-			 * is gone, since we already left the bridge when the
-			 * VLAN device was unlinked from the real device.
-			 */
 			if (!mlxsw_sp_vport)
 				return 0;
 			mlxsw_sp_vport_bridge_leave(mlxsw_sp_vport);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 9122abb..36c9835 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -88,6 +88,7 @@ struct mlxsw_sp_upper {
 };
 
 struct mlxsw_sp_fid {
+	void (*leave)(struct mlxsw_sp_port *mlxsw_sp_vport);
 	struct list_head list;
 	unsigned int ref_count;
 	struct net_device *dev;
-- 
2.5.5
