From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 30/39] dl2k: stop using net_device.{base_addr, irq} and convert to __iomem.
Date: Fri,  6 Apr 2012 12:06:44 +0200
Message-ID: <3fb93f6502cb93284bc6e6eec6ffb36456cef37a.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43465 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755974Ab2DFKKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:38 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The eeprom registers always use the same PCI bar whereas the general
registers may either use the same mapping as the eeprom registers or
a different one. It is thus possible to simplify parse_eeprom().

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/dlink/dl2k.c |  416 ++++++++++++++++++-------------------
 drivers/net/ethernet/dlink/dl2k.h |   19 +--
 2 files changed, 209 insertions(+), 226 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index b2dc2c8..ef4499d 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -16,6 +16,13 @@
 #include "dl2k.h"
 #include <linux/dma-mapping.h>
 
+#define dw32(reg, val)	iowrite32(val, ioaddr + (reg))
+#define dw16(reg, val)	iowrite16(val, ioaddr + (reg))
+#define dw8(reg, val)	iowrite8(val, ioaddr + (reg))
+#define dr32(reg)	ioread32(ioaddr + (reg))
+#define dr16(reg)	ioread16(ioaddr + (reg))
+#define dr8(reg)	ioread8(ioaddr + (reg))
+
 static char version[] __devinitdata =
       KERN_INFO DRV_NAME " " DRV_VERSION " " DRV_RELDATE "\n";
 #define MAX_UNITS 8
@@ -49,8 +56,13 @@ module_param(tx_coalesce, int, 0); /* HW xmit count each TxDMAComplete */
 /* Enable the default interrupts */
 #define DEFAULT_INTR (RxDMAComplete | HostError | IntRequested | TxDMAComplete| \
        UpdateStats | LinkEvent)
-#define EnableInt() \
-writew(DEFAULT_INTR, ioaddr + IntEnable)
+
+static void dl2k_enable_int(struct netdev_private *np)
+{
+	void __iomem *ioaddr = np->ioaddr;
+
+	dw16(IntEnable, DEFAULT_INTR);
+}
 
 static const int max_intrloop = 50;
 static const int multicast_filter_limit = 0x40;
@@ -73,7 +85,7 @@ static int rio_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
 static int rio_close (struct net_device *dev);
 static int find_miiphy (struct net_device *dev);
 static int parse_eeprom (struct net_device *dev);
-static int read_eeprom (long ioaddr, int eep_addr);
+static int read_eeprom (struct netdev_private *, int eep_addr);
 static int mii_wait_link (struct net_device *dev, int wait);
 static int mii_set_media (struct net_device *dev);
 static int mii_get_media (struct net_device *dev);
@@ -106,7 +118,7 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 	static int card_idx;
 	int chip_idx = ent->driver_data;
 	int err, irq;
-	long ioaddr;
+	void __iomem *ioaddr;
 	static int version_printed;
 	void *ring_space;
 	dma_addr_t ring_dma;
@@ -124,26 +136,29 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -239,7 +254,7 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_unmap_rx;
 
 	/* Fiber device? */
