From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 4/5] d80211: retain PS frames for at least STA listen interval
Date: Tue, 3 Oct 2006 11:12:28 -0700
Message-ID: <20061003181228.GD19403@devicescape.com>
References: <20061003181118.537800000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-58.dex002.intermedia.net ([64.78.21.227]:15796 "EHLO
	dhost002-58.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751003AbWJCSMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:12:32 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="listen-interval.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jouni Malinen <jkm@devicescape.com>

Start using 2 * listen_int * beacon_int as a timeout for PS buffered
unicast frames if that is longer than 10 seconds. Previously, we used
fixed 10 second limit regardless of the listen interval.

This fixes power saving for STAs that request very long listen
interval (over 10 seconds).

This was reported by UNH IOL 802.11 AP Base MAC Test Suite v2.4
Test #1.3.2 Part e.

While we are at it, remove the station from the TIM when the PS buffer is
empty.

Signed-off-by: Jouni Malinen <jkm@devicescape.com>

Index: wireless-dev/net/d80211/hostapd_ioctl.h
===================================================================
--- wireless-dev.orig/net/d80211/hostapd_ioctl.h
+++ wireless-dev/net/d80211/hostapd_ioctl.h
@@ -189,6 +189,7 @@ struct prism2_hostapd_param {
 			u8 wds_flags;
 #define IEEE80211_STA_DYNAMIC_ENC BIT(0)
 			u8 enc_flags;
+			u16 listen_interval;
 		} add_sta;
 		struct {
 			u32 inactive_msec;
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -296,6 +296,7 @@ static int ieee80211_ioctl_add_sta(struc
 	sta->aid = param->u.add_sta.aid;
 	if (sta->aid > IEEE80211_MAX_AID)
 		sta->aid = 0;
+	sta->listen_interval = param->u.add_sta.listen_interval;
 
 	rates = 0;
 	for (i = 0; i < sizeof(param->u.add_sta.supp_rates); i++) {
Index: wireless-dev/net/d80211/sta_info.c
===================================================================
--- wireless-dev.orig/net/d80211/sta_info.c
+++ wireless-dev/net/d80211/sta_info.c
@@ -269,18 +269,24 @@ void sta_info_free(struct sta_info *sta,
 }
 
 
-static inline int sta_info_buffer_expired(struct sk_buff *skb)
+static inline int sta_info_buffer_expired(struct ieee80211_local *local,
+					  struct sta_info *sta,
+					  struct sk_buff *skb)
 {
         struct ieee80211_tx_packet_data *pkt_data;
+	int timeout;
+
 	if (!skb)
 		return 0;
 
-	/* TODO: this could be improved by passing STA listen interval into
-	 * the kernel driver and expiring frames after 2 x listen_interval x
-         * beacon interval */
-
         pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
-	return time_after(jiffies, pkt_data->jiffies + STA_TX_BUFFER_EXPIRE);
+
+	/* Timeout: (2 * listen_interval * beacon_int * 1024 / 1000000) sec */
+	timeout = (sta->listen_interval * local->conf.beacon_int * 32 /
+		   15625) * HZ;
+	if (timeout < STA_TX_BUFFER_EXPIRE)
+		timeout = STA_TX_BUFFER_EXPIRE;
+	return time_after(jiffies, pkt_data->jiffies + timeout);
 }
 
 
@@ -296,9 +302,11 @@ static void sta_info_cleanup_expire_buff
 	for (;;) {
 		spin_lock_irqsave(&sta->ps_tx_buf.lock, flags);
 		skb = skb_peek(&sta->ps_tx_buf);
-		if (sta_info_buffer_expired(skb))
+		if (sta_info_buffer_expired(local, sta, skb)) {
 			skb = __skb_dequeue(&sta->ps_tx_buf);
-		else
+			if (skb_queue_empty(&sta->ps_tx_buf))
+				sta->flags &= ~WLAN_STA_TIM;
+		} else
 			skb = NULL;
 		spin_unlock_irqrestore(&sta->ps_tx_buf.lock, flags);
 
Index: wireless-dev/net/d80211/sta_info.h
===================================================================
--- wireless-dev.orig/net/d80211/sta_info.h
+++ wireless-dev/net/d80211/sta_info.h
@@ -107,6 +107,8 @@ struct sta_info {
 #endif /* CONFIG_D80211_DEBUG_COUNTERS */
 
 	int vlan_id;
+
+	u16 listen_interval;
 };
 
 
@@ -120,7 +122,8 @@ struct sta_info {
 /* Maximum number of frames to buffer per power saving station */
 #define STA_MAX_TX_BUFFER 128
 
-/* Buffered frame expiry time */
+/* Minimum buffered frame expiry time. If STA uses listen interval that is
+ * smaller than this value, the minimum value here is used instead. */
 #define STA_TX_BUFFER_EXPIRE (10 * HZ)
 
 /* How often station data is cleaned up (e.g., expiration of buffered frames)

--
