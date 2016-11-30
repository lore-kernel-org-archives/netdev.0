From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 2/7] net/mlx5e: Move function mlx5e_create_umr_mkey
Date: Wed, 30 Nov 2016 17:59:38 +0200
Message-ID: <1480521583-12755-3-git-send-email-saeedm@mellanox.com>
References: <1480521583-12755-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59025 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758042AbcK3Q2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:28:04 -0500
In-Reply-To: <1480521583-12755-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In next patch we are going to create a UMR MKey per RQ, we need
mlx5e_create_umr_mkey declared before mlx5e_create_rq.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 74 +++++++++++------------
 1 file changed, 37 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index ba25cd3..49ca30b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -471,6 +471,43 @@ static void mlx5e_rq_free_mpwqe_info(struct mlx5e_rq *rq)
 	kfree(rq->mpwqe.info);
 }
 
+static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u64 npages = MLX5E_REQUIRED_MTTS(priv->profile->max_nch(mdev),
+					 BIT(MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE_MPW));
+	int inlen = MLX5_ST_SZ_BYTES(create_mkey_in);
+	void *mkc;
+	u32 *in;
+	int err;
+
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	mkc = MLX5_ADDR_OF(create_mkey_in, in, memory_key_mkey_entry);
+
+	npages = min_t(u32, ALIGN(U16_MAX, 4) * 2, npages);
+
+	MLX5_SET(mkc, mkc, free, 1);
+	MLX5_SET(mkc, mkc, umr_en, 1);
+	MLX5_SET(mkc, mkc, lw, 1);
+	MLX5_SET(mkc, mkc, lr, 1);
+	MLX5_SET(mkc, mkc, access_mode, MLX5_MKC_ACCESS_MODE_MTT);
+
+	MLX5_SET(mkc, mkc, qpn, 0xffffff);
+	MLX5_SET(mkc, mkc, pd, mdev->mlx5e_res.pdn);
+	MLX5_SET64(mkc, mkc, len, npages << PAGE_SHIFT);
+	MLX5_SET(mkc, mkc, translations_octword_size,
+		 MLX5_MTT_OCTW(npages));
+	MLX5_SET(mkc, mkc, log_page_size, PAGE_SHIFT);
+
+	err = mlx5_core_create_mkey(mdev, &priv->umr_mkey, in, inlen);
+
+	kvfree(in);
+	return err;
+}
+
 static int mlx5e_create_rq(struct mlx5e_channel *c,
 			   struct mlx5e_rq_param *param,
 			   struct mlx5e_rq *rq)
@@ -3625,43 +3662,6 @@ static void mlx5e_destroy_q_counter(struct mlx5e_priv *priv)
 	mlx5_core_dealloc_q_counter(priv->mdev, priv->q_counter);
 }
 
-static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv)
-{
-	struct mlx5_core_dev *mdev = priv->mdev;
-	u64 npages = MLX5E_REQUIRED_MTTS(priv->profile->max_nch(mdev),
-					 BIT(MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE_MPW));
-	int inlen = MLX5_ST_SZ_BYTES(create_mkey_in);
-	void *mkc;
-	u32 *in;
-	int err;
-
-	in = mlx5_vzalloc(inlen);
-	if (!in)
-		return -ENOMEM;
-
-	mkc = MLX5_ADDR_OF(create_mkey_in, in, memory_key_mkey_entry);
-
-	npages = min_t(u32, ALIGN(U16_MAX, 4) * 2, npages);
-
-	MLX5_SET(mkc, mkc, free, 1);
-	MLX5_SET(mkc, mkc, umr_en, 1);
-	MLX5_SET(mkc, mkc, lw, 1);
-	MLX5_SET(mkc, mkc, lr, 1);
-	MLX5_SET(mkc, mkc, access_mode, MLX5_MKC_ACCESS_MODE_MTT);
-
-	MLX5_SET(mkc, mkc, qpn, 0xffffff);
-	MLX5_SET(mkc, mkc, pd, mdev->mlx5e_res.pdn);
-	MLX5_SET64(mkc, mkc, len, npages << PAGE_SHIFT);
-	MLX5_SET(mkc, mkc, translations_octword_size,
-		 MLX5_MTT_OCTW(npages));
-	MLX5_SET(mkc, mkc, log_page_size, PAGE_SHIFT);
-
-	err = mlx5_core_create_mkey(mdev, &priv->umr_mkey, in, inlen);
-
-	kvfree(in);
-	return err;
-}
-
 static void mlx5e_nic_init(struct mlx5_core_dev *mdev,
 			   struct net_device *netdev,
 			   const struct mlx5e_profile *profile,
-- 
2.7.4
