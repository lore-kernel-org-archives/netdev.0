From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 20/39] mv643xx_eth: get rid of hungarian variable naming
Date: Tue,  3 Jun 2008 13:02:35 +0200
Message-ID: <1212490974-23719-21-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48762 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756072AbYFCMAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:40 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nuke some Hungarian-esque variable naming conventions:
- p_ prefix for pointers
- _q suffix for variables dealing with rx/tx queue state

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  156 ++++++++++++++++++++++----------------------
 1 files changed, 78 insertions(+), 78 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index cce9686..15a17e2 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -314,21 +314,21 @@ struct mv643xx_eth_private {
 	/* Tx/Rx rings managment indexes fields. For driver use */
 
 	/* Next available and first returning Rx resource */
-	int rx_curr_desc_q, rx_used_desc_q;
+	int rx_curr_desc, rx_used_desc;
 
 	/* Next available and first returning Tx resource */
-	int tx_curr_desc_q, tx_used_desc_q;
+	int tx_curr_desc, tx_used_desc;
 
 #ifdef MV643XX_ETH_TX_FAST_REFILL
 	u32 tx_clean_threshold;
 #endif
 
-	struct rx_desc *p_rx_desc_area;
+	struct rx_desc *rx_desc_area;
 	dma_addr_t rx_desc_dma;
 	int rx_desc_area_size;
 	struct sk_buff **rx_skb;
 
-	struct tx_desc *p_tx_desc_area;
+	struct tx_desc *tx_desc_area;
 	dma_addr_t tx_desc_dma;
 	int tx_desc_area_size;
 	struct sk_buff **tx_skb;
@@ -435,31 +435,31 @@ static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_eth_private *mep)
 static void mv643xx_eth_free_completed_tx_descs(struct net_device *dev);
 
 static FUNC_RET_STATUS rx_return_buff(struct mv643xx_eth_private *mep,
-						struct pkt_info *p_pkt_info)
+						struct pkt_info *pkt_info)
 {
 	int used_rx_desc;	/* Where to return Rx resource */
-	volatile struct rx_desc *p_used_rx_desc;
+	volatile struct rx_desc *rx_desc;
 	unsigned long flags;
 
 	spin_lock_irqsave(&mep->lock, flags);
 
 	/* Get 'used' Rx descriptor */
-	used_rx_desc = mep->rx_used_desc_q;
-	p_used_rx_desc = &mep->p_rx_desc_area[used_rx_desc];
+	used_rx_desc = mep->rx_used_desc;
+	rx_desc = &mep->rx_desc_area[used_rx_desc];
 
-	p_used_rx_desc->buf_ptr = p_pkt_info->buf_ptr;
-	p_used_rx_desc->buf_size = p_pkt_info->byte_cnt;
-	mep->rx_skb[used_rx_desc] = p_pkt_info->return_info;
+	rx_desc->buf_ptr = pkt_info->buf_ptr;
+	rx_desc->buf_size = pkt_info->byte_cnt;
+	mep->rx_skb[used_rx_desc] = pkt_info->return_info;
 
 	/* Flush the write pipe */
 
 	/* Return the descriptor to DMA ownership */
 	wmb();
-	p_used_rx_desc->cmd_sts = BUFFER_OWNED_BY_DMA | RX_ENABLE_INTERRUPT;
+	rx_desc->cmd_sts = BUFFER_OWNED_BY_DMA | RX_ENABLE_INTERRUPT;
 	wmb();
 
 	/* Move the used descriptor pointer to the next descriptor */
-	mep->rx_used_desc_q = (used_rx_desc + 1) % mep->rx_ring_size;
+	mep->rx_used_desc = (used_rx_desc + 1) % mep->rx_ring_size;
 
 	spin_unlock_irqrestore(&mep->lock, flags);
 
@@ -510,23 +510,23 @@ static inline void mv643xx_eth_rx_refill_descs_timer_wrapper(unsigned long data)
 }
 
 static FUNC_RET_STATUS port_receive(struct mv643xx_eth_private *mep,
-						struct pkt_info *p_pkt_info)
+						struct pkt_info *pkt_info)
 {
 	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
-	volatile struct rx_desc *p_rx_desc;
+	volatile struct rx_desc *rx_desc;
 	unsigned int command_status;
 	unsigned long flags;
 
 	spin_lock_irqsave(&mep->lock, flags);
 
 	/* Get the Rx Desc ring 'curr and 'used' indexes */
-	rx_curr_desc = mep->rx_curr_desc_q;
-	rx_used_desc = mep->rx_used_desc_q;
+	rx_curr_desc = mep->rx_curr_desc;
+	rx_used_desc = mep->rx_used_desc;
 
-	p_rx_desc = &mep->p_rx_desc_area[rx_curr_desc];
+	rx_desc = &mep->rx_desc_area[rx_curr_desc];
 
 	/* The following parameters are used to save readings from memory */
-	command_status = p_rx_desc->cmd_sts;
+	command_status = rx_desc->cmd_sts;
 	rmb();
 
 	/* Nothing to receive... */
@@ -535,11 +535,11 @@ static FUNC_RET_STATUS port_receive(struct mv643xx_eth_private *mep,
 		return ETH_END_OF_JOB;
 	}
 
-	p_pkt_info->byte_cnt = p_rx_desc->byte_cnt - ETH_HW_IP_ALIGN;
-	p_pkt_info->cmd_sts = command_status;
-	p_pkt_info->buf_ptr = p_rx_desc->buf_ptr + ETH_HW_IP_ALIGN;
-	p_pkt_info->return_info = mep->rx_skb[rx_curr_desc];
-	p_pkt_info->l4i_chk = p_rx_desc->buf_size;
+	pkt_info->byte_cnt = rx_desc->byte_cnt - ETH_HW_IP_ALIGN;
+	pkt_info->cmd_sts = command_status;
+	pkt_info->buf_ptr = rx_desc->buf_ptr + ETH_HW_IP_ALIGN;
+	pkt_info->return_info = mep->rx_skb[rx_curr_desc];
+	pkt_info->l4i_chk = rx_desc->buf_size;
 
 	/*
 	 * Clean the return info field to indicate that the
@@ -549,7 +549,7 @@ static FUNC_RET_STATUS port_receive(struct mv643xx_eth_private *mep,
 
 	/* Update current index in data structure */
 	rx_next_curr_desc = (rx_curr_desc + 1) % mep->rx_ring_size;
-	mep->rx_curr_desc_q = rx_next_curr_desc;
+	mep->rx_curr_desc = rx_next_curr_desc;
 
 	spin_unlock_irqrestore(&mep->lock, flags);
 
@@ -641,7 +641,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 
 	work_done = 0;
 	if ((rdl(mep, RXQ_CURRENT_DESC_PTR(port_num)))
-	    != (u32) mep->rx_used_desc_q)
+	    != (u32) mep->rx_used_desc)
 		work_done = mv643xx_eth_receive_queue(dev, budget);
 
 	if (work_done < budget) {
@@ -676,10 +676,10 @@ static int alloc_tx_desc_index(struct mv643xx_eth_private *mep)
 
 	BUG_ON(mep->tx_desc_count >= mep->tx_ring_size);
 
-	tx_desc_curr = mep->tx_curr_desc_q;
-	mep->tx_curr_desc_q = (tx_desc_curr + 1) % mep->tx_ring_size;
+	tx_desc_curr = mep->tx_curr_desc;
+	mep->tx_curr_desc = (tx_desc_curr + 1) % mep->tx_ring_size;
 
-	BUG_ON(mep->tx_curr_desc_q == mep->tx_used_desc_q);
+	BUG_ON(mep->tx_curr_desc == mep->tx_used_desc);
 
 	return tx_desc_curr;
 }
