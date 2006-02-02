From: Mark Brown <broonie@sirena.org.uk>
Subject: [patch 2/2] natsemi: NAPI and a bugfix
Date: Thu, 02 Feb 2006 00:00:02 +0000
Message-ID: <20060202235157.257341000@lorien.sirena.org.uk>
References: <20060202233909.426660000@lorien.sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932489AbWBBXxo@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>, Tim Hockin <thockin@hockin.org>
Content-Disposition: inline; filename=natsemi-an-1287
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As documented in National application note 1287 the RX state machine on
the natsemi chip can lock up under some conditions (mostly related to
heavy load).  When this happens a series of bogus packets are reported
by the chip including some oversized frames prior to the final lockup.

This patch implements the fix from the application note: when an
oversized packet is reported it resets the RX state machine, dropping
any currently pending packets.

Signed-off-by: Mark Brown <broonie@sirena.org.uk>

Index: linux-2.6.15.2/drivers/net/natsemi.c
===================================================================
--- linux-2.6.15.2.orig/drivers/net/natsemi.c	2006-02-01 22:59:29.000000000 +0000
+++ linux-2.6.15.2/drivers/net/natsemi.c	2006-02-02 00:05:23.000000000 +0000
@@ -1498,6 +1498,31 @@ static void natsemi_reset(struct net_dev
 	writel(rfcr, ioaddr + RxFilterAddr);
 }
 
+static void reset_rx(struct net_device *dev)
+{
+	int i;
+	struct netdev_private *np = netdev_priv(dev);
+	void __iomem *ioaddr = ns_ioaddr(dev);
+
+	np->intr_status &= ~RxResetDone;
+
+	writel(RxReset, ioaddr + ChipCmd);
+
+	for (i=0;i<NATSEMI_HW_TIMEOUT;i++) {
+		np->intr_status |= readl(ioaddr + IntrStatus);
+		if (np->intr_status & RxResetDone)
+			break;
+		udelay(15);
+	}
+	if (i==NATSEMI_HW_TIMEOUT) {
+		printk(KERN_WARNING "%s: RX reset did not complete in %d usec.\n",
+		       dev->name, i*15);
+	} else if (netif_msg_hw(np)) {
+		printk(KERN_WARNING "%s: RX reset took %d usec.\n",
+		       dev->name, i*15);
+	}
+}
+
 static void natsemi_reload_eeprom(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
@@ -2292,6 +2317,23 @@ static void netdev_rx(struct net_device 
 						"status %#08x.\n", dev->name,
 						np->cur_rx, desc_status);
 				np->stats.rx_length_errors++;
+
+				/* The RX state machine has probably
+				 * locked up beneath us.  Follow the
+				 * reset procedure documented in
+				 * AN-1287. */
+
+				spin_lock_irq(&np->lock);
+				reset_rx(dev);
+				reinit_rx(dev);
+				writel(np->ring_dma, ioaddr + RxRingPtr);
+				check_link(dev);
+				spin_unlock_irq(&np->lock);
+
+				/* We'll enable RX on exit from this
+				 * function. */
+				break;
+
 			} else {
 				/* There was an error. */
 				np->stats.rx_errors++;

--
"You grabbed my hand and we fell into it, like a daydream - or a fever."
