From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 6/6] gianfar: Revive SKB recycling
Date: Wed, 11 Nov 2009 03:11:10 +0300
Message-ID: <20091111001110.GF8817@oksana.dev.rtsoft.ru>
References: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>, Jon Loeliger <jdl@jdl.com>,
	Kumar Gopalpet-B05799 <B05799@freescale.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:1587 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752346AbZKKALF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 19:11:05 -0500
Content-Disposition: inline
In-Reply-To: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before calling gfar_clean_tx_ring() the driver grabs an irqsave
spinlock, and then tries to recycle skbs. But since
skb_recycle_check() returns 0 with IRQs disabled, we'll never
recycle any skbs.

It appears that gfar_clean_tx_ring() and gfar_start_xmit() are
mostly idependent and can work in parallel, except when they
modify num_txbdfree.

So we can drop the lock from most sections and thus fix the skb
recycling.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |   31 +++++++++++++++++++------------
 1 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index fde430a..16def13 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1928,14 +1928,11 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* total number of fragments in the SKB */
 	nr_frags = skb_shinfo(skb)->nr_frags;
 
-	spin_lock_irqsave(&tx_queue->txlock, flags);
-
 	/* check if there is space to queue this packet */
 	if ((nr_frags+1) > tx_queue->num_txbdfree) {
 		/* no space, stop the queue */
 		netif_tx_stop_queue(txq);
 		dev->stats.tx_fifo_errors++;
-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1999,6 +1996,20 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	lstatus |= BD_LFLAG(TXBD_CRC | TXBD_READY) | skb_headlen(skb);
 
 	/*
+	 * We can work in parallel with gfar_clean_tx_ring(), except
+	 * when modifying num_txbdfree. Note that we didn't grab the lock
+	 * when we were reading the num_txbdfree and checking for available
+	 * space, that's because outside of this function it can only grow,
+	 * and once we've got needed space, it cannot suddenly disappear.
+	 *
+	 * The lock also protects us from gfar_error(), which can modify
+	 * regs->tstat and thus retrigger the transfers, which is why we
+	 * also must grab the lock before setting ready bit for the first
+	 * to be transmitted BD.
+	 */
+	spin_lock_irqsave(&tx_queue->txlock, flags);
+
+	/*
 	 * The powerpc-specific eieio() is used, as wmb() has too strong
 	 * semantics (it requires synchronization between cacheable and
 	 * uncacheable mappings, which eieio doesn't provide and which we
@@ -2225,6 +2236,8 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	skb_dirtytx = tx_queue->skb_dirtytx;
 
 	while ((skb = tx_queue->tx_skbuff[skb_dirtytx])) {
+		unsigned long flags;
+
 		frags = skb_shinfo(skb)->nr_frags;
 		lbdp = skip_txbd(bdp, frags, base, tx_ring_size);
 
@@ -2269,7 +2282,9 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 			TX_RING_MOD_MASK(tx_ring_size);
 
 		howmany++;
+		spin_lock_irqsave(&tx_queue->txlock, flags);
 		tx_queue->num_txbdfree += frags + 1;
+		spin_unlock_irqrestore(&tx_queue->txlock, flags);
 	}
 
 	/* If we freed a buffer, we can restart transmission, if necessary */
@@ -2548,7 +2563,6 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	int tx_cleaned = 0, i, left_over_budget = budget;
 	unsigned long serviced_queues = 0;
 	int num_queues = 0;
-	unsigned long flags;
 
 	num_queues = gfargrp->num_rx_queues;
 	budget_per_queue = budget/num_queues;
@@ -2568,14 +2582,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 			rx_queue = priv->rx_queue[i];
 			tx_queue = priv->tx_queue[rx_queue->qindex];
 
-			/* If we fail to get the lock,
-			 * don't bother with the TX BDs */
-			if (spin_trylock_irqsave(&tx_queue->txlock, flags)) {
-				tx_cleaned += gfar_clean_tx_ring(tx_queue);
-				spin_unlock_irqrestore(&tx_queue->txlock,
-							flags);
-			}
-
+			tx_cleaned += gfar_clean_tx_ring(tx_queue);
 			rx_cleaned_per_queue = gfar_clean_rx_ring(rx_queue,
 							budget_per_queue);
 			rx_cleaned += rx_cleaned_per_queue;
-- 
1.6.3.3
