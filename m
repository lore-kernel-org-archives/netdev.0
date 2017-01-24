From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 07/12] net/mlx5: E-Switch, Enlarge the FDB size for the switchdev mode
Date: Tue, 24 Jan 2017 22:16:47 +0200
Message-ID: <20170124201652.2920-8-saeedm@mellanox.com>
References: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54280 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750917AbdAXURZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:25 -0500
In-Reply-To: <20170124201652.2920-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

The E-Switch FDB size was hard coded to 8k. Change it to be

  min(max eswitch table size, max flow counters * num flow groups)

where the max values are read from the firmware and the number of
flow groups is hard-coded as before this change.

We don't know upfront the division of flows to group. This setup allows
each group to be of size up to the where we want to support (we mandate
pairing of flows with counters for offloading). Thus, we don't expect
multiple occurences for a group which in turn adds steering hops.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Tested-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 03293ed1cc22..348182599294 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -402,19 +402,18 @@ static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 }
 
 #define MAX_PF_SQ 256
-#define ESW_OFFLOADS_NUM_ENTRIES (1 << 13) /* 8K */
 #define ESW_OFFLOADS_NUM_GROUPS  4
 
 static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
+	int table_size, ix, esw_size, err = 0;
 	struct mlx5_core_dev *dev = esw->dev;
 	struct mlx5_flow_namespace *root_ns;
 	struct mlx5_flow_table *fdb = NULL;
 	struct mlx5_flow_group *g;
 	u32 *flow_group_in;
 	void *match_criteria;
-	int table_size, ix, err = 0;
 	u32 flags = 0;
 
 	flow_group_in = mlx5_vzalloc(inlen);
@@ -427,15 +426,19 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 		goto ns_err;
 	}
 
-	esw_debug(dev, "Create offloads FDB table, log_max_size(%d)\n",
-		  MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
+	esw_debug(dev, "Create offloads FDB table, min (max esw size(2^%d), max counters(%d)*groups(%d))\n",
+		  MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size),
+		  MLX5_CAP_GEN(dev, max_flow_counter), ESW_OFFLOADS_NUM_GROUPS);
+
+	esw_size = min_t(int, MLX5_CAP_GEN(dev, max_flow_counter) * ESW_OFFLOADS_NUM_GROUPS,
+			 1 << MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
 
 	if (MLX5_CAP_ESW_FLOWTABLE_FDB(dev, encap) &&
 	    MLX5_CAP_ESW_FLOWTABLE_FDB(dev, decap))
 		flags |= MLX5_FLOW_TABLE_TUNNEL_EN;
 
 	fdb = mlx5_create_auto_grouped_flow_table(root_ns, FDB_FAST_PATH,
-						  ESW_OFFLOADS_NUM_ENTRIES,
+						  esw_size,
 						  ESW_OFFLOADS_NUM_GROUPS, 0,
 						  flags);
 	if (IS_ERR(fdb)) {
-- 
2.11.0
