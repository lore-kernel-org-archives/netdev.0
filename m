From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [patch 07/33] m68k: Mac89x0 Ethernet netif updates
Date: Tue, 01 May 2007 22:32:41 +0200
Message-ID: <20070501203331.078826974@mail.of.borg>
References: <20070501203234.252205858@mail.of.borg>
Cc: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from europa.telenet-ops.be ([195.130.137.75]:44958 "EHLO
	europa.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423610AbXEAUe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 16:34:56 -0400
Content-Disposition: inline; filename=357-mac89x0.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Urlichs <smurf@smurf.noris.de>

Macintosh CS89x0 Ethernet: Netif updates
Addition of netif_stop_queue() before transmission by Michael Schmitz
skb_copy_{from,to}_linear_data() conversion by Geert Uytterhoeven

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/Kconfig   |    2 -
 drivers/net/mac89x0.c |   92 ++++++++++++++++++--------------------------------
 2 files changed, 35 insertions(+), 59 deletions(-)

--- linux-m68k-2.6.21.orig/drivers/net/Kconfig
+++ linux-m68k-2.6.21/drivers/net/Kconfig
@@ -311,7 +311,7 @@ config MAC8390
 
 config MAC89x0
 	tristate "Macintosh CS89x0 based ethernet cards"
-	depends on NET_ETHERNET && MAC && BROKEN
+	depends on NET_ETHERNET && MAC
 	---help---
 	  Support for CS89x0 chipset based Ethernet cards.  If you have a
 	  Nubus or LC-PDS network (Ethernet) card of this type, say Y and
--- linux-m68k-2.6.21.orig/drivers/net/mac89x0.c
+++ linux-m68k-2.6.21/drivers/net/mac89x0.c
@@ -128,7 +128,7 @@ struct net_local {
 extern void reset_chip(struct net_device *dev);
 #endif
 static int net_open(struct net_device *dev);
-static int	net_send_packet(struct sk_buff *skb, struct net_device *dev);
+static int net_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t net_interrupt(int irq, void *dev_id);
 static void set_multicast_list(struct net_device *dev);
 static void net_rx(struct net_device *dev);
@@ -374,56 +374,39 @@ net_open(struct net_device *dev)
 static int
 net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	if (dev->tbusy) {
-		/* If we get here, some higher level has decided we are broken.
-		   There should really be a "kick me" function call instead. */
-		int tickssofar = jiffies - dev->trans_start;
-		if (tickssofar < 5)
-			return 1;
-		if (net_debug > 0) printk("%s: transmit timed out, %s?\n", dev->name,
-			   tx_done(dev) ? "IRQ conflict" : "network cable problem");
-		/* Try to restart the adaptor. */
-		dev->tbusy=0;
-		dev->trans_start = jiffies;
-	}
-
-	/* Block a timer-based transmit from overlapping.  This could better be
-	   done with atomic_swap(1, dev->tbusy), but set_bit() works as well. */
-	if (test_and_set_bit(0, (void*)&dev->tbusy) != 0)
-		printk("%s: Transmitter access conflict.\n", dev->name);
-	else {
-		struct net_local *lp = netdev_priv(dev);
-		unsigned long flags;
-
-		if (net_debug > 3)
-			printk("%s: sent %d byte packet of type %x\n",
-			       dev->name, skb->len,
-			       (skb->data[ETH_ALEN+ETH_ALEN] << 8)
-			       | skb->data[ETH_ALEN+ETH_ALEN+1]);
-
-		/* keep the upload from being interrupted, since we
-                   ask the chip to start transmitting before the
-                   whole packet has been completely uploaded. */
-		local_irq_save(flags);
-
-		/* initiate a transmit sequence */
-		writereg(dev, PP_TxCMD, lp->send_cmd);
-		writereg(dev, PP_TxLength, skb->len);
-
-		/* Test to see if the chip has allocated memory for the packet */
-		if ((readreg(dev, PP_BusST) & READY_FOR_TX_NOW) == 0) {
-			/* Gasp!  It hasn't.  But that shouldn't happen since
-			   we're waiting for TxOk, so return 1 and requeue this packet. */
-			local_irq_restore(flags);
-			return 1;
-		}
+	struct net_local *lp = netdev_priv(dev);
+	unsigned long flags;
 
-		/* Write the contents of the packet */
-		memcpy_toio(dev->mem_start + PP_TxFrame, skb->data, skb->len+1);
+	if (net_debug > 3)
+		printk("%s: sent %d byte packet of type %x\n",
+		       dev->name, skb->len,
+		       (skb->data[ETH_ALEN+ETH_ALEN] << 8)
+		       | skb->data[ETH_ALEN+ETH_ALEN+1]);
+
+	/* keep the upload from being interrupted, since we
+	   ask the chip to start transmitting before the
+	   whole packet has been completely uploaded. */
+	local_irq_save(flags);
+	netif_stop_queue(dev);
 
+	/* initiate a transmit sequence */
+	writereg(dev, PP_TxCMD, lp->send_cmd);
+	writereg(dev, PP_TxLength, skb->len);
+
+	/* Test to see if the chip has allocated memory for the packet */
+	if ((readreg(dev, PP_BusST) & READY_FOR_TX_NOW) == 0) {
+		/* Gasp!  It hasn't.  But that shouldn't happen since
+		   we're waiting for TxOk, so return 1 and requeue this packet. */
 		local_irq_restore(flags);
-		dev->trans_start = jiffies;
+		return 1;
 	}
+
+	/* Write the contents of the packet */
+	skb_copy_from_linear_data(skb, (void *)(dev->mem_start + PP_TxFrame),
+				  skb->len+1);
+
+	local_irq_restore(flags);
+	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
 
 	return 0;
@@ -441,9 +424,6 @@ static irqreturn_t net_interrupt(int irq
 		printk ("net_interrupt(): irq %d for unknown device.\n", irq);
 		return IRQ_NONE;
 	}
-	if (dev->interrupt)
-		printk("%s: Re-entering the interrupt handler.\n", dev->name);
-	dev->interrupt = 1;
 
 	ioaddr = dev->base_addr;
 	lp = netdev_priv(dev);
@@ -464,8 +444,7 @@ static irqreturn_t net_interrupt(int irq
 			break;
 		case ISQ_TRANSMITTER_EVENT:
 			lp->stats.tx_packets++;
-			dev->tbusy = 0;
-			mark_bh(NET_BH);	/* Inform upper layers. */
+			netif_wake_queue(dev);
 			if ((status & TX_OK) == 0) lp->stats.tx_errors++;
 			if (status & TX_LOST_CRS) lp->stats.tx_carrier_errors++;
 			if (status & TX_SQE_ERROR) lp->stats.tx_heartbeat_errors++;
@@ -479,8 +458,7 @@ static irqreturn_t net_interrupt(int irq
                                    That shouldn't happen since we only ever
                                    load one packet.  Shrug.  Do the right
                                    thing anyway. */
-				dev->tbusy = 0;
-				mark_bh(NET_BH);	/* Inform upper layers. */
+				netif_wake_queue(dev);
 			}
 			if (status & TX_UNDERRUN) {
 				if (net_debug > 0) printk("%s: transmit underrun\n", dev->name);
@@ -497,7 +475,6 @@ static irqreturn_t net_interrupt(int irq
 			break;
 		}
 	}
-	dev->interrupt = 0;
 	return IRQ_HANDLED;
 }
 
@@ -531,7 +508,8 @@ net_rx(struct net_device *dev)
 	}
 	skb_put(skb, length);
 
-	memcpy_fromio(skb->data, dev->mem_start + PP_RxFrame, length);
+	skb_copy_to_linear_data(skb, (void *)(dev->mem_start + PP_RxFrame),
+				length);
 
 	if (net_debug > 3)printk("%s: received %d byte packet of type %x\n",
                                  dev->name, length,
@@ -610,8 +588,6 @@ static void set_multicast_list(struct ne
 static int set_mac_address(struct net_device *dev, void *addr)
 {
 	int i;
-	if (dev->start)
-		return -EBUSY;
 	printk("%s: Setting MAC address to ", dev->name);
 	for (i = 0; i < 6; i++)
 		printk(" %2.2x", dev->dev_addr[i] = ((unsigned char *)addr)[i]);

--
Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds

