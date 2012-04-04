From: Jing Huang <huangj@brocade.com>
Subject: [PATCH 4/7] bna: tx rx cleanup fix
Date: Wed, 4 Apr 2012 08:43:18 -0700
Message-ID: <1333554198-22447-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <AdapterLinuxOpenSrcExtTeam@brocade.com>,
	Jing Huang <huangj@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:36406 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932301Ab2DDPnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 11:43:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes busy wait in tx/rx cleanup. bnad_cb_tx_cleanup() and
bnad_cb_rx_cleanup() functions are called from irq context, and currently
they do busy wait for the in-flight transmit or the currently executing napi
polling routine to complete. To fix the issue, we create a workqueue to defer
tx & rx cleanup processing, an in the tx rx cleanup handler, we will
wait respective in flight processing to complete, before freeing the buffers.

Signed-off-by: Jing Huang <huangj@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |  201 +++++++++++++++++++------------
 drivers/net/ethernet/brocade/bna/bnad.h |    4 +
 2 files changed, 125 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index ff78f77..032a306 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -80,8 +80,6 @@ do {								\
 	(sizeof(struct bnad_skb_unmap) * ((_depth) - 1));	\
 } while (0)
 
-#define BNAD_TXRX_SYNC_MDELAY	250	/* 250 msecs */
-
 static void
 bnad_add_to_list(struct bnad *bnad)
 {
@@ -141,7 +139,8 @@ bnad_pci_unmap_skb(struct device *pdev, struct bnad_skb_unmap *array,
 
 	for (j = 0; j < frag; j++) {
 		dma_unmap_page(pdev, dma_unmap_addr(&array[index], dma_addr),
-			  skb_frag_size(&skb_shinfo(skb)->frags[j]), DMA_TO_DEVICE);
+			  skb_frag_size(&skb_shinfo(skb)->frags[j]),
+						DMA_TO_DEVICE);
 		dma_unmap_addr_set(&array[index], dma_addr, 0);
 		BNA_QE_INDX_ADD(index, 1, depth);
 	}
@@ -453,12 +452,8 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 	struct bna_pkt_rate *pkt_rt = &ccb->pkt_rate;
 	struct bnad_rx_ctrl *rx_ctrl = (struct bnad_rx_ctrl *)(ccb->ctrl);
 
-	set_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags);
-
-	if (!test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)) {
-		clear_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags);
+	if (!test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags))
 		return 0;
-	}
 
 	prefetch(bnad->netdev);
 	BNA_CQ_QPGE_PTR_GET(ccb->producer_index, ccb->sw_qpt, cmpl,
@@ -533,9 +528,8 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 
 		if (skb->ip_summed == CHECKSUM_UNNECESSARY)
 			napi_gro_receive(&rx_ctrl->napi, skb);
-		else {
+		else
 			netif_receive_skb(skb);
-		}
 
 next:
 		cmpl->valid = 0;
@@ -839,20 +833,9 @@ bnad_cb_tcb_destroy(struct bnad *bnad, struct bna_tcb *tcb)
 {
 	struct bnad_tx_info *tx_info =
 			(struct bnad_tx_info *)tcb->txq->tx->priv;
-	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
-
-	while (test_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags))
-		cpu_relax();
-
-	bnad_free_all_txbufs(bnad, tcb);
-
-	unmap_q->producer_index = 0;
-	unmap_q->consumer_index = 0;
-
-	smp_mb__before_clear_bit();
-	clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
 
 	tx_info->tcb[tcb->id] = NULL;
+	tcb->priv = NULL;
 }
 
 static void
@@ -866,12 +849,6 @@ bnad_cb_rcb_setup(struct bnad *bnad, struct bna_rcb *rcb)
 }
 
 static void
