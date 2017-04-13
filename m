From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 13/16] net/mlx5e: RX handlers per netdev profile
Date: Thu, 13 Apr 2017 06:37:03 +0300
Message-ID: <20170413033706.19016-14-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41824 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755400AbdDMDhu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 23:37:50 -0400
In-Reply-To: <20170413033706.19016-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to have different RX handler per profile, fix and refactor the
current code to take the rx handler directly from the netdevice profile
rather than computing it on runtime as it was done with the switchdev
mode representor rx handler.

This will also remove the current wrong assumption in mlx5e_alloc_rq
code that mlx5e_priv->ppriv is of the type vport_rep.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  5 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 28 ++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  |  4 +++-
 3 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 25185f8c3562..0881325fba04 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -779,6 +779,10 @@ struct mlx5e_profile {
 	void	(*disable)(struct mlx5e_priv *priv);
 	void	(*update_stats)(struct mlx5e_priv *priv);
 	int	(*max_nch)(struct mlx5_core_dev *mdev);
+	struct {
+		mlx5e_fp_handle_rx_cqe handle_rx_cqe;
+		mlx5e_fp_handle_rx_cqe handle_rx_cqe_mpwqe;
+	} rx_handlers;
 	int	max_tc;
 };
 
@@ -1032,7 +1036,6 @@ int mlx5e_get_offload_stats(int attr_id, const struct net_device *dev,
 bool mlx5e_has_offload_stats(const struct net_device *dev, int attr_id);
 
 bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv);
-bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv);
 
 /* mlx5e generic netdev management API */
 struct net_device*
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2201b7ea05f4..6a164aff404c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -585,15 +585,17 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 
 	switch (rq->wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
-		if (mlx5e_is_vf_vport_rep(c->priv)) {
-			err = -EINVAL;
-			goto err_rq_wq_destroy;
-		}
 
-		rq->handle_rx_cqe = mlx5e_handle_rx_cqe_mpwrq;
 		rq->alloc_wqe = mlx5e_alloc_rx_mpwqe;
 		rq->dealloc_wqe = mlx5e_dealloc_rx_mpwqe;
 
+		rq->handle_rx_cqe = c->priv->profile->rx_handlers.handle_rx_cqe_mpwqe;
+		if (!rq->handle_rx_cqe) {
+			err = -EINVAL;
+			netdev_err(c->netdev, "RX handler of MPWQE RQ is not set, err %d\n", err);
+			goto err_rq_wq_destroy;
+		}
+
 		rq->mpwqe_stride_sz = BIT(params->mpwqe_log_stride_sz);
 		rq->mpwqe_num_strides = BIT(params->mpwqe_log_num_strides);
 
@@ -616,15 +618,17 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 			err = -ENOMEM;
 			goto err_rq_wq_destroy;
 		}
-
-		if (mlx5e_is_vf_vport_rep(c->priv))
-			rq->handle_rx_cqe = mlx5e_handle_rx_cqe_rep;
-		else
-			rq->handle_rx_cqe = mlx5e_handle_rx_cqe;
-
 		rq->alloc_wqe = mlx5e_alloc_rx_wqe;
 		rq->dealloc_wqe = mlx5e_dealloc_rx_wqe;
 
+		rq->handle_rx_cqe = c->priv->profile->rx_handlers.handle_rx_cqe;
+		if (!rq->handle_rx_cqe) {
+			kfree(rq->dma_info);
+			err = -EINVAL;
+			netdev_err(c->netdev, "RX handler of RQ is not set, err %d\n", err);
+			goto err_rq_wq_destroy;
+		}
+
 		rq->buff.wqe_sz = params->lro_en  ?
 				params->lro_wqe_sz :
 				MLX5E_SW2HW_MTU(c->netdev->mtu);
@@ -4229,6 +4233,8 @@ static const struct mlx5e_profile mlx5e_nic_profile = {
 	.disable	   = mlx5e_nic_disable,
 	.update_stats	   = mlx5e_update_stats,
 	.max_nch	   = mlx5e_get_max_num_channels,
+	.rx_handlers.handle_rx_cqe       = mlx5e_handle_rx_cqe,
+	.rx_handlers.handle_rx_cqe_mpwqe = mlx5e_handle_rx_cqe_mpwrq,
 	.max_tc		   = MLX5E_MAX_NUM_TC,
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index da85b0ad3e92..16b683e8226d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -329,7 +329,7 @@ bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv)
 	return false;
 }
 
-bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv)
+static bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv)
 {
 	struct mlx5_eswitch_rep *rep = (struct mlx5_eswitch_rep *)priv->ppriv;
 
@@ -538,6 +538,8 @@ static struct mlx5e_profile mlx5e_rep_profile = {
 	.cleanup_tx		= mlx5e_cleanup_nic_tx,
 	.update_stats           = mlx5e_rep_update_stats,
 	.max_nch		= mlx5e_get_rep_max_num_channels,
+	.rx_handlers.handle_rx_cqe       = mlx5e_handle_rx_cqe_rep,
+	.rx_handlers.handle_rx_cqe_mpwqe = NULL /* Not supported */,
 	.max_tc			= 1,
 };
 
-- 
2.11.0
