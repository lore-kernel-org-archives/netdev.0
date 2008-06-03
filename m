From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 01/39] mv643xx_eth: reverse topological sort of functions
Date: Tue,  3 Jun 2008 13:02:16 +0200
Message-ID: <1212490974-23719-2-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48765 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756209AbYFCMAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:44 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch performs a reverse topological sort of all functions in
mv643xx_eth.c, so that we can get rid of all forward declarations,
and end up with a more understandable driver due to related functions
being grouped together.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c | 3438 ++++++++++++++++++++++-----------------------
 1 files changed, 1646 insertions(+), 1792 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b7915cd..835b85d 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -62,6 +62,9 @@
 #include <asm/delay.h>
 #include <asm/dma-mapping.h>
 
+static char mv643xx_driver_name[] = "mv643xx_eth";
+static char mv643xx_driver_version[] = "1.0";
+
 #define MV643XX_CHECKSUM_OFFLOAD_TX
 #define MV643XX_NAPI
 #define MV643XX_TX_FAST_REFILL
@@ -478,7 +481,21 @@ struct pkt_info {
 	struct sk_buff *return_info;	/* User resource return information */
 };
 
-/* Ethernet port specific information */
+
+/* global *******************************************************************/
+struct mv643xx_shared_private {
+	void __iomem *eth_base;
+
+	/* used to protect SMI_REG, which is shared across ports */
+	spinlock_t phy_lock;
+
+	u32 win_protect;
+
+	unsigned int t_clk;
+};
+
+
+/* per-port *****************************************************************/
 struct mv643xx_mib_counters {
 	u64 good_octets_received;
 	u32 bad_octets_received;
@@ -512,17 +529,6 @@ struct mv643xx_mib_counters {
 	u32 late_collision;
 };
 
-struct mv643xx_shared_private {
-	void __iomem *eth_base;
-
-	/* used to protect SMI_REG, which is shared across ports */
-	spinlock_t phy_lock;
-
-	u32 win_protect;
-
-	unsigned int t_clk;
-};
-
 struct mv643xx_private {
 	struct mv643xx_shared_private *shared;
 	int port_num;			/* User Ethernet port number	*/
@@ -585,93 +591,135 @@ struct mv643xx_private {
 	struct mii_if_info mii;
 };
 
-/* Static function declarations */
-static void eth_port_init(struct mv643xx_private *mp);
-static void eth_port_reset(struct mv643xx_private *mp);
-static void eth_port_start(struct net_device *dev);
 
-static void ethernet_phy_reset(struct mv643xx_private *mp);
+/* port register accessors **************************************************/
+static inline u32 rdl(struct mv643xx_private *mp, int offset)
+{
+	return readl(mp->shared->eth_base + offset);
+}
 
-static void eth_port_write_smi_reg(struct mv643xx_private *mp,
-				   unsigned int phy_reg, unsigned int value);
+static inline void wrl(struct mv643xx_private *mp, int offset, u32 data)
+{
+	writel(data, mp->shared->eth_base + offset);
+}
 
-static void eth_port_read_smi_reg(struct mv643xx_private *mp,
-				  unsigned int phy_reg, unsigned int *value);
 
-static void eth_clear_mib_counters(struct mv643xx_private *mp);
+/* rxq/txq helper functions *************************************************/
+static void mv643xx_eth_port_enable_rx(struct mv643xx_private *mp,
+					unsigned int queues)
+{
+	wrl(mp, RECEIVE_QUEUE_COMMAND_REG(mp->port_num), queues);
+}
 
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
-					    struct pkt_info *p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
-					      struct pkt_info *p_pkt_info);
+static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp)
+{
+	unsigned int port_num = mp->port_num;
+	u32 queues;
 
-static void eth_port_uc_addr_get(struct mv643xx_private *mp,
-				 unsigned char *p_addr);
-static void eth_port_uc_addr_set(struct mv643xx_private *mp,
-				 unsigned char *p_addr);
-static void eth_port_set_multicast_list(struct net_device *);
-static void mv643xx_eth_port_enable_tx(struct mv643xx_private *mp,
-						unsigned int queues);
-static void mv643xx_eth_port_enable_rx(struct mv643xx_private *mp,
-						unsigned int queues);
-static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp);
-static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp);
-static int mv643xx_eth_open(struct net_device *);
-static int mv643xx_eth_stop(struct net_device *);
-static void eth_port_init_mac_tables(struct mv643xx_private *mp);
-#ifdef MV643XX_NAPI
-static int mv643xx_poll(struct napi_struct *napi, int budget);
-#endif
-static int ethernet_phy_get(struct mv643xx_private *mp);
-static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr);
-static int ethernet_phy_detect(struct mv643xx_private *mp);
-static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location);
-static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val);
-static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
-static const struct ethtool_ops mv643xx_ethtool_ops;
+	/* Stop Rx port activity. Check port Rx activity. */
+	queues = rdl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF;
+	if (queues) {
+		/* Issue stop command for active queues only */
+		wrl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num), (queues << 8));
 
-static char mv643xx_driver_name[] = "mv643xx_eth";
-static char mv643xx_driver_version[] = "1.0";
+		/* Wait for all Rx activity to terminate. */
+		/* Check port cause register that all Rx queues are stopped */
+		while (rdl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF)
+			udelay(PHY_WAIT_MICRO_SECONDS);
+	}
 
-static inline u32 rdl(struct mv643xx_private *mp, int offset)
+	return queues;
+}
+
+static void mv643xx_eth_port_enable_tx(struct mv643xx_private *mp,
+					unsigned int queues)
 {
-	return readl(mp->shared->eth_base + offset);
+	wrl(mp, TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), queues);
 }
 
-static inline void wrl(struct mv643xx_private *mp, int offset, u32 data)
+static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
 {
-	writel(data, mp->shared->eth_base + offset);
+	unsigned int port_num = mp->port_num;
+	u32 queues;
+
+	/* Stop Tx port activity. Check port Tx activity. */
+	queues = rdl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF;
+	if (queues) {
+		/* Issue stop command for active queues only */
+		wrl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num), (queues << 8));
+
+		/* Wait for all Tx activity to terminate. */
+		/* Check port cause register that all Tx queues are stopped */
+		while (rdl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF)
+			udelay(PHY_WAIT_MICRO_SECONDS);
+
+		/* Wait for Tx FIFO to empty */
+		while (rdl(mp, PORT_STATUS_REG(port_num)) &
+							ETH_PORT_TX_FIFO_EMPTY)
+			udelay(PHY_WAIT_MICRO_SECONDS);
+	}
+
+	return queues;
 }
 
+
+/* rx ***********************************************************************/
+static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev);
+
 /*
- * Changes MTU (maximum transfer unit) of the gigabit ethenret port
+ * eth_rx_return_buff - Returns a Rx buffer back to the Rx ring.
  *
- * Input :	pointer to ethernet interface network device structure
- *		new mtu size
- * Output :	0 upon success, -EINVAL upon failure
+ * DESCRIPTION:
+ *	This routine returns a Rx buffer back to the Rx ring. It retrieves the
+ *	next 'used' descriptor and attached the returned buffer to it.
+ *	In case the Rx ring was in "resource error" condition, where there are
+ *	no available Rx resources, the function resets the resource error flag.
+ *
+ * INPUT:
+ *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
+ *	struct pkt_info		*p_pkt_info	Information on returned buffer.
+ *
+ * OUTPUT:
+ *	New available Rx resource in Rx descriptor ring.
+ *
+ * RETURN:
+ *	ETH_ERROR in case the routine can not access Rx desc ring.
+ *	ETH_OK otherwise.
  */
-static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
+static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
+						struct pkt_info *p_pkt_info)
 {
-	if ((new_mtu > 9500) || (new_mtu < 64))
-		return -EINVAL;
+	int used_rx_desc;	/* Where to return Rx resource */
+	volatile struct eth_rx_desc *p_used_rx_desc;
+	unsigned long flags;
 
-	dev->mtu = new_mtu;
-	if (!netif_running(dev))
-		return 0;
+	spin_lock_irqsave(&mp->lock, flags);
 
-	/*
-	 * Stop and then re-open the interface. This will allocate RX
-	 * skbs of the new MTU.
-	 * There is a possible danger that the open will not succeed,
-	 * due to memory being full, which might fail the open function.
-	 */
-	mv643xx_eth_stop(dev);
-	if (mv643xx_eth_open(dev)) {
-		printk(KERN_ERR "%s: Fatal error on opening device\n",
-			dev->name);
-	}
+	/* Get 'used' Rx descriptor */
+	used_rx_desc = mp->rx_used_desc_q;
+	p_used_rx_desc = &mp->p_rx_desc_area[used_rx_desc];
 
-	return 0;
+	p_used_rx_desc->buf_ptr = p_pkt_info->buf_ptr;
+	p_used_rx_desc->buf_size = p_pkt_info->byte_cnt;
+	mp->rx_skb[used_rx_desc] = p_pkt_info->return_info;
+
+	/* Flush the write pipe */
+
+	/* Return the descriptor to DMA ownership */
+	wmb();
+	p_used_rx_desc->cmd_sts =
+			ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
+	wmb();
+
+	/* Move the used descriptor pointer to the next descriptor */
+	mp->rx_used_desc_q = (used_rx_desc + 1) % mp->rx_ring_size;
+
+	/* Any Rx return cancels the Rx resource error status */
+	mp->rx_resource_err = 0;
+
+	spin_unlock_irqrestore(&mp->lock, flags);
+
+	return ETH_OK;
 }
 
 /*
@@ -736,42 +784,841 @@ static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
 }
 
 /*
- * mv643xx_eth_update_mac_address
+ * eth_port_receive - Get received information from Rx ring.
  *
- * Update the MAC address of the port in the address table
+ * DESCRIPTION:
+ * 	This routine returns the received data to the caller. There is no
+ *	data copying during routine operation. All information is returned
+ *	using pointer to packet information struct passed from the caller.
+ *	If the routine exhausts Rx ring resources then the resource error flag
+ *	is set.
  *
- * Input :	pointer to ethernet interface network device structure
- * Output :	N/A
+ * INPUT:
+ *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
+ *	struct pkt_info		*p_pkt_info	User packet buffer.
+ *
+ * OUTPUT:
+ *	Rx ring current and used indexes are updated.
+ *
+ * RETURN:
+ *	ETH_ERROR in case the routine can not access Rx desc ring.
+ *	ETH_QUEUE_FULL if Rx ring resources are exhausted.
+ *	ETH_END_OF_JOB if there is no received data.
+ *	ETH_OK otherwise.
  */
-static void mv643xx_eth_update_mac_address(struct net_device *dev)
+static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
+						struct pkt_info *p_pkt_info)
+{
+	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
+	volatile struct eth_rx_desc *p_rx_desc;
+	unsigned int command_status;
+	unsigned long flags;
+
+	/* Do not process Rx ring in case of Rx ring resource error */
+	if (mp->rx_resource_err)
+		return ETH_QUEUE_FULL;
+
+	spin_lock_irqsave(&mp->lock, flags);
+
+	/* Get the Rx Desc ring 'curr and 'used' indexes */
+	rx_curr_desc = mp->rx_curr_desc_q;
+	rx_used_desc = mp->rx_used_desc_q;
+
+	p_rx_desc = &mp->p_rx_desc_area[rx_curr_desc];
+
+	/* The following parameters are used to save readings from memory */
+	command_status = p_rx_desc->cmd_sts;
+	rmb();
+
+	/* Nothing to receive... */
+	if (command_status & (ETH_BUFFER_OWNED_BY_DMA)) {
+		spin_unlock_irqrestore(&mp->lock, flags);
+		return ETH_END_OF_JOB;
+	}
+
+	p_pkt_info->byte_cnt = (p_rx_desc->byte_cnt) - RX_BUF_OFFSET;
+	p_pkt_info->cmd_sts = command_status;
+	p_pkt_info->buf_ptr = (p_rx_desc->buf_ptr) + RX_BUF_OFFSET;
+	p_pkt_info->return_info = mp->rx_skb[rx_curr_desc];
+	p_pkt_info->l4i_chk = p_rx_desc->buf_size;
+
+	/*
+	 * Clean the return info field to indicate that the
+	 * packet has been moved to the upper layers
+	 */
+	mp->rx_skb[rx_curr_desc] = NULL;
+
+	/* Update current index in data structure */
+	rx_next_curr_desc = (rx_curr_desc + 1) % mp->rx_ring_size;
+	mp->rx_curr_desc_q = rx_next_curr_desc;
+
+	/* Rx descriptors exhausted. Set the Rx ring resource error flag */
+	if (rx_next_curr_desc == rx_used_desc)
+		mp->rx_resource_err = 1;
+
+	spin_unlock_irqrestore(&mp->lock, flags);
+
+	return ETH_OK;
+}
+
+/*
+ * mv643xx_eth_receive
+ *
+ * This function is forward packets that are received from the port's
+ * queues toward kernel core or FastRoute them to another interface.
+ *
+ * Input :	dev - a pointer to the required interface
+ *		max - maximum number to receive (0 means unlimted)
+ *
+ * Output :	number of served packets
+ */
+static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	unsigned int received_packets = 0;
+	struct sk_buff *skb;
+	struct pkt_info pkt_info;
 
