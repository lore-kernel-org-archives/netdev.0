From: Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Sun, 10 Nov 2013 15:45:45 -0600
Message-ID: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We don't want to be waiting forever for a beacon that will never come,
just continue the association.

Signed-off-by: Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

The previous version depended on some cleanup patches, plus had some unclear
rerun logic.

 net/mac80211/ieee80211_i.h |  1 +
 net/mac80211/mlme.c        | 32 ++++++++++++++++++++++++++------
 2 files changed, 27 insertions(+), 6 deletions(-)

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
index 86e4ad5..68f76f7 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -38,6 +38,7 @@
 #define IEEE80211_ASSOC_TIMEOUT		(HZ / 5)
 #define IEEE80211_ASSOC_TIMEOUT_LONG	(HZ / 2)
 #define IEEE80211_ASSOC_TIMEOUT_SHORT	(HZ / 10)
+#define IEEE80211_ASSOC_BEACON_TIMEOUT	2 * HZ
 #define IEEE80211_ASSOC_MAX_TRIES	3
 
 static int max_nullfunc_tries = 2;
@@ -3475,6 +3476,24 @@ void ieee80211_mgd_conn_tx_status(struct ieee80211_sub_if_data *sdata,
 	ieee80211_queue_work(&local->hw, &sdata->work);
 }
 
+static int check_beacon(struct ieee80211_sub_if_data *sdata)
+{
+	struct ieee80211_if_managed *ifmgd = &sdata->u.mgd;
+	struct ieee80211_mgd_assoc_data *assoc_data = ifmgd->assoc_data;
+
+	if (!assoc_data->need_beacon || ifmgd->have_beacon)
+		return true;
+
+	if (time_after(jiffies, assoc_data->beacon_timeout)) {
+		sdata_info(sdata, "no beacon from %pM\n", assoc_data->bss->bssid);
+		return true;
+	}
+
+	assoc_data->timeout = TU_TO_EXP_TIME(assoc_data->bss->beacon_interval);
+	run_again(sdata, assoc_data->timeout);
+	return false;
+}
+
 void ieee80211_sta_work(struct ieee80211_sub_if_data *sdata)
 {
 	struct ieee80211_local *local = sdata->local;
@@ -3533,12 +3552,12 @@ void ieee80211_sta_work(struct ieee80211_sub_if_data *sdata)
 
 	if (ifmgd->assoc_data && ifmgd->assoc_data->timeout_started &&
 	    time_after(jiffies, ifmgd->assoc_data->timeout)) {
-		if ((ifmgd->assoc_data->need_beacon && !ifmgd->have_beacon) ||
-		    ieee80211_do_assoc(sdata)) {
-			struct cfg80211_bss *bss = ifmgd->assoc_data->bss;
