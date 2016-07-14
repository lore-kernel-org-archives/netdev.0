From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 02/10] net/mlx5: Introduce bulk reading of flow counters
Date: Thu, 14 Jul 2016 10:32:38 +0300
Message-ID: <1468481566-29859-3-git-send-email-saeedm@mellanox.com>
References: <1468481566-29859-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43300 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750739AbcGNHdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 03:33:08 -0400
In-Reply-To: <1468481566-29859-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>

This commit utilize the ability of ConnectX-4 to bulk read flow counters.
Few bulk counter queries could be done instead of issuing thousands of
firmware commands per second to get statistics of all flows set to HW,
such as those programmed when we offload tc filters.

Counters are stored sorted by hardware id, and queried in blocks (id +
number of counters).

Due to hardware requirement, start of block and number of counters in a
block must be four aligned.

Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   | 67 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   | 12 ++++
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  | 83 ++++++++++++++++------
 include/linux/mlx5/mlx5_ifc.h                      |  8 ++-
 4 files changed, 146 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index a5bb6b6..9134010 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -413,3 +413,70 @@ int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u16 id,
 
 	return 0;
 }
+
+struct mlx5_cmd_fc_bulk {
+	u16 id;
+	int num;
+	int outlen;
+	u32 out[0];
+};
+
+struct mlx5_cmd_fc_bulk *
+mlx5_cmd_fc_bulk_alloc(struct mlx5_core_dev *dev, u16 id, int num)
+{
+	struct mlx5_cmd_fc_bulk *b;
+	int outlen = sizeof(*b) +
+		MLX5_ST_SZ_BYTES(query_flow_counter_out) +
+		MLX5_ST_SZ_BYTES(traffic_counter) * num;
+
+	b = kzalloc(outlen, GFP_KERNEL);
+	if (!b)
+		return NULL;
+
+	b->id = id;
+	b->num = num;
+	b->outlen = outlen;
+
+	return b;
+}
+
+void mlx5_cmd_fc_bulk_free(struct mlx5_cmd_fc_bulk *b)
+{
+	kfree(b);
+}
+
+int
+mlx5_cmd_fc_bulk_query(struct mlx5_core_dev *dev, struct mlx5_cmd_fc_bulk *b)
+{
+	u32 in[MLX5_ST_SZ_DW(query_flow_counter_in)];
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(query_flow_counter_in, in, opcode,
+		 MLX5_CMD_OP_QUERY_FLOW_COUNTER);
+	MLX5_SET(query_flow_counter_in, in, op_mod, 0);
+	MLX5_SET(query_flow_counter_in, in, flow_counter_id, b->id);
+	MLX5_SET(query_flow_counter_in, in, num_of_counters, b->num);
+
+	return mlx5_cmd_exec_check_status(dev, in, sizeof(in),
+					  b->out, b->outlen);
+}
+
+void mlx5_cmd_fc_bulk_get(struct mlx5_core_dev *dev,
+			  struct mlx5_cmd_fc_bulk *b, u16 id,
+			  u64 *packets, u64 *bytes)
+{
+	int index = id - b->id;
+	void *stats;
+
+	if (index < 0 || index >= b->num) {
+		mlx5_core_warn(dev, "Flow counter id (0x%x) out of range (0x%x..0x%x). Counter ignored.\n",
+			       id, b->id, b->id + b->num - 1);
+		return;
+	}
+
+	stats = MLX5_ADDR_OF(query_flow_counter_out, b->out,
+			     flow_statistics[index]);
+	*packets = MLX5_GET64(traffic_counter, stats, packets);
+	*bytes = MLX5_GET64(traffic_counter, stats, octets);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index fc4f7b8..158844c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -76,4 +76,16 @@ int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u16 *id);
 int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u16 id);
 int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u16 id,
 		      u64 *packets, u64 *bytes);
+
+struct mlx5_cmd_fc_bulk;
+
+struct mlx5_cmd_fc_bulk *
+mlx5_cmd_fc_bulk_alloc(struct mlx5_core_dev *dev, u16 id, int num);
+void mlx5_cmd_fc_bulk_free(struct mlx5_cmd_fc_bulk *b);
+int
+mlx5_cmd_fc_bulk_query(struct mlx5_core_dev *dev, struct mlx5_cmd_fc_bulk *b);
+void mlx5_cmd_fc_bulk_get(struct mlx5_core_dev *dev,
+			  struct mlx5_cmd_fc_bulk *b, u16 id,
+			  u64 *packets, u64 *bytes);
+
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
index aaf8fd1..c2877e9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
@@ -90,16 +90,66 @@ static void mlx5_fc_stats_insert(struct rb_root *root, struct mlx5_fc *counter)
 	rb_insert_color(&counter->node, root);
 }
 
