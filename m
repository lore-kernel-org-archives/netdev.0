From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 07/12] ftgmac100: Cleanup tx queue handling
Date: Fri,  7 Apr 2017 13:31:00 +1000
Message-ID: <20170407033105.29558-8-benh@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39163 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753847AbdDGDbt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:31:49 -0400
In-Reply-To: <20170407033105.29558-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a private lock which isn't terribly useful, and we maintain
a "tx_pending" counter for information that's already available
via a trivial arithmetic operation. Then we unconditionaly wake
the queue even when not stopped. Finally our code in tx isn't
really safe vs. a concurrent reclaim. The aspeed chips aren't SMP
today but I prefer the code being right and future proof.

So rip that out and replace it with more "standard" queue handling,
currently with a threshold of 1 queue element, which will be
increased when we implement fragmented sends.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 103 ++++++++++++++++++++-----------
 1 file changed, 68 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index ff01dfb..ccf0fcd 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -44,6 +44,9 @@
 #define MAX_PKT_SIZE		1536
 #define RX_BUF_SIZE		MAX_PKT_SIZE	/* must be smaller than 0x3fff */
 
+/* Min number of tx ring entries before stopping queue */
+#define TX_THRESHOLD		(1)
+
 struct ftgmac100_descs {
 	struct ftgmac100_rxdes rxdes[RX_QUEUE_ENTRIES];
 	struct ftgmac100_txdes txdes[TX_QUEUE_ENTRIES];
@@ -66,9 +69,7 @@ struct ftgmac100 {
 	struct sk_buff *tx_skbs[TX_QUEUE_ENTRIES];
 	unsigned int tx_clean_pointer;
 	unsigned int tx_pointer;
-	unsigned int tx_pending;
 	u32 txdes0_edotr_mask;
-	spinlock_t tx_lock;
 
 	/* Scratch page to use when rx skb alloc fails */
 	void *rx_scratch;
@@ -163,7 +164,6 @@ static int ftgmac100_reset_and_config_mac(struct ftgmac100 *priv)
 	priv->rx_pointer = 0;
 	priv->tx_clean_pointer = 0;
 	priv->tx_pointer = 0;
-	priv->tx_pending = 0;
 
 	/* The doc says reset twice with 10us interval */
 	if (ftgmac100_reset_mac(priv, maccr))
@@ -549,6 +549,23 @@ static int ftgmac100_next_tx_pointer(int pointer)
 	return (pointer + 1) & (TX_QUEUE_ENTRIES - 1);
 }
 
+static u32 ftgmac100_tx_buf_avail(struct ftgmac100 *priv)
+{
+	/* Returns the number of available slots in the TX queue
+	 *
+	 * This always leaves one free slot so we don't have to
+	 * worry about empty vs. full, and this simplifies the
+	 * test for ftgmac100_tx_buf_cleanable() below
+	 */
+	return (priv->tx_clean_pointer - priv->tx_pointer - 1) &
+		(TX_QUEUE_ENTRIES - 1);
+}
+
+static bool ftgmac100_tx_buf_cleanable(struct ftgmac100 *priv)
+{
+	return priv->tx_pointer != priv->tx_clean_pointer;
+}
+
 static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 {
 	struct net_device *netdev = priv->netdev;
@@ -557,9 +574,6 @@ static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 	struct sk_buff *skb;
 	dma_addr_t map;
 
-	if (priv->tx_pending == 0)
-		return false;
-
 	pointer = priv->tx_clean_pointer;
 	txdes = &priv->descs->txdes[pointer];
 
@@ -581,18 +595,31 @@ static bool ftgmac100_tx_complete_packet(struct ftgmac100 *priv)
 
 	priv->tx_clean_pointer = ftgmac100_next_tx_pointer(pointer);
 
-	spin_lock(&priv->tx_lock);
-	priv->tx_pending--;
-	spin_unlock(&priv->tx_lock);
-	netif_wake_queue(netdev);
-
 	return true;
 }
 
 static void ftgmac100_tx_complete(struct ftgmac100 *priv)
 {
-	while (ftgmac100_tx_complete_packet(priv))
+	struct net_device *netdev = priv->netdev;
+
+	/* Process all completed packets */
+	while (ftgmac100_tx_buf_cleanable(priv) &&
+	       ftgmac100_tx_complete_packet(priv))
 		;
+
+	/* Restart queue if needed */
+	smp_mb();
+	if (unlikely(netif_queue_stopped(netdev) &&
+		     ftgmac100_tx_buf_avail(priv) >= TX_THRESHOLD)) {
+		struct netdev_queue *txq;
+
+		txq = netdev_get_tx_queue(netdev, 0);
+		__netif_tx_lock(txq, smp_processor_id());
+		if (netif_queue_stopped(netdev) &&
+		    ftgmac100_tx_buf_avail(priv) >= TX_THRESHOLD)
+			netif_wake_queue(netdev);
+		__netif_tx_unlock(txq);
+	}
 }
 
 static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
@@ -651,17 +678,22 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 		}
 	}
 
