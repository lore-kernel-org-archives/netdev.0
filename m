From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: 2.6.x wanXL driver update
Date: Mon, 08 Mar 2004 01:00:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3llmc6wdy.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

Hi,

The attached patch updates wanXL card driver. Please apply to Linux 2.6.
Thanks.

Changes:
* fixed initialization kernel panic, introduced with recent alloc_netdev()
  wan patch,
* wanxl_rx_intr() port# now checked before accessing port structure,
* cleanups etc.
-- 
Krzysztof Halasa, B*FH

--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline; filename=wanxl-2.6.4rc2.patch

--- linux/drivers/net/wan/wanxl.c	26 Feb 2004 16:26:48 -0000	1.5
+++ linux/drivers/net/wan/wanxl.c	7 Mar 2004 21:50:38 -0000
@@ -31,7 +31,7 @@
 
 #include "wanxl.h"
 
-static const char* version = "wanXL serial card driver version: 0.47";
+static const char* version = "wanXL serial card driver version: 0.48";
 
 #define PLX_CTL_RESET   0x40000000 /* adapter reset */
 
@@ -73,12 +73,11 @@
 
 	u8 *plx;		/* PLX PCI9060 virtual base address */
 	struct pci_dev *pdev;	/* for pdev->slot_name */
-	port_t *ports[4];
 	int rx_in;
 	struct sk_buff *rx_skbs[RX_QUEUE_LENGTH];
 	card_status_t *status;	/* shared between host and card */
 	dma_addr_t status_address;
-	port_t __ports[0];
+	port_t ports[0];	/* 1 - 4 port_t structures follow */
 }card_t;
 
 
@@ -89,18 +88,6 @@
 }
 
 
-static inline struct net_device *port_to_dev(port_t* port)
-{
-        return port->dev;
-}
-
-
-static inline const char* port_name(port_t *port)
-{
-	return port_to_dev(port)->name;
-}
-
-
 static inline const char* card_name(struct pci_dev *pdev)
 {
 	return pdev->slot_name;
@@ -165,9 +152,9 @@
 		dte = (value & STATUS_CABLE_DCE) ? " DCE" : " DTE";
 	}
 	printk(KERN_INFO "%s: %s%s module, %s cable%s%s\n",
-	       port_name(port), pm, dte, cable, dsr, dcd);
+	       port->dev->name, pm, dte, cable, dsr, dcd);
 
-	hdlc_set_carrier(value & STATUS_CABLE_DCD, port_to_dev(port));
+	hdlc_set_carrier(value & STATUS_CABLE_DCD, port->dev);
 }
 
 
