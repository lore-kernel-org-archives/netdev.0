From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 1/5] d80211: allow for large scan results
Date: Tue, 22 Aug 2006 10:33:09 -0700
Message-ID: <20060822173309.GB12500@devicescape.com>
References: <20060822173241.313859000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-37.dex002.intermedia.net ([64.78.21.122]:24231 "EHLO
	dhost002-37.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932322AbWHVRdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 13:33:10 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="scan_length.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a problem where incomplete scan results could be returned if the
environment includes a large number of devices.  Do not truncate the
scan results and allow a result to contain more than IW_SCAN_MAX_DATA
bytes.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_sta.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_sta.c
+++ wireless-dev/net/d80211/ieee80211_sta.c
@@ -2753,6 +2753,10 @@ int ieee80211_sta_scan_results(struct ne
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
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -1998,7 +1998,7 @@ static int ieee80211_ioctl_giwscan(struc
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	if (local->sta_scanning)
 		return -EAGAIN;
-	res = ieee80211_sta_scan_results(dev, extra, IW_SCAN_MAX_DATA);
+	res = ieee80211_sta_scan_results(dev, extra, data->length);
 	if (res >= 0) {
 		data->length = res;
 		return 0;

--
