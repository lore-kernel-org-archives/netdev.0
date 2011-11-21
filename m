From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 4/8] net/mlx4_en: using non collapsed CQ on TX
Date: Mon, 21 Nov 2011 10:43:39 +0200
Message-ID: <4ECA0F3B.70107@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <oren@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:41570 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755478Ab1KULTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 06:19:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>


Moving to regular Completion Queue implementation (not collapsed)
Completion for each transmitted packet is written to new entry.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c |    7 +--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |   65 ++++++++++++++--------------
 2 files changed, 35 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 227997d..2d1a342 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -51,10 +51,7 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 	int err;
 
 	cq->size = entries;
-	if (mode == RX)
-		cq->buf_size = cq->size * sizeof(struct mlx4_cqe);
-	else
-		cq->buf_size = sizeof(struct mlx4_cqe);
+	cq->buf_size = cq->size * sizeof(struct mlx4_cqe);
 
 	cq->ring = ring;
 	cq->is_tx = mode;
@@ -120,7 +117,7 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 		cq->size = priv->rx_ring[cq->ring].actual_size;
 
 	err = mlx4_cq_alloc(mdev->dev, cq->size, &cq->wqres.mtt, &mdev->priv_uar,
-			    cq->wqres.db.dma, &cq->mcq, cq->vector, cq->is_tx);
+			    cq->wqres.db.dma, &cq->mcq, cq->vector, 0);
 	if (err)
 		return err;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index d901b42..3094f94 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -307,59 +307,60 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
 	return cnt;
 }
 
-
 static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_cq *mcq = &cq->mcq;
 	struct mlx4_en_tx_ring *ring = &priv->tx_ring[cq->ring];
-	struct mlx4_cqe *cqe = cq->buf;
+	struct mlx4_cqe *cqe;
 	u16 index;
-	u16 new_index;
+	u16 new_index, ring_index;
 	u32 txbbs_skipped = 0;
-	u32 cq_last_sav;
-
-	/* index always points to the first TXBB of the last polled descriptor */
-	index = ring->cons & ring->size_mask;
-	new_index = be16_to_cpu(cqe->wqe_index) & ring->size_mask;
-	if (index == new_index)
-		return;
+	u32 cons_index = mcq->cons_index;
+	int size = cq->size;
+	u32 size_mask = ring->size_mask;
+	struct mlx4_cqe *buf = cq->buf;
 
 	if (!priv->port_up)
 		return;
 
-	/*
-	 * We use a two-stage loop:
-	 * - the first samples the HW-updated CQE
-	 * - the second frees TXBBs until the last sample
-	 * This lets us amortize CQE cache misses, while still polling the CQ
-	 * until is quiescent.
-	 */
-	cq_last_sav = mcq->cons_index;
-	do {
+	index = cons_index & size_mask;
+	cqe = &buf[index];
+	ring_index = ring->cons & size_mask;
+
+	/* Process all completed CQEs */
+	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
+			cons_index & size)) {
+		/*
+		 * make sure we read the CQE after we read the
+		 * ownership bit
+		 */
+		rmb();
+
+		/* Skip over last polled CQE */
+		new_index = be16_to_cpu(cqe->wqe_index) & size_mask;
+
 		do {
-			/* Skip over last polled CQE */
-			index = (index + ring->last_nr_txbb) & ring->size_mask;
 			txbbs_skipped += ring->last_nr_txbb;
-
-			/* Poll next CQE */
+			ring_index = (ring_index + ring->last_nr_txbb) & size_mask;
+			/* free next descriptor */
 			ring->last_nr_txbb = mlx4_en_free_tx_desc(
-						priv, ring, index,
-						!!((ring->cons + txbbs_skipped) &
-						   ring->size));
-			++mcq->cons_index;
+					priv, ring, ring_index,
+					!!((ring->cons + txbbs_skipped) &
+							ring->size));
+		} while (ring_index != new_index);
 
-		} while (index != new_index);
+		++cons_index;
+		index = cons_index & size_mask;
+		cqe = &buf[index];
+	}
 
-		new_index = be16_to_cpu(cqe->wqe_index) & ring->size_mask;
-	} while (index != new_index);
-	AVG_PERF_COUNTER(priv->pstats.tx_coal_avg,
-			 (u32) (mcq->cons_index - cq_last_sav));
 
 	/*
 	 * To prevent CQ overflow we first update CQ consumer and only then
 	 * the ring consumer.
 	 */
+	mcq->cons_index = cons_index;
 	mlx4_cq_set_ci(mcq);
 	wmb();
 	ring->cons += txbbs_skipped;
-- 
1.7.7