-	eth_port_init_mac_tables(mp);
-	eth_port_uc_addr_set(mp, dev->dev_addr);
+	while (budget-- > 0 && eth_port_receive(mp, &pkt_info) == ETH_OK) {
+		dma_unmap_single(NULL, pkt_info.buf_ptr, ETH_RX_SKB_SIZE,
+							DMA_FROM_DEVICE);
+		mp->rx_desc_count--;
+		received_packets++;
+
+		/*
+		 * Update statistics.
+		 * Note byte count includes 4 byte CRC count
+		 */
+		stats->rx_packets++;
+		stats->rx_bytes += pkt_info.byte_cnt;
+		skb = pkt_info.return_info;
+		/*
+		 * In case received a packet without first / last bits on OR
+		 * the error summary bit is on, the packets needs to be dropeed.
+		 */
+		if (((pkt_info.cmd_sts
+				& (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) !=
+					(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC))
+				|| (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)) {
+			stats->rx_dropped++;
+			if ((pkt_info.cmd_sts & (ETH_RX_FIRST_DESC |
+							ETH_RX_LAST_DESC)) !=
+				(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) {
+				if (net_ratelimit())
+					printk(KERN_ERR
+						"%s: Received packet spread "
+						"on multiple descriptors\n",
+						dev->name);
+			}
+			if (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)
+				stats->rx_errors++;
+
+			dev_kfree_skb_irq(skb);
+		} else {
+			/*
+			 * The -4 is for the CRC in the trailer of the
+			 * received packet
+			 */
+			skb_put(skb, pkt_info.byte_cnt - 4);
+
+			if (pkt_info.cmd_sts & ETH_LAYER_4_CHECKSUM_OK) {
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+				skb->csum = htons(
+					(pkt_info.cmd_sts & 0x0007fff8) >> 3);
+			}
+			skb->protocol = eth_type_trans(skb, dev);
+#ifdef MV643XX_NAPI
+			netif_receive_skb(skb);
+#else
+			netif_rx(skb);
+#endif
+		}
+		dev->last_rx = jiffies;
+	}
+	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
+
+	return received_packets;
 }
 
+#ifdef MV643XX_NAPI
 /*
- * mv643xx_eth_set_rx_mode
+ * mv643xx_poll
  *
- * Change from promiscuos to regular rx mode
+ * This function is used in case of NAPI
+ */
+static int mv643xx_poll(struct napi_struct *napi, int budget)
+{
+	struct mv643xx_private *mp = container_of(napi, struct mv643xx_private, napi);
+	struct net_device *dev = mp->dev;
+	unsigned int port_num = mp->port_num;
+	int work_done;
+
+#ifdef MV643XX_TX_FAST_REFILL
+	if (++mp->tx_clean_threshold > 5) {
+		mv643xx_eth_free_completed_tx_descs(dev);
+		mp->tx_clean_threshold = 0;
+	}
+#endif
+
+	work_done = 0;
+	if ((rdl(mp, RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
+	    != (u32) mp->rx_used_desc_q)
+		work_done = mv643xx_eth_receive_queue(dev, budget);
+
+	if (work_done < budget) {
+		netif_rx_complete(dev, napi);
+		wrl(mp, INTERRUPT_CAUSE_REG(port_num), 0);
+		wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+		wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	}
+
+	return work_done;
+}
+#endif
+
+
+/* tx ***********************************************************************/
+/**
+ * has_tiny_unaligned_frags - check if skb has any small, unaligned fragments
+ *
+ * Hardware can't handle unaligned fragments smaller than 9 bytes.
+ * This helper function detects that case.
+ */
+
+static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
+{
+	unsigned int frag;
+	skb_frag_t *fragp;
+
+	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
+		fragp = &skb_shinfo(skb)->frags[frag];
+		if (fragp->size <= 8 && fragp->page_offset & 0x7)
+			return 1;
+	}
+	return 0;
+}
+
+/**
+ * eth_alloc_tx_desc_index - return the index of the next available tx desc
+ */
+static int eth_alloc_tx_desc_index(struct mv643xx_private *mp)
+{
+	int tx_desc_curr;
+
+	BUG_ON(mp->tx_desc_count >= mp->tx_ring_size);
+
+	tx_desc_curr = mp->tx_curr_desc_q;
+	mp->tx_curr_desc_q = (tx_desc_curr + 1) % mp->tx_ring_size;
+
+	BUG_ON(mp->tx_curr_desc_q == mp->tx_used_desc_q);
+
+	return tx_desc_curr;
+}
+
+/**
+ * eth_tx_fill_frag_descs - fill tx hw descriptors for an skb's fragments.
+ *
+ * Ensure the data for each fragment to be transmitted is mapped properly,
+ * then fill in descriptors in the tx hw queue.
+ */
+static void eth_tx_fill_frag_descs(struct mv643xx_private *mp,
+				   struct sk_buff *skb)
+{
+	int frag;
+	int tx_index;
+	struct eth_tx_desc *desc;
+
+	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
+		skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
+
+		tx_index = eth_alloc_tx_desc_index(mp);
+		desc = &mp->p_tx_desc_area[tx_index];
+
+		desc->cmd_sts = ETH_BUFFER_OWNED_BY_DMA;
+		/* Last Frag enables interrupt and frees the skb */
+		if (frag == (skb_shinfo(skb)->nr_frags - 1)) {
+			desc->cmd_sts |= ETH_ZERO_PADDING |
+					 ETH_TX_LAST_DESC |
+					 ETH_TX_ENABLE_INTERRUPT;
+			mp->tx_skb[tx_index] = skb;
+		} else
+			mp->tx_skb[tx_index] = NULL;
+
+		desc = &mp->p_tx_desc_area[tx_index];
+		desc->l4i_chk = 0;
+		desc->byte_cnt = this_frag->size;
+		desc->buf_ptr = dma_map_page(NULL, this_frag->page,
+						this_frag->page_offset,
+						this_frag->size,
+						DMA_TO_DEVICE);
+	}
+}
+
+static inline __be16 sum16_as_be(__sum16 sum)
+{
+	return (__force __be16)sum;
+}
+
+/**
+ * eth_tx_submit_descs_for_skb - submit data from an skb to the tx hw
+ *
+ * Ensure the data for an skb to be transmitted is mapped properly,
+ * then fill in descriptors in the tx hw queue and start the hardware.
+ */
+static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
+					struct sk_buff *skb)
+{
+	int tx_index;
+	struct eth_tx_desc *desc;
+	u32 cmd_sts;
+	int length;
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+
+	cmd_sts = ETH_TX_FIRST_DESC | ETH_GEN_CRC | ETH_BUFFER_OWNED_BY_DMA;
+
+	tx_index = eth_alloc_tx_desc_index(mp);
+	desc = &mp->p_tx_desc_area[tx_index];
+
+	if (nr_frags) {
+		eth_tx_fill_frag_descs(mp, skb);
+
+		length = skb_headlen(skb);
+		mp->tx_skb[tx_index] = NULL;
+	} else {
+		cmd_sts |= ETH_ZERO_PADDING |
+			   ETH_TX_LAST_DESC |
+			   ETH_TX_ENABLE_INTERRUPT;
+		length = skb->len;
+		mp->tx_skb[tx_index] = skb;
+	}
+
+	desc->byte_cnt = length;
+	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		BUG_ON(skb->protocol != htons(ETH_P_IP));
+
+		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
+			   ETH_GEN_IP_V_4_CHECKSUM  |
+			   ip_hdr(skb)->ihl << ETH_TX_IHL_SHIFT;
+
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_UDP:
+			cmd_sts |= ETH_UDP_FRAME;
+			desc->l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
+			break;
+		case IPPROTO_TCP:
+			desc->l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
+			break;
+		default:
+			BUG();
+		}
+	} else {
+		/* Errata BTS #50, IHL must be 5 if no HW checksum */
+		cmd_sts |= 5 << ETH_TX_IHL_SHIFT;
+		desc->l4i_chk = 0;
+	}
+
+	/* ensure all other descriptors are written before first cmd_sts */
+	wmb();
+	desc->cmd_sts = cmd_sts;
+
+	/* ensure all descriptors are written before poking hardware */
+	wmb();
+	mv643xx_eth_port_enable_tx(mp, ETH_TX_QUEUES_ENABLED);
+
+	mp->tx_desc_count += nr_frags + 1;
+}
+
+/**
+ * mv643xx_eth_start_xmit - queue an skb to the hardware for transmission
+ *
+ */
+static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	unsigned long flags;
+
+	BUG_ON(netif_queue_stopped(dev));
+
+	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
+		stats->tx_dropped++;
+		printk(KERN_DEBUG "%s: failed to linearize tiny "
+				"unaligned fragment\n", dev->name);
+		return NETDEV_TX_BUSY;
+	}
+
+	spin_lock_irqsave(&mp->lock, flags);
+
+	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB) {
+		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
+		netif_stop_queue(dev);
+		spin_unlock_irqrestore(&mp->lock, flags);
+		return NETDEV_TX_BUSY;
+	}
+
+	eth_tx_submit_descs_for_skb(mp, skb);
+	stats->tx_bytes += skb->len;
+	stats->tx_packets++;
+	dev->trans_start = jiffies;
+
+	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB)
+		netif_stop_queue(dev);
+
+	spin_unlock_irqrestore(&mp->lock, flags);
+
+	return NETDEV_TX_OK;
+}
+
+
+/* mii management interface *************************************************/
+static int ethernet_phy_get(struct mv643xx_private *mp);
+
+/*
+ * eth_port_read_smi_reg - Read PHY registers
+ *
+ * DESCRIPTION:
+ *	This routine utilize the SMI interface to interact with the PHY in
+ *	order to perform PHY register read.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port.
+ *	unsigned int	phy_reg		PHY register address offset.
+ *	unsigned int	*value		Register value buffer.
+ *
+ * OUTPUT:
+ *	Write the value of a specified PHY register into given buffer.
+ *
+ * RETURN:
+ *	false if the PHY is busy or read data is not in valid state.
+ *	true otherwise.
+ *
+ */
+static void eth_port_read_smi_reg(struct mv643xx_private *mp,
+				unsigned int phy_reg, unsigned int *value)
+{
+	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
+	int phy_addr = ethernet_phy_get(mp);
+	unsigned long flags;
+	int i;
+
+	/* the SMI register is a shared resource */
+	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
+
+	/* wait for the SMI register to become available */
+	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk("%s: PHY busy timeout\n", mp->dev->name);
+			goto out;
+		}
+		udelay(PHY_WAIT_MICRO_SECONDS);
+	}
+
+	writel((phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ,
+		smi_reg);
+
+	/* now wait for the data to be valid */
+	for (i = 0; !(readl(smi_reg) & ETH_SMI_READ_VALID); i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk("%s: PHY read timeout\n", mp->dev->name);
+			goto out;
+		}
+		udelay(PHY_WAIT_MICRO_SECONDS);
+	}
+
+	*value = readl(smi_reg) & 0xffff;
+out:
+	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
+}
+
+/*
+ * eth_port_write_smi_reg - Write to PHY registers
+ *
+ * DESCRIPTION:
+ *	This routine utilize the SMI interface to interact with the PHY in
+ *	order to perform writes to PHY registers.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port.
+ *	unsigned int	phy_reg		PHY register address offset.
+ *	unsigned int	value		Register value.
+ *
+ * OUTPUT:
+ *	Write the given value to the specified PHY register.
+ *
+ * RETURN:
+ *	false if the PHY is busy.
+ *	true otherwise.
+ *
+ */
+static void eth_port_write_smi_reg(struct mv643xx_private *mp,
+				   unsigned int phy_reg, unsigned int value)
+{
+	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
+	int phy_addr = ethernet_phy_get(mp);
+	unsigned long flags;
+	int i;
+
+	/* the SMI register is a shared resource */
+	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
+
+	/* wait for the SMI register to become available */
+	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk("%s: PHY busy timeout\n", mp->dev->name);
+			goto out;
+		}
+		udelay(PHY_WAIT_MICRO_SECONDS);
+	}
+
+	writel((phy_addr << 16) | (phy_reg << 21) |
+		ETH_SMI_OPCODE_WRITE | (value & 0xffff), smi_reg);
+out:
+	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
+}
+
+
+/* mib counters *************************************************************/
+/*
+ * eth_clear_mib_counters - Clear all MIB counters
+ *
+ * DESCRIPTION:
+ *	This function clears all MIB counters of a specific ethernet port.
+ *	A read from the MIB counter will reset the counter.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port.
+ *
+ * OUTPUT:
+ *	After reading all MIB counters, the counters resets.
+ *
+ * RETURN:
+ *	MIB counter value.
+ *
+ */
+static void eth_clear_mib_counters(struct mv643xx_private *mp)
+{
+	unsigned int port_num = mp->port_num;
+	int i;
+
+	/* Perform dummy reads from MIB counters */
+	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
+									i += 4)
+		rdl(mp, MIB_COUNTERS_BASE(port_num) + i);
+}
+
+static inline u32 read_mib(struct mv643xx_private *mp, int offset)
+{
+	return rdl(mp, MIB_COUNTERS_BASE(mp->port_num) + offset);
+}
+
+static void eth_update_mib_counters(struct mv643xx_private *mp)
+{
+	struct mv643xx_mib_counters *p = &mp->mib_counters;
+	int offset;
+
+	p->good_octets_received +=
+		read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
+	p->good_octets_received +=
+		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH) << 32;
+
+	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
+			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
+			offset += 4)
+		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
+
+	p->good_octets_sent += read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_LOW);
+	p->good_octets_sent +=
+		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
+
+	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
+			offset <= ETH_MIB_LATE_COLLISION;
+			offset += 4)
+		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
+}
+
+
+/* ethtool ******************************************************************/
+struct mv643xx_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define MV643XX_STAT(m) FIELD_SIZEOF(struct mv643xx_private, m), \
+					offsetof(struct mv643xx_private, m)
+
+static const struct mv643xx_stats mv643xx_gstrings_stats[] = {
+	{ "rx_packets", MV643XX_STAT(stats.rx_packets) },
+	{ "tx_packets", MV643XX_STAT(stats.tx_packets) },
+	{ "rx_bytes", MV643XX_STAT(stats.rx_bytes) },
+	{ "tx_bytes", MV643XX_STAT(stats.tx_bytes) },
+	{ "rx_errors", MV643XX_STAT(stats.rx_errors) },
+	{ "tx_errors", MV643XX_STAT(stats.tx_errors) },
+	{ "rx_dropped", MV643XX_STAT(stats.rx_dropped) },
+	{ "tx_dropped", MV643XX_STAT(stats.tx_dropped) },
+	{ "good_octets_received", MV643XX_STAT(mib_counters.good_octets_received) },
+	{ "bad_octets_received", MV643XX_STAT(mib_counters.bad_octets_received) },
+	{ "internal_mac_transmit_err", MV643XX_STAT(mib_counters.internal_mac_transmit_err) },
+	{ "good_frames_received", MV643XX_STAT(mib_counters.good_frames_received) },
+	{ "bad_frames_received", MV643XX_STAT(mib_counters.bad_frames_received) },
+	{ "broadcast_frames_received", MV643XX_STAT(mib_counters.broadcast_frames_received) },
+	{ "multicast_frames_received", MV643XX_STAT(mib_counters.multicast_frames_received) },
+	{ "frames_64_octets", MV643XX_STAT(mib_counters.frames_64_octets) },
+	{ "frames_65_to_127_octets", MV643XX_STAT(mib_counters.frames_65_to_127_octets) },
+	{ "frames_128_to_255_octets", MV643XX_STAT(mib_counters.frames_128_to_255_octets) },
+	{ "frames_256_to_511_octets", MV643XX_STAT(mib_counters.frames_256_to_511_octets) },
+	{ "frames_512_to_1023_octets", MV643XX_STAT(mib_counters.frames_512_to_1023_octets) },
+	{ "frames_1024_to_max_octets", MV643XX_STAT(mib_counters.frames_1024_to_max_octets) },
+	{ "good_octets_sent", MV643XX_STAT(mib_counters.good_octets_sent) },
+	{ "good_frames_sent", MV643XX_STAT(mib_counters.good_frames_sent) },
+	{ "excessive_collision", MV643XX_STAT(mib_counters.excessive_collision) },
+	{ "multicast_frames_sent", MV643XX_STAT(mib_counters.multicast_frames_sent) },
+	{ "broadcast_frames_sent", MV643XX_STAT(mib_counters.broadcast_frames_sent) },
+	{ "unrec_mac_control_received", MV643XX_STAT(mib_counters.unrec_mac_control_received) },
+	{ "fc_sent", MV643XX_STAT(mib_counters.fc_sent) },
+	{ "good_fc_received", MV643XX_STAT(mib_counters.good_fc_received) },
+	{ "bad_fc_received", MV643XX_STAT(mib_counters.bad_fc_received) },
+	{ "undersize_received", MV643XX_STAT(mib_counters.undersize_received) },
+	{ "fragments_received", MV643XX_STAT(mib_counters.fragments_received) },
+	{ "oversize_received", MV643XX_STAT(mib_counters.oversize_received) },
+	{ "jabber_received", MV643XX_STAT(mib_counters.jabber_received) },
+	{ "mac_receive_error", MV643XX_STAT(mib_counters.mac_receive_error) },
+	{ "bad_crc_event", MV643XX_STAT(mib_counters.bad_crc_event) },
+	{ "collision", MV643XX_STAT(mib_counters.collision) },
+	{ "late_collision", MV643XX_STAT(mib_counters.late_collision) },
+};
+
+#define MV643XX_STATS_LEN	ARRAY_SIZE(mv643xx_gstrings_stats)
+
+static int mv643xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	int err;
+
+	spin_lock_irq(&mp->lock);
+	err = mii_ethtool_gset(&mp->mii, cmd);
+	spin_unlock_irq(&mp->lock);
+
+	/* The PHY may support 1000baseT_Half, but the mv643xx does not */
+	cmd->supported &= ~SUPPORTED_1000baseT_Half;
+	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
+
+	return err;
+}
+
+static int mv643xx_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	int err;
+
+	spin_lock_irq(&mp->lock);
+	err = mii_ethtool_sset(&mp->mii, cmd);
+	spin_unlock_irq(&mp->lock);
+
+	return err;
+}
+
+static void mv643xx_get_drvinfo(struct net_device *netdev,
+				struct ethtool_drvinfo *drvinfo)
+{
+	strncpy(drvinfo->driver,  mv643xx_driver_name, 32);
+	strncpy(drvinfo->version, mv643xx_driver_version, 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, "mv643xx", 32);
+	drvinfo->n_stats = MV643XX_STATS_LEN;
+}
+
+static int mv643xx_eth_nway_restart(struct net_device *dev)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+
+	return mii_nway_restart(&mp->mii);
+}
+
+static u32 mv643xx_eth_get_link(struct net_device *dev)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+
+	return mii_link_ok(&mp->mii);
+}
+
+static void mv643xx_get_strings(struct net_device *netdev, uint32_t stringset,
+				uint8_t *data)
+{
+	int i;
+
+	switch(stringset) {
+	case ETH_SS_STATS:
+		for (i=0; i < MV643XX_STATS_LEN; i++) {
+			memcpy(data + i * ETH_GSTRING_LEN,
+					mv643xx_gstrings_stats[i].stat_string,
+					ETH_GSTRING_LEN);
+		}
+		break;
+	}
+}
+
+static void mv643xx_get_ethtool_stats(struct net_device *netdev,
+				struct ethtool_stats *stats, uint64_t *data)
+{
+	struct mv643xx_private *mp = netdev->priv;
+	int i;
+
+	eth_update_mib_counters(mp);
+
+	for (i = 0; i < MV643XX_STATS_LEN; i++) {
+		char *p = (char *)mp+mv643xx_gstrings_stats[i].stat_offset;
+		data[i] = (mv643xx_gstrings_stats[i].sizeof_stat ==
+			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+	}
+}
+
+static int mv643xx_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return MV643XX_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static const struct ethtool_ops mv643xx_ethtool_ops = {
+	.get_settings           = mv643xx_get_settings,
+	.set_settings           = mv643xx_set_settings,
+	.get_drvinfo            = mv643xx_get_drvinfo,
+	.get_link               = mv643xx_eth_get_link,
+	.set_sg			= ethtool_op_set_sg,
+	.get_sset_count		= mv643xx_get_sset_count,
+	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
+	.get_strings            = mv643xx_get_strings,
+	.nway_reset		= mv643xx_eth_nway_restart,
+};
+
+
+/* address handling *********************************************************/
+/*
+ * eth_port_uc_addr_get - Read the MAC address from the port's hw registers
+ */
+static void eth_port_uc_addr_get(struct mv643xx_private *mp,
+				 unsigned char *p_addr)
+{
+	unsigned int port_num = mp->port_num;
+	unsigned int mac_h;
+	unsigned int mac_l;
+
+	mac_h = rdl(mp, MAC_ADDR_HIGH(port_num));
+	mac_l = rdl(mp, MAC_ADDR_LOW(port_num));
+
+	p_addr[0] = (mac_h >> 24) & 0xff;
+	p_addr[1] = (mac_h >> 16) & 0xff;
+	p_addr[2] = (mac_h >> 8) & 0xff;
+	p_addr[3] = mac_h & 0xff;
+	p_addr[4] = (mac_l >> 8) & 0xff;
+	p_addr[5] = mac_l & 0xff;
+}
+
+/*
+ * eth_port_init_mac_tables - Clear all entrance in the UC, SMC and OMC tables
+ *
+ * DESCRIPTION:
+ *	Go through all the DA filter tables (Unicast, Special Multicast &
+ *	Other Multicast) and set each entry to 0.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port.
+ *
+ * OUTPUT:
+ *	Multicast and Unicast packets are rejected.
+ *
+ * RETURN:
+ *	None.
+ */
+static void eth_port_init_mac_tables(struct mv643xx_private *mp)
+{
+	unsigned int port_num = mp->port_num;
+	int table_index;
+
+	/* Clear DA filter unicast table (Ex_dFUT) */
+	for (table_index = 0; table_index <= 0xC; table_index += 4)
+		wrl(mp, DA_FILTER_UNICAST_TABLE_BASE(port_num) +
+					table_index, 0);
+
+	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
+		/* Clear DA filter special multicast table (Ex_dFSMT) */
+		wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num) +
+					table_index, 0);
+		/* Clear DA filter other multicast table (Ex_dFOMT) */
+		wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num) +
+					table_index, 0);
+	}
+}
+
+/*
+ * The entries in each table are indexed by a hash of a packet's MAC
+ * address.  One bit in each entry determines whether the packet is
+ * accepted.  There are 4 entries (each 8 bits wide) in each register
+ * of the table.  The bits in each entry are defined as follows:
+ *	0	Accept=1, Drop=0
+ *	3-1	Queue			(ETH_Q0=0)
+ *	7-4	Reserved = 0;
+ */
+static void eth_port_set_filter_table_entry(struct mv643xx_private *mp,
+					    int table, unsigned char entry)
+{
+	unsigned int table_reg;
+	unsigned int tbl_offset;
+	unsigned int reg_offset;
+
+	tbl_offset = (entry / 4) * 4;	/* Register offset of DA table entry */
+	reg_offset = entry % 4;		/* Entry offset within the register */
+
+	/* Set "accepts frame bit" at specified table entry */
+	table_reg = rdl(mp, table + tbl_offset);
+	table_reg |= 0x01 << (8 * reg_offset);
+	wrl(mp, table + tbl_offset, table_reg);
+}
+
+/*
+ * eth_port_uc_addr_set - Write a MAC address into the port's hw registers
+ */
+static void eth_port_uc_addr_set(struct mv643xx_private *mp,
+				 unsigned char *p_addr)
+{
+	unsigned int port_num = mp->port_num;
+	unsigned int mac_h;
+	unsigned int mac_l;
+	int table;
+
+	mac_l = (p_addr[4] << 8) | (p_addr[5]);
+	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
+							(p_addr[3] << 0);
+
+	wrl(mp, MAC_ADDR_LOW(port_num), mac_l);
+	wrl(mp, MAC_ADDR_HIGH(port_num), mac_h);
+
+	/* Accept frames with this address */
+	table = DA_FILTER_UNICAST_TABLE_BASE(port_num);
+	eth_port_set_filter_table_entry(mp, table, p_addr[5] & 0x0f);
+}
+
+/*
+ * mv643xx_eth_update_mac_address
+ *
+ * Update the MAC address of the port in the address table
  *
  * Input :	pointer to ethernet interface network device structure
  * Output :	N/A
  */
