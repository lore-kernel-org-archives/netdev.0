From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/3] d80211: experimental: do not receive through master
 interface when not scanning
Date: Sat, 24 Jun 2006 13:50:43 +0200
Message-ID: <20060624135043.09e2d237@logostar.upir.cz>
References: <20060623201604.835047000.midnight@suse.cz>
	<20060623181634.56509483AB@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mbuesch@freenet.de>,
	Alexander Tsvyashchenko <lists@ndl.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r2u241.chello.upc.cz ([62.245.84.241]:51089 "EHLO cela.cz")
	by vger.kernel.org with ESMTP id S964782AbWFXLuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jun 2006 07:50:46 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060623181634.56509483AB@silver.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a corrected version of the patch. I also updated the 'devel' branch
of my tree.

---

Arrived packets should not go into master interface except when scanning
- it leads to duplicate packets reception. This also fixes a race when
scanning is finished during invoking of rx handlers.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211.c   |   17 +++++++++++++++--
 net/d80211/ieee80211_i.h |    1 +
 2 files changed, 16 insertions(+), 2 deletions(-)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -3348,6 +3348,12 @@ ieee80211_rx_h_passive_scan(struct ieee8
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
 
@@ -3539,6 +3545,9 @@ void __ieee80211_rx(struct net_device *d
 		goto end;
         }
 
+	if (unlikely(local->sta_scanning || local->scan.in_scan))
+		rx.u.rx.in_scan = 1;
+
 	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS) &&
 	    !local->iff_promiscs && !multicast) {
 		rx.dev = sta->dev;
@@ -3581,11 +3590,15 @@ void __ieee80211_rx(struct net_device *d
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
--- dscape.orig/net/d80211/ieee80211_i.h
+++ dscape/net/d80211/ieee80211_i.h
@@ -137,6 +137,7 @@ struct ieee80211_txrx_data {
 			struct ieee80211_rx_status *status;
 			int sent_ps_buffered;
 			int queue;
+			int in_scan:1;
 		} rx;
 	} u;
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
