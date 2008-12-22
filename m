From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general] [PATCH 8/9] mlx4_en: Added "set_ringparam" Ethtool
	interface implementation
Date: Mon, 22 Dec 2008 12:01:32 +0200
Message-ID: <494F657C.2080100@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Now using Ethtool to determine ring sizes, removed the module parameters
that controlled those values.
Modifying ring size requires restart of the interface.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    8 ++--
 drivers/net/mlx4/en_params.c |   80 ++++++++++++++++++++++++++---------------
 drivers/net/mlx4/mlx4_en.h   |    6 +++
 3 files changed, 61 insertions(+), 33 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 8b5e8f0..07a939a 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -552,7 +552,7 @@ static void mlx4_en_linkstate(struct work_struct *work)
 }


-static int mlx4_en_start_port(struct net_device *dev)
+int mlx4_en_start_port(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
@@ -707,7 +707,7 @@ cq_err:
 }


-static void mlx4_en_stop_port(struct net_device *dev)
+void mlx4_en_stop_port(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
@@ -826,7 +826,7 @@ static int mlx4_en_close(struct net_device *dev)
 	return 0;
 }

-static void mlx4_en_free_resources(struct mlx4_en_priv *priv)
+void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 {
 	int i;

@@ -845,7 +845,7 @@ static void mlx4_en_free_resources(struct mlx4_en_priv *priv)
 	}
 }

-static int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
+int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_port_profile *prof = priv->prof;
diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index 6483ae9..cfeef0f 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -65,12 +65,6 @@ MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
 MLX4_EN_PARM_INT(pfcrx, 0, "Priority based Flow Control policy on RX[7:0]."
 			   " Per priority bit mask");

-MLX4_EN_PARM_INT(tx_ring_size1, MLX4_EN_AUTO_CONF, "Tx ring size for port 1");
-MLX4_EN_PARM_INT(tx_ring_size2, MLX4_EN_AUTO_CONF, "Tx ring size for port 2");
-MLX4_EN_PARM_INT(rx_ring_size1, MLX4_EN_AUTO_CONF, "Rx ring size for port 1");
-MLX4_EN_PARM_INT(rx_ring_size2, MLX4_EN_AUTO_CONF, "Rx ring size for port 2");
-
-
 int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 {
 	struct mlx4_en_profile *params = &mdev->profile;
@@ -84,6 +78,8 @@ int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].rx_ppp = pfcrx;
 		params->prof[i].tx_pause = 1;
 		params->prof[i].tx_ppp = pfctx;
+		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
+		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
 	}
 	if (pfcrx || pfctx) {
 		params->prof[1].tx_ring_num = MLX4_EN_TX_RING_NUM;
@@ -93,29 +89,6 @@ int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[2].tx_ring_num = 1;
 	}

-	if (tx_ring_size1 == MLX4_EN_AUTO_CONF)
-		tx_ring_size1 = MLX4_EN_DEF_TX_RING_SIZE;
-	params->prof[1].tx_ring_size =
-		(tx_ring_size1 < MLX4_EN_MIN_TX_SIZE) ?
-		 MLX4_EN_MIN_TX_SIZE : roundup_pow_of_two(tx_ring_size1);
-
-	if (tx_ring_size2 == MLX4_EN_AUTO_CONF)
-		tx_ring_size2 = MLX4_EN_DEF_TX_RING_SIZE;
-	params->prof[2].tx_ring_size =
-		(tx_ring_size2 < MLX4_EN_MIN_TX_SIZE) ?
-		 MLX4_EN_MIN_TX_SIZE : roundup_pow_of_two(tx_ring_size2);
-
-	if (rx_ring_size1 == MLX4_EN_AUTO_CONF)
-		rx_ring_size1 = MLX4_EN_DEF_RX_RING_SIZE;
-	params->prof[1].rx_ring_size =
-		(rx_ring_size1 < MLX4_EN_MIN_RX_SIZE) ?
-		 MLX4_EN_MIN_RX_SIZE : roundup_pow_of_two(rx_ring_size1);
-
-	if (rx_ring_size2 == MLX4_EN_AUTO_CONF)
-		rx_ring_size2 = MLX4_EN_DEF_RX_RING_SIZE;
-	params->prof[2].rx_ring_size =
-		(rx_ring_size2 < MLX4_EN_MIN_RX_SIZE) ?
-		 MLX4_EN_MIN_RX_SIZE : roundup_pow_of_two(rx_ring_size2);
 	return 0;
 }

@@ -412,6 +385,54 @@ static void mlx4_en_get_pauseparam(struct net_device *dev,
 	pause->rx_pause = priv->prof->rx_pause;
 }

+static int mlx4_en_set_ringparam(struct net_device *dev,
+				 struct ethtool_ringparam *param)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	u32 rx_size, tx_size;
+	int port_up = 0;
+	int err = 0;
+
+	if (param->rx_jumbo_pending || param->rx_mini_pending)
+		return -EINVAL;
+
+	rx_size = roundup_pow_of_two(param->rx_pending);
+	rx_size = max_t(u32, rx_size, MLX4_EN_MIN_RX_SIZE);
+	tx_size = roundup_pow_of_two(param->tx_pending);
+	tx_size = max_t(u32, tx_size, MLX4_EN_MIN_TX_SIZE);
+
+	if (rx_size == priv->prof->rx_ring_size &&
+	    tx_size == priv->prof->tx_ring_size)
+		return 0;
+
+	mutex_lock(&mdev->state_lock);
+	if (priv->port_up) {
+		port_up = 1;
+		mlx4_en_stop_port(dev);
+	}
+
+	mlx4_en_free_resources(priv);
+
+	priv->prof->tx_ring_size = tx_size;
+	priv->prof->rx_ring_size = rx_size;
+
+	err = mlx4_en_alloc_resources(priv);
+	if (err) {
+		mlx4_err(mdev, "Failed reallocating port resources\n");
+		goto out;
+	}
+	if (port_up) {
+		err = mlx4_en_start_port(dev);
+		if (err)
+			mlx4_err(mdev, "Failed starting port\n");
+	}
+
+out:
+	mutex_unlock(&mdev->state_lock);
+	return err;
+}
+
 static void mlx4_en_get_ringparam(struct net_device *dev,
 				  struct ethtool_ringparam *param)
 {
@@ -451,6 +472,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_pauseparam = mlx4_en_get_pauseparam,
 	.set_pauseparam = mlx4_en_set_pauseparam,
 	.get_ringparam = mlx4_en_get_ringparam,
+	.set_ringparam = mlx4_en_set_ringparam,
 	.get_flags = ethtool_op_get_flags,
 	.set_flags = ethtool_op_set_flags,
 };
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 63c42e4..76c9ad3 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -489,6 +489,12 @@ void mlx4_en_destroy_netdev(struct net_device *dev);
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			struct mlx4_en_port_profile *prof);

+int mlx4_en_start_port(struct net_device *dev);
+void mlx4_en_stop_port(struct net_device *dev);
+
+void mlx4_en_free_resources(struct mlx4_en_priv *priv);
+int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
+
 int mlx4_en_get_profile(struct mlx4_en_dev *mdev);

 int mlx4_en_create_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
-- 
1.5.4
