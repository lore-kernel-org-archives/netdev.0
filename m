From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next v1 3/3] net/mlx4_en: Set number of rx/tx channels using ethtool
Date: Thu, 29 Nov 2012 21:21:43 +0200
Message-ID: <1354216903-830-4-git-send-email-amirv@mellanox.com>
References: <1354216903-830-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Oren Duer <oren@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:33589 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753570Ab2K2TWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 14:22:01 -0500
In-Reply-To: <1354216903-830-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to changing number of rx/tx channels using
ethtool ('ethtool -[lL]'). Where the number of tx channels specified in ethtool
is the number of rings per user priority - not total number of tx rings.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   69 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   26 +++++----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    8 ++-
 5 files changed, 93 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index dc8ccb4..681bc1b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -999,6 +999,73 @@ static int mlx4_en_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return err;
 }
 
+static void mlx4_en_get_channels(struct net_device *dev,
+		struct ethtool_channels *channel)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	memset(channel, 0, sizeof(*channel));
+
+	channel->max_rx = MAX_RX_RINGS;
+	channel->max_tx = MLX4_EN_MAX_TX_RING_P_UP;
+
+	channel->rx_count = priv->rx_ring_num;
+	channel->tx_count = priv->tx_ring_num / MLX4_EN_NUM_UP;
+}
+
+static int mlx4_en_set_channels(struct net_device *dev,
+		struct ethtool_channels *channel)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int port_up;
+	int err = 0;
+
+	if (channel->other_count || channel->combined_count ||
+	    channel->tx_count > channel->max_tx ||
+	    channel->rx_count > channel->max_rx ||
+	    !channel->tx_count || !channel->rx_count)
+		return -EINVAL;
+
+	mutex_lock(&mdev->state_lock);
+	if (priv->port_up) {
+		port_up = 1;
+		mlx4_en_stop_port(dev);
+	}
+
+	mlx4_en_free_resources(priv);
+
+	priv->num_tx_rings_p_up = channel->tx_count;
+	priv->tx_ring_num = channel->tx_count * MLX4_EN_NUM_UP;
+	priv->rx_ring_num = channel->rx_count;
+
+	err = mlx4_en_alloc_resources(priv);
+	if (err) {
+		en_err(priv, "Failed reallocating port resources\n");
+		goto out;
+	}
+
+	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
+	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
+
+	mlx4_en_setup_tc(dev, MLX4_EN_NUM_UP);
+
+	en_warn(priv, "Using %d TX rings\n", priv->tx_ring_num);
+	en_warn(priv, "Using %d RX rings\n", priv->rx_ring_num);
+
+	if (port_up) {
+		err = mlx4_en_start_port(dev);
+		if (err)
+			en_err(priv, "Failed starting port\n");
+	}
+
+	err = mlx4_en_moderation_update(priv);
+
+out:
+	mutex_unlock(&mdev->state_lock);
+	return err;
+}
+
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
 	.get_settings = mlx4_en_get_settings,
@@ -1023,6 +1090,8 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_rxfh_indir_size = mlx4_en_get_rxfh_indir_size,
 	.get_rxfh_indir = mlx4_en_get_rxfh_indir,
 	.set_rxfh_indir = mlx4_en_set_rxfh_indir,
