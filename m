From: Roger Luethi <rl@hellgate.ch>
Subject: [6/9][PATCH 2.6] Return codes for rhine_init_one
Date: Wed, 2 Jun 2004 13:58:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602115850.GA17556@k3.hellgate.ch>
References: <20040602115703.GA16079@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040602115703.GA16079@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use return codes in rhine_init_one instead of -ENODEV for all errors.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -616,7 +616,7 @@
 {
 	struct net_device *dev;
 	struct rhine_private *rp;
-	int i, option;
+	int i, option, rc;
 	int chip_id = (int) ent->driver_data;
 	static int card_idx = -1;
 	long ioaddr;
@@ -638,11 +638,13 @@
 	option = card_idx < MAX_UNITS ? options[card_idx] : 0;
 	io_size = rhine_chip_info[chip_id].io_size;
 
-	if (pci_enable_device(pdev))
+	rc = pci_enable_device(pdev);
+	if (rc)
 		goto err_out;
 
 	/* this should always be supported */
-	if (pci_set_dma_mask(pdev, 0xffffffff)) {
+	rc = pci_set_dma_mask(pdev, 0xffffffff);
+	if (rc) {
 		printk(KERN_ERR "32-bit PCI DMA addresses not supported by "
 		       "the card!?\n");
 		goto err_out;
@@ -651,6 +653,7 @@
 	/* sanity check */
 	if ((pci_resource_len(pdev, 0) < io_size) ||
 	    (pci_resource_len(pdev, 1) < io_size)) {
+		rc = -EIO;
 		printk(KERN_ERR "Insufficient PCI resources, aborting\n");
 		goto err_out;
 	}
@@ -662,6 +665,7 @@
 
 	dev = alloc_etherdev(sizeof(*rp));
 	if (dev == NULL) {
+		rc = -ENOMEM;
 		printk(KERN_ERR "init_ethernet failed for card #%d\n",
 		       card_idx);
 		goto err_out;
@@ -669,7 +673,8 @@
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	if (pci_request_regions(pdev, shortname))
+	rc = pci_request_regions(pdev, shortname);
+	if (rc)
 		goto err_out_free_netdev;
 
 #ifdef USE_MMIO
@@ -678,6 +683,7 @@
 
 	ioaddr = (long) ioremap(memaddr, io_size);
 	if (!ioaddr) {
+		rc = -EIO;
 		printk(KERN_ERR "ioremap failed for device %s, region 0x%X "
 		       "@ 0x%lX\n", pci_name(pdev), io_size, memaddr);
 		goto err_out_free_res;
@@ -690,6 +696,7 @@
 		unsigned char a = inb(ioaddr0+reg);
 		unsigned char b = readb(ioaddr+reg);
 		if (a != b) {
+			rc = -EIO;
 			printk(KERN_ERR "MMIO do not match PIO [%02x] "
 			       "(%02x != %02x)\n", reg, a, b);
 			goto err_out_unmap;
@@ -736,6 +743,7 @@
 		dev->dev_addr[i] = readb(ioaddr + StationAddr + i);
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
+		rc = -EIO;
 		printk(KERN_ERR "Invalid MAC address for card #%d\n", card_idx);
 		goto err_out_unmap;
 	}
@@ -787,8 +795,8 @@
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
 
 	/* dev->name not defined before register_netdev()! */
-	i = register_netdev(dev);
-	if (i)
+	rc = register_netdev(dev);
+	if (rc)
 		goto err_out_unmap;
 
 	/* The lower four bits are the media type. */
@@ -871,7 +879,7 @@
 err_out_free_netdev:
 	free_netdev(dev);
 err_out:
-	return -ENODEV;
+	return rc;
 }
 
 static int alloc_ring(struct net_device* dev)
