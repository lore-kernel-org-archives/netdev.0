From: Christian Lamparter <chunkeey-S0/GAf8tV78@public.gmane.org>
Subject: [PATCH 2.6.31] p54: band-aid to restore driver functionality
Date: Fri, 19 Jun 2009 19:28:27 +0200
Message-ID: <200906191928.28386.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: "linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch is the trade-off between size vs. time vs. functionality.
Unfortunately, It reverts some portions of
"[PATCH 3/10]: p54: Use SKB list handling helpers instead of by-hand code."
as rewriting the mm code to only rely on the available helper functions
in include/linux/skbuff.h is beyond scope of -rcX patches.

in p54_assign_address:
target_skb is used as a mere "pointer" after which the next element
will be queued. It's perfectly _legal_ if this pointer points to 
priv->tx_queue's head/tail.
Also ieee80211_stop_queue(s) must not be called during initialisation.

in p54_free_skb: 
Nearly ;-)... Actually, the skb->prev || skb->next check was once very
useful for finding double frees in the back-end driver code.
However, it is dead code now and can be removed.

Signed-off-by: Christian Lamparter <chunkeey-S0/GAf8tV78@public.gmane.org>
---
--- a/drivers/net/wireless/p54/p54common.c	2009-06-19 17:02:53.000000000 +0200
+++ b/drivers/net/wireless/p54/p54common.c	2009-06-19 18:17:16.000000000 +0200
@@ -823,14 +823,8 @@ void p54_free_skb(struct ieee80211_hw *d
 	struct p54_tx_info *range;
 	unsigned long flags;
 
-	if (unlikely(!skb || !dev || skb_queue_empty(&priv->tx_queue)))
-		return;
-
-	/* There used to be a check here to see if the SKB was on the
-	 * TX queue or not.  This can never happen because all SKBs we
-	 * see here successfully went through p54_assign_address()
-	 * which means the SKB is on the ->tx_queue.
-	 */
+	if (unlikely(!skb || WARN_ON(!dev)))
+		return ;
 
 	spin_lock_irqsave(&priv->tx_queue.lock, flags);
 	info = IEEE80211_SKB_CB(skb);
@@ -1149,7 +1143,8 @@ static int p54_assign_address(struct iee
 		 * We have throttle normal data traffic, because we must
 		 * have a few spare slots for control frames left.
 		 */
-		ieee80211_stop_queues(dev);
+		if (likely(priv->mode != NL80211_IFTYPE_UNSPECIFIED))
+			ieee80211_stop_queues(dev);
 		queue_delayed_work(dev->workqueue, &priv->work,
 				   msecs_to_jiffies(P54_TX_TIMEOUT));
 
@@ -1170,7 +1165,7 @@ static int p54_assign_address(struct iee
 		range = (void *)info->rate_driver_data;
 		hole_size = range->start_addr - last_addr;
 		if (!target_skb && hole_size >= len) {
-			target_skb = skb_queue_prev(&priv->tx_queue, entry);
+			target_skb = entry->prev;
 			hole_size -= len;
 			target_addr = last_addr;
 		}
@@ -1178,7 +1173,7 @@ static int p54_assign_address(struct iee
 		last_addr = range->end_addr;
 	}
 	if (!target_skb && priv->rx_end - last_addr >= len) {
-		target_skb = skb_peek_tail(&priv->tx_queue);
+		target_skb = priv->tx_queue.prev;
 		largest_hole = max(largest_hole, priv->rx_end - last_addr - len);
 		if (!skb_queue_empty(&priv->tx_queue)) {
 			info = IEEE80211_SKB_CB(target_skb);
@@ -1190,7 +1185,8 @@ static int p54_assign_address(struct iee
 
 	if (!target_skb) {
 		spin_unlock_irqrestore(&priv->tx_queue.lock, flags);
-		ieee80211_stop_queues(dev);
+		if (likely(priv->mode != NL80211_IFTYPE_UNSPECIFIED))
+			ieee80211_stop_queues(dev);
 		return -ENOSPC;
 	}
 
@@ -1201,8 +1197,9 @@ static int p54_assign_address(struct iee
 	__skb_queue_after(&priv->tx_queue, target_skb, skb);
 	spin_unlock_irqrestore(&priv->tx_queue.lock, flags);
 
-	if (largest_hole < priv->headroom + sizeof(struct p54_hdr) +
-			   48 + IEEE80211_MAX_RTS_THRESHOLD + priv->tailroom)
+	if ((largest_hole < priv->headroom + sizeof(struct p54_hdr) +
+			   48 + IEEE80211_MAX_RTS_THRESHOLD + priv->tailroom) &&
+		(priv->mode != NL80211_IFTYPE_UNSPECIFIED))
 		ieee80211_stop_queues(dev);
 
 	data->req_id = cpu_to_le32(target_addr + priv->headroom);
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
