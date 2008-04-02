From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: [PATCH 4/5] m68knommu: fec fixup locking
Date: Wed, 02 Apr 2008 22:58:29 +0200
Message-ID: <20080402210104.449666396@linutronix.de>
References: <20080402204417.597098190@linutronix.de>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org
To: Greg Ungerer <gerg@uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:58658 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755919AbYDBU6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 16:58:34 -0400
Content-Disposition: inline; filename=m68knommu-fec_fixup_spinlock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now there are two spinlocks:
- one for HW access like the RX/TX buffer & friends (but the MAC address)
- one for the mii lists.

Theoretically those two spinlocks could become one, but that way it looks
better.
The locks are taken before the first access to the HW (like retrieving the
current pointer to the ring buffer) and released after we finished. This
fixes some races that were covered / fixed by 0a504779d.

Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -209,7 +209,10 @@ struct fec_enet_private {
 	cbd_t *cur_rx, *cur_tx;	/* The next free ring entry */
 	cbd_t *dirty_tx;	/* The ring entries to be free()ed. */
 	uint tx_full;
-	spinlock_t lock;
+	/* hold while accessing the HW like ringbuffer for tx/rx but not MAC */
+	spinlock_t hw_lock;
+	/* hold while accessing the mii_list_t() elements */
+	spinlock_t mii_lock;
 
 	uint phy_id;
 	uint phy_id_done;
@@ -309,6 +312,7 @@ static int fec_enet_start_xmit(struct sk
 	volatile fec_t *fecp;
 	volatile cbd_t *bdp;
 	unsigned short status;
+	unsigned long flags;
 
 	fep = netdev_priv(dev);
 	fecp = (volatile fec_t *)dev->base_addr;
@@ -318,6 +322,7 @@ static int fec_enet_start_xmit(struct sk
 		return 1;
 	}
 
+	spin_lock_irqsave(&fep->hw_lock, flags);
 	/* Fill in a Tx ring entry */
 	bdp = fep->cur_tx;
 
@@ -328,6 +333,7 @@ static int fec_enet_start_xmit(struct sk
 		 * This should not happen, since dev->tbusy should be set.
 		 */
 		printk("%s: tx queue full!.\n", dev->name);
+		spin_unlock_irqrestore(&fep->hw_lock, flags);
 		return 1;
 	}
 #endif
@@ -367,7 +373,6 @@ static int fec_enet_start_xmit(struct sk
 	flush_dcache_range((unsigned long)skb->data,
 			   (unsigned long)skb->data + skb->len);
 
-	spin_lock_irq(&fep->lock);
 
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
 	 * it's the last BD of the frame, and to put the CRC on the end.
@@ -397,7 +402,7 @@ static int fec_enet_start_xmit(struct sk
 
 	fep->cur_tx = (cbd_t *) bdp;
 
-	spin_unlock_irq(&fep->lock);
+	spin_unlock_irqrestore(&fep->hw_lock, flags);
 
 	return 0;
 }
@@ -451,19 +456,20 @@ static irqreturn_t fec_enet_interrupt(in
 	struct net_device *dev = dev_id;
 	volatile fec_t *fecp;
 	uint int_events;
-	int handled = 0;
+	irqreturn_t ret = IRQ_NONE;
 
 	fecp = (volatile fec_t *)dev->base_addr;
 
 	/* Get the interrupt events that caused us to be here.
 	 */
-	while ((int_events = fecp->fec_ievent) != 0) {
+	do {
+		int_events = fecp->fec_ievent;
 		fecp->fec_ievent = int_events;
 
 		/* Handle receive event in its own function.
 		 */
 		if (int_events & FEC_ENET_RXF) {
-			handled = 1;
+			ret = IRQ_HANDLED;
 			fec_enet_rx(dev);
 		}
 
@@ -472,17 +478,18 @@ static irqreturn_t fec_enet_interrupt(in
 		   them as part of the transmit process.
 		 */
 		if (int_events & FEC_ENET_TXF) {
-			handled = 1;
+			ret = IRQ_HANDLED;
 			fec_enet_tx(dev);
 		}
 
 		if (int_events & FEC_ENET_MII) {
-			handled = 1;
+			ret = IRQ_HANDLED;
 			fec_enet_mii(dev);
 		}
 
-	}
-	return IRQ_RETVAL(handled);
+	} while (int_events);
+
+	return ret;
 }
 
 static void fec_enet_tx(struct net_device *dev)
@@ -493,7 +500,7 @@ static void fec_enet_tx(struct net_devic
 	struct sk_buff *skb;
 
 	fep = netdev_priv(dev);
-	spin_lock(&fep->lock);
+	spin_lock_irq(&fep->hw_lock);
 	bdp = fep->dirty_tx;
 
 	while (((status = bdp->cbd_sc) & BD_ENET_TX_READY) == 0) {
@@ -552,7 +559,7 @@ static void fec_enet_tx(struct net_devic
 		}
 	}
 	fep->dirty_tx = (cbd_t *) bdp;
-	spin_unlock(&fep->lock);
+	spin_unlock_irq(&fep->hw_lock);
 }
 
 /* During a receive, the cur_rx points to the current incoming buffer.
@@ -575,6 +582,7 @@ static void fec_enet_rx(struct net_devic
 #endif
 
 	fep = netdev_priv(dev);
+	spin_lock_irq(&fep->hw_lock);
 	fecp = (volatile fec_t *)dev->base_addr;
 
 	/* First, grab all of the stats for the incoming packet.
@@ -683,6 +691,7 @@ rx_processing_done:
 	 */
 	fecp->fec_r_des_active = 0;
 #endif
+	spin_unlock_irq(&fep->hw_lock);
 }
 
 /* called from interrupt context */
@@ -695,11 +704,11 @@ static void fec_enet_mii(struct net_devi
 	mii_func *mii_func = NULL;
 
 	fep = netdev_priv(dev);
+	spin_lock_irq(&fep->mii_lock);
+
 	ep = fep->hwp;
 	mii_reg = ep->fec_mii_data;
 
-	spin_lock(&fep->lock);
-
 	if ((mip = mii_head) == NULL) {
 		printk("MII and no head!\n");
 		goto unlock;
@@ -716,7 +725,7 @@ static void fec_enet_mii(struct net_devi
 		ep->fec_mii_data = mip->mii_regval;
 
 unlock:
-	spin_unlock(&fep->lock);
+	spin_unlock_irq(&fep->mii_lock);
 	if (mii_func)
 		mii_func(mii_reg, dev);
 }
@@ -731,12 +740,11 @@ static int mii_queue(struct net_device *
 	/* Add PHY address to register command.
 	 */
 	fep = netdev_priv(dev);
-	regval |= fep->phy_addr << 23;
+	spin_lock_irqsave(&fep->mii_lock, flags);
 
+	regval |= fep->phy_addr << 23;
 	retval = 0;
 
-	spin_lock_irqsave(&fep->lock, flags);
-
 	if ((mip = mii_free) != NULL) {
 		mii_free = mip->mii_next;
 		mip->mii_regval = regval;
@@ -753,9 +761,8 @@ static int mii_queue(struct net_device *
 		retval = 1;
 	}
 
-	spin_unlock_irqrestore(&fep->lock, flags);
-
-	return (retval);
+	spin_unlock_irqrestore(&fep->mii_lock, flags);
+	return retval;
 }
 
 static void mii_do_cmd(struct net_device *dev, const phy_cmd_t *c)
@@ -2371,6 +2378,8 @@ int __init fec_enet_init(struct net_devi
 		return -ENOMEM;
 	}
 
+	spin_lock_init(&fep->hw_lock);
+	spin_lock_init(&fep->mii_lock);
 	/* Create an Ethernet device instance.
 	 */
 	fecp = (volatile fec_t *)fec_hw[index];

-- 

