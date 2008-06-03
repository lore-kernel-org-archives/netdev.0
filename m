From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 27/39] mv643xx_eth: split out tx queue state
Date: Tue,  3 Jun 2008 13:02:42 +0200
Message-ID: <1212490974-23719-28-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48760 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755674AbYFCMAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:37 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split all TX queue related state into 'struct tx_queue', in
preparation for multiple TX queue support.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  510 ++++++++++++++++++++++-----------------------
 1 files changed, 254 insertions(+), 256 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 39de2db..beeadcf 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -288,38 +288,30 @@ struct rx_queue {
 	struct timer_list rx_oom;
 };
 
-struct mv643xx_eth_private {
-	struct mv643xx_eth_shared_private *shared;
-	int port_num;			/* User Ethernet port number	*/
-
-	struct mv643xx_eth_shared_private *shared_smi;
-
-	u32 tx_sram_addr;		/* Base address of tx sram area */
-	u32 tx_sram_size;		/* Size of tx sram area		*/
-
-	/* Tx/Rx rings managment indexes fields. For driver use */
-
-	/* Next available and first returning Tx resource */
-	int tx_curr_desc, tx_used_desc;
+struct tx_queue {
+	int tx_ring_size;
 
-#ifdef MV643XX_ETH_TX_FAST_REFILL
-	u32 tx_clean_threshold;
-#endif
+	int tx_desc_count;
+	int tx_curr_desc;
+	int tx_used_desc;
 
 	struct tx_desc *tx_desc_area;
 	dma_addr_t tx_desc_dma;
 	int tx_desc_area_size;
 	struct sk_buff **tx_skb;
+};
+
+struct mv643xx_eth_private {
+	struct mv643xx_eth_shared_private *shared;
+	int port_num;			/* User Ethernet port number	*/
+
+	struct mv643xx_eth_shared_private *shared_smi;
 
 	struct work_struct tx_timeout_task;
 
 	struct net_device *dev;
 	struct mib_counters mib_counters;
 	spinlock_t lock;
-	/* Size of Tx Ring per queue */
-	int tx_ring_size;
-	/* Number of tx descriptors in use */
-	int tx_desc_count;
 
 	u32 rx_int_coal;
 	u32 tx_int_coal;
@@ -333,6 +325,17 @@ struct mv643xx_eth_private {
 	int rx_desc_sram_size;
 	struct napi_struct napi;
 	struct rx_queue rxq[1];
+
+	/*
+	 * TX state.
+	 */
+	int default_tx_ring_size;
+	unsigned long tx_desc_sram_addr;
+	int tx_desc_sram_size;
+	struct tx_queue txq[1];
+#ifdef MV643XX_ETH_TX_FAST_REFILL
+	int tx_clean_threshold;
+#endif
 };
 
 
@@ -354,6 +357,11 @@ static struct mv643xx_eth_private *rxq_to_mep(struct rx_queue *rxq)
 	return container_of(rxq, struct mv643xx_eth_private, rxq[0]);
 }
 
+static struct mv643xx_eth_private *txq_to_mep(struct tx_queue *txq)
+{
+	return container_of(txq, struct mv643xx_eth_private, txq[0]);
+}
+
 static void rxq_enable(struct rx_queue *rxq)
 {
 	struct mv643xx_eth_private *mep = rxq_to_mep(rxq);
@@ -370,39 +378,33 @@ static void rxq_disable(struct rx_queue *rxq)
 		udelay(10);
 }
 
-static void mv643xx_eth_port_enable_tx(struct mv643xx_eth_private *mep,
-					unsigned int queues)
+static void txq_enable(struct tx_queue *txq)
 {
-	wrl(mep, TXQ_COMMAND(mep->port_num), queues);
+	struct mv643xx_eth_private *mep = txq_to_mep(txq);
+	wrl(mep, TXQ_COMMAND(mep->port_num), 1);
 }
 
-static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_eth_private *mep)
+static void txq_disable(struct tx_queue *txq)
 {
-	unsigned int port_num = mep->port_num;
-	u32 queues;
-
-	/* Stop Tx port activity. Check port Tx activity. */
-	queues = rdl(mep, TXQ_COMMAND(port_num)) & 0xFF;
-	if (queues) {
-		/* Issue stop command for active queues only */
-		wrl(mep, TXQ_COMMAND(port_num), (queues << 8));
-
-		/* Wait for all Tx activity to terminate. */
-		/* Check port cause register that all Tx queues are stopped */
-		while (rdl(mep, TXQ_COMMAND(port_num)) & 0xFF)
-			udelay(10);
-
-		/* Wait for Tx FIFO to empty */
-		while (rdl(mep, PORT_STATUS(port_num)) & TX_FIFO_EMPTY)
-			udelay(10);
-	}
+	struct mv643xx_eth_private *mep = txq_to_mep(txq);
+	u8 mask = 1;
 
-	return queues;
+	wrl(mep, TXQ_COMMAND(mep->port_num), mask << 8);
+	while (rdl(mep, TXQ_COMMAND(mep->port_num)) & mask)
+		udelay(10);
+}
+
+static void __txq_maybe_wake(struct tx_queue *txq)
+{
+	struct mv643xx_eth_private *mep = txq_to_mep(txq);
+
+	if (txq->tx_ring_size - txq->tx_desc_count >= MAX_DESCS_PER_SKB)
+		netif_wake_queue(mep->dev);
 }
 
 
 /* rx ***********************************************************************/
