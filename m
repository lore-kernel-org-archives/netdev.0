From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/8) farsync - hdlc_device conversion
Date: Tue, 2 Dec 2003 14:02:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202140217.776fdff6.shemminger@osdl.org>
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
#	           ChangeSet	1.1494  -> 1.1495 
#	drivers/net/wan/farsync.c	1.18    -> 1.19   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/26	shemminger@osdl.org	1.1495
# Convert from embedding hdlc_device (with embedded net_device)
# to hdlc_device pointer.
# --------------------------------------------
#
diff -Nru a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
--- a/drivers/net/wan/farsync.c	Wed Nov 26 12:31:27 2003
+++ b/drivers/net/wan/farsync.c	Wed Nov 26 12:31:28 2003
@@ -328,7 +328,7 @@
 /*      Per port (line or channel) information
  */
 struct fst_port_info {
-        hdlc_device             hdlc;   /* HDLC device struct - must be first */
+        hdlc_device            *hdlc;   /* HDLC device struct */
         struct fst_card_info   *card;   /* Card we're associated with */
         int                     index;  /* Port index on the card */
         int                     hwif;   /* Line hardware (lineInterface copy) */
@@ -353,13 +353,16 @@
         spinlock_t     card_lock;       /* Lock for SMP access */
         unsigned short pci_conf;        /* PCI card config in I/O space */
                                         /* Per port info */
-        struct fst_port_info ports[ FST_MAX_PORTS ];
+        struct fst_port_info *ports[ FST_MAX_PORTS ];
 };
 
 /* Convert an HDLC device pointer into a port info pointer and similar */
-#define hdlc_to_port(H) ((struct fst_port_info *)(H))
+static __inline__ struct fst_port_info *hdlc_to_port(hdlc_device *hdlc)
+{
+	return hdlc->dev_data;
+}
 #define dev_to_port(D)  hdlc_to_port(dev_to_hdlc(D))
-#define port_to_dev(P)  hdlc_to_dev(&(P)->hdlc)
+#define port_to_dev(P)	hdlc_to_dev(P->hdlc)
 
 
 /*
@@ -678,24 +681,24 @@
                                         len );
         if ( dmabits != ( RX_STP | RX_ENP ) || len > LEN_RX_BUFFER - 2 )
         {
-                port->hdlc.stats.rx_errors++;
+                port->hdlc->stats.rx_errors++;
 
                 /* Update error stats and discard buffer */
                 if ( dmabits & RX_OFLO )
                 {
-                        port->hdlc.stats.rx_fifo_errors++;
+                        port->hdlc->stats.rx_fifo_errors++;
                 }
                 if ( dmabits & RX_CRC )
                 {
-                        port->hdlc.stats.rx_crc_errors++;
+                        port->hdlc->stats.rx_crc_errors++;
                 }
                 if ( dmabits & RX_FRAM )
                 {
-                        port->hdlc.stats.rx_frame_errors++;
+                        port->hdlc->stats.rx_frame_errors++;
                 }
                 if ( dmabits == ( RX_STP | RX_ENP ))
                 {
-                        port->hdlc.stats.rx_length_errors++;
+                        port->hdlc->stats.rx_length_errors++;
                 }
 
                 /* Discard buffer descriptors until we see the end of packet
@@ -732,7 +735,7 @@
         {
                 dbg ( DBG_RX,"intr_rx: can't allocate buffer\n");
 
-                port->hdlc.stats.rx_dropped++;
+                port->hdlc->stats.rx_dropped++;
 
                 /* Return descriptor to card */
                 FST_WRB ( card, rxDescrRing[pi][rxp].bits, DMA_OWN );
@@ -756,12 +759,12 @@
                 port->rxpos = rxp;
 
         /* Update stats */
-        port->hdlc.stats.rx_packets++;
-        port->hdlc.stats.rx_bytes += len;
+        port->hdlc->stats.rx_packets++;
+        port->hdlc->stats.rx_bytes += len;
 
         /* Push upstream */
         skb->mac.raw = skb->data;
-        skb->dev = hdlc_to_dev ( &port->hdlc );
+        skb->dev = hdlc_to_dev ( port->hdlc );
         skb->protocol = hdlc_type_trans(skb, skb->dev);
         netif_rx ( skb );
 
@@ -806,7 +809,7 @@
         {
                 event = FST_RDB ( card, interruptEvent.evntbuff[rdidx]);
 
-                port = &card->ports[event & 0x03];
+                port = card->ports[event & 0x03];
 
                 dbg ( DBG_INTR,"intr: %x\n", event );
 
@@ -835,8 +838,8 @@
                          * always load up the entire packet for DMA.
                          */
                         dbg ( DBG_TX,"Tx underflow port %d\n", event & 0x03 );
-                        port->hdlc.stats.tx_errors++;
-                        port->hdlc.stats.tx_fifo_errors++;
+                        port->hdlc->stats.tx_errors++;
+                        port->hdlc->stats.tx_fifo_errors++;
                         break;
 
                 case INIT_CPLT:
@@ -859,9 +862,10 @@
         }
         FST_WRB ( card, interruptEvent.rdindex, rdidx );
 
