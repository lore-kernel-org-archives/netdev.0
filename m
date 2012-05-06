From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4_en: num cores tx rings for every UP
Date: Sun,  6 May 2012 10:05:10 +0300
Message-ID: <1336287910-12010-3-git-send-email-amirv@mellanox.com>
References: <1336287910-12010-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Oren Duer <oren@mellanox.com>,
	Liran Liss <liranl@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:56358 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751558Ab2EFHFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2012 03:05:37 -0400
In-Reply-To: <1336287910-12010-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having num cores tx rings for untagged traffic and only 1 tx ring
per UP, allocate num cores * num UP's tx rings - There is no reason why all
cores will share the same tx_ring when using tagged traffic.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c   |    6 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   42 ++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   12 -------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    9 ++---
 4 files changed, 41 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 346fdb2..988b242 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -101,6 +101,8 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 	int i;
 
 	params->udp_rss = udp_rss;
+	params->num_tx_rings_p_up = min_t(int, num_online_cpus(),
+			MLX4_EN_MAX_TX_RING_P_UP);
 	if (params->udp_rss && !(mdev->dev->caps.flags
 					& MLX4_DEV_CAP_FLAG_UDP_RSS)) {
 		mlx4_warn(mdev, "UDP RSS is not supported on this device.\n");
@@ -113,8 +115,8 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].tx_ppp = pfctx;
 		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
 		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
-		params->prof[i].tx_ring_num = MLX4_EN_NUM_TX_RINGS +
-			MLX4_EN_NUM_PPP_RINGS;
+		params->prof[i].tx_ring_num = params->num_tx_rings_p_up *
+			MLX4_EN_NUM_UP;
 		params->prof[i].rss_rings = 0;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index eaa8fad..9cf85ba 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -47,12 +47,20 @@
 
 static int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 {
-	if (up != MLX4_EN_NUM_UP)
+	if (up && up != MLX4_EN_NUM_UP)
 		return -EINVAL;
 
 	return 0;
 }
 
+static int mlx4_en_set_pg_type(struct net_device *dev, u8 pg_type)
+{
+	if (pg_type != PGROUP_UP)
+		return -EINVAL;
+
+	return netdev_set_pg_type(dev, pg_type);
+}
+
 static int mlx4_en_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -661,7 +669,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		/* Configure ring */
 		tx_ring = &priv->tx_ring[i];
 		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn,
-				max(0, i - MLX4_EN_NUM_TX_RINGS));
+			i / priv->mdev->profile.num_tx_rings_p_up);
 		if (err) {
 			en_err(priv, "Failed allocating Tx ring\n");
 			mlx4_en_deactivate_cq(priv, cq);
@@ -986,6 +994,9 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 
 	mlx4_en_free_resources(priv);
 
+	kfree(priv->tx_ring);
+	kfree(priv->tx_cq);
+
 	free_netdev(dev);
 }
 
@@ -1043,7 +1054,6 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
 	.ndo_start_xmit		= mlx4_en_xmit,
-	.ndo_select_queue	= mlx4_en_select_queue,
 	.ndo_get_stats		= mlx4_en_get_stats,
 	.ndo_set_rx_mode	= mlx4_en_set_multicast,
 	.ndo_set_mac_address	= mlx4_en_set_mac,
@@ -1057,6 +1067,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #endif
 	.ndo_set_features	= mlx4_en_set_features,
 	.ndo_setup_tc		= mlx4_en_setup_tc,
+	.ndo_set_pg_type	= mlx4_en_set_pg_type,
 };
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
@@ -1066,6 +1077,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	struct mlx4_en_priv *priv;
 	int i;
 	int err;
+	unsigned int q, offset = 0;
 
 	dev = alloc_etherdev_mqs(sizeof(struct mlx4_en_priv),
 	    prof->tx_ring_num, prof->rx_ring_num);
