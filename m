From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 1/2] gianfar: Move TxFIFO underrun handling to reset path
Date: Wed, 6 May 2015 18:07:29 +0300
Message-ID: <1430924850-2871-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0113.outbound.protection.outlook.com ([157.56.111.113]:46976
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750876AbbEFPXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 11:23:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle TxFIFO underrun exceptions outside the fast path.
A controller reset is more reliable in this exceptional
case, as opposed to re-enabling on-the-fly the Tx DMA.

As the controller reset is handled outside the fast path
by the reset_gfar() workqueue handler, the locking
scheme on the Tx path is significantly simplified.
Because the Tx processing (xmit queues and tx napi) is
disabled during controller reset, tstat access from xmit
does not require locking.  So the scope of the txlock on
the processing path is now reduced to num_txbdfree, which
is shared only between process context (xmit) and softirq
(clean_tx_ring).  As a result, the txlock must not guard
against interrupt context, and the spin_lock_irqsave()
from xmit can be replaced by spin_lock_bh().  Likewise,
the locking has been downgraded for clean_tx_ring().

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 40 ++++++++------------------------
 1 file changed, 10 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4ee080d..3c84e5a 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2254,7 +2254,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int i, rq = 0;
 	int do_tstamp, do_csum, do_vlan;
 	u32 bufaddr;
-	unsigned long flags;
 	unsigned int nr_frags, nr_txbds, bytes_sent, fcb_len = 0;
 
 	rq = skb->queue_mapping;
@@ -2434,19 +2433,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	netdev_tx_sent_queue(txq, bytes_sent);
 
-	/* We can work in parallel with gfar_clean_tx_ring(), except
-	 * when modifying num_txbdfree. Note that we didn't grab the lock
-	 * when we were reading the num_txbdfree and checking for available
-	 * space, that's because outside of this function it can only grow,
-	 * and once we've got needed space, it cannot suddenly disappear.
-	 *
-	 * The lock also protects us from gfar_error(), which can modify
-	 * regs->tstat and thus retrigger the transfers, which is why we
-	 * also must grab the lock before setting ready bit for the first
-	 * to be transmitted BD.
-	 */
-	spin_lock_irqsave(&tx_queue->txlock, flags);
-
 	gfar_wmb();
 
 	txbdp_start->lstatus = cpu_to_be32(lstatus);
@@ -2463,8 +2449,15 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_queue->cur_tx = next_txbd(txbdp, base, tx_queue->tx_ring_size);
 
+	/* We can work in parallel with gfar_clean_tx_ring(), except
+	 * when modifying num_txbdfree. Note that we didn't grab the lock
+	 * when we were reading the num_txbdfree and checking for available
+	 * space, that's because outside of this function it can only grow.
+	 */
+	spin_lock_bh(&tx_queue->txlock);
 	/* reduce TxBD free count */
 	tx_queue->num_txbdfree -= (nr_txbds);
+	spin_unlock_bh(&tx_queue->txlock);
 
 	/* If the next BD still needs to be cleaned up, then the bds
 	 * are full.  We need to tell the kernel to stop sending us stuff.
@@ -2478,9 +2471,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Tell the DMA to go go go */
 	gfar_write(&regs->tstat, TSTAT_CLEAR_THALT >> tx_queue->qindex);
 
-	/* Unlock priv */
-	spin_unlock_irqrestore(&tx_queue->txlock, flags);
-
 	return NETDEV_TX_OK;
 
 dma_map_err:
@@ -2622,7 +2612,6 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	skb_dirtytx = tx_queue->skb_dirtytx;
 
 	while ((skb = tx_queue->tx_skbuff[skb_dirtytx])) {
-		unsigned long flags;
 
 		frags = skb_shinfo(skb)->nr_frags;
 
@@ -2686,9 +2675,9 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 			      TX_RING_MOD_MASK(tx_ring_size);
 
 		howmany++;
-		spin_lock_irqsave(&tx_queue->txlock, flags);
+		spin_lock(&tx_queue->txlock);
 		tx_queue->num_txbdfree += nr_txbds;
-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
+		spin_unlock(&tx_queue->txlock);
 	}
 
 	/* If we freed a buffer, we can restart transmission, if necessary */
@@ -3411,21 +3400,12 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 		if (events & IEVENT_CRL)
 			dev->stats.tx_aborted_errors++;
 		if (events & IEVENT_XFUN) {
-			unsigned long flags;
-
 			netif_dbg(priv, tx_err, dev,
 				  "TX FIFO underrun, packet dropped\n");
 			dev->stats.tx_dropped++;
 			atomic64_inc(&priv->extra_stats.tx_underrun);
 
-			local_irq_save(flags);
-			lock_tx_qs(priv);
-
-			/* Reactivate the Tx Queues */
-			gfar_write(&regs->tstat, gfargrp->tstat);
-
-			unlock_tx_qs(priv);
-			local_irq_restore(flags);
+			schedule_work(&priv->reset_task);
 		}
 		netif_dbg(priv, tx_err, dev, "Transmit Error\n");
 	}
-- 
1.7.11.7
