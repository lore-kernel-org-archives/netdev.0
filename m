From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/2) skfddi: initialization
Date: Tue, 11 Jan 2005 11:19:17 -0800
Message-ID: <20050111111917.52988b75@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When the skfddi driver was converted to the new PCI netdevice interface,
it never got tested with real hardware. The initialization got broken, this
should fix it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
--- a/drivers/net/skfp/skfddi.c	2004-12-14 11:08:07 -08:00
+++ b/drivers/net/skfp/skfddi.c	2004-12-14 11:08:07 -08:00
@@ -205,7 +205,6 @@
 {
 	struct net_device *dev;
 	struct s_smc *smc;	/* board pointer */
-	unsigned long port, len;
 	void __iomem *mem;
 	int err;
 
@@ -216,62 +215,43 @@
 
 	err = pci_enable_device(pdev);
 	if (err)
+		return err;
+
+	err = pci_request_regions(pdev, "skfddi");
+	if (err)
 		goto err_out1;
 
+	pci_set_master(pdev);
 
 #ifdef MEM_MAPPED_IO
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		printk(KERN_ERR "skfp: region is not an MMIO resource\n");
 		err = -EIO;
-		goto err_out1;
+		goto err_out2;
 	}
-	port = pci_resource_start(pdev, 0);
-	len = pci_resource_len(pdev, 0);
 
-	if (len < 0x4000) {
-		printk(KERN_ERR "skfp: Invalid PCI region size: %lu\n", len);
-		err = -EIO;
-		goto err_out1;
-	}
+	mem = ioremap(pci_resource_start(pdev, 0), 0x4000);
 #else
 	if (!(pci_resource_flags(pdev, 1) & IO_RESOURCE_IO)) {
 		printk(KERN_ERR "skfp: region is not PIO resource\n");
 		err = -EIO;
-		goto err_out1;
+		goto err_out2;
 	}
 
-	port = pci_resource_start(pdev, 1);
-	len = pci_resource_len(pdev, 1);
-	if (len < FP_IO_LEN) {
-		printk(KERN_ERR "skfp: Invalid PCI region size: %d\n",
-		       io_len);
+	mem = ioport_map(pci_resource_start(pdev, 1), FP_IO_LEN);
+#endif
+	if (!mem) {
+		printk(KERN_ERR "skfp:  Unable to map register, "
+				"FDDI adapter will be disabled.\n");
 		err = -EIO;
-		goto err_out1;
+		goto err_out2;
 	}
-#endif
-	err = pci_request_regions(pdev, "skfddi");
-	if (err)
-		goto err_out1;
-
-	pci_set_master(pdev);
 
 	dev = alloc_fddidev(sizeof(struct s_smc));
 	if (!dev) {
 		printk(KERN_ERR "skfp: Unable to allocate fddi device, "
 				"FDDI adapter will be disabled.\n");
 		err = -ENOMEM;
-		goto err_out2;
-	}
-
-#ifdef MEM_MAPPED_IO
-	mem = ioremap(port, len);
-#else
-	mem =ioport_map(port, len);
-#endif
-	if (!mem) {
-		printk(KERN_ERR "skfp:  Unable to map register, "
-				"FDDI adapter will be disabled.\n");
-		err = -EIO;
 		goto err_out3;
 	}
 
@@ -331,16 +311,17 @@
 	pci_free_consistent(pdev, MAX_FRAME_SIZE,
 			    smc->os.LocalRxBuffer, smc->os.LocalRxBufferDMA);
 err_out4:
+	free_netdev(dev);
+err_out3:
 #ifdef MEM_MAPPED_IO
-	iounmap(smc->hw.iop);
+	iounmap(mem);
 #else
-	ioport_unmap(smc->hw.iop);
+	ioport_unmap(mem);
 #endif
-err_out3:
-	free_netdev(dev);
 err_out2:
 	pci_release_regions(pdev);
 err_out1:
+	pci_disable_device(pdev);
 	return err;
 }
 
@@ -376,6 +357,7 @@
 	pci_release_regions(pdev);
 	free_netdev(p);
 
+	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 }
 
