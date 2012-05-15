From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3] net: mac80211: Add and use ibss_vdbg debugging macro
Date: Tue, 15 May 2012 14:20:32 -0700
Message-ID: <51ca4a7ba071816e30ef8544bbb0fa51334b61cb.1337116579.git.joe@perches.com>
References: <1337106548.15553.8.camel@jlt3.sipsolutions.net> <cover.1337116578.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1337116578.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify the use of #ifdef CONFIG_MAC80211_IBSS_DEBUG/#endif
by adding a logging macro to encapsulate the test.

Convert the appropriate uses too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/mac80211.h  |   11 ++++++
 net/mac80211/ibss.c     |   79 ++++++++++++++++------------------------------
 net/mac80211/sta_info.c |    6 +--
 3 files changed, 41 insertions(+), 55 deletions(-)

diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 7d79fd0..9306e6d 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -3842,4 +3842,15 @@ do {						\
 } while (0)
 #endif
 
+#ifdef CONFIG_MAC80211_IBSS_DEBUG
+#define ibss_vdbg(fmt, ...)			\
+	pr_debug(fmt, ##__VA_ARGS__)
+#else
+#define ibss_vdbg(fmt, ...)			\
+do {						\
+	if (0)					\
+		pr_debug(fmt, ##__VA_ARGS__);	\
+} while (0)
+#endif
+
 #endif /* MAC80211_H */
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 33e0566..e23faba 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -276,10 +276,8 @@ static struct sta_info *ieee80211_ibss_finish_sta(struct sta_info *sta,
 	if (sta_info_insert_rcu(sta))
 		return sta_info_get(sdata, addr);
 	if (auth) {
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-		pr_debug("TX Auth SA=%pM DA=%pM BSSID=%pM (auth_transaction=1)\n",
-			 sdata->vif.addr, sdata->u.ibss.bssid, addr);
-#endif
+		ibss_vdbg("TX Auth SA=%pM DA=%pM BSSID=%pM (auth_transaction=1)\n",
+			  sdata->vif.addr, sdata->u.ibss.bssid, addr);
 		ieee80211_send_auth(sdata, 1, WLAN_AUTH_OPEN, NULL, 0,
 				    addr, sdata->u.ibss.bssid, NULL, 0, 0);
 	}
@@ -349,11 +347,9 @@ static void ieee80211_rx_mgmt_auth_ibss(struct ieee80211_sub_if_data *sdata,
 
 	if (auth_alg != WLAN_AUTH_OPEN || auth_transaction != 1)
 		return;
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-	pr_debug("%s: RX Auth SA=%pM DA=%pM BSSID=%pM (auth_transaction=%d)\n",
-		 sdata->name, mgmt->sa, mgmt->da, mgmt->bssid,
-		 auth_transaction);
-#endif
+	ibss_vdbg("%s: RX Auth SA=%pM DA=%pM BSSID=%pM (auth_transaction=%d)\n",
+		  sdata->name, mgmt->sa, mgmt->da, mgmt->bssid,
+		  auth_transaction);
 	sta_info_destroy_addr(sdata, mgmt->sa);
 	ieee80211_ibss_add_sta(sdata, mgmt->bssid, mgmt->sa, 0, false);
 	rcu_read_unlock();
@@ -416,12 +412,10 @@ static void ieee80211_rx_bss_info(struct ieee80211_sub_if_data *sdata,
 					ieee80211_mandatory_rates(local, band);
 
 				if (sta->sta.supp_rates[band] != prev_rates) {
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-					pr_debug("%s: updated supp_rates set for %pM based on beacon/probe_resp (0x%x -> 0x%x)\n",
-						 sdata->name, sta->sta.addr,
-						 prev_rates,
-						 sta->sta.supp_rates[band]);
-#endif
+					ibss_vdbg("%s: updated supp_rates set for %pM based on beacon/probe_resp (0x%x -> 0x%x)\n",
+						  sdata->name, sta->sta.addr,
+						  prev_rates,
+						  sta->sta.supp_rates[band]);
 					rates_updated = true;
 				}
 			} else {
@@ -536,20 +530,16 @@ static void ieee80211_rx_bss_info(struct ieee80211_sub_if_data *sdata,
 		rx_timestamp = drv_get_tsf(local, sdata);
 	}
 
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-	pr_debug("RX beacon SA=%pM BSSID=%pM TSF=0x%llx BCN=0x%llx diff=%lld @%lu\n",
-		 mgmt->sa, mgmt->bssid,
-		 (unsigned long long)rx_timestamp,
-		 (unsigned long long)beacon_timestamp,
-		 (unsigned long long)(rx_timestamp - beacon_timestamp),
-		 jiffies);
-#endif
+	ibss_vdbg("RX beacon SA=%pM BSSID=%pM TSF=0x%llx BCN=0x%llx diff=%lld @%lu\n",
+		  mgmt->sa, mgmt->bssid,
+		  (unsigned long long)rx_timestamp,
+		  (unsigned long long)beacon_timestamp,
+		  (unsigned long long)(rx_timestamp - beacon_timestamp),
+		  jiffies);
 
 	if (beacon_timestamp > rx_timestamp) {
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-		pr_debug("%s: beacon TSF higher than local TSF - IBSS merge with BSSID %pM\n",
-			 sdata->name, mgmt->bssid);
-#endif
+		ibss_vdbg("%s: beacon TSF higher than local TSF - IBSS merge with BSSID %pM\n",
+			  sdata->name, mgmt->bssid);
 		ieee80211_sta_join_ibss(sdata, bss);
 		supp_rates = ieee80211_sta_get_rates(local, elems, band, NULL);
 		ieee80211_ibss_add_sta(sdata, mgmt->bssid, mgmt->sa,
@@ -712,10 +702,8 @@ static void ieee80211_sta_find_ibss(struct ieee80211_sub_if_data *sdata)
 	lockdep_assert_held(&ifibss->mtx);
 
 	active_ibss = ieee80211_sta_active_ibss(sdata);
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-	pr_debug("%s: sta_find_ibss (active_ibss=%d)\n",
-		 sdata->name, active_ibss);
-#endif /* CONFIG_MAC80211_IBSS_DEBUG */
+	ibss_vdbg("%s: sta_find_ibss (active_ibss=%d)\n",
+		  sdata->name, active_ibss);
 
 	if (active_ibss)
 		return;
@@ -738,11 +726,8 @@ static void ieee80211_sta_find_ibss(struct ieee80211_sub_if_data *sdata)
 		struct ieee80211_bss *bss;
 
 		bss = (void *)cbss->priv;
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-		pr_debug("   sta_find_ibss: selected %pM current %pM\n",
-			 cbss->bssid, ifibss->bssid);
-#endif /* CONFIG_MAC80211_IBSS_DEBUG */
-
+		ibss_vdbg("   sta_find_ibss: selected %pM current %pM\n",
+			  cbss->bssid, ifibss->bssid);
 		pr_debug("%s: Selected IBSS BSSID %pM based on configured SSID\n",
 			 sdata->name, cbss->bssid);
 
@@ -751,9 +736,7 @@ static void ieee80211_sta_find_ibss(struct ieee80211_sub_if_data *sdata)
 		return;
 	}
 
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-	pr_debug("   did not try to join ibss\n");
-#endif /* CONFIG_MAC80211_IBSS_DEBUG */
+	ibss_vdbg("   did not try to join ibss\n");
 
 	/* Selected IBSS not found in current scan results - try to scan */
 	if (time_after(jiffies, ifibss->last_scan_completed +
@@ -810,11 +793,9 @@ static void ieee80211_rx_mgmt_probe_req(struct ieee80211_sub_if_data *sdata,
 
 	tx_last_beacon = drv_tx_last_beacon(local);
 
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-	pr_debug("%s: RX ProbeReq SA=%pM DA=%pM BSSID=%pM (tx_last_beacon=%d)\n",
-		 sdata->name, mgmt->sa, mgmt->da,
-		 mgmt->bssid, tx_last_beacon);
-#endif /* CONFIG_MAC80211_IBSS_DEBUG */
+	ibss_vdbg("%s: RX ProbeReq SA=%pM DA=%pM BSSID=%pM (tx_last_beacon=%d)\n",
+		  sdata->name, mgmt->sa, mgmt->da,
+		  mgmt->bssid, tx_last_beacon);
 
 	if (!tx_last_beacon && is_multicast_ether_addr(mgmt->da))
 		return;
@@ -827,10 +808,8 @@ static void ieee80211_rx_mgmt_probe_req(struct ieee80211_sub_if_data *sdata,
 	pos = mgmt->u.probe_req.variable;
 	if (pos[0] != WLAN_EID_SSID ||
 	    pos + 2 + pos[1] > end) {
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-		pr_debug("%s: Invalid SSID IE in ProbeReq from %pM\n",
-			 sdata->name, mgmt->sa);
-#endif
+		ibss_vdbg("%s: Invalid SSID IE in ProbeReq from %pM\n",
+			  sdata->name, mgmt->sa);
 		return;
 	}
 	if (pos[1] != 0 &&
@@ -847,9 +826,7 @@ static void ieee80211_rx_mgmt_probe_req(struct ieee80211_sub_if_data *sdata,
 
 	resp = (struct ieee80211_mgmt *) skb->data;
 	memcpy(resp->da, mgmt->sa, ETH_ALEN);
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-	pr_debug("%s: Sending ProbeResp to %pM\n", sdata->name, resp->da);
-#endif /* CONFIG_MAC80211_IBSS_DEBUG */
+	ibss_vdbg("%s: Sending ProbeResp to %pM\n", sdata->name, resp->da);
 	IEEE80211_SKB_CB(skb)->flags |= IEEE80211_TX_INTFL_DONT_ENCRYPT;
 	ieee80211_tx_skb(sdata, skb);
 }
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 4be5098..0a70f79 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -887,10 +887,8 @@ void ieee80211_sta_expire(struct ieee80211_sub_if_data *sdata,
 			continue;
 
 		if (time_after(jiffies, sta->last_rx + exp_time)) {
-#ifdef CONFIG_MAC80211_IBSS_DEBUG
-			pr_debug("%s: expiring inactive STA %pM\n",
-				 sdata->name, sta->sta.addr);
-#endif
+			ibss_vdbg("%s: expiring inactive STA %pM\n",
+				  sdata->name, sta->sta.addr);
 			WARN_ON(__sta_info_destroy(sta));
 		}
 	}
-- 
1.7.8.111.gad25c.dirty
