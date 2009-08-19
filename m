From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/3] qlge: Change RSS ring to MSIx vector mapping.
Date: Wed, 19 Aug 2009 16:53:10 -0700
Message-ID: <1250725991-7155-3-git-send-email-ron.mercer@qlogic.com>
References: <1250725991-7155-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:23652 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753479AbZHSX6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 19:58:50 -0400
In-Reply-To: <1250725991-7155-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we set aside one vector for a 'default' ring that handles
broadcast/multicast, and events from the chip and firmware.
The remainder of the vectors are split among the RSS rings and TX
completion rings.

Now that TX completions are handled in the send path, this change uses
all vectors for RSS rings on a one to one basis.

The broadcast/multicast and events are rolled into the functionality of
the 1st RSS ring and are processed before NAPI is called for RSS.
The remaining rings call NAPI directly.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h         |   12 +-
 drivers/net/qlge/qlge_dbg.c     |    8 +-
 drivers/net/qlge/qlge_ethtool.c |   20 ++--
 drivers/net/qlge/qlge_main.c    |  299 ++++++++++++++++-----------------------
 4 files changed, 135 insertions(+), 204 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 94dfba4..9e30fb0 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -34,7 +34,7 @@
 #define QLGE_DEVICE_ID_8000	0x8000
 #define MAX_CPUS 8
 #define MAX_TX_RINGS MAX_CPUS
-#define MAX_RX_RINGS ((MAX_CPUS * 2) + 1)
+#define MAX_RX_RINGS (MAX_CPUS * 2)
 
 #define NUM_TX_RING_ENTRIES	256
 #define NUM_RX_RING_ENTRIES	256