@@ -695,7 +695,7 @@ static void tx_fill_frag_descs(struct mv643xx_eth_private *mep,
 		skb_frag_t *this_frag = &skb_shinfo(skb)->frags[frag];
 
 		tx_index = alloc_tx_desc_index(mep);
-		desc = &mep->p_tx_desc_area[tx_index];
+		desc = &mep->tx_desc_area[tx_index];
 
 		desc->cmd_sts = BUFFER_OWNED_BY_DMA;
 		/* Last Frag enables interrupt and frees the skb */
@@ -707,7 +707,7 @@ static void tx_fill_frag_descs(struct mv643xx_eth_private *mep,
 		} else
 			mep->tx_skb[tx_index] = NULL;
 
-		desc = &mep->p_tx_desc_area[tx_index];
+		desc = &mep->tx_desc_area[tx_index];
 		desc->l4i_chk = 0;
 		desc->byte_cnt = this_frag->size;
 		desc->buf_ptr = dma_map_page(NULL, this_frag->page,
@@ -734,7 +734,7 @@ static void tx_submit_descs_for_skb(struct mv643xx_eth_private *mep,
 	cmd_sts = TX_FIRST_DESC | GEN_CRC | BUFFER_OWNED_BY_DMA;
 
 	tx_index = alloc_tx_desc_index(mep);
-	desc = &mep->p_tx_desc_area[tx_index];
+	desc = &mep->tx_desc_area[tx_index];
 
 	if (nr_frags) {
 		tx_fill_frag_descs(mep, skb);
@@ -1104,7 +1104,7 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 
 
 /* address handling *********************************************************/
-static void uc_addr_get(struct mv643xx_eth_private *mep, unsigned char *p_addr)
+static void uc_addr_get(struct mv643xx_eth_private *mep, unsigned char *addr)
 {
 	unsigned int port_num = mep->port_num;
 	unsigned int mac_h;
@@ -1113,12 +1113,12 @@ static void uc_addr_get(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 	mac_h = rdl(mep, MAC_ADDR_HIGH(port_num));
 	mac_l = rdl(mep, MAC_ADDR_LOW(port_num));
 
-	p_addr[0] = (mac_h >> 24) & 0xff;
-	p_addr[1] = (mac_h >> 16) & 0xff;
-	p_addr[2] = (mac_h >> 8) & 0xff;
-	p_addr[3] = mac_h & 0xff;
-	p_addr[4] = (mac_l >> 8) & 0xff;
-	p_addr[5] = mac_l & 0xff;
+	addr[0] = (mac_h >> 24) & 0xff;
+	addr[1] = (mac_h >> 16) & 0xff;
+	addr[2] = (mac_h >> 8) & 0xff;
+	addr[3] = mac_h & 0xff;
+	addr[4] = (mac_l >> 8) & 0xff;
+	addr[5] = mac_l & 0xff;
 }
 
 static void init_mac_tables(struct mv643xx_eth_private *mep)
@@ -1154,23 +1154,23 @@ static void set_filter_table_entry(struct mv643xx_eth_private *mep,
 	wrl(mep, table + tbl_offset, table_reg);
 }
 
-static void uc_addr_set(struct mv643xx_eth_private *mep, unsigned char *p_addr)
+static void uc_addr_set(struct mv643xx_eth_private *mep, unsigned char *addr)
 {
 	unsigned int port_num = mep->port_num;
 	unsigned int mac_h;
 	unsigned int mac_l;
 	int table;
 
-	mac_l = (p_addr[4] << 8) | (p_addr[5]);
-	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
-							(p_addr[3] << 0);
+	mac_l = (addr[4] << 8) | (addr[5]);
+	mac_h = (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) |
+							(addr[3] << 0);
 
 	wrl(mep, MAC_ADDR_LOW(port_num), mac_l);
 	wrl(mep, MAC_ADDR_HIGH(port_num), mac_h);
 
 	/* Accept frames with this address */
 	table = UNICAST_TABLE(port_num);
-	set_filter_table_entry(mep, table, p_addr[5] & 0x0f);
+	set_filter_table_entry(mep, table, addr[5] & 0x0f);
 }
 
 static void mv643xx_eth_update_mac_address(struct net_device *dev)
@@ -1192,7 +1192,7 @@ static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
 	return 0;
 }
 
-static void mc_addr(struct mv643xx_eth_private *mep, unsigned char *p_addr)
+static void mc_addr(struct mv643xx_eth_private *mep, unsigned char *addr)
 {
 	unsigned int port_num = mep->port_num;
 	unsigned int mac_h;
@@ -1203,17 +1203,17 @@ static void mc_addr(struct mv643xx_eth_private *mep, unsigned char *p_addr)
 	int crc[8];
 	int i;
 
-	if ((p_addr[0] == 0x01) && (p_addr[1] == 0x00) &&
-	    (p_addr[2] == 0x5E) && (p_addr[3] == 0x00) && (p_addr[4] == 0x00)) {
+	if ((addr[0] == 0x01) && (addr[1] == 0x00) &&
+	    (addr[2] == 0x5E) && (addr[3] == 0x00) && (addr[4] == 0x00)) {
 		table = SPECIAL_MCAST_TABLE(port_num);
-		set_filter_table_entry(mep, table, p_addr[5]);
+		set_filter_table_entry(mep, table, addr[5]);
 		return;
 	}
 
 	/* Calculate CRC-8 out of the given address */
-	mac_h = (p_addr[0] << 8) | (p_addr[1]);
-	mac_l = (p_addr[2] << 24) | (p_addr[3] << 16) |
-			(p_addr[4] << 8) | (p_addr[5] << 0);
+	mac_h = (addr[0] << 8) | (addr[1]);
+	mac_l = (addr[2] << 24) | (addr[3] << 16) |
+			(addr[4] << 8) | (addr[5] << 0);
 
 	for (i = 0; i < 32; i++)
 		mac_array[i] = (mac_l >> i) & 0x1;
@@ -1363,15 +1363,15 @@ static void ether_init_rx_desc_ring(struct mv643xx_eth_private *mep)
 	int i;
 
 	/* initialize the next_desc_ptr links in the Rx descriptors ring */
-	p_rx_desc = (struct rx_desc *)mep->p_rx_desc_area;
+	p_rx_desc = (struct rx_desc *)mep->rx_desc_area;
 	for (i = 0; i < rx_desc_num; i++) {
 		p_rx_desc[i].next_desc_ptr = mep->rx_desc_dma +
 			((i + 1) % rx_desc_num) * sizeof(struct rx_desc);
 	}
 
 	/* Save Rx desc pointer to driver struct. */
-	mep->rx_curr_desc_q = 0;
-	mep->rx_used_desc_q = 0;
+	mep->rx_curr_desc = 0;
+	mep->rx_used_desc = 0;
 
 	mep->rx_desc_area_size = rx_desc_num * sizeof(struct rx_desc);
 }
@@ -1399,10 +1399,10 @@ static void mv643xx_eth_free_rx_rings(struct net_device *dev)
 			mep->rx_desc_count);
 	/* Free RX ring */
 	if (mep->rx_sram_size)
-		iounmap(mep->p_rx_desc_area);
+		iounmap(mep->rx_desc_area);
 	else
 		dma_free_coherent(NULL, mep->rx_desc_area_size,
-				mep->p_rx_desc_area, mep->rx_desc_dma);
+				mep->rx_desc_area, mep->rx_desc_dma);
 }
 
 static void ether_init_tx_desc_ring(struct mv643xx_eth_private *mep)
@@ -1412,14 +1412,14 @@ static void ether_init_tx_desc_ring(struct mv643xx_eth_private *mep)
 	int i;
 
 	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
-	p_tx_desc = (struct tx_desc *)mep->p_tx_desc_area;
+	p_tx_desc = (struct tx_desc *)mep->tx_desc_area;
 	for (i = 0; i < tx_desc_num; i++) {
 		p_tx_desc[i].next_desc_ptr = mep->tx_desc_dma +
 			((i + 1) % tx_desc_num) * sizeof(struct tx_desc);
 	}
 
-	mep->tx_curr_desc_q = 0;
-	mep->tx_used_desc_q = 0;
+	mep->tx_curr_desc = 0;
+	mep->tx_used_desc = 0;
 
 	mep->tx_desc_area_size = tx_desc_num * sizeof(struct tx_desc);
 }
@@ -1445,8 +1445,8 @@ static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 			return released;
 		}
 
