From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 27/42] mlxsw: spectrum: Unsplit the vFID range
Date: Fri,  1 Jul 2016 16:04:55 +0200
Message-ID: <1467381910-3445-28-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33667 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbcGAOUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:20:17 -0400
Received: by mail-wm0-f65.google.com with SMTP id r201so5676119wme.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:20:03 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Previous commit deprecated the vFIDs used to get traffic to the CPU
('port_vfids'). Thus, we now use the vFIDs as god intended and the
artificial split is no longer needed.

Rename functions and variables to reflect that.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 55 +++++++++++++-------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  4 +-
 2 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index bd8448a..e987a8a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2235,7 +2235,7 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 	mlxsw_sp->core = mlxsw_core;
 	mlxsw_sp->bus_info = mlxsw_bus_info;
 	INIT_LIST_HEAD(&mlxsw_sp->fids);
-	INIT_LIST_HEAD(&mlxsw_sp->br_vfids.list);
+	INIT_LIST_HEAD(&mlxsw_sp->vfids.list);
 	INIT_LIST_HEAD(&mlxsw_sp->br_mids.list);
 
 	err = mlxsw_sp_base_mac_get(mlxsw_sp);
@@ -2320,6 +2320,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sp_buffers_fini(mlxsw_sp);
 	mlxsw_sp_traps_fini(mlxsw_sp);
 	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
+	WARN_ON(!list_empty(&mlxsw_sp->vfids.list));
 	WARN_ON(!list_empty(&mlxsw_sp->fids));
 	for (i = 0; i < MLXSW_SP_RIF_MAX; i++)
 		WARN_ON_ONCE(mlxsw_sp->rifs[i]);
@@ -3373,12 +3374,12 @@ static int mlxsw_sp_netdevice_lag_event(struct net_device *lag_dev,
 }
 
 static struct mlxsw_sp_fid *
-mlxsw_sp_br_vfid_find(const struct mlxsw_sp *mlxsw_sp,
-		      const struct net_device *br_dev)
+mlxsw_sp_vfid_find(const struct mlxsw_sp *mlxsw_sp,
+		   const struct net_device *br_dev)
 {
 	struct mlxsw_sp_fid *f;
 
-	list_for_each_entry(f, &mlxsw_sp->br_vfids.list, list) {
+	list_for_each_entry(f, &mlxsw_sp->vfids.list, list) {
 		if (f->dev == br_dev)
 			return f;
 	}
@@ -3386,9 +3387,9 @@ mlxsw_sp_br_vfid_find(const struct mlxsw_sp *mlxsw_sp,
 	return NULL;
 }
 
-static u16 mlxsw_sp_avail_br_vfid_get(const struct mlxsw_sp *mlxsw_sp)
+static u16 mlxsw_sp_avail_vfid_get(const struct mlxsw_sp *mlxsw_sp)
 {
-	return find_first_zero_bit(mlxsw_sp->br_vfids.mapped,
+	return find_first_zero_bit(mlxsw_sp->vfids.mapped,
 				   MLXSW_SP_VFID_MAX);
 }
 
@@ -3400,17 +3401,17 @@ static int mlxsw_sp_vfid_op(struct mlxsw_sp *mlxsw_sp, u16 fid, bool create)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sfmr), sfmr_pl);
 }
 
-static void mlxsw_sp_vport_br_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
+static void mlxsw_sp_vport_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport);
 