+	ftgmac100_txdes_set_dma_own(txdes);
+
 	/* Update next TX pointer */
 	priv->tx_pointer = ftgmac100_next_tx_pointer(pointer);
 
-	spin_lock(&priv->tx_lock);
-	priv->tx_pending++;
-	if (priv->tx_pending == TX_QUEUE_ENTRIES)
+	/* If there isn't enough room for all the fragments of a new packet
+	 * in the TX ring, stop the queue. The sequence below is race free
+	 * vs. a concurrent restart in ftgmac100_poll()
+	 */
+	if (unlikely(ftgmac100_tx_buf_avail(priv) < TX_THRESHOLD)) {
 		netif_stop_queue(netdev);
-
-	/* start transmit */
-	ftgmac100_txdes_set_dma_own(txdes);
-	spin_unlock(&priv->tx_lock);
+		/* Order the queue stop with the test below */
+		smp_mb();
+		if (ftgmac100_tx_buf_avail(priv) >= TX_THRESHOLD)
+			netif_wake_queue(netdev);
+	}
 
 	ftgmac100_txdma_normal_prio_start_polling(priv);
 
@@ -979,17 +1011,17 @@ static bool ftgmac100_check_rx(struct ftgmac100 *priv)
 static int ftgmac100_poll(struct napi_struct *napi, int budget)
 {
 	struct ftgmac100 *priv = container_of(napi, struct ftgmac100, napi);
-	bool more, completed = true;
-	int rx = 0;
+	int work_done = 0;
+	bool more;
 
-	ftgmac100_tx_complete(priv);
+	/* Handle TX completions */
+	if (ftgmac100_tx_buf_cleanable(priv))
+		ftgmac100_tx_complete(priv);
 
+	/* Handle RX packets */
 	do {
-		more = ftgmac100_rx_packet(priv, &rx);
-	} while (more && rx < budget);
-
-	if (more && rx == budget)
-		completed = false;
+		more = ftgmac100_rx_packet(priv, &work_done);
+	} while (more && work_done < budget);
 
 
 	/* The interrupt is telling us to kick the MAC back to life
@@ -1003,11 +1035,13 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 			  priv->base + FTGMAC100_OFFSET_IER);
 	}
 
-	/* Keep NAPI going if we have still packets to reclaim */
-	if (priv->tx_pending)
-		return budget;
+	/* As long as we are waiting for transmit packets to be
+	 * completed we keep NAPI going
+	 */
+	if (ftgmac100_tx_buf_cleanable(priv))
+		work_done = budget;
 
-	if (completed) {
+	if (work_done < budget) {
 		/* We are about to re-enable all interrupts. However
 		 * the HW has been latching RX/TX packet interrupts while
 		 * they were masked. So we clear them first, then we need
@@ -1015,7 +1049,8 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 		 */
 		iowrite32(FTGMAC100_INT_RXTX,
 			  priv->base + FTGMAC100_OFFSET_ISR);
-		if (ftgmac100_check_rx(priv) || priv->tx_pending)
+		if (ftgmac100_check_rx(priv) ||
+		    ftgmac100_tx_buf_cleanable(priv))
 			return budget;
 
 		/* deschedule NAPI */
@@ -1026,7 +1061,7 @@ static int ftgmac100_poll(struct napi_struct *napi, int budget)
 			  priv->base + FTGMAC100_OFFSET_IER);
 	}
 
-	return rx;
+	return work_done;
 }
 
 static int ftgmac100_init_all(struct ftgmac100 *priv, bool ignore_alloc_err)
@@ -1354,8 +1389,6 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	priv->dev = &pdev->dev;
 	INIT_WORK(&priv->reset_task, ftgmac100_reset_task);
 
-	spin_lock_init(&priv->tx_lock);
-
 	/* map io memory */
 	priv->res = request_mem_region(res->start, resource_size(res),
 				       dev_name(&pdev->dev));
-- 
2.9.3
