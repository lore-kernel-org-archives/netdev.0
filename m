From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/10] d80211: use is_multicast_ether_addr
Date: Fri, 21 Apr 2006 22:53:21 +0200 (CEST)
Message-ID: <20060421205321.F2012482C0@silver.suse.cz>
References: <20060421225314.048983000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:45953 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932442AbWDUUwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:52:54 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421225314.048983000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace custom MULTICAST_ADDR macro with is_multicast_ether_addr function.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c   |   29 +++++++++++++++--------------
 net/d80211/ieee80211_i.h |    2 --
 2 files changed, 15 insertions(+), 16 deletions(-)

f01885676fc8b7adb838b110b4f6449cbb17dae5
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 64cc66f..eb701ac 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -731,7 +731,7 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	u16 dur;
 	struct ieee80211_tx_control *control = tx->u.tx.control;
 
-	if (!MULTICAST_ADDR(hdr->addr1)) {
+	if (!is_multicast_ether_addr(hdr->addr1)) {
 		if (tx->skb->len >= tx->local->rts_threshold &&
 		    tx->local->rts_threshold < IEEE80211_MAX_RTS_THRESHOLD) {
 			control->use_rts_cts = 1;
@@ -766,7 +766,7 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	/* Setup duration field for the first fragment of the frame. Duration
 	 * for remaining fragments will be updated when they are being sent
 	 * to low-level driver in ieee80211_tx(). */
-	dur = ieee80211_duration(tx, MULTICAST_ADDR(hdr->addr1),
+	dur = ieee80211_duration(tx, is_multicast_ether_addr(hdr->addr1),
 				 tx->fragmented ? tx->u.tx.extra_frag[0]->len :
 				 0);
 	hdr->duration_id = cpu_to_le16(dur);
@@ -1072,8 +1072,8 @@ static void inline ieee80211_tx_prepare(
 	tx->fc = le16_to_cpu(hdr->frame_control);
         control->power_level = local->conf.power_level;
 	tx->u.tx.control = control;
-        tx->u.tx.unicast = !MULTICAST_ADDR(hdr->addr1);
-        control->no_ack = MULTICAST_ADDR(hdr->addr1);
+        tx->u.tx.unicast = !is_multicast_ether_addr(hdr->addr1);
+        control->no_ack = is_multicast_ether_addr(hdr->addr1);
 	tx->fragmented = local->fragmentation_threshold <
 		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
 		skb->len + 4 /* FCS */ > local->fragmentation_threshold &&
@@ -2229,7 +2229,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 
 	if (local->bridge_packets && (sdata->type == IEEE80211_IF_TYPE_AP
 	    || sdata->type == IEEE80211_IF_TYPE_VLAN)) {
-		if (MULTICAST_ADDR(skb->data)) {
+		if (is_multicast_ether_addr(skb->data)) {
 			/* send multicast frames both to higher layers in
 			 * local net stack and back to the wireless media */
 			skb2 = skb_copy(skb, GFP_ATOMIC);
@@ -2659,7 +2659,8 @@ ieee80211_rx_h_defragment(struct ieee802
 	frag = WLAN_GET_SEQ_FRAG(sc);
 
 	if (likely((!(rx->fc & WLAN_FC_MOREFRAG) && frag == 0) ||
-		   (rx->skb)->len < 24 || MULTICAST_ADDR(hdr->addr1))) {
+		   (rx->skb)->len < 24 ||
+		   is_multicast_ether_addr(hdr->addr1))) {
 		/* not fragmented */
 		goto out;
 	}
@@ -2747,7 +2748,7 @@ ieee80211_rx_h_defragment(struct ieee802
  out:
 	if (rx->sta)
 		rx->sta->rx_packets++;
-	if (MULTICAST_ADDR(hdr->addr1))
+	if (is_multicast_ether_addr(hdr->addr1))
 		rx->local->dot11MulticastReceivedFrameCount++;
 #ifdef IEEE80211_LEDS
         else
@@ -2778,7 +2779,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 	hdr = (struct ieee80211_hdr *) rx->skb->data;
 
 	/* Drop duplicate 802.11 retransmissions (IEEE 802.11 Chap. 9.2.9) */
-	if (rx->sta && !MULTICAST_ADDR(hdr->addr1)) {
+	if (rx->sta && !is_multicast_ether_addr(hdr->addr1)) {
 		if (unlikely(rx->fc & WLAN_FC_RETRY &&
 			     rx->sta->last_seq_ctrl[rx->u.rx.queue] ==
 			     hdr->seq_ctrl)) {
@@ -2900,7 +2901,7 @@ ieee80211_rx_h_sta_process(struct ieee80
 		if (memcmp(bssid, rx->sdata->u.sta.bssid, ETH_ALEN) == 0)
 			sta->last_rx = jiffies;
 	} else
-	if (!MULTICAST_ADDR(hdr->addr1) ||
+	if (!is_multicast_ether_addr(hdr->addr1) ||
 	    rx->sdata->type == IEEE80211_IF_TYPE_STA) {
 		/* Update last_rx only for unicast frames in order to prevent
 		 * the Probe Request frames (the only broadcast frames from a
@@ -3415,7 +3416,7 @@ ieee80211_tx_h_load_stats(struct ieee802
 		hdrtime = CHAN_UTIL_HDR_LONG;
 
 	load = hdrtime;
-	if (!MULTICAST_ADDR(hdr->addr1))
+	if (!is_multicast_ether_addr(hdr->addr1))
 		load += hdrtime;
 
 	if (tx->u.tx.control->use_rts_cts)
@@ -3481,7 +3482,7 @@ ieee80211_rx_h_load_stats(struct ieee802
 		hdrtime = CHAN_UTIL_HDR_LONG;
 
 	load = hdrtime;
-	if (!MULTICAST_ADDR(hdr->addr1))
+	if (!is_multicast_ether_addr(hdr->addr1))
 		load += hdrtime;
 
 	load += skb->len * rate->rate_inv;
@@ -3792,7 +3793,7 @@ #endif /* IEEE80211_LEDS */
         if (status->ack) {
 		if (frag == 0) {
 			local->dot11TransmittedFrameCount++;
-			if (MULTICAST_ADDR(hdr->addr1))
+			if (is_multicast_ether_addr(hdr->addr1))
 				local->dot11MulticastTransmittedFrameCount++;
 			if (status->retry_count > 0)
 				local->dot11RetryCount++;
@@ -3804,8 +3805,8 @@ #endif /* IEEE80211_LEDS */
 		 * with an individual address in the address 1 field or an MPDU
 		 * with a multicast address in the address 1 field of type Data
 		 * or Management. */
-		if (!MULTICAST_ADDR(hdr->addr1) || type == WLAN_FC_TYPE_DATA ||
-		    type == WLAN_FC_TYPE_MGMT)
+		if (!is_multicast_ether_addr(hdr->addr1) ||
+		    type == WLAN_FC_TYPE_DATA || type == WLAN_FC_TYPE_MGMT)
 			local->dot11TransmittedFragmentCount++;
         } else {
 		if (frag == 0)
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 2dbb132..400c675 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -50,8 +50,6 @@ #define MAC2STR(a) ((a)[0] & 0xff), ((a)
 		   ((a)[3] & 0xff), ((a)[4] & 0xff), ((a)[5] & 0xff)
 #define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
 
-#define MULTICAST_ADDR(a) ((a)[0] & 0x01)
-
 
 /* IEEE 802.11 (Ch. 9.5 Defragmentation) requires support for concurrent
  * reception of at least three fragmented frames. This limit can be increased
-- 
1.3.0

