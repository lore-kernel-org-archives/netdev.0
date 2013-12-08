From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 07/12] net/mlx4_en: Configure the XPS queue mapping on driver load
Date: Sun,  8 Dec 2013 14:35:47 +0200
Message-ID: <1386506152-10298-8-git-send-email-amirv@mellanox.com>
References: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40350 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752127Ab3LHMgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Dec 2013 07:36:12 -0500
In-Reply-To: <1386506152-10298-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Only TX rings of User Piority 0 are mapped.
TX rings of other UP's are using UP 0 mapping.
XPS is not in use when num_tc is set.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 6 ++++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 9 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 7 +++++--
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 44a1cc2..c9bc292 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1914,8 +1914,10 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 				      prof->tx_ring_size, i, TX, node))
 			goto err;
 
-		if (mlx4_en_create_tx_ring(priv, &priv->tx_ring[i], priv->base_tx_qpn + i,
-					   prof->tx_ring_size, TXBB_SIZE, node))
+		if (mlx4_en_create_tx_ring(priv, &priv->tx_ring[i],
+					   priv->base_tx_qpn + i,
+					   prof->tx_ring_size, TXBB_SIZE,
+					   node, i))
 			goto err;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index f54ebd5..5e22d7d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -55,7 +55,7 @@ MODULE_PARM_DESC(inline_thold, "threshold for using inline data");
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_tx_ring **pring, int qpn, u32 size,
-			   u16 stride, int node)
+			   u16 stride, int node, int queue_index)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_tx_ring *ring;
@@ -140,6 +140,10 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 		ring->bf_enabled = true;
 
 	ring->hwtstamp_tx_type = priv->hwtstamp_config.tx_type;
+	ring->queue_index = queue_index;
+
+	if (queue_index < priv->num_tx_rings_p_up && cpu_online(queue_index))
+		cpumask_set_cpu(queue_index, &ring->affinity_mask);
 
 	*pring = ring;
 	return 0;
@@ -206,6 +210,9 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 
 	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, &ring->context,
 			       &ring->qp, &ring->qp_state);
+	if (!user_prio && cpu_online(ring->queue_index))
+		netif_set_xps_queue(priv->dev, &ring->affinity_mask,
+				    ring->queue_index);
 
 	return err;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index fa33a83..a4cdd7d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -241,6 +241,8 @@ struct mlx4_en_tx_ring {
 	u16 poll_cnt;
 	struct mlx4_en_tx_info *tx_info;
 	u8 *bounce_buf;
+	u8 queue_index;
+	cpumask_t affinity_mask;
 	u32 last_nr_txbb;
 	struct mlx4_qp qp;
 	struct mlx4_qp_context context;
@@ -708,8 +710,9 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb);
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
-			   struct mlx4_en_tx_ring **pring,
-			   int qpn, u32 size, u16 stride, int node);
+			struct mlx4_en_tx_ring **pring,
+			int qpn, u32 size, u16 stride,
+			int node, int queue_index);
 void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring **pring);
 int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
-- 
1.8.3.4