-	np->phy_media = (readw(ioaddr + ASICCtrl) & PhyMedia) ? 1 : 0;
+	np->phy_media = (dr16(ASICCtrl) & PhyMedia) ? 1 : 0;
 	np->link_status = 0;
 	/* Set media and reset PHY */
 	if (np->phy_media) {
@@ -276,22 +291,20 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -299,11 +312,9 @@ rio_probe1 (struct pci_dev *pdev, const struct pci_device_id *ent)
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
@@ -323,26 +334,19 @@ find_miiphy (struct net_device *dev)
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
@@ -378,8 +382,7 @@ parse_eeprom (struct net_device *dev)
 			return 0;
 		case 2:	/* Duplex Polarity */
 			np->duplex_polarity = psib[i];
-			writeb (readb (ioaddr + PhyCtrl) | psib[i],
-				ioaddr + PhyCtrl);
+			dw8(PhyCtrl, dr8(PhyCtrl) | psib[i]);
 			break;
 		case 3:	/* Wake Polarity */
 			np->wake_polarity = psib[i];
@@ -407,59 +410,57 @@ static int
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
 
 	/* Reset all logic functions */
-	writew (GlobalReset | DMAReset | FIFOReset | NetworkReset | HostReset,
-		ioaddr + ASICCtrl + 2);
+	dw16(ASICCtrl + 2,
+	     GlobalReset | DMAReset | FIFOReset | NetworkReset | HostReset);
 	mdelay(10);
 
 	/* DebugCtrl bit 4, 5, 9 must set */
-	writel (readl (ioaddr + DebugCtrl) | 0x0230, ioaddr + DebugCtrl);
+	dw32(DebugCtrl, dr32(DebugCtrl) | 0x0230);
 
 	/* Jumbo frame */
 	if (np->jumbo != 0)
-		writew (MAX_JUMBO+14, ioaddr + MaxFrameSize);
+		dw16(MaxFrameSize, MAX_JUMBO+14);
 
 	alloc_list (dev);
 
 	/* Get station address */
 	for (i = 0; i < 6; i++)
-		writeb (dev->dev_addr[i], ioaddr + StationAddr0 + i);
+		dw8(StationAddr0 + i, dev->dev_addr[i]);
 
 	set_multicast (dev);
 	if (np->coalesce) {
-		writel (np->rx_coalesce | np->rx_timeout << 16,
-			ioaddr + RxDMAIntCtrl);
+		dw32(RxDMAIntCtrl, np->rx_coalesce | np->rx_timeout << 16);
 	}
 	/* Set RIO to poll every N*320nsec. */
-	writeb (0x20, ioaddr + RxDMAPollPeriod);
-	writeb (0xff, ioaddr + TxDMAPollPeriod);
-	writeb (0x30, ioaddr + RxDMABurstThresh);
-	writeb (0x30, ioaddr + RxDMAUrgentThresh);
-	writel (0x0007ffff, ioaddr + RmonStatMask);
+	dw8(RxDMAPollPeriod, 0x20);
+	dw8(TxDMAPollPeriod, 0xff);
+	dw8(RxDMABurstThresh, 0x30);
+	dw8(RxDMAUrgentThresh, 0x30);
+	dw32(RmonStatMask, 0x0007ffff);
 	/* clear statistics */
 	clear_stats (dev);
 
 	/* VLAN supported */
 	if (np->vlan) {
 		/* priority field in RxDMAIntCtrl  */
-		writel (readl(ioaddr + RxDMAIntCtrl) | 0x7 << 10,
-			ioaddr + RxDMAIntCtrl);
+		dw32(RxDMAIntCtrl, dr32(RxDMAIntCtrl) | 0x7 << 10);
 		/* VLANId */
-		writew (np->vlan, ioaddr + VLANId);
+		dw16(VLANId, np->vlan);
 		/* Length/Type should be 0x8100 */
-		writel (0x8100 << 16 | np->vlan, ioaddr + VLANTag);
+		dw32(VLANTag, 0x8100 << 16 | np->vlan);
 		/* Enable AutoVLANuntagging, but disable AutoVLANtagging.
 		   VLAN information tagged by TFC' VID, CFI fields. */
-		writel (readl (ioaddr + MACCtrl) | AutoVLANuntagging,
-			ioaddr + MACCtrl);
+		dw32(MACCtrl, dr32(MACCtrl) | AutoVLANuntagging);
 	}
 
 	init_timer (&np->timer);
@@ -469,20 +470,18 @@ rio_open (struct net_device *dev)
 	add_timer (&np->timer);
 
 	/* Start Tx/Rx */
-	writel (readl (ioaddr + MACCtrl) | StatsEnable | RxEnable | TxEnable,
-			ioaddr + MACCtrl);
+	dw32(MACCtrl, dr32(MACCtrl) | StatsEnable | RxEnable | TxEnable);
 
 	macctrl = 0;
 	macctrl |= (np->vlan) ? AutoVLANuntagging : 0;
 	macctrl |= (np->full_duplex) ? DuplexSelect : 0;
 	macctrl |= (np->tx_flow) ? TxFlowControlEnable : 0;
 	macctrl |= (np->rx_flow) ? RxFlowControlEnable : 0;
-	writew(macctrl,	ioaddr + MACCtrl);
+	dw16(MACCtrl, macctrl);
 
 	netif_start_queue (dev);
 
-	/* Enable default interrupts */
-	EnableInt ();
+	dl2k_enable_int(np);
 	return 0;
 }
 
