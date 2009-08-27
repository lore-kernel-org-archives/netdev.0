From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/3] qlge: Move TX completions from workqueue to NAPI.
Date: Thu, 27 Aug 2009 14:02:11 -0700
Message-ID: <1251406931-15107-4-git-send-email-ron.mercer@qlogic.com>
References: <1251406931-15107-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40659 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbZH0VHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 17:07:53 -0400
In-Reply-To: <1251406931-15107-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX completions were running in a workqueue queued by the ISR.  This
patch moves the processing of TX completions to an existing RSS NAPI
context.
Now each irq vector runs NAPI for one RSS ring and one or more TX
completion rings.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    7 +-
 drivers/net/qlge/qlge_main.c |  266 +++++++++++++++++++++---------------------
 2 files changed, 137 insertions(+), 136 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index ed5dbca..a9845a2 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1292,7 +1292,6 @@ struct rx_ring {
 	u32 cpu;		/* Which CPU this should run on. */
 	char name[IFNAMSIZ + 5];
 	struct napi_struct napi;
-	struct delayed_work rx_work;
 	u8 reserved;
 	struct ql_adapter *qdev;
 };
@@ -1366,6 +1365,7 @@ struct nic_stats {
 struct intr_context {
 	struct ql_adapter *qdev;
 	u32 intr;
+	u32 irq_mask;		/* Mask of which rings the vector services. */
 	u32 hooked;
 	u32 intr_en_mask;	/* value/mask used to enable this intr */
 	u32 intr_dis_mask;	/* value/mask used to disable this intr */
@@ -1486,11 +1486,11 @@ struct ql_adapter {
 	struct intr_context intr_context[MAX_RX_RINGS];
 
 	int tx_ring_count;	/* One per online CPU. */
-	u32 rss_ring_count;	/* One per online CPU.  */
+	u32 rss_ring_count;	/* One per irq vector.  */
 	/*
 	 * rx_ring_count =
 	 *  (CPU count * outbound completion rx_ring) +
-	 *  (CPU count * inbound (RSS) completion rx_ring)
+	 *  (irq_vector_cnt * inbound (RSS) completion rx_ring)
 	 */
 	int rx_ring_count;
 	int ring_mem_size;
@@ -1517,7 +1517,6 @@ struct ql_adapter {
 	union flash_params flash;
 
 	struct net_device_stats stats;
-	struct workqueue_struct *q_workqueue;
 	struct workqueue_struct *workqueue;
 	struct delayed_work asic_reset_work;
 	struct delayed_work mpi_reset_work;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 0cbda4d..8dd266b 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1859,11 +1859,41 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 {
 	struct rx_ring *rx_ring = container_of(napi, struct rx_ring, napi);
 	struct ql_adapter *qdev = rx_ring->qdev;
-	int work_done = ql_clean_inbound_rx_ring(rx_ring, budget);
+	struct rx_ring *trx_ring;
+	int i, work_done = 0;
+	struct intr_context *ctx = &qdev->intr_context[rx_ring->cq_id];
 
 	QPRINTK(qdev, RX_STATUS, DEBUG, "Enter, NAPI POLL cq_id = %d.\n",
 		rx_ring->cq_id);
 
+	/* Service the TX rings first.  They start
+	 * right after the RSS rings. */
+	for (i = qdev->rss_ring_count; i < qdev->rx_ring_count; i++) {
+		trx_ring = &qdev->rx_ring[i];
+		/* If this TX completion ring belongs to this vector and
+		 * it's not empty then service it.
+		 */
+		if ((ctx->irq_mask & (1 << trx_ring->cq_id)) &&
+			(ql_read_sh_reg(trx_ring->prod_idx_sh_reg) !=
+					trx_ring->cnsmr_idx)) {
+			QPRINTK(qdev, INTR, DEBUG,
+				"%s: Servicing TX completion ring %d.\n",
+				__func__, trx_ring->cq_id);
+			ql_clean_outbound_rx_ring(trx_ring);
+		}
+	}
+
+	/*
+	 * Now service the RSS ring if it's active.
+	 */
+	if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) !=
+					rx_ring->cnsmr_idx) {
+		QPRINTK(qdev, INTR, DEBUG,
+			"%s: Servicing RX completion ring %d.\n",
+			__func__, rx_ring->cq_id);
+		work_done = ql_clean_inbound_rx_ring(rx_ring, budget);
+	}
+
 	if (work_done < budget) {
 		napi_complete(napi);
 		ql_enable_completion_interrupt(qdev, rx_ring->irq);
@@ -1925,38 +1955,6 @@ static void ql_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 
 }
 
-/* Worker thread to process a given rx_ring that is dedicated
- * to outbound completions.
- */
-static void ql_tx_clean(struct work_struct *work)
-{
-	struct rx_ring *rx_ring =
-	    container_of(work, struct rx_ring, rx_work.work);
-	ql_clean_outbound_rx_ring(rx_ring);
-	ql_enable_completion_interrupt(rx_ring->qdev, rx_ring->irq);
-
-}
-
-/* Worker thread to process a given rx_ring that is dedicated
- * to inbound completions.
- */
-static void ql_rx_clean(struct work_struct *work)
-{
-	struct rx_ring *rx_ring =
-	    container_of(work, struct rx_ring, rx_work.work);
-	ql_clean_inbound_rx_ring(rx_ring, 64);
-	ql_enable_completion_interrupt(rx_ring->qdev, rx_ring->irq);
-}
-
-/* MSI-X Multiple Vector Interrupt Handler for outbound completions. */
-static irqreturn_t qlge_msix_tx_isr(int irq, void *dev_id)
-{
-	struct rx_ring *rx_ring = dev_id;
-	queue_delayed_work_on(rx_ring->cpu, rx_ring->qdev->q_workqueue,
-			      &rx_ring->rx_work, 0);
-	return IRQ_HANDLED;
-}
-
 /* MSI-X Multiple Vector Interrupt Handler for inbound completions. */
 static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
 {
@@ -1976,7 +1974,6 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	struct ql_adapter *qdev = rx_ring->qdev;
 	struct intr_context *intr_context = &qdev->intr_context[0];
 	u32 var;
-	int i;
 	int work_done = 0;
 
 	spin_lock(&qdev->hw_lock);
@@ -2017,41 +2014,18 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	}
 
 	/*
-	 * Check the default queue and wake handler if active.
+	 * Get the bit-mask that shows the active queues for this
+	 * pass.  Compare it to the queues that this irq services
+	 * and call napi if there's a match.
 	 */
-	rx_ring = &qdev->rx_ring[0];
-	if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) != rx_ring->cnsmr_idx) {
-		QPRINTK(qdev, INTR, INFO, "Waking handler for rx_ring[0].\n");
-		ql_disable_completion_interrupt(qdev, intr_context->intr);
-		queue_delayed_work_on(smp_processor_id(), qdev->q_workqueue,
-				      &rx_ring->rx_work, 0);
-		work_done++;
-	}
-
-	if (!test_bit(QL_MSIX_ENABLED, &qdev->flags)) {
-		/*
-		 * Start the DPC for each active queue.
-		 */
-		for (i = 1; i < qdev->rx_ring_count; i++) {
-			rx_ring = &qdev->rx_ring[i];
-			if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) !=
-			    rx_ring->cnsmr_idx) {
+	var = ql_read32(qdev, ISR1);
+	if (var & intr_context->irq_mask) {
 				QPRINTK(qdev, INTR, INFO,
-					"Waking handler for rx_ring[%d].\n", i);
-				ql_disable_completion_interrupt(qdev,
-								intr_context->
-								intr);
-				if (i >= qdev->rss_ring_count)
-					queue_delayed_work_on(rx_ring->cpu,
-							      qdev->q_workqueue,
-							      &rx_ring->rx_work,
-							      0);
-				else
+			"Waking handler for rx_ring[0].\n");
+		ql_disable_completion_interrupt(qdev, intr_context->intr);
 					napi_schedule(&rx_ring->napi);
 				work_done++;
 			}
-		}
-	}
 	ql_enable_completion_interrupt(qdev, intr_context->intr);
 	return work_done ? IRQ_HANDLED : IRQ_NONE;
 }
