From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] 2.6.3 - misc errors in epic100 driver
Date: Sun, 22 Feb 2004 01:22:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040222012206.A8431@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


- extra pci_disable_device() to balance invocation of pci_enable_device()
  in epic_init_one() (-> error path + epic_remove_one());
- lazy return status in epic_init_one(), tsss...;
- memory dedicated to Rx descriptors was not freed after failure of
  register_netdev() in epic_init_one();
- use of epic_pause() in epic_close() offers a small window for a late
  interruption just before the final free_irq(). Let's close the window to
  avoid two epic_rx() threads racing with each other.


 drivers/net/epic100.c |   59 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 40 insertions(+), 19 deletions(-)

diff -puN drivers/net/epic100.c~epic100-fixup drivers/net/epic100.c
--- linux-2.6.3/drivers/net/epic100.c~epic100-fixup	2004-02-22 01:07:47.000000000 +0100
+++ linux-2.6.3-fr/drivers/net/epic100.c	2004-02-22 01:07:47.000000000 +0100
@@ -378,7 +378,7 @@ static int __devinit epic_init_one (stru
 	int irq;
 	struct net_device *dev;
 	struct epic_private *ep;
-	int i, option = 0, duplex = 0;
+	int i, ret, option = 0, duplex = 0;
 	void *ring_space;
 	dma_addr_t ring_dma;
 
@@ -392,29 +392,33 @@ static int __devinit epic_init_one (stru
 	
 	card_idx++;
 	
-	i = pci_enable_device(pdev);
-	if (i)
-		return i;
+	ret = pci_enable_device(pdev);
+	if (ret)
+		goto out;
 	irq = pdev->irq;
 
 	if (pci_resource_len(pdev, 0) < pci_id_tbl[chip_idx].io_size) {
 		printk (KERN_ERR "card %d: no PCI region space\n", card_idx);
-		return -ENODEV;
+		ret = -ENODEV;
+		goto err_out_disable;
 	}
 	
 	pci_set_master(pdev);
 
+	ret = pci_request_regions(pdev, DRV_NAME);
+	if (ret < 0)
+		goto err_out_disable;
+
+	ret = -ENOMEM;
+
 	dev = alloc_etherdev(sizeof (*ep));
 	if (!dev) {
 		printk (KERN_ERR "card %d: no memory for eth device\n", card_idx);
-		return -ENOMEM;
+		goto err_out_free_res;
 	}
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	if (pci_request_regions(pdev, DRV_NAME))
-		goto err_out_free_netdev;
-
 #ifdef USE_IO_OPS
 	ioaddr = pci_resource_start (pdev, 0);
 #else
@@ -422,7 +426,7 @@ static int __devinit epic_init_one (stru
 	ioaddr = (long) ioremap (ioaddr, pci_resource_len (pdev, 1));
 	if (!ioaddr) {
 		printk (KERN_ERR DRV_NAME " %d: ioremap failed\n", card_idx);
-		goto err_out_free_res;
+		goto err_out_free_netdev;
 	}
 #endif
 
@@ -544,9 +548,9 @@ static int __devinit epic_init_one (stru
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->tx_timeout = &epic_tx_timeout;
 
-	i = register_netdev(dev);
-	if (i)
-		goto err_out_unmap_tx;
+	ret = register_netdev(dev);
+	if (ret < 0)
+		goto err_out_unmap_rx;
 
 	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, ",
 		   dev->name, pci_id_tbl[chip_idx].name, ioaddr, dev->irq);
@@ -554,19 +558,24 @@ static int __devinit epic_init_one (stru
 		printk("%2.2x:", dev->dev_addr[i]);
 	printk("%2.2x.\n", dev->dev_addr[i]);
 
-	return 0;
+out:
+	return ret;
 
+err_out_unmap_rx:
+	pci_free_consistent(pdev, RX_TOTAL_SIZE, ep->rx_ring, ep->rx_ring_dma);
 err_out_unmap_tx:
 	pci_free_consistent(pdev, TX_TOTAL_SIZE, ep->tx_ring, ep->tx_ring_dma);
 err_out_iounmap:
 #ifndef USE_IO_OPS
 	iounmap(ioaddr);
-err_out_free_res:
-#endif
-	pci_release_regions(pdev);
 err_out_free_netdev:
+#endif
 	free_netdev(dev);
-	return -ENODEV;
+err_out_free_res:
+	pci_release_regions(pdev);
+err_out_disable:
+	pci_disable_device(pdev);
+	goto out;
 }
 
 /* Serial EEPROM section. */
@@ -592,6 +601,13 @@ err_out_free_netdev:
 #define EE_READ256_CMD	(6 << 8)
 #define EE_ERASE_CMD	(7 << 6)
 
+static void epic_disable_int(struct net_device *dev, struct epic_private *ep)
+{
+	long ioaddr = dev->base_addr;
+
+	outl(0x00000000, ioaddr + INTMASK);
+}
+
 static int __devinit read_eeprom(long ioaddr, int location)
 {
 	int i;
@@ -1270,9 +1286,13 @@ static int epic_close(struct net_device 
 			   dev->name, (int)inl(ioaddr + INTSTAT));
 
 	del_timer_sync(&ep->timer);
-	epic_pause(dev);
+
+	epic_disable_int(dev, ep);
+
 	free_irq(dev->irq, dev);
 
+	epic_pause(dev);
+
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		skb = ep->rx_skbuff[i];
@@ -1470,6 +1490,7 @@ static void __devexit epic_remove_one (s
 #endif
 	pci_release_regions(pdev);
 	free_netdev(dev);
+	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 	/* pci_power_off(pdev, -1); */
 }

_