-bnad_cb_rcb_destroy(struct bnad *bnad, struct bna_rcb *rcb)
-{
-	bnad_free_all_rxbufs(bnad, rcb);
-}
-
-static void
 bnad_cb_ccb_setup(struct bnad *bnad, struct bna_ccb *ccb)
 {
 	struct bnad_rx_info *rx_info =
@@ -916,7 +893,6 @@ bnad_cb_tx_resume(struct bnad *bnad, struct bna_tx *tx)
 {
 	struct bnad_tx_info *tx_info = (struct bnad_tx_info *)tx->priv;
 	struct bna_tcb *tcb;
-	struct bnad_unmap_q *unmap_q;
 	u32 txq_id;
 	int i;
 
@@ -926,23 +902,9 @@ bnad_cb_tx_resume(struct bnad *bnad, struct bna_tx *tx)
 			continue;
 		txq_id = tcb->id;
 
-		unmap_q = tcb->unmap_q;
-
-		if (test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))
-			continue;
-
-		while (test_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags))
-			cpu_relax();
-
-		bnad_free_all_txbufs(bnad, tcb);
-
-		unmap_q->producer_index = 0;
-		unmap_q->consumer_index = 0;
-
-		smp_mb__before_clear_bit();
-		clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
-
+		BUG_ON(test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags));
 		set_bit(BNAD_TXQ_TX_STARTED, &tcb->flags);
+		BUG_ON(*(tcb->hw_consumer_index) != 0);
 
 		if (netif_carrier_ok(bnad->netdev)) {
 			printk(KERN_INFO "bna: %s %d TXQ_STARTED\n",
@@ -963,6 +925,54 @@ bnad_cb_tx_resume(struct bnad *bnad, struct bna_tx *tx)
 	}
 }
 
+/*
+ * Free all TxQs buffers and then notify TX_E_CLEANUP_DONE to Tx fsm.
+ */
+static void
+bnad_tx_cleanup(struct delayed_work *work)
+{
+	struct bnad_tx_info *tx_info =
+		container_of(work, struct bnad_tx_info, tx_cleanup_work);
+	struct bnad *bnad = NULL;
+	struct bnad_unmap_q *unmap_q;
+	struct bna_tcb *tcb;
+	unsigned long flags;
+	uint32_t i, pending = 0;
+
+	for (i = 0; i < BNAD_MAX_TXQ_PER_TX; i++) {
+		tcb = tx_info->tcb[i];
+		if (!tcb)
+			continue;
+
+		bnad = tcb->bnad;
+
+		if (test_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags)) {
+			pending++;
+			continue;
+		}
+
+		bnad_free_all_txbufs(bnad, tcb);
+
+		unmap_q = tcb->unmap_q;
+		unmap_q->producer_index = 0;
+		unmap_q->consumer_index = 0;
+
+		smp_mb__before_clear_bit();
+		clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
+	}
+
+	if (pending) {
+		queue_delayed_work(bnad->work_q, &tx_info->tx_cleanup_work,
+			msecs_to_jiffies(1));
+		return;
+	}
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	bna_tx_cleanup_complete(tx_info->tx);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+}
+
+
 static void
 bnad_cb_tx_cleanup(struct bnad *bnad, struct bna_tx *tx)
 {
@@ -976,8 +986,7 @@ bnad_cb_tx_cleanup(struct bnad *bnad, struct bna_tx *tx)
 			continue;
 	}
 
-	mdelay(BNAD_TXRX_SYNC_MDELAY);
-	bna_tx_cleanup_complete(tx);
+	queue_delayed_work(bnad->work_q, &tx_info->tx_cleanup_work, 0);
 }
 
 static void
@@ -1001,6 +1010,44 @@ bnad_cb_rx_stall(struct bnad *bnad, struct bna_rx *rx)
 	}
 }
 
+/*
+ * Free all RxQs buffers and then notify RX_E_CLEANUP_DONE to Rx fsm.
+ */
+static void
+bnad_rx_cleanup(void *work)
+{
+	struct bnad_rx_info *rx_info =
+		container_of(work, struct bnad_rx_info, rx_cleanup_work);
+	struct bnad_rx_ctrl *rx_ctrl;
+	struct bnad *bnad = NULL;
+	unsigned long flags;
+	uint32_t i;
+
+	for (i = 0; i < BNAD_MAX_RXP_PER_RX; i++) {
+		rx_ctrl = &rx_info->rx_ctrl[i];
+
+		if (!rx_ctrl->ccb)
+			continue;
+
+		bnad = rx_ctrl->ccb->bnad;
+
+		/*
+		 * Wait till the poll handler has exited
+		 * and nothing can be scheduled anymore
+		 */
+		napi_disable(&rx_ctrl->napi);
+
+		bnad_cq_cmpl_init(bnad, rx_ctrl->ccb);
+		bnad_free_all_rxbufs(bnad, rx_ctrl->ccb->rcb[0]);
+		if (rx_ctrl->ccb->rcb[1])
+			bnad_free_all_rxbufs(bnad, rx_ctrl->ccb->rcb[1]);
+	}
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	bna_rx_cleanup_complete(rx_info->rx);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+}
+
 static void
 bnad_cb_rx_cleanup(struct bnad *bnad, struct bna_rx *rx)
 {
@@ -1009,8 +1056,6 @@ bnad_cb_rx_cleanup(struct bnad *bnad, struct bna_rx *rx)
 	struct bnad_rx_ctrl *rx_ctrl;
 	int i;
 
-	mdelay(BNAD_TXRX_SYNC_MDELAY);
-
 	for (i = 0; i < BNAD_MAX_RXP_PER_RX; i++) {
 		rx_ctrl = &rx_info->rx_ctrl[i];
 		ccb = rx_ctrl->ccb;
@@ -1021,12 +1066,9 @@ bnad_cb_rx_cleanup(struct bnad *bnad, struct bna_rx *rx)
 
 		if (ccb->rcb[1])
 			clear_bit(BNAD_RXQ_STARTED, &ccb->rcb[1]->flags);
-
-		while (test_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags))
-			cpu_relax();
 	}
 
