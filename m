From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 2.6.0 - r8169 64 bit
Date: Sat, 20 Dec 2003 02:09:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031220020946.A4594@electric-eye.fr.zoreil.com>
References: <20031219233231.A2420@electric-eye.fr.zoreil.com> <20031220011718.A2442@electric-eye.fr.zoreil.com> <20031220014307.B2442@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031220014307.B2442@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Dec 20, 2003 at 01:43:07AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]

Oops, bad patch. Correct version below.


- 64bit/DAC update;
- provide a decent return status when power state detection fails.


 drivers/net/r8169.c |  100 ++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 77 insertions(+), 23 deletions(-)

diff -puN drivers/net/r8169.c~r8169-addr-high drivers/net/r8169.c
--- linux-2.6.0-vanilla/drivers/net/r8169.c~r8169-addr-high	2003-12-18 23:01:09.000000000 +0100
+++ linux-2.6.0-vanilla-fr/drivers/net/r8169.c	2003-12-20 02:02:03.000000000 +0100
@@ -148,8 +148,10 @@ static int rx_copybreak = 200;
 enum RTL8169_registers {
 	MAC0 = 0,		/* Ethernet hardware address. */
 	MAR0 = 8,		/* Multicast filter. */
-	TxDescStartAddr = 0x20,
-	TxHDescStartAddr = 0x28,
+	TxDescStdPrioAddrLow = 0x20,
+	TxDescStdPrioAddrHigh = 0x24,
+	TxDescHighPrioAddrLow = 0x28,
+	TxDescHighPrioAddrHigh = 0x2C,
 	FLASH = 0x30,
 	ERSR = 0x36,
 	ChipCmd = 0x37,
@@ -174,7 +176,8 @@ enum RTL8169_registers {
 	PHYstatus = 0x6C,
 	RxMaxSize = 0xDA,
 	CPlusCmd = 0xE0,
-	RxDescStartAddr = 0xE4,
+	RxDescAddrLow = 0xE4,
+	RxDescAddrHigh = 0xE8,
 	EarlyTxThres = 0xEC,
 	FuncEvent = 0xF0,
 	FuncEventMask = 0xF4,
@@ -227,6 +230,11 @@ enum RTL8169_register_content {
 	/*TxConfigBits */
 	TxInterFrameGapShift = 24,
 	TxDMAShift = 8,		/* DMA burst value (0-7) is shift this many bits */
+	/*CPlusCmd p.31 */
+	RxVlan		= (1 << 6),
+	RxChkSum	= (1 << 5),
+	DAC		= (1 << 4),
+	MulRW		= (1 << 3),
 
 	/*rtl8169_PHYstatus */
 	TBI_Enable = 0x80,
@@ -345,6 +353,16 @@ static const unsigned int rtl8169_rx_con
 #define PHY_Cap_100_Half_Or_Less PHY_Cap_100_Half | PHY_Cap_10_Full_Or_Less
 #define PHY_Cap_100_Full_Or_Less PHY_Cap_100_Full | PHY_Cap_100_Half_Or_Less
 
+#define rtl8169_set_desc_addr(desc,addr) \
+	do { \
+		desc->buf_addr = cpu_to_le32((u64)addr & 0xffffffff); \
+		desc->buf_Haddr = cpu_to_le32((u64)addr >> 32); \
+	} while (0)
+
+#define rtl8169_get_dma_addr(desc) \
+	(((u64)le32_to_cpu(desc->buf_Haddr) << 32) | \
+		le32_to_cpu(desc->buf_addr))
+
 void
 mdio_write(void *ioaddr, int RegAddr, int value)
 {
@@ -628,6 +646,29 @@ static inline void rtl8169_request_timer
 	add_timer(timer);
 }
 
+static inline int rtl8169_configure_dma_attributes(struct pci_dev *pdev,
+						   struct net_device *dev)
+{
+	int rc;
+
+	rc = pci_set_dma_mask(pdev, 0xffffffffffffffffULL);
+	if (!rc) {
+		rc = pci_set_consistent_dma_mask(pdev, 0xffffffffffffffffULL);
+		if (rc < 0) {
+			printk(KERN_ERR PFX "Unable to obtain 64 bit DMA "
+			       "for consistent allocations\n");
+		} else
+			dev->features |= NETIF_F_HIGHDMA;
+
+	} else {
+		rc = pci_set_dma_mask(pdev, 0xffffffffULL);
+		if (rc < 0)
+			printk(KERN_ERR PFX "No usable DMA configuration, "
+			       "aborting.\n");
+	}
+	return rc;
+}
+
 static int __devinit
 rtl8169_init_board(struct pci_dev *pdev, struct net_device **dev_out,
 		   void **ioaddr_out)
@@ -663,6 +704,8 @@ rtl8169_init_board(struct pci_dev *pdev,
 		goto err_out;
 	}
 
+	rc = -ENODEV;
+
 	/* save power state before pci_enable_device overwrites it */
 	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
 	if (pm_cap) {
@@ -684,13 +727,11 @@ rtl8169_init_board(struct pci_dev *pdev,
 	if (!(mmio_flags & IORESOURCE_MEM)) {
 		printk(KERN_ERR PFX
 		       "region #1 not an MMIO resource, aborting\n");
-		rc = -ENODEV;
 		goto err_out_disable;
 	}
 	// check for weird/broken PCI region reporting
 	if (mmio_len < RTL_MIN_IO_SIZE) {
 		printk(KERN_ERR PFX "Invalid PCI region size(s), aborting\n");
-		rc = -ENODEV;
 		goto err_out_disable;
 	}
 
@@ -700,6 +741,10 @@ rtl8169_init_board(struct pci_dev *pdev,
 		goto err_out_disable;
 	}
 
+	rc = rtl8169_configure_dma_attributes(pdev, dev);
+	if (rc < 0)
+		goto err_out_free_res;
+
 	// enable PCI bus-mastering
 	pci_set_master(pdev);
 
@@ -1085,7 +1130,8 @@ rtl8169_hw_start(struct net_device *dev)
 	RTL_W32(TxConfig,
 		(TX_DMA_BURST << TxDMAShift) | (InterFrameGap <<
 						TxInterFrameGapShift));
-	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd));
+	RTL_W16(CPlusCmd, ((dev->features & NETIF_F_HIGHDMA) ? DAC : 0) |
+			  RTL_R16(CPlusCmd));
 
 	if (tp->mac_version == RTL_GIGA_MAC_VER_D) {
 		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0: bit-3 and bit-14 MUST be 1\n");
@@ -1094,8 +1140,10 @@ rtl8169_hw_start(struct net_device *dev)
 
 	tp->cur_rx = 0;
 
-	RTL_W32(TxDescStartAddr, tp->TxPhyAddr);
-	RTL_W32(RxDescStartAddr, tp->RxPhyAddr);
+	RTL_W32(TxDescStdPrioAddrLow, (u64) tp->TxPhyAddr & 0xffffffff);
+	RTL_W32(TxDescStdPrioAddrHigh, (u64) tp->TxPhyAddr >> 32);
+	RTL_W32(RxDescAddrLow, (u64) tp->RxPhyAddr & 0xffffffff);
+	RTL_W32(RxDescAddrHigh, (u64) tp->RxPhyAddr >> 32);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 	udelay(10);
 
@@ -1115,15 +1163,17 @@ rtl8169_hw_start(struct net_device *dev)
 
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
-	desc->buf_addr = 0xdeadbeef;
+	rtl8169_set_desc_addr(desc, 0xdeadbeefdeadbeef);
 	desc->status &= ~cpu_to_le32(OWNbit | RsvdMask);
 }
 
 static void rtl8169_free_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
 				struct RxDesc *desc)
 {
-	pci_unmap_single(pdev, le32_to_cpu(desc->buf_addr), RX_BUF_SIZE,
-			 PCI_DMA_FROMDEVICE);
+	dma_addr_t mapping;
+
+	mapping = rtl8169_get_dma_addr(desc);
+	pci_unmap_single(pdev, mapping, RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
 	dev_kfree_skb(*sk_buff);
 	*sk_buff = NULL;
 	rtl8169_make_unusable_by_asic(desc);
@@ -1136,7 +1186,7 @@ static inline void rtl8169_return_to_asi
 
 static inline void rtl8169_give_to_asic(struct RxDesc *desc, dma_addr_t mapping)
 {
-	desc->buf_addr = cpu_to_le32(mapping);
+	rtl8169_set_desc_addr(desc, mapping);
 	desc->status |= cpu_to_le32(OWNbit + RX_BUF_SIZE);
 }
 
@@ -1233,10 +1283,12 @@ static void rtl8169_unmap_tx_skb(struct 
 				 struct TxDesc *desc)
 {
 	u32 len = sk_buff[0]->len;
+	dma_addr_t mapping;
 
-	pci_unmap_single(pdev, le32_to_cpu(desc->buf_addr),
-			 len < ETH_ZLEN ? ETH_ZLEN : len, PCI_DMA_TODEVICE);
-	desc->buf_addr = 0x00;
+	mapping = rtl8169_get_dma_addr(desc);
+	pci_unmap_single(pdev, mapping, len < ETH_ZLEN ? ETH_ZLEN : len,
+			 PCI_DMA_TODEVICE);
+	rtl8169_set_desc_addr(desc, 0x00);
 	*sk_buff = NULL;
 }
 
@@ -1290,6 +1342,7 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 	struct rtl8169_private *tp = dev->priv;
 	void *ioaddr = tp->mmio_addr;
 	int entry = tp->cur_tx % NUM_TX_DESC;
+	struct TxDesc *desc = tp->TxDescArray + entry;
 	u32 len = skb->len;
 
 	if (unlikely(skb->len < ETH_ZLEN)) {
@@ -1301,17 +1354,17 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 	
 	spin_lock_irq(&tp->lock);
 
-	if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
+	if (!(le32_to_cpu(desc->status) & OWNbit)) {
 		dma_addr_t mapping;
 
 		mapping = pci_map_single(tp->pci_dev, skb->data, len,
 					 PCI_DMA_TODEVICE);
 
 		tp->Tx_skbuff[entry] = skb;
-		tp->TxDescArray[entry].buf_addr = cpu_to_le32(mapping);
+		rtl8169_set_desc_addr(desc, mapping);
 
-		tp->TxDescArray[entry].status = cpu_to_le32(OWNbit | FSbit |
-			LSbit | len | (EORbit * !((entry + 1) % NUM_TX_DESC)));
+		desc->status = cpu_to_le32(OWNbit | FSbit | LSbit | len |
+			(EORbit * !((entry + 1) % NUM_TX_DESC)));
 			
 		RTL_W8(TxPoll, 0x40);	//set polling bit
 
@@ -1424,14 +1477,15 @@ rtl8169_rx_interrupt(struct net_device *
 			struct RxDesc *desc = tp->RxDescArray + cur_rx;
 			struct sk_buff *skb = tp->Rx_skbuff[cur_rx];
 			int pkt_size = (status & 0x00001FFF) - 4;
+			dma_addr_t mapping;
 
-			pci_dma_sync_single(tp->pci_dev,
-					    le32_to_cpu(desc->buf_addr),
-					    RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			mapping = rtl8169_get_dma_addr(desc);
+			pci_dma_sync_single(tp->pci_dev, mapping, RX_BUF_SIZE,
+					    PCI_DMA_FROMDEVICE);
 
 			if (rtl8169_try_rx_copy(&skb, pkt_size, desc, dev)) {
 				pci_unmap_single(tp->pci_dev,
-						 le32_to_cpu(desc->buf_addr),
+						 le32_to_cpu(mapping),
 						 RX_BUF_SIZE,
 						 PCI_DMA_FROMDEVICE);
 				tp->Rx_skbuff[cur_rx] = NULL;

_