@@ -1236,7 +1236,6 @@ struct tx_ring {
  * Type of inbound queue.
  */
 enum {
-	DEFAULT_Q = 2,		/* Handles slow queue and chip/MPI events. */
 	TX_Q = 3,		/* Handles outbound completions. */
 	RX_Q = 4,		/* Handles inbound completions. */
 };
@@ -1288,7 +1287,7 @@ struct rx_ring {
 	u32 sbq_free_cnt;	/* free buffer desc cnt */
 
 	/* Misc. handler elements. */
-	u32 type;		/* Type of queue, tx, rx, or default. */
+	u32 type;		/* Type of queue, tx, rx. */
 	u32 irq;		/* Which vector this ring is assigned. */
 	u32 cpu;		/* Which CPU this should run on. */
 	char name[IFNAMSIZ + 5];
@@ -1487,13 +1486,11 @@ struct ql_adapter {
 	struct intr_context intr_context[MAX_RX_RINGS];
 
 	int tx_ring_count;	/* One per online CPU. */
-	u32 rss_ring_first_cq_id;/* index of first inbound (rss) rx_ring */
-	u32 rss_ring_count;	/* One per online CPU.  */
+	u32 rss_ring_count;	/* One per irq vector.  */
 	/*
 	 * rx_ring_count =
-	 *  one default queue +
 	 *  (CPU count * outbound completion rx_ring) +
-	 *  (CPU count * inbound (RSS) completion rx_ring)
+	 *  (irq_vector_cnt * inbound (RSS) completion rx_ring)
 	 */
 	int rx_ring_count;
 	int ring_mem_size;
@@ -1503,7 +1500,6 @@ struct ql_adapter {
 	struct tx_ring tx_ring[MAX_TX_RINGS];
 
 	int rx_csum;
-	u32 default_rx_queue;
 
 	u16 rx_coalesce_usecs;	/* cqicb->int_delay */
 	u16 rx_max_coalesced_frames;	/* cqicb->pkt_int_delay */
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 40a70c3..c6d4db5 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -418,13 +418,9 @@ void ql_dump_qdev(struct ql_adapter *qdev)
 	printk(KERN_ERR PFX "qdev->intr_count 	= %d.\n", qdev->intr_count);
 	printk(KERN_ERR PFX "qdev->tx_ring		= %p.\n",
 	       qdev->tx_ring);
-	printk(KERN_ERR PFX "qdev->rss_ring_first_cq_id 	= %d.\n",
-	       qdev->rss_ring_first_cq_id);
 	printk(KERN_ERR PFX "qdev->rss_ring_count 	= %d.\n",
 	       qdev->rss_ring_count);
 	printk(KERN_ERR PFX "qdev->rx_ring	= %p.\n", qdev->rx_ring);
-	printk(KERN_ERR PFX "qdev->default_rx_queue	= %d.\n",
-	       qdev->default_rx_queue);
 	printk(KERN_ERR PFX "qdev->xg_sem_mask		= 0x%08x.\n",
 	       qdev->xg_sem_mask);
 	printk(KERN_ERR PFX "qdev->port_link_up		= 0x%08x.\n",
@@ -545,8 +541,8 @@ void ql_dump_rx_ring(struct rx_ring *rx_ring)
 	printk(KERN_ERR PFX
 	       "===================== Dumping rx_ring %d ===============.\n",
 	       rx_ring->cq_id);
-	printk(KERN_ERR PFX "Dumping rx_ring %d, type = %s%s%s.\n",
-	       rx_ring->cq_id, rx_ring->type == DEFAULT_Q ? "DEFAULT" : "",
+	printk(KERN_ERR PFX "Dumping rx_ring %d, type = %s%s.\n",
+		rx_ring->cq_id,
 	       rx_ring->type == TX_Q ? "OUTBOUND COMPLETIONS" : "",
 	       rx_ring->type == RX_Q ? "INBOUND_COMPLETIONS" : "");
 	printk(KERN_ERR PFX "rx_ring->cqicb = %p.\n", &rx_ring->cqicb);
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index eb6a9ee..8938111 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -49,15 +49,16 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 	/* Skip the default queue, and update the outbound handler
 	 * queues if they changed.
 	 */
-	cqicb = (struct cqicb *)&qdev->rx_ring[1];
+	cqicb = (struct cqicb *)&qdev->rx_ring[qdev->rss_ring_count];
 	if (le16_to_cpu(cqicb->irq_delay) != qdev->tx_coalesce_usecs ||
-	    le16_to_cpu(cqicb->pkt_delay) != qdev->tx_max_coalesced_frames) {
-		for (i = 1; i < qdev->rss_ring_first_cq_id; i++, rx_ring++) {
+		le16_to_cpu(cqicb->pkt_delay) !=
+				qdev->tx_max_coalesced_frames) {
+		for (i = qdev->rss_ring_count; i < qdev->rx_ring_count; i++) {
 			rx_ring = &qdev->rx_ring[i];
 			cqicb = (struct cqicb *)rx_ring;
 			cqicb->irq_delay = cpu_to_le16(qdev->tx_coalesce_usecs);
 			cqicb->pkt_delay =
-			    cpu_to_le16(qdev->tx_max_coalesced_frames);
+				cpu_to_le16(qdev->tx_max_coalesced_frames);
 			cqicb->flags = FLAGS_LI;
 			status = ql_write_cfg(qdev, cqicb, sizeof(*cqicb),
 						CFG_LCQ, rx_ring->cq_id);
@@ -70,17 +71,16 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 	}
 
 	/* Update the inbound (RSS) handler queues if they changed. */
-	cqicb = (struct cqicb *)&qdev->rx_ring[qdev->rss_ring_first_cq_id];
+	cqicb = (struct cqicb *)&qdev->rx_ring[0];
 	if (le16_to_cpu(cqicb->irq_delay) != qdev->rx_coalesce_usecs ||
-	    le16_to_cpu(cqicb->pkt_delay) != qdev->rx_max_coalesced_frames) {
-		for (i = qdev->rss_ring_first_cq_id;
-		     i <= qdev->rss_ring_first_cq_id + qdev->rss_ring_count;
-		     i++) {
+		le16_to_cpu(cqicb->pkt_delay) !=
+					qdev->rx_max_coalesced_frames) {
+		for (i = 0; i < qdev->rss_ring_count; i++, rx_ring++) {
 			rx_ring = &qdev->rx_ring[i];
 			cqicb = (struct cqicb *)rx_ring;
 			cqicb->irq_delay = cpu_to_le16(qdev->rx_coalesce_usecs);
 			cqicb->pkt_delay =
-			    cpu_to_le16(qdev->rx_max_coalesced_frames);
+				cpu_to_le16(qdev->rx_max_coalesced_frames);
 			cqicb->flags = FLAGS_LI;
 			status = ql_write_cfg(qdev, cqicb, sizeof(*cqicb),
 						CFG_LCQ, rx_ring->cq_id);
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c964066..56b5d0e 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -370,9 +370,7 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 				cam_output = (CAM_OUT_ROUTE_NIC |
 					      (qdev->
 					       func << CAM_OUT_FUNC_SHIFT) |
-					      (qdev->
-					       rss_ring_first_cq_id <<
-					       CAM_OUT_CQ_ID_SHIFT));
+					       (0 << CAM_OUT_CQ_ID_SHIFT));
 				if (qdev->vlgrp)
 					cam_output |= CAM_OUT_RV;
 				/* route to NIC core */
@@ -616,9 +614,8 @@ u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 	unsigned long hw_flags = 0;
 	struct intr_context *ctx = qdev->intr_context + intr;
 
-	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr)) {
-		/* Always enable if we're MSIX multi interrupts and
-		 * it's not the default (zeroeth) interrupt.
+	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags))) {
+		/* Always enable if we're MSIX multi interrupts.
 		 */
 		ql_write32(qdev, INTR_EN,
 			   ctx->intr_en_mask);
@@ -644,7 +641,7 @@ static u32 ql_disable_completion_interrupt(struct ql_adapter *qdev, u32 intr)
 	/* HW disables for us if we're MSIX multi interrupts and
 	 * it's not the default (zeroeth) interrupt.
 	 */
-	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags) && intr))
+	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags)))
 		return 0;
 
 	ctx = qdev->intr_context + intr;
@@ -1649,8 +1646,7 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 
 	qdev->stats.rx_packets++;
 	qdev->stats.rx_bytes += skb->len;
-	skb_record_rx_queue(skb,
-		rx_ring->cq_id - qdev->rss_ring_first_cq_id);
+	skb_record_rx_queue(skb, rx_ring->cq_id);
 	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		if (qdev->vlgrp &&
 			(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) &&
@@ -1982,6 +1978,50 @@ static irqreturn_t qlge_msix_tx_isr(int irq, void *dev_id)
 }
 
 /* MSI-X Multiple Vector Interrupt Handler for inbound completions. */
+static irqreturn_t qlge_msix_dflt_rx_isr(int irq, void *dev_id)
+{
+	struct rx_ring *rx_ring = dev_id;
+	struct ql_adapter *qdev = rx_ring->qdev;
+	u32 var;
+
+	var = ql_read32(qdev, STS);
+	/*
+	 * Check for fatal error.
+	 */
+	if (var & STS_FE) {
+		ql_queue_asic_error(qdev);
+		QPRINTK(qdev, INTR, ERR, "Got fatal error, STS = %x.\n", var);
+		var = ql_read32(qdev, ERR_STS);
+		QPRINTK(qdev, INTR, ERR,
+			"Resetting chip. Error Status Register = 0x%x\n", var);
+		return IRQ_HANDLED;
+	}
+
+	/*
+	 * Check MPI processor activity.
+	 */
+	if ((var & STS_PI) &&
+		(ql_read32(qdev, INTR_MASK) & INTR_MASK_PI)) {
+		/*
+		 * We've got an async event or mailbox completion.
+		 * Handle it and clear the source of the interrupt.
+		 */
+		QPRINTK(qdev, INTR, ERR, "Got MPI processor interrupt.\n");
+		queue_delayed_work(qdev->workqueue,
+				      &qdev->mpi_work, 0);
+		return IRQ_HANDLED;
+	}
+
+	/*
+	 * Start NAPI if there's work to do.
+	 */
+	if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) !=
+			    rx_ring->cnsmr_idx)
+		napi_schedule(&rx_ring->napi);
+	return IRQ_HANDLED;
+}
+
+/* MSI-X Multiple Vector Interrupt Handler for inbound completions. */
 static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
 {
 	struct rx_ring *rx_ring = dev_id;
@@ -2040,23 +2080,11 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 		work_done++;
 	}
 
-	/*
-	 * Check the default queue and wake handler if active.
-	 */
-	rx_ring = &qdev->rx_ring[0];
-	if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) != rx_ring->cnsmr_idx) {
-		QPRINTK(qdev, INTR, INFO, "Waking handler for rx_ring[0].\n");
-		ql_disable_completion_interrupt(qdev, intr_context->intr);
-		queue_delayed_work_on(smp_processor_id(), qdev->q_workqueue,
-				      &rx_ring->rx_work, 0);
-		work_done++;
-	}
-
 	if (!test_bit(QL_MSIX_ENABLED, &qdev->flags)) {
 		/*
 		 * Start the DPC for each active queue.
 		 */
-		for (i = 1; i < qdev->rx_ring_count; i++) {
+		for (i = 0; i < qdev->rx_ring_count; i++) {
 			rx_ring = &qdev->rx_ring[i];
 			if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) !=
 			    rx_ring->cnsmr_idx) {
@@ -2067,13 +2095,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 				ql_disable_completion_interrupt(qdev,
 								intr_context->
 								intr);
-				if (i < qdev->rss_ring_first_cq_id)
-					queue_delayed_work_on(rx_ring->cpu,
-							      qdev->q_workqueue,
-							      &rx_ring->rx_work,
-							      0);
-				else
-					napi_schedule(&rx_ring->napi);
+				napi_schedule(&rx_ring->napi);
 				work_done++;
 			}
 		}
