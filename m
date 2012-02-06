From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
Subject: [PATCH v6 5/5] netdev: ethernet dev_alloc_skb to netdev_alloc_skb
Date: Tue,  7 Feb 2012 02:46:48 +0530
Message-ID: <ce53bc956b35497724bbbb76ab07bfc4c5b78291.1328562210.git.netdev@pradeepdalvi.com>
References: <6fbe769a05ae20f89f6112bd2a7ccbb085ed874d.1328445742.git.netdev@pradeepdalvi.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Pradeep A Dalvi <netdev@pradeepdalvi.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6fbe769a05ae20f89f6112bd2a7ccbb085ed874d.1328445742.git.netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
  - Removed extra skb->dev = dev after netdev_alloc_skb

Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>
---
 drivers/net/ethernet/3com/3c515.c        |   10 ++++------
 drivers/net/ethernet/adi/bfin_mac.c      |    8 ++++----
 drivers/net/ethernet/apple/bmac.c        |   11 ++++++-----
 drivers/net/ethernet/dec/tulip/dmfe.c    |   20 +++++++++++---------
 drivers/net/ethernet/dec/tulip/uli526x.c |   21 ++++++++++++---------
 drivers/net/ethernet/s6gmac.c            |    9 +++++----
 6 files changed, 42 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index f67a5d3..59e1e00 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -826,11 +826,10 @@ static int corkscrew_open(struct net_device *dev)
 				vp->rx_ring[i].next = 0;
 			vp->rx_ring[i].status = 0;	/* Clear complete bit. */
 			vp->rx_ring[i].length = PKT_BUF_SZ | 0x80000000;
-			skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 			vp->rx_skbuff[i] = skb;
 			if (skb == NULL)
 				break;	/* Bad news!  */
-			skb->dev = dev;	/* Mark as being used by this device. */
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 			vp->rx_ring[i].addr = isa_virt_to_bus(skb->data);
 		}
@@ -1295,7 +1294,7 @@ static int corkscrew_rx(struct net_device *dev)
 			short pkt_len = rx_status & 0x1fff;
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len + 5 + 2);
+			skb = netdev_alloc_skb(dev, pkt_len + 5 + 2);
 			if (corkscrew_debug > 4)
 				pr_debug("Receiving packet size %d status %4.4x.\n",
 				     pkt_len, rx_status);
@@ -1368,7 +1367,7 @@ static int boomerang_rx(struct net_device *dev)
 			/* Check if the packet is long enough to just accept without
 			   copying to a properly sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 4)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 4)) != NULL) {
 				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 				/* 'skb_put()' points to the start of sk_buff data area. */
 				memcpy(skb_put(skb, pkt_len),
@@ -1403,10 +1402,9 @@ static int boomerang_rx(struct net_device *dev)
 		struct sk_buff *skb;
 		entry = vp->dirty_rx % RX_RING_SIZE;
 		if (vp->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 			if (skb == NULL)
 				break;	/* Bad news!  */
-			skb->dev = dev;	/* Mark as being used by this device. */
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 			vp->rx_ring[entry].addr = isa_virt_to_bus(skb->data);
 			vp->rx_skbuff[entry] = skb;
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 525a976..4973369 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -113,7 +113,7 @@ static void desc_list_free(void)
 	}
 }
 
-static int desc_list_init(void)
+static int desc_list_init(struct net_device *dev)
 {
 	int i;
 	struct sk_buff *new_skb;
@@ -187,7 +187,7 @@ static int desc_list_init(void)
 		struct dma_descriptor *b = &(r->desc_b);
 
 		/* allocate a new skb for next time receive */
-		new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
+		new_skb = netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN);
 		if (!new_skb) {
 			pr_notice("init: low on mem - packet dropped\n");
 			goto init_error;
@@ -1090,7 +1090,7 @@ static void bfin_mac_rx(struct net_device *dev)
 	/* allocate a new skb for next time receive */
 	skb = current_rx_ptr->skb;
 
-	new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
+	new_skb = netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN);
 	if (!new_skb) {
 		netdev_notice(dev, "rx: low on mem - packet dropped\n");
 		dev->stats.rx_dropped++;
@@ -1397,7 +1397,7 @@ static int bfin_mac_open(struct net_device *dev)
 	}
 
 	/* initial rx and tx list */
