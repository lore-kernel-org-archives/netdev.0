From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/8) wanxl - hdlc device conversion
Date: Tue, 2 Dec 2003 14:02:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202140223.636f178d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Halas <khc@pm.waw.pl>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1495  -> 1.1496 
#	drivers/net/wan/wanxl.c	1.2     -> 1.3    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/26	shemminger@osdl.org	1.1496
# Convert from embedded hdlc_device with embedded net_device to
# hdlc_device pointer. 
# Use explicit error unwind goto's to handle early errors in initialization.
# C99 initializers.
# --------------------------------------------
#
diff -Nru a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
--- a/drivers/net/wan/wanxl.c	Wed Nov 26 12:37:49 2003
+++ b/drivers/net/wan/wanxl.c	Wed Nov 26 12:37:50 2003
@@ -51,7 +51,7 @@
 
 
 typedef struct {
-	hdlc_device hdlc;	/* HDLC device struct - must be first */
+	hdlc_device *hdlc;	/* HDLC device struct - must be first */
 	struct card_t *card;
 	spinlock_t lock;	/* for wanxl_xmit */
         int node;		/* physical port #0 - 3 */
@@ -84,7 +84,7 @@
 
 static inline port_t* hdlc_to_port(hdlc_device *hdlc)
 {
-        return (port_t*)hdlc;
+        return hdlc->dev_data;
 }
 
 
@@ -96,13 +96,13 @@
 
 static inline struct net_device *port_to_dev(port_t* port)
 {
-        return hdlc_to_dev(&port->hdlc);
+        return hdlc_to_dev(port->hdlc);
 }
 
 
 static inline const char* port_name(port_t *port)
 {
-	return hdlc_to_name((hdlc_device*)port);
+	return hdlc_to_name(port->hdlc);
 }
 
 
@@ -172,7 +172,7 @@
 	printk(KERN_INFO "%s: %s%s module, %s cable%s%s\n",
 	       port_name(port), pm, dte, cable, dsr, dcd);
 
-	hdlc_set_carrier(value & STATUS_CABLE_DCD, &port->hdlc);
+	hdlc_set_carrier(value & STATUS_CABLE_DCD, port->hdlc);
 }
 
 
@@ -191,13 +191,13 @@
 			return;
 
 		case PACKET_UNDERRUN:
-			port->hdlc.stats.tx_errors++;
-			port->hdlc.stats.tx_fifo_errors++;
+			port->hdlc->stats.tx_errors++;
+			port->hdlc->stats.tx_fifo_errors++;
 			break;
 
 		default:
-			port->hdlc.stats.tx_packets++;
-			port->hdlc.stats.tx_bytes += skb->len;
+			port->hdlc->stats.tx_packets++;
+			port->hdlc->stats.tx_bytes += skb->len;
 		}
                 desc->stat = PACKET_EMPTY; /* Free descriptor */
 		pci_unmap_single(port->card->pdev, desc->address, skb->len,
@@ -224,7 +224,7 @@
 			       " nonexistent port\n", card_name(card->pdev));
 
 		else if (!skb)
-			port->hdlc.stats.rx_dropped++;
+			port->hdlc->stats.rx_dropped++;
 
 		else {
 			pci_unmap_single(card->pdev, desc->address,
@@ -236,8 +236,8 @@
 			       skb->len);
 			debug_frame(skb);
 #endif
-			port->hdlc.stats.rx_packets++;
-			port->hdlc.stats.rx_bytes += skb->len;
+			port->hdlc->stats.rx_packets++;
+			port->hdlc->stats.rx_bytes += skb->len;
 			skb->mac.raw = skb->data;
 			skb->dev = dev;
 			dev->last_rx = jiffies;
@@ -530,7 +530,7 @@
 
 
 
-static void wanxl_pci_remove_one(struct pci_dev *pdev)
+static void __devexit wanxl_pci_remove_one(struct pci_dev *pdev)
 {
 	card_t *card = pci_get_drvdata(pdev);
 	int i;
@@ -539,9 +539,13 @@
 	if (card->irq)
 		free_irq(card->irq, card);
 
-	for (i = 0; i < 4; i++)
-		if (card->ports[i])
-			unregister_hdlc_device(&card->ports[i]->hdlc);
+	for (i = 0; i < 4; i++) {
+		port_t *port = card->ports[i];
+		if (port) {
+			unregister_hdlc_device(port->hdlc);
+			free_hdlc_device(port->hdlc);
+		}
+	}
 
 	wanxl_reset(card);
 
@@ -577,7 +581,7 @@
 	u32 plx_phy;		/* PLX PCI base address */
 	u32 mem_phy;		/* memory PCI base addr */
 	u8 *mem;		/* memory virtual base addr */
-	int i, ports, alloc_size;
+	int i, err, ports;
 
 #ifndef MODULE
 	static int printed_version;
@@ -587,9 +591,9 @@
 	}
 #endif
 
-	i = pci_enable_device(pdev);
-	if (i)
-		return i;
+	err = pci_enable_device(pdev);
+	if (err)
+		goto err_1;
 
 	/* QUICC can only access first 256 MB of host RAM directly,
 	   but PLX9060 DMA does 32-bits for actual packet data transfers */
@@ -601,28 +605,28 @@
 	if (pci_set_consistent_dma_mask(pdev, 0x0FFFFFFF) ||
 	    pci_set_dma_mask(pdev, 0x0FFFFFFF)) {
 		printk(KERN_ERR "No usable DMA configuration\n");
-		return -EIO;
+		err =  -EIO;
+		goto err_1;
 	}
 
-	i = pci_request_regions(pdev, "wanXL");
-	if (i)
-		return i;
+	err = pci_request_regions(pdev, "wanXL");
+	if (err)
+		goto err_1;
 
 	switch (pdev->device) {
 	case PCI_DEVICE_ID_SBE_WANXL100: ports = 1; break;
 	case PCI_DEVICE_ID_SBE_WANXL200: ports = 2; break;
 	default: ports = 4;
 	}
-
-	alloc_size = sizeof(card_t) + ports * sizeof(port_t);
-	card = kmalloc(alloc_size, GFP_KERNEL);
+	
+	card = kmalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
 		printk(KERN_ERR "wanXL %s: unable to allocate memory\n",
 		       card_name(pdev));
-		pci_release_regions(pdev);
-		return -ENOBUFS;
+		err = -ENOBUFS;
+		goto err_2;
 	}
