From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [RFC net-next PATCH 1/4] qlge: Remove workqueue usage from data path.
Date: Mon, 17 Aug 2009 14:08:46 -0700
Message-ID: <1250543329-15123-2-git-send-email-ron.mercer@qlogic.com>
References: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39434 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757649AbZHQVO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 17:14:27 -0400
In-Reply-To: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver was using workqueues for TX completions and for default
(broadcast/multicast) RX completions.  This change moves default
RX to NAPI context and TX to interrupt context.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    2 -
 drivers/net/qlge/qlge_main.c |  115 +++++++++---------------------------------
 2 files changed, 24 insertions(+), 93 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 6ed5317..e0b9330 100644
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
@@ -1519,7 +1518,6 @@ struct ql_adapter {
 	union flash_params flash;
 
 	struct net_device_stats stats;
-	struct workqueue_struct *q_workqueue;
 	struct workqueue_struct *workqueue;
 	struct delayed_work asic_reset_work;
 	struct delayed_work mpi_reset_work;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3a271af..c551ac3 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1682,7 +1682,7 @@ static void ql_process_mac_tx_intr(struct ql_adapter *qdev,
 	ql_unmap_send(qdev, tx_ring_desc, tx_ring_desc->map_cnt);
 	qdev->stats.tx_bytes += (tx_ring_desc->skb)->len;
 	qdev->stats.tx_packets++;
-	dev_kfree_skb(tx_ring_desc->skb);
+	dev_kfree_skb_any(tx_ring_desc->skb);
 	tx_ring_desc->skb = NULL;
 
 	if (unlikely(mac_rsp->flags1 & (OB_MAC_IOCB_RSP_E |
@@ -1928,35 +1928,11 @@ static void ql_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 
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
 /* MSI-X Multiple Vector Interrupt Handler for outbound completions. */
 static irqreturn_t qlge_msix_tx_isr(int irq, void *dev_id)
 {
 	struct rx_ring *rx_ring = dev_id;
-	queue_delayed_work_on(rx_ring->cpu, rx_ring->qdev->q_workqueue,
-			      &rx_ring->rx_work, 0);
+	ql_clean_outbound_rx_ring(rx_ring);
 	return IRQ_HANDLED;
 }
 
@@ -1978,7 +1954,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	struct rx_ring *rx_ring = dev_id;
 	struct ql_adapter *qdev = rx_ring->qdev;
 	struct intr_context *intr_context = &qdev->intr_context[0];
-	u32 var;
+	u32 var, mask;
 	int i;
 	int work_done = 0;
 
@@ -2020,41 +1996,26 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	}
 
 	/*
-	 * Check the default queue and wake handler if active.
+	 * Start NAPI for rx or handler for TX for each active queue.
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
+	mask = ql_read32(qdev, ISR1);
+	for (i = 0; i < qdev->rx_ring_count; i++) {
+		if (mask & (1 << i)) {
 			rx_ring = &qdev->rx_ring[i];
-			if (ql_read_sh_reg(rx_ring->prod_idx_sh_reg) !=
-			    rx_ring->cnsmr_idx) {
-				QPRINTK(qdev, INTR, INFO,
-					"Waking handler for rx_ring[%d].\n", i);
+			QPRINTK(qdev, INTR, INFO,
+				"Waking handler for rx_ring[%d].\n", i);
+			if (rx_ring->type == TX_Q)
+				ql_clean_outbound_rx_ring(rx_ring);
+			else {
 				ql_disable_completion_interrupt(qdev,
-								intr_context->
-								intr);
-				if (i < qdev->rss_ring_first_cq_id)
-					queue_delayed_work_on(rx_ring->cpu,
-							      qdev->q_workqueue,
-							      &rx_ring->rx_work,
-							      0);
-				else
-					napi_schedule(&rx_ring->napi);
-				work_done++;
+							intr_context->
+							intr);
+				napi_schedule(&rx_ring->napi);
 			}
+			work_done++;
 		}
 	}
+
 	ql_enable_completion_interrupt(qdev, intr_context->intr);
 	return work_done ? IRQ_HANDLED : IRQ_NONE;
 }
@@ -2706,32 +2667,15 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
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
 	case DEFAULT_Q:
-		INIT_DELAYED_WORK(&rx_ring->rx_work, ql_rx_clean);
+		/* Inbound completion handling rx_rings run in
+		 * separate NAPI contexts.
+		 */
+		netif_napi_add(qdev->ndev, &rx_ring->napi, ql_napi_poll_msix,
+			       64);
 		cqicb->irq_delay = 0;
 		cqicb->pkt_delay = 0;
 		break;
@@ -3340,16 +3284,11 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	cancel_delayed_work_sync(&qdev->mpi_idc_work);
 	cancel_delayed_work_sync(&qdev->mpi_port_cfg_work);
 
-	/* The default queue at index 0 is always processed in
-	 * a workqueue.
-	 */
-	cancel_delayed_work_sync(&qdev->rx_ring[0].rx_work);
-
 	/* The rest of the rx_rings are processed in
 	 * a workqueue only if it's a single interrupt
 	 * environment (MSI/Legacy).
 	 */
-	for (i = 1; i < qdev->rx_ring_count; i++) {
+	for (i = 0; i < qdev->rx_ring_count; i++) {
 		rx_ring = &qdev->rx_ring[i];
 		/* Only the RSS rings use NAPI on multi irq
 		 * environment.  Outbound completion processing
@@ -3357,8 +3296,6 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 		 */
 		if (i >= qdev->rss_ring_first_cq_id) {
 			napi_disable(&rx_ring->napi);
-		} else {
-			cancel_delayed_work_sync(&rx_ring->rx_work);
 		}
 	}
 
@@ -3845,10 +3782,7 @@ static void ql_release_all(struct pci_dev *pdev)
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
@@ -3962,7 +3896,6 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 	 */
 	qdev->rx_csum = 1;
 
-	qdev->q_workqueue = create_workqueue(ndev->name);
 	qdev->workqueue = create_singlethread_workqueue(ndev->name);
 	INIT_DELAYED_WORK(&qdev->asic_reset_work, ql_asic_reset_work);
 	INIT_DELAYED_WORK(&qdev->mpi_reset_work, ql_mpi_reset_work);
-- 
1.6.0.2

