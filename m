From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3]: tg3: Extract TX packet queueing core into
 __tg3_xmit_one().
Date: Fri, 20 Jun 2008 16:16:59 -0700 (PDT)
Message-ID: <20080620.161659.121003625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48532
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754273AbYFTXQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 19:16:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tg3: Extract TX packet queueing core into __tg3_xmit_one().

So that we can queue packets from multiple locations and
let the top level logic tell the hardware that new TX packets
are queued, pull the core logic of putting SKBs on the TX
ring into a seperate function.

Now, all that tg3_start_xmit() does is check invariants (queue has
enough space) and when __tg3_xmit_one() actually does queue the frame
it hits the HW TX producer index, updates tp->tx_entry, and updates
dev->trans_start.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tg3.c |  116 ++++++++++++++++++++++++++++++----------------------
 1 files changed, 67 insertions(+), 49 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b94a16d..096f0b9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4685,23 +4685,21 @@ static void tg3_set_txd(struct tg3 *tp, int entry,
 	txd->vlan_tag = vlan_tag << TXD_VLAN_TAG_SHIFT;
 }
 
-static int tg3_start_xmit(struct sk_buff *, struct net_device *);
+static u32 __tg3_xmit_one(struct tg3 *tp, struct net_device *dev,
+			  struct sk_buff *skb, u32 tx_entry);
 
 /* Use GSO to workaround a rare TSO bug that may be triggered when the
  * TSO header is greater than 80 bytes.
  */
-static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
+static u32 tg3_tso_bug(struct tg3 *tp, struct net_device *dev,
+		       struct sk_buff *skb, u32 tx_entry)
 {
 	struct sk_buff *segs, *nskb;
+	u32 entry = tx_entry;
 
 	/* Estimate the number of fragments in the worst case */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))) {
-		netif_stop_queue(tp->dev);
-		if (tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3))
-			return NETDEV_TX_BUSY;
-
-		netif_wake_queue(tp->dev);
-	}
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->gso_segs * 3)))
+		goto tg3_tso_bug_end;
 
 	segs = skb_gso_segment(skb, tp->dev->features & ~NETIF_F_TSO);
 	if (IS_ERR(segs))
@@ -4711,13 +4709,13 @@ static int tg3_tso_bug(struct tg3 *tp, struct sk_buff *skb)
 		nskb = segs;
 		segs = segs->next;
 		nskb->next = NULL;
-		tg3_start_xmit(nskb, tp->dev);
+		entry = __tg3_xmit_one(tp, dev, nskb, entry);
 	} while (segs);
 
 tg3_tso_bug_end:
 	dev_kfree_skb(skb);
 
-	return NETDEV_TX_OK;
+	return entry;
 }
 
 static int tg3_setup_fw_tso(struct tg3 *tp, struct sk_buff *skb, u32 *mss,
@@ -4807,45 +4805,32 @@ static int tg3_setup_hw2_tso(struct tg3 *tp, struct sk_buff *skb, u32 *mss,
 	return 0;
 }
 
-static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+/* Transmit one SKB, return the final TX descriptor slot used.
+ * No errors may be returned.  If something occurs which prevents
+ * sending this packet, it will be dropped.
+ *
+ * All necessary locking is made by the caller.
+ */
+static u32 __tg3_xmit_one(struct tg3 *tp, struct net_device *dev,
+			  struct sk_buff *skb, u32 tx_entry)
 {
-	struct tg3 *tp = netdev_priv(dev);
-	dma_addr_t mapping;
-	u32 len, entry, base_flags, mss;
+	u32 entry = tx_entry, base_flags = 0, len, mss;
 	int would_hit_hwbug;
+	dma_addr_t mapping;
 
-	len = skb_headlen(skb);
-
-	/* We are running in BH disabled context with netif_tx_lock
-	 * and TX reclaim runs via tp->napi.poll inside of a software
-	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
-	 * no IRQ context deadlocks to worry about either.  Rejoice!
-	 */
-	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_queue_stopped(dev)) {
-			netif_stop_queue(dev);
-
-			/* This is a hard error, log it. */
-			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
-			       "queue awake!\n", dev->name);
-		}
-		return NETDEV_TX_BUSY;
-	}
-
-	entry = tp->tx_prod;
 	base_flags = 0;
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		base_flags |= TXD_FLAG_TCPUDP_CSUM;
-	mss = 0;
+
 	if ((mss = skb_shinfo(skb)->gso_size) != 0) {
 		if (skb_header_cloned(skb) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
 			dev_kfree_skb(skb);
-			goto out_unlock;
+			goto out;
 		}
 
 		if (unlikely(tp->setup_tso(tp, skb, &mss, &base_flags)))
-			return (tg3_tso_bug(tp, skb));
+			return tg3_tso_bug(tp, dev, skb, entry);
 	}
 #if TG3_VLAN_TAG_USED
 	if (tp->vlgrp != NULL && vlan_tx_tag_present(skb))
@@ -4853,6 +4838,8 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			       (vlan_tx_tag_get(skb) << 16));
 #endif
 
+	len = skb_headlen(skb);
+
 	/* Queue skb data, a.k.a. the main skb fragment. */
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 
@@ -4916,26 +4903,57 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * failure, silently drop this packet.
 		 */
 		if (tigon3_dma_hwbug_workaround(tp, skb, last_plus_one,
-						&start, base_flags, mss))
-			goto out_unlock;
+						&start, base_flags, mss)) {
+			entry = tx_entry;
+			goto out;
+		}
 
 		entry = start;
 	}
 
-	/* Packets are ready, update Tx producer idx local and on card. */
-	tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW), entry);
+out:
+	return entry;
+}
 
-	tp->tx_prod = entry;
-	if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
-		netif_stop_queue(dev);
-		if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
-			netif_wake_queue(tp->dev);
+static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	u32 entry;
+
+	/* We are running in BH disabled context with netif_tx_lock
+	 * and TX reclaim runs via tp->napi.poll inside of a software
+	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
+	 * no IRQ context deadlocks to worry about either.  Rejoice!
+	 */
+	if (unlikely(tg3_tx_avail(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
+		if (!netif_queue_stopped(dev)) {
+			netif_stop_queue(dev);
+
+			/* This is a hard error, log it. */
+			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
+			       "queue awake!\n", dev->name);
+		}
+		return NETDEV_TX_BUSY;
 	}
 
-out_unlock:
-    	mmiowb();
+	entry = __tg3_xmit_one(tp, dev, skb, tp->tx_prod);
+
+	if (entry != tp->tx_prod) {
+		/* Packets are ready, update Tx producer idx local
+		 * and on card.
+		 */
+		tw32_tx_mbox((MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW),
+			     entry);
 
-	dev->trans_start = jiffies;
+		tp->tx_prod = entry;
+		if (unlikely(tg3_tx_avail(tp) <= (MAX_SKB_FRAGS + 1))) {
+			netif_stop_queue(dev);
+			if (tg3_tx_avail(tp) > TG3_TX_WAKEUP_THRESH(tp))
+				netif_wake_queue(tp->dev);
+		}
+		mmiowb();
+		dev->trans_start = jiffies;
+	}
 
 	return NETDEV_TX_OK;
 }
-- 
1.5.6

