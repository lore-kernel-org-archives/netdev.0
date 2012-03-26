From: Jing Huang <huangj@brocade.com>
Subject: [PATCH 6/7] bna: Function name changes and cleanups
Date: Mon, 26 Mar 2012 12:40:41 -0700
Message-ID: <1332790841-10513-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Jing Huang <huangj@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:58162 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754708Ab2CZTkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 15:40:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renamed following functions:
bnad_cleanup_tx to bnad_destroy_tx
bnad_free_all_txbufs to bnad_txq_cleanup
bnad_free_txbufs to bnad_txcmpl_process
bnad_tx to bnad_tx_complete
bnad_cleanup_rx to bnad_destroy_rx
bnad_reset_rcb to bnad_rcb_cleanup
bnad_free_all_rxbufs to bnad_rxq_cleanup
bnad_cq_cmpl_init to bnad_cq_cleanup
bnad_alloc_n_post_rxbufs to bnad_rxq_post
bnad_poll_cq to bnad_cq_process

Signed-off-by: Jing Huang <huangj@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c         |   54 +++++++++++-----------
 drivers/net/ethernet/brocade/bna/bnad.h         |    4 +-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    6 +-
 3 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index f1103e6..25c4e7f 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -101,7 +101,7 @@ bnad_remove_from_list(struct bnad *bnad)
  * Reinitialize completions in CQ, once Rx is taken down
  */
 static void
