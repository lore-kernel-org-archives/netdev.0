From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] hamachi: module_param and __iomem cleanup
Date: Mon, 29 Nov 2004 10:19:19 -0800
Message-ID: <20041129101919.504f73ef@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup the Packet Engines Hamachi driver to get rid of warnings.
Convert to the new format module_param macros.
The device is memory mapped so store the memory base in the device
structure and use that rather than dev->base_addr.
Compiles clean, but not tested.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/drivers/net/hamachi.c b/drivers/net/hamachi.c
--- a/drivers/net/hamachi.c	2004-11-29 10:16:33 -08:00
+++ b/drivers/net/hamachi.c	2004-11-29 10:16:33 -08:00
@@ -153,6 +153,7 @@
 #define TX_TIMEOUT  (5*HZ)
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -512,27 +513,28 @@
 	u32 rx_int_var, tx_int_var;	/* interrupt control variables */
 	u32 option;							/* Hold on to a copy of the options */
 	struct pci_dev *pci_dev;
+	void __iomem *ioaddr;
 };
 
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>, Eric Kasten <kasten@nscl.msu.edu>, Keith Underwood <keithu@parl.clemson.edu>");
 MODULE_DESCRIPTION("Packet Engines 'Hamachi' GNIC-II Gigabit Ethernet driver");
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM(mtu, "i");
-MODULE_PARM(debug, "i");
-MODULE_PARM(min_rx_pkt, "i");
-MODULE_PARM(max_rx_gap, "i");
-MODULE_PARM(max_rx_latency, "i");
-MODULE_PARM(min_tx_pkt, "i");
-MODULE_PARM(max_tx_gap, "i");
-MODULE_PARM(max_tx_latency, "i");
-MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM(rx_params, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(tx_params, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(force32, "i");
+module_param(max_interrupt_work, int, 0);
+module_param(mtu, int, 0);
+module_param(debug, int, 0);
+module_param(min_rx_pkt, int, 0);
+module_param(max_rx_gap, int, 0);
+module_param(max_rx_latency, int, 0);
+module_param(min_tx_pkt, int, 0);
+module_param(max_tx_gap, int, 0);
+module_param(max_tx_latency, int, 0);
+module_param(rx_copybreak, int, 0);
+module_param_array(rx_params, int, NULL, 0);
+module_param_array(tx_params, int, NULL, 0);
+module_param_array(options, int, NULL, 0);
+module_param_array(full_duplex, int, NULL, 0);
+module_param(force32, int, 0);
 MODULE_PARM_DESC(max_interrupt_work, "GNIC-II maximum events handled per interrupt");
 MODULE_PARM_DESC(mtu, "GNIC-II MTU (all boards)");
 MODULE_PARM_DESC(debug, "GNIC-II debug level (0-7)");
@@ -549,7 +551,7 @@
 MODULE_PARM_DESC(full_duplex, "GNIC-II full duplex setting(s) (1)");
 MODULE_PARM_DESC(force32, "GNIC-II: Bit 0: 32 bit PCI, bit 1: disable parity, bit 2: 64 bit PCI (all boards)");
                                                                         
-static int read_eeprom(long ioaddr, int location);
+static int read_eeprom(void __iomem *ioaddr, int location);
 static int mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int hamachi_open(struct net_device *dev);
@@ -575,7 +577,8 @@
 	int option, i, rx_int_var, tx_int_var, boguscnt;
 	int chip_id = ent->driver_data;
 	int irq;
-	long ioaddr;
+	unsigned long base;
+	void __iomem *ioaddr;
 	static int card_idx;
 	struct net_device *dev;
 	void *ring_space;
@@ -594,9 +597,9 @@
 		goto err_out;
 	}
 
-	ioaddr = pci_resource_start(pdev, 0);
+	base = pci_resource_start(pdev, 0);
 #ifdef __alpha__				/* Really "64 bit addrs" */
-	ioaddr |= (pci_resource_start(pdev, 1) << 32);
+	base |= (pci_resource_start(pdev, 1) << 32);
 #endif
 
 	pci_set_master(pdev);
@@ -605,7 +608,7 @@
 	if (i) return i;
 
 	irq = pdev->irq;
-	ioaddr = (long) ioremap(ioaddr, 0x400);
+	ioaddr = ioremap(base, 0x400);
 	if (!ioaddr)
 		goto err_out_release;
 
@@ -678,7 +681,7 @@
 		i = readb(ioaddr + PCIClkMeas);	
 	}
 
