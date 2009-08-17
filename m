From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [RFC net-next PATCH 3/4] qlge: Change rx_ring to MSIX vector mapping.
Date: Mon, 17 Aug 2009 14:08:48 -0700
Message-ID: <1250543329-15123-4-git-send-email-ron.mercer@qlogic.com>
References: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39434 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758010AbZHQVO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 17:14:28 -0400
In-Reply-To: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is one default ring, one outbound rx ring for each
CPU, and one RSS ring for each CPU.
This patch allocates one RSS ring for each MSIx vector,
and adds the default ring's functionality to the first
RSS ring.
Using up an MSIX vector on sideband work is expensive on platforms
that have limited resources.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h         |   10 +-
 drivers/net/qlge/qlge_dbg.c     |    8 +-
 drivers/net/qlge/qlge_ethtool.c |   40 +++---
 drivers/net/qlge/qlge_main.c    |  266 +++++++++++++++++----------------------
 4 files changed, 141 insertions(+), 183 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 975590c..5559c80 100644
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
@@ -1486,11 +1485,9 @@ struct ql_adapter {
 	struct intr_context intr_context[MAX_RX_RINGS];
 
 	int tx_ring_count;	/* One per online CPU. */
-	u32 rss_ring_first_cq_id;/* index of first inbound (rss) rx_ring */
-	u32 rss_ring_count;	/* One per online CPU.  */
+	u32 rss_ring_count;	/* One per irq vector.  */
 	/*
 	 * rx_ring_count =
-	 *  one default queue +
 	 *  (CPU count * outbound completion rx_ring) +
 	 *  (CPU count * inbound (RSS) completion rx_ring)
 	 */
@@ -1502,7 +1499,6 @@ struct ql_adapter {
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
index eb6a9ee..57faa54 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -46,20 +46,21 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 		return status;
 
 	spin_lock(&qdev->hw_lock);
-	/* Skip the default queue, and update the outbound handler
+	/* Update the inbound (RSS) handler
 	 * queues if they changed.
 	 */
-	cqicb = (struct cqicb *)&qdev->rx_ring[1];
-	if (le16_to_cpu(cqicb->irq_delay) != qdev->tx_coalesce_usecs ||
-	    le16_to_cpu(cqicb->pkt_delay) != qdev->tx_max_coalesced_frames) {
-		for (i = 1; i < qdev->rss_ring_first_cq_id; i++, rx_ring++) {
+	cqicb = (struct cqicb *)&qdev->rx_ring[0];
+	if (le16_to_cpu(cqicb->irq_delay) != qdev->rx_coalesce_usecs ||
+		le16_to_cpu(cqicb->pkt_delay) !=
+					qdev->rx_max_coalesced_frames) {
+		for (i = 0; i < qdev->rss_ring_count; i++, rx_ring++) {
 			rx_ring = &qdev->rx_ring[i];
-			cqicb = (struct cqicb *)rx_ring;
-			cqicb->irq_delay = cpu_to_le16(qdev->tx_coalesce_usecs);
+			cqicb = &rx_ring->cqicb;
+			cqicb->irq_delay = cpu_to_le16(qdev->rx_coalesce_usecs);
 			cqicb->pkt_delay =
-			    cpu_to_le16(qdev->tx_max_coalesced_frames);
+				cpu_to_le16(qdev->rx_max_coalesced_frames);
 			cqicb->flags = FLAGS_LI;
-			status = ql_write_cfg(qdev, cqicb, sizeof(*cqicb),
+			status = ql_write_cfg(qdev, cqicb, sizeof(cqicb),
 						CFG_LCQ, rx_ring->cq_id);
 			if (status) {
 				QPRINTK(qdev, IFUP, ERR,
@@ -69,20 +70,21 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 		}
 	}
 
-	/* Update the inbound (RSS) handler queues if they changed. */
-	cqicb = (struct cqicb *)&qdev->rx_ring[qdev->rss_ring_first_cq_id];
-	if (le16_to_cpu(cqicb->irq_delay) != qdev->rx_coalesce_usecs ||
-	    le16_to_cpu(cqicb->pkt_delay) != qdev->rx_max_coalesced_frames) {
-		for (i = qdev->rss_ring_first_cq_id;
-		     i <= qdev->rss_ring_first_cq_id + qdev->rss_ring_count;
+	/* Update the outbound handler queues if they changed. */
+	cqicb = (struct cqicb *)&qdev->rx_ring[qdev->rss_ring_count];
+	if (le16_to_cpu(cqicb->irq_delay) != qdev->tx_coalesce_usecs ||
+		le16_to_cpu(cqicb->pkt_delay) !=
+					 qdev->tx_max_coalesced_frames) {
+		for (i = qdev->rss_ring_count;
+			i < qdev->rx_ring_count;
 		     i++) {
 			rx_ring = &qdev->rx_ring[i];
-			cqicb = (struct cqicb *)rx_ring;
-			cqicb->irq_delay = cpu_to_le16(qdev->rx_coalesce_usecs);
+			cqicb = &rx_ring->cqicb;
+			cqicb->irq_delay = cpu_to_le16(qdev->tx_coalesce_usecs);
 			cqicb->pkt_delay =
-			    cpu_to_le16(qdev->rx_max_coalesced_frames);
+				cpu_to_le16(qdev->tx_max_coalesced_frames);
 			cqicb->flags = FLAGS_LI;
-			status = ql_write_cfg(qdev, cqicb, sizeof(*cqicb),
+			status = ql_write_cfg(qdev, cqicb, sizeof(cqicb),
 						CFG_LCQ, rx_ring->cq_id);
 			if (status) {
 				QPRINTK(qdev, IFUP, ERR,
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index d9b22da..dcac9f2 100644
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
@@ -1946,19 +1942,55 @@ static void ql_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 
 }
 
-/* MSI-X Multiple Vector Interrupt Handler for outbound completions. */
-static irqreturn_t qlge_msix_tx_isr(int irq, void *dev_id)
+/* MSI-X Multiple Vector Interrupt Handler for inbound completions. */
+static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
 {
 	struct rx_ring *rx_ring = dev_id;
-	ql_clean_outbound_rx_ring(rx_ring);
+       napi_schedule(&rx_ring->napi);
 	return IRQ_HANDLED;
 }
 
 /* MSI-X Multiple Vector Interrupt Handler for inbound completions. */
-static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
+static irqreturn_t qlge_msix_dflt_rx_isr(int irq, void *dev_id)
 {
 	struct rx_ring *rx_ring = dev_id;
-	napi_schedule(&rx_ring->napi);
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
 	return IRQ_HANDLED;
 }
 
@@ -1972,8 +2004,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	struct rx_ring *rx_ring = dev_id;
 	struct ql_adapter *qdev = rx_ring->qdev;
 	struct intr_context *intr_context = &qdev->intr_context[0];
-	u32 var, mask;
-	int i;
+	u32 var;
 	int work_done = 0;
 
 	spin_lock(&qdev->hw_lock);
@@ -2016,22 +2047,14 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	/*
 	 * Start NAPI for rx or handler for TX for each active queue.
 	 */
-	mask = ql_read32(qdev, ISR1);
-	for (i = 0; i < qdev->rx_ring_count; i++) {
-		if (mask & (1 << i)) {
-			rx_ring = &qdev->rx_ring[i];
-			QPRINTK(qdev, INTR, INFO,
-				"Waking handler for rx_ring[%d].\n", i);
-			if (rx_ring->type == TX_Q)
-				continue;
-			else {
-				ql_disable_completion_interrupt(qdev,
-							intr_context->
-							intr);
-				napi_schedule(&rx_ring->napi);
-			}
-			work_done++;
-		}
+	var = ql_read32(qdev, ISR1);
+	if (var) {
+		QPRINTK(qdev, INTR, INFO,
+		"Waking handler for rx_ring[0].\n");
+		ql_disable_completion_interrupt(qdev,
+						intr_context->intr);
+		napi_schedule(&rx_ring->napi);
+		work_done++;
 	}
 
 	ql_enable_completion_interrupt(qdev, intr_context->intr);
@@ -2612,6 +2635,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	/* Set up the shadow registers for this ring. */
 	rx_ring->prod_idx_sh_reg = shadow_reg;
 	rx_ring->prod_idx_sh_reg_dma = shadow_reg_dma;
+	*rx_ring->prod_idx_sh_reg = 0;
 	shadow_reg += sizeof(u64);
 	shadow_reg_dma += sizeof(u64);
 	rx_ring->lbq_base_indirect = shadow_reg;
@@ -2702,15 +2726,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	case TX_Q:
 		cqicb->irq_delay = cpu_to_le16(qdev->tx_coalesce_usecs);
 		cqicb->pkt_delay = cpu_to_le16(qdev->tx_max_coalesced_frames);
-		break;
-	case DEFAULT_Q:
-		/* Inbound completion handling rx_rings run in
-		 * separate NAPI contexts.
-		 */
-		netif_napi_add(qdev->ndev, &rx_ring->napi, ql_napi_poll_msix,
-			       64);
-		cqicb->irq_delay = 0;
-		cqicb->pkt_delay = 0;
+		cqicb->msix_vect = 0;
 		break;
 	case RX_Q:
 		/* Inbound completion handling rx_rings run in
@@ -2800,15 +2816,14 @@ static void ql_disable_msix(struct ql_adapter *qdev)
 
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
@@ -2816,26 +2831,39 @@ static void ql_enable_msix(struct ql_adapter *qdev)
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
@@ -2845,7 +2873,7 @@ msi:
 		}
 	}
 	irq_type = LEG_IRQ;
-	QPRINTK(qdev, IFUP, DEBUG, "Running with legacy interrupts.\n");
+	QPRINTK(qdev, IFUP, INFO, "Running with legacy interrupts.\n");
 }
 
 /*
@@ -2859,13 +2887,10 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
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
@@ -2887,25 +2912,18 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 			    INTR_EN_TYPE_MASK | INTR_EN_INTR_MASK |
 			    INTR_EN_TYPE_READ | INTR_EN_IHD_MASK | INTR_EN_IHD |
 			    i;
-
 			if (i == 0) {
-				/*
-				 * Default queue handles bcast/mcast plus
-				 * async events.  Needs buffers.
+				/* The first vector/queue handles
+				 * broadcast/multicast, fatal errors,
+				 * and firmware events.  This in addition
+				 * to normal inbound NAPI processing.
 				 */
-				intr_context->handler = qlge_isr;
-				sprintf(intr_context->name, "%s-default-queue",
-					qdev->ndev->name);
-			} else if (i < qdev->rss_ring_first_cq_id) {
-				/*
-				 * Outbound queue is for outbound completions only.
-				 */
-				intr_context->handler = qlge_msix_tx_isr;
-				sprintf(intr_context->name, "%s-tx-%d",
+				intr_context->handler = qlge_msix_dflt_rx_isr;
+				sprintf(intr_context->name, "%s-rx-%d",
 					qdev->ndev->name, i);
 			} else {
 				/*
-				 * Inbound queues handle unicast frames only.
+				 * Inbound queues handle unicast frames.
 				 */
 				intr_context->handler = qlge_msix_rx_isr;
 				sprintf(intr_context->name, "%s-rx-%d",
@@ -2935,7 +2953,7 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 		 */
 		intr_context->handler = qlge_isr;
 		sprintf(intr_context->name, "%s-single_irq", qdev->ndev->name);
-		for (i = 0; i < qdev->rx_ring_count; i++)
+		for (i = 0; i < qdev->rss_ring_count; i++)
 			qdev->rx_ring[i].irq = 0;
 	}
 }
@@ -2986,11 +3004,10 @@ static int ql_request_irq(struct ql_adapter *qdev)
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
@@ -3016,10 +3033,8 @@ static int ql_request_irq(struct ql_adapter *qdev)
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
@@ -3042,7 +3057,7 @@ static int ql_start_rss(struct ql_adapter *qdev)
 
 	memset((void *)ricb, 0, sizeof(*ricb));
 
-	ricb->base_cq = qdev->rss_ring_first_cq_id | RSS_L4K;
+	ricb->base_cq = RSS_L4K;
 	ricb->flags =
 	    (RSS_L6K | RSS_LI | RSS_LB | RSS_LM | RSS_RI4 | RSS_RI6 | RSS_RT4 |
 	     RSS_RT6);
@@ -3244,7 +3259,7 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	}
 
 	/* Start NAPI for the RSS queues. */
-	for (i = qdev->rss_ring_first_cq_id; i < qdev->rx_ring_count; i++) {
+	for (i = 0; i < qdev->rss_ring_count; i++) {
 		QPRINTK(qdev, IFUP, DEBUG, "Enabling NAPI for rx_ring[%d].\n",
 			i);
 		napi_enable(&qdev->rx_ring[i].napi);
@@ -3306,7 +3321,6 @@ static void ql_display_dev_info(struct net_device *ndev)
 static int ql_adapter_down(struct ql_adapter *qdev)
 {
 	int i, status = 0;
-	struct rx_ring *rx_ring;
 
 	ql_link_off(qdev);
 
@@ -3320,20 +3334,12 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	cancel_delayed_work_sync(&qdev->mpi_idc_work);
 	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
 
-	/* The rest of the rx_rings are processed in
-	 * a workqueue only if it's a single interrupt
-	 * environment (MSI/Legacy).
-	 */
-	for (i = 0; i < qdev->rx_ring_count; i++) {
-		rx_ring = &qdev->rx_ring[i];
 		/* Only the RSS rings use NAPI on multi irq
 		 * environment.  Outbound completion processing
 		 * is done in interrupt context.
 		 */
-		if (i >= qdev->rss_ring_first_cq_id) {
-			napi_disable(&rx_ring->napi);
-		}
-	}
+	for (i = 0; i < qdev->rss_ring_count; i++)
+		napi_disable(&qdev->rx_ring[i].napi);
 
 	/* Delete the timers used for cleaning up
 	 * TX completions.
@@ -3349,7 +3355,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 
 	/* Call netif_napi_del() from common point.
 	 */
-	for (i = qdev->rss_ring_first_cq_id; i < qdev->rx_ring_count; i++)
+	for (i = 0; i < qdev->rss_ring_count; i++)
 		netif_napi_del(&qdev->rx_ring[i].napi);
 
 	ql_free_rx_buffers(qdev);
@@ -3428,43 +3434,20 @@ static int ql_configure_rings(struct ql_adapter *qdev)
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
-	 */
-
-	if (cpu_cnt > MAX_CPUS)
-		cpu_cnt = MAX_CPUS;
+	int cpu_cnt = min(MAX_CPUS, (int)num_online_cpus());
 
-	/*
-	 * rx_ring[0] is always the default queue.
-	 */
 	/* Allocate outbound completion ring for each CPU. */
 	qdev->tx_ring_count = cpu_cnt;
-	/* Allocate inbound completion (RSS) ring for each CPU. */
 	qdev->rss_ring_count = cpu_cnt;
-	/* cq_id for the first inbound ring handler. */
-	qdev->rss_ring_first_cq_id = cpu_cnt + 1;
+	qdev->intr_count = qdev->rss_ring_count;
+	/* Try to get a vector for each RSS queue (per CPU). */
+	ql_enable_msix(qdev);
 	/*
-	 * qdev->rx_ring_count:
-	 * Total number of rx_rings.  This includes the one
-	 * default queue, a number of outbound completion
-	 * handler rx_rings, and the number of inbound
-	 * completion handler rx_rings.
+	 * We might not have gotten what we wanted.
+	 * Downshift to what we were actually given
 	 */
-	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count + 1;
+	qdev->rss_ring_count = qdev->intr_count;
+	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count;
 
 	for (i = 0; i < qdev->tx_ring_count; i++) {
 		tx_ring = &qdev->tx_ring[i];
@@ -3477,9 +3460,9 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 
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
@@ -3487,14 +3470,12 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 
 	for (i = 0; i < qdev->rx_ring_count; i++) {
 		rx_ring = &qdev->rx_ring[i];
-		memset((void *)rx_ring, 0, sizeof(*rx_ring));
+		memset(rx_ring, 0, sizeof(*rx_ring));
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
@@ -3507,12 +3488,11 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			rx_ring->sbq_size =
 			    rx_ring->sbq_len * sizeof(__le64);
 			rx_ring->sbq_buf_size = SMALL_BUFFER_SIZE * 2;
-			rx_ring->type = DEFAULT_Q;
-		} else if (i < qdev->rss_ring_first_cq_id) {
+			rx_ring->type = RX_Q;
+		} else {
 			/*
-			 * Outbound queue handles outbound completions only.
+			 * Outbound queues handling outbound completions only.
 			 */
-			/* outbound cq is same size as tx_ring it services. */
 			rx_ring->cq_len = qdev->tx_ring_size;
 			rx_ring->cq_size =
 			    rx_ring->cq_len * sizeof(struct ql_net_rsp_iocb);
@@ -3523,22 +3503,6 @@ static int ql_configure_rings(struct ql_adapter *qdev)
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
-- 
1.6.0.2

