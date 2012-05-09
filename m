From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/13] wireless: Convert compare_ether_addr to ether_addr_equal
Date: Tue,  8 May 2012 21:56:55 -0700
Message-ID: <7b451ccc096b5176febd24ce9cd8009b38b3bf0a.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1336538937.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new bool function ether_addr_equal to add
some clarity and reduce the likelihood for misuse
of compare_ether_addr for sorting.

I removed a conversion from scan.c/cmp_bss_core
that appears to be a sorting function.

Done via cocci script:

$ cat compare_ether_addr.cocci
@@
expression a,b;
@@
-	!compare_ether_addr(a, b)
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	compare_ether_addr(a, b)
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) == 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) != 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) == 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) != 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal(a, b)
+	ether_addr_equal(a, b)

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/wireless/ibss.c     |    2 +-
 net/wireless/mlme.c     |   31 +++++++++++++++----------------
 net/wireless/scan.c     |    2 +-
 net/wireless/util.c     |    5 ++---
 net/wireless/wext-sme.c |    2 +-
 net/wireless/wext-spy.c |    2 +-
 6 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/net/wireless/ibss.c b/net/wireless/ibss.c
index 30f20fe..d2a19b0 100644
--- a/net/wireless/ibss.c
+++ b/net/wireless/ibss.c
@@ -473,7 +473,7 @@ int cfg80211_ibss_wext_siwap(struct net_device *dev,
 
 	/* fixed already - and no change */
 	if (wdev->wext.ibss.bssid && bssid &&
-	    compare_ether_addr(bssid, wdev->wext.ibss.bssid) == 0)
+	    ether_addr_equal(bssid, wdev->wext.ibss.bssid))
 		return 0;
 
 	wdev_lock(wdev);
