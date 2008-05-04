From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][MAC80211]: Do not free net device after it is unregistered.
Date: Sun, 04 May 2008 10:53:45 +0400
Message-ID: <481D5D79.5080702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:49110 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649AbYEDHBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 03:01:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error path in ieee80211_register_hw() may call the unregister_netdev()
and right after it - the free_netdev(), which is wrong, since the
unregister releases the device itself.

So the proposed fix is to NULL the local->mdev after unregister is done
and check this before calling free_netdev().

I checked - no code uses the local->mdev after unregister in this error
path (but even if some did this would be a BUG).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/mac80211/main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 9ad4e36..915afad 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -1766,6 +1766,7 @@ fail_wep:
 fail_rate:
 	ieee80211_debugfs_remove_netdev(IEEE80211_DEV_TO_SUB_IF(local->mdev));
 	unregister_netdevice(local->mdev);
+	local->mdev = NULL;
 fail_dev:
 	rtnl_unlock();
 	sta_info_stop(local);
@@ -1773,8 +1774,10 @@ fail_sta_info:
 	debugfs_hw_del(local);
 	destroy_workqueue(local->hw.workqueue);
 fail_workqueue:
-	ieee80211_if_free(local->mdev);
-	local->mdev = NULL;
+	if (local->mdev != NULL) {
+		ieee80211_if_free(local->mdev);
+		local->mdev = NULL;
+	}
 fail_mdev_alloc:
 	wiphy_unregister(local->hw.wiphy);
 	return result;
-- 
1.5.3.4

