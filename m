From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 15/16] net/mlx5e: E-switch vport manager is valid for ethernet only
Date: Thu, 13 Apr 2017 06:37:05 +0300
Message-ID: <20170413033706.19016-16-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170413033706.19016-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently the driver support only ethernet eswitch, and we want to
protect downstream IPoIB netdev from trying to access it in IB link.

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 6a164aff404c..061b20c73071 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2548,6 +2548,12 @@ static void mlx5e_build_channels_tx_maps(struct mlx5e_priv *priv)
 	}
 }
 
+static bool mlx5e_is_eswitch_vport_mngr(struct mlx5_core_dev *mdev)
+{
+	return (MLX5_CAP_GEN(mdev, vport_group_manager) &&
+		MLX5_CAP_GEN(mdev, port_type) == MLX5_CAP_PORT_TYPE_ETH);
+}
+
 void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
 {
 	int num_txqs = priv->channels.num * priv->channels.params.num_tc;
@@ -2561,7 +2567,7 @@ void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
 	mlx5e_activate_channels(&priv->channels);
 	netif_tx_start_all_queues(priv->netdev);
 
-	if (MLX5_CAP_GEN(priv->mdev, vport_group_manager))
+	if (mlx5e_is_eswitch_vport_mngr(priv->mdev))
 		mlx5e_add_sqs_fwd_rules(priv);
 
 	mlx5e_wait_channels_min_rx_wqes(&priv->channels);
@@ -2572,7 +2578,7 @@ void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv)
 {
 	mlx5e_redirect_rqts_to_drop(priv);
 
-	if (MLX5_CAP_GEN(priv->mdev, vport_group_manager))
+	if (mlx5e_is_eswitch_vport_mngr(priv->mdev))
 		mlx5e_remove_sqs_fwd_rules(priv);
 
 	/* FIXME: This is a W/A only for tx timeout watch dog false alarm when
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