-static void mv643xx_eth_set_rx_mode(struct net_device *dev)
+static void mv643xx_eth_update_mac_address(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	u32 config_reg;
-
-	config_reg = rdl(mp, PORT_CONFIG_REG(mp->port_num));
-	if (dev->flags & IFF_PROMISC)
-		config_reg |= (u32) UNICAST_PROMISCUOUS_MODE;
-	else
-		config_reg &= ~(u32) UNICAST_PROMISCUOUS_MODE;
-	wrl(mp, PORT_CONFIG_REG(mp->port_num), config_reg);
 
-	eth_port_set_multicast_list(dev);
+	eth_port_init_mac_tables(mp);
+	eth_port_uc_addr_set(mp, dev->dev_addr);
 }
 
 /*
@@ -797,44 +1644,306 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 }
 
 /*
- * mv643xx_eth_tx_timeout
+ * eth_port_mc_addr - Multicast address settings.
  *
- * Called upon a timeout on transmitting a packet
+ * The MV device supports multicast using two tables:
+ * 1) Special Multicast Table for MAC addresses of the form
+ *    0x01-00-5E-00-00-XX (where XX is between 0x00 and 0x_FF).
+ *    The MAC DA[7:0] bits are used as a pointer to the Special Multicast
+ *    Table entries in the DA-Filter table.
+ * 2) Other Multicast Table for multicast of another type. A CRC-8bit
+ *    is used as an index to the Other Multicast Table entries in the
+ *    DA-Filter table.  This function calculates the CRC-8bit value.
+ * In either case, eth_port_set_filter_table_entry() is then called
+ * to set to set the actual table entry.
+ */
+static void eth_port_mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
+{
+	unsigned int port_num = mp->port_num;
+	unsigned int mac_h;
+	unsigned int mac_l;
+	unsigned char crc_result = 0;
+	int table;
+	int mac_array[48];
+	int crc[8];
+	int i;
+
+	if ((p_addr[0] == 0x01) && (p_addr[1] == 0x00) &&
+	    (p_addr[2] == 0x5E) && (p_addr[3] == 0x00) && (p_addr[4] == 0x00)) {
+		table = DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num);
+		eth_port_set_filter_table_entry(mp, table, p_addr[5]);
+		return;
+	}
+
+	/* Calculate CRC-8 out of the given address */
+	mac_h = (p_addr[0] << 8) | (p_addr[1]);
+	mac_l = (p_addr[2] << 24) | (p_addr[3] << 16) |
+			(p_addr[4] << 8) | (p_addr[5] << 0);
+
+	for (i = 0; i < 32; i++)
+		mac_array[i] = (mac_l >> i) & 0x1;
+	for (i = 32; i < 48; i++)
+		mac_array[i] = (mac_h >> (i - 32)) & 0x1;
+
+	crc[0] = mac_array[45] ^ mac_array[43] ^ mac_array[40] ^ mac_array[39] ^
+		 mac_array[35] ^ mac_array[34] ^ mac_array[31] ^ mac_array[30] ^
+		 mac_array[28] ^ mac_array[23] ^ mac_array[21] ^ mac_array[19] ^
+		 mac_array[18] ^ mac_array[16] ^ mac_array[14] ^ mac_array[12] ^
+		 mac_array[8]  ^ mac_array[7]  ^ mac_array[6]  ^ mac_array[0];
+
+	crc[1] = mac_array[46] ^ mac_array[45] ^ mac_array[44] ^ mac_array[43] ^
+		 mac_array[41] ^ mac_array[39] ^ mac_array[36] ^ mac_array[34] ^
+		 mac_array[32] ^ mac_array[30] ^ mac_array[29] ^ mac_array[28] ^
+		 mac_array[24] ^ mac_array[23] ^ mac_array[22] ^ mac_array[21] ^
+		 mac_array[20] ^ mac_array[18] ^ mac_array[17] ^ mac_array[16] ^
+		 mac_array[15] ^ mac_array[14] ^ mac_array[13] ^ mac_array[12] ^
+		 mac_array[9]  ^ mac_array[6]  ^ mac_array[1]  ^ mac_array[0];
+
+	crc[2] = mac_array[47] ^ mac_array[46] ^ mac_array[44] ^ mac_array[43] ^
+		 mac_array[42] ^ mac_array[39] ^ mac_array[37] ^ mac_array[34] ^
+		 mac_array[33] ^ mac_array[29] ^ mac_array[28] ^ mac_array[25] ^
+		 mac_array[24] ^ mac_array[22] ^ mac_array[17] ^ mac_array[15] ^
+		 mac_array[13] ^ mac_array[12] ^ mac_array[10] ^ mac_array[8]  ^
+		 mac_array[6]  ^ mac_array[2]  ^ mac_array[1]  ^ mac_array[0];
+
+	crc[3] = mac_array[47] ^ mac_array[45] ^ mac_array[44] ^ mac_array[43] ^
+		 mac_array[40] ^ mac_array[38] ^ mac_array[35] ^ mac_array[34] ^
+		 mac_array[30] ^ mac_array[29] ^ mac_array[26] ^ mac_array[25] ^
+		 mac_array[23] ^ mac_array[18] ^ mac_array[16] ^ mac_array[14] ^
+		 mac_array[13] ^ mac_array[11] ^ mac_array[9]  ^ mac_array[7]  ^
+		 mac_array[3]  ^ mac_array[2]  ^ mac_array[1];
+
+	crc[4] = mac_array[46] ^ mac_array[45] ^ mac_array[44] ^ mac_array[41] ^
+		 mac_array[39] ^ mac_array[36] ^ mac_array[35] ^ mac_array[31] ^
+		 mac_array[30] ^ mac_array[27] ^ mac_array[26] ^ mac_array[24] ^
+		 mac_array[19] ^ mac_array[17] ^ mac_array[15] ^ mac_array[14] ^
+		 mac_array[12] ^ mac_array[10] ^ mac_array[8]  ^ mac_array[4]  ^
+		 mac_array[3]  ^ mac_array[2];
+
+	crc[5] = mac_array[47] ^ mac_array[46] ^ mac_array[45] ^ mac_array[42] ^
+		 mac_array[40] ^ mac_array[37] ^ mac_array[36] ^ mac_array[32] ^
+		 mac_array[31] ^ mac_array[28] ^ mac_array[27] ^ mac_array[25] ^
+		 mac_array[20] ^ mac_array[18] ^ mac_array[16] ^ mac_array[15] ^
+		 mac_array[13] ^ mac_array[11] ^ mac_array[9]  ^ mac_array[5]  ^
+		 mac_array[4]  ^ mac_array[3];
+
+	crc[6] = mac_array[47] ^ mac_array[46] ^ mac_array[43] ^ mac_array[41] ^
+		 mac_array[38] ^ mac_array[37] ^ mac_array[33] ^ mac_array[32] ^
+		 mac_array[29] ^ mac_array[28] ^ mac_array[26] ^ mac_array[21] ^
+		 mac_array[19] ^ mac_array[17] ^ mac_array[16] ^ mac_array[14] ^
+		 mac_array[12] ^ mac_array[10] ^ mac_array[6]  ^ mac_array[5]  ^
+		 mac_array[4];
+
+	crc[7] = mac_array[47] ^ mac_array[44] ^ mac_array[42] ^ mac_array[39] ^
+		 mac_array[38] ^ mac_array[34] ^ mac_array[33] ^ mac_array[30] ^
+		 mac_array[29] ^ mac_array[27] ^ mac_array[22] ^ mac_array[20] ^
+		 mac_array[18] ^ mac_array[17] ^ mac_array[15] ^ mac_array[13] ^
+		 mac_array[11] ^ mac_array[7]  ^ mac_array[6]  ^ mac_array[5];
+
+	for (i = 0; i < 8; i++)
+		crc_result = crc_result | (crc[i] << i);
+
+	table = DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num);
+	eth_port_set_filter_table_entry(mp, table, crc_result);
+}
+
+/*
+ * Set the entire multicast list based on dev->mc_list.
+ */
+static void eth_port_set_multicast_list(struct net_device *dev)
+{
+
+	struct dev_mc_list	*mc_list;
+	int			i;
+	int			table_index;
+	struct mv643xx_private	*mp = netdev_priv(dev);
+	unsigned int		eth_port_num = mp->port_num;
+
+	/* If the device is in promiscuous mode or in all multicast mode,
+	 * we will fully populate both multicast tables with accept.
+	 * This is guaranteed to yield a match on all multicast addresses...
+	 */
+	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI)) {
+		for (table_index = 0; table_index <= 0xFC; table_index += 4) {
+			/* Set all entries in DA filter special multicast
+			 * table (Ex_dFSMT)
+			 * Set for ETH_Q0 for now
+			 * Bits
+			 * 0	  Accept=1, Drop=0
+			 * 3-1  Queue	 ETH_Q0=0
+			 * 7-4  Reserved = 0;
+			 */
+			wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+
+			/* Set all entries in DA filter other multicast
+			 * table (Ex_dFOMT)
+			 * Set for ETH_Q0 for now
+			 * Bits
+			 * 0	  Accept=1, Drop=0
+			 * 3-1  Queue	 ETH_Q0=0
+			 * 7-4  Reserved = 0;
+			 */
+			wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+		}
+		return;
+	}
+
+	/* We will clear out multicast tables every time we get the list.
+	 * Then add the entire new list...
+	 */
+	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
+		/* Clear DA filter special multicast table (Ex_dFSMT) */
+		wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
+				(eth_port_num) + table_index, 0);
+
+		/* Clear DA filter other multicast table (Ex_dFOMT) */
+		wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE
+				(eth_port_num) + table_index, 0);
+	}
+
+	/* Get pointer to net_device multicast list and add each one... */
+	for (i = 0, mc_list = dev->mc_list;
+			(i < 256) && (mc_list != NULL) && (i < dev->mc_count);
+			i++, mc_list = mc_list->next)
+		if (mc_list->dmi_addrlen == 6)
+			eth_port_mc_addr(mp, mc_list->dmi_addr);
+}
+
+/*
+ * mv643xx_eth_set_rx_mode
  *
- * Input :	pointer to ethernet interface network device structure.
+ * Change from promiscuos to regular rx mode
+ *
+ * Input :	pointer to ethernet interface network device structure
  * Output :	N/A
  */
-static void mv643xx_eth_tx_timeout(struct net_device *dev)
+static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
+	u32 config_reg;
 
