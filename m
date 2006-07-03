From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/4] d80211: fix defragmentation
Date: Mon,  3 Jul 2006 19:24:09 +0200 (CEST)
Message-ID: <20060703172409.D1AB2483BC@silver.suse.cz>
References: <20060703192335.935001000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:2991 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751208AbWGCRWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 13:22:36 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060703192335.935001000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When multiple virtual interfaces are active and some of them is in promisc
mode, defragmentation does not work. Fix it by introducing separate fragment
table for each virtual interface.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   26 +++++++++++---------------
 net/d80211/ieee80211_i.h     |    8 ++++----
 net/d80211/ieee80211_iface.c |    5 +++++
 3 files changed, 20 insertions(+), 19 deletions(-)

9b8e66f2aee1f620da25453255cf58e8744519a6
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 52316f9..7b0b4c1 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2812,17 +2812,17 @@ #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 
 
 static inline struct ieee80211_fragment_entry *
-ieee80211_reassemble_add(struct ieee80211_local *local,
+ieee80211_reassemble_add(struct ieee80211_sub_if_data *sdata,
 			 unsigned int frag, unsigned int seq, int rx_queue,
 			 struct sk_buff **skb)
 {
         struct ieee80211_fragment_entry *entry;
 	int idx;
 
-	idx = local->fragment_next;
-	entry = &local->fragments[local->fragment_next++];
-	if (local->fragment_next >= IEEE80211_FRAGMENT_MAX)
-		local->fragment_next = 0;
+	idx = sdata->fragment_next;
+	entry = &sdata->fragments[sdata->fragment_next++];
+	if (sdata->fragment_next >= IEEE80211_FRAGMENT_MAX)
+		sdata->fragment_next = 0;
 
 	if (entry->skb) {
 #ifdef CONFIG_D80211_DEBUG
@@ -2831,7 +2831,7 @@ #ifdef CONFIG_D80211_DEBUG
 		printk(KERN_DEBUG "%s: RX reassembly removed oldest "
 		       "fragment entry (idx=%d age=%lu seq=%d last_frag=%d "
 		       "addr1=" MACSTR " addr2=" MACSTR "\n",
-		       local->mdev->name, idx,
+		       sdata->dev->name, idx,
 		       jiffies - entry->first_frag_time, entry->seq,
 		       entry->last_frag, MAC2STR(hdr->addr1),
 		       MAC2STR(hdr->addr2));
@@ -2852,14 +2852,14 @@ #endif /* CONFIG_D80211_DEBUG */
 
 
 static inline struct ieee80211_fragment_entry *
-ieee80211_reassemble_find(struct ieee80211_local *local,
+ieee80211_reassemble_find(struct ieee80211_sub_if_data *sdata,
 			  u16 fc, unsigned int frag, unsigned int seq,
 			  int rx_queue, struct ieee80211_hdr *hdr)
 {
 	struct ieee80211_fragment_entry *entry;
         int i, idx;
 
-	idx = local->fragment_next;
+	idx = sdata->fragment_next;
 	for (i = 0; i < IEEE80211_FRAGMENT_MAX; i++) {
 		struct ieee80211_hdr *f_hdr;
 		u16 f_fc;
@@ -2868,7 +2868,7 @@ ieee80211_reassemble_find(struct ieee802
 		if (idx < 0)
 			idx = IEEE80211_FRAGMENT_MAX - 1;
 
-		entry = &local->fragments[idx];
+		entry = &sdata->fragments[idx];
 		if (!entry->skb || entry->seq != seq ||
 		    entry->rx_queue != rx_queue ||
 		    entry->last_frag + 1 != frag)
@@ -2918,7 +2918,7 @@ ieee80211_rx_h_defragment(struct ieee802
 
 	if (frag == 0) {
 		/* This is the first fragment of a new frame. */
-		entry = ieee80211_reassemble_add(rx->local, frag, seq,
+		entry = ieee80211_reassemble_add(rx->sdata, frag, seq,
 						 rx->u.rx.queue, &(rx->skb));
 		if (rx->key && rx->key->alg == ALG_CCMP &&
 		    (rx->fc & WLAN_FC_ISWEP)) {
@@ -2935,7 +2935,7 @@ ieee80211_rx_h_defragment(struct ieee802
 	/* This is a fragment for a frame that should already be pending in
 	 * fragment cache. Add this fragment to the end of the pending entry.
 	 */
-	entry = ieee80211_reassemble_find(rx->local, rx->fc, frag, seq,
+	entry = ieee80211_reassemble_find(rx->sdata, rx->fc, frag, seq,
 					  rx->u.rx.queue, hdr);
 	if (!entry) {
 		I802_DEBUG_INC(rx->local->rx_handlers_drop_defrag);
@@ -4573,10 +4573,6 @@ void ieee80211_unregister_hw(struct net_
 				  &local->class_dev.kobj);
 	ieee80211_dev_sysfs_del(local);
 
-	for (i = 0; i < IEEE80211_FRAGMENT_MAX; i++)
-		if (local->fragments[i].skb)
-			dev_kfree_skb(local->fragments[i].skb);
-
 	for (i = 0; i < NUM_IEEE80211_MODES; i++) {
 		kfree(local->supp_rates[i]);
 		kfree(local->basic_rates[i]);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 3f4d00e..6a952bd 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -307,6 +307,10 @@ struct ieee80211_sub_if_data {
 	int ieee802_1x; /* IEEE 802.1X PAE - drop packet to/from unauthorized
 			 * port */
 
+	/* Fragment table for host-based reassembly */
+	struct ieee80211_fragment_entry	fragments[IEEE80211_FRAGMENT_MAX];
+	unsigned int fragment_next;
+
 #define NUM_DEFAULT_KEYS 4
         struct ieee80211_key *keys[NUM_DEFAULT_KEYS];
         struct ieee80211_key *default_key;
@@ -406,10 +410,6 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 				  * or RX before generating a rekey
 				  * notification; 0 = notification disabled. */
 
-	/* Fragment table for host-based reassembly */
-	struct ieee80211_fragment_entry	fragments[IEEE80211_FRAGMENT_MAX];
-	unsigned int fragment_next;
-
 	int bridge_packets; /* bridge packets between associated stations and
 			     * deliver multicast frames both back to wireless
 			     * media and to the local net stack */
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 566bb36..f49ce8a 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -336,9 +336,14 @@ int ieee80211_if_remove(struct net_devic
 void ieee80211_if_free(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	int i;
 
 	/* local->apdev must be NULL when freeing management interface */
 	BUG_ON(dev == local->apdev);
+	for (i = 0; i < IEEE80211_FRAGMENT_MAX; i++)
+		if (sdata->fragments[i].skb)
+			dev_kfree_skb(sdata->fragments[i].skb);
 	free_netdev(dev);
 }
 
-- 
1.3.0

