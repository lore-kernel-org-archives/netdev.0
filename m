From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH v2] mac80211: STA reassociation improvements
Date: Sun, 15 Jul 2007 15:02:51 +0100 (BST)
Message-ID: <20070715140251.B4F6B7B409F@zog.reactivated.net>
Cc: linville@tuxdriver.com
To: jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:58867 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755702AbXGOOCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 10:02:55 -0400
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My cheapy D-Link AP behaves strangely w.r.t reassociations.

The following sequence of commands causes me to lose association and to be
unable to regain it:

	ifconfig eth8 down
	ifconfig eth8 up
	iwconfig eth8 essid <x>

This is because mac80211 tries to reassociate, rather than just associate.
My AP replies with an association response (not a reassociation response...)
denying the association with code 12: "Association denied due to reason
outside the scope of this standard"

mac80211 tries this reassociation another 4 times or so before finally giving
up.

I see 2 problems here:
 1. bringing the interface down and up again should be resetting interface state
    i.e. after the interface is brought down, it should have no memory of if or
         where it was previously associated
 2. after the first reassociation fails, mac80211 should fall back to
    standard association for the next attempt

Signed-off-by: Daniel Drake <dsd@gentoo.org>

---
Changes since first submission: created ieee80211_if_open and moved state
resetting to there, and clarified reasoning for retrying with a full
association as requested by Jiri Benc.

Index: wireless-dev/net/mac80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/mac80211/ieee80211.c
+++ wireless-dev/net/mac80211/ieee80211.c
@@ -2277,6 +2277,18 @@ static struct net_device_stats *ieee8021
 	return &(sdata->stats);
 }
 
+static void ieee80211_if_open(struct net_device *dev)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	switch (sdata->type) {
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_IBSS:
+		sdata->u.sta.prev_bssid_set = 0;
+		break;
+	}
+}
+
 static void ieee80211_if_shutdown(struct net_device *dev)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
@@ -2426,6 +2438,7 @@ static int ieee80211_open(struct net_dev
 		local->hw.conf.flags |= IEEE80211_CONF_RADIOTAP;
 		return 0;
 	}
+	ieee80211_if_open(dev);
 	ieee80211_start_soft_monitor(local);
 
 	if (local->ops->add_interface) {
Index: wireless-dev/net/mac80211/ieee80211_sta.c
===================================================================
--- wireless-dev.orig/net/mac80211/ieee80211_sta.c
+++ wireless-dev/net/mac80211/ieee80211_sta.c
@@ -1605,8 +1605,10 @@ static void ieee80211_rx_mgmt_assoc_resp
 	if (status_code != WLAN_STATUS_SUCCESS) {
 		printk(KERN_DEBUG "%s: AP denied association (code=%d)\n",
 		       dev->name, status_code);
-		if (status_code == WLAN_STATUS_REASSOC_NO_ASSOC)
-			ifsta->prev_bssid_set = 0;
+		/* if this was a reassociation, ensure we try a "full"
+		 * association next time. This works around some broken APs
+		 * which do not correctly reject reassociation requests. */
+		ifsta->prev_bssid_set = 0;
 		return;
 	}
 
