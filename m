From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 03/13] bna: Interrupt Polling and NAPI Init Changes
Date: Fri, 19 Aug 2011 14:39:22 -0700
Message-ID: <1313789972-22711-4-git-send-email-rmody@brocade.com>
References: <1313789972-22711-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38063 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755130Ab1HSVj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 17:39:56 -0400
In-Reply-To: <1313789972-22711-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Remove unnecessary ccb check from bnad_poll_cq
 - Add bnad pointer to rx_ctrl structure, so that bnad can be accessed directly
   from rx_ctrl in the NAPI poll routines, even if ccb is NULL
 - Validate ccb before referencing to it in bnad_msix_rx and bnad_napi_poll_rx
 - Fix the order of NAPI init / uninit in Tx / Rx setup / teardown path:
   a. Kill bnad tx free tasklet ahead of call to bna_tx_destroy()
   b. Call NAPI disable only after call to Rx free_irq(). This makes sure Rx
      interrupt does not schedule a poll when NAPI is already disabled
 - NAPI poll runs before the h/w has completed configuration. This causes a
   crash. Delay enabling NAPI till after bna_rx_enable(). Split NAPI
   initialization into 2 steps, bnad_napi_init() & bnad_napi_enable().

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |   83 ++++++++++++++++++++-----------
 drivers/net/ethernet/brocade/bna/bnad.h |    1 +
 2 files changed, 54 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 3f19a4d..095eac9 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -535,16 +535,11 @@ next:
 
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
 
@@ -590,9 +585,9 @@ static irqreturn_t
 bnad_msix_rx(int irq, void *data)
 {
 	struct bna_ccb *ccb = (struct bna_ccb *)data;
-	struct bnad *bnad = ccb->bnad;
 
-	bnad_netif_rx_schedule_poll(bnad, ccb);
+	if (ccb)
+		bnad_netif_rx_schedule_poll(ccb->bnad, ccb);
 
 	return IRQ_HANDLED;
 }
@@ -1658,18 +1653,14 @@ bnad_napi_poll_rx(struct napi_struct *napi, int budget)
 {
 	struct bnad_rx_ctrl *rx_ctrl =
 		container_of(napi, struct bnad_rx_ctrl, napi);
-	struct bna_ccb *ccb;
-	struct bnad *bnad;
+	struct bnad *bnad = rx_ctrl->bnad;
 	int rcvd = 0;
 
-	ccb = rx_ctrl->ccb;
-
-	bnad = ccb->bnad;
 
 	if (!netif_carrier_ok(bnad->netdev))
 		goto poll_exit;
 
-	rcvd = bnad_poll_cq(bnad, ccb, budget);
+	rcvd = bnad_poll_cq(bnad, rx_ctrl->ccb, budget);
 	if (rcvd == budget)
 		return rcvd;
 
@@ -1678,12 +1669,15 @@ poll_exit:
 
 	BNAD_UPDATE_CTR(bnad, netif_rx_complete);
 
-	bnad_enable_rx_irq(bnad, ccb);
+
+	if (rx_ctrl->ccb)
+		bnad_enable_rx_irq(bnad, rx_ctrl->ccb);
 	return rcvd;
 }
 
+#define BNAD_NAPI_POLL_QUOTA		64
 static void
