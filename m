From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 18/21] d80211: allow for large scan results
Date: Wed, 23 Aug 2006 21:24:27 +0200 (CEST)
Message-ID: <20060823192427.74A8B483B6@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:30672 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965142AbWHWTY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:27 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

Fix a problem where incomplete scan results could be returned if the
environment includes a large number of devices.  Do not truncate the
scan results and allow a result to contain more than IW_SCAN_MAX_DATA
bytes.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |    2 +-
 net/d80211/ieee80211_sta.c   |    4 ++++
 2 files changed, 5 insertions(+), 1 deletions(-)

fb6433e836927581362d71532f010b0d5aa7587b
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 35e4711..53b7841 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -1992,7 +1992,7 @@ static int ieee80211_ioctl_giwscan(struc
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	if (local->sta_scanning)
 		return -EAGAIN;
-	res = ieee80211_sta_scan_results(dev, extra, IW_SCAN_MAX_DATA);
+	res = ieee80211_sta_scan_results(dev, extra, data->length);
 	if (res >= 0) {
 		data->length = res;
 		return 0;
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index a3bcc1b..a933d92 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2743,6 +2743,10 @@ int ieee80211_sta_scan_results(struct ne
 	spin_lock_bh(&local->sta_bss_lock);
 	list_for_each(ptr, &local->sta_bss_list) {
 		bss = list_entry(ptr, struct ieee80211_sta_bss, list);
+		if (buf + len - current_ev <= IW_EV_ADDR_LEN) {
+			spin_unlock_bh(&local->sta_bss_lock);
+			return -E2BIG;
+		}
 		current_ev = ieee80211_sta_scan_result(dev, bss, current_ev,
 						       end_buf);
 	}
-- 
1.3.0

