From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 15/17] d80211: fix handling of received frames
Date: Fri, 21 Apr 2006 22:11:46 +0200 (CEST)
Message-ID: <20060421201146.CC30F482CE@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:14727 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932427AbWDUULT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:19 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure that every frame reaches every interface it belongs to.
Previously, some packet (most notably multicast ones) were not delivered to
all interface they should be delivered to. This also allows monitor
interfaces to work easily, even together with regular interfaces.

On a typical setup (i.e. one or two interfaces only) this patch shouldn't
have significant impact on performance. However, on a setup with great
number of interfaces, things will probably slow down. This is not a problem
with design of this patch - things can be relatively easily sped up later.
See related comment in 'd80211: remove obsolete stuff' patch.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |  338 +++++++++++++++++-------------------------------
 1 files changed, 121 insertions(+), 217 deletions(-)

5aa4f5e0b7654f03d39977ac1212356d6b6f3fa7
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index fbca700..e2a42af 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2020,73 +2020,10 @@ static int header_parse_80211(struct sk_
 	return ETH_ALEN;
 }
 
-
-static struct net_device *
-ieee80211_get_wds_dev(struct ieee80211_local *local, u8 *addr)
+static inline int ieee80211_bssid_match(u8 *raddr, u8 *addr)
 {
-	struct list_head *ptr;
-
-	list_for_each(ptr, &local->sub_if_list)	{
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		if (sdata->type == IEEE80211_IF_TYPE_WDS &&
-		    memcmp(addr, sdata->u.wds.remote_addr, ETH_ALEN) == 0)
-			return sdata->dev;
-	}
-
-	return NULL;
-}
-
-
-static struct net_device * ieee80211_own_bssid(struct ieee80211_local *local,
-					       u8 *addr)
-{
-	struct net_device *dev = NULL;
-	struct ieee80211_sub_if_data *sdata;
-
-	spin_lock_bh(&local->sub_if_lock);
-	list_for_each_entry(sdata, &local->sub_if_list, list) {
-		if (sdata->type == IEEE80211_IF_TYPE_AP &&
-		    memcmp(addr, sdata->dev->dev_addr, ETH_ALEN) == 0) {
-			dev = sdata->dev;
-			break;
-		}
-	}
-	spin_unlock_bh(&local->sub_if_lock);
-
-	return dev;
-}
-
-
-static struct net_device * ieee80211_sta_bssid(struct ieee80211_local *local,
-					       u8 *addr, u8 *a1,
-					       int *sta_multicast)
-{
-	struct list_head *ptr;
-	int multicast;
-
-	multicast = a1[0] & 0x01;
-
-	/* Could not find station interface, resort to O(n) lookup. */
-	list_for_each(ptr, &local->sub_if_list) {
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		if (sdata->type != IEEE80211_IF_TYPE_STA &&
-		    sdata->type != IEEE80211_IF_TYPE_IBSS)
-			continue;
-		if (!multicast &&
-		    memcmp(a1, sdata->dev->dev_addr, ETH_ALEN) != 0)
-			continue;
-
-		if (memcmp(addr, sdata->u.sta.bssid, ETH_ALEN) == 0 ||
-		    (memcmp(addr, "\xff\xff\xff\xff\xff\xff", ETH_ALEN) == 0 &&
-		     sdata->type == IEEE80211_IF_TYPE_IBSS)) {
-			*sta_multicast = multicast;
-			return sdata->dev;
-		}
-	}
-
-	return NULL;
+	return memcmp(raddr, addr, ETH_ALEN) == 0 ||
+	       is_broadcast_ether_addr(raddr);
 }
 
 
