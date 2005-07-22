From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] forcedeth: Add support for 64-bit dma addresses.
Date: Fri, 22 Jul 2005 22:45:27 +0200
Message-ID: <42E15AE7.3020304@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050509060201050106010501"
Cc: Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050509060201050106010501
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jeff,

Ayaz wrote a patch that enables 64-bit DMA for recent nForce nics: The 
latest nForce nics support extended ring descriptors with 64-bit dma 
addresses (actual hardware limit: 40 bits)
Could you add the patch to your tree?

Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

--------------050509060201050106010501
Content-Type: text/plain;
 name="patch-forcedeth-039-64bit"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-039-64bit"

--- 2.6/drivers/net/forcedeth.c	2005-07-22 22:29:49.000000000 +0200
+++ build-2.6/drivers/net/forcedeth.c	2005-07-22 22:32:53.000000000 +0200
@@ -89,6 +89,7 @@
  *	0.37: 10 Jul 2005: Additional ethtool support, cleanup of pci id list
  *	0.38: 16 Jul 2005: tx irq rewrite: Use global flags instead of
  *			   per-packet flags.
+ *      0.39: 18 Jul 2005: Add 64bit descriptor support.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -100,7 +101,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.38"
+#define FORCEDETH_VERSION		"0.39"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -138,6 +139,7 @@
 #define DEV_NEED_TIMERIRQ	0x0001  /* set the timer irq flag in the irq mask */
 #define DEV_NEED_LINKTIMER	0x0002	/* poll link settings. Relies on the timer irq */
 #define DEV_HAS_LARGEDESC	0x0004	/* device supports jumbo frames and needs packet format 2 */
+#define DEV_HAS_HIGH_DMA        0x0008  /* device supports 64bit dma */
 
 enum {
 	NvRegIrqStatus = 0x000,
@@ -291,6 +293,18 @@
 	u32 FlagLen;
 };
 
+struct ring_desc_ex {
+	u32 PacketBufferHigh;
+	u32 PacketBufferLow;
+	u32 Reserved;
+	u32 FlagLen;
+};
+
+typedef union _ring_type {
+	struct ring_desc* orig;
+	struct ring_desc_ex* ex;
+} ring_type;
+
 #define FLAG_MASK_V1 0xffff0000
 #define FLAG_MASK_V2 0xffffc000
 #define LEN_MASK_V1 (0xffffffff ^ FLAG_MASK_V1)
@@ -405,6 +419,7 @@
  */
 #define DESC_VER_1	0x0
 #define DESC_VER_2	(0x02100|NVREG_TXRXCTL_RXCHECK)
+#define DESC_VER_3      (0x02200|NVREG_TXRXCTL_RXCHECK)
 
 /* PHY defines */
 #define PHY_OUI_MARVELL	0x5043
@@ -477,7 +492,7 @@
 	/* rx specific fields.
 	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
 	 */
-	struct ring_desc *rx_ring;
+	ring_type rx_ring;
 	unsigned int cur_rx, refill_rx;
 	struct sk_buff *rx_skbuff[RX_RING];
 	dma_addr_t rx_dma[RX_RING];
@@ -494,7 +509,7 @@
 	/*
 	 * tx specific fields.
 	 */
-	struct ring_desc *tx_ring;
+	ring_type tx_ring;
 	unsigned int next_tx, nic_tx;
 	struct sk_buff *tx_skbuff[TX_RING];
 	dma_addr_t tx_dma[TX_RING];
@@ -529,6 +544,11 @@
 		& ((v == DESC_VER_1) ? LEN_MASK_V1 : LEN_MASK_V2);
 }
 
+static inline u32 nv_descr_getlength_ex(struct ring_desc_ex *prd, u32 v)
+{
+	return le32_to_cpu(prd->FlagLen) & LEN_MASK_V2;
+}
+
 static int reg_delay(struct net_device *dev, int offset, u32 mask, u32 target,
 				int delay, int delaymax, const char *msg)
 {
@@ -813,9 +833,16 @@
 		}
 		np->rx_dma[nr] = pci_map_single(np->pci_dev, skb->data, skb->len,
 						PCI_DMA_FROMDEVICE);
-		np->rx_ring[nr].PacketBuffer = cpu_to_le32(np->rx_dma[nr]);
-		wmb();
-		np->rx_ring[nr].FlagLen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+			np->rx_ring.orig[nr].PacketBuffer = cpu_to_le32(np->rx_dma[nr]);
+			wmb();
+			np->rx_ring.orig[nr].FlagLen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
+		} else {
+			np->rx_ring.ex[nr].PacketBufferHigh = cpu_to_le64(np->rx_dma[nr]) >> 32;
+			np->rx_ring.ex[nr].PacketBufferLow = cpu_to_le64(np->rx_dma[nr]) & 0x0FFFFFFFF;
+			wmb();
+			np->rx_ring.ex[nr].FlagLen = cpu_to_le32(np->rx_buf_sz | NV_RX2_AVAIL);
+		}
 		dprintk(KERN_DEBUG "%s: nv_alloc_rx: Packet %d marked as Available\n",
 					dev->name, refill_rx);
 		refill_rx++;