@@ -175,7 +162,7 @@
 /* Transmit complete interrupt service */
 static inline void wanxl_tx_intr(port_t *port)
 {
-	struct net_device *dev = port_to_dev(port);
+	struct net_device *dev = port->dev;
 	struct net_device_stats *stats = hdlc_stats(dev);
 	while (1) {
                 desc_t *desc = &get_status(port)->tx_descs[port->tx_in];
@@ -210,47 +197,49 @@
 static inline void wanxl_rx_intr(card_t *card)
 {
 	desc_t *desc;
-	while(desc = &card->status->rx_descs[card->rx_in],
-	      desc->stat != PACKET_EMPTY) {
-		struct sk_buff *skb = card->rx_skbs[card->rx_in];
-		port_t *port = card->ports[desc->stat & PACKET_PORT_MASK];
-		struct net_device *dev = port_to_dev(port);
-		struct net_device_stats *stats = hdlc_stats(dev);
-
+	while (desc = &card->status->rx_descs[card->rx_in],
+	       desc->stat != PACKET_EMPTY) {
 		if ((desc->stat & PACKET_PORT_MASK) > card->n_ports)
 			printk(KERN_CRIT "wanXL %s: received packet for"
 			       " nonexistent port\n", card_name(card->pdev));
-
-		else if (!skb)
-			stats->rx_dropped++;
-
 		else {
-			pci_unmap_single(card->pdev, desc->address,
-					 BUFFER_LENGTH, PCI_DMA_FROMDEVICE);
-			skb_put(skb, desc->length);
+			struct sk_buff *skb = card->rx_skbs[card->rx_in];
+			port_t *port = &card->ports[desc->stat &
+						    PACKET_PORT_MASK];
+			struct net_device *dev = port->dev;
+			struct net_device_stats *stats = hdlc_stats(dev);
+
+			if (!skb)
+				stats->rx_dropped++;
+			else {
+				pci_unmap_single(card->pdev, desc->address,
+						 BUFFER_LENGTH,
+						 PCI_DMA_FROMDEVICE);
+				skb_put(skb, desc->length);
 
 #ifdef DEBUG_PKT
-			printk(KERN_DEBUG "%s RX(%i):", port_name(port),
-			       skb->len);
-			debug_frame(skb);
+				printk(KERN_DEBUG "%s RX(%i):", dev->name,
+				       skb->len);
+				debug_frame(skb);
 #endif
-			stats->rx_packets++;
-			stats->rx_bytes += skb->len;
-			skb->mac.raw = skb->data;
-			skb->dev = dev;
-			dev->last_rx = jiffies;
-			skb->protocol = hdlc_type_trans(skb, dev);
-			netif_rx(skb);
-			skb = NULL;
-		}
-
-		if (!skb) {
-			skb = dev_alloc_skb(BUFFER_LENGTH);
-			desc->address = skb ?
-				pci_map_single(card->pdev, skb->data,
-					       BUFFER_LENGTH,
-					       PCI_DMA_FROMDEVICE) : 0;
-			card->rx_skbs[card->rx_in] = skb;
+				stats->rx_packets++;
+				stats->rx_bytes += skb->len;
+				skb->mac.raw = skb->data;
+				skb->dev = dev;
+				dev->last_rx = jiffies;
+				skb->protocol = hdlc_type_trans(skb, dev);
+				netif_rx(skb);
+				skb = NULL;
+			}
+
+			if (!skb) {
+				skb = dev_alloc_skb(BUFFER_LENGTH);
+				desc->address = skb ?
+					pci_map_single(card->pdev, skb->data,
+						       BUFFER_LENGTH,
+						       PCI_DMA_FROMDEVICE) : 0;
+				card->rx_skbs[card->rx_in] = skb;
+			}
 		}
 		desc->stat = PACKET_EMPTY; /* Free descriptor */
 		card->rx_in = (card->rx_in + 1) % RX_QUEUE_LENGTH;
@@ -273,9 +262,9 @@
 
                 for (i = 0; i < card->n_ports; i++) {
 			if (stat & (1 << (DOORBELL_FROM_CARD_TX_0 + i)))
-				wanxl_tx_intr(card->ports[i]);
+				wanxl_tx_intr(&card->ports[i]);
 			if (stat & (1 << (DOORBELL_FROM_CARD_CABLE_0 + i)))
-				wanxl_cable_intr(card->ports[i]);
+				wanxl_cable_intr(&card->ports[i]);
 		}
 		if (stat & (1 << DOORBELL_FROM_CARD_RX))
 			wanxl_rx_intr(card);
@@ -297,8 +286,7 @@
         if (desc->stat != PACKET_EMPTY) {
                 /* should never happen - previous xmit should stop queue */
 #ifdef DEBUG_PKT
-                printk(KERN_DEBUG "%s: transmitter buffer full\n",
-		       port_name(port));
+                printk(KERN_DEBUG "%s: transmitter buffer full\n", dev->name);
 #endif
 		netif_stop_queue(dev);
 		spin_unlock_irq(&port->lock);
@@ -306,7 +294,7 @@
 	}
 
 #ifdef DEBUG_PKT
-	printk(KERN_DEBUG "%s TX(%i):", port_name(port), skb->len);
+	printk(KERN_DEBUG "%s TX(%i):", dev->name, skb->len);
 	debug_frame(skb);
 #endif
 
@@ -324,8 +312,7 @@
 	if (get_status(port)->tx_descs[port->tx_out].stat != PACKET_EMPTY) {
 		netif_stop_queue(dev);
 #ifdef DEBUG_PKT
-		printk(KERN_DEBUG "%s: transmitter buffer full\n",
-		       port_name(port));
+		printk(KERN_DEBUG "%s: transmitter buffer full\n", dev->name);
 #endif
 	}
 
@@ -417,7 +404,7 @@
 	int i;
 
 	if (get_status(port)->open) {
-		printk(KERN_ERR "%s: port already open\n", port_name(port));
+		printk(KERN_ERR "%s: port already open\n", dev->name);
 		return -EIO;
 	}
 	if ((i = hdlc_open(dev)) != 0)
@@ -435,7 +422,7 @@
 			return 0;
 	while (time_after(timeout, jiffies));
 
-	printk(KERN_ERR "%s: unable to open port\n", port_name(port));
+	printk(KERN_ERR "%s: unable to open port\n", dev->name);
 	/* ask the card to close the port, should it be still alive */
 	writel(1 << (DOORBELL_TO_CARD_CLOSE_0 + port->node), dbr);
 	return -EFAULT;
@@ -461,7 +448,7 @@
 	while (time_after(timeout, jiffies));
 
 	if (get_status(port)->open)
-		printk(KERN_ERR "%s: unable to close port\n", port_name(port));
+		printk(KERN_ERR "%s: unable to close port\n", dev->name);
 
 	for (i = 0; i < TX_BUFFERS; i++) {
 		desc_t *desc = &get_status(port)->tx_descs[i];
@@ -528,11 +515,10 @@
 	card_t *card = pci_get_drvdata(pdev);
 	int i;
 
-	for (i = 0; i < 4; i++)
-		if (card->ports[i]) {
-			struct net_device *dev = port_to_dev(card->ports[i]);
-			unregister_hdlc_device(dev);
-		}
+	for (i = 0; i < card->n_ports; i++) {
+		unregister_hdlc_device(card->ports[i].dev);
+		free_netdev(card->ports[i].dev);
+	}
 
 	/* unregister and free all host resources */
 	if (card->irq)
@@ -555,13 +541,10 @@
 		pci_free_consistent(pdev, sizeof(card_status_t),
 				    card->status, card->status_address);
 
-	for (i = 0; i < card->n_ports; i++)
-		if (card->__ports[i].dev)
-			free_netdev(card->__ports[i].dev);
-
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 	kfree(card);
-	pci_release_regions(pdev);
 }
 
 
@@ -599,13 +582,15 @@
 	   work on most platforms */
 	if (pci_set_consistent_dma_mask(pdev, 0x0FFFFFFF) ||
 	    pci_set_dma_mask(pdev, 0x0FFFFFFF)) {
-		printk(KERN_ERR "No usable DMA configuration\n");
+		printk(KERN_ERR "wanXL: No usable DMA configuration\n");
 		return -EIO;
 	}
 
 	i = pci_request_regions(pdev, "wanXL");
-	if (i)
+	if (i) {
+		pci_disable_device(pdev);
 		return i;
+	}
 
 	switch (pdev->device) {
 	case PCI_DEVICE_ID_SBE_WANXL100: ports = 1; break;
@@ -619,23 +604,13 @@
 		printk(KERN_ERR "wanXL %s: unable to allocate memory\n",
 		       card_name(pdev));
 		pci_release_regions(pdev);
+		pci_disable_device(pdev);
 		return -ENOBUFS;
 	}
 	memset(card, 0, alloc_size);
 
 	pci_set_drvdata(pdev, card);
 	card->pdev = pdev;
-	card->n_ports = ports;
-
-	for (i = 0; i < ports; i++) {
-		card->__ports[i].dev = alloc_hdlcdev(&card->__ports[i]);
-		if (!card->__ports[i].dev) {
-			printk(KERN_ERR "wanXL %s: unable to allocate memory\n",
-			       card_name(pdev));
-			wanxl_pci_remove_one(pdev);
-			return -ENOMEM;
-		}
-	}
 
 	card->status = pci_alloc_consistent(pdev, sizeof(card_status_t),
 					    &card->status_address);
@@ -655,7 +630,7 @@
 	   to indicate the card can do 32-bit DMA addressing */
 	if (pci_set_consistent_dma_mask(pdev, 0xFFFFFFFF) ||
 	    pci_set_dma_mask(pdev, 0xFFFFFFFF)) {
-		printk(KERN_ERR "No usable DMA configuration\n");
+		printk(KERN_ERR "wanXL: No usable DMA configuration\n");
 		wanxl_pci_remove_one(pdev);
 		return -EIO;
 	}
@@ -767,17 +742,11 @@
 	ramsize = stat;
 #endif
 
-	printk(KERN_INFO "wanXL %s: at 0x%X, %u KB of RAM at 0x%X, irq"
-	       " %u\n" KERN_INFO "wanXL %s: port", card_name(pdev),
-	       plx_phy, ramsize / 1024, mem_phy, pdev->irq, card_name(pdev));
-
-	for (i = 0; i < ports; i++)
-		printk("%s #%i: %s", i ? "," : "", i,
-		       port_name(card->ports[i]));
-	printk("\n");
+	printk(KERN_INFO "wanXL %s: at 0x%X, %u KB of RAM at 0x%X, irq %u\n",
+	       card_name(pdev), plx_phy, ramsize / 1024, mem_phy, pdev->irq);
 
 	/* Allocate IRQ */
-	if(request_irq(pdev->irq, wanxl_intr, SA_SHIRQ, "wanXL", card)) {
+	if (request_irq(pdev->irq, wanxl_intr, SA_SHIRQ, "wanXL", card)) {
 		printk(KERN_WARNING "wanXL %s: could not allocate IRQ%i.\n",
 		       card_name(pdev), pdev->irq);
 		wanxl_pci_remove_one(pdev);
@@ -786,9 +755,18 @@
 	card->irq = pdev->irq;
 
 	for (i = 0; i < ports; i++) {
-		port_t *port = &card->__ports[i];
-		struct net_device *dev = port_to_dev(port);
-		hdlc_device *hdlc = dev_to_hdlc(dev);
+		hdlc_device *hdlc;
+		port_t *port = &card->ports[i];
+		struct net_device *dev = alloc_hdlcdev(port);
+		if (!dev) {
+			printk(KERN_ERR "wanXL %s: unable to allocate"
+			       " memory\n", card_name(pdev));
+			wanxl_pci_remove_one(pdev);
+			return -ENOMEM;
+		}
+
+		port->dev = dev;
+		hdlc = dev_to_hdlc(dev);
 		spin_lock_init(&port->lock);
 		SET_MODULE_OWNER(dev);
 		dev->tx_queue_len = 50;
@@ -797,7 +775,6 @@
 		dev->stop = wanxl_close;
 		hdlc->attach = wanxl_attach;
 		hdlc->xmit = wanxl_xmit;
-		card->ports[i] = port;
 		dev->get_stats = wanxl_get_stats;
 		port->card = card;
 		port->node = i;
@@ -805,11 +782,21 @@
 		if (register_hdlc_device(dev)) {
 			printk(KERN_ERR "wanXL %s: unable to register hdlc"
 			       " device\n", card_name(pdev));
-			card->ports[i] = NULL;
+			free_netdev(dev);
 			wanxl_pci_remove_one(pdev);
 			return -ENOBUFS;
 		}
+		card->n_ports++;
 	}
+
+	printk(KERN_INFO "wanXL %s: port", card_name(pdev));
+	for (i = 0; i < ports; i++)
+		printk("%s #%i: %s", i ? "," : "", i,
+		       card->ports[i].dev->name);
+	printk("\n");
+
+	for (i = 0; i < ports; i++)
+		wanxl_cable_intr(&card->ports[i]); /* get carrier status etc.*/
 
 	return 0;
 }

--=-=-=--
