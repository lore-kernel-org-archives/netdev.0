From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 26/39] mv643xx_eth: split out rx queue state
Date: Tue,  3 Jun 2008 13:02:41 +0200
Message-ID: <1212490974-23719-27-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48752 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754768AbYFCMAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:38 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split all RX queue related state into 'struct rx_queue', in
preparation for multiple RX queue support.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  441 +++++++++++++++++++++++----------------------
 1 files changed, 225 insertions(+), 216 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index beb4cf9..39de2db 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -65,13 +65,7 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define MAX_DESCS_PER_SKB	1
 #endif
 
-#define ETH_VLAN_HLEN		4
-#define ETH_FCS_LEN		4
-#define ETH_HW_IP_ALIGN		2		/* hw aligns IP header */
-#define ETH_WRAPPER_LEN		(ETH_HW_IP_ALIGN + ETH_HLEN + \
-					ETH_VLAN_HLEN + ETH_FCS_LEN)
-#define ETH_RX_SKB_SIZE		(dev->mtu + ETH_WRAPPER_LEN + \
-					dma_get_cache_alignment())
+#define ETH_HW_IP_ALIGN		2
 
 /*
  * Registers shared between all ports.
@@ -279,22 +273,32 @@ struct mib_counters {
 	u32 late_collision;
 };
 
+struct rx_queue {
+	int rx_ring_size;
+
+	int rx_desc_count;
+	int rx_curr_desc;
+	int rx_used_desc;
+
+	struct rx_desc *rx_desc_area;
+	dma_addr_t rx_desc_dma;
+	int rx_desc_area_size;
+	struct sk_buff **rx_skb;
+
+	struct timer_list rx_oom;
+};
+
 struct mv643xx_eth_private {
 	struct mv643xx_eth_shared_private *shared;
 	int port_num;			/* User Ethernet port number	*/
 
 	struct mv643xx_eth_shared_private *shared_smi;
 
-	u32 rx_sram_addr;		/* Base address of rx sram area */
-	u32 rx_sram_size;		/* Size of rx sram area		*/
 	u32 tx_sram_addr;		/* Base address of tx sram area */
 	u32 tx_sram_size;		/* Size of tx sram area		*/
 
 	/* Tx/Rx rings managment indexes fields. For driver use */
 
-	/* Next available and first returning Rx resource */
-	int rx_curr_desc, rx_used_desc;
-
 	/* Next available and first returning Tx resource */
 	int tx_curr_desc, tx_used_desc;
 