-	dev->base_addr = ioaddr;
+	dev->base_addr = (unsigned long) ioaddr;
 	dev->irq = irq;
 	pci_set_drvdata(pdev, dev);
 
@@ -743,7 +746,7 @@
 
 	printk(KERN_INFO "%s: %s type %x at 0x%lx, ",
 		   dev->name, chip_tbl[chip_id].name, readl(ioaddr + ChipRev),
-		   ioaddr);
+		   dev->base_addr);
 	for (i = 0; i < 5; i++)
 			printk("%2.2x:", dev->dev_addr[i]);
 	printk("%2.2x, IRQ %d.\n", dev->dev_addr[i], irq);
@@ -797,7 +800,7 @@
 	return ret;
 }
 
-static int __devinit read_eeprom(long ioaddr, int location)
+static int __devinit read_eeprom(void __iomem *ioaddr, int location)
 {
 	int bogus_cnt = 1000;
 
@@ -819,7 +822,8 @@
 
 static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	long ioaddr = dev->base_addr;
+	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->ioaddr;
 	int i;
 
 	/* We should check busy first - per docs -KDU */
@@ -836,7 +840,8 @@
 
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value)
 {
-	long ioaddr = dev->base_addr;
+	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->ioaddr;
 	int i;
 
 	/* We should check busy first - per docs -KDU */
@@ -857,7 +862,7 @@
 static int hamachi_open(struct net_device *dev)
 {
 	struct hamachi_private *hmp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = hmp->ioaddr;
 	int i;
 	u32 rx_int_var, tx_int_var;
 	u16 fifo_info;
@@ -987,7 +992,7 @@
 	writew(0x001D, ioaddr + RxDMACtrl);
 	writew(0x001D, ioaddr + TxDMACtrl);
 #endif
-	writew(0x0001, dev->base_addr + RxCmd);
+	writew(0x0001, ioaddr + RxCmd);
 
 	if (hamachi_debug > 2) {
 		printk(KERN_DEBUG "%s: Done hamachi_open(), status: Rx %x Tx %x.\n",
@@ -1038,7 +1043,7 @@
 {
 	struct net_device *dev = (struct net_device *)data;
 	struct hamachi_private *hmp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = hmp->ioaddr;
 	int next_tick = 10*HZ;
 
 	if (hamachi_debug > 2) {
@@ -1063,7 +1068,7 @@
 {
 	int i;
 	struct hamachi_private *hmp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
+	void __iomem *ioaddr = hmp->ioaddr;
 
 	printk(KERN_WARNING "%s: Hamachi transmit timed out, status %8.8x,"
 		   " resetting...\n", dev->name, (int)readw(ioaddr + TxStatus));
@@ -1115,7 +1120,7 @@
 	}
 
 	udelay(60); /* Sleep 60 us just for safety sake */
-	writew(0x0002, dev->base_addr + RxCmd); /* STOP Rx */
+	writew(0x0002, ioaddr + RxCmd); /* STOP Rx */
 		
 	writeb(0x01, ioaddr + ChipReset);  /* Reinit the hardware */ 
 
@@ -1157,9 +1162,9 @@
 	hmp->stats.tx_errors++;
 
 	/* Restart the chip's Tx/Rx processes . */
-	writew(0x0002, dev->base_addr + TxCmd); /* STOP Tx */
-	writew(0x0001, dev->base_addr + TxCmd); /* START Tx */
-	writew(0x0001, dev->base_addr + RxCmd); /* START Rx */
+	writew(0x0002, ioaddr + TxCmd); /* STOP Tx */
+	writew(0x0001, ioaddr + TxCmd); /* START Tx */
+	writew(0x0001, ioaddr + RxCmd); /* START Rx */
 
 	netif_wake_queue(dev);
 }
@@ -1275,9 +1280,9 @@
 
 		/* Wake the potentially-idle transmit channel. */
 		/* If we don't need to read status, DON'T -KDU */
-		status=readw(dev->base_addr + TxStatus);
+		status=readw(hmp->ioaddr + TxStatus);
 		if( !(status & 0x0001) || (status & 0x0002))
-			writew(0x0001, dev->base_addr + TxCmd);
+			writew(0x0001, hmp->ioaddr + TxCmd);
 		return 1;
 	} 
 
@@ -1343,9 +1348,9 @@
 
 	/* Wake the potentially-idle transmit channel. */
 	/* If we don't need to read status, DON'T -KDU */
-	status=readw(dev->base_addr + TxStatus);
+	status=readw(hmp->ioaddr + TxStatus);
 	if( !(status & 0x0001) || (status & 0x0002))
-		writew(0x0001, dev->base_addr + TxCmd);
+		writew(0x0001, hmp->ioaddr + TxCmd);
 
 	/* Immediately before returning, let's clear as many entries as we can. */
 	hamachi_tx(dev);
@@ -1376,8 +1381,9 @@
 static irqreturn_t hamachi_interrupt(int irq, void *dev_instance, struct pt_regs *rgs)
 {
 	struct net_device *dev = dev_instance;
-	struct hamachi_private *hmp;
-	long ioaddr, boguscnt = max_interrupt_work;
+	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->ioaddr;
+	long boguscnt = max_interrupt_work;
 	int handled = 0;
 
 #ifndef final_version			/* Can never occur. */
@@ -1386,9 +1392,7 @@
 		return IRQ_NONE;
 	}
 #endif
-
-	ioaddr = dev->base_addr;
-	hmp = netdev_priv(dev);
+	
 	spin_lock(&hmp->lock);
 
 	do {
@@ -1687,8 +1691,8 @@
 
 	/* Restart Rx engine if stopped. */
 	/* If we don't need to check status, don't. -KDU */
-	if (readw(dev->base_addr + RxStatus) & 0x0002)
-		writew(0x0001, dev->base_addr + RxCmd);
+	if (readw(hmp->ioaddr + RxStatus) & 0x0002)
+		writew(0x0001, hmp->ioaddr + RxCmd);
 
 	return 0;
 }
@@ -1697,8 +1701,8 @@
    than just errors. */
 static void hamachi_error(struct net_device *dev, int intr_status)
 {
-	long ioaddr = dev->base_addr;
 	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->ioaddr;
 
 	if (intr_status & (LinkChange|NegotiationChange)) {
 		if (hamachi_debug > 1)
@@ -1731,8 +1735,8 @@
 
 static int hamachi_close(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->ioaddr;
 	struct sk_buff *skb;
 	int i;
 
@@ -1817,8 +1821,8 @@
 
 static struct net_device_stats *hamachi_get_stats(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
 	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->ioaddr;
 
 	/* We should lock this segment of code for SMP eventually, although
 	   the vulnerability window is very small and statistics are
@@ -1845,7 +1849,8 @@
 
 static void set_rx_mode(struct net_device *dev)
 {
-	long ioaddr = dev->base_addr;
+	struct hamachi_private *hmp = netdev_priv(dev);
+	void __iomem *ioaddr = hmp->ioaddr;
 
 	if (dev->flags & IFF_PROMISC) {			/* Set promiscuous. */
 		/* Unconditionally log net taps. */
@@ -1950,11 +1955,11 @@
 		 */
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		writel(d[0], dev->base_addr + TxIntrCtrl);
-		writel(d[1], dev->base_addr + RxIntrCtrl);
+		writel(d[0], np->ioaddr + TxIntrCtrl);
+		writel(d[1], np->ioaddr + RxIntrCtrl);
 		printk(KERN_NOTICE "%s: tx %08x, rx %08x intr\n", dev->name,
-		  (u32) readl(dev->base_addr + TxIntrCtrl),
-		  (u32) readl(dev->base_addr + RxIntrCtrl));
+		  (u32) readl(np->ioaddr + TxIntrCtrl),
+		  (u32) readl(np->ioaddr + RxIntrCtrl));
 		rc = 0;
 	}
 
@@ -1980,7 +1985,7 @@
 		pci_free_consistent(pdev, TX_TOTAL_SIZE, hmp->tx_ring, 
 			hmp->tx_ring_dma);
 		unregister_netdev(dev);
-		iounmap((char *)dev->base_addr);
+		iounmap(hmp->ioaddr);
 		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_set_drvdata(pdev, NULL);
