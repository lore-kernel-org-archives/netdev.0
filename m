From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 30/34] dl2k: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Thu, 15 Mar 2012 14:57:27 +0100
Message-ID: <4d00a4ed99e4951226860ff1580a8e507858f332.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51872 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754421Ab2CON7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:51 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The eeprom registers always use the same PCI bar whereas the general
registers may either use the same mapping as the eeprom registers or
a different one. It is thus possible to simplify parse_eeprom().

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/dlink/dl2k.c |  158 ++++++++++++++++++-------------------
 drivers/net/ethernet/dlink/dl2k.h |   25 ++----
 2 files changed, 85 insertions(+), 98 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index b2dc2c8..7248cfb 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -73,7 +73,7 @@ static int rio_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
 static int rio_close (struct net_device *dev);
 static int find_miiphy (struct net_device *dev);
 static int parse_eeprom (struct net_device *dev);
-static int read_eeprom (long ioaddr, int eep_addr);
+static int read_eeprom (struct netdev_private *, int eep_addr);
 static int mii_wait_link (struct net_device *dev, int wait);
 static int mii_set_media (struct net_device *dev);
 static int mii_get_media (struct net_device *dev);
@@ -106,7 +106,7 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	static int card_idx;
 	int chip_idx = ent->driver_data;
 	int err, irq;
-	long ioaddr;
+	void __iomem *ioaddr;
 	static int version_printed;
 	void *ring_space;
 	dma_addr_t ring_dma;
@@ -124,26 +124,29 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_disable;
 
 	pci_set_master (pdev);
+
+	err = -ENOMEM;
+
 	dev = alloc_etherdev (sizeof (*np));
-	if (!dev) {
-		err = -ENOMEM;
+	if (!dev)
 		goto err_out_res;
-	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-#ifdef MEM_MAPPING
-	ioaddr = pci_resource_start (pdev, 1);
-	ioaddr = (long) ioremap (ioaddr, RIO_IO_SIZE);
-	if (!ioaddr) {
-		err = -ENOMEM;
+	np = netdev_priv(dev);
+
+	/* IO registers range. */
+	ioaddr = pci_iomap(pdev, 0, 0);
+	if (!ioaddr)
 		goto err_out_dev;
-	}
-#else
-	ioaddr = pci_resource_start (pdev, 0);
+	np->eeprom_addr = ioaddr;
+
+#ifdef MEM_MAPPING
+	/* MM registers range. */
+	ioaddr = pci_iomap(pdev, 1, 0);
+	if (!ioaddr)
+		goto err_out_iounmap;
 #endif
-	dev->base_addr = ioaddr;
-	dev->irq = irq;
-	np = netdev_priv(dev);
+	np->ioaddr = ioaddr;
 	np->chip_id = chip_idx;
 	np->pdev = pdev;
 	spin_lock_init (&np->tx_lock);
@@ -276,22 +279,20 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 		printk(KERN_INFO "vlan(id):\t%d\n", np->vlan);
 	return 0;
 
-      err_out_unmap_rx:
+err_out_unmap_rx:
 	pci_free_consistent (pdev, RX_TOTAL_SIZE, np->rx_ring, np->rx_ring_dma);
-      err_out_unmap_tx:
+err_out_unmap_tx:
 	pci_free_consistent (pdev, TX_TOTAL_SIZE, np->tx_ring, np->tx_ring_dma);
-      err_out_iounmap:
+err_out_iounmap:
 #ifdef MEM_MAPPING
-	iounmap ((void *) ioaddr);
-
-      err_out_dev:
+	pci_iounmap(pdev, np->ioaddr);
 #endif
+	pci_iounmap(pdev, np->eeprom_addr);
+err_out_dev:
 	free_netdev (dev);
-
-      err_out_res:
+err_out_res:
 	pci_release_regions (pdev);
-
-      err_out_disable:
+err_out_disable:
 	pci_disable_device (pdev);
 	return err;
 }
