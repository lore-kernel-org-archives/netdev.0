From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH 2/3] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Tue, 19 Aug 2014 11:52:50 -0700
Message-ID: <1408474371-19509-2-git-send-email-bpoirier@suse.de>
References: <1408474371-19509-1-git-send-email-bpoirier@suse.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408474371-19509-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In tg3_set_ringparam(), the tx_pending test to cover the cases where
tg3_tso_bug() is entered has two problems
1) the check is only done for certain hardware whereas the workaround
is now used more broadly. IOW, the check may not be performed when it
is needed.
2) the check is too optimistic.

For example, with a 5761 (SHORT_DMA_BUG), tg3_set_ringparam() skips over the
"tx_pending <= (MAX_SKB_FRAGS * 3)" check because TSO_BUG is false. Even if it
did do the check, with a full sized skb, frag_cnt_est = 135 but the check is
for <= MAX_SKB_FRAGS * 3 (= 17 * 3 = 51). So the check is insufficient. This
leads to the following situation: by setting, ex. tx_pending = 100, there can
be an skb that triggers tg3_tso_bug() and that is large enough to cause
tg3_tso_bug() to stop the queue even when it is empty. We then end up with a
netdev watchdog transmit timeout.

Given that 1) some of the conditions tested for in tg3_tx_frag_set() apply
regardless of the chipset flags and that 2) it is difficult to estimate ahead
of time the max possible number of frames that a large skb may be split into
by gso, we instead take the approach of adjusting dev->gso_max_segs according
to the requested tx_pending size.

This puts us in the exceptional situation that a single skb that triggers
tg3_tso_bug() may require the entire tx ring. Usually the tx queue is woken up
when at least a quarter of it is available (TG3_TX_WAKEUP_THRESH) but that
would be insufficient now. To avoid useless wakeups, the tx queue wake up
threshold is made dynamic.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---

I reproduced this bug using the same approach explained in patch 1.
The bug reproduces with tx_pending <= 135

---
 drivers/net/ethernet/broadcom/tg3.c | 31 ++++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/tg3.h |  1 +
 2 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index b11c0fd..7022f6d 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6609,10 +6609,10 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	smp_mb();
 
 	if (unlikely(netif_tx_queue_stopped(txq) &&
-		     (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))) {
+		     (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh))) {
 		__netif_tx_lock(txq, smp_processor_id());
 		if (netif_tx_queue_stopped(txq) &&
-		    (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi)))
+		    (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh))
 			netif_tx_wake_queue(txq);
 		__netif_tx_unlock(txq);
 	}
@@ -7838,11 +7838,14 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
 		       struct netdev_queue *txq, struct sk_buff *skb)
 {
 	struct sk_buff *segs, *nskb;
-	u32 frag_cnt_est = skb_shinfo(skb)->gso_segs * 3;
 
-	/* Estimate the number of fragments in the worst case */
-	if (unlikely(tg3_tx_avail(tnapi) <= frag_cnt_est)) {
+	if (unlikely(tg3_tx_avail(tnapi) <= skb_shinfo(skb)->gso_segs)) {
+		trace_printk("stopping queue, %d <= %d\n",
+			     tg3_tx_avail(tnapi), skb_shinfo(skb)->gso_segs);
 		netif_tx_stop_queue(txq);
+		trace_printk("stopped queue\n");
+		tnapi->wakeup_thresh = skb_shinfo(skb)->gso_segs;
+		BUG_ON(tnapi->wakeup_thresh >= tnapi->tx_pending);
 
 		/* netif_tx_stop_queue() must be done before checking
 		 * checking tx index in tg3_tx_avail() below, because in
@@ -7850,7 +7853,7 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
 		 * netif_tx_queue_stopped().
 		 */
 		smp_mb();
-		if (tg3_tx_avail(tnapi) <= frag_cnt_est)
+		if (tg3_tx_avail(tnapi) <= tnapi->wakeup_thresh)
 			return NETDEV_TX_BUSY;
 
 		netif_tx_wake_queue(txq);
@@ -7905,12 +7908,17 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(budget <= (skb_shinfo(skb)->nr_frags + 1))) {
 		if (!netif_tx_queue_stopped(txq)) {
 			netif_tx_stop_queue(txq);
+			tnapi->wakeup_thresh = TG3_TX_WAKEUP_THRESH(tnapi);
 
 			/* This is a hard error, log it. */
 			netdev_err(dev,
 				   "BUG! Tx Ring full when queue awake!\n");
 		}
-		return NETDEV_TX_BUSY;
+		smp_mb();
+		if (tg3_tx_avail(tnapi) <= tnapi->wakeup_thresh)
+			return NETDEV_TX_BUSY;
+
+		netif_tx_wake_queue(txq);
 	}
 
 	entry = tnapi->tx_prod;
@@ -8089,6 +8097,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tnapi->tx_prod = entry;
 	if (unlikely(tg3_tx_avail(tnapi) <= (MAX_SKB_FRAGS + 1))) {
 		netif_tx_stop_queue(txq);
+		tnapi->wakeup_thresh = TG3_TX_WAKEUP_THRESH(tnapi);
 
 		/* netif_tx_stop_queue() must be done before checking
 		 * checking tx index in tg3_tx_avail() below, because in
@@ -8096,7 +8105,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * netif_tx_queue_stopped().
 		 */
 		smp_mb();
-		if (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi))
+		if (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh)
 			netif_tx_wake_queue(txq);
 	}
 
@@ -12319,9 +12328,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 	if ((ering->rx_pending > tp->rx_std_ring_mask) ||
 	    (ering->rx_jumbo_pending > tp->rx_jmb_ring_mask) ||
 	    (ering->tx_pending > TG3_TX_RING_SIZE - 1) ||
-	    (ering->tx_pending <= MAX_SKB_FRAGS) ||
-	    (tg3_flag(tp, TSO_BUG) &&
-	     (ering->tx_pending <= (MAX_SKB_FRAGS * 3))))
+	    (ering->tx_pending <= MAX_SKB_FRAGS))
 		return -EINVAL;
 
 	if (netif_running(dev)) {
@@ -12341,6 +12348,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 	if (tg3_flag(tp, JUMBO_RING_ENABLE))
 		tp->rx_jumbo_pending = ering->rx_jumbo_pending;
 
+	dev->gso_max_segs = ering->tx_pending - 1;
 	for (i = 0; i < tp->irq_max; i++)
 		tp->napi[i].tx_pending = ering->tx_pending;
 
@@ -17817,6 +17825,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 		else
 			sndmbx += 0xc;
 	}
+	dev->gso_max_segs = TG3_DEF_TX_RING_PENDING - 1;
 
 	tg3_init_coal(tp);
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 461acca..6a7e13d 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3006,6 +3006,7 @@ struct tg3_napi {
 	u32				tx_pending;
 	u32				last_tx_cons;
 	u32				prodmbox;
+	u32				wakeup_thresh;
 	struct tg3_tx_buffer_desc	*tx_ring;
 	struct tg3_tx_ring_info		*tx_buffers;
 
-- 
1.8.4.5
