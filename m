From: Alexander Guller <alexg@mellanox.com>
Subject: [PATCH 2/7] mlx4_en: Removing reserve vectors
Date: Sun, 9 Oct 2011 17:26:46 +0200
Message-ID: <4E91BD36.6090903@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexg@mellanox.com>,
	<yevgenyp@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53601 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751240Ab1JIP0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 11:26:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed a bug where ring size change caused insufficient memory
upon driver restart due to unreleased EQs.

Signed-off-by: Alexander Guller <alexg@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c      |    5 ++---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    8 ++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    5 ++---
 4 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 70ec529..227997d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -139,14 +139,13 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 	return 0;
 }
 
-void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
-			bool reserve_vectors)
+void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 
 	mlx4_en_unmap_buffer(&cq->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
-	if (priv->mdev->dev->caps.comp_pool && cq->vector && !reserve_vectors)
+	if (priv->mdev->dev->caps.comp_pool && cq->vector)
 		mlx4_release_eq(priv->mdev->dev, cq->vector);
 	cq->buf_size = 0;
 	cq->buf = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index eb09625..e247bd7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -416,7 +416,7 @@ static int mlx4_en_set_ringparam(struct net_device *dev,
 		mlx4_en_stop_port(dev);
 	}
 
-	mlx4_en_free_resources(priv, true);
+	mlx4_en_free_resources(priv);
 
 	priv->prof->tx_ring_size = tx_size;
 	priv->prof->rx_ring_size = rx_size;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b42c6aa..8402982 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -876,7 +876,7 @@ static int mlx4_en_close(struct net_device *dev)
 	return 0;
 }
 
-void mlx4_en_free_resources(struct mlx4_en_priv *priv, bool reserve_vectors)
+void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 {
 	int i;
 
@@ -884,14 +884,14 @@ void mlx4_en_free_resources(struct mlx4_en_priv *priv, bool reserve_vectors)
 		if (priv->tx_ring[i].tx_info)
 			mlx4_en_destroy_tx_ring(priv, &priv->tx_ring[i]);
 		if (priv->tx_cq[i].buf)
-			mlx4_en_destroy_cq(priv, &priv->tx_cq[i], reserve_vectors);
+			mlx4_en_destroy_cq(priv, &priv->tx_cq[i]);
 	}
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		if (priv->rx_ring[i].rx_info)
 			mlx4_en_destroy_rx_ring(priv, &priv->rx_ring[i]);
 		if (priv->rx_cq[i].buf)
-			mlx4_en_destroy_cq(priv, &priv->rx_cq[i], reserve_vectors);
+			mlx4_en_destroy_cq(priv, &priv->rx_cq[i]);
 	}
 }
 
@@ -961,7 +961,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	mdev->pndev[priv->port] = NULL;
 	mutex_unlock(&mdev->state_lock);
 
-	mlx4_en_free_resources(priv, false);
+	mlx4_en_free_resources(priv);
 	free_netdev(dev);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 115784d..fe8146d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -502,13 +502,12 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 int mlx4_en_start_port(struct net_device *dev);
 void mlx4_en_stop_port(struct net_device *dev);
 
-void mlx4_en_free_resources(struct mlx4_en_priv *priv, bool reserve_vectors);
+void mlx4_en_free_resources(struct mlx4_en_priv *priv);
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
 
 int mlx4_en_create_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 		      int entries, int ring, enum cq_type mode);
-void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
-			bool reserve_vectors);
+void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 			int cq_idx);
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
-- 
1.7.5.4
