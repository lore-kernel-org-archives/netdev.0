From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 16/39] mv643xx_eth: get rid of ETH_/ethernet_/eth_ prefixes
Date: Tue,  3 Jun 2008 13:02:31 +0200
Message-ID: <1212490974-23719-17-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48749 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754327AbYFCMA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:27 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fact that mv643xx_eth is an ethernet driver is pretty obvious,
and having a lot of internal-use-only functions and defines prefixed
with ETH_/ethernet_/eth_ prefixes is rather pointless.  So, get rid
of most of those prefixes.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  399 ++++++++++++++++++++++-----------------------
 1 files changed, 195 insertions(+), 204 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index ea1af64..4375b7c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -158,31 +158,31 @@ static char mv643xx_driver_version[] = "1.0";
 #define FORCE_LINK_PASS				(1 << 1)
 #define SERIAL_PORT_ENABLE			(1 << 0)
 
-#define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
-#define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
+#define DEFAULT_RX_QUEUE_SIZE		400
+#define DEFAULT_TX_QUEUE_SIZE		800
 
 /* SMI reg */
-#define ETH_SMI_BUSY		0x10000000	/* 0 - Write, 1 - Read	*/
-#define ETH_SMI_READ_VALID	0x08000000	/* 0 - Write, 1 - Read	*/
-#define ETH_SMI_OPCODE_WRITE	0		/* Completion of Read	*/
-#define ETH_SMI_OPCODE_READ	0x04000000	/* Operation is in progress */
+#define SMI_BUSY		0x10000000	/* 0 - Write, 1 - Read	*/
+#define SMI_READ_VALID		0x08000000	/* 0 - Write, 1 - Read	*/
+#define SMI_OPCODE_WRITE	0		/* Completion of Read	*/
+#define SMI_OPCODE_READ		0x04000000	/* Operation is in progress */
 
 /* typedefs */
 
-typedef enum _eth_func_ret_status {
+typedef enum _func_ret_status {
 	ETH_OK,			/* Returned as expected.		*/
 	ETH_ERROR,		/* Fundamental error.			*/
 	ETH_RETRY,		/* Could not process request. Try later.*/
 	ETH_END_OF_JOB,		/* Ring has nothing to process.		*/
 	ETH_QUEUE_FULL,		/* Ring resource error.			*/
 	ETH_QUEUE_LAST_RESOURCE	/* Ring resources about to exhaust.	*/
-} ETH_FUNC_RET_STATUS;
+} FUNC_RET_STATUS;
 
 /*
  * RX/TX descriptors.
  */
 #if defined(__BIG_ENDIAN)