@@ -2703,35 +2677,9 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	}
 	switch (rx_ring->type) {
 	case TX_Q:
-		/* If there's only one interrupt, then we use
-		 * worker threads to process the outbound
-		 * completion handling rx_rings. We do this so
-		 * they can be run on multiple CPUs. There is
-		 * room to play with this more where we would only
-		 * run in a worker if there are more than x number
-		 * of outbound completions on the queue and more
-		 * than one queue active.  Some threshold that
-		 * would indicate a benefit in spite of the cost
-		 * of a context switch.
-		 * If there's more than one interrupt, then the
-		 * outbound completions are processed in the ISR.
-		 */
-		if (!test_bit(QL_MSIX_ENABLED, &qdev->flags))
-			INIT_DELAYED_WORK(&rx_ring->rx_work, ql_tx_clean);
-		else {
-			/* With all debug warnings on we see a WARN_ON message
-			 * when we free the skb in the interrupt context.
-			 */
-			INIT_DELAYED_WORK(&rx_ring->rx_work, ql_tx_clean);
-		}
 		cqicb->irq_delay = cpu_to_le16(qdev->tx_coalesce_usecs);
 		cqicb->pkt_delay = cpu_to_le16(qdev->tx_max_coalesced_frames);
 		break;
-	case DEFAULT_Q:
-		INIT_DELAYED_WORK(&rx_ring->rx_work, ql_rx_clean);
-		cqicb->irq_delay = 0;
-		cqicb->pkt_delay = 0;
-		break;
 	case RX_Q:
 		/* Inbound completion handling rx_rings run in
 		 * separate NAPI contexts.
@@ -2878,6 +2826,71 @@ msi:
 	QPRINTK(qdev, IFUP, DEBUG, "Running with legacy interrupts.\n");
 }
 
+/* Each vector services 1 RSS ring and and 1 or more
+ * TX completion rings.  This function loops through
+ * the TX completion rings and assigns the vector that
+ * will service it.  An example would be if there are
+ * 2 vectors (so 2 RSS rings) and 8 TX completion rings.
+ * This would mean that vector 0 would service RSS ring 0
+ * and TX competion rings 0,1,2 and 3.  Vector 1 would
+ * service RSS ring 1 and TX completion rings 4,5,6 and 7.
+ */
+static void ql_set_tx_vect(struct ql_adapter *qdev)
+{
+	int i, j, vect;
+	u32 tx_rings_per_vector = qdev->tx_ring_count / qdev->intr_count;
+
+	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags))) {
+		/* Assign irq vectors to TX rx_rings.*/
+		for (vect = 0, j = 0, i = qdev->rss_ring_count;
+					 i < qdev->rx_ring_count; i++) {
+			if (j == tx_rings_per_vector) {
+				vect++;
+				j = 0;
+			}
+			qdev->rx_ring[i].irq = vect;
+			j++;
+		}
+	} else {
+		/* For single vector all rings have an irq
+		 * of zero.
+		 */
+		for (i = 0; i < qdev->rx_ring_count; i++)
+			qdev->rx_ring[i].irq = 0;
+	}
+}
+
+/* Set the interrupt mask for this vector.  Each vector
+ * will service 1 RSS ring and 1 or more TX completion
+ * rings.  This function sets up a bit mask per vector
+ * that indicates which rings it services.
+ */
+static void ql_set_irq_mask(struct ql_adapter *qdev, struct intr_context *ctx)
+{
+	int j, vect = ctx->intr;
+	u32 tx_rings_per_vector = qdev->tx_ring_count / qdev->intr_count;
+
+	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags))) {
+		/* Add the RSS ring serviced by this vector
+		 * to the mask.
+		 */
+		ctx->irq_mask = (1 << qdev->rx_ring[vect].cq_id);
+		/* Add the TX ring(s) serviced by this vector
+		 * to the mask. */
+		for (j = 0; j < tx_rings_per_vector; j++) {
+			ctx->irq_mask |=
+			(1 << qdev->rx_ring[qdev->rss_ring_count +
+			(vect * tx_rings_per_vector) + j].cq_id);
+		}
+	} else {
+		/* For single vector we just shift each queue's
+		 * ID into the mask.
+		 */
+		for (j = 0; j < qdev->rx_ring_count; j++)
+			ctx->irq_mask |= (1 << qdev->rx_ring[j].cq_id);
+	}
+}
+
 /*
  * Here we build the intr_context structures based on
  * our rx_ring count and intr vector count.
@@ -2893,12 +2906,15 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 		/* Each rx_ring has it's
 		 * own intr_context since we have separate
 		 * vectors for each queue.
-		 * This only true when MSI-X is enabled.
 		 */
 		for (i = 0; i < qdev->intr_count; i++, intr_context++) {
 			qdev->rx_ring[i].irq = i;
 			intr_context->intr = i;
 			intr_context->qdev = qdev;
+			/* Set up this vector's bit-mask that indicates
+			 * which queues it services.
+			 */
+			ql_set_irq_mask(qdev, intr_context);
 			/*
 			 * We set up each vectors enable/disable/read bits so
 			 * there's no bit/mask calculations in the critical path.
@@ -2915,20 +2931,21 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 			    INTR_EN_TYPE_MASK | INTR_EN_INTR_MASK |
 			    INTR_EN_TYPE_READ | INTR_EN_IHD_MASK | INTR_EN_IHD |
 			    i;
-
-			if (i < qdev->rss_ring_count) {
-				/*
-				 * Inbound queues handle unicast frames only.
+			if (i == 0) {
+				/* The first vector/queue handles
+				 * broadcast/multicast, fatal errors,
+				 * and firmware events.  This in addition
+				 * to normal inbound NAPI processing.
 				 */
-				intr_context->handler = qlge_msix_rx_isr;
+				intr_context->handler = qlge_isr;
 				sprintf(intr_context->name, "%s-rx-%d",
 					qdev->ndev->name, i);
 			} else {
 				/*
-				 * Outbound queue is for outbound completions only.
+				 * Inbound queues handle unicast frames only.
 				 */
-				intr_context->handler = qlge_msix_tx_isr;
-				sprintf(intr_context->name, "%s-tx-%d",
+				intr_context->handler = qlge_msix_rx_isr;
+				sprintf(intr_context->name, "%s-rx-%d",
 					qdev->ndev->name, i);
 			}
 		}
