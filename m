From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/8] mlxsw: spectrum_dpipe: Add adjacency group size
Date: Sun, 22 Oct 2017 23:11:43 +0200
Message-ID: <20171022211150.2567-2-jiri@resnulli.us>
References: <20171022211150.2567-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:54960 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932110AbdJVVLx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 17:11:53 -0400
Received: by mail-wm0-f67.google.com with SMTP id r68so6367919wmr.3
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 14:11:53 -0700 (PDT)
In-Reply-To: <20171022211150.2567-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The adjacency group size is part of the match on the adjacency group and
should therefore be exposed using dpipe.

When non-equal-cost multi-path support will be introduced, the group's
size will help users understand the exact number of adjacency entries
each nexthop occupies, as a nexthop will no longer correspond to a
single entry.

The output for a multi-path route with two nexthops, one with weight 255
and the second 1 will be:

Example:

$ devlink dpipe table dump pci/0000:01:00.0 name mlxsw_adj
pci/0000:01:00.0:
  index 0
  match_value:
    type field_exact header mlxsw_meta field adj_index value 65536
    type field_exact header mlxsw_meta field adj_size value 512
    type field_exact header mlxsw_meta field adj_hash_index value 0
  action_value:
    type field_modify header ethernet field destination mac value e4:1d:2d:a5:f3:64
    type field_modify header mlxsw_meta field erif_port mapping ifindex mapping_value 3 value 1

  index 1
  match_value:
    type field_exact header mlxsw_meta field adj_index value 65536
    type field_exact header mlxsw_meta field adj_size value 512
    type field_exact header mlxsw_meta field adj_hash_index value 510
  action_value:
    type field_modify header ethernet field destination mac value e4:1d:2d:a5:f3:65
    type field_modify header mlxsw_meta field erif_port mapping ifindex mapping_value 4 value 2

Thus, the first nexthop occupies 510 adjacency entries and the second 2,
which leads to a ratio of 255 to 1.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_dpipe.c   | 46 +++++++++++++++++++---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  3 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  2 +-
 3 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index a056f23..6ea6435 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -44,6 +44,7 @@ enum mlxsw_sp_field_metadata_id {
 	MLXSW_SP_DPIPE_FIELD_METADATA_L3_FORWARD,
 	MLXSW_SP_DPIPE_FIELD_METADATA_L3_DROP,
 	MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_INDEX,
+	MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_SIZE,
 	MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_HASH_INDEX,
 };
 