-bnad_napi_enable(struct bnad *bnad, u32 rx_id)
+bnad_napi_init(struct bnad *bnad, u32 rx_id)
 {
 	struct bnad_rx_ctrl *rx_ctrl;
 	int i;
@@ -1691,9 +1685,20 @@ bnad_napi_enable(struct bnad *bnad, u32 rx_id)
 	/* Initialize & enable NAPI */
 	for (i = 0; i <	bnad->num_rxp_per_rx; i++) {
 		rx_ctrl = &bnad->rx_info[rx_id].rx_ctrl[i];
-
 		netif_napi_add(bnad->netdev, &rx_ctrl->napi,
-			       bnad_napi_poll_rx, 64);
+			       bnad_napi_poll_rx, BNAD_NAPI_POLL_QUOTA);
+	}
+}
+
+static void
+bnad_napi_enable(struct bnad *bnad, u32 rx_id)
+{
+	struct bnad_rx_ctrl *rx_ctrl;
+	int i;
+
+	/* Initialize & enable NAPI */
+	for (i = 0; i <	bnad->num_rxp_per_rx; i++) {
+		rx_ctrl = &bnad->rx_info[rx_id].rx_ctrl[i];
 
 		napi_enable(&rx_ctrl->napi);
 	}
@@ -1732,6 +1737,9 @@ bnad_cleanup_tx(struct bnad *bnad, u32 tx_id)
 		bnad_tx_msix_unregister(bnad, tx_info,
 			bnad->num_txq_per_tx);
 
+	if (0 == tx_id)
+		tasklet_kill(&bnad->tx_free_tasklet);
+
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_tx_destroy(tx_info->tx);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
@@ -1739,9 +1747,6 @@ bnad_cleanup_tx(struct bnad *bnad, u32 tx_id)
 	tx_info->tx = NULL;
 	tx_info->tx_id = 0;
 
-	if (0 == tx_id)
-		tasklet_kill(&bnad->tx_free_tasklet);
-
 	bnad_tx_res_free(bnad, res_info);
 }
 
@@ -1852,6 +1857,16 @@ bnad_init_rx_config(struct bnad *bnad, struct bna_rx_config *rx_config)
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
@@ -1875,8 +1890,6 @@ bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
 			del_timer_sync(&bnad->dim_timer);
 	}
 
-	bnad_napi_disable(bnad, rx_id);
-
 	init_completion(&bnad->bnad_completions.rx_comp);
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_rx_disable(rx_info->rx, BNA_HARD_CLEANUP, bnad_cb_rx_disabled);
@@ -1886,6 +1899,8 @@ bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
 	if (rx_info->rx_ctrl[0].ccb->intr_type == BNA_INTR_T_MSIX)
 		bnad_rx_msix_unregister(bnad, rx_info, rx_config->num_paths);
 
+	bnad_napi_disable(bnad, rx_id);
+
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_rx_destroy(rx_info->rx);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
@@ -1939,6 +1954,8 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	if (err)
 		return err;
 
+	bnad_rx_ctrl_init(bnad, rx_id);
+
 	/* Ask BNA to create one Rx object, supplying required resources */
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	rx = bna_rx_create(&bnad->bna, bnad, rx_config, &rx_cbfn, res_info,
@@ -1948,6 +1965,12 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 		goto err_return;
 	rx_info->rx = rx;
 
+	/*
+	 * Init NAPI, so that state is set to NAPI_STATE_SCHED,
+	 * so that IRQ handler cannot schedule NAPI at this point.
+	 */
+	bnad_napi_init(bnad, rx_id);
+
 	/* Register ISR for the Rx object */
 	if (intr_info->intr_type == BNA_INTR_T_MSIX) {
 		err = bnad_rx_msix_register(bnad, rx_info, rx_id,
@@ -1956,9 +1979,6 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 			goto err_return;
 	}
 
-	/* Enable NAPI */
-	bnad_napi_enable(bnad, rx_id);
-
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	if (0 == rx_id) {
 		/* Set up Dynamic Interrupt Moderation Vector */
@@ -1975,6 +1995,9 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	bna_rx_enable(rx);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
+	/* Enable scheduling of NAPI */
+	bnad_napi_enable(bnad, rx_id);
+
 	return 0;
 
 err_return:
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 3c23139..60c2e9d 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -53,6 +53,7 @@
  */
 struct bnad_rx_ctrl {
 	struct bna_ccb *ccb;
+	struct bnad *bnad;
 	unsigned long  flags;
 	struct napi_struct	napi;
 };
-- 
1.7.1