-	ret = desc_list_init();
+	ret = desc_list_init(dev);
 	if (ret)
 		return ret;
 
diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index ebc0dba..855bdaf 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -607,8 +607,9 @@ bmac_init_tx_ring(struct bmac_data *bp)
 }
 
 static int
-bmac_init_rx_ring(struct bmac_data *bp)
+bmac_init_rx_ring(struct net_device *dev)
 {
+	struct bmac_data *bp = netdev_priv(dev);
 	volatile struct dbdma_regs __iomem *rd = bp->rx_dma;
 	int i;
 	struct sk_buff *skb;
@@ -618,7 +619,7 @@ bmac_init_rx_ring(struct bmac_data *bp)
 	       (N_RX_RING + 1) * sizeof(struct dbdma_cmd));
 	for (i = 0; i < N_RX_RING; i++) {
 		if ((skb = bp->rx_bufs[i]) == NULL) {
-			bp->rx_bufs[i] = skb = dev_alloc_skb(RX_BUFLEN+2);
+			bp->rx_bufs[i] = skb = netdev_alloc_skb(dev, RX_BUFLEN + 2);
 			if (skb != NULL)
 				skb_reserve(skb, 2);
 		}
@@ -722,7 +723,7 @@ static irqreturn_t bmac_rxdma_intr(int irq, void *dev_id)
 			++dev->stats.rx_dropped;
 		}
 		if ((skb = bp->rx_bufs[i]) == NULL) {
-			bp->rx_bufs[i] = skb = dev_alloc_skb(RX_BUFLEN+2);
+			bp->rx_bufs[i] = skb = netdev_alloc_skb(dev, RX_BUFLEN + 2);
 			if (skb != NULL)
 				skb_reserve(bp->rx_bufs[i], 2);
 		}
@@ -1208,7 +1209,7 @@ static void bmac_reset_and_enable(struct net_device *dev)
 	spin_lock_irqsave(&bp->lock, flags);
 	bmac_enable_and_reset_chip(dev);
 	bmac_init_tx_ring(bp);
-	bmac_init_rx_ring(bp);
+	bmac_init_rx_ring(dev);
 	bmac_init_chip(dev);
 	bmac_start_chip(dev);
 	bmwrite(dev, INTDISABLE, EnableNormal);
@@ -1218,7 +1219,7 @@ static void bmac_reset_and_enable(struct net_device *dev)
 	 * It seems that the bmac can't receive until it's transmitted
 	 * a packet.  So we give it a dummy packet to transmit.
 	 */
