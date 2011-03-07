From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 06/17 V2] mlx4_en: using new mlx4 interrupt scheme
Date: Mon, 7 Mar 2011 15:27:36 +0200
Message-ID: <4D74DD48.4090500@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<markuze@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:32943 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750754Ab1CGN1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 08:27:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Each RX ring will have its own interrupt vector, and TX rings will share one
(we mostly use polling for TX completions).
The vectors are assigned first time device is opened, and its name includes
the interface name and ring number.

Signed-off-by: Markuze Alex <markuze@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---

diff from V1: using <ifname>-tx instead of <ifname>_tx

 drivers/net/mlx4/en_cq.c      |   38 +++++++++++++++++++++++++++++++-------
 drivers/net/mlx4/en_ethtool.c |    2 +-
 drivers/net/mlx4/en_main.c    |   20 +++++++++++---------
 drivers/net/mlx4/en_netdev.c  |   18 ++++++++++++++----
 drivers/net/mlx4/mlx4_en.h    |    7 +++++--
 5 files changed, 62 insertions(+), 23 deletions(-)

diff --git a/drivers/net/mlx4/en_cq.c b/drivers/net/mlx4/en_cq.c
index 21786ad..ec4b6d0 100644
--- a/drivers/net/mlx4/en_cq.c
+++ b/drivers/net/mlx4/en_cq.c
@@ -51,13 +51,10 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 	int err;
 
 	cq->size = entries;
-	if (mode == RX) {
+	if (mode == RX)
 		cq->buf_size = cq->size * sizeof(struct mlx4_cqe);
-		cq->vector   = ring % mdev->dev->caps.num_comp_vectors;
-	} else {
+	else
 		cq->buf_size = sizeof(struct mlx4_cqe);
-		cq->vector   = 0;
-	}
 
 	cq->ring = ring;
 	cq->is_tx = mode;
@@ -80,7 +77,8 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
-	int err;
+	int err = 0;
+	char name[25];
 
 	cq->dev = mdev->pndev[priv->port];
 	cq->mcq.set_ci_db  = cq->wqres.db.db;
@@ -89,6 +87,29 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 	*cq->mcq.arm_db    = 0;
 	memset(cq->buf, 0, cq->buf_size);
 
+	if (cq->is_tx == RX) {
+		if (mdev->dev->caps.comp_pool) {
+			if (!cq->vector) {
+				sprintf(name , "%s-rx-%d", priv->dev->name, cq->ring);
+				if (mlx4_assign_eq(mdev->dev, name, &cq->vector)) {
+					cq->vector = (cq->ring + 1 + priv->port) %
+						mdev->dev->caps.num_comp_vectors;
+					mlx4_warn(mdev, "Failed Assigning an EQ to "
+						  "%s_rx-%d ,Falling back to legacy EQ's\n",
+						  priv->dev->name, cq->ring);
+				}
+			}
+		} else {
+			cq->vector = (cq->ring + 1 + priv->port) %
+				mdev->dev->caps.num_comp_vectors;
+		}
+	} else {
+		if (!cq->vector || !mdev->dev->caps.comp_pool) {
+			/*Fallback to legacy pool in case of error*/
+			cq->vector   = 0;
+		}
+	}
+
 	if (!cq->is_tx)
 		cq->size = priv->rx_ring[cq->ring].actual_size;
 
@@ -112,12 +133,15 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 	return 0;
 }
 
-void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
+void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
+			bool reserve_vectors)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 
 	mlx4_en_unmap_buffer(&cq->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
+	if (priv->mdev->dev->caps.comp_pool && cq->vector && !reserve_vectors)
+		mlx4_release_eq(priv->mdev->dev, cq->vector);
 	cq->buf_size = 0;
 	cq->buf = NULL;
 }
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index 056152b..8cfe858 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -388,7 +388,7 @@ static int mlx4_en_set_ringparam(struct net_device *dev,
 		mlx4_en_stop_port(dev);
 	}
 
-	mlx4_en_free_resources(priv);
+	mlx4_en_free_resources(priv, true);
 
 	priv->prof->tx_ring_size = tx_size;
 	priv->prof->rx_ring_size = rx_size;
diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 1ff6ca6..29aaa43 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -241,16 +241,18 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH)
 		mdev->port_cnt++;
 