-static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev);
+static void txq_reclaim(struct tx_queue *txq, int force);
 
 static void rxq_refill(struct rx_queue *rxq)
 {
@@ -562,7 +564,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 
 #ifdef MV643XX_ETH_TX_FAST_REFILL
 	if (++mep->tx_clean_threshold > 5) {
-		mv643xx_eth_free_completed_tx_descs(mep->dev);
+		txq_reclaim(mep->txq, 0);
 		mep->tx_clean_threshold = 0;
 	}
 #endif
@@ -584,55 +586,59 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 /* tx ***********************************************************************/
 static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
 {
-	unsigned int frag;
-	skb_frag_t *fragp;
+	int frag;
 
 	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-		fragp = &skb_shinfo(skb)->frags[frag];
-		if (fragp->size <= 8 && fragp->page_offset & 0x7)
+		skb_frag_t *fragp = &skb_shinfo(skb)->frags[frag];
+		if (fragp->size <= 8 && fragp->page_offset & 7)
 			return 1;
 	}
+
 	return 0;
 }
 
-static int alloc_tx_desc_index(struct mv643xx_eth_private *mep)
+static int txq_alloc_desc_index(struct tx_queue *txq)
 {
 	int tx_desc_curr;
 
-	BUG_ON(mep->tx_desc_count >= mep->tx_ring_size);
+	BUG_ON(txq->tx_desc_count >= txq->tx_ring_size);
 
-	tx_desc_curr = mep->tx_curr_desc;
-	mep->tx_curr_desc = (tx_desc_curr + 1) % mep->tx_ring_size;
+	tx_desc_curr = txq->tx_curr_desc;
+	txq->tx_curr_desc = (tx_desc_curr + 1) % txq->tx_ring_size;
 
-	BUG_ON(mep->tx_curr_desc == mep->tx_used_desc);
+	BUG_ON(txq->tx_curr_desc == txq->tx_used_desc);
 
 	return tx_desc_curr;
 }
 
-static void tx_fill_frag_descs(struct mv643xx_eth_private *mep,
-				   struct sk_buff *skb)
+static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
+	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int frag;
-	int tx_index;
-	struct tx_desc *desc;
 
