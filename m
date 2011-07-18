From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 35/45] bna: Change TxQ Select Logic and Interrupt Handling
Date: Mon, 18 Jul 2011 01:22:55 -0700
Message-ID: <1310977385-5268-25-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37829 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753918Ab1GRIYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:55 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Simplify the TxQ selection logic:
   Macro BNAD_TXQ_ID_GET() calls bnad_tx_select_queue(), which returns priority.
   While only a few packets during transition could have wrong priority, all
   will be associated with a valid non-NULL tcb.
 - Add bnad pointer to rx_ctrl structure, so that bnad can be accessed directly
   from rx_ctrl in the NAPI poll routines, even if ccb is NULL
 - Fix the order of init / uninit in Tx / Rx setup / teardown path:
   Kill bnad tx free tasklet ahead of call to bna_tx_destroy().
   Call NAPI disable only aftet call to Rx free_irq(). This makes sure Rx
   interrupt does not schedule a poll when NAPI is already disabled.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |   70 +++++++++++++++++++++++++++++++----------------
 drivers/net/bna/bnad.h |    1 +
 2 files changed, 47 insertions(+), 24 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 8ca1b60..3f9ddbf 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -554,16 +554,11 @@ next:
 
 	BNA_QE_INDX_ADD(ccb->producer_index, wis, ccb->q_depth);
 
-	if (likely(ccb)) {
-		if (likely(test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)))
-			bna_ib_ack(ccb->i_dbell, packets);
-		bnad_refill_rxq(bnad, ccb->rcb[0]);
-		if (ccb->rcb[1])
-			bnad_refill_rxq(bnad, ccb->rcb[1]);
-	} else {
-		if (likely(test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)))
-			bna_ib_ack(ccb->i_dbell, 0);
-	}
+	if (likely(test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags)))
+		bna_ib_ack(ccb->i_dbell, packets);
+	bnad_refill_rxq(bnad, ccb->rcb[0]);
+	if (ccb->rcb[1])
+		bnad_refill_rxq(bnad, ccb->rcb[1]);
 
 	clear_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags);
 
@@ -613,7 +608,8 @@ bnad_msix_rx(int irq, void *data)
 	struct bna_ccb *ccb = (struct bna_ccb *)data;
 	struct bnad *bnad = ccb->bnad;
 
-	bnad_netif_rx_schedule_poll(bnad, ccb);
+	if (ccb)
+		bnad_netif_rx_schedule_poll(bnad, ccb);
 
 	return IRQ_HANDLED;
 }
@@ -652,6 +648,7 @@ bnad_isr(int irq, void *data)
 	struct bnad *bnad = (struct bnad *)data;
 	struct bnad_rx_info *rx_info;
 	struct bnad_rx_ctrl *rx_ctrl;
+	struct bna_tcb *tcb = NULL;
 
 	if (unlikely(test_bit(BNAD_RF_MBOX_IRQ_DISABLED, &bnad->run_flags)))
 		return IRQ_NONE;
@@ -674,8 +671,11 @@ bnad_isr(int irq, void *data)
 	/* Process data interrupts */
 	/* Tx processing */
 	for (i = 0; i < bnad->num_tx; i++) {
-		for (j = 0; j < bnad->num_txq_per_tx; j++)
-			bnad_tx(bnad, bnad->tx_info[i].tcb[j]);
+		for (j = 0; j < bnad->num_txq_per_tx; j++) {
+			tcb = bnad->tx_info[i].tcb[j];
+			if (tcb && test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))
+				bnad_tx(bnad, bnad->tx_info[i].tcb[j]);
+		}
 	}
 	/* Rx processing */
 	for (i = 0; i < bnad->num_rx; i++) {
@@ -1773,6 +1773,9 @@ bnad_cleanup_tx(struct bnad *bnad, u32 tx_id)
 		bnad_tx_msix_unregister(bnad, tx_info,
 			bnad->num_txq_per_tx);
 
+	if (0 == tx_id)
+		tasklet_kill(&bnad->tx_free_tasklet);
+
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_tx_destroy(tx_info->tx);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
@@ -1780,9 +1783,6 @@ bnad_cleanup_tx(struct bnad *bnad, u32 tx_id)
 	tx_info->tx = NULL;
 	tx_info->tx_id = 0;
 
-	if (0 == tx_id)
-		tasklet_kill(&bnad->tx_free_tasklet);
-
 	bnad_tx_res_free(bnad, res_info);
 }
 
