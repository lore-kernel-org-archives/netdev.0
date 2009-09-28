From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 2/2] cfg80211: fix wireless handlers assignment
Date: Mon, 28 Sep 2009 10:21:57 +0200
Message-ID: <1254126117.6583.19.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hugh Dickins <hugh.dickins-IWqWACnzNjwqdlJmJB21zg@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The point we assign dev->wireless_handlers at is too
late, we need to do that before netdev_register_kobject()
gets called, so use the new NETDEV_PRE_INIT notifier.
The result of adding wireless_handlers too late is the
disappearance of /sys/class/net/wlan0/wireless which a
bunch of distro scripts still require.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 net/wireless/core.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

--- wireless-testing.orig/net/wireless/core.c	2009-09-28 09:54:52.000000000 +0200
+++ wireless-testing/net/wireless/core.c	2009-09-28 10:18:47.000000000 +0200
@@ -641,6 +641,12 @@ static int cfg80211_netdev_notifier_call
 	WARN_ON(wdev->iftype == NL80211_IFTYPE_UNSPECIFIED);
 
 	switch (state) {
+	case NETDEV_POST_INIT:
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


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