-	memset(card, 0, alloc_size);
+	memset(card, 0, sizeof(card_t));
 
 	pci_set_drvdata(pdev, card);
 	card->pdev = pdev;
@@ -631,8 +635,8 @@
 	card->status = pci_alloc_consistent(pdev, sizeof(card_status_t),
 					    &card->status_address);
 	if (card->status == NULL) {
-		wanxl_pci_remove_one(pdev);
-		return -ENOBUFS;
+		err = -ENOBUFS;
+		goto err_3;
 	}
 
 #ifdef DEBUG_PCI
@@ -647,8 +651,8 @@
 	if (pci_set_consistent_dma_mask(pdev, 0xFFFFFFFF) ||
 	    pci_set_dma_mask(pdev, 0xFFFFFFFF)) {
 		printk(KERN_ERR "No usable DMA configuration\n");
-		wanxl_pci_remove_one(pdev);
-		return -EIO;
+		err = -EIO;
+		goto err_4;
 	}
 
 	/* set up PLX mapping */
@@ -660,12 +664,12 @@
 #endif
 
 	timeout = jiffies + 20 * HZ;
+	err = -ENODEV;
 	while ((stat = readl(card->plx + PLX_MAILBOX_0)) != 0) {
 		if (time_before(timeout, jiffies)) {
 			printk(KERN_WARNING "wanXL %s: timeout waiting for"
 			       " PUTS to complete\n", card_name(pdev));
-			wanxl_pci_remove_one(pdev);
-			return -ENODEV;
+			goto err_4;
 		}
 
 		switch(stat & 0xC0) {
@@ -676,8 +680,7 @@
 		default:
 			printk(KERN_WARNING "wanXL %s: PUTS test 0x%X"
 			       " failed\n", card_name(pdev), stat & 0x30);
-			wanxl_pci_remove_one(pdev);
-			return -ENODEV;
+			goto err_4;
 		}
 
 		schedule();
@@ -697,50 +700,61 @@
 		       " (%u bytes detected, %u bytes required)\n",
 		       card_name(pdev), ramsize, BUFFERS_ADDR +
 		       (TX_BUFFERS + RX_BUFFERS) * BUFFER_LENGTH * ports);
