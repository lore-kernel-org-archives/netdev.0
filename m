From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH wireless-dev, net-2.6.22] cfg80211: fix locking in wiphy_new
Date: Thu, 26 Apr 2007 15:14:22 +0200
Message-ID: <1177593262.6814.75.camel@johannes.berg>
References: <20070423183334.GC5883@tuxdriver.com>
	 <20070423183443.GD5883@tuxdriver.com> <20070423183634.GE5883@tuxdriver.com>
	 <200704251806.46270.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35109 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031355AbXDZRJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 13:09:04 -0400
In-Reply-To: <200704251806.46270.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the locking in wiphy new. Ingo Oeser <netdev@axxeo.de>
noticed that locking in the error case was wrong and also suggested this
fix.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
As with other patches, this is diffed against wireless-dev but applies
against net-2.6.22 (or is that net-2.6 now?) with some offset (but no
fuzz.)

---
 net/wireless/core.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

--- wireless-dev.orig/net/wireless/core.c	2007-04-26 15:01:15.623251869 +0200
+++ wireless-dev/net/wireless/core.c	2007-04-26 15:07:27.933251869 +0200
@@ -189,21 +189,25 @@ struct wiphy *wiphy_new(struct cfg80211_
 
 	mutex_lock(&cfg80211_drv_mutex);
 
-	if (unlikely(wiphy_counter<0)) {
+	drv->idx = wiphy_counter;
+
+	/* now increase counter for the next device unless
+	 * it has wrapped previously */
+	if (wiphy_counter >= 0)
+		wiphy_counter++;
+
+	mutex_unlock(&cfg80211_drv_mutex);
+
+	if (unlikely(drv->idx < 0)) {
 		/* ugh, wrapped! */
 		kfree(drv);
 		return NULL;
 	}
-	drv->idx = wiphy_counter;
 
 	/* give it a proper name */
 	snprintf(drv->wiphy.dev.bus_id, BUS_ID_SIZE,
 		 PHY_NAME "%d", drv->idx);
 
-	/* now increase counter for the next time */
-	wiphy_counter++;
-	mutex_unlock(&cfg80211_drv_mutex);
-
 	mutex_init(&drv->mtx);
 	mutex_init(&drv->devlist_mtx);
 	INIT_LIST_HEAD(&drv->netdev_list);