@@ -2128,8 +2065,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
-		if (unlikely(sdata->type != IEEE80211_IF_TYPE_AP ||
-			     !ieee80211_own_bssid(local, hdr->addr1))) {
+		if (unlikely(sdata->type != IEEE80211_IF_TYPE_AP)) {
 			printk(KERN_DEBUG "%s: dropped ToDS frame (BSSID="
 			       MACSTR " SA=" MACSTR " DA=" MACSTR ")\n",
 			       dev->name, MAC2STR(hdr->addr1),
@@ -2142,8 +2078,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr4, ETH_ALEN);
 
-		dev = ieee80211_get_wds_dev(local, hdr->addr2);
-		if (!dev || memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN) != 0) {
+		if (unlikely(sdata->type != IEEE80211_IF_TYPE_WDS)) {
 			printk(KERN_DEBUG "%s: dropped FromDS&ToDS frame (RA="
 			       MACSTR " TA=" MACSTR " DA=" MACSTR " SA="
 			       MACSTR ")\n",
@@ -2158,9 +2093,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr1, ETH_ALEN);
 		memcpy(src, hdr->addr3, ETH_ALEN);
 
-		if (sdata->type != IEEE80211_IF_TYPE_STA ||
-		    memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN) == 0 ||
-		    memcmp(hdr->addr2, sdata->u.sta.bssid, ETH_ALEN) != 0) {
+		if (sdata->type != IEEE80211_IF_TYPE_STA) {
 			return TXRX_DROP;
 		}
 		break;
@@ -2169,8 +2102,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr1, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
-		if (sdata->type != IEEE80211_IF_TYPE_IBSS ||
-		    memcmp(hdr->addr3, sdata->u.sta.bssid, ETH_ALEN) != 0) {
+		if (sdata->type != IEEE80211_IF_TYPE_IBSS) {
 			if (net_ratelimit()) {
 				printk(KERN_DEBUG "%s: dropped IBSS frame (DA="
 				       MACSTR " SA=" MACSTR " BSSID=" MACSTR
@@ -2802,12 +2734,15 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		return TXRX_DROP;
 	}
 
-	/* Filter out foreign unicast packets when in promiscuous mode.
-	 * FIX: Filter out multicast to foreign BSSID. */
-	if (rx->sdata->type == IEEE80211_IF_TYPE_STA &&
-	    !MULTICAST_ADDR(hdr->addr1) &&
-	    memcmp(rx->dev->dev_addr, hdr->addr1, ETH_ALEN) != 0)
-		return TXRX_DROP;
+	if (memcmp(rx->dev->dev_addr, hdr->addr1, ETH_ALEN) == 0)
+		rx->skb->pkt_type = PACKET_HOST;
+	else if (is_multicast_ether_addr(hdr->addr1)) {
+		if (is_broadcast_ether_addr(hdr->addr1))
+			rx->skb->pkt_type = PACKET_BROADCAST;
+		else
+			rx->skb->pkt_type = PACKET_MULTICAST;
+	} else
+		rx->skb->pkt_type = PACKET_OTHERHOST;
 
 	/* Drop disallowed frame classes based on STA auth/assoc state;
 	 * IEEE 802.11, Chap 5.5.
@@ -2840,17 +2775,6 @@ ieee80211_rx_h_check(struct ieee80211_tx
 	if (rx->sta && rx->sta->key && always_sta_key) {
 		rx->key = rx->sta->key;
         } else {
-		if (!rx->sdata) {
-			printk(KERN_DEBUG "%s: sdata was null in packet!!\n",
-			       rx->dev->name);
-			printk(KERN_DEBUG "%s: Addr1: " MACSTR "\n",
-			       rx->dev->name, MAC2STR(hdr->addr1));
-			printk(KERN_DEBUG "%s: Addr2: " MACSTR "\n",
-			       rx->dev->name, MAC2STR(hdr->addr2));
-			printk(KERN_DEBUG "%s: Addr3: " MACSTR "\n",
-			       rx->dev->name, MAC2STR(hdr->addr3));
-			return TXRX_DROP;
-		}
 		if (rx->sta && rx->sta->key)
 			rx->key = rx->sta->key;
 		else
@@ -3158,41 +3082,6 @@ static u8 * ieee80211_get_bssid(struct i
 	return NULL;
 }
 
-
-static struct net_device * ieee80211_get_rx_dev(struct ieee80211_local *local,
-						struct ieee80211_hdr *hdr,
-						size_t len, int *sta_broadcast)
-{
-	u8 *bssid;
-	struct net_device *dev;
-	u16 fc;
-
-	bssid = ieee80211_get_bssid(hdr, len);
-	if (bssid) {
-		dev = ieee80211_own_bssid(local, bssid);
-		if (!dev)
-			dev = ieee80211_sta_bssid(local, bssid, hdr->addr1,
-						  sta_broadcast);
-		if (dev)
-			return dev;
-	}
-
-	if (len >= 30) {
-		fc = le16_to_cpu(hdr->frame_control);
-		if (WLAN_FC_GET_TYPE(fc) == WLAN_FC_TYPE_DATA &&
-		    (fc & (WLAN_FC_TODS | WLAN_FC_FROMDS)) ==
-		    (WLAN_FC_TODS | WLAN_FC_FROMDS)) {
-			dev = ieee80211_get_wds_dev(local, hdr->addr2);
-			if (dev)
-				return dev;
-		}
-	}
-
-	/* Default to default device if nothing else matches */
-	return local->wdev;
-}
-
-
 static void ieee80211_rx_michael_mic_report(struct net_device *dev,
 					    struct ieee80211_hdr *hdr,
 					    struct sta_info *sta,
@@ -3283,63 +3172,31 @@ static void ieee80211_rx_michael_mic_rep
 	rx->skb = NULL;
 }
 
-
-static void ieee80211_sta_rx_broadcast(struct ieee80211_txrx_data *rx)
+static inline void ieee80211_invoke_rx_handlers(struct ieee80211_local *local,
+						struct ieee80211_txrx_data *rx,
+						struct sta_info *sta)
 {
-	struct ieee80211_local *local = rx->dev->priv;
-	u8 *_bssid, bssid[ETH_ALEN];
-	struct sk_buff *orig_skb = rx->skb, *skb;
-	struct ieee80211_hdr *hdr;
 	ieee80211_rx_handler *handler;
-	ieee80211_txrx_result res;
-	struct list_head *ptr;
-
-	hdr = (struct ieee80211_hdr *) orig_skb->data;
-	_bssid = ieee80211_get_bssid(hdr, orig_skb->len);
-	if (_bssid == NULL) {
-		dev_kfree_skb(orig_skb);
-		return;
-	}
-	memcpy(bssid, _bssid, ETH_ALEN);
-
-	list_for_each(ptr, &local->sub_if_list) {
-		struct ieee80211_sub_if_data *sdata =
-			list_entry(ptr, struct ieee80211_sub_if_data, list);
-		if (sdata->type != IEEE80211_IF_TYPE_STA ||
-		    (memcmp(bssid, sdata->u.sta.bssid, ETH_ALEN) != 0 &&
-		     !(bssid[0] & 0x01)))
-			continue;
+        ieee80211_txrx_result res = TXRX_DROP;
 
-		skb = skb_copy(orig_skb, GFP_ATOMIC);
-		if (skb == NULL) {
-			if (net_ratelimit()) {
-				printk(KERN_DEBUG "%s: failed to copy "
-				       "multicast frame for %s",
-				       rx->dev->name, sdata->dev->name);
+	for (handler = local->rx_handlers; *handler != NULL; handler++) {
+		res = (*handler)(rx);
+		if (res != TXRX_CONTINUE) {
+			if (res == TXRX_DROP) {
+				I802_DEBUG_INC(local->rx_handlers_drop);
+				if (sta)
+					sta->rx_dropped++;
 			}
-			continue;
-		}
-
-		hdr = (struct ieee80211_hdr *) skb->data;
-		rx->skb = skb;
-		rx->dev = sdata->dev;
-		rx->sdata = IEEE80211_DEV_TO_SUB_IF(rx->dev);
-
-		res = TXRX_DROP;
-		for (handler = local->rx_handlers; *handler != NULL; handler++)
-		{
-			res = (*handler)(rx);
-			if (res == TXRX_DROP || res == TXRX_QUEUED)
-				break;
+			if (res == TXRX_QUEUED)
+				I802_DEBUG_INC(local->rx_handlers_queued);
+			break;
 		}
-
-		if (res == TXRX_DROP || *handler == NULL)
-			dev_kfree_skb(skb);
 	}
 
-	dev_kfree_skb(orig_skb);
-}
 
+	if (res == TXRX_DROP || *handler == NULL)
+		dev_kfree_skb(rx->skb);
+}
 
 /*
  * This is the receive path handler. It is called by a low level driver when an
@@ -3349,71 +3206,118 @@ void __ieee80211_rx(struct net_device *d
 		    struct ieee80211_rx_status *status)
 {
 	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata;
 	struct sta_info *sta;
 	struct ieee80211_hdr *hdr;
-	ieee80211_rx_handler *handler;
 	struct ieee80211_txrx_data rx;
-        ieee80211_txrx_result res = TXRX_DROP;
 	u16 type;
-	int sta_broadcast = 0;
+	int multicast;
 
 	hdr = (struct ieee80211_hdr *) skb->data;
 	memset(&rx, 0, sizeof(rx));
 	rx.skb = skb;
 	rx.local = local;
-	if (skb->len >= 16)
-		sta = rx.sta = sta_info_get(local, hdr->addr2);
-	else
-		sta = rx.sta = NULL;
-	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS)) {
-		rx.dev = sta->dev;
-		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
-	} else {
-		rx.dev = ieee80211_get_rx_dev(local, hdr, skb->len,
-					      &sta_broadcast);
-		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
-		if (sta == NULL &&
-		    rx.sdata->type == IEEE80211_IF_TYPE_IBSS) {
-			u8 *bssid = ieee80211_get_bssid(hdr, skb->len);
-			if (bssid)
-				sta = rx.sta =
-					ieee80211_ibss_add_sta(dev, skb, bssid,
-							       hdr->addr2);
-		}
-	}
 
 	rx.u.rx.status = status;
 	rx.fc = skb->len >= 2 ? le16_to_cpu(hdr->frame_control) : 0;
 	type = WLAN_FC_GET_TYPE(rx.fc);
 	if (type == WLAN_FC_TYPE_DATA || type == WLAN_FC_TYPE_MGMT)
 		local->dot11ReceivedFragmentCount++;
-	if (sta_broadcast) {
-		ieee80211_sta_rx_broadcast(&rx);
-		goto end;
-	}
+	multicast = is_multicast_ether_addr(hdr->addr1);
+
+	if (skb->len >= 16)
+		sta = rx.sta = sta_info_get(local, hdr->addr2);
+	else
+		sta = rx.sta = NULL;
 
         if ((status->flag & RX_FLAG_MMIC_ERROR)) {
 		ieee80211_rx_michael_mic_report(dev, hdr, sta, &rx);
 		goto end;
         }
 
-	for (handler = local->rx_handlers; *handler != NULL; handler++) {
-		res = (*handler)(&rx);
-		if (res != TXRX_CONTINUE) {
-			if (res == TXRX_DROP) {
-				I802_DEBUG_INC(local->rx_handlers_drop);
-				if (sta)
-					sta->rx_dropped++;
+	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS) &&
+	    !local->iff_promiscs && !multicast) {
+		rx.dev = sta->dev;
+		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
+		ieee80211_invoke_rx_handlers(local, &rx, sta);
+	} else {
+		struct ieee80211_sub_if_data *prev = NULL;
+		struct sk_buff *skb_new;
+		u8 *bssid = ieee80211_get_bssid(hdr, skb->len);
+
+		list_for_each_entry(sdata, &local->sub_if_list, list) {
+			switch (sdata->type) {
+			case IEEE80211_IF_TYPE_STA:
+				if (!bssid || memcmp(sdata->u.sta.bssid,
+						     bssid, ETH_ALEN) != 0)
+					continue;
+				if (!multicast && !sdata->promisc &&
+				    memcmp(sdata->dev->dev_addr, hdr->addr1,
+					   ETH_ALEN) != 0)
+					continue;
+				break;
+			case IEEE80211_IF_TYPE_IBSS:
+				if (!bssid ||
+				    !ieee80211_bssid_match(bssid,
+							   sdata->u.sta.bssid))
+					continue;
+				if (!multicast && !sdata->promisc &&
+				    memcmp(sdata->dev->dev_addr, hdr->addr1,
+					   ETH_ALEN) != 0)
+					continue;
+				if (sta == NULL) {
+					sta = rx.sta =
+						ieee80211_ibss_add_sta(dev, skb, bssid,
+								       hdr->addr2);
+						/* FIXME: call with sdata->dev */
+				}
+				break;
+			case IEEE80211_IF_TYPE_AP:
+				if (!bssid) {
+					if (memcmp(sdata->dev->dev_addr,
+						   hdr->addr1, ETH_ALEN) != 0)
+						continue;
+				} else if (!local->sta_scanning &&
+					   !local->scan.in_scan &&
+					   !ieee80211_bssid_match(bssid,
+							sdata->dev->dev_addr))
+					continue;
+				break;
+			case IEEE80211_IF_TYPE_WDS:
+				if (bssid ||
+				    WLAN_FC_GET_TYPE(rx.fc) != WLAN_FC_TYPE_DATA)
+					continue;
+				if (memcmp(sdata->u.wds.remote_addr,
+					   hdr->addr2, ETH_ALEN) != 0)
+					continue;
+				break;
 			}
-			if (res == TXRX_QUEUED)
-				I802_DEBUG_INC(local->rx_handlers_queued);
-			break;
+
+			if (prev) {
+				skb_new = skb_copy(skb, GFP_ATOMIC);
+				if (skb_new == NULL) {
+					if (net_ratelimit()) {
+						printk(KERN_DEBUG "%s: failed to copy "
+						       "multicast frame for %s",
+						       dev->name, prev->dev->name);
+					}
+					continue;
+				}
+				rx.skb = skb_new;
+				rx.dev = prev->dev;
+				rx.sdata = prev;
+				ieee80211_invoke_rx_handlers(local, &rx, sta);
+			}
+			prev = sdata;
 		}
+		if (prev) {
+			rx.skb = skb;
+			rx.dev = prev->dev;
+			rx.sdata = prev;
+			ieee80211_invoke_rx_handlers(local, &rx, sta);
+		} else
+			dev_kfree_skb(skb);
 	}
-	skb = rx.skb; /* handlers are allowed to change skb */
-
-	if (res == TXRX_DROP || *handler == NULL)
-		dev_kfree_skb(skb);
 
   end:
 	if (sta)
-- 
1.3.0