@@ -533,10 +532,11 @@ rio_timer (unsigned long data)
 static void
 rio_tx_timeout (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 
 	printk (KERN_INFO "%s: Tx timed out (%4.4x), is buffer full?\n",
-		dev->name, readl (ioaddr + TxStatus));
+		dev->name, dr32(TxStatus));
 	rio_free_tx(dev, 0);
 	dev->if_port = 0;
 	dev->trans_start = jiffies; /* prevent tx timeout */
@@ -547,6 +547,7 @@ static void
 alloc_list (struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 	int i;
 
 	np->cur_rx = np->cur_tx = 0;
@@ -594,24 +595,23 @@ alloc_list (struct net_device *dev)
 	}
 
 	/* Set RFDListPtr */
-	writel (np->rx_ring_dma, dev->base_addr + RFDListPtr0);
-	writel (0, dev->base_addr + RFDListPtr1);
+	dw32(RFDListPtr0, np->rx_ring_dma);
+	dw32(RFDListPtr1, 0);
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
@@ -646,9 +646,9 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 					      (1 << FragCountShift));
 
 	/* TxDMAPollNow */
-	writel (readl (ioaddr + DMACtrl) | 0x00001000, ioaddr + DMACtrl);
+	dw32(DMACtrl, dr32(DMACtrl) | 0x00001000);
 	/* Schedule ISR */
