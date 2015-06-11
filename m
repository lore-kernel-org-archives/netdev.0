From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 7/7] net/mlx5e: Add transport domain to the ethernet TIRs/TISs
Date: Thu, 11 Jun 2015 14:47:33 +0300
Message-ID: <1434023253-24362-8-git-send-email-ogerlitz@mellanox.com>
References: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47294 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752851AbbFKLsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 07:48:04 -0400
In-Reply-To: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Allocate and use transport domain by the Ethernet driver code.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   16 +++++++++++++++-
 2 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 23cc3bf..e14120e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -389,6 +389,7 @@ struct mlx5e_priv {
 	struct mutex               state_lock; /* Protects Interface state */
 	struct mlx5_uar            cq_uar;
 	u32                        pdn;
+	u32                        tdn;
 	struct mlx5_core_mr        mr;
 
 	struct mlx5e_channel     **channel;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5458cc6..4e8b0c2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1101,6 +1101,7 @@ static int mlx5e_open_tis(struct mlx5e_priv *priv, int tc)
 	memset(in, 0, sizeof(in));
 
 	MLX5_SET(tisc, tisc, prio,  tc);
+	MLX5_SET(tisc, tisc, transport_domain, priv->tdn);
 
 	return mlx5_core_create_tis(mdev, in, sizeof(in), &priv->tisn[tc]);
 }
@@ -1199,6 +1200,8 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 {
 	void *hfso = MLX5_ADDR_OF(tirc, tirc, rx_hash_field_selector_outer);
 
+	MLX5_SET(tirc, tirc, transport_domain, priv->tdn);
+
 #define ROUGH_MAX_L2_L3_HDR_SZ 256
 
 #define MLX5_HASH_IP     (MLX5_HASH_FIELD_SEL_SRC_IP   |\
@@ -1818,11 +1821,18 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 		goto err_unmap_free_uar;
 	}
 
+	err = mlx5_alloc_transport_domain(mdev, &priv->tdn);
+	if (err) {
+		netdev_err(netdev, "%s: mlx5_alloc_transport_domain failed, %d\n",
+			   __func__, err);
+		goto err_dealloc_pd;
+	}
+
 	err = mlx5e_create_mkey(priv, priv->pdn, &priv->mr);
 	if (err) {
 		netdev_err(netdev, "%s: mlx5e_create_mkey failed, %d\n",
 			   __func__, err);
-		goto err_dealloc_pd;
+		goto err_dealloc_transport_domain;
 	}
 
 	err = register_netdev(netdev);
@@ -1839,6 +1849,9 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 err_destroy_mkey:
 	mlx5_core_destroy_mkey(mdev, &priv->mr);
 
+err_dealloc_transport_domain:
+	mlx5_dealloc_transport_domain(mdev, priv->tdn);
+
 err_dealloc_pd:
 	mlx5_core_dealloc_pd(mdev, priv->pdn);
 
@@ -1858,6 +1871,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 
 	unregister_netdev(netdev);
 	mlx5_core_destroy_mkey(priv->mdev, &priv->mr);
+	mlx5_dealloc_transport_domain(priv->mdev, priv->tdn);
 	mlx5_core_dealloc_pd(priv->mdev, priv->pdn);
 	mlx5_unmap_free_uar(priv->mdev, &priv->cq_uar);
 	mlx5e_disable_async_events(priv);
-- 
1.7.1
