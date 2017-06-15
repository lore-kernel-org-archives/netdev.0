From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 12/15] net/mlx5e: Move and optimize query out of buffer function
Date: Fri, 16 Jun 2017 00:42:49 +0300
Message-ID: <20170615214252.30140-13-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32939 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752271AbdFOVnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:06 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Move "query queue counter out of buffer" helper function out of
qp.c to en_main.c, since mlx5e netdev driver is the only one to use it.

Also allocate the output buffer on the stack instead of the heap, to reduce
number of heap allocs on update_stats work.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  9 +++++++--
 drivers/net/ethernet/mellanox/mlx5/core/qp.c      | 20 --------------------
 include/linux/mlx5/qp.h                           |  2 --
 3 files changed, 7 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 50184021624e..8bb0241df069 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -289,12 +289,17 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 static void mlx5e_update_q_counter(struct mlx5e_priv *priv)
 {
 	struct mlx5e_qcounter_stats *qcnt = &priv->stats.qcnt;
+	u32 out[MLX5_ST_SZ_DW(query_q_counter_out)];
+	int err;
 
 	if (!priv->q_counter)
 		return;
 
-	mlx5_core_query_out_of_buffer(priv->mdev, priv->q_counter,
-				      &qcnt->rx_out_of_buffer);
+	err = mlx5_core_query_q_counter(priv->mdev, priv->q_counter, 0, out, sizeof(out));
+	if (err)
+		return;
+
+	qcnt->rx_out_of_buffer = MLX5_GET(query_q_counter_out, out, out_of_buffer);
 }
 
 static void mlx5e_update_pcie_counters(struct mlx5e_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
index da0f18f93616..340f281c9801 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -518,23 +518,3 @@ int mlx5_core_query_q_counter(struct mlx5_core_dev *dev, u16 counter_id,
 	return mlx5_cmd_exec(dev, in, sizeof(in), out, out_size);
 }
 EXPORT_SYMBOL_GPL(mlx5_core_query_q_counter);
-
-int mlx5_core_query_out_of_buffer(struct mlx5_core_dev *dev, u16 counter_id,
-				  u32 *out_of_buffer)
-{
-	int outlen = MLX5_ST_SZ_BYTES(query_q_counter_out);
-	void *out;
-	int err;
-
-	out = kvzalloc(outlen, GFP_KERNEL);
-	if (!out)
-		return -ENOMEM;
-
-	err = mlx5_core_query_q_counter(dev, counter_id, 0, out, outlen);
-	if (!err)
-		*out_of_buffer = MLX5_GET(query_q_counter_out, out,
-					  out_of_buffer);
-
-	kfree(out);
-	return err;
-}
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index bef80d0a0e30..1f637f4d1265 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -569,8 +569,6 @@ int mlx5_core_alloc_q_counter(struct mlx5_core_dev *dev, u16 *counter_id);
 int mlx5_core_dealloc_q_counter(struct mlx5_core_dev *dev, u16 counter_id);
 int mlx5_core_query_q_counter(struct mlx5_core_dev *dev, u16 counter_id,
 			      int reset, void *out, int out_size);
-int mlx5_core_query_out_of_buffer(struct mlx5_core_dev *dev, u16 counter_id,
-				  u32 *out_of_buffer);
 
 static inline const char *mlx5_qp_type_str(int type)
 {
-- 
2.11.0
