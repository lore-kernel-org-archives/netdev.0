From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2]: niu: Manage TX backlog in-driver.
Date: Sun, 22 Jun 2008 16:16:58 -0700 (PDT)
Message-ID: <20080622.161658.115278698.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com,
	matheos.worku@sun.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54641
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755817AbYFVXQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 19:16:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


niu: Manage TX backlog in-driver.

We no longer stop and wake the generic device queue.
Instead we manage the backlog inside of the driver,
and the mid-layer thinks that the device can always
receive packets.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |  116 +++++++++++++++++++++++++++++++++++++++-------------
 drivers/net/niu.h |   38 ++++++++++++++++-
 2 files changed, 123 insertions(+), 31 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 8486da4..d5c79c4 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3232,6 +3232,45 @@ static int release_tx_packet(struct niu *np, struct tx_ring_info *rp, int idx)
 	return idx;
 }
 
+static void __niu_tx_hit(struct niu *np, struct tx_ring_info *rp, int n)
+{
+	if (unlikely(n == rp->prod))
+		return;
+
+	if (n < rp->prod)
+		rp->wrap_bit ^= TX_RING_KICK_WRAP;
+	rp->prod = n;
+
+	nw64(TX_RING_KICK(rp->tx_channel), rp->wrap_bit | (n << 3));
+
+	np->dev->trans_start = jiffies;
+}
+
+static int __niu_xmit_one(struct niu *np, struct tx_ring_info *rp,
+			  struct net_device *dev, struct sk_buff *skb,
+			  int prod_entry);
+
+/* Queue as many backlogged TX packets as possible.  Invoked
+ * under tx_lock.
+ */
+static void __niu_xmit_backlog(struct niu *np, struct tx_ring_info *rp)
+{
+	struct sk_buff *skb;
+	int prod;
+
+	if (unlikely(skb_queue_empty(&rp->tx_backlog)))
+		return;
+
+	prod = rp->prod;
+	while ((skb = skb_peek(&rp->tx_backlog)) != NULL) {
+		if (!__niu_tx_has_space(rp, prod, skb))
+			break;
+		__skb_unlink(skb, &rp->tx_backlog);
+		prod = __niu_xmit_one(np, rp, np->dev, skb, prod);
+	}
+	__niu_tx_hit(np, rp, prod);
+}
+
 #define NIU_TX_WAKEUP_THRESH(rp)		((rp)->pending / 4)
 
 static void niu_tx_work(struct niu *np, struct tx_ring_info *rp)
@@ -3262,12 +3301,14 @@ static void niu_tx_work(struct niu *np, struct tx_ring_info *rp)
 	smp_mb();
 
 out:
-	if (unlikely(netif_queue_stopped(np->dev) &&
-		     (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp)))) {
+	/* Since this code path is running lockless, some care is needed
+	 * in order to prevent deadlocking the backlog queue.  See the
+	 * commentary in __niu_tx_queue_backlog() for details.
+	 */
+	if (!skb_queue_empty(&rp->tx_backlog) &&
+	    (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp))) {
 		netif_tx_lock(np->dev);
-		if (netif_queue_stopped(np->dev) &&
-		    (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp)))
-			netif_wake_queue(np->dev);
+		__niu_xmit_backlog(np, rp);
 		netif_tx_unlock(np->dev);
 	}
 }
@@ -3870,6 +3911,7 @@ static void niu_free_tx_ring_info(struct niu *np, struct tx_ring_info *rp)
 		rp->mbox = NULL;
 	}
 	if (rp->descr) {
+		struct sk_buff *skb;
 		int i;
 
 		for (i = 0; i < MAX_TX_RING_SIZE; i++) {
@@ -3885,6 +3927,9 @@ static void niu_free_tx_ring_info(struct niu *np, struct tx_ring_info *rp)
 		rp->prod = 0;
 		rp->cons = 0;
 		rp->wrap_bit = 0;
+
+		while ((skb = __skb_dequeue(&rp->tx_backlog)) != NULL)
+			dev_kfree_skb(skb);
 	}
 }
 
@@ -4010,6 +4055,8 @@ static int niu_alloc_tx_ring_info(struct niu *np,
 	rp->cons = 0;
 	rp->wrap_bit = 0;
 
+	skb_queue_head_init(&rp->tx_backlog);
+
 	/* XXX make these configurable... XXX */
 	rp->mark_freq = rp->pending / 4;
 
@@ -6210,37 +6257,48 @@ out_err:
 
 }
 
