From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/7] net/mlx5e: Support NETIF_F_SG
Date: Thu, 11 Jun 2015 14:47:31 +0300
Message-ID: <1434023253-24362-6-git-send-email-ogerlitz@mellanox.com>
References: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47280 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752880AbbFKLsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 07:48:02 -0400
In-Reply-To: <1434023253-24362-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

When NETIF_F_SG is set, each send WQE may have a different size since
each skb can have different number of fragments as of LSO header etc.

This implies that a given WQE may wrap around the send queue, i.e begin
at its end and continue at its start. While it is legal by the device spec,
we preferred a solution that avoids it - when building of current WQE is
done, if the next WQE may wrap around the send queue, fill the send queue
with NOPs WQEs till its end, so that the next WQE will begin at send queue
start.

NOP WQE for itself cannot wrap around the send queue since it is of
minimal size - 64 bytes, and all send WQEs are a multiple of that size.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    3 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   26 ++-------------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |   35 +++++++++++++++++++-
 3 files changed, 40 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 71f38bb..23cc3bf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -283,6 +283,8 @@ struct mlx5e_sq {
 	struct netdev_queue       *txq;
 	u32                        sqn;
 	u32                        bf_buf_size;
+	u16                        max_inline;
+	u16                        edge;
 	struct device             *pdev;
 	__be32                     mkey_be;
 	unsigned long              state;
@@ -453,6 +455,7 @@ enum mlx5e_link_mode {
 
 #define MLX5E_PROT_MASK(link_mode) (1 << link_mode)
 
+void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw);
 u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 		       void *accel_priv, select_queue_fallback_t fallback);
 netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1a655fd..5458cc6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -257,26 +257,6 @@ static void mlx5e_disable_async_events(struct mlx5e_priv *priv)
 	spin_unlock_irq(&priv->async_events_spinlock);
 }
 
-static void mlx5e_send_nop(struct mlx5e_sq *sq)
-{
-	struct mlx5_wq_cyc                *wq  = &sq->wq;
-
-	u16 pi = sq->pc & wq->sz_m1;
-	struct mlx5e_tx_wqe              *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
-
-	struct mlx5_wqe_ctrl_seg         *cseg = &wqe->ctrl;
-
-	memset(cseg, 0, sizeof(*cseg));
-
-	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | MLX5_OPCODE_NOP);
-	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | 0x01);
-	cseg->fm_ce_se         = MLX5_WQE_CTRL_CQ_UPDATE;
-
-	sq->skb[pi] = NULL;
-	sq->pc++;
-	mlx5e_tx_notify_hw(sq, wqe);
-}
-
 #define MLX5E_HW2SW_MTU(hwmtu) (hwmtu - (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
 #define MLX5E_SW2HW_MTU(swmtu) (swmtu + (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
 
@@ -453,7 +433,7 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 		goto err_disable_rq;
 
 	set_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state);
-	mlx5e_send_nop(&c->sq[0]); /* trigger mlx5e_post_rx_wqes() */
+	mlx5e_send_nop(&c->sq[0], true); /* trigger mlx5e_post_rx_wqes() */
 
 	return 0;
 
@@ -541,6 +521,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	sq->mkey_be = c->mkey_be;
 	sq->channel = c;
 	sq->tc      = tc;
+	sq->edge    = (sq->wq.sz_m1 + 1) - MLX5_SEND_WQE_MAX_WQEBBS;
 
 	return 0;
 
@@ -694,7 +675,7 @@ static void mlx5e_close_sq(struct mlx5e_sq *sq)
 
 	/* ensure hw is notified of all pending wqes */
 	if (mlx5e_sq_has_room_for(sq, 1))
-		mlx5e_send_nop(sq);
+		mlx5e_send_nop(sq, true);
 
 	mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY, MLX5_SQC_STATE_ERR);
 	while (sq->cc != sq->pc) /* wait till sq is empty */
@@ -1746,6 +1727,7 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 
 	netdev->ethtool_ops	  = &mlx5e_ethtool_ops;
 
+	netdev->vlan_features    |= NETIF_F_SG;
 	netdev->vlan_features    |= NETIF_F_IP_CSUM;
 	netdev->vlan_features    |= NETIF_F_IPV6_CSUM;
 	netdev->vlan_features    |= NETIF_F_GRO;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 3cfd2bc..bac268a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -34,6 +34,33 @@
 #include <linux/if_vlan.h>
 #include "en.h"
 
+#define MLX5E_SQ_NOPS_ROOM  MLX5_SEND_WQE_MAX_WQEBBS
+#define MLX5E_SQ_STOP_ROOM (MLX5_SEND_WQE_MAX_WQEBBS +\
+			    MLX5E_SQ_NOPS_ROOM)
+
+void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
+{
+	struct mlx5_wq_cyc                *wq  = &sq->wq;
+
+	u16 pi = sq->pc & wq->sz_m1;
+	struct mlx5e_tx_wqe              *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
+
+	struct mlx5_wqe_ctrl_seg         *cseg = &wqe->ctrl;
+
+	memset(cseg, 0, sizeof(*cseg));
+
+	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | MLX5_OPCODE_NOP);
+	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | 0x01);
+
+	sq->skb[pi] = NULL;
+	sq->pc++;
+
+	if (notify_hw) {
+		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
+		mlx5e_tx_notify_hw(sq, wqe);
+	}
+}
+
 static void mlx5e_dma_pop_last_pushed(struct mlx5e_sq *sq, dma_addr_t *addr,
 				      u32 *size)
 {
@@ -196,7 +223,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 
 	netdev_tx_sent_queue(sq->txq, MLX5E_TX_SKB_CB(skb)->num_bytes);
 
-	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5_SEND_WQE_MAX_WQEBBS))) {
+	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM))) {
 		netif_tx_stop_queue(sq->txq);
 		sq->stats.stopped++;
 	}
@@ -204,6 +231,10 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	if (!skb->xmit_more || netif_xmit_stopped(sq->txq))
 		mlx5e_tx_notify_hw(sq, wqe);
 
+	/* fill sq edge with nops to avoid wqe wrap around */
+	while ((sq->pc & wq->sz_m1) > sq->edge)
+		mlx5e_send_nop(sq, false);
+
 	sq->stats.packets++;
 	return NETDEV_TX_OK;
 
@@ -311,7 +342,7 @@ free_skb:
 	netdev_tx_completed_queue(sq->txq, npkts, nbytes);
 
 	if (netif_tx_queue_stopped(sq->txq) &&
-	    mlx5e_sq_has_room_for(sq, MLX5_SEND_WQE_MAX_WQEBBS) &&
+	    mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM) &&
 	    likely(test_bit(MLX5E_SQ_STATE_WAKE_TXQ_ENABLE, &sq->state))) {
 				netif_tx_wake_queue(sq->txq);
 				sq->stats.wake++;
-- 
1.7.1
