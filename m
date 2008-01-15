From: Frank Rowand <frank.rowand@am.sony.com>
Subject: [PATCH] 8390: fix CONFIG_LOCKDEP error, 2.6.24-rc7
Date: Tue, 15 Jan 2008 14:23:26 -0800
Message-ID: <1200435806.4092.22.camel@bx740>
Reply-To: frank.rowand@am.sony.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: p_gortmaker@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-sin.frontbridge.com ([207.46.51.80]:36516 "EHLO
	outbound3-sin-R.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752477AbYAOWYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 17:24:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Rowand <frank.rowand@am.sony.com>

Turning on CONFIG_LOCKDEP for CONFIG_PREEMPT invokes a path which may
sleep with IRQs disabled.  Change disable_irq_nosync_lockdep() to
disable_irq_nosync(), etc.  Note the comment near the top of
drivers/net/lib8390.c, which is an lkml email from Alan Cox, pre-saging
the need of this patch.

Signed-off-by: Frank Rowand <frank.rowand@am.sony.com>
---
 drivers/net/lib8390.c |   14 	7 +	7 -	0 !
 1 files changed, 7 insertions(+), 7 deletions(-)

Index: linux-2.6.24-rc5/drivers/net/lib8390.c
===================================================================
--- linux-2.6.24-rc5.orig/drivers/net/lib8390.c
+++ linux-2.6.24-rc5/drivers/net/lib8390.c
@@ -284,7 +284,7 @@ static void ei_tx_timeout(struct net_dev
 
 	/* Ugly but a reset can be slow, yet must be protected */
 
-	disable_irq_nosync_lockdep(dev->irq);
+	disable_irq_nosync(dev->irq);
 	spin_lock(&ei_local->page_lock);
 
 	/* Try to restart the card.  Perhaps the user has fixed something. */
@@ -292,7 +292,7 @@ static void ei_tx_timeout(struct net_dev
 	__NS8390_init(dev, 1);
 
 	spin_unlock(&ei_local->page_lock);
-	enable_irq_lockdep(dev->irq);
+	enable_irq(dev->irq);
 	netif_wake_queue(dev);
 }
 
@@ -334,7 +334,7 @@ static int ei_start_xmit(struct sk_buff 
 	 *	Slow phase with lock held.
 	 */
 
-	disable_irq_nosync_lockdep_irqsave(dev->irq, &flags);
+	disable_irq_nosync(dev->irq);
 
 	spin_lock(&ei_local->page_lock);
 
@@ -373,7 +373,7 @@ static int ei_start_xmit(struct sk_buff 
 		netif_stop_queue(dev);
 		ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 		spin_unlock(&ei_local->page_lock);
-		enable_irq_lockdep_irqrestore(dev->irq, &flags);
+		enable_irq(dev->irq);
 		ei_local->stat.tx_errors++;
 		return 1;
 	}
@@ -414,7 +414,7 @@ static int ei_start_xmit(struct sk_buff 
 	ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 
 	spin_unlock(&ei_local->page_lock);
-	enable_irq_lockdep_irqrestore(dev->irq, &flags);
+	enable_irq(dev->irq);
 
 	dev_kfree_skb (skb);
 	ei_local->stat.tx_bytes += send_length;
@@ -530,9 +530,9 @@ static irqreturn_t __ei_interrupt(int ir
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void __ei_poll(struct net_device *dev)
 {
-	disable_irq_lockdep(dev->irq);
+	disable_irq(dev->irq);
 	__ei_interrupt(dev->irq, dev);
-	enable_irq_lockdep(dev->irq);
+	enable_irq(dev->irq);
 }
 #endif
 



