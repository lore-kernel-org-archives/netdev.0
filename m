From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 13/13] ftgmac100: Rework NAPI & interrupts handling
Date: Sun,  2 Apr 2017 13:35:23 +1000
Message-ID: <20170402033523.9482-14-benh@kernel.crashing.org>
References: <20170402033523.9482-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55383 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750796AbdDBEnx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 2 Apr 2017 00:43:53 -0400
In-Reply-To: <20170402033523.9482-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First, don't look at the interrupt status in the poll loop
to decide what to poll. It's wrong. If we have run out of
budget, we may still have RX packets to unqueue but no more
RX interrupt pending.

So instead move the code looking at the interrupt status
into the interrupt handler where it belongs. That avoids a slow
MMIO read in the NAPI fast path. We keep the abnormal interrupts
enabled while NAPI is scheduled.

While at it, actually do something useful in the "error" cases:

On AHB bus error, trigger the new reset task, that's about all
we can do. On RX packet fifo or descriptor overflows, we need
to restart the MAC after having freed things up. So set a flag
that NAPI will see and use to perform that restart after
harvesting the RX ring.

Finally, we shouldn't complete NAPI if there are still outgoing
packets that will need harvesting. Waiting for more interrupts
is less efficient than letting NAPI run a while longer while
the queue drains.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 137 +++++++++++++++++--------------
 drivers/net/ethernet/faraday/ftgmac100.h |  14 ++++
 2 files changed, 90 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index dc85d78..cbcbc92 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -83,7 +83,7 @@ struct ftgmac100 {
 	bool use_ncsi;
 
 	/* Misc */
-	int int_mask_all;
+	bool need_mac_restart;
 };
 
 static int ftgmac100_alloc_rx_page(struct ftgmac100 *priv,
@@ -1048,10 +1048,49 @@ static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
 {
 	struct net_device *netdev = dev_id;
 	struct ftgmac100 *priv = netdev_priv(netdev);
+	unsigned int status, new_mask = FTGMAC100_INT_BAD;
 
-	/* Disable interrupts for polling */
-	iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
-	napi_schedule(&priv->napi);
+	/* Fetch and clear interrupt bits, process abnormal ones */
+	status = ioread32(priv->base + FTGMAC100_OFFSET_ISR);
+	iowrite32(status, priv->base + FTGMAC100_OFFSET_ISR);
+	if (unlikely(status & FTGMAC100_INT_BAD)) {
+
+		/* RX buffer unavailable */
+		if (status & FTGMAC100_INT_NO_RXBUF)
+			netdev->stats.rx_over_errors++;
+
+		/* received packet lost due to RX FIFO full */
+		if (status & FTGMAC100_INT_RPKT_LOST)
+			netdev->stats.rx_fifo_errors++;
+
+		/* sent packet lost due to excessive TX collision */
+		if (status & FTGMAC100_INT_XPKT_LOST)
+			netdev->stats.tx_fifo_errors++;
+
+		/* AHB error -> Reset the chip */
+		if (status & FTGMAC100_INT_AHB_ERR) {
+			if (net_ratelimit())
+				netdev_warn(netdev,
+					   "AHB bus error ! Resetting chip.\n");
+			iowrite32(0, priv->base + FTGMAC100_OFFSET_IER);
+			schedule_work(&priv->reset_task);
+			return IRQ_HANDLED;
+		}
+
+		/* We may need to restart the MAC after such errors, delay
+		 * this until after we have freed some Rx buffers though
+		 */
+		priv->need_mac_restart = true;
+
+		/* Disable those errors until we restart */
+		new_mask &= ~status;
+	}
+
+	/* Only enable "bad" interrupts while NAPI is on */
+	iowrite32(new_mask, priv->base + FTGMAC100_OFFSET_IER);
+
+	/* Schedule NAPI bh */
+	napi_schedule_irqoff(&priv->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1059,68 +1098,51 @@ static irqreturn_t ftgmac100_interrupt(int irq, void *dev_id)
 static int ftgmac100_poll(struct napi_struct *napi, int budget)
 {
 	struct ftgmac100 *priv = container_of(napi, struct ftgmac100, napi);
-	struct net_device *netdev = priv->netdev;
-	unsigned int status;
-	bool completed = true;
+	bool more, completed = true;
 	int rx = 0;
 
-	status = ioread32(priv->base + FTGMAC100_OFFSET_ISR);
-	iowrite32(status, priv->base + FTGMAC100_OFFSET_ISR);
-
-	if (status & (FTGMAC100_INT_RPKT_BUF | FTGMAC100_INT_NO_RXBUF)) {
-		/*
-		 * FTGMAC100_INT_RPKT_BUF:
-		 *	RX DMA has received packets into RX buffer successfully
-		 *
-		 * FTGMAC100_INT_NO_RXBUF:
-		 *	RX buffer unavailable
-		 */
-		bool retry;
+	ftgmac100_tx_complete(priv);
 
-		do {
-			retry = ftgmac100_rx_packet(priv, &rx);
-		} while (retry && rx < budget);
+	do {
+		more = ftgmac100_rx_packet(priv, &rx);
+	} while (more && rx < budget);
 
-		if (retry && rx == budget)
-			completed = false;
-	}
+	if (more && rx == budget)
+		completed = false;
 
-	if (status & (FTGMAC100_INT_XPKT_ETH | FTGMAC100_INT_XPKT_LOST)) {
-		/*
-		 * FTGMAC100_INT_XPKT_ETH:
-		 *	packet transmitted to ethernet successfully
-		 *
-		 * FTGMAC100_INT_XPKT_LOST:
-		 *	packet transmitted to ethernet lost due to late
-		 *	collision or excessive collision
-		 */
-		ftgmac100_tx_complete(priv);
-	}
-
-	if (status & priv->int_mask_all & (FTGMAC100_INT_NO_RXBUF |
-			FTGMAC100_INT_RPKT_LOST | FTGMAC100_INT_AHB_ERR)) {
-		if (net_ratelimit())
-			netdev_info(netdev, "[ISR] = 0x%x: %s%s%s\n", status,
-				    status & FTGMAC100_INT_NO_RXBUF ? "NO_RXBUF " : "",
-				    status & FTGMAC100_INT_RPKT_LOST ? "RPKT_LOST " : "",
-				    status & FTGMAC100_INT_AHB_ERR ? "AHB_ERR " : "");
 
-		if (status & FTGMAC100_INT_NO_RXBUF) {
-			/* RX buffer unavailable */
-			netdev->stats.rx_over_errors++;
-		}
+	/* The interrupt is telling us to kick the MAC back to life
+	 * after an RX overflow
+	 */
+	if (unlikely(priv->need_mac_restart)) {
+		ftgmac100_start_hw(priv);
 
-		if (status & FTGMAC100_INT_RPKT_LOST) {
-			/* received packet lost due to RX FIFO full */
-			netdev->stats.rx_fifo_errors++;
-		}
+		/* Re-enable "bad" interrupts */
+		iowrite32(FTGMAC100_INT_BAD,
+			  priv->base + FTGMAC100_OFFSET_IER);
 	}
 
+	/* Keep NAPI going if we have still packets to reclaim */
+	if (priv->tx_pending)
+		return budget;
+
 	if (completed) {
+		/* We are about to re-enable all interrupts. However
+		 * the HW has been latching RX/TX packet interrupts while
+		 * they were masked. So we clear them first, then we need
+		 * to re-check if there's something to process
+		 */
+		iowrite32(FTGMAC100_INT_RXTX,
+			  priv->base + FTGMAC100_OFFSET_ISR);
+		if (ftgmac100_rxdes_packet_ready
+		    (ftgmac100_current_rxdes(priv)) || priv->tx_pending)
+			return budget;
+
+		/* deschedule NAPI */
 		napi_complete(napi);
 
 		/* enable all interrupts */
-		iowrite32(priv->int_mask_all,
+		iowrite32(FTGMAC100_INT_ALL,
 			  priv->base + FTGMAC100_OFFSET_IER);
 	}
 
@@ -1148,7 +1170,7 @@ static int ftgmac100_init_all(struct ftgmac100 *priv, bool ignore_alloc_err)
 	netif_start_queue(priv->netdev);
 
 	/* Enable all interrupts */
-	iowrite32(priv->int_mask_all, priv->base + FTGMAC100_OFFSET_IER);
+	iowrite32(FTGMAC100_INT_ALL, priv->base + FTGMAC100_OFFSET_IER);
 
 	return err;
 }
@@ -1489,13 +1511,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	/* MAC address from chip or random one */
 	ftgmac100_setup_mac(priv);
 
-	priv->int_mask_all = (FTGMAC100_INT_RPKT_LOST |
-			      FTGMAC100_INT_XPKT_ETH |
-			      FTGMAC100_INT_XPKT_LOST |
-			      FTGMAC100_INT_AHB_ERR |
-			      FTGMAC100_INT_RPKT_BUF |
-			      FTGMAC100_INT_NO_RXBUF);
-
 	if (of_machine_is_compatible("aspeed,ast2400") ||
 	    of_machine_is_compatible("aspeed,ast2500")) {
 		priv->rxdes0_edorr_mask = BIT(30);
diff --git a/drivers/net/ethernet/faraday/ftgmac100.h b/drivers/net/ethernet/faraday/ftgmac100.h
index a7ce0ac..c4d5cc1 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.h
+++ b/drivers/net/ethernet/faraday/ftgmac100.h
@@ -86,6 +86,20 @@
 #define FTGMAC100_INT_PHYSTS_CHG	(1 << 9)
 #define FTGMAC100_INT_NO_HPTXBUF	(1 << 10)
 
+/* Interrupts we care about in NAPI mode */
+#define FTGMAC100_INT_BAD  (FTGMAC100_INT_RPKT_LOST | \
+			    FTGMAC100_INT_XPKT_LOST | \
+			    FTGMAC100_INT_AHB_ERR   | \
+			    FTGMAC100_INT_NO_RXBUF)
+
+/* Normal RX/TX interrupts, enabled when NAPI off */
+#define FTGMAC100_INT_RXTX (FTGMAC100_INT_XPKT_ETH  | \
+			    FTGMAC100_INT_RPKT_BUF)
+
+/* All the interrupts we care about */
+#define FTGMAC100_INT_ALL (FTGMAC100_INT_RPKT_BUF  |  \
+			   FTGMAC100_INT_BAD)
+
 /*
  * Interrupt timer control register
  */
-- 
2.9.3