@@ -70,6 +71,11 @@ static struct devlink_dpipe_field mlxsw_sp_dpipe_fields_metadata[] = {
 		.bitwidth = 32,
 	},
 	{
+		.name = "adj_size",
+		.id = MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_SIZE,
+		.bitwidth = 32,
+	},
+	{
 		.name = "adj_hash_index",
 		.id = MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_HASH_INDEX,
 		.bitwidth = 32,
@@ -857,6 +863,14 @@ static int mlxsw_sp_dpipe_table_adj_matches_dump(void *priv,
 
 	match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
 	match.header = &mlxsw_sp_dpipe_header_metadata;
+	match.field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_SIZE;
+
+	err = devlink_dpipe_match_put(skb, &match);
+	if (err)
+		return err;
+
+	match.type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+	match.header = &mlxsw_sp_dpipe_header_metadata;
 	match.field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_HASH_INDEX;
 
 	return devlink_dpipe_match_put(skb, &match);
@@ -897,6 +911,7 @@ static u64 mlxsw_sp_dpipe_table_adj_size(struct mlxsw_sp *mlxsw_sp)
 
 enum mlxsw_sp_dpipe_table_adj_match {
 	MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_INDEX,
+	MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_SIZE,
 	MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_HASH_INDEX,
 	MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_COUNT,
 };
@@ -919,6 +934,11 @@ mlxsw_sp_dpipe_table_adj_match_action_prepare(struct devlink_dpipe_match *matche
 	match->header = &mlxsw_sp_dpipe_header_metadata;
 	match->field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_INDEX;
 
+	match = &matches[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_SIZE];
+	match->type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
+	match->header = &mlxsw_sp_dpipe_header_metadata;
+	match->field_id = MLXSW_SP_DPIPE_FIELD_METADATA_ADJ_SIZE;
+
 	match = &matches[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_HASH_INDEX];
 	match->type = DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT;
 	match->header = &mlxsw_sp_dpipe_header_metadata;
@@ -961,6 +981,15 @@ mlxsw_sp_dpipe_table_adj_entry_prepare(struct devlink_dpipe_entry *entry,
 	if (!match_value->value)
 		return -ENOMEM;
 
+	match = &matches[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_SIZE];
+	match_value = &match_values[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_SIZE];
+
+	match_value->match = match;
+	match_value->value_size = sizeof(u32);
+	match_value->value = kmalloc(match_value->value_size, GFP_KERNEL);
+	if (!match_value->value)
+		return -ENOMEM;
+
 	match = &matches[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_HASH_INDEX];
 	match_value = &match_values[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_HASH_INDEX];
 
@@ -993,8 +1022,8 @@ mlxsw_sp_dpipe_table_adj_entry_prepare(struct devlink_dpipe_entry *entry,
 
 static void
 __mlxsw_sp_dpipe_table_adj_entry_fill(struct devlink_dpipe_entry *entry,
-				      u32 adj_index, u32 adj_hash_index,
-				      unsigned char *ha,
+				      u32 adj_index, u32 adj_size,
+				      u32 adj_hash_index, unsigned char *ha,
 				      struct mlxsw_sp_rif *rif)
 {
 	struct devlink_dpipe_value *value;
@@ -1005,6 +1034,10 @@ __mlxsw_sp_dpipe_table_adj_entry_fill(struct devlink_dpipe_entry *entry,
 	p_index = value->value;
 	*p_index = adj_index;
 
+	value = &entry->match_values[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_SIZE];
+	p_index = value->value;
+	*p_index = adj_size;
+
 	value = &entry->match_values[MLXSW_SP_DPIPE_TABLE_ADJ_MATCH_HASH_INDEX];
 	p_index = value->value;
 	*p_index = adj_hash_index;
@@ -1027,10 +1060,11 @@ static void mlxsw_sp_dpipe_table_adj_entry_fill(struct mlxsw_sp *mlxsw_sp,
 	unsigned char *ha = mlxsw_sp_nexthop_ha(nh);
 	u32 adj_hash_index = 0;
 	u32 adj_index = 0;
+	u32 adj_size = 0;
 	int err;
 
-	mlxsw_sp_nexthop_indexes(nh, &adj_index, &adj_hash_index);
-	__mlxsw_sp_dpipe_table_adj_entry_fill(entry, adj_index,
+	mlxsw_sp_nexthop_indexes(nh, &adj_index, &adj_size, &adj_hash_index);
+	__mlxsw_sp_dpipe_table_adj_entry_fill(entry, adj_index, adj_size,
 					      adj_hash_index, ha, rif);
 	err = mlxsw_sp_nexthop_counter_get(mlxsw_sp, nh, &entry->counter);
 	if (!err)
@@ -1138,13 +1172,15 @@ static int mlxsw_sp_dpipe_table_adj_counters_update(void *priv, bool enable)
 	struct mlxsw_sp_nexthop *nh;
 	u32 adj_hash_index = 0;
 	u32 adj_index = 0;
+	u32 adj_size = 0;
 
 	mlxsw_sp_nexthop_for_each(nh, mlxsw_sp->router) {
 		if (!mlxsw_sp_nexthop_offload(nh) ||
 		    mlxsw_sp_nexthop_group_has_ipip(nh))
 			continue;
 
-		mlxsw_sp_nexthop_indexes(nh, &adj_index, &adj_hash_index);
+		mlxsw_sp_nexthop_indexes(nh, &adj_index, &adj_size,
+					 &adj_hash_index);
 		if (enable)
 			mlxsw_sp_nexthop_counter_alloc(mlxsw_sp, nh);
 		else
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 5f2d100..cb0d25e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2299,7 +2299,7 @@ unsigned char *mlxsw_sp_nexthop_ha(struct mlxsw_sp_nexthop *nh)
 }
 
 int mlxsw_sp_nexthop_indexes(struct mlxsw_sp_nexthop *nh, u32 *p_adj_index,
-			     u32 *p_adj_hash_index)
+			     u32 *p_adj_size, u32 *p_adj_hash_index)
 {
 	struct mlxsw_sp_nexthop_group *nh_grp = nh->nh_grp;
 	u32 adj_hash_index = 0;
@@ -2309,6 +2309,7 @@ int mlxsw_sp_nexthop_indexes(struct mlxsw_sp_nexthop *nh, u32 *p_adj_index,
 		return -EINVAL;
 
 	*p_adj_index = nh_grp->adj_index;
+	*p_adj_size = nh_grp->ecmp_size;
 
 	for (i = 0; i < nh_grp->count; i++) {
 		struct mlxsw_sp_nexthop *nh_iter = &nh_grp->nexthops[i];
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
index 3f2d840..39e5811 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -115,7 +115,7 @@ struct mlxsw_sp_nexthop *mlxsw_sp_nexthop_next(struct mlxsw_sp_router *router,
 bool mlxsw_sp_nexthop_offload(struct mlxsw_sp_nexthop *nh);
 unsigned char *mlxsw_sp_nexthop_ha(struct mlxsw_sp_nexthop *nh);
 int mlxsw_sp_nexthop_indexes(struct mlxsw_sp_nexthop *nh, u32 *p_adj_index,
-			     u32 *p_adj_hash_index);
+			     u32 *p_adj_size, u32 *p_adj_hash_index);
 struct mlxsw_sp_rif *mlxsw_sp_nexthop_rif(struct mlxsw_sp_nexthop *nh);
 bool mlxsw_sp_nexthop_group_has_ipip(struct mlxsw_sp_nexthop *nh);
 #define mlxsw_sp_nexthop_for_each(nh, router)				\
-- 
2.9.5
