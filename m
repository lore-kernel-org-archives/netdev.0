From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH 8/8] net/mlx4_en: num cores tx rings for every UP
Date: Tue, 13 Mar 2012 19:22:03 +0200
Message-ID: <1331659323-12904-9-git-send-email-amirv@mellanox.com>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:42141 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758615Ab2CMRWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 13:22:25 -0400
In-Reply-To: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Instead of having num cores tx rings for untagged traffic and only 1 tx ring
per UP, allocate num cores * num UP's tx rings - There is no reason why all
cores will share the same tx_ring when using tagged traffic.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c   |    6 ++++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   23 ++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    5 +++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    6 ++++--
 4 files changed, 31 insertions(+), 9 deletions(-)

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
index 22c4da6..993e148 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -659,7 +659,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		/* Configure ring */
 		tx_ring = &priv->tx_ring[i];
 		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn,
-				max(0, i - MLX4_EN_NUM_TX_RINGS));
+			i / priv->mdev->profile.num_tx_rings_p_up);
 		if (err) {
 			en_err(priv, "Failed allocating Tx ring\n");
 			mlx4_en_deactivate_cq(priv, cq);
@@ -991,6 +991,8 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 #ifdef CONFIG_MLX4_EN_DCB
 	vfree(priv->mlx4_en_ieee_ets);
 #endif
+	vfree(priv->tx_ring);
+	vfree(priv->tx_cq);
 
 	free_netdev(dev);
 }
@@ -1073,6 +1075,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	struct mlx4_en_priv *priv;
 	int i;
 	int err;
+	unsigned int q, offset = 0;
 
 	dev = alloc_etherdev_mqs(sizeof(struct mlx4_en_priv),
 	    prof->tx_ring_num, prof->rx_ring_num);
@@ -1098,6 +1101,17 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->ctrl_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
 			MLX4_WQE_CTRL_SOLICITED);
 	priv->tx_ring_num = prof->tx_ring_num;
+	priv->tx_ring = vzalloc(sizeof(struct mlx4_en_tx_ring) *
+			priv->tx_ring_num);
+	if (!priv->tx_ring) {
+		err = -ENOMEM;
+		goto out;
+	}
+	priv->tx_cq = vzalloc(sizeof(struct mlx4_en_cq) * priv->tx_ring_num);
+	if (!priv->tx_cq) {
+		err = -ENOMEM;
+		goto out;
+	}
 	priv->rx_ring_num = prof->rx_ring_num;
 	priv->mac_index = -1;
 	priv->msg_enable = MLX4_EN_MSG_LEVEL;
@@ -1155,8 +1169,11 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	netdev_set_num_tc(dev, MLX4_EN_NUM_UP);
 
 	/* Partition Tx queues evenly amongst UP's */
-	for (i = 0; i < MLX4_EN_NUM_UP; i++)
-		netdev_set_tc_queue(dev, i, 1, MLX4_EN_NUM_TX_RINGS + i);
+	q = priv->tx_ring_num / MLX4_EN_NUM_UP;
+	for (i = 0; i < MLX4_EN_NUM_UP; i++) {
+		netdev_set_tc_queue(dev, i, q, offset);
+		offset += q;
+	}
 
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index d0d96e3..c9b9e84 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -570,6 +570,8 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	u16 qcount = priv->mdev->profile.num_tx_rings_p_up;
 	int up = 0;
 
 	if (vlan_tx_tag_present(skb))
@@ -577,8 +579,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 	else if (dev->num_tc)
 		up = netdev_get_prio_tc_map(dev, skb->priority);
 
-	return __skb_tx_hash(dev, skb, MLX4_EN_NUM_TX_RINGS,
-			MLX4_EN_NUM_TX_RINGS + up, 1);
+	return __skb_tx_hash(dev, skb, qcount, qcount * up, qcount);
 }
 
 static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 32b447d..a739d3e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -113,6 +113,7 @@ enum {
 #define MLX4_EN_NUM_TX_RINGS		8
 #define MLX4_EN_NUM_PPP_RINGS		8
 #define MAX_TX_RINGS			(MLX4_EN_NUM_TX_RINGS + MLX4_EN_NUM_PPP_RINGS)
+#define MLX4_EN_MAX_TX_RING_P_UP	32
 #define MLX4_EN_NUM_UP			8
 #define MLX4_EN_DEF_TX_RING_SIZE	512
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
@@ -339,6 +340,7 @@ struct mlx4_en_profile {
 	u32 active_ports;
 	u32 small_pkt_int;
 	u8 no_reset;
+	u8 num_tx_rings_p_up;
 	struct mlx4_en_port_profile prof[MLX4_MAX_PORTS + 1];
 };
 
@@ -477,9 +479,9 @@ struct mlx4_en_priv {
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
