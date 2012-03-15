From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 29/34] 8139too: dev->{base_addr, irq} removal.
Date: Thu, 15 Mar 2012 14:57:26 +0100
Message-ID: <1c98b91ceb9435e5669f31d68d94f7bb9a51ef33.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51870 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761192Ab2CON7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:51 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/8139too.c |  136 +++++++++++++-------------------
 1 files changed, 56 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index df7fd8d..03df076 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -148,9 +148,9 @@ static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 
 /* Whether to use MMIO or PIO. Default to MMIO. */
 #ifdef CONFIG_8139TOO_PIO
-static int use_io = 1;
+static bool use_io = true;
 #else
-static int use_io = 0;
+static bool use_io = false;
 #endif
 
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
@@ -620,7 +620,7 @@ MODULE_DESCRIPTION ("RealTek RTL-8139 Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-module_param(use_io, int, 0);
+module_param(use_io, bool, 0);
 MODULE_PARM_DESC(use_io, "Force use of I/O access mode. 0=MMIO 1=PIO");
 module_param(multicast_filter_limit, int, 0);
 module_param_array(media, int, NULL, 0);
@@ -750,15 +750,22 @@ static void rtl8139_chip_reset (void __iomem *ioaddr)
 
 static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
 {
+	struct device *d = &pdev->dev;
 	void __iomem *ioaddr;
 	struct net_device *dev;
 	struct rtl8139_private *tp;
 	u8 tmp8;
 	int rc, disable_dev_on_err = 0;
-	unsigned int i;
-	unsigned long pio_start, pio_end, pio_flags, pio_len;
-	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
+	unsigned int i, bar;
+	unsigned long io_len;
 	u32 version;
+	static const struct {
+		unsigned long mask;
+		char *type;
+	} res[] = {
+		{ IORESOURCE_IO,  "PIO" },
+		{ IORESOURCE_MEM, "MMIO" }
+	};
 
 	assert (pdev != NULL);
 
@@ -777,78 +784,45 @@ static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
 	if (rc)
 		goto err_out;
 
-	pio_start = pci_resource_start (pdev, 0);
-	pio_end = pci_resource_end (pdev, 0);
-	pio_flags = pci_resource_flags (pdev, 0);
-	pio_len = pci_resource_len (pdev, 0);
-
-	mmio_start = pci_resource_start (pdev, 1);
-	mmio_end = pci_resource_end (pdev, 1);
-	mmio_flags = pci_resource_flags (pdev, 1);
-	mmio_len = pci_resource_len (pdev, 1);
-
-	/* set this immediately, we need to know before
-	 * we talk to the chip directly */
-	pr_debug("PIO region size == 0x%02lX\n", pio_len);
-	pr_debug("MMIO region size == 0x%02lX\n", mmio_len);
-
-retry:
-	if (use_io) {
-		/* make sure PCI base addr 0 is PIO */
-		if (!(pio_flags & IORESOURCE_IO)) {
-			dev_err(&pdev->dev, "region #0 not a PIO resource, aborting\n");
-			rc = -ENODEV;
-			goto err_out;
-		}
-		/* check for weird/broken PCI region reporting */
-		if (pio_len < RTL_MIN_IO_SIZE) {
-			dev_err(&pdev->dev, "Invalid PCI I/O region size(s), aborting\n");
-			rc = -ENODEV;
-			goto err_out;
-		}
-	} else {
-		/* make sure PCI base addr 1 is MMIO */
-		if (!(mmio_flags & IORESOURCE_MEM)) {
-			dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
-			rc = -ENODEV;
-			goto err_out;
-		}
-		if (mmio_len < RTL_MIN_IO_SIZE) {
-			dev_err(&pdev->dev, "Invalid PCI mem region size(s), aborting\n");
-			rc = -ENODEV;
-			goto err_out;
-		}
-	}
-
 	rc = pci_request_regions (pdev, DRV_NAME);
 	if (rc)
 		goto err_out;
 	disable_dev_on_err = 1;
 
-	/* enable PCI bus-mastering */
 	pci_set_master (pdev);
 
-	if (use_io) {
-		ioaddr = pci_iomap(pdev, 0, 0);
-		if (!ioaddr) {
-			dev_err(&pdev->dev, "cannot map PIO, aborting\n");
-			rc = -EIO;
-			goto err_out;
-		}
-		dev->base_addr = pio_start;
-		tp->regs_len = pio_len;
-	} else {
-		/* ioremap MMIO region */
-		ioaddr = pci_iomap(pdev, 1, 0);
-		if (ioaddr == NULL) {
-			dev_err(&pdev->dev, "cannot remap MMIO, trying PIO\n");
-			pci_release_regions(pdev);
-			use_io = 1;
+retry:
+	/* PIO bar register comes first. */
+	bar = !use_io;
+
+	io_len = pci_resource_len(pdev, bar);
+
+	dev_dbg(d, "%s region size = 0x%02lX\n", res[bar].type, io_len);
+
+	if (!(pci_resource_flags(pdev, bar) & res[bar].mask)) {
+		dev_err(d, "region #%d not a %s resource, aborting\n", bar,
+			res[bar].type);
+		rc = -ENODEV;
+		goto err_out;
+	}
+	if (io_len < RTL_MIN_IO_SIZE) {
+		dev_err(d, "Invalid PCI %s region size(s), aborting\n",
+			res[bar].type);
+		rc = -ENODEV;
+		goto err_out;
+	}
+
+	ioaddr = pci_iomap(pdev, bar, 0);
+	if (!ioaddr) {
+		dev_err(d, "cannot map %s\n", res[bar].type);
+		if (!use_io) {
+			use_io = true;
 			goto retry;
 		}
-		dev->base_addr = (long) ioaddr;
-		tp->regs_len = mmio_len;
+		rc = -ENODEV;
+		goto err_out;
 	}
+	tp->regs_len = io_len;
 	tp->mmio_addr = ioaddr;
 
 	/* Bring old chips out of low-power mode. */
@@ -1035,8 +1009,6 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	dev->hw_features |= NETIF_F_RXALL;
 	dev->hw_features |= NETIF_F_RXFCS;
 
-	dev->irq = pdev->irq;
-
 	/* tp zeroed and aligned in alloc_etherdev */
 	tp = netdev_priv(dev);
 
@@ -1062,9 +1034,9 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 
 	pci_set_drvdata (pdev, dev);
 
-	netdev_info(dev, "%s at 0x%lx, %pM, IRQ %d\n",
+	netdev_info(dev, "%s at 0x%p, %pM, IRQ %d\n",
 		    board_info[ent->driver_data].name,
-		    dev->base_addr, dev->dev_addr, dev->irq);
+		    ioaddr, dev->dev_addr, pdev->irq);
 
 	netdev_dbg(dev, "Identified 8139 chip type '%s'\n",
 		   rtl_chip_info[tp->chipset].name);
@@ -1339,10 +1311,11 @@ static void mdio_write (struct net_device *dev, int phy_id, int location,
 static int rtl8139_open (struct net_device *dev)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
-	int retval;
 	void __iomem *ioaddr = tp->mmio_addr;
+	const int irq = tp->pci_dev->irq;
+	int retval;
 
-	retval = request_irq (dev->irq, rtl8139_interrupt, IRQF_SHARED, dev->name, dev);
+	retval = request_irq(irq, rtl8139_interrupt, IRQF_SHARED, dev->name, dev);
 	if (retval)
 		return retval;
 
@@ -1351,7 +1324,7 @@ static int rtl8139_open (struct net_device *dev)
 	tp->rx_ring = dma_alloc_coherent(&tp->pci_dev->dev, RX_BUF_TOT_LEN,
 					   &tp->rx_ring_dma, GFP_KERNEL);
 	if (tp->tx_bufs == NULL || tp->rx_ring == NULL) {
-		free_irq(dev->irq, dev);
+		free_irq(irq, dev);
 
 		if (tp->tx_bufs)
 			dma_free_coherent(&tp->pci_dev->dev, TX_BUF_TOT_LEN,
@@ -1377,7 +1350,7 @@ static int rtl8139_open (struct net_device *dev)
 		  "%s() ioaddr %#llx IRQ %d GP Pins %02x %s-duplex\n",
 		  __func__,
 		  (unsigned long long)pci_resource_start (tp->pci_dev, 1),
-		  dev->irq, RTL_R8 (MediaStatus),
+		  irq, RTL_R8 (MediaStatus),
 		  tp->mii.full_duplex ? "full" : "half");
 
 	rtl8139_start_thread(tp);
@@ -2240,9 +2213,12 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
  */
 static void rtl8139_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
-	rtl8139_interrupt(dev->irq, dev);
-	enable_irq(dev->irq);
+	struct rtl8139_private *tp = netdev_priv(dev);
+	const int irq = tp->pci_dev->irq;
+
+	disable_irq(irq);
+	rtl8139_interrupt(irq, dev);
+	enable_irq(irq);
 }
 #endif
 
@@ -2295,7 +2271,7 @@ static int rtl8139_close (struct net_device *dev)
 
 	spin_unlock_irqrestore (&tp->lock, flags);
 
-	free_irq (dev->irq, dev);
+	free_irq(tp->pci_dev->irq, dev);
 
 	rtl8139_tx_clear (tp);
 
-- 
1.7.7.6
