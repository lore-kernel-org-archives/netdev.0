From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/8) n2 and c101 hdlc dis-embedding
Date: Tue, 2 Dec 2003 15:32:46 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202153246.57ef7c43.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Halas <khc@pm.waw.pl>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change the n2 and c101 drivers to allocate the hdlc device structure
and use hdlc->dev_data for their private data.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1492  -> 1.1493 
#	drivers/net/wan/hd6457x.c	1.8     -> 1.9    
#	drivers/net/wan/n2.c	1.13    -> 1.14   
#	drivers/net/wan/c101.c	1.12    -> 1.13   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/26	shemminger@osdl.org	1.1493
# Change to work with hdlc_device without embedded net_device.
# --------------------------------------------
#
diff -Nru a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
--- a/drivers/net/wan/c101.c	Wed Nov 26 12:28:38 2003
+++ b/drivers/net/wan/c101.c	Wed Nov 26 12:28:38 2003
@@ -54,7 +54,7 @@
 
 
 typedef struct card_s {
-	hdlc_device hdlc;	/* HDLC device struct - must be first */
+	hdlc_device *hdlc;	/* HDLC device struct - must be first */
 	spinlock_t lock;	/* TX lock */
 	u8 *win0base;		/* ISA window base address */
 	u32 phy_winbase;	/* ISA physical base address */
@@ -128,8 +128,8 @@
 	sca_out(stat & ST1_UDRN, MSCI0_OFFSET + ST1, card);
 
 	if (stat & ST1_UDRN) {
-		port->hdlc.stats.tx_errors++; /* TX Underrun error detected */
-		port->hdlc.stats.tx_fifo_errors++;
+		port->hdlc->stats.tx_errors++; /* TX Underrun error detected */
+		port->hdlc->stats.tx_fifo_errors++;
 	}
 
 	/* Reset MSCI CDCD status bit - uses ch#2 DCD input */
@@ -137,7 +137,7 @@
 
 	if (stat & ST1_CDCD)
 		hdlc_set_carrier(!(sca_in(MSCI1_OFFSET + ST3, card) & ST3_DCD),
-				 &port->hdlc);
+				 port->hdlc);
 }
 
 
@@ -288,13 +288,14 @@
 		release_mem_region(card->phy_winbase, C101_MAPPED_RAM_SIZE);
 	}
 
-	kfree(card);
+	free_hdlc_device(card->hdlc);
 }
 
 
 
 static int __init c101_run(unsigned long irq, unsigned long winbase)
 {
+	hdlc_device *hdlc;
 	struct net_device *dev;
 	card_t *card;
 	int result;
@@ -309,12 +310,13 @@
 		return -ENODEV;
 	}
 
-	card = kmalloc(sizeof(card_t), GFP_KERNEL);
-	if (card == NULL) {
+	hdlc = alloc_hdlc_device(sizeof(card_t));
+	if (!hdlc) {
 		printk(KERN_ERR "c101: unable to allocate memory\n");
 		return -ENOBUFS;
 	}
-	memset(card, 0, sizeof(card_t));
+	card = hdlc->dev_data;
+	card->hdlc = hdlc;
 
 	if (request_irq(irq, sca_intr, 0, devname, card)) {
 		printk(KERN_ERR "c101: could not allocate IRQ\n");
@@ -347,7 +349,7 @@
 
 	sca_init(card, 0);
 
-	dev = hdlc_to_dev(&card->hdlc);
+	dev = hdlc_to_dev(hdlc);
 
 	spin_lock_init(&card->lock);
 	SET_MODULE_OWNER(dev);
@@ -358,11 +360,11 @@
 	dev->do_ioctl = c101_ioctl;
 	dev->open = c101_open;
 	dev->stop = c101_close;
-	card->hdlc.attach = sca_attach;
-	card->hdlc.xmit = sca_xmit;
+	hdlc->attach = sca_attach;
+	hdlc->xmit = sca_xmit;
 	card->settings.clock_type = CLOCK_EXT;
 
-	result = register_hdlc_device(&card->hdlc);
+	result = register_hdlc_device(hdlc);
 	if (result) {
 		printk(KERN_WARNING "c101: unable to register hdlc device\n");
 		c101_destroy_card(card);
@@ -371,11 +373,11 @@
 
 	sca_init_sync_port(card); /* Set up C101 memory */
 	hdlc_set_carrier(!(sca_in(MSCI1_OFFSET + ST3, card) & ST3_DCD),
-			 &card->hdlc);
+			 card->hdlc);
 
 	printk(KERN_INFO "%s: Moxa C101 on IRQ%u,"
 	       " using %u TX + %u RX packets rings\n",
-	       hdlc_to_name(&card->hdlc), card->irq,
+	       hdlc_to_name(card->hdlc), card->irq,
 	       card->tx_ring_buffers, card->rx_ring_buffers);
 
 	*new_card = card;
@@ -424,7 +426,7 @@
 	while (card) {
 		card_t *ptr = card;
 		card = card->next_card;
-		unregister_hdlc_device(&ptr->hdlc);
+		unregister_hdlc_device(ptr->hdlc);
 		c101_destroy_card(ptr);
 	}
 }
diff -Nru a/drivers/net/wan/hd6457x.c b/drivers/net/wan/hd6457x.c
--- a/drivers/net/wan/hd6457x.c	Wed Nov 26 12:28:38 2003
+++ b/drivers/net/wan/hd6457x.c	Wed Nov 26 12:28:38 2003
@@ -114,7 +114,7 @@
 
 static inline port_t* hdlc_to_port(hdlc_device *hdlc)
 {
-	return (port_t*)hdlc;
+	return hdlc->dev_data;
 }
 
 
@@ -245,7 +245,7 @@
 	}
 
 	hdlc_set_carrier(!(sca_in(get_msci(port) + ST3, card) & ST3_DCD),
-			 &port->hdlc);
+			 port->hdlc);
 }
 
 
