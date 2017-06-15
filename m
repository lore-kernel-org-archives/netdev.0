From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 09/10] net/mlx4_en: Replace TXBB_SIZE multiplications with shift operations
Date: Thu, 15 Jun 2017 14:35:39 +0300
Message-ID: <1497526540-30028-10-git-send-email-tariqt@mellanox.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36108 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752397AbdFOLgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:36:25 -0400
In-Reply-To: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define LOG_TXBB_SIZE, log of TXBB_SIZE, and use it with a shift
operation instead of a multiplication with TXBB_SIZE.
Operations are equivalent as TXBB_SIZE is a power of two.

Performance tests:
Tested on ConnectX3Pro, Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz

Gain is too small to be measurable, no degradation sensed.
Results are similar for IPv4 and IPv6.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 26 ++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  3 ++-
 2 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 500442c60342..efc4411b1e44 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -234,23 +234,24 @@ static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
 			      u8 owner)
 {
 	__be32 stamp = cpu_to_be32(STAMP_VAL | (!!owner << STAMP_SHIFT));
-	struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
+	struct mlx4_en_tx_desc *tx_desc = ring->buf + (index << LOG_TXBB_SIZE);
 	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
 	void *end = ring->buf + ring->buf_size;
 	__be32 *ptr = (__be32 *)tx_desc;
 	int i;
 
 	/* Optimize the common case when there are no wraparounds */
-	if (likely((void *)tx_desc + tx_info->nr_txbb * TXBB_SIZE <= end)) {
+	if (likely((void *)tx_desc +
+		   (tx_info->nr_txbb << LOG_TXBB_SIZE) <= end)) {
 		/* Stamp the freed descriptor */
-		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE;
+		for (i = 0; i < tx_info->nr_txbb << LOG_TXBB_SIZE;
 		     i += STAMP_STRIDE) {
 			*ptr = stamp;
 			ptr += STAMP_DWORDS;
 		}
 	} else {
 		/* Stamp the freed descriptor */
-		for (i = 0; i < tx_info->nr_txbb * TXBB_SIZE;
+		for (i = 0; i < tx_info->nr_txbb << LOG_TXBB_SIZE;
 		     i += STAMP_STRIDE) {
 			*ptr = stamp;
 			ptr += STAMP_DWORDS;
@@ -269,7 +270,7 @@ u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 			 int napi_mode)
 {
 	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
-	struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
+	struct mlx4_en_tx_desc *tx_desc = ring->buf + (index << LOG_TXBB_SIZE);
 	struct mlx4_wqe_data_seg *data = (void *) tx_desc + tx_info->data_offset;
 	void *end = ring->buf + ring->buf_size;
 	struct sk_buff *skb = tx_info->skb;
@@ -289,7 +290,8 @@ u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
 	}
 
 	/* Optimize the common case when there are no wraparounds */
-	if (likely((void *) tx_desc + tx_info->nr_txbb * TXBB_SIZE <= end)) {
+	if (likely((void *)tx_desc +
+		   (tx_info->nr_txbb << LOG_TXBB_SIZE) <= end)) {
 		if (!tx_info->inl) {
 			if (tx_info->linear)
 				dma_unmap_single(priv->ddev,
@@ -542,7 +544,7 @@ static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
 						      u32 index,
 						      unsigned int desc_size)
 {
-	u32 copy = (ring->size - index) * TXBB_SIZE;
+	u32 copy = (ring->size - index) << LOG_TXBB_SIZE;
 	int i;
 
 	for (i = desc_size - copy - 4; i >= 0; i -= 4) {
@@ -557,12 +559,12 @@ static struct mlx4_en_tx_desc *mlx4_en_bounce_to_desc(struct mlx4_en_priv *priv,
 		if ((i & (TXBB_SIZE - 1)) == 0)
 			wmb();
 
-		*((u32 *) (ring->buf + index * TXBB_SIZE + i)) =
+		*((u32 *)(ring->buf + (index << LOG_TXBB_SIZE) + i)) =
 			*((u32 *) (ring->bounce_buf + i));
 	}
 
 	/* Return real descriptor location */
-	return ring->buf + index * TXBB_SIZE;
+	return ring->buf + (index << LOG_TXBB_SIZE);
 }
 
 /* Decide if skb can be inlined in tx descriptor to avoid dma mapping
@@ -881,7 +883,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Align descriptor to TXBB size */
 	desc_size = ALIGN(real_size, TXBB_SIZE);
-	nr_txbb = desc_size / TXBB_SIZE;
+	nr_txbb = desc_size >> LOG_TXBB_SIZE;
 	if (unlikely(nr_txbb > MAX_DESC_TXBBS)) {
 		if (netif_msg_tx_err(priv))
 			en_warn(priv, "Oversized header or SG list\n");
@@ -916,7 +918,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* See if we have enough space for whole descriptor TXBB for setting
 	 * SW ownership on next descriptor; if not, use a bounce buffer. */
 	if (likely(index + nr_txbb <= ring->size))
-		tx_desc = ring->buf + index * TXBB_SIZE;
+		tx_desc = ring->buf + (index << LOG_TXBB_SIZE);
 	else {
 		tx_desc = (struct mlx4_en_tx_desc *) ring->bounce_buf;
 		bounce = true;
@@ -1129,7 +1131,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 	AVG_PERF_COUNTER(priv->pstats.inflight_avg,
 			 (u32)(ring->prod - READ_ONCE(ring->cons) - 1));
 
-	tx_desc = ring->buf + index * TXBB_SIZE;
+	tx_desc = ring->buf + (index << LOG_TXBB_SIZE);
 	data = &tx_desc->data;
 
 	dma = frame->dma;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 7f61b5829709..963b77d51b48 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -72,7 +72,8 @@
 #define DEF_RX_RINGS		16
 #define MAX_RX_RINGS		128
 #define MIN_RX_RINGS		4
-#define TXBB_SIZE		64
+#define LOG_TXBB_SIZE		6
+#define TXBB_SIZE		BIT(LOG_TXBB_SIZE)
 #define HEADROOM		(2048 / TXBB_SIZE + 1)
 #define STAMP_STRIDE		64
 #define STAMP_DWORDS		(STAMP_STRIDE / 4)
-- 
1.8.3.1