-	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-		skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
-
-		tx_index = alloc_tx_desc_index(mep);
-		desc = &mep->tx_desc_area[tx_index];
-
-		desc->cmd_sts = BUFFER_OWNED_BY_DMA;
-		/* Last Frag enables interrupt and frees the skb */
-		if (frag == (skb_shinfo(skb)->nr_frags - 1)) {
-			desc->cmd_sts |= ZERO_PADDING |
-					 TX_LAST_DESC |
-					 TX_ENABLE_INTERRUPT;
-			mep->tx_skb[tx_index] = skb;
-		} else
-			mep->tx_skb[tx_index] = NULL;
-
-		desc = &mep->tx_desc_area[tx_index];
+	for (frag = 0; frag < nr_frags; frag++) {
+		skb_frag_t *this_frag;
+		int tx_index;
+		struct tx_desc *desc;
+
+		this_frag = &skb_shinfo(skb)->frags[frag];
+		tx_index = txq_alloc_desc_index(txq);
+		desc = &txq->tx_desc_area[tx_index];
+
+		/*
+		 * The last fragment will generate an interrupt
+		 * which will free the skb on TX completion.
+		 */
+		if (frag == nr_frags - 1) {
+			desc->cmd_sts = BUFFER_OWNED_BY_DMA |
+					ZERO_PADDING | TX_LAST_DESC |
+					TX_ENABLE_INTERRUPT;
+			txq->tx_skb[tx_index] = skb;
+		} else {
+			desc->cmd_sts = BUFFER_OWNED_BY_DMA;
+			txq->tx_skb[tx_index] = NULL;
+		}
+
 		desc->l4i_chk = 0;
 		desc->byte_cnt = this_frag->size;
 		desc->buf_ptr = dma_map_page(NULL, this_frag->page,
@@ -647,29 +653,28 @@ static inline __be16 sum16_as_be(__sum16 sum)
 	return (__force __be16)sum;
 }
 
-static void tx_submit_descs_for_skb(struct mv643xx_eth_private *mep,
-					struct sk_buff *skb)
+static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
+	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int tx_index;
 	struct tx_desc *desc;
 	u32 cmd_sts;
 	int length;
-	int nr_frags = skb_shinfo(skb)->nr_frags;
 
 	cmd_sts = TX_FIRST_DESC | GEN_CRC | BUFFER_OWNED_BY_DMA;
 
-	tx_index = alloc_tx_desc_index(mep);
-	desc = &mep->tx_desc_area[tx_index];
+	tx_index = txq_alloc_desc_index(txq);
+	desc = &txq->tx_desc_area[tx_index];
 
 	if (nr_frags) {
-		tx_fill_frag_descs(mep, skb);
+		txq_submit_frag_skb(txq, skb);
 
 		length = skb_headlen(skb);
-		mep->tx_skb[tx_index] = NULL;
+		txq->tx_skb[tx_index] = NULL;
 	} else {
 		cmd_sts |= ZERO_PADDING | TX_LAST_DESC | TX_ENABLE_INTERRUPT;
 		length = skb->len;
-		mep->tx_skb[tx_index] = skb;
+		txq->tx_skb[tx_index] = skb;
 	}
 
 	desc->byte_cnt = length;
@@ -705,15 +710,16 @@ static void tx_submit_descs_for_skb(struct mv643xx_eth_private *mep,
 
 	/* ensure all descriptors are written before poking hardware */
 	wmb();
-	mv643xx_eth_port_enable_tx(mep, 1);
+	txq_enable(txq);
 
-	mep->tx_desc_count += nr_frags + 1;
+	txq->tx_desc_count += nr_frags + 1;
 }
 
 static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
+	struct tx_queue *txq;
 	unsigned long flags;
 
 	BUG_ON(netif_queue_stopped(dev));
@@ -727,19 +733,21 @@ static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_lock_irqsave(&mep->lock, flags);
 
-	if (mep->tx_ring_size - mep->tx_desc_count < MAX_DESCS_PER_SKB) {
+	txq = mep->txq;
+
+	if (txq->tx_ring_size - txq->tx_desc_count < MAX_DESCS_PER_SKB) {
 		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&mep->lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
-	tx_submit_descs_for_skb(mep, skb);
+	txq_submit_skb(txq, skb);
 	stats->tx_bytes += skb->len;
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
-	if (mep->tx_ring_size - mep->tx_desc_count < MAX_DESCS_PER_SKB)
+	if (txq->tx_ring_size - txq->tx_desc_count < MAX_DESCS_PER_SKB)
 		netif_stop_queue(dev);
 
 	spin_unlock_irqrestore(&mep->lock, flags);
@@ -1339,69 +1347,106 @@ static void rxq_deinit(struct rx_queue *rxq)
 	kfree(rxq->rx_skb);
 }
 
-static void ether_init_tx_desc_ring(struct mv643xx_eth_private *mep)
+static int txq_init(struct mv643xx_eth_private *mep)
 {
-	int tx_desc_num = mep->tx_ring_size;
-	struct tx_desc *p_tx_desc;
+	struct tx_queue *txq = mep->txq;
+	struct tx_desc *tx_desc;
+	int size;
 	int i;
 
-	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
-	p_tx_desc = (struct tx_desc *)mep->tx_desc_area;
-	for (i = 0; i < tx_desc_num; i++) {
-		p_tx_desc[i].next_desc_ptr = mep->tx_desc_dma +
-			((i + 1) % tx_desc_num) * sizeof(struct tx_desc);
+	txq->tx_ring_size = mep->default_tx_ring_size;
+
+	txq->tx_desc_count = 0;
+	txq->tx_curr_desc = 0;
+	txq->tx_used_desc = 0;
+
+	size = txq->tx_ring_size * sizeof(struct tx_desc);
+
+	if (size <= mep->tx_desc_sram_size) {
+		txq->tx_desc_area = ioremap(mep->tx_desc_sram_addr,
+						mep->tx_desc_sram_size);
+		txq->tx_desc_dma = mep->tx_desc_sram_addr;
+	} else {
+		txq->tx_desc_area = dma_alloc_coherent(NULL, size,
+							&txq->tx_desc_dma,
+							GFP_KERNEL);
+	}
+
+	if (txq->tx_desc_area == NULL) {
+		dev_printk(KERN_ERR, &mep->dev->dev,
+			   "can't allocate tx ring (%d bytes)\n", size);
+		goto out;
 	}
+	memset(txq->tx_desc_area, 0, size);
+
+	txq->tx_desc_area_size = size;
+	txq->tx_skb = kmalloc(txq->tx_ring_size * sizeof(*txq->tx_skb),
+								GFP_KERNEL);
+	if (txq->tx_skb == NULL) {
+		dev_printk(KERN_ERR, &mep->dev->dev,
+			   "can't allocate tx skb ring\n");
+		goto out_free;
+	}
+
+	tx_desc = (struct tx_desc *)txq->tx_desc_area;
+	for (i = 0; i < txq->tx_ring_size; i++) {
+		int nexti = (i + 1) % txq->tx_ring_size;
+		tx_desc[i].next_desc_ptr = txq->tx_desc_dma +
+					nexti * sizeof(struct tx_desc);
+	}
+
+	return 0;
+
 
-	mep->tx_curr_desc = 0;
-	mep->tx_used_desc = 0;
+out_free:
+	if (size <= mep->tx_desc_sram_size)
+		iounmap(txq->tx_desc_area);
+	else
+		dma_free_coherent(NULL, size,
+				  txq->tx_desc_area,
+				  txq->tx_desc_dma);
 
-	mep->tx_desc_area_size = tx_desc_num * sizeof(struct tx_desc);
+out:
+	return -ENOMEM;
 }
 
-static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
+static void txq_reclaim(struct tx_queue *txq, int force)
 {
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	struct tx_desc *desc;
-	u32 cmd_sts;
-	struct sk_buff *skb;
+	struct mv643xx_eth_private *mep = txq_to_mep(txq);
 	unsigned long flags;
-	int tx_index;
-	dma_addr_t addr;
-	int count;
-	int released = 0;
 
-	while (mep->tx_desc_count > 0) {
-		spin_lock_irqsave(&mep->lock, flags);
-
-		/* tx_desc_count might have changed before acquiring the lock */
-		if (mep->tx_desc_count <= 0) {
-			spin_unlock_irqrestore(&mep->lock, flags);
-			return released;
-		}
+	spin_lock_irqsave(&mep->lock, flags);
+	while (txq->tx_desc_count > 0) {
+		int tx_index;
+		struct tx_desc *desc;
+		u32 cmd_sts;
+		struct sk_buff *skb;
+		dma_addr_t addr;
+		int count;
 
-		tx_index = mep->tx_used_desc;
-		desc = &mep->tx_desc_area[tx_index];
+		tx_index = txq->tx_used_desc;
+		desc = &txq->tx_desc_area[tx_index];
 		cmd_sts = desc->cmd_sts;
 
-		if (!force && (cmd_sts & BUFFER_OWNED_BY_DMA)) {
-			spin_unlock_irqrestore(&mep->lock, flags);
-			return released;
-		}
+		if (!force && (cmd_sts & BUFFER_OWNED_BY_DMA))
+			break;
 
-		mep->tx_used_desc = (tx_index + 1) % mep->tx_ring_size;
-		mep->tx_desc_count--;
+		txq->tx_used_desc = (tx_index + 1) % txq->tx_ring_size;
+		txq->tx_desc_count--;
 
 		addr = desc->buf_ptr;
 		count = desc->byte_cnt;
-		skb = mep->tx_skb[tx_index];
-		if (skb)
-			mep->tx_skb[tx_index] = NULL;
+		skb = txq->tx_skb[tx_index];
+		txq->tx_skb[tx_index] = NULL;
 
 		if (cmd_sts & ERROR_SUMMARY) {
-			printk("%s: Error in TX\n", dev->name);
-			dev->stats.tx_errors++;
+			dev_printk(KERN_INFO, &mep->dev->dev, "tx error\n");
+			mep->dev->stats.tx_errors++;
 		}
 
+		/*
+		 * Drop mep->lock while we free the skb.
+		 */
 		spin_unlock_irqrestore(&mep->lock, flags);
 
 		if (cmd_sts & TX_FIRST_DESC)
@@ -1412,91 +1457,68 @@ static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 		if (skb)
 			dev_kfree_skb_irq(skb);
 
-		released = 1;
+		spin_lock_irqsave(&mep->lock, flags);
 	}
-
-	return released;
-}
-
-static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev)
-{
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
-
-	if (mv643xx_eth_free_tx_descs(dev, 0) &&
-	    mep->tx_ring_size - mep->tx_desc_count >= MAX_DESCS_PER_SKB)
-		netif_wake_queue(dev);
-}
-
-static void mv643xx_eth_free_all_tx_descs(struct net_device *dev)
-{
-	mv643xx_eth_free_tx_descs(dev, 1);
+	spin_unlock_irqrestore(&mep->lock, flags);
 }
 
-static void mv643xx_eth_free_tx_rings(struct net_device *dev)
+static void txq_deinit(struct tx_queue *txq)
 {
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
-
-	/* Stop Tx Queues */
-	mv643xx_eth_port_disable_tx(mep);
+	struct mv643xx_eth_private *mep = txq_to_mep(txq);
 
-	/* Free outstanding skb's on TX ring */
-	mv643xx_eth_free_all_tx_descs(dev);
+	txq_disable(txq);
+	txq_reclaim(txq, 1);
 
-	BUG_ON(mep->tx_used_desc != mep->tx_curr_desc);
+	BUG_ON(txq->tx_used_desc != txq->tx_curr_desc);
 
-	/* Free TX ring */
-	if (mep->tx_sram_size)
-		iounmap(mep->tx_desc_area);
+	if (txq->tx_desc_area_size <= mep->tx_desc_sram_size)
+		iounmap(txq->tx_desc_area);
 	else
-		dma_free_coherent(NULL, mep->tx_desc_area_size,
-				mep->tx_desc_area, mep->tx_desc_dma);
+		dma_free_coherent(NULL, txq->tx_desc_area_size,
+				  txq->tx_desc_area, txq->tx_desc_dma);
+
+	kfree(txq->tx_skb);
 }
 
 
 /* netdev ops and related ***************************************************/
 static void port_reset(struct mv643xx_eth_private *mep);
 
-static void mv643xx_eth_update_pscr(struct net_device *dev,
+static void mv643xx_eth_update_pscr(struct mv643xx_eth_private *mep,
 				    struct ethtool_cmd *ecmd)
 {
-	struct mv643xx_eth_private *mep = netdev_priv(dev);
-	int port_num = mep->port_num;
-	u32 o_pscr, n_pscr;
-	unsigned int queues;
+	u32 pscr_o;
+	u32 pscr_n;
 
-	o_pscr = rdl(mep, PORT_SERIAL_CONTROL(port_num));
-	n_pscr = o_pscr;
+	pscr_o = rdl(mep, PORT_SERIAL_CONTROL(mep->port_num));
 
 	/* clear speed, duplex and rx buffer size fields */
-	n_pscr &= ~(SET_MII_SPEED_TO_100  |
-		   SET_GMII_SPEED_TO_1000 |
-		   SET_FULL_DUPLEX_MODE   |
-		   MAX_RX_PACKET_MASK);
-
-	if (ecmd->duplex == DUPLEX_FULL)
-		n_pscr |= SET_FULL_DUPLEX_MODE;
+	pscr_n = pscr_o & ~(SET_MII_SPEED_TO_100   |
+			    SET_GMII_SPEED_TO_1000 |
+			    SET_FULL_DUPLEX_MODE   |
+			    MAX_RX_PACKET_MASK);
 
-	if (ecmd->speed == SPEED_1000)
-		n_pscr |= SET_GMII_SPEED_TO_1000 |
-			  MAX_RX_PACKET_9700BYTE;
-	else {
+	if (ecmd->speed == SPEED_1000) {
+		pscr_n |= SET_GMII_SPEED_TO_1000 | MAX_RX_PACKET_9700BYTE;
+	} else {
 		if (ecmd->speed == SPEED_100)
-			n_pscr |= SET_MII_SPEED_TO_100;
-		n_pscr |= MAX_RX_PACKET_1522BYTE;
+			pscr_n |= SET_MII_SPEED_TO_100;
+		pscr_n |= MAX_RX_PACKET_1522BYTE;
 	}
 
-	if (n_pscr != o_pscr) {
-		if ((o_pscr & SERIAL_PORT_ENABLE) == 0)
-			wrl(mep, PORT_SERIAL_CONTROL(port_num), n_pscr);
+	if (ecmd->duplex == DUPLEX_FULL)
+		pscr_n |= SET_FULL_DUPLEX_MODE;
+
+	if (pscr_n != pscr_o) {
+		if ((pscr_o & SERIAL_PORT_ENABLE) == 0)
+			wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr_n);
 		else {
-			queues = mv643xx_eth_port_disable_tx(mep);
-
-			o_pscr &= ~SERIAL_PORT_ENABLE;
-			wrl(mep, PORT_SERIAL_CONTROL(port_num), o_pscr);
-			wrl(mep, PORT_SERIAL_CONTROL(port_num), n_pscr);
-			wrl(mep, PORT_SERIAL_CONTROL(port_num), n_pscr);
-			if (queues)
-				mv643xx_eth_port_enable_tx(mep, queues);
+			txq_disable(mep->txq);
+			pscr_o &= ~SERIAL_PORT_ENABLE;
+			wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr_o);
+			wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr_n);
+			wrl(mep, PORT_SERIAL_CONTROL(mep->port_num), pscr_n);
+			txq_enable(mep->txq);
 		}
 	}
 }
@@ -1506,29 +1528,26 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	u32 int_cause, int_cause_ext = 0;
-	unsigned int port_num = mep->port_num;
 
 	/* Read interrupt cause registers */
-	int_cause = rdl(mep, INT_CAUSE(port_num)) & (INT_RX | INT_EXT);
+	int_cause = rdl(mep, INT_CAUSE(mep->port_num)) & (INT_RX | INT_EXT);
 	if (int_cause & INT_EXT) {
-		int_cause_ext = rdl(mep, INT_CAUSE_EXT(port_num))
+		int_cause_ext = rdl(mep, INT_CAUSE_EXT(mep->port_num))
 				& (INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
-		wrl(mep, INT_CAUSE_EXT(port_num), ~int_cause_ext);
+		wrl(mep, INT_CAUSE_EXT(mep->port_num), ~int_cause_ext);
 	}
 
 	/* PHY status changed */
 	if (int_cause_ext & (INT_EXT_LINK | INT_EXT_PHY)) {
-		struct ethtool_cmd cmd;
-
 		if (mii_link_ok(&mep->mii)) {
+			struct ethtool_cmd cmd;
+
 			mii_ethtool_gset(&mep->mii, &cmd);
-			mv643xx_eth_update_pscr(dev, &cmd);
-			mv643xx_eth_port_enable_tx(mep, 1);
+			mv643xx_eth_update_pscr(mep, &cmd);
+			txq_enable(mep->txq);
 			if (!netif_carrier_ok(dev)) {
 				netif_carrier_on(dev);
-				if (mep->tx_ring_size - mep->tx_desc_count >=
-							MAX_DESCS_PER_SKB)
-					netif_wake_queue(dev);
+				__txq_maybe_wake(mep->txq);
 			}
 		} else if (netif_carrier_ok(dev)) {
 			netif_stop_queue(dev);
@@ -1539,10 +1558,10 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 #ifdef MV643XX_ETH_NAPI
 	if (int_cause & INT_RX) {
 		/* schedule the NAPI poll routine to maintain port */
-		wrl(mep, INT_MASK(port_num), 0x00000000);
+		wrl(mep, INT_MASK(mep->port_num), 0x00000000);
 
 		/* wait for previous write to complete */
-		rdl(mep, INT_MASK(port_num));
+		rdl(mep, INT_MASK(mep->port_num));
 
 		netif_rx_schedule(dev, &mep->napi);
 	}
@@ -1550,8 +1569,10 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	if (int_cause & INT_RX)
 		rxq_process(mep->rxq, INT_MAX);
 #endif
-	if (int_cause_ext & INT_EXT_TX)
-		mv643xx_eth_free_completed_tx_descs(dev);
+	if (int_cause_ext & INT_EXT_TX) {
+		txq_reclaim(mep->txq, 0);
+		__txq_maybe_wake(mep->txq);
+	}
 
 	/*
 	 * If no real interrupt occured, exit.
@@ -1607,6 +1628,20 @@ static void port_start(struct net_device *dev)
 	phy_reset(mep);
 	mv643xx_eth_set_settings(dev, &ethtool_cmd);
 
+	/*
+	 * Configure TX path and queues.
+	 */
+	wrl(mep, TX_BW_MTU(mep->port_num), 0);
+	for (i = 0; i < 1; i++) {
+		struct tx_queue *txq = mep->txq;
+		int off = TXQ_CURRENT_DESC_PTR(mep->port_num);
+		u32 addr;
+
+		addr = (u32)txq->tx_desc_dma;
+		addr += txq->tx_curr_desc * sizeof(struct tx_desc);
+		wrl(mep, off, addr);
+	}
+
 	/* Add the assigned Ethernet address to the port's address table */
 	uc_addr_set(mep, dev->dev_addr);
 
@@ -1635,13 +1670,6 @@ static void port_start(struct net_device *dev)
 
 		rxq_enable(rxq);
 	}
-
-
-	wrl(mep, TXQ_CURRENT_DESC_PTR(mep->port_num),
-		(u32)((struct tx_desc *)mep->tx_desc_dma + mep->tx_curr_desc));
-
-	/* Disable port bandwidth limits by clearing MTU register */
-	wrl(mep, TX_BW_MTU(mep->port_num), 0);
 }
 
 #ifdef MV643XX_ETH_COAL
@@ -1683,7 +1711,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	unsigned int port_num = mep->port_num;
-	unsigned int size;
 	int err;
 
 	/* Clear any pending ethernet port interrupts */
@@ -1706,38 +1733,9 @@ static int mv643xx_eth_open(struct net_device *dev)
 		goto out_free_irq;
 	rxq_refill(mep->rxq);
 
-	mep->tx_skb = kmalloc(sizeof(*mep->tx_skb) * mep->tx_ring_size,
-								GFP_KERNEL);
-	if (!mep->tx_skb) {
-		printk(KERN_ERR "%s: Cannot allocate Tx skb ring\n", dev->name);
-		err = -ENOMEM;
+	err = txq_init(mep);
+	if (err)
 		goto out_free_rx_skb;
-	}
-
-	/* Allocate TX ring */
-	mep->tx_desc_count = 0;
-	size = mep->tx_ring_size * sizeof(struct tx_desc);
-	mep->tx_desc_area_size = size;
-
-	if (mep->tx_sram_size) {
-		mep->tx_desc_area = ioremap(mep->tx_sram_addr,
-							mep->tx_sram_size);
-		mep->tx_desc_dma = mep->tx_sram_addr;
-	} else
-		mep->tx_desc_area = dma_alloc_coherent(NULL, size,
-							&mep->tx_desc_dma,
-							GFP_KERNEL);
-
-	if (!mep->tx_desc_area) {
-		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
-							dev->name, size);
-		err = -ENOMEM;
-		goto out_free_tx_skb;
-	}
-	BUG_ON((u32) mep->tx_desc_area & 0xf);	/* check 16-byte alignment */
-	memset((void *)mep->tx_desc_area, 0, mep->tx_desc_area_size);
-
-	ether_init_tx_desc_ring(mep);
 
 #ifdef MV643XX_ETH_NAPI
 	napi_enable(&mep->napi);
@@ -1761,8 +1759,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	return 0;
 
-out_free_tx_skb:
-	kfree(mep->tx_skb);
+
 out_free_rx_skb:
 	rxq_deinit(mep->rxq);
 out_free_irq:
@@ -1776,8 +1773,10 @@ static void port_reset(struct mv643xx_eth_private *mep)
 	unsigned int port_num = mep->port_num;
 	unsigned int reg_data;
 
-	mv643xx_eth_port_disable_tx(mep);
+	txq_disable(mep->txq);
 	rxq_disable(mep->rxq);
+	while (!(rdl(mep, PORT_STATUS(mep->port_num)) & TX_FIFO_EMPTY))
+		udelay(10);
 
 	/* Clear all MIB counters */
 	clear_mib_counters(mep);
@@ -1808,7 +1807,7 @@ static int mv643xx_eth_stop(struct net_device *dev)
 
 	port_reset(mep);
 
-	mv643xx_eth_free_tx_rings(dev);
+	txq_deinit(mep->txq);
 	rxq_deinit(mep->rxq);
 
 	free_irq(dev->irq, dev);
@@ -1861,8 +1860,7 @@ static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
 	port_reset(mep);
 	port_start(dev);
 
-	if (mep->tx_ring_size - mep->tx_desc_count >= MAX_DESCS_PER_SKB)
-		netif_wake_queue(dev);
+	__txq_maybe_wake(mep->txq);
 }
 
 static void mv643xx_eth_tx_timeout(struct net_device *dev)
@@ -2162,7 +2160,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	/* set default config values */
 	uc_addr_get(mep, dev->dev_addr);
-	mep->tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 
 	if (is_valid_ether_addr(pd->mac_addr))
 		memcpy(dev->dev_addr, pd->mac_addr, 6);
@@ -2174,12 +2171,13 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	if (pd->rx_queue_size)
 		mep->default_rx_ring_size = pd->rx_queue_size;
 
+	mep->default_tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 	if (pd->tx_queue_size)
-		mep->tx_ring_size = pd->tx_queue_size;
+		mep->default_tx_ring_size = pd->tx_queue_size;
 
 	if (pd->tx_sram_size) {
-		mep->tx_sram_size = pd->tx_sram_size;
-		mep->tx_sram_addr = pd->tx_sram_addr;
+		mep->tx_desc_sram_size = pd->tx_sram_size;
+		mep->tx_desc_sram_addr = pd->tx_sram_addr;
 	}
 
 	if (pd->rx_sram_size) {
@@ -2208,7 +2206,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	phy_reset(mep);
 	mep->mii.supports_gmii = mii_check_gmii_support(&mep->mii);
 	mv643xx_init_ethtool_cmd(dev, mep->mii.phy_id, speed, duplex, &cmd);
-	mv643xx_eth_update_pscr(dev, &cmd);
+	mv643xx_eth_update_pscr(mep, &cmd);
 	mv643xx_eth_set_settings(dev, &cmd);
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -2241,7 +2239,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	printk(KERN_NOTICE "%s: RX NAPI Enabled \n", dev->name);
 #endif
 
-	if (mep->tx_sram_size > 0)
+	if (mep->tx_desc_sram_size > 0)
 		printk(KERN_NOTICE "%s: Using SRAM\n", dev->name);
 
 	return 0;
-- 
1.5.3.4

