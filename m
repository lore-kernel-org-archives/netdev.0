From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/2] cfg80211: fix wireless handlers assignment
Date: Sun, 27 Sep 2009 20:27:55 +0200
Message-ID: <1254076075.6583.6.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Hugh Dickins <hugh.dickins@tiscali.co.uk>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40784 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbZI0S1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2009 14:27:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The point we assign dev->wireless_handlers at is too
late, we need to do that before netdev_register_kobject()
gets called, so use the new NETDEV_PRE_INIT notifier.
The result of adding wireless_handlers too late is the
disappearance of /sys/class/net/wlan0/wireless which a
bunch of distro scripts still require.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
This should fix the regression Hugh reported (of course requires the
other patch which unfortunately I forgot to CC you, Hugh, I'll send you
a copy in private).

 net/wireless/core.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

--- wireless-testing.orig/net/wireless/core.c	2009-09-27 15:12:20.000000000 +0200
+++ wireless-testing/net/wireless/core.c	2009-09-27 15:12:54.000000000 +0200
@@ -641,6 +641,12 @@ static int cfg80211_netdev_notifier_call
 	WARN_ON(wdev->iftype == NL80211_IFTYPE_UNSPECIFIED);
 
 	switch (state) {
+	case NETDEV_PRE_INIT:
+#ifdef CONFIG_WIRELESS_EXT
+		if (!dev->wireless_handlers)
+			dev->wireless_handlers = &cfg80211_wext_handler;
+#endif
+		break;
 	case NETDEV_REGISTER:
 		/*
 		 * NB: cannot take rdev->mtx here because this may be
@@ -666,8 +672,6 @@ static int cfg80211_netdev_notifier_call
 		wdev->sme_state = CFG80211_SME_IDLE;
 		mutex_unlock(&rdev->devlist_mtx);
 #ifdef CONFIG_WIRELESS_EXT
-		if (!dev->wireless_handlers)
-			dev->wireless_handlers = &cfg80211_wext_handler;
 		wdev->wext.default_key = -1;
 		wdev->wext.default_mgmt_key = -1;
 		wdev->wext.connect.auth_type = NL80211_AUTHTYPE_AUTOMATIC;