+static struct rb_node *mlx5_fc_stats_query(struct mlx5_core_dev *dev,
+					   struct mlx5_fc *first,
+					   u16 last_id)
+{
+	struct mlx5_cmd_fc_bulk *b;
+	struct rb_node *node = NULL;
+	u16 afirst_id;
+	int num;
+	int err;
+	int max_bulk = 1 << MLX5_CAP_GEN(dev, log_max_flow_counter_bulk);
+
+	/* first id must be aligned to 4 when using bulk query */
+	afirst_id = first->id & ~0x3;
+
+	/* number of counters to query inc. the last counter */
+	num = ALIGN(last_id - afirst_id + 1, 4);
+	if (num > max_bulk) {
+		num = max_bulk;
+		last_id = afirst_id + num - 1;
+	}
+
+	b = mlx5_cmd_fc_bulk_alloc(dev, afirst_id, num);
+	if (!b) {
+		mlx5_core_err(dev, "Error allocating resources for bulk query\n");
+		return NULL;
+	}
+
+	err = mlx5_cmd_fc_bulk_query(dev, b);
+	if (err) {
+		mlx5_core_err(dev, "Error doing bulk query: %d\n", err);
+		goto out;
+	}
+
+	for (node = &first->node; node; node = rb_next(node)) {
+		struct mlx5_fc *counter = rb_entry(node, struct mlx5_fc, node);
+		struct mlx5_fc_cache *c = &counter->cache;
+
+		if (counter->id > last_id)
+			break;
+
+		mlx5_cmd_fc_bulk_get(dev, b,
+				     counter->id, &c->packets, &c->bytes);
+	}
+
+out:
+	mlx5_cmd_fc_bulk_free(b);
+
+	return node;
+}
+
 static void mlx5_fc_stats_work(struct work_struct *work)
 {
 	struct mlx5_core_dev *dev = container_of(work, struct mlx5_core_dev,
 						 priv.fc_stats.work.work);
 	struct mlx5_fc_stats *fc_stats = &dev->priv.fc_stats;
 	unsigned long now = jiffies;
-	struct mlx5_fc *counter;
+	struct mlx5_fc *counter = NULL;
+	struct mlx5_fc *last = NULL;
 	struct rb_node *node;
 	LIST_HEAD(tmplist);
-	int err = 0;
 
 	spin_lock(&fc_stats->addlist_lock);
 
@@ -115,12 +165,7 @@ static void mlx5_fc_stats_work(struct work_struct *work)
 
 	node = rb_first(&fc_stats->counters);
 	while (node) {
-		struct mlx5_fc_cache *c;
-		u64 packets;
-		u64 bytes;
-
 		counter = rb_entry(node, struct mlx5_fc, node);
-		c = &counter->cache;
 
 		node = rb_next(node);
 
@@ -133,26 +178,20 @@ static void mlx5_fc_stats_work(struct work_struct *work)
 			continue;
 		}
 
-		if (time_before(now, fc_stats->next_query))
-			continue;
+		last = counter;
+	}
 
-		err = mlx5_cmd_fc_query(dev, counter->id, &packets, &bytes);
-		if (err) {
-			pr_err("Error querying stats for counter id %d\n",
-			       counter->id);
-			continue;
-		}
+	if (time_before(now, fc_stats->next_query) || !last)
+		return;
 
-		if (packets == c->packets)
-			continue;
+	node = rb_first(&fc_stats->counters);
+	while (node) {
+		counter = rb_entry(node, struct mlx5_fc, node);
 
-		c->lastuse = jiffies;
-		c->packets = packets;
-		c->bytes   = bytes;
+		node = mlx5_fc_stats_query(dev, counter, last->id);
 	}
 
-	if (time_after_eq(now, fc_stats->next_query))
-		fc_stats->next_query = now + MLX5_FC_STATS_PERIOD;
+	fc_stats->next_query = now + MLX5_FC_STATS_PERIOD;
 }
 
 struct mlx5_fc *mlx5_fc_create(struct mlx5_core_dev *dev, bool aging)
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 152421c..d671e4e 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -893,7 +893,10 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         reserved_at_330[0xb];
 	u8         log_max_xrcd[0x5];
 
-	u8         reserved_at_340[0x20];
+	u8         reserved_at_340[0x8];
+	u8         log_max_flow_counter_bulk[0x8];
+	u8         max_flow_counter[0x10];
+
 
 	u8         reserved_at_360[0x3];
 	u8         log_max_rq[0x5];
@@ -980,7 +983,8 @@ struct mlx5_ifc_dest_format_struct_bits {
 };
 
 struct mlx5_ifc_flow_counter_list_bits {
-	u8         reserved_at_0[0x10];
+	u8         clear[0x1];
+	u8         num_of_counters[0xf];
 	u8         flow_counter_id[0x10];
 
 	u8         reserved_at_20[0x20];
-- 
2.8.0