@@ -262,13 +262,13 @@
 	sca_out(stat & (ST1_UDRN | ST1_CDCD), msci + ST1, card);
 
 	if (stat & ST1_UDRN) {
-		port->hdlc.stats.tx_errors++; /* TX Underrun error detected */
-		port->hdlc.stats.tx_fifo_errors++;
+		port->hdlc->stats.tx_errors++; /* TX Underrun error detected */
+		port->hdlc->stats.tx_fifo_errors++;
 	}
 
 	if (stat & ST1_CDCD)
 		hdlc_set_carrier(!(sca_in(msci + ST3, card) & ST3_DCD),
-				 &port->hdlc);
+				 port->hdlc);
 }
 #endif
 
@@ -287,7 +287,7 @@
 	len = readw(&desc->len);
 	skb = dev_alloc_skb(len);
 	if (!skb) {
-		port->hdlc.stats.rx_dropped++;
+		port->hdlc->stats.rx_dropped++;
 		return;
 	}
 
@@ -316,12 +316,12 @@
 	printk(KERN_DEBUG "%s RX(%i):", hdlc_to_name(&port->hdlc), skb->len);
 	debug_frame(skb);
 #endif
-	port->hdlc.stats.rx_packets++;
-	port->hdlc.stats.rx_bytes += skb->len;
+	port->hdlc->stats.rx_packets++;
+	port->hdlc->stats.rx_bytes += skb->len;
 	skb->mac.raw = skb->data;
-	skb->dev = hdlc_to_dev(&port->hdlc);
+	skb->dev = hdlc_to_dev(port->hdlc);
 	skb->dev->last_rx = jiffies;
-	skb->protocol = hdlc_type_trans(skb, hdlc_to_dev(&port->hdlc));
+	skb->protocol = hdlc_type_trans(skb, hdlc_to_dev(port->hdlc));
 	netif_rx(skb);
 }
 
@@ -333,7 +333,7 @@
 	u16 dmac = get_dmac_rx(port);
 	card_t *card = port_to_card(port);
 	u8 stat = sca_in(DSR_RX(phy_node(port)), card); /* read DMA Status */
-	struct net_device_stats *stats = &port->hdlc.stats;
+	struct net_device_stats *stats = &port->hdlc->stats;
 
 	/* Reset DSR status bits */
 	sca_out((stat & (DSR_EOT | DSR_EOM | DSR_BOF | DSR_COF)) | DSR_DWE,
@@ -401,13 +401,13 @@
 			break;	/* Transmitter is/will_be sending this frame */
 
 		desc = desc_address(port, port->txlast, 1);
-		port->hdlc.stats.tx_packets++;
-		port->hdlc.stats.tx_bytes += readw(&desc->len);
+		port->hdlc->stats.tx_packets++;
+		port->hdlc->stats.tx_bytes += readw(&desc->len);
 		writeb(0, &desc->stat);	/* Free descriptor */
 		port->txlast = next_desc(port, port->txlast, 1);
 	}
 