-	/* If we did not receive an explicit number of Rx rings, default to
-	 * the number of completion vectors populated by the mlx4_core */
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
-		mlx4_info(mdev, "Using %d tx rings for port:%d\n",
-			  mdev->profile.prof[i].tx_ring_num, i);
-		mdev->profile.prof[i].rx_ring_num = min_t(int,
-			roundup_pow_of_two(dev->caps.num_comp_vectors),
-			MAX_RX_RINGS);
-		mlx4_info(mdev, "Defaulting to %d rx rings for port:%d\n",
-			  mdev->profile.prof[i].rx_ring_num, i);
+		if (!dev->caps.comp_pool) {
+			mdev->profile.prof[i].rx_ring_num =
+				rounddown_pow_of_two(max_t(int, MIN_RX_RINGS,
+							   min_t(int,
+								 dev->caps.num_comp_vectors,
+								 MAX_RX_RINGS)));
+		} else {
+			mdev->profile.prof[i].rx_ring_num = rounddown_pow_of_two(
+				min_t(int, dev->caps.comp_pool/
+				      dev->caps.num_ports - 1 , MAX_MSIX_P_PORT - 1));
+		}
 	}
 
 	/* Create our own workqueue for reset/multicast tasks
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 5727bf5..f0d06a0 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -557,6 +557,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	int err = 0;
 	int i;
 	int j;
+	char name[32];
 
 	if (priv->port_up) {
 		en_dbg(DRV, priv, "start port called while port already up\n");
@@ -601,10 +602,19 @@ int mlx4_en_start_port(struct net_device *dev)
 		goto cq_err;
 	}
 
+	if (mdev->dev->caps.comp_pool && !priv->tx_vector) {
+		sprintf(name , "%s-tx", priv->dev->name);
+		if (mlx4_assign_eq(mdev->dev , name, &priv->tx_vector)) {
+			mlx4_warn(mdev, "Failed Assigning an EQ to "
+					"%s_tx ,Falling back to legacy "
+					"EQ's\n", priv->dev->name);
+		}
+	}
 	/* Configure tx cq's and rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		/* Configure cq */
 		cq = &priv->tx_cq[i];
+		cq->vector = priv->tx_vector;
 		err = mlx4_en_activate_cq(priv, cq);
 		if (err) {
 			en_err(priv, "Failed allocating Tx CQ\n");
@@ -819,7 +829,7 @@ static int mlx4_en_close(struct net_device *dev)
 	return 0;
 }
 
-void mlx4_en_free_resources(struct mlx4_en_priv *priv)
+void mlx4_en_free_resources(struct mlx4_en_priv *priv, bool reserve_vectors)
 {
 	int i;
 
@@ -827,14 +837,14 @@ void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 		if (priv->tx_ring[i].tx_info)
 			mlx4_en_destroy_tx_ring(priv, &priv->tx_ring[i]);
 		if (priv->tx_cq[i].buf)
-			mlx4_en_destroy_cq(priv, &priv->tx_cq[i]);
+			mlx4_en_destroy_cq(priv, &priv->tx_cq[i], reserve_vectors);
 	}
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		if (priv->rx_ring[i].rx_info)
 			mlx4_en_destroy_rx_ring(priv, &priv->rx_ring[i]);
 		if (priv->rx_cq[i].buf)
-			mlx4_en_destroy_cq(priv, &priv->rx_cq[i]);
+			mlx4_en_destroy_cq(priv, &priv->rx_cq[i], reserve_vectors);
 	}
 }
 
@@ -896,7 +906,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	mdev->pndev[priv->port] = NULL;
 	mutex_unlock(&mdev->state_lock);
 
-	mlx4_en_free_resources(priv);
+	mlx4_en_free_resources(priv, false);
 	free_netdev(dev);
 }
 
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 5387c4e..2db245f 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -62,6 +62,7 @@
 #define MLX4_EN_PAGE_SHIFT	12
 #define MLX4_EN_PAGE_SIZE	(1 << MLX4_EN_PAGE_SHIFT)
 #define MAX_RX_RINGS		16
+#define MIN_RX_RINGS		4
 #define TXBB_SIZE		64
 #define HEADROOM		(2048 / TXBB_SIZE + 1)
 #define STAMP_STRIDE		64
@@ -462,6 +463,7 @@ struct mlx4_en_priv {
 	u16 log_rx_info;
 
 	struct mlx4_en_tx_ring tx_ring[MAX_TX_RINGS];
+	int tx_vector;
 	struct mlx4_en_rx_ring rx_ring[MAX_RX_RINGS];
 	struct mlx4_en_cq tx_cq[MAX_TX_RINGS];
 	struct mlx4_en_cq rx_cq[MAX_RX_RINGS];
@@ -487,12 +489,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 int mlx4_en_start_port(struct net_device *dev);
 void mlx4_en_stop_port(struct net_device *dev);
 
-void mlx4_en_free_resources(struct mlx4_en_priv *priv);
+void mlx4_en_free_resources(struct mlx4_en_priv *priv, bool reserve_vectors);
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
 
 int mlx4_en_create_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 		      int entries, int ring, enum cq_type mode);
-void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
+void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
+			bool reserve_vectors);
 int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 int mlx4_en_set_cq_moder(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
-- 
1.6.0.2