+	.get_channels = mlx4_en_get_channels,
+	.set_channels = mlx4_en_set_channels,
 };
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index a52922e..3a2b8c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -250,7 +250,7 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 				rounddown_pow_of_two(max_t(int, MIN_RX_RINGS,
 							   min_t(int,
 								 dev->caps.num_comp_vectors,
-								 MAX_RX_RINGS)));
+								 DEF_RX_RINGS)));
 		} else {
 			mdev->profile.prof[i].rx_ring_num = rounddown_pow_of_two(
 				min_t(int, dev->caps.comp_pool/
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 2b23ca2..7d1287f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -47,11 +47,11 @@
 #include "mlx4_en.h"
 #include "en_port.h"
 
-static int mlx4_en_setup_tc(struct net_device *dev, u8 up)
+int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int i;
-	unsigned int q, offset = 0;
+	unsigned int offset = 0;
 
 	if (up && up != MLX4_EN_NUM_UP)
 		return -EINVAL;
@@ -59,10 +59,9 @@ static int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 	netdev_set_num_tc(dev, up);
 
 	/* Partition Tx queues evenly amongst UP's */
-	q = priv->tx_ring_num / up;
 	for (i = 0; i < up; i++) {
-		netdev_set_tc_queue(dev, i, q, offset);
-		offset += q;
+		netdev_set_tc_queue(dev, i, priv->num_tx_rings_p_up, offset);
+		offset += priv->num_tx_rings_p_up;
 	}
 
 	return 0;
@@ -1114,7 +1113,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		/* Configure ring */
 		tx_ring = &priv->tx_ring[i];
 		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn,
-			i / priv->mdev->profile.num_tx_rings_p_up);
+			i / priv->num_tx_rings_p_up);
 		if (err) {
 			en_err(priv, "Failed allocating Tx ring\n");
 			mlx4_en_deactivate_cq(priv, cq);
@@ -1564,10 +1563,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	int err;
 
 	dev = alloc_etherdev_mqs(sizeof(struct mlx4_en_priv),
-	    prof->tx_ring_num, prof->rx_ring_num);
+				 MAX_TX_RINGS, MAX_RX_RINGS);
 	if (dev == NULL)
 		return -ENOMEM;
 
+	netif_set_real_num_tx_queues(dev, prof->tx_ring_num);
+	netif_set_real_num_rx_queues(dev, prof->rx_ring_num);
+
 	SET_NETDEV_DEV(dev, &mdev->dev->pdev->dev);
 	dev->dev_id =  port - 1;
 
@@ -1586,15 +1588,17 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->flags = prof->flags;
 	priv->ctrl_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
 			MLX4_WQE_CTRL_SOLICITED);
+	priv->num_tx_rings_p_up = mdev->profile.num_tx_rings_p_up;
 	priv->tx_ring_num = prof->tx_ring_num;
-	priv->tx_ring = kzalloc(sizeof(struct mlx4_en_tx_ring) *
-			priv->tx_ring_num, GFP_KERNEL);
+
+	priv->tx_ring = kzalloc(sizeof(struct mlx4_en_tx_ring) * MAX_TX_RINGS,
+				GFP_KERNEL);
 	if (!priv->tx_ring) {
 		err = -ENOMEM;
 		goto out;
 	}
-	priv->tx_cq = kzalloc(sizeof(struct mlx4_en_cq) * priv->tx_ring_num,
-			GFP_KERNEL);
+	priv->tx_cq = kzalloc(sizeof(struct mlx4_en_cq) * MAX_RX_RINGS,
+			      GFP_KERNEL);
 	if (!priv->tx_cq) {
 		err = -ENOMEM;
 		goto out;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index b35094c..1f571d0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -523,7 +523,7 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	u16 rings_p_up = priv->mdev->profile.num_tx_rings_p_up;
+	u16 rings_p_up = priv->num_tx_rings_p_up;
 	u8 up = 0;
 
 	if (dev->num_tc)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index d3eba8b..334ec48 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -67,7 +67,8 @@
 
 #define MLX4_EN_PAGE_SHIFT	12
 #define MLX4_EN_PAGE_SIZE	(1 << MLX4_EN_PAGE_SHIFT)
-#define MAX_RX_RINGS		16
+#define DEF_RX_RINGS		16
+#define MAX_RX_RINGS		128
 #define MIN_RX_RINGS		4
 #define TXBB_SIZE		64
 #define HEADROOM		(2048 / TXBB_SIZE + 1)
@@ -118,6 +119,8 @@ enum {
 #define MLX4_EN_NUM_UP			8
 #define MLX4_EN_DEF_TX_RING_SIZE	512
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
+#define MAX_TX_RINGS			(MLX4_EN_MAX_TX_RING_P_UP * \
+					 MLX4_EN_NUM_UP)
 
 /* Target number of packets to coalesce with interrupt moderation */
 #define MLX4_EN_RX_COAL_TARGET	44
@@ -476,6 +479,7 @@ struct mlx4_en_priv {
 	u32 flags;
 #define MLX4_EN_FLAG_PROMISC	0x1
 #define MLX4_EN_FLAG_MC_PROMISC	0x2
+	u8 num_tx_rings_p_up;
 	u32 tx_ring_num;
 	u32 rx_ring_num;
 	u32 rx_skb_size;
@@ -596,6 +600,8 @@ int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
 extern const struct dcbnl_rtnl_ops mlx4_en_dcbnl_ops;
 #endif
 
+int mlx4_en_setup_tc(struct net_device *dev, u8 up);
+
 #ifdef CONFIG_RFS_ACCEL
 void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv,
 			     struct mlx4_en_rx_ring *rx_ring);
-- 
1.7.8.2