@@ -2656,6 +2678,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	/* Set up the shadow registers for this ring. */
 	rx_ring->prod_idx_sh_reg = shadow_reg;
 	rx_ring->prod_idx_sh_reg_dma = shadow_reg_dma;
+	*rx_ring->prod_idx_sh_reg = 0;
 	shadow_reg += sizeof(u64);
 	shadow_reg_dma += sizeof(u64);
 	rx_ring->lbq_base_indirect = shadow_reg;
@@ -2744,34 +2767,9 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
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
-		break;
-	case DEFAULT_Q:
-		INIT_DELAYED_WORK(&rx_ring->rx_work, ql_rx_clean);
-		cqicb->irq_delay = 0;
-		cqicb->pkt_delay = 0;
+		cqicb->msix_vect = 0;
 		break;
 	case RX_Q:
 		/* Inbound completion handling rx_rings run in
@@ -2859,17 +2857,20 @@ static void ql_disable_msix(struct ql_adapter *qdev)
 	}
 }
 
+/* We start by trying to get the number of vectors
+ * stored in qdev->intr_count. If we don't get that
+ * many then we decrement by 1 and try again.
+ */
 static void ql_enable_msix(struct ql_adapter *qdev)
 {
-	int i;
+	int i, err;
 
-	qdev->intr_count = 1;
 	/* Get the MSIX vectors. */
 	if (irq_type == MSIX_IRQ) {
 		/* Try to alloc space for the msix struct,
 		 * if it fails then go to MSI/legacy.
 		 */
-		qdev->msi_x_entry = kcalloc(qdev->rx_ring_count,
+		qdev->msi_x_entry = kcalloc(qdev->intr_count,
 					    sizeof(struct msix_entry),
 					    GFP_KERNEL);
 		if (!qdev->msi_x_entry) {
@@ -2877,26 +2878,39 @@ static void ql_enable_msix(struct ql_adapter *qdev)
 			goto msi;
 		}
 
-		for (i = 0; i < qdev->rx_ring_count; i++)
+		for (i = 0; i < qdev->intr_count; i++) {
 			qdev->msi_x_entry[i].entry = i;
+			qdev->msi_x_entry[i].vector = 0;
+		}
 
-		if (!pci_enable_msix
-		    (qdev->pdev, qdev->msi_x_entry, qdev->rx_ring_count)) {
-			set_bit(QL_MSIX_ENABLED, &qdev->flags);
-			qdev->intr_count = qdev->rx_ring_count;
-			QPRINTK(qdev, IFUP, DEBUG,
-				"MSI-X Enabled, got %d vectors.\n",
-				qdev->intr_count);
-			return;
-		} else {
+		/* Loop to get our vectors.  We start with
+		 * what we want and settle for what we get.
+		 */
+		do {
+			err = pci_enable_msix(qdev->pdev,
+				qdev->msi_x_entry, qdev->intr_count);
+			if (err > 0)
+				qdev->intr_count = err;
+		} while (err > 0);
+
+		if (err < 0) {
+			pci_disable_msix(qdev->pdev);
 			kfree(qdev->msi_x_entry);
 			qdev->msi_x_entry = NULL;
 			QPRINTK(qdev, IFUP, WARNING,
 				"MSI-X Enable failed, trying MSI.\n");
+			qdev->intr_count = 1;
 			irq_type = MSI_IRQ;
+		} else if (err == 0) {
+			set_bit(QL_MSIX_ENABLED, &qdev->flags);
+			QPRINTK(qdev, IFUP, INFO,
+				"MSI-X Enabled, got %d vectors.\n",
+				qdev->intr_count);
+			return;
 		}
 	}
 msi:
+	qdev->intr_count = 1;
 	if (irq_type == MSI_IRQ) {
 		if (!pci_enable_msi(qdev->pdev)) {
 			set_bit(QL_MSI_ENABLED, &qdev->flags);
@@ -2920,13 +2934,10 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 	int i = 0;
 	struct intr_context *intr_context = &qdev->intr_context[0];
 
-	ql_enable_msix(qdev);
-
 	if (likely(test_bit(QL_MSIX_ENABLED, &qdev->flags))) {
 		/* Each rx_ring has it's
 		 * own intr_context since we have separate
 		 * vectors for each queue.
-		 * This only true when MSI-X is enabled.
 		 */
 		for (i = 0; i < qdev->intr_count; i++, intr_context++) {
 			qdev->rx_ring[i].irq = i;
@@ -2948,21 +2959,14 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 			    INTR_EN_TYPE_MASK | INTR_EN_INTR_MASK |
 			    INTR_EN_TYPE_READ | INTR_EN_IHD_MASK | INTR_EN_IHD |
 			    i;
-
 			if (i == 0) {
-				/*
-				 * Default queue handles bcast/mcast plus
-				 * async events.  Needs buffers.
-				 */
-				intr_context->handler = qlge_isr;
-				sprintf(intr_context->name, "%s-default-queue",
-					qdev->ndev->name);
-			} else if (i < qdev->rss_ring_first_cq_id) {
-				/*
-				 * Outbound queue is for outbound completions only.
+				/* The first vector/queue handles
+				 * broadcast/multicast, fatal errors,
+				 * and firmware events.  This in addition
+				 * to normal inbound NAPI processing.
 				 */
-				intr_context->handler = qlge_msix_tx_isr;
-				sprintf(intr_context->name, "%s-tx-%d",
+				intr_context->handler = qlge_msix_dflt_rx_isr;
+				sprintf(intr_context->name, "%s-rx-%d",
 					qdev->ndev->name, i);
 			} else {
 				/*
@@ -2996,7 +3000,7 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 		 */
 		intr_context->handler = qlge_isr;
 		sprintf(intr_context->name, "%s-single_irq", qdev->ndev->name);
-		for (i = 0; i < qdev->rx_ring_count; i++)
+		for (i = 0; i < qdev->rss_ring_count; i++)
 			qdev->rx_ring[i].irq = 0;
 	}
 }
@@ -3047,11 +3051,10 @@ static int ql_request_irq(struct ql_adapter *qdev)
 				goto err_irq;
 			} else {
 				QPRINTK(qdev, IFUP, DEBUG,
-					"Hooked intr %d, queue type %s%s%s, with name %s.\n",
+				"Hooked intr %d, queue type %s%s, "
+				"with name %s.\n",
 					i,
 					qdev->rx_ring[i].type ==
-					DEFAULT_Q ? "DEFAULT_Q" : "",
-					qdev->rx_ring[i].type ==
 					TX_Q ? "TX_Q" : "",
 					qdev->rx_ring[i].type ==
 					RX_Q ? "RX_Q" : "", intr_context->name);
@@ -3077,10 +3080,8 @@ static int ql_request_irq(struct ql_adapter *qdev)
 				goto err_irq;
 
 			QPRINTK(qdev, IFUP, ERR,
-				"Hooked intr %d, queue type %s%s%s, with name %s.\n",
+			"Hooked intr %d, queue type %s%s, with name %s.\n",
 				i,
-				qdev->rx_ring[0].type ==
-				DEFAULT_Q ? "DEFAULT_Q" : "",
 				qdev->rx_ring[0].type == TX_Q ? "TX_Q" : "",
 				qdev->rx_ring[0].type == RX_Q ? "RX_Q" : "",
 				intr_context->name);
@@ -3103,7 +3104,7 @@ static int ql_start_rss(struct ql_adapter *qdev)
 
 	memset((void *)ricb, 0, sizeof(*ricb));
 
-	ricb->base_cq = qdev->rss_ring_first_cq_id | RSS_L4K;
+	ricb->base_cq = RSS_L4K;
 	ricb->flags =
 	    (RSS_L6K | RSS_LI | RSS_LB | RSS_LM | RSS_RI4 | RSS_RI6 | RSS_RT4 |
 	     RSS_RT6);
@@ -3305,7 +3306,7 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	}
 
 	/* Start NAPI for the RSS queues. */
-	for (i = qdev->rss_ring_first_cq_id; i < qdev->rx_ring_count; i++) {
+	for (i = 0; i < qdev->rss_ring_count; i++) {
 		QPRINTK(qdev, IFUP, DEBUG, "Enabling NAPI for rx_ring[%d].\n",
 			i);
 		napi_enable(&qdev->rx_ring[i].napi);
@@ -3367,7 +3368,6 @@ static void ql_display_dev_info(struct net_device *ndev)
 static int ql_adapter_down(struct ql_adapter *qdev)
 {
 	int i, status = 0;
-	struct rx_ring *rx_ring;
 
 	ql_link_off(qdev);
 
@@ -3381,27 +3381,11 @@ static int ql_adapter_down(struct ql_adapter *qdev)
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
+	/* Only the RSS rings use NAPI.
+	 * Outbound completion processing is done in send context.
 	 */
-	for (i = 1; i < qdev->rx_ring_count; i++) {
-		rx_ring = &qdev->rx_ring[i];
-		/* Only the RSS rings use NAPI on multi irq
-		 * environment.  Outbound completion processing
-		 * is done in interrupt context.
-		 */
-		if (i >= qdev->rss_ring_first_cq_id) {
-			napi_disable(&rx_ring->napi);
-		} else {
-			cancel_delayed_work_sync(&rx_ring->rx_work);
-		}
-	}
+	for (i = 0; i < qdev->rss_ring_count; i++)
+		napi_disable(&qdev->rx_ring[i].napi);
 
 	/* Delete the timers used for cleaning up
 	 * TX completions.
@@ -3417,7 +3401,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 
 	/* Call netif_napi_del() from common point.
 	 */
-	for (i = qdev->rss_ring_first_cq_id; i < qdev->rx_ring_count; i++)
+	for (i = 0; i < qdev->rss_ring_count; i++)
 		netif_napi_del(&qdev->rx_ring[i].napi);
 
 	ql_free_rx_buffers(qdev);
@@ -3496,43 +3480,21 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	int i;
 	struct rx_ring *rx_ring;
 	struct tx_ring *tx_ring;
-	int cpu_cnt = num_online_cpus();
-
-	/*
-	 * For each processor present we allocate one
-	 * rx_ring for outbound completions, and one
-	 * rx_ring for inbound completions.  Plus there is
-	 * always the one default queue.  For the CPU
-	 * counts we end up with the following rx_rings:
-	 * rx_ring count =
-	 *  one default queue +
-	 *  (CPU count * outbound completion rx_ring) +
-	 *  (CPU count * inbound (RSS) completion rx_ring)
-	 * To keep it simple we limit the total number of
-	 * queues to < 32, so we truncate CPU to 8.
-	 * This limitation can be removed when requested.
+	int cpu_cnt = min(MAX_CPUS, (int)num_online_cpus());
+
+	/* In a perfect world we have one RSS ring for each CPU
+	 * and each has it's own vector.  To do that we ask for
+	 * cpu_cnt vectors.  ql_enable_msix() will adjust the
+	 * vector count to what we actually get.  We then
+	 * allocate an RSS ring for each.
+	 * Essentially, we are doing min(cpu_count, msix_vector_count).
 	 */
-
-	if (cpu_cnt > MAX_CPUS)
-		cpu_cnt = MAX_CPUS;
-
-	/*
-	 * rx_ring[0] is always the default queue.
-	 */
-	/* Allocate outbound completion ring for each CPU. */
+	qdev->intr_count = cpu_cnt;
+	ql_enable_msix(qdev);
+	/* Adjust the RSS ring count to the actual vector count. */
+	qdev->rss_ring_count = qdev->intr_count;
 	qdev->tx_ring_count = cpu_cnt;
-	/* Allocate inbound completion (RSS) ring for each CPU. */
-	qdev->rss_ring_count = cpu_cnt;
-	/* cq_id for the first inbound ring handler. */
-	qdev->rss_ring_first_cq_id = cpu_cnt + 1;
-	/*
-	 * qdev->rx_ring_count:
-	 * Total number of rx_rings.  This includes the one
-	 * default queue, a number of outbound completion
-	 * handler rx_rings, and the number of inbound
-	 * completion handler rx_rings.
-	 */
-	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count + 1;
+	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count;
 
 	for (i = 0; i < qdev->tx_ring_count; i++) {
 		tx_ring = &qdev->tx_ring[i];
@@ -3545,9 +3507,9 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 
 		/*
 		 * The completion queue ID for the tx rings start
-		 * immediately after the default Q ID, which is zero.
+		 * immediately after the rss rings.
 		 */
-		tx_ring->cq_id = i + 1;
+		tx_ring->cq_id = qdev->rss_ring_count + i;
 		init_timer(&tx_ring->txq_clean_timer);
 		tx_ring->txq_clean_timer.data = (unsigned long)tx_ring;
 		tx_ring->txq_clean_timer.function = ql_txq_clean_timer;
@@ -3558,11 +3520,9 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 		memset((void *)rx_ring, 0, sizeof(*rx_ring));
 		rx_ring->qdev = qdev;
 		rx_ring->cq_id = i;
-		rx_ring->cpu = i % cpu_cnt;	/* CPU to run handler on. */
-		if (i == 0) {	/* Default queue at index 0. */
+		if (i  < qdev->rss_ring_count) {
 			/*
-			 * Default queue handles bcast/mcast plus
-			 * async events.  Needs buffers.
+			 * Inbound (RSS) queues.
 			 */
 			rx_ring->cq_len = qdev->rx_ring_size;
 			rx_ring->cq_size =
@@ -3575,8 +3535,8 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			rx_ring->sbq_size =
 			    rx_ring->sbq_len * sizeof(__le64);
 			rx_ring->sbq_buf_size = SMALL_BUFFER_SIZE * 2;
-			rx_ring->type = DEFAULT_Q;
-		} else if (i < qdev->rss_ring_first_cq_id) {
+			rx_ring->type = RX_Q;
+		} else {
 			/*
 			 * Outbound queue handles outbound completions only.
 			 */
@@ -3591,22 +3551,6 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			rx_ring->sbq_size = 0;
 			rx_ring->sbq_buf_size = 0;
 			rx_ring->type = TX_Q;
-		} else {	/* Inbound completions (RSS) queues */
-			/*
-			 * Inbound queues handle unicast frames only.
-			 */
-			rx_ring->cq_len = qdev->rx_ring_size;
-			rx_ring->cq_size =
-			    rx_ring->cq_len * sizeof(struct ql_net_rsp_iocb);
-			rx_ring->lbq_len = NUM_LARGE_BUFFERS;
-			rx_ring->lbq_size =
-			    rx_ring->lbq_len * sizeof(__le64);
-			rx_ring->lbq_buf_size = LARGE_BUFFER_SIZE;
-			rx_ring->sbq_len = NUM_SMALL_BUFFERS;
-			rx_ring->sbq_size =
-			    rx_ring->sbq_len * sizeof(__le64);
-			rx_ring->sbq_buf_size = SMALL_BUFFER_SIZE * 2;
-			rx_ring->type = RX_Q;
 		}
 	}
 	return 0;
@@ -3895,10 +3839,7 @@ static void ql_release_all(struct pci_dev *pdev)
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
@@ -4011,8 +3952,6 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
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