-	bna_rx_cleanup_complete(rx);
+	queue_work(bnad->work_q, &rx_info->rx_cleanup_work);
 }
 
 static void
@@ -1046,13 +1088,12 @@ bnad_cb_rx_post(struct bnad *bnad, struct bna_rx *rx)
 		if (!ccb)
 			continue;
 
-		bnad_cq_cmpl_init(bnad, ccb);
+		napi_enable(&rx_ctrl->napi);
 
 		for (j = 0; j < BNAD_MAX_RXQ_PER_RXP; j++) {
 			rcb = ccb->rcb[j];
 			if (!rcb)
 				continue;
-			bnad_free_all_rxbufs(bnad, rcb);
 
 			set_bit(BNAD_RXQ_STARTED, &rcb->flags);
 			set_bit(BNAD_RXQ_POST_OK, &rcb->flags);
@@ -1704,7 +1745,7 @@ poll_exit:
 
 #define BNAD_NAPI_POLL_QUOTA		64
 static void
-bnad_napi_init(struct bnad *bnad, u32 rx_id)
+bnad_napi_add(struct bnad *bnad, u32 rx_id)
 {
 	struct bnad_rx_ctrl *rx_ctrl;
 	int i;
@@ -1718,29 +1759,13 @@ bnad_napi_init(struct bnad *bnad, u32 rx_id)
 }
 
 static void
-bnad_napi_enable(struct bnad *bnad, u32 rx_id)
-{
-	struct bnad_rx_ctrl *rx_ctrl;
-	int i;
-
-	/* Initialize & enable NAPI */
-	for (i = 0; i <	bnad->num_rxp_per_rx; i++) {
-		rx_ctrl = &bnad->rx_info[rx_id].rx_ctrl[i];
-
-		napi_enable(&rx_ctrl->napi);
-	}
-}
-
-static void
-bnad_napi_disable(struct bnad *bnad, u32 rx_id)
+bnad_napi_delete(struct bnad *bnad, u32 rx_id)
 {
 	int i;
 
 	/* First disable and then clean up */
-	for (i = 0; i < bnad->num_rxp_per_rx; i++) {
-		napi_disable(&bnad->rx_info[rx_id].rx_ctrl[i].napi);
+	for (i = 0; i < bnad->num_rxp_per_rx; i++)
 		netif_napi_del(&bnad->rx_info[rx_id].rx_ctrl[i].napi);
-	}
 }
 
 /* Should be held with conf_lock held */
@@ -1832,6 +1857,9 @@ bnad_setup_tx(struct bnad *bnad, u32 tx_id)
 		goto err_return;
 	tx_info->tx = tx;
 
+	INIT_DELAYED_WORK(&tx_info->tx_cleanup_work,
+			(work_func_t)bnad_tx_cleanup);
+
 	/* Register ISR for the Tx object */
 	if (intr_info->intr_type == BNA_INTR_T_MSIX) {
 		err = bnad_tx_msix_register(bnad, tx_info,
@@ -1928,7 +1956,7 @@ bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
 	if (rx_info->rx_ctrl[0].ccb->intr_type == BNA_INTR_T_MSIX)
 		bnad_rx_msix_unregister(bnad, rx_info, rx_config->num_paths);
 
-	bnad_napi_disable(bnad, rx_id);
+	bnad_napi_delete(bnad, rx_id);
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_rx_destroy(rx_info->rx);
@@ -1952,7 +1980,7 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	struct bna_rx_config *rx_config = &bnad->rx_config[rx_id];
 	static const struct bna_rx_event_cbfn rx_cbfn = {
 		.rcb_setup_cbfn = bnad_cb_rcb_setup,
-		.rcb_destroy_cbfn = bnad_cb_rcb_destroy,
+		.rcb_destroy_cbfn = NULL,
 		.ccb_setup_cbfn = bnad_cb_ccb_setup,
 		.ccb_destroy_cbfn = bnad_cb_ccb_destroy,
 		.rx_stall_cbfn = bnad_cb_rx_stall,
@@ -1998,11 +2026,14 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	rx_info->rx = rx;
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
+	INIT_WORK(&rx_info->rx_cleanup_work,
+			(work_func_t)(bnad_rx_cleanup));
+
 	/*
 	 * Init NAPI, so that state is set to NAPI_STATE_SCHED,
 	 * so that IRQ handler cannot schedule NAPI at this point.
 	 */
-	bnad_napi_init(bnad, rx_id);
+	bnad_napi_add(bnad, rx_id);
 
 	/* Register ISR for the Rx object */
 	if (intr_info->intr_type == BNA_INTR_T_MSIX) {
@@ -2028,9 +2059,6 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	bna_rx_enable(rx);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
-	/* Enable scheduling of NAPI */
-	bnad_napi_enable(bnad, rx_id);
-
 	return 0;
 
 err_return:
@@ -3129,6 +3157,7 @@ bnad_netdev_init(struct bnad *bnad, bool using_dac)
  * 2. Setup netdev pointer in pci_dev
  * 3. Initialze Tx free tasklet
  * 4. Initialize no. of TxQ & CQs & MSIX vectors
+ * 5. Initialize work queue.
  */
 static int
 bnad_init(struct bnad *bnad,
@@ -3174,6 +3203,12 @@ bnad_init(struct bnad *bnad,
 	tasklet_init(&bnad->tx_free_tasklet, bnad_tx_free_tasklet,
 		     (unsigned long)bnad);
 
+	sprintf(bnad->wq_name, "%s_wq_%d", BNAD_NAME, bnad->id);
+	bnad->work_q = create_singlethread_workqueue(bnad->wq_name);
+
+	if (!bnad->work_q)
+		return -ENOMEM;
+
 	return 0;
 }
 
@@ -3185,6 +3220,12 @@ bnad_init(struct bnad *bnad,
 static void
 bnad_uninit(struct bnad *bnad)
 {
+	if (bnad->work_q) {
+		flush_workqueue(bnad->work_q);
+		destroy_workqueue(bnad->work_q);
+		bnad->work_q = NULL;
+	}
+
 	if (bnad->bar0)
 		iounmap(bnad->bar0);
 	pci_set_drvdata(bnad->pcidev, NULL);
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 55824d9..ff129aa 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -210,6 +210,7 @@ struct bnad_tx_info {
 	struct bna_tx *tx; /* 1:1 between tx_info & tx */
 	struct bna_tcb *tcb[BNAD_MAX_TXQ_PER_TX];
 	u32 tx_id;
+	struct delayed_work tx_cleanup_work;
 } ____cacheline_aligned;
 
 struct bnad_rx_info {
@@ -217,6 +218,7 @@ struct bnad_rx_info {
 
 	struct bnad_rx_ctrl rx_ctrl[BNAD_MAX_RXP_PER_RX];
 	u32 rx_id;
+	struct work_struct rx_cleanup_work;
 } ____cacheline_aligned;
 
 /* Unmap queues for Tx / Rx cleanup */
@@ -319,6 +321,7 @@ struct bnad {
 	mac_t			perm_addr;
 
 	struct tasklet_struct	tx_free_tasklet;
+	struct workqueue_struct *work_q;
 
 	/* Statistics */
 	struct bnad_stats stats;
@@ -328,6 +331,7 @@ struct bnad {
 	char			adapter_name[BNAD_NAME_LEN];
 	char			port_name[BNAD_NAME_LEN];
 	char			mbox_irq_name[BNAD_NAME_LEN];
+	char			wq_name[BNAD_NAME_LEN];
 
 	/* debugfs specific data */
 	char	*regdata;
-- 
1.6.5.2
