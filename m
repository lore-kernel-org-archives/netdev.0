From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 17/39] mv643xx_eth: use 'mv643xx_eth_' prefix consistently
Date: Tue,  3 Jun 2008 13:02:32 +0200
Message-ID: <1212490974-23719-18-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48754 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756099AbYFCMAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:42 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bunch of places in the mv643xx_eth driver use the 'mv643xx_'
prefix.  Since the mv643xx is a chip that includes more than just
ethernet, this patch makes all those places use either no prefix
(for some internal-use-only functions), or the full 'mv643xx_eth_'
prefix.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c | 1169 +++++++++++++++++++++++----------------------
 1 files changed, 585 insertions(+), 584 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 4375b7c..15174b9 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -46,20 +46,20 @@
 #include <linux/mii.h>
 #include <linux/mv643xx_eth.h>
 
-static char mv643xx_driver_name[] = "mv643xx_eth";
-static char mv643xx_driver_version[] = "1.0";
+static char mv643xx_eth_driver_name[] = "mv643xx_eth";
+static char mv643xx_eth_driver_version[] = "1.0";
 
-#define MV643XX_CHECKSUM_OFFLOAD_TX
-#define MV643XX_NAPI
-#define MV643XX_TX_FAST_REFILL
-#undef	MV643XX_COAL
+#define MV643XX_ETH_CHECKSUM_OFFLOAD_TX
+#define MV643XX_ETH_NAPI
+#define MV643XX_ETH_TX_FAST_REFILL
+#undef	MV643XX_ETH_COAL
 
-#define MV643XX_TX_COAL 100
-#ifdef MV643XX_COAL
-#define MV643XX_RX_COAL 100
+#define MV643XX_ETH_TX_COAL 100
+#ifdef MV643XX_ETH_COAL
+#define MV643XX_ETH_RX_COAL 100
 #endif
 
-#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+#ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
 #else
 #define MAX_DESCS_PER_SKB	1