-		tx_index = mep->tx_used_desc_q;
-		desc = &mep->p_tx_desc_area[tx_index];
+		tx_index = mep->tx_used_desc;
+		desc = &mep->tx_desc_area[tx_index];
 		cmd_sts = desc->cmd_sts;
 
 		if (!force && (cmd_sts & BUFFER_OWNED_BY_DMA)) {
@@ -1454,7 +1454,7 @@ static int mv643xx_eth_free_tx_descs(struct net_device *dev, int force)
 			return released;
 		}
 
-		mep->tx_used_desc_q = (tx_index + 1) % mep->tx_ring_size;
+		mep->tx_used_desc = (tx_index + 1) % mep->tx_ring_size;
 		mep->tx_desc_count--;
 
 		addr = desc->buf_ptr;
@@ -1508,14 +1508,14 @@ static void mv643xx_eth_free_tx_rings(struct net_device *dev)
 	/* Free outstanding skb's on TX ring */
 	mv643xx_eth_free_all_tx_descs(dev);
 
-	BUG_ON(mep->tx_used_desc_q != mep->tx_curr_desc_q);
+	BUG_ON(mep->tx_used_desc != mep->tx_curr_desc);
 
 	/* Free TX ring */
 	if (mep->tx_sram_size)
-		iounmap(mep->p_tx_desc_area);
+		iounmap(mep->tx_desc_area);
 	else
 		dma_free_coherent(NULL, mep->tx_desc_area_size,
-				mep->p_tx_desc_area, mep->tx_desc_dma);
+				mep->tx_desc_area, mep->tx_desc_dma);
 }
 
 