@@ -2955,9 +2972,17 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 		 */
 		intr_context->handler = qlge_isr;
 		sprintf(intr_context->name, "%s-single_irq", qdev->ndev->name);
-		for (i = 0; i < qdev->rx_ring_count; i++)
-			qdev->rx_ring[i].irq = 0;
+		/* Set up this vector's bit-mask that indicates
+		 * which queues it services. In this case there is
+		 * a single vector so it will service all RSS and
+		 * TX completion rings.
+		 */
+		ql_set_irq_mask(qdev, intr_context);
 	}
+	/* Tell the TX completion rings which MSIx vector
+	 * they will be using.
+	 */
+	ql_set_tx_vect(qdev);
 }
 
 static void ql_free_irq(struct ql_adapter *qdev)
@@ -3326,7 +3351,6 @@ static void ql_display_dev_info(struct net_device *ndev)
 static int ql_adapter_down(struct ql_adapter *qdev)
 {
 	int i, status = 0;
-	struct rx_ring *rx_ring;
 
 	ql_link_off(qdev);
 
@@ -3340,27 +3364,8 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	cancel_delayed_work_sync(&qdev->mpi_idc_work);
 	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
 
-	/* The default queue at index 0 is always processed in
-	 * a workqueue.
-	 */
-	cancel_delayed_work_sync(&qdev->rx_ring[0].rx_work);
-
-	/* The rest of the rx_rings are processed in
-	 * a workqueue only if it's a single interrupt
-	 * environment (MSI/Legacy).
-	 */
-	for (i = 1; i < qdev->rx_ring_count; i++) {
-		rx_ring = &qdev->rx_ring[i];
-		/* Only the RSS rings use NAPI on multi irq
-		 * environment.  Outbound completion processing
-		 * is done in interrupt context.
-		 */
-		if (i <= qdev->rss_ring_count) {
-			napi_disable(&rx_ring->napi);
-		} else {
-			cancel_delayed_work_sync(&rx_ring->rx_work);
-		}
-	}
+	for (i = 0; i < qdev->rss_ring_count; i++)
+		napi_disable(&qdev->rx_ring[i].napi);
 
 	clear_bit(QL_ADAPTER_UP, &qdev->flags);
 
@@ -3476,9 +3481,9 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 
 		/*
 		 * The completion queue ID for the tx rings start
-		 * immediately after the default Q ID, which is zero.
+		 * immediately after the rss rings.
 		 */
-		tx_ring->cq_id = i + qdev->rss_ring_count;
+		tx_ring->cq_id = qdev->rss_ring_count + i;
 	}
 
 	for (i = 0; i < qdev->rx_ring_count; i++) {
@@ -3488,7 +3493,9 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 		rx_ring->cq_id = i;
 		rx_ring->cpu = i % cpu_cnt;	/* CPU to run handler on. */
 		if (i < qdev->rss_ring_count) {
-			/* Inbound completions (RSS) queues */
+			/*
+			 * Inbound (RSS) queues.
+			 */
 			rx_ring->cq_len = qdev->rx_ring_size;
 			rx_ring->cq_size =
 			    rx_ring->cq_len * sizeof(struct ql_net_rsp_iocb);
@@ -3804,10 +3811,7 @@ static void ql_release_all(struct pci_dev *pdev)
 		destroy_workqueue(qdev->workqueue);
 		qdev->workqueue = NULL;
 	}
-	if (qdev->q_workqueue) {
-		destroy_workqueue(qdev->q_workqueue);
-		qdev->q_workqueue = NULL;
-	}
+
 	if (qdev->reg_base)
 		iounmap(qdev->reg_base);
 	if (qdev->doorbell_area)
@@ -3920,8 +3924,6 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	 * Set up the operating parameters.
 	 */
 	qdev->rx_csum = 1;
-
-	qdev->q_workqueue = create_workqueue(ndev->name);
 	qdev->workqueue = create_singlethread_workqueue(ndev->name);
 	INIT_DELAYED_WORK(&qdev->asic_reset_work, ql_asic_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_reset_work, ql_mpi_reset_work);
-- 
1.6.0.2

