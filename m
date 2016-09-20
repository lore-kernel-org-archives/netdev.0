From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 9/9] mlxsw: spectrum: Implement max rif resource
Date: Tue, 20 Sep 2016 11:16:57 +0200
Message-ID: <1474363017-2901-10-git-send-email-jiri@resnulli.us>
References: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33207 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932366AbcITJRL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:17:11 -0400
Received: by mail-wm0-f68.google.com with SMTP id w84so2316985wmg.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:17:11 -0700 (PDT)
In-Reply-To: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Replace max rif const with using the result from resource query.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 13 +++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  9 ++++---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 31 ++++++++++++++++++++--
 3 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 359a9dc..c421b46 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3017,7 +3017,6 @@ err_rx_listener_register:
 static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
-	int i;
 
 	mlxsw_sp_ports_remove(mlxsw_sp);
 	mlxsw_sp_span_fini(mlxsw_sp);
@@ -3029,8 +3028,6 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
 	WARN_ON(!list_empty(&mlxsw_sp->vfids.list));
 	WARN_ON(!list_empty(&mlxsw_sp->fids));
-	for (i = 0; i < MLXSW_SP_RIF_MAX; i++)
-		WARN_ON_ONCE(mlxsw_sp->rifs[i]);
 }
 
 static struct mlxsw_config_profile mlxsw_sp_config_profile = {
@@ -3172,13 +3169,15 @@ static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *r,
 
 static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
 {
+	struct mlxsw_resources *resources;
 	int i;
 
-	for (i = 0; i < MLXSW_SP_RIF_MAX; i++)
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+	for (i = 0; i < resources->max_rif; i++)
 		if (!mlxsw_sp->rifs[i])
 			return i;
 
-	return MLXSW_SP_RIF_MAX;
+	return MLXSW_SP_INVALID_RIF;
 }
 
 static void mlxsw_sp_vport_rif_sp_attr_get(struct mlxsw_sp_port *mlxsw_sp_vport,
@@ -3258,7 +3257,7 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 	int err;
 
 	rif = mlxsw_sp_avail_rif_get(mlxsw_sp);
-	if (rif == MLXSW_SP_RIF_MAX)
+	if (rif == MLXSW_SP_INVALID_RIF)
 		return ERR_PTR(-ERANGE);
 
 	err = mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, l3_dev, rif, true);
@@ -3490,7 +3489,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	int err;
 
 	rif = mlxsw_sp_avail_rif_get(mlxsw_sp);
-	if (rif == MLXSW_SP_RIF_MAX)
+	if (rif == MLXSW_SP_INVALID_RIF)
 		return -ERANGE;
 
 	err = mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, true);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 352079e..73cae21 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -54,7 +54,7 @@
 #define MLXSW_SP_VFID_MAX 6656	/* Bridged VLAN interfaces */
 
 #define MLXSW_SP_RFID_BASE 15360
-#define MLXSW_SP_RIF_MAX 800
+#define MLXSW_SP_INVALID_RIF 0xffff
 
 #define MLXSW_SP_MID_MAX 7000
 
@@ -269,7 +269,7 @@ struct mlxsw_sp {
 		DECLARE_BITMAP(mapped, MLXSW_SP_MID_MAX);
 	} br_mids;
 	struct list_head fids;	/* VLAN-aware bridge FIDs */
-	struct mlxsw_sp_rif *rifs[MLXSW_SP_RIF_MAX];
+	struct mlxsw_sp_rif **rifs;
 	struct mlxsw_sp_port **ports;
 	struct mlxsw_core *core;
 	const struct mlxsw_bus_info *bus_info;
@@ -477,9 +477,12 @@ static inline struct mlxsw_sp_rif *
 mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
 			 const struct net_device *dev)
 {
+	struct mlxsw_resources *resources;
 	int i;
 
-	for (i = 0; i < MLXSW_SP_RIF_MAX; i++)
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+
+	for (i = 0; i < resources->max_rif; i++)
 		if (mlxsw_sp->rifs[i] && mlxsw_sp->rifs[i]->dev == dev)
 			return mlxsw_sp->rifs[i];
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index ded19f0..cc653ac 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1522,19 +1522,46 @@ static void mlxsw_sp_nexthop_group_put(struct mlxsw_sp *mlxsw_sp,
 
 static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
+	struct mlxsw_resources *resources;
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+	int err;
+
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+	if (!resources->max_rif_valid)
+		return -EIO;
+
+	mlxsw_sp->rifs = kcalloc(resources->max_rif,
+				 sizeof(struct mlxsw_sp_rif *), GFP_KERNEL);
+	if (!mlxsw_sp->rifs)
+		return -ENOMEM;
 
 	mlxsw_reg_rgcr_pack(rgcr_pl, true);
-	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, MLXSW_SP_RIF_MAX);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, resources->max_rif);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+	if (err)
+		goto err_rgcr_fail;
+
+	return 0;
+
+err_rgcr_fail:
+	kfree(mlxsw_sp->rifs);
+	return err;
 }
 
 static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 {
+	struct mlxsw_resources *resources;
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+	int i;
 
 	mlxsw_reg_rgcr_pack(rgcr_pl, false);
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+	for (i = 0; i < resources->max_rif; i++)
+		WARN_ON_ONCE(mlxsw_sp->rifs[i]);
+
+	kfree(mlxsw_sp->rifs);
 }
 
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
-- 
2.5.5
