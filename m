From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3]: tg3: Manage TX backlog in-driver.
Date: Fri, 20 Jun 2008 16:17:10 -0700 (PDT)
Message-ID: <20080620.161710.223267437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48537
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756230AbYFTXRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 19:17:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tg3: Manage TX backlog in-driver.

We no longer stop and wake the generic device queue.
Instead we manage the backlog inside of the driver,
and the mid-layer thinks that the device can always
receive packets.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tg3.c |  160 +++++++++++++++++++++++++++++++++++++---------------
 drivers/net/tg3.h |    1 +
 2 files changed, 115 insertions(+), 46 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 096f0b9..62316bc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3821,11 +3821,78 @@ static void tg3_tx_recover(struct tg3 *tp)
 	spin_unlock(&tp->lock);
 }
 
+static inline u32 __tg3_tx_avail(struct tg3 *tp, u32 prod)
+{
+	return (tp->tx_pending -
+		((prod - tp->tx_cons) & (TG3_TX_RING_SIZE - 1)));
+}
+
 static inline u32 tg3_tx_avail(struct tg3 *tp)
 {
 	smp_mb();
-	return (tp->tx_pending -
-		((tp->tx_prod - tp->tx_cons) & (TG3_TX_RING_SIZE - 1)));
+	return __tg3_tx_avail(tp, tp->tx_prod);
+}
+
+/* Return true if the TX ring has enough space to queue SKB.  */
+static bool __tg3_tx_has_space(struct tg3 *tp, u32 prod, struct sk_buff *skb)
+{
+	int chunks = skb_shinfo(skb)->nr_frags + 1;
+	if (__tg3_tx_avail(tp, prod) <= chunks)
+		return false;
+	return true;
+}
+
+static bool tg3_tx_has_space(struct tg3 *tp, struct sk_buff *skb)
+{
+	/* If the backlog has any packets, indicate no space.  We want
+	 * to queue in this case because the TX completion interrupt
+	 * handler is pending to run the backlog, and therefore if we
+	 * push the packet straight out now we'll introduce packet
+	 * reordering.
+	 *
+	 * It is important that we make this check here, and not in
+	 * __tg3_tx_has_space(), otherwise the TX backlog processing
+	 * would never make any progress.
+	 */
+	if (!skb_queue_empty(&tp->tx_backlog))
+		return false;
+
+	return __tg3_tx_has_space(tp, tp->tx_prod, skb);
+}
+
+/* Tell the chip that N is the current TX producer index.  */
+static void __tg3_tx_hit(struct tg3 *tp, u32 n)
+{
+	if (unlikely(n == tp->tx_prod))
+		return;
+	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), n);
+	tp->tx_prod = n;
+	mmiowb();
+	tp->dev->trans_start = jiffies;
+}
+
+static u32 __tg3_xmit_one(struct tg3 *tp, struct net_device *dev,
+			  struct sk_buff *skb, u32 tx_entry);
+
+/* Queue as many backlogged TX packets as possible.  Invoked
+ * under tx_lock.
+ */
+static void __tg3_xmit_backlog(struct tg3 *tp)
+{
+	struct sk_buff *skb;
+	u32 entry;
+
+	if (unlikely(skb_queue_empty(&tp->tx_backlog)))
+		return;
+
+	entry = tp->tx_prod;
+	while ((skb = skb_peek(&tp->tx_backlog)) != NULL) {
+		if (!__tg3_tx_has_space(tp, entry, skb))
+			break;
+		__skb_unlink(skb, &tp->tx_backlog);
+		entry = __tg3_xmit_one(tp, tp->dev, skb, entry);
+	}
+	__tg3_tx_hit(tp, entry);
 }
 
 /* Tigon3 never reports partial packet sends.  So we do not
@@ -3880,18 +3947,20 @@ static void tg3_tx(struct tg3 *tp)
 	tp->tx_cons = sw_idx;
 
 	/* Need to make the tx_cons update visible to tg3_start_xmit()
-	 * before checking for netif_queue_stopped().  Without the
-	 * memory barrier, there is a small possibility that tg3_start_xmit()
+	 * before checking the TX backlog.  Without the memory
+	 * barrier, there is a small possibility that tg3_start_xmit()
 	 * will miss it and cause the queue to be stopped forever.
 	 */
 	smp_mb();
 
-	if (unlikely(netif_queue_stopped(tp->dev) &&
-		     (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))) {
+	/* Since this code path is running lockless, some care is needed
+	 * in order to prevent deadlocking the backlog queue.  See the
+	 * commentary in __tg3_tx_queue_backlog() for details.
+	 */
+	if (!skb_queue_empty(&tp->tx_backlog) &&
+	    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))) {
 		netif_tx_lock(tp->dev);
-		if (netif_queue_stopped(tp->dev) &&
-		    (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp)))
-			netif_wake_queue(tp->dev);
+		__tg3_xmit_backlog(tp);
 		netif_tx_unlock(tp->dev);
 	}
 }
