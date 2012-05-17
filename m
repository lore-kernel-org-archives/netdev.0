From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next] net/mlx4_en: num cores tx rings for every UP
Date: Thu, 17 May 2012 13:58:10 +0300
Message-ID: <1337252290-20444-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Liran Liss <liranl@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:60117 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1761545Ab2EQK6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 06:58:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the TX ring scheme such that the number of rings for untagged packets
and for tagged packets (per each of the vlan priorities) is the same, unlike
the current situation where for tagged traffic there's one ring per priority
and for untagged rings as the number of core.

Queue selection is done as follows:

If the mqprio qdisc is operates on the interface, such that the core networking
code invoked the device setup_tc ndo callback, a mapping of skb->priority =>
queue set is forced - for both, tagged and untagged traffic.

Else, the egress map skb->priority =>  User priority is used for tagged traffic, and
all untagged traffic is sent through tx rings of UP 0.

The patch follows the convergence of discussing that issue with John Fastabend
over this thread http://comments.gmane.org/gmane.linux.network/229877

Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Liran Liss <liranl@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_main.c   |    6 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   41 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   15 +++++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    9 ++---
 4 files changed, 47 insertions(+), 24 deletions(-)

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
index eaa8fad..926d8aa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -47,9 +47,22 @@
 
 static int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 {
-	if (up != MLX4_EN_NUM_UP)
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int i;
+	unsigned int q, offset = 0;
+
+	if (up && up != MLX4_EN_NUM_UP)
 		return -EINVAL;
 
+	netdev_set_num_tc(dev, up);
+
+	/* Partition Tx queues evenly amongst UP's */
+	q = priv->tx_ring_num / up;
+	for (i = 0; i < up; i++) {
+		netdev_set_tc_queue(dev, i, q, offset);
+		offset += q;
+	}
+
 	return 0;
 }
 
@@ -661,7 +674,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		/* Configure ring */
 		tx_ring = &priv->tx_ring[i];
 		err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn,
-				max(0, i - MLX4_EN_NUM_TX_RINGS));
+			i / priv->mdev->profile.num_tx_rings_p_up);
 		if (err) {
 			en_err(priv, "Failed allocating Tx ring\n");
 			mlx4_en_deactivate_cq(priv, cq);
@@ -986,6 +999,9 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 
 	mlx4_en_free_resources(priv);
 
+	kfree(priv->tx_ring);
+	kfree(priv->tx_cq);
+
 	free_netdev(dev);
 }
 
@@ -1091,6 +1107,18 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
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
@@ -1138,15 +1166,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
-	netdev_set_num_tc(dev, MLX4_EN_NUM_UP);
-
-	/* First 9 rings are for UP 0 */
-	netdev_set_tc_queue(dev, 0, MLX4_EN_NUM_TX_RINGS + 1, 0);
-
-	/* Partition Tx queues evenly amongst UP's 1-7 */
-	for (i = 1; i < MLX4_EN_NUM_UP; i++)
-		netdev_set_tc_queue(dev, i, 1, MLX4_EN_NUM_TX_RINGS + i);
-
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
 
 	/* Set defualt MAC */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 9a38483..019d856 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -525,14 +525,17 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	u16 vlan_tag = 0;
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	u16 rings_p_up = priv->mdev->profile.num_tx_rings_p_up;
+	u8 up = 0;
 
-	if (vlan_tx_tag_present(skb)) {
-		vlan_tag = vlan_tx_tag_get(skb);
-		return MLX4_EN_NUM_TX_RINGS + (vlan_tag >> 13);
-	}
+	if (dev->num_tc)
+		return skb_tx_hash(dev, skb);
+
+	if (vlan_tx_tag_present(skb))
+		up = vlan_tx_tag_get(skb) >> VLAN_PRIO_SHIFT;
 
-	return skb_tx_hash(dev, skb);
+	return __skb_tx_hash(dev, skb, rings_p_up) + up * rings_p_up;
 }
 
 static void mlx4_bf_copy(void __iomem *dst, unsigned long *src, unsigned bytecnt)
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
