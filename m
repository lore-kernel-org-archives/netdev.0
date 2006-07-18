From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/9] d80211: do not receive through master interface when not scanning
Date: Tue, 18 Jul 2006 17:45:21 +0200 (CEST)
Message-ID: <20060718154521.D2DE1483BC@silver.suse.cz>
References: <20060718174442.485760904.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:39817 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932292AbWGRPne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:43:34 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060718174442.485760904.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arrived packets should not go into master interface except when scanning
- it leads to duplicate packets reception. This also fixes a race when
scanning is finished during invoking of rx handlers.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c   |   17 +++++++++++++++--
 net/d80211/ieee80211_i.h |    1 +
 2 files changed, 16 insertions(+), 2 deletions(-)

62cefb2dabe7ea740481200408a07a797b7281ab
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 7ceef10..18d910d 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -3346,6 +3346,12 @@ ieee80211_rx_h_passive_scan(struct ieee8
                 }
         }
 
+	if (unlikely(rx->u.rx.in_scan)) {
+		/* scanning finished during invoking of handlers */
+		I802_DEBUG_INC(local->rx_handlers_drop_passive_scan);
+		return TXRX_DROP;
+	}
+
         return TXRX_CONTINUE;
 }
 
@@ -3537,6 +3543,9 @@ void __ieee80211_rx(struct net_device *d
 		goto end;
         }
 
+	if (unlikely(local->sta_scanning || local->scan.in_scan))
+		rx.u.rx.in_scan = 1;
+
 	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS) &&
 	    !local->iff_promiscs && !multicast) {
 		rx.dev = sta->dev;
@@ -3579,11 +3588,15 @@ void __ieee80211_rx(struct net_device *d
 					if (memcmp(sdata->dev->dev_addr,
 						   hdr->addr1, ETH_ALEN) != 0)
 						continue;
-				} else if (!local->sta_scanning &&
-					   !local->scan.in_scan &&
+				} else if (!rx.u.rx.in_scan &&
 					   !ieee80211_bssid_match(bssid,
 							sdata->dev->dev_addr))
 					continue;
+				if (sdata->dev == sdata->master &&
+				    !rx.u.rx.in_scan)
+					/* do not receive anything via
+					 * master device when not scanning */
+					continue;
 				break;
 			case IEEE80211_IF_TYPE_WDS:
 				if (bssid ||
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 0409c52..9e1fff2 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -137,6 +137,7 @@ struct ieee80211_txrx_data {
 			struct ieee80211_rx_status *status;
 			int sent_ps_buffered;
 			int queue;
+			int in_scan:1;
 		} rx;
 	} u;
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
-- 
1.3.0

