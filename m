From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Ignore budget on TX napi polling
Date: Tue,  8 Jul 2014 11:28:12 +0300
Message-ID: <1404808092-29411-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46659 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752691AbaGHI2g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 04:28:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is recommended that TX work not count against the quota.
The cost of TX packet liberation is a minute percentage of what it costs to
process an RX frame. Furthermore, that SKB freeing makes memory available for
other paths in the stack.

Give the TX a larger budget and be more aggressive about cleaning up the Tx
descriptors this budget could be changed using ethtool:
$ ethtool -C eth1 tx-frames-irq <budget>

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  7 +++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  1 +
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 28 ++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  3 +++
 4 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index fa1a069..68d763d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -417,6 +417,8 @@ static int mlx4_en_get_coalesce(struct net_device *dev,
 
 	coal->tx_coalesce_usecs = priv->tx_usecs;
 	coal->tx_max_coalesced_frames = priv->tx_frames;
+	coal->tx_max_coalesced_frames_irq = priv->tx_work_limit;
+
 	coal->rx_coalesce_usecs = priv->rx_usecs;
 	coal->rx_max_coalesced_frames = priv->rx_frames;
 
@@ -426,6 +428,7 @@ static int mlx4_en_get_coalesce(struct net_device *dev,
 	coal->rx_coalesce_usecs_high = priv->rx_usecs_high;
 	coal->rate_sample_interval = priv->sample_interval;
 	coal->use_adaptive_rx_coalesce = priv->adaptive_rx_coal;
+
 	return 0;
 }
 
@@ -434,6 +437,9 @@ static int mlx4_en_set_coalesce(struct net_device *dev,
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
+	if (!coal->tx_max_coalesced_frames_irq)
+		return -EINVAL;
+
 	priv->rx_frames = (coal->rx_max_coalesced_frames ==
 			   MLX4_EN_AUTO_CONF) ?
 				MLX4_EN_RX_COAL_TARGET :
@@ -457,6 +463,7 @@ static int mlx4_en_set_coalesce(struct net_device *dev,
 	priv->rx_usecs_high = coal->rx_coalesce_usecs_high;
 	priv->sample_interval = coal->rate_sample_interval;
 	priv->adaptive_rx_coal = coal->use_adaptive_rx_coalesce;
+	priv->tx_work_limit = coal->tx_max_coalesced_frames_irq;
 
 	return mlx4_en_moderation_update(priv);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 7d4fb7b..f451382 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2473,6 +2473,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			MLX4_WQE_CTRL_SOLICITED);
 	priv->num_tx_rings_p_up = mdev->profile.num_tx_rings_p_up;
 	priv->tx_ring_num = prof->tx_ring_num;
+	priv->tx_work_limit = MLX4_EN_DEFAULT_TX_WORK;
 
 	priv->tx_ring = kzalloc(sizeof(struct mlx4_en_tx_ring *) * MAX_TX_RINGS,
 				GFP_KERNEL);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index ac3dead..5045bab 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -351,9 +351,8 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 	return cnt;
 }
 
-static int mlx4_en_process_tx_cq(struct net_device *dev,
-				 struct mlx4_en_cq *cq,
-				 int budget)
+static bool mlx4_en_process_tx_cq(struct net_device *dev,
+				 struct mlx4_en_cq *cq)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_cq *mcq = &cq->mcq;
@@ -372,9 +371,10 @@ static int mlx4_en_process_tx_cq(struct net_device *dev,
 	int factor = priv->cqe_factor;
 	u64 timestamp = 0;
 	int done = 0;
+	int budget = priv->tx_work_limit;
 
 	if (!priv->port_up)
-		return 0;
+		return true;
 
 	index = cons_index & size_mask;
 	cqe = &buf[(index << factor) + factor];
@@ -447,7 +447,7 @@ static int mlx4_en_process_tx_cq(struct net_device *dev,
 		netif_tx_wake_queue(ring->tx_queue);
 		ring->wake_queue++;
 	}
-	return done;
+	return done < budget;
 }
 
 void mlx4_en_tx_irq(struct mlx4_cq *mcq)
@@ -467,18 +467,16 @@ int mlx4_en_poll_tx_cq(struct napi_struct *napi, int budget)
 	struct mlx4_en_cq *cq = container_of(napi, struct mlx4_en_cq, napi);
 	struct net_device *dev = cq->dev;
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	int done;
+	int clean_complete;
 
-	done = mlx4_en_process_tx_cq(dev, cq, budget);
+	clean_complete = mlx4_en_process_tx_cq(dev, cq);
+	if (!clean_complete)
+		return budget;
 
-	/* If we used up all the quota - we're probably not done yet... */
-	if (done < budget) {
-		/* Done for now */
-		napi_complete(napi);
-		mlx4_en_arm_cq(priv, cq);
-		return done;
-	}
-	return budget;
+	napi_complete(napi);
+	mlx4_en_arm_cq(priv, cq);
+
+	return 0;
 }
 
 static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 624e193..d72a5a8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -126,6 +126,8 @@ enum {
 #define MAX_TX_RINGS			(MLX4_EN_MAX_TX_RING_P_UP * \
 					 MLX4_EN_NUM_UP)
 
+#define MLX4_EN_DEFAULT_TX_WORK		256
+
 /* Target number of packets to coalesce with interrupt moderation */
 #define MLX4_EN_RX_COAL_TARGET	44
 #define MLX4_EN_RX_COAL_TIME	0x10
@@ -543,6 +545,7 @@ struct mlx4_en_priv {
 	__be32 ctrl_flags;
 	u32 flags;
 	u8 num_tx_rings_p_up;
+	u32 tx_work_limit;
 	u32 tx_ring_num;
 	u32 rx_ring_num;
 	u32 rx_skb_size;
-- 
1.8.3.4