@@ -1091,6 +1103,18 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->ctrl_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
 			MLX4_WQE_CTRL_SOLICITED);
 	priv->tx_ring_num = prof->tx_ring_num;
+	priv->tx_ring = kzalloc(sizeof(struct mlx4_en_tx_ring) *
+			priv->tx_ring_num, GFP_KERNEL);
+	if (!priv->tx_ring) {
+		err = -ENOMEM;
+		goto out;
+	}
+	priv->tx_cq = kzalloc(sizeof(struct mlx4_en_cq) * priv->tx_ring_num,
+			GFP_KERNEL);
+	if (!priv->tx_cq) {
+		err = -ENOMEM;
+		goto out;
+	}
 	priv->rx_ring_num = prof->rx_ring_num;
 	priv->mac_index = -1;
 	priv->msg_enable = MLX4_EN_MSG_LEVEL;
@@ -1140,12 +1164,12 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	netdev_set_num_tc(dev, MLX4_EN_NUM_UP);
 
-	/* First 9 rings are for UP 0 */
-	netdev_set_tc_queue(dev, 0, MLX4_EN_NUM_TX_RINGS + 1, 0);
-
-	/* Partition Tx queues evenly amongst UP's 1-7 */
-	for (i = 1; i < MLX4_EN_NUM_UP; i++)
-		netdev_set_tc_queue(dev, i, 1, MLX4_EN_NUM_TX_RINGS + i);
+	/* Partition Tx queues evenly amongst UP's */
+	q = priv->tx_ring_num / MLX4_EN_NUM_UP;
+	for (i = 0; i < MLX4_EN_NUM_UP; i++) {
+		netdev_set_tc_queue(dev, i, q, offset);
+		offset += q;
+	}
 
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 9a38483..ac735d2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -523,18 +523,6 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 }
 
-u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
-{
-	u16 vlan_tag = 0;
-
-	if (vlan_tx_tag_present(skb)) {
-		vlan_tag = vlan_tx_tag_get(skb);
-		return MLX4_EN_NUM_TX_RINGS + (vlan_tag >> 13);
-	}
-
-	return skb_tx_hash(dev, skb);
-}
-
 static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
 {
 	__iowrite64_copy(dst, src, bytecnt / 8);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 5d87637..6ae3509 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -111,9 +111,7 @@ enum {
 #define MLX4_EN_MIN_TX_SIZE	(4096 / TXBB_SIZE)
 
 #define MLX4_EN_SMALL_PKT_SIZE		64
-#define MLX4_EN_NUM_TX_RINGS		8
-#define MLX4_EN_NUM_PPP_RINGS		8
-#define MAX_TX_RINGS			(MLX4_EN_NUM_TX_RINGS + MLX4_EN_NUM_PPP_RINGS)
+#define MLX4_EN_MAX_TX_RING_P_UP	32
 #define MLX4_EN_NUM_UP			8
 #define MLX4_EN_DEF_TX_RING_SIZE	512
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
@@ -339,6 +337,7 @@ struct mlx4_en_profile {
 	u32 active_ports;
 	u32 small_pkt_int;
 	u8 no_reset;
+	u8 num_tx_rings_p_up;
 	struct mlx4_en_port_profile prof[MLX4_MAX_PORTS + 1];
 };
 
@@ -477,9 +476,9 @@ struct mlx4_en_priv {
 	u16 num_frags;
 	u16 log_rx_info;
 
-	struct mlx4_en_tx_ring tx_ring[MAX_TX_RINGS];
+	struct mlx4_en_tx_ring *tx_ring;
 	struct mlx4_en_rx_ring rx_ring[MAX_RX_RINGS];
-	struct mlx4_en_cq tx_cq[MAX_TX_RINGS];
+	struct mlx4_en_cq *tx_cq;
 	struct mlx4_en_cq rx_cq[MAX_RX_RINGS];
 	struct work_struct mcast_task;
 	struct work_struct mac_task;
-- 
1.7.8.2
