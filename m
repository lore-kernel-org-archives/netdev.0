From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 06/10] net/mlx4_en: Improve XDP xmit function
Date: Thu, 15 Jun 2017 14:35:36 +0300
Message-ID: <1497526540-30028-7-git-send-email-tariqt@mellanox.com>
References: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36073 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752401AbdFOLgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:36:25 -0400
In-Reply-To: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several performance improvements in XDP TX datapath,
including:
- Ring a single doorbell for XDP TX ring per NAPI budget,
  instead of doing it per a lower threshold (was 8).
  This includes removing the flow of immediate doorbell ringing
  in case of a full TX ring.
- Compiler branch predictor hints.
- Calculate values in compile time rather than in runtime.

Performance tests:
Tested on ConnectX3Pro, Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
Single queue no-RSS optimization ON.

XDP_TX packet rate:
-------------------------------------
     | Before    | After     | Gain |
IPv4 | 10.3 Mpps | 12.0 Mpps |  17% |
IPv6 | 10.3 Mpps | 12.0 Mpps |  17% |
-------------------------------------

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   | 59 +++++++++-------------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  3 +-
 3 files changed, 21 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 507c48ef2674..747e4d7d7693 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -643,7 +643,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_en_rx_ring *ring;
 	struct bpf_prog *xdp_prog;
 	int cq_ring = cq->ring;
-	int doorbell_pending;
+	bool doorbell_pending;
 	struct mlx4_cqe *cqe;
 	int polled = 0;
 	int index;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 58f4b322587b..01bb43879221 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -1095,51 +1095,40 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+#define MLX4_EN_XDP_TX_NRTXBB  1
+#define MLX4_EN_XDP_TX_REAL_SZ (((CTRL_SIZE + MLX4_EN_XDP_TX_NRTXBB * DS_SIZE) \
+				 / 16) & 0x3f)
+
 netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 			       struct mlx4_en_rx_alloc *frame,
 			       struct net_device *dev, unsigned int length,
-			       int tx_ind, int *doorbell_pending)
+			       int tx_ind, bool *doorbell_pending)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	union mlx4_wqe_qpn_vlan	qpn_vlan = {};
-	struct mlx4_en_tx_ring *ring;
 	struct mlx4_en_tx_desc *tx_desc;
-	struct mlx4_wqe_data_seg *data;
 	struct mlx4_en_tx_info *tx_info;
-	int index, bf_index;
-	bool send_doorbell;
-	int nr_txbb = 1;
-	bool stop_queue;
+	struct mlx4_wqe_data_seg *data;
+	struct mlx4_en_tx_ring *ring;
 	dma_addr_t dma;
-	int real_size;
 	__be32 op_own;
-	u32 ring_cons;
-	bool bf_ok;
+	int index;
 
-	BUILD_BUG_ON_MSG(ALIGN(CTRL_SIZE + DS_SIZE, TXBB_SIZE) != TXBB_SIZE,
-			 "mlx4_en_xmit_frame requires minimum size tx desc");
+	if (unlikely(!priv->port_up))
+		goto tx_drop;
 
 	ring = priv->tx_ring[TX_XDP][tx_ind];
 
-	if (!priv->port_up)
-		goto tx_drop;
-
-	if (mlx4_en_is_tx_ring_full(ring))
+	if (unlikely(mlx4_en_is_tx_ring_full(ring)))
 		goto tx_drop_count;
 
-	/* fetch ring->cons far ahead before needing it to avoid stall */
-	ring_cons = READ_ONCE(ring->cons);
-
 	index = ring->prod & ring->size_mask;
 	tx_info = &ring->tx_info[index];
 
-	bf_ok = ring->bf_enabled;
-
 	/* Track current inflight packets for performance analysis */
 	AVG_PERF_COUNTER(priv->pstats.inflight_avg,
-			 (u32)(ring->prod - ring_cons - 1));
+			 (u32)(ring->prod - READ_ONCE(ring->cons) - 1));
 
-	bf_index = ring->prod;
 	tx_desc = ring->buf + index * TXBB_SIZE;
 	data = &tx_desc->data;
 
@@ -1149,9 +1138,9 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 	frame->page = NULL;
 	tx_info->map0_dma = dma;
 	tx_info->map0_byte_count = PAGE_SIZE;
-	tx_info->nr_txbb = nr_txbb;
+	tx_info->nr_txbb = MLX4_EN_XDP_TX_NRTXBB;
 	tx_info->nr_bytes = max_t(unsigned int, length, ETH_ZLEN);
-	tx_info->data_offset = (void *)data - (void *)tx_desc;
+	tx_info->data_offset = offsetof(struct mlx4_en_tx_desc, data);
 	tx_info->ts_requested = 0;
 	tx_info->nr_maps = 1;
 	tx_info->linear = 1;
@@ -1175,23 +1164,13 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 	rx_ring->xdp_tx++;
 	AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, length);
 
-	ring->prod += nr_txbb;
+	ring->prod += MLX4_EN_XDP_TX_NRTXBB;
 
-	stop_queue = mlx4_en_is_tx_ring_full(ring);
-	send_doorbell = stop_queue ||
-				*doorbell_pending > MLX4_EN_DOORBELL_BUDGET;
-	bf_ok &= send_doorbell;
+	qpn_vlan.fence_size = MLX4_EN_XDP_TX_REAL_SZ;
 
-	real_size = ((CTRL_SIZE + nr_txbb * DS_SIZE) / 16) & 0x3f;
-
-	if (bf_ok)
-		qpn_vlan.bf_qpn = ring->doorbell_qpn | cpu_to_be32(real_size);
-	else
-		qpn_vlan.fence_size = real_size;
-
-	mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, TXBB_SIZE, bf_index,
-			      op_own, bf_ok, send_doorbell);
-	*doorbell_pending = send_doorbell ? 0 : *doorbell_pending + 1;
+	mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, TXBB_SIZE, 0,
+			      op_own, false, false);
+	*doorbell_pending = true;
 
 	return NETDEV_TX_OK;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 41f4f8f9f300..c52edb717add 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -121,7 +121,6 @@
 					 MLX4_EN_NUM_UP)
 
 #define MLX4_EN_DEFAULT_TX_WORK		256
-#define MLX4_EN_DOORBELL_BUDGET		8
 
 /* Target number of packets to coalesce with interrupt moderation */
 #define MLX4_EN_RX_COAL_TARGET	44
@@ -689,7 +688,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 			       struct mlx4_en_rx_alloc *frame,
 			       struct net_device *dev, unsigned int length,
-			       int tx_ind, int *doorbell_pending);
+			       int tx_ind, bool *doorbell_pending);
 void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring);
 bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
 			struct mlx4_en_rx_alloc *frame);
-- 
1.8.3.1
