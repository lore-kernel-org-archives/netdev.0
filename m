From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 8/8] net/mlx5: Increase the maximum flow counters supported
Date: Mon,  7 Aug 2017 13:18:08 +0300
Message-ID: <20170807101808.22924-9-saeedm@mellanox.com>
References: <20170807101808.22924-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Rabie Loulou <rabiel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170807101808.22924-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Rabie Loulou <rabiel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Read new NIC capability field which represnts 16 MSBs of the max flow
counters number supported (max_flow_counter_31_16).

Backward compatibility with older firmware is preserved, the modified
driver reads max_flow_counter_31_16 as 0 from the older firmware and
uses up to 64K counters.

Changed flow counter id from 16 bits to 32 bits. Backward compatibility
with older firmware is preserved as we kept the 16 LSBs of the counter
id in place and added 16 MSBs from reserved field.

Changed the background bulk reading of flow counters to work in chunks
of at most 32K counters, to make sure we don't attempt to allocate very
large buffers.

Signed-off-by: Rabie Loulou <rabiel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 .../net/ethernet/mellanox/mlx5/core/eswitch_offloads.c   |  6 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c         | 12 ++++++------
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h         | 10 +++++-----
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h        |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c    | 13 ++++++++++---
 include/linux/mlx5/mlx5_ifc.h                            | 16 ++++++----------
 6 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 95b64025ce36..e7c186b58579 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -433,6 +433,8 @@ static int esw_create_offloads_fast_fdb_table(struct mlx5_eswitch *esw)
 	struct mlx5_flow_table *fdb = NULL;
 	int esw_size, err = 0;
 	u32 flags = 0;
+	u32 max_flow_counter = (MLX5_CAP_GEN(dev, max_flow_counter_31_16) << 16) |
+				MLX5_CAP_GEN(dev, max_flow_counter_15_0);
 
 	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_FDB);
 	if (!root_ns) {
@@ -443,9 +445,9 @@ static int esw_create_offloads_fast_fdb_table(struct mlx5_eswitch *esw)
 
 	esw_debug(dev, "Create offloads FDB table, min (max esw size(2^%d), max counters(%d)*groups(%d))\n",
 		  MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size),
-		  MLX5_CAP_GEN(dev, max_flow_counter), ESW_OFFLOADS_NUM_GROUPS);
+		  max_flow_counter, ESW_OFFLOADS_NUM_GROUPS);
 
-	esw_size = min_t(int, MLX5_CAP_GEN(dev, max_flow_counter) * ESW_OFFLOADS_NUM_GROUPS,
+	esw_size = min_t(int, max_flow_counter * ESW_OFFLOADS_NUM_GROUPS,
 			 1 << MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
 
 	if (esw->offloads.encap != DEVLINK_ESWITCH_ENCAP_MODE_NONE)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index e750f07793b8..16b32f31d691 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -359,7 +359,7 @@ int mlx5_cmd_delete_fte(struct mlx5_core_dev *dev,
 	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
 }
 
-int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u16 *id)
+int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u32 *id)
 {
 	u32 in[MLX5_ST_SZ_DW(alloc_flow_counter_in)]   = {0};
 	u32 out[MLX5_ST_SZ_DW(alloc_flow_counter_out)] = {0};
@@ -374,7 +374,7 @@ int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u16 *id)
 	return err;
 }
 
-int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u16 id)
+int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u32 id)
 {
 	u32 in[MLX5_ST_SZ_DW(dealloc_flow_counter_in)]   = {0};
 	u32 out[MLX5_ST_SZ_DW(dealloc_flow_counter_out)] = {0};
@@ -385,7 +385,7 @@ int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u16 id)
 	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
 }
 
-int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u16 id,
+int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u32 id,
 		      u64 *packets, u64 *bytes)
 {
 	u32 out[MLX5_ST_SZ_BYTES(query_flow_counter_out) +
@@ -409,14 +409,14 @@ int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u16 id,
 }
 
 struct mlx5_cmd_fc_bulk {
-	u16 id;
+	u32 id;
 	int num;
 	int outlen;
 	u32 out[0];
 };
 
 struct mlx5_cmd_fc_bulk *
-mlx5_cmd_fc_bulk_alloc(struct mlx5_core_dev *dev, u16 id, int num)
+mlx5_cmd_fc_bulk_alloc(struct mlx5_core_dev *dev, u32 id, int num)
 {
 	struct mlx5_cmd_fc_bulk *b;
 	int outlen =
@@ -453,7 +453,7 @@ mlx5_cmd_fc_bulk_query(struct mlx5_core_dev *dev, struct mlx5_cmd_fc_bulk *b)
 }
 
 void mlx5_cmd_fc_bulk_get(struct mlx5_core_dev *dev,
-			  struct mlx5_cmd_fc_bulk *b, u16 id,
+			  struct mlx5_cmd_fc_bulk *b, u32 id,
 			  u64 *packets, u64 *bytes)
 {
 	int index = id - b->id;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index 0f98a7cf4877..c6d7bdf255b6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -74,20 +74,20 @@ int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 			    struct mlx5_flow_table *ft,
 			    u32 underlay_qpn);
 
-int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u16 *id);
-int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u16 id);
-int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u16 id,
+int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u32 *id);
+int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u32 id);
+int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u32 id,
 		      u64 *packets, u64 *bytes);
 
 struct mlx5_cmd_fc_bulk;
 
 struct mlx5_cmd_fc_bulk *
