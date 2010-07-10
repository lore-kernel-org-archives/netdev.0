From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.35-rc3-git7] axnet_cs: use spin_lock_irqsave in
 ax_interrupt
Date: Sat, 10 Jul 2010 20:18:13 +0900
Message-ID: <20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
	<20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
	<20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg508.nifty.com ([202.248.238.88]:49733 "EHLO
	userg508.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab0GJXQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 19:16:56 -0400
Received: from localhost.localdomain (eaoska302241.adsl.ppp.infoweb.ne.jp [222.159.205.241])by userg508.nifty.com with SMTP id o6ANGpKS028815
	for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 08:16:51 +0900
In-Reply-To: <20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


axnet_cs:
    use spin_lock_irqsave instead of spin_lock in ax_interrupt

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.35-git7/drivers/net/pcmcia/axnet_cs.c.orig	2010-07-04 08:28:15.000000000 +0900
+++ linux-2.6.35-git7/drivers/net/pcmcia/axnet_cs.c	2010-07-10 19:07:20.000000000 +0900
@@ -1168,6 +1168,7 @@ static irqreturn_t ax_interrupt(int irq,
 	int interrupts, nr_serviced = 0, i;
 	struct ei_device *ei_local;
     	int handled = 0;
+	unsigned long flags;
 
 	e8390_base = dev->base_addr;
 	ei_local = netdev_priv(dev);
@@ -1176,7 +1177,7 @@ static irqreturn_t ax_interrupt(int irq,
 	 *	Protect the irq test too.
 	 */
 	 
-	spin_lock(&ei_local->page_lock);
+	spin_lock_irqsave(&ei_local->page_lock, flags);
 
 	if (ei_local->irqlock) 
 	{
@@ -1188,7 +1189,7 @@ static irqreturn_t ax_interrupt(int irq,
 			   dev->name, inb_p(e8390_base + EN0_ISR),
 			   inb_p(e8390_base + EN0_IMR));
 #endif
-		spin_unlock(&ei_local->page_lock);
+		spin_unlock_irqrestore(&ei_local->page_lock, flags);
 		return IRQ_NONE;
 	}
     
@@ -1261,7 +1262,7 @@ static irqreturn_t ax_interrupt(int irq,
 	ei_local->irqlock = 0;
 	outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 
-	spin_unlock(&ei_local->page_lock);
+	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 	return IRQ_RETVAL(handled);
 }
 
