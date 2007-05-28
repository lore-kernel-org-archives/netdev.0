From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 28 May 2007 12:16:51 +0200
Message-ID: <200705281216.51690.mb@bu3sch.de>
References: <20070525172431.60affaca@freepuppy> <200705280224.40506.mb@bu3sch.de> <200705280240.17910.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705280240.17910.maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Can you give 2.6.16 a try? The diff is not that big and we might
be able to find out what broke if you find out 2.6.16 works.
You can also try later kernels like .17, .18, .19 to further
reduce the patch. (You could also git-bisect, if you have the time).

git-diff v2.6.16..v2.6.22-rc3 drivers/net/b44.c

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index c3267e4..879a2ff 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2,6 +2,7 @@
  *
  * Copyright (C) 2002 David S. Miller (davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org)
  * Fixed by Pekka Pietikainen (pp-YuCZbdju05vHOG6cAo2yLw@public.gmane.org)
+ * Copyright (C) 2006 Broadcom Corporation.
  *
  * Distribute under GPL.
  */
@@ -28,8 +29,8 @@ #include "b44.h"
 
 #define DRV_MODULE_NAME		"b44"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"0.97"
-#define DRV_MODULE_RELDATE	"Nov 30, 2005"
+#define DRV_MODULE_VERSION	"1.01"
+#define DRV_MODULE_RELDATE	"Jun 16, 2006"
 
 #define B44_DEF_MSG_ENABLE	  \
 	(NETIF_MSG_DRV		| \
@@ -58,7 +59,6 @@ #define B44_TX_RING_SIZE		512
 #define B44_DEF_TX_RING_PENDING		(B44_TX_RING_SIZE - 1)
 #define B44_TX_RING_BYTES	(sizeof(struct dma_desc) * \
 				 B44_TX_RING_SIZE)
-#define B44_DMA_MASK 0x3fffffff
 
 #define TX_RING_GAP(BP)	\
 	(B44_TX_RING_SIZE - (BP)->tx_pending)
@@ -74,6 +74,15 @@ #define TX_PKT_BUF_SZ		(B44_MAX_MTU + ET
 /* minimum number of free TX descriptors required to wake up TX process */
 #define B44_TX_WAKEUP_THRESH		(B44_TX_RING_SIZE / 4)
 
+/* b44 internal pattern match filter info */
+#define B44_PATTERN_BASE	0x400
+#define B44_PATTERN_SIZE	0x80
+#define B44_PMASK_BASE		0x600
+#define B44_PMASK_SIZE		0x10
+#define B44_MAX_PATTERNS	16
+#define B44_ETHIPV6UDP_HLEN	62
+#define B44_ETHIPV4UDP_HLEN	42
+
 static char version[] __devinitdata =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
@@ -100,7 +109,12 @@ MODULE_DEVICE_TABLE(pci, b44_pci_tbl);
 
 static void b44_halt(struct b44 *);
 static void b44_init_rings(struct b44 *);
-static void b44_init_hw(struct b44 *);
+
+#define B44_FULL_RESET		1
+#define B44_FULL_RESET_SKIP_PHY	2
+#define B44_PARTIAL_RESET	3
+
+static void b44_init_hw(struct b44 *, int);
 
 static int dma_desc_align_mask;
 static int dma_desc_sync_size;
@@ -136,7 +150,7 @@ static inline unsigned long br32(const s
 	return readl(bp->regs + reg);
 }
 