-        for ( pi = 0, port = card->ports ; pi < card->nports ; pi++, port++ )
+        for ( pi = 0 ; pi < card->nports ; pi++ )
         {
-                if ( ! port->run )
+		port = card->ports[pi];
+                if ( !port || ! port->run )
                         continue;
 
                 /* Check for rx completions */
@@ -1346,8 +1350,8 @@
 
         port = dev_to_port ( dev );
 
-        port->hdlc.stats.tx_errors++;
-        port->hdlc.stats.tx_aborted_errors++;
+        port->hdlc->stats.tx_errors++;
+        port->hdlc->stats.tx_aborted_errors++;
 
         if ( port->txcnt > 0 )
                 fst_issue_cmd ( port, ABORTTX );
@@ -1374,8 +1378,8 @@
         if ( ! netif_carrier_ok ( dev ))
         {
                 dev_kfree_skb ( skb );
-                port->hdlc.stats.tx_errors++;
-                port->hdlc.stats.tx_carrier_errors++;
+                port->hdlc->stats.tx_errors++;
+                port->hdlc->stats.tx_carrier_errors++;
                 return 0;
         }
 
@@ -1385,7 +1389,7 @@
                 dbg ( DBG_TX,"Packet too large %d vs %d\n", skb->len,
                                                 LEN_TX_BUFFER );
                 dev_kfree_skb ( skb );
-                port->hdlc.stats.tx_errors++;
+                port->hdlc->stats.tx_errors++;
                 return 0;
         }
 
@@ -1399,7 +1403,7 @@
                 spin_unlock_irqrestore ( &card->card_lock, flags );
                 dbg ( DBG_TX,"Out of Tx buffers\n");
                 dev_kfree_skb ( skb );
-                port->hdlc.stats.tx_errors++;
+                port->hdlc->stats.tx_errors++;
                 return 0;
         }
         if ( ++port->txpos >= NUM_TX_BUFFER )
@@ -1419,8 +1423,8 @@
         FST_WRW ( card, txDescrRing[pi][txp].bcnt, cnv_bcnt ( skb->len ));
         FST_WRB ( card, txDescrRing[pi][txp].bits, DMA_OWN | TX_STP | TX_ENP );
 
-        port->hdlc.stats.tx_packets++;
-        port->hdlc.stats.tx_bytes += skb->len;
+        port->hdlc->stats.tx_packets++;
+        port->hdlc->stats.tx_bytes += skb->len;
 
         dev_kfree_skb ( skb );
 
@@ -1455,11 +1459,23 @@
          */
         for ( i = 0 ; i < card->nports ; i++ )
         {
-                card->ports[i].card   = card;
-                card->ports[i].index  = i;
-                card->ports[i].run    = 0;
+		hdlc_device *hdlc;
+		struct fst_port_info *port;
+
+		hdlc = alloc_hdlc_device(sizeof(*port));
+		if (!hdlc) {
+                        printk_err ("Cannot allcoate HDLC device for port %d", i);
+                        card->nports = i;
+                        break;
+		}
 
-                dev = hdlc_to_dev ( &card->ports[i].hdlc );
+		card->ports[i] = port = hdlc->dev_data;
+		port->hdlc = hdlc;
+                port->card   = card;
+                port->index  = i;
+                port->run    = 0;
+
+                dev = hdlc_to_dev ( hdlc );
 
                 /* Fill in the net device info */
                                 /* Since this is a PCI setup this is purely
@@ -1479,10 +1495,11 @@
                 dev->do_ioctl              = fst_ioctl;
                 dev->watchdog_timeo        = FST_TX_TIMEOUT;
                 dev->tx_timeout            = fst_tx_timeout;
-                card->ports[i].hdlc.attach = fst_attach;
-                card->ports[i].hdlc.xmit   = fst_start_xmit;
+                hdlc->attach	 	   = fst_attach;
+                hdlc->xmit  		   = fst_start_xmit;
 
-                if (( err = register_hdlc_device ( &card->ports[i].hdlc )) < 0 )
+		err = register_hdlc_device ( hdlc );
+		if (err)
                 {
                         printk_err ("Cannot register HDLC device for port %d"
                                     " (errno %d)\n", i, -err );
@@ -1494,8 +1511,8 @@
         spin_lock_init ( &card->card_lock );
 
         printk ( KERN_INFO "%s-%s: %s IRQ%d, %d ports\n",
-                        hdlc_to_dev(&card->ports[0].hdlc)->name,
-                        hdlc_to_dev(&card->ports[card->nports-1].hdlc)->name,
+                        hdlc_to_dev(card->ports[0]->hdlc)->name,
+                        hdlc_to_dev(card->ports[card->nports-1]->hdlc)->name,
                         type_strings[card->type], card->irq, card->nports );
 }
 
@@ -1641,13 +1658,14 @@
 fst_remove_one ( struct pci_dev *pdev )
 {
         struct fst_card_info *card;
-        int i;
+	int i;
 
         card = pci_get_drvdata(pdev);
 
-        for ( i = 0 ; i < card->nports ; i++ )
-        {
-                unregister_hdlc_device ( &card->ports[i].hdlc );
+        for ( i = 0 ; i < card->nports ; i++ ) {
+		hdlc_device *hdlc = card->ports[i]->hdlc;
+                unregister_hdlc_device (hdlc);
+		free_hdlc_device (hdlc);
         }
 
         fst_disable_intr ( card );
