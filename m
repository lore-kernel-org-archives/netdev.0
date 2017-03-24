From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] mlxsw: spectrum_router: Query number of LPM trees from firmware
Date: Fri, 24 Mar 2017 08:02:47 +0100
Message-ID: <1490338971-2687-2-git-send-email-jiri@resnulli.us>
References: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36196 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-FAIL-OK-OK)
        by vger.kernel.org with ESMTP id S1755966AbdCXHDr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 03:03:47 -0400
Received: by mail-wr0-f195.google.com with SMTP id u1so716597wra.3
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 00:03:46 -0700 (PDT)
In-Reply-To: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Instead of hard coding the number of LPM trees in the driver, query it
from the firmware, as it may change in future devices.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/resources.h    |  2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  9 ++---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 43 ++++++++++++++++++----
 3 files changed, 41 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/resources.h b/drivers/net/ethernet/mellanox/mlxsw/resources.h
index 905a8e2..41553a7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/resources.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/resources.h
@@ -61,6 +61,7 @@ enum mlxsw_res_id {
 	MLXSW_RES_ID_MAX_CPU_POLICERS,
 	MLXSW_RES_ID_MAX_VRS,
 	MLXSW_RES_ID_MAX_RIFS,
+	MLXSW_RES_ID_MAX_LPM_TREES,
 
 	/* Internal resources.
 	 * Determined by the SW, not queried from the HW.
@@ -95,6 +96,7 @@ static u16 mlxsw_res_ids[] = {
 	[MLXSW_RES_ID_MAX_CPU_POLICERS] = 0x2A13,
 	[MLXSW_RES_ID_MAX_VRS] = 0x2C01,
 	[MLXSW_RES_ID_MAX_RIFS] = 0x2C02,
+	[MLXSW_RES_ID_MAX_LPM_TREES] = 0x2C30,
 };
 
 struct mlxsw_res {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index bffd9e6..b1713a4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -63,10 +63,6 @@
 
 #define MLXSW_SP_PORTS_PER_CLUSTER_MAX 4
 
-#define MLXSW_SP_LPM_TREE_MIN 2 /* trees 0 and 1 are reserved */
-#define MLXSW_SP_LPM_TREE_MAX 22
-#define MLXSW_SP_LPM_TREE_COUNT (MLXSW_SP_LPM_TREE_MAX - MLXSW_SP_LPM_TREE_MIN)
-
 #define MLXSW_SP_PORT_BASE_SPEED 25000	/* Mb/s */
 
 #define MLXSW_SP_BYTES_PER_CELL 96
@@ -230,12 +226,15 @@ struct mlxsw_sp_port_mall_tc_entry {
 };
 
 struct mlxsw_sp_router {
-	struct mlxsw_sp_lpm_tree lpm_trees[MLXSW_SP_LPM_TREE_COUNT];
 	struct mlxsw_sp_vr *vrs;
 	struct rhashtable neigh_ht;
 	struct rhashtable nexthop_group_ht;
 	struct rhashtable nexthop_ht;
 	struct {
+		struct mlxsw_sp_lpm_tree *trees;
+		unsigned int tree_count;
+	} lpm;
+	struct {
 		struct delayed_work dw;
 		unsigned long interval;	/* ms */
 	} neighs_update;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index fe4a55e..2c666f9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -206,8 +206,8 @@ mlxsw_sp_lpm_tree_find_unused(struct mlxsw_sp *mlxsw_sp)
 	static struct mlxsw_sp_lpm_tree *lpm_tree;
 	int i;
 
-	for (i = 0; i < MLXSW_SP_LPM_TREE_COUNT; i++) {
-		lpm_tree = &mlxsw_sp->router.lpm_trees[i];
+	for (i = 0; i < mlxsw_sp->router.lpm.tree_count; i++) {
+		lpm_tree = &mlxsw_sp->router.lpm.trees[i];
 		if (lpm_tree->ref_count == 0)
 			return lpm_tree;
 	}
@@ -303,8 +303,8 @@ mlxsw_sp_lpm_tree_get(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_lpm_tree *lpm_tree;
 	int i;
 
-	for (i = 0; i < MLXSW_SP_LPM_TREE_COUNT; i++) {
-		lpm_tree = &mlxsw_sp->router.lpm_trees[i];
+	for (i = 0; i < mlxsw_sp->router.lpm.tree_count; i++) {
+		lpm_tree = &mlxsw_sp->router.lpm.trees[i];
 		if (lpm_tree->ref_count != 0 &&
 		    lpm_tree->proto == proto &&
 		    mlxsw_sp_prefix_usage_eq(&lpm_tree->prefix_usage,
@@ -329,15 +329,36 @@ static int mlxsw_sp_lpm_tree_put(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
-static void mlxsw_sp_lpm_init(struct mlxsw_sp *mlxsw_sp)
+#define MLXSW_SP_LPM_TREE_MIN 2 /* trees 0 and 1 are reserved */
+
+static int mlxsw_sp_lpm_init(struct mlxsw_sp *mlxsw_sp)
 {
 	struct mlxsw_sp_lpm_tree *lpm_tree;
+	u64 max_trees;
 	int i;
 
-	for (i = 0; i < MLXSW_SP_LPM_TREE_COUNT; i++) {
-		lpm_tree = &mlxsw_sp->router.lpm_trees[i];
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_LPM_TREES))
+		return -EIO;
+
+	max_trees = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_LPM_TREES);
+	mlxsw_sp->router.lpm.tree_count = max_trees - MLXSW_SP_LPM_TREE_MIN;
+	mlxsw_sp->router.lpm.trees = kcalloc(mlxsw_sp->router.lpm.tree_count,
+					     sizeof(struct mlxsw_sp_lpm_tree),
+					     GFP_KERNEL);
+	if (!mlxsw_sp->router.lpm.trees)
+		return -ENOMEM;
+
+	for (i = 0; i < mlxsw_sp->router.lpm.tree_count; i++) {
+		lpm_tree = &mlxsw_sp->router.lpm.trees[i];
 		lpm_tree->id = i + MLXSW_SP_LPM_TREE_MIN;
 	}
+
+	return 0;
+}
+
+static void mlxsw_sp_lpm_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	kfree(mlxsw_sp->router.lpm.trees);
 }
 
 static bool mlxsw_sp_vr_is_used(const struct mlxsw_sp_vr *vr)
@@ -3372,7 +3393,10 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		goto err_nexthop_group_ht_init;
 
-	mlxsw_sp_lpm_init(mlxsw_sp);
+	err = mlxsw_sp_lpm_init(mlxsw_sp);
+	if (err)
+		goto err_lpm_init;
+
 	err = mlxsw_sp_vrs_init(mlxsw_sp);
 	if (err)
 		goto err_vrs_init;
@@ -3394,6 +3418,8 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 err_neigh_init:
 	mlxsw_sp_vrs_fini(mlxsw_sp);
 err_vrs_init:
+	mlxsw_sp_lpm_fini(mlxsw_sp);
+err_lpm_init:
 	rhashtable_destroy(&mlxsw_sp->router.nexthop_group_ht);
 err_nexthop_group_ht_init:
 	rhashtable_destroy(&mlxsw_sp->router.nexthop_ht);
@@ -3407,6 +3433,7 @@ void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	unregister_fib_notifier(&mlxsw_sp->fib_nb);
 	mlxsw_sp_neigh_fini(mlxsw_sp);
 	mlxsw_sp_vrs_fini(mlxsw_sp);
+	mlxsw_sp_lpm_fini(mlxsw_sp);
 	rhashtable_destroy(&mlxsw_sp->router.nexthop_group_ht);
 	rhashtable_destroy(&mlxsw_sp->router.nexthop_ht);
 	__mlxsw_sp_router_fini(mlxsw_sp);
-- 
2.7.4