-	netif_wake_queue(hdlc_to_dev(&port->hdlc));
+	netif_wake_queue(hdlc_to_dev(port->hdlc));
 	spin_unlock(&port->lock);
 }
 
@@ -790,7 +790,7 @@
 
 	desc = desc_address(port, port->txin + 1, 1);
 	if (readb(&desc->stat)) /* allow 1 packet gap */
-		netif_stop_queue(hdlc_to_dev(&port->hdlc));
+		netif_stop_queue(hdlc_to_dev(port->hdlc));
 
 	spin_unlock_irq(&port->lock);
 
diff -Nru a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
--- a/drivers/net/wan/n2.c	Wed Nov 26 12:28:38 2003
+++ b/drivers/net/wan/n2.c	Wed Nov 26 12:28:38 2003
@@ -92,11 +92,10 @@
 
 
 typedef struct port_s {
-	hdlc_device hdlc;	/* HDLC device struct - must be first */
+	hdlc_device *hdlc;	/* HDLC device struct */
 	struct card_s *card;
 	spinlock_t lock;	/* TX lock */
 	sync_serial_settings settings;
-	int valid;		/* port enabled */
 	int rxpart;		/* partial frame received, next frame invalid*/
 	unsigned short encoding;
 	unsigned short parity;
@@ -120,7 +119,7 @@
 	u16 tx_ring_buffers;
 	u8 irq;			/* IRQ (3-15) */
 
-	port_t ports[2];
+	port_t *ports[2];
 	struct card_s *next_card;
 }card_t;
 
@@ -141,8 +140,7 @@
 #define phy_node(port)			((port)->phy_node)
 #define winsize(card)			(USE_WINDOWSIZE)
 #define winbase(card)      	     	((card)->winbase)
-#define get_port(card, port)		((card)->ports[port].valid ? \
-					 &(card)->ports[port] : NULL)
+#define get_port(card, port)		((card)->ports[port])
 
 
 
@@ -311,9 +309,13 @@
 {
 	int cnt;
 
-	for (cnt = 0; cnt < 2; cnt++)
-		if (card->ports[cnt].card)
-			unregister_hdlc_device(&card->ports[cnt].hdlc);
+	for (cnt = 0; cnt < 2; cnt++) {
+		port_t *port = card->ports[cnt];
+		if (port) {
+			unregister_hdlc_device(port->hdlc);
+			free_hdlc_device(port->hdlc);
+		}
+	}
 
 	if (card->irq)
 		free_irq(card->irq, card);
@@ -434,14 +436,25 @@
 
 	sca_init(card, 0);
 	for (cnt = 0; cnt < 2; cnt++) {
-		port_t *port = &card->ports[cnt];
-		struct net_device *dev = hdlc_to_dev(&port->hdlc);
+		hdlc_device *hdlc;
+		port_t *port;
+		struct net_device *dev;
+		int err;
 
 		if ((cnt == 0 && !valid0) || (cnt == 1 && !valid1))
 			continue;
 
+		hdlc = alloc_hdlc_device(sizeof(*port));
+		if (!hdlc) {
+			printk(KERN_WARNING "n2: unable to allocate hdlc device\n");
+			n2_destroy_card(card);
+			return -ENOMEM;
+		}
+
+		dev = hdlc_to_dev(hdlc);
+		port = hdlc->dev_data;
+		port->hdlc = hdlc;
 		port->phy_node = cnt;
-		port->valid = 1;
 
 		if ((cnt == 1) && valid0)
 			port->log_node = 1;
@@ -455,21 +468,23 @@
 		dev->do_ioctl = n2_ioctl;
 		dev->open = n2_open;
 		dev->stop = n2_close;
-		port->hdlc.attach = sca_attach;
-		port->hdlc.xmit = sca_xmit;
+		hdlc->attach = sca_attach;
+		hdlc->xmit = sca_xmit;
 		port->settings.clock_type = CLOCK_EXT;
 
-		if (register_hdlc_device(&port->hdlc)) {
+		err = register_hdlc_device(hdlc);
+		if (err) {
 			printk(KERN_WARNING "n2: unable to register hdlc "
 			       "device\n");
 			n2_destroy_card(card);
-			return -ENOBUFS;
+			return err;
 		}
 		port->card = card;
 		sca_init_sync_port(port); /* Set up SCA memory */
+		card->ports[i] = port;
 
 		printk(KERN_INFO "%s: RISCom/N2 node %d\n",
-		       hdlc_to_name(&port->hdlc), port->phy_node);
+		       hdlc_to_name(hdlc), port->phy_node);
 	}
 
 	*new_card = card;