-	writel(10000, ioaddr + CountDown);
+	dw32(CountDown, 10000);
 	np->cur_tx = (np->cur_tx + 1) % TX_RING_SIZE;
 	if ((np->cur_tx - np->old_tx + TX_RING_SIZE) % TX_RING_SIZE
 			< TX_QUEUE_LEN - 1 && np->speed != 10) {
@@ -658,10 +658,10 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* The first TFDListPtr */
-	if (readl (dev->base_addr + TFDListPtr0) == 0) {
-		writel (np->tx_ring_dma + entry * sizeof (struct netdev_desc),
-			dev->base_addr + TFDListPtr0);
-		writel (0, dev->base_addr + TFDListPtr1);
+	if (!dr32(TFDListPtr0)) {
+		dw32(TFDListPtr0, np->tx_ring_dma +
+		     entry * sizeof (struct netdev_desc));
+		dw32(TFDListPtr1, 0);
 	}
 
 	return NETDEV_TX_OK;
@@ -671,17 +671,15 @@ static irqreturn_t
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
-		int_status = readw (ioaddr + IntStatus);
-		writew (int_status, ioaddr + IntStatus);
+		int_status = dr16(IntStatus);
+		dw16(IntStatus, int_status);
 		int_status &= DEFAULT_INTR;
 		if (int_status == 0 || --cnt < 0)
 			break;
@@ -692,7 +690,7 @@ rio_interrupt (int irq, void *dev_instance)
 		/* TxDMAComplete interrupt */
 		if ((int_status & (TxDMAComplete|IntRequested))) {
 			int tx_status;
-			tx_status = readl (ioaddr + TxStatus);
+			tx_status = dr32(TxStatus);
 			if (tx_status & 0x01)
 				tx_error (dev, tx_status);
 			/* Free used tx skbuffs */
@@ -705,7 +703,7 @@ rio_interrupt (int irq, void *dev_instance)
 			rio_error (dev, int_status);
 	}
 	if (np->cur_tx != np->old_tx)
-		writel (100, ioaddr + CountDown);
+		dw32(CountDown, 100);
 	return IRQ_RETVAL(handled);
 }
 
@@ -765,13 +763,11 @@ rio_free_tx (struct net_device *dev, int irq)
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
@@ -779,23 +775,21 @@ tx_error (struct net_device *dev, int tx_status)
 	/* Ttransmit Underrun */
 	if (tx_status & 0x10) {
 		np->stats.tx_fifo_errors++;
-		writew (readw (ioaddr + TxStartThresh) + 0x10,
-			ioaddr + TxStartThresh);
+		dw16(TxStartThresh, dr16(TxStartThresh) + 0x10);
 		/* Transmit Underrun need to set TxReset, DMARest, FIFOReset */
-		writew (TxReset | DMAReset | FIFOReset | NetworkReset,
-			ioaddr + ASICCtrl + 2);
+		dw16(ASICCtrl + 2,
+		     TxReset | DMAReset | FIFOReset | NetworkReset);
 		/* Wait for ResetBusy bit clear */
 		for (i = 50; i > 0; i--) {
-			if ((readw (ioaddr + ASICCtrl + 2) & ResetBusy) == 0)
+			if (!(dr16(ASICCtrl + 2) & ResetBusy))
 				break;
 			mdelay (1);
 		}
 		rio_free_tx (dev, 1);
 		/* Reset TFDListPtr */
-		writel (np->tx_ring_dma +
-			np->old_tx * sizeof (struct netdev_desc),
-			dev->base_addr + TFDListPtr0);
-		writel (0, dev->base_addr + TFDListPtr1);
+		dw32(TFDListPtr0, np->tx_ring_dma +
+		     np->old_tx * sizeof (struct netdev_desc));
+		dw32(TFDListPtr1, 0);
 
 		/* Let TxStartThresh stay default value */
 	}
@@ -803,10 +797,10 @@ tx_error (struct net_device *dev, int tx_status)
 	if (tx_status & 0x04) {
 		np->stats.tx_fifo_errors++;
 		/* TxReset and clear FIFO */
-		writew (TxReset | FIFOReset, ioaddr + ASICCtrl + 2);
+		dw16(ASICCtrl + 2, TxReset | FIFOReset);
 		/* Wait reset done */
 		for (i = 50; i > 0; i--) {
-			if ((readw (ioaddr + ASICCtrl + 2) & ResetBusy) == 0)
+			if (!(dr16(ASICCtrl + 2) & ResetBusy))
 				break;
 			mdelay (1);
 		}
@@ -821,7 +815,7 @@ tx_error (struct net_device *dev, int tx_status)
 		np->stats.collisions++;
 #endif
 	/* Restart the Tx */
-	writel (readw (dev->base_addr + MACCtrl) | TxEnable, ioaddr + MACCtrl);
+	dw32(MACCtrl, dr16(MACCtrl) | TxEnable);
 }
 
 static int
@@ -931,8 +925,8 @@ receive_packet (struct net_device *dev)
 static void
 rio_error (struct net_device *dev, int int_status)
 {
-	long ioaddr = dev->base_addr;
 	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 	u16 macctrl;
 
 	/* Link change event */
@@ -954,7 +948,7 @@ rio_error (struct net_device *dev, int int_status)
 				TxFlowControlEnable : 0;
 			macctrl |= (np->rx_flow) ?
 				RxFlowControlEnable : 0;
-			writew(macctrl,	ioaddr + MACCtrl);
+			dw16(MACCtrl, macctrl);
 			np->link_status = 1;
 			netif_carrier_on(dev);
 		} else {
@@ -974,7 +968,7 @@ rio_error (struct net_device *dev, int int_status)
 	if (int_status & HostError) {
 		printk (KERN_ERR "%s: HostError! IntStatus %4.4x.\n",
 			dev->name, int_status);
-		writew (GlobalReset | HostReset, ioaddr + ASICCtrl + 2);
+		dw16(ASICCtrl + 2, GlobalReset | HostReset);
 		mdelay (500);
 	}
 }
@@ -982,8 +976,8 @@ rio_error (struct net_device *dev, int int_status)
 static struct net_device_stats *
 get_stats (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 #ifdef MEM_MAPPING
 	int i;
 #endif
@@ -992,106 +986,107 @@ get_stats (struct net_device *dev)
 	/* All statistics registers need to be acknowledged,
 	   else statistic overflow could cause problems */
 
-	np->stats.rx_packets += readl (ioaddr + FramesRcvOk);
-	np->stats.tx_packets += readl (ioaddr + FramesXmtOk);
-	np->stats.rx_bytes += readl (ioaddr + OctetRcvOk);
-	np->stats.tx_bytes += readl (ioaddr + OctetXmtOk);
+	np->stats.rx_packets += dr32(FramesRcvOk);
+	np->stats.tx_packets += dr32(FramesXmtOk);
+	np->stats.rx_bytes += dr32(OctetRcvOk);
+	np->stats.tx_bytes += dr32(OctetXmtOk);
 
-	np->stats.multicast = readl (ioaddr + McstFramesRcvdOk);
-	np->stats.collisions += readl (ioaddr + SingleColFrames)
-			     +  readl (ioaddr + MultiColFrames);
+	np->stats.multicast = dr32(McstFramesRcvdOk);
+	np->stats.collisions += dr32(SingleColFrames)
+			     +  dr32(MultiColFrames);
 
 	/* detailed tx errors */
-	stat_reg = readw (ioaddr + FramesAbortXSColls);
+	stat_reg = dr16(FramesAbortXSColls);
 	np->stats.tx_aborted_errors += stat_reg;
 	np->stats.tx_errors += stat_reg;
 
-	stat_reg = readw (ioaddr + CarrierSenseErrors);
+	stat_reg = dr16(CarrierSenseErrors);
 	np->stats.tx_carrier_errors += stat_reg;
 	np->stats.tx_errors += stat_reg;
 
 	/* Clear all other statistic register. */
-	readl (ioaddr + McstOctetXmtOk);
-	readw (ioaddr + BcstFramesXmtdOk);
-	readl (ioaddr + McstFramesXmtdOk);
-	readw (ioaddr + BcstFramesRcvdOk);
-	readw (ioaddr + MacControlFramesRcvd);
-	readw (ioaddr + FrameTooLongErrors);
-	readw (ioaddr + InRangeLengthErrors);
-	readw (ioaddr + FramesCheckSeqErrors);
-	readw (ioaddr + FramesLostRxErrors);
-	readl (ioaddr + McstOctetXmtOk);
-	readl (ioaddr + BcstOctetXmtOk);
-	readl (ioaddr + McstFramesXmtdOk);
-	readl (ioaddr + FramesWDeferredXmt);
-	readl (ioaddr + LateCollisions);
-	readw (ioaddr + BcstFramesXmtdOk);
-	readw (ioaddr + MacControlFramesXmtd);
-	readw (ioaddr + FramesWEXDeferal);
+	dr32(McstOctetXmtOk);
+	dr16(BcstFramesXmtdOk);
+	dr32(McstFramesXmtdOk);
+	dr16(BcstFramesRcvdOk);
+	dr16(MacControlFramesRcvd);
+	dr16(FrameTooLongErrors);
+	dr16(InRangeLengthErrors);
+	dr16(FramesCheckSeqErrors);
+	dr16(FramesLostRxErrors);
+	dr32(McstOctetXmtOk);
+	dr32(BcstOctetXmtOk);
+	dr32(McstFramesXmtdOk);
+	dr32(FramesWDeferredXmt);
+	dr32(LateCollisions);
+	dr16(BcstFramesXmtdOk);
+	dr16(MacControlFramesXmtd);
+	dr16(FramesWEXDeferal);
 
 #ifdef MEM_MAPPING
 	for (i = 0x100; i <= 0x150; i += 4)
-		readl (ioaddr + i);
+		dr32(i);
 #endif
-	readw (ioaddr + TxJumboFrames);
-	readw (ioaddr + RxJumboFrames);
-	readw (ioaddr + TCPCheckSumErrors);
-	readw (ioaddr + UDPCheckSumErrors);
-	readw (ioaddr + IPCheckSumErrors);
+	dr16(TxJumboFrames);
+	dr16(RxJumboFrames);
+	dr16(TCPCheckSumErrors);
+	dr16(UDPCheckSumErrors);
+	dr16(IPCheckSumErrors);
 	return &np->stats;
 }
 
 static int
 clear_stats (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 #ifdef MEM_MAPPING
 	int i;
 #endif
 
 	/* All statistics registers need to be acknowledged,
 	   else statistic overflow could cause problems */
-	readl (ioaddr + FramesRcvOk);
-	readl (ioaddr + FramesXmtOk);
-	readl (ioaddr + OctetRcvOk);
-	readl (ioaddr + OctetXmtOk);
-
-	readl (ioaddr + McstFramesRcvdOk);
-	readl (ioaddr + SingleColFrames);
-	readl (ioaddr + MultiColFrames);
-	readl (ioaddr + LateCollisions);
+	dr32(FramesRcvOk);
+	dr32(FramesXmtOk);
+	dr32(OctetRcvOk);
+	dr32(OctetXmtOk);
+
+	dr32(McstFramesRcvdOk);
+	dr32(SingleColFrames);
+	dr32(MultiColFrames);
+	dr32(LateCollisions);
 	/* detailed rx errors */
-	readw (ioaddr + FrameTooLongErrors);
-	readw (ioaddr + InRangeLengthErrors);
-	readw (ioaddr + FramesCheckSeqErrors);
-	readw (ioaddr + FramesLostRxErrors);
+	dr16(FrameTooLongErrors);
+	dr16(InRangeLengthErrors);
+	dr16(FramesCheckSeqErrors);
+	dr16(FramesLostRxErrors);
 
 	/* detailed tx errors */
-	readw (ioaddr + FramesAbortXSColls);
-	readw (ioaddr + CarrierSenseErrors);
+	dr16(FramesAbortXSColls);
+	dr16(CarrierSenseErrors);
 
 	/* Clear all other statistic register. */
-	readl (ioaddr + McstOctetXmtOk);
-	readw (ioaddr + BcstFramesXmtdOk);
-	readl (ioaddr + McstFramesXmtdOk);
-	readw (ioaddr + BcstFramesRcvdOk);
-	readw (ioaddr + MacControlFramesRcvd);
-	readl (ioaddr + McstOctetXmtOk);
-	readl (ioaddr + BcstOctetXmtOk);
-	readl (ioaddr + McstFramesXmtdOk);
-	readl (ioaddr + FramesWDeferredXmt);
-	readw (ioaddr + BcstFramesXmtdOk);
-	readw (ioaddr + MacControlFramesXmtd);
-	readw (ioaddr + FramesWEXDeferal);
+	dr32(McstOctetXmtOk);
+	dr16(BcstFramesXmtdOk);
+	dr32(McstFramesXmtdOk);
+	dr16(BcstFramesRcvdOk);
+	dr16(MacControlFramesRcvd);
+	dr32(McstOctetXmtOk);
+	dr32(BcstOctetXmtOk);
+	dr32(McstFramesXmtdOk);
+	dr32(FramesWDeferredXmt);
+	dr16(BcstFramesXmtdOk);
+	dr16(MacControlFramesXmtd);
+	dr16(FramesWEXDeferal);
 #ifdef MEM_MAPPING
 	for (i = 0x100; i <= 0x150; i += 4)
-		readl (ioaddr + i);
+		dr32(i);
 #endif
-	readw (ioaddr + TxJumboFrames);
-	readw (ioaddr + RxJumboFrames);
-	readw (ioaddr + TCPCheckSumErrors);
-	readw (ioaddr + UDPCheckSumErrors);
-	readw (ioaddr + IPCheckSumErrors);
+	dr16(TxJumboFrames);
+	dr16(RxJumboFrames);
+	dr16(TCPCheckSumErrors);
+	dr16(UDPCheckSumErrors);
+	dr16(IPCheckSumErrors);
 	return 0;
 }
 
@@ -1114,10 +1109,10 @@ change_mtu (struct net_device *dev, int new_mtu)
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
@@ -1153,9 +1148,9 @@ set_multicast (struct net_device *dev)
 		rx_mode |= ReceiveVLANMatch;
 	}
 
