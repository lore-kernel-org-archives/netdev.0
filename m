From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH net v5 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Fri, 29 Aug 2014 13:46:31 -0700
Message-ID: <1409345191-8819-4-git-send-email-bpoirier@suse.de>
References: <1409345191-8819-1-git-send-email-bpoirier@suse.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409345191-8819-1-git-send-email-bpoirier@suse.de>
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
threshold is made dynamic. Likewise, usually the tx queue is stopped as soon
as an skb with max frags may overrun it. Since the skbs submitted from
tg3_tso_bug() use a controlled number of descriptors, the tx queue stop
threshold may be lowered.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---

Changes v1->v2
* in tg3_set_ringparam(), reduce gso_max_segs further to budget 3 descriptors
  per gso seg instead of only 1 as in v1
* in tg3_tso_bug(), check that this estimation (3 desc/seg) holds, otherwise
  linearize some skbs as needed
* in tg3_start_xmit(), make the queue stop threshold a parameter, for the
  reason explained in the commit description

Changes v2->v3
* use tg3_maybe_stop_txq() instead of repeatedly open coding it
* add the requested tp->tx_dropped++ stat increase in tg3_tso_bug() if
  skb_linearize() fails and we must abort
* in the same code block, add an additional check to stop the queue with the
  default threshold. Otherwise, the netdev_err message at the start of
  __tg3_start_xmit() could be triggered when the next frame is transmitted.
  That is because the previous calls to __tg3_start_xmit() in tg3_tso_bug()
  may have been using a stop_thresh=segs_remaining that is < MAX_SKB_FRAGS +
  1.

Changes v3->v4
* in tg3_set_ringparam(), make sure that wakeup_thresh does not end up being
  >= tx_pending. Identified by Prashant.

Changes v4->v5
* in tg3_set_ringparam(), use TG3_TX_WAKEUP_THRESH() and tp->txq_cnt instead
  of tp->irq_max. Identified by Prashant.

I reproduced this bug using the same approach explained in patch 1.
The bug reproduces with tx_pending <= 135
---
 drivers/net/ethernet/broadcom/tg3.c | 69 +++++++++++++++++++++++++++++--------
 drivers/net/ethernet/broadcom/tg3.h |  1 +
 2 files changed, 56 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index f706a1e..43feb18 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -204,6 +204,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 /* minimum number of free TX descriptors required to wake up TX process */
 #define TG3_TX_WAKEUP_THRESH(tnapi)	max_t(u32, (tnapi)->tx_pending / 4, \
 					      MAX_SKB_FRAGS + 1)
+/* estimate a certain number of descriptors per gso segment */
+#define TG3_TX_DESC_PER_SEG(seg_nb)	((seg_nb) * 3)
+#define TG3_TX_SEG_PER_DESC(desc_nb)	((desc_nb) / 3)
+
 #define TG3_TX_BD_DMA_MAX_2K		2048
 #define TG3_TX_BD_DMA_MAX_4K		4096
 
@@ -6609,10 +6613,10 @@ static void tg3_tx(struct tg3_napi *tnapi)
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
@@ -7830,6 +7834,8 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 }
 
 static netdev_tx_t tg3_start_xmit(struct sk_buff *, struct net_device *);
+static netdev_tx_t __tg3_start_xmit(struct sk_buff *, struct net_device *,
+				    u32);
 
 /* Returns true if the queue has been stopped. Note that it may have been
  * restarted since.
@@ -7844,6 +7850,7 @@ static inline bool tg3_maybe_stop_txq(struct tg3_napi *tnapi,
 		if (!netif_tx_queue_stopped(txq)) {
 			stopped = true;
 			netif_tx_stop_queue(txq);
+			tnapi->wakeup_thresh = wakeup_thresh;
 			if (wakeup_thresh >= tnapi->tx_pending)
 				netdev_err(tnapi->tp->dev,
 					   "BUG! wakeup_thresh too large (%u >= %u)\n",
@@ -7851,10 +7858,11 @@ static inline bool tg3_maybe_stop_txq(struct tg3_napi *tnapi,
 		}
 		/* netif_tx_stop_queue() must be done before checking tx index
 		 * in tg3_tx_avail(), because in tg3_tx(), we update tx index
-		 * before checking for netif_tx_queue_stopped().
+		 * before checking for netif_tx_queue_stopped(). The memory
+		 * barrier also synchronizes wakeup_thresh changes.
 		 */
 		smp_mb();
-		if (tg3_tx_avail(tnapi) > wakeup_thresh)
+		if (tg3_tx_avail(tnapi) > tnapi->wakeup_thresh)
 			netif_tx_wake_queue(txq);
 	}
 	return stopped;
