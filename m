From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 11/12 NEXT] rtlwifi:  Add missing code to PWDB statics routine
Date: Mon, 18 Nov 2013 11:11:35 -0600
Message-ID: <1384794696-20314-12-git-send-email-Larry.Finger@lwfinger.net>
References: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384794696-20314-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/stats.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/wireless/rtlwifi/stats.c b/drivers/net/wireless/rtlwifi/stats.c
index 8ed3174..4f083fc 100644
--- a/drivers/net/wireless/rtlwifi/stats.c
+++ b/drivers/net/wireless/rtlwifi/stats.c
@@ -176,6 +176,7 @@ static void rtl_process_pwdb(struct ieee80211_hw *hw, struct rtl_stats *pstatus)
 	struct rtl_sta_info *drv_priv = NULL;
 	struct ieee80211_sta *sta = NULL;
 	long undec_sm_pwdb;
+	long undec_sm_cck;
 
 	rcu_read_lock();
 	if (rtlpriv->mac80211.opmode != NL80211_IFTYPE_STATION)
@@ -185,12 +186,16 @@ static void rtl_process_pwdb(struct ieee80211_hw *hw, struct rtl_stats *pstatus)
 	if (sta) {
 		drv_priv = (struct rtl_sta_info *) sta->drv_priv;
 		undec_sm_pwdb = drv_priv->rssi_stat.undec_sm_pwdb;
+		undec_sm_cck = drv_priv->rssi_stat.undec_sm_cck;
 	} else {
 		undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
+		undec_sm_cck = rtlpriv->dm.undec_sm_cck;
 	}
 
 	if (undec_sm_pwdb < 0)
 		undec_sm_pwdb = pstatus->rx_pwdb_all;
+	if (undec_sm_cck < 0)
+		undec_sm_cck = pstatus->rx_pwdb_all;
 	if (pstatus->rx_pwdb_all > (u32) undec_sm_pwdb) {
 		undec_sm_pwdb = (((undec_sm_pwdb) *
 		      (RX_SMOOTH_FACTOR - 1)) +
@@ -200,6 +205,15 @@ static void rtl_process_pwdb(struct ieee80211_hw *hw, struct rtl_stats *pstatus)
 		undec_sm_pwdb = (((undec_sm_pwdb) * (RX_SMOOTH_FACTOR - 1)) +
 		     (pstatus->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
 	}
+	if (pstatus->rx_pwdb_all > (u32) undec_sm_cck) {
+		undec_sm_cck = (((undec_sm_pwdb) *
+		      (RX_SMOOTH_FACTOR - 1)) +
+		     (pstatus->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
+		undec_sm_cck = undec_sm_cck + 1;
+	} else {
+		undec_sm_pwdb = (((undec_sm_cck) * (RX_SMOOTH_FACTOR - 1)) +
+		     (pstatus->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
+	}
 
 	if (sta) {
 		drv_priv->rssi_stat.undec_sm_pwdb = undec_sm_pwdb;
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
