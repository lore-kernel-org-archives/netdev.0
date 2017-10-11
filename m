From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx4_en: XDP_TX, assign constant values of TX descs on ring creaion
Date: Wed, 11 Oct 2017 13:17:27 +0300
Message-ID: <1507717047-29255-4-git-send-email-tariqt@mellanox.com>
References: <1507717047-29255-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        kernel-team@fb.com, Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53146 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751964AbdJKKRs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 06:17:48 -0400
In-Reply-To: <1507717047-29255-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In XDP_TX, some fields in tx_info and tx_desc are constants across
all entries of the different XDP_TX rings.
Assign values to these fields on ring creation time, rather than in
data-path.

Patchset performance tests:
Tested on ConnectX3Pro, Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
Single queue no-RSS optimization ON.

XDP_TX packet rate:
------------------------------
Before    | After     | Gain |
13.7 Mpps | 14.0 Mpps | %2.2 |
------------------------------

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  1 +
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 38 ++++++++++++++++----------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  2 ++
 3 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index e4c7a80ef5a8..d611df2f274d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1752,6 +1752,7 @@ int mlx4_en_start_port(struct net_device *dev)
 				mlx4_en_arm_cq(priv, cq);
 
 			} else {
+				mlx4_en_init_tx_xdp_ring_descs(priv, tx_ring);
 				mlx4_en_init_recycle_ring(priv, i);
 				/* XDP TX CQ should never be armed */
 			}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index ac7254e3f909..596445a4a241 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -1085,14 +1085,35 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 #define MLX4_EN_XDP_TX_REAL_SZ (((CTRL_SIZE + MLX4_EN_XDP_TX_NRTXBB * DS_SIZE) \
 				 / 16) & 0x3f)
 
+void mlx4_en_init_tx_xdp_ring_descs(struct mlx4_en_priv *priv,
+				    struct mlx4_en_tx_ring *ring)
+{
+	int i;
+
+	for (i = 0; i < ring->size; i++) {
+		struct mlx4_en_tx_info *tx_info = &ring->tx_info[i];
+		struct mlx4_en_tx_desc *tx_desc = ring->buf +
+			(i << LOG_TXBB_SIZE);
+
+		tx_info->map0_byte_count = PAGE_SIZE;
+		tx_info->nr_txbb = MLX4_EN_XDP_TX_NRTXBB;
+		tx_info->data_offset = offsetof(struct mlx4_en_tx_desc, data);
+		tx_info->ts_requested = 0;
+		tx_info->nr_maps = 1;
+		tx_info->linear = 1;
+		tx_info->inl = 0;
+
+		tx_desc->data.lkey = ring->mr_key;
+		tx_desc->ctrl.qpn_vlan.fence_size = MLX4_EN_XDP_TX_REAL_SZ;
+		tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
+	}
+}
+
 netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 			       struct mlx4_en_rx_alloc *frame,
 			       struct mlx4_en_priv *priv, unsigned int length,
 			       int tx_ind, bool *doorbell_pending)
 {
-	union mlx4_wqe_qpn_vlan qpn_vlan = {
-		.fence_size = MLX4_EN_XDP_TX_REAL_SZ,
-	};
 	struct mlx4_en_tx_desc *tx_desc;
 	struct mlx4_en_tx_info *tx_info;
 	struct mlx4_wqe_data_seg *data;
@@ -1124,20 +1145,12 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 	tx_info->page = frame->page;
 	frame->page = NULL;
 	tx_info->map0_dma = dma;
-	tx_info->map0_byte_count = PAGE_SIZE;
-	tx_info->nr_txbb = MLX4_EN_XDP_TX_NRTXBB;
 	tx_info->nr_bytes = max_t(unsigned int, length, ETH_ZLEN);
-	tx_info->data_offset = offsetof(struct mlx4_en_tx_desc, data);
-	tx_info->ts_requested = 0;
-	tx_info->nr_maps = 1;
-	tx_info->linear = 1;
-	tx_info->inl = 0;
 
 	dma_sync_single_range_for_device(priv->ddev, dma, frame->page_offset,
 					 length, PCI_DMA_TODEVICE);
 
 	data->addr = cpu_to_be64(dma + frame->page_offset);
-	data->lkey = ring->mr_key;
 	dma_wmb();
 	data->byte_count = cpu_to_be32(length);
 
@@ -1152,9 +1165,6 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 
 	ring->prod += MLX4_EN_XDP_TX_NRTXBB;
 
-	tx_desc->ctrl.qpn_vlan = qpn_vlan;
-	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
-
 	/* Ensure new descriptor hits memory
 	 * before setting ownership of this descriptor to HW
 	 */
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 8cad9b4f1936..1856e279a7e0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -705,6 +705,8 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 			   int node, int queue_index);
 void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring **pring);
+void mlx4_en_init_tx_xdp_ring_descs(struct mlx4_en_priv *priv,
+				    struct mlx4_en_tx_ring *ring);
 int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 			     struct mlx4_en_tx_ring *ring,
 			     int cq, int user_prio);
-- 
1.8.3.1
