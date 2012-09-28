From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/7 net-next v2] tg3: Introduce separate functions to
 allocate/free RX/TX rings.
Date: Fri, 28 Sep 2012 10:12:37 -0700
Message-ID: <1348852363-8582-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3446 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758342Ab2I2Blp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 21:41:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is preparation work to allow the number of RX and TX rings to be
configured separately.

Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  220 +++++++++++++++++++++++------------
 drivers/net/ethernet/broadcom/tg3.h |    2 +
 2 files changed, 146 insertions(+), 76 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index bf906c5..93b8120 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7607,15 +7607,11 @@ static int tg3_init_rings(struct tg3 *tp)
 	return 0;
 }
 
-/*
- * Must not be invoked with interrupt sources disabled and
- * the hardware shutdown down.
- */
-static void tg3_free_consistent(struct tg3 *tp)
+static void tg3_mem_tx_release(struct tg3 *tp)
 {
 	int i;
 
-	for (i = 0; i < tp->irq_cnt; i++) {
+	for (i = 0; i < tp->irq_max; i++) {
 		struct tg3_napi *tnapi = &tp->napi[i];
 
 		if (tnapi->tx_ring) {
@@ -7626,17 +7622,114 @@ static void tg3_free_consistent(struct tg3 *tp)
 
 		kfree(tnapi->tx_buffers);
 		tnapi->tx_buffers = NULL;
+	}
+}
 
-		if (tnapi->rx_rcb) {
-			dma_free_coherent(&tp->pdev->dev,
-					  TG3_RX_RCB_RING_BYTES(tp),
-					  tnapi->rx_rcb,
-					  tnapi->rx_rcb_mapping);
-			tnapi->rx_rcb = NULL;
-		}
+static int tg3_mem_tx_acquire(struct tg3 *tp)
+{
+	int i;
+	struct tg3_napi *tnapi = &tp->napi[0];
+
+	/* If multivector TSS is enabled, vector 0 does not handle
+	 * tx interrupts.  Don't allocate any resources for it.
+	 */
+	if (tg3_flag(tp, ENABLE_TSS))
+		tnapi++;
+
+	for (i = 0; i < tp->txq_cnt; i++, tnapi++) {
+		tnapi->tx_buffers = kzalloc(sizeof(struct tg3_tx_ring_info) *
+					    TG3_TX_RING_SIZE, GFP_KERNEL);
+		if (!tnapi->tx_buffers)
+			goto err_out;
+
+		tnapi->tx_ring = dma_alloc_coherent(&tp->pdev->dev,
+						    TG3_TX_RING_BYTES,
+						    &tnapi->tx_desc_mapping,
+						    GFP_KERNEL);
+		if (!tnapi->tx_ring)
+			goto err_out;
+	}
+
+	return 0;
+
+err_out:
+	tg3_mem_tx_release(tp);
+	return -ENOMEM;
+}
+
+static void tg3_mem_rx_release(struct tg3 *tp)
+{
+	int i;
+
+	for (i = 0; i < tp->irq_max; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
 
 		tg3_rx_prodring_fini(tp, &tnapi->prodring);
 
+		if (!tnapi->rx_rcb)
+			continue;
+
+		dma_free_coherent(&tp->pdev->dev,
+				  TG3_RX_RCB_RING_BYTES(tp),
+				  tnapi->rx_rcb,
+				  tnapi->rx_rcb_mapping);
+		tnapi->rx_rcb = NULL;
+	}
+}
+
+static int tg3_mem_rx_acquire(struct tg3 *tp)
+{
+	unsigned int i, limit;
+
+	limit = tp->rxq_cnt;
+
+	/* If RSS is enabled, we need a (dummy) producer ring
+	 * set on vector zero.  This is the true hw prodring.
+	 */
+	if (tg3_flag(tp, ENABLE_RSS))
+		limit++;
+
+	for (i = 0; i < limit; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+
+		if (tg3_rx_prodring_init(tp, &tnapi->prodring))
+			goto err_out;
+
+		/* If multivector RSS is enabled, vector 0
+		 * does not handle rx or tx interrupts.
+		 * Don't allocate any resources for it.
+		 */
+		if (!i && tg3_flag(tp, ENABLE_RSS))
+			continue;
+
+		tnapi->rx_rcb = dma_alloc_coherent(&tp->pdev->dev,
+						   TG3_RX_RCB_RING_BYTES(tp),
+						   &tnapi->rx_rcb_mapping,
+						   GFP_KERNEL);
+		if (!tnapi->rx_rcb)
+			goto err_out;
+
+		memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
+	}
+
+	return 0;
+
+err_out:
+	tg3_mem_rx_release(tp);
+	return -ENOMEM;
+}
+
+/*
+ * Must not be invoked with interrupt sources disabled and
+ * the hardware shutdown down.
+ */
+static void tg3_free_consistent(struct tg3 *tp)
+{
+	int i;
+
+	for (i = 0; i < tp->irq_cnt; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+
 		if (tnapi->hw_status) {
 			dma_free_coherent(&tp->pdev->dev, TG3_HW_STATUS_SIZE,
 					  tnapi->hw_status,
@@ -7645,6 +7738,9 @@ static void tg3_free_consistent(struct tg3 *tp)
 		}
 	}
 
+	tg3_mem_rx_release(tp);
+	tg3_mem_tx_release(tp);
+
 	if (tp->hw_stats) {
 		dma_free_coherent(&tp->pdev->dev, sizeof(struct tg3_hw_stats),
 				  tp->hw_stats, tp->stats_mapping);
@@ -7683,72 +7779,38 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
 		sblk = tnapi->hw_status;
 
-		if (tg3_rx_prodring_init(tp, &tnapi->prodring))
-			goto err_out;
+		if (tg3_flag(tp, ENABLE_RSS)) {
+			u16 *prodptr = 0;
 
-		/* If multivector TSS is enabled, vector 0 does not handle
-		 * tx interrupts.  Don't allocate any resources for it.
-		 */
-		if ((!i && !tg3_flag(tp, ENABLE_TSS)) ||
-		    (i && tg3_flag(tp, ENABLE_TSS))) {
-			tnapi->tx_buffers = kzalloc(
-					       sizeof(struct tg3_tx_ring_info) *
-					       TG3_TX_RING_SIZE, GFP_KERNEL);
-			if (!tnapi->tx_buffers)
-				goto err_out;
-
-			tnapi->tx_ring = dma_alloc_coherent(&tp->pdev->dev,
-							    TG3_TX_RING_BYTES,
-							&tnapi->tx_desc_mapping,
-							    GFP_KERNEL);
-			if (!tnapi->tx_ring)
-				goto err_out;
-		}
-
-		/*
-		 * When RSS is enabled, the status block format changes
-		 * slightly.  The "rx_jumbo_consumer", "reserved",
-		 * and "rx_mini_consumer" members get mapped to the
-		 * other three rx return ring producer indexes.
-		 */
-		switch (i) {
-		default:
-			if (tg3_flag(tp, ENABLE_RSS)) {
-				tnapi->rx_rcb_prod_idx = NULL;
+			/*
+			 * When RSS is enabled, the status block format changes
+			 * slightly.  The "rx_jumbo_consumer", "reserved",
+			 * and "rx_mini_consumer" members get mapped to the
+			 * other three rx return ring producer indexes.
+			 */
+			switch (i) {
+			case 1:
+				prodptr = &sblk->idx[0].rx_producer;
+				break;
+			case 2:
+				prodptr = &sblk->rx_jumbo_consumer;
+				break;
+			case 3:
+				prodptr = &sblk->reserved;
+				break;
+			case 4:
+				prodptr = &sblk->rx_mini_consumer;
 				break;
 			}
-			/* Fall through */
-		case 1:
+			tnapi->rx_rcb_prod_idx = prodptr;
+		} else {
 			tnapi->rx_rcb_prod_idx = &sblk->idx[0].rx_producer;
-			break;
-		case 2:
-			tnapi->rx_rcb_prod_idx = &sblk->rx_jumbo_consumer;
-			break;
-		case 3:
-			tnapi->rx_rcb_prod_idx = &sblk->reserved;
-			break;
-		case 4:
-			tnapi->rx_rcb_prod_idx = &sblk->rx_mini_consumer;
-			break;
 		}
-
-		/*
-		 * If multivector RSS is enabled, vector 0 does not handle
-		 * rx or tx interrupts.  Don't allocate any resources for it.
-		 */
-		if (!i && tg3_flag(tp, ENABLE_RSS))
-			continue;
-
-		tnapi->rx_rcb = dma_alloc_coherent(&tp->pdev->dev,
-						   TG3_RX_RCB_RING_BYTES(tp),
-						   &tnapi->rx_rcb_mapping,
-						   GFP_KERNEL);
-		if (!tnapi->rx_rcb)
-			goto err_out;
-
-		memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 	}
 
+	if (tg3_mem_tx_acquire(tp) || tg3_mem_rx_acquire(tp))
+		goto err_out;
+
 	return 0;
 
 err_out:
@@ -10154,6 +10216,7 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		 * one to the number of vectors we are requesting.
 		 */
 		tp->irq_cnt = min_t(unsigned, tp->irq_cnt + 1, tp->irq_max);
+		tp->rxq_cnt = tp->irq_cnt - 1;
 	}
 
 	for (i = 0; i < tp->irq_max; i++) {
@@ -10170,14 +10233,13 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		netdev_notice(tp->dev, "Requested %d MSI-X vectors, received %d\n",
 			      tp->irq_cnt, rc);
 		tp->irq_cnt = rc;
+		tp->rxq_cnt = max(rc - 1, 1);
 	}
 
 	for (i = 0; i < tp->irq_max; i++)
 		tp->napi[i].irq_vec = msix_ent[i].vector;
 
-	netif_set_real_num_tx_queues(tp->dev, 1);
-	rc = tp->irq_cnt > 1 ? tp->irq_cnt - 1 : 1;
-	if (netif_set_real_num_rx_queues(tp->dev, rc)) {
+	if (netif_set_real_num_rx_queues(tp->dev, tp->rxq_cnt)) {
 		pci_disable_msix(tp->pdev);
 		return false;
 	}
@@ -10188,7 +10250,8 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
 			tg3_flag_set(tp, ENABLE_TSS);
-			netif_set_real_num_tx_queues(tp->dev, tp->irq_cnt - 1);
+			tp->txq_cnt = tp->rxq_cnt;
+			netif_set_real_num_tx_queues(tp->dev, tp->txq_cnt);
 		}
 	}
 
@@ -10224,6 +10287,11 @@ defcfg:
 	if (!tg3_flag(tp, USING_MSIX)) {
 		tp->irq_cnt = 1;
 		tp->napi[0].irq_vec = tp->pdev->irq;
+	}
+
+	if (tp->irq_cnt == 1) {
+		tp->txq_cnt = 1;
+		tp->rxq_cnt = 1;
 		netif_set_real_num_tx_queues(tp->dev, 1);
 		netif_set_real_num_rx_queues(tp->dev, 1);
 	}
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 6d52cb2..5838dea 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3037,6 +3037,7 @@ struct tg3 {
 	void				(*write32_tx_mbox) (struct tg3 *, u32,
 							    u32);
 	u32				dma_limit;
+	u32				txq_cnt;
 
 	/* begin "rx thread" cacheline section */
 	struct tg3_napi			napi[TG3_IRQ_MAX_VECS];
@@ -3051,6 +3052,7 @@ struct tg3 {
 	u32				rx_std_max_post;
 	u32				rx_offset;
 	u32				rx_pkt_map_sz;
+	u32				rxq_cnt;
 	bool				rx_refill;
 
 
-- 
1.7.1
