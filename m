From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/5] d80211: return correct error codes for scan requests
Date: Tue,  1 Aug 2006 21:16:56 +0200 (CEST)
Message-ID: <20060801191656.E8574483A6@silver.suse.cz>
References: <20060801211530.150852000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49624 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751819AbWHATQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 15:16:55 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801211530.150852000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not allow scanning when the network interface is down. Return 0 instead
of -EBUSY when scanning is in progress on the same network interface.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |    6 ++++++
 net/d80211/ieee80211_sta.c   |    5 ++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

2cf10f1a78222a375297d01a919d55d1a3c2a5a6
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index d73693e..e43e3b0 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1091,6 +1091,9 @@ static int ieee80211_ioctl_scan_req(stru
 	if (local->user_space_mlme)
 		return -EOPNOTSUPP;
 
+	if (!netif_running(dev))
+		return -ENETDOWN;
+
 	if (left < len || len > IEEE80211_MAX_SSID_LEN)
 		return -EINVAL;
 
@@ -1914,6 +1917,9 @@ static int ieee80211_ioctl_siwscan(struc
 	u8 *ssid = NULL;
 	size_t ssid_len = 0;
 
+	if (!netif_running(dev))
+		return -ENETDOWN;
+
 	if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
 		if (sdata->type == IEEE80211_IF_TYPE_STA ||
 		    sdata->type == IEEE80211_IF_TYPE_IBSS) {
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 22f9599..13dcdae 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2548,8 +2548,11 @@ int ieee80211_sta_req_scan(struct net_de
 	/* TODO: if assoc, move to power save mode for the duration of the
 	 * scan */
 
-	if (local->sta_scanning)
+	if (local->sta_scanning) {
+		if (local->scan_work.data == dev)
+			return 0;
 		return -EBUSY;
+	}
 
 	printk(KERN_DEBUG "%s: starting scan\n", dev->name);
 
-- 
1.3.0

