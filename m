From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/6] d80211: drop packets from nonexisting interfaces in PS mode
Date: Mon, 29 Jan 2007 18:48:08 +0100 (CET)
Message-ID: <20070129174808.54F4648498@silver.suse.cz>
References: <20070129184707.885764375.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41731 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752525AbXA2Rr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 12:47:57 -0500
In-Reply-To: <20070129184707.885764375.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a power saving mode, packets queued by devices that meanwhile disappeared
has to be discarded.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211.c |   46 +++++++++++++++++++++++++---------------------
 1 files changed, 25 insertions(+), 21 deletions(-)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -1104,10 +1104,10 @@ static int inline is_ieee80211_device(st
 
 /* Device in tx->dev has a reference added; use dev_put(tx->dev) when
  * finished with it. */
-static void inline ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
-					struct sk_buff *skb,
-					struct net_device *mdev,
-					struct ieee80211_tx_control *control)
+static int inline ieee80211_tx_prepare(struct ieee80211_txrx_data *tx,
+				       struct sk_buff *skb,
+				       struct net_device *mdev,
+				       struct ieee80211_tx_control *control)
 {
 	struct ieee80211_tx_packet_data *pkt_data;
 	struct net_device *dev;
@@ -1118,13 +1118,10 @@ static void inline ieee80211_tx_prepare(
 		dev_put(dev);
 		dev = NULL;
 	}
-	if (unlikely(!dev)) {
-		printk(KERN_WARNING "%s: NULL ifindex in pkt_data\n",
-		       mdev->name);
-		dev = mdev;
-		dev_hold(dev);
-	}
+	if (unlikely(!dev))
+		return -ENODEV;
 	__ieee80211_tx_prepare(tx, skb, dev, control);
+	return 0;
 }
 
 static inline int __ieee80211_queue_stopped(struct ieee80211_local *local,
@@ -1815,20 +1812,27 @@ ieee80211_get_buffered_bc(struct ieee802
 
 	if (bss->dtim_count != 0)
 		return NULL; /* send buffered bc/mc only after DTIM beacon */
-	skb = skb_dequeue(&bss->ps_bc_buf);
 	memset(control, 0, sizeof(*control));
-	if (!skb)
-		return NULL;
-	local->total_ps_buffered--;
+	while (1) {
+		skb = skb_dequeue(&bss->ps_bc_buf);
+		if (!skb)
+			return NULL;
+		local->total_ps_buffered--;
 
-	if (!skb_queue_empty(&bss->ps_bc_buf) && skb->len >= 2) {
-		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
-		/* more buffered multicast/broadcast frames ==> set MoreData
-		 * flag in IEEE 802.11 header to inform PS STAs */
-		hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_MOREDATA);
-	}
+		if (!skb_queue_empty(&bss->ps_bc_buf) && skb->len >= 2) {
+			struct ieee80211_hdr *hdr =
+				(struct ieee80211_hdr *) skb->data;
+			/* more buffered multicast/broadcast frames ==> set
+			 * MoreData flag in IEEE 802.11 header to inform PS
+			 * STAs */
+			hdr->frame_control |=
+				cpu_to_le16(IEEE80211_FCTL_MOREDATA);
+		}
 
-	ieee80211_tx_prepare(&tx, skb, local->mdev, control);
+		if (ieee80211_tx_prepare(&tx, skb, local->mdev, control) == 0)
+			break;
+		dev_kfree_skb_any(skb);
+	}
 	sta = tx.sta;
 	tx.u.tx.ps_buffered = 1;
 
