From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH net v5 3/4] tg3: Move tx queue stop logic to its own function
Date: Fri, 29 Aug 2014 13:46:30 -0700
Message-ID: <1409345191-8819-3-git-send-email-bpoirier@suse.de>
References: <1409345191-8819-1-git-send-email-bpoirier@suse.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409345191-8819-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is duplicated. Also, the first instance in tg3_start_xmit() is racy.
Consider:

tg3_start_xmit()
	if budget <= ...
				tg3_tx()
					(free up the entire ring)
					tx_cons =
					smp_mb
					if queue_stopped and tx_avail, NO
		if !queue_stopped
			stop queue
		return NETDEV_TX_BUSY

... tx queue stopped forever

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---
Changes v2->v3
* new patch to avoid repeatedly open coding this block in the next patch.

Changes v3->v4
* added a comment to clarify the return value, as suggested
* replaced the BUG_ON with netdev_err(). No need to be so dramatic, this
  situation will trigger a netdev watchdog anyways.
---
 drivers/net/ethernet/broadcom/tg3.c | 75 ++++++++++++++++++++-----------------
 1 file changed, 40 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0cecd6d..f706a1e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7831,6 +7831,35 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 
 static netdev_tx_t tg3_start_xmit(struct sk_buff *, struct net_device *);
 
+/* Returns true if the queue has been stopped. Note that it may have been
+ * restarted since.
+ */
+static inline bool tg3_maybe_stop_txq(struct tg3_napi *tnapi,
+				      struct netdev_queue *txq,
+				      u32 stop_thresh, u32 wakeup_thresh)
+{
+	bool stopped = false;
+
+	if (unlikely(tg3_tx_avail(tnapi) <= stop_thresh)) {
+		if (!netif_tx_queue_stopped(txq)) {
+			stopped = true;
+			netif_tx_stop_queue(txq);
+			if (wakeup_thresh >= tnapi->tx_pending)
+				netdev_err(tnapi->tp->dev,
+					   "BUG! wakeup_thresh too large (%u >= %u)\n",
+					   wakeup_thresh, tnapi->tx_pending);
+		}
+		/* netif_tx_stop_queue() must be done before checking tx index
+		 * in tg3_tx_avail(), because in tg3_tx(), we update tx index
+		 * before checking for netif_tx_queue_stopped().
+		 */
+		smp_mb();
+		if (tg3_tx_avail(tnapi) > wakeup_thresh)
+			netif_tx_wake_queue(txq);
+	}
+	return stopped;
+}
+
 /* Use GSO to workaround all TSO packets that meet HW bug conditions
  * indicated in tg3_tx_frag_set()
  */
@@ -7841,20 +7870,9 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
 	u32 frag_cnt_est = skb_shinfo(skb)->gso_segs * 3;
 
 	/* Estimate the number of fragments in the worst case */
-	if (unlikely(tg3_tx_avail(tnapi) <= frag_cnt_est)) {
-		netif_tx_stop_queue(txq);
-
-		/* netif_tx_stop_queue() must be done before checking
-		 * checking tx index in tg3_tx_avail() below, because in
-		 * tg3_tx(), we update tx index before checking for
-		 * netif_tx_queue_stopped().
-		 */
-		smp_mb();
-		if (tg3_tx_avail(tnapi) <= frag_cnt_est)
-			return NETDEV_TX_BUSY;
-
-		netif_tx_wake_queue(txq);
-	}
+	tg3_maybe_stop_txq(tnapi, txq, frag_cnt_est, frag_cnt_est);
+	if (netif_tx_queue_stopped(txq))
+		return NETDEV_TX_BUSY;
 
 	segs = skb_gso_segment(skb, tp->dev->features &
 				    ~(NETIF_F_TSO | NETIF_F_TSO6));
@@ -7902,16 +7920,13 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * interrupt.  Furthermore, IRQ processing runs lockless so we have
 	 * no IRQ context deadlocks to worry about either.  Rejoice!
 	 */
-	if (unlikely(budget <= (skb_shinfo(skb)->nr_frags + 1))) {
-		if (!netif_tx_queue_stopped(txq)) {
-			netif_tx_stop_queue(txq);
-
-			/* This is a hard error, log it. */
-			netdev_err(dev,
-				   "BUG! Tx Ring full when queue awake!\n");
-		}
-		return NETDEV_TX_BUSY;
+	if (tg3_maybe_stop_txq(tnapi, txq, skb_shinfo(skb)->nr_frags + 1,
+			       TG3_TX_WAKEUP_THRESH(tnapi))) {
+		/* This is a hard error, log it. */
+		netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
 	}
+	if (netif_tx_queue_stopped(txq))
+		return NETDEV_TX_BUSY;
 
 	entry = tnapi->tx_prod;
 	base_flags = 0;
@@ -8087,18 +8102,8 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	tw32_tx_mbox(tnapi->prodmbox, entry);
 
 	tnapi->tx_prod = entry;
-	if (unlikely(tg3_tx_avail(tnapi) <= (MAX_SKB_FRAGS + 1))) {
-		netif_tx_stop_queue(txq);
-
-		/* netif_tx_stop_queue() must be done before checking
-		 * checking tx index in tg3_tx_avail() below, because in
-		 * tg3_tx(), we update tx index before checking for
-		 * netif_tx_queue_stopped().
-		 */
-		smp_mb();
-		if (tg3_tx_avail(tnapi) > TG3_TX_WAKEUP_THRESH(tnapi))
-			netif_tx_wake_queue(txq);
-	}
+	tg3_maybe_stop_txq(tnapi, txq, MAX_SKB_FRAGS + 1,
+			   TG3_TX_WAKEUP_THRESH(tnapi));
 
 	mmiowb();
 	return NETDEV_TX_OK;
-- 
1.8.4.5
