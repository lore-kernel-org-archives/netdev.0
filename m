From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/10] mlxsw: spectrum_dpipe: Add support for controlling nexthop counters
Date: Mon, 25 Sep 2017 10:32:30 +0200
Message-ID: <20170925083230.1193-11-jiri@resnulli.us>
References: <20170925083230.1193-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33890 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934150AbdIYIck (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:32:40 -0400
Received: by mail-wm0-f67.google.com with SMTP id i131so6489916wma.1
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:32:39 -0700 (PDT)
In-Reply-To: <20170925083230.1193-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for controlling nexthop counters via dpipe.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 24 ++++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 12 +++++------
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  6 ++++++
 3 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index e6755a9..a056f23 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -1132,6 +1132,29 @@ mlxsw_sp_dpipe_table_adj_entries_dump(void *priv, bool counters_enabled,
 	return err;
 }
 
+static int mlxsw_sp_dpipe_table_adj_counters_update(void *priv, bool enable)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp_nexthop *nh;
+	u32 adj_hash_index = 0;
+	u32 adj_index = 0;
+
+	mlxsw_sp_nexthop_for_each(nh, mlxsw_sp->router) {
+		if (!mlxsw_sp_nexthop_offload(nh) ||
+		    mlxsw_sp_nexthop_group_has_ipip(nh))
+			continue;
+
+		mlxsw_sp_nexthop_indexes(nh, &adj_index, &adj_hash_index);
+		if (enable)
+			mlxsw_sp_nexthop_counter_alloc(mlxsw_sp, nh);
+		else
+			mlxsw_sp_nexthop_counter_free(mlxsw_sp, nh);
+		mlxsw_sp_nexthop_update(mlxsw_sp,
+					adj_index + adj_hash_index, nh);
+	}
+	return 0;
+}
+
 static u64
 mlxsw_sp_dpipe_table_adj_size_get(void *priv)
 {
@@ -1149,6 +1172,7 @@ static struct devlink_dpipe_table_ops mlxsw_sp_dpipe_table_adj_ops = {
 	.matches_dump = mlxsw_sp_dpipe_table_adj_matches_dump,
 	.actions_dump = mlxsw_sp_dpipe_table_adj_actions_dump,
 	.entries_dump = mlxsw_sp_dpipe_table_adj_entries_dump,
+	.counters_set_update = mlxsw_sp_dpipe_table_adj_counters_update,
 	.size_get = mlxsw_sp_dpipe_table_adj_size_get,
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2400fff..ef4b86b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2085,8 +2085,8 @@ struct mlxsw_sp_nexthop_group {
 #define nh_rif	nexthops[0].rif
 };
 
-static void mlxsw_sp_nexthop_counter_alloc(struct mlxsw_sp *mlxsw_sp,
-					   struct mlxsw_sp_nexthop *nh)
+void mlxsw_sp_nexthop_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+				    struct mlxsw_sp_nexthop *nh)
 {
 	struct devlink *devlink;
 
@@ -2101,8 +2101,8 @@ static void mlxsw_sp_nexthop_counter_alloc(struct mlxsw_sp *mlxsw_sp,
 	nh->counter_valid = true;
 }
 
-static void mlxsw_sp_nexthop_counter_free(struct mlxsw_sp *mlxsw_sp,
-					  struct mlxsw_sp_nexthop *nh)
+void mlxsw_sp_nexthop_counter_free(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_nexthop *nh)
 {
 	if (!nh->counter_valid)
 		return;
@@ -2448,8 +2448,8 @@ static int mlxsw_sp_adj_index_mass_update(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
-static int mlxsw_sp_nexthop_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
-				   struct mlxsw_sp_nexthop *nh)
+int mlxsw_sp_nexthop_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
+			    struct mlxsw_sp_nexthop *nh)
 {
 	struct mlxsw_sp_neigh_entry *neigh_entry = nh->neigh_entry;
 	char ratr_pl[MLXSW_REG_RATR_LEN];
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index a6e8659..3d44918 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -122,5 +122,11 @@ bool mlxsw_sp_nexthop_group_has_ipip(struct mlxsw_sp_nexthop *nh);
 	     nh = mlxsw_sp_nexthop_next(router, nh))
 int mlxsw_sp_nexthop_counter_get(struct mlxsw_sp *mlxsw_sp,
 				 struct mlxsw_sp_nexthop *nh, u64 *p_counter);
+int mlxsw_sp_nexthop_update(struct mlxsw_sp *mlxsw_sp, u32 adj_index,
+			    struct mlxsw_sp_nexthop *nh);
+void mlxsw_sp_nexthop_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+				    struct mlxsw_sp_nexthop *nh);
+void mlxsw_sp_nexthop_counter_free(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_nexthop *nh);
 
 #endif /* _MLXSW_ROUTER_H_*/
-- 
2.9.5
