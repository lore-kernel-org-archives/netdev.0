From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] natsemi: netpoll fixes
Date: Tue, 6 Mar 2007 00:10:08 +0400
Message-ID: <200703052310.08359.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mhuth@mvista.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:61759 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751924AbXCEUKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 15:10:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix two issues in this driver's netpoll path: one usual, with spin_unlock_irq()
enabling interrupts which nobody asks it to do (that has been fixed recently in
a number of drivers) and one unusual, with poll_controller() method possibly
causing loss of interrupts due to the interrupt status register being cleared
by a simple read and the interrpupt handler simply storing it, not accumulating.

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
 drivers/net/natsemi.c |   24 +++++++++++++++++++-----
 1 files changed, 19 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/net/natsemi.c
===================================================================
--- linux-2.6.orig/drivers/net/natsemi.c
+++ linux-2.6/drivers/net/natsemi.c
@@ -2024,6 +2024,7 @@ static int start_tx(struct sk_buff *skb,
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
 	unsigned entry;
+	unsigned long flags;
 
 	/* Note: Ordering is important here, set the field with the
 	   "ownership" bit last, and only then increment cur_tx. */
@@ -2037,7 +2038,7 @@ static int start_tx(struct sk_buff *skb,
 
 	np->tx_ring[entry].addr = cpu_to_le32(np->tx_dma[entry]);
 
-	spin_lock_irq(&np->lock);
+	spin_lock_irqsave(&np->lock, flags);
 
 	if (!np->hands_off) {
 		np->tx_ring[entry].cmd_status = cpu_to_le32(DescOwn | skb->len);
@@ -2056,7 +2057,7 @@ static int start_tx(struct sk_buff *skb,
 		dev_kfree_skb_irq(skb);
 		np->stats.tx_dropped++;
 	}
-	spin_unlock_irq(&np->lock);
+	spin_unlock_irqrestore(&np->lock, flags);
 
 	dev->trans_start = jiffies;
 
@@ -2222,6 +2223,8 @@ static void netdev_rx(struct net_device 
 		pkt_len = (desc_status & DescSizeMask) - 4;
 		if ((desc_status&(DescMore|DescPktOK|DescRxLong)) != DescPktOK){
 			if (desc_status & DescMore) {
+				unsigned long flags;
+
 				if (netif_msg_rx_err(np))
 					printk(KERN_WARNING
 						"%s: Oversized(?) Ethernet "
@@ -2236,12 +2239,12 @@ static void netdev_rx(struct net_device 
 				 * reset procedure documented in
 				 * AN-1287. */
 
-				spin_lock_irq(&np->lock);
+				spin_lock_irqsave(&np->lock, flags);
 				reset_rx(dev);
 				reinit_rx(dev);
 				writel(np->ring_dma, ioaddr + RxRingPtr);
 				check_link(dev);
-				spin_unlock_irq(&np->lock);
+				spin_unlock_irqrestore(&np->lock, flags);
 
 				/* We'll enable RX on exit from this
 				 * function. */
@@ -2396,8 +2399,19 @@ static struct net_device_stats *get_stat
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void natsemi_poll_controller(struct net_device *dev)
 {
+	struct netdev_private *np = netdev_priv(dev);
+
 	disable_irq(dev->irq);
-	intr_handler(dev->irq, dev);
+
+	/*
+	 * A real interrupt might have already reached us at this point
+	 * but NAPI might still haven't called us back.  As the interrupt
+	 * status register is cleared by reading, we should prevent an
+	 * interrupt loss in this case...
+	 */
+	if (!np->intr_status)
+		intr_handler(dev->irq, dev);
+
 	enable_irq(dev->irq);
 }
 #endif