-	printk(KERN_INFO "%s: TX timeout  ", dev->name);
+	config_reg = rdl(mp, PORT_CONFIG_REG(mp->port_num));
+	if (dev->flags & IFF_PROMISC)
+		config_reg |= (u32) UNICAST_PROMISCUOUS_MODE;
+	else
+		config_reg &= ~(u32) UNICAST_PROMISCUOUS_MODE;
+	wrl(mp, PORT_CONFIG_REG(mp->port_num), config_reg);
 
-	/* Do the reset outside of interrupt context */
-	schedule_work(&mp->tx_timeout_task);
+	eth_port_set_multicast_list(dev);
 }
 
+
+/* rx/tx queue initialisation ***********************************************/
 /*
- * mv643xx_eth_tx_timeout_task
+ * ether_init_rx_desc_ring - Curve a Rx chain desc list and buffer in memory.
  *
- * Actual routine to reset the adapter when a timeout on Tx has occurred
+ * DESCRIPTION:
+ *	This function prepares a Rx chained list of descriptors and packet
+ *	buffers in a form of a ring. The routine must be called after port
+ *	initialization routine and before port start routine.
+ *	The Ethernet SDMA engine uses CPU bus addresses to access the various
+ *	devices in the system (i.e. DRAM). This function uses the ethernet
+ *	struct 'virtual to physical' routine (set by the user) to set the ring
+ *	with physical addresses.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
+ *
+ * OUTPUT:
+ *	The routine updates the Ethernet port control struct with information
+ *	regarding the Rx descriptors and buffers.
+ *
+ * RETURN:
+ *	None.
  */
-static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
+static void ether_init_rx_desc_ring(struct mv643xx_private *mp)
 {
-	struct mv643xx_private *mp = container_of(ugly, struct mv643xx_private,
-						  tx_timeout_task);
-	struct net_device *dev = mp->dev;
+	volatile struct eth_rx_desc *p_rx_desc;
+	int rx_desc_num = mp->rx_ring_size;
+	int i;
 
-	if (!netif_running(dev))
-		return;
+	/* initialize the next_desc_ptr links in the Rx descriptors ring */
+	p_rx_desc = (struct eth_rx_desc *)mp->p_rx_desc_area;
+	for (i = 0; i < rx_desc_num; i++) {
+		p_rx_desc[i].next_desc_ptr = mp->rx_desc_dma +
+			((i + 1) % rx_desc_num) * sizeof(struct eth_rx_desc);
+	}
 
-	netif_stop_queue(dev);
+	/* Save Rx desc pointer to driver struct. */
+	mp->rx_curr_desc_q = 0;
+	mp->rx_used_desc_q = 0;
 
-	eth_port_reset(mp);
-	eth_port_start(dev);
+	mp->rx_desc_area_size = rx_desc_num * sizeof(struct eth_rx_desc);
+}
 
-	if (mp->tx_ring_size - mp->tx_desc_count >= MAX_DESCS_PER_SKB)
-		netif_wake_queue(dev);
+static void mv643xx_eth_free_rx_rings(struct net_device *dev)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	int curr;
+
+	/* Stop RX Queues */
+	mv643xx_eth_port_disable_rx(mp);
+
+	/* Free preallocated skb's on RX rings */
+	for (curr = 0; mp->rx_desc_count && curr < mp->rx_ring_size; curr++) {
+		if (mp->rx_skb[curr]) {
+			dev_kfree_skb(mp->rx_skb[curr]);
+			mp->rx_desc_count--;
+		}
+	}
+
+	if (mp->rx_desc_count)
+		printk(KERN_ERR
+			"%s: Error in freeing Rx Ring. %d skb's still"
+			" stuck in RX Ring - ignoring them\n", dev->name,
+			mp->rx_desc_count);
+	/* Free RX ring */
+	if (mp->rx_sram_size)
+		iounmap(mp->p_rx_desc_area);
+	else
+		dma_free_coherent(NULL, mp->rx_desc_area_size,
+				mp->p_rx_desc_area, mp->rx_desc_dma);
+}
+
+/*
+ * ether_init_tx_desc_ring - Curve a Tx chain desc list and buffer in memory.
+ *
+ * DESCRIPTION:
+ *	This function prepares a Tx chained list of descriptors and packet
+ *	buffers in a form of a ring. The routine must be called after port
+ *	initialization routine and before port start routine.
+ *	The Ethernet SDMA engine uses CPU bus addresses to access the various
+ *	devices in the system (i.e. DRAM). This function uses the ethernet
+ *	struct 'virtual to physical' routine (set by the user) to set the ring
+ *	with physical addresses.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
+ *
+ * OUTPUT:
+ *	The routine updates the Ethernet port control struct with information
+ *	regarding the Tx descriptors and buffers.
+ *
+ * RETURN:
+ *	None.
+ */
+static void ether_init_tx_desc_ring(struct mv643xx_private *mp)
+{
+	int tx_desc_num = mp->tx_ring_size;
+	struct eth_tx_desc *p_tx_desc;
+	int i;
+
+	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
+	p_tx_desc = (struct eth_tx_desc *)mp->p_tx_desc_area;
+	for (i = 0; i < tx_desc_num; i++) {
+		p_tx_desc[i].next_desc_ptr = mp->tx_desc_dma +
+			((i + 1) % tx_desc_num) * sizeof(struct eth_tx_desc);
+	}
+
+	mp->tx_curr_desc_q = 0;
+	mp->tx_used_desc_q = 0;
+
+	mp->tx_desc_area_size = tx_desc_num * sizeof(struct eth_tx_desc);
 }
 
 /**
@@ -916,86 +2025,30 @@ static void mv643xx_eth_free_all_tx_descs(struct net_device *dev)
 	mv643xx_eth_free_tx_descs(dev, 1);
 }
 
-/*
- * mv643xx_eth_receive
- *
- * This function is forward packets that are received from the port's
- * queues toward kernel core or FastRoute them to another interface.
- *
- * Input :	dev - a pointer to the required interface
- *		max - maximum number to receive (0 means unlimted)
- *
- * Output :	number of served packets
- */
-static int mv643xx_eth_receive_queue(struct net_device *dev, int budget)
+static void mv643xx_eth_free_tx_rings(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
-	unsigned int received_packets = 0;
-	struct sk_buff *skb;
-	struct pkt_info pkt_info;
 
-	while (budget-- > 0 && eth_port_receive(mp, &pkt_info) == ETH_OK) {
-		dma_unmap_single(NULL, pkt_info.buf_ptr, ETH_RX_SKB_SIZE,
-							DMA_FROM_DEVICE);
-		mp->rx_desc_count--;
-		received_packets++;
-
-		/*
-		 * Update statistics.
-		 * Note byte count includes 4 byte CRC count
-		 */
-		stats->rx_packets++;
-		stats->rx_bytes += pkt_info.byte_cnt;
-		skb = pkt_info.return_info;
-		/*
-		 * In case received a packet without first / last bits on OR
-		 * the error summary bit is on, the packets needs to be dropeed.
-		 */
-		if (((pkt_info.cmd_sts
-				& (ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) !=
-					(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC))
-				|| (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)) {
-			stats->rx_dropped++;
-			if ((pkt_info.cmd_sts & (ETH_RX_FIRST_DESC |
-							ETH_RX_LAST_DESC)) !=
-				(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) {
-				if (net_ratelimit())
-					printk(KERN_ERR
-						"%s: Received packet spread "
-						"on multiple descriptors\n",
-						dev->name);
-			}
-			if (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)
-				stats->rx_errors++;
+	/* Stop Tx Queues */
+	mv643xx_eth_port_disable_tx(mp);
 
-			dev_kfree_skb_irq(skb);
-		} else {
-			/*
-			 * The -4 is for the CRC in the trailer of the
-			 * received packet
-			 */
-			skb_put(skb, pkt_info.byte_cnt - 4);
+	/* Free outstanding skb's on TX ring */
+	mv643xx_eth_free_all_tx_descs(dev);
 
-			if (pkt_info.cmd_sts & ETH_LAYER_4_CHECKSUM_OK) {
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				skb->csum = htons(
-					(pkt_info.cmd_sts & 0x0007fff8) >> 3);
-			}
-			skb->protocol = eth_type_trans(skb, dev);
-#ifdef MV643XX_NAPI
-			netif_receive_skb(skb);
-#else
-			netif_rx(skb);
-#endif
-		}
-		dev->last_rx = jiffies;
-	}
-	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
+	BUG_ON(mp->tx_used_desc_q != mp->tx_curr_desc_q);
 
-	return received_packets;
+	/* Free TX ring */
+	if (mp->tx_sram_size)
+		iounmap(mp->p_tx_desc_area);
+	else
+		dma_free_coherent(NULL, mp->tx_desc_area_size,
+				mp->p_tx_desc_area, mp->tx_desc_dma);
 }
 
+
+/* netdev ops and related ***************************************************/
+static void eth_port_reset(struct mv643xx_private *mp);
+
 /* Set the mv643xx port configuration register for the speed/duplex mode. */
 static void mv643xx_eth_update_pscr(struct net_device *dev,
 				    struct ethtool_cmd *ecmd)
@@ -1118,6 +2171,125 @@ static irqreturn_t mv643xx_eth_int_handler(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+/*
+ * ethernet_phy_reset - Reset Ethernet port PHY.
+ *
+ * DESCRIPTION:
+ *	This routine utilizes the SMI interface to reset the ethernet port PHY.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port.
+ *
+ * OUTPUT:
+ *	The PHY is reset.
+ *
+ * RETURN:
+ *	None.
+ *
+ */
+static void ethernet_phy_reset(struct mv643xx_private *mp)
+{
+	unsigned int phy_reg_data;
+
+	/* Reset the PHY */
+	eth_port_read_smi_reg(mp, 0, &phy_reg_data);
+	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
+	eth_port_write_smi_reg(mp, 0, phy_reg_data);
+
+	/* wait for PHY to come out of reset */
+	do {
+		udelay(1);
+		eth_port_read_smi_reg(mp, 0, &phy_reg_data);
+	} while (phy_reg_data & 0x8000);
+}
+
+/*
+ * eth_port_start - Start the Ethernet port activity.
+ *
+ * DESCRIPTION:
+ *	This routine prepares the Ethernet port for Rx and Tx activity:
+ *	 1. Initialize Tx and Rx Current Descriptor Pointer for each queue that
+ *	    has been initialized a descriptor's ring (using
+ *	    ether_init_tx_desc_ring for Tx and ether_init_rx_desc_ring for Rx)
+ *	 2. Initialize and enable the Ethernet configuration port by writing to
+ *	    the port's configuration and command registers.
+ *	 3. Initialize and enable the SDMA by writing to the SDMA's
+ *	    configuration and command registers.  After completing these steps,
+ *	    the ethernet port SDMA can starts to perform Rx and Tx activities.
+ *
+ *	Note: Each Rx and Tx queue descriptor's list must be initialized prior
+ *	to calling this function (use ether_init_tx_desc_ring for Tx queues
+ *	and ether_init_rx_desc_ring for Rx queues).
+ *
+ * INPUT:
+ *	dev - a pointer to the required interface
+ *
+ * OUTPUT:
+ *	Ethernet port is ready to receive and transmit.
+ *
+ * RETURN:
+ *	None.
+ */
+static void eth_port_start(struct net_device *dev)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	unsigned int port_num = mp->port_num;
+	int tx_curr_desc, rx_curr_desc;
+	u32 pscr;
+	struct ethtool_cmd ethtool_cmd;
+
+	/* Assignment of Tx CTRP of given queue */
+	tx_curr_desc = mp->tx_curr_desc_q;
+	wrl(mp, TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
+
+	/* Assignment of Rx CRDP of given queue */
+	rx_curr_desc = mp->rx_curr_desc_q;
+	wrl(mp, RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
+
+	/* Add the assigned Ethernet address to the port's address table */
+	eth_port_uc_addr_set(mp, dev->dev_addr);
+
+	/* Assign port configuration and command. */
+	wrl(mp, PORT_CONFIG_REG(port_num),
+			  PORT_CONFIG_DEFAULT_VALUE);
+
+	wrl(mp, PORT_CONFIG_EXTEND_REG(port_num),
+			  PORT_CONFIG_EXTEND_DEFAULT_VALUE);
+
+	pscr = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
+
+	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
+	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
+
+	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
+		DISABLE_AUTO_NEG_SPEED_GMII    |
+		DISABLE_AUTO_NEG_FOR_DUPLX     |
+		DO_NOT_FORCE_LINK_FAIL	   |
+		SERIAL_PORT_CONTROL_RESERVED;
+
+	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
+
+	pscr |= SERIAL_PORT_ENABLE;
+	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
+
+	/* Assign port SDMA configuration */
+	wrl(mp, SDMA_CONFIG_REG(port_num),
+			  PORT_SDMA_CONFIG_DEFAULT_VALUE);
+
+	/* Enable port Rx. */
+	mv643xx_eth_port_enable_rx(mp, ETH_RX_QUEUES_ENABLED);
+
+	/* Disable port bandwidth limits by clearing MTU register */
+	wrl(mp, MAXIMUM_TRANSMIT_UNIT(port_num), 0);
+
+	/* save phy settings across reset */
+	mv643xx_get_settings(dev, &ethtool_cmd);
+	ethernet_phy_reset(mp);
+	mv643xx_set_settings(dev, &ethtool_cmd);
+}
+
 #ifdef MV643XX_COAL
 
 /*
@@ -1192,114 +2364,36 @@ static unsigned int eth_port_set_tx_coal(struct mv643xx_private *mp,
 }
 
 /*
- * ether_init_rx_desc_ring - Curve a Rx chain desc list and buffer in memory.
- *
- * DESCRIPTION:
- *	This function prepares a Rx chained list of descriptors and packet
- *	buffers in a form of a ring. The routine must be called after port
- *	initialization routine and before port start routine.
- *	The Ethernet SDMA engine uses CPU bus addresses to access the various
- *	devices in the system (i.e. DRAM). This function uses the ethernet
- *	struct 'virtual to physical' routine (set by the user) to set the ring
- *	with physical addresses.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
- *
- * OUTPUT:
- *	The routine updates the Ethernet port control struct with information
- *	regarding the Rx descriptors and buffers.
- *
- * RETURN:
- *	None.
- */
-static void ether_init_rx_desc_ring(struct mv643xx_private *mp)
-{
-	volatile struct eth_rx_desc *p_rx_desc;
-	int rx_desc_num = mp->rx_ring_size;
-	int i;
-
-	/* initialize the next_desc_ptr links in the Rx descriptors ring */
-	p_rx_desc = (struct eth_rx_desc *)mp->p_rx_desc_area;
-	for (i = 0; i < rx_desc_num; i++) {
-		p_rx_desc[i].next_desc_ptr = mp->rx_desc_dma +
-			((i + 1) % rx_desc_num) * sizeof(struct eth_rx_desc);
-	}
-
-	/* Save Rx desc pointer to driver struct. */
-	mp->rx_curr_desc_q = 0;
-	mp->rx_used_desc_q = 0;
-
-	mp->rx_desc_area_size = rx_desc_num * sizeof(struct eth_rx_desc);
-}
-
-/*
- * ether_init_tx_desc_ring - Curve a Tx chain desc list and buffer in memory.
+ * eth_port_init - Initialize the Ethernet port driver
  *
  * DESCRIPTION:
- *	This function prepares a Tx chained list of descriptors and packet
- *	buffers in a form of a ring. The routine must be called after port
- *	initialization routine and before port start routine.
- *	The Ethernet SDMA engine uses CPU bus addresses to access the various
- *	devices in the system (i.e. DRAM). This function uses the ethernet
- *	struct 'virtual to physical' routine (set by the user) to set the ring
- *	with physical addresses.
+ *	This function prepares the ethernet port to start its activity:
+ *	1) Completes the ethernet port driver struct initialization toward port
+ *		start routine.
+ *	2) Resets the device to a quiescent state in case of warm reboot.
+ *	3) Enable SDMA access to all four DRAM banks as well as internal SRAM.
+ *	4) Clean MAC tables. The reset status of those tables is unknown.
+ *	5) Set PHY address.
+ *	Note: Call this routine prior to eth_port_start routine and after
+ *	setting user values in the user fields of Ethernet port control
+ *	struct.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
+ *	struct mv643xx_private *mp	Ethernet port control struct
  *
  * OUTPUT:
- *	The routine updates the Ethernet port control struct with information
- *	regarding the Tx descriptors and buffers.
+ *	See description.
  *
  * RETURN:
  *	None.
  */
-static void ether_init_tx_desc_ring(struct mv643xx_private *mp)
-{
-	int tx_desc_num = mp->tx_ring_size;
-	struct eth_tx_desc *p_tx_desc;
-	int i;
-
-	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
-	p_tx_desc = (struct eth_tx_desc *)mp->p_tx_desc_area;
-	for (i = 0; i < tx_desc_num; i++) {
-		p_tx_desc[i].next_desc_ptr = mp->tx_desc_dma +
-			((i + 1) % tx_desc_num) * sizeof(struct eth_tx_desc);
-	}
-
-	mp->tx_curr_desc_q = 0;
-	mp->tx_used_desc_q = 0;
-
-	mp->tx_desc_area_size = tx_desc_num * sizeof(struct eth_tx_desc);
-}
-
-static int mv643xx_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int err;
-
-	spin_lock_irq(&mp->lock);
-	err = mii_ethtool_sset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
-
-	return err;
-}
-
-static int mv643xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static void eth_port_init(struct mv643xx_private *mp)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int err;
-
-	spin_lock_irq(&mp->lock);
-	err = mii_ethtool_gset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
+	mp->rx_resource_err = 0;
 
-	/* The PHY may support 1000baseT_Half, but the mv643xx does not */
-	cmd->supported &= ~SUPPORTED_1000baseT_Half;
-	cmd->advertising &= ~ADVERTISED_1000baseT_Half;
+	eth_port_reset(mp);
 
-	return err;
+	eth_port_init_mac_tables(mp);
 }
 
 /*
@@ -1449,53 +2543,41 @@ out_free_irq:
 	return err;
 }
 
-static void mv643xx_eth_free_tx_rings(struct net_device *dev)
+/*
+ * eth_port_reset - Reset Ethernet port
+ *
+ * DESCRIPTION:
+ * 	This routine resets the chip by aborting any SDMA engine activity and
+ *	clearing the MIB counters. The Receiver and the Transmit unit are in
+ *	idle state after this command is performed and the port is disabled.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port.
+ *
+ * OUTPUT:
+ *	Channel activity is halted.
+ *
+ * RETURN:
+ *	None.
+ *
+ */
+static void eth_port_reset(struct mv643xx_private *mp)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
+	unsigned int port_num = mp->port_num;
+	unsigned int reg_data;
 
-	/* Stop Tx Queues */
 	mv643xx_eth_port_disable_tx(mp);
-
-	/* Free outstanding skb's on TX ring */
-	mv643xx_eth_free_all_tx_descs(dev);
-
-	BUG_ON(mp->tx_used_desc_q != mp->tx_curr_desc_q);
-
-	/* Free TX ring */
-	if (mp->tx_sram_size)
-		iounmap(mp->p_tx_desc_area);
-	else
-		dma_free_coherent(NULL, mp->tx_desc_area_size,
-				mp->p_tx_desc_area, mp->tx_desc_dma);
-}
-
-static void mv643xx_eth_free_rx_rings(struct net_device *dev)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int curr;
-
-	/* Stop RX Queues */
 	mv643xx_eth_port_disable_rx(mp);
 
-	/* Free preallocated skb's on RX rings */
-	for (curr = 0; mp->rx_desc_count && curr < mp->rx_ring_size; curr++) {
-		if (mp->rx_skb[curr]) {
-			dev_kfree_skb(mp->rx_skb[curr]);
-			mp->rx_desc_count--;
-		}
-	}
+	/* Clear all MIB counters */
+	eth_clear_mib_counters(mp);
 
-	if (mp->rx_desc_count)
-		printk(KERN_ERR
-			"%s: Error in freeing Rx Ring. %d skb's still"
-			" stuck in RX Ring - ignoring them\n", dev->name,
-			mp->rx_desc_count);
-	/* Free RX ring */
-	if (mp->rx_sram_size)
-		iounmap(mp->p_rx_desc_area);
-	else
-		dma_free_coherent(NULL, mp->rx_desc_area_size,
-				mp->p_rx_desc_area, mp->rx_desc_dma);
+	/* Reset the Enable bit in the Configuration Register */
+	reg_data = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
+	reg_data &= ~(SERIAL_PORT_ENABLE		|
+			DO_NOT_FORCE_LINK_FAIL	|
+			FORCE_LINK_PASS);
+	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), reg_data);
 }
 
 /*
@@ -1534,250 +2616,308 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	return 0;
 }
 
-#ifdef MV643XX_NAPI
-/*
- * mv643xx_poll
- *
- * This function is used in case of NAPI
- */
-static int mv643xx_poll(struct napi_struct *napi, int budget)
+static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct mv643xx_private *mp = container_of(napi, struct mv643xx_private, napi);
-	struct net_device *dev = mp->dev;
-	unsigned int port_num = mp->port_num;
-	int work_done;
-
-#ifdef MV643XX_TX_FAST_REFILL
-	if (++mp->tx_clean_threshold > 5) {
-		mv643xx_eth_free_completed_tx_descs(dev);
-		mp->tx_clean_threshold = 0;
-	}
-#endif
-
-	work_done = 0;
-	if ((rdl(mp, RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
-	    != (u32) mp->rx_used_desc_q)
-		work_done = mv643xx_eth_receive_queue(dev, budget);
-
-	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
-		wrl(mp, INTERRUPT_CAUSE_REG(port_num), 0);
-		wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-		wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
-	}
+	struct mv643xx_private *mp = netdev_priv(dev);
 
-	return work_done;
+	return generic_mii_ioctl(&mp->mii, if_mii(ifr), cmd, NULL);
 }