@@ -299,11 +300,9 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 static int
 find_miiphy (struct net_device *dev)
 {
+	struct netdev_private *np = netdev_priv(dev);
 	int i, phy_found = 0;
-	struct netdev_private *np;
-	long ioaddr;
 	np = netdev_priv(dev);
-	ioaddr = dev->base_addr;
 	np->phy_addr = 1;
 
 	for (i = 31; i >= 0; i--) {
@@ -323,26 +322,19 @@ find_miiphy (struct net_device *dev)
 static int
 parse_eeprom (struct net_device *dev)
 {
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 	int i, j;
-	long ioaddr = dev->base_addr;
 	u8 sromdata[256];
 	u8 *psib;
 	u32 crc;
 	PSROM_t psrom = (PSROM_t) sromdata;
-	struct netdev_private *np = netdev_priv(dev);
 
 	int cid, next;
 
-#ifdef	MEM_MAPPING
-	ioaddr = pci_resource_start (np->pdev, 0);
-#endif
-	/* Read eeprom */
-	for (i = 0; i < 128; i++) {
-		((__le16 *) sromdata)[i] = cpu_to_le16(read_eeprom (ioaddr, i));
-	}
-#ifdef	MEM_MAPPING
-	ioaddr = dev->base_addr;
-#endif
+	for (i = 0; i < 128; i++)
+		((__le16 *) sromdata)[i] = cpu_to_le16(read_eeprom(np, i));
+
 	if (np->pdev->vendor == PCI_VENDOR_ID_DLINK) {	/* D-Link Only */
 		/* Check CRC */
 		crc = ~ether_crc_le (256 - 4, sromdata);
@@ -407,11 +399,12 @@ static int
 rio_open (struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = np->ioaddr;
+	const int irq = np->pdev->irq;
 	int i;
 	u16 macctrl;
 
-	i = request_irq (dev->irq, rio_interrupt, IRQF_SHARED, dev->name, dev);
+	i = request_irq(irq, rio_interrupt, IRQF_SHARED, dev->name, dev);
 	if (i)
 		return i;
 
@@ -533,7 +526,8 @@ rio_timer (unsigned long data)
 static void
 rio_tx_timeout (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 
 	printk (KERN_INFO "%s: Tx timed out (%4.4x), is buffer full?\n",
 		dev->name, readl (ioaddr + TxStatus));
@@ -547,6 +541,7 @@ static void
 alloc_list (struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 	int i;
 
 	np->cur_rx = np->cur_tx = 0;
@@ -594,24 +589,23 @@ alloc_list (struct net_device *dev)
 	}
 
 	/* Set RFDListPtr */
-	writel (np->rx_ring_dma, dev->base_addr + RFDListPtr0);
-	writel (0, dev->base_addr + RFDListPtr1);
+	writel (np->rx_ring_dma, ioaddr + RFDListPtr0);
+	writel (0, ioaddr + RFDListPtr1);
 }
 
 static netdev_tx_t
 start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 	struct netdev_desc *txdesc;
 	unsigned entry;
-	u32 ioaddr;
 	u64 tfc_vlan_tag = 0;
 
 	if (np->link_status == 0) {	/* Link Down */
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	ioaddr = dev->base_addr;
 	entry = np->cur_tx % TX_RING_SIZE;
 	np->tx_skbuff[entry] = skb;
 	txdesc = &np->tx_ring[entry];
@@ -658,10 +652,10 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* The first TFDListPtr */
-	if (readl (dev->base_addr + TFDListPtr0) == 0) {
+	if (readl (ioaddr + TFDListPtr0) == 0) {
 		writel (np->tx_ring_dma + entry * sizeof (struct netdev_desc),
-			dev->base_addr + TFDListPtr0);
-		writel (0, dev->base_addr + TFDListPtr1);
+			ioaddr + TFDListPtr0);
+		writel (0, ioaddr + TFDListPtr1);
 	}
 
 	return NETDEV_TX_OK;
@@ -671,14 +665,12 @@ static irqreturn_t
 rio_interrupt (int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
-	struct netdev_private *np;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 	unsigned int_status;
-	long ioaddr;
 	int cnt = max_intrloop;
 	int handled = 0;
 
-	ioaddr = dev->base_addr;
-	np = netdev_priv(dev);
 	while (1) {
 		int_status = readw (ioaddr + IntStatus);
 		writew (int_status, ioaddr + IntStatus);
@@ -765,13 +757,11 @@ rio_free_tx (struct net_device *dev, int irq)
 static void
 tx_error (struct net_device *dev, int tx_status)
 {
-	struct netdev_private *np;
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 	int frame_id;
 	int i;
 
-	np = netdev_priv(dev);
-
 	frame_id = (tx_status & 0xffff0000);
 	printk (KERN_ERR "%s: Transmit error, TxStatus %4.4x, FrameId %d.\n",
 		dev->name, tx_status, frame_id);
@@ -794,8 +784,8 @@ tx_error (struct net_device *dev, int tx_status)
 		/* Reset TFDListPtr */
 		writel (np->tx_ring_dma +
 			np->old_tx * sizeof (struct netdev_desc),
-			dev->base_addr + TFDListPtr0);
-		writel (0, dev->base_addr + TFDListPtr1);
+			ioaddr + TFDListPtr0);
+		writel (0, ioaddr + TFDListPtr1);
 
 		/* Let TxStartThresh stay default value */
 	}
@@ -821,7 +811,7 @@ tx_error (struct net_device *dev, int tx_status)
 		np->stats.collisions++;
 #endif
 	/* Restart the Tx */
-	writel (readw (dev->base_addr + MACCtrl) | TxEnable, ioaddr + MACCtrl);
+	writel(readw(ioaddr + MACCtrl) | TxEnable, ioaddr + MACCtrl);
 }
 
 static int
@@ -931,8 +921,8 @@ receive_packet (struct net_device *dev)
 static void
 rio_error (struct net_device *dev, int int_status)
 {
-	long ioaddr = dev->base_addr;
 	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 	u16 macctrl;
 
 	/* Link change event */
@@ -982,8 +972,8 @@ rio_error (struct net_device *dev, int int_status)
 static struct net_device_stats *
 get_stats (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 #ifdef MEM_MAPPING
 	int i;
 #endif
@@ -1044,7 +1034,8 @@ get_stats (struct net_device *dev)
 static int
 clear_stats (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 #ifdef MEM_MAPPING
 	int i;
 #endif
@@ -1114,10 +1105,10 @@ change_mtu (struct net_device *dev, int new_mtu)
 static void
 set_multicast (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 	u32 hash_table[2];
 	u16 rx_mode = 0;
-	struct netdev_private *np = netdev_priv(dev);
 
 	hash_table[0] = hash_table[1] = 0;
 	/* RxFlowcontrol DA: 01-80-C2-00-00-01. Hash index=0x39 */
@@ -1318,15 +1309,15 @@ rio_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 #define EEP_BUSY 0x8000
 /* Read the EEPROM word */
 /* We use I/O instruction to read/write eeprom to avoid fail on some machines */
-static int
-read_eeprom (long ioaddr, int eep_addr)
+static int read_eeprom(struct netdev_private *np, int eep_addr)
 {
+	void __iomem *ioaddr = np->eeprom_addr;
 	int i = 1000;
-	outw (EEP_READ | (eep_addr & 0xff), ioaddr + EepromCtrl);
+
+	writew(EEP_READ | (eep_addr & 0xff), ioaddr + EepromCtrl);
 	while (i-- > 0) {
-		if (!(inw (ioaddr + EepromCtrl) & EEP_BUSY)) {
-			return inw (ioaddr + EepromData);
-		}
+		if (!(readw(ioaddr + EepromCtrl) & EEP_BUSY))
+			return readw(ioaddr + EepromData);
 	}
 	return 0;
 }
@@ -1340,7 +1331,9 @@ enum phy_ctrl_bits {
 static void
 mii_sendbit (struct net_device *dev, u32 data)
 {
-	long ioaddr = dev->base_addr + PhyCtrl;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr + PhyCtrl;
+
 	data = (data) ? MII_DATA1 : 0;
 	data |= MII_WRITE;
 	data |= (readb (ioaddr) & 0xf8) | MII_WRITE;
@@ -1353,7 +1346,8 @@ mii_sendbit (struct net_device *dev, u32 data)
 static int
 mii_getbit (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr + PhyCtrl;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr + PhyCtrl;
 	u8 data;
 
 	data = (readb (ioaddr) & 0xf8) | MII_READ;
@@ -1721,8 +1715,9 @@ mii_set_media_pcs (struct net_device *dev)
 static int
 rio_close (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
+	struct pci_dev *pdev = np->pdev;
 	struct sk_buff *skb;
 	int i;
 
@@ -1734,15 +1729,14 @@ rio_close (struct net_device *dev)
 	/* Stop Tx and Rx logics */
 	writel (TxDisable | RxDisable | StatsDisable, ioaddr + MACCtrl);
 
-	free_irq (dev->irq, dev);
+	free_irq(pdev->irq, dev);
 	del_timer_sync (&np->timer);
 
 	/* Free all the skbuffs in the queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		skb = np->rx_skbuff[i];
 		if (skb) {
-			pci_unmap_single(np->pdev,
-					 desc_to_dma(&np->rx_ring[i]),
+			pci_unmap_single(pdev, desc_to_dma(&np->rx_ring[i]),
 					 skb->len, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb (skb);
 			np->rx_skbuff[i] = NULL;
@@ -1753,8 +1747,7 @@ rio_close (struct net_device *dev)
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		skb = np->tx_skbuff[i];
 		if (skb) {
-			pci_unmap_single(np->pdev,
-					 desc_to_dma(&np->tx_ring[i]),
+			pci_unmap_single(pdev, desc_to_dma(&np->tx_ring[i]),
 					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb (skb);
 			np->tx_skbuff[i] = NULL;
@@ -1778,8 +1771,9 @@ rio_remove1 (struct pci_dev *pdev)
 		pci_free_consistent (pdev, TX_TOTAL_SIZE, np->tx_ring,
 				     np->tx_ring_dma);
 #ifdef MEM_MAPPING
-		iounmap ((char *) (dev->base_addr));
+		pci_iounmap(pdev, np->ioaddr);
 #endif
+		pci_iounmap(pdev, np->eeprom_addr);
 		free_netdev (dev);
 		pci_release_regions (pdev);
 		pci_disable_device (pdev);
diff --git a/drivers/net/ethernet/dlink/dl2k.h b/drivers/net/ethernet/dlink/dl2k.h
index ba0adca..b52ef97 100644
--- a/drivers/net/ethernet/dlink/dl2k.h
+++ b/drivers/net/ethernet/dlink/dl2k.h
@@ -42,22 +42,13 @@
 #define TX_TOTAL_SIZE	TX_RING_SIZE*sizeof(struct netdev_desc)
 #define RX_TOTAL_SIZE	RX_RING_SIZE*sizeof(struct netdev_desc)
 
-/* This driver was written to use PCI memory space, however x86-oriented
-   hardware often uses I/O space accesses. */
-#ifndef MEM_MAPPING
-#undef readb
-#undef readw
-#undef readl
-#undef writeb
-#undef writew
-#undef writel
-#define readb inb
-#define readw inw
-#define readl inl
-#define writeb outb
-#define writew outw
-#define writel outl
-#endif
+/* FIXME: use driver local shorthands for io ops and remove this stuff. */
+#define readb	ioread8
+#define readw	ioread16
+#define readl	ioread32
+#define writeb	iowrite8
+#define writew	iowrite16
+#define writel	iowrite32
 
 /* Offsets to the device registers.
    Unlike software-only systems, device drivers interact with complex hardware.
@@ -391,6 +382,8 @@ struct netdev_private {
 	dma_addr_t tx_ring_dma;
 	dma_addr_t rx_ring_dma;
 	struct pci_dev *pdev;
+	void __iomem *ioaddr;
+	void __iomem *eeprom_addr;
 	spinlock_t tx_lock;
 	spinlock_t rx_lock;
 	struct net_device_stats stats;
-- 
1.7.7.6
