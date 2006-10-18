From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 13/18] d80211: retain PS frames for at least STA listen interval
Date: Wed, 18 Oct 2006 17:49:36 +0200 (CEST)
Message-ID: <20061018154936.00E3647FB0@silver.suse.cz>
References: <20061018174838.116675768.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13474 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1161205AbWJRPtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 11:49:07 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061018174838.116675768.midnight@suse.cz>
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
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/hostapd_ioctl.h   |    1 +
 net/d80211/ieee80211_ioctl.c |    1 +
 net/d80211/sta_info.c        |   24 ++++++++++++++++--------
 net/d80211/sta_info.h        |    5 ++++-
 4 files changed, 22 insertions(+), 9 deletions(-)

a1db08ff39daef9a57d50d737bdbb91f8a5e0592
diff --git a/net/d80211/hostapd_ioctl.h b/net/d80211/hostapd_ioctl.h
index 73d54b7..003f371 100644
--- a/net/d80211/hostapd_ioctl.h
+++ b/net/d80211/hostapd_ioctl.h
@@ -189,6 +189,7 @@ struct prism2_hostapd_param {
 			u8 wds_flags;
 #define IEEE80211_STA_DYNAMIC_ENC BIT(0)
 			u8 enc_flags;
+			u16 listen_interval;
 		} add_sta;
 		struct {
 			u32 inactive_msec;
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 1fb2dfd..29fb230 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -300,6 +300,7 @@ static int ieee80211_ioctl_add_sta(struc
 	sta->aid = param->u.add_sta.aid;
 	if (sta->aid > IEEE80211_MAX_AID)
 		sta->aid = 0;
+	sta->listen_interval = param->u.add_sta.listen_interval;
 
 	rates = 0;
 	for (i = 0; i < sizeof(param->u.add_sta.supp_rates); i++) {
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index c18365b..17f4b92 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
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
 
diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index 44a532e..821645e 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -108,6 +108,8 @@ #ifdef CONFIG_D80211_DEBUG_COUNTERS
 #endif /* CONFIG_D80211_DEBUG_COUNTERS */
 
 	int vlan_id;
+
+	u16 listen_interval;
 };
 
 
@@ -121,7 +123,8 @@ #define STA_HASH(sta) (sta[5])
 /* Maximum number of frames to buffer per power saving station */
 #define STA_MAX_TX_BUFFER 128
 
-/* Buffered frame expiry time */
+/* Minimum buffered frame expiry time. If STA uses listen interval that is
+ * smaller than this value, the minimum value here is used instead. */
 #define STA_TX_BUFFER_EXPIRE (10 * HZ)
 
 /* How often station data is cleaned up (e.g., expiration of buffered frames)
-- 
1.3.0