@@ -254,7 +254,7 @@ struct pkt_info {
 
 
 /* global *******************************************************************/
-struct mv643xx_shared_private {
+struct mv643xx_eth_shared_private {
 	void __iomem *base;
 
 	/* used to protect SMI_REG, which is shared across ports */
@@ -267,7 +267,7 @@ struct mv643xx_shared_private {
 
 
 /* per-port *****************************************************************/
-struct mv643xx_mib_counters {
+struct mib_counters {
 	u64 good_octets_received;
 	u32 bad_octets_received;
 	u32 internal_mac_transmit_err;
@@ -300,11 +300,11 @@ struct mv643xx_mib_counters {
 	u32 late_collision;
 };
 
-struct mv643xx_private {
-	struct mv643xx_shared_private *shared;
+struct mv643xx_eth_private {
+	struct mv643xx_eth_shared_private *shared;
 	int port_num;			/* User Ethernet port number	*/
 
-	struct mv643xx_shared_private *shared_smi;
+	struct mv643xx_eth_shared_private *shared_smi;
 
 	u32 rx_sram_addr;		/* Base address of rx sram area */
 	u32 rx_sram_size;		/* Size of rx sram area		*/
@@ -321,7 +321,7 @@ struct mv643xx_private {
 	/* Next available and first returning Tx resource */
 	int tx_curr_desc_q, tx_used_desc_q;
 
-#ifdef MV643XX_TX_FAST_REFILL
+#ifdef MV643XX_ETH_TX_FAST_REFILL
 	u32 tx_clean_threshold;
 #endif
 
@@ -340,7 +340,7 @@ struct mv643xx_private {
 	struct net_device *dev;
 	struct napi_struct napi;
 	struct net_device_stats stats;
-	struct mv643xx_mib_counters mib_counters;
+	struct mib_counters mib_counters;
 	spinlock_t lock;
 	/* Size of Tx Ring per queue */
 	int tx_ring_size;
@@ -364,68 +364,68 @@ struct mv643xx_private {
 
 
 /* port register accessors **************************************************/
-static inline u32 rdl(struct mv643xx_private *mp, int offset)
+static inline u32 rdl(struct mv643xx_eth_private *mep, int offset)
 {
-	return readl(mp->shared->base + offset);
+	return readl(mep->shared->base + offset);
 }
 
-static inline void wrl(struct mv643xx_private *mp, int offset, u32 data)
+static inline void wrl(struct mv643xx_eth_private *mep, int offset, u32 data)
 {
-	writel(data, mp->shared->base + offset);
+	writel(data, mep->shared->base + offset);
 }
 
 
 /* rxq/txq helper functions *************************************************/
-static void mv643xx_eth_port_enable_rx(struct mv643xx_private *mp,
+static void mv643xx_eth_port_enable_rx(struct mv643xx_eth_private *mep,
 					unsigned int queues)
 {
-	wrl(mp, RXQ_COMMAND(mp->port_num), queues);
+	wrl(mep, RXQ_COMMAND(mep->port_num), queues);
 }
 
-static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp)
+static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_eth_private *mep)
 {
-	unsigned int port_num = mp->port_num;
+	unsigned int port_num = mep->port_num;
 	u32 queues;
 
 	/* Stop Rx port activity. Check port Rx activity. */
-	queues = rdl(mp, RXQ_COMMAND(port_num)) & 0xFF;
+	queues = rdl(mep, RXQ_COMMAND(port_num)) & 0xFF;
 	if (queues) {
 		/* Issue stop command for active queues only */
-		wrl(mp, RXQ_COMMAND(port_num), (queues << 8));
+		wrl(mep, RXQ_COMMAND(port_num), (queues << 8));
 
 		/* Wait for all Rx activity to terminate. */
 		/* Check port cause register that all Rx queues are stopped */
-		while (rdl(mp, RXQ_COMMAND(port_num)) & 0xFF)
+		while (rdl(mep, RXQ_COMMAND(port_num)) & 0xFF)
 			udelay(10);
 	}
 
 	return queues;
 }
 
-static void mv643xx_eth_port_enable_tx(struct mv643xx_private *mp,
+static void mv643xx_eth_port_enable_tx(struct mv643xx_eth_private *mep,
 					unsigned int queues)
 {
-	wrl(mp, TXQ_COMMAND(mp->port_num), queues);
+	wrl(mep, TXQ_COMMAND(mep->port_num), queues);
 }
 
-static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
+static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_eth_private *mep)
 {
-	unsigned int port_num = mp->port_num;
+	unsigned int port_num = mep->port_num;
 	u32 queues;
 
 	/* Stop Tx port activity. Check port Tx activity. */
-	queues = rdl(mp, TXQ_COMMAND(port_num)) & 0xFF;
+	queues = rdl(mep, TXQ_COMMAND(port_num)) & 0xFF;
 	if (queues) {
 		/* Issue stop command for active queues only */
-		wrl(mp, TXQ_COMMAND(port_num), (queues << 8));
+		wrl(mep, TXQ_COMMAND(port_num), (queues << 8));
 
 		/* Wait for all Tx activity to terminate. */
 		/* Check port cause register that all Tx queues are stopped */
-		while (rdl(mp, TXQ_COMMAND(port_num)) & 0xFF)
+		while (rdl(mep, TXQ_COMMAND(port_num)) & 0xFF)
 			udelay(10);
 
 		/* Wait for Tx FIFO to empty */
-		while (rdl(mp, PORT_STATUS(port_num)) & TX_FIFO_EMPTY)
+		while (rdl(mep, PORT_STATUS(port_num)) & TX_FIFO_EMPTY)
 			udelay(10);
 	}
 
@@ -446,7 +446,7 @@ static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev);
  *	no available Rx resources, the function resets the resource error flag.
  *
  * INPUT:
- *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
+ *	struct mv643xx_eth_private	*mep		Ethernet Port Control srtuct.
  *	struct pkt_info		*p_pkt_info	Information on returned buffer.
  *
  * OUTPUT:
@@ -456,22 +456,22 @@ static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev);
  *	ETH_ERROR in case the routine can not access Rx desc ring.
  *	ETH_OK otherwise.
  */
-static FUNC_RET_STATUS rx_return_buff(struct mv643xx_private *mp,
+static FUNC_RET_STATUS rx_return_buff(struct mv643xx_eth_private *mep,
 						struct pkt_info *p_pkt_info)
 {
 	int used_rx_desc;	/* Where to return Rx resource */
 	volatile struct rx_desc *p_used_rx_desc;
 	unsigned long flags;
 
-	spin_lock_irqsave(&mp->lock, flags);
+	spin_lock_irqsave(&mep->lock, flags);
 
 	/* Get 'used' Rx descriptor */
-	used_rx_desc = mp->rx_used_desc_q;
-	p_used_rx_desc = &mp->p_rx_desc_area[used_rx_desc];
+	used_rx_desc = mep->rx_used_desc_q;
+	p_used_rx_desc = &mep->p_rx_desc_area[used_rx_desc];
 
 	p_used_rx_desc->buf_ptr = p_pkt_info->buf_ptr;
 	p_used_rx_desc->buf_size = p_pkt_info->byte_cnt;
-	mp->rx_skb[used_rx_desc] = p_pkt_info->return_info;
+	mep->rx_skb[used_rx_desc] = p_pkt_info->return_info;
 
 	/* Flush the write pipe */
 
@@ -481,12 +481,12 @@ static FUNC_RET_STATUS rx_return_buff(struct mv643xx_private *mp,
 	wmb();
 
 	/* Move the used descriptor pointer to the next descriptor */
-	mp->rx_used_desc_q = (used_rx_desc + 1) % mp->rx_ring_size;
+	mep->rx_used_desc_q = (used_rx_desc + 1) % mep->rx_ring_size;
 
 	/* Any Rx return cancels the Rx resource error status */
-	mp->rx_resource_err = 0;
+	mep->rx_resource_err = 0;
 
-	spin_unlock_irqrestore(&mp->lock, flags);
+	spin_unlock_irqrestore(&mep->lock, flags);
 
 	return ETH_OK;
 }
@@ -501,16 +501,16 @@ static FUNC_RET_STATUS rx_return_buff(struct mv643xx_private *mp,
  */
 static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	struct pkt_info pkt_info;
 	struct sk_buff *skb;
 	int unaligned;
 
-	while (mp->rx_desc_count < mp->rx_ring_size) {
+	while (mep->rx_desc_count < mep->rx_ring_size) {
 		skb = dev_alloc_skb(ETH_RX_SKB_SIZE + dma_get_cache_alignment());
 		if (!skb)
 			break;
-		mp->rx_desc_count++;
+		mep->rx_desc_count++;
 		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
 		if (unaligned)
 			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
@@ -519,7 +519,7 @@ static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
 		pkt_info.buf_ptr = dma_map_single(NULL, skb->data,
 					ETH_RX_SKB_SIZE, DMA_FROM_DEVICE);
 		pkt_info.return_info = skb;
-		if (rx_return_buff(mp, &pkt_info) != ETH_OK) {
+		if (rx_return_buff(mep, &pkt_info) != ETH_OK) {
 			printk(KERN_ERR
 				"%s: Error allocating RX Ring\n", dev->name);
 			break;
@@ -530,10 +530,10 @@ static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
 	 * If RX ring is empty of SKB, set a timer to try allocating
 	 * again at a later time.
 	 */
-	if (mp->rx_desc_count == 0) {
+	if (mep->rx_desc_count == 0) {
 		printk(KERN_INFO "%s: Rx ring is empty\n", dev->name);
-		mp->timeout.expires = jiffies + (HZ / 10);	/* 100 mSec */
-		add_timer(&mp->timeout);
+		mep->timeout.expires = jiffies + (HZ / 10);	/* 100 mSec */
+		add_timer(&mep->timeout);
 	}
 }
 
@@ -563,7 +563,7 @@ static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
  *	is set.
  *
  * INPUT:
- *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
+ *	struct mv643xx_eth_private	*mep		Ethernet Port Control srtuct.
  *	struct pkt_info		*p_pkt_info	User packet buffer.
  *
  * OUTPUT:
@@ -575,7 +575,7 @@ static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
  *	ETH_END_OF_JOB if there is no received data.
  *	ETH_OK otherwise.
  */
-static FUNC_RET_STATUS port_receive(struct mv643xx_private *mp,
+static FUNC_RET_STATUS port_receive(struct mv643xx_eth_private *mep,
 						struct pkt_info *p_pkt_info)
 {
 	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
@@ -584,16 +584,16 @@ static FUNC_RET_STATUS port_receive(struct mv643xx_private *mp,
 	unsigned long flags;
 
 	/* Do not process Rx ring in case of Rx ring resource error */
-	if (mp->rx_resource_err)
+	if (mep->rx_resource_err)
 		return ETH_QUEUE_FULL;
 
-	spin_lock_irqsave(&mp->lock, flags);
+	spin_lock_irqsave(&mep->lock, flags);
 
 	/* Get the Rx Desc ring 'curr and 'used' indexes */
-	rx_curr_desc = mp->rx_curr_desc_q;
-	rx_used_desc = mp->rx_used_desc_q;
+	rx_curr_desc = mep->rx_curr_desc_q;
+	rx_used_desc = mep->rx_used_desc_q;
 
-	p_rx_desc = &mp->p_rx_desc_area[rx_curr_desc];
+	p_rx_desc = &mep->p_rx_desc_area[rx_curr_desc];
 
 	/* The following parameters are used to save readings from memory */
 	command_status = p_rx_desc->cmd_sts;
@@ -601,31 +601,31 @@ static FUNC_RET_STATUS port_receive(struct mv643xx_private *mp,
 
 	/* Nothing to receive... */
 	if (command_status & BUFFER_OWNED_BY_DMA) {
-		spin_unlock_irqrestore(&mp->lock, flags);
+		spin_unlock_irqrestore(&mep->lock, flags);
 		return ETH_END_OF_JOB;
 	}
 
 	p_pkt_info->byte_cnt = p_rx_desc->byte_cnt - ETH_HW_IP_ALIGN;
 	p_pkt_info->cmd_sts = command_status;
 	p_pkt_info->buf_ptr = p_rx_desc->buf_ptr + ETH_HW_IP_ALIGN;
-	p_pkt_info->return_info = mp->rx_skb[rx_curr_desc];
+	p_pkt_info->return_info = mep->rx_skb[rx_curr_desc];
 	p_pkt_info->l4i_chk = p_rx_desc->buf_size;
 
 	/*
 	 * Clean the return info field to indicate that the
 	 * packet has been moved to the upper layers
 	 */
-	mp->rx_skb[rx_curr_desc] = NULL;
+	mep->rx_skb[rx_curr_desc] = NULL;
 
 	/* Update current index in data structure */
-	rx_next_curr_desc = (rx_curr_desc + 1) % mp->rx_ring_size;
-	mp->rx_curr_desc_q = rx_next_curr_desc;
+	rx_next_curr_desc = (rx_curr_desc + 1) % mep->rx_ring_size;
+	mep->rx_curr_desc_q = rx_next_curr_desc;
 
 	/* Rx descriptors exhausted. Set the Rx ring resource error flag */
 	if (rx_next_curr_desc == rx_used_desc)
-		mp->rx_resource_err = 1;
+		mep->rx_resource_err = 1;
 
-	spin_unlock_irqrestore(&mp->lock, flags);
+	spin_unlock_irqrestore(&mep->lock, flags);
 
 	return ETH_OK;
 }
@@ -643,16 +643,16 @@ static FUNC_RET_STATUS port_receive(struct mv643xx_private *mp,
  */
 static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 	unsigned int received_packets = 0;
 	struct sk_buff *skb;
 	struct pkt_info pkt_info;
 
-	while (budget-- > 0 && port_receive(mp, &pkt_info) == ETH_OK) {
+	while (budget-- > 0 && port_receive(mep, &pkt_info) == ETH_OK) {
 		dma_unmap_single(NULL, pkt_info.buf_ptr, ETH_RX_SKB_SIZE,
 							DMA_FROM_DEVICE);
-		mp->rx_desc_count--;
+		mep->rx_desc_count--;
 		received_packets++;
 
 		/*
@@ -696,7 +696,7 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 					(pkt_info.cmd_sts & 0x0007fff8) >> 3);
 			}
 			skb->protocol = eth_type_trans(skb, dev);
-#ifdef MV643XX_NAPI
+#ifdef MV643XX_ETH_NAPI
 			netif_receive_skb(skb);
 #else
 			netif_rx(skb);
@@ -709,36 +709,36 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 	return received_packets;
 }
 
-#ifdef MV643XX_NAPI
+#ifdef MV643XX_ETH_NAPI
 /*
- * mv643xx_poll
+ * mv643xx_eth_poll
  *
  * This function is used in case of NAPI
  */
-static int mv643xx_poll(struct napi_struct *napi, int budget)
+static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 {
-	struct mv643xx_private *mp = container_of(napi, struct mv643xx_private, napi);
-	struct net_device *dev = mp->dev;
-	unsigned int port_num = mp->port_num;
+	struct mv643xx_eth_private *mep = container_of(napi, struct mv643xx_eth_private, napi);
+	struct net_device *dev = mep->dev;
+	unsigned int port_num = mep->port_num;
 	int work_done;
 
-#ifdef MV643XX_TX_FAST_REFILL
-	if (++mp->tx_clean_threshold > 5) {
+#ifdef MV643XX_ETH_TX_FAST_REFILL
+	if (++mep->tx_clean_threshold > 5) {
 		mv643xx_eth_free_completed_tx_descs(dev);
-		mp->tx_clean_threshold = 0;
+		mep->tx_clean_threshold = 0;
 	}
 #endif
 
 	work_done = 0;
-	if ((rdl(mp, RXQ_CURRENT_DESC_PTR(port_num)))
-	    != (u32) mp->rx_used_desc_q)
+	if ((rdl(mep, RXQ_CURRENT_DESC_PTR(port_num)))
+	    != (u32) mep->rx_used_desc_q)
 		work_done = mv643xx_eth_receive_queue(dev, budget);
 
 	if (work_done < budget) {
 		netif_rx_complete(dev, napi);
-		wrl(mp, INT_CAUSE(port_num), 0);
-		wrl(mp, INT_CAUSE_EXT(port_num), 0);
-		wrl(mp, INT_MASK(port_num), INT_RX | INT_EXT);
+		wrl(mep, INT_CAUSE(port_num), 0);
+		wrl(mep, INT_CAUSE_EXT(port_num), 0);
+		wrl(mep, INT_MASK(port_num), INT_RX | INT_EXT);
 	}
 
 	return work_done;
@@ -770,16 +770,16 @@ static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
 /**
  * alloc_tx_desc_index - return the index of the next available tx desc
  */
-static int alloc_tx_desc_index(struct mv643xx_private *mp)
+static int alloc_tx_desc_index(struct mv643xx_eth_private *mep)
 {
 	int tx_desc_curr;
 
-	BUG_ON(mp->tx_desc_count >= mp->tx_ring_size);
+	BUG_ON(mep->tx_desc_count >= mep->tx_ring_size);
 
-	tx_desc_curr = mp->tx_curr_desc_q;
-	mp->tx_curr_desc_q = (tx_desc_curr + 1) % mp->tx_ring_size;
+	tx_desc_curr = mep->tx_curr_desc_q;
+	mep->tx_curr_desc_q = (tx_desc_curr + 1) % mep->tx_ring_size;
 
-	BUG_ON(mp->tx_curr_desc_q == mp->tx_used_desc_q);
+	BUG_ON(mep->tx_curr_desc_q == mep->tx_used_desc_q);
 
 	return tx_desc_curr;
 }
@@ -790,7 +790,7 @@ static int alloc_tx_desc_index(struct mv643xx_private *mp)
  * Ensure the data for each fragment to be transmitted is mapped properly,
  * then fill in descriptors in the tx hw queue.
  */
-static void tx_fill_frag_descs(struct mv643xx_private *mp,
+static void tx_fill_frag_descs(struct mv643xx_eth_private *mep,
 				   struct sk_buff *skb)
 {
 	int frag;
@@ -800,8 +800,8 @@ static void tx_fill_frag_descs(struct mv643xx_private *mp,
 	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
 		skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
 
-		tx_index = alloc_tx_desc_index(mp);
-		desc = &mp->p_tx_desc_area[tx_index];
+		tx_index = alloc_tx_desc_index(mep);
+		desc = &mep->p_tx_desc_area[tx_index];
 
 		desc->cmd_sts = BUFFER_OWNED_BY_DMA;
 		/* Last Frag enables interrupt and frees the skb */
@@ -809,11 +809,11 @@ static void tx_fill_frag_descs(struct mv643xx_private *mp,
 			desc->cmd_sts |= ZERO_PADDING |
 					 TX_LAST_DESC |
 					 TX_ENABLE_INTERRUPT;
-			mp->tx_skb[tx_index] = skb;
+			mep->tx_skb[tx_index] = skb;
 		} else
-			mp->tx_skb[tx_index] = NULL;
+			mep->tx_skb[tx_index] = NULL;
 
-		desc = &mp->p_tx_desc_area[tx_index];
+		desc = &mep->p_tx_desc_area[tx_index];
 		desc->l4i_chk = 0;
 		desc->byte_cnt = this_frag->size;
 		desc->buf_ptr = dma_map_page(NULL, this_frag->page,
@@ -834,7 +834,7 @@ static inline __be16 sum16_as_be(__sum16 sum)
  * Ensure the data for an skb to be transmitted is mapped properly,
  * then fill in descriptors in the tx hw queue and start the hardware.
  */
-static void tx_submit_descs_for_skb(struct mv643xx_private *mp,
+static void tx_submit_descs_for_skb(struct mv643xx_eth_private *mep,
 					struct sk_buff *skb)
 {
 	int tx_index;
@@ -845,18 +845,18 @@ static void tx_submit_descs_for_skb(struct mv643xx_private *mp,
 
 	cmd_sts = TX_FIRST_DESC | GEN_CRC | BUFFER_OWNED_BY_DMA;
 
-	tx_index = alloc_tx_desc_index(mp);
-	desc = &mp->p_tx_desc_area[tx_index];
+	tx_index = alloc_tx_desc_index(mep);
+	desc = &mep->p_tx_desc_area[tx_index];
 
 	if (nr_frags) {
-		tx_fill_frag_descs(mp, skb);
+		tx_fill_frag_descs(mep, skb);
 
 		length = skb_headlen(skb);
-		mp->tx_skb[tx_index] = NULL;
+		mep->tx_skb[tx_index] = NULL;
 	} else {
 		cmd_sts |= ZERO_PADDING | TX_LAST_DESC | TX_ENABLE_INTERRUPT;
 		length = skb->len;
-		mp->tx_skb[tx_index] = skb;
+		mep->tx_skb[tx_index] = skb;
 	}
 
 	desc->byte_cnt = length;
@@ -892,9 +892,9 @@ static void tx_submit_descs_for_skb(struct mv643xx_private *mp,
 
 	/* ensure all descriptors are written before poking hardware */
 	wmb();
-	mv643xx_eth_port_enable_tx(mp, 1);
+	mv643xx_eth_port_enable_tx(mep, 1);
 
-	mp->tx_desc_count += nr_frags + 1;
+	mep->tx_desc_count += nr_frags + 1;
 }
 
 /**
@@ -903,7 +903,7 @@ static void tx_submit_descs_for_skb(struct mv643xx_private *mp,
  */
 static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 	unsigned long flags;
 
@@ -916,31 +916,31 @@ static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	spin_lock_irqsave(&mp->lock, flags);
+	spin_lock_irqsave(&mep->lock, flags);
 
-	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB) {
+	if (mep->tx_ring_size - mep->tx_desc_count < MAX_DESCS_PER_SKB) {
 		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
 		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&mp->lock, flags);
+		spin_unlock_irqrestore(&mep->lock, flags);
 		return NETDEV_TX_BUSY;
 	}
 
-	tx_submit_descs_for_skb(mp, skb);
+	tx_submit_descs_for_skb(mep, skb);
 	stats->tx_bytes += skb->len;
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
-	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB)
+	if (mep->tx_ring_size - mep->tx_desc_count < MAX_DESCS_PER_SKB)
 		netif_stop_queue(dev);
 
-	spin_unlock_irqrestore(&mp->lock, flags);
+	spin_unlock_irqrestore(&mep->lock, flags);
 
 	return NETDEV_TX_OK;
 }
 
 
 /* mii management interface *************************************************/
-static int phy_addr_get(struct mv643xx_private *mp);
+static int phy_addr_get(struct mv643xx_eth_private *mep);
 
 /*
  * read_smi_reg - Read PHY registers
@@ -950,7 +950,7 @@ static int phy_addr_get(struct mv643xx_private *mp);
  *	order to perform PHY register read.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
+ *	struct mv643xx_eth_private *mep	Ethernet Port.
  *	unsigned int	phy_reg		PHY register address offset.
  *	unsigned int	*value		Register value buffer.
  *
@@ -962,21 +962,21 @@ static int phy_addr_get(struct mv643xx_private *mp);
  *	true otherwise.
  *
  */
-static void read_smi_reg(struct mv643xx_private *mp,
+static void read_smi_reg(struct mv643xx_eth_private *mep,
 				unsigned int phy_reg, unsigned int *value)
 {
-	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
-	int phy_addr = phy_addr_get(mp);
+	void __iomem *smi_reg = mep->shared_smi->base + SMI_REG;
+	int phy_addr = phy_addr_get(mep);
 	unsigned long flags;
 	int i;
 
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
+	spin_lock_irqsave(&mep->shared_smi->phy_lock, flags);
 
 	/* wait for the SMI register to become available */
 	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
 		if (i == 1000) {
-			printk("%s: PHY busy timeout\n", mp->dev->name);
+			printk("%s: PHY busy timeout\n", mep->dev->name);
 			goto out;
 		}
 		udelay(10);
@@ -987,7 +987,7 @@ static void read_smi_reg(struct mv643xx_private *mp,
 	/* now wait for the data to be valid */
 	for (i = 0; !(readl(smi_reg) & SMI_READ_VALID); i++) {
 		if (i == 1000) {
-			printk("%s: PHY read timeout\n", mp->dev->name);
+			printk("%s: PHY read timeout\n", mep->dev->name);
 			goto out;
 		}
 		udelay(10);
@@ -995,7 +995,7 @@ static void read_smi_reg(struct mv643xx_private *mp,
 
 	*value = readl(smi_reg) & 0xffff;
 out:
-	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
+	spin_unlock_irqrestore(&mep->shared_smi->phy_lock, flags);
 }
 
 /*
@@ -1006,7 +1006,7 @@ out:
  *	order to perform writes to PHY registers.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
+ *	struct mv643xx_eth_private *mep	Ethernet Port.
  *	unsigned int	phy_reg		PHY register address offset.
  *	unsigned int	value		Register value.
  *
@@ -1018,21 +1018,21 @@ out:
  *	true otherwise.
  *
  */
-static void write_smi_reg(struct mv643xx_private *mp,
+static void write_smi_reg(struct mv643xx_eth_private *mep,
 				   unsigned int phy_reg, unsigned int value)
 {
-	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
-	int phy_addr = phy_addr_get(mp);
+	void __iomem *smi_reg = mep->shared_smi->base + SMI_REG;
+	int phy_addr = phy_addr_get(mep);
 	unsigned long flags;
 	int i;
 
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
+	spin_lock_irqsave(&mep->shared_smi->phy_lock, flags);
 
 	/* wait for the SMI register to become available */
 	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
 		if (i == 1000) {
-			printk("%s: PHY busy timeout\n", mp->dev->name);
+			printk("%s: PHY busy timeout\n", mep->dev->name);
 			goto out;
 		}
 		udelay(10);
@@ -1041,7 +1041,7 @@ static void write_smi_reg(struct mv643xx_private *mp,
 	writel((phy_addr << 16) | (phy_reg << 21) |
 		SMI_OPCODE_WRITE | (value & 0xffff), smi_reg);
 out:
-	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
+	spin_unlock_irqrestore(&mep->shared_smi->phy_lock, flags);
 }
 
 
@@ -1054,7 +1054,7 @@ out:
  *	A read from the MIB counter will reset the counter.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
+ *	struct mv643xx_eth_private *mep	Ethernet Port.
  *
  * OUTPUT:
  *	After reading all MIB counters, the counters resets.
@@ -1063,121 +1063,121 @@ out:
  *	MIB counter value.
  *
  */
-static void clear_mib_counters(struct mv643xx_private *mp)
+static void clear_mib_counters(struct mv643xx_eth_private *mep)
 {
-	unsigned int port_num = mp->port_num;
+	unsigned int port_num = mep->port_num;
 	int i;
 
 	/* Perform dummy reads from MIB counters */
 	for (i = 0; i < 0x80; i += 4)
-		rdl(mp, MIB_COUNTERS(port_num) + i);
-}
-
-static inline u32 read_mib(struct mv643xx_private *mp, int offset)
-{
-	return rdl(mp, MIB_COUNTERS(mp->port_num) + offset);
-}
-
-static void update_mib_counters(struct mv643xx_private *mp)
-{
-	struct mv643xx_mib_counters *p = &mp->mib_counters;
-
-	p->good_octets_received += read_mib(mp, 0x00);
-	p->good_octets_received += (u64)read_mib(mp, 0x04) << 32;
-	p->bad_octets_received += read_mib(mp, 0x08);
-	p->internal_mac_transmit_err += read_mib(mp, 0x0c);
-	p->good_frames_received += read_mib(mp, 0x10);
-	p->bad_frames_received += read_mib(mp, 0x14);
-	p->broadcast_frames_received += read_mib(mp, 0x18);
-	p->multicast_frames_received += read_mib(mp, 0x1c);
-	p->frames_64_octets += read_mib(mp, 0x20);
-	p->frames_65_to_127_octets += read_mib(mp, 0x24);
-	p->frames_128_to_255_octets += read_mib(mp, 0x28);
-	p->frames_256_to_511_octets += read_mib(mp, 0x2c);
-	p->frames_512_to_1023_octets += read_mib(mp, 0x30);
-	p->frames_1024_to_max_octets += read_mib(mp, 0x34);
-	p->good_octets_sent += read_mib(mp, 0x38);
-	p->good_octets_sent += (u64)read_mib(mp, 0x3c) << 32;
-	p->good_frames_sent += read_mib(mp, 0x40);
-	p->excessive_collision += read_mib(mp, 0x44);
-	p->multicast_frames_sent += read_mib(mp, 0x48);
-	p->broadcast_frames_sent += read_mib(mp, 0x4c);
-	p->unrec_mac_control_received += read_mib(mp, 0x50);
-	p->fc_sent += read_mib(mp, 0x54);
-	p->good_fc_received += read_mib(mp, 0x58);
-	p->bad_fc_received += read_mib(mp, 0x5c);
-	p->undersize_received += read_mib(mp, 0x60);
-	p->fragments_received += read_mib(mp, 0x64);
-	p->oversize_received += read_mib(mp, 0x68);
-	p->jabber_received += read_mib(mp, 0x6c);
-	p->mac_receive_error += read_mib(mp, 0x70);
-	p->bad_crc_event += read_mib(mp, 0x74);
-	p->collision += read_mib(mp, 0x78);
-	p->late_collision += read_mib(mp, 0x7c);
+		rdl(mep, MIB_COUNTERS(port_num) + i);
+}
+
+static inline u32 read_mib(struct mv643xx_eth_private *mep, int offset)
+{
+	return rdl(mep, MIB_COUNTERS(mep->port_num) + offset);
+}
+
+static void update_mib_counters(struct mv643xx_eth_private *mep)
+{
+	struct mib_counters *p = &mep->mib_counters;
+
+	p->good_octets_received += read_mib(mep, 0x00);
+	p->good_octets_received += (u64)read_mib(mep, 0x04) << 32;
+	p->bad_octets_received += read_mib(mep, 0x08);
+	p->internal_mac_transmit_err += read_mib(mep, 0x0c);
+	p->good_frames_received += read_mib(mep, 0x10);
+	p->bad_frames_received += read_mib(mep, 0x14);
+	p->broadcast_frames_received += read_mib(mep, 0x18);
+	p->multicast_frames_received += read_mib(mep, 0x1c);
+	p->frames_64_octets += read_mib(mep, 0x20);
+	p->frames_65_to_127_octets += read_mib(mep, 0x24);
+	p->frames_128_to_255_octets += read_mib(mep, 0x28);
+	p->frames_256_to_511_octets += read_mib(mep, 0x2c);
+	p->frames_512_to_1023_octets += read_mib(mep, 0x30);
+	p->frames_1024_to_max_octets += read_mib(mep, 0x34);
+	p->good_octets_sent += read_mib(mep, 0x38);
+	p->good_octets_sent += (u64)read_mib(mep, 0x3c) << 32;
+	p->good_frames_sent += read_mib(mep, 0x40);
+	p->excessive_collision += read_mib(mep, 0x44);
+	p->multicast_frames_sent += read_mib(mep, 0x48);
+	p->broadcast_frames_sent += read_mib(mep, 0x4c);
+	p->unrec_mac_control_received += read_mib(mep, 0x50);
+	p->fc_sent += read_mib(mep, 0x54);
+	p->good_fc_received += read_mib(mep, 0x58);
+	p->bad_fc_received += read_mib(mep, 0x5c);
+	p->undersize_received += read_mib(mep, 0x60);
+	p->fragments_received += read_mib(mep, 0x64);
+	p->oversize_received += read_mib(mep, 0x68);
+	p->jabber_received += read_mib(mep, 0x6c);
+	p->mac_receive_error += read_mib(mep, 0x70);
+	p->bad_crc_event += read_mib(mep, 0x74);
+	p->collision += read_mib(mep, 0x78);
+	p->late_collision += read_mib(mep, 0x7c);
 }
 
 
 /* ethtool ******************************************************************/
-struct mv643xx_stats {
+struct mv643xx_eth_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int sizeof_stat;
 	int stat_offset;
 };
 
-#define MV643XX_STAT(m) FIELD_SIZEOF(struct mv643xx_private, m), \
-					offsetof(struct mv643xx_private, m)
-
-static const struct mv643xx_stats mv643xx_gstrings_stats[] = {
-	{ "rx_packets", MV643XX_STAT(stats.rx_packets) },
-	{ "tx_packets", MV643XX_STAT(stats.tx_packets) },
-	{ "rx_bytes", MV643XX_STAT(stats.rx_bytes) },
-	{ "tx_bytes", MV643XX_STAT(stats.tx_bytes) },
-	{ "rx_errors", MV643XX_STAT(stats.rx_errors) },
-	{ "tx_errors", MV643XX_STAT(stats.tx_errors) },
-	{ "rx_dropped", MV643XX_STAT(stats.rx_dropped) },
-	{ "tx_dropped", MV643XX_STAT(stats.tx_dropped) },
-	{ "good_octets_received", MV643XX_STAT(mib_counters.good_octets_received) },
-	{ "bad_octets_received", MV643XX_STAT(mib_counters.bad_octets_received) },
-	{ "internal_mac_transmit_err", MV643XX_STAT(mib_counters.internal_mac_transmit_err) },
-	{ "good_frames_received", MV643XX_STAT(mib_counters.good_frames_received) },
-	{ "bad_frames_received", MV643XX_STAT(mib_counters.bad_frames_received) },
-	{ "broadcast_frames_received", MV643XX_STAT(mib_counters.broadcast_frames_received) },
-	{ "multicast_frames_received", MV643XX_STAT(mib_counters.multicast_frames_received) },
-	{ "frames_64_octets", MV643XX_STAT(mib_counters.frames_64_octets) },
-	{ "frames_65_to_127_octets", MV643XX_STAT(mib_counters.frames_65_to_127_octets) },
-	{ "frames_128_to_255_octets", MV643XX_STAT(mib_counters.frames_128_to_255_octets) },
-	{ "frames_256_to_511_octets", MV643XX_STAT(mib_counters.frames_256_to_511_octets) },
-	{ "frames_512_to_1023_octets", MV643XX_STAT(mib_counters.frames_512_to_1023_octets) },
-	{ "frames_1024_to_max_octets", MV643XX_STAT(mib_counters.frames_1024_to_max_octets) },
-	{ "good_octets_sent", MV643XX_STAT(mib_counters.good_octets_sent) },
-	{ "good_frames_sent", MV643XX_STAT(mib_counters.good_frames_sent) },
-	{ "excessive_collision", MV643XX_STAT(mib_counters.excessive_collision) },
-	{ "multicast_frames_sent", MV643XX_STAT(mib_counters.multicast_frames_sent) },
-	{ "broadcast_frames_sent", MV643XX_STAT(mib_counters.broadcast_frames_sent) },
-	{ "unrec_mac_control_received", MV643XX_STAT(mib_counters.unrec_mac_control_received) },
-	{ "fc_sent", MV643XX_STAT(mib_counters.fc_sent) },
-	{ "good_fc_received", MV643XX_STAT(mib_counters.good_fc_received) },
-	{ "bad_fc_received", MV643XX_STAT(mib_counters.bad_fc_received) },
-	{ "undersize_received", MV643XX_STAT(mib_counters.undersize_received) },
-	{ "fragments_received", MV643XX_STAT(mib_counters.fragments_received) },
-	{ "oversize_received", MV643XX_STAT(mib_counters.oversize_received) },
-	{ "jabber_received", MV643XX_STAT(mib_counters.jabber_received) },
-	{ "mac_receive_error", MV643XX_STAT(mib_counters.mac_receive_error) },
-	{ "bad_crc_event", MV643XX_STAT(mib_counters.bad_crc_event) },
-	{ "collision", MV643XX_STAT(mib_counters.collision) },
-	{ "late_collision", MV643XX_STAT(mib_counters.late_collision) },
+#define MV643XX_ETH_STAT(m) FIELD_SIZEOF(struct mv643xx_eth_private, m), \
+					offsetof(struct mv643xx_eth_private, m)
+
+static const struct mv643xx_eth_stats mv643xx_eth_gstrings_stats[] = {
+	{ "rx_packets", MV643XX_ETH_STAT(stats.rx_packets) },
+	{ "tx_packets", MV643XX_ETH_STAT(stats.tx_packets) },
+	{ "rx_bytes", MV643XX_ETH_STAT(stats.rx_bytes) },
+	{ "tx_bytes", MV643XX_ETH_STAT(stats.tx_bytes) },
+	{ "rx_errors", MV643XX_ETH_STAT(stats.rx_errors) },
+	{ "tx_errors", MV643XX_ETH_STAT(stats.tx_errors) },
+	{ "rx_dropped", MV643XX_ETH_STAT(stats.rx_dropped) },
+	{ "tx_dropped", MV643XX_ETH_STAT(stats.tx_dropped) },
+	{ "good_octets_received", MV643XX_ETH_STAT(mib_counters.good_octets_received) },
+	{ "bad_octets_received", MV643XX_ETH_STAT(mib_counters.bad_octets_received) },
+	{ "internal_mac_transmit_err", MV643XX_ETH_STAT(mib_counters.internal_mac_transmit_err) },
+	{ "good_frames_received", MV643XX_ETH_STAT(mib_counters.good_frames_received) },
+	{ "bad_frames_received", MV643XX_ETH_STAT(mib_counters.bad_frames_received) },
+	{ "broadcast_frames_received", MV643XX_ETH_STAT(mib_counters.broadcast_frames_received) },
+	{ "multicast_frames_received", MV643XX_ETH_STAT(mib_counters.multicast_frames_received) },
+	{ "frames_64_octets", MV643XX_ETH_STAT(mib_counters.frames_64_octets) },
+	{ "frames_65_to_127_octets", MV643XX_ETH_STAT(mib_counters.frames_65_to_127_octets) },
+	{ "frames_128_to_255_octets", MV643XX_ETH_STAT(mib_counters.frames_128_to_255_octets) },
+	{ "frames_256_to_511_octets", MV643XX_ETH_STAT(mib_counters.frames_256_to_511_octets) },
+	{ "frames_512_to_1023_octets", MV643XX_ETH_STAT(mib_counters.frames_512_to_1023_octets) },
+	{ "frames_1024_to_max_octets", MV643XX_ETH_STAT(mib_counters.frames_1024_to_max_octets) },
+	{ "good_octets_sent", MV643XX_ETH_STAT(mib_counters.good_octets_sent) },
+	{ "good_frames_sent", MV643XX_ETH_STAT(mib_counters.good_frames_sent) },
+	{ "excessive_collision", MV643XX_ETH_STAT(mib_counters.excessive_collision) },
+	{ "multicast_frames_sent", MV643XX_ETH_STAT(mib_counters.multicast_frames_sent) },
+	{ "broadcast_frames_sent", MV643XX_ETH_STAT(mib_counters.broadcast_frames_sent) },
+	{ "unrec_mac_control_received", MV643XX_ETH_STAT(mib_counters.unrec_mac_control_received) },
+	{ "fc_sent", MV643XX_ETH_STAT(mib_counters.fc_sent) },
+	{ "good_fc_received", MV643XX_ETH_STAT(mib_counters.good_fc_received) },
+	{ "bad_fc_received", MV643XX_ETH_STAT(mib_counters.bad_fc_received) },
+	{ "undersize_received", MV643XX_ETH_STAT(mib_counters.undersize_received) },
+	{ "fragments_received", MV643XX_ETH_STAT(mib_counters.fragments_received) },
+	{ "oversize_received", MV643XX_ETH_STAT(mib_counters.oversize_received) },
+	{ "jabber_received", MV643XX_ETH_STAT(mib_counters.jabber_received) },
+	{ "mac_receive_error", MV643XX_ETH_STAT(mib_counters.mac_receive_error) },
+	{ "bad_crc_event", MV643XX_ETH_STAT(mib_counters.bad_crc_event) },
+	{ "collision", MV643XX_ETH_STAT(mib_counters.collision) },
+	{ "late_collision", MV643XX_ETH_STAT(mib_counters.late_collision) },
 };
 
-#define MV643XX_STATS_LEN	ARRAY_SIZE(mv643xx_gstrings_stats)
+#define MV643XX_ETH_STATS_LEN	ARRAY_SIZE(mv643xx_eth_gstrings_stats)
 
-static int mv643xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int mv643xx_eth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	int err;
 
-	spin_lock_irq(&mp->lock);
-	err = mii_ethtool_gset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
+	spin_lock_irq(&mep->lock);
+	err = mii_ethtool_gset(&mep->mii, cmd);
+	spin_unlock_irq(&mep->lock);
 
 	/* The PHY may support 1000baseT_Half, but the mv643xx does not */
 	cmd->supported &= ~SUPPORTED_1000baseT_Half;
@@ -1186,92 +1186,92 @@ static int mv643xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return err;
 }
 
-static int mv643xx_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int mv643xx_eth_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	int err;
 
-	spin_lock_irq(&mp->lock);
-	err = mii_ethtool_sset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
+	spin_lock_irq(&mep->lock);
+	err = mii_ethtool_sset(&mep->mii, cmd);
+	spin_unlock_irq(&mep->lock);
 
 	return err;
 }
 
-static void mv643xx_get_drvinfo(struct net_device *netdev,
+static void mv643xx_eth_get_drvinfo(struct net_device *netdev,
 				struct ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver,  mv643xx_driver_name, 32);
-	strncpy(drvinfo->version, mv643xx_driver_version, 32);
+	strncpy(drvinfo->driver,  mv643xx_eth_driver_name, 32);
+	strncpy(drvinfo->version, mv643xx_eth_driver_version, 32);
 	strncpy(drvinfo->fw_version, "N/A", 32);
 	strncpy(drvinfo->bus_info, "mv643xx", 32);
-	drvinfo->n_stats = MV643XX_STATS_LEN;
+	drvinfo->n_stats = MV643XX_ETH_STATS_LEN;
 }
 
 static int mv643xx_eth_nway_restart(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
-	return mii_nway_restart(&mp->mii);
+	return mii_nway_restart(&mep->mii);
 }
 
 static u32 mv643xx_eth_get_link(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
-	return mii_link_ok(&mp->mii);
+	return mii_link_ok(&mep->mii);
 }
 
-static void mv643xx_get_strings(struct net_device *netdev, uint32_t stringset,
+static void mv643xx_eth_get_strings(struct net_device *netdev, uint32_t stringset,
 				uint8_t *data)
 {
 	int i;
 
 	switch(stringset) {
 	case ETH_SS_STATS:
-		for (i=0; i < MV643XX_STATS_LEN; i++) {
+		for (i=0; i < MV643XX_ETH_STATS_LEN; i++) {
 			memcpy(data + i * ETH_GSTRING_LEN,
-					mv643xx_gstrings_stats[i].stat_string,
-					ETH_GSTRING_LEN);
+				mv643xx_eth_gstrings_stats[i].stat_string,
+				ETH_GSTRING_LEN);
 		}
 		break;
 	}
 }
 
-static void mv643xx_get_ethtool_stats(struct net_device *netdev,
+static void mv643xx_eth_get_ethtool_stats(struct net_device *netdev,
 				struct ethtool_stats *stats, uint64_t *data)
 {
-	struct mv643xx_private *mp = netdev->priv;
+	struct mv643xx_eth_private *mep = netdev->priv;
 	int i;
 
-	update_mib_counters(mp);
+	update_mib_counters(mep);
 
-	for (i = 0; i < MV643XX_STATS_LEN; i++) {
-		char *p = (char *)mp+mv643xx_gstrings_stats[i].stat_offset;
-		data[i] = (mv643xx_gstrings_stats[i].sizeof_stat ==
+	for (i = 0; i < MV643XX_ETH_STATS_LEN; i++) {
+		char *p = (char *)mep+mv643xx_eth_gstrings_stats[i].stat_offset;
+		data[i] = (mv643xx_eth_gstrings_stats[i].sizeof_stat ==
 			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
 	}
 }
 
-static int mv643xx_get_sset_count(struct net_device *netdev, int sset)
+static int mv643xx_eth_get_sset_count(struct net_device *netdev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_STATS:
-		return MV643XX_STATS_LEN;
+		return MV643XX_ETH_STATS_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
 }
 
-static const struct ethtool_ops mv643xx_ethtool_ops = {
-	.get_settings           = mv643xx_get_settings,
-	.set_settings           = mv643xx_set_settings,
-	.get_drvinfo            = mv643xx_get_drvinfo,
+static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
+	.get_settings           = mv643xx_eth_get_settings,
+	.set_settings           = mv643xx_eth_set_settings,
+	.get_drvinfo            = mv643xx_eth_get_drvinfo,
 	.get_link               = mv643xx_eth_get_link,
 	.set_sg			= ethtool_op_set_sg,
-	.get_sset_count		= mv643xx_get_sset_count,
-	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
-	.get_strings            = mv643xx_get_strings,
+	.get_sset_count		= mv643xx_eth_get_sset_count,
+	.get_ethtool_stats      = mv643xx_eth_get_ethtool_stats,
+	.get_strings            = mv643xx_eth_get_strings,
 	.nway_reset		= mv643xx_eth_nway_restart,
 };
 
@@ -1280,14 +1280,14 @@ static const struct ethtool_ops mv643xx_ethtool_ops = {
 /*
  * uc_addr_get - Read the MAC address from the port's hw registers
  */
-static void uc_addr_get(struct mv643xx_private *mp, unsigned char *p_addr)
+static void uc_addr_get(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 {
-	unsigned int port_num = mp->port_num;
+	unsigned int port_num = mep->port_num;
 	unsigned int mac_h;
 	unsigned int mac_l;
 
-	mac_h = rdl(mp, MAC_ADDR_HIGH(port_num));
-	mac_l = rdl(mp, MAC_ADDR_LOW(port_num));
+	mac_h = rdl(mep, MAC_ADDR_HIGH(port_num));
+	mac_l = rdl(mep, MAC_ADDR_LOW(port_num));
 
 	p_addr[0] = (mac_h >> 24) & 0xff;
 	p_addr[1] = (mac_h >> 16) & 0xff;
@@ -1305,7 +1305,7 @@ static void uc_addr_get(struct mv643xx_private *mp, unsigned char *p_addr)
  *	Other Multicast) and set each entry to 0.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
+ *	struct mv643xx_eth_private *mep	Ethernet Port.
  *
  * OUTPUT:
  *	Multicast and Unicast packets are rejected.
@@ -1313,20 +1313,20 @@ static void uc_addr_get(struct mv643xx_private *mp, unsigned char *p_addr)
  * RETURN:
  *	None.
  */
-static void init_mac_tables(struct mv643xx_private *mp)
+static void init_mac_tables(struct mv643xx_eth_private *mep)
 {
-	unsigned int port_num = mp->port_num;
+	unsigned int port_num = mep->port_num;
 	int table_index;
 
 	/* Clear DA filter unicast table (Ex_dFUT) */
 	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		wrl(mp, UNICAST_TABLE(port_num) + table_index, 0);
+		wrl(mep, UNICAST_TABLE(port_num) + table_index, 0);
 
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mp, SPECIAL_MCAST_TABLE(port_num) + table_index, 0);
+		wrl(mep, SPECIAL_MCAST_TABLE(port_num) + table_index, 0);
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mp, OTHER_MCAST_TABLE(port_num) + table_index, 0);
+		wrl(mep, OTHER_MCAST_TABLE(port_num) + table_index, 0);
 	}
 }
 
@@ -1339,7 +1339,7 @@ static void init_mac_tables(struct mv643xx_private *mp)
  *	3-1	Queue			(ETH_Q0=0)
  *	7-4	Reserved = 0;
  */
-static void set_filter_table_entry(struct mv643xx_private *mp,
+static void set_filter_table_entry(struct mv643xx_eth_private *mep,
 					    int table, unsigned char entry)
 {
 	unsigned int table_reg;
@@ -1350,17 +1350,17 @@ static void set_filter_table_entry(struct mv643xx_private *mp,
 	reg_offset = entry % 4;		/* Entry offset within the register */
 
 	/* Set "accepts frame bit" at specified table entry */
-	table_reg = rdl(mp, table + tbl_offset);
+	table_reg = rdl(mep, table + tbl_offset);
 	table_reg |= 0x01 << (8 * reg_offset);
-	wrl(mp, table + tbl_offset, table_reg);
+	wrl(mep, table + tbl_offset, table_reg);
 }
 
 /*
  * uc_addr_set - Write a MAC address into the port's hw registers
  */
-static void uc_addr_set(struct mv643xx_private *mp, unsigned char *p_addr)
+static void uc_addr_set(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 {
-	unsigned int port_num = mp->port_num;
+	unsigned int port_num = mep->port_num;
 	unsigned int mac_h;
 	unsigned int mac_l;
 	int table;
@@ -1369,12 +1369,12 @@ static void uc_addr_set(struct mv643xx_private *mp, unsigned char *p_addr)
 	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
 							(p_addr[3] << 0);
 
-	wrl(mp, MAC_ADDR_LOW(port_num), mac_l);
-	wrl(mp, MAC_ADDR_HIGH(port_num), mac_h);
+	wrl(mep, MAC_ADDR_LOW(port_num), mac_l);
+	wrl(mep, MAC_ADDR_HIGH(port_num), mac_h);
 
 	/* Accept frames with this address */
 	table = UNICAST_TABLE(port_num);
-	set_filter_table_entry(mp, table, p_addr[5] & 0x0f);
+	set_filter_table_entry(mep, table, p_addr[5] & 0x0f);
 }
 
 /*
@@ -1387,10 +1387,10 @@ static void uc_addr_set(struct mv643xx_private *mp, unsigned char *p_addr)
  */
 static void mv643xx_eth_update_mac_address(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
-	init_mac_tables(mp);
-	uc_addr_set(mp, dev->dev_addr);
+	init_mac_tables(mep);
+	uc_addr_set(mep, dev->dev_addr);
 }
 
 /*
@@ -1429,9 +1429,9 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
  * In either case, set_filter_table_entry() is then called
  * to set to set the actual table entry.
  */
-static void mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
+static void mc_addr(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 {
-	unsigned int port_num = mp->port_num;
+	unsigned int port_num = mep->port_num;
 	unsigned int mac_h;
 	unsigned int mac_l;
 	unsigned char crc_result = 0;
@@ -1443,7 +1443,7 @@ static void mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
 	if ((p_addr[0] == 0x01) && (p_addr[1] == 0x00) &&
 	    (p_addr[2] == 0x5E) && (p_addr[3] == 0x00) && (p_addr[4] == 0x00)) {
 		table = SPECIAL_MCAST_TABLE(port_num);
-		set_filter_table_entry(mp, table, p_addr[5]);
+		set_filter_table_entry(mep, table, p_addr[5]);
 		return;
 	}
 
@@ -1516,7 +1516,7 @@ static void mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
 		crc_result = crc_result | (crc[i] << i);
 
 	table = OTHER_MCAST_TABLE(port_num);
-	set_filter_table_entry(mp, table, crc_result);
+	set_filter_table_entry(mep, table, crc_result);
 }
 
 /*
@@ -1528,8 +1528,8 @@ static void set_multicast_list(struct net_device *dev)
 	struct dev_mc_list	*mc_list;
 	int			i;
 	int			table_index;
-	struct mv643xx_private	*mp = netdev_priv(dev);
-	unsigned int		port_num = mp->port_num;
+	struct mv643xx_eth_private	*mep = netdev_priv(dev);
+	unsigned int		port_num = mep->port_num;
 
 	/* If the device is in promiscuous mode or in all multicast mode,
 	 * we will fully populate both multicast tables with accept.
@@ -1545,7 +1545,7 @@ static void set_multicast_list(struct net_device *dev)
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			wrl(mp, SPECIAL_MCAST_TABLE(port_num) + table_index, 0x01010101);
+			wrl(mep, SPECIAL_MCAST_TABLE(port_num) + table_index, 0x01010101);
 
 			/* Set all entries in DA filter other multicast
 			 * table (Ex_dFOMT)
@@ -1555,7 +1555,7 @@ static void set_multicast_list(struct net_device *dev)
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			wrl(mp, OTHER_MCAST_TABLE(port_num) + table_index, 0x01010101);
+			wrl(mep, OTHER_MCAST_TABLE(port_num) + table_index, 0x01010101);
 		}
 		return;
 	}
@@ -1565,10 +1565,10 @@ static void set_multicast_list(struct net_device *dev)
 	 */
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mp, SPECIAL_MCAST_TABLE(port_num) + table_index, 0);
+		wrl(mep, SPECIAL_MCAST_TABLE(port_num) + table_index, 0);
 
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mp, OTHER_MCAST_TABLE(port_num) + table_index, 0);
+		wrl(mep, OTHER_MCAST_TABLE(port_num) + table_index, 0);
 	}
 
 	/* Get pointer to net_device multicast list and add each one... */
@@ -1576,7 +1576,7 @@ static void set_multicast_list(struct net_device *dev)
 			(i < 256) && (mc_list != NULL) && (i < dev->mc_count);
 			i++, mc_list = mc_list->next)
 		if (mc_list->dmi_addrlen == 6)
-			mc_addr(mp, mc_list->dmi_addr);
+			mc_addr(mep, mc_list->dmi_addr);
 }
 
 /*
@@ -1589,15 +1589,15 @@ static void set_multicast_list(struct net_device *dev)
  */
 static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	u32 config_reg;
 
-	config_reg = rdl(mp, PORT_CONFIG(mp->port_num));
+	config_reg = rdl(mep, PORT_CONFIG(mep->port_num));
 	if (dev->flags & IFF_PROMISC)
 		config_reg |= 0x00000001;
 	else
 		config_reg &= ~0x00000001;
-	wrl(mp, PORT_CONFIG(mp->port_num), config_reg);
+	wrl(mep, PORT_CONFIG(mep->port_num), config_reg);
 
 	set_multicast_list(dev);
 }
@@ -1617,7 +1617,7 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
  *	with physical addresses.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
+ *	struct mv643xx_eth_private *mep	Ethernet Port Control srtuct.
  *
  * OUTPUT:
  *	The routine updates the Ethernet port control struct with information
@@ -1626,53 +1626,53 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
  * RETURN:
  *	None.
  */
-static void ether_init_rx_desc_ring(struct mv643xx_private *mp)
+static void ether_init_rx_desc_ring(struct mv643xx_eth_private *mep)
 {
 	volatile struct rx_desc *p_rx_desc;
-	int rx_desc_num = mp->rx_ring_size;
+	int rx_desc_num = mep->rx_ring_size;
 	int i;
 
 	/* initialize the next_desc_ptr links in the Rx descriptors ring */
-	p_rx_desc = (struct rx_desc *)mp->p_rx_desc_area;
+	p_rx_desc = (struct rx_desc *)mep->p_rx_desc_area;
 	for (i = 0; i < rx_desc_num; i++) {
-		p_rx_desc[i].next_desc_ptr = mp->rx_desc_dma +
+		p_rx_desc[i].next_desc_ptr = mep->rx_desc_dma +
 			((i + 1) % rx_desc_num) * sizeof(struct rx_desc);
 	}
 
 	/* Save Rx desc pointer to driver struct. */
-	mp->rx_curr_desc_q = 0;
-	mp->rx_used_desc_q = 0;
+	mep->rx_curr_desc_q = 0;
+	mep->rx_used_desc_q = 0;
 
-	mp->rx_desc_area_size = rx_desc_num * sizeof(struct rx_desc);
+	mep->rx_desc_area_size = rx_desc_num * sizeof(struct rx_desc);
 }
 
 static void mv643xx_eth_free_rx_rings(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	int curr;
 
 	/* Stop RX Queues */
-	mv643xx_eth_port_disable_rx(mp);
+	mv643xx_eth_port_disable_rx(mep);
 
 	/* Free preallocated skb's on RX rings */
-	for (curr = 0; mp->rx_desc_count && curr < mp->rx_ring_size; curr++) {
-		if (mp->rx_skb[curr]) {
-			dev_kfree_skb(mp->rx_skb[curr]);
-			mp->rx_desc_count--;
+	for (curr = 0; mep->rx_desc_count && curr < mep->rx_ring_size; curr++) {
+		if (mep->rx_skb[curr]) {
+			dev_kfree_skb(mep->rx_skb[curr]);
+			mep->rx_desc_count--;
 		}
 	}
 
-	if (mp->rx_desc_count)
+	if (mep->rx_desc_count)
 		printk(KERN_ERR
 			"%s: Error in freeing Rx Ring. %d skb's still"
 			" stuck in RX Ring - ignoring them\n", dev->name,
-			mp->rx_desc_count);
+			mep->rx_desc_count);
 	/* Free RX ring */
-	if (mp->rx_sram_size)
-		iounmap(mp->p_rx_desc_area);
+	if (mep->rx_sram_size)
+		iounmap(mep->p_rx_desc_area);
 	else
-		dma_free_coherent(NULL, mp->rx_desc_area_size,
-				mp->p_rx_desc_area, mp->rx_desc_dma);
+		dma_free_coherent(NULL, mep->rx_desc_area_size,
+				mep->p_rx_desc_area, mep->rx_desc_dma);
 }
 
 /*
@@ -1688,7 +1688,7 @@ static void mv643xx_eth_free_rx_rings(struct net_device *dev)
  *	with physical addresses.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
+ *	struct mv643xx_eth_private *mep	Ethernet Port Control srtuct.
  *
  * OUTPUT:
  *	The routine updates the Ethernet port control struct with information
@@ -1697,23 +1697,23 @@ static void mv643xx_eth_free_rx_rings(struct net_device *dev)
  * RETURN:
  *	None.
  */
-static void ether_init_tx_desc_ring(struct mv643xx_private *mp)
+static void ether_init_tx_desc_ring(struct mv643xx_eth_private *mep)
 {
-	int tx_desc_num = mp->tx_ring_size;
+	int tx_desc_num = mep->tx_ring_size;
 	struct tx_desc *p_tx_desc;
 	int i;
 
 	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
-	p_tx_desc = (struct tx_desc *)mp->p_tx_desc_area;
+	p_tx_desc = (struct tx_desc *)mep->p_tx_desc_area;
 	for (i = 0; i < tx_desc_num; i++) {
-		p_tx_desc[i].next_desc_ptr = mp->tx_desc_dma +
+		p_tx_desc[i].next_desc_ptr = mep->tx_desc_dma +
 			((i + 1) % tx_desc_num) * sizeof(struct tx_desc);
 	}
 
-	mp->tx_curr_desc_q = 0;
-	mp->tx_used_desc_q = 0;
+	mep->tx_curr_desc_q = 0;
+	mep->tx_used_desc_q = 0;
 
-	mp->tx_desc_area_size = tx_desc_num * sizeof(struct tx_desc);
+	mep->tx_desc_area_size = tx_desc_num * sizeof(struct tx_desc);
 }
 
 /**
@@ -1723,7 +1723,7 @@ static void ether_init_tx_desc_ring(struct mv643xx_private *mp)
  */
 static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	struct tx_desc *desc;
 	u32 cmd_sts;
 	struct sk_buff *skb;
@@ -1733,39 +1733,39 @@ static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 	int count;
 	int released = 0;
 
-	while (mp->tx_desc_count > 0) {
-		spin_lock_irqsave(&mp->lock, flags);
+	while (mep->tx_desc_count > 0) {
+		spin_lock_irqsave(&mep->lock, flags);
 
 		/* tx_desc_count might have changed before acquiring the lock */
-		if (mp->tx_desc_count <= 0) {
-			spin_unlock_irqrestore(&mp->lock, flags);
+		if (mep->tx_desc_count <= 0) {
+			spin_unlock_irqrestore(&mep->lock, flags);
 			return released;
 		}
 
-		tx_index = mp->tx_used_desc_q;
-		desc = &mp->p_tx_desc_area[tx_index];
+		tx_index = mep->tx_used_desc_q;
+		desc = &mep->p_tx_desc_area[tx_index];
 		cmd_sts = desc->cmd_sts;
 
 		if (!force && (cmd_sts & BUFFER_OWNED_BY_DMA)) {
-			spin_unlock_irqrestore(&mp->lock, flags);
+			spin_unlock_irqrestore(&mep->lock, flags);
 			return released;
 		}
 
-		mp->tx_used_desc_q = (tx_index + 1) % mp->tx_ring_size;
-		mp->tx_desc_count--;
+		mep->tx_used_desc_q = (tx_index + 1) % mep->tx_ring_size;
+		mep->tx_desc_count--;
 
 		addr = desc->buf_ptr;
 		count = desc->byte_cnt;
-		skb = mp->tx_skb[tx_index];
+		skb = mep->tx_skb[tx_index];
 		if (skb)
-			mp->tx_skb[tx_index] = NULL;
+			mep->tx_skb[tx_index] = NULL;
 
 		if (cmd_sts & ERROR_SUMMARY) {
 			printk("%s: Error in TX\n", dev->name);
 			dev->stats.tx_errors++;
 		}
 
-		spin_unlock_irqrestore(&mp->lock, flags);
+		spin_unlock_irqrestore(&mep->lock, flags);
 
 		if (cmd_sts & TX_FIRST_DESC)
 			dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
@@ -1783,10 +1783,10 @@ static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 
 static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
 	if (mv643xx_eth_free_tx_descs(dev, 0) &&
-	    mp->tx_ring_size - mp->tx_desc_count >= MAX_DESCS_PER_SKB)
+	    mep->tx_ring_size - mep->tx_desc_count >= MAX_DESCS_PER_SKB)
 		netif_wake_queue(dev);
 }
 
@@ -1797,38 +1797,38 @@ static void mv643xx_eth_free_all_tx_descs(struct net_device *dev)
 
 static void mv643xx_eth_free_tx_rings(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
 	/* Stop Tx Queues */
-	mv643xx_eth_port_disable_tx(mp);
+	mv643xx_eth_port_disable_tx(mep);
 
 	/* Free outstanding skb's on TX ring */
 	mv643xx_eth_free_all_tx_descs(dev);
 
-	BUG_ON(mp->tx_used_desc_q != mp->tx_curr_desc_q);
+	BUG_ON(mep->tx_used_desc_q != mep->tx_curr_desc_q);
 
 	/* Free TX ring */
-	if (mp->tx_sram_size)
-		iounmap(mp->p_tx_desc_area);
+	if (mep->tx_sram_size)
+		iounmap(mep->p_tx_desc_area);
 	else
-		dma_free_coherent(NULL, mp->tx_desc_area_size,
-				mp->p_tx_desc_area, mp->tx_desc_dma);
+		dma_free_coherent(NULL, mep->tx_desc_area_size,
+				mep->p_tx_desc_area, mep->tx_desc_dma);
 }
 
 
 /* netdev ops and related ***************************************************/
-static void port_reset(struct mv643xx_private *mp);
+static void port_reset(struct mv643xx_eth_private *mep);
 
 /* Set the mv643xx port configuration register for the speed/duplex mode. */
 static void mv643xx_eth_update_pscr(struct net_device *dev,
 				    struct ethtool_cmd *ecmd)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int port_num = mp->port_num;
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	int port_num = mep->port_num;
 	u32 o_pscr, n_pscr;
 	unsigned int queues;
 
-	o_pscr = rdl(mp, PORT_SERIAL_CONTROL(port_num));
+	o_pscr = rdl(mep, PORT_SERIAL_CONTROL(port_num));
 	n_pscr = o_pscr;
 
 	/* clear speed, duplex and rx buffer size fields */
@@ -1851,16 +1851,16 @@ static void mv643xx_eth_update_pscr(struct net_device *dev,
 
 	if (n_pscr != o_pscr) {
 		if ((o_pscr & SERIAL_PORT_ENABLE) == 0)
-			wrl(mp, PORT_SERIAL_CONTROL(port_num), n_pscr);
+			wrl(mep, PORT_SERIAL_CONTROL(port_num), n_pscr);
 		else {
-			queues = mv643xx_eth_port_disable_tx(mp);
+			queues = mv643xx_eth_port_disable_tx(mep);
 
 			o_pscr &= ~SERIAL_PORT_ENABLE;
-			wrl(mp, PORT_SERIAL_CONTROL(port_num), o_pscr);
-			wrl(mp, PORT_SERIAL_CONTROL(port_num), n_pscr);
-			wrl(mp, PORT_SERIAL_CONTROL(port_num), n_pscr);
+			wrl(mep, PORT_SERIAL_CONTROL(port_num), o_pscr);
+			wrl(mep, PORT_SERIAL_CONTROL(port_num), n_pscr);
+			wrl(mep, PORT_SERIAL_CONTROL(port_num), n_pscr);
 			if (queues)
-				mv643xx_eth_port_enable_tx(mp, queues);
+				mv643xx_eth_port_enable_tx(mep, queues);
 		}
 	}
 }
@@ -1879,29 +1879,29 @@ static void mv643xx_eth_update_pscr(struct net_device *dev,
 static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	u32 int_cause, int_cause_ext = 0;
-	unsigned int port_num = mp->port_num;
+	unsigned int port_num = mep->port_num;
 
 	/* Read interrupt cause registers */
-	int_cause = rdl(mp, INT_CAUSE(port_num)) & (INT_RX | INT_EXT);
+	int_cause = rdl(mep, INT_CAUSE(port_num)) & (INT_RX | INT_EXT);
 	if (int_cause & INT_EXT) {
-		int_cause_ext = rdl(mp, INT_CAUSE_EXT(port_num))
+		int_cause_ext = rdl(mep, INT_CAUSE_EXT(port_num))
 				& (INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
-		wrl(mp, INT_CAUSE_EXT(port_num), ~int_cause_ext);
+		wrl(mep, INT_CAUSE_EXT(port_num), ~int_cause_ext);
 	}
 
 	/* PHY status changed */
 	if (int_cause_ext & (INT_EXT_LINK | INT_EXT_PHY)) {
 		struct ethtool_cmd cmd;
 
-		if (mii_link_ok(&mp->mii)) {
-			mii_ethtool_gset(&mp->mii, &cmd);
+		if (mii_link_ok(&mep->mii)) {
+			mii_ethtool_gset(&mep->mii, &cmd);
 			mv643xx_eth_update_pscr(dev, &cmd);
-			mv643xx_eth_port_enable_tx(mp, 1);
+			mv643xx_eth_port_enable_tx(mep, 1);
 			if (!netif_carrier_ok(dev)) {
 				netif_carrier_on(dev);
-				if (mp->tx_ring_size - mp->tx_desc_count >=
+				if (mep->tx_ring_size - mep->tx_desc_count >=
 							MAX_DESCS_PER_SKB)
 					netif_wake_queue(dev);
 			}
@@ -1911,15 +1911,15 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 		}
 	}
 
-#ifdef MV643XX_NAPI
+#ifdef MV643XX_ETH_NAPI
 	if (int_cause & INT_RX) {
 		/* schedule the NAPI poll routine to maintain port */
-		wrl(mp, INT_MASK(port_num), 0x00000000);
+		wrl(mep, INT_MASK(port_num), 0x00000000);
 
 		/* wait for previous write to complete */
-		rdl(mp, INT_MASK(port_num));
+		rdl(mep, INT_MASK(port_num));
 
-		netif_rx_schedule(dev, &mp->napi);
+		netif_rx_schedule(dev, &mep->napi);
 	}
 #else
 	if (int_cause & INT_RX)
@@ -1945,7 +1945,7 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
  *	This routine utilizes the SMI interface to reset the ethernet port PHY.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
+ *	struct mv643xx_eth_private *mep	Ethernet Port.
  *
  * OUTPUT:
  *	The PHY is reset.
@@ -1954,19 +1954,19 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
  *	None.
  *
  */
-static void phy_reset(struct mv643xx_private *mp)
+static void phy_reset(struct mv643xx_eth_private *mep)
 {
 	unsigned int phy_reg_data;
 
 	/* Reset the PHY */
-	read_smi_reg(mp, 0, &phy_reg_data);
+	read_smi_reg(mep, 0, &phy_reg_data);
 	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
-	write_smi_reg(mp, 0, phy_reg_data);
+	write_smi_reg(mep, 0, phy_reg_data);
 
 	/* wait for PHY to come out of reset */
 	do {
 		udelay(1);
-		read_smi_reg(mp, 0, &phy_reg_data);
+		read_smi_reg(mep, 0, &phy_reg_data);
 	} while (phy_reg_data & 0x8000);
 }
 
@@ -1999,40 +1999,40 @@ static void phy_reset(struct mv643xx_private *mp)
  */
 static void port_start(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	unsigned int port_num = mep->port_num;
 	int tx_curr_desc, rx_curr_desc;
 	u32 pscr;
 	struct ethtool_cmd ethtool_cmd;
 
 	/* Assignment of Tx CTRP of given queue */
-	tx_curr_desc = mp->tx_curr_desc_q;
-	wrl(mp, TXQ_CURRENT_DESC_PTR(port_num),
-		(u32)((struct tx_desc *)mp->tx_desc_dma + tx_curr_desc));
+	tx_curr_desc = mep->tx_curr_desc_q;
+	wrl(mep, TXQ_CURRENT_DESC_PTR(port_num),
+		(u32)((struct tx_desc *)mep->tx_desc_dma + tx_curr_desc));
 
 	/* Assignment of Rx CRDP of given queue */
-	rx_curr_desc = mp->rx_curr_desc_q;
-	wrl(mp, RXQ_CURRENT_DESC_PTR(port_num),
-		(u32)((struct rx_desc *)mp->rx_desc_dma + rx_curr_desc));
+	rx_curr_desc = mep->rx_curr_desc_q;
+	wrl(mep, RXQ_CURRENT_DESC_PTR(port_num),
+		(u32)((struct rx_desc *)mep->rx_desc_dma + rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
-	uc_addr_set(mp, dev->dev_addr);
+	uc_addr_set(mep, dev->dev_addr);
 
 	/*
 	 * Receive all unmatched unicast, TCP, UDP, BPDU and broadcast
 	 * frames to RX queue #0.
 	 */
-	wrl(mp, PORT_CONFIG(port_num), 0x00000000);
+	wrl(mep, PORT_CONFIG(port_num), 0x00000000);
 
 	/*
 	 * Treat BPDUs as normal multicasts, and disable partition mode.
 	 */
-	wrl(mp, PORT_CONFIG_EXT(port_num), 0x00000000);
+	wrl(mep, PORT_CONFIG_EXT(port_num), 0x00000000);
 
-	pscr = rdl(mp, PORT_SERIAL_CONTROL(port_num));
+	pscr = rdl(mep, PORT_SERIAL_CONTROL(port_num));
 
 	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL(port_num), pscr);
+	wrl(mep, PORT_SERIAL_CONTROL(port_num), pscr);
 
 	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
 		DISABLE_AUTO_NEG_SPEED_GMII    |
@@ -2040,27 +2040,27 @@ static void port_start(struct net_device *dev)
 		DO_NOT_FORCE_LINK_FAIL	   |
 		SERIAL_PORT_CONTROL_RESERVED;
 
-	wrl(mp, PORT_SERIAL_CONTROL(port_num), pscr);
+	wrl(mep, PORT_SERIAL_CONTROL(port_num), pscr);
 
 	pscr |= SERIAL_PORT_ENABLE;
-	wrl(mp, PORT_SERIAL_CONTROL(port_num), pscr);
+	wrl(mep, PORT_SERIAL_CONTROL(port_num), pscr);
 
 	/* Assign port SDMA configuration */
-	wrl(mp, SDMA_CONFIG(port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
+	wrl(mep, SDMA_CONFIG(port_num), PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
 	/* Enable port Rx. */
-	mv643xx_eth_port_enable_rx(mp, 1);
+	mv643xx_eth_port_enable_rx(mep, 1);
 
 	/* Disable port bandwidth limits by clearing MTU register */
-	wrl(mp, TX_BW_MTU(port_num), 0);
+	wrl(mep, TX_BW_MTU(port_num), 0);
 
 	/* save phy settings across reset */
-	mv643xx_get_settings(dev, &ethtool_cmd);
-	phy_reset(mp);
-	mv643xx_set_settings(dev, &ethtool_cmd);
+	mv643xx_eth_get_settings(dev, &ethtool_cmd);
+	phy_reset(mep);
+	mv643xx_eth_set_settings(dev, &ethtool_cmd);
 }
 
-#ifdef MV643XX_COAL
+#ifdef MV643XX_ETH_COAL
 
 /*
  * set_rx_coal - Sets coalescing interrupt mechanism on RX path
@@ -2074,7 +2074,7 @@ static void port_start(struct net_device *dev)
  *	, and the required delay of the interrupt in usec.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet port
+ *	struct mv643xx_eth_private *mep	Ethernet port
  *	unsigned int delay		Delay in usec
  *
  * OUTPUT:
@@ -2084,16 +2084,16 @@ static void port_start(struct net_device *dev)
  *	The interrupt coalescing value set in the gigE port.
  *
  */
-static unsigned int set_rx_coal(struct mv643xx_private *mp,
+static unsigned int set_rx_coal(struct mv643xx_eth_private *mep,
 					unsigned int delay)
 {
-	unsigned int port_num = mp->port_num;
-	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
+	unsigned int port_num = mep->port_num;
+	unsigned int coal = ((mep->shared->t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
-	wrl(mp, SDMA_CONFIG(port_num),
+	wrl(mep, SDMA_CONFIG(port_num),
 		((coal & 0x3fff) << 8) |
-		(rdl(mp, SDMA_CONFIG(port_num))
+		(rdl(mep, SDMA_CONFIG(port_num))
 			& 0xffc000ff));
 
 	return coal;
@@ -2112,7 +2112,7 @@ static unsigned int set_rx_coal(struct mv643xx_private *mp,
  *	MV-643xx chip and the required delay in the interrupt in uSec
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet port
+ *	struct mv643xx_eth_private *mep	Ethernet port
  *	unsigned int delay		Delay in uSeconds
  *
  * OUTPUT:
@@ -2122,13 +2122,13 @@ static unsigned int set_rx_coal(struct mv643xx_private *mp,
  *	The interrupt coalescing value set in the gigE port.
  *
  */
-static unsigned int set_tx_coal(struct mv643xx_private *mp,
+static unsigned int set_tx_coal(struct mv643xx_eth_private *mep,
 					unsigned int delay)
 {
-	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
+	unsigned int coal = ((mep->shared->t_clk / 1000000) * delay) / 64;
 
 	/* Set TX Coalescing mechanism */
-	wrl(mp, TX_FIFO_URGENT_THRESHOLD(mp->port_num), coal << 4);
+	wrl(mep, TX_FIFO_URGENT_THRESHOLD(mep->port_num), coal << 4);
 
 	return coal;
 }
@@ -2149,7 +2149,7 @@ static unsigned int set_tx_coal(struct mv643xx_private *mp,
  *	struct.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet port control struct
+ *	struct mv643xx_eth_private *mep	Ethernet port control struct
  *
  * OUTPUT:
  *	See description.
@@ -2157,13 +2157,13 @@ static unsigned int set_tx_coal(struct mv643xx_private *mp,
  * RETURN:
  *	None.
  */
-static void port_init(struct mv643xx_private *mp)
+static void port_init(struct mv643xx_eth_private *mep)
 {
-	mp->rx_resource_err = 0;
+	mep->rx_resource_err = 0;
 
-	port_reset(mp);
+	port_reset(mep);
 
-	init_mac_tables(mp);
+	init_mac_tables(mep);
 }
 
 /*
@@ -2181,16 +2181,16 @@ static void port_init(struct mv643xx_private *mp)
 
 static int mv643xx_eth_open(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	unsigned int port_num = mep->port_num;
 	unsigned int size;
 	int err;
 
 	/* Clear any pending ethernet port interrupts */
-	wrl(mp, INT_CAUSE(port_num), 0);
-	wrl(mp, INT_CAUSE_EXT(port_num), 0);
+	wrl(mep, INT_CAUSE(port_num), 0);
+	wrl(mep, INT_CAUSE_EXT(port_num), 0);
 	/* wait for previous write to complete */
-	rdl(mp, INT_CAUSE_EXT(port_num));
+	rdl(mep, INT_CAUSE_EXT(port_num));
 
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
@@ -2199,112 +2199,112 @@ static int mv643xx_eth_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	port_init(mp);
+	port_init(mep);
 
-	memset(&mp->timeout, 0, sizeof(struct timer_list));
-	mp->timeout.function = mv643xx_eth_rx_refill_descs_timer_wrapper;
-	mp->timeout.data = (unsigned long)dev;
+	memset(&mep->timeout, 0, sizeof(struct timer_list));
+	mep->timeout.function = mv643xx_eth_rx_refill_descs_timer_wrapper;
+	mep->timeout.data = (unsigned long)dev;
 
 	/* Allocate RX and TX skb rings */
-	mp->rx_skb = kmalloc(sizeof(*mp->rx_skb) * mp->rx_ring_size,
+	mep->rx_skb = kmalloc(sizeof(*mep->rx_skb) * mep->rx_ring_size,
 								GFP_KERNEL);
-	if (!mp->rx_skb) {
+	if (!mep->rx_skb) {
 		printk(KERN_ERR "%s: Cannot allocate Rx skb ring\n", dev->name);
 		err = -ENOMEM;
 		goto out_free_irq;
 	}
-	mp->tx_skb = kmalloc(sizeof(*mp->tx_skb) * mp->tx_ring_size,
+	mep->tx_skb = kmalloc(sizeof(*mep->tx_skb) * mep->tx_ring_size,
 								GFP_KERNEL);
-	if (!mp->tx_skb) {
+	if (!mep->tx_skb) {
 		printk(KERN_ERR "%s: Cannot allocate Tx skb ring\n", dev->name);
 		err = -ENOMEM;
 		goto out_free_rx_skb;
 	}
 
 	/* Allocate TX ring */
-	mp->tx_desc_count = 0;
-	size = mp->tx_ring_size * sizeof(struct tx_desc);
-	mp->tx_desc_area_size = size;
-
-	if (mp->tx_sram_size) {
-		mp->p_tx_desc_area = ioremap(mp->tx_sram_addr,
-							mp->tx_sram_size);
-		mp->tx_desc_dma = mp->tx_sram_addr;
+	mep->tx_desc_count = 0;
+	size = mep->tx_ring_size * sizeof(struct tx_desc);
+	mep->tx_desc_area_size = size;
+
+	if (mep->tx_sram_size) {
+		mep->p_tx_desc_area = ioremap(mep->tx_sram_addr,
+							mep->tx_sram_size);
+		mep->tx_desc_dma = mep->tx_sram_addr;
 	} else
-		mp->p_tx_desc_area = dma_alloc_coherent(NULL, size,
-							&mp->tx_desc_dma,
+		mep->p_tx_desc_area = dma_alloc_coherent(NULL, size,
+							&mep->tx_desc_dma,
 							GFP_KERNEL);
 
-	if (!mp->p_tx_desc_area) {
+	if (!mep->p_tx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
 							dev->name, size);
 		err = -ENOMEM;
 		goto out_free_tx_skb;
 	}
-	BUG_ON((u32) mp->p_tx_desc_area & 0xf);	/* check 16-byte alignment */
-	memset((void *)mp->p_tx_desc_area, 0, mp->tx_desc_area_size);
+	BUG_ON((u32) mep->p_tx_desc_area & 0xf);	/* check 16-byte alignment */
+	memset((void *)mep->p_tx_desc_area, 0, mep->tx_desc_area_size);
 
-	ether_init_tx_desc_ring(mp);
+	ether_init_tx_desc_ring(mep);
 
 	/* Allocate RX ring */
-	mp->rx_desc_count = 0;
-	size = mp->rx_ring_size * sizeof(struct rx_desc);
-	mp->rx_desc_area_size = size;
-
-	if (mp->rx_sram_size) {
-		mp->p_rx_desc_area = ioremap(mp->rx_sram_addr,
-							mp->rx_sram_size);
-		mp->rx_desc_dma = mp->rx_sram_addr;
+	mep->rx_desc_count = 0;
+	size = mep->rx_ring_size * sizeof(struct rx_desc);
+	mep->rx_desc_area_size = size;
+
+	if (mep->rx_sram_size) {
+		mep->p_rx_desc_area = ioremap(mep->rx_sram_addr,
+							mep->rx_sram_size);
+		mep->rx_desc_dma = mep->rx_sram_addr;
 	} else
-		mp->p_rx_desc_area = dma_alloc_coherent(NULL, size,
-							&mp->rx_desc_dma,
+		mep->p_rx_desc_area = dma_alloc_coherent(NULL, size,
+							&mep->rx_desc_dma,
 							GFP_KERNEL);
 
-	if (!mp->p_rx_desc_area) {
+	if (!mep->p_rx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Rx ring (size %d bytes)\n",
 							dev->name, size);
 		printk(KERN_ERR "%s: Freeing previously allocated TX queues...",
 							dev->name);
-		if (mp->rx_sram_size)
-			iounmap(mp->p_tx_desc_area);
+		if (mep->rx_sram_size)
+			iounmap(mep->p_tx_desc_area);
 		else
-			dma_free_coherent(NULL, mp->tx_desc_area_size,
-					mp->p_tx_desc_area, mp->tx_desc_dma);
+			dma_free_coherent(NULL, mep->tx_desc_area_size,
+					mep->p_tx_desc_area, mep->tx_desc_dma);
 		err = -ENOMEM;
 		goto out_free_tx_skb;
 	}
-	memset((void *)mp->p_rx_desc_area, 0, size);
+	memset((void *)mep->p_rx_desc_area, 0, size);
 
-	ether_init_rx_desc_ring(mp);
+	ether_init_rx_desc_ring(mep);
 
 	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
 
-#ifdef MV643XX_NAPI
-	napi_enable(&mp->napi);
+#ifdef MV643XX_ETH_NAPI
+	napi_enable(&mep->napi);
 #endif
 
 	port_start(dev);
 
 	/* Interrupt Coalescing */
 
-#ifdef MV643XX_COAL
-	mp->rx_int_coal = set_rx_coal(mp, MV643XX_RX_COAL);
+#ifdef MV643XX_ETH_COAL
+	mep->rx_int_coal = set_rx_coal(mep, MV643XX_ETH_RX_COAL);
 #endif
 
-	mp->tx_int_coal = set_tx_coal(mp, MV643XX_TX_COAL);
+	mep->tx_int_coal = set_tx_coal(mep, MV643XX_ETH_TX_COAL);
 
 	/* Unmask phy and link status changes interrupts */
-	wrl(mp, INT_MASK_EXT(port_num), INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
+	wrl(mep, INT_MASK_EXT(port_num), INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
 
 	/* Unmask RX buffer and TX end interrupt */
-	wrl(mp, INT_MASK(port_num), INT_RX | INT_EXT);
+	wrl(mep, INT_MASK(port_num), INT_RX | INT_EXT);
 
 	return 0;
 
 out_free_tx_skb:
-	kfree(mp->tx_skb);
+	kfree(mep->tx_skb);
 out_free_rx_skb:
-	kfree(mp->rx_skb);
+	kfree(mep->rx_skb);
 out_free_irq:
 	free_irq(dev->irq, dev);
 
@@ -2320,7 +2320,7 @@ out_free_irq:
  *	idle state after this command is performed and the port is disabled.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
+ *	struct mv643xx_eth_private *mep	Ethernet Port.
  *
  * OUTPUT:
  *	Channel activity is halted.
@@ -2329,23 +2329,23 @@ out_free_irq:
  *	None.
  *
  */
-static void port_reset(struct mv643xx_private *mp)
+static void port_reset(struct mv643xx_eth_private *mep)
 {
-	unsigned int port_num = mp->port_num;
+	unsigned int port_num = mep->port_num;
 	unsigned int reg_data;
 
-	mv643xx_eth_port_disable_tx(mp);
-	mv643xx_eth_port_disable_rx(mp);
+	mv643xx_eth_port_disable_tx(mep);
+	mv643xx_eth_port_disable_rx(mep);
 
 	/* Clear all MIB counters */
-	clear_mib_counters(mp);
+	clear_mib_counters(mep);
 
 	/* Reset the Enable bit in the Configuration Register */
-	reg_data = rdl(mp, PORT_SERIAL_CONTROL(port_num));
+	reg_data = rdl(mep, PORT_SERIAL_CONTROL(port_num));
 	reg_data &= ~(SERIAL_PORT_ENABLE		|
 			DO_NOT_FORCE_LINK_FAIL	|
 			FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL(port_num), reg_data);
+	wrl(mep, PORT_SERIAL_CONTROL(port_num), reg_data);
 }
 
 /*
@@ -2360,21 +2360,21 @@ static void port_reset(struct mv643xx_private *mp)
 
 static int mv643xx_eth_stop(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	unsigned int port_num = mep->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	wrl(mp, INT_MASK(port_num), 0x00000000);
+	wrl(mep, INT_MASK(port_num), 0x00000000);
 	/* wait for previous write to complete */
-	rdl(mp, INT_MASK(port_num));
+	rdl(mep, INT_MASK(port_num));
 
-#ifdef MV643XX_NAPI
-	napi_disable(&mp->napi);
+#ifdef MV643XX_ETH_NAPI
+	napi_disable(&mep->napi);
 #endif
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 
-	port_reset(mp);
+	port_reset(mep);
 
 	mv643xx_eth_free_tx_rings(dev);
 	mv643xx_eth_free_rx_rings(dev);
@@ -2386,9 +2386,9 @@ static int mv643xx_eth_stop(struct net_device *dev)
 
 static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
-	return generic_mii_ioctl(&mp->mii, if_mii(ifr), cmd, NULL);
+	return generic_mii_ioctl(&mep->mii, if_mii(ifr), cmd, NULL);
 }
 
 /*
@@ -2429,19 +2429,19 @@ static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
  */
 static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
 {
-	struct mv643xx_private *mp = container_of(ugly, struct mv643xx_private,
+	struct mv643xx_eth_private *mep = container_of(ugly, struct mv643xx_eth_private,
 						  tx_timeout_task);
-	struct net_device *dev = mp->dev;
+	struct net_device *dev = mep->dev;
 
 	if (!netif_running(dev))
 		return;
 
 	netif_stop_queue(dev);
 
-	port_reset(mp);
+	port_reset(mep);
 	port_start(dev);
 
-	if (mp->tx_ring_size - mp->tx_desc_count >= MAX_DESCS_PER_SKB)
+	if (mep->tx_ring_size - mep->tx_desc_count >= MAX_DESCS_PER_SKB)
 		netif_wake_queue(dev);
 }
 
@@ -2455,54 +2455,55 @@ static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
  */
 static void mv643xx_eth_tx_timeout(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
 	printk(KERN_INFO "%s: TX timeout  ", dev->name);
 
 	/* Do the reset outside of interrupt context */
-	schedule_work(&mp->tx_timeout_task);
+	schedule_work(&mep->tx_timeout_task);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void mv643xx_netpoll(struct net_device *netdev)
+static void mv643xx_eth_netpoll(struct net_device *netdev)
 {
-	struct mv643xx_private *mp = netdev_priv(netdev);
-	int port_num = mp->port_num;
+	struct mv643xx_eth_private *mep = netdev_priv(netdev);
+	int port_num = mep->port_num;
 
-	wrl(mp, INT_MASK(port_num), 0x00000000);
+	wrl(mep, INT_MASK(port_num), 0x00000000);
 	/* wait for previous write to complete */
-	rdl(mp, INT_MASK(port_num));
+	rdl(mep, INT_MASK(port_num));
 
 	mv643xx_eth_int_handler(netdev->irq, netdev);
 
-	wrl(mp, INT_MASK(port_num), INT_RX | INT_CAUSE_EXT);
+	wrl(mep, INT_MASK(port_num), INT_RX | INT_CAUSE_EXT);
 }
 #endif
 
 /*
  * Wrappers for MII support library.
  */
-static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location)
+static int mv643xx_eth_mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	int val;
 
-	read_smi_reg(mp, location, &val);
+	read_smi_reg(mep, location, &val);
 	return val;
 }
 
-static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val)
+static void mv643xx_eth_mdio_write(struct net_device *dev, int phy_id, int location, int val)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	write_smi_reg(mp, location, val);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	write_smi_reg(mep, location, val);
 }
 
 
 /* platform glue ************************************************************/
-static void mv643xx_eth_conf_mbus_windows(struct mv643xx_shared_private *msp,
-					  struct mbus_dram_target_info *dram)
+static void
+mv643xx_eth_conf_mbus_windows(struct mv643xx_eth_shared_private *mesp,
+			      struct mbus_dram_target_info *dram)
 {
-	void __iomem *base = msp->base;
+	void __iomem *base = mesp->base;
 	u32 win_enable;
 	u32 win_protect;
 	int i;
@@ -2530,18 +2531,18 @@ static void mv643xx_eth_conf_mbus_windows(struct mv643xx_shared_private *msp,
 	}
 
 	writel(win_enable, base + WINDOW_BAR_ENABLE);
-	msp->win_protect = win_protect;
+	mesp->win_protect = win_protect;
 }
 
 static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 {
-	static int mv643xx_version_printed = 0;
+	static int mv643xx_eth_version_printed = 0;
 	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
-	struct mv643xx_shared_private *msp;
+	struct mv643xx_eth_shared_private *mesp;
 	struct resource *res;
 	int ret;
 
-	if (!mv643xx_version_printed++)
+	if (!mv643xx_eth_version_printed++)
 		printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
 
 	ret = -EINVAL;
@@ -2550,40 +2551,40 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 		goto out;
 
 	ret = -ENOMEM;
-	msp = kmalloc(sizeof(*msp), GFP_KERNEL);
-	if (msp == NULL)
+	mesp = kmalloc(sizeof(*mesp), GFP_KERNEL);
+	if (mesp == NULL)
 		goto out;
-	memset(msp, 0, sizeof(*msp));
+	memset(mesp, 0, sizeof(*mesp));
 
-	msp->base = ioremap(res->start, res->end - res->start + 1);
-	if (msp->base == NULL)
+	mesp->base = ioremap(res->start, res->end - res->start + 1);
+	if (mesp->base == NULL)
 		goto out_free;
 
-	spin_lock_init(&msp->phy_lock);
-	msp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
+	spin_lock_init(&mesp->phy_lock);
+	mesp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
 
-	platform_set_drvdata(pdev, msp);
+	platform_set_drvdata(pdev, mesp);
 
 	/*
 	 * (Re-)program MBUS remapping windows if we are asked to.
 	 */
 	if (pd != NULL && pd->dram != NULL)
-		mv643xx_eth_conf_mbus_windows(msp, pd->dram);
+		mv643xx_eth_conf_mbus_windows(mesp, pd->dram);
 
 	return 0;
 
 out_free:
-	kfree(msp);
+	kfree(mesp);
 out:
 	return ret;
 }
 
 static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
-	struct mv643xx_shared_private *msp = platform_get_drvdata(pdev);
+	struct mv643xx_eth_shared_private *mesp = platform_get_drvdata(pdev);
 
-	iounmap(msp->base);
-	kfree(msp);
+	iounmap(mesp->base);
+	kfree(mesp);
 
 	return 0;
 }
@@ -2604,7 +2605,7 @@ static struct platform_driver mv643xx_eth_shared_driver = {
  *	This routine sets the given ethernet port PHY address.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
+ *	struct mv643xx_eth_private *mep	Ethernet Port.
  *	int		phy_addr	PHY address.
  *
  * OUTPUT:
@@ -2614,15 +2615,15 @@ static struct platform_driver mv643xx_eth_shared_driver = {
  *	None.
  *
  */
-static void phy_addr_set(struct mv643xx_private *mp, int phy_addr)
+static void phy_addr_set(struct mv643xx_eth_private *mep, int phy_addr)
 {
 	u32 reg_data;
-	int addr_shift = 5 * mp->port_num;
+	int addr_shift = 5 * mep->port_num;
 
-	reg_data = rdl(mp, PHY_ADDR);
+	reg_data = rdl(mep, PHY_ADDR);
 	reg_data &= ~(0x1f << addr_shift);
 	reg_data |= (phy_addr & 0x1f) << addr_shift;
-	wrl(mp, PHY_ADDR, reg_data);
+	wrl(mep, PHY_ADDR, reg_data);
 }
 
 /*
@@ -2632,7 +2633,7 @@ static void phy_addr_set(struct mv643xx_private *mp, int phy_addr)
  *	This routine returns the given ethernet port PHY address.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
+ *	struct mv643xx_eth_private *mep	Ethernet Port.
  *
  * OUTPUT:
  *	None.
@@ -2641,13 +2642,13 @@ static void phy_addr_set(struct mv643xx_private *mp, int phy_addr)
  *	PHY address.
  *
  */
-static int phy_addr_get(struct mv643xx_private *mp)
+static int phy_addr_get(struct mv643xx_eth_private *mep)
 {
 	unsigned int reg_data;
 
-	reg_data = rdl(mp, PHY_ADDR);
+	reg_data = rdl(mep, PHY_ADDR);
 
-	return ((reg_data >> (5 * mp->port_num)) & 0x1f);
+	return ((reg_data >> (5 * mep->port_num)) & 0x1f);
 }
 
 /*
@@ -2658,7 +2659,7 @@ static int phy_addr_get(struct mv643xx_private *mp)
  *	the specified port.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
+ *	struct mv643xx_eth_private *mep	Ethernet Port.
  *
  * OUTPUT:
  *	None
@@ -2668,22 +2669,22 @@ static int phy_addr_get(struct mv643xx_private *mp)
  *	-ENODEV on failure
  *
  */
-static int phy_detect(struct mv643xx_private *mp)
+static int phy_detect(struct mv643xx_eth_private *mep)
 {
 	unsigned int phy_reg_data0;
 	int auto_neg;
 
-	read_smi_reg(mp, 0, &phy_reg_data0);
+	read_smi_reg(mep, 0, &phy_reg_data0);
 	auto_neg = phy_reg_data0 & 0x1000;
 	phy_reg_data0 ^= 0x1000;	/* invert auto_neg */
-	write_smi_reg(mp, 0, phy_reg_data0);
+	write_smi_reg(mep, 0, phy_reg_data0);
 
-	read_smi_reg(mp, 0, &phy_reg_data0);
+	read_smi_reg(mep, 0, &phy_reg_data0);
 	if ((phy_reg_data0 & 0x1000) == auto_neg)
 		return -ENODEV;				/* change didn't take */
 
 	phy_reg_data0 ^= 0x1000;
-	write_smi_reg(mp, 0, phy_reg_data0);
+	write_smi_reg(mep, 0, phy_reg_data0);
 	return 0;
 }
 
@@ -2691,7 +2692,7 @@ static void mv643xx_init_ethtool_cmd(struct net_device *dev, int phy_address,
 				     int speed, int duplex,
 				     struct ethtool_cmd *cmd)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
 
 	memset(cmd, 0, sizeof(*cmd));
 
@@ -2707,7 +2708,7 @@ static void mv643xx_init_ethtool_cmd(struct net_device *dev, int phy_address,
 				   ADVERTISED_10baseT_Full  |
 				   ADVERTISED_100baseT_Half |
 				   ADVERTISED_100baseT_Full;
-		if (mp->mii.supports_gmii)
+		if (mep->mii.supports_gmii)
 			cmd->advertising |= ADVERTISED_1000baseT_Full;
 	} else {
 		cmd->autoneg = AUTONEG_DISABLE;
@@ -2731,7 +2732,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
 	int port_num;
-	struct mv643xx_private *mp;
+	struct mv643xx_eth_private *mep;
 	struct net_device *dev;
 	u8 *p;
 	struct resource *res;
@@ -2752,16 +2753,16 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	dev = alloc_etherdev(sizeof(struct mv643xx_private));
+	dev = alloc_etherdev(sizeof(struct mv643xx_eth_private));
 	if (!dev)
 		return -ENOMEM;
 
 	platform_set_drvdata(pdev, dev);
 
-	mp = netdev_priv(dev);
-	mp->dev = dev;
-#ifdef MV643XX_NAPI
-	netif_napi_add(dev, &mp->napi, mv643xx_poll, 64);
+	mep = netdev_priv(dev);
+	mep->dev = dev;
+#ifdef MV643XX_ETH_NAPI
+	netif_napi_add(dev, &mep->napi, mv643xx_eth_poll, 64);
 #endif
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
@@ -2778,16 +2779,16 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev->tx_timeout = mv643xx_eth_tx_timeout;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = mv643xx_netpoll;
+	dev->poll_controller = mv643xx_eth_netpoll;
 #endif
 
 	dev->watchdog_timeo = 2 * HZ;
 	dev->base_addr = 0;
 	dev->change_mtu = mv643xx_eth_change_mtu;
 	dev->do_ioctl = mv643xx_eth_do_ioctl;
-	SET_ETHTOOL_OPS(dev, &mv643xx_ethtool_ops);
+	SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
 
-#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+#ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 #ifdef MAX_SKB_FRAGS
 	/*
 	 * Zero copy can only work if we use Discovery II memory. Else, we will
@@ -2798,70 +2799,70 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 #endif
 
 	/* Configure the timeout task */
-	INIT_WORK(&mp->tx_timeout_task, mv643xx_eth_tx_timeout_task);
+	INIT_WORK(&mep->tx_timeout_task, mv643xx_eth_tx_timeout_task);
 
-	spin_lock_init(&mp->lock);
+	spin_lock_init(&mep->lock);
 
-	mp->shared = platform_get_drvdata(pd->shared);
-	port_num = mp->port_num = pd->port_number;
+	mep->shared = platform_get_drvdata(pd->shared);
+	port_num = mep->port_num = pd->port_number;
 
-	if (mp->shared->win_protect)
-		wrl(mp, WINDOW_PROTECT(port_num), mp->shared->win_protect);
+	if (mep->shared->win_protect)
+		wrl(mep, WINDOW_PROTECT(port_num), mep->shared->win_protect);
 
-	mp->shared_smi = mp->shared;
+	mep->shared_smi = mep->shared;
 	if (pd->shared_smi != NULL)
-		mp->shared_smi = platform_get_drvdata(pd->shared_smi);
+		mep->shared_smi = platform_get_drvdata(pd->shared_smi);
 
 	/* set default config values */
-	uc_addr_get(mp, dev->dev_addr);
-	mp->rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
-	mp->tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
+	uc_addr_get(mep, dev->dev_addr);
+	mep->rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
+	mep->tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 
 	if (is_valid_ether_addr(pd->mac_addr))
 		memcpy(dev->dev_addr, pd->mac_addr, 6);
 
 	if (pd->phy_addr || pd->force_phy_addr)
-		phy_addr_set(mp, pd->phy_addr);
+		phy_addr_set(mep, pd->phy_addr);
 
 	if (pd->rx_queue_size)
-		mp->rx_ring_size = pd->rx_queue_size;
+		mep->rx_ring_size = pd->rx_queue_size;
 
 	if (pd->tx_queue_size)
-		mp->tx_ring_size = pd->tx_queue_size;
+		mep->tx_ring_size = pd->tx_queue_size;
 
 	if (pd->tx_sram_size) {
-		mp->tx_sram_size = pd->tx_sram_size;
-		mp->tx_sram_addr = pd->tx_sram_addr;
+		mep->tx_sram_size = pd->tx_sram_size;
+		mep->tx_sram_addr = pd->tx_sram_addr;
 	}
 
 	if (pd->rx_sram_size) {
-		mp->rx_sram_size = pd->rx_sram_size;
-		mp->rx_sram_addr = pd->rx_sram_addr;
+		mep->rx_sram_size = pd->rx_sram_size;
+		mep->rx_sram_addr = pd->rx_sram_addr;
 	}
 
 	duplex = pd->duplex;
 	speed = pd->speed;
 
 	/* Hook up MII support for ethtool */
-	mp->mii.dev = dev;
-	mp->mii.mdio_read = mv643xx_mdio_read;
-	mp->mii.mdio_write = mv643xx_mdio_write;
-	mp->mii.phy_id = phy_addr_get(mp);
-	mp->mii.phy_id_mask = 0x3f;
-	mp->mii.reg_num_mask = 0x1f;
-
-	err = phy_detect(mp);
+	mep->mii.dev = dev;
+	mep->mii.mdio_read = mv643xx_eth_mdio_read;
+	mep->mii.mdio_write = mv643xx_eth_mdio_write;
+	mep->mii.phy_id = phy_addr_get(mep);
+	mep->mii.phy_id_mask = 0x3f;
+	mep->mii.reg_num_mask = 0x1f;
+
+	err = phy_detect(mep);
 	if (err) {
 		pr_debug("%s: No PHY detected at addr %d\n",
-				dev->name, phy_addr_get(mp));
+				dev->name, phy_addr_get(mep));
 		goto out;
 	}
 
-	phy_reset(mp);
-	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
-	mv643xx_init_ethtool_cmd(dev, mp->mii.phy_id, speed, duplex, &cmd);
+	phy_reset(mep);
+	mep->mii.supports_gmii = mii_check_gmii_support(&mep->mii);
+	mv643xx_init_ethtool_cmd(dev, mep->mii.phy_id, speed, duplex, &cmd);
 	mv643xx_eth_update_pscr(dev, &cmd);
-	mv643xx_set_settings(dev, &cmd);
+	mv643xx_eth_set_settings(dev, &cmd);
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	err = register_netdev(dev);
@@ -2880,20 +2881,20 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 		printk(KERN_NOTICE "%s: TX TCP/IP Checksumming Supported\n",
 								dev->name);
 
-#ifdef MV643XX_CHECKSUM_OFFLOAD_TX
+#ifdef MV643XX_ETH_CHECKSUM_OFFLOAD_TX
 	printk(KERN_NOTICE "%s: RX TCP/UDP Checksum Offload ON \n", dev->name);
 #endif
 
-#ifdef MV643XX_COAL
+#ifdef MV643XX_ETH_COAL
 	printk(KERN_NOTICE "%s: TX and RX Interrupt Coalescing ON \n",
 								dev->name);
 #endif
 
-#ifdef MV643XX_NAPI
+#ifdef MV643XX_ETH_NAPI
 	printk(KERN_NOTICE "%s: RX NAPI Enabled \n", dev->name);
 #endif
 
-	if (mp->tx_sram_size > 0)
+	if (mep->tx_sram_size > 0)
 		printk(KERN_NOTICE "%s: Using SRAM\n", dev->name);
 
 	return 0;
@@ -2919,14 +2920,14 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 static void mv643xx_eth_shutdown(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
+	struct mv643xx_eth_private *mep = netdev_priv(dev);
+	unsigned int port_num = mep->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	wrl(mp, INT_MASK(port_num), 0);
-	rdl(mp, INT_MASK(port_num));
+	wrl(mep, INT_MASK(port_num), 0);
+	rdl(mep, INT_MASK(port_num));
 
-	port_reset(mp);
+	port_reset(mep);
 }
 
 static struct platform_driver mv643xx_eth_driver = {
@@ -2940,7 +2941,7 @@ static struct platform_driver mv643xx_eth_driver = {
 };
 
 /*
- * mv643xx_init_module
+ * mv643xx_eth_init_module
  *
  * Registers the network drivers into the Linux kernel
  *
@@ -2948,7 +2949,7 @@ static struct platform_driver mv643xx_eth_driver = {
  *
  * Output :	N/A
  */
-static int __init mv643xx_init_module(void)
+static int __init mv643xx_eth_init_module(void)
 {
 	int rc;
 
@@ -2962,7 +2963,7 @@ static int __init mv643xx_init_module(void)
 }
 
 /*
- * mv643xx_cleanup_module
+ * mv643xx_eth_cleanup_module
  *
  * Registers the network drivers into the Linux kernel
  *
@@ -2970,14 +2971,14 @@ static int __init mv643xx_init_module(void)
  *
  * Output :	N/A
  */
-static void __exit mv643xx_cleanup_module(void)
+static void __exit mv643xx_eth_cleanup_module(void)
 {
 	platform_driver_unregister(&mv643xx_eth_driver);
 	platform_driver_unregister(&mv643xx_eth_shared_driver);
 }
 
-module_init(mv643xx_init_module);
-module_exit(mv643xx_cleanup_module);
+module_init(mv643xx_eth_init_module);
+module_exit(mv643xx_eth_cleanup_module);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
-- 
1.5.3.4