-#endif
 
-/**
- * has_tiny_unaligned_frags - check if skb has any small, unaligned fragments
+/*
+ * Changes MTU (maximum transfer unit) of the gigabit ethenret port
  *
- * Hardware can't handle unaligned fragments smaller than 9 bytes.
- * This helper function detects that case.
+ * Input :	pointer to ethernet interface network device structure
+ *		new mtu size
+ * Output :	0 upon success, -EINVAL upon failure
  */
-
-static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
+static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 {
-	unsigned int frag;
-	skb_frag_t *fragp;
+	if ((new_mtu > 9500) || (new_mtu < 64))
+		return -EINVAL;
 
-	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-		fragp = &skb_shinfo(skb)->frags[frag];
-		if (fragp->size <= 8 && fragp->page_offset & 0x7)
-			return 1;
+	dev->mtu = new_mtu;
+	if (!netif_running(dev))
+		return 0;
+
+	/*
+	 * Stop and then re-open the interface. This will allocate RX
+	 * skbs of the new MTU.
+	 * There is a possible danger that the open will not succeed,
+	 * due to memory being full, which might fail the open function.
+	 */
+	mv643xx_eth_stop(dev);
+	if (mv643xx_eth_open(dev)) {
+		printk(KERN_ERR "%s: Fatal error on opening device\n",
+			dev->name);
 	}
+
 	return 0;
 }
 
-/**
- * eth_alloc_tx_desc_index - return the index of the next available tx desc
+/*
+ * mv643xx_eth_tx_timeout_task
+ *
+ * Actual routine to reset the adapter when a timeout on Tx has occurred
  */
-static int eth_alloc_tx_desc_index(struct mv643xx_private *mp)
+static void mv643xx_eth_tx_timeout_task(struct work_struct *ugly)
 {
-	int tx_desc_curr;
+	struct mv643xx_private *mp = container_of(ugly, struct mv643xx_private,
+						  tx_timeout_task);
+	struct net_device *dev = mp->dev;
 
-	BUG_ON(mp->tx_desc_count >= mp->tx_ring_size);
+	if (!netif_running(dev))
+		return;
 
-	tx_desc_curr = mp->tx_curr_desc_q;
-	mp->tx_curr_desc_q = (tx_desc_curr + 1) % mp->tx_ring_size;
+	netif_stop_queue(dev);
 
-	BUG_ON(mp->tx_curr_desc_q == mp->tx_used_desc_q);
+	eth_port_reset(mp);
+	eth_port_start(dev);
 
-	return tx_desc_curr;
+	if (mp->tx_ring_size - mp->tx_desc_count >= MAX_DESCS_PER_SKB)
+		netif_wake_queue(dev);
 }
 
-/**
- * eth_tx_fill_frag_descs - fill tx hw descriptors for an skb's fragments.
+/*
+ * mv643xx_eth_tx_timeout
  *
- * Ensure the data for each fragment to be transmitted is mapped properly,
- * then fill in descriptors in the tx hw queue.
+ * Called upon a timeout on transmitting a packet
+ *
+ * Input :	pointer to ethernet interface network device structure.
+ * Output :	N/A
  */
-static void eth_tx_fill_frag_descs(struct mv643xx_private *mp,
-				   struct sk_buff *skb)
+static void mv643xx_eth_tx_timeout(struct net_device *dev)
 {
-	int frag;
-	int tx_index;
-	struct eth_tx_desc *desc;
-
-	for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
-		skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
-
-		tx_index = eth_alloc_tx_desc_index(mp);
-		desc = &mp->p_tx_desc_area[tx_index];
+	struct mv643xx_private *mp = netdev_priv(dev);
 
-		desc->cmd_sts = ETH_BUFFER_OWNED_BY_DMA;
-		/* Last Frag enables interrupt and frees the skb */
-		if (frag == (skb_shinfo(skb)->nr_frags - 1)) {
-			desc->cmd_sts |= ETH_ZERO_PADDING |
-					 ETH_TX_LAST_DESC |
-					 ETH_TX_ENABLE_INTERRUPT;
-			mp->tx_skb[tx_index] = skb;
-		} else
-			mp->tx_skb[tx_index] = NULL;
+	printk(KERN_INFO "%s: TX timeout  ", dev->name);
 
-		desc = &mp->p_tx_desc_area[tx_index];
-		desc->l4i_chk = 0;
-		desc->byte_cnt = this_frag->size;
-		desc->buf_ptr = dma_map_page(NULL, this_frag->page,
-						this_frag->page_offset,
-						this_frag->size,
-						DMA_TO_DEVICE);
-	}
+	/* Do the reset outside of interrupt context */
+	schedule_work(&mp->tx_timeout_task);
 }
 
-static inline __be16 sum16_as_be(__sum16 sum)
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void mv643xx_netpoll(struct net_device *netdev)
 {
-	return (__force __be16)sum;
+	struct mv643xx_private *mp = netdev_priv(netdev);
+	int port_num = mp->port_num;
+
+	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+	/* wait for previous write to complete */
+	rdl(mp, INTERRUPT_MASK_REG(port_num));
+
+	mv643xx_eth_int_handler(netdev->irq, netdev);
+
+	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
 }
+#endif
 
-/**
- * eth_tx_submit_descs_for_skb - submit data from an skb to the tx hw
- *
- * Ensure the data for an skb to be transmitted is mapped properly,
- * then fill in descriptors in the tx hw queue and start the hardware.
+/*
+ * Wrappers for MII support library.
  */
-static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
-					struct sk_buff *skb)
+static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	int tx_index;
-	struct eth_tx_desc *desc;
-	u32 cmd_sts;
-	int length;
-	int nr_frags = skb_shinfo(skb)->nr_frags;
+	struct mv643xx_private *mp = netdev_priv(dev);
+	int val;
 
-	cmd_sts = ETH_TX_FIRST_DESC | ETH_GEN_CRC | ETH_BUFFER_OWNED_BY_DMA;
+	eth_port_read_smi_reg(mp, location, &val);
+	return val;
+}
 
-	tx_index = eth_alloc_tx_desc_index(mp);
-	desc = &mp->p_tx_desc_area[tx_index];
+static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	eth_port_write_smi_reg(mp, location, val);
+}
 
-	if (nr_frags) {
-		eth_tx_fill_frag_descs(mp, skb);
 
-		length = skb_headlen(skb);
-		mp->tx_skb[tx_index] = NULL;
-	} else {
-		cmd_sts |= ETH_ZERO_PADDING |
-			   ETH_TX_LAST_DESC |
-			   ETH_TX_ENABLE_INTERRUPT;
-		length = skb->len;
-		mp->tx_skb[tx_index] = skb;
+/* platform glue ************************************************************/
+static void mv643xx_eth_conf_mbus_windows(struct mv643xx_shared_private *msp,
+					  struct mbus_dram_target_info *dram)
+{
+	void __iomem *base = msp->eth_base;
+	u32 win_enable;
+	u32 win_protect;
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		writel(0, base + WINDOW_BASE(i));
+		writel(0, base + WINDOW_SIZE(i));
+		if (i < 4)
+			writel(0, base + WINDOW_REMAP_HIGH(i));
 	}
 
-	desc->byte_cnt = length;
-	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
+	win_enable = 0x3f;
+	win_protect = 0;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		BUG_ON(skb->protocol != htons(ETH_P_IP));
+	for (i = 0; i < dram->num_cs; i++) {
+		struct mbus_dram_window *cs = dram->cs + i;
 
-		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
-			   ETH_GEN_IP_V_4_CHECKSUM  |
-			   ip_hdr(skb)->ihl << ETH_TX_IHL_SHIFT;
+		writel((cs->base & 0xffff0000) |
+			(cs->mbus_attr << 8) |
+			dram->mbus_dram_target_id, base + WINDOW_BASE(i));
+		writel((cs->size - 1) & 0xffff0000, base + WINDOW_SIZE(i));
 
-		switch (ip_hdr(skb)->protocol) {
-		case IPPROTO_UDP:
-			cmd_sts |= ETH_UDP_FRAME;
-			desc->l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
-			break;
-		case IPPROTO_TCP:
-			desc->l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
-			break;
-		default:
-			BUG();
-		}
-	} else {
-		/* Errata BTS #50, IHL must be 5 if no HW checksum */
-		cmd_sts |= 5 << ETH_TX_IHL_SHIFT;
-		desc->l4i_chk = 0;
+		win_enable &= ~(1 << i);
+		win_protect |= 3 << (2 * i);
 	}
 
-	/* ensure all other descriptors are written before first cmd_sts */
-	wmb();
-	desc->cmd_sts = cmd_sts;
+	writel(win_enable, base + WINDOW_BAR_ENABLE);
+	msp->win_protect = win_protect;
+}
 
-	/* ensure all descriptors are written before poking hardware */
-	wmb();
-	mv643xx_eth_port_enable_tx(mp, ETH_TX_QUEUES_ENABLED);
+static int mv643xx_eth_shared_probe(struct platform_device *pdev)
+{
+	static int mv643xx_version_printed = 0;
+	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
+	struct mv643xx_shared_private *msp;
+	struct resource *res;
+	int ret;
 
-	mp->tx_desc_count += nr_frags + 1;
+	if (!mv643xx_version_printed++)
+		printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
+
+	ret = -EINVAL;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (res == NULL)
+		goto out;
+
+	ret = -ENOMEM;
+	msp = kmalloc(sizeof(*msp), GFP_KERNEL);
+	if (msp == NULL)
+		goto out;
+	memset(msp, 0, sizeof(*msp));
+
+	msp->eth_base = ioremap(res->start, res->end - res->start + 1);
+	if (msp->eth_base == NULL)
+		goto out_free;
+
+	spin_lock_init(&msp->phy_lock);
+	msp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
+
+	platform_set_drvdata(pdev, msp);
+
+	/*
+	 * (Re-)program MBUS remapping windows if we are asked to.
+	 */
+	if (pd != NULL && pd->dram != NULL)
+		mv643xx_eth_conf_mbus_windows(msp, pd->dram);
+
+	return 0;
+
+out_free:
+	kfree(msp);
+out:
+	return ret;
 }
 
