From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v3.6 14/19] hostap: slight optimization of addr compare
Date: Wed, 8 Jan 2014 10:54:10 +0800
Message-ID: <52CCBDD2.9060909@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jouni Malinen <j@w1.fi>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
instead of memcmp.

Cc: Jouni Malinen <j@w1.fi>
Cc: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Weilong Chen <chenweilong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/wireless/hostap/hostap_80211_tx.c |  4 ++--
 drivers/net/wireless/hostap/hostap_ap.c       | 28 +++++++++++++--------------
 drivers/net/wireless/hostap/hostap_hw.c       |  2 +-
 drivers/net/wireless/hostap/hostap_ioctl.c    |  4 ++--
 drivers/net/wireless/hostap/hostap_main.c     |  8 +++-----
 5 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index 344a981..8bde776 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -1,5 +1,6 @@
 #include <linux/slab.h>
 #include <linux/export.h>
+#include <linux/etherdevice.h>
 
 #include "hostap_80211.h"
 #include "hostap_common.h"
@@ -103,8 +104,7 @@ netdev_tx_t hostap_data_start_xmit(struct sk_buff *skb,
 			return NETDEV_TX_OK;
 		} else if (local->iw_mode == IW_MODE_INFRA &&
 			   (local->wds_type & HOSTAP_WDS_AP_CLIENT) &&
-			   memcmp(skb->data + ETH_ALEN, dev->dev_addr,
-				  ETH_ALEN) != 0) {
+			   !ether_addr_equal(skb->data + ETH_ALEN, dev->dev_addr)) {
 			/* AP client mode: send frames with foreign src addr
 			 * using 4-addr WDS frames */
 			use_wds = WDS_COMPLIANT_FRAME;
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index d6033a8..d36e252 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -24,6 +24,7 @@
 #include <linux/slab.h>
 #include <linux/export.h>
 #include <linux/moduleparam.h>
+#include <linux/etherdevice.h>
 
 #include "hostap_wlan.h"
 #include "hostap.h"
@@ -106,13 +107,12 @@ static void ap_sta_hash_del(struct ap_data *ap, struct sta_info *sta)
 
 	s = ap->sta_hash[STA_HASH(sta->addr)];
 	if (s == NULL) return;
-	if (memcmp(s->addr, sta->addr, ETH_ALEN) == 0) {
+	if (ether_addr_equal(s->addr, sta->addr)) {
 		ap->sta_hash[STA_HASH(sta->addr)] = s->hnext;
 		return;
 	}
 
-	while (s->hnext != NULL && memcmp(s->hnext->addr, sta->addr, ETH_ALEN)
-	       != 0)
+	while (s->hnext != NULL && !ether_addr_equal(s->hnext->addr, sta->addr))
 		s = s->hnext;
 	if (s->hnext != NULL)
 		s->hnext = s->hnext->hnext;
@@ -435,7 +435,7 @@ int ap_control_del_mac(struct mac_restrictions *mac_restrictions, u8 *mac)
 	     ptr != &mac_restrictions->mac_list; ptr = ptr->next) {
 		entry = list_entry(ptr, struct mac_entry, list);
 
-		if (memcmp(entry->addr, mac, ETH_ALEN) == 0) {
+		if (ether_addr_equal(entry->addr, mac)) {
 			list_del(ptr);
 			kfree(entry);
 			mac_restrictions->entries--;
@@ -459,7 +459,7 @@ static int ap_control_mac_deny(struct mac_restrictions *mac_restrictions,
 
 	spin_lock_bh(&mac_restrictions->lock);
 	list_for_each_entry(entry, &mac_restrictions->mac_list, list) {
-		if (memcmp(entry->addr, mac, ETH_ALEN) == 0) {
+		if (ether_addr_equal(entry->addr, mac)) {
 			found = 1;
 			break;
 		}
@@ -957,7 +957,7 @@ static struct sta_info* ap_get_sta(struct ap_data *ap, u8 *sta)
 	struct sta_info *s;
 
 	s = ap->sta_hash[STA_HASH(sta)];
-	while (s != NULL && memcmp(s->addr, sta, ETH_ALEN) != 0)
+	while (s != NULL && !ether_addr_equal(s->addr, sta))
 		s = s->hnext;
 	return s;
 }
@@ -1391,7 +1391,7 @@ static void handle_authen(local_info_t *local, struct sk_buff *skb,
 	status_code = __le16_to_cpu(*pos);
 	pos++;
 
-	if (memcmp(dev->dev_addr, hdr->addr2, ETH_ALEN) == 0 ||
+	if (ether_addr_equal(dev->dev_addr, hdr->addr2) ||
 	    ap_control_mac_deny(&ap->mac_restrictions, hdr->addr2)) {
 		txt = "authentication denied";
 		resp = WLAN_STATUS_UNSPECIFIED_FAILURE;
@@ -1935,7 +1935,7 @@ static void handle_pspoll(local_info_t *local,
 	PDEBUG(DEBUG_PS2, "handle_pspoll: BSSID=%pM, TA=%pM PWRMGT=%d\n",
 	       hdr->addr1, hdr->addr2, !!ieee80211_has_pm(hdr->frame_control));
 
-	if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN)) {
+	if (!ether_addr_equal(hdr->addr1, dev->dev_addr)) {
 		PDEBUG(DEBUG_AP,
 		       "handle_pspoll - addr1(BSSID)=%pM not own MAC\n",
 		       hdr->addr1);
@@ -2230,7 +2230,7 @@ static void handle_ap_item(local_info_t *local, struct sk_buff *skb,
 			goto done;
 		}
 
-		if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN)) {
+		if (!ether_addr_equal(hdr->addr1, dev->dev_addr)) {
 			PDEBUG(DEBUG_AP, "handle_ap_item - addr1(BSSID)=%pM"
 			       " not own MAC\n", hdr->addr1);
 			goto done;
@@ -2267,13 +2267,13 @@ static void handle_ap_item(local_info_t *local, struct sk_buff *skb,
 		goto done;
 	}
 
-	if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN)) {
+	if (!ether_addr_equal(hdr->addr1, dev->dev_addr)) {
 		PDEBUG(DEBUG_AP, "handle_ap_item - addr1(DA)=%pM"
 		       " not own MAC\n", hdr->addr1);
 		goto done;
 	}
 
-	if (memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN)) {
+	if (!ether_addr_equal(hdr->addr3, dev->dev_addr)) {
 		PDEBUG(DEBUG_AP, "handle_ap_item - addr3(BSSID)=%pM"
 		       " not own MAC\n", hdr->addr3);
 		goto done;
@@ -3035,7 +3035,7 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 		if (!wds) {
 			/* FromDS frame - not for us; probably
 			 * broadcast/multicast in another BSS - drop */
-			if (memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN) == 0) {
+			if (ether_addr_equal(hdr->addr1, dev->dev_addr)) {
 				printk(KERN_DEBUG "Odd.. FromDS packet "
 				       "received with own BSSID\n");
 				hostap_dump_rx_80211(dev->name, skb, rx_stats);
@@ -3044,7 +3044,7 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 			goto out;
 		}
 	} else if (stype == IEEE80211_STYPE_NULLFUNC && sta == NULL &&
-		   memcmp(hdr->addr1, dev->dev_addr, ETH_ALEN) == 0) {
+		   ether_addr_equal(hdr->addr1, dev->dev_addr)) {
 
 		if (local->hostapd) {
 			prism2_rx_80211(local->apdev, skb, rx_stats,
@@ -3073,7 +3073,7 @@ ap_rx_ret hostap_handle_sta_rx(local_info_t *local, struct net_device *dev,
 		/* If BSSID (Addr3) is foreign, this frame is a normal
 		 * broadcast frame from an IBSS network. Drop it silently.
 		 * If BSSID is own, report the dropping of this frame. */
-		if (memcmp(hdr->addr3, dev->dev_addr, ETH_ALEN) == 0) {
+		if (ether_addr_equal(hdr->addr3, dev->dev_addr)) {
 			printk(KERN_DEBUG "%s: dropped received packet from %pM"
 			       " with no ToDS flag "
 			       "(type=0x%02x, subtype=0x%02x)\n", dev->name,
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index c275dc1..6df3ee5 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -2175,7 +2175,7 @@ static void hostap_tx_callback(local_info_t *local,
 	struct hostap_tx_callback_info *cb;
 
 	/* Make sure that frame was from us. */
-	if (memcmp(txdesc->addr2, local->dev->dev_addr, ETH_ALEN)) {
+	if (!ether_addr_equal(txdesc->addr2, local->dev->dev_addr)) {
 		printk(KERN_DEBUG "%s: TX callback - foreign frame\n",
 		       local->dev->name);
 		return;
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index e509030..2454a74 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -655,7 +655,7 @@ static int hostap_join_ap(struct net_device *dev)
 		if (!local->last_scan_results)
 			break;
 		entry = &local->last_scan_results[i];
-		if (memcmp(local->preferred_ap, entry->bssid, ETH_ALEN) == 0) {
+		if (ether_addr_equal(local->preferred_ap, entry->bssid)) {
 			req.channel = entry->chid;
 			break;
 		}
@@ -1978,7 +1978,7 @@ static inline int prism2_translate_scan(local_info_t *local,
 		list_for_each(ptr, &local->bss_list) {
 			struct hostap_bss_info *bss;
 			bss = list_entry(ptr, struct hostap_bss_info, list);
-			if (memcmp(bss->bssid, scan->bssid, ETH_ALEN) == 0) {
+			if (ether_addr_equal(bss->bssid, scan->bssid)) {
 				bss->included = 1;
 				current_ev = __prism2_translate_scan(
 					local, info, scan, bss, current_ev,
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index a1257c9..67db34e 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -155,8 +155,7 @@ int prism2_wds_add(local_info_t *local, u8 *remote_addr,
 
 		if (prism2_wds_special_addr(iface->u.wds.remote_addr))
 			empty = iface;
-		else if (memcmp(iface->u.wds.remote_addr, remote_addr,
-				ETH_ALEN) == 0) {
+		else if (ether_addr_equal(iface->u.wds.remote_addr, remote_addr)) {
 			match = iface;
 			break;
 		}
@@ -214,8 +213,7 @@ int prism2_wds_del(local_info_t *local, u8 *remote_addr,
 		if (iface->type != HOSTAP_INTERFACE_WDS)
 			continue;
 
-		if (memcmp(iface->u.wds.remote_addr, remote_addr,
-			   ETH_ALEN) == 0) {
+		if (ether_addr_equal(iface->u.wds.remote_addr, remote_addr)) {
 			selected = iface;
 			break;
 		}
@@ -1085,7 +1083,7 @@ int prism2_sta_deauth(local_info_t *local, u16 reason)
 
 	if (local->iw_mode != IW_MODE_INFRA ||
 	    is_zero_ether_addr(local->bssid) ||
-	    memcmp(local->bssid, "\x44\x44\x44\x44\x44\x44", ETH_ALEN) == 0)
+	    ether_addr_equal(local->bssid, "\x44\x44\x44\x44\x44\x44"))
 		return 0;
 
 	ret = prism2_sta_send_mgmt(local, local->bssid, IEEE80211_STYPE_DEAUTH,
-- 
1.8.0


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
