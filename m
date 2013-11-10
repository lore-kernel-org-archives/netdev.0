From: Felipe Contreras <felipe.contreras@gmail.com>
Subject: [PATCH] mac80211: add assoc beacon timeout logic
Date: Sun, 10 Nov 2013 14:26:45 -0600
Message-ID: <1384115205-3820-1-git-send-email-felipe.contreras@gmail.com>
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:45751 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab3KJUdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Nov 2013 15:33:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't want to be waiting forever for a beacon that will never come,
just continue the association.

Signed-off-by: Felipe Contreras <felipe.contreras@gmail.com>
---
 net/mac80211/ieee80211_i.h |  1 +
 net/mac80211/mlme.c        | 18 ++++++++++++++----
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 611abfc..e1f858d 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -358,6 +358,7 @@ struct ieee80211_mgd_assoc_data {
 	const u8 *supp_rates;
 
 	unsigned long timeout;
+	unsigned long beacon_timeout;
 	int tries;
 
 	u16 capability;
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 529cef6..1c14484 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -38,6 +38,7 @@
 #define IEEE80211_ASSOC_TIMEOUT		(HZ / 5)
 #define IEEE80211_ASSOC_TIMEOUT_LONG	(HZ / 2)
 #define IEEE80211_ASSOC_TIMEOUT_SHORT	(HZ / 10)
+#define IEEE80211_ASSOC_BEACON_TIMEOUT	2 * HZ
 #define IEEE80211_ASSOC_MAX_TRIES	3
 
 static int max_nullfunc_tries = 2;
@@ -3537,10 +3538,18 @@ void ieee80211_sta_work(struct ieee80211_sub_if_data *sdata)
 
 	if (assoc_data && assoc_data->timeout_started) {
 		if (time_after(jiffies, assoc_data->timeout)) {
-			if ((assoc_data->need_beacon && !ifmgd->have_beacon) ||
-			    ieee80211_do_assoc(sdata)) {
-				struct cfg80211_bss *bss = assoc_data->bss;
-
+			struct cfg80211_bss *bss = assoc_data->bss;
+
+			if (assoc_data->need_beacon && !ifmgd->have_beacon) {
+				if (time_after(jiffies, assoc_data->beacon_timeout)) {
+					sdata_info(sdata, "no beacon from %pM\n", bss->bssid);
+					assoc_data->need_beacon = false;
+					assoc_data->timeout = jiffies;
+				} else {
+					assoc_data->timeout = TU_TO_EXP_TIME(bss->beacon_interval);
+				}
+				run_again(sdata, assoc_data->timeout);
+			} else if (ieee80211_do_assoc(sdata)) {
 				ieee80211_destroy_assoc_data(sdata, false);
 				cfg80211_assoc_timeout(sdata->dev, bss);
 			}
@@ -4341,6 +4350,7 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data *sdata,
 		sdata_info(sdata, "waiting for beacon from %pM\n",
 			   ifmgd->bssid);
 		assoc_data->timeout = TU_TO_EXP_TIME(req->bss->beacon_interval);
+		assoc_data->beacon_timeout = jiffies + IEEE80211_ASSOC_BEACON_TIMEOUT;
 		assoc_data->timeout_started = true;
 		assoc_data->need_beacon = true;
 	} else if (beacon_ies) {
-- 
1.8.4.2+fc1