-/**
- * mv643xx_eth_start_xmit - queue an skb to the hardware for transmission
- *
- */
-static int mv643xx_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
-	unsigned long flags;
+	struct mv643xx_shared_private *msp = platform_get_drvdata(pdev);
 
-	BUG_ON(netif_queue_stopped(dev));
+	iounmap(msp->eth_base);
+	kfree(msp);
 
-	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
-		stats->tx_dropped++;
-		printk(KERN_DEBUG "%s: failed to linearize tiny "
-				"unaligned fragment\n", dev->name);
-		return NETDEV_TX_BUSY;
-	}
+	return 0;
+}
 
-	spin_lock_irqsave(&mp->lock, flags);
+static struct platform_driver mv643xx_eth_shared_driver = {
+	.probe = mv643xx_eth_shared_probe,
+	.remove = mv643xx_eth_shared_remove,
+	.driver = {
+		.name = MV643XX_ETH_SHARED_NAME,
+		.owner	= THIS_MODULE,
+	},
+};
 
-	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB) {
-		printk(KERN_ERR "%s: transmit with queue full\n", dev->name);
-		netif_stop_queue(dev);
-		spin_unlock_irqrestore(&mp->lock, flags);
-		return NETDEV_TX_BUSY;
-	}
+/*
+ * ethernet_phy_set - Set the ethernet port PHY address.
+ *
+ * DESCRIPTION:
+ *	This routine sets the given ethernet port PHY address.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port.
+ *	int		phy_addr	PHY address.
+ *
+ * OUTPUT:
+ *	None.
+ *
+ * RETURN:
+ *	None.
+ *
+ */
+static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr)
+{
+	u32 reg_data;
+	int addr_shift = 5 * mp->port_num;
 
-	eth_tx_submit_descs_for_skb(mp, skb);
-	stats->tx_bytes += skb->len;
-	stats->tx_packets++;
-	dev->trans_start = jiffies;
+	reg_data = rdl(mp, PHY_ADDR_REG);
+	reg_data &= ~(0x1f << addr_shift);
+	reg_data |= (phy_addr & 0x1f) << addr_shift;
+	wrl(mp, PHY_ADDR_REG, reg_data);
+}
 
-	if (mp->tx_ring_size - mp->tx_desc_count < MAX_DESCS_PER_SKB)
-		netif_stop_queue(dev);
+/*
+ * ethernet_phy_get - Get the ethernet port PHY address.
+ *
+ * DESCRIPTION:
+ *	This routine returns the given ethernet port PHY address.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port.
+ *
+ * OUTPUT:
+ *	None.
+ *
+ * RETURN:
+ *	PHY address.
+ *
+ */
+static int ethernet_phy_get(struct mv643xx_private *mp)
+{
+	unsigned int reg_data;
 
-	spin_unlock_irqrestore(&mp->lock, flags);
+	reg_data = rdl(mp, PHY_ADDR_REG);
 
-	return NETDEV_TX_OK;
+	return ((reg_data >> (5 * mp->port_num)) & 0x1f);
 }
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static void mv643xx_netpoll(struct net_device *netdev)
+/*
+ * ethernet_phy_detect - Detect whether a phy is present
+ *
+ * DESCRIPTION:
+ *	This function tests whether there is a PHY present on
+ *	the specified port.
+ *
+ * INPUT:
+ *	struct mv643xx_private *mp	Ethernet Port.
+ *
+ * OUTPUT:
+ *	None
+ *
+ * RETURN:
+ *	0 on success
+ *	-ENODEV on failure
+ *
+ */
+static int ethernet_phy_detect(struct mv643xx_private *mp)
 {
-	struct mv643xx_private *mp = netdev_priv(netdev);
-	int port_num = mp->port_num;
+	unsigned int phy_reg_data0;
+	int auto_neg;
 
-	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
-	/* wait for previous write to complete */
-	rdl(mp, INTERRUPT_MASK_REG(port_num));
+	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
+	auto_neg = phy_reg_data0 & 0x1000;
+	phy_reg_data0 ^= 0x1000;	/* invert auto_neg */
+	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
 
-	mv643xx_eth_int_handler(netdev->irq, netdev);
+	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
+	if ((phy_reg_data0 & 0x1000) == auto_neg)
+		return -ENODEV;				/* change didn't take */
 
-	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	phy_reg_data0 ^= 0x1000;
+	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
+	return 0;
 }
