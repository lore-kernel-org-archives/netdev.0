From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RFC] mv643xx_eth: move tx clean into its own napi poll handler
Date: Wed, 9 Jul 2008 01:50:23 +0200
Message-ID: <20080708235023.GF14330@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ashish Karkare <akarkare@marvell.com>,
	Dale Farnsworth <dale@farnsworth.org>,
	Eugene San <eugenesan@gmail.com>, Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:60170 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993AbYGHXu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 19:50:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This hacky test patch moves TX cleaning from the RX napi poll handler
into its own napi poll handler, and boosts the throughput on a 1 GiB
file sendfile() test from ~14.4 MiB/s (71 seconds) to ~17.1 MiB/s (60
seconds).

(It needs more work to not break TxEnd interrupt handling and verify
the locking and such.)


Index: linux-2.6.26-rc9/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.26-rc9.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.26-rc9/drivers/net/mv643xx_eth.c
@@ -59,7 +59,6 @@ static char mv643xx_eth_driver_version[]
 
 #define MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #define MV643XX_ETH_NAPI
-#define MV643XX_ETH_TX_FAST_REFILL
 
 #ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
@@ -96,7 +95,6 @@ static char mv643xx_eth_driver_version[]
 #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
 #define TX_BW_BURST(p)			(0x045c + ((p) << 10))
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
-#define  INT_TX_END			0x07f80000
 #define  INT_RX				0x0007fbfc
 #define  INT_EXT			0x00000002
 #define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