@@ -302,11 +306,6 @@ struct mv643xx_eth_private {
 	u32 tx_clean_threshold;
 #endif
 
-	struct rx_desc *rx_desc_area;
-	dma_addr_t rx_desc_dma;
-	int rx_desc_area_size;
-	struct sk_buff **rx_skb;
-
 	struct tx_desc *tx_desc_area;
 	dma_addr_t tx_desc_dma;
 	int tx_desc_area_size;
@@ -315,27 +314,25 @@ struct mv643xx_eth_private {
 	struct work_struct tx_timeout_task;
 
 	struct net_device *dev;
-	struct napi_struct napi;
 	struct mib_counters mib_counters;
 	spinlock_t lock;
 	/* Size of Tx Ring per queue */
 	int tx_ring_size;
 	/* Number of tx descriptors in use */
 	int tx_desc_count;
-	/* Size of Rx Ring per queue */
-	int rx_ring_size;
-	/* Number of rx descriptors in use */
-	int rx_desc_count;
-
-	/*
-	 * Used in case RX Ring is empty, which can be caused when
-	 * system does not have resources (skb's)
-	 */
-	struct timer_list timeout;
 
 	u32 rx_int_coal;
 	u32 tx_int_coal;
 	struct mii_if_info mii;
+
+	/*
+	 * RX state.
+	 */
+	int default_rx_ring_size;
+	unsigned long rx_desc_sram_addr;
+	int rx_desc_sram_size;
+	struct napi_struct napi;
+	struct rx_queue rxq[1];
 };
 
 
@@ -352,30 +349,25 @@ static inline void wrl(struct mv643xx_eth_private *mep, int offset, u32 data)
 
 
 /* rxq/txq helper functions *************************************************/
-static void mv643xx_eth_port_enable_rx(struct mv643xx_eth_private *mep,
-					unsigned int queues)
+static struct mv643xx_eth_private *rxq_to_mep(struct rx_queue *rxq)
 {
-	wrl(mep, RXQ_COMMAND(mep->port_num), queues);
+	return container_of(rxq, struct mv643xx_eth_private, rxq[0]);
 }
 
-static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_eth_private *mep)
+static void rxq_enable(struct rx_queue *rxq)
 {
-	unsigned int port_num = mep->port_num;
-	u32 queues;
-
-	/* Stop Rx port activity. Check port Rx activity. */
-	queues = rdl(mep, RXQ_COMMAND(port_num)) & 0xFF;
-	if (queues) {
-		/* Issue stop command for active queues only */
-		wrl(mep, RXQ_COMMAND(port_num), (queues << 8));
+	struct mv643xx_eth_private *mep = rxq_to_mep(rxq);
+	wrl(mep, RXQ_COMMAND(mep->port_num), 1);
+}
 
-		/* Wait for all Rx activity to terminate. */
-		/* Check port cause register that all Rx queues are stopped */
-		while (rdl(mep, RXQ_COMMAND(port_num)) & 0xFF)
-			udelay(10);
-	}
+static void rxq_disable(struct rx_queue *rxq)
+{
+	struct mv643xx_eth_private *mep = rxq_to_mep(rxq);
+	u8 mask = 1;
 
-	return queues;
+	wrl(mep, RXQ_COMMAND(mep->port_num), mask << 8);
+	while (rdl(mep, RXQ_COMMAND(mep->port_num)) & mask)
+		udelay(10);
 }
 
 static void mv643xx_eth_port_enable_tx(struct mv643xx_eth_private *mep,
@@ -412,19 +404,29 @@ static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_eth_private *mep)
 /* rx ***********************************************************************/
 static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev);
 
-static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
+static void rxq_refill(struct rx_queue *rxq)
 {
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = rxq_to_mep(rxq);
 	unsigned long flags;
 
 	spin_lock_irqsave(&mep->lock, flags);
 
-	while (mep->rx_desc_count < mep->rx_ring_size) {
+	while (rxq->rx_desc_count < rxq->rx_ring_size) {
+		int skb_size;
 		struct sk_buff *skb;
 		int unaligned;
 		int rx;
 
-		skb = dev_alloc_skb(ETH_RX_SKB_SIZE + dma_get_cache_alignment());
+		/*
+		 * Reserve 2+14 bytes for an ethernet header (the
+		 * hardware automatically prepends 2 bytes of dummy
+		 * data to each received packet), 4 bytes for a VLAN
+		 * header, and 4 bytes for the trailing FCS -- 24
+		 * bytes total.
+		 */
+		skb_size = mep->dev->mtu + 24;
+
+		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 1);
 		if (skb == NULL)
 			break;
 
@@ -432,44 +434,43 @@ static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
 		if (unaligned)
 			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
 
-		mep->rx_desc_count++;
-		rx = mep->rx_used_desc;
-		mep->rx_used_desc = (rx + 1) % mep->rx_ring_size;
+		rxq->rx_desc_count++;
+		rx = rxq->rx_used_desc;
+		rxq->rx_used_desc = (rx + 1) % rxq->rx_ring_size;
 
-		mep->rx_desc_area[rx].buf_ptr = dma_map_single(NULL,
-							skb->data,
-							ETH_RX_SKB_SIZE,
-							DMA_FROM_DEVICE);
-		mep->rx_desc_area[rx].buf_size = ETH_RX_SKB_SIZE;
-		mep->rx_skb[rx] = skb;
+		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, skb->data,
+						skb_size, DMA_FROM_DEVICE);
+		rxq->rx_desc_area[rx].buf_size = skb_size;
+		rxq->rx_skb[rx] = skb;
 		wmb();
-		mep->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
+		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
 						RX_ENABLE_INTERRUPT;
 		wmb();
 
 		skb_reserve(skb, ETH_HW_IP_ALIGN);
 	}
 
