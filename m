From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2]: niu: Extract TX packet queueing core into
 __niu_xmit_one().
Date: Sun, 22 Jun 2008 16:16:55 -0700 (PDT)
Message-ID: <20080622.161655.81938596.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com,
	matheos.worku@sun.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754041AbYFVXQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 19:16:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


niu: Extract TX packet queueing core into __niu_xmit_one().

So that we can queue packets from multiple locations and let the top
level logic tell the hardware that new TX packets are queued, pull the
core logic of putting SKBs on the TX ring into a seperate function.

Now, all that niu_start_xmit() does is check invariants (queue has
enough space) and when __niu_xmit_one() actually does queue the frame
it hits the HW TX producer index, updates rp->prod, and updates
dev->trans_start.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |   85 +++++++++++++++++++++++++++++++----------------------
 1 files changed, 50 insertions(+), 35 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 918f802..8486da4 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6102,32 +6102,28 @@ static struct tx_ring_info *tx_ring_select(struct niu *np, struct sk_buff *skb)
 	return &np->tx_rings[0];
 }
 
-static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
+/* Transmit one SKB on the given TX ring, return the resulting TX
+ * producer index.  No errors may be returned.  If something occurs
+ * which prevents sending this packet, it will be dropped.
+ *
+ * All necessary locking is made by the caller.
+ */
+static int __niu_xmit_one(struct niu *np, struct tx_ring_info *rp,
+			  struct net_device *dev, struct sk_buff *skb,
+			  int prod_entry)
 {
-	struct niu *np = netdev_priv(dev);
 	unsigned long align, headroom;
-	struct tx_ring_info *rp;
 	struct tx_pkt_hdr *tp;
-	unsigned int len, nfg;
+	int prod = prod_entry;
+	int len, tlen, nfg, i;
 	struct ethhdr *ehdr;
-	int prod, i, tlen;
 	u64 mapping, mrk;
 
-	rp = tx_ring_select(np, skb);
-
-	if (niu_tx_avail(rp) <= (skb_shinfo(skb)->nr_frags + 1)) {
-		netif_stop_queue(dev);
-		dev_err(np->device, PFX "%s: BUG! Tx ring full when "
-			"queue awake!\n", dev->name);
-		rp->tx_errors++;
-		return NETDEV_TX_BUSY;
-	}
-
 	if (skb->len < ETH_ZLEN) {
 		unsigned int pad_bytes = ETH_ZLEN - skb->len;
 
 		if (skb_pad(skb, pad_bytes))
-			goto out;
+			goto out_err;
 		skb_put(skb, pad_bytes);
 	}
 
@@ -6136,11 +6132,9 @@ static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct sk_buff *skb_new;
 
 		skb_new = skb_realloc_headroom(skb, len);
-		if (!skb_new) {
-			rp->tx_errors++;
-			goto out_drop;
-		}
 		kfree_skb(skb);
+		if (!skb_new)
+			goto out_err;
 		skb = skb_new;
 	} else
 		skb_orphan(skb);
@@ -6192,7 +6186,7 @@ static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		len -= this_len;
 	}
 
-	for (i = 0; i <  skb_shinfo(skb)->nr_frags; i++) {
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		len = frag->size;
@@ -6208,27 +6202,48 @@ static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		prod = NEXT_TX(rp, prod);
 	}
 
-	if (prod < rp->prod)
-		rp->wrap_bit ^= TX_RING_KICK_WRAP;
-	rp->prod = prod;
+	return prod;
 
-	nw64(TX_RING_KICK(rp->tx_channel), rp->wrap_bit | (prod << 3));
+out_err:
+	rp->tx_errors++;
+	return prod_entry;
 
-	if (unlikely(niu_tx_avail(rp) <= (MAX_SKB_FRAGS + 1))) {
+}
+
+static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct niu *np = netdev_priv(dev);
+	struct tx_ring_info *rp;
+	int prod;
+
+	rp = tx_ring_select(np, skb);
+
+	if (niu_tx_avail(rp) <= (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
-		if (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp))
-			netif_wake_queue(dev);
+		dev_err(np->device, PFX "%s: BUG! Tx ring full when "
+			"queue awake!\n", dev->name);
+		rp->tx_errors++;
+		return NETDEV_TX_BUSY;
 	}
 
-	dev->trans_start = jiffies;
+	prod = __niu_xmit_one(np, rp, dev, skb, rp->prod);
+	if (prod != rp->prod) {
+		if (prod < rp->prod)
+			rp->wrap_bit ^= TX_RING_KICK_WRAP;
+		rp->prod = prod;
 
-out:
-	return NETDEV_TX_OK;
+		nw64(TX_RING_KICK(rp->tx_channel),
+		     rp->wrap_bit | (prod << 3));
 
-out_drop:
-	rp->tx_errors++;
-	kfree_skb(skb);
-	goto out;
+		if (unlikely(niu_tx_avail(rp) <= (MAX_SKB_FRAGS + 1))) {
+			netif_stop_queue(dev);
+			if (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp))
+				netif_wake_queue(dev);
+		}
+		dev->trans_start = jiffies;
+	}
+
+	return NETDEV_TX_OK;
 }
 
 static int niu_change_mtu(struct net_device *dev, int new_mtu)
-- 
1.5.6