+static void __niu_tx_queue_backlog(struct niu *np, struct tx_ring_info *rp,
+				   struct sk_buff *skb)
+{
+	if (skb_queue_len(&rp->tx_backlog) < np->dev->tx_queue_len)
+		__skb_queue_tail(&rp->tx_backlog, skb);
+	else
+		dev_kfree_skb(skb);
+
+	smp_mb();
+
+	/* This is a deadlock breaker.  niu_tx_work() updates the consumer
+	 * index, then checks the tx_backlog for emptiness.  It also
+	 * tries to mitigate work by only flushing the backlog when at
+	 * least a certain percentage of space is available.  Those
+	 * tests in niu_tx_work() run lockless.
+	 *
+	 * Here, we make the two primary memory operations in the
+	 * reverse order.  The idea is to make sure that one of these
+	 * two code paths will process the backlog no matter what the
+	 * order of their relative execution might be.
+	 *
+	 * In short:
+	 *
+	 * niu_tx_work() --> rp->cons = foo; test skb_queue_empty()
+	 * niu_start_xmit() --> __skb_queue_tail(); test rp->cons
+	 */
+	if (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp))
+		__niu_xmit_backlog(np, rp);
+}
+
 static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct niu *np = netdev_priv(dev);
 	struct tx_ring_info *rp;
-	int prod;
 
 	rp = tx_ring_select(np, skb);
 
-	if (niu_tx_avail(rp) <= (skb_shinfo(skb)->nr_frags + 1)) {
-		netif_stop_queue(dev);
-		dev_err(np->device, PFX "%s: BUG! Tx ring full when "
-			"queue awake!\n", dev->name);
-		rp->tx_errors++;
-		return NETDEV_TX_BUSY;
-	}
-
-	prod = __niu_xmit_one(np, rp, dev, skb, rp->prod);
-	if (prod != rp->prod) {
-		if (prod < rp->prod)
-			rp->wrap_bit ^= TX_RING_KICK_WRAP;
-		rp->prod = prod;
-
-		nw64(TX_RING_KICK(rp->tx_channel),
-		     rp->wrap_bit | (prod << 3));
-
-		if (unlikely(niu_tx_avail(rp) <= (MAX_SKB_FRAGS + 1))) {
-			netif_stop_queue(dev);
-			if (niu_tx_avail(rp) > NIU_TX_WAKEUP_THRESH(rp))
-				netif_wake_queue(dev);
-		}
-		dev->trans_start = jiffies;
+	if (unlikely(!niu_tx_has_space(rp, skb))) {
+		__niu_tx_queue_backlog(np, rp, skb);
+	} else {
+		__niu_tx_hit(np, rp,
+			     __niu_xmit_one(np, rp, dev, skb, rp->prod));
 	}
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/niu.h b/drivers/net/niu.h
index c6fa883..f7d6ffc 100644
--- a/drivers/net/niu.h
+++ b/drivers/net/niu.h
@@ -2841,6 +2841,7 @@ struct tx_ring_info {
 	int			prod;
 	int			cons;
 	int			wrap_bit;
+	struct sk_buff_head	tx_backlog;
 	u16			last_pkt_cnt;
 	u16			tx_channel;
 	u16			mark_counter;
@@ -2862,10 +2863,43 @@ struct tx_ring_info {
 #define NEXT_TX(tp, index) \
 	(((index) + 1) < (tp)->pending ? ((index) + 1) : 0)
 
-static inline u32 niu_tx_avail(struct tx_ring_info *tp)
+static inline u32 __niu_tx_avail(struct tx_ring_info *tp, int prod)
 {
 	return (tp->pending -
-		((tp->prod - tp->cons) & (MAX_TX_RING_SIZE - 1)));
+		((prod - tp->cons) & (MAX_TX_RING_SIZE - 1)));
+}
+
+static inline u32 niu_tx_avail(struct tx_ring_info *tp)
+{
+	return __niu_tx_avail(tp, tp->prod);
+}
+
+/* Return true if the TX ring has enough space to queue SKB.  */
+static bool __niu_tx_has_space(struct tx_ring_info *tp, int prod,
+			       struct sk_buff *skb)
+{
+	int chunks = skb_shinfo(skb)->nr_frags + 1;
+	if (__niu_tx_avail(tp, prod) <= chunks)
+		return false;
+	return true;
+}
+
+static bool niu_tx_has_space(struct tx_ring_info *tp, struct sk_buff *skb)
+{
+	/* If the backlog has any packets, indicate no space.  We want
+	 * to queue in this case because the TX completion interrupt
+	 * handler is pending to run the backlog, and therefore if we
+	 * push the packet straight out now we'll introduce packet
+	 * reordering.
+	 *
+	 * It is important that we make this check here, and not in
+	 * __niu_tx_has_space(), otherwise the TX backlog processing
+	 * would never make any progress.
+	 */
+	if (!skb_queue_empty(&tp->tx_backlog))
+		return false;
+
+	return __niu_tx_has_space(tp, tp->prod, skb);
 }
 
 struct rxdma_mailbox {
-- 
1.5.6