-static struct mlxsw_sp_fid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
-						    struct net_device *br_dev)
+static struct mlxsw_sp_fid *mlxsw_sp_vfid_create(struct mlxsw_sp *mlxsw_sp,
+						 struct net_device *br_dev)
 {
 	struct device *dev = mlxsw_sp->bus_info->dev;
 	struct mlxsw_sp_fid *f;
 	u16 vfid, fid;
 	int err;
 
-	vfid = mlxsw_sp_avail_br_vfid_get(mlxsw_sp);
+	vfid = mlxsw_sp_avail_vfid_get(mlxsw_sp);
 	if (vfid == MLXSW_SP_VFID_MAX) {
 		dev_err(dev, "No available vFIDs\n");
 		return ERR_PTR(-ERANGE);
@@ -3427,12 +3428,12 @@ static struct mlxsw_sp_fid *mlxsw_sp_br_vfid_create(struct mlxsw_sp *mlxsw_sp,
 	if (!f)
 		goto err_allocate_vfid;
 
-	f->leave = mlxsw_sp_vport_br_vfid_leave;
+	f->leave = mlxsw_sp_vport_vfid_leave;
 	f->fid = fid;
 	f->dev = br_dev;
 
-	list_add(&f->list, &mlxsw_sp->br_vfids.list);
-	set_bit(vfid, mlxsw_sp->br_vfids.mapped);
+	list_add(&f->list, &mlxsw_sp->vfids.list);
+	set_bit(vfid, mlxsw_sp->vfids.mapped);
 
 	return f;
 
@@ -3441,12 +3442,12 @@ err_allocate_vfid:
 	return ERR_PTR(-ENOMEM);
 }
 
-static void mlxsw_sp_br_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
-				     struct mlxsw_sp_fid *f)
+static void mlxsw_sp_vfid_destroy(struct mlxsw_sp *mlxsw_sp,
+				  struct mlxsw_sp_fid *f)
 {
 	u16 vfid = mlxsw_sp_fid_to_vfid(f->fid);
 
-	clear_bit(vfid, mlxsw_sp->br_vfids.mapped);
+	clear_bit(vfid, mlxsw_sp->vfids.mapped);
 	list_del(&f->list);
 
 	mlxsw_sp_vfid_op(mlxsw_sp, f->fid, false);
@@ -3464,15 +3465,15 @@ static int mlxsw_sp_vport_fid_map(struct mlxsw_sp_port *mlxsw_sp_vport, u16 fid,
 					    vid);
 }
 
-static int mlxsw_sp_vport_br_vfid_join(struct mlxsw_sp_port *mlxsw_sp_vport,
-				       struct net_device *br_dev)
+static int mlxsw_sp_vport_vfid_join(struct mlxsw_sp_port *mlxsw_sp_vport,
+				    struct net_device *br_dev)
 {
 	struct mlxsw_sp_fid *f;
 	int err;
 
-	f = mlxsw_sp_br_vfid_find(mlxsw_sp_vport->mlxsw_sp, br_dev);
+	f = mlxsw_sp_vfid_find(mlxsw_sp_vport->mlxsw_sp, br_dev);
 	if (!f) {
-		f = mlxsw_sp_br_vfid_create(mlxsw_sp_vport->mlxsw_sp, br_dev);
+		f = mlxsw_sp_vfid_create(mlxsw_sp_vport->mlxsw_sp, br_dev);
 		if (IS_ERR(f))
 			return PTR_ERR(f);
 	}
@@ -3496,11 +3497,11 @@ err_vport_fid_map:
 	mlxsw_sp_vport_flood_set(mlxsw_sp_vport, f->fid, false);
 err_vport_flood_set:
 	if (!f->ref_count)
-		mlxsw_sp_br_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
+		mlxsw_sp_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
 	return err;
 }
 
-static void mlxsw_sp_vport_br_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
+static void mlxsw_sp_vport_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 {
 	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
@@ -3514,7 +3515,7 @@ static void mlxsw_sp_vport_br_vfid_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 
 	mlxsw_sp_vport_fid_set(mlxsw_sp_vport, NULL);
 	if (--f->ref_count == 0)
-		mlxsw_sp_br_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
+		mlxsw_sp_vfid_destroy(mlxsw_sp_vport->mlxsw_sp, f);
 }
 
 static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
@@ -3528,7 +3529,7 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	if (f && !WARN_ON(!f->leave))
 		f->leave(mlxsw_sp_vport);
 
-	err = mlxsw_sp_vport_br_vfid_join(mlxsw_sp_vport, br_dev);
+	err = mlxsw_sp_vport_vfid_join(mlxsw_sp_vport, br_dev);
 	if (err) {
 		netdev_err(dev, "Failed to join vFID\n");
 		return err;
@@ -3548,7 +3549,7 @@ static int mlxsw_sp_vport_bridge_join(struct mlxsw_sp_port *mlxsw_sp_vport,
 	return 0;
 
 err_port_vid_learning_set:
-	mlxsw_sp_vport_br_vfid_leave(mlxsw_sp_vport);
+	mlxsw_sp_vport_vfid_leave(mlxsw_sp_vport);
 	return err;
 }
 
@@ -3558,7 +3559,7 @@ static void mlxsw_sp_vport_bridge_leave(struct mlxsw_sp_port *mlxsw_sp_vport)
 
 	mlxsw_sp_port_vid_learning_set(mlxsw_sp_vport, vid, false);
 
-	mlxsw_sp_vport_br_vfid_leave(mlxsw_sp_vport);
+	mlxsw_sp_vport_vfid_leave(mlxsw_sp_vport);
 
 	mlxsw_sp_vport->learning = 0;
 	mlxsw_sp_vport->learning_sync = 0;
@@ -3574,7 +3575,7 @@ mlxsw_sp_port_master_bridge_check(const struct mlxsw_sp_port *mlxsw_sp_port,
 
 	list_for_each_entry(mlxsw_sp_vport, &mlxsw_sp_port->vports_list,
 			    vport.list) {
-		struct net_device *dev = mlxsw_sp_vport_br_get(mlxsw_sp_vport);
+		struct net_device *dev = mlxsw_sp_vport_dev_get(mlxsw_sp_vport);
 
 		if (dev && dev == br_dev)
 			return false;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index b6eeab7..b15b47b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -218,7 +218,7 @@ struct mlxsw_sp {
 	struct {
 		struct list_head list;
 		DECLARE_BITMAP(mapped, MLXSW_SP_VFID_MAX);
-	} br_vfids;
+	} vfids;
 	struct {
 		struct list_head list;
 		DECLARE_BITMAP(mapped, MLXSW_SP_MID_MAX);
@@ -349,7 +349,7 @@ mlxsw_sp_vport_fid_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 }
 
 static inline struct net_device *
-mlxsw_sp_vport_br_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
+mlxsw_sp_vport_dev_get(const struct mlxsw_sp_port *mlxsw_sp_vport)
 {
 	struct mlxsw_sp_fid *f = mlxsw_sp_vport_fid_get(mlxsw_sp_vport);
 
-- 
2.5.5
