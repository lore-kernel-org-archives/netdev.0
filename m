From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH net v6 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Thu,  4 Sep 2014 18:30:47 -0700
Message-ID: <1409880647-14887-5-git-send-email-bpoirier@suse.de>
References: <1409880647-14887-1-git-send-email-bpoirier@suse.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35345 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755790AbaIEBbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 21:31:37 -0400
In-Reply-To: <1409880647-14887-1-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
by gso, this patch changes tg3_set_ringparam() to ignore the requirements of
tg3_tso_bug(). Those requirements are instead checked in tg3_tso_bug() itself
and if there is not a sufficient number of descriptors available in the tx
queue, the skb is linearized.

This patch also removes the current scheme in tg3_tso_bug() where the number
of descriptors required to transmit an skb is estimated. Instead,
gso_segment() is called without _SG which yields predictable, linear skbs.

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

Changes v5->v6
* avoid changing gso_max_segs and making the tx queue wakeup threshold
  dynamic. Instead of stopping the queue when there are not enough descriptors
  available, the skb is linearized.

I reproduced this bug using the same approach explained in patch 1.
The bug reproduces with tx_pending <= 135
---
 drivers/net/ethernet/broadcom/tg3.c | 59 ++++++++++++++++++++++++-------------
 1 file changed, 38 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 6e6b07c..a9787a1 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7830,6 +7830,8 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 }
 
 static netdev_tx_t tg3_start_xmit(struct sk_buff *, struct net_device *);
+static netdev_tx_t __tg3_start_xmit(struct sk_buff *, struct net_device *,
+				    u32);
 
 /* Returns true if the queue has been stopped. Note that it may have been
  * restarted since.
@@ -7866,27 +7868,38 @@ static inline bool tg3_maybe_stop_txq(struct tg3_napi *tnapi,
 static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
 		       struct netdev_queue *txq, struct sk_buff *skb)
 {
-	struct sk_buff *segs, *nskb;
-	u32 frag_cnt_est = skb_shinfo(skb)->gso_segs * 3;
+	unsigned int segs_remaining = skb_shinfo(skb)->gso_segs;
 
-	/* Estimate the number of fragments in the worst case */
-	tg3_maybe_stop_txq(tnapi, txq, frag_cnt_est, frag_cnt_est);
-	if (netif_tx_queue_stopped(txq))
-		return NETDEV_TX_BUSY;
+	if (unlikely(tg3_tx_avail(tnapi) <= segs_remaining)) {
+		if (!skb_is_nonlinear(skb) || skb_linearize(skb))
+			goto tg3_tso_bug_drop;
+		tg3_start_xmit(skb, tp->dev);
+	} else {
+		struct sk_buff *segs, *nskb;
 
-	segs = skb_gso_segment(skb, tp->dev->features &
-				    ~(NETIF_F_TSO | NETIF_F_TSO6));
-	if (IS_ERR(segs) || !segs)
-		goto tg3_tso_bug_end;
+		segs = skb_gso_segment(skb, tp->dev->features &
+				       ~(NETIF_F_TSO | NETIF_F_TSO6 |
+					 NETIF_F_SG));
+		if (IS_ERR(segs) || !segs)
+			goto tg3_tso_bug_drop;
 
-	do {
-		nskb = segs;
-		segs = segs->next;
-		nskb->next = NULL;
-		tg3_start_xmit(nskb, tp->dev);
-	} while (segs);
+		do {
+			nskb = segs;
+			segs = segs->next;
+			nskb->next = NULL;
+			if (--segs_remaining)
+				__tg3_start_xmit(nskb, tp->dev, segs_remaining);
+			else
+				tg3_start_xmit(nskb, tp->dev);
+		} while (segs);
 
-tg3_tso_bug_end:
+		dev_kfree_skb_any(skb);
+	}
+
+	return NETDEV_TX_OK;
+
+tg3_tso_bug_drop:
+	tp->tx_dropped++;
 	dev_kfree_skb_any(skb);
 
 	return NETDEV_TX_OK;
@@ -7895,6 +7908,12 @@ tg3_tso_bug_end:
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
@@ -8102,7 +8121,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tw32_tx_mbox(tnapi->prodmbox, entry);
 
 	tnapi->tx_prod = entry;
-	tg3_maybe_stop_txq(tnapi, txq, MAX_SKB_FRAGS + 1,
+	tg3_maybe_stop_txq(tnapi, txq, stop_thresh,
 			   TG3_TX_WAKEUP_THRESH(tnapi));
 
 	mmiowb();
@@ -12336,9 +12355,7 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 	if ((ering->rx_pending > tp->rx_std_ring_mask) ||
 	    (ering->rx_jumbo_pending > tp->rx_jmb_ring_mask) ||
 	    (ering->tx_pending > TG3_TX_RING_SIZE - 1) ||
-	    (ering->tx_pending <= MAX_SKB_FRAGS + 1) ||
-	    (tg3_flag(tp, TSO_BUG) &&
-	     (ering->tx_pending <= (MAX_SKB_FRAGS * 3))))
+	    (ering->tx_pending <= MAX_SKB_FRAGS + 1))
 		return -EINVAL;
 
 	if (netif_running(dev)) {
-- 
1.8.4.5