@@ -1654,12 +1654,12 @@ static void port_start(struct net_device *dev)
 	struct ethtool_cmd ethtool_cmd;
 
 	/* Assignment of Tx CTRP of given queue */
-	tx_curr_desc = mep->tx_curr_desc_q;
+	tx_curr_desc = mep->tx_curr_desc;
 	wrl(mep, TXQ_CURRENT_DESC_PTR(port_num),
 		(u32)((struct tx_desc *)mep->tx_desc_dma + tx_curr_desc));
 
 	/* Assignment of Rx CRDP of given queue */
-	rx_curr_desc = mep->rx_curr_desc_q;
+	rx_curr_desc = mep->rx_curr_desc;
 	wrl(mep, RXQ_CURRENT_DESC_PTR(port_num),
 		(u32)((struct rx_desc *)mep->rx_desc_dma + rx_curr_desc));
 
@@ -1791,22 +1791,22 @@ static int mv643xx_eth_open(struct net_device *dev)
 	mep->tx_desc_area_size = size;
 
 	if (mep->tx_sram_size) {
-		mep->p_tx_desc_area = ioremap(mep->tx_sram_addr,
+		mep->tx_desc_area = ioremap(mep->tx_sram_addr,
 							mep->tx_sram_size);
 		mep->tx_desc_dma = mep->tx_sram_addr;
 	} else
-		mep->p_tx_desc_area = dma_alloc_coherent(NULL, size,
+		mep->tx_desc_area = dma_alloc_coherent(NULL, size,
 							&mep->tx_desc_dma,
 							GFP_KERNEL);
 
-	if (!mep->p_tx_desc_area) {
+	if (!mep->tx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
 							dev->name, size);
 		err = -ENOMEM;
 		goto out_free_tx_skb;
 	}
-	BUG_ON((u32) mep->p_tx_desc_area & 0xf);	/* check 16-byte alignment */
-	memset((void *)mep->p_tx_desc_area, 0, mep->tx_desc_area_size);
+	BUG_ON((u32) mep->tx_desc_area & 0xf);	/* check 16-byte alignment */
+	memset((void *)mep->tx_desc_area, 0, mep->tx_desc_area_size);
 
 	ether_init_tx_desc_ring(mep);
 
@@ -1816,28 +1816,28 @@ static int mv643xx_eth_open(struct net_device *dev)
 	mep->rx_desc_area_size = size;
 
 	if (mep->rx_sram_size) {
-		mep->p_rx_desc_area = ioremap(mep->rx_sram_addr,
+		mep->rx_desc_area = ioremap(mep->rx_sram_addr,
 							mep->rx_sram_size);
 		mep->rx_desc_dma = mep->rx_sram_addr;
 	} else
-		mep->p_rx_desc_area = dma_alloc_coherent(NULL, size,
+		mep->rx_desc_area = dma_alloc_coherent(NULL, size,
 							&mep->rx_desc_dma,
 							GFP_KERNEL);
 
-	if (!mep->p_rx_desc_area) {
+	if (!mep->rx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Rx ring (size %d bytes)\n",
 							dev->name, size);
 		printk(KERN_ERR "%s: Freeing previously allocated TX queues...",
 							dev->name);
 		if (mep->rx_sram_size)
-			iounmap(mep->p_tx_desc_area);
+			iounmap(mep->tx_desc_area);
 		else
 			dma_free_coherent(NULL, mep->tx_desc_area_size,
-					mep->p_tx_desc_area, mep->tx_desc_dma);
+					mep->tx_desc_area, mep->tx_desc_dma);
 		err = -ENOMEM;
 		goto out_free_tx_skb;
 	}
-	memset((void *)mep->p_rx_desc_area, 0, size);
+	memset((void *)mep->rx_desc_area, 0, size);
 
 	ether_init_rx_desc_ring(mep);
 
-- 
1.5.3.4