-	skb = dev_alloc_skb(ETHERMINPACKET);
+	skb = netdev_alloc_skb(dev, ETHERMINPACKET);
 	if (skb != NULL) {
 		data = skb_put(skb, ETHERMINPACKET);
 		memset(data, 0, ETHERMINPACKET);
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 51f7542..1eccf49 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -325,8 +325,8 @@ static irqreturn_t dmfe_interrupt(int , void *);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_dmfe (struct net_device *dev);
 #endif
-static void dmfe_descriptor_init(struct dmfe_board_info *, unsigned long);
-static void allocate_rx_buffer(struct dmfe_board_info *);
+static void dmfe_descriptor_init(struct net_device *, unsigned long);
+static void allocate_rx_buffer(struct net_device *);
 static void update_cr6(u32, unsigned long);
 static void send_filter_frame(struct DEVICE *);
 static void dm9132_id_table(struct DEVICE *);
@@ -649,7 +649,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 		db->op_mode = db->media_mode; 	/* Force Mode */
 
 	/* Initialize Transmit/Receive decriptor and CR3/4 */
-	dmfe_descriptor_init(db, ioaddr);
+	dmfe_descriptor_init(dev, ioaddr);
 
 	/* Init CR6 to program DM910x operation */
 	update_cr6(db->cr6_data, ioaddr);
@@ -828,7 +828,7 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 
 	/* reallocate rx descriptor buffer */
 	if (db->rx_avail_cnt<RX_DESC_CNT)
-		allocate_rx_buffer(db);
+		allocate_rx_buffer(dev);
 
 	/* Free the transmitted descriptor */
 	if ( db->cr5_data & 0x01)
@@ -1008,7 +1008,7 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 					/* Good packet, send to upper layer */
 					/* Shorst packet used new SKB */
 					if ((rxlen < RX_COPY_SIZE) &&
-						((newskb = dev_alloc_skb(rxlen + 2))
+						((newskb = netdev_alloc_skb(dev, rxlen + 2))
 						!= NULL)) {
 
 						skb = newskb;
@@ -1364,8 +1364,9 @@ static void dmfe_reuse_skb(struct dmfe_board_info *db, struct sk_buff * skb)
  *	Using Chain structure, and allocate Tx/Rx buffer
  */
 
-static void dmfe_descriptor_init(struct dmfe_board_info *db, unsigned long ioaddr)
+static void dmfe_descriptor_init(struct net_device *dev, unsigned long ioaddr)
 {
+	struct dmfe_board_info *db = netdev_priv(dev);
 	struct tx_desc *tmp_tx;
 	struct rx_desc *tmp_rx;
 	unsigned char *tmp_buf;
@@ -1421,7 +1422,7 @@ static void dmfe_descriptor_init(struct dmfe_board_info *db, unsigned long ioadd
 	tmp_rx->next_rx_desc = db->first_rx_desc;
 
 	/* pre-allocate Rx buffer */
-	allocate_rx_buffer(db);
+	allocate_rx_buffer(dev);
 }
 
 
@@ -1551,15 +1552,16 @@ static void send_filter_frame(struct DEVICE *dev)
  *	As possible as allocate maxiumn Rx buffer
  */
 
-static void allocate_rx_buffer(struct dmfe_board_info *db)
+static void allocate_rx_buffer(struct net_device *dev)
 {
+	struct dmfe_board_info *db = netdev_priv(dev);
 	struct rx_desc *rxptr;
 	struct sk_buff *skb;
 
 	rxptr = db->rx_insert_ptr;
 
 	while(db->rx_avail_cnt < RX_DESC_CNT) {
-		if ( ( skb = dev_alloc_skb(RX_ALLOC_SIZE) ) == NULL )
+		if ( ( skb = netdev_alloc_skb(dev, RX_ALLOC_SIZE) ) == NULL )
 			break;
 		rxptr->rx_skb_ptr = skb; /* FIXME (?) */
 		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev, skb->data,
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 48b0b65..fc4001f 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -232,8 +232,8 @@ static irqreturn_t uli526x_interrupt(int, void *);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void uli526x_poll(struct net_device *dev);
 #endif
-static void uli526x_descriptor_init(struct uli526x_board_info *, unsigned long);
-static void allocate_rx_buffer(struct uli526x_board_info *);
+static void uli526x_descriptor_init(struct net_device *, unsigned long);
+static void allocate_rx_buffer(struct net_device *);
 static void update_cr6(u32, unsigned long);
 static void send_filter_frame(struct net_device *, int);
 static u16 phy_read(unsigned long, u8, u8, u32);
@@ -549,7 +549,7 @@ static void uli526x_init(struct net_device *dev)
 		db->op_mode = db->media_mode; 	/* Force Mode */
 
 	/* Initialize Transmit/Receive decriptor and CR3/4 */
-	uli526x_descriptor_init(db, ioaddr);
+	uli526x_descriptor_init(dev, ioaddr);
 
 	/* Init CR6 to program M526X operation */
 	update_cr6(db->cr6_data, ioaddr);
@@ -711,7 +711,7 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 
 	/* reallocate rx descriptor buffer */
 	if (db->rx_avail_cnt<RX_DESC_CNT)
-		allocate_rx_buffer(db);
+		allocate_rx_buffer(dev);
 
 	/* Free the transmitted descriptor */
 	if ( db->cr5_data & 0x01)
@@ -844,7 +844,7 @@ static void uli526x_rx_packet(struct net_device *dev, struct uli526x_board_info
 				/* Good packet, send to upper layer */
 				/* Shorst packet used new SKB */
 				if ((rxlen < RX_COPY_SIZE) &&
-				    (((new_skb = dev_alloc_skb(rxlen + 2)) != NULL))) {
+				    (((new_skb = netdev_alloc_skb(dev, rxlen + 2)) != NULL))) {
 					skb = new_skb;
 					/* size less than COPY_SIZE, allocate a rxlen SKB */
 					skb_reserve(skb, 2); /* 16byte align */
@@ -1289,8 +1289,9 @@ static void uli526x_reuse_skb(struct uli526x_board_info *db, struct sk_buff * sk
  *	Using Chain structure, and allocate Tx/Rx buffer
  */
 
-static void uli526x_descriptor_init(struct uli526x_board_info *db, unsigned long ioaddr)
+static void uli526x_descriptor_init(struct net_device *dev, unsigned long ioaddr)
 {
+	struct uli526x_board_info *db = netdev_priv(dev);
 	struct tx_desc *tmp_tx;
 	struct rx_desc *tmp_rx;
 	unsigned char *tmp_buf;
@@ -1343,7 +1344,7 @@ static void uli526x_descriptor_init(struct uli526x_board_info *db, unsigned long
 	tmp_rx->next_rx_desc = db->first_rx_desc;
 
 	/* pre-allocate Rx buffer */
-	allocate_rx_buffer(db);
+	allocate_rx_buffer(dev);
 }
 
 
@@ -1433,15 +1434,17 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
  *	As possible as allocate maxiumn Rx buffer
  */
 
-static void allocate_rx_buffer(struct uli526x_board_info *db)
+static void allocate_rx_buffer(struct net_device *dev)
 {
+	struct uli526x_board_info *db = netdev_priv(dev);
 	struct rx_desc *rxptr;
 	struct sk_buff *skb;
 
 	rxptr = db->rx_insert_ptr;
 
 	while(db->rx_avail_cnt < RX_DESC_CNT) {
-		if ( ( skb = dev_alloc_skb(RX_ALLOC_SIZE) ) == NULL )
+		skb = netdev_alloc_skb(dev, RX_ALLOC_SIZE);
+		if (skb == NULL)
 			break;
 		rxptr->rx_skb_ptr = skb; /* FIXME (?) */
 		rxptr->rdes2 = cpu_to_le32(pci_map_single(db->pdev,
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index bee9703..1895605 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -370,12 +370,13 @@ struct s6gmac {
 	} link;
 };
 
-static void s6gmac_rx_fillfifo(struct s6gmac *pd)
+static void s6gmac_rx_fillfifo(struct net_device *dev)
 {
+	struct s6gmac *pd = netdev_priv(dev);
 	struct sk_buff *skb;
 	while ((((u8)(pd->rx_skb_i - pd->rx_skb_o)) < S6_NUM_RX_SKB) &&
 	       (!s6dmac_fifo_full(pd->rx_dma, pd->rx_chan)) &&
-	       (skb = dev_alloc_skb(S6_MAX_FRLEN + 2))) {
+	       (skb = netdev_alloc_skb(dev, S6_MAX_FRLEN + 2))) {
 		pd->rx_skb[(pd->rx_skb_i++) % S6_NUM_RX_SKB] = skb;
 		s6dmac_put_fifo_cache(pd->rx_dma, pd->rx_chan,
 			pd->io, (u32)skb->data, S6_MAX_FRLEN);
@@ -514,7 +515,7 @@ static irqreturn_t s6gmac_interrupt(int irq, void *dev_id)
 	spin_lock(&pd->lock);
 	if (s6dmac_termcnt_irq(pd->rx_dma, pd->rx_chan))
 		s6gmac_rx_interrupt(dev);
-	s6gmac_rx_fillfifo(pd);
+	s6gmac_rx_fillfifo(dev);
 	if (s6dmac_termcnt_irq(pd->tx_dma, pd->tx_chan))
 		s6gmac_tx_interrupt(dev);
 	s6gmac_stats_interrupt(pd, 0);
@@ -894,7 +895,7 @@ static int s6gmac_open(struct net_device *dev)
 	s6gmac_init_device(dev);
 	s6gmac_init_stats(dev);
 	s6gmac_init_dmac(dev);
-	s6gmac_rx_fillfifo(pd);
+	s6gmac_rx_fillfifo(dev);
 	s6dmac_enable_chan(pd->rx_dma, pd->rx_chan,
 		2, 1, 0, 1, 0, 0, 0, 7, -1, 2, 0, 1);
 	s6dmac_enable_chan(pd->tx_dma, pd->tx_chan,
