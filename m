From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] xircom_cb -- fix setting statistics after registration
Date: Tue, 14 Oct 2003 11:56:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031014115614.42b86470.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This driver was setting dev->get_statistics after registration and
confusing netdevice sysfs on unload.  The change was to use alloc_etherdev
and defer registration till the device was initialized properly.

This patch has been tested by the original bug reporter.

diff -Nru a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
--- a/drivers/net/tulip/xircom_cb.c	Tue Oct 14 09:34:41 2003
+++ b/drivers/net/tulip/xircom_cb.c	Tue Oct 14 09:34:41 2003
@@ -230,7 +230,8 @@
 	   This way, we can fail gracefully if not enough memory
 	   is available. 
 	 */
-	if ((dev = init_etherdev(NULL, sizeof(struct xircom_private))) == NULL) {
+	dev = alloc_etherdev(sizeof(struct xircom_private));
+	if (!dev) {
 		printk(KERN_ERR "xircom_probe: failed to allocate etherdev\n");
 		goto device_fail;
 	}
@@ -250,7 +251,7 @@
 
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	printk(KERN_INFO "%s: Xircom cardbus revision %i at irq %i \n", dev->name, chip_rev, pdev->irq);
+
 
 	private->dev = dev;
 	private->pdev = pdev;
@@ -259,7 +260,6 @@
 	dev->irq = pdev->irq;
 	dev->base_addr = private->io_port;
 	
-	
 	initialize_card(private);
 	read_mac_address(private);
 	setup_descriptors(private);
@@ -272,7 +272,12 @@
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	pci_set_drvdata(pdev, dev);
 
-	
+	if (register_netdev(dev)) {
+		printk(KERN_ERR "xircom_probe: netdevice registration failed.\n");
+		goto reg_fail;
+	}
+		
+	printk(KERN_INFO "%s: Xircom cardbus revision %i at irq %i \n", dev->name, chip_rev, pdev->irq);
 	/* start the transmitter to get a heartbeat */
 	/* TODO: send 2 dummy packets here */
 	transceiver_voodoo(private);
@@ -287,10 +292,12 @@
 	leave("xircom_probe");
 	return 0;
 
+reg_fail:
+	kfree(private->tx_buffer);
 tx_buf_fail:
 	kfree(private->rx_buffer);
 rx_buf_fail:
-	kfree(dev);
+	free_netdev(dev);
 device_fail:
 	return -ENODEV;
 }
@@ -305,22 +312,16 @@
 static void __devexit xircom_remove(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct xircom_private *card;
+	struct xircom_private *card = dev->priv;
+
 	enter("xircom_remove");
-	if (dev!=NULL) {
-		card=dev->priv;
-		if (card!=NULL) {	
-			if (card->rx_buffer!=NULL)
-				pci_free_consistent(pdev,8192,card->rx_buffer,card->rx_dma_handle);
-			card->rx_buffer = NULL;
-			if (card->tx_buffer!=NULL)
-				pci_free_consistent(pdev,8192,card->tx_buffer,card->tx_dma_handle);
-			card->tx_buffer = NULL;			
-		}
-	}
+	pci_free_consistent(pdev,8192,card->rx_buffer,card->rx_dma_handle);
+	pci_free_consistent(pdev,8192,card->tx_buffer,card->tx_dma_handle);
+
 	release_region(dev->base_addr, 128);
 	unregister_netdev(dev);
 	free_netdev(dev);
+	pci_set_drvdata(pdev, NULL);
 	leave("xircom_remove");
 } 
 
