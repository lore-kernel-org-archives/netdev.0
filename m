From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/3] qlge: Get rid of 'default' rx_ring type.
Date: Thu, 27 Aug 2009 14:02:09 -0700
Message-ID: <1251406931-15107-2-git-send-email-ron.mercer@qlogic.com>
References: <1251406931-15107-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40659 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbZH0VHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 17:07:52 -0400
In-Reply-To: <1251406931-15107-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we have three types of RX rings.

1) Default ring - services rx_ring for broadcast/multicast, handles
firmware events, and errors.

2) TX completion ring - handles only outbound completions.

3) RSS ring - handles only inbound completions.

This patch gets rid of the default ring type and moves it's functionality
into the first RSS ring.  This makes better use of MSIX vectors since
they are a limited resource on some platforms.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h         |    4 +--
 drivers/net/qlge/qlge_dbg.c     |    2 -
 drivers/net/qlge/qlge_ethtool.c |   16 ++++----
 drivers/net/qlge/qlge_main.c    |   70 ++++++++++----------------------------
 4 files changed, 28 insertions(+), 64 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 6ed5317..ed5dbca 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1287,7 +1287,7 @@ struct rx_ring {
 	u32 sbq_free_cnt;	/* free buffer desc cnt */
 
 	/* Misc. handler elements. */
-	u32 type;		/* Type of queue, tx, rx, or default. */
+	u32 type;		/* Type of queue, tx, rx. */
 	u32 irq;		/* Which vector this ring is assigned. */
 	u32 cpu;		/* Which CPU this should run on. */
 	char name[IFNAMSIZ + 5];
@@ -1486,11 +1486,9 @@ struct ql_adapter {
 	struct intr_context intr_context[MAX_RX_RINGS];
 
 	int tx_ring_count;	/* One per online CPU. */
-	u32 rss_ring_first_cq_id;/* index of first inbound (rss) rx_ring */
 	u32 rss_ring_count;	/* One per online CPU.  */
 	/*
 	 * rx_ring_count =
-	 *  one default queue +
 	 *  (CPU count * outbound completion rx_ring) +
 	 *  (CPU count * inbound (RSS) completion rx_ring)
 	 */
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/qlge/qlge_dbg.c
index 40a70c3..aa88cb3 100644
--- a/drivers/net/qlge/qlge_dbg.c
+++ b/drivers/net/qlge/qlge_dbg.c
@@ -418,8 +418,6 @@ void ql_dump_qdev(struct ql_adapter *qdev)
 	printk(KERN_ERR PFX "qdev->intr_count 	= %d.\n", qdev->intr_count);
 	printk(KERN_ERR PFX "qdev->tx_ring		= %p.\n",
 	       qdev->tx_ring);
-	printk(KERN_ERR PFX "qdev->rss_ring_first_cq_id 	= %d.\n",
-	       qdev->rss_ring_first_cq_id);
 	printk(KERN_ERR PFX "qdev->rss_ring_count 	= %d.\n",
 	       qdev->rss_ring_count);
 	printk(KERN_ERR PFX "qdev->rx_ring	= %p.\n", qdev->rx_ring);
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index eb6a9ee..68f9bd2 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -49,10 +49,11 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
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
@@ -70,12 +71,11 @@ static int ql_update_ring_coalescing(struct ql_adapter *qdev)
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
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3a271af..89ea9c7 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -370,9 +370,7 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 				cam_output = (CAM_OUT_ROUTE_NIC |
 					      (qdev->
 					       func << CAM_OUT_FUNC_SHIFT) |
-					      (qdev->
-					       rss_ring_first_cq_id <<
-					       CAM_OUT_CQ_ID_SHIFT));
+						(0 << CAM_OUT_CQ_ID_SHIFT));
 				if (qdev->vlgrp)
 					cam_output |= CAM_OUT_RV;
 				/* route to NIC core */
@@ -1649,8 +1647,7 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 
 	qdev->stats.rx_packets++;
 	qdev->stats.rx_bytes += skb->len;
-	skb_record_rx_queue(skb,
-		rx_ring->cq_id - qdev->rss_ring_first_cq_id);
+	skb_record_rx_queue(skb, rx_ring->cq_id);
 	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		if (qdev->vlgrp &&
 			(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) &&
@@ -2044,7 +2041,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 				ql_disable_completion_interrupt(qdev,
 								intr_context->
 								intr);
-				if (i < qdev->rss_ring_first_cq_id)
+				if (i >= qdev->rss_ring_count)
 					queue_delayed_work_on(rx_ring->cpu,
 							      qdev->q_workqueue,
 							      &rx_ring->rx_work,
@@ -2908,28 +2905,20 @@ static void ql_resolve_queues_to_irqs(struct ql_adapter *qdev)
 			    INTR_EN_TYPE_READ | INTR_EN_IHD_MASK | INTR_EN_IHD |
 			    i;
 
-			if (i == 0) {
+			if (i < qdev->rss_ring_count) {
 				/*
-				 * Default queue handles bcast/mcast plus
-				 * async events.  Needs buffers.
+				 * Inbound queues handle unicast frames only.
 				 */
-				intr_context->handler = qlge_isr;
-				sprintf(intr_context->name, "%s-default-queue",
-					qdev->ndev->name);
-			} else if (i < qdev->rss_ring_first_cq_id) {
+				intr_context->handler = qlge_msix_rx_isr;
+				sprintf(intr_context->name, "%s-rx-%d",
+					qdev->ndev->name, i);
+			} else {
 				/*
 				 * Outbound queue is for outbound completions only.
 				 */
 				intr_context->handler = qlge_msix_tx_isr;
 				sprintf(intr_context->name, "%s-tx-%d",
 					qdev->ndev->name, i);
-			} else {
-				/*
-				 * Inbound queues handle unicast frames only.
-				 */
-				intr_context->handler = qlge_msix_rx_isr;
-				sprintf(intr_context->name, "%s-rx-%d",
-					qdev->ndev->name, i);
 			}
 		}
 	} else {
@@ -3062,7 +3051,7 @@ static int ql_start_rss(struct ql_adapter *qdev)
 
 	memset((void *)ricb, 0, sizeof(*ricb));
 
-	ricb->base_cq = qdev->rss_ring_first_cq_id | RSS_L4K;
+	ricb->base_cq = RSS_L4K;
 	ricb->flags =
 	    (RSS_L6K | RSS_LI | RSS_LB | RSS_LM | RSS_RI4 | RSS_RI6 | RSS_RT4 |
 	     RSS_RT6);
@@ -3264,7 +3253,7 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	}
 
 	/* Start NAPI for the RSS queues. */
-	for (i = qdev->rss_ring_first_cq_id; i < qdev->rx_ring_count; i++) {
+	for (i = 0; i < qdev->rss_ring_count; i++) {
 		QPRINTK(qdev, IFUP, DEBUG, "Enabling NAPI for rx_ring[%d].\n",
 			i);
 		napi_enable(&qdev->rx_ring[i].napi);
@@ -3355,7 +3344,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 		 * environment.  Outbound completion processing
 		 * is done in interrupt context.
 		 */
-		if (i >= qdev->rss_ring_first_cq_id) {
+		if (i <= qdev->rss_ring_count) {
 			napi_disable(&rx_ring->napi);
 		} else {
 			cancel_delayed_work_sync(&rx_ring->rx_work);
@@ -3370,7 +3359,7 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 
 	/* Call netif_napi_del() from common point.
 	 */
-	for (i = qdev->rss_ring_first_cq_id; i < qdev->rx_ring_count; i++)
+	for (i = 0; i < qdev->rss_ring_count; i++)
 		netif_napi_del(&qdev->rx_ring[i].napi);
 
 	ql_free_rx_buffers(qdev);
@@ -3476,8 +3465,6 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	qdev->tx_ring_count = cpu_cnt;
 	/* Allocate inbound completion (RSS) ring for each CPU. */
 	qdev->rss_ring_count = cpu_cnt;
-	/* cq_id for the first inbound ring handler. */
-	qdev->rss_ring_first_cq_id = cpu_cnt + 1;
 	/*
 	 * qdev->rx_ring_count:
 	 * Total number of rx_rings.  This includes the one
@@ -3485,7 +3472,7 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	 * handler rx_rings, and the number of inbound
 	 * completion handler rx_rings.
 	 */
-	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count + 1;
+	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count;
 
 	for (i = 0; i < qdev->tx_ring_count; i++) {
 		tx_ring = &qdev->tx_ring[i];
@@ -3500,7 +3487,7 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 		 * The completion queue ID for the tx rings start
 		 * immediately after the default Q ID, which is zero.
 		 */
-		tx_ring->cq_id = i + 1;
+		tx_ring->cq_id = i + qdev->rss_ring_count;
 	}
 
 	for (i = 0; i < qdev->rx_ring_count; i++) {
@@ -3509,11 +3496,8 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 		rx_ring->qdev = qdev;
 		rx_ring->cq_id = i;
 		rx_ring->cpu = i % cpu_cnt;	/* CPU to run handler on. */
-		if (i == 0) {	/* Default queue at index 0. */
-			/*
-			 * Default queue handles bcast/mcast plus
-			 * async events.  Needs buffers.
-			 */
+		if (i < qdev->rss_ring_count) {
+			/* Inbound completions (RSS) queues */
 			rx_ring->cq_len = qdev->rx_ring_size;
 			rx_ring->cq_size =
 			    rx_ring->cq_len * sizeof(struct ql_net_rsp_iocb);
@@ -3525,8 +3509,8 @@ static int ql_configure_rings(struct ql_adapter *qdev)
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
@@ -3541,22 +3525,6 @@ static int ql_configure_rings(struct ql_adapter *qdev)
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

