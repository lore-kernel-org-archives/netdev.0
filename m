From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] clarify locking comment in cfg80211
Date: Thu, 26 Apr 2007 21:50:55 -0400
Message-ID: <20070427015055.GF25332@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

This patch clarifies the comment about locking in wiphy_unregister.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
I applied this after the "fix locking in wiphy_new" patch, but I
don't think the order really matters.

 net/wireless/core.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/wireless/core.c b/net/wireless/core.c
index 24a21ad..7eabd55 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -91,7 +91,6 @@ int wiphy_register(struct wiphy *wiphy)
 
 	mutex_lock(&cfg80211_drv_mutex);
 
-
 	res = device_add(&drv->wiphy.dev);
 	if (res)
 		goto out_unlock;
@@ -114,14 +113,26 @@ void wiphy_unregister(struct wiphy *wiphy)
 {
 	struct cfg80211_registered_device *drv = wiphy_to_dev(wiphy);
 
+	/* protect the device list */
 	mutex_lock(&cfg80211_drv_mutex);
 
-	/* hold registered driver mutex during list removal as well
-	 * to make sure no commands are in progress at the moment */
+	BUG_ON(!list_empty(&drv->netdev_list));
+
+	/*
+	 * Try to grab drv->mtx. If a command is still in progress,
+	 * hopefully the driver will refuse it since it's tearing
+	 * down the device already. We wait for this command to complete
+	 * before unlinking the item from the list.
+	 * Note: as codified by the BUG_ON above we cannot get here if
+	 * a virtual interface is still associated. Hence, we can only
+	 * get to lock contention here if userspace issues a command
+	 * that identified the hardware by wiphy index.
+	 */
 	mutex_lock(&drv->mtx);
-	list_del(&drv->list);
+	/* unlock again before freeing */
 	mutex_unlock(&drv->mtx);
 
+	list_del(&drv->list);
 	device_del(&drv->wiphy.dev);
 	debugfs_remove(drv->wiphy.debugfsdir);
 
-- 
1.5.0.6

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