-#endif
 
 static void mv643xx_init_ethtool_cmd(struct net_device *dev, int phy_address,
 				     int speed, int duplex,
@@ -2008,95 +3148,6 @@ static int mv643xx_eth_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static void mv643xx_eth_conf_mbus_windows(struct mv643xx_shared_private *msp,
-					  struct mbus_dram_target_info *dram)
-{
-	void __iomem *base = msp->eth_base;
-	u32 win_enable;
-	u32 win_protect;
-	int i;
-
-	for (i = 0; i < 6; i++) {
-		writel(0, base + WINDOW_BASE(i));
-		writel(0, base + WINDOW_SIZE(i));
-		if (i < 4)
-			writel(0, base + WINDOW_REMAP_HIGH(i));
-	}
-
-	win_enable = 0x3f;
-	win_protect = 0;
-
-	for (i = 0; i < dram->num_cs; i++) {
-		struct mbus_dram_window *cs = dram->cs + i;
-
-		writel((cs->base & 0xffff0000) |
-			(cs->mbus_attr << 8) |
-			dram->mbus_dram_target_id, base + WINDOW_BASE(i));
-		writel((cs->size - 1) & 0xffff0000, base + WINDOW_SIZE(i));
-
-		win_enable &= ~(1 << i);
-		win_protect |= 3 << (2 * i);
-	}
-
-	writel(win_enable, base + WINDOW_BAR_ENABLE);
-	msp->win_protect = win_protect;
-}
-
-static int mv643xx_eth_shared_probe(struct platform_device *pdev)
-{
-	static int mv643xx_version_printed = 0;
-	struct mv643xx_eth_shared_platform_data *pd = pdev->dev.platform_data;
-	struct mv643xx_shared_private *msp;
-	struct resource *res;
-	int ret;
-
-	if (!mv643xx_version_printed++)
-		printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
-
-	ret = -EINVAL;
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (res == NULL)
-		goto out;
-
-	ret = -ENOMEM;
-	msp = kmalloc(sizeof(*msp), GFP_KERNEL);
-	if (msp == NULL)
-		goto out;
-	memset(msp, 0, sizeof(*msp));
-
-	msp->eth_base = ioremap(res->start, res->end - res->start + 1);
-	if (msp->eth_base == NULL)
-		goto out_free;
-
-	spin_lock_init(&msp->phy_lock);
-	msp->t_clk = (pd != NULL && pd->t_clk != 0) ? pd->t_clk : 133000000;
-
-	platform_set_drvdata(pdev, msp);
-
-	/*
-	 * (Re-)program MBUS remapping windows if we are asked to.
-	 */
-	if (pd != NULL && pd->dram != NULL)
-		mv643xx_eth_conf_mbus_windows(msp, pd->dram);
-
-	return 0;
-
-out_free:
-	kfree(msp);
-out:
-	return ret;
-}
-
-static int mv643xx_eth_shared_remove(struct platform_device *pdev)
-{
-	struct mv643xx_shared_private *msp = platform_get_drvdata(pdev);
-
-	iounmap(msp->eth_base);
-	kfree(msp);
-
-	return 0;
-}
-
 static void mv643xx_eth_shutdown(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
@@ -2120,15 +3171,6 @@ static struct platform_driver mv643xx_eth_driver = {
 	},
 };
 
-static struct platform_driver mv643xx_eth_shared_driver = {
-	.probe = mv643xx_eth_shared_probe,
-	.remove = mv643xx_eth_shared_remove,
-	.driver = {
-		.name = MV643XX_ETH_SHARED_NAME,
-		.owner	= THIS_MODULE,
-	},
-};
-
 /*
  * mv643xx_init_module
  *
@@ -2175,1191 +3217,3 @@ MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV643XX");
 MODULE_ALIAS("platform:" MV643XX_ETH_NAME);
 MODULE_ALIAS("platform:" MV643XX_ETH_SHARED_NAME);
-
-/*
- * The second part is the low level driver of the gigE ethernet ports.
- */
-
-/*
- * Marvell's Gigabit Ethernet controller low level driver
- *
- * DESCRIPTION:
- *	This file introduce low level API to Marvell's Gigabit Ethernet
- *		controller. This Gigabit Ethernet Controller driver API controls
- *		1) Operations (i.e. port init, start, reset etc').
- *		2) Data flow (i.e. port send, receive etc').
- *		Each Gigabit Ethernet port is controlled via
- *		struct mv643xx_private.
- *		This struct includes user configuration information as well as
- *		driver internal data needed for its operations.
- *
- *		Supported Features:
- *		- This low level driver is OS independent. Allocating memory for
- *		  the descriptor rings and buffers are not within the scope of
- *		  this driver.
- *		- The user is free from Rx/Tx queue managing.
- *		- This low level driver introduce functionality API that enable
- *		  the to operate Marvell's Gigabit Ethernet Controller in a
- *		  convenient way.
- *		- Simple Gigabit Ethernet port operation API.
- *		- Simple Gigabit Ethernet port data flow API.
- *		- Data flow and operation API support per queue functionality.
- *		- Support cached descriptors for better performance.
- *		- Enable access to all four DRAM banks and internal SRAM memory
- *		  spaces.
- *		- PHY access and control API.
- *		- Port control register configuration API.
- *		- Full control over Unicast and Multicast MAC configurations.
- *
- *		Operation flow:
- *
- *		Initialization phase
- *		This phase complete the initialization of the the
- *		mv643xx_private struct.
- *		User information regarding port configuration has to be set
- *		prior to calling the port initialization routine.
- *
- *		In this phase any port Tx/Rx activity is halted, MIB counters
- *		are cleared, PHY address is set according to user parameter and
- *		access to DRAM and internal SRAM memory spaces.
- *
- *		Driver ring initialization
- *		Allocating memory for the descriptor rings and buffers is not
- *		within the scope of this driver. Thus, the user is required to
- *		allocate memory for the descriptors ring and buffers. Those
- *		memory parameters are used by the Rx and Tx ring initialization
- *		routines in order to curve the descriptor linked list in a form
- *		of a ring.
- *		Note: Pay special attention to alignment issues when using
- *		cached descriptors/buffers. In this phase the driver store
- *		information in the mv643xx_private struct regarding each queue
- *		ring.
- *
- *		Driver start
- *		This phase prepares the Ethernet port for Rx and Tx activity.
- *		It uses the information stored in the mv643xx_private struct to
- *		initialize the various port registers.
- *
- *		Data flow:
- *		All packet references to/from the driver are done using
- *		struct pkt_info.
- *		This struct is a unified struct used with Rx and Tx operations.
- *		This way the user is not required to be familiar with neither
- *		Tx nor Rx descriptors structures.
- *		The driver's descriptors rings are management by indexes.
- *		Those indexes controls the ring resources and used to indicate
- *		a SW resource error:
- *		'current'
- *		This index points to the current available resource for use. For
- *		example in Rx process this index will point to the descriptor
- *		that will be passed to the user upon calling the receive
- *		routine.  In Tx process, this index will point to the descriptor
- *		that will be assigned with the user packet info and transmitted.
- *		'used'
- *		This index points to the descriptor that need to restore its
- *		resources. For example in Rx process, using the Rx buffer return
- *		API will attach the buffer returned in packet info to the
- *		descriptor pointed by 'used'. In Tx process, using the Tx
- *		descriptor return will merely return the user packet info with
- *		the command status of the transmitted buffer pointed by the
- *		'used' index. Nevertheless, it is essential to use this routine
- *		to update the 'used' index.
- *		'first'
- *		This index supports Tx Scatter-Gather. It points to the first
- *		descriptor of a packet assembled of multiple buffers. For
- *		example when in middle of Such packet we have a Tx resource
- *		error the 'curr' index get the value of 'first' to indicate
- *		that the ring returned to its state before trying to transmit
- *		this packet.
- *
- *		Receive operation:
- *		The eth_port_receive API set the packet information struct,
- *		passed by the caller, with received information from the
- *		'current' SDMA descriptor.
- *		It is the user responsibility to return this resource back
- *		to the Rx descriptor ring to enable the reuse of this source.
- *		Return Rx resource is done using the eth_rx_return_buff API.
- *
- *	Prior to calling the initialization routine eth_port_init() the user
- *	must set the following fields under mv643xx_private struct:
- *	port_num		User Ethernet port number.
- *	port_config		User port configuration value.
- *	port_config_extend	User port config extend value.
- *	port_sdma_config	User port SDMA config value.
- *	port_serial_control	User port serial control value.
- *
- *		This driver data flow is done using the struct pkt_info which
- *		is a unified struct for Rx and Tx operations:
- *
- *		byte_cnt	Tx/Rx descriptor buffer byte count.
- *		l4i_chk		CPU provided TCP Checksum. For Tx operation
- *				only.
- *		cmd_sts		Tx/Rx descriptor command status.
- *		buf_ptr		Tx/Rx descriptor buffer pointer.
- *		return_info	Tx/Rx user resource return information.
- */
-
-/* Ethernet Port routines */
-static void eth_port_set_filter_table_entry(struct mv643xx_private *mp,
-					    int table, unsigned char entry);
-
-/*
- * eth_port_init - Initialize the Ethernet port driver
- *
- * DESCRIPTION:
- *	This function prepares the ethernet port to start its activity:
- *	1) Completes the ethernet port driver struct initialization toward port
- *		start routine.
- *	2) Resets the device to a quiescent state in case of warm reboot.
- *	3) Enable SDMA access to all four DRAM banks as well as internal SRAM.
- *	4) Clean MAC tables. The reset status of those tables is unknown.
- *	5) Set PHY address.
- *	Note: Call this routine prior to eth_port_start routine and after
- *	setting user values in the user fields of Ethernet port control
- *	struct.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet port control struct
- *
- * OUTPUT:
- *	See description.
- *
- * RETURN:
- *	None.
- */
-static void eth_port_init(struct mv643xx_private *mp)
-{
-	mp->rx_resource_err = 0;
-
-	eth_port_reset(mp);
-
-	eth_port_init_mac_tables(mp);
-}
-
-/*
- * eth_port_start - Start the Ethernet port activity.
- *
- * DESCRIPTION:
- *	This routine prepares the Ethernet port for Rx and Tx activity:
- *	 1. Initialize Tx and Rx Current Descriptor Pointer for each queue that
- *	    has been initialized a descriptor's ring (using
- *	    ether_init_tx_desc_ring for Tx and ether_init_rx_desc_ring for Rx)
- *	 2. Initialize and enable the Ethernet configuration port by writing to
- *	    the port's configuration and command registers.
- *	 3. Initialize and enable the SDMA by writing to the SDMA's
- *	    configuration and command registers.  After completing these steps,
- *	    the ethernet port SDMA can starts to perform Rx and Tx activities.
- *
- *	Note: Each Rx and Tx queue descriptor's list must be initialized prior
- *	to calling this function (use ether_init_tx_desc_ring for Tx queues
- *	and ether_init_rx_desc_ring for Rx queues).
- *
- * INPUT:
- *	dev - a pointer to the required interface
- *
- * OUTPUT:
- *	Ethernet port is ready to receive and transmit.
- *
- * RETURN:
- *	None.
- */
-static void eth_port_start(struct net_device *dev)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
-	int tx_curr_desc, rx_curr_desc;
-	u32 pscr;
-	struct ethtool_cmd ethtool_cmd;
-
-	/* Assignment of Tx CTRP of given queue */
-	tx_curr_desc = mp->tx_curr_desc_q;
-	wrl(mp, TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
-		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
-
-	/* Assignment of Rx CRDP of given queue */
-	rx_curr_desc = mp->rx_curr_desc_q;
-	wrl(mp, RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
-		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
-
-	/* Add the assigned Ethernet address to the port's address table */
-	eth_port_uc_addr_set(mp, dev->dev_addr);
-
-	/* Assign port configuration and command. */
-	wrl(mp, PORT_CONFIG_REG(port_num),
-			  PORT_CONFIG_DEFAULT_VALUE);
-
-	wrl(mp, PORT_CONFIG_EXTEND_REG(port_num),
-			  PORT_CONFIG_EXTEND_DEFAULT_VALUE);
-
-	pscr = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
-
-	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
-
-	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
-		DISABLE_AUTO_NEG_SPEED_GMII    |
-		DISABLE_AUTO_NEG_FOR_DUPLX     |
-		DO_NOT_FORCE_LINK_FAIL	   |
-		SERIAL_PORT_CONTROL_RESERVED;
-
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
-
-	pscr |= SERIAL_PORT_ENABLE;
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
-
-	/* Assign port SDMA configuration */
-	wrl(mp, SDMA_CONFIG_REG(port_num),
-			  PORT_SDMA_CONFIG_DEFAULT_VALUE);
-
-	/* Enable port Rx. */
-	mv643xx_eth_port_enable_rx(mp, ETH_RX_QUEUES_ENABLED);
-
-	/* Disable port bandwidth limits by clearing MTU register */
-	wrl(mp, MAXIMUM_TRANSMIT_UNIT(port_num), 0);
-
-	/* save phy settings across reset */
-	mv643xx_get_settings(dev, &ethtool_cmd);
-	ethernet_phy_reset(mp);
-	mv643xx_set_settings(dev, &ethtool_cmd);
-}
-
-/*
- * eth_port_uc_addr_set - Write a MAC address into the port's hw registers
- */
-static void eth_port_uc_addr_set(struct mv643xx_private *mp,
-				 unsigned char *p_addr)
-{
-	unsigned int port_num = mp->port_num;
-	unsigned int mac_h;
-	unsigned int mac_l;
-	int table;
-
-	mac_l = (p_addr[4] << 8) | (p_addr[5]);
-	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
-							(p_addr[3] << 0);
-
-	wrl(mp, MAC_ADDR_LOW(port_num), mac_l);
-	wrl(mp, MAC_ADDR_HIGH(port_num), mac_h);
-
-	/* Accept frames with this address */
-	table = DA_FILTER_UNICAST_TABLE_BASE(port_num);
-	eth_port_set_filter_table_entry(mp, table, p_addr[5] & 0x0f);
-}
-
-/*
- * eth_port_uc_addr_get - Read the MAC address from the port's hw registers
- */
-static void eth_port_uc_addr_get(struct mv643xx_private *mp,
-				 unsigned char *p_addr)
-{
-	unsigned int port_num = mp->port_num;
-	unsigned int mac_h;
-	unsigned int mac_l;
-
-	mac_h = rdl(mp, MAC_ADDR_HIGH(port_num));
-	mac_l = rdl(mp, MAC_ADDR_LOW(port_num));
-
-	p_addr[0] = (mac_h >> 24) & 0xff;
-	p_addr[1] = (mac_h >> 16) & 0xff;
-	p_addr[2] = (mac_h >> 8) & 0xff;
-	p_addr[3] = mac_h & 0xff;
-	p_addr[4] = (mac_l >> 8) & 0xff;
-	p_addr[5] = mac_l & 0xff;
-}
-
-/*
- * The entries in each table are indexed by a hash of a packet's MAC
- * address.  One bit in each entry determines whether the packet is
- * accepted.  There are 4 entries (each 8 bits wide) in each register
- * of the table.  The bits in each entry are defined as follows:
- *	0	Accept=1, Drop=0
- *	3-1	Queue			(ETH_Q0=0)
- *	7-4	Reserved = 0;
- */
-static void eth_port_set_filter_table_entry(struct mv643xx_private *mp,
-					    int table, unsigned char entry)
-{
-	unsigned int table_reg;
-	unsigned int tbl_offset;
-	unsigned int reg_offset;
-
-	tbl_offset = (entry / 4) * 4;	/* Register offset of DA table entry */
-	reg_offset = entry % 4;		/* Entry offset within the register */
-
-	/* Set "accepts frame bit" at specified table entry */
-	table_reg = rdl(mp, table + tbl_offset);
-	table_reg |= 0x01 << (8 * reg_offset);
-	wrl(mp, table + tbl_offset, table_reg);
-}
-
-/*
- * eth_port_mc_addr - Multicast address settings.
- *
- * The MV device supports multicast using two tables:
- * 1) Special Multicast Table for MAC addresses of the form
- *    0x01-00-5E-00-00-XX (where XX is between 0x00 and 0x_FF).
- *    The MAC DA[7:0] bits are used as a pointer to the Special Multicast
- *    Table entries in the DA-Filter table.
- * 2) Other Multicast Table for multicast of another type. A CRC-8bit
- *    is used as an index to the Other Multicast Table entries in the
- *    DA-Filter table.  This function calculates the CRC-8bit value.
- * In either case, eth_port_set_filter_table_entry() is then called
- * to set to set the actual table entry.
- */
-static void eth_port_mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
-{
-	unsigned int port_num = mp->port_num;
-	unsigned int mac_h;
-	unsigned int mac_l;
-	unsigned char crc_result = 0;
-	int table;
-	int mac_array[48];
-	int crc[8];
-	int i;
-
-	if ((p_addr[0] == 0x01) && (p_addr[1] == 0x00) &&
-	    (p_addr[2] == 0x5E) && (p_addr[3] == 0x00) && (p_addr[4] == 0x00)) {
-		table = DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num);
-		eth_port_set_filter_table_entry(mp, table, p_addr[5]);
-		return;
-	}
-
-	/* Calculate CRC-8 out of the given address */
-	mac_h = (p_addr[0] << 8) | (p_addr[1]);
-	mac_l = (p_addr[2] << 24) | (p_addr[3] << 16) |
-			(p_addr[4] << 8) | (p_addr[5] << 0);
-
-	for (i = 0; i < 32; i++)
-		mac_array[i] = (mac_l >> i) & 0x1;
-	for (i = 32; i < 48; i++)
-		mac_array[i] = (mac_h >> (i - 32)) & 0x1;
-
-	crc[0] = mac_array[45] ^ mac_array[43] ^ mac_array[40] ^ mac_array[39] ^
-		 mac_array[35] ^ mac_array[34] ^ mac_array[31] ^ mac_array[30] ^
-		 mac_array[28] ^ mac_array[23] ^ mac_array[21] ^ mac_array[19] ^
-		 mac_array[18] ^ mac_array[16] ^ mac_array[14] ^ mac_array[12] ^
-		 mac_array[8]  ^ mac_array[7]  ^ mac_array[6]  ^ mac_array[0];
-
-	crc[1] = mac_array[46] ^ mac_array[45] ^ mac_array[44] ^ mac_array[43] ^
-		 mac_array[41] ^ mac_array[39] ^ mac_array[36] ^ mac_array[34] ^
-		 mac_array[32] ^ mac_array[30] ^ mac_array[29] ^ mac_array[28] ^
-		 mac_array[24] ^ mac_array[23] ^ mac_array[22] ^ mac_array[21] ^
-		 mac_array[20] ^ mac_array[18] ^ mac_array[17] ^ mac_array[16] ^
-		 mac_array[15] ^ mac_array[14] ^ mac_array[13] ^ mac_array[12] ^
-		 mac_array[9]  ^ mac_array[6]  ^ mac_array[1]  ^ mac_array[0];
-
-	crc[2] = mac_array[47] ^ mac_array[46] ^ mac_array[44] ^ mac_array[43] ^
-		 mac_array[42] ^ mac_array[39] ^ mac_array[37] ^ mac_array[34] ^
-		 mac_array[33] ^ mac_array[29] ^ mac_array[28] ^ mac_array[25] ^
-		 mac_array[24] ^ mac_array[22] ^ mac_array[17] ^ mac_array[15] ^
-		 mac_array[13] ^ mac_array[12] ^ mac_array[10] ^ mac_array[8]  ^
-		 mac_array[6]  ^ mac_array[2]  ^ mac_array[1]  ^ mac_array[0];
-
-	crc[3] = mac_array[47] ^ mac_array[45] ^ mac_array[44] ^ mac_array[43] ^
-		 mac_array[40] ^ mac_array[38] ^ mac_array[35] ^ mac_array[34] ^
-		 mac_array[30] ^ mac_array[29] ^ mac_array[26] ^ mac_array[25] ^
-		 mac_array[23] ^ mac_array[18] ^ mac_array[16] ^ mac_array[14] ^
-		 mac_array[13] ^ mac_array[11] ^ mac_array[9]  ^ mac_array[7]  ^
-		 mac_array[3]  ^ mac_array[2]  ^ mac_array[1];
-
-	crc[4] = mac_array[46] ^ mac_array[45] ^ mac_array[44] ^ mac_array[41] ^
-		 mac_array[39] ^ mac_array[36] ^ mac_array[35] ^ mac_array[31] ^
-		 mac_array[30] ^ mac_array[27] ^ mac_array[26] ^ mac_array[24] ^
-		 mac_array[19] ^ mac_array[17] ^ mac_array[15] ^ mac_array[14] ^
-		 mac_array[12] ^ mac_array[10] ^ mac_array[8]  ^ mac_array[4]  ^
-		 mac_array[3]  ^ mac_array[2];
-
-	crc[5] = mac_array[47] ^ mac_array[46] ^ mac_array[45] ^ mac_array[42] ^
-		 mac_array[40] ^ mac_array[37] ^ mac_array[36] ^ mac_array[32] ^
-		 mac_array[31] ^ mac_array[28] ^ mac_array[27] ^ mac_array[25] ^
-		 mac_array[20] ^ mac_array[18] ^ mac_array[16] ^ mac_array[15] ^
-		 mac_array[13] ^ mac_array[11] ^ mac_array[9]  ^ mac_array[5]  ^
-		 mac_array[4]  ^ mac_array[3];
-
-	crc[6] = mac_array[47] ^ mac_array[46] ^ mac_array[43] ^ mac_array[41] ^
-		 mac_array[38] ^ mac_array[37] ^ mac_array[33] ^ mac_array[32] ^
-		 mac_array[29] ^ mac_array[28] ^ mac_array[26] ^ mac_array[21] ^
-		 mac_array[19] ^ mac_array[17] ^ mac_array[16] ^ mac_array[14] ^
-		 mac_array[12] ^ mac_array[10] ^ mac_array[6]  ^ mac_array[5]  ^
-		 mac_array[4];
-
-	crc[7] = mac_array[47] ^ mac_array[44] ^ mac_array[42] ^ mac_array[39] ^
-		 mac_array[38] ^ mac_array[34] ^ mac_array[33] ^ mac_array[30] ^
-		 mac_array[29] ^ mac_array[27] ^ mac_array[22] ^ mac_array[20] ^
-		 mac_array[18] ^ mac_array[17] ^ mac_array[15] ^ mac_array[13] ^
-		 mac_array[11] ^ mac_array[7]  ^ mac_array[6]  ^ mac_array[5];
-
-	for (i = 0; i < 8; i++)
-		crc_result = crc_result | (crc[i] << i);
-
-	table = DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num);
-	eth_port_set_filter_table_entry(mp, table, crc_result);
-}
-
-/*
- * Set the entire multicast list based on dev->mc_list.
- */
-static void eth_port_set_multicast_list(struct net_device *dev)
-{
-
-	struct dev_mc_list	*mc_list;
-	int			i;
-	int			table_index;
-	struct mv643xx_private	*mp = netdev_priv(dev);
-	unsigned int		eth_port_num = mp->port_num;
-
-	/* If the device is in promiscuous mode or in all multicast mode,
-	 * we will fully populate both multicast tables with accept.
-	 * This is guaranteed to yield a match on all multicast addresses...
-	 */
-	if ((dev->flags & IFF_PROMISC) || (dev->flags & IFF_ALLMULTI)) {
-		for (table_index = 0; table_index <= 0xFC; table_index += 4) {
-			/* Set all entries in DA filter special multicast
-			 * table (Ex_dFSMT)
-			 * Set for ETH_Q0 for now
-			 * Bits
-			 * 0	  Accept=1, Drop=0
-			 * 3-1  Queue	 ETH_Q0=0
-			 * 7-4  Reserved = 0;
-			 */
-			wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
-
-			/* Set all entries in DA filter other multicast
-			 * table (Ex_dFOMT)
-			 * Set for ETH_Q0 for now
-			 * Bits
-			 * 0	  Accept=1, Drop=0
-			 * 3-1  Queue	 ETH_Q0=0
-			 * 7-4  Reserved = 0;
-			 */
-			wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
-		}
-		return;
-	}
-
-	/* We will clear out multicast tables every time we get the list.
-	 * Then add the entire new list...
-	 */
-	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
-		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
-				(eth_port_num) + table_index, 0);
-
-		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE
-				(eth_port_num) + table_index, 0);
-	}
-
-	/* Get pointer to net_device multicast list and add each one... */
-	for (i = 0, mc_list = dev->mc_list;
-			(i < 256) && (mc_list != NULL) && (i < dev->mc_count);
-			i++, mc_list = mc_list->next)
-		if (mc_list->dmi_addrlen == 6)
-			eth_port_mc_addr(mp, mc_list->dmi_addr);
-}
-
-/*
- * eth_port_init_mac_tables - Clear all entrance in the UC, SMC and OMC tables
- *
- * DESCRIPTION:
- *	Go through all the DA filter tables (Unicast, Special Multicast &
- *	Other Multicast) and set each entry to 0.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	Multicast and Unicast packets are rejected.
- *
- * RETURN:
- *	None.
- */
-static void eth_port_init_mac_tables(struct mv643xx_private *mp)
-{
-	unsigned int port_num = mp->port_num;
-	int table_index;
-
-	/* Clear DA filter unicast table (Ex_dFUT) */
-	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		wrl(mp, DA_FILTER_UNICAST_TABLE_BASE(port_num) +
-					table_index, 0);
-
-	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
-		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num) +
-					table_index, 0);
-		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num) +
-					table_index, 0);
-	}
-}
-
-/*
- * eth_clear_mib_counters - Clear all MIB counters
- *
- * DESCRIPTION:
- *	This function clears all MIB counters of a specific ethernet port.
- *	A read from the MIB counter will reset the counter.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	After reading all MIB counters, the counters resets.
- *
- * RETURN:
- *	MIB counter value.
- *
- */
-static void eth_clear_mib_counters(struct mv643xx_private *mp)
-{
-	unsigned int port_num = mp->port_num;
-	int i;
-
-	/* Perform dummy reads from MIB counters */
-	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
-									i += 4)
-		rdl(mp, MIB_COUNTERS_BASE(port_num) + i);
-}
-
-static inline u32 read_mib(struct mv643xx_private *mp, int offset)
-{
-	return rdl(mp, MIB_COUNTERS_BASE(mp->port_num) + offset);
-}
-
-static void eth_update_mib_counters(struct mv643xx_private *mp)
-{
-	struct mv643xx_mib_counters *p = &mp->mib_counters;
-	int offset;
-
-	p->good_octets_received +=
-		read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
-	p->good_octets_received +=
-		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH) << 32;
-
-	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
-			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
-			offset += 4)
-		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
-
-	p->good_octets_sent += read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_LOW);
-	p->good_octets_sent +=
-		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
-
-	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
-			offset <= ETH_MIB_LATE_COLLISION;
-			offset += 4)
-		*(u32 *)((char *)p + offset) += read_mib(mp, offset);
-}
-
-/*
- * ethernet_phy_detect - Detect whether a phy is present
- *
- * DESCRIPTION:
- *	This function tests whether there is a PHY present on
- *	the specified port.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	None
- *
- * RETURN:
- *	0 on success
- *	-ENODEV on failure
- *
- */
-static int ethernet_phy_detect(struct mv643xx_private *mp)
-{
-	unsigned int phy_reg_data0;
-	int auto_neg;
-
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
-	auto_neg = phy_reg_data0 & 0x1000;
-	phy_reg_data0 ^= 0x1000;	/* invert auto_neg */
-	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
-
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
-	if ((phy_reg_data0 & 0x1000) == auto_neg)
-		return -ENODEV;				/* change didn't take */
-
-	phy_reg_data0 ^= 0x1000;
-	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
-	return 0;
-}
-
-/*
- * ethernet_phy_get - Get the ethernet port PHY address.
- *
- * DESCRIPTION:
- *	This routine returns the given ethernet port PHY address.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	None.
- *
- * RETURN:
- *	PHY address.
- *
- */
-static int ethernet_phy_get(struct mv643xx_private *mp)
-{
-	unsigned int reg_data;
-
-	reg_data = rdl(mp, PHY_ADDR_REG);
-
-	return ((reg_data >> (5 * mp->port_num)) & 0x1f);
-}
-
-/*
- * ethernet_phy_set - Set the ethernet port PHY address.
- *
- * DESCRIPTION:
- *	This routine sets the given ethernet port PHY address.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *	int		phy_addr	PHY address.
- *
- * OUTPUT:
- *	None.
- *
- * RETURN:
- *	None.
- *
- */
-static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr)
-{
-	u32 reg_data;
-	int addr_shift = 5 * mp->port_num;
-
-	reg_data = rdl(mp, PHY_ADDR_REG);
-	reg_data &= ~(0x1f << addr_shift);
-	reg_data |= (phy_addr & 0x1f) << addr_shift;
-	wrl(mp, PHY_ADDR_REG, reg_data);
-}
-
-/*
- * ethernet_phy_reset - Reset Ethernet port PHY.
- *
- * DESCRIPTION:
- *	This routine utilizes the SMI interface to reset the ethernet port PHY.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	The PHY is reset.
- *
- * RETURN:
- *	None.
- *
- */
-static void ethernet_phy_reset(struct mv643xx_private *mp)
-{
-	unsigned int phy_reg_data;
-
-	/* Reset the PHY */
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data);
-	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
-	eth_port_write_smi_reg(mp, 0, phy_reg_data);
-
-	/* wait for PHY to come out of reset */
-	do {
-		udelay(1);
-		eth_port_read_smi_reg(mp, 0, &phy_reg_data);
-	} while (phy_reg_data & 0x8000);
-}
-
-static void mv643xx_eth_port_enable_tx(struct mv643xx_private *mp,
-					unsigned int queues)
-{
-	wrl(mp, TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), queues);
-}
-
-static void mv643xx_eth_port_enable_rx(struct mv643xx_private *mp,
-					unsigned int queues)
-{
-	wrl(mp, RECEIVE_QUEUE_COMMAND_REG(mp->port_num), queues);
-}
-
-static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
-{
-	unsigned int port_num = mp->port_num;
-	u32 queues;
-
-	/* Stop Tx port activity. Check port Tx activity. */
-	queues = rdl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF;
-	if (queues) {
-		/* Issue stop command for active queues only */
-		wrl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num), (queues << 8));
-
-		/* Wait for all Tx activity to terminate. */
-		/* Check port cause register that all Tx queues are stopped */
-		while (rdl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF)
-			udelay(PHY_WAIT_MICRO_SECONDS);
-
-		/* Wait for Tx FIFO to empty */
-		while (rdl(mp, PORT_STATUS_REG(port_num)) &
-							ETH_PORT_TX_FIFO_EMPTY)
-			udelay(PHY_WAIT_MICRO_SECONDS);
-	}
-
-	return queues;
-}
-
-static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp)
-{
-	unsigned int port_num = mp->port_num;
-	u32 queues;
-
-	/* Stop Rx port activity. Check port Rx activity. */
-	queues = rdl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF;
-	if (queues) {
-		/* Issue stop command for active queues only */
-		wrl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num), (queues << 8));
-
-		/* Wait for all Rx activity to terminate. */
-		/* Check port cause register that all Rx queues are stopped */
-		while (rdl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF)
-			udelay(PHY_WAIT_MICRO_SECONDS);
-	}
-
-	return queues;
-}
-
-/*
- * eth_port_reset - Reset Ethernet port
- *
- * DESCRIPTION:
- * 	This routine resets the chip by aborting any SDMA engine activity and
- *	clearing the MIB counters. The Receiver and the Transmit unit are in
- *	idle state after this command is performed and the port is disabled.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *
- * OUTPUT:
- *	Channel activity is halted.
- *
- * RETURN:
- *	None.
- *
- */
-static void eth_port_reset(struct mv643xx_private *mp)
-{
-	unsigned int port_num = mp->port_num;
-	unsigned int reg_data;
-
-	mv643xx_eth_port_disable_tx(mp);
-	mv643xx_eth_port_disable_rx(mp);
-
-	/* Clear all MIB counters */
-	eth_clear_mib_counters(mp);
-
-	/* Reset the Enable bit in the Configuration Register */
-	reg_data = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
-	reg_data &= ~(SERIAL_PORT_ENABLE		|
-			DO_NOT_FORCE_LINK_FAIL	|
-			FORCE_LINK_PASS);
-	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), reg_data);
-}
-
-
-/*
- * eth_port_read_smi_reg - Read PHY registers
- *
- * DESCRIPTION:
- *	This routine utilize the SMI interface to interact with the PHY in
- *	order to perform PHY register read.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *	unsigned int	phy_reg		PHY register address offset.
- *	unsigned int	*value		Register value buffer.
- *
- * OUTPUT:
- *	Write the value of a specified PHY register into given buffer.
- *
- * RETURN:
- *	false if the PHY is busy or read data is not in valid state.
- *	true otherwise.
- *
- */
-static void eth_port_read_smi_reg(struct mv643xx_private *mp,
-				unsigned int phy_reg, unsigned int *value)
-{
-	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
-	int phy_addr = ethernet_phy_get(mp);
-	unsigned long flags;
-	int i;
-
-	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
-
-	/* wait for the SMI register to become available */
-	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
-		if (i == PHY_WAIT_ITERATIONS) {
-			printk("%s: PHY busy timeout\n", mp->dev->name);
-			goto out;
-		}
-		udelay(PHY_WAIT_MICRO_SECONDS);
-	}
-
-	writel((phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ,
-		smi_reg);
-
-	/* now wait for the data to be valid */
-	for (i = 0; !(readl(smi_reg) & ETH_SMI_READ_VALID); i++) {
-		if (i == PHY_WAIT_ITERATIONS) {
-			printk("%s: PHY read timeout\n", mp->dev->name);
-			goto out;
-		}
-		udelay(PHY_WAIT_MICRO_SECONDS);
-	}
-
-	*value = readl(smi_reg) & 0xffff;
-out:
-	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
-}
-
-/*
- * eth_port_write_smi_reg - Write to PHY registers
- *
- * DESCRIPTION:
- *	This routine utilize the SMI interface to interact with the PHY in
- *	order to perform writes to PHY registers.
- *
- * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port.
- *	unsigned int	phy_reg		PHY register address offset.
- *	unsigned int	value		Register value.
- *
- * OUTPUT:
- *	Write the given value to the specified PHY register.
- *
- * RETURN:
- *	false if the PHY is busy.
- *	true otherwise.
- *
- */
-static void eth_port_write_smi_reg(struct mv643xx_private *mp,
-				   unsigned int phy_reg, unsigned int value)
-{
-	void __iomem *smi_reg = mp->shared_smi->eth_base + SMI_REG;
-	int phy_addr = ethernet_phy_get(mp);
-	unsigned long flags;
-	int i;
-
-	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mp->shared_smi->phy_lock, flags);
-
-	/* wait for the SMI register to become available */
-	for (i = 0; readl(smi_reg) & ETH_SMI_BUSY; i++) {
-		if (i == PHY_WAIT_ITERATIONS) {
-			printk("%s: PHY busy timeout\n", mp->dev->name);
-			goto out;
-		}
-		udelay(PHY_WAIT_MICRO_SECONDS);
-	}
-
-	writel((phy_addr << 16) | (phy_reg << 21) |
-		ETH_SMI_OPCODE_WRITE | (value & 0xffff), smi_reg);
-out:
-	spin_unlock_irqrestore(&mp->shared_smi->phy_lock, flags);
-}
-
-/*
- * Wrappers for MII support library.
- */
-static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-	int val;
-
-	eth_port_read_smi_reg(mp, location, &val);
-	return val;
-}
-
-static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-	eth_port_write_smi_reg(mp, location, val);
-}
-
-/*
- * eth_port_receive - Get received information from Rx ring.
- *
- * DESCRIPTION:
- * 	This routine returns the received data to the caller. There is no
- *	data copying during routine operation. All information is returned
- *	using pointer to packet information struct passed from the caller.
- *	If the routine exhausts Rx ring resources then the resource error flag
- *	is set.
- *
- * INPUT:
- *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
- *	struct pkt_info		*p_pkt_info	User packet buffer.
- *
- * OUTPUT:
- *	Rx ring current and used indexes are updated.
- *
- * RETURN:
- *	ETH_ERROR in case the routine can not access Rx desc ring.
- *	ETH_QUEUE_FULL if Rx ring resources are exhausted.
- *	ETH_END_OF_JOB if there is no received data.
- *	ETH_OK otherwise.
- */
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
-						struct pkt_info *p_pkt_info)
-{
-	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
-	volatile struct eth_rx_desc *p_rx_desc;
-	unsigned int command_status;
-	unsigned long flags;
-
-	/* Do not process Rx ring in case of Rx ring resource error */
-	if (mp->rx_resource_err)
-		return ETH_QUEUE_FULL;
-
-	spin_lock_irqsave(&mp->lock, flags);
-
-	/* Get the Rx Desc ring 'curr and 'used' indexes */
-	rx_curr_desc = mp->rx_curr_desc_q;
-	rx_used_desc = mp->rx_used_desc_q;
-
-	p_rx_desc = &mp->p_rx_desc_area[rx_curr_desc];
-
-	/* The following parameters are used to save readings from memory */
-	command_status = p_rx_desc->cmd_sts;
-	rmb();
-
-	/* Nothing to receive... */
-	if (command_status & (ETH_BUFFER_OWNED_BY_DMA)) {
-		spin_unlock_irqrestore(&mp->lock, flags);
-		return ETH_END_OF_JOB;
-	}
-
-	p_pkt_info->byte_cnt = (p_rx_desc->byte_cnt) - RX_BUF_OFFSET;
-	p_pkt_info->cmd_sts = command_status;
-	p_pkt_info->buf_ptr = (p_rx_desc->buf_ptr) + RX_BUF_OFFSET;
-	p_pkt_info->return_info = mp->rx_skb[rx_curr_desc];
-	p_pkt_info->l4i_chk = p_rx_desc->buf_size;
-
-	/*
-	 * Clean the return info field to indicate that the
-	 * packet has been moved to the upper layers
-	 */
-	mp->rx_skb[rx_curr_desc] = NULL;
-
-	/* Update current index in data structure */
-	rx_next_curr_desc = (rx_curr_desc + 1) % mp->rx_ring_size;
-	mp->rx_curr_desc_q = rx_next_curr_desc;
-
-	/* Rx descriptors exhausted. Set the Rx ring resource error flag */
-	if (rx_next_curr_desc == rx_used_desc)
-		mp->rx_resource_err = 1;
-
-	spin_unlock_irqrestore(&mp->lock, flags);
-
-	return ETH_OK;
-}
-
-/*
- * eth_rx_return_buff - Returns a Rx buffer back to the Rx ring.
- *
- * DESCRIPTION:
- *	This routine returns a Rx buffer back to the Rx ring. It retrieves the
- *	next 'used' descriptor and attached the returned buffer to it.
- *	In case the Rx ring was in "resource error" condition, where there are
- *	no available Rx resources, the function resets the resource error flag.
- *
- * INPUT:
- *	struct mv643xx_private	*mp		Ethernet Port Control srtuct.
- *	struct pkt_info		*p_pkt_info	Information on returned buffer.
- *
- * OUTPUT:
- *	New available Rx resource in Rx descriptor ring.
- *
- * RETURN:
- *	ETH_ERROR in case the routine can not access Rx desc ring.
- *	ETH_OK otherwise.
- */
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
-						struct pkt_info *p_pkt_info)
-{
-	int used_rx_desc;	/* Where to return Rx resource */
-	volatile struct eth_rx_desc *p_used_rx_desc;
-	unsigned long flags;
-
-	spin_lock_irqsave(&mp->lock, flags);
-
-	/* Get 'used' Rx descriptor */
-	used_rx_desc = mp->rx_used_desc_q;
-	p_used_rx_desc = &mp->p_rx_desc_area[used_rx_desc];
-
-	p_used_rx_desc->buf_ptr = p_pkt_info->buf_ptr;
-	p_used_rx_desc->buf_size = p_pkt_info->byte_cnt;
-	mp->rx_skb[used_rx_desc] = p_pkt_info->return_info;
-
-	/* Flush the write pipe */
-
-	/* Return the descriptor to DMA ownership */
-	wmb();
-	p_used_rx_desc->cmd_sts =
-			ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
-	wmb();
-
-	/* Move the used descriptor pointer to the next descriptor */
-	mp->rx_used_desc_q = (used_rx_desc + 1) % mp->rx_ring_size;
-
-	/* Any Rx return cancels the Rx resource error status */
-	mp->rx_resource_err = 0;
-
-	spin_unlock_irqrestore(&mp->lock, flags);
-
-	return ETH_OK;
-}
-
-/************* Begin ethtool support *************************/
-
-struct mv643xx_stats {
-	char stat_string[ETH_GSTRING_LEN];
-	int sizeof_stat;
-	int stat_offset;
-};
-
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
-};
-
-#define MV643XX_STATS_LEN	ARRAY_SIZE(mv643xx_gstrings_stats)
-
-static void mv643xx_get_drvinfo(struct net_device *netdev,
-				struct ethtool_drvinfo *drvinfo)
-{
-	strncpy(drvinfo->driver,  mv643xx_driver_name, 32);
-	strncpy(drvinfo->version, mv643xx_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, "mv643xx", 32);
-	drvinfo->n_stats = MV643XX_STATS_LEN;
-}
-
-static int mv643xx_get_sset_count(struct net_device *netdev, int sset)
-{
-	switch (sset) {
-	case ETH_SS_STATS:
-		return MV643XX_STATS_LEN;
-	default:
-		return -EOPNOTSUPP;
-	}
-}
-
-static void mv643xx_get_ethtool_stats(struct net_device *netdev,
-				struct ethtool_stats *stats, uint64_t *data)
-{
-	struct mv643xx_private *mp = netdev->priv;
-	int i;
-
-	eth_update_mib_counters(mp);
-
-	for (i = 0; i < MV643XX_STATS_LEN; i++) {
-		char *p = (char *)mp+mv643xx_gstrings_stats[i].stat_offset;
-		data[i] = (mv643xx_gstrings_stats[i].sizeof_stat ==
-			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
-	}
-}
-
-static void mv643xx_get_strings(struct net_device *netdev, uint32_t stringset,
-				uint8_t *data)
-{
-	int i;
-
-	switch(stringset) {
-	case ETH_SS_STATS:
-		for (i=0; i < MV643XX_STATS_LEN; i++) {
-			memcpy(data + i * ETH_GSTRING_LEN,
-					mv643xx_gstrings_stats[i].stat_string,
-					ETH_GSTRING_LEN);
-		}
-		break;
-	}
-}
-
-static u32 mv643xx_eth_get_link(struct net_device *dev)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-
-	return mii_link_ok(&mp->mii);
-}
-
-static int mv643xx_eth_nway_restart(struct net_device *dev)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-
-	return mii_nway_restart(&mp->mii);
-}
-
-static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-
-	return generic_mii_ioctl(&mp->mii, if_mii(ifr), cmd, NULL);
-}
-
-static const struct ethtool_ops mv643xx_ethtool_ops = {
-	.get_settings           = mv643xx_get_settings,
-	.set_settings           = mv643xx_set_settings,
-	.get_drvinfo            = mv643xx_get_drvinfo,
-	.get_link               = mv643xx_eth_get_link,
-	.set_sg			= ethtool_op_set_sg,
-	.get_sset_count		= mv643xx_get_sset_count,
-	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
-	.get_strings            = mv643xx_get_strings,
-	.nway_reset		= mv643xx_eth_nway_restart,
-};
-
-/************* End ethtool support *************************/
-- 
1.5.3.4

