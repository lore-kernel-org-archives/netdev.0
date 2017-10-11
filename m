From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 2/3] net/mlx4_en: Obsolete call to generic write_desc in XDP xmit flow
Date: Wed, 11 Oct 2017 13:17:26 +0300
Message-ID: <1507717047-29255-3-git-send-email-tariqt@mellanox.com>
References: <1507717047-29255-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        kernel-team@fb.com, Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53160 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752346AbdJKKRs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 06:17:48 -0400
In-Reply-To: <1507717047-29255-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function mlx4_en_tx_write_desc() is not optimized to use of XDP xmit.
Use the relevant parts inline instead.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index f16774c9c347..ac7254e3f909 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -1090,7 +1090,9 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 			       struct mlx4_en_priv *priv, unsigned int length,
 			       int tx_ind, bool *doorbell_pending)
 {
-	union mlx4_wqe_qpn_vlan	qpn_vlan = {};
+	union mlx4_wqe_qpn_vlan qpn_vlan = {
+		.fence_size = MLX4_EN_XDP_TX_REAL_SZ,
+	};
 	struct mlx4_en_tx_desc *tx_desc;
 	struct mlx4_en_tx_info *tx_info;
 	struct mlx4_wqe_data_seg *data;
@@ -1140,7 +1142,6 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 	data->byte_count = cpu_to_be32(length);
 
 	/* tx completion can avoid cache line miss for common cases */
-	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
 
 	op_own = cpu_to_be32(MLX4_OPCODE_SEND) |
 		((ring->prod & ring->size) ?
@@ -1151,10 +1152,16 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 
 	ring->prod += MLX4_EN_XDP_TX_NRTXBB;
 
-	qpn_vlan.fence_size = MLX4_EN_XDP_TX_REAL_SZ;
+	tx_desc->ctrl.qpn_vlan = qpn_vlan;
+	tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
+
+	/* Ensure new descriptor hits memory
+	 * before setting ownership of this descriptor to HW
+	 */
+	dma_wmb();
+	tx_desc->ctrl.owner_opcode = op_own;
+	ring->xmit_more++;
 
-	mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, TXBB_SIZE, 0,
-			      op_own, false, false);
 	*doorbell_pending = true;
 
 	return NETDEV_TX_OK;
-- 
1.8.3.1
