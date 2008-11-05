From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general] [PATCH] mlx4_en: Pause parameters per port
Date: Wed, 05 Nov 2008 16:48:36 +0200
Message-ID: <4911B244.30205@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>, jgarzik@pobox.com
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

Before the change the driver reported the same pause parameters
for all the ports, even only one of them was modified.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    8 ++++----
 drivers/net/mlx4/en_params.c |   30 ++++++++++++++++--------------
 drivers/net/mlx4/mlx4_en.h   |    8 ++++----
 3 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index a339afb..12d736a 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -656,10 +656,10 @@ static int mlx4_en_start_port(struct net_device *dev)
 	/* Configure port */
 	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
 				    priv->rx_skb_size + ETH_FCS_LEN,
-				    mdev->profile.tx_pause,
-				    mdev->profile.tx_ppp,
-				    mdev->profile.rx_pause,
-				    mdev->profile.rx_ppp);
+				    priv->prof->tx_pause,
+				    priv->prof->tx_ppp,
+				    priv->prof->rx_pause,
+				    priv->prof->rx_ppp);
 	if (err) {
 		mlx4_err(mdev, "Failed setting port general configurations"
 			       " for port %d, with error %d\n", priv->port, err);
diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index c2e69b1..95706ee 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -90,6 +90,7 @@ MLX4_EN_PARM_INT(rx_ring_size2, MLX4_EN_AUTO_CONF, "Rx ring size for port 2");
 int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 {
 	struct mlx4_en_profile *params = &mdev->profile;
+	int i;

 	params->rx_moder_cnt = min_t(int, rx_moder_cnt, MLX4_EN_AUTO_CONF);
 	params->rx_moder_time = min_t(int, rx_moder_time, MLX4_EN_AUTO_CONF);
@@ -97,11 +98,13 @@ int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 	params->rss_xor = (rss_xor != 0);
 	params->rss_mask = rss_mask & 0x1f;
 	params->num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);
-	params->rx_pause = pprx;
-	params->rx_ppp = pfcrx;
-	params->tx_pause = pptx;
-	params->tx_ppp = pfctx;
-	if (params->rx_ppp || params->tx_ppp) {
+	for (i = 1; i <= MLX4_MAX_PORTS; i++) {
+		params->prof[i].rx_pause = pprx;
+		params->prof[i].rx_ppp = pfcrx;
+		params->prof[i].tx_pause = pptx;
+		params->prof[i].tx_ppp = pfctx;
+	}
+	if (pfcrx || pfctx) {
 		params->prof[1].tx_ring_num = MLX4_EN_TX_RING_NUM;
 		params->prof[2].tx_ring_num = MLX4_EN_TX_RING_NUM;
 	} else {
@@ -407,14 +410,14 @@ static int mlx4_en_set_pauseparam(struct net_device *dev,
 	struct mlx4_en_dev *mdev = priv->mdev;
 	int err;

-	mdev->profile.tx_pause = pause->tx_pause != 0;
-	mdev->profile.rx_pause = pause->rx_pause != 0;
+	priv->prof->tx_pause = pause->tx_pause != 0;
+	priv->prof->rx_pause = pause->rx_pause != 0;
 	err = mlx4_SET_PORT_general(mdev->dev, priv->port,
 				    priv->rx_skb_size + ETH_FCS_LEN,
-				    mdev->profile.tx_pause,
-				    mdev->profile.tx_ppp,
-				    mdev->profile.rx_pause,
-				    mdev->profile.rx_ppp);
+				    priv->prof->tx_pause,
+				    priv->prof->tx_ppp,
+				    priv->prof->rx_pause,
+				    priv->prof->rx_ppp);
 	if (err)
 		mlx4_err(mdev, "Failed setting pause params to\n");

@@ -425,10 +428,9 @@ static void mlx4_en_get_pauseparam(struct net_device *dev,
 				 struct ethtool_pauseparam *pause)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;

-	pause->tx_pause = mdev->profile.tx_pause;
-	pause->rx_pause = mdev->profile.rx_pause;
+	pause->tx_pause = priv->prof->tx_pause;
+	pause->rx_pause = priv->prof->rx_pause;
 }

 static void mlx4_en_get_ringparam(struct net_device *dev,
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 11fb17c..98ddc08 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -322,6 +322,10 @@ struct mlx4_en_port_profile {
 	u32 rx_ring_num;
 	u32 tx_ring_size;
 	u32 rx_ring_size;
+	u8 rx_pause;
+	u8 rx_ppp;
+	u8 tx_pause;
+	u8 tx_ppp;
 };

 struct mlx4_en_profile {
@@ -333,10 +337,6 @@ struct mlx4_en_profile {
 	int rx_moder_cnt;
 	int rx_moder_time;
 	int auto_moder;
-	u8 rx_pause;
-	u8 rx_ppp;
-	u8 tx_pause;
-	u8 tx_ppp;
 	u8 no_reset;
 	struct mlx4_en_port_profile prof[MLX4_MAX_PORTS + 1];
 };
-- 
1.5.4
