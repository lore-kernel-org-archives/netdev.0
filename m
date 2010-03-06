From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.33-git11] lib8390: use spin_lock_irqsave for
 locking
Date: Sun, 7 Mar 2010 07:02:56 +0900
Message-ID: <20100307070256.cb86716d.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091213094411.18be2ff6.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg506.nifty.com ([202.248.238.86]:22409 "EHLO
	userg506.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204Ab0CFWD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 17:03:28 -0500
Received: from localhost.localdomain (eaoska103212.adsl.ppp.infoweb.ne.jp [218.226.18.212])by userg506.nifty.com with SMTP id o26M34EO005964
	for <netdev@vger.kernel.org>; Sun, 7 Mar 2010 07:03:04 +0900
In-Reply-To: <20091213094411.18be2ff6.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


lib8390:
 use "spin_lock_irqsave", "local_irq_save" instead of "disable_irq".

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.33-git11/drivers/net/lib8390.c.orig	2010-03-06 20:09:28.000000000 +0900
+++ linux-2.6.33-git11/drivers/net/lib8390.c	2010-03-07 06:42:47.000000000 +0900
@@ -279,15 +279,13 @@ static void __ei_tx_timeout(struct net_d
 
 	/* Ugly but a reset can be slow, yet must be protected */
 
-	disable_irq_nosync_lockdep(dev->irq);
-	spin_lock(&ei_local->page_lock);
+	spin_lock_irqsave(&ei_local->page_lock, flags);
 
 	/* Try to restart the card.  Perhaps the user has fixed something. */
 	ei_reset_8390(dev);
 	__NS8390_init(dev, 1);
 
-	spin_unlock(&ei_local->page_lock);
-	enable_irq_lockdep(dev->irq);
+	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 	netif_wake_queue(dev);
 }
 
@@ -323,17 +321,11 @@ static netdev_tx_t __ei_start_xmit(struc
 
 	spin_lock_irqsave(&ei_local->page_lock, flags);
 	ei_outb_p(0x00, e8390_base + EN0_IMR);
-	spin_unlock_irqrestore(&ei_local->page_lock, flags);
-
 
 	/*
 	 *	Slow phase with lock held.
 	 */
 
-	disable_irq_nosync_lockdep_irqsave(dev->irq, &flags);
-
-	spin_lock(&ei_local->page_lock);
-
 	ei_local->irqlock = 1;
 
 	/*
@@ -368,8 +360,7 @@ static netdev_tx_t __ei_start_xmit(struc
 		ei_local->irqlock = 0;
 		netif_stop_queue(dev);
 		ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
-		spin_unlock(&ei_local->page_lock);
-		enable_irq_lockdep_irqrestore(dev->irq, &flags);
+		spin_unlock_irqrestore(&ei_local->page_lock, flags);
 		dev->stats.tx_errors++;
 		return NETDEV_TX_BUSY;
 	}
@@ -409,8 +400,7 @@ static netdev_tx_t __ei_start_xmit(struc
 	ei_local->irqlock = 0;
 	ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 
-	spin_unlock(&ei_local->page_lock);
-	enable_irq_lockdep_irqrestore(dev->irq, &flags);
+	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
 	dev_kfree_skb (skb);
 	dev->stats.tx_bytes += send_length;
@@ -526,9 +516,11 @@ static irqreturn_t __ei_interrupt(int ir
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void __ei_poll(struct net_device *dev)
 {
-	disable_irq(dev->irq);
+	unsigned long flags;
+
+	local_irq_save(flags);
 	__ei_interrupt(dev->irq, dev);
-	enable_irq(dev->irq);
+	local_irq_restore(flags);
 }
 #endif
 