-	writel (hash_table[0], ioaddr + HashTable0);
-	writel (hash_table[1], ioaddr + HashTable1);
-	writew (rx_mode, ioaddr + ReceiveMode);
+	dw32(HashTable0, hash_table[0]);
+	dw32(HashTable1, hash_table[1]);
+	dw16(ReceiveMode, rx_mode);
 }
 
 static void rio_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -1318,15 +1313,15 @@ rio_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
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
+	dw16(EepromCtrl, EEP_READ | (eep_addr & 0xff));
 	while (i-- > 0) {
-		if (!(inw (ioaddr + EepromCtrl) & EEP_BUSY)) {
-			return inw (ioaddr + EepromData);
-		}
+		if (!(dr16(EepromCtrl) & EEP_BUSY))
+			return dr16(EepromData);
 	}
 	return 0;
 }
@@ -1336,38 +1331,40 @@ enum phy_ctrl_bits {
 	MII_DUPLEX = 0x08,
 };
 
-#define mii_delay() readb(ioaddr)
+#define mii_delay() dr8(PhyCtrl)
 static void
 mii_sendbit (struct net_device *dev, u32 data)
 {
-	long ioaddr = dev->base_addr + PhyCtrl;
-	data = (data) ? MII_DATA1 : 0;
-	data |= MII_WRITE;
-	data |= (readb (ioaddr) & 0xf8) | MII_WRITE;
-	writeb (data, ioaddr);
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
+
+	data = ((data) ? MII_DATA1 : 0) | (dr8(PhyCtrl) & 0xf8) | MII_WRITE;
+	dw8(PhyCtrl, data);
 	mii_delay ();
-	writeb (data | MII_CLK, ioaddr);
+	dw8(PhyCtrl, data | MII_CLK);
 	mii_delay ();
 }
 
 static int
 mii_getbit (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr + PhyCtrl;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
 	u8 data;
 
-	data = (readb (ioaddr) & 0xf8) | MII_READ;
-	writeb (data, ioaddr);
+	data = (dr8(PhyCtrl) & 0xf8) | MII_READ;
+	dw8(PhyCtrl, data);
 	mii_delay ();
-	writeb (data | MII_CLK, ioaddr);
+	dw8(PhyCtrl, data | MII_CLK);
 	mii_delay ();
-	return ((readb (ioaddr) >> 1) & 1);
+	return (dr8(PhyCtrl) >> 1) & 1;
 }
 
 static void
 mii_send_bits (struct net_device *dev, u32 data, int len)
 {
 	int i;
+
 	for (i = len - 1; i >= 0; i--) {
 		mii_sendbit (dev, data & (1 << i));
 	}
@@ -1721,28 +1718,29 @@ mii_set_media_pcs (struct net_device *dev)
 static int
 rio_close (struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = np->ioaddr;
+
+	struct pci_dev *pdev = np->pdev;
 	struct sk_buff *skb;
 	int i;
 
 	netif_stop_queue (dev);
 
 	/* Disable interrupts */
-	writew (0, ioaddr + IntEnable);
+	dw16(IntEnable, 0);
 
 	/* Stop Tx and Rx logics */
-	writel (TxDisable | RxDisable | StatsDisable, ioaddr + MACCtrl);
+	dw32(MACCtrl, TxDisable | RxDisable | StatsDisable);
 
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
@@ -1753,8 +1751,7 @@ rio_close (struct net_device *dev)
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		skb = np->tx_skbuff[i];
 		if (skb) {
-			pci_unmap_single(np->pdev,
-					 desc_to_dma(&np->tx_ring[i]),
+			pci_unmap_single(pdev, desc_to_dma(&np->tx_ring[i]),
 					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb (skb);
 			np->tx_skbuff[i] = NULL;
@@ -1778,8 +1775,9 @@ rio_remove1 (struct pci_dev *pdev)
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
index ba0adca..40ba6e0 100644
--- a/drivers/net/ethernet/dlink/dl2k.h
+++ b/drivers/net/ethernet/dlink/dl2k.h
@@ -42,23 +42,6 @@
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
-
 /* Offsets to the device registers.
    Unlike software-only systems, device drivers interact with complex hardware.
    It's not useful to define symbolic names for every register bit in the
@@ -391,6 +374,8 @@ struct netdev_private {
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
