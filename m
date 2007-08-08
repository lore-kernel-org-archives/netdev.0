From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 3/3] 8139too: clean up I/O remapping
Date: Wed, 8 Aug 2007 02:45:39 -0400
Message-ID: <20070808064539.GB16645@havoc.gtf.org>
References: <20070808064440.GA16595@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934232AbXHHGqA@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070808064440.GA16595@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 9ee6b32a47b9abc565466a9c3b127a5246b452e5
Author: Jeff Garzik <jeff@garzik.org>
Date:   Wed Aug 8 02:42:47 2007 -0400

    [netdrvr] 8139too: clean up I/O remapping
    
    * no need to explicitly use ioport_map() for PIO.  pci_iomap()
      works just fine for both PIO and MMIO.  This permits deletion
      of redundant code.
    
    * add 'use_pio' module parameter to enable PIO mode without
      rebuilding the kernel.
    
    * change a few other module options' sysfs perms to enable visibility
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

 drivers/net/8139too.c |   50 +++++++++++++++++++++-----------------------------
 1 file changed, 21 insertions(+), 29 deletions(-)

9ee6b32a47b9abc565466a9c3b127a5246b452e5
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 87ecaf8..761f716 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -121,8 +121,15 @@
 
 
 /* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected */
+enum rtl_bar_map_info {
+	rtl_pio_bar	= 0,	/* PCI BAR #0: PIO */
+	rtl_mmio_bar	= 1,	/* PCI BAR #1: MMIO */
+};
+
 #ifdef CONFIG_8139TOO_PIO
-#define USE_IO_OPS 1
+static int use_pio	= 1;
+#else
+static int use_pio;
 #endif
 
 /* define to 1, 2 or 3 to enable copious debugging info */
@@ -613,14 +620,17 @@ MODULE_DESCRIPTION ("RealTek RTL-8139 Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-module_param(multicast_filter_limit, int, 0);
+module_param(multicast_filter_limit, int, 0444);
 module_param_array(media, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
-module_param(debug, int, 0);
-MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
+module_param(debug, int, 0444);
+module_param(use_pio, int, 0444);
+
 MODULE_PARM_DESC (multicast_filter_limit, "8139too maximum number of filtered multicast addresses");
 MODULE_PARM_DESC (media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
 MODULE_PARM_DESC (full_duplex, "8139too: Force full duplex for board(s) (1)");
+MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
+MODULE_PARM_DESC (use_pio, "Non-zero to enable PIO (rather than MMIO) register mapping");
 
 static int read_eeprom (void __iomem *ioaddr, int location, int addr_len);
 static int rtl8139_open (struct net_device *dev);
@@ -708,13 +718,7 @@ static void __rtl8139_cleanup_dev (struct net_device *dev)
 	assert (tp->pci_dev != NULL);
 	pdev = tp->pci_dev;
 
-#ifdef USE_IO_OPS
-	if (tp->mmio_addr)
-		ioport_unmap (tp->mmio_addr);
-#else
-	if (tp->mmio_addr)
-		pci_iounmap (pdev, tp->mmio_addr);
-#endif /* USE_IO_OPS */
+	pci_iounmap (pdev, tp->mmio_addr);
 
 	/* it's ok to call this even if we have no regions to free */
 	pci_release_regions (pdev);
@@ -790,32 +794,32 @@ static int __devinit rtl8139_init_board (struct pci_dev *pdev,
 	DPRINTK("PIO region size == 0x%02X\n", pio_len);
 	DPRINTK("MMIO region size == 0x%02lX\n", mmio_len);
 
-#ifdef USE_IO_OPS
 	/* make sure PCI base addr 0 is PIO */
 	if (!(pio_flags & IORESOURCE_IO)) {
 		dev_err(&pdev->dev, "region #0 not a PIO resource, aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
+
 	/* check for weird/broken PCI region reporting */
 	if (pio_len < RTL_MIN_IO_SIZE) {
 		dev_err(&pdev->dev, "Invalid PCI I/O region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
-#else
+
 	/* make sure PCI base addr 1 is MMIO */
 	if (!(mmio_flags & IORESOURCE_MEM)) {
 		dev_err(&pdev->dev, "region #1 not an MMIO resource, aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
+
 	if (mmio_len < RTL_MIN_IO_SIZE) {
 		dev_err(&pdev->dev, "Invalid PCI mem region size(s), aborting\n");
 		rc = -ENODEV;
 		goto err_out;
 	}
-#endif
 
 	rc = pci_request_regions (pdev, DRV_NAME);
 	if (rc)
@@ -825,28 +829,16 @@ static int __devinit rtl8139_init_board (struct pci_dev *pdev,
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
+	/* iomap MMIO region */
+	ioaddr = pci_iomap(pdev, use_pio ? rtl_pio_bar : rtl_mmio_bar, 0);
 	if (ioaddr == NULL) {
-		dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
+		dev_err(&pdev->dev, "cannot map I/O regions, aborting\n");
 		rc = -EIO;
 		goto err_out;
 	}
 	dev->base_addr = (long) ioaddr;
 	tp->mmio_addr = ioaddr;
 	tp->regs_len = mmio_len;
-#endif /* USE_IO_OPS */
 
 	/* Bring old chips out of low-power mode. */
 	RTL_W8 (HltClk, 'R');
