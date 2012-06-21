From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 3/4] net/mlx4_en: Release QP range in free_resources
Date: Thu, 21 Jun 2012 12:19:16 +0300
Message-ID: <1340270358-19504-4-git-send-email-yevgenyp@mellanox.co.il>
References: <1340270358-19504-1-git-send-email-yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:34813 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932301Ab2FUJTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 05:19:42 -0400
In-Reply-To: <1340270358-19504-1-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a missing resource release in ring cleanup.
Not doing this leaves a range of QPs that are being reserved,
and no one can use them.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   12 ++++++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    1 +
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index a80280e..073b85b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -929,15 +929,20 @@ void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 		if (priv->rx_cq[i].buf)
 			mlx4_en_destroy_cq(priv, &priv->rx_cq[i]);
 	}
+
+	if (priv->base_tx_qpn) {
+		mlx4_qp_release_range(priv->mdev->dev, priv->base_tx_qpn, priv->tx_ring_num);
+		priv->base_tx_qpn = 0;
+	}
 }
 
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 {
 	struct mlx4_en_port_profile *prof = priv->prof;
 	int i;
-	int base_tx_qpn, err;
+	int err;
 
-	err = mlx4_qp_reserve_range(priv->mdev->dev, priv->tx_ring_num, 256, &base_tx_qpn);
+	err = mlx4_qp_reserve_range(priv->mdev->dev, priv->tx_ring_num, 256, &priv->base_tx_qpn);
 	if (err) {
 		en_err(priv, "failed reserving range for TX rings\n");
 		return err;
@@ -949,7 +954,7 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 				      prof->tx_ring_size, i, TX))
 			goto err;
 
-		if (mlx4_en_create_tx_ring(priv, &priv->tx_ring[i], base_tx_qpn + i,
+		if (mlx4_en_create_tx_ring(priv, &priv->tx_ring[i], priv->base_tx_qpn + i,
 					   prof->tx_ring_size, TXBB_SIZE))
 			goto err;
 	}
@@ -969,7 +974,6 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 
 err:
 	en_err(priv, "Failed to allocate NIC resources\n");
-	mlx4_qp_release_range(priv->mdev->dev, base_tx_qpn, priv->tx_ring_num);
 	return -ENOMEM;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 6ae3509..225c20d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -495,6 +495,7 @@ struct mlx4_en_priv {
 	int vids[128];
 	bool wol;
 	struct device *ddev;
+	int base_tx_qpn;
 
 #ifdef CONFIG_MLX4_EN_DCB
 	struct ieee_ets ets;
-- 
1.7.1
