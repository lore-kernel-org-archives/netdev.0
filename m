From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH][net-next] gianfar: Simplify MQ polling to avoid soft lockup
Date: Mon, 14 Oct 2013 17:05:09 +0300
Message-ID: <1381759509-26882-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0252.outbound.messaging.microsoft.com ([213.199.154.252]:14647
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750738Ab3JNOKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 10:10:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under certain low traffic conditions, the single core
devices with multiple Rx/Tx queues (MQ mode) may reach
soft lockup due to gfar_poll not returning in proper time.
The following exception was obtained using iperf on a 100Mbit
half-duplex link, for a p1010 single core device:

BUG: soft lockup - CPU#0 stuck for 23s! [iperf:2847]
Modules linked in:
CPU: 0 PID: 2847 Comm: iperf Not tainted 3.12.0-rc3 #16
task: e8bf8000 ti: eeb16000 task.ti: ee646000
NIP: c0255b6c LR: c0367ae8 CTR: c0461c18
REGS: eeb17e70 TRAP: 0901   Not tainted  (3.12.0-rc3)
MSR: 00029000 <CE,EE,ME>  CR: 44228428  XER: 20000000

GPR00: c0367ad4 eeb17f20 e8bf8000 ee01f4b4 00000008 ffffffff ffffffff
00000000
GPR08: 000000c0 00000008 000000ff ffffffc0 000193fe
NIP [c0255b6c] find_next_bit+0xb8/0xc4
LR [c0367ae8] gfar_poll+0xc8/0x1d8
Call Trace:
[eeb17f20] [c0367ad4] gfar_poll+0xb4/0x1d8 (unreliable)
[eeb17f70] [c0422100] net_rx_action+0xa4/0x158
[eeb17fa0] [c003ec6c] __do_softirq+0xcc/0x17c
[eeb17ff0] [c000c28c] call_do_softirq+0x24/0x3c
[ee647cc0] [c0004660] do_softirq+0x6c/0x94
[ee647ce0] [c003eb9c] local_bh_enable+0x9c/0xa0
[ee647cf0] [c0454fe8] tcp_prequeue_process+0xa4/0xdc
[ee647d10] [c0457e44] tcp_recvmsg+0x498/0x96c
[ee647d80] [c047b630] inet_recvmsg+0x40/0x64
[ee647da0] [c040ca8c] sock_recvmsg+0x90/0xc0
[ee647e30] [c040edb8] SyS_recvfrom+0x98/0xfc

To prevent this, the outer while() loop has been removed
allowing gfar_poll() to return faster even if there's
still budget left.  Also, there's no need to recompute
the budget per Rx queue anymore.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 87 ++++++++++++++------------------
 1 file changed, 38 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 9fbe4dd..d6d810c 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2918,7 +2918,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	int work_done = 0, work_done_per_q = 0;
 	int i, budget_per_q = 0;
-	int has_tx_work;
+	int has_tx_work = 0;
 	unsigned long rstat_rxf;
 	int num_act_queues;
 
@@ -2933,62 +2933,51 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	if (num_act_queues)
 		budget_per_q = budget/num_act_queues;
 
-	while (1) {
-		has_tx_work = 0;
-		for_each_set_bit(i, &gfargrp->tx_bit_map, priv->num_tx_queues) {
-			tx_queue = priv->tx_queue[i];
-			/* run Tx cleanup to completion */
-			if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx]) {
-				gfar_clean_tx_ring(tx_queue);
-				has_tx_work = 1;
-			}
+	for_each_set_bit(i, &gfargrp->tx_bit_map, priv->num_tx_queues) {
+		tx_queue = priv->tx_queue[i];
+		/* run Tx cleanup to completion */
+		if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx]) {
+			gfar_clean_tx_ring(tx_queue);
+			has_tx_work = 1;
 		}
+	}
 
-		for_each_set_bit(i, &gfargrp->rx_bit_map, priv->num_rx_queues) {
-			/* skip queue if not active */
-			if (!(rstat_rxf & (RSTAT_CLEAR_RXF0 >> i)))
-				continue;
-
-			rx_queue = priv->rx_queue[i];
-			work_done_per_q =
-				gfar_clean_rx_ring(rx_queue, budget_per_q);
-			work_done += work_done_per_q;
-
-			/* finished processing this queue */
-			if (work_done_per_q < budget_per_q) {
-				/* clear active queue hw indication */
-				gfar_write(&regs->rstat,
-					   RSTAT_CLEAR_RXF0 >> i);
-				rstat_rxf &= ~(RSTAT_CLEAR_RXF0 >> i);
-				num_act_queues--;
-
-				if (!num_act_queues)
-					break;
-				/* recompute budget per Rx queue */
-				budget_per_q =
-					(budget - work_done) / num_act_queues;
-			}
-		}
+	for_each_set_bit(i, &gfargrp->rx_bit_map, priv->num_rx_queues) {
+		/* skip queue if not active */
+		if (!(rstat_rxf & (RSTAT_CLEAR_RXF0 >> i)))
+			continue;
 
-		if (work_done >= budget)
-			break;
+		rx_queue = priv->rx_queue[i];
+		work_done_per_q =
+			gfar_clean_rx_ring(rx_queue, budget_per_q);
+		work_done += work_done_per_q;
+
+		/* finished processing this queue */
+		if (work_done_per_q < budget_per_q) {
+			/* clear active queue hw indication */
+			gfar_write(&regs->rstat,
+				   RSTAT_CLEAR_RXF0 >> i);
+			num_act_queues--;
+
+			if (!num_act_queues)
+				break;
+		}
+	}
 
-		if (!num_act_queues && !has_tx_work) {
+	if (!num_act_queues && !has_tx_work) {
 
-			napi_complete(napi);
+		napi_complete(napi);
 
-			/* Clear the halt bit in RSTAT */
-			gfar_write(&regs->rstat, gfargrp->rstat);
+		/* Clear the halt bit in RSTAT */
+		gfar_write(&regs->rstat, gfargrp->rstat);
 
-			gfar_write(&regs->imask, IMASK_DEFAULT);
+		gfar_write(&regs->imask, IMASK_DEFAULT);
 
-			/* If we are coalescing interrupts, update the timer
-			 * Otherwise, clear it
-			 */
-			gfar_configure_coalescing(priv, gfargrp->rx_bit_map,
-						  gfargrp->tx_bit_map);
-			break;
-		}
+		/* If we are coalescing interrupts, update the timer
+		 * Otherwise, clear it
+		 */
+		gfar_configure_coalescing(priv, gfargrp->rx_bit_map,
+					  gfargrp->tx_bit_map);
 	}
 
 	return work_done;
-- 
1.7.11.7
