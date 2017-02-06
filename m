From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next V2 6/6] net/mlx5e: Bring back bfreg uar map dedicated pointer
Date: Tue,  7 Feb 2017 01:38:29 +0200
Message-ID: <20170206233829.29716-7-saeedm@mellanox.com>
References: <20170206233829.29716-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52049 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751502AbdBFXjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 18:39:01 -0500
In-Reply-To: <20170206233829.29716-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

4K Uar series modified the mlx5e driver to use the new bfreg API,
and mistakenly removed the sq->uar_map iomem data path dedicated
pointer, which was meant to be read from xmit path for cache locality
utilization.

Fix that by returning that pointer to the SQ struct.

Fixes: 7309cb4ad71e ("IB/mlx5: Support 4k UAR for libmlx5")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 5 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 8be4b12b5545..95ca03c0d9f5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -475,6 +475,7 @@ struct mlx5e_sq {
 	/* read only */
 	struct mlx5_wq_cyc         wq;
 	u32                        dma_fifo_mask;
+	void __iomem              *uar_map;
 	struct netdev_queue       *txq;
 	u32                        sqn;
 	u16                        bf_buf_size;
@@ -831,9 +832,9 @@ static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 	 */
 	wmb();
 	if (bf_sz)
-		__iowrite64_copy(sq->bfreg.map + ofst, ctrl, bf_sz);
+		__iowrite64_copy(sq->uar_map + ofst, ctrl, bf_sz);
 	else
-		mlx5_write64((__be32 *)ctrl, sq->bfreg.map + ofst, NULL);
+		mlx5_write64((__be32 *)ctrl, sq->uar_map + ofst, NULL);
 	/* flush the write-combining mapped buffer */
 	wmb();
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index ed230757d9c5..3cce6281e075 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1016,6 +1016,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	if (err)
 		return err;
 
+	sq->uar_map = sq->bfreg.map;
 	param->wq.db_numa_node = cpu_to_node(c->cpu);
 
 	err = mlx5_wq_cyc_create(mdev, &param->wq, sqc_wq, &sq->wq,
-- 
2.11.0
