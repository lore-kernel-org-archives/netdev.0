From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 11/15] net/mlx5e: Reduce number of heap allocated buffers for update stats
Date: Fri, 16 Jun 2017 00:42:48 +0300
Message-ID: <20170615214252.30140-12-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32934 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752445AbdFOVnL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:11 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Allocating buffers on the heap every 200ms is something we should avoid,
let's use buffers located on the stack instead.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Reviewed-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 51f686d737cb..50184021624e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -248,14 +248,10 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 {
 	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
 	struct mlx5_core_dev *mdev = priv->mdev;
+	u32 in[MLX5_ST_SZ_DW(ppcnt_reg)] = {0};
 	int sz = MLX5_ST_SZ_BYTES(ppcnt_reg);
 	int prio;
 	void *out;
-	u32 *in;
-
-	in = kvzalloc(sz, GFP_KERNEL);
-	if (!in)
-		return;
 
 	MLX5_SET(ppcnt_reg, in, local_port, 1);
 
@@ -288,8 +284,6 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 		mlx5_core_access_reg(mdev, in, sz, out, sz,
 				     MLX5_REG_PPCNT, 0, 0);
 	}
-
-	kvfree(in);
 }
 
 static void mlx5e_update_q_counter(struct mlx5e_priv *priv)
@@ -307,22 +301,16 @@ static void mlx5e_update_pcie_counters(struct mlx5e_priv *priv)
 {
 	struct mlx5e_pcie_stats *pcie_stats = &priv->stats.pcie;
 	struct mlx5_core_dev *mdev = priv->mdev;
+	u32 in[MLX5_ST_SZ_DW(mpcnt_reg)] = {0};
 	int sz = MLX5_ST_SZ_BYTES(mpcnt_reg);
 	void *out;
-	u32 *in;
 
 	if (!MLX5_CAP_MCAM_FEATURE(mdev, pcie_performance_group))
 		return;
 
-	in = kvzalloc(sz, GFP_KERNEL);
-	if (!in)
-		return;
-
 	out = pcie_stats->pcie_perf_counters;
 	MLX5_SET(mpcnt_reg, in, grp, MLX5_PCIE_PERFORMANCE_COUNTERS_GROUP);
 	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_MPCNT, 0, 0);
-
-	kvfree(in);
 }
 
 void mlx5e_update_stats(struct mlx5e_priv *priv)
-- 
2.11.0
