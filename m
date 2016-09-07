From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC 06/11] net/mlx5e: Slightly reduce hardware LRO size
Date: Wed,  7 Sep 2016 15:42:27 +0300
Message-ID: <1473252152-11379-7-git-send-email-saeedm@mellanox.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: iovisor-dev <iovisor-dev@lists.iovisor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45166 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754742AbcIGMmw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 08:42:52 -0400
In-Reply-To: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch LRO size was 64K, now with build_skb requires
extra room, headroom + sizeof(skb_shared_info) added to the data
buffer will make  wqe size or page_frag_size slightly larger than
64K which will demand order 5 page instead of order 4 in 4K page systems.

We take those extra bytes from hardware LRO data size in order to not
increase the required page order for when hardware LRO is enabled.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9f0f5f6..17f84f9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3185,8 +3185,11 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
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
2.7.4
