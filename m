From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 6/9] d80211: optimize defragmentation
Date: Tue, 18 Jul 2006 17:45:27 +0200 (CEST)
Message-ID: <20060718154527.11F28483BB@silver.suse.cz>
References: <20060718174442.485760904.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:40585 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932294AbWGRPnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:43:39 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060718174442.485760904.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Optimize defragmentation by storing all fragments in skb queue and
reallocating skb only once all fragments are received.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   46 ++++++++++++++++++++++--------------------
 net/d80211/ieee80211_i.h     |    3 ++-
 net/d80211/ieee80211_iface.c |   19 ++++++++++++++---
 3 files changed, 41 insertions(+), 27 deletions(-)

162a9ab0920090224f0af03b4a79b45b35dd437f
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ac2c03f..cc06675 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2822,10 +2822,10 @@ ieee80211_reassemble_add(struct ieee8021
 	if (sdata->fragment_next >= IEEE80211_FRAGMENT_MAX)
 		sdata->fragment_next = 0;
 
-	if (entry->skb) {
+	if (!skb_queue_empty(&entry->skb_list)) {
 #ifdef CONFIG_D80211_DEBUG
 		struct ieee80211_hdr *hdr =
-			(struct ieee80211_hdr *) entry->skb->data;
+			(struct ieee80211_hdr *) entry->skb_list.next->data;
 		printk(KERN_DEBUG "%s: RX reassembly removed oldest "
 		       "fragment entry (idx=%d age=%lu seq=%d last_frag=%d "
 		       "addr1=" MACSTR " addr2=" MACSTR "\n",
@@ -2834,16 +2834,17 @@ #ifdef CONFIG_D80211_DEBUG
 		       entry->last_frag, MAC2STR(hdr->addr1),
 		       MAC2STR(hdr->addr2));
 #endif /* CONFIG_D80211_DEBUG */
-		dev_kfree_skb(entry->skb);
+		__skb_queue_purge(&entry->skb_list);
 	}
 
-	entry->skb = *skb;
+	__skb_queue_tail(&entry->skb_list, *skb); /* no need for locking */
 	*skb = NULL;
 	entry->first_frag_time = jiffies;
 	entry->seq = seq;
 	entry->rx_queue = rx_queue;
         entry->last_frag = frag;
 	entry->ccmp = 0;
+	entry->extra_len = 0;
 
 	return entry;
 }
@@ -2867,12 +2868,12 @@ ieee80211_reassemble_find(struct ieee802
 			idx = IEEE80211_FRAGMENT_MAX - 1;
 
 		entry = &sdata->fragments[idx];
-		if (!entry->skb || entry->seq != seq ||
+		if (skb_queue_empty(&entry->skb_list) || entry->seq != seq ||
 		    entry->rx_queue != rx_queue ||
 		    entry->last_frag + 1 != frag)
 			continue;
 
-		f_hdr = (struct ieee80211_hdr *) entry->skb->data;
+		f_hdr = (struct ieee80211_hdr *) entry->skb_list.next->data;
 		f_fc = le16_to_cpu(f_hdr->frame_control);
 
 		if (WLAN_FC_GET_TYPE(fc) != WLAN_FC_GET_TYPE(f_fc) ||
@@ -2881,8 +2882,7 @@ ieee80211_reassemble_find(struct ieee802
 			continue;
 
 		if (entry->first_frag_time + 2 * HZ < jiffies) {
-			dev_kfree_skb(entry->skb);
-			entry->skb = NULL;
+			__skb_queue_purge(&entry->skb_list);
 			continue;
 		}
 		return entry;
@@ -2899,6 +2899,7 @@ ieee80211_rx_h_defragment(struct ieee802
 	u16 sc;
 	unsigned int frag, seq;
 	struct ieee80211_fragment_entry *entry;
+	struct sk_buff *skb;
 
 	hdr = (struct ieee80211_hdr *) rx->skb->data;
 	sc = le16_to_cpu(hdr->seq_ctrl);
@@ -2966,30 +2967,30 @@ ieee80211_rx_h_defragment(struct ieee802
 		memcpy(entry->last_pn, pn, CCMP_PN_LEN);
 	}
 
-	/* TODO: could gather list of skb's and reallocate data buffer only
-	 * after finding out the total length of the frame */
 	skb_pull(rx->skb, ieee80211_get_hdrlen(rx->fc));
-	if (skb_tailroom(entry->skb) < rx->skb->len) {
+	__skb_queue_tail(&entry->skb_list, rx->skb);
+	entry->last_frag = frag;
+	entry->extra_len += rx->skb->len;
+	if (rx->fc & WLAN_FC_MOREFRAG) {
+		rx->skb = NULL;
+		return TXRX_QUEUED;
+	}
+
+	rx->skb = __skb_dequeue(&entry->skb_list);
+	if (skb_tailroom(rx->skb) < entry->extra_len) {
 		I802_DEBUG_INC(rx->local->rx_expand_skb_head2);
-		if (unlikely(pskb_expand_head(entry->skb, 0, rx->skb->len,
+		if (unlikely(pskb_expand_head(rx->skb, 0, entry->extra_len,
 					      GFP_ATOMIC))) {
 			I802_DEBUG_INC(rx->local->rx_handlers_drop_defrag);
+			__skb_queue_purge(&entry->skb_list);
 			return TXRX_DROP;
 		}
 	}
-	memcpy(skb_put(entry->skb, rx->skb->len), rx->skb->data, rx->skb->len);
-	entry->last_frag = frag;
-	dev_kfree_skb(rx->skb);
-
-	if (rx->fc & WLAN_FC_MOREFRAG) {
-                rx->skb = NULL;
-		return TXRX_QUEUED;
-	}
+	while ((skb = __skb_dequeue(&entry->skb_list)))
+		memcpy(skb_put(rx->skb, skb->len), skb->data, skb->len);
 
 	/* Complete frame has been reassembled - process it now */
-	rx->skb = entry->skb;
 	rx->fragmented = 1;
-        entry->skb = NULL;
 
  out:
 	if (rx->sta)
@@ -4390,6 +4391,7 @@ struct net_device *ieee80211_alloc_hw(si
         sdata->dev = mdev;
         sdata->master = mdev;
         sdata->local = local;
+	ieee80211_if_sdata_init(sdata);
         list_add_tail(&sdata->list, &local->sub_if_list);
 
 	tasklet_init(&local->tx_pending_tasklet, ieee80211_tx_pending,
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 6a952bd..b4e294c 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -62,7 +62,8 @@ struct ieee80211_fragment_entry {
 	unsigned int seq;
 	unsigned int rx_queue;
 	unsigned int last_frag;
-	struct sk_buff *skb;
+	unsigned int extra_len;
+	struct sk_buff_head skb_list;
 	int ccmp; /* Whether fragments were encrypted with CCMP */
 	u8 last_pn[6]; /* PN of the last fragment if CCMP was used */
 };
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index f49ce8a..f64b4de 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -18,9 +18,22 @@ #include "sta_info.h"
 
 void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata)
 {
+	int i;
+
 	/* Default values for sub-interface parameters */
 	sdata->drop_unencrypted = 0;
 	sdata->eapol = 1;
+	for (i = 0; i < IEEE80211_FRAGMENT_MAX; i++)
+		skb_queue_head_init(&sdata->fragments[i].skb_list);
+}
+
+static void ieee80211_if_sdata_deinit(struct ieee80211_sub_if_data *sdata)
+{
+	int i;
+
+	for (i = 0; i < IEEE80211_FRAGMENT_MAX; i++) {
+		__skb_queue_purge(&sdata->fragments[i].skb_list);
+	}
 }
 
 /* Must be called with rtnl lock held. */
@@ -212,6 +225,7 @@ void ieee80211_if_reinit(struct net_devi
 	int i;
 
 	ASSERT_RTNL();
+	ieee80211_if_sdata_deinit(sdata);
 	for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
 		if (!sdata->keys[i])
 			continue;
@@ -337,13 +351,10 @@ void ieee80211_if_free(struct net_device
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	int i;
 
 	/* local->apdev must be NULL when freeing management interface */
 	BUG_ON(dev == local->apdev);
-	for (i = 0; i < IEEE80211_FRAGMENT_MAX; i++)
-		if (sdata->fragments[i].skb)
-			dev_kfree_skb(sdata->fragments[i].skb);
+	ieee80211_if_sdata_deinit(sdata);
 	free_netdev(dev);
 }
 
-- 
1.3.0