-bnad_cq_cmpl_init(struct bnad *bnad, struct bna_ccb *ccb)
+bnad_cq_cleanup(struct bnad *bnad, struct bna_ccb *ccb)
 {
 	struct bna_cq_entry *cmpl, *next_cmpl;
 	unsigned int wi_range, wis = 0, ccb_prod = 0;
@@ -154,7 +154,7 @@ bnad_pci_unmap_skb(struct device *pdev, struct bnad_skb_unmap *array,
  * so DMA unmap & freeing is fine.
  */
 static void
-bnad_free_all_txbufs(struct bnad *bnad,
+bnad_txq_cleanup(struct bnad *bnad,
 		 struct bna_tcb *tcb)
 {
 	u32		unmap_cons;
@@ -182,12 +182,12 @@ bnad_free_all_txbufs(struct bnad *bnad,
 /* Data Path Handlers */
 
 /*
- * bnad_free_txbufs : Frees the Tx bufs on Tx completion
+ * bnad_txcmpl_process : Frees the Tx bufs on Tx completion
  * Can be called in a) Interrupt context
  *		    b) Sending context
  */
 static u32
-bnad_free_txbufs(struct bnad *bnad,
+bnad_txcmpl_process(struct bnad *bnad,
 		 struct bna_tcb *tcb)
 {
 	u32		unmap_cons, sent_packets = 0, sent_bytes = 0;
@@ -236,7 +236,7 @@ bnad_free_txbufs(struct bnad *bnad,
 }
 
 static u32
-bnad_tx(struct bnad *bnad, struct bna_tcb *tcb)
+bnad_tx_complete(struct bnad *bnad, struct bna_tcb *tcb)
 {
 	struct net_device *netdev = bnad->netdev;
 	u32 sent = 0;
@@ -244,7 +244,7 @@ bnad_tx(struct bnad *bnad, struct bna_tcb *tcb)
 	if (test_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags))
 		return 0;
 
-	sent = bnad_free_txbufs(bnad, tcb);
+	sent = bnad_txcmpl_process(bnad, tcb);
 	if (sent) {
 		if (netif_queue_stopped(netdev) &&
 		    netif_carrier_ok(netdev) &&
@@ -273,13 +273,13 @@ bnad_msix_tx(int irq, void *data)
 	struct bna_tcb *tcb = (struct bna_tcb *)data;
 	struct bnad *bnad = tcb->bnad;
 
-	bnad_tx(bnad, tcb);
+	bnad_tx_complete(bnad, tcb);
 
 	return IRQ_HANDLED;
 }
 
 static void
-bnad_reset_rcb(struct bnad *bnad, struct bna_rcb *rcb)
+bnad_rcb_cleanup(struct bnad *bnad, struct bna_rcb *rcb)
 {
 	struct bnad_unmap_q *unmap_q = rcb->unmap_q;
 
@@ -291,7 +291,7 @@ bnad_reset_rcb(struct bnad *bnad, struct bna_rcb *rcb)
 }
 
 static void
-bnad_free_all_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
+bnad_rxq_cleanup(struct bnad *bnad, struct bna_rcb *rcb)
 {
 	struct bnad_unmap_q *unmap_q;
 	struct bnad_skb_unmap *unmap_array;
@@ -312,11 +312,11 @@ bnad_free_all_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
 				 DMA_FROM_DEVICE);
 		dev_kfree_skb(skb);
 	}
-	bnad_reset_rcb(bnad, rcb);
+	bnad_rcb_cleanup(bnad, rcb);
 }
 
 static void
-bnad_alloc_n_post_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
+bnad_rxq_post(struct bnad *bnad, struct bna_rcb *rcb)
 {
 	u16 to_alloc, alloced, unmap_prod, wi_range;
 	struct bnad_unmap_q *unmap_q = rcb->unmap_q;
@@ -377,14 +377,14 @@ bnad_refill_rxq(struct bnad *bnad, struct bna_rcb *rcb)
 	if (!test_and_set_bit(BNAD_RXQ_REFILL, &rcb->flags)) {
 		if (BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth)
 			 >> BNAD_RXQ_REFILL_THRESHOLD_SHIFT)
-			bnad_alloc_n_post_rxbufs(bnad, rcb);
+			bnad_rxq_post(bnad, rcb);
 		smp_mb__before_clear_bit();
 		clear_bit(BNAD_RXQ_REFILL, &rcb->flags);
 	}
 }
 
 static u32
-bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
+bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 {
 	struct bna_cq_entry *cmpl, *next_cmpl;
 	struct bna_rcb *rcb = NULL;
@@ -584,7 +584,7 @@ bnad_isr(int irq, void *data)
 		for (j = 0; j < bnad->num_txq_per_tx; j++) {
 			tcb = bnad->tx_info[i].tcb[j];
 			if (tcb && test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))
-				bnad_tx(bnad, bnad->tx_info[i].tcb[j]);
+				bnad_tx_complete(bnad, bnad->tx_info[i].tcb[j]);
 		}
 	}
 	/* Rx processing */
@@ -895,7 +895,7 @@ bnad_tx_cleanup(struct delayed_work *work)
 			continue;
 		}
 
-		bnad_free_all_txbufs(bnad, tcb);
+		bnad_txq_cleanup(bnad, tcb);
 
 		unmap_q = tcb->unmap_q;
 		unmap_q->producer_index = 0;
@@ -981,10 +981,10 @@ bnad_rx_cleanup(void *work)
 		 */
 		napi_disable(&rx_ctrl->napi);
 
-		bnad_cq_cmpl_init(bnad, rx_ctrl->ccb);
-		bnad_free_all_rxbufs(bnad, rx_ctrl->ccb->rcb[0]);
+		bnad_cq_cleanup(bnad, rx_ctrl->ccb);
+		bnad_rxq_cleanup(bnad, rx_ctrl->ccb->rcb[0]);
 		if (rx_ctrl->ccb->rcb[1])
-			bnad_free_all_rxbufs(bnad, rx_ctrl->ccb->rcb[1]);
+			bnad_rxq_cleanup(bnad, rx_ctrl->ccb->rcb[1]);
 	}
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
@@ -1048,7 +1048,7 @@ bnad_cb_rx_post(struct bnad *bnad, struct bna_rx *rx)
 			if (!test_and_set_bit(BNAD_RXQ_REFILL, &rcb->flags)) {
 				if (BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth)
 					>> BNAD_RXQ_REFILL_THRESHOLD_SHIFT)
-					bnad_alloc_n_post_rxbufs(bnad, rcb);
+					bnad_rxq_post(bnad, rcb);
 					smp_mb__before_clear_bit();
 				clear_bit(BNAD_RXQ_REFILL, &rcb->flags);
 			}
@@ -1672,7 +1672,7 @@ bnad_napi_poll_rx(struct napi_struct *napi, int budget)
 	if (!netif_carrier_ok(bnad->netdev))
 		goto poll_exit;
 
-	rcvd = bnad_poll_cq(bnad, rx_ctrl->ccb, budget);
+	rcvd = bnad_cq_process(bnad, rx_ctrl->ccb, budget);
 	if (rcvd >= budget)
 		return rcvd;
 
@@ -1714,7 +1714,7 @@ bnad_napi_delete(struct bnad *bnad, u32 rx_id)
 
 /* Should be held with conf_lock held */
 void
-bnad_cleanup_tx(struct bnad *bnad, u32 tx_id)
+bnad_destroy_tx(struct bnad *bnad, u32 tx_id)
 {
 	struct bnad_tx_info *tx_info = &bnad->tx_info[tx_id];
 	struct bna_res_info *res_info = &bnad->tx_res_info[tx_id].res_info[0];
@@ -1865,7 +1865,7 @@ bnad_rx_ctrl_init(struct bnad *bnad, u32 rx_id)
 
 /* Called with mutex_lock(&bnad->conf_mutex) held */
 void
-bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
+bnad_destroy_rx(struct bnad *bnad, u32 rx_id)
 {
 	struct bnad_rx_info *rx_info = &bnad->rx_info[rx_id];
 	struct bna_rx_config *rx_config = &bnad->rx_config[rx_id];
@@ -2003,7 +2003,7 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	return 0;
 
 err_return:
-	bnad_cleanup_rx(bnad, rx_id);
+	bnad_destroy_rx(bnad, rx_id);
 	return err;
 }
 
@@ -2488,7 +2488,7 @@ bnad_open(struct net_device *netdev)
 	return 0;
 
 cleanup_tx:
-	bnad_cleanup_tx(bnad, 0);
+	bnad_destroy_tx(bnad, 0);
 
 err_return:
 	mutex_unlock(&bnad->conf_mutex);
@@ -2515,8 +2515,8 @@ bnad_stop(struct net_device *netdev)
 
 	wait_for_completion(&bnad->bnad_completions.enet_comp);
 
-	bnad_cleanup_tx(bnad, 0);
-	bnad_cleanup_rx(bnad, 0);
+	bnad_destroy_tx(bnad, 0);
+	bnad_destroy_rx(bnad, 0);
 
 	/* Synchronize mailbox IRQ */
 	bnad_mbox_irq_sync(bnad);
@@ -2589,7 +2589,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		if ((u16) (*tcb->hw_consumer_index) !=
 		    tcb->consumer_index &&
 		    !test_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags)) {
-			acked = bnad_free_txbufs(bnad, tcb);
+			acked = bnad_txcmpl_process(bnad, tcb);
 			if (likely(test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags)))
 				bna_ib_ack(tcb->i_dbell, acked);
 			smp_mb__before_clear_bit();
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index cf1d3ba..d73967a 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -373,8 +373,8 @@ extern void bnad_rx_coalescing_timeo_set(struct bnad *bnad);
 
 extern int bnad_setup_rx(struct bnad *bnad, u32 rx_id);
 extern int bnad_setup_tx(struct bnad *bnad, u32 tx_id);
-extern void bnad_cleanup_tx(struct bnad *bnad, u32 tx_id);
-extern void bnad_cleanup_rx(struct bnad *bnad, u32 rx_id);
+extern void bnad_destroy_tx(struct bnad *bnad, u32 tx_id);
+extern void bnad_destroy_rx(struct bnad *bnad, u32 rx_id);
 
 /* Timer start/stop protos */
 extern void bnad_dim_timer_start(struct bnad *bnad);
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index ab753d7..40e1e84 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -464,7 +464,7 @@ bnad_set_ringparam(struct net_device *netdev,
 		for (i = 0; i < bnad->num_rx; i++) {
 			if (!bnad->rx_info[i].rx)
 				continue;
-			bnad_cleanup_rx(bnad, i);
+			bnad_destroy_rx(bnad, i);
 			current_err = bnad_setup_rx(bnad, i);
 			if (current_err && !err)
 				err = current_err;
@@ -492,7 +492,7 @@ bnad_set_ringparam(struct net_device *netdev,
 		for (i = 0; i < bnad->num_tx; i++) {
 			if (!bnad->tx_info[i].tx)
 				continue;
-			bnad_cleanup_tx(bnad, i);
+			bnad_destroy_tx(bnad, i);
 			current_err = bnad_setup_tx(bnad, i);
 			if (current_err && !err)
 				err = current_err;
@@ -539,7 +539,7 @@ bnad_set_pauseparam(struct net_device *netdev,
 }
 
 static void
-bnad_get_strings(struct net_device *netdev, u32 stringset, u8 * string)
+bnad_get_strings(struct net_device *netdev, u32 stringset, u8 *string)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	int i, j, q_num;
-- 
1.6.5.2
