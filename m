From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/9] mlxsw: spectrum: Implement max virtual routers resource
Date: Tue, 20 Sep 2016 11:16:54 +0200
Message-ID: <1474363017-2901-7-git-send-email-jiri@resnulli.us>
References: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35643 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754275AbcITJRI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:17:08 -0400
Received: by mail-wm0-f66.google.com with SMTP id 133so2307468wmq.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:17:07 -0700 (PDT)
In-Reply-To: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Replace max virtual routers const with the result from
the resource query.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 43 +++++++++++++++++++---
 2 files changed, 38 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 208dfee..352079e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -64,8 +64,6 @@
 #define MLXSW_SP_LPM_TREE_MAX 22
 #define MLXSW_SP_LPM_TREE_COUNT (MLXSW_SP_LPM_TREE_MAX - MLXSW_SP_LPM_TREE_MIN)
 
-#define MLXSW_SP_VIRTUAL_ROUTER_MAX 256
-
 #define MLXSW_SP_PORT_BASE_SPEED 25000	/* Mb/s */
 
 #define MLXSW_SP_BYTES_PER_CELL 96
@@ -249,7 +247,7 @@ struct mlxsw_sp_port_mall_tc_entry {
 
 struct mlxsw_sp_router {
 	struct mlxsw_sp_lpm_tree lpm_trees[MLXSW_SP_LPM_TREE_COUNT];
-	struct mlxsw_sp_vr vrs[MLXSW_SP_VIRTUAL_ROUTER_MAX];
+	struct mlxsw_sp_vr *vrs;
 	struct rhashtable neigh_ht;
 	struct {
 		struct delayed_work dw;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 4afb498..ded19f0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -372,10 +372,12 @@ static void mlxsw_sp_lpm_init(struct mlxsw_sp *mlxsw_sp)
 
 static struct mlxsw_sp_vr *mlxsw_sp_vr_find_unused(struct mlxsw_sp *mlxsw_sp)
 {
+	struct mlxsw_resources *resources;
 	struct mlxsw_sp_vr *vr;
 	int i;
 
-	for (i = 0; i < MLXSW_SP_VIRTUAL_ROUTER_MAX; i++) {
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+	for (i = 0; i < resources->max_virtual_routers; i++) {
 		vr = &mlxsw_sp->router.vrs[i];
 		if (!vr->used)
 			return vr;
@@ -417,11 +419,14 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_find(struct mlxsw_sp *mlxsw_sp,
 					    u32 tb_id,
 					    enum mlxsw_sp_l3proto proto)
 {
+	struct mlxsw_resources *resources;
 	struct mlxsw_sp_vr *vr;
 	int i;
 
 	tb_id = mlxsw_sp_fix_tb_id(tb_id);
-	for (i = 0; i < MLXSW_SP_VIRTUAL_ROUTER_MAX; i++) {
+
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+	for (i = 0; i < resources->max_virtual_routers; i++) {
 		vr = &mlxsw_sp->router.vrs[i];
 		if (vr->used && vr->proto == proto && vr->tb_id == tb_id)
 			return vr;
@@ -555,15 +560,33 @@ static void mlxsw_sp_vr_put(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr)
 					   &vr->fib->prefix_usage);
 }
 
-static void mlxsw_sp_vrs_init(struct mlxsw_sp *mlxsw_sp)
+static int mlxsw_sp_vrs_init(struct mlxsw_sp *mlxsw_sp)
 {
+	struct mlxsw_resources *resources;
 	struct mlxsw_sp_vr *vr;
 	int i;
 
-	for (i = 0; i < MLXSW_SP_VIRTUAL_ROUTER_MAX; i++) {
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+	if (!resources->max_virtual_routers_valid)
+		return -EIO;
+
+	mlxsw_sp->router.vrs = kcalloc(resources->max_virtual_routers,
+				       sizeof(struct mlxsw_sp_vr),
+				       GFP_KERNEL);
+	if (!mlxsw_sp->router.vrs)
+		return -ENOMEM;
+
+	for (i = 0; i < resources->max_virtual_routers; i++) {
 		vr = &mlxsw_sp->router.vrs[i];
 		vr->id = i;
 	}
+
+	return 0;
+}
+
+static void mlxsw_sp_vrs_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	kfree(mlxsw_sp->router.vrs);
 }
 
 struct mlxsw_sp_neigh_key {
@@ -1523,14 +1546,21 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	err = __mlxsw_sp_router_init(mlxsw_sp);
 	if (err)
 		return err;
+
 	mlxsw_sp_lpm_init(mlxsw_sp);
-	mlxsw_sp_vrs_init(mlxsw_sp);
-	err = mlxsw_sp_neigh_init(mlxsw_sp);
+	err = mlxsw_sp_vrs_init(mlxsw_sp);
+	if (err)
+		goto err_vrs_init;
+
+	err =  mlxsw_sp_neigh_init(mlxsw_sp);
 	if (err)
 		goto err_neigh_init;
+
 	return 0;
 
 err_neigh_init:
+	mlxsw_sp_vrs_fini(mlxsw_sp);
+err_vrs_init:
 	__mlxsw_sp_router_fini(mlxsw_sp);
 	return err;
 }
@@ -1538,6 +1568,7 @@ err_neigh_init:
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 {
 	mlxsw_sp_neigh_fini(mlxsw_sp);
+	mlxsw_sp_vrs_fini(mlxsw_sp);
 	__mlxsw_sp_router_fini(mlxsw_sp);
 }
 
-- 
2.5.5
