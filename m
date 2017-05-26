From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/18] mlxsw: spectrum: Change signature of FID leave function
Date: Fri, 26 May 2017 08:37:27 +0200
Message-ID: <20170526063740.8909-6-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33800 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935579AbdEZGhv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:37:51 -0400
Received: by mail-lf0-f68.google.com with SMTP id q24so170409lfb.1
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:37:50 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a vPort is destroyed, it leaves the FID it's currently mapped to
(if any) and drops the reference. The FID's leave function expects to
get the vPort as its argument, but this will have to change when the
vPort model is retired.

Change the function signature to expect a Port-VLAN struct instead and
patch the call sites accordingly.

The code introduced in this patch will be removed later in the patchset,
but this intermediary step is required in order to ease the code review.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 42 +++++++++++++++-------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  3 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 23 +++++++-----
 3 files changed, 47 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6f5f011..acc3a1a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1574,7 +1574,7 @@ static int mlxsw_sp_port_kill_vid(struct net_device *dev,
 	 */
 	f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 	if (f && !WARN_ON(!f->leave))
-		f->leave(mlxsw_sp_vport);
+		f->leave(mlxsw_sp_port_vlan);
 
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
 
@@ -4192,6 +4192,7 @@ static void
 mlxsw_sp_port_pvid_vport_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
 				  struct net_device *lag_dev, u16 lag_id)
 {
+	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	struct mlxsw_sp_fid *f;
 
@@ -4199,12 +4200,13 @@ mlxsw_sp_port_pvid_vport_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
 	if (WARN_ON(!mlxsw_sp_vport))
 		return;
 
+	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_vid(mlxsw_sp_port, 1);
 	/* If vPort is assigned a RIF, then leave it since it's no
 	 * longer valid.
 	 */
 	f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 	if (f)
-		f->leave(mlxsw_sp_vport);
+		f->leave(mlxsw_sp_port_vlan);
 
 	mlxsw_sp_vport->lag_id = lag_id;
 	mlxsw_sp_vport->lagged = 1;
@@ -4214,6 +4216,7 @@ mlxsw_sp_port_pvid_vport_lag_join(struct mlxsw_sp_port *mlxsw_sp_port,
 static void
 mlxsw_sp_port_pvid_vport_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 {
+	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 	struct mlxsw_sp_fid *f;
 
@@ -4221,9 +4224,10 @@ mlxsw_sp_port_pvid_vport_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port)
 	if (WARN_ON(!mlxsw_sp_vport))
 		return;
 
+	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_vid(mlxsw_sp_port, 1);
 	f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 	if (f)
-		f->leave(mlxsw_sp_vport);
+		f->leave(mlxsw_sp_port_vlan);
 
 	mlxsw_sp_vport->dev = mlxsw_sp_port->dev;
 	mlxsw_sp_vport->lagged = 0;
@@ -4652,7 +4656,8 @@ static int mlxsw_sp_vfid_op(struct mlxsw_sp *mlxsw_sp, u16 fid, bool create)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
 }
 
-static void mlxsw_sp_vport_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
+static void
+mlxsw_sp_port_vlan_vfid_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan);
 
 static struct mlxsw_sp_fid *mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp,
 						 struct net_device *br_dev)
@@ -4679,7 +4684,7 @@ static struct mlxsw_sp_fid *mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp,
 	if (!f)
 		goto err_allocate_vfid;
 
-	f->leave = mlxsw_sp_vport_vfid_leave;
+	f->leave = mlxsw_sp_port_vlan_vfid_leave;
 	f->fid = fid;
 	f->dev = br_dev;
 
@@ -4767,17 +4772,22 @@ static int mlxsw_sp_vport_vfid_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	return err;
 }
 
