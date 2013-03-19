From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 1/4][net-next] gianfar: Fix tx napi polling
Date: Tue, 19 Mar 2013 19:40:02 +0200
Message-ID: <1363714805-9142-2-git-send-email-claudiu.manoil@freescale.com>
References: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:28681 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932483Ab3CSRlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:41:18 -0400
In-Reply-To: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 2 issues with the current napi poll routine, with regards
to tx ring cleanup:
1) for multi-queue devices (MQ_MG_MODE), should tx_bit_map != rx_bit_map,
which is possible (and supported in h/w) if the DT property "fsl,tx-bit-map"
holds a different value than rx_bit_map, the current polling routine will
service the wrong Tx queues in this case (i.e. the interrupt group will
receive interrupts from tx queues that it will not service)
2) Tx cleanup completion consumes napi budget, whereas the napi budget
should be reserved for Rx work only.

The patch fixes these issues and provides a clean napi polling routine.
Napi poll completion is reached when all the Rx queues have been
serviced and there is no Tx work to do.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 82 ++++++++++++++++++--------------
 1 file changed, 45 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 1b468a8..1e555a7 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -132,7 +132,7 @@ static int gfar_poll(struct napi_struct *napi, int budget);
 static void gfar_netpoll(struct net_device *dev);
 #endif
 int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit);
-static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue);
+static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue);
 static void gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 			       int amount_pull, struct napi_struct *napi);
 void gfar_halt(struct net_device *dev);
@@ -2468,7 +2468,7 @@ static void gfar_align_skb(struct sk_buff *skb)
 }
 
 /* Interrupt Handler for Transmit complete */
-static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
+static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 {
 	struct net_device *dev = tx_queue->dev;
 	struct netdev_queue *txq;
@@ -2570,8 +2570,6 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	tx_queue->dirty_tx = bdp;
 
 	netdev_tx_completed_queue(txq, howmany, bytes_sent);
-
-	return howmany;
 }
 
 static void gfar_schedule_cleanup(struct gfar_priv_grp *gfargrp)
@@ -2834,62 +2832,72 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	struct gfar __iomem *regs = gfargrp->regs;
 	struct gfar_priv_tx_q *tx_queue = NULL;
 	struct gfar_priv_rx_q *rx_queue = NULL;
-	int rx_cleaned = 0, budget_per_queue = 0, rx_cleaned_per_queue = 0;
-	int tx_cleaned = 0, i, left_over_budget = budget;
+	int work_done = 0, work_done_per_q = 0;
+	int i, budget_per_q;
+	int has_tx_work;
 	unsigned long serviced_queues = 0;
-	int num_queues = 0;
-
-	num_queues = gfargrp->num_rx_queues;
-	budget_per_queue = budget/num_queues;
+	int num_queues = gfargrp->num_rx_queues;
 
+	budget_per_q = budget/num_queues;
 	/* Clear IEVENT, so interrupts aren't called again
 	 * because of the packets that have already arrived
 	 */
 	gfar_write(&regs->ievent, IEVENT_RTX_MASK);
 
-	while (num_queues && left_over_budget) {
-		budget_per_queue = left_over_budget/num_queues;
-		left_over_budget = 0;
+	while (1) {
+		has_tx_work = 0;
+		for_each_set_bit(i, &gfargrp->tx_bit_map, priv->num_tx_queues) {
+			tx_queue = priv->tx_queue[i];
+			/* run Tx cleanup to completion */
+			if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx]) {
+				gfar_clean_tx_ring(tx_queue);
+				has_tx_work = 1;
+			}
+		}
 
 		for_each_set_bit(i, &gfargrp->rx_bit_map, priv->num_rx_queues) {
 			if (test_bit(i, &serviced_queues))
 				continue;
+
 			rx_queue = priv->rx_queue[i];
-			tx_queue = priv->tx_queue[rx_queue->qindex];
-
-			tx_cleaned += gfar_clean_tx_ring(tx_queue);
-			rx_cleaned_per_queue =
-				gfar_clean_rx_ring(rx_queue, budget_per_queue);
-			rx_cleaned += rx_cleaned_per_queue;
-			if (rx_cleaned_per_queue < budget_per_queue) {
-				left_over_budget = left_over_budget +
-					(budget_per_queue -
-					 rx_cleaned_per_queue);
+			work_done_per_q =
+				gfar_clean_rx_ring(rx_queue, budget_per_q);
+			work_done += work_done_per_q;
+
+			/* finished processing this queue */
+			if (work_done_per_q < budget_per_q) {
 				set_bit(i, &serviced_queues);
 				num_queues--;
+				if (!num_queues)
+					break;
+				/* recompute budget per Rx queue */
+				budget_per_q =
+					(budget - work_done) / num_queues;
 			}
 		}
-	}
 
-	if (tx_cleaned)
-		return budget;
+		if (work_done >= budget)
+			break;
 
-	if (rx_cleaned < budget) {
-		napi_complete(napi);
+		if (!num_queues && !has_tx_work) {
 
-		/* Clear the halt bit in RSTAT */
-		gfar_write(&regs->rstat, gfargrp->rstat);
+			napi_complete(napi);
 
-		gfar_write(&regs->imask, IMASK_DEFAULT);
+			/* Clear the halt bit in RSTAT */
+			gfar_write(&regs->rstat, gfargrp->rstat);
 
-		/* If we are coalescing interrupts, update the timer
-		 * Otherwise, clear it
-		 */
-		gfar_configure_coalescing(priv, gfargrp->rx_bit_map,
-					  gfargrp->tx_bit_map);
+			gfar_write(&regs->imask, IMASK_DEFAULT);
+
+			/* If we are coalescing interrupts, update the timer
+			 * Otherwise, clear it
+			 */
+			gfar_configure_coalescing(priv, gfargrp->rx_bit_map,
+						  gfargrp->tx_bit_map);
+			break;
+		}
 	}
 
-	return rx_cleaned;
+	return work_done;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.7.11.3
