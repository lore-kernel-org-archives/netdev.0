From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 9/12] d80211: do not cancel uninitialized work
Date: Wed,  3 Jan 2007 19:05:17 +0100 (CET)
Message-ID: <20070103180517.779303AA7F2@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42230 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751033AbXACSFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:19 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When ops->hw_scan is set, scan_work is never initialized thus canceling it
causes weird problems.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

82c4e75463da9d3f38540198c4594cafe336b3e1
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index a5ae8a1..056b26c 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2082,7 +2082,8 @@ void ieee80211_if_shutdown(struct net_de
 	case IEEE80211_IF_TYPE_IBSS:
 		sdata->u.sta.state = IEEE80211_DISABLED;
 		cancel_delayed_work(&sdata->u.sta.work);
-		if (local->scan_work.data == sdata->dev) {
+		if (!local->ops->hw_scan &&
+		    local->scan_work.data == sdata->dev) {
 			local->sta_scanning = 0;
 			cancel_delayed_work(&local->scan_work);
 			flush_scheduled_work();
@@ -4660,7 +4661,7 @@ void ieee80211_unregister_hw(struct ieee
 
 	if (local->stat_time)
 		del_timer_sync(&local->stat_timer);
-	if (local->scan_work.data) {
+	if (!local->ops->hw_scan && local->scan_work.data) {
 		local->sta_scanning = 0;
 		cancel_delayed_work(&local->scan_work);
 		flush_scheduled_work();
-- 
1.3.0