-static void mlxsw_sp_vport_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
+static void
+mlxsw_sp_port_vlan_vfid_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan)
 {
-	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
-	struct mlxsw_sp_port *mlxsw_sp_port;
+	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+	u16 vid = mlxsw_sp_port_vlan->vid;
+	struct mlxsw_sp_fid *f;
+
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
+	f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
 	netdev_dbg(mlxsw_sp_vport->dev, "Left FID=%d\n", f->fid);
 
 	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
 	f->ref_count--;
 
-	mlxsw_sp_port = mlxsw_sp_vport_port(mlxsw_sp_vport);
 	if (mlxsw_sp_port->nr_port_vid_map == 1)
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 	mlxsw_sp_port->nr_port_vid_map--;
@@ -4797,11 +4807,15 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 {
 	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
 	struct net_device *dev = mlxsw_sp_vport->dev;
+	struct mlxsw_sp_port *mlxsw_sp_port;
 	int err;
 
+	mlxsw_sp_port = mlxsw_sp_vport_port(mlxsw_sp_vport);
+	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_vid(mlxsw_sp_port, vid);
 	if (f && !WARN_ON(!f->leave))
-		f->leave(mlxsw_sp_vport);
+		f->leave(mlxsw_sp_port_vlan);
 
 	err = mlxsw_sp_vport_vfid_join(mlxsw_sp_vport, br_dev);
 	if (err) {
@@ -4826,17 +4840,21 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	return 0;
 
 err_port_vid_learning_set:
-	mlxsw_sp_vport_vfid_leave(mlxsw_sp_vport);
+	mlxsw_sp_port_vlan_vfid_leave(mlxsw_sp_port_vlan);
 	return err;
 }
 
 static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 {
 	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
+	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
+	struct mlxsw_sp_port *mlxsw_sp_port;
 
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
 
-	mlxsw_sp_vport_vfid_leave(mlxsw_sp_vport);
+	mlxsw_sp_port = mlxsw_sp_vport_port(mlxsw_sp_vport);
+	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_vid(mlxsw_sp_port, vid);
+	mlxsw_sp_port_vlan_vfid_leave(mlxsw_sp_port_vlan);
 
 	mlxsw_sp_vport->learning = 0;
 	mlxsw_sp_vport->learning_sync = 0;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index c4ac648..b72ecf3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -70,6 +70,7 @@
 #define MLXSW_SP_KVD_LINEAR_SIZE 65536 /* entries */
 #define MLXSW_SP_KVD_GRANULARITY 128
 
+struct mlxsw_sp_port_vlan;
 struct mlxsw_sp_port;
 struct mlxsw_sp_rif;
 
@@ -79,7 +80,7 @@ struct mlxsw_sp_upper {
 };
 
 struct mlxsw_sp_fid {
-	void (*leave)(struct mlxsw_sp_port *mlxsw_sp_vport);
+	void (*leave)(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan);
 	struct list_head list;
 	unsigned int ref_count;
 	struct net_device *dev;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index cb5e86a..6a1de24 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2945,7 +2945,8 @@ static int mlxsw_sp_vport_rif_sp_op(struct mlxsw_sp_port *mlxsw_sp_vport,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
 }
 
-static void mlxsw_sp_vport_rif_sp_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
+static void
+mlxsw_sp_port_vlan_rif_sp_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan);
 
 static u16 mlxsw_sp_rif_sp_to_fid(u16 rif_index)
 {
@@ -2961,7 +2962,7 @@ mlxsw_sp_rfid_alloc(u16 fid, struct net_device *l3_dev)
 	if (!f)
 		return NULL;
 
-	f->leave = mlxsw_sp_vport_rif_sp_leave;
+	f->leave = mlxsw_sp_port_vlan_rif_sp_leave;
 	f->ref_count = 0;
 	f->dev = l3_dev;
 	f->fid = fid;
@@ -3156,18 +3157,22 @@ static int mlxsw_sp_vport_rif_sp_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	return err;
 }
 
-static void mlxsw_sp_vport_rif_sp_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
+static void
+mlxsw_sp_port_vlan_rif_sp_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan)
 {
-	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
-	u16 vid = mlxsw_sp_vport_vid_get(mlxsw_sp_vport);
-	struct mlxsw_sp_port *mlxsw_sp_port;
+	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
+	struct mlxsw_sp_port *mlxsw_sp_vport;
+	u16 vid = mlxsw_sp_port_vlan->vid;
+	struct mlxsw_sp_fid *f;
+
+	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
+	f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
 	netdev_dbg(mlxsw_sp_vport->dev, "Left FID=%d\n", f->fid);
 
 	f->ref_count--;
 	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
 
-	mlxsw_sp_port = mlxsw_sp_vport_port(mlxsw_sp_vport);
 	if (mlxsw_sp_port->nr_port_vid_map == 1)
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 	mlxsw_sp_port->nr_port_vid_map--;
@@ -3183,17 +3188,19 @@ static int mlxsw_sp_inetaddr_vport_event(struct net_device *l3_dev,
 					 unsigned long event, u16 vid)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(port_dev);
+	struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan;
 	struct mlxsw_sp_port *mlxsw_sp_vport;
 
 	mlxsw_sp_vport = mlxsw_sp_port_vport_find(mlxsw_sp_port, vid);
 	if (WARN_ON(!mlxsw_sp_vport))
 		return -EINVAL;
+	mlxsw_sp_port_vlan = mlxsw_sp_port_vlan_find_by_vid(mlxsw_sp_port, vid);
 
 	switch (event) {
 	case NETDEV_UP:
 		return mlxsw_sp_vport_rif_sp_join(mlxsw_sp_vport, l3_dev);
 	case NETDEV_DOWN:
-		mlxsw_sp_vport_rif_sp_leave(mlxsw_sp_vport);
+		mlxsw_sp_port_vlan_rif_sp_leave(mlxsw_sp_port_vlan);
 		break;
 	}
 
-- 
2.9.3