-		wanxl_pci_remove_one(pdev);
-		return -ENODEV;
+		goto err_4;
 	}
 
 	if (wanxl_puts_command(card, MBX1_CMD_BSWAP)) {
 		printk(KERN_WARNING "wanXL %s: unable to Set Byte Swap"
 		       " Mode\n", card_name(pdev));
-		wanxl_pci_remove_one(pdev);
-		return -ENODEV;
+		goto err_4;
 	}
 
 	for (i = 0; i < ports; i++) {
-		port_t *port = (void *)card + sizeof(card_t) +
-			i * sizeof(port_t);
-		struct net_device *dev = hdlc_to_dev(&port->hdlc);
+		hdlc_device *hdlc;
+		port_t *port;
+		struct net_device *dev;
+
+		hdlc = alloc_hdlc_device(sizeof(*port));
+		if (!hdlc) {
+			err = -ENOBUFS;
+			goto err_5;
+		}
+
+		port = hdlc->dev_data;
+		port->hdlc = hdlc;
+		dev = hdlc_to_dev(hdlc);
+
 		spin_lock_init(&port->lock);
 		SET_MODULE_OWNER(dev);
 		dev->tx_queue_len = 50;
 		dev->do_ioctl = wanxl_ioctl;
 		dev->open = wanxl_open;
 		dev->stop = wanxl_close;
-		port->hdlc.attach = wanxl_attach;
-		port->hdlc.xmit = wanxl_xmit;
-		if(register_hdlc_device(&port->hdlc)) {
+		dev->get_stats = wanxl_get_stats;
+		hdlc->attach = wanxl_attach;
+		hdlc->xmit = wanxl_xmit;
+		port->card = card;
+		port->node = i;
+
+		err = register_hdlc_device(hdlc);
+		if (err) {
 			printk(KERN_ERR "wanXL %s: unable to register hdlc"
 			       " device\n", card_name(pdev));
-			wanxl_pci_remove_one(pdev);
-			return -ENOBUFS;
+			goto err_5;
 		}
 		card->ports[i] = port;
-		dev->get_stats = wanxl_get_stats;
-		port->card = card;
-		port->node = i;
 		get_status(port)->clocking = CLOCK_EXT;
 	}
 
 	for (i = 0; i < RX_QUEUE_LENGTH; i++) {
 		struct sk_buff *skb = dev_alloc_skb(BUFFER_LENGTH);
 		card->rx_skbs[i] = skb;
-		if (skb)
-			card->status->rx_descs[i].address =
-				pci_map_single(card->pdev, skb->data,
-					       BUFFER_LENGTH,
-					       PCI_DMA_FROMDEVICE);
+		if (!skb)
+			goto err_6;
+		card->status->rx_descs[i].address =
+			pci_map_single(card->pdev, skb->data,
+				       BUFFER_LENGTH,
+				       PCI_DMA_FROMDEVICE);
 	}
 
 	mem = ioremap_nocache(mem_phy, PDM_OFFSET + sizeof(firmware));
@@ -760,8 +774,8 @@
 	if (wanxl_puts_command(card, MBX1_CMD_ABORTJ)) {
 		printk(KERN_WARNING "wanXL %s: unable to Abort and Jump\n",
 		       card_name(pdev));
-		wanxl_pci_remove_one(pdev);
-		return -ENODEV;
+		err = -ENODEV;
+		goto err_6;
 	}
 
 	stat = 0;
@@ -770,13 +784,13 @@
 		if ((stat = readl(card->plx + PLX_MAILBOX_5)) != 0)
 			break;
 		schedule();
-	}while (time_after(timeout, jiffies));
+	} while (time_after(timeout, jiffies));
 
 	if (!stat) {
 		printk(KERN_WARNING "wanXL %s: timeout while initializing card"
 		       "firmware\n", card_name(pdev));
-		wanxl_pci_remove_one(pdev);
-		return -ENODEV;
+		err = -ENODEV;
+		goto err_6;
 	}
 
 #if DETECT_RAM
@@ -796,12 +810,40 @@
 	if(request_irq(pdev->irq, wanxl_intr, SA_SHIRQ, "wanXL", card)) {
 		printk(KERN_WARNING "wanXL %s: could not allocate IRQ%i.\n",
 		       card_name(pdev), pdev->irq);
-		wanxl_pci_remove_one(pdev);
-		return -EBUSY;
+		err = -EBUSY;
+		goto err_7;
 	}
 	card->irq = pdev->irq;
 
 	return 0;
+
+ err_7:
+	wanxl_reset(card);
+ err_6:
+	for (i = 0; i < RX_QUEUE_LENGTH; i++)
+		if (card->rx_skbs[i]) {
+			pci_unmap_single(card->pdev,
+					 card->status->rx_descs[i].address,
+					 BUFFER_LENGTH, PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(card->rx_skbs[i]);
+		}
+ err_5:
+	for (i = 0; i < ports; i++) {
+		port_t *port = card->ports[i];
+		if (port) {
+			unregister_hdlc_device(port->hdlc);
+			free_hdlc_device(port->hdlc);
+		}
+	}
+ err_4:
+	pci_free_consistent(pdev, sizeof(card_status_t),
+			    card->status, card->status_address);
+ err_3:
+	kfree(card);		
+ err_2:
+	pci_release_regions(pdev);
+ err_1:
+	return err;
 }
 
 static struct pci_device_id wanxl_pci_tbl[] __devinitdata = {
@@ -816,10 +858,10 @@
 
 
 static struct pci_driver wanxl_pci_driver = {
-	name:           "wanXL",
-	id_table:       wanxl_pci_tbl,
-	probe:          wanxl_pci_init_one,
-	remove:         wanxl_pci_remove_one,
+	.name 		= "wanXL",
+	.id_table	= wanxl_pci_tbl,
+	.probe		= wanxl_pci_init_one,
+	.remove		= __devexit_p(wanxl_pci_remove_one),
 };
 
 
