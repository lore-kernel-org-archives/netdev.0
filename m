From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] d80211: use ieee80211_hw.dev
Date: Tue, 21 Nov 2006 18:48:40 +0100
Message-ID: <1164131320.3631.3.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163964522.15473.52.camel@johannes.berg>
	 <1164062740.8981.3.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:31905 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966969AbWKURul
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 12:50:41 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1164062740.8981.3.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes up my earlier patches by actually using the dev field in
struct ieee80211_hw.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---

Jiri, please apply. This is a fix and restores the behaviour we had
before when drivers did SET_NETDEV_DEV on the master device.

I think it might make sense to actually point the device link from
virtual interfaces to the wiphy instead of the actual device. I know we
have a wiphy link but now all userspace must be updated to check for
wiphy links, and I'd expect userspace to follow the device links until
it comes to a sink in the device graph if it wants the actual physical
device... so having the device link point to the wiphy would make the
hierarchical relation clear.

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-21 18:15:33.649658585 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-21 18:20:04.159658585 +0100
@@ -4561,7 +4561,10 @@ int ieee80211_register_hw(struct ieee802
 		rtnl_unlock();
 		goto fail_dev;
 	}
+
 	memcpy(local->mdev->dev_addr, local->hw.perm_addr, ETH_ALEN);
+	SET_NETDEV_DEV(local->mdev, local->hw.dev);
+
 	result = register_netdevice(local->mdev);
 	if (result < 0) {
 		rtnl_unlock();
--- wireless-dev.orig/net/d80211/ieee80211_iface.c	2006-11-21 18:14:39.999658585 +0100
+++ wireless-dev/net/d80211/ieee80211_iface.c	2006-11-21 18:19:52.499658585 +0100
@@ -76,7 +76,7 @@ int ieee80211_if_add(struct net_device *
 	ndev->mem_start = dev->mem_start;
 	ndev->mem_end = dev->mem_end;
 	ndev->flags = dev->flags & IFF_MULTICAST;
-	SET_NETDEV_DEV(ndev, dev->class_dev.dev);
+	SET_NETDEV_DEV(ndev, local->hw.dev);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	sdata->type = IEEE80211_IF_TYPE_AP;
@@ -124,7 +124,7 @@ int ieee80211_if_add_mgmt(struct ieee802
 
 	ndev->ieee80211_ptr = local;
 	memcpy(ndev->dev_addr, local->hw.perm_addr, ETH_ALEN);
-	SET_NETDEV_DEV(ndev, local->mdev->class_dev.dev);
+	SET_NETDEV_DEV(ndev, local->hw.dev);
 
 	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	nsdata->type = IEEE80211_IF_TYPE_MGMT;