@@ -7867,10 +7875,10 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
 		       struct netdev_queue *txq, struct sk_buff *skb)
 {
 	struct sk_buff *segs, *nskb;
-	u32 frag_cnt_est = skb_shinfo(skb)->gso_segs * 3;
+	unsigned int segs_remaining = skb_shinfo(skb)->gso_segs;
+	u32 desc_cnt_est = TG3_TX_DESC_PER_SEG(segs_remaining);
 
-	/* Estimate the number of fragments in the worst case */
-	tg3_maybe_stop_txq(tnapi, txq, frag_cnt_est, frag_cnt_est);
+	tg3_maybe_stop_txq(tnapi, txq, desc_cnt_est, desc_cnt_est);
 	if (netif_tx_queue_stopped(txq))
 		return NETDEV_TX_BUSY;
 
@@ -7880,10 +7888,32 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
 		goto tg3_tso_bug_end;
 
 	do {
+		unsigned int desc_cnt = skb_shinfo(segs)->nr_frags + 1;
+
 		nskb = segs;
 		segs = segs->next;
 		nskb->next = NULL;
-		tg3_start_xmit(nskb, tp->dev);
+
+		if (tg3_tx_avail(tnapi) <= segs_remaining - 1 + desc_cnt &&
+		    skb_linearize(nskb)) {
+			tp->tx_dropped++;
+			nskb->next = segs;
+			segs = nskb;
+			do {
+				nskb = segs->next;
+
+				dev_kfree_skb_any(segs);
+				segs = nskb;
+			} while (segs);
+			tg3_maybe_stop_txq(tnapi, txq, MAX_SKB_FRAGS + 1,
+					   TG3_TX_WAKEUP_THRESH(tnapi));
+			goto tg3_tso_bug_end;
+		}
+		segs_remaining--;
+		if (segs_remaining)
+			__tg3_start_xmit(nskb, tp->dev, segs_remaining);
+		else
+			tg3_start_xmit(nskb, tp->dev);
 	} while (segs);
 
 tg3_tso_bug_end:
@@ -7895,6 +7925,12 @@ tg3_tso_bug_end:
 /* hard_start_xmit for all devices */
 static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	return __tg3_start_xmit(skb, dev, MAX_SKB_FRAGS + 1);
+}
+
+static netdev_tx_t __tg3_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev, u32 stop_thresh)
+{
 	struct tg3 *tp = netdev_priv(dev);
 	u32 len, entry, base_flags, mss, vlan = 0;
 	u32 budget;
@@ -8102,7 +8138,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tw32_tx_mbox(tnapi->prodmbox, entry);
 
 	tnapi->tx_prod = entry;
-	tg3_maybe_stop_txq(tnapi, txq, MAX_SKB_FRAGS + 1,
+	tg3_maybe_stop_txq(tnapi, txq, stop_thresh,
 			   TG3_TX_WAKEUP_THRESH(tnapi));
 
 	mmiowb();
@@ -12320,13 +12356,12 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 {
 	struct tg3 *tp = netdev_priv(dev);
 	int i, irq_sync = 0, err = 0;
+	struct tg3_napi *tnapi = &tp->napi[0];
 
 	if ((ering->rx_pending > tp->rx_std_ring_mask) ||
 	    (ering->rx_jumbo_pending > tp->rx_jmb_ring_mask) ||
 	    (ering->tx_pending > TG3_TX_RING_SIZE - 1) ||
-	    (ering->tx_pending <= MAX_SKB_FRAGS + 1) ||
-	    (tg3_flag(tp, TSO_BUG) &&
-	     (ering->tx_pending <= (MAX_SKB_FRAGS * 3))))
+	    (ering->tx_pending <= MAX_SKB_FRAGS + 1))
 		return -EINVAL;
 
 	if (netif_running(dev)) {
@@ -12346,8 +12381,13 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 	if (tg3_flag(tp, JUMBO_RING_ENABLE))
 		tp->rx_jumbo_pending = ering->rx_jumbo_pending;
 
-	for (i = 0; i < tp->irq_max; i++)
-		tp->napi[i].tx_pending = ering->tx_pending;
+	dev->gso_max_segs = TG3_TX_SEG_PER_DESC(ering->tx_pending - 1);
+	for (i = 0; i < tp->txq_cnt; i++, tnapi++) {
+		tnapi->tx_pending = ering->tx_pending;
+		if (netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)) &&
+		    tnapi->wakeup_thresh >= tnapi->tx_pending)
+			tnapi->wakeup_thresh = TG3_TX_WAKEUP_THRESH(tnapi);
+	}
 
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
@@ -17822,6 +17862,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 		else
 			sndmbx += 0xc;
 	}
+	dev->gso_max_segs = TG3_TX_SEG_PER_DESC(TG3_DEF_TX_RING_PENDING - 1);
 
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