-struct eth_rx_desc {
+struct rx_desc {
 	u16 byte_cnt;		/* Descriptor buffer byte count		*/
 	u16 buf_size;		/* Buffer size				*/
 	u32 cmd_sts;		/* Descriptor command status		*/
@@ -190,7 +190,7 @@ struct eth_rx_desc {
 	u32 buf_ptr;		/* Descriptor buffer pointer		*/
 };
 
-struct eth_tx_desc {
+struct tx_desc {
 	u16 byte_cnt;		/* buffer byte count			*/
 	u16 l4i_chk;		/* CPU provided TCP checksum		*/
 	u32 cmd_sts;		/* Command/status field			*/
@@ -198,7 +198,7 @@ struct eth_tx_desc {
 	u32 buf_ptr;		/* pointer to buffer for this descriptor*/
 };
 #elif defined(__LITTLE_ENDIAN)
-struct eth_rx_desc {
+struct rx_desc {
 	u32 cmd_sts;		/* Descriptor command status		*/
 	u16 buf_size;		/* Buffer size				*/
 	u16 byte_cnt;		/* Descriptor buffer byte count		*/
@@ -206,7 +206,7 @@ struct eth_rx_desc {
 	u32 next_desc_ptr;	/* Next descriptor pointer		*/
 };
 
-struct eth_tx_desc {
+struct tx_desc {
 	u32 cmd_sts;		/* Command/status field			*/
 	u16 l4i_chk;		/* CPU provided TCP checksum		*/
 	u16 byte_cnt;		/* buffer byte count			*/
@@ -218,28 +218,28 @@ struct eth_tx_desc {
 #endif
 
 /* RX & TX descriptor command */
-#define ETH_BUFFER_OWNED_BY_DMA			0x80000000
+#define BUFFER_OWNED_BY_DMA		0x80000000
 
 /* RX & TX descriptor status */
-#define ETH_ERROR_SUMMARY			0x00000001
+#define ERROR_SUMMARY			0x00000001
 
 /* RX descriptor status */
-#define ETH_LAYER_4_CHECKSUM_OK			0x40000000
-#define ETH_RX_ENABLE_INTERRUPT			0x20000000
-#define ETH_RX_FIRST_DESC			0x08000000
-#define ETH_RX_LAST_DESC			0x04000000
+#define LAYER_4_CHECKSUM_OK		0x40000000
+#define RX_ENABLE_INTERRUPT		0x20000000
+#define RX_FIRST_DESC			0x08000000
+#define RX_LAST_DESC			0x04000000
 
 /* TX descriptor command */
-#define ETH_TX_ENABLE_INTERRUPT			0x00800000
-#define ETH_GEN_CRC				0x00400000
-#define ETH_TX_FIRST_DESC			0x00200000
-#define ETH_TX_LAST_DESC			0x00100000
-#define ETH_ZERO_PADDING			0x00080000
-#define ETH_GEN_IP_V4_CHECKSUM			0x00040000
-#define ETH_GEN_TCP_UDP_CHECKSUM		0x00020000
-#define ETH_UDP_FRAME				0x00010000
+#define TX_ENABLE_INTERRUPT		0x00800000
+#define GEN_CRC				0x00400000
+#define TX_FIRST_DESC			0x00200000
+#define TX_LAST_DESC			0x00100000
+#define ZERO_PADDING			0x00080000
+#define GEN_IP_V4_CHECKSUM		0x00040000
+#define GEN_TCP_UDP_CHECKSUM		0x00020000
+#define UDP_FRAME			0x00010000
 
-#define ETH_TX_IHL_SHIFT			11
+#define TX_IHL_SHIFT			11
 
 
 /* Unified struct for Rx and Tx operations. The user is not required to	*/
@@ -255,7 +255,7 @@ struct pkt_info {
 
 /* global *******************************************************************/
 struct mv643xx_shared_private {
-	void __iomem *eth_base;
+	void __iomem *base;
 
 	/* used to protect SMI_REG, which is shared across ports */
 	spinlock_t phy_lock;
@@ -325,12 +325,12 @@ struct mv643xx_private {
 	u32 tx_clean_threshold;
 #endif
 
-	struct eth_rx_desc *p_rx_desc_area;
+	struct rx_desc *p_rx_desc_area;
 	dma_addr_t rx_desc_dma;
 	int rx_desc_area_size;
 	struct sk_buff **rx_skb;
 
-	struct eth_tx_desc *p_tx_desc_area;
+	struct tx_desc *p_tx_desc_area;
 	dma_addr_t tx_desc_dma;
 	int tx_desc_area_size;
 	struct sk_buff **tx_skb;
@@ -366,12 +366,12 @@ struct mv643xx_private {
 /* port register accessors **************************************************/
 static inline u32 rdl(struct mv643xx_private *mp, int offset)
 {
-	return readl(mp->shared->eth_base + offset);
+	return readl(mp->shared->base + offset);
 }
 
 static inline void wrl(struct mv643xx_private *mp, int offset, u32 data)
 {
-	writel(data, mp->shared->eth_base + offset);
+	writel(data, mp->shared->base + offset);
 }
 
 
@@ -437,7 +437,7 @@ static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
 static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev);
 
 /*
- * eth_rx_return_buff - Returns a Rx buffer back to the Rx ring.
+ * rx_return_buff - Returns a Rx buffer back to the Rx ring.
  *
  * DESCRIPTION:
  *	This routine returns a Rx buffer back to the Rx ring. It retrieves the
@@ -456,11 +456,11 @@ static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev);
  *	ETH_ERROR in case the routine can not access Rx desc ring.
  *	ETH_OK otherwise.
  */
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
+static FUNC_RET_STATUS rx_return_buff(struct mv643xx_private *mp,
 						struct pkt_info *p_pkt_info)
 {
 	int used_rx_desc;	/* Where to return Rx resource */
-	volatile struct eth_rx_desc *p_used_rx_desc;
+	volatile struct rx_desc *p_used_rx_desc;
 	unsigned long flags;
 
 	spin_lock_irqsave(&mp->lock, flags);
@@ -477,8 +477,7 @@ static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
 
 	/* Return the descriptor to DMA ownership */
 	wmb();
-	p_used_rx_desc->cmd_sts =
-			ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
+	p_used_rx_desc->cmd_sts = BUFFER_OWNED_BY_DMA | RX_ENABLE_INTERRUPT;
 	wmb();
 
 	/* Move the used descriptor pointer to the next descriptor */
@@ -515,12 +514,12 @@ static void mv643xx_eth_rx_refill_descs(struct net_device *dev)
 		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
 		if (unaligned)
 			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
-		pkt_info.cmd_sts = ETH_RX_ENABLE_INTERRUPT;
+		pkt_info.cmd_sts = RX_ENABLE_INTERRUPT;
 		pkt_info.byte_cnt = ETH_RX_SKB_SIZE;
 		pkt_info.buf_ptr = dma_map_single(NULL, skb->data,
 					ETH_RX_SKB_SIZE, DMA_FROM_DEVICE);
 		pkt_info.return_info = skb;
-		if (eth_rx_return_buff(mp, &pkt_info) != ETH_OK) {
+		if (rx_return_buff(mp, &pkt_info) != ETH_OK) {
 			printk(KERN_ERR
 				"%s: Error allocating RX Ring\n", dev->name);
 			break;
@@ -554,7 +553,7 @@ static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
 }
 
 /*
- * eth_port_receive - Get received information from Rx ring.
+ * port_receive - Get received information from Rx ring.
  *
  * DESCRIPTION:
  * 	This routine returns the received data to the caller. There is no
@@ -576,11 +575,11 @@ static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
  *	ETH_END_OF_JOB if there is no received data.
  *	ETH_OK otherwise.
  */
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
+static FUNC_RET_STATUS port_receive(struct mv643xx_private *mp,
 						struct pkt_info *p_pkt_info)
 {
 	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
-	volatile struct eth_rx_desc *p_rx_desc;
+	volatile struct rx_desc *p_rx_desc;
 	unsigned int command_status;
 	unsigned long flags;
 
@@ -601,7 +600,7 @@ static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
 	rmb();
 
 	/* Nothing to receive... */
-	if (command_status & (ETH_BUFFER_OWNED_BY_DMA)) {
+	if (command_status & BUFFER_OWNED_BY_DMA) {
 		spin_unlock_irqrestore(&mp->lock, flags);
 		return ETH_END_OF_JOB;
 	}
@@ -650,7 +649,7 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 	struct sk_buff *skb;
 	struct pkt_info pkt_info;
 
-	while (budget-- > 0 && eth_port_receive(mp, &pkt_info) == ETH_OK) {
+	while (budget-- > 0 && port_receive(mp, &pkt_info) == ETH_OK) {
 		dma_unmap_single(NULL, pkt_info.buf_ptr, ETH_RX_SKB_SIZE,
 							DMA_FROM_DEVICE);
 		mp->rx_desc_count--;
@@ -667,21 +666,20 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 		 * In case received a packet without first / last bits on OR
 		 * the error summary bit is on, the packets needs to be dropeed.
 		 */
-		if (((pkt_info.cmd_sts
-				& (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) !=
-					(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC))
-				|| (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)) {
+		if (((pkt_info.cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
+					(RX_FIRST_DESC | RX_LAST_DESC))
+				|| (pkt_info.cmd_sts & ERROR_SUMMARY)) {
 			stats->rx_dropped++;
-			if ((pkt_info.cmd_sts & (ETH_RX_FIRST_DESC |
-							ETH_RX_LAST_DESC)) !=
-				(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) {
+			if ((pkt_info.cmd_sts & (RX_FIRST_DESC |
+							RX_LAST_DESC)) !=
+				(RX_FIRST_DESC | RX_LAST_DESC)) {
 				if (net_ratelimit())
 					printk(KERN_ERR
 						"%s: Received packet spread "
 						"on multiple descriptors\n",
 						dev->name);
 			}
-			if (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)
+			if (pkt_info.cmd_sts & ERROR_SUMMARY)
 				stats->rx_errors++;
 
 			dev_kfree_skb_irq(skb);
@@ -692,7 +690,7 @@ static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 			 */
 			skb_put(skb, pkt_info.byte_cnt - 4);
 
-			if (pkt_info.cmd_sts & ETH_LAYER_4_CHECKSUM_OK) {
+			if (pkt_info.cmd_sts & LAYER_4_CHECKSUM_OK) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 				skb->csum = htons(
 					(pkt_info.cmd_sts & 0x0007fff8) >> 3);
@@ -770,9 +768,9 @@ static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
 }
 
 /**
- * eth_alloc_tx_desc_index - return the index of the next available tx desc
+ * alloc_tx_desc_index - return the index of the next available tx desc
  */
-static int eth_alloc_tx_desc_index(struct mv643xx_private *mp)
+static int alloc_tx_desc_index(struct mv643xx_private *mp)
 {
 	int tx_desc_curr;
 
@@ -787,30 +785,30 @@ static int eth_alloc_tx_desc_index(struct mv643xx_private *mp)
 }
 
 /**
- * eth_tx_fill_frag_descs - fill tx hw descriptors for an skb's fragments.
+ * tx_fill_frag_descs - fill tx hw descriptors for an skb's fragments.
  *
  * Ensure the data for each fragment to be transmitted is mapped properly,
  * then fill in descriptors in the tx hw queue.
  */
-static void eth_tx_fill_frag_descs(struct mv643xx_private *mp,
+static void tx_fill_frag_descs(struct mv643xx_private *mp,
 				   struct sk_buff *skb)
 {
 	int frag;
 	int tx_index;
-	struct eth_tx_desc *desc;
+	struct tx_desc *desc;
 
 	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
 		skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
 
-		tx_index = eth_alloc_tx_desc_index(mp);
+		tx_index = alloc_tx_desc_index(mp);
 		desc = &mp->p_tx_desc_area[tx_index];
 
-		desc->cmd_sts = ETH_BUFFER_OWNED_BY_DMA;
+		desc->cmd_sts = BUFFER_OWNED_BY_DMA;
 		/* Last Frag enables interrupt and frees the skb */
 		if (frag == (skb_shinfo(skb)->nr_frags - 1)) {
-			desc->cmd_sts |= ETH_ZERO_PADDING |
-					 ETH_TX_LAST_DESC |
-					 ETH_TX_ENABLE_INTERRUPT;
+			desc->cmd_sts |= ZERO_PADDING |
+					 TX_LAST_DESC |
+					 TX_ENABLE_INTERRUPT;
 			mp->tx_skb[tx_index] = skb;
 		} else
 			mp->tx_skb[tx_index] = NULL;
@@ -831,34 +829,32 @@ static inline __be16 sum16_as_be(__sum16 sum)
 }
 
 /**
- * eth_tx_submit_descs_for_skb - submit data from an skb to the tx hw
+ * tx_submit_descs_for_skb - submit data from an skb to the tx hw
  *
  * Ensure the data for an skb to be transmitted is mapped properly,
  * then fill in descriptors in the tx hw queue and start the hardware.
  */
-static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
+static void tx_submit_descs_for_skb(struct mv643xx_private *mp,
 					struct sk_buff *skb)
 {
 	int tx_index;
-	struct eth_tx_desc *desc;
+	struct tx_desc *desc;
 	u32 cmd_sts;
 	int length;
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 
-	cmd_sts = ETH_TX_FIRST_DESC | ETH_GEN_CRC | ETH_BUFFER_OWNED_BY_DMA;
+	cmd_sts = TX_FIRST_DESC | GEN_CRC | BUFFER_OWNED_BY_DMA;
 
-	tx_index = eth_alloc_tx_desc_index(mp);
+	tx_index = alloc_tx_desc_index(mp);
 	desc = &mp->p_tx_desc_area[tx_index];
 
 	if (nr_frags) {
-		eth_tx_fill_frag_descs(mp, skb);
+		tx_fill_frag_descs(mp, skb);
 
 		length = skb_headlen(skb);
 		mp->tx_skb[tx_index] = NULL;
 	} else {
-		cmd_sts |= ETH_ZERO_PADDING |
-			   ETH_TX_LAST_DESC |
-			   ETH_TX_ENABLE_INTERRUPT;
+		cmd_sts |= ZERO_PADDING | TX_LAST_DESC | TX_ENABLE_INTERRUPT;
 		length = skb->len;
 		mp->tx_skb[tx_index] = skb;
 	}
@@ -869,13 +865,13 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		BUG_ON(skb->protocol != htons(ETH_P_IP));
 
-		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
-			   ETH_GEN_IP_V4_CHECKSUM   |
-			   ip_hdr(skb)->ihl << ETH_TX_IHL_SHIFT;
+		cmd_sts |= GEN_TCP_UDP_CHECKSUM |
+			   GEN_IP_V4_CHECKSUM   |
+			   ip_hdr(skb)->ihl << TX_IHL_SHIFT;
 
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
-			cmd_sts |= ETH_UDP_FRAME;
+			cmd_sts |= UDP_FRAME;
 			desc->l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
 			break;
 		case IPPROTO_TCP:
@@ -886,7 +882,7 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 		}
 	} else {
 		/* Errata BTS #50, IHL must be 5 if no HW checksum */
-		cmd_sts |= 5 << ETH_TX_IHL_SHIFT;
+		cmd_sts |= 5 << TX_IHL_SHIFT;
 		desc->l4i_chk = 0;
 	}
 
@@ -929,7 +925,7 @@ static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	eth_tx_submit_descs_for_skb(mp, skb);
+	tx_submit_descs_for_skb(mp, skb);
 	stats->tx_bytes += skb->len;
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
@@ -944,10 +940,10 @@ static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 
 /* mii management interface *************************************************/
-static int ethernet_phy_get(struct mv643xx_private *mp);
+static int phy_addr_get(struct mv643xx_private *mp);
 
 /*
- * eth_port_read_smi_reg - Read PHY registers
+ * read_smi_reg - Read PHY registers
  *
  * DESCRIPTION:
  *	This routine utilize the SMI interface to interact with the PHY in
@@ -966,11 +962,11 @@ static int ethernet_phy_get(struct mv643xx_private *mp);
  *	true otherwise.
  *
  */
-static void eth_port_read_smi_reg(struct mv643xx_private *mp,
+static void read_smi_reg(struct mv643xx_private *mp,
 				unsigned int phy_reg, unsigned int *value)
 {
-	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
-	int phy_addr = ethernet_phy_get(mp);
+	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
+	int phy_addr = phy_addr_get(mp);
 	unsigned long flags;
 	int i;
 
@@ -978,7 +974,7 @@ static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
+	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
 		if (i == 1000) {
 			printk("%s: PHY busy timeout\n", mp->dev->name);
 			goto out;
@@ -986,11 +982,10 @@ static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 		udelay(10);
 	}
 
-	writel((phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ,
-		smi_reg);
+	writel((phy_addr << 16) | (phy_reg << 21) | SMI_OPCODE_READ, smi_reg);
 
 	/* now wait for the data to be valid */
-	for (i = 0; !(readl(smi_reg) & ETH_SMI_READ_VALID); i++) {
+	for (i = 0; !(readl(smi_reg) & SMI_READ_VALID); i++) {
 		if (i == 1000) {
 			printk("%s: PHY read timeout\n", mp->dev->name);
 			goto out;
@@ -1004,7 +999,7 @@ out:
 }
 
 /*
- * eth_port_write_smi_reg - Write to PHY registers
+ * write_smi_reg - Write to PHY registers
  *
  * DESCRIPTION:
  *	This routine utilize the SMI interface to interact with the PHY in
@@ -1023,11 +1018,11 @@ out:
  *	true otherwise.
  *
  */
-static void eth_port_write_smi_reg(struct mv643xx_private *mp,
+static void write_smi_reg(struct mv643xx_private *mp,
 				   unsigned int phy_reg, unsigned int value)
 {
-	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
-	int phy_addr = ethernet_phy_get(mp);
+	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
+	int phy_addr = phy_addr_get(mp);
 	unsigned long flags;
 	int i;
 
@@ -1035,7 +1030,7 @@ static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
+	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
 		if (i == 1000) {
 			printk("%s: PHY busy timeout\n", mp->dev->name);
 			goto out;
@@ -1044,7 +1039,7 @@ static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 	}
 
 	writel((phy_addr << 16) | (phy_reg << 21) |
-		ETH_SMI_OPCODE_WRITE | (value & 0xffff), smi_reg);
+		SMI_OPCODE_WRITE | (value & 0xffff), smi_reg);
 out:
 	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
 }
@@ -1052,7 +1047,7 @@ out:
 
 /* mib counters *************************************************************/
 /*
- * eth_clear_mib_counters - Clear all MIB counters
+ * clear_mib_counters - Clear all MIB counters
  *
  * DESCRIPTION:
  *	This function clears all MIB counters of a specific ethernet port.
@@ -1068,7 +1063,7 @@ out:
  *	MIB counter value.
  *
  */
-static void eth_clear_mib_counters(struct mv643xx_private *mp)
+static void clear_mib_counters(struct mv643xx_private *mp)
 {
 	unsigned int port_num = mp->port_num;
 	int i;
@@ -1083,7 +1078,7 @@ static inline u32 read_mib(struct mv643xx_private *mp, int offset)
 	return rdl(mp, MIB_COUNTERS(mp->port_num) + offset);
 }
 
-static void eth_update_mib_counters(struct mv643xx_private *mp)
+static void update_mib_counters(struct mv643xx_private *mp)
 {
 	struct mv643xx_mib_counters *p = &mp->mib_counters;
 
@@ -1249,7 +1244,7 @@ static void mv643xx_get_ethtool_stats(struct net_device *netdev,
 	struct mv643xx_private *mp = netdev->priv;
 	int i;
 
-	eth_update_mib_counters(mp);
+	update_mib_counters(mp);
 
 	for (i = 0; i < MV643XX_STATS_LEN; i++) {
 		char *p = (char *)mp+mv643xx_gstrings_stats[i].stat_offset;
@@ -1283,10 +1278,9 @@ static const struct ethtool_ops mv643xx_ethtool_ops = {
 
 /* address handling *********************************************************/
 /*
- * eth_port_uc_addr_get - Read the MAC address from the port's hw registers
+ * uc_addr_get - Read the MAC address from the port's hw registers
  */
-static void eth_port_uc_addr_get(struct mv643xx_private *mp,
-				 unsigned char *p_addr)
+static void uc_addr_get(struct mv643xx_private *mp, unsigned char *p_addr)
 {
 	unsigned int port_num = mp->port_num;
 	unsigned int mac_h;
@@ -1304,7 +1298,7 @@ static void eth_port_uc_addr_get(struct mv643xx_private *mp,
 }
 
 /*
- * eth_port_init_mac_tables - Clear all entrance in the UC, SMC and OMC tables
+ * init_mac_tables - Clear all entrance in the UC, SMC and OMC tables
  *
  * DESCRIPTION:
  *	Go through all the DA filter tables (Unicast, Special Multicast &
@@ -1319,7 +1313,7 @@ static void eth_port_uc_addr_get(struct mv643xx_private *mp,
  * RETURN:
  *	None.
  */
-static void eth_port_init_mac_tables(struct mv643xx_private *mp)
+static void init_mac_tables(struct mv643xx_private *mp)
 {
 	unsigned int port_num = mp->port_num;
 	int table_index;
@@ -1345,7 +1339,7 @@ static void eth_port_init_mac_tables(struct mv643xx_private *mp)
  *	3-1	Queue			(ETH_Q0=0)
  *	7-4	Reserved = 0;
  */
-static void eth_port_set_filter_table_entry(struct mv643xx_private *mp,
+static void set_filter_table_entry(struct mv643xx_private *mp,
 					    int table, unsigned char entry)
 {
 	unsigned int table_reg;
@@ -1362,10 +1356,9 @@ static void eth_port_set_filter_table_entry(struct mv643xx_private *mp,
 }
 
 /*
- * eth_port_uc_addr_set - Write a MAC address into the port's hw registers
+ * uc_addr_set - Write a MAC address into the port's hw registers
  */
-static void eth_port_uc_addr_set(struct mv643xx_private *mp,
-				 unsigned char *p_addr)
+static void uc_addr_set(struct mv643xx_private *mp, unsigned char *p_addr)
 {
 	unsigned int port_num = mp->port_num;
 	unsigned int mac_h;
@@ -1381,7 +1374,7 @@ static void eth_port_uc_addr_set(struct mv643xx_private *mp,
 
 	/* Accept frames with this address */
 	table = UNICAST_TABLE(port_num);
-	eth_port_set_filter_table_entry(mp, table, p_addr[5] & 0x0f);
+	set_filter_table_entry(mp, table, p_addr[5] & 0x0f);
 }
 
 /*
@@ -1396,8 +1389,8 @@ static void mv643xx_eth_update_mac_address(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 
-	eth_port_init_mac_tables(mp);
-	eth_port_uc_addr_set(mp, dev->dev_addr);
+	init_mac_tables(mp);
+	uc_addr_set(mp, dev->dev_addr);
 }
 
 /*
@@ -1423,7 +1416,7 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 }
 
 /*
- * eth_port_mc_addr - Multicast address settings.
+ * mc_addr - Multicast address settings.
  *
  * The MV device supports multicast using two tables:
  * 1) Special Multicast Table for MAC addresses of the form
@@ -1433,10 +1426,10 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
  * 2) Other Multicast Table for multicast of another type. A CRC-8bit
  *    is used as an index to the Other Multicast Table entries in the
  *    DA-Filter table.  This function calculates the CRC-8bit value.
- * In either case, eth_port_set_filter_table_entry() is then called
+ * In either case, set_filter_table_entry() is then called
  * to set to set the actual table entry.
  */
-static void eth_port_mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
+static void mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
 {
 	unsigned int port_num = mp->port_num;
 	unsigned int mac_h;
@@ -1450,7 +1443,7 @@ static void eth_port_mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
 	if ((p_addr[0] == 0x01) && (p_addr[1] == 0x00) &&
 	    (p_addr[2] == 0x5E) && (p_addr[3] == 0x00) && (p_addr[4] == 0x00)) {
 		table = SPECIAL_MCAST_TABLE(port_num);
-		eth_port_set_filter_table_entry(mp, table, p_addr[5]);
+		set_filter_table_entry(mp, table, p_addr[5]);
 		return;
 	}
 
@@ -1523,20 +1516,20 @@ static void eth_port_mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
 		crc_result = crc_result | (crc[i] << i);
 
 	table = OTHER_MCAST_TABLE(port_num);
-	eth_port_set_filter_table_entry(mp, table, crc_result);
+	set_filter_table_entry(mp, table, crc_result);
 }
 
 /*
  * Set the entire multicast list based on dev->mc_list.
  */
-static void eth_port_set_multicast_list(struct net_device *dev)
+static void set_multicast_list(struct net_device *dev)
 {
 
 	struct dev_mc_list	*mc_list;
 	int			i;
 	int			table_index;
 	struct mv643xx_private	*mp = netdev_priv(dev);
-	unsigned int		eth_port_num = mp->port_num;
+	unsigned int		port_num = mp->port_num;
 
 	/* If the device is in promiscuous mode or in all multicast mode,
 	 * we will fully populate both multicast tables with accept.
@@ -1552,7 +1545,7 @@ static void eth_port_set_multicast_list(struct net_device *dev)
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			wrl(mp, SPECIAL_MCAST_TABLE(eth_port_num) + table_index, 0x01010101);
+			wrl(mp, SPECIAL_MCAST_TABLE(port_num) + table_index, 0x01010101);
 
 			/* Set all entries in DA filter other multicast
 			 * table (Ex_dFOMT)
@@ -1562,7 +1555,7 @@ static void eth_port_set_multicast_list(struct net_device *dev)
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			wrl(mp, OTHER_MCAST_TABLE(eth_port_num) + table_index, 0x01010101);
+			wrl(mp, OTHER_MCAST_TABLE(port_num) + table_index, 0x01010101);
 		}
 		return;
 	}
@@ -1572,10 +1565,10 @@ static void eth_port_set_multicast_list(struct net_device *dev)
 	 */
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mp, SPECIAL_MCAST_TABLE(eth_port_num) + table_index, 0);
+		wrl(mp, SPECIAL_MCAST_TABLE(port_num) + table_index, 0);
 
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mp, OTHER_MCAST_TABLE(eth_port_num) + table_index, 0);
+		wrl(mp, OTHER_MCAST_TABLE(port_num) + table_index, 0);
 	}
 
 	/* Get pointer to net_device multicast list and add each one... */
@@ -1583,7 +1576,7 @@ static void eth_port_set_multicast_list(struct net_device *dev)
 			(i < 256) && (mc_list != NULL) && (i < dev->mc_count);
 			i++, mc_list = mc_list->next)
 		if (mc_list->dmi_addrlen == 6)
-			eth_port_mc_addr(mp, mc_list->dmi_addr);
+			mc_addr(mp, mc_list->dmi_addr);
 }
 
 /*
@@ -1606,7 +1599,7 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 		config_reg &= ~0x00000001;
 	wrl(mp, PORT_CONFIG(mp->port_num), config_reg);
 
-	eth_port_set_multicast_list(dev);
+	set_multicast_list(dev);
 }
 
 
@@ -1635,22 +1628,22 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
  */
 static void ether_init_rx_desc_ring(struct mv643xx_private *mp)
 {
-	volatile struct eth_rx_desc *p_rx_desc;
+	volatile struct rx_desc *p_rx_desc;
 	int rx_desc_num = mp->rx_ring_size;
 	int i;
 
 	/* initialize the next_desc_ptr links in the Rx descriptors ring */
-	p_rx_desc = (struct eth_rx_desc *)mp->p_rx_desc_area;
+	p_rx_desc = (struct rx_desc *)mp->p_rx_desc_area;
 	for (i = 0; i < rx_desc_num; i++) {
 		p_rx_desc[i].next_desc_ptr = mp->rx_desc_dma +
-			((i + 1) % rx_desc_num) * sizeof(struct eth_rx_desc);
+			((i + 1) % rx_desc_num) * sizeof(struct rx_desc);
 	}
 
 	/* Save Rx desc pointer to driver struct. */
 	mp->rx_curr_desc_q = 0;
 	mp->rx_used_desc_q = 0;
 
-	mp->rx_desc_area_size = rx_desc_num * sizeof(struct eth_rx_desc);
+	mp->rx_desc_area_size = rx_desc_num * sizeof(struct rx_desc);
 }
 
 static void mv643xx_eth_free_rx_rings(struct net_device *dev)
@@ -1707,20 +1700,20 @@ static void mv643xx_eth_free_rx_rings(struct net_device *dev)
 static void ether_init_tx_desc_ring(struct mv643xx_private *mp)
 {
 	int tx_desc_num = mp->tx_ring_size;
-	struct eth_tx_desc *p_tx_desc;
+	struct tx_desc *p_tx_desc;
 	int i;
 
 	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
-	p_tx_desc = (struct eth_tx_desc *)mp->p_tx_desc_area;
+	p_tx_desc = (struct tx_desc *)mp->p_tx_desc_area;
 	for (i = 0; i < tx_desc_num; i++) {
 		p_tx_desc[i].next_desc_ptr = mp->tx_desc_dma +
-			((i + 1) % tx_desc_num) * sizeof(struct eth_tx_desc);
+			((i + 1) % tx_desc_num) * sizeof(struct tx_desc);
 	}
 
 	mp->tx_curr_desc_q = 0;
 	mp->tx_used_desc_q = 0;
 
-	mp->tx_desc_area_size = tx_desc_num * sizeof(struct eth_tx_desc);
+	mp->tx_desc_area_size = tx_desc_num * sizeof(struct tx_desc);
 }
 
 /**
@@ -1731,7 +1724,7 @@ static void ether_init_tx_desc_ring(struct mv643xx_private *mp)
 static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	struct eth_tx_desc *desc;
+	struct tx_desc *desc;
 	u32 cmd_sts;
 	struct sk_buff *skb;
 	unsigned long flags;
@@ -1753,7 +1746,7 @@ static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 		desc = &mp->p_tx_desc_area[tx_index];
 		cmd_sts = desc->cmd_sts;
 
-		if (!force && (cmd_sts & ETH_BUFFER_OWNED_BY_DMA)) {
+		if (!force && (cmd_sts & BUFFER_OWNED_BY_DMA)) {
 			spin_unlock_irqrestore(&mp->lock, flags);
 			return released;
 		}
@@ -1767,14 +1760,14 @@ static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 		if (skb)
 			mp->tx_skb[tx_index] = NULL;
 
-		if (cmd_sts & ETH_ERROR_SUMMARY) {
+		if (cmd_sts & ERROR_SUMMARY) {
 			printk("%s: Error in TX\n", dev->name);
 			dev->stats.tx_errors++;
 		}
 
 		spin_unlock_irqrestore(&mp->lock, flags);
 
-		if (cmd_sts & ETH_TX_FIRST_DESC)
+		if (cmd_sts & TX_FIRST_DESC)
 			dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
 		else
 			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
@@ -1824,7 +1817,7 @@ static void mv643xx_eth_free_tx_rings(struct net_device *dev)
 
 
 /* netdev ops and related ***************************************************/
-static void eth_port_reset(struct mv643xx_private *mp);
+static void port_reset(struct mv643xx_private *mp);
 
 /* Set the mv643xx port configuration register for the speed/duplex mode. */
 static void mv643xx_eth_update_pscr(struct net_device *dev,
@@ -1887,19 +1880,19 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct mv643xx_private *mp = netdev_priv(dev);
-	u32 eth_int_cause, eth_int_cause_ext = 0;
+	u32 int_cause, int_cause_ext = 0;
 	unsigned int port_num = mp->port_num;
 
 	/* Read interrupt cause registers */
-	eth_int_cause = rdl(mp, INT_CAUSE(port_num)) & (INT_RX | INT_EXT);
-	if (eth_int_cause & INT_EXT) {
-		eth_int_cause_ext = rdl(mp, INT_CAUSE_EXT(port_num))
+	int_cause = rdl(mp, INT_CAUSE(port_num)) & (INT_RX | INT_EXT);
+	if (int_cause & INT_EXT) {
+		int_cause_ext = rdl(mp, INT_CAUSE_EXT(port_num))
 				& (INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
-		wrl(mp, INT_CAUSE_EXT(port_num), ~eth_int_cause_ext);
+		wrl(mp, INT_CAUSE_EXT(port_num), ~int_cause_ext);
 	}
 
 	/* PHY status changed */
-	if (eth_int_cause_ext & (INT_EXT_LINK | INT_EXT_PHY)) {
+	if (int_cause_ext & (INT_EXT_LINK | INT_EXT_PHY)) {
 		struct ethtool_cmd cmd;
 
 		if (mii_link_ok(&mp->mii)) {
@@ -1919,7 +1912,7 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	}
 
 #ifdef MV643XX_NAPI
-	if (eth_int_cause & INT_RX) {
+	if (int_cause & INT_RX) {
 		/* schedule the NAPI poll routine to maintain port */
 		wrl(mp, INT_MASK(port_num), 0x00000000);
 
@@ -1929,24 +1922,24 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 		netif_rx_schedule(dev, &mp->napi);
 	}
 #else
-	if (eth_int_cause & INT_RX)
+	if (int_cause & INT_RX)
 		mv643xx_eth_receive_queue(dev, INT_MAX);
 #endif
-	if (eth_int_cause_ext & INT_EXT_TX)
+	if (int_cause_ext & INT_EXT_TX)
 		mv643xx_eth_free_completed_tx_descs(dev);
 
 	/*
 	 * If no real interrupt occured, exit.
 	 * This can happen when using gigE interrupt coalescing mechanism.
 	 */
-	if ((eth_int_cause == 0x0) && (eth_int_cause_ext == 0x0))
+	if ((int_cause == 0x0) && (int_cause_ext == 0x0))
 		return IRQ_NONE;
 
 	return IRQ_HANDLED;
 }
 
 /*
- * ethernet_phy_reset - Reset Ethernet port PHY.
+ * phy_reset - Reset Ethernet port PHY.
  *
  * DESCRIPTION:
  *	This routine utilizes the SMI interface to reset the ethernet port PHY.
@@ -1961,24 +1954,24 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
  *	None.
  *
  */
-static void ethernet_phy_reset(struct mv643xx_private *mp)
+static void phy_reset(struct mv643xx_private *mp)
 {
 	unsigned int phy_reg_data;
 
 	/* Reset the PHY */
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data);
+	read_smi_reg(mp, 0, &phy_reg_data);
 	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
-	eth_port_write_smi_reg(mp, 0, phy_reg_data);
+	write_smi_reg(mp, 0, phy_reg_data);
 
 	/* wait for PHY to come out of reset */
 	do {
 		udelay(1);
-		eth_port_read_smi_reg(mp, 0, &phy_reg_data);
+		read_smi_reg(mp, 0, &phy_reg_data);
 	} while (phy_reg_data & 0x8000);
 }
 
 /*
- * eth_port_start - Start the Ethernet port activity.
+ * port_start - Start the Ethernet port activity.
  *
  * DESCRIPTION:
  *	This routine prepares the Ethernet port for Rx and Tx activity:
@@ -2004,7 +1997,7 @@ static void ethernet_phy_reset(struct mv643xx_private *mp)
  * RETURN:
  *	None.
  */
-static void eth_port_start(struct net_device *dev)
+static void port_start(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
@@ -2015,15 +2008,15 @@ static void eth_port_start(struct net_device *dev)
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
 	wrl(mp, TXQ_CURRENT_DESC_PTR(port_num),
-		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
+		(u32)((struct tx_desc *)mp->tx_desc_dma + tx_curr_desc));
 
 	/* Assignment of Rx CRDP of given queue */
 	rx_curr_desc = mp->rx_curr_desc_q;
 	wrl(mp, RXQ_CURRENT_DESC_PTR(port_num),
-		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
+		(u32)((struct rx_desc *)mp->rx_desc_dma + rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
-	eth_port_uc_addr_set(mp, dev->dev_addr);
+	uc_addr_set(mp, dev->dev_addr);
 
 	/*
 	 * Receive all unmatched unicast, TCP, UDP, BPDU and broadcast
@@ -2063,14 +2056,14 @@ static void eth_port_start(struct net_device *dev)
 
 	/* save phy settings across reset */
 	mv643xx_get_settings(dev, &ethtool_cmd);
-	ethernet_phy_reset(mp);
+	phy_reset(mp);
 	mv643xx_set_settings(dev, &ethtool_cmd);
 }
 
 #ifdef MV643XX_COAL
 
 /*
- * eth_port_set_rx_coal - Sets coalescing interrupt mechanism on RX path
+ * set_rx_coal - Sets coalescing interrupt mechanism on RX path
  *
  * DESCRIPTION:
  *	This routine sets the RX coalescing interrupt mechanism parameter.
@@ -2091,7 +2084,7 @@ static void eth_port_start(struct net_device *dev)
  *	The interrupt coalescing value set in the gigE port.
  *
  */
-static unsigned int eth_port_set_rx_coal(struct mv643xx_private *mp,
+static unsigned int set_rx_coal(struct mv643xx_private *mp,
 					unsigned int delay)
 {
 	unsigned int port_num = mp->port_num;
@@ -2108,7 +2101,7 @@ static unsigned int eth_port_set_rx_coal(struct mv643xx_private *mp,
 #endif
 
 /*
- * eth_port_set_tx_coal - Sets coalescing interrupt mechanism on TX path
+ * set_tx_coal - Sets coalescing interrupt mechanism on TX path
  *
  * DESCRIPTION:
  *	This routine sets the TX coalescing interrupt mechanism parameter.
@@ -2129,7 +2122,7 @@ static unsigned int eth_port_set_rx_coal(struct mv643xx_private *mp,
  *	The interrupt coalescing value set in the gigE port.
  *
  */
-static unsigned int eth_port_set_tx_coal(struct mv643xx_private *mp,
+static unsigned int set_tx_coal(struct mv643xx_private *mp,
 					unsigned int delay)
 {
 	unsigned int coal = ((mp->shared->t_clk / 1000000) * delay) / 64;
@@ -2141,7 +2134,7 @@ static unsigned int eth_port_set_tx_coal(struct mv643xx_private *mp,
 }
 
 /*
- * eth_port_init - Initialize the Ethernet port driver
+ * port_init - Initialize the Ethernet port driver
  *
  * DESCRIPTION:
  *	This function prepares the ethernet port to start its activity:
@@ -2151,7 +2144,7 @@ static unsigned int eth_port_set_tx_coal(struct mv643xx_private *mp,
  *	3) Enable SDMA access to all four DRAM banks as well as internal SRAM.
  *	4) Clean MAC tables. The reset status of those tables is unknown.
  *	5) Set PHY address.
- *	Note: Call this routine prior to eth_port_start routine and after
+ *	Note: Call this routine prior to port_start routine and after
  *	setting user values in the user fields of Ethernet port control
  *	struct.
  *
@@ -2164,13 +2157,13 @@ static unsigned int eth_port_set_tx_coal(struct mv643xx_private *mp,
  * RETURN:
  *	None.
  */
-static void eth_port_init(struct mv643xx_private *mp)
+static void port_init(struct mv643xx_private *mp)
 {
 	mp->rx_resource_err = 0;
 
-	eth_port_reset(mp);
+	port_reset(mp);
 
-	eth_port_init_mac_tables(mp);
+	init_mac_tables(mp);
 }
 
 /*
@@ -2206,7 +2199,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	eth_port_init(mp);
+	port_init(mp);
 
 	memset(&mp->timeout, 0, sizeof(struct timer_list));
 	mp->timeout.function = mv643xx_eth_rx_refill_descs_timer_wrapper;
@@ -2230,7 +2223,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	/* Allocate TX ring */
 	mp->tx_desc_count = 0;
-	size = mp->tx_ring_size * sizeof(struct eth_tx_desc);
+	size = mp->tx_ring_size * sizeof(struct tx_desc);
 	mp->tx_desc_area_size = size;
 
 	if (mp->tx_sram_size) {
@@ -2255,7 +2248,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	/* Allocate RX ring */
 	mp->rx_desc_count = 0;
-	size = mp->rx_ring_size * sizeof(struct eth_rx_desc);
+	size = mp->rx_ring_size * sizeof(struct rx_desc);
 	mp->rx_desc_area_size = size;
 
 	if (mp->rx_sram_size) {
@@ -2290,17 +2283,15 @@ static int mv643xx_eth_open(struct net_device *dev)
 	napi_enable(&mp->napi);
 #endif
 
-	eth_port_start(dev);
+	port_start(dev);
 
 	/* Interrupt Coalescing */
 
 #ifdef MV643XX_COAL
-	mp->rx_int_coal =
-		eth_port_set_rx_coal(mp, MV643XX_RX_COAL);
+	mp->rx_int_coal = set_rx_coal(mp, MV643XX_RX_COAL);
 #endif
 
-	mp->tx_int_coal =
-		eth_port_set_tx_coal(mp, MV643XX_TX_COAL);
+	mp->tx_int_coal = set_tx_coal(mp, MV643XX_TX_COAL);
 
 	/* Unmask phy and link status changes interrupts */
 	wrl(mp, INT_MASK_EXT(port_num), INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
@@ -2321,7 +2312,7 @@ out_free_irq:
 }
 
 /*
- * eth_port_reset - Reset Ethernet port
+ * port_reset - Reset Ethernet port
  *
  * DESCRIPTION:
  * 	This routine resets the chip by aborting any SDMA engine activity and
@@ -2338,7 +2329,7 @@ out_free_irq:
  *	None.
  *
  */
-static void eth_port_reset(struct mv643xx_private *mp)
+static void port_reset(struct mv643xx_private *mp)
 {
 	unsigned int port_num = mp->port_num;
 	unsigned int reg_data;
@@ -2347,7 +2338,7 @@ static void eth_port_reset(struct mv643xx_private *mp)
 	mv643xx_eth_port_disable_rx(mp);
 
 	/* Clear all MIB counters */
-	eth_clear_mib_counters(mp);
+	clear_mib_counters(mp);
 
 	/* Reset the Enable bit in the Configuration Register */
 	reg_data = rdl(mp, PORT_SERIAL_CONTROL(port_num));
@@ -2383,7 +2374,7 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 
-	eth_port_reset(mp);
+	port_reset(mp);
 
 	mv643xx_eth_free_tx_rings(dev);
 	mv643xx_eth_free_rx_rings(dev);
@@ -2447,8 +2438,8 @@ static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
 
 	netif_stop_queue(dev);
 
-	eth_port_reset(mp);
-	eth_port_start(dev);
+	port_reset(mp);
+	port_start(dev);
 
 	if (mp->tx_ring_size - mp->tx_desc_count >= MAX_DESCS_PER_SKB)
 		netif_wake_queue(dev);
@@ -2496,14 +2487,14 @@ static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location)
 	struct mv643xx_private *mp = netdev_priv(dev);
 	int val;
 
-	eth_port_read_smi_reg(mp, location, &val);
+	read_smi_reg(mp, location, &val);
 	return val;
 }
 
 static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	eth_port_write_smi_reg(mp, location, val);
+	write_smi_reg(mp, location, val);
 }
 
 
@@ -2511,7 +2502,7 @@ static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location,
 static void mv643xx_eth_conf_mbus_windows(struct mv643xx_shared_private *msp,
 					  struct mbus_dram_target_info *dram)
 {
-	void __iomem *base = msp->eth_base;
+	void __iomem *base = msp->base;
 	u32 win_enable;
 	u32 win_protect;
 	int i;
@@ -2564,8 +2555,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 		goto out;
 	memset(msp, 0, sizeof(*msp));
 
-	msp->eth_base = ioremap(res->start, res->end - res->start + 1);
-	if (msp->eth_base == NULL)
+	msp->base = ioremap(res->start, res->end - res->start + 1);
+	if (msp->base == NULL)
 		goto out_free;
 
 	spin_lock_init(&msp->phy_lock);
@@ -2591,7 +2582,7 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
 	struct mv643xx_shared_private *msp = platform_get_drvdata(pdev);
 
-	iounmap(msp->eth_base);
+	iounmap(msp->base);
 	kfree(msp);
 
 	return 0;
@@ -2607,7 +2598,7 @@ static struct platform_driver mv643xx_eth_shared_driver = {
 };
 
 /*
- * ethernet_phy_set - Set the ethernet port PHY address.
+ * phy_addr_set - Set the ethernet port PHY address.
  *
  * DESCRIPTION:
  *	This routine sets the given ethernet port PHY address.
@@ -2623,7 +2614,7 @@ static struct platform_driver mv643xx_eth_shared_driver = {
  *	None.
  *
  */
-static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr)
+static void phy_addr_set(struct mv643xx_private *mp, int phy_addr)
 {
 	u32 reg_data;
 	int addr_shift = 5 * mp->port_num;
@@ -2635,7 +2626,7 @@ static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr)
 }
 
 /*
- * ethernet_phy_get - Get the ethernet port PHY address.
+ * phy_addr_get - Get the ethernet port PHY address.
  *
  * DESCRIPTION:
  *	This routine returns the given ethernet port PHY address.
@@ -2650,7 +2641,7 @@ static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr)
  *	PHY address.
  *
  */
-static int ethernet_phy_get(struct mv643xx_private *mp)
+static int phy_addr_get(struct mv643xx_private *mp)
 {
 	unsigned int reg_data;
 
@@ -2660,7 +2651,7 @@ static int ethernet_phy_get(struct mv643xx_private *mp)
 }
 
 /*
- * ethernet_phy_detect - Detect whether a phy is present
+ * phy_detect - Detect whether a phy is present
  *
  * DESCRIPTION:
  *	This function tests whether there is a PHY present on
@@ -2677,22 +2668,22 @@ static int ethernet_phy_get(struct mv643xx_private *mp)
  *	-ENODEV on failure
  *
  */
-static int ethernet_phy_detect(struct mv643xx_private *mp)
+static int phy_detect(struct mv643xx_private *mp)
 {
 	unsigned int phy_reg_data0;
 	int auto_neg;
 
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
+	read_smi_reg(mp, 0, &phy_reg_data0);
 	auto_neg = phy_reg_data0 & 0x1000;
 	phy_reg_data0 ^= 0x1000;	/* invert auto_neg */
-	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
+	write_smi_reg(mp, 0, phy_reg_data0);
 
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
+	read_smi_reg(mp, 0, &phy_reg_data0);
 	if ((phy_reg_data0 & 0x1000) == auto_neg)
 		return -ENODEV;				/* change didn't take */
 
 	phy_reg_data0 ^= 0x1000;
-	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
+	write_smi_reg(mp, 0, phy_reg_data0);
 	return 0;
 }
 
@@ -2822,15 +2813,15 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 		mp->shared_smi = platform_get_drvdata(pd->shared_smi);
 
 	/* set default config values */
-	eth_port_uc_addr_get(mp, dev->dev_addr);
-	mp->rx_ring_size = PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
-	mp->tx_ring_size = PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
+	uc_addr_get(mp, dev->dev_addr);
+	mp->rx_ring_size = DEFAULT_RX_QUEUE_SIZE;
+	mp->tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 
 	if (is_valid_ether_addr(pd->mac_addr))
 		memcpy(dev->dev_addr, pd->mac_addr, 6);
 
 	if (pd->phy_addr || pd->force_phy_addr)
-		ethernet_phy_set(mp, pd->phy_addr);
+		phy_addr_set(mp, pd->phy_addr);
 
 	if (pd->rx_queue_size)
 		mp->rx_ring_size = pd->rx_queue_size;
@@ -2855,18 +2846,18 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mp->mii.dev = dev;
 	mp->mii.mdio_read = mv643xx_mdio_read;
 	mp->mii.mdio_write = mv643xx_mdio_write;
-	mp->mii.phy_id = ethernet_phy_get(mp);
+	mp->mii.phy_id = phy_addr_get(mp);
 	mp->mii.phy_id_mask = 0x3f;
 	mp->mii.reg_num_mask = 0x1f;
 
-	err = ethernet_phy_detect(mp);
+	err = phy_detect(mp);
 	if (err) {
 		pr_debug("%s: No PHY detected at addr %d\n",
-				dev->name, ethernet_phy_get(mp));
+				dev->name, phy_addr_get(mp));
 		goto out;
 	}
 
-	ethernet_phy_reset(mp);
+	phy_reset(mp);
 	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
 	mv643xx_init_ethtool_cmd(dev, mp->mii.phy_id, speed, duplex, &cmd);
 	mv643xx_eth_update_pscr(dev, &cmd);
@@ -2935,7 +2926,7 @@ static void mv643xx_eth_shutdown(struct platform_device *pdev)
 	wrl(mp, INT_MASK(port_num), 0);
 	rdl(mp, INT_MASK(port_num));
 
-	eth_port_reset(mp);
+	port_reset(mp);
 }
 
 static struct platform_driver mv643xx_eth_driver = {
-- 
1.5.3.4