-static inline void bw32(const struct b44 *bp, 
+static inline void bw32(const struct b44 *bp,
 			unsigned long reg, unsigned long val)
 {
 	writel(val, bp->regs + reg);
@@ -286,13 +300,13 @@ static void __b44_cam_write(struct b44 *
 	val |= ((u32) data[4]) <<  8;
 	val |= ((u32) data[5]) <<  0;
 	bw32(bp, B44_CAM_DATA_LO, val);
-	val = (CAM_DATA_HI_VALID | 
+	val = (CAM_DATA_HI_VALID |
 	       (((u32) data[0]) << 8) |
 	       (((u32) data[1]) << 0));
 	bw32(bp, B44_CAM_DATA_HI, val);
 	bw32(bp, B44_CAM_CTRL, (CAM_CTRL_WRITE |
 			    (index << CAM_CTRL_INDEX_SHIFT)));
-	b44_wait_bit(bp, B44_CAM_CTRL, CAM_CTRL_BUSY, 100, 1);	
+	b44_wait_bit(bp, B44_CAM_CTRL, CAM_CTRL_BUSY, 100, 1);
 }
 
 static inline void __b44_disable_ints(struct b44 *bp)
@@ -410,25 +424,18 @@ static void __b44_set_flow_ctrl(struct b
 
 static void b44_set_flow_ctrl(struct b44 *bp, u32 local, u32 remote)
 {
-	u32 pause_enab = bp->flags & (B44_FLAG_TX_PAUSE |
-				      B44_FLAG_RX_PAUSE);
+	u32 pause_enab = 0;
 
-	if (local & ADVERTISE_PAUSE_CAP) {
-		if (local & ADVERTISE_PAUSE_ASYM) {
-			if (remote & LPA_PAUSE_CAP)
-				pause_enab |= (B44_FLAG_TX_PAUSE |
-					       B44_FLAG_RX_PAUSE);
-			else if (remote & LPA_PAUSE_ASYM)
-				pause_enab |= B44_FLAG_RX_PAUSE;
-		} else {
-			if (remote & LPA_PAUSE_CAP)
-				pause_enab |= (B44_FLAG_TX_PAUSE |
-					       B44_FLAG_RX_PAUSE);
-		}
-	} else if (local & ADVERTISE_PAUSE_ASYM) {
-		if ((remote & LPA_PAUSE_CAP) &&
-		    (remote & LPA_PAUSE_ASYM))
-			pause_enab |= B44_FLAG_TX_PAUSE;
+	/* The driver supports only rx pause by default because
+	   the b44 mac tx pause mechanism generates excessive
+	   pause frames.
+	   Use ethtool to turn on b44 tx pause if necessary.
+	 */
+	if ((local & ADVERTISE_PAUSE_CAP) &&
+	    (local & ADVERTISE_PAUSE_ASYM)){
+		if ((remote & LPA_PAUSE_ASYM) &&
+		    !(remote & LPA_PAUSE_CAP))
+			pause_enab |= B44_FLAG_RX_PAUSE;
 	}
 
 	__b44_set_flow_ctrl(bp, pause_enab);
@@ -608,8 +615,7 @@ static void b44_tx(struct b44 *bp)
 		struct ring_info *rp = &bp->tx_buffers[cons];
 		struct sk_buff *skb = rp->skb;
 
-		if (unlikely(skb == NULL))
-			BUG();
+		BUG_ON(skb == NULL);
 
 		pci_unmap_single(bp->pdev,
 				 pci_unmap_addr(rp, mapping),
@@ -657,9 +663,11 @@ static int b44_alloc_rx_skb(struct b44 *
 
 	/* Hardware bug work-around, the chip is unable to do PCI DMA
 	   to/from anything above 1GB :-( */
-	if (mapping + RX_PKT_BUF_SZ > B44_DMA_MASK) {
+	if (dma_mapping_error(mapping) ||
+		mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
 		/* Sigh... */
-		pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
+		if (!dma_mapping_error(mapping))
+			pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
 		dev_kfree_skb_any(skb);
 		skb = __dev_alloc_skb(RX_PKT_BUF_SZ,GFP_DMA);
 		if (skb == NULL)
@@ -667,8 +675,10 @@ static int b44_alloc_rx_skb(struct b44 *
 		mapping = pci_map_single(bp->pdev, skb->data,
 					 RX_PKT_BUF_SZ,
 					 PCI_DMA_FROMDEVICE);
-		if (mapping + RX_PKT_BUF_SZ > B44_DMA_MASK) {
-			pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
+		if (dma_mapping_error(mapping) ||
+			mapping + RX_PKT_BUF_SZ > DMA_30BIT_MASK) {
+			if (!dma_mapping_error(mapping))
+				pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
 			dev_kfree_skb_any(skb);
 			return -ENOMEM;
 		}
@@ -710,7 +720,7 @@ static void b44_recycle_rx(struct b44 *b
 	struct ring_info *src_map, *dest_map;
 	struct rx_header *rh;
 	int dest_idx;
-	u32 ctrl;
+	__le32 ctrl;
 
 	dest_idx = dest_idx_unmasked & (B44_RX_RING_SIZE - 1);
 	dest_desc = &bp->rx_ring[dest_idx];
@@ -746,7 +756,7 @@ static void b44_recycle_rx(struct b44 *b
 		                             dest_idx * sizeof(dest_desc),
 		                             DMA_BIDIRECTIONAL);
 
-	pci_dma_sync_single_for_device(bp->pdev, src_desc->addr,
+	pci_dma_sync_single_for_device(bp->pdev, le32_to_cpu(src_desc->addr),
 				       RX_PKT_BUF_SZ,
 				       PCI_DMA_FROMDEVICE);
 }
@@ -772,7 +782,7 @@ static int b44_rx(struct b44 *bp, int bu
 					    RX_PKT_BUF_SZ,
 					    PCI_DMA_FROMDEVICE);
 		rh = (struct rx_header *) skb->data;
-		len = cpu_to_le16(rh->len);
+		len = le16_to_cpu(rh->len);
 		if ((len > (RX_PKT_BUF_SZ - bp->rx_offset)) ||
 		    (rh->flags & cpu_to_le16(RX_FLAG_ERRORS))) {
 		drop_it:
@@ -788,7 +798,7 @@ static int b44_rx(struct b44 *bp, int bu
 			do {
 				udelay(2);
 				barrier();
-				len = cpu_to_le16(rh->len);
+				len = le16_to_cpu(rh->len);
 			} while (len == 0 && i++ < 5);
 			if (len == 0)
 				goto drop_it;
@@ -815,12 +825,11 @@ static int b44_rx(struct b44 *bp, int bu
 			if (copy_skb == NULL)
 				goto drop_it_no_recycle;
 
-			copy_skb->dev = bp->dev;
 			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			/* DMA sync done above, copy just the actual packet */
-			memcpy(copy_skb->data, skb->data+bp->rx_offset, len);
-
+			skb_copy_from_linear_data_offset(skb, bp->rx_offset,
+							 copy_skb->data, len);
 			skb = copy_skb;
 		}
 		skb->ip_summed = CHECKSUM_NONE;
@@ -873,12 +882,14 @@ static int b44_poll(struct net_device *n
 	}
 
 	if (bp->istat & ISTAT_ERRORS) {
-		spin_lock_irq(&bp->lock);
+		unsigned long flags;
+
+		spin_lock_irqsave(&bp->lock, flags);
 		b44_halt(bp);
 		b44_init_rings(bp);
-		b44_init_hw(bp);
+		b44_init_hw(bp, B44_FULL_RESET_SKIP_PHY);
 		netif_wake_queue(bp->dev);
-		spin_unlock_irq(&bp->lock);
+		spin_unlock_irqrestore(&bp->lock, flags);
 		done = 1;
 	}
 
@@ -890,7 +901,7 @@ static int b44_poll(struct net_device *n
 	return (done ? 0 : 1);
 }
 
-static irqreturn_t b44_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+static irqreturn_t b44_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct b44 *bp = netdev_priv(dev);
@@ -902,8 +913,9 @@ static irqreturn_t b44_interrupt(int irq
 	istat = br32(bp, B44_ISTAT);
 	imask = br32(bp, B44_IMASK);
 
-	/* ??? What the fuck is the purpose of the interrupt mask
-	 * ??? register if we have to mask it out by hand anyways?
+	/* The interrupt mask register controls which interrupt bits
+	 * will actually raise an interrupt to the CPU when set by hw/firmware,
+	 * but doesn't mask off the bits.
 	 */
 	istat &= imask;
 	if (istat) {
@@ -945,7 +957,7 @@ static void b44_tx_timeout(struct net_de
 
 	b44_halt(bp);
 	b44_init_rings(bp);
-	b44_init_hw(bp);
+	b44_init_hw(bp, B44_FULL_RESET);
 
 	spin_unlock_irq(&bp->lock);
 
@@ -974,9 +986,10 @@ static int b44_start_xmit(struct sk_buff
 	}
 
 	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	if (mapping + len > B44_DMA_MASK) {
+	if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
-		pci_unmap_single(bp->pdev, mapping, len, PCI_DMA_TODEVICE);
+		if (!dma_mapping_error(mapping))
+			pci_unmap_single(bp->pdev, mapping, len, PCI_DMA_TODEVICE);
 
 		bounce_skb = __dev_alloc_skb(TX_PKT_BUF_SZ,
 					     GFP_ATOMIC|GFP_DMA);
@@ -985,14 +998,16 @@ static int b44_start_xmit(struct sk_buff
 
 		mapping = pci_map_single(bp->pdev, bounce_skb->data,
 					 len, PCI_DMA_TODEVICE);
-		if (mapping + len > B44_DMA_MASK) {
-			pci_unmap_single(bp->pdev, mapping,
+		if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
+			if (!dma_mapping_error(mapping))
+				pci_unmap_single(bp->pdev, mapping,
 					 len, PCI_DMA_TODEVICE);
 			dev_kfree_skb_any(bounce_skb);
 			goto err_out;
 		}
 
-		memcpy(skb_put(bounce_skb, len), skb->data, skb->len);
+		skb_copy_from_linear_data(skb, skb_put(bounce_skb, len),
+					  skb->len);
 		dev_kfree_skb_any(skb);
 		skb = bounce_skb;
 	}
@@ -1060,11 +1075,11 @@ static int b44_change_mtu(struct net_dev
 	b44_halt(bp);
 	dev->mtu = new_mtu;
 	b44_init_rings(bp);
-	b44_init_hw(bp);
+	b44_init_hw(bp, B44_FULL_RESET);
 	spin_unlock_irq(&bp->lock);
 
 	b44_enable_ints(bp);
-	
+
 	return 0;
 }
 
@@ -1210,7 +1225,8 @@ static int b44_alloc_consistent(struct b
 		                             DMA_TABLE_BYTES,
 		                             DMA_BIDIRECTIONAL);
 
-		if (rx_ring_dma + size > B44_DMA_MASK) {
+		if (dma_mapping_error(rx_ring_dma) ||
+			rx_ring_dma + size > DMA_30BIT_MASK) {
 			kfree(rx_ring);
 			goto out_err;
 		}
@@ -1236,7 +1252,8 @@ static int b44_alloc_consistent(struct b
 		                             DMA_TABLE_BYTES,
 		                             DMA_TO_DEVICE);
 
-		if (tx_ring_dma + size > B44_DMA_MASK) {
+		if (dma_mapping_error(tx_ring_dma) ||
+			tx_ring_dma + size > DMA_30BIT_MASK) {
 			kfree(tx_ring);
 			goto out_err;
 		}
@@ -1271,7 +1288,7 @@ static void b44_chip_reset(struct b44 *b
 	if (ssb_is_core_up(bp)) {
 		bw32(bp, B44_RCV_LAZY, 0);
 		bw32(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE);
-		b44_wait_bit(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE, 100, 1);
+		b44_wait_bit(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE, 200, 1);
 		bw32(bp, B44_DMATX_CTRL, 0);
 		bp->tx_prod = bp->tx_cons = 0;
 		if (br32(bp, B44_DMARX_STAT) & DMARX_STAT_EMASK) {
@@ -1339,6 +1356,9 @@ static int b44_set_mac_addr(struct net_d
 	if (netif_running(dev))
 		return -EBUSY;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
 	spin_lock_irq(&bp->lock);
@@ -1352,13 +1372,15 @@ static int b44_set_mac_addr(struct net_d
  * packet processing.  Invoked with bp->lock held.
  */
 static void __b44_set_rx_mode(struct net_device *);
-static void b44_init_hw(struct b44 *bp)
+static void b44_init_hw(struct b44 *bp, int reset_kind)
 {
 	u32 val;
 
 	b44_chip_reset(bp);
-	b44_phy_reset(bp);
-	b44_setup_phy(bp);
+	if (reset_kind == B44_FULL_RESET) {
+		b44_phy_reset(bp);
+		b44_setup_phy(bp);
+	}
 
 	/* Enable CRC32, set proper LED modes and power on PHY */
 	bw32(bp, B44_MAC_CTRL, MAC_CTRL_CRC32_ENAB | MAC_CTRL_PHY_LEDCTRL);
@@ -1372,16 +1394,21 @@ static void b44_init_hw(struct b44 *bp)
 	bw32(bp, B44_TXMAXLEN, bp->dev->mtu + ETH_HLEN + 8 + RX_HEADER_LEN);
 
 	bw32(bp, B44_TX_WMARK, 56); /* XXX magic */
-	bw32(bp, B44_DMATX_CTRL, DMATX_CTRL_ENABLE);
-	bw32(bp, B44_DMATX_ADDR, bp->tx_ring_dma + bp->dma_offset);
-	bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
-			      (bp->rx_offset << DMARX_CTRL_ROSHIFT)));
-	bw32(bp, B44_DMARX_ADDR, bp->rx_ring_dma + bp->dma_offset);
+	if (reset_kind == B44_PARTIAL_RESET) {
+		bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
+				      (bp->rx_offset << DMARX_CTRL_ROSHIFT)));
+	} else {
+		bw32(bp, B44_DMATX_CTRL, DMATX_CTRL_ENABLE);
+		bw32(bp, B44_DMATX_ADDR, bp->tx_ring_dma + bp->dma_offset);
+		bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
+				      (bp->rx_offset << DMARX_CTRL_ROSHIFT)));
+		bw32(bp, B44_DMARX_ADDR, bp->rx_ring_dma + bp->dma_offset);
 
-	bw32(bp, B44_DMARX_PTR, bp->rx_pending);
-	bp->rx_prod = bp->rx_pending;	
+		bw32(bp, B44_DMARX_PTR, bp->rx_pending);
+		bp->rx_prod = bp->rx_pending;
 
-	bw32(bp, B44_MIB_CTRL, MIB_CTRL_CLR_ON_READ);
+		bw32(bp, B44_MIB_CTRL, MIB_CTRL_CLR_ON_READ);
+	}
 
 	val = br32(bp, B44_ENET_CTRL);
 	bw32(bp, B44_ENET_CTRL, (val | ENET_CTRL_ENABLE));
@@ -1397,11 +1424,11 @@ static int b44_open(struct net_device *d
 		goto out;
 
 	b44_init_rings(bp);
-	b44_init_hw(bp);
+	b44_init_hw(bp, B44_FULL_RESET);
 
 	b44_check_phy(bp);
 
-	err = request_irq(dev->irq, b44_interrupt, SA_SHIRQ, dev->name, dev);
+	err = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
 	if (unlikely(err < 0)) {
 		b44_chip_reset(bp);
 		b44_free_rings(bp);
@@ -1441,11 +1468,145 @@ #ifdef CONFIG_NET_POLL_CONTROLLER
 static void b44_poll_controller(struct net_device *dev)
 {
 	disable_irq(dev->irq);
-	b44_interrupt(dev->irq, dev, NULL);
+	b44_interrupt(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif
 
+static void bwfilter_table(struct b44 *bp, u8 *pp, u32 bytes, u32 table_offset)
+{
+	u32 i;
+	u32 *pattern = (u32 *) pp;
+
+	for (i = 0; i < bytes; i += sizeof(u32)) {
+		bw32(bp, B44_FILT_ADDR, table_offset + i);
+		bw32(bp, B44_FILT_DATA, pattern[i / sizeof(u32)]);
+	}
+}
+
+static int b44_magic_pattern(u8 *macaddr, u8 *ppattern, u8 *pmask, int offset)
+{
+	int magicsync = 6;
+	int k, j, len = offset;
+	int ethaddr_bytes = ETH_ALEN;
+
+	memset(ppattern + offset, 0xff, magicsync);
+	for (j = 0; j < magicsync; j++)
+		set_bit(len++, (unsigned long *) pmask);
+
+	for (j = 0; j < B44_MAX_PATTERNS; j++) {
+		if ((B44_PATTERN_SIZE - len) >= ETH_ALEN)
+			ethaddr_bytes = ETH_ALEN;
+		else
+			ethaddr_bytes = B44_PATTERN_SIZE - len;
+		if (ethaddr_bytes <=0)
+			break;
+		for (k = 0; k< ethaddr_bytes; k++) {
+			ppattern[offset + magicsync +
+				(j * ETH_ALEN) + k] = macaddr[k];
+			len++;
+			set_bit(len, (unsigned long *) pmask);
+		}
+	}
+	return len - 1;
+}
+
+/* Setup magic packet patterns in the b44 WOL
+ * pattern matching filter.
+ */
+static void b44_setup_pseudo_magicp(struct b44 *bp)
+{
+
+	u32 val;
+	int plen0, plen1, plen2;
+	u8 *pwol_pattern;
+	u8 pwol_mask[B44_PMASK_SIZE];
+
+	pwol_pattern = kmalloc(B44_PATTERN_SIZE, GFP_KERNEL);
+	if (!pwol_pattern) {
+		printk(KERN_ERR PFX "Memory not available for WOL\n");
+		return;
+	}
+
+	/* Ipv4 magic packet pattern - pattern 0.*/
+	memset(pwol_pattern, 0, B44_PATTERN_SIZE);
+	memset(pwol_mask, 0, B44_PMASK_SIZE);
+	plen0 = b44_magic_pattern(bp->dev->dev_addr, pwol_pattern, pwol_mask,
+				  B44_ETHIPV4UDP_HLEN);
+
+   	bwfilter_table(bp, pwol_pattern, B44_PATTERN_SIZE, B44_PATTERN_BASE);
+   	bwfilter_table(bp, pwol_mask, B44_PMASK_SIZE, B44_PMASK_BASE);
+
+	/* Raw ethernet II magic packet pattern - pattern 1 */
+	memset(pwol_pattern, 0, B44_PATTERN_SIZE);
+	memset(pwol_mask, 0, B44_PMASK_SIZE);
+	plen1 = b44_magic_pattern(bp->dev->dev_addr, pwol_pattern, pwol_mask,
+				  ETH_HLEN);
+
+   	bwfilter_table(bp, pwol_pattern, B44_PATTERN_SIZE,
+		       B44_PATTERN_BASE + B44_PATTERN_SIZE);
+  	bwfilter_table(bp, pwol_mask, B44_PMASK_SIZE,
+		       B44_PMASK_BASE + B44_PMASK_SIZE);
+
+	/* Ipv6 magic packet pattern - pattern 2 */
+	memset(pwol_pattern, 0, B44_PATTERN_SIZE);
+	memset(pwol_mask, 0, B44_PMASK_SIZE);
+	plen2 = b44_magic_pattern(bp->dev->dev_addr, pwol_pattern, pwol_mask,
+				  B44_ETHIPV6UDP_HLEN);
+
+   	bwfilter_table(bp, pwol_pattern, B44_PATTERN_SIZE,
+		       B44_PATTERN_BASE + B44_PATTERN_SIZE + B44_PATTERN_SIZE);
+  	bwfilter_table(bp, pwol_mask, B44_PMASK_SIZE,
+		       B44_PMASK_BASE + B44_PMASK_SIZE + B44_PMASK_SIZE);
+
+	kfree(pwol_pattern);
+
+	/* set these pattern's lengths: one less than each real length */
+	val = plen0 | (plen1 << 8) | (plen2 << 16) | WKUP_LEN_ENABLE_THREE;
+	bw32(bp, B44_WKUP_LEN, val);
+
+	/* enable wakeup pattern matching */
+	val = br32(bp, B44_DEVCTRL);
+	bw32(bp, B44_DEVCTRL, val | DEVCTRL_PFE);
+
+}
+
+static void b44_setup_wol(struct b44 *bp)
+{
+	u32 val;
+	u16 pmval;
+
+	bw32(bp, B44_RXCONFIG, RXCONFIG_ALLMULTI);
+
+	if (bp->flags & B44_FLAG_B0_ANDLATER) {
+
+		bw32(bp, B44_WKUP_LEN, WKUP_LEN_DISABLE);
+
+		val = bp->dev->dev_addr[2] << 24 |
+			bp->dev->dev_addr[3] << 16 |
+			bp->dev->dev_addr[4] << 8 |
+			bp->dev->dev_addr[5];
+		bw32(bp, B44_ADDR_LO, val);
+
+		val = bp->dev->dev_addr[0] << 8 |
+			bp->dev->dev_addr[1];
+		bw32(bp, B44_ADDR_HI, val);
+
+		val = br32(bp, B44_DEVCTRL);
+		bw32(bp, B44_DEVCTRL, val | DEVCTRL_MPM | DEVCTRL_PFE);
+
+ 	} else {
+ 		b44_setup_pseudo_magicp(bp);
+ 	}
+
+	val = br32(bp, B44_SBTMSLOW);
+	bw32(bp, B44_SBTMSLOW, val | SBTMSLOW_PE);
+
+	pci_read_config_word(bp->pdev, SSB_PMCSR, &pmval);
+	pci_write_config_word(bp->pdev, SSB_PMCSR, pmval | SSB_PE);
+
+}
+
 static int b44_close(struct net_device *dev)
 {
 	struct b44 *bp = netdev_priv(dev);
@@ -1471,6 +1632,11 @@ #endif
 
 	netif_poll_enable(dev);
 
+	if (bp->flags & B44_FLAG_WOL_ENABLE) {
+		b44_init_hw(bp, B44_PARTIAL_RESET);
+		b44_setup_wol(bp);
+	}
+
 	b44_free_consistent(bp);
 
 	return 0;
@@ -1543,18 +1709,19 @@ static void __b44_set_rx_mode(struct net
 		bw32(bp, B44_RXCONFIG, val);
 	} else {
 		unsigned char zero[6] = {0, 0, 0, 0, 0, 0};
-		int i = 0;
+		int i = 1;
 
 		__b44_set_mac_addr(bp);
 
-		if (dev->flags & IFF_ALLMULTI)
+		if ((dev->flags & IFF_ALLMULTI) ||
+		    (dev->mc_count > B44_MCAST_TABLE_SIZE))
 			val |= RXCONFIG_ALLMULTI;
 		else
 			i = __b44_load_mcast(bp, dev);
-		
-		for (; i < 64; i++) {
-			__b44_cam_write(bp, zero, i);			
-		}
+
+		for (; i < 64; i++)
+			__b44_cam_write(bp, zero, i);
+
 		bw32(bp, B44_RXCONFIG, val);
         	val = br32(bp, B44_CAM_CTRL);
 	        bw32(bp, B44_CAM_CTRL, val | CAM_CTRL_ENABLE);
@@ -1616,8 +1783,6 @@ static int b44_get_settings(struct net_d
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
-		return -EAGAIN;
 	cmd->supported = (SUPPORTED_Autoneg);
 	cmd->supported |= (SUPPORTED_100baseT_Half |
 			  SUPPORTED_100baseT_Full |
@@ -1645,6 +1810,12 @@ static int b44_get_settings(struct net_d
 		XCVR_INTERNAL : XCVR_EXTERNAL;
 	cmd->autoneg = (bp->flags & B44_FLAG_FORCE_LINK) ?
 		AUTONEG_DISABLE : AUTONEG_ENABLE;
+	if (cmd->autoneg == AUTONEG_ENABLE)
+		cmd->advertising |= ADVERTISED_Autoneg;
+	if (!netif_running(dev)){
+		cmd->speed = 0;
+		cmd->duplex = 0xff;
+	}
 	cmd->maxtxpkt = 0;
 	cmd->maxrxpkt = 0;
 	return 0;
@@ -1654,9 +1825,6 @@ static int b44_set_settings(struct net_d
 {
 	struct b44 *bp = netdev_priv(dev);
 
-	if (!netif_running(dev))
-		return -EAGAIN;
-
 	/* We do not support gigabit. */
 	if (cmd->autoneg == AUTONEG_ENABLE) {
 		if (cmd->advertising &
@@ -1673,28 +1841,39 @@ static int b44_set_settings(struct net_d
 	spin_lock_irq(&bp->lock);
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
-		bp->flags &= ~B44_FLAG_FORCE_LINK;
-		bp->flags &= ~(B44_FLAG_ADV_10HALF |
+		bp->flags &= ~(B44_FLAG_FORCE_LINK |
+			       B44_FLAG_100_BASE_T |
+			       B44_FLAG_FULL_DUPLEX |
+			       B44_FLAG_ADV_10HALF |
 			       B44_FLAG_ADV_10FULL |
 			       B44_FLAG_ADV_100HALF |
 			       B44_FLAG_ADV_100FULL);
-		if (cmd->advertising & ADVERTISE_10HALF)
-			bp->flags |= B44_FLAG_ADV_10HALF;
-		if (cmd->advertising & ADVERTISE_10FULL)
-			bp->flags |= B44_FLAG_ADV_10FULL;
-		if (cmd->advertising & ADVERTISE_100HALF)
-			bp->flags |= B44_FLAG_ADV_100HALF;
-		if (cmd->advertising & ADVERTISE_100FULL)
-			bp->flags |= B44_FLAG_ADV_100FULL;
+		if (cmd->advertising == 0) {
+			bp->flags |= (B44_FLAG_ADV_10HALF |
+				      B44_FLAG_ADV_10FULL |
+				      B44_FLAG_ADV_100HALF |
+				      B44_FLAG_ADV_100FULL);
+		} else {
+			if (cmd->advertising & ADVERTISED_10baseT_Half)
+				bp->flags |= B44_FLAG_ADV_10HALF;
+			if (cmd->advertising & ADVERTISED_10baseT_Full)
+				bp->flags |= B44_FLAG_ADV_10FULL;
+			if (cmd->advertising & ADVERTISED_100baseT_Half)
+				bp->flags |= B44_FLAG_ADV_100HALF;
+			if (cmd->advertising & ADVERTISED_100baseT_Full)
+				bp->flags |= B44_FLAG_ADV_100FULL;
+		}
 	} else {
 		bp->flags |= B44_FLAG_FORCE_LINK;
+		bp->flags &= ~(B44_FLAG_100_BASE_T | B44_FLAG_FULL_DUPLEX);
 		if (cmd->speed == SPEED_100)
 			bp->flags |= B44_FLAG_100_BASE_T;
 		if (cmd->duplex == DUPLEX_FULL)
 			bp->flags |= B44_FLAG_FULL_DUPLEX;
 	}
 
-	b44_setup_phy(bp);
+	if (netif_running(dev))
+		b44_setup_phy(bp);
 
 	spin_unlock_irq(&bp->lock);
 
@@ -1730,12 +1909,12 @@ static int b44_set_ringparam(struct net_
 
 	b44_halt(bp);
 	b44_init_rings(bp);
-	b44_init_hw(bp);
+	b44_init_hw(bp, B44_FULL_RESET);
 	netif_wake_queue(bp->dev);
 	spin_unlock_irq(&bp->lock);
 
 	b44_enable_ints(bp);
-	
+
 	return 0;
 }
 
@@ -1773,14 +1952,14 @@ static int b44_set_pauseparam(struct net
 	if (bp->flags & B44_FLAG_PAUSE_AUTO) {
 		b44_halt(bp);
 		b44_init_rings(bp);
-		b44_init_hw(bp);
+		b44_init_hw(bp, B44_FULL_RESET);
 	} else {
 		__b44_set_flow_ctrl(bp, bp->flags);
 	}
 	spin_unlock_irq(&bp->lock);
 
 	b44_enable_ints(bp);
-	
+
 	return 0;
 }
 
@@ -1815,12 +1994,40 @@ static void b44_get_ethtool_stats(struct
 	spin_unlock_irq(&bp->lock);
 }
 
-static struct ethtool_ops b44_ethtool_ops = {
+static void b44_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct b44 *bp = netdev_priv(dev);
+
+	wol->supported = WAKE_MAGIC;
+	if (bp->flags & B44_FLAG_WOL_ENABLE)
+		wol->wolopts = WAKE_MAGIC;
+	else
+		wol->wolopts = 0;
+	memset(&wol->sopass, 0, sizeof(wol->sopass));
+}
+
+static int b44_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct b44 *bp = netdev_priv(dev);
+
+	spin_lock_irq(&bp->lock);
+	if (wol->wolopts & WAKE_MAGIC)
+		bp->flags |= B44_FLAG_WOL_ENABLE;
+	else
+		bp->flags &= ~B44_FLAG_WOL_ENABLE;
+	spin_unlock_irq(&bp->lock);
+
+	return 0;
+}
+
+static const struct ethtool_ops b44_ethtool_ops = {
 	.get_drvinfo		= b44_get_drvinfo,
 	.get_settings		= b44_get_settings,
 	.set_settings		= b44_set_settings,
 	.nway_reset		= b44_nway_reset,
 	.get_link		= ethtool_op_get_link,
+	.get_wol		= b44_get_wol,
+	.set_wol		= b44_set_wol,
 	.get_ringparam		= b44_get_ringparam,
 	.set_ringparam		= b44_set_ringparam,
 	.get_pauseparam		= b44_get_pauseparam,
@@ -1853,10 +2060,10 @@ out:
 static int b44_read_eeprom(struct b44 *bp, u8 *data)
 {
 	long i;
-	u16 *ptr = (u16 *) data;
+	__le16 *ptr = (__le16 *) data;
 
 	for (i = 0; i < 128; i += 2)
-		ptr[i / 2] = readw(bp->regs + 4096 + i);
+		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));
 
 	return 0;
 }
@@ -1876,6 +2083,12 @@ static int __devinit b44_get_invariants(
 	bp->dev->dev_addr[3] = eeprom[80];
 	bp->dev->dev_addr[4] = eeprom[83];
 	bp->dev->dev_addr[5] = eeprom[82];
+
+	if (!is_valid_ether_addr(&bp->dev->dev_addr[0])){
+		printk(KERN_ERR PFX "Invalid MAC address found in EEPROM\n");
+		return -EINVAL;
+	}
+
 	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, bp->dev->addr_len);
 
 	bp->phy_addr = eeprom[90] & 0x1f;
@@ -1890,9 +2103,13 @@ static int __devinit b44_get_invariants(
 	bp->core_unit = ssb_core_unit(bp);
 	bp->dma_offset = SB_PCI_DMA;
 
-	/* XXX - really required? 
+	/* XXX - really required?
 	   bp->flags |= B44_FLAG_BUGGY_TXPTR;
          */
+
+ 	if (ssb_get_core_rev(bp) >= 7)
+ 		bp->flags |= B44_FLAG_B0_ANDLATER;
+
 out:
 	return err;
 }
@@ -1911,13 +2128,14 @@ static int __devinit b44_init_one(struct
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot enable PCI device, "
+		dev_err(&pdev->dev, "Cannot enable PCI device, "
 		       "aborting.\n");
 		return err;
 	}
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		printk(KERN_ERR PFX "Cannot find proper PCI device "
+		dev_err(&pdev->dev,
+			"Cannot find proper PCI device "
 		       "base address, aborting.\n");
 		err = -ENODEV;
 		goto err_out_disable_pdev;
@@ -1925,24 +2143,22 @@ static int __devinit b44_init_one(struct
 
 	err = pci_request_regions(pdev, DRV_MODULE_NAME);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot obtain PCI resources, "
-		       "aborting.\n");
+		dev_err(&pdev->dev,
+			"Cannot obtain PCI resources, aborting.\n");
 		goto err_out_disable_pdev;
 	}
 
 	pci_set_master(pdev);
 
-	err = pci_set_dma_mask(pdev, (u64) B44_DMA_MASK);
+	err = pci_set_dma_mask(pdev, (u64) DMA_30BIT_MASK);
 	if (err) {
-		printk(KERN_ERR PFX "No usable DMA configuration, "
-		       "aborting.\n");
+		dev_err(&pdev->dev, "No usable DMA configuration, aborting.\n");
 		goto err_out_free_res;
 	}
-	
-	err = pci_set_consistent_dma_mask(pdev, (u64) B44_DMA_MASK);
+
+	err = pci_set_consistent_dma_mask(pdev, (u64) DMA_30BIT_MASK);
 	if (err) {
-		printk(KERN_ERR PFX "No usable DMA configuration, "
-		       "aborting.\n");
+		dev_err(&pdev->dev, "No usable DMA configuration, aborting.\n");
 		goto err_out_free_res;
 	}
 
@@ -1951,7 +2167,7 @@ static int __devinit b44_init_one(struct
 
 	dev = alloc_etherdev(sizeof(*bp));
 	if (!dev) {
-		printk(KERN_ERR PFX "Etherdev alloc failed, aborting.\n");
+		dev_err(&pdev->dev, "Etherdev alloc failed, aborting.\n");
 		err = -ENOMEM;
 		goto err_out_free_res;
 	}
@@ -1972,8 +2188,7 @@ static int __devinit b44_init_one(struct
 
 	bp->regs = ioremap(b44reg_base, b44reg_len);
 	if (bp->regs == 0UL) {
-		printk(KERN_ERR PFX "Cannot map device registers, "
-		       "aborting.\n");
+		dev_err(&pdev->dev, "Cannot map device registers, aborting.\n");
 		err = -ENOMEM;
 		goto err_out_free_dev;
 	}
@@ -2003,8 +2218,8 @@ #endif
 
 	err = b44_get_invariants(bp);
 	if (err) {
-		printk(KERN_ERR PFX "Problem fetching invariants of chip, "
-		       "aborting.\n");
+		dev_err(&pdev->dev,
+			"Problem fetching invariants of chip, aborting.\n");
 		goto err_out_iounmap;
 	}
 
@@ -2024,8 +2239,7 @@ #endif
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot register net device, "
-		       "aborting.\n");
+		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
 		goto err_out_iounmap;
 	}
 
@@ -2033,6 +2247,11 @@ #endif
 
 	pci_save_state(bp->pdev);
 
+	/* Chip reset provides power to the b44 MAC & PCI cores, which
+	 * is necessary for MAC register access.
+	 */
+	b44_chip_reset(bp);
+
 	printk(KERN_INFO "%s: Broadcom 4400 10/100BaseT Ethernet ", dev->name);
 	for (i = 0; i < 6; i++)
 		printk("%2.2x%c", dev->dev_addr[i],
@@ -2078,16 +2297,20 @@ static int b44_suspend(struct pci_dev *p
 
 	del_timer_sync(&bp->timer);
 
-	spin_lock_irq(&bp->lock); 
+	spin_lock_irq(&bp->lock);
 
 	b44_halt(bp);
-	netif_carrier_off(bp->dev); 
+	netif_carrier_off(bp->dev);
 	netif_device_detach(bp->dev);
 	b44_free_rings(bp);
 
 	spin_unlock_irq(&bp->lock);
 
 	free_irq(dev->irq, dev);
+	if (bp->flags & B44_FLAG_WOL_ENABLE) {
+		b44_init_hw(bp, B44_PARTIAL_RESET);
+		b44_setup_wol(bp);
+	}
 	pci_disable_device(pdev);
 	return 0;
 }
@@ -2096,21 +2319,32 @@ static int b44_resume(struct pci_dev *pd
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct b44 *bp = netdev_priv(dev);
+	int rc = 0;
 
 	pci_restore_state(pdev);
-	pci_enable_device(pdev);
+	rc = pci_enable_device(pdev);
+	if (rc) {
+		printk(KERN_ERR PFX "%s: pci_enable_device failed\n",
+			dev->name);
+		return rc;
+	}
+
 	pci_set_master(pdev);
 
 	if (!netif_running(dev))
 		return 0;
 
-	if (request_irq(dev->irq, b44_interrupt, SA_SHIRQ, dev->name, dev))
+	rc = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
+	if (rc) {
 		printk(KERN_ERR PFX "%s: request_irq failed\n", dev->name);
+		pci_disable_device(pdev);
+		return rc;
+	}
 
 	spin_lock_irq(&bp->lock);
 
 	b44_init_rings(bp);
-	b44_init_hw(bp);
+	b44_init_hw(bp, B44_FULL_RESET);
 	netif_device_attach(bp->dev);
 	spin_unlock_irq(&bp->lock);
 
@@ -2139,7 +2373,7 @@ static int __init b44_init(void)
 	dma_desc_align_mask = ~(dma_desc_align_size - 1);
 	dma_desc_sync_size = max_t(unsigned int, dma_desc_align_size, sizeof(struct dma_desc));
 
-	return pci_module_init(&b44_driver);
+	return pci_register_driver(&b44_driver);
 }
 
 static void __exit b44_cleanup(void)

-- 
Greetings Michael.
