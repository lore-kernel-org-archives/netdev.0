From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 3/8] net/mlx5e: Slightly reduce hardware LRO size
Date: Wed, 21 Sep 2016 12:19:44 +0300
Message-ID: <1474449589-27035-4-git-send-email-tariqt@mellanox.com>
References: <1474449589-27035-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41601 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932933AbcIUJUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 05:20:40 -0400
In-Reply-To: <1474449589-27035-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Before this patch LRO size was 64K, now with build_skb requires
extra room, headroom + sizeof(skb_shared_info) added to the data
buffer will make  wqe size or page_frag_size slightly larger than
64K which will demand order 5 page instead of order 4 in 4K page systems.

We take those extra bytes from hardware LRO data size in order to not
increase the required page order for when hardware LRO is enabled.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f2efa532f453..8734240865e1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3187,8 +3187,11 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	mlx5e_build_default_indir_rqt(mdev, priv->params.indirection_rqt,
 				      MLX5E_INDIR_RQT_SIZE, profile->max_nch(mdev));
 
-	priv->params.lro_wqe_sz            =
-		MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
+	priv->params.lro_wqe_sz =
+		MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ -
+		/* Extra room needed for build_skb */
+		MLX5_RX_HEADROOM -
+		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	/* Initialize pflags */
 	MLX5E_SET_PRIV_FLAG(priv, MLX5E_PFLAG_RX_CQE_BASED_MODER,
-- 
1.8.3.1
