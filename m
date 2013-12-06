From: Nikita Yushchenko <nyushchenko@dev.rtsoft.ru>
Subject: [PATCH] net: gainfar: fix race between issuing and completing Tx
Date: Fri,  6 Dec 2013 16:35:59 +0400
Message-ID: <1386333359-18854-1-git-send-email-nyushchenko@dev.rtsoft.ru>
Cc: linux-kernel@vger.kernel.org,
	Dmitry Krivoschekov <dkrivoschokov@dev.rtsoft.ru>,
	Konstantin Baydarov <kbaidarov@dev.rtsoft.ru>,
	Nikita Yushchenko <nyushchenko@dev.rtsoft.ru>
To: "David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gfar_poll() checked Tx queue status without locking, thus allowing
gfar_start_xmit() to alter it in parallel, which caused hang on every
other nfsroot boot with RT enabled.

This patch raises locking from gfar_clean_tx_ring() up to gfar_poll().
With this change applied, hangs are no longer reproduced.

Signed-off-by: Nikita Yushchenko <nyushchenko@dev.rtsoft.ru>
---
 drivers/net/ethernet/freescale/gianfar.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 0343a14..9ac1946 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2499,7 +2499,6 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 	skb_dirtytx = tx_queue->skb_dirtytx;
 
 	while ((skb = tx_queue->tx_skbuff[skb_dirtytx])) {
-		unsigned long flags;
 
 		frags = skb_shinfo(skb)->nr_frags;
 
@@ -2561,9 +2560,7 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 			      TX_RING_MOD_MASK(tx_ring_size);
 
 		howmany++;
-		spin_lock_irqsave(&tx_queue->txlock, flags);
 		tx_queue->num_txbdfree += nr_txbds;
-		spin_unlock_irqrestore(&tx_queue->txlock, flags);
 	}
 
 	/* If we freed a buffer, we can restart transmission, if necessary */
@@ -2838,6 +2835,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	int has_tx_work;
 	unsigned long rstat_rxf;
 	int num_act_queues;
+	unsigned long flags;
 
 	/* Clear IEVENT, so interrupts aren't called again
 	 * because of the packets that have already arrived
@@ -2854,11 +2852,13 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 		has_tx_work = 0;
 		for_each_set_bit(i, &gfargrp->tx_bit_map, priv->num_tx_queues) {
 			tx_queue = priv->tx_queue[i];
+			spin_lock_irqsave(&tx_queue->txlock, flags);
 			/* run Tx cleanup to completion */
 			if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx]) {
 				gfar_clean_tx_ring(tx_queue);
 				has_tx_work = 1;
 			}
+			spin_unlock_irqrestore(&tx_queue->txlock, flags);
 		}
 
 		for_each_set_bit(i, &gfargrp->rx_bit_map, priv->num_rx_queues) {
-- 
1.7.0.1
