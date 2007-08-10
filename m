From: akpm@linux-foundation.org
Subject: [patch 01/18] revert "8139too: clean up I/O remapping"
Date: Fri, 10 Aug 2007 14:05:05 -0700
Message-ID: <200708102105.l7AL565d008945@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	michal.k.k.piotrowski@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40574 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755430AbXHJVGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:06:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

Revert git-netdev-all's 9ee6b32a47b9abc565466a9c3b127a5246b452e5.  Michal was
getting oopses.

Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/8139too.c |   50 +++++++++++++++++++++++-----------------
 1 files changed, 29 insertions(+), 21 deletions(-)

diff -puN drivers/net/8139too.c~revert-8139too-clean-up-i-o-remapping drivers/net/8139too.c
--- a/drivers/net/8139too.c~revert-8139too-clean-up-i-o-remapping
+++ a/drivers/net/8139too.c
@@ -121,15 +121,8 @@
 
 
 /* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
-enum rtl_bar_map_info {
-	rtl_pio_bar	= 0,	/* PCI BAR #0: PIO */
-	rtl_mmio_bar	= 1,	/* PCI BAR #1: MMIO */
-};
-
 #ifdef CONFIG_8139TOO_PIO
-static int use_pio	= 1;
-#else
-static int use_pio;
+#define USE_IO_OPS 1
 #endif
 
 /* define to 1, 2 or 3 to enable copious debugging info */
@@ -620,17 +613,14 @@ MODULE_DESCRIPTION ("RealTek RTL-8139 Fa
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-module_param(multicast_filter_limit, int, 0444);
+module_param(multicast_filter_limit, int, 0);
 module_param_array(media, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
-module_param(debug, int, 0444);
-module_param(use_pio, int, 0444);
-
+module_param(debug, int, 0);
+MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
 MODULE_PARM_DESC (multicast_filter_limit, "8139too maximum number of filtered multicast addresses");
 MODULE_PARM_DESC (media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
 MODULE_PARM_DESC (full_duplex, "8139too: Force full duplex for board(s) (1)");
-MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
-MODULE_PARM_DESC (use_pio, "Non-zero to enable PIO (rather than MMIO) register mapping");
 
 static int read_eeprom (void __iomem *ioaddr, int location, int addr_len);
 static int rtl8139_open (struct net_device *dev);
@@ -718,7 +708,13 @@ static void __rtl8139_cleanup_dev (struc
 	assert (tp->pci_dev != NULL);
 	pdev = tp->pci_dev;
 
-	pci_iounmap (pdev, tp->mmio_addr);
+#ifdef USE_IO_OPS
+	if (tp->mmio_addr)
+		ioport_unmap (tp->mmio_addr);
+#else
+	if (tp->mmio_addr)
+		pci_iounmap (pdev, tp->mmio_addr);
+#endif /* USE_IO_OPS */
 
 	/* it's ok to call this even if we have no regions to free */
 	pci_release_regions (pdev);
@@ -794,32 +790,32 @@ static int __devinit rtl8139_init_board 
 	DPRINTK("PIO region size == 0x%02X\n", pio_len);
 	DPRINTK("MMIO region size == 0x%02lX\n", mmio_len);
 
+#ifdef USE_IO_OPS
 	/* make sure PCI base addr 0 is PIO */
 	if (!(pio_flags & IORESOURCE_IO)) {
 		dev_err(&pdev->dev, "region #0 not a PIO resource, aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
-
 	/* check for weird/broken PCI region reporting */
 	if (pio_len < RTL_MIN_IO_SIZE) {
 		dev_err(&pdev->dev, "Invalid PCI I/O region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
-
+#else
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(mmio_flags & IORESOURCE_MEM)) {
 		dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
-
 	if (mmio_len < RTL_MIN_IO_SIZE) {
 		dev_err(&pdev->dev, "Invalid PCI mem region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
+#endif
 
 	rc = pci_request_regions (pdev, DRV_NAME);
 	if (rc)
@@ -829,16 +825,28 @@ static int __devinit rtl8139_init_board 
 	/* enable PCI bus-mastering */
 	pci_set_master (pdev);
 
-	/* iomap MMIO region */
-	ioaddr = pci_iomap(pdev, use_pio ? rtl_pio_bar : rtl_mmio_bar, 0);
+#ifdef USE_IO_OPS
+	ioaddr = ioport_map(pio_start, pio_len);
+	if (!ioaddr) {
+		dev_err(&pdev->dev, "cannot map PIO, aborting\n");
+		rc = -EIO;
+		goto err_out;
+	}
+	dev->base_addr = pio_start;
+	tp->mmio_addr = ioaddr;
+	tp->regs_len = pio_len;
+#else
+	/* ioremap MMIO region */
+	ioaddr = pci_iomap(pdev, 1, 0);
 	if (ioaddr == NULL) {
-		dev_err(&pdev->dev, "cannot map I/O regions, aborting\n");
+		dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
 		rc = -EIO;
 		goto err_out;
 	}
 	dev->base_addr = (long) ioaddr;
 	tp->mmio_addr = ioaddr;
 	tp->regs_len = mmio_len;
+#endif /* USE_IO_OPS */
 
 	/* Bring old chips out of low-power mode. */
 	RTL_W8 (HltClk, 'R');
_