@@ -849,7 +876,10 @@
 	np->cur_rx = RX_RING;
 	np->refill_rx = 0;
 	for (i = 0; i < RX_RING; i++)
-		np->rx_ring[i].FlagLen = 0;
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+			np->rx_ring.orig[i].FlagLen = 0;
+	        else
+			np->rx_ring.ex[i].FlagLen = 0;
 }
 
 static void nv_init_tx(struct net_device *dev)
@@ -859,7 +889,10 @@
 
 	np->next_tx = np->nic_tx = 0;
 	for (i = 0; i < TX_RING; i++)
-		np->tx_ring[i].FlagLen = 0;
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+			np->tx_ring.orig[i].FlagLen = 0;
+	        else
+			np->tx_ring.ex[i].FlagLen = 0;
 }
 
 static int nv_init_ring(struct net_device *dev)
@@ -874,7 +907,10 @@
 	struct fe_priv *np = get_nvpriv(dev);
 	int i;
 	for (i = 0; i < TX_RING; i++) {
-		np->tx_ring[i].FlagLen = 0;
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+			np->tx_ring.orig[i].FlagLen = 0;
+		else
+			np->tx_ring.ex[i].FlagLen = 0;
 		if (np->tx_skbuff[i]) {
 			pci_unmap_single(np->pci_dev, np->tx_dma[i],
 						np->tx_skbuff[i]->len,
@@ -891,7 +927,10 @@
 	struct fe_priv *np = get_nvpriv(dev);
 	int i;
 	for (i = 0; i < RX_RING; i++) {
-		np->rx_ring[i].FlagLen = 0;
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+			np->rx_ring.orig[i].FlagLen = 0;
+		else
+			np->rx_ring.ex[i].FlagLen = 0;
 		wmb();
 		if (np->rx_skbuff[i]) {
 			pci_unmap_single(np->pci_dev, np->rx_dma[i],
@@ -922,11 +961,19 @@
 	np->tx_dma[nr] = pci_map_single(np->pci_dev, skb->data,skb->len,
 					PCI_DMA_TODEVICE);
 
-	np->tx_ring[nr].PacketBuffer = cpu_to_le32(np->tx_dma[nr]);
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		np->tx_ring.orig[nr].PacketBuffer = cpu_to_le32(np->tx_dma[nr]);
+	else {
+		np->tx_ring.ex[nr].PacketBufferHigh = cpu_to_le64(np->tx_dma[nr]) >> 32;
+		np->tx_ring.ex[nr].PacketBufferLow = cpu_to_le64(np->tx_dma[nr]) & 0x0FFFFFFFF;
+	}
 
 	spin_lock_irq(&np->lock);
 	wmb();
-	np->tx_ring[nr].FlagLen = cpu_to_le32( (skb->len-1) | np->tx_flags );
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		np->tx_ring.orig[nr].FlagLen = cpu_to_le32( (skb->len-1) | np->tx_flags );
+	else
+		np->tx_ring.ex[nr].FlagLen = cpu_to_le32( (skb->len-1) | np->tx_flags );
 	dprintk(KERN_DEBUG "%s: nv_start_xmit: packet packet %d queued for transmission.\n",
 				dev->name, np->next_tx);
 	{
@@ -964,7 +1011,10 @@
 	while (np->nic_tx != np->next_tx) {
 		i = np->nic_tx % TX_RING;
 
-		Flags = le32_to_cpu(np->tx_ring[i].FlagLen);
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+			Flags = le32_to_cpu(np->tx_ring.orig[i].FlagLen);
+		else
+			Flags = le32_to_cpu(np->tx_ring.ex[i].FlagLen);
 
 		dprintk(KERN_DEBUG "%s: nv_tx_done: looking at packet %d, Flags 0x%x.\n",
 					dev->name, np->nic_tx, Flags);
@@ -1035,16 +1085,33 @@
 		}
 		printk(KERN_INFO "%s: Dumping tx ring\n", dev->name);
 		for (i=0;i<TX_RING;i+= 4) {
-			printk(KERN_INFO "%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
-					i, 
-					le32_to_cpu(np->tx_ring[i].PacketBuffer),
-					le32_to_cpu(np->tx_ring[i].FlagLen),
-					le32_to_cpu(np->tx_ring[i+1].PacketBuffer),
-					le32_to_cpu(np->tx_ring[i+1].FlagLen),
-					le32_to_cpu(np->tx_ring[i+2].PacketBuffer),
-					le32_to_cpu(np->tx_ring[i+2].FlagLen),
-					le32_to_cpu(np->tx_ring[i+3].PacketBuffer),
-					le32_to_cpu(np->tx_ring[i+3].FlagLen));
+			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+				printk(KERN_INFO "%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
+				       i, 
+				       le32_to_cpu(np->tx_ring.orig[i].PacketBuffer),
+				       le32_to_cpu(np->tx_ring.orig[i].FlagLen),
+				       le32_to_cpu(np->tx_ring.orig[i+1].PacketBuffer),
+				       le32_to_cpu(np->tx_ring.orig[i+1].FlagLen),
+				       le32_to_cpu(np->tx_ring.orig[i+2].PacketBuffer),
+				       le32_to_cpu(np->tx_ring.orig[i+2].FlagLen),
+				       le32_to_cpu(np->tx_ring.orig[i+3].PacketBuffer),
+				       le32_to_cpu(np->tx_ring.orig[i+3].FlagLen));
+			} else {
+				printk(KERN_INFO "%03x: %08x %08x %08x // %08x %08x %08x // %08x %08x %08x // %08x %08x %08x\n",
+				       i, 
+				       le32_to_cpu(np->tx_ring.ex[i].PacketBufferHigh),
+				       le32_to_cpu(np->tx_ring.ex[i].PacketBufferLow),
+				       le32_to_cpu(np->tx_ring.ex[i].FlagLen),
+				       le32_to_cpu(np->tx_ring.ex[i+1].PacketBufferHigh),
+				       le32_to_cpu(np->tx_ring.ex[i+1].PacketBufferLow),
+				       le32_to_cpu(np->tx_ring.ex[i+1].FlagLen),
+				       le32_to_cpu(np->tx_ring.ex[i+2].PacketBufferHigh),
+				       le32_to_cpu(np->tx_ring.ex[i+2].PacketBufferLow),
+				       le32_to_cpu(np->tx_ring.ex[i+2].FlagLen),
+				       le32_to_cpu(np->tx_ring.ex[i+3].PacketBufferHigh),
+				       le32_to_cpu(np->tx_ring.ex[i+3].PacketBufferLow),
+				       le32_to_cpu(np->tx_ring.ex[i+3].FlagLen));
+			}
 		}
 	}
 
@@ -1061,7 +1128,10 @@
 		printk(KERN_DEBUG "%s: tx_timeout: dead entries!\n", dev->name);
 		nv_drain_tx(dev);
 		np->next_tx = np->nic_tx = 0;
-		writel((u32) (np->ring_addr + RX_RING*sizeof(struct ring_desc)), base + NvRegTxRingPhysAddr);
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+			writel((u32) (np->ring_addr + RX_RING*sizeof(struct ring_desc)), base + NvRegTxRingPhysAddr);
+		else
+			writel((u32) (np->ring_addr + RX_RING*sizeof(struct ring_desc_ex)), base + NvRegTxRingPhysAddr);
 		netif_wake_queue(dev);
 	}
 
@@ -1136,8 +1206,13 @@
 			break;	/* we scanned the whole ring - do not continue */
 
 		i = np->cur_rx % RX_RING;
-		Flags = le32_to_cpu(np->rx_ring[i].FlagLen);
-		len = nv_descr_getlength(&np->rx_ring[i], np->desc_ver);
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+			Flags = le32_to_cpu(np->rx_ring.orig[i].FlagLen);
+			len = nv_descr_getlength(&np->rx_ring.orig[i], np->desc_ver);
+		} else {
+			Flags = le32_to_cpu(np->rx_ring.ex[i].FlagLen);
+			len = nv_descr_getlength_ex(&np->rx_ring.ex[i], np->desc_ver);
+		}
 
 		dprintk(KERN_DEBUG "%s: nv_rx_process: looking at packet %d, Flags 0x%x.\n",
 					dev->name, np->cur_rx, Flags);
@@ -1321,7 +1396,10 @@
 		/* reinit nic view of the rx queue */
 		writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 		writel((u32) np->ring_addr, base + NvRegRxRingPhysAddr);
-		writel((u32) (np->ring_addr + RX_RING*sizeof(struct ring_desc)), base + NvRegTxRingPhysAddr);
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+			writel((u32) (np->ring_addr + RX_RING*sizeof(struct ring_desc)), base + NvRegTxRingPhysAddr);
+		else
+			writel((u32) (np->ring_addr + RX_RING*sizeof(struct ring_desc_ex)), base + NvRegTxRingPhysAddr);
 		writel( ((RX_RING-1) << NVREG_RINGSZ_RXSHIFT) + ((TX_RING-1) << NVREG_RINGSZ_TXSHIFT),
 			base + NvRegRingSizes);
 		pci_push(base);
@@ -1982,7 +2060,10 @@
 
 	/* 4) give hw rings */
 	writel((u32) np->ring_addr, base + NvRegRxRingPhysAddr);
-	writel((u32) (np->ring_addr + RX_RING*sizeof(struct ring_desc)), base + NvRegTxRingPhysAddr);
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		writel((u32) (np->ring_addr + RX_RING*sizeof(struct ring_desc)), base + NvRegTxRingPhysAddr);
+	else
+		writel((u32) (np->ring_addr + RX_RING*sizeof(struct ring_desc_ex)), base + NvRegTxRingPhysAddr);
 	writel( ((RX_RING-1) << NVREG_RINGSZ_RXSHIFT) + ((TX_RING-1) << NVREG_RINGSZ_TXSHIFT),
 		base + NvRegRingSizes);
 
@@ -2179,18 +2260,38 @@
 		np->desc_ver = DESC_VER_2;
 		np->pkt_limit = NV_PKTLIMIT_2;
 	}
+	if (id->driver_data & DEV_HAS_HIGH_DMA) {
+		np->desc_ver = DESC_VER_3;
+		dev->features |= NETIF_F_HIGHDMA;
+		if (pci_set_dma_mask(pci_dev, 0x0000007fffffffffULL)) {
+			if (pci_set_dma_mask(pci_dev, 0xffffffffULL))
+				goto out_relreg;
+		}
+	}
 
 	err = -ENOMEM;
 	np->base = ioremap(addr, NV_PCI_REGSZ);
 	if (!np->base)
 		goto out_relreg;
 	dev->base_addr = (unsigned long)np->base;
+
 	dev->irq = pci_dev->irq;
-	np->rx_ring = pci_alloc_consistent(pci_dev, sizeof(struct ring_desc) * (RX_RING + TX_RING),
-						&np->ring_addr);
-	if (!np->rx_ring)
-		goto out_unmap;
-	np->tx_ring = &np->rx_ring[RX_RING];
+
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+		np->rx_ring.orig = pci_alloc_consistent(pci_dev,
+					sizeof(struct ring_desc) * (RX_RING + TX_RING),
+					&np->ring_addr);
+		if (!np->rx_ring.orig)
+			goto out_unmap;
+		np->tx_ring.orig = &np->rx_ring.orig[RX_RING];
+	} else {
+		np->rx_ring.ex = pci_alloc_consistent(pci_dev,
+					sizeof(struct ring_desc_ex) * (RX_RING + TX_RING),
+					&np->ring_addr);
+		if (!np->rx_ring.ex)
+			goto out_unmap;
+		np->tx_ring.ex = &np->rx_ring.ex[RX_RING];
+	}
 
 	dev->open = nv_open;
 	dev->stop = nv_close;
@@ -2313,8 +2414,12 @@
 	return 0;
 
 out_freering:
-	pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (RX_RING + TX_RING),
-				np->rx_ring, np->ring_addr);
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (RX_RING + TX_RING),
+				    np->rx_ring.orig, np->ring_addr);
+	else
+		pci_free_consistent(np->pci_dev, sizeof(struct ring_desc_ex) * (RX_RING + TX_RING),
+				    np->rx_ring.ex, np->ring_addr);
 	pci_set_drvdata(pci_dev, NULL);
 out_unmap:
 	iounmap(get_hwbase(dev));
@@ -2343,7 +2448,10 @@
 	writel(np->orig_mac[1], base + NvRegMacAddrB);
 
 	/* free all structures */
-	pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (RX_RING + TX_RING), np->rx_ring, np->ring_addr);
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (RX_RING + TX_RING), np->rx_ring.orig, np->ring_addr);
+	else
+		pci_free_consistent(np->pci_dev, sizeof(struct ring_desc_ex) * (RX_RING + TX_RING), np->rx_ring.ex, np->ring_addr);
 	iounmap(get_hwbase(dev));
 	pci_release_regions(pci_dev);
 	pci_disable_device(pci_dev);
@@ -2382,35 +2490,35 @@
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_8),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
 	},
 	{	/* CK804 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_9),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_10),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
 	},
 	{	/* MCP04 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_11),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
 	},
 	{	/* MCP51 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_12),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA,
 	},
 	{	/* MCP51 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_13),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_14),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
 	},
 	{	/* MCP55 Ethernet Controller */
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_15),
-		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC,
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_HIGH_DMA,
 	},
 	{0,},
 };

--------------050509060201050106010501--
