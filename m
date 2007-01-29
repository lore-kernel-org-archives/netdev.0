From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 6/6] d80211: fix rtnl locking in ieee80211_register_hw
Date: Mon, 29 Jan 2007 18:48:11 +0100 (CET)
Message-ID: <20070129174811.753724849D@silver.suse.cz>
References: <20070129184707.885764375.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41736 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752533AbXA2Rr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 12:47:59 -0500
In-Reply-To: <20070129184707.885764375.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtnl locking in ieee80211_register_hw was racy. This patch fixes that.

Unfortunatelly, the creation of master interface has to be still protected
by rtnl lock as we need to protect against addition of a new virtual
interface.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211.c |    4 +---
 1 files changed, 1 insertion(+), 3 deletions(-)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -4540,12 +4540,10 @@ int ieee80211_register_hw(struct ieee802
 
 	result = register_invisible_netdevice(local->mdev);
 	if (result < 0) {
-		rtnl_unlock();
 		goto fail_dev;
 	}
 
 	result = ieee80211_init_rate_ctrl_alg(local, NULL);
-	rtnl_unlock();
 	if (result < 0) {
 		printk(KERN_DEBUG "wiphy%d: Failed to initialize rate control "
 		       "algorithm\n", local->hw.index);
@@ -4564,7 +4562,6 @@ int ieee80211_register_hw(struct ieee802
 	ieee80211_install_qdisc(local->mdev);
 
 	/* add one default STA interface */
-	rtnl_lock();
 	result = ieee80211_if_add(local->mdev, "wlan%d", 1, &sta_dev);
 	if (result == 0)
 		ieee80211_if_set_type(sta_dev, IEEE80211_IF_TYPE_STA);
@@ -4581,6 +4578,7 @@ fail_wep:
 fail_rate:
 	unregister_invisible_netdevice(local->mdev);
 fail_dev:
+	rtnl_unlock();
 	sta_info_stop(local);
 fail_sta_info:
 	ieee80211_dev_sysfs_del(local);
