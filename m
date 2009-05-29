From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/10]: p54: Use SKB list handling helpers instead of
 by-hand code.
Date: Fri, 29 May 2009 01:40:09 -0700 (PDT)
Message-ID: <20090529.014009.107644427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757277AbZE2IkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:40:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/wireless/p54/p54common.c |   46 ++++++++++++++--------------------
 1 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireless/p54/p54common.c
index 48d81d9..b618bd1 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -823,30 +823,30 @@ void p54_free_skb(struct ieee80211_hw *dev, struct sk_buff *skb)
 	struct p54_tx_info *range;
 	unsigned long flags;
 
-	if (unlikely(!skb || !dev || !skb_queue_len(&priv->tx_queue)))
+	if (unlikely(!skb || !dev || skb_queue_empty(&priv->tx_queue)))
 		return;
 
-	/*
-	 * don't try to free an already unlinked skb
+	/* There used to be a check here to see if the SKB was on the
+	 * TX queue or not.  This can never happen because all SKBs we
+	 * see here successfully went through p54_assign_address()
+	 * which means the SKB is on the ->tx_queue.
 	 */
-	if (unlikely((!skb->next) || (!skb->prev)))
-		return;
 
 	spin_lock_irqsave(&priv->tx_queue.lock, flags);
 	info = IEEE80211_SKB_CB(skb);
 	range = (void *)info->rate_driver_data;
-	if (skb->prev != (struct sk_buff *)&priv->tx_queue) {
+	if (!skb_queue_is_first(&priv->tx_queue, skb)) {
 		struct ieee80211_tx_info *ni;
 		struct p54_tx_info *mr;
 
-		ni = IEEE80211_SKB_CB(skb->prev);
+		ni = IEEE80211_SKB_CB(skb_queue_prev(&priv->tx_queue, skb));
 		mr = (struct p54_tx_info *)ni->rate_driver_data;
 	}
-	if (skb->next != (struct sk_buff *)&priv->tx_queue) {
+	if (!skb_queue_is_last(&priv->tx_queue, skb)) {
 		struct ieee80211_tx_info *ni;
 		struct p54_tx_info *mr;
 
-		ni = IEEE80211_SKB_CB(skb->next);
+		ni = IEEE80211_SKB_CB(skb_queue_next(&priv->tx_queue, skb));
 		mr = (struct p54_tx_info *)ni->rate_driver_data;
 	}
 	__skb_unlink(skb, &priv->tx_queue);
@@ -864,15 +864,13 @@ static struct sk_buff *p54_find_tx_entry(struct ieee80211_hw *dev,
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->tx_queue.lock, flags);
-	entry = priv->tx_queue.next;
-	while (entry != (struct sk_buff *)&priv->tx_queue) {
+	skb_queue_walk(&priv->tx_queue, entry) {
 		struct p54_hdr *hdr = (struct p54_hdr *) entry->data;
 
 		if (hdr->req_id == req_id) {
 			spin_unlock_irqrestore(&priv->tx_queue.lock, flags);
 			return entry;
 		}
-		entry = entry->next;
 	}
 	spin_unlock_irqrestore(&priv->tx_queue.lock, flags);
 	return NULL;
@@ -890,24 +888,22 @@ static void p54_rx_frame_sent(struct ieee80211_hw *dev, struct sk_buff *skb)
 	int count, idx;
 
 	spin_lock_irqsave(&priv->tx_queue.lock, flags);
-	entry = (struct sk_buff *) priv->tx_queue.next;
-	while (entry != (struct sk_buff *)&priv->tx_queue) {
+	skb_queue_walk(&priv->tx_queue, entry) {
 		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(entry);
 		struct p54_hdr *entry_hdr;
 		struct p54_tx_data *entry_data;
 		unsigned int pad = 0, frame_len;
 
 		range = (void *)info->rate_driver_data;
-		if (range->start_addr != addr) {
-			entry = entry->next;
+		if (range->start_addr != addr)
 			continue;
-		}
 
-		if (entry->next != (struct sk_buff *)&priv->tx_queue) {
+		if (!skb_queue_is_last(&priv->tx_queue, entry)) {
 			struct ieee80211_tx_info *ni;
 			struct p54_tx_info *mr;
 
-			ni = IEEE80211_SKB_CB(entry->next);
+			ni = IEEE80211_SKB_CB(skb_queue_next(&priv->tx_queue,
+							     entry));
 			mr = (struct p54_tx_info *)ni->rate_driver_data;
 		}
 
@@ -1168,23 +1164,21 @@ static int p54_assign_address(struct ieee80211_hw *dev, struct sk_buff *skb,
 		}
 	}
 
-	entry = priv->tx_queue.next;
-	while (left--) {
+	skb_queue_walk(&priv->tx_queue, entry) {
 		u32 hole_size;
 		info = IEEE80211_SKB_CB(entry);
 		range = (void *)info->rate_driver_data;
 		hole_size = range->start_addr - last_addr;
 		if (!target_skb && hole_size >= len) {
-			target_skb = entry->prev;
+			target_skb = skb_queue_prev(&priv->tx_queue, entry);
 			hole_size -= len;
 			target_addr = last_addr;
 		}
 		largest_hole = max(largest_hole, hole_size);
 		last_addr = range->end_addr;
-		entry = entry->next;
 	}
 	if (!target_skb && priv->rx_end - last_addr >= len) {
-		target_skb = priv->tx_queue.prev;
+		target_skb = skb_peek_tail(&priv->tx_queue);
 		largest_hole = max(largest_hole, priv->rx_end - last_addr - len);
 		if (!skb_queue_empty(&priv->tx_queue)) {
 			info = IEEE80211_SKB_CB(target_skb);
@@ -2090,7 +2084,6 @@ out:
 static void p54_stop(struct ieee80211_hw *dev)
 {
 	struct p54_common *priv = dev->priv;
-	struct sk_buff *skb;
 
 	mutex_lock(&priv->conf_mutex);
 	priv->mode = NL80211_IFTYPE_UNSPECIFIED;
@@ -2105,8 +2098,7 @@ static void p54_stop(struct ieee80211_hw *dev)
 		p54_tx_cancel(dev, priv->cached_beacon);
 
 	priv->stop(dev);
-	while ((skb = skb_dequeue(&priv->tx_queue)))
-		kfree_skb(skb);
+	skb_queue_purge(&priv->tx_queue);
 	priv->cached_beacon = NULL;
 	priv->tsf_high32 = priv->tsf_low32 = 0;
 	mutex_unlock(&priv->conf_mutex);
-- 
1.6.3