@@ -349,7 +347,7 @@ struct mv643xx_eth_private {
 	int rx_desc_sram_size;
 	u8 rxq_mask;
 	int rxq_primary;
-	struct napi_struct napi;
+	struct napi_struct rx_napi;
 	struct rx_queue rxq[8];
 
 	/*
@@ -361,10 +359,8 @@ struct mv643xx_eth_private {
 	u8 txq_mask;
 	int txq_primary;
 	u32 tx_stalls;
+	struct napi_struct tx_napi;
 	struct tx_queue txq[8];
-#ifdef MV643XX_ETH_TX_FAST_REFILL
-	int tx_clean_threshold;
-#endif
 };
 
 
@@ -439,7 +435,7 @@ static void __txq_maybe_wake(struct tx_q
 
 
 /* rx ***********************************************************************/
-static void txq_reclaim(struct tx_queue *txq, int force);
+static int txq_reclaim(struct tx_queue *txq, int force, int budget);
 
 static void rxq_refill(struct rx_queue *rxq)
 {
@@ -603,22 +599,13 @@ static int rxq_process(struct rx_queue *
 }
 
 #ifdef MV643XX_ETH_NAPI
-static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
+static int mv643xx_eth_rx_poll(struct napi_struct *napi, int budget)
 {
 	struct mv643xx_eth_private *mp;
 	int rx;
 	int i;
 
-	mp = container_of(napi, struct mv643xx_eth_private, napi);
-
-#ifdef MV643XX_ETH_TX_FAST_REFILL
-	if (++mp->tx_clean_threshold > 5) {
-		mp->tx_clean_threshold = 0;
-		for (i = 0; i < 8; i++)
-			if (mp->txq_mask & (1 << i))
-				txq_reclaim(mp->txq + i, 0);
-	}
-#endif
+	mp = container_of(napi, struct mv643xx_eth_private, rx_napi);
 
 	rx = 0;
 	for (i = 7; rx < budget && i >= 0; i--)
@@ -629,11 +616,34 @@ static int mv643xx_eth_poll(struct napi_
 		netif_rx_complete(mp->dev, napi);
 		wrl(mp, INT_CAUSE(mp->port_num), 0);
 		wrl(mp, INT_CAUSE_EXT(mp->port_num), 0);
-		wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
+		wrl(mp, INT_MASK(mp->port_num), INT_RX | INT_EXT);
 	}
 
 	return rx;
 }
+
+static int mv643xx_eth_tx_poll(struct napi_struct *napi, int budget)
+{
+	struct mv643xx_eth_private *mp;
+	int txc;
+	int i;
+
+	mp = container_of(napi, struct mv643xx_eth_private, tx_napi);
+
+	txc = 0;
+	for (i = 7; txc < budget && i >= 0; i--)
+		if (mp->txq_mask & (1 << i))
+			txc += txq_reclaim(mp->txq + i, 0, budget - txc);
+
+	if (txc < budget) {
+		netif_rx_complete(mp->dev, napi);
+		wrl(mp, INT_CAUSE_EXT(mp->port_num), 0);
+		wrl(mp, INT_MASK_EXT(mp->port_num),
+		    INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
+	}
+
+	return txc;
+}
 #endif
 
 
@@ -1615,13 +1625,15 @@ out:
 	return -ENOMEM;
 }
 
-static void txq_reclaim(struct tx_queue *txq, int force)
+static int txq_reclaim(struct tx_queue *txq, int force, int budget)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	unsigned long flags;
+	int tx;
 
 	spin_lock_irqsave(&mp->lock, flags);
-	while (txq->tx_desc_count > 0) {
+	tx = 0;
+	while (tx < budget || budget < 0) {
 		int tx_index;
 		struct tx_desc *desc;
 		u32 cmd_sts;
@@ -1629,6 +1641,9 @@ static void txq_reclaim(struct tx_queue 
 		dma_addr_t addr;
 		int count;
 
+		if (txq->tx_desc_count == 0)
+			break;
+
 		tx_index = txq->tx_used_desc;
 		desc = &txq->tx_desc_area[tx_index];
 		cmd_sts = desc->cmd_sts;
@@ -1638,6 +1653,7 @@ static void txq_reclaim(struct tx_queue 
 
 		txq->tx_used_desc = (tx_index + 1) % txq->tx_ring_size;
 		txq->tx_desc_count--;
+		tx++;
 
 		addr = desc->buf_ptr;
 		count = desc->byte_cnt;
@@ -1665,6 +1681,8 @@ static void txq_reclaim(struct tx_queue 
 		spin_lock_irqsave(&mp->lock, flags);
 	}
 	spin_unlock_irqrestore(&mp->lock, flags);
+
+	return tx;
 }
 
 static void txq_deinit(struct tx_queue *txq)
@@ -1672,7 +1690,7 @@ static void txq_deinit(struct tx_queue *
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 
 	txq_disable(txq);
-	txq_reclaim(txq, 1);
+	txq_reclaim(txq, 1, -1);
 
 	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
 
@@ -1740,10 +1758,8 @@ static irqreturn_t mv643xx_eth_irq(int i
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	u32 int_cause;
 	u32 int_cause_ext;
-	u32 txq_active;
 
-	int_cause = rdl(mp, INT_CAUSE(mp->port_num)) &
-			(INT_TX_END | INT_RX | INT_EXT);
+	int_cause = rdl(mp, INT_CAUSE(mp->port_num)) & (INT_RX | INT_EXT);
 	if (int_cause == 0)
 		return IRQ_NONE;
 
@@ -1787,7 +1803,7 @@ static irqreturn_t mv643xx_eth_irq(int i
 		wrl(mp, INT_MASK(mp->port_num), 0x00000000);
 		rdl(mp, INT_MASK(mp->port_num));
 
-		netif_rx_schedule(dev, &mp->napi);
+		netif_rx_schedule(dev, &mp->rx_napi);
 	}
 #else
 	if (int_cause & INT_RX) {
@@ -1799,11 +1815,17 @@ static irqreturn_t mv643xx_eth_irq(int i
 	}
 #endif
 
-	txq_active = rdl(mp, TXQ_COMMAND(mp->port_num));
-
 	/*
 	 * TxBuffer or TxError set for any of the 8 queues?
 	 */
+#ifdef MV643XX_ETH_NAPI
+	if (int_cause_ext & INT_EXT_TX) {
+		wrl(mp, INT_MASK_EXT(mp->port_num), INT_EXT_LINK | INT_EXT_PHY);
+		rdl(mp, INT_MASK_EXT(mp->port_num));
+
+		netif_rx_schedule(dev, &mp->tx_napi);
+	}
+#else
 	if (int_cause_ext & INT_EXT_TX) {
 		int i;
 
@@ -1811,22 +1833,7 @@ static irqreturn_t mv643xx_eth_irq(int i
 			if (mp->txq_mask & (1 << i))
 				txq_reclaim(mp->txq + i, 0);
 	}
-
-	/*
-	 * Any TxEnd interrupts?
-	 */
-	if (int_cause & INT_TX_END) {
-		int i;
-
-		wrl(mp, INT_CAUSE(mp->port_num), ~(int_cause & INT_TX_END));
-		for (i = 0; i < 8; i++) {
-			struct tx_queue *txq = mp->txq + i;
-			if (txq->tx_desc_count && !((txq_active >> i) & 1)) {
-				mp->tx_stalls++;
-				txq_enable(txq);
-			}
-		}
-	}
+#endif
 
 	/*
 	 * Enough space again in the primary TX queue for a full packet?
@@ -2020,7 +2027,8 @@ static int mv643xx_eth_open(struct net_d
 	}
 
 #ifdef MV643XX_ETH_NAPI
-	napi_enable(&mp->napi);
+	napi_enable(&mp->rx_napi);
+	napi_enable(&mp->tx_napi);
 #endif
 
 	port_start(mp);
@@ -2031,7 +2039,7 @@ static int mv643xx_eth_open(struct net_d
 	wrl(mp, INT_MASK_EXT(mp->port_num),
 	    INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
 
-	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
+	wrl(mp, INT_MASK(mp->port_num), INT_RX | INT_EXT);
 
 	return 0;
 
@@ -2077,7 +2085,8 @@ static int mv643xx_eth_stop(struct net_d
 	rdl(mp, INT_MASK(mp->port_num));
 
 #ifdef MV643XX_ETH_NAPI
-	napi_disable(&mp->napi);
+	napi_disable(&mp->tx_napi);
+	napi_disable(&mp->rx_napi);
 #endif
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
@@ -2170,7 +2179,7 @@ static void mv643xx_eth_netpoll(struct n
 
 	mv643xx_eth_irq(dev->irq, dev);
 
-	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
+	wrl(mp, INT_MASK(mp->port_num), INT_RX | INT_EXT);
 }
 #endif
 
@@ -2491,7 +2500,8 @@ static int mv643xx_eth_probe(struct plat
 
 	mp->dev = dev;
 #ifdef MV643XX_ETH_NAPI
-	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, 64);
+	netif_napi_add(dev, &mp->rx_napi, mv643xx_eth_rx_poll, 64);
+	netif_napi_add(dev, &mp->tx_napi, mv643xx_eth_tx_poll, 64);
 #endif
 
 	set_params(mp, pd);
