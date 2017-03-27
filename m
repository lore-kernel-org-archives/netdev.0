From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 05/14] net/mlx5e: Refactor refresh TIRs
Date: Mon, 27 Mar 2017 23:49:01 +0300
Message-ID: <20170327204910.20287-6-saeedm@mellanox.com>
References: <20170327204910.20287-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44923 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752579AbdC0UuR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 16:50:17 -0400
In-Reply-To: <20170327204910.20287-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename mlx5e_refresh_tirs_self_loopback to mlx5e_refresh_tirs,
as it will be used in downstream (Safe config flow) patches, and make it
fail safe on mlx5e_open.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h          |  3 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_common.c   | 17 +++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c     |  8 +-------
 drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c |  9 +++------
 4 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 50dfc4c6c8e4..5f7cc58d900c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -959,8 +959,7 @@ void mlx5e_destroy_tir(struct mlx5_core_dev *mdev,
 		       struct mlx5e_tir *tir);
 int mlx5e_create_mdev_resources(struct mlx5_core_dev *mdev);
 void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev);
-int mlx5e_refresh_tirs_self_loopback(struct mlx5_core_dev *mdev,
-				     bool enable_uc_lb);
+int mlx5e_refresh_tirs(struct mlx5e_priv *priv, bool enable_uc_lb);
 
 struct mlx5_eswitch_rep;
 int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
index 20bdbe685795..f1f17f7a3cd0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
@@ -136,18 +136,20 @@ void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev)
 	mlx5_core_dealloc_pd(mdev, res->pdn);
 }
 
-int mlx5e_refresh_tirs_self_loopback(struct mlx5_core_dev *mdev,
-				     bool enable_uc_lb)
+int mlx5e_refresh_tirs(struct mlx5e_priv *priv, bool enable_uc_lb)
 {
+	struct mlx5_core_dev *mdev = priv->mdev;
 	struct mlx5e_tir *tir;
-	void *in;
+	int err  = -ENOMEM;
+	u32 tirn = 0;
 	int inlen;
-	int err = 0;
+	void *in;
+
 
 	inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
 	in = mlx5_vzalloc(inlen);
 	if (!in)
-		return -ENOMEM;
+		goto out;
 
 	if (enable_uc_lb)
 		MLX5_SET(modify_tir_in, in, ctx.self_lb_block,
@@ -156,13 +158,16 @@ int mlx5e_refresh_tirs_self_loopback(struct mlx5_core_dev *mdev,
 	MLX5_SET(modify_tir_in, in, bitmask.self_lb_en, 1);
 
 	list_for_each_entry(tir, &mdev->mlx5e_res.td.tirs_list, list) {
-		err = mlx5_core_modify_tir(mdev, tir->tirn, in, inlen);
+		tirn = tir->tirn;
+		err = mlx5_core_modify_tir(mdev, tirn, in, inlen);
 		if (err)
 			goto out;
 	}
 
 out:
 	kvfree(in);
+	if (err)
+		netdev_err(priv->netdev, "refresh tir(0x%x) failed, %d\n", tirn, err);
 
 	return err;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index aec77f075714..a98d01684247 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2498,13 +2498,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 		goto err_clear_state_opened_flag;
 	}
 
-	err = mlx5e_refresh_tirs_self_loopback(priv->mdev, false);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5e_refresh_tirs_self_loopback_enable failed, %d\n",
-			   __func__, err);
-		goto err_close_channels;
-	}
-
+	mlx5e_refresh_tirs(priv, false);
 	mlx5e_redirect_rqts_to_channels(priv, &priv->channels);
 	mlx5e_update_carrier(priv);
 	mlx5e_timestamp_init(priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
index 5621dcfda4f1..5225f2226a67 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
@@ -236,12 +236,9 @@ static int mlx5e_test_loopback_setup(struct mlx5e_priv *priv,
 {
 	int err = 0;
 
-	err = mlx5e_refresh_tirs_self_loopback(priv->mdev, true);
-	if (err) {
-		netdev_err(priv->netdev,
-			   "\tFailed to enable UC loopback err(%d)\n", err);
+	err = mlx5e_refresh_tirs(priv, true);
+	if (err)
 		return err;
-	}
 
 	lbtp->loopback_ok = false;
 	init_completion(&lbtp->comp);
@@ -258,7 +255,7 @@ static void mlx5e_test_loopback_cleanup(struct mlx5e_priv *priv,
 					struct mlx5e_lbt_priv *lbtp)
 {
 	dev_remove_pack(&lbtp->pt);
-	mlx5e_refresh_tirs_self_loopback(priv->mdev, false);
+	mlx5e_refresh_tirs(priv, false);
 }
 
 #define MLX5E_LB_VERIFY_TIMEOUT (msecs_to_jiffies(200))
-- 
2.11.0
