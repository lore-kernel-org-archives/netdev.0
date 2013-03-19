From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 2/4][net-next] gianfar: Poll only active Rx queues
Date: Tue, 19 Mar 2013 19:40:03 +0200
Message-ID: <1363714805-9142-3-git-send-email-claudiu.manoil@freescale.com>
References: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:49851 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932483Ab3CSRk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:40:56 -0400
In-Reply-To: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split the napi budget fairly among the active queues only, instead
of dividing it by the total number of Rx queues assigned to the
given interrupt group.
Use the h/w indication field RXFi in rstat (receive status register)
to identify the active rx queues from the current interrupt group
(i.e. receive event occured on ring i, if ring i is part of the current
interrupt group). This indication field in rstat, RXFi i=0..7,
allows us to find out on which queues of the same interrupt group
do we have incomming traffic once we entered the polling routine for
the given interrupt group. After servicing the ring i, the corresponding
bit RXFi will be written with 1 to clear the active queue indication for
that ring.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 28 +++++++++++++++++++---------
 drivers/net/ethernet/freescale/gianfar.h |  4 +++-
 2 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 1e555a7..3f07dbd 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2835,15 +2835,20 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	int work_done = 0, work_done_per_q = 0;
 	int i, budget_per_q;
 	int has_tx_work;
-	unsigned long serviced_queues = 0;
-	int num_queues = gfargrp->num_rx_queues;
+	unsigned long rstat_rxf;
+	int num_act_queues;
 
-	budget_per_q = budget/num_queues;
 	/* Clear IEVENT, so interrupts aren't called again
 	 * because of the packets that have already arrived
 	 */
 	gfar_write(&regs->ievent, IEVENT_RTX_MASK);
 
+	rstat_rxf = gfar_read(&regs->rstat) & RSTAT_RXF_MASK;
+
+	num_act_queues = bitmap_weight(&rstat_rxf, MAX_RX_QS);
+	if (num_act_queues)
+		budget_per_q = budget/num_act_queues;
+
 	while (1) {
 		has_tx_work = 0;
 		for_each_set_bit(i, &gfargrp->tx_bit_map, priv->num_tx_queues) {
@@ -2856,7 +2861,8 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 		}
 
 		for_each_set_bit(i, &gfargrp->rx_bit_map, priv->num_rx_queues) {
-			if (test_bit(i, &serviced_queues))
+			/* skip queue if not active */
+			if (!(rstat_rxf & (RSTAT_CLEAR_RXF0 >> i)))
 				continue;
 
 			rx_queue = priv->rx_queue[i];
@@ -2866,20 +2872,24 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 
 			/* finished processing this queue */
 			if (work_done_per_q < budget_per_q) {
-				set_bit(i, &serviced_queues);
-				num_queues--;
-				if (!num_queues)
+				/* clear active queue hw indication */
+				gfar_write(&regs->rstat,
+					   RSTAT_CLEAR_RXF0 >> i);
+				rstat_rxf &= ~(RSTAT_CLEAR_RXF0 >> i);
+				num_act_queues--;
+
+				if (!num_act_queues)
 					break;
 				/* recompute budget per Rx queue */
 				budget_per_q =
-					(budget - work_done) / num_queues;
+					(budget - work_done) / num_act_queues;
 			}
 		}
 
 		if (work_done >= budget)
 			break;
 
-		if (!num_queues && !has_tx_work) {
+		if (!num_act_queues && !has_tx_work) {
 
 			napi_complete(napi);
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 63a28d2..b1d0c1c 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -291,7 +291,9 @@ extern const char gfar_driver_version[];
 #define RCTRL_PADDING(x)	((x << 16) & RCTRL_PAL_MASK)
 
 
-#define RSTAT_CLEAR_RHALT       0x00800000
+#define RSTAT_CLEAR_RHALT	0x00800000
+#define RSTAT_CLEAR_RXF0	0x00000080
+#define RSTAT_RXF_MASK		0x000000ff
 
 #define TCTRL_IPCSEN		0x00004000
 #define TCTRL_TUCSEN		0x00002000
-- 
1.7.11.3
