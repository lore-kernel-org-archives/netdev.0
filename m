From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] tg3 shutdown sequence update
Date: Mon, 25 Nov 2002 01:34:16 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE1C468.1060806@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040304080808010802090102"
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040304080808010802090102
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch is only for testing and comment, _not_ for applying.
(testers requested)

The attached patch updates the tg3 net driver shutdown sequence to be a 
bit more correct WRT the documented sequence.  Detailed changes:

* bail out of tg3_stop_block ASAP if block is already disabled
* use standard tg3_stop_block to disable RX MAC mode.  this adds polling 
of the the enable bit to the standard code.
* just in case, shut down DMA completion between send data completion 
shutdown and send DB completion shutdown
* use standard tg3_stop_block to disable TX MAC mode.
* don't bother to disable MAC_MODE_TDE_ENABLE bit manually, TX MAC mode 
disable does it for us.
* add PCI posting flush for flow-through queues

Does this look ok WRT errata and hardware seen in the field?

One potential concern is that the error handling if tg3_stop_block fails 
runs through all the blocks unconditionally, and then returns an error. 
  It does not bail early if some of the stop-block calls fail.

Comments?

	Jeff



--------------040304080808010802090102
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"


--- drivers/net/tg3.c.~1~	Tue Nov 19 15:30:41 2002
+++ drivers/net/tg3.c	Tue Nov 19 15:31:34 2002
@@ -2367,6 +2367,7 @@
 	unsigned int i;
 	u32 len, entry, base_flags, mss;
 	int would_hit_hwbug;
+	unsigned long flags;
 
 	len = (skb->len - skb->data_len);
 
@@ -2389,12 +2390,12 @@
 	 * So we really do need to disable interrupts when taking
 	 * tx_lock here.
 	 */
-	spin_lock_irq(&tp->tx_lock);
+	spin_lock_irqsave(&tp->tx_lock, flags);
 
 	/* This is a hard error, log it. */
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_stop_queue(dev);
-		spin_unlock_irq(&tp->tx_lock);
+		spin_unlock_irqrestore(&tp->tx_lock, flags);
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return 1;
@@ -2535,7 +2536,7 @@
 		netif_stop_queue(dev);
 
 out_unlock:
-	spin_unlock_irq(&tp->tx_lock);
+	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
 	dev->trans_start = jiffies;
 
@@ -2547,6 +2548,7 @@
 	struct tg3 *tp = dev->priv;
 	dma_addr_t mapping;
 	u32 len, entry, base_flags, mss;
+	unsigned long flags;
 
 	len = (skb->len - skb->data_len);
 
@@ -2569,12 +2571,12 @@
 	 * So we really do need to disable interrupts when taking
 	 * tx_lock here.
 	 */
-	spin_lock_irq(&tp->tx_lock);
+	spin_lock_irqsave(&tp->tx_lock, flags);
 
 	/* This is a hard error, log it. */
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
 		netif_stop_queue(dev);
-		spin_unlock_irq(&tp->tx_lock);
+		spin_unlock_irqrestore(&tp->tx_lock, flags);
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return 1;
@@ -2665,7 +2667,7 @@
 	if (TX_BUFFS_AVAIL(tp) <= (MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
 
-	spin_unlock_irq(&tp->tx_lock);
+	spin_unlock_irqrestore(&tp->tx_lock, flags);
 
 	dev->trans_start = jiffies;
 


--------------040304080808010802090102--
