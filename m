From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH 5/5] net: mvneta: replace Tx timer with a real interrupt
Date: Sun, 12 Jan 2014 10:31:09 +0100
Message-ID: <1389519069-1619-6-git-send-email-w@1wt.eu>
References: <1389519069-1619-1-git-send-email-w@1wt.eu>
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Arnaud Ebalard <arno@natisbad.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55220 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbaALJcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 04:32:04 -0500
In-Reply-To: <1389519069-1619-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now the mvneta driver doesn't handle Tx IRQ, and relies on two
mechanisms to flush Tx descriptors : a flush at the end of mvneta_tx()
and a timer. If a burst of packets is emitted faster than the device
can send them, then the queue is stopped until next wake-up of the
timer 10ms later. This causes jerky output traffic with bursts and
pauses, making it difficult to reach line rate with very few streams.

A test on UDP traffic shows that it's not possible to go beyond 134
Mbps / 12 kpps of outgoing traffic with 1500-bytes IP packets. Routed
traffic tends to observe pauses as well if the traffic is bursty,
making it even burstier after the wake-up.

It seems that this feature was inherited from the original driver but
nothing there mentions any reason for not using the interrupt instead,
which the chip supports.

Thus, this patch enables Tx interrupts and removes the timer. It does
the two at once because it's not really possible to make the two
mechanisms coexist, so a split patch doesn't make sense.

First tests performed on a Mirabox (Armada 370) show that less CPU
seems to be used when sending traffic. One reason might be that we now
call the mvneta_tx_done_gbe() with a mask indicating which queues have
been done instead of looping over all of them.

The same UDP test above now happily reaches 987 Mbps / 87.7 kpps.
Single-stream TCP traffic can now more easily reach line rate. HTTP
transfers of 1 MB objects over a single connection went from 730 to
840 Mbps. It is even possible to go significantly higher (>900 Mbps)
by tweaking tcp_tso_win_divisor.

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Cc: Arnaud Ebalard <arno@natisbad.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Willy Tarreau <w@1wt.eu>

---
 drivers/net/ethernet/marvell/mvneta.c | 71 ++++++-----------------------------
 1 file changed, 12 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index defda6f..df75a23 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -216,9 +216,6 @@
 #define MVNETA_RX_COAL_PKTS		32
 #define MVNETA_RX_COAL_USEC		100
 
-/* Timer */
-#define MVNETA_TX_DONE_TIMER_PERIOD	10
-
 /* Napi polling weight */
 #define MVNETA_RX_POLL_WEIGHT		64
 
@@ -274,16 +271,11 @@ struct mvneta_port {
 	void __iomem *base;
 	struct mvneta_rx_queue *rxqs;
 	struct mvneta_tx_queue *txqs;
-	struct timer_list tx_done_timer;
 	struct net_device *dev;
 
 	u32 cause_rx_tx;
 	struct napi_struct napi;
 
-	/* Flags */
-	unsigned long flags;
-#define MVNETA_F_TX_DONE_TIMER_BIT  0
-
 	/* Napi weight */
 	int weight;
 
@@ -1149,17 +1141,6 @@ static void mvneta_tx_done_pkts_coal_set(struct mvneta_port *pp,
 	txq->done_pkts_coal = value;
 }
 
-/* Trigger tx done timer in MVNETA_TX_DONE_TIMER_PERIOD msecs */
-static void mvneta_add_tx_done_timer(struct mvneta_port *pp)
-{
-	if (test_and_set_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags) == 0) {
-		pp->tx_done_timer.expires = jiffies +
-			msecs_to_jiffies(MVNETA_TX_DONE_TIMER_PERIOD);
-		add_timer(&pp->tx_done_timer);
-	}
-}
-
-
 /* Handle rx descriptor fill by setting buf_cookie and buf_phys_addr */
 static void mvneta_rx_desc_fill(struct mvneta_rx_desc *rx_desc,
 				u32 phys_addr, u32 cookie)
@@ -1651,15 +1632,6 @@ out:
 		dev_kfree_skb_any(skb);
 	}
 
-	if (txq->count >= MVNETA_TXDONE_COAL_PKTS)
-		mvneta_txq_done(pp, txq);
-
-	/* If after calling mvneta_txq_done, count equals
-	 * frags, we need to set the timer
-	 */
-	if (txq->count == frags && frags > 0)
-		mvneta_add_tx_done_timer(pp);
-
 	return NETDEV_TX_OK;
 }
 
@@ -1935,14 +1907,22 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 
 	/* Read cause register */
 	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE) &
-		MVNETA_RX_INTR_MASK(rxq_number);
+		(MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
+
+	/* Release Tx descriptors */
+	if (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL) {
+		int tx_todo = 0;
+
+		mvneta_tx_done_gbe(pp, (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL), &tx_todo);
+		cause_rx_tx &= ~MVNETA_TX_INTR_MASK_ALL;
+	}
 
 	/* For the case where the last mvneta_poll did not process all
 	 * RX packets
 	 */
 	cause_rx_tx |= pp->cause_rx_tx;
 	if (rxq_number > 1) {
-		while ((cause_rx_tx != 0) && (budget > 0)) {
+		while ((cause_rx_tx & MVNETA_RX_INTR_MASK_ALL) && (budget > 0)) {
 			int count;
 			struct mvneta_rx_queue *rxq;
 			/* get rx queue number from cause_rx_tx */
@@ -1974,7 +1954,7 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		local_irq_save(flags);
 		mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-			    MVNETA_RX_INTR_MASK(rxq_number));
+			    MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
 		local_irq_restore(flags);
 	}
 
@@ -1982,26 +1962,6 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	return rx_done;
 }
 
-/* tx done timer callback */
-static void mvneta_tx_done_timer_callback(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *)data;
-	struct mvneta_port *pp = netdev_priv(dev);
-	int tx_done = 0, tx_todo = 0;
-
-	if (!netif_running(dev))
-		return ;
-
-	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
-
-	tx_done = mvneta_tx_done_gbe(pp,
-				     (((1 << txq_number) - 1) &
-				      MVNETA_CAUSE_TXQ_SENT_DESC_ALL_MASK),
-				     &tx_todo);
-	if (tx_todo > 0)
-		mvneta_add_tx_done_timer(pp);
-}
-
 /* Handle rxq fill: allocates rxq skbs; called when initializing a port */
 static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
 			   int num)
@@ -2251,7 +2211,7 @@ static void mvneta_start_dev(struct mvneta_port *pp)
 
 	/* Unmask interrupts */
 	mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-		    MVNETA_RX_INTR_MASK(rxq_number));
+		    MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
 
 	phy_start(pp->phy_dev);
 	netif_tx_start_all_queues(pp->dev);
@@ -2527,8 +2487,6 @@ static int mvneta_stop(struct net_device *dev)
 	free_irq(dev->irq, pp);
 	mvneta_cleanup_rxqs(pp);
 	mvneta_cleanup_txqs(pp);
-	del_timer(&pp->tx_done_timer);
-	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
 
 	return 0;
 }
@@ -2887,11 +2845,6 @@ static int mvneta_probe(struct platform_device *pdev)
 		}
 	}
 
-	pp->tx_done_timer.data = (unsigned long)dev;
-	pp->tx_done_timer.function = mvneta_tx_done_timer_callback;
-	init_timer(&pp->tx_done_timer);
-	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
-
 	pp->tx_ring_size = MVNETA_MAX_TXD;
 	pp->rx_ring_size = MVNETA_MAX_RXD;
 
-- 
1.7.12.2.21.g234cd45.dirty
