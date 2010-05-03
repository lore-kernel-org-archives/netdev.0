From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.34-rc5] lib8390: to be SMP safe
Date: Mon, 3 May 2010 19:43:16 +0900
Message-ID: <20100503194316.60c98272.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091213094411.18be2ff6.ken_kawasaki@spring.nifty.jp>
	<20100307070256.cb86716d.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg508.nifty.com ([202.248.238.88]:26215 "EHLO
	userg508.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756675Ab0ECKn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 06:43:29 -0400
Received: from localhost.localdomain (eaoska322229.adsl.ppp.infoweb.ne.jp [115.176.51.229])by userg508.nifty.com with SMTP id o43AhMGY007045
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 19:43:22 +0900
In-Reply-To: <20100307070256.cb86716d.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


lib8390:
	write the value "ENISR_ALL" to register "EN0_IMR"
	after enable_irq_lockdep_irqrestore. 

	This patch avoids frequent transmit error on SMP system.


Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.34-rc6/drivers/net/lib8390.c.orig	2010-05-02 16:49:57.000000000 +0900
+++ linux-2.6.34-rc6/drivers/net/lib8390.c	2010-05-02 18:09:18.000000000 +0900
@@ -367,9 +367,9 @@ static netdev_tx_t __ei_start_xmit(struc
 				dev->name, ei_local->tx1, ei_local->tx2, ei_local->lasttx);
 		ei_local->irqlock = 0;
 		netif_stop_queue(dev);
-		ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 		spin_unlock(&ei_local->page_lock);
 		enable_irq_lockdep_irqrestore(dev->irq, &flags);
+		ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 		dev->stats.tx_errors++;
 		return NETDEV_TX_BUSY;
 	}
@@ -407,10 +407,10 @@ static netdev_tx_t __ei_start_xmit(struc
 
 	/* Turn 8390 interrupts back on. */
 	ei_local->irqlock = 0;
-	ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 
 	spin_unlock(&ei_local->page_lock);
 	enable_irq_lockdep_irqrestore(dev->irq, &flags);
+	ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 
 	dev_kfree_skb (skb);
 	dev->stats.tx_bytes += send_length;
