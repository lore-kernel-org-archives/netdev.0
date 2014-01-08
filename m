From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3.6 16/19] ipw2x00: slight optimization of addr compare
Date: Wed, 8 Jan 2014 10:54:17 +0800
Message-ID: <52CCBDD9.7050308@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
instead of memcmp.

Cc: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Weilong Chen <chenweilong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/wireless/ipw2x00/ipw2200.c   | 34 ++++++++++++++++----------------
 drivers/net/wireless/ipw2x00/libipw_rx.c | 10 +++++-----
 2 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 9244b36..1393260 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -3012,7 +3012,7 @@ static void ipw_remove_current_network(struct ipw_priv *priv)
 	spin_lock_irqsave(&priv->ieee->lock, flags);
 	list_for_each_safe(element, safe, &priv->ieee->network_list) {
 		network = list_entry(element, struct libipw_network, list);
-		if (!memcmp(network->bssid, priv->bssid, ETH_ALEN)) {
+		if (ether_addr_equal(network->bssid, priv->bssid)) {
 			list_del(element);
 			list_add_tail(&network->list,
 				      &priv->ieee->network_free_list);
@@ -3921,7 +3921,7 @@ static u8 ipw_add_station(struct ipw_priv *priv, u8 * bssid)
 	int i;
 
 	for (i = 0; i < priv->num_stations; i++) {
-		if (!memcmp(priv->stations[i], bssid, ETH_ALEN)) {
+		if (ether_addr_equal(priv->stations[i], bssid)) {
 			/* Another node is active in network */
 			priv->missed_adhoc_beacons = 0;
 			if (!(priv->config & CFG_STATIC_CHANNEL))
@@ -3953,7 +3953,7 @@ static u8 ipw_find_station(struct ipw_priv *priv, u8 * bssid)
 	int i;
 
 	for (i = 0; i < priv->num_stations; i++)
-		if (!memcmp(priv->stations[i], bssid, ETH_ALEN))
+		if (ether_addr_equal(priv->stations[i], bssid))
 			return i;
 
 	return IPW_INVALID_STATION;
@@ -5622,7 +5622,7 @@ static int ipw_find_adhoc_network(struct ipw_priv *priv,
 		return 0;
 	}
 
-	if (!memcmp(network->bssid, priv->bssid, ETH_ALEN)) {
+	if (ether_addr_equal(network->bssid, priv->bssid)) {
 		IPW_DEBUG_MERGE("Network '%s (%pM)' excluded "
 				"because of the same BSSID match: %pM"
 				".\n", print_ssid(ssid, network->ssid,
@@ -5849,7 +5849,7 @@ static int ipw_best_network(struct ipw_priv *priv,
 	}
 
 	if ((priv->config & CFG_STATIC_BSSID) &&
-	    memcmp(network->bssid, priv->bssid, ETH_ALEN)) {
+	    !ether_addr_equal(network->bssid, priv->bssid)) {
 		IPW_DEBUG_ASSOC("Network '%s (%pM)' excluded "
 				"because of BSSID mismatch: %pM.\n",
 				print_ssid(ssid, network->ssid,
@@ -6988,7 +6988,7 @@ static int ipw_qos_handle_probe_response(struct ipw_priv *priv,
 	}
 	if ((priv->status & STATUS_ASSOCIATED) &&
 	    (priv->ieee->iw_mode == IW_MODE_ADHOC) && (active_network == 0)) {
-		if (memcmp(network->bssid, priv->bssid, ETH_ALEN))
+		if (!ether_addr_equal(network->bssid, priv->bssid))
 			if (network->capability & WLAN_CAPABILITY_IBSS)
 				if ((network->ssid_len ==
 				     priv->assoc_network->ssid_len) &&
@@ -8210,29 +8210,29 @@ static int is_network_packet(struct ipw_priv *priv,
 	switch (priv->ieee->iw_mode) {
 	case IW_MODE_ADHOC:	/* Header: Dest. | Source    | BSSID */
 		/* packets from our adapter are dropped (echo) */
-		if (!memcmp(header->addr2, priv->net_dev->dev_addr, ETH_ALEN))
+		if (ether_addr_equal(header->addr2, priv->net_dev->dev_addr))
 			return 0;
 
 		/* {broad,multi}cast packets to our BSSID go through */
 		if (is_multicast_ether_addr(header->addr1))
-			return !memcmp(header->addr3, priv->bssid, ETH_ALEN);
+			return ether_addr_equal(header->addr3, priv->bssid);
 
 		/* packets to our adapter go through */
-		return !memcmp(header->addr1, priv->net_dev->dev_addr,
-			       ETH_ALEN);
+		return ether_addr_equal(header->addr1,
+					priv->net_dev->dev_addr);
 
 	case IW_MODE_INFRA:	/* Header: Dest. | BSSID | Source */
 		/* packets from our adapter are dropped (echo) */
-		if (!memcmp(header->addr3, priv->net_dev->dev_addr, ETH_ALEN))
+		if (ether_addr_equal(header->addr3, priv->net_dev->dev_addr))
 			return 0;
 
 		/* {broad,multi}cast packets to our BSS go through */
 		if (is_multicast_ether_addr(header->addr1))
-			return !memcmp(header->addr2, priv->bssid, ETH_ALEN);
+			return ether_addr_equal(header->addr2, priv->bssid);
 
 		/* packets to our adapter go through */
-		return !memcmp(header->addr1, priv->net_dev->dev_addr,
-			       ETH_ALEN);
+		return ether_addr_equal(header->addr1,
+					priv->net_dev->dev_addr);
 	}
 
 	return 1;
@@ -8260,7 +8260,7 @@ static  int is_duplicate_packet(struct ipw_priv *priv,
 			list_for_each(p, &priv->ibss_mac_hash[index]) {
 				entry =
 				    list_entry(p, struct ipw_ibss_seq, list);
-				if (!memcmp(entry->mac, mac, ETH_ALEN))
+				if (ether_addr_equal(entry->mac, mac))
 					break;
 			}
 			if (p == &priv->ibss_mac_hash[index]) {
@@ -8329,7 +8329,7 @@ static void ipw_handle_mgmt_packet(struct ipw_priv *priv,
 	      IEEE80211_STYPE_PROBE_RESP) ||
 	     (WLAN_FC_GET_STYPE(le16_to_cpu(header->frame_ctl)) ==
 	      IEEE80211_STYPE_BEACON))) {
-		if (!memcmp(header->addr3, priv->bssid, ETH_ALEN))
+		if (ether_addr_equal(header->addr3, priv->bssid))
 			ipw_add_station(priv, header->addr2);
 	}
 
@@ -9045,7 +9045,7 @@ static int ipw_wx_set_wap(struct net_device *dev,
 	}
 
 	priv->config |= CFG_STATIC_BSSID;
-	if (!memcmp(priv->bssid, wrqu->ap_addr.sa_data, ETH_ALEN)) {
+	if (ether_addr_equal(priv->bssid, wrqu->ap_addr.sa_data)) {
 		IPW_DEBUG_WX("BSSID set to current BSSID.\n");
 		mutex_unlock(&priv->mutex);
 		return 0;
diff --git a/drivers/net/wireless/ipw2x00/libipw_rx.c b/drivers/net/wireless/ipw2x00/libipw_rx.c
index 9ffe659..5c62538 100644
--- a/drivers/net/wireless/ipw2x00/libipw_rx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_rx.c
@@ -874,13 +874,13 @@ void libipw_rx_any(struct libipw_device *ieee,
 	switch (ieee->iw_mode) {
 	case IW_MODE_ADHOC:
 		/* our BSS and not from/to DS */
-		if (memcmp(hdr->addr3, ieee->bssid, ETH_ALEN) == 0)
+		if (ether_addr_equal(hdr->addr3, ieee->bssid))
 		if ((fc & (IEEE80211_FCTL_TODS+IEEE80211_FCTL_FROMDS)) == 0) {
 			/* promisc: get all */
 			if (ieee->dev->flags & IFF_PROMISC)
 				is_packet_for_us = 1;
 			/* to us */
-			else if (memcmp(hdr->addr1, ieee->dev->dev_addr, ETH_ALEN) == 0)
+			else if (ether_addr_equal(hdr->addr1, ieee->dev->dev_addr))
 				is_packet_for_us = 1;
 			/* mcast */
 			else if (is_multicast_ether_addr(hdr->addr1))
@@ -889,18 +889,18 @@ void libipw_rx_any(struct libipw_device *ieee,
 		break;
 	case IW_MODE_INFRA:
 		/* our BSS (== from our AP) and from DS */
-		if (memcmp(hdr->addr2, ieee->bssid, ETH_ALEN) == 0)
+		if (ether_addr_equal(hdr->addr2, ieee->bssid))
 		if ((fc & (IEEE80211_FCTL_TODS+IEEE80211_FCTL_FROMDS)) == IEEE80211_FCTL_FROMDS) {
 			/* promisc: get all */
 			if (ieee->dev->flags & IFF_PROMISC)
 				is_packet_for_us = 1;
 			/* to us */
-			else if (memcmp(hdr->addr1, ieee->dev->dev_addr, ETH_ALEN) == 0)
+			else if (ether_addr_equal(hdr->addr1, ieee->dev->dev_addr))
 				is_packet_for_us = 1;
 			/* mcast */
 			else if (is_multicast_ether_addr(hdr->addr1)) {
 				/* not our own packet bcasted from AP */
-				if (memcmp(hdr->addr3, ieee->dev->dev_addr, ETH_ALEN))
+				if (!ether_addr_equal(hdr->addr3, ieee->dev->dev_addr))
 					is_packet_for_us = 1;
 			}
 		}
-- 
1.8.0


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
