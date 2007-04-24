From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH net-2.6.22, wireless-dev] clarify locking comment in
	cfg80211
Date: Tue, 24 Apr 2007 20:39:09 +0200
Message-ID: <1177439950.3528.42.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: John Linville <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47975 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993151AbXDZJlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 05:41:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch clarifies the comment about locking in wiphy_unregister.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
Diffed for wireless-dev but applies with some offset to net-2.6.22 as
well.

 net/wireless/core.c |   19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

--- wireless-dev.orig/net/wireless/core.c	2007-04-24 20:21:02.648804911 +0200
+++ wireless-dev/net/wireless/core.c	2007-04-24 20:36:05.948804911 +0200
@@ -223,7 +223,6 @@ int wiphy_register(struct wiphy *wiphy)
 
 	mutex_lock(&cfg80211_drv_mutex);
 
-
 	res = device_add(&drv->wiphy.dev);
 	if (res)
 		goto out_unlock;
@@ -246,14 +245,26 @@ void wiphy_unregister(struct wiphy *wiph
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
 