-mlx5_cmd_fc_bulk_alloc(struct mlx5_core_dev *dev, u16 id, int num);
+mlx5_cmd_fc_bulk_alloc(struct mlx5_core_dev *dev, u32 id, int num);
 void mlx5_cmd_fc_bulk_free(struct mlx5_cmd_fc_bulk *b);
 int
 mlx5_cmd_fc_bulk_query(struct mlx5_core_dev *dev, struct mlx5_cmd_fc_bulk *b);
 void mlx5_cmd_fc_bulk_get(struct mlx5_core_dev *dev,
-			  struct mlx5_cmd_fc_bulk *b, u16 id,
+			  struct mlx5_cmd_fc_bulk *b, u32 id,
 			  u64 *packets, u64 *bytes);
 
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 990acee6fb09..9fb5a333df52 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -136,7 +136,7 @@ struct mlx5_fc {
 	u64 lastpackets;
 	u64 lastbytes;
 
-	u16 id;
+	u32 id;
 	bool deleted;
 	bool aging;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
index 6507d8acc54d..89d1f8650033 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
@@ -38,6 +38,8 @@
 #include "fs_cmd.h"
 
 #define MLX5_FC_STATS_PERIOD msecs_to_jiffies(1000)
+/* Max number of counters to query in bulk read is 32K */
+#define MLX5_SW_MAX_COUNTERS_BULK BIT(15)
 
 /* locking scheme:
  *
@@ -90,16 +92,21 @@ static void mlx5_fc_stats_insert(struct rb_root *root, struct mlx5_fc *counter)
 	rb_insert_color(&counter->node, root);
 }
 
+/* The function returns the last node that was queried so the caller
+ * function can continue calling it till all counters are queried.
+ */
 static struct rb_node *mlx5_fc_stats_query(struct mlx5_core_dev *dev,
 					   struct mlx5_fc *first,
-					   u16 last_id)
+					   u32 last_id)
 {
 	struct mlx5_cmd_fc_bulk *b;
 	struct rb_node *node = NULL;
-	u16 afirst_id;
+	u32 afirst_id;
 	int num;
 	int err;
-	int max_bulk = 1 << MLX5_CAP_GEN(dev, log_max_flow_counter_bulk);
+
+	int max_bulk = min_t(int, MLX5_SW_MAX_COUNTERS_BULK,
+			     (1 << MLX5_CAP_GEN(dev, log_max_flow_counter_bulk)));
 
 	/* first id must be aligned to 4 when using bulk query */
 	afirst_id = first->id & ~0x3;
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index f847a3a57913..c99daffc3c3c 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -963,7 +963,7 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         reserved_at_2a0[0x10];
 	u8         max_wqe_sz_rq[0x10];
 
-	u8         reserved_at_2c0[0x10];
+	u8         max_flow_counter_31_16[0x10];
 	u8         max_wqe_sz_sq_dc[0x10];
 
 	u8         reserved_at_2e0[0x7];
@@ -981,7 +981,7 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 
 	u8         reserved_at_340[0x8];
 	u8         log_max_flow_counter_bulk[0x8];
-	u8         max_flow_counter[0x10];
+	u8         max_flow_counter_15_0[0x10];
 
 
 	u8         reserved_at_360[0x3];
@@ -1071,8 +1071,7 @@ struct mlx5_ifc_dest_format_struct_bits {
 };
 
 struct mlx5_ifc_flow_counter_list_bits {
-	u8         reserved_at_0[0x10];
-	u8         flow_counter_id[0x10];
+	u8         flow_counter_id[0x20];
 
 	u8         reserved_at_20[0x20];
 };
@@ -4402,8 +4401,7 @@ struct mlx5_ifc_query_flow_counter_in_bits {
 	u8         reserved_at_c1[0xf];
 	u8         num_of_counters[0x10];
 
-	u8         reserved_at_e0[0x10];
-	u8         flow_counter_id[0x10];
+	u8         flow_counter_id[0x20];
 };
 
 struct mlx5_ifc_query_esw_vport_context_out_bits {
@@ -6271,8 +6269,7 @@ struct mlx5_ifc_dealloc_flow_counter_in_bits {
 	u8         reserved_at_20[0x10];
 	u8         op_mod[0x10];
 
-	u8         reserved_at_40[0x10];
-	u8         flow_counter_id[0x10];
+	u8         flow_counter_id[0x20];
 
 	u8         reserved_at_60[0x20];
 };
@@ -7097,8 +7094,7 @@ struct mlx5_ifc_alloc_flow_counter_out_bits {
 
 	u8         syndrome[0x20];
 
-	u8         reserved_at_40[0x10];
-	u8         flow_counter_id[0x10];
+	u8         flow_counter_id[0x20];
 
 	u8         reserved_at_60[0x20];
 };
-- 
2.13.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
