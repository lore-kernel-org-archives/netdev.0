From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 6/17] d80211: remove local->bssid variable
Date: Fri, 21 Apr 2006 22:11:37 +0200 (CEST)
Message-ID: <20060421201137.55AC4482C7@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:11655 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932407AbWDUULJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:09 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BSSID shouldn't be common for all interfaces.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c     |    4 ++--
 net/d80211/ieee80211_i.h   |    1 -
 net/d80211/ieee80211_sta.c |    8 ++------
 3 files changed, 4 insertions(+), 9 deletions(-)

78d82ec5d0282693656a09add989460775d56bbd
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 10c4792..362c231 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2063,7 +2063,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
 		if (sdata->type != IEEE80211_SUB_IF_TYPE_IBSS ||
-		    memcmp(hdr->addr3, local->bssid, ETH_ALEN) != 0) {
+		    memcmp(hdr->addr3, sdata->u.sta.bssid, ETH_ALEN) != 0) {
 			if (net_ratelimit()) {
 				printk(KERN_DEBUG "%s: dropped IBSS frame (DA="
 				       MACSTR " SA=" MACSTR " BSSID=" MACSTR
@@ -2803,7 +2803,7 @@ ieee80211_rx_h_sta_process(struct ieee80
 	 * other STAs are using different BSSID. */
 	if (rx->sdata->type == IEEE80211_SUB_IF_TYPE_IBSS) {
 		u8 *bssid = ieee80211_get_bssid(hdr, rx->skb->len);
-		if (memcmp(bssid, rx->local->bssid, ETH_ALEN) == 0)
+		if (memcmp(bssid, rx->sdata->u.sta.bssid, ETH_ALEN) == 0)
 			sta->last_rx = jiffies;
 	} else
 	if (!MULTICAST_ADDR(hdr->addr1) ||
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 848afb7..8fe1dd1 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -433,7 +433,6 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
         u32 stat_time;
         struct timer_list stat_timer;
 
-	u8 bssid[ETH_ALEN]; /* BSSID for STA modes (Adhoc/Managed) */
         struct timer_list rate_limit_timer;
         u32 rate_limit;
         u32 rate_limit_burst;
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 9972b98..5df6734 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1365,7 +1365,7 @@ #endif
 		((u64) pos[1] << 8) | ((u64) pos[0]);
 
 	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS && beacon &&
-	    memcmp(mgmt->bssid, local->bssid, ETH_ALEN) == 0) {
+	    memcmp(mgmt->bssid, sdata->u.sta.bssid, ETH_ALEN) == 0) {
 #ifdef IEEE80211_IBSS_DEBUG
 		static unsigned long last_tsf_debug = 0;
 		u64 tsf;
@@ -1389,7 +1389,7 @@ #endif /* IEEE80211_IBSS_DEBUG */
 		invalid = 1;
 
 	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS && elems.supp_rates &&
-	    memcmp(mgmt->bssid, local->bssid, ETH_ALEN) == 0 &&
+	    memcmp(mgmt->bssid, sdata->u.sta.bssid, ETH_ALEN) == 0 &&
 	    (sta = sta_info_get(local, mgmt->sa))) {
 		struct ieee80211_rate *rates;
 		size_t num_rates;
@@ -1990,7 +1990,6 @@ static int ieee80211_sta_join_ibss(struc
 		local->hw->reset_tsf(local->mdev);
 	}
 	memcpy(ifsta->bssid, bss->bssid, ETH_ALEN);
-	memcpy(local->bssid, bss->bssid, ETH_ALEN);
 	memcpy(local->conf.client_bssid, bss->bssid, ETH_ALEN);
 
 	local->conf.beacon_int = bss->beacon_int >= 10 ? bss->beacon_int : 10;
@@ -2344,7 +2343,6 @@ int ieee80211_sta_get_ssid(struct net_de
 
 int ieee80211_sta_set_bssid(struct net_device *dev, u8 *bssid)
 {
-	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_if_sta *ifsta;
 
@@ -2352,8 +2350,6 @@ int ieee80211_sta_set_bssid(struct net_d
 	ifsta = &sdata->u.sta;
 
 	memcpy(ifsta->bssid, bssid, ETH_ALEN);
-	if (sdata->type == IEEE80211_SUB_IF_TYPE_IBSS)
-		memcpy(local->bssid, bssid, ETH_ALEN);
 
 	if (memcmp(bssid, "\x00\x00\x00\x00\x00\x00", ETH_ALEN) == 0)
 		ifsta->bssid_set = 0;
-- 
1.3.0

