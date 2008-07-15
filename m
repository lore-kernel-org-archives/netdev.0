From: Dave Jones <davej@redhat.com>
Subject: [1/3] 8139too: Make PIO/MMIO a runtime decision through a module parameter.
Date: Tue, 15 Jul 2008 19:54:53 -0400
Message-ID: <200807152354.m6FNsrk1026943@gelk.kernelslacker.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40656 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754112AbYGPABZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 20:01:25 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m6G01Pgi018282
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 20:01:25 -0400
Received: from file.rdu.redhat.com (file.rdu.redhat.com [10.11.255.147])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m6G01ONH000657
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 20:01:25 -0400
Received: from gelk.kernelslacker.org (vpn-12-217.rdu.redhat.com [10.11.12.217])
	by file.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id m6G01Ng9007000
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 20:01:24 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.2/8.14.2) with ESMTP id m6FNsri6026944
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 19:54:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed to support devices that only work with PIO without penalising devices
that work fine with MMIO in distro kernels.   It also allows us to eventually
use PIO as a fallback when setting up MMIO fails.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 53bd903..b620317 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -98,7 +98,6 @@
 #include <linux/compiler.h>
 #include <linux/pci.h>
 #include <linux/init.h>
-#include <linux/ioport.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/rtnetlink.h>
@@ -120,11 +119,6 @@
                                  NETIF_MSG_LINK)
 
 
-/* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
-#ifdef CONFIG_8139TOO_PIO
-#define USE_IO_OPS 1
-#endif
-
 /* define to 1, 2 or 3 to enable copious debugging info */
 #define RTL8139_DEBUG 0
 
@@ -156,6 +150,13 @@
 static int media[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
 
+/* Whether to use MMIO or PIO. Default to MMIO. */
+#ifdef CONFIG_8139TOO_PIO
+static int use_io = 1;
+#else
+static int use_io = 0;
+#endif
+
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
    The RTL chips use a 64 element hash table based on the Ethernet CRC.  */
 static int multicast_filter_limit = 32;
@@ -615,6 +612,8 @@ MODULE_DESCRIPTION ("RealTek RTL-8139 Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+module_param(use_io, int, 0);
+MODULE_PARM_DESC(use_io, "Force use of I/O access mode. 0=MMIO 1=PIO");
 module_param(multicast_filter_limit, int, 0);
 module_param_array(media, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
@@ -710,13 +708,8 @@ static void __rtl8139_cleanup_dev (struct net_device *dev)
 	assert (tp->pci_dev != NULL);
 	pdev = tp->pci_dev;
 
-#ifdef USE_IO_OPS
-	if (tp->mmio_addr)
-		ioport_unmap (tp->mmio_addr);
-#else
 	if (tp->mmio_addr)
 		pci_iounmap (pdev, tp->mmio_addr);
-#endif /* USE_IO_OPS */
 
 	/* it's ok to call this even if we have no regions to free */
 	pci_release_regions (pdev);
@@ -791,32 +784,32 @@ static int __devinit rtl8139_init_board (struct pci_dev *pdev,
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
+	if (use_io) {
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
@@ -826,28 +819,27 @@ static int __devinit rtl8139_init_board (struct pci_dev *pdev,
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
+	if (use_io) {
+		ioaddr = pci_iomap(pdev, 0, 0);
+		if (!ioaddr) {
+			dev_err(&pdev->dev, "cannot map PIO, aborting\n");
+			rc = -EIO;
+			goto err_out;
+		}
+		dev->base_addr = pio_start;
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
+		tp->regs_len = mmio_len;
 	}
-	dev->base_addr = (long) ioaddr;
 	tp->mmio_addr = ioaddr;
-	tp->regs_len = mmio_len;
-#endif /* USE_IO_OPS */
 
 	/* Bring old chips out of low-power mode. */
 	RTL_W8 (HltClk, 'R');
@@ -2383,20 +2375,24 @@ static void rtl8139_set_msglevel(struct net_device *dev, u32 datum)
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
+	if (use_io)
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
+	if (use_io)
+		return;
+	np = netdev_priv(dev);
 
 	regs->version = RTL_REGS_VER;
 
@@ -2404,7 +2400,6 @@ static void rtl8139_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	memcpy_fromio(regbuf, np->mmio_addr, regs->len);
 	spin_unlock_irq(&np->lock);
 }
-#endif /* CONFIG_8139TOO_MMIO */
 
 static int rtl8139_get_sset_count(struct net_device *dev, int sset)
 {
