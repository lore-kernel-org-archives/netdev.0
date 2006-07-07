From: akpm@osdl.org
Subject: [patch 6/9] lockdep: annotate 8390.c disable_irq(), #2
Date: Thu, 06 Jul 2006 23:58:25 -0700
Message-ID: <200607070658.k676wPqM030377@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, arjan@linux.intel.com,
	davem@davemloft.net, mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18882 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751224AbWGGG64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 02:58:56 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arjan van de Ven <arjan@linux.intel.com>

The ne2000 drivers use disable_irq as a poor mans locking construct; make
sure lockdep knows about these.

NOTE NOTE: the ne2000 driver calls these *from interrupt context*.  That's
a new situation that needs to be analyzed for correctness still; it feels
really wrong to me (but then again so does disable_irq() tricks in general)

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/8390.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff -puN drivers/net/8390.c~lockdep-annotate-8390c-disable_irq-2 drivers/net/8390.c
--- a/drivers/net/8390.c~lockdep-annotate-8390c-disable_irq-2
+++ a/drivers/net/8390.c
@@ -299,7 +299,7 @@ static int ei_start_xmit(struct sk_buff 
 	 *	Slow phase with lock held.
 	 */
 	 
-	disable_irq_nosync(dev->irq);
+	disable_irq_nosync_lockdep(dev->irq);
 	
 	spin_lock(&ei_local->page_lock);
 	
@@ -338,7 +338,7 @@ static int ei_start_xmit(struct sk_buff 
 		netif_stop_queue(dev);
 		outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 		spin_unlock(&ei_local->page_lock);
-		enable_irq(dev->irq);
+		enable_irq_lockdep(dev->irq);
 		ei_local->stat.tx_errors++;
 		return 1;
 	}
@@ -379,7 +379,7 @@ static int ei_start_xmit(struct sk_buff 
 	outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 	
 	spin_unlock(&ei_local->page_lock);
-	enable_irq(dev->irq);
+	enable_irq_lockdep(dev->irq);
 
 	dev_kfree_skb (skb);
 	ei_local->stat.tx_bytes += send_length;
@@ -505,9 +505,9 @@ irqreturn_t ei_interrupt(int irq, void *
 #ifdef CONFIG_NET_POLL_CONTROLLER
 void ei_poll(struct net_device *dev)
 {
-	disable_irq(dev->irq);
+	disable_irq_lockdep(dev->irq);
 	ei_interrupt(dev->irq, dev, NULL);
-	enable_irq(dev->irq);
+	enable_irq_lockdep(dev->irq);
 }
 #endif
 
_
