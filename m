From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx4_en: Add mlx4_en_get_cqe helper
Date: Thu, 18 Sep 2014 11:51:01 +0300
Message-ID: <1411030261-12145-4-git-send-email-ogerlitz@mellanox.com>
References: <1411030261-12145-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34932 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752976AbaIRIvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 04:51:07 -0400
In-Reply-To: <1411030261-12145-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

This function derives the base address of the CQE from the CQE size,
and calculates the real CQE context segment in it from the factor
(this is like before). Before this change the code used the factor to
calculate the base address of the CQE as well.

The factor indicates in which segment of the cqe stride the cqe information
is located. For 32-byte strides, the segment is 0, and for 64 byte strides,
the segment is 1 (bytes 32..63). Using the factor was ok as long as we had
only 32 and 64 byte strides. However, with larger strides, the factor is zero,
and so cannot be used to calculate the base of the CQE.

The helper uses the same method of CQE buffer pulling made by all other
components that reads the CQE buffer (mlx4_ib driver and libmlx4).

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    1 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    6 ++++++
 4 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index abddcf8..f3032fe 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2459,6 +2459,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 	priv->rx_ring_num = prof->rx_ring_num;
 	priv->cqe_factor = (mdev->dev->caps.cqe_size == 64) ? 1 : 0;
+	priv->cqe_size = mdev->dev->caps.cqe_size;
 	priv->mac_index = -1;
 	priv->msg_enable = MLX4_EN_MSG_LEVEL;
 	spin_lock_init(&priv->stats_lock);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 14686b6..a33048e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -671,7 +671,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	 * descriptor offset can be deduced from the CQE index instead of
 	 * reading 'cqe->index' */
 	index = cq->mcq.cons_index & ring->size_mask;
-	cqe = &cq->buf[(index << factor) + factor];
+	cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
 
 	/* Process all completed CQEs */
 	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
@@ -858,7 +858,7 @@ next:
 
 		++cq->mcq.cons_index;
 		index = (cq->mcq.cons_index) & ring->size_mask;
-		cqe = &cq->buf[(index << factor) + factor];
+		cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
 		if (++polled == budget)
 			goto out;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index bc8f51c..c44f423 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -382,7 +382,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 		return true;
 
 	index = cons_index & size_mask;
-	cqe = &buf[(index << factor) + factor];
+	cqe = mlx4_en_get_cqe(buf, index, priv->cqe_size) + factor;
 	ring_index = ring->cons & size_mask;
 	stamp_index = ring_index;
 
@@ -430,7 +430,7 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
 
 		++cons_index;
 		index = cons_index & size_mask;
-		cqe = &buf[(index << factor) + factor];
+		cqe = mlx4_en_get_cqe(buf, index, priv->cqe_size) + factor;
 	}
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 3de41be..e3d71c3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -542,6 +542,7 @@ struct mlx4_en_priv {
 	unsigned max_mtu;
 	int base_qpn;
 	int cqe_factor;
+	int cqe_size;
 
 	struct mlx4_en_rss_map rss_map;
 	__be32 ctrl_flags;
@@ -612,6 +613,11 @@ struct mlx4_mac_entry {
 	struct rcu_head rcu;
 };
 
+static inline struct mlx4_cqe *mlx4_en_get_cqe(void *buf, int idx, int cqe_sz)
+{
+	return buf + idx * cqe_sz;
+}
+
 #ifdef CONFIG_NET_RX_BUSY_POLL
 static inline void mlx4_en_cq_init_lock(struct mlx4_en_cq *cq)
 {
-- 
1.7.1
