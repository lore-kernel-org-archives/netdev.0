From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] d80211: make _irqsafe functions understandable
Date: Wed, 30 Aug 2006 10:45:44 +0200
Message-ID: <1156927544.4013.60.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:30659 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750704AbWH3IpM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 04:45:12 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scheduling a tasklet when all it'll do is free the skb seems pretty
strange, we can just free the skb right away (it'll not be freed but
cleaned up later anyway then).

Also, this patch adds a few comments about what that code is doing with
the skb->cb field, namely storing a pointer and not the actual data in
there.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-26 11:22:40.129393464 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-26 11:35:44.249393464 +0200
@@ -3885,16 +3885,27 @@ void ieee80211_rx_irqsafe(struct net_dev
 			  struct ieee80211_rx_status *status)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct ieee80211_rx_status *saved;
+	struct ieee80211_rx_status *saved, *tmp;
 
-        skb->dev = dev;
+	skb->dev = dev;
 	saved = kmalloc(sizeof(struct ieee80211_rx_status), GFP_ATOMIC);
-	if (saved)
-		memcpy(saved, status, sizeof(struct ieee80211_rx_status));
+	if (unlikely(!saved)) {
+		if (net_ratelimit())
+			printk(KERN_WARNING "%s: Not enough memory, "
+			       "dropping packet", skb->dev->name);
+		/* should be dev_kfree_skb_irq, but due to this function being
+		 * named _irqsafe instead of just _irq we can't be sure that
+		 * people won't call it from non-irq contexts */
+		dev_kfree_skb_any(skb);
+		return;
+	}
+	memcpy(saved, status, sizeof(struct ieee80211_rx_status));
+	/* copy pointer to saved status into skb->cb for use by tasklet */
 	memcpy(skb->cb, &saved, sizeof(saved));
-        skb->pkt_type = ieee80211_rx_msg;
-        skb_queue_tail(&local->skb_queue, skb);
-        tasklet_schedule(&local->tasklet);
+
+	skb->pkt_type = ieee80211_rx_msg;
+	skb_queue_tail(&local->skb_queue, skb);
+	tasklet_schedule(&local->tasklet);
 }
 EXPORT_SYMBOL(ieee80211_rx_irqsafe);
 
@@ -3905,12 +3916,23 @@ void ieee80211_tx_status_irqsafe(struct 
 	struct ieee80211_tx_status *saved;
 	int tmp;
 
-        skb->dev = dev;
+	skb->dev = dev;
 	saved = kmalloc(sizeof(struct ieee80211_tx_status), GFP_ATOMIC);
-	if (saved)
-		memcpy(saved, status, sizeof(struct ieee80211_tx_status));
+	if (unlikely(!saved)) {
+		if (net_ratelimit())
+			printk(KERN_WARNING "%s: Not enough memory, "
+			       "dropping tx status", skb->dev->name);
+		/* should be dev_kfree_skb_irq, but due to this function being
+		 * named _irqsafe instead of just _irq we can't be sure that
+		 * people won't call it from non-irq contexts */
+		dev_kfree_skb_any(skb);
+		return;
+	}
+	memcpy(saved, status, sizeof(struct ieee80211_tx_status));
+	/* copy pointer to saved status into skb->cb for use by tasklet */
 	memcpy(skb->cb, &saved, sizeof(saved));
-        skb->pkt_type = ieee80211_tx_status_msg;
+
+	skb->pkt_type = ieee80211_tx_status_msg;
 	skb_queue_tail(status->control.req_tx_status ?
 		       &local->skb_queue : &local->skb_queue_unreliable, skb);
 	tmp = skb_queue_len(&local->skb_queue) +
@@ -3938,15 +3960,8 @@ static void ieee80211_tasklet_handler(un
 	       (skb = skb_dequeue(&local->skb_queue_unreliable))) {
                 switch (skb->pkt_type) {
 		case ieee80211_rx_msg:
+			/* get pointer to saved status out of skb->cb */
 			memcpy(&rx_status, skb->cb, sizeof(rx_status));
-			if (!rx_status) {
-				if (net_ratelimit())
-					printk(KERN_WARNING "%s: Not enough "
-					       "memory, dropping packet",
-					       skb->dev->name);
-				dev_kfree_skb(skb);
-				return;
-			}
 			/* Clear skb->type in order to not confuse kernel
 			 * netstack. */
 			skb->pkt_type = 0;
@@ -3954,11 +3969,8 @@ static void ieee80211_tasklet_handler(un
 			kfree(rx_status);
 			break;
 		case ieee80211_tx_status_msg:
+			/* get pointer to saved status out of skb->cb */
 			memcpy(&tx_status, skb->cb, sizeof(tx_status));
-			if (!tx_status) {
-				dev_kfree_skb(skb);
-				return;
-			}
 			skb->pkt_type = 0;
 			ieee80211_tx_status(skb->dev, skb, tx_status);
 			kfree(tx_status);