-	if (mep->rx_desc_count == 0) {
-		mep->timeout.expires = jiffies + (HZ / 10);
-		add_timer(&mep->timeout);
+	if (rxq->rx_desc_count == 0) {
+		rxq->rx_oom.expires = jiffies + (HZ / 10);
+		add_timer(&rxq->rx_oom);
 	}
 
 	spin_unlock_irqrestore(&mep->lock, flags);
 }
 
-static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
+static inline void rxq_refill_timer_wrapper(unsigned long data)
 {
-	mv643xx_eth_rx_refill_descs((struct net_device *)data);
+	rxq_refill((struct rx_queue *)data);
 }
 
-static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
+static int rxq_process(struct rx_queue *rxq, int budget)
 {
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
-	unsigned int received_packets = 0;
+	struct mv643xx_eth_private *mep = rxq_to_mep(rxq);
+	struct net_device_stats *stats = &mep->dev->stats;
+	int rx;
 
-	while (budget-- > 0) {
+	rx = 0;
+	while (rx < budget) {
 		struct sk_buff *skb;
 		volatile struct rx_desc *rx_desc;
 		unsigned int cmd_sts;
@@ -477,7 +478,7 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 
 		spin_lock_irqsave(&mep->lock, flags);
 
-		rx_desc = &mep->rx_desc_area[mep->rx_curr_desc];
+		rx_desc = &rxq->rx_desc_area[rxq->rx_curr_desc];
 
 		cmd_sts = rx_desc->cmd_sts;
 		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
@@ -486,17 +487,17 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 		}
 		rmb();
 
-		skb = mep->rx_skb[mep->rx_curr_desc];
-		mep->rx_skb[mep->rx_curr_desc] = NULL;
+		skb = rxq->rx_skb[rxq->rx_curr_desc];
+		rxq->rx_skb[rxq->rx_curr_desc] = NULL;
 
-		mep->rx_curr_desc = (mep->rx_curr_desc + 1) % mep->rx_ring_size;
+		rxq->rx_curr_desc = (rxq->rx_curr_desc + 1) % rxq->rx_ring_size;
 
 		spin_unlock_irqrestore(&mep->lock, flags);
 
 		dma_unmap_single(NULL, rx_desc->buf_ptr + ETH_HW_IP_ALIGN,
-					ETH_RX_SKB_SIZE, DMA_FROM_DEVICE);
-		mep->rx_desc_count--;
-		received_packets++;
+					mep->dev->mtu + 24, DMA_FROM_DEVICE);
+		rxq->rx_desc_count--;
+		rx++;
 
 		/*
 		 * Update statistics.
@@ -519,7 +520,7 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 					printk(KERN_ERR
 						"%s: Received packet spread "
 						"on multiple descriptors\n",
-						dev->name);
+						mep->dev->name);
 			}
 			if (cmd_sts & ERROR_SUMMARY)
 				stats->rx_errors++;
@@ -537,48 +538,45 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 				skb->csum = htons(
 					(cmd_sts & 0x0007fff8) >> 3);
 			}
-			skb->protocol = eth_type_trans(skb, dev);
+			skb->protocol = eth_type_trans(skb, mep->dev);
 #ifdef MV643XX_ETH_NAPI
 			netif_receive_skb(skb);
 #else
 			netif_rx(skb);
 #endif
 		}
-		dev->last_rx = jiffies;
+		mep->dev->last_rx = jiffies;
 	}
-	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
+	rxq_refill(rxq);
 
-	return received_packets;
+	return rx;
 }
 
 #ifdef MV643XX_ETH_NAPI
 static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 {
-	struct mv643xx_eth_private *mep = container_of(napi, struct mv643xx_eth_private, napi);
-	struct net_device *dev = mep->dev;
-	unsigned int port_num = mep->port_num;
-	int work_done;
+	struct mv643xx_eth_private *mep;
+	int rx;
+
+	mep = container_of(napi, struct mv643xx_eth_private, napi);
 
 #ifdef MV643XX_ETH_TX_FAST_REFILL
 	if (++mep->tx_clean_threshold > 5) {
-		mv643xx_eth_free_completed_tx_descs(dev);
+		mv643xx_eth_free_completed_tx_descs(mep->dev);
 		mep->tx_clean_threshold = 0;
 	}
 #endif
 
-	work_done = 0;
-	if ((rdl(mep, RXQ_CURRENT_DESC_PTR(port_num)))
-	    != (u32) mep->rx_used_desc)
-		work_done = mv643xx_eth_receive_queue(dev, budget);
+	rx = rxq_process(mep->rxq, budget);
 
-	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
-		wrl(mep, INT_CAUSE(port_num), 0);
-		wrl(mep, INT_CAUSE_EXT(port_num), 0);
-		wrl(mep, INT_MASK(port_num), INT_RX | INT_EXT);
+	if (rx < budget) {
+		netif_rx_complete(mep->dev, napi);
+		wrl(mep, INT_CAUSE(mep->port_num), 0);
+		wrl(mep, INT_CAUSE_EXT(mep->port_num), 0);
+		wrl(mep, INT_MASK(mep->port_num), INT_RX | INT_EXT);
 	}
 
-	return work_done;
+	return rx;
 }
 #endif
 
@@ -1243,53 +1241,102 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 
 
 /* rx/tx queue initialisation ***********************************************/
-static void ether_init_rx_desc_ring(struct mv643xx_eth_private *mep)
+static int rxq_init(struct mv643xx_eth_private *mep)
 {
-	volatile struct rx_desc *p_rx_desc;
-	int rx_desc_num = mep->rx_ring_size;
+	struct rx_queue *rxq = mep->rxq;
+	struct rx_desc *rx_desc;
+	int size;
 	int i;
 
-	/* initialize the next_desc_ptr links in the Rx descriptors ring */
-	p_rx_desc = (struct rx_desc *)mep->rx_desc_area;
-	for (i = 0; i < rx_desc_num; i++) {
-		p_rx_desc[i].next_desc_ptr = mep->rx_desc_dma +
-			((i + 1) % rx_desc_num) * sizeof(struct rx_desc);
+	rxq->rx_ring_size = mep->default_rx_ring_size;
+
+	rxq->rx_desc_count = 0;
+	rxq->rx_curr_desc = 0;
+	rxq->rx_used_desc = 0;
+
+	size = rxq->rx_ring_size * sizeof(struct rx_desc);
+
+	if (size <= mep->rx_desc_sram_size) {
+		rxq->rx_desc_area = ioremap(mep->rx_desc_sram_addr,
+						mep->rx_desc_sram_size);
+		rxq->rx_desc_dma = mep->rx_desc_sram_addr;
+	} else {
+		rxq->rx_desc_area = dma_alloc_coherent(NULL, size,
+							&rxq->rx_desc_dma,
+							GFP_KERNEL);
+	}
+
+	if (rxq->rx_desc_area == NULL) {
+		dev_printk(KERN_ERR, &mep->dev->dev,
+			   "can't allocate rx ring (%d bytes)\n", size);
+		goto out;
+	}
+	memset(rxq->rx_desc_area, 0, size);
+
+	rxq->rx_desc_area_size = size;
+	rxq->rx_skb = kmalloc(rxq->rx_ring_size * sizeof(*rxq->rx_skb),
+								GFP_KERNEL);
+	if (rxq->rx_skb == NULL) {
+		dev_printk(KERN_ERR, &mep->dev->dev,
+			   "can't allocate rx skb ring\n");
+		goto out_free;
+	}
+
+	rx_desc = (struct rx_desc *)rxq->rx_desc_area;
+	for (i = 0; i < rxq->rx_ring_size; i++) {
+		int nexti = (i + 1) % rxq->rx_ring_size;
+		rx_desc[i].next_desc_ptr = rxq->rx_desc_dma +
+					nexti * sizeof(struct rx_desc);
 	}
 
-	/* Save Rx desc pointer to driver struct. */
-	mep->rx_curr_desc = 0;
-	mep->rx_used_desc = 0;
+	init_timer(&rxq->rx_oom);
+	rxq->rx_oom.data = (unsigned long)rxq;
+	rxq->rx_oom.function = rxq_refill_timer_wrapper;
+
+	return 0;
+
+
+out_free:
+	if (size <= mep->rx_desc_sram_size)
+		iounmap(rxq->rx_desc_area);
+	else
+		dma_free_coherent(NULL, size,
+				  rxq->rx_desc_area,
+				  rxq->rx_desc_dma);
 
-	mep->rx_desc_area_size = rx_desc_num * sizeof(struct rx_desc);
+out:
+	return -ENOMEM;
 }
 
-static void mv643xx_eth_free_rx_rings(struct net_device *dev)
+static void rxq_deinit(struct rx_queue *rxq)
 {
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	int curr;
+	struct mv643xx_eth_private *mep = rxq_to_mep(rxq);
+	int i;
+
+	rxq_disable(rxq);
 
-	/* Stop RX Queues */
-	mv643xx_eth_port_disable_rx(mep);
+	del_timer_sync(&rxq->rx_oom);
 
-	/* Free preallocated skb's on RX rings */
-	for (curr = 0; mep->rx_desc_count && curr < mep->rx_ring_size; curr++) {
-		if (mep->rx_skb[curr]) {
-			dev_kfree_skb(mep->rx_skb[curr]);
-			mep->rx_desc_count--;
+	for (i = 0; i < rxq->rx_ring_size; i++) {
+		if (rxq->rx_skb[i]) {
+			dev_kfree_skb(rxq->rx_skb[i]);
+			rxq->rx_desc_count--;
 		}
 	}
 
-	if (mep->rx_desc_count)
-		printk(KERN_ERR
-			"%s: Error in freeing Rx Ring. %d skb's still"
-			" stuck in RX Ring - ignoring them\n", dev->name,
-			mep->rx_desc_count);
-	/* Free RX ring */
-	if (mep->rx_sram_size)
-		iounmap(mep->rx_desc_area);
+	if (rxq->rx_desc_count) {
+		dev_printk(KERN_ERR, &mep->dev->dev,
+			   "error freeing rx ring -- %d skbs stuck\n",
+			   rxq->rx_desc_count);
+	}
+
+	if (rxq->rx_desc_area_size <= mep->rx_desc_sram_size)
+		iounmap(rxq->rx_desc_area);
 	else
-		dma_free_coherent(NULL, mep->rx_desc_area_size,
-				mep->rx_desc_area, mep->rx_desc_dma);
+		dma_free_coherent(NULL, rxq->rx_desc_area_size,
+				  rxq->rx_desc_area, rxq->rx_desc_dma);
+
+	kfree(rxq->rx_skb);
 }
 
 static void ether_init_tx_desc_ring(struct mv643xx_eth_private *mep)
@@ -1501,7 +1548,7 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	}
 #else
 	if (int_cause & INT_RX)
-		mv643xx_eth_receive_queue(dev, INT_MAX);
+		rxq_process(mep->rxq, INT_MAX);
 #endif
 	if (int_cause_ext & INT_EXT_TX)
 		mv643xx_eth_free_completed_tx_descs(dev);
@@ -1535,20 +1582,30 @@ static void phy_reset(struct mv643xx_eth_private *mep)
 static void port_start(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	unsigned int port_num = mep->port_num;
-	int tx_curr_desc, rx_curr_desc;
 	u32 pscr;
 	struct ethtool_cmd ethtool_cmd;
+	int i;
 
-	/* Assignment of Tx CTRP of given queue */
-	tx_curr_desc = mep->tx_curr_desc;
-	wrl(mep, TXQ_CURRENT_DESC_PTR(port_num),
-		(u32)((struct tx_desc *)mep->tx_desc_dma + tx_curr_desc));
+	/*
+	 * Configure basic link parameters.
+	 */
+	pscr = rdl(mep, PORT_SERIAL_CONTROL(mep->port_num));
+	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
+	wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr);
+	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
+		DISABLE_AUTO_NEG_SPEED_GMII    |
+		DISABLE_AUTO_NEG_FOR_DUPLEX    |
+		DO_NOT_FORCE_LINK_FAIL	       |
+		SERIAL_PORT_CONTROL_RESERVED;
+	wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr);
+	pscr |= SERIAL_PORT_ENABLE;
+	wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr);
 
-	/* Assignment of Rx CRDP of given queue */
-	rx_curr_desc = mep->rx_curr_desc;
-	wrl(mep, RXQ_CURRENT_DESC_PTR(port_num),
-		(u32)((struct rx_desc *)mep->rx_desc_dma + rx_curr_desc));
+	wrl(mep, SDMA_CONFIG(mep->port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
+
+	mv643xx_eth_get_settings(dev, &ethtool_cmd);
+	phy_reset(mep);
+	mv643xx_eth_set_settings(dev, &ethtool_cmd);
 
 	/* Add the assigned Ethernet address to the port's address table */
 	uc_addr_set(mep, dev->dev_addr);
@@ -1557,42 +1614,34 @@ static void port_start(struct net_device *dev)
 	 * Receive all unmatched unicast, TCP, UDP, BPDU and broadcast
 	 * frames to RX queue #0.
 	 */
-	wrl(mep, PORT_CONFIG(port_num), 0x00000000);
+	wrl(mep, PORT_CONFIG(mep->port_num), 0x00000000);
 
 	/*
 	 * Treat BPDUs as normal multicasts, and disable partition mode.
 	 */
-	wrl(mep, PORT_CONFIG_EXT(port_num), 0x00000000);
-
-	pscr = rdl(mep, PORT_SERIAL_CONTROL(port_num));
-
-	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
-	wrl(mep, PORT_SERIAL_CONTROL(port_num), pscr);
+	wrl(mep, PORT_CONFIG_EXT(mep->port_num), 0x00000000);
 
-	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
-		DISABLE_AUTO_NEG_SPEED_GMII    |
-		DISABLE_AUTO_NEG_FOR_DUPLEX    |
-		DO_NOT_FORCE_LINK_FAIL	   |
-		SERIAL_PORT_CONTROL_RESERVED;
+	/*
+	 * Enable the receive queue.
+	 */
+	for (i = 0; i < 1; i++) {
+		struct rx_queue *rxq = mep->rxq;
+		int off = RXQ_CURRENT_DESC_PTR(mep->port_num);
+		u32 addr;
 
-	wrl(mep, PORT_SERIAL_CONTROL(port_num), pscr);
+		addr = (u32)rxq->rx_desc_dma;
+		addr += rxq->rx_curr_desc * sizeof(struct rx_desc);
+		wrl(mep, off, addr);
 
-	pscr |= SERIAL_PORT_ENABLE;
-	wrl(mep, PORT_SERIAL_CONTROL(port_num), pscr);
+		rxq_enable(rxq);
+	}
 
-	/* Assign port SDMA configuration */
-	wrl(mep, SDMA_CONFIG(port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
-	/* Enable port Rx. */
-	mv643xx_eth_port_enable_rx(mep, 1);
+	wrl(mep, TXQ_CURRENT_DESC_PTR(mep->port_num),
+		(u32)((struct tx_desc *)mep->tx_desc_dma + mep->tx_curr_desc));
 
 	/* Disable port bandwidth limits by clearing MTU register */
-	wrl(mep, TX_BW_MTU(port_num), 0);
-
-	/* save phy settings across reset */
-	mv643xx_eth_get_settings(dev, &ethtool_cmd);
-	phy_reset(mep);
-	mv643xx_eth_set_settings(dev, &ethtool_cmd);
+	wrl(mep, TX_BW_MTU(mep->port_num), 0);
 }
 
 #ifdef MV643XX_ETH_COAL
@@ -1652,18 +1701,11 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	port_init(mep);
 
-	memset(&mep->timeout, 0, sizeof(struct timer_list));
-	mep->timeout.function = mv643xx_eth_rx_refill_descs_timer_wrapper;
-	mep->timeout.data = (unsigned long)dev;
-
-	/* Allocate RX and TX skb rings */
-	mep->rx_skb = kmalloc(sizeof(*mep->rx_skb) * mep->rx_ring_size,
-								GFP_KERNEL);
-	if (!mep->rx_skb) {
-		printk(KERN_ERR "%s: Cannot allocate Rx skb ring\n", dev->name);
-		err = -ENOMEM;
+	err = rxq_init(mep);
+	if (err)
 		goto out_free_irq;
-	}
+	rxq_refill(mep->rxq);
+
 	mep->tx_skb = kmalloc(sizeof(*mep->tx_skb) * mep->tx_ring_size,
 								GFP_KERNEL);
 	if (!mep->tx_skb) {
@@ -1697,39 +1739,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	ether_init_tx_desc_ring(mep);
 
-	/* Allocate RX ring */
-	mep->rx_desc_count = 0;
-	size = mep->rx_ring_size * sizeof(struct rx_desc);
-	mep->rx_desc_area_size = size;
-
-	if (mep->rx_sram_size) {
-		mep->rx_desc_area = ioremap(mep->rx_sram_addr,
-							mep->rx_sram_size);
-		mep->rx_desc_dma = mep->rx_sram_addr;
-	} else
-		mep->rx_desc_area = dma_alloc_coherent(NULL, size,
-							&mep->rx_desc_dma,
-							GFP_KERNEL);
-
-	if (!mep->rx_desc_area) {
-		printk(KERN_ERR "%s: Cannot allocate Rx ring (size %d bytes)\n",
-							dev->name, size);
-		printk(KERN_ERR "%s: Freeing previously allocated TX queues...",
-							dev->name);
-		if (mep->rx_sram_size)
-			iounmap(mep->tx_desc_area);
-		else
-			dma_free_coherent(NULL, mep->tx_desc_area_size,
-					mep->tx_desc_area, mep->tx_desc_dma);
-		err = -ENOMEM;
-		goto out_free_tx_skb;
-	}
-	memset((void *)mep->rx_desc_area, 0, size);
-
-	ether_init_rx_desc_ring(mep);
-
-	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
-
 #ifdef MV643XX_ETH_NAPI
 	napi_enable(&mep->napi);
 #endif
@@ -1755,7 +1764,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 out_free_tx_skb:
 	kfree(mep->tx_skb);
 out_free_rx_skb:
-	kfree(mep->rx_skb);
+	rxq_deinit(mep->rxq);
 out_free_irq:
 	free_irq(dev->irq, dev);
 
@@ -1768,7 +1777,7 @@ static void port_reset(struct mv643xx_eth_private *mep)
 	unsigned int reg_data;
 
 	mv643xx_eth_port_disable_tx(mep);
-	mv643xx_eth_port_disable_rx(mep);
+	rxq_disable(mep->rxq);
 
 	/* Clear all MIB counters */
 	clear_mib_counters(mep);
@@ -1800,7 +1809,7 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	port_reset(mep);
 
 	mv643xx_eth_free_tx_rings(dev);
-	mv643xx_eth_free_rx_rings(dev);
+	rxq_deinit(mep->rxq);
 
 	free_irq(dev->irq, dev);
 
@@ -2153,7 +2162,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	/* set default config values */
 	uc_addr_get(mep, dev->dev_addr);
-	mep->rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
 	mep->tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 
 	if (is_valid_ether_addr(pd->mac_addr))
@@ -2162,8 +2170,9 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	if (pd->phy_addr || pd->force_phy_addr)
 		phy_addr_set(mep, pd->phy_addr);
 
+	mep->default_rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
 	if (pd->rx_queue_size)
-		mep->rx_ring_size = pd->rx_queue_size;
+		mep->default_rx_ring_size = pd->rx_queue_size;
 
 	if (pd->tx_queue_size)
 		mep->tx_ring_size = pd->tx_queue_size;
@@ -2174,8 +2183,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	}
 
 	if (pd->rx_sram_size) {
-		mep->rx_sram_size = pd->rx_sram_size;
-		mep->rx_sram_addr = pd->rx_sram_addr;
+		mep->rx_desc_sram_addr = pd->rx_sram_addr;
+		mep->rx_desc_sram_size = pd->rx_sram_size;
 	}
 
 	duplex = pd->duplex;
-- 
1.5.3.4

