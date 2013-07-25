From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next] net/mlx4_en: Fix BlueFlame race
Date: Thu, 25 Jul 2013 19:21:23 +0300
Message-ID: <1374769283-18580-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53311 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756121Ab3GYQVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 12:21:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Fix a race between BlueFlame flow and stamping in post send flow.
Example:
	SW: Build WQE 0 on the TX buffer, except the ownership bit
	SW: Set ownership for WQE 0 on the TX buffer
	SW: Ring doorbell for WQE 0
	SW: Build WQE 1 on the TX buffer, except the ownership bit
	SW: Set ownership for WQE 1 on the TX buffer
	HW: Read WQE 0 and then WQE 1, before doorbell was rung/BF was done for WQE 1
	HW: Produce CQEs for WQE 0 and WQE 1
	SW: Process the CQEs, and stamp WQE 0 and WQE 1 accordingly (on the TX buffer)
	SW: Copy WQE 1 from the TX buffer to the BF register - ALREADY STAMPED!
	HW: CQE error with index 0xFFFF  - the BF WQE's control segment is STAMPED,
		so the BF index is 0xFFFF. Error: Invalid Opcode.
As a result QP enters the error state and no traffic can be sent.

Solution:
When stamping - do not stamp last completed wqe.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 61 ++++++++++++++++++++----------
 1 file changed, 42 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 7c49238..6dcca98 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -191,6 +191,39 @@ void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
 		       MLX4_QP_STATE_RST, NULL, 0, 0, &ring->qp);
 }
 
+static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
+			      struct mlx4_en_tx_ring *ring, int index,
+			      u8 owner)
+{
+	__be32 stamp = cpu_to_be32(STAMP_VAL | (!!owner << STAMP_SHIFT));
+	struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
+	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
+	void *end = ring->buf + ring->buf_size;
+	__be32 *ptr = (__be32 *)tx_desc;
+	int i;
+
+	/* Optimize the common case when there are no wraparounds */
+	if (likely((void *)tx_desc + tx_info->nr_txbb * TXBB_SIZE <= end)) {
+		/* Stamp the freed descriptor */
+		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE;
+		     i += STAMP_STRIDE) {
+			*ptr = stamp;
+			ptr += STAMP_DWORDS;
+		}
+	} else {
+		/* Stamp the freed descriptor */
+		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE;
+		     i += STAMP_STRIDE) {
+			*ptr = stamp;
+			ptr += STAMP_DWORDS;
+			if ((void *)ptr >= end) {
+				ptr = ring->buf;
+				stamp ^= cpu_to_be32(0x80000000);
+			}
+		}
+	}
+}
+
 
 static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 				struct mlx4_en_tx_ring *ring,
@@ -205,8 +238,6 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 	void *end = ring->buf + ring->buf_size;
 	int frags = skb_shinfo(skb)->nr_frags;
 	int i;
-	__be32 *ptr = (__be32 *)tx_desc;
-	__be32 stamp = cpu_to_be32(STAMP_VAL | (!!owner << STAMP_SHIFT));
 	struct skb_shared_hwtstamps hwts;
 
 	if (timestamp) {
@@ -232,12 +263,6 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 					skb_frag_size(frag), PCI_DMA_TODEVICE);
 			}
 		}
-		/* Stamp the freed descriptor */
-		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE; i += STAMP_STRIDE) {
-			*ptr = stamp;
-			ptr += STAMP_DWORDS;
-		}
-
 	} else {
 		if (!tx_info->inl) {
 			if ((void *) data >= end) {
@@ -263,16 +288,6 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 				++data;
 			}
 		}
-		/* Stamp the freed descriptor */
-		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE; i += STAMP_STRIDE) {
-			*ptr = stamp;
-			ptr += STAMP_DWORDS;
-			if ((void *) ptr >= end) {
-				ptr = ring->buf;
-				stamp ^= cpu_to_be32(0x80000000);
-			}
-		}
-
 	}
 	dev_kfree_skb_any(skb);
 	return tx_info->nr_txbb;
@@ -318,8 +333,9 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 	struct mlx4_en_tx_ring *ring = &priv->tx_ring[cq->ring];
 	struct mlx4_cqe *cqe;
 	u16 index;
-	u16 new_index, ring_index;
+	u16 new_index, ring_index, stamp_index;
 	u32 txbbs_skipped = 0;
+	u32 txbbs_stamp = 0;
 	u32 cons_index = mcq->cons_index;
 	int size = cq->size;
 	u32 size_mask = ring->size_mask;
@@ -335,6 +351,7 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 	index = cons_index & size_mask;
 	cqe = &buf[(index << factor) + factor];
 	ring_index = ring->cons & size_mask;
+	stamp_index = ring_index;
 
 	/* Process all completed CQEs */
 	while (XNOR(cqe->owner_sr_opcode & MLX4_CQE_OWNER_MASK,
@@ -359,6 +376,12 @@ static void mlx4_en_process_tx_cq(struct net_device *dev, struct mlx4_en_cq *cq)
 					priv, ring, ring_index,
 					!!((ring->cons + txbbs_skipped) &
 					ring->size), timestamp);
+
+			mlx4_en_stamp_wqe(priv, ring, stamp_index,
+					  !!((ring->cons + txbbs_stamp) &
+						ring->size));
+			stamp_index = ring_index;
+			txbbs_stamp = txbbs_skipped;
 			packets++;
 			bytes += ring->tx_info[ring_index].nr_bytes;
 		} while (ring_index != new_index);
-- 
1.8.3.251.g1462b67