@@ -1918,6 +1918,16 @@ bnad_init_rx_config(struct bnad *bnad, struct bna_rx_config *rx_config)
 	rx_config->vlan_strip_status = BNA_STATUS_T_ENABLED;
 }
 
+static void
+bnad_rx_ctrl_init(struct bnad *bnad, u32 rx_id)
+{
+	struct bnad_rx_info *rx_info = &bnad->rx_info[rx_id];
+	int i;
+
+	for (i = 0; i < bnad->num_rxp_per_rx; i++)
+		rx_info->rx_ctrl[i].bnad = bnad;
+}
+
 /* Called with mutex_lock(&bnad->conf_mutex) held */
 void
 bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
@@ -1941,8 +1951,6 @@ bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
 			del_timer_sync(&bnad->dim_timer);
 	}
 
-	bnad_napi_disable(bnad, rx_id);
-
 	init_completion(&bnad->bnad_completions.rx_comp);
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_rx_disable(rx_info->rx, BNA_HARD_CLEANUP, bnad_cb_rx_disabled);
@@ -1952,6 +1960,8 @@ bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
 	if (rx_info->rx_ctrl[0].ccb->intr_type == BNA_INTR_T_MSIX)
 		bnad_rx_msix_unregister(bnad, rx_info, rx_config->num_paths);
 
+	bnad_napi_disable(bnad, rx_id);
+
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_rx_destroy(rx_info->rx);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
@@ -2005,6 +2015,8 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	if (err)
 		return err;
 
+	bnad_rx_ctrl_init(bnad, rx_id);
+
 	/* Ask BNA to create one Rx object, supplying required resources */
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	rx = bna_rx_create(&bnad->bna, bnad, rx_config, &rx_cbfn, res_info,
@@ -2014,6 +2026,9 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 		goto err_return;
 	rx_info->rx = rx;
 
+	/* Enable NAPI */
+	bnad_napi_enable(bnad, rx_id);
+
 	/* Register ISR for the Rx object */
 	if (intr_info->intr_type == BNA_INTR_T_MSIX) {
 		err = bnad_rx_msix_register(bnad, rx_info, rx_id,
@@ -2022,9 +2037,6 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 			goto err_return;
 	}
 
-	/* Enable NAPI */
-	bnad_napi_enable(bnad, rx_id);
-
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	if (0 == rx_id) {
 		/* Set up Dynamic Interrupt Moderation Vector */
@@ -2602,15 +2614,15 @@ static netdev_tx_t
 bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
-	u32 txq_id = 0;
-	struct bna_tcb *tcb = bnad->tx_info[0].tcb[txq_id];
+	struct bna_tcb *tcb = NULL;
+	u32 txq_id;
+	struct bnad_unmap_q *unmap_q;
 
 	u16		txq_prod, vlan_tag = 0;
 	u32		unmap_prod, wis, wis_used, wi_range;
 	u32		vectors, vect_id, i, acked;
 	int			err;
 
-	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 	dma_addr_t		dma_addr;
 	struct bna_txq_entry *txqent;
 	u16	flags;
@@ -2621,6 +2633,16 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
+	txq_id = skb_get_queue_mapping(skb);
+
+	tcb = bnad->tx_info[0].tcb[txq_id];
+
+	if (unlikely(!tcb)) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	unmap_q = tcb->unmap_q;
 	/*
 	 * Takes care of the Tx that is scheduled between clearing the flag
 	 * and the netif_stop_all_queue() call.
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 1b87b27..4f9da1c 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -51,6 +51,7 @@
  */
 struct bnad_rx_ctrl {
 	struct bna_ccb *ccb;
+	struct bnad *bnad;
 	unsigned long  flags;
 	struct napi_struct	napi;
 };
-- 
1.7.1

