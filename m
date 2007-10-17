From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] mac80211: only honor IW_SCAN_THIS_ESSID in STA, IBSS, and AP modes
Date: Wed, 17 Oct 2007 10:54:54 -0400
Message-ID: <11926328942540-git-send-email-linville@tuxdriver.com>
References: <200710162329.55966.flamingice@sourmilk.net> <20071017145315.GC5744@tuxdriver.com>
Cc: davem@davemloft.net, flamingice@sourmilk.net,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2348 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755828AbXJQPI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 11:08:56 -0400
In-Reply-To: <20071017145315.GC5744@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The previous IW_SCAN_THIS_ESSID patch left a hole allowing scan
requests on interfaces in inappropriate modes.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/mac80211/ieee80211_ioctl.c |   37 +++++++++++++++++++------------------
 1 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 83e4035..e1fafb6 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -521,29 +521,30 @@ static int ieee80211_ioctl_siwscan(struct net_device *dev,
 	if (!netif_running(dev))
 		return -ENETDOWN;
 
+	switch (sdata->type) {
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_IBSS:
+		if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
+			ssid = sdata->u.sta.ssid;
+			ssid_len = sdata->u.sta.ssid_len;
+		}
+		break;
+	case IEEE80211_IF_TYPE_AP:
+		if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
+			ssid = sdata->u.ap.ssid;
+			ssid_len = sdata->u.ap.ssid_len;
+		}
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	/* if SSID was specified explicitly then use that */
 	if (wrqu->data.length == sizeof(struct iw_scan_req) &&
 	    wrqu->data.flags & IW_SCAN_THIS_ESSID) {
 		req = (struct iw_scan_req *)extra;
 		ssid = req->essid;
 		ssid_len = req->essid_len;
-	} else {
-		switch (sdata->type) {
-		case IEEE80211_IF_TYPE_STA:
-		case IEEE80211_IF_TYPE_IBSS:
-			if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
-				ssid = sdata->u.sta.ssid;
-				ssid_len = sdata->u.sta.ssid_len;
-			}
-			break;
-		case IEEE80211_IF_TYPE_AP:
-			if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
-				ssid = sdata->u.ap.ssid;
-				ssid_len = sdata->u.ap.ssid_len;
-			}
-			break;
-		default:
-			return -EOPNOTSUPP;
-		}
 	}
 
 	return ieee80211_sta_req_scan(dev, ssid, ssid_len);
-- 
1.5.2.4