diff --git a/net/wireless/mlme.c b/net/wireless/mlme.c
index 6801d96..eb90988 100644
--- a/net/wireless/mlme.c
+++ b/net/wireless/mlme.c
@@ -101,7 +101,7 @@ void __cfg80211_send_deauth(struct net_device *dev,
 	ASSERT_WDEV_LOCK(wdev);
 
 	if (wdev->current_bss &&
-	    compare_ether_addr(wdev->current_bss->pub.bssid, bssid) == 0) {
+	    ether_addr_equal(wdev->current_bss->pub.bssid, bssid)) {
 		cfg80211_unhold_bss(wdev->current_bss);
 		cfg80211_put_bss(&wdev->current_bss->pub);
 		wdev->current_bss = NULL;
@@ -116,7 +116,7 @@ void __cfg80211_send_deauth(struct net_device *dev,
 
 		reason_code = le16_to_cpu(mgmt->u.deauth.reason_code);
 
-		from_ap = compare_ether_addr(mgmt->sa, dev->dev_addr) != 0;
+		from_ap = !ether_addr_equal(mgmt->sa, dev->dev_addr);
 		__cfg80211_disconnected(dev, NULL, 0, reason_code, from_ap);
 	} else if (wdev->sme_state == CFG80211_SME_CONNECTING) {
 		__cfg80211_connect_result(dev, mgmt->bssid, NULL, 0, NULL, 0,
@@ -155,7 +155,7 @@ void __cfg80211_send_disassoc(struct net_device *dev,
 		return;
 
 	if (wdev->current_bss &&
-	    compare_ether_addr(wdev->current_bss->pub.bssid, bssid) == 0) {
+	    ether_addr_equal(wdev->current_bss->pub.bssid, bssid)) {
 		cfg80211_sme_disassoc(dev, wdev->current_bss);
 		cfg80211_unhold_bss(wdev->current_bss);
 		cfg80211_put_bss(&wdev->current_bss->pub);
@@ -166,7 +166,7 @@ void __cfg80211_send_disassoc(struct net_device *dev,
 
 	reason_code = le16_to_cpu(mgmt->u.disassoc.reason_code);
 
-	from_ap = compare_ether_addr(mgmt->sa, dev->dev_addr) != 0;
+	from_ap = !ether_addr_equal(mgmt->sa, dev->dev_addr);
 	__cfg80211_disconnected(dev, NULL, 0, reason_code, from_ap);
 }
 EXPORT_SYMBOL(__cfg80211_send_disassoc);
@@ -286,7 +286,7 @@ int __cfg80211_mlme_auth(struct cfg80211_registered_device *rdev,
 			return -EINVAL;
 
 	if (wdev->current_bss &&
-	    compare_ether_addr(bssid, wdev->current_bss->pub.bssid) == 0)
+	    ether_addr_equal(bssid, wdev->current_bss->pub.bssid))
 		return -EALREADY;
 
 	memset(&req, 0, sizeof(req));
@@ -363,7 +363,7 @@ int __cfg80211_mlme_assoc(struct cfg80211_registered_device *rdev,
 	memset(&req, 0, sizeof(req));
 
 	if (wdev->current_bss && prev_bssid &&
-	    compare_ether_addr(wdev->current_bss->pub.bssid, prev_bssid) == 0) {
+	    ether_addr_equal(wdev->current_bss->pub.bssid, prev_bssid)) {
 		/*
 		 * Trying to reassociate: Allow this to proceed and let the old
 		 * association to be dropped when the new one is completed.
@@ -447,8 +447,7 @@ int __cfg80211_mlme_deauth(struct cfg80211_registered_device *rdev,
 
 	if (local_state_change) {
 		if (wdev->current_bss &&
-		    compare_ether_addr(wdev->current_bss->pub.bssid, bssid)
-		    == 0) {
+		    ether_addr_equal(wdev->current_bss->pub.bssid, bssid)) {
 			cfg80211_unhold_bss(wdev->current_bss);
 			cfg80211_put_bss(&wdev->current_bss->pub);
 			wdev->current_bss = NULL;
@@ -497,7 +496,7 @@ static int __cfg80211_mlme_disassoc(struct cfg80211_registered_device *rdev,
 	req.local_state_change = local_state_change;
 	req.ie = ie;
 	req.ie_len = ie_len;
-	if (compare_ether_addr(wdev->current_bss->pub.bssid, bssid) == 0)
+	if (ether_addr_equal(wdev->current_bss->pub.bssid, bssid))
 		req.bss = &wdev->current_bss->pub;
 	else
 		return -ENOTCONN;
@@ -760,8 +759,8 @@ int cfg80211_mlme_mgmt_tx(struct cfg80211_registered_device *rdev,
 				break;
 			}
 
-			if (compare_ether_addr(wdev->current_bss->pub.bssid,
-					       mgmt->bssid)) {
+			if (!ether_addr_equal(wdev->current_bss->pub.bssid,
+					      mgmt->bssid)) {
 				err = -ENOTCONN;
 				break;
 			}
@@ -774,8 +773,8 @@ int cfg80211_mlme_mgmt_tx(struct cfg80211_registered_device *rdev,
 				break;
 
 			/* for station, check that DA is the AP */
-			if (compare_ether_addr(wdev->current_bss->pub.bssid,
-					       mgmt->da)) {
+			if (!ether_addr_equal(wdev->current_bss->pub.bssid,
+					      mgmt->da)) {
 				err = -ENOTCONN;
 				break;
 			}
@@ -783,11 +782,11 @@ int cfg80211_mlme_mgmt_tx(struct cfg80211_registered_device *rdev,
 		case NL80211_IFTYPE_AP:
 		case NL80211_IFTYPE_P2P_GO:
 		case NL80211_IFTYPE_AP_VLAN:
-			if (compare_ether_addr(mgmt->bssid, dev->dev_addr))
+			if (!ether_addr_equal(mgmt->bssid, dev->dev_addr))
 				err = -EINVAL;
 			break;
 		case NL80211_IFTYPE_MESH_POINT:
-			if (compare_ether_addr(mgmt->sa, mgmt->bssid)) {
+			if (!ether_addr_equal(mgmt->sa, mgmt->bssid)) {
 				err = -EINVAL;
 				break;
 			}
@@ -806,7 +805,7 @@ int cfg80211_mlme_mgmt_tx(struct cfg80211_registered_device *rdev,
 			return err;
 	}
 
-	if (compare_ether_addr(mgmt->sa, dev->dev_addr) != 0)
+	if (!ether_addr_equal(mgmt->sa, dev->dev_addr))
 		return -EINVAL;
 
 	/* Transmit the Action frame as requested by user space */
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 1442bb6..26d96d7 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -281,7 +281,7 @@ static bool is_bss(struct cfg80211_bss *a,
 {
 	const u8 *ssidie;
 
-	if (bssid && compare_ether_addr(a->bssid, bssid))
+	if (bssid && !ether_addr_equal(a->bssid, bssid))
 		return false;
 
 	if (!ssid)
diff --git a/net/wireless/util.c b/net/wireless/util.c
index 6cba001..3ba366f 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -609,10 +609,9 @@ void ieee80211_amsdu_to_8023s(struct sk_buff *skb, struct sk_buff_head *list,
 		payload = frame->data;
 		ethertype = (payload[6] << 8) | payload[7];
 
-		if (likely((compare_ether_addr(payload, rfc1042_header) == 0 &&
+		if (likely((ether_addr_equal(payload, rfc1042_header) &&
 			    ethertype != ETH_P_AARP && ethertype != ETH_P_IPX) ||
-			   compare_ether_addr(payload,
-					      bridge_tunnel_header) == 0)) {
+			   ether_addr_equal(payload, bridge_tunnel_header))) {
 			/* remove RFC1042 or Bridge-Tunnel
 			 * encapsulation and replace EtherType */
 			skb_pull(frame, 6);
diff --git a/net/wireless/wext-sme.c b/net/wireless/wext-sme.c
index 7c01c2f..7decbd3 100644
--- a/net/wireless/wext-sme.c
+++ b/net/wireless/wext-sme.c
@@ -276,7 +276,7 @@ int cfg80211_mgd_wext_siwap(struct net_device *dev,
 
 		/* fixed already - and no change */
 		if (wdev->wext.connect.bssid && bssid &&
-		    compare_ether_addr(bssid, wdev->wext.connect.bssid) == 0)
+		    ether_addr_equal(bssid, wdev->wext.connect.bssid))
 			goto out;
 
 		err = __cfg80211_disconnect(rdev, dev,
diff --git a/net/wireless/wext-spy.c b/net/wireless/wext-spy.c
index 5d643a5..33bef22 100644
--- a/net/wireless/wext-spy.c
+++ b/net/wireless/wext-spy.c
@@ -203,7 +203,7 @@ void wireless_spy_update(struct net_device *	dev,
 
 	/* Update all records that match */
 	for (i = 0; i < spydata->spy_number; i++)
-		if (!compare_ether_addr(address, spydata->spy_address[i])) {
+		if (ether_addr_equal(address, spydata->spy_address[i])) {
 			memcpy(&(spydata->spy_stat[i]), wstats,
 			       sizeof(struct iw_quality));
 			match = i;
-- 
1.7.8.111.gad25c.dirty
