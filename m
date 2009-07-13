From: Dongdong Deng <dongdong.deng@windriver.com>
Subject: [PATCH] drivers/net: using spin_lock_irqsave() in net_send_packet()
Date: Mon, 13 Jul 2009 14:27:06 +0800
Message-ID: <1247466426-14205-1-git-send-email-dongdong.deng@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39407 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801AbZGMGQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jul 2009 02:16:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

spin_unlock_irq() will enable interrupt in net_send_packet(),
this patch changes it to spin_lock_irqsave/spin_lock_irqrestore,
so that it doesn't enable interrupts when already disabled,
and netconsole would work properly over cs89x0/isa-skeleton.

Call trace:
netconsole write_msg()
{
 ...
 -> spin_lock_irqsave();
        -> netpoll_send_udp()
          -> netpoll_send_skb()
            -> net_send_packet()
              ->...

 -> spin_unlock_irqrestore();
 ...
}

Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
---
 drivers/net/cs89x0.c       |    7 ++++---
 drivers/net/isa-skeleton.c |    5 +++--
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 3eee666..5d619ae 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1523,6 +1523,7 @@ static void net_timeout(struct net_device *dev)
 
 static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
+	unsigned long flags;
 	struct net_local *lp = netdev_priv(dev);
 
 	if (net_debug > 3) {
@@ -1535,7 +1536,7 @@ static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
                   ask the chip to start transmitting before the
                   whole packet has been completely uploaded. */
 
-	spin_lock_irq(&lp->lock);
+	spin_lock_irqsave(&lp->lock, flags);
 	netif_stop_queue(dev);
 
 	/* initiate a transmit sequence */
@@ -1549,13 +1550,13 @@ static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 		 * we're waiting for TxOk, so return 1 and requeue this packet.
 		 */
 
-		spin_unlock_irq(&lp->lock);
+		spin_unlock_irqrestore(&lp->lock, flags);
 		if (net_debug) printk("cs89x0: Tx buffer not free!\n");
 		return NETDEV_TX_BUSY;
 	}
 	/* Write the contents of the packet */
 	writewords(dev->base_addr, TX_FRAME_PORT,skb->data,(skb->len+1) >>1);
-	spin_unlock_irq(&lp->lock);
+	spin_unlock_irqrestore(&lp->lock, flags);
 	lp->stats.tx_bytes += skb->len;
 	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index 73585fd..d12377b 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -430,7 +430,8 @@ static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	 * hardware interrupt handler.  Queue flow control is
 	 * thus managed under this lock as well.
 	 */
-	spin_lock_irq(&np->lock);
+	unsigned long flags;
+	spin_lock_irqsave(&np->lock, flags);
 
 	add_to_tx_ring(np, skb, length);
 	dev->trans_start = jiffies;
@@ -446,7 +447,7 @@ static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	 * is when the transmit statistics are updated.
 	 */
 
-	spin_unlock_irq(&np->lock);
+	spin_unlock_irqrestore(&np->lock, flags);
 #else
 	/* This is the case for older hardware which takes
 	 * a single transmit buffer at a time, and it is
-- 
1.6.0.4

