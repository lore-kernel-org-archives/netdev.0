From: Dave Jones <davej@redhat.com>
Subject: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Thu, 29 May 2008 11:07:52 -0400
Message-ID: <20080529150752.GB8247@redhat.com>
References: <20080429171403.GA21035@redhat.com> <48177905.4000409@garzik.org> <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290AbYE2PPT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 11:15:19 -0400
Content-Disposition: inline
In-Reply-To: <4818546C.4060703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make PIO/MMIO a runtime thing via a module parameter.
This is needed to support devices that only work with PIO
without penalising devices that work fine with MMIO in
distro kernels.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 53bd903..09ace39 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -120,11 +120,6 @@
                                  NETIF_MSG_LINK)
 
 
-/* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
-#ifdef CONFIG_8139TOO_PIO
-#define USE_IO_OPS 1
-#endif
-
 /* define to 1, 2 or 3 to enable copious debugging info */
 #define RTL8139_DEBUG 0
 
@@ -156,6 +151,9 @@
 static int media[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 
+/* Whether to use MMIO or PIO. Default to MMIO. */
+static int use_pio;
+
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
    The RTL chips use a 64 element hash table based on the Ethernet CRC.  */
 static int multicast_filter_limit = 32;
@@ -615,6 +613,7 @@ MODULE_DESCRIPTION ("RealTek RTL-8139 Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+module_param(use_pio, int, 0);
 module_param(multicast_filter_limit, int, 0);
 module_param_array(media, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
@@ -710,14 +709,13 @@ static void __rtl8139_cleanup_dev (struct net_device *dev)
 	assert (tp->pci_dev != NULL);
 	pdev = tp->pci_dev;
 
-#ifdef USE_IO_OPS
-	if (tp->mmio_addr)
-		ioport_unmap (tp->mmio_addr);
-#else
-	if (tp->mmio_addr)
-		pci_iounmap (pdev, tp->mmio_addr);
-#endif /* USE_IO_OPS */
-
+	if (use_pio) {
+		if (tp->mmio_addr)
+			ioport_unmap (tp->mmio_addr);
+	} else {
+		if (tp->mmio_addr)
+			pci_iounmap (pdev, tp->mmio_addr);
+	}
 	/* it's ok to call this even if we have no regions to free */
 	pci_release_regions (pdev);
 
@@ -791,32 +789,32 @@ static int __devinit rtl8139_init_board (struct pci_dev *pdev,
 	DPRINTK("PIO region size == 0x%02X\n", pio_len);
 	DPRINTK("MMIO region size == 0x%02lX\n", mmio_len);
 
-#ifdef USE_IO_OPS
-	/* make sure PCI base addr 0 is PIO */
-	if (!(pio_flags & IORESOURCE_IO)) {
-		dev_err(&pdev->dev, "region #0 not a PIO resource, aborting\n");
-		rc = -ENODEV;
-		goto err_out;
-	}
-	/* check for weird/broken PCI region reporting */
-	if (pio_len < RTL_MIN_IO_SIZE) {
-		dev_err(&pdev->dev, "Invalid PCI I/O region size(s), aborting\n");
-		rc = -ENODEV;
-		goto err_out;
-	}
-#else
-	/* make sure PCI base addr 1 is MMIO */
-	if (!(mmio_flags & IORESOURCE_MEM)) {
-		dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
-		rc = -ENODEV;
-		goto err_out;
-	}
-	if (mmio_len < RTL_MIN_IO_SIZE) {
-		dev_err(&pdev->dev, "Invalid PCI mem region size(s), aborting\n");
-		rc = -ENODEV;
-		goto err_out;
+	if (use_pio) {
+		/* make sure PCI base addr 0 is PIO */
+		if (!(pio_flags & IORESOURCE_IO)) {
+			dev_err(&pdev->dev, "region #0 not a PIO resource, aborting\n");
+			rc = -ENODEV;
+			goto err_out;
+		}
+		/* check for weird/broken PCI region reporting */
+		if (pio_len < RTL_MIN_IO_SIZE) {
+			dev_err(&pdev->dev, "Invalid PCI I/O region size(s), aborting\n");
+			rc = -ENODEV;
+			goto err_out;
+		}
+	} else {
+		/* make sure PCI base addr 1 is MMIO */
+		if (!(mmio_flags & IORESOURCE_MEM)) {
+			dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
+			rc = -ENODEV;
+			goto err_out;
+		}
+		if (mmio_len < RTL_MIN_IO_SIZE) {
+			dev_err(&pdev->dev, "Invalid PCI mem region size(s), aborting\n");
+			rc = -ENODEV;
+			goto err_out;
+		}
 	}
-#endif
 
 	rc = pci_request_regions (pdev, DRV_NAME);
 	if (rc)
@@ -826,28 +824,28 @@ static int __devinit rtl8139_init_board (struct pci_dev *pdev,
 	/* enable PCI bus-mastering */
 	pci_set_master (pdev);
 
-#ifdef USE_IO_OPS
-	ioaddr = ioport_map(pio_start, pio_len);
-	if (!ioaddr) {
-		dev_err(&pdev->dev, "cannot map PIO, aborting\n");
-		rc = -EIO;
-		goto err_out;
-	}
-	dev->base_addr = pio_start;
-	tp->mmio_addr = ioaddr;
-	tp->regs_len = pio_len;
-#else
-	/* ioremap MMIO region */
-	ioaddr = pci_iomap(pdev, 1, 0);
-	if (ioaddr == NULL) {
-		dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
-		rc = -EIO;
-		goto err_out;
+	if (use_pio) {
+		ioaddr = ioport_map(pio_start, pio_len);
+		if (!ioaddr) {
+			dev_err(&pdev->dev, "cannot map PIO, aborting\n");
+			rc = -EIO;
+			goto err_out;
+		}
+		dev->base_addr = pio_start;
+		tp->mmio_addr = ioaddr;
+		tp->regs_len = pio_len;
+	} else {
+		/* ioremap MMIO region */
+		ioaddr = pci_iomap(pdev, 1, 0);
+		if (ioaddr == NULL) {
+			dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
+			rc = -EIO;
+			goto err_out;
+		}
+		dev->base_addr = (long) ioaddr;
+		tp->mmio_addr = ioaddr;
+		tp->regs_len = mmio_len;
 	}
-	dev->base_addr = (long) ioaddr;
-	tp->mmio_addr = ioaddr;
-	tp->regs_len = mmio_len;
-#endif /* USE_IO_OPS */
 
 	/* Bring old chips out of low-power mode. */
 	RTL_W8 (HltClk, 'R');
@@ -2383,20 +2381,24 @@ static void rtl8139_set_msglevel(struct net_device *dev, u32 datum)
 	np->msg_enable = datum;
 }
 
-/* TODO: we are too slack to do reg dumping for pio, for now */
-#ifdef CONFIG_8139TOO_PIO
-#define rtl8139_get_regs_len	NULL
-#define rtl8139_get_regs	NULL
-#else
 static int rtl8139_get_regs_len(struct net_device *dev)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
+	struct rtl8139_private *np;
+	/* TODO: we are too slack to do reg dumping for pio, for now */
+	if (use_pio)
+		return 0;
+	np = netdev_priv(dev);
 	return np->regs_len;
 }
 
 static void rtl8139_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *regbuf)
 {
-	struct rtl8139_private *np = netdev_priv(dev);
+	struct rtl8139_private *np;
+
+	/* TODO: we are too slack to do reg dumping for pio, for now */
+	if (use_pio)
+		return;
+	np = netdev_priv(dev);
 
 	regs->version = RTL_REGS_VER;
 
@@ -2404,7 +2406,6 @@ static void rtl8139_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	memcpy_fromio(regbuf, np->mmio_addr, regs->len);
 	spin_unlock_irq(&np->lock);
 }
-#endif /* CONFIG_8139TOO_MMIO */
 
 static int rtl8139_get_sset_count(struct net_device *dev, int sset)
 {
@@ -2610,6 +2611,11 @@ static int __init rtl8139_init_module (void)
 	printk (KERN_INFO RTL8139_DRIVER_NAME "\n");
 #endif
 
+	/* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
+#ifdef CONFIG_8139TOO_PIO
+	use_pio = 1;
+#endif
+
 	return pci_register_driver(&rtl8139_pci_driver);
 }
 

-- 
http://www.codemonkey.org.uk
