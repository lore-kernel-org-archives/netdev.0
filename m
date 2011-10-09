From: Alexander Guller <alexg@mellanox.com>
Subject: [PATCH 4/7] mlx4_en: Added missing iounmap upon releasing a device
Date: Sun, 9 Oct 2011 17:27:11 +0200
Message-ID: <4E91BD4F.70809@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <alexg@mellanox.com>,
	<yevgenyp@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53627 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751871Ab1JIP1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 11:27:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed a memory leak caused by missing iounmap when device
is being released.

Signed-off-by: Alexander Guller <alexg@mellanox.co.il>
Signed-off-by: Sharon Cohen <sharonc@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 6bfea23..a06096f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -176,6 +176,7 @@ static void mlx4_en_remove(struct mlx4_dev *dev, void *endev_ptr)
 	flush_workqueue(mdev->workqueue);
 	destroy_workqueue(mdev->workqueue);
 	mlx4_mr_free(dev, &mdev->mr);
+	iounmap(mdev->uar_map);
 	mlx4_uar_free(dev, &mdev->priv_uar);
 	mlx4_pd_free(dev, mdev->priv_pdn);
 	kfree(mdev);
@@ -223,7 +224,7 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 			 MLX4_PERM_LOCAL_WRITE |  MLX4_PERM_LOCAL_READ,
 			 0, 0, &mdev->mr)) {
 		mlx4_err(mdev, "Failed allocating memory region\n");
-		goto err_uar;
+		goto err_map;
 	}
 	if (mlx4_mr_enable(mdev->dev, &mdev->mr)) {
 		mlx4_err(mdev, "Failed enabling memory region\n");
@@ -282,6 +283,9 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 
 err_mr:
 	mlx4_mr_free(dev, &mdev->mr);
+err_map:
+	if (!mdev->uar_map)
+		iounmap(mdev->uar_map);
 err_uar:
 	mlx4_uar_free(dev, &mdev->priv_uar);
 err_pd:
-- 
1.7.5.4

Until now only RX rings used irq per ring
and TX used only one per port.
>From now on, both of them will use the
irq per ring while RX & TX ring[i] will
use the same irq.

Signed-off-by: Alexander Guller <alexg@mellanox.co.il>
Signed-off-by: Sharon Cohen <sharonc@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |   26 ++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   14 +-----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    4 +-
 3 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index ec4b6d0..70ec529 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -74,7 +74,8 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 	return err;
 }
 
-int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
+int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
+			int cq_idx)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err = 0;
@@ -90,13 +91,15 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 	if (cq->is_tx == RX) {
 		if (mdev->dev->caps.comp_pool) {
 			if (!cq->vector) {
-				sprintf(name , "%s-rx-%d", priv->dev->name, cq->ring);
+				sprintf(name, "%s-%d", priv->dev->name,
+					cq->ring);
+				/* Set IRQ for specific name (per ring) */
 				if (mlx4_assign_eq(mdev->dev, name, &cq->vector)) {
-					cq->vector = (cq->ring + 1 + priv->port) %
-						mdev->dev->caps.num_comp_vectors;
+					cq->vector = (cq->ring + 1 + priv->port)
+					    % mdev->dev->caps.num_comp_vectors;
 					mlx4_warn(mdev, "Failed Assigning an EQ to "
-						  "%s_rx-%d ,Falling back to legacy EQ's\n",
-						  priv->dev->name, cq->ring);
+						  "%s ,Falling back to legacy EQ's\n",
+						  name);
 				}
 			}
 		} else {
@@ -104,10 +107,13 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 				mdev->dev->caps.num_comp_vectors;
 		}
 	} else {
-		if (!cq->vector || !mdev->dev->caps.comp_pool) {
-			/*Fallback to legacy pool in case of error*/
-			cq->vector   = 0;
-		}
+		/* For TX we use the same irq per
+		ring we assigned for the RX    */
+		struct mlx4_en_cq *rx_cq;
+
+		cq_idx = cq_idx % priv->rx_ring_num;
+		rx_cq = &priv->rx_cq[cq_idx];
+		cq->vector = rx_cq->vector;
 	}
 
 	if (!cq->is_tx)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 27789be..b42c6aa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -587,7 +587,6 @@ int mlx4_en_start_port(struct net_device *dev)
 	int i;
 	int j;
 	u8 mc_list[16] = {0};
-	char name[32];
 
 	if (priv->port_up) {
 		en_dbg(DRV, priv, "start port called while port already up\n");
@@ -608,7 +607,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		cq = &priv->rx_cq[i];
 
-		err = mlx4_en_activate_cq(priv, cq);
+		err = mlx4_en_activate_cq(priv, cq, i);
 		if (err) {
 			en_err(priv, "Failed activating Rx CQ\n");
 			goto cq_err;
@@ -642,20 +641,11 @@ int mlx4_en_start_port(struct net_device *dev)
 		goto mac_err;
 	}
 
-	if (mdev->dev->caps.comp_pool && !priv->tx_vector) {
-		sprintf(name , "%s-tx", priv->dev->name);
-		if (mlx4_assign_eq(mdev->dev , name, &priv->tx_vector)) {
-			mlx4_warn(mdev, "Failed Assigning an EQ to "
-					"%s_tx ,Falling back to legacy "
-					"EQ's\n", priv->dev->name);
-		}
-	}
 	/* Configure tx cq's and rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		/* Configure cq */
 		cq = &priv->tx_cq[i];
-		cq->vector = priv->tx_vector;
-		err = mlx4_en_activate_cq(priv, cq);
+		err = mlx4_en_activate_cq(priv, cq, i);
 		if (err) {
 			en_err(priv, "Failed allocating Tx CQ\n");
 			goto tx_err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index ed84811..115784d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -470,7 +470,6 @@ struct mlx4_en_priv {
 	u16 log_rx_info;
 
 	struct mlx4_en_tx_ring tx_ring[MAX_TX_RINGS];
-	int tx_vector;
 	struct mlx4_en_rx_ring rx_ring[MAX_RX_RINGS];
 	struct mlx4_en_cq tx_cq[MAX_TX_RINGS];
 	struct mlx4_en_cq rx_cq[MAX_RX_RINGS];
@@ -510,7 +509,8 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 		      int entries, int ring, enum cq_type mode);
 void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 			bool reserve_vectors);
-int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
+int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
+			int cq_idx);
 void mlx4_en_deactivate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 int mlx4_en_set_cq_moder(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
 int mlx4_en_arm_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq);
-- 
1.7.5.4