@@ -4685,9 +4754,6 @@ static void tg3_set_txd(struct tg3 *tp, int entry,
 	txd->vlan_tag = vlan_tag << TXD_VLAN_TAG_SHIFT;
 }
 
-static u32 __tg3_xmit_one(struct tg3 *tp, struct net_device *dev,
-			  struct sk_buff *skb, u32 tx_entry);
-
 /* Use GSO to workaround a rare TSO bug that may be triggered when the
  * TSO header is greater than 80 bytes.
  */
@@ -4915,44 +4981,43 @@ out:
 	return entry;
 }
 
-static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static void __tg3_tx_queue_backlog(struct tg3 *tp, struct sk_buff *skb)
 {
-	struct tg3 *tp = netdev_priv(dev);
-	u32 entry;
-
-	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->napi.poll inside of a software
-	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
-	 * no IRQ context deadlocks to worry about either.  Rejoice!
-	 */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
+	if (skb_queue_len(&tp->tx_backlog) < tp->dev->tx_queue_len)
+		__skb_queue_tail(&tp->tx_backlog, skb);
+	else
+		dev_kfree_skb(skb);
 
-			/* This is a hard error, log it. */
-			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
-			       "queue awake!\n", dev->name);
-		}
-		return NETDEV_TX_BUSY;
-	}
+	smp_mb();
 
-	entry = __tg3_xmit_one(tp, dev, skb, tp->tx_prod);
+	/* This is a deadlock breaker.  tg3_tx() updates the consumer
+	 * index, then checks the tx_backlog for emptiness.  It also
+	 * tries to mitigate work by only flushing the backlog when at
+	 * least a certain percentage of space is available.  Those
+	 * tests in tg3_tx() run lockless.
+	 *
+	 * Here, we make the two primary memory operations in the
+	 * reverse order.  The idea is to make sure that one of these
+	 * two code paths will process the backlog no matter what the
+	 * order of their relative execution might be.
+	 *
+	 * In short:
+	 *
+	 * tg3_tx() --> tp->tx_cons = foo; test skb_queue_empty()
+	 * tg3_start_xmit() --> __skb_queue_tail(); test tp->tx_cons
+	 */
+	if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
+		__tg3_xmit_backlog(tp);
+}
 
-	if (entry != tp->tx_prod) {
-		/* Packets are ready, update Tx producer idx local
-		 * and on card.
-		 */
-		tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW),
-			     entry);
+static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
 
-		tp->tx_prod = entry;
-		if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
-			netif_stop_queue(dev);
-			if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
-				netif_wake_queue(tp->dev);
-		}
-		mmiowb();
-		dev->trans_start = jiffies;
+	if (unlikely(!tg3_tx_has_space(tp, skb))) {
+		__tg3_tx_queue_backlog(tp, skb);
+	} else {
+		__tg3_tx_hit(tp, __tg3_xmit_one(tp, dev, skb, tp->tx_prod));
 	}
 
 	return NETDEV_TX_OK;
@@ -5026,6 +5091,7 @@ static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 static void tg3_free_rings(struct tg3 *tp)
 {
 	struct ring_info *rxp;
+	struct sk_buff *skb;
 	int i;
 
 	for (i = 0; i < TG3_RX_RING_SIZE; i++) {
@@ -5056,7 +5122,6 @@ static void tg3_free_rings(struct tg3 *tp)
 
 	for (i = 0; i < TG3_TX_RING_SIZE; ) {
 		struct tx_ring_info *txp;
-		struct sk_buff *skb;
 		int j;
 
 		txp = &tp->tx_buffers[i];
@@ -5086,6 +5151,8 @@ static void tg3_free_rings(struct tg3 *tp)
 
 		dev_kfree_skb_any(skb);
 	}
+	while ((skb = __skb_dequeue(&tp->tx_backlog)) != NULL)
+		dev_kfree_skb_any(skb);
 }
 
 /* Initialize tx/rx rings for packet processing.
@@ -13278,6 +13345,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	spin_lock_init(&tp->lock);
 	spin_lock_init(&tp->indirect_lock);
 	INIT_WORK(&tp->reset_task, tg3_reset_task);
+	skb_queue_head_init(&tp->tx_backlog);
 
 	tp->regs = ioremap_nocache(tg3reg_base, tg3reg_len);
 	if (!tp->regs) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 9ff3ba8..1792d47 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2394,6 +2394,7 @@ struct tg3 {
 	u32				tx_prod;
 	u32				tx_cons;
 	u32				tx_pending;
+	struct sk_buff_head		tx_backlog;
 
 	struct tg3_tx_buffer_desc	*tx_ring;
 	struct tx_ring_info		*tx_buffers;
-- 
1.5.6

