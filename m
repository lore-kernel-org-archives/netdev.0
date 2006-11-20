From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 7/13] d80211: add a perm_addr hardware property
Date: Mon, 20 Nov 2006 19:54:08 +0100
Message-ID: <1164048849.9216.38.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163964556.15473.53.camel@johannes.berg>
	 <1163978418.9216.4.camel@johannes.berg>
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:20942 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966435AbWKTSz4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 13:55:56 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163978418.9216.4.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After removing knowledge of the master net_dev from drivers,
they'll still need a way to tell us which MAC address they have.
This is that way, the perm_addr is initially used for all devices.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
resend with the wiphy thing fixed. not sure how that slipped in

--- wireless-dev.orig/include/net/d80211.h	2006-11-20 19:40:04.879598504 +0100
+++ wireless-dev/include/net/d80211.h	2006-11-20 19:40:33.139598504 +0100
@@ -11,6 +11,7 @@
 #define D80211_H
 
 #include <linux/kernel.h>
+#include <linux/if_ether.h>
 #include <linux/skbuff.h>
 #include <linux/wireless.h>
 #include <linux/device.h>
@@ -440,6 +441,9 @@ struct ieee80211_hw {
 
 	struct device *dev;
 
+	/* permanent mac address */
+	u8 perm_addr[ETH_ALEN];
+
 	/* TODO: frame_type 802.11/802.3, sw_encryption requirements */
 
 	/* Some wireless LAN chipsets generate beacons in the hardware/firmware
--- wireless-dev.orig/net/d80211/ieee80211_iface.c	2006-11-20 19:37:14.669598504 +0100
+++ wireless-dev/net/d80211/ieee80211_iface.c	2006-11-20 19:40:33.139598504 +0100
@@ -70,7 +70,7 @@ int ieee80211_if_add(struct net_device *
 		snprintf(ndev->name, IFNAMSIZ, "%s", name);
 	}
 
-	memcpy(ndev->dev_addr, local->mdev->dev_addr, ETH_ALEN);
+	memcpy(ndev->dev_addr, local->hw.perm_addr, ETH_ALEN);
 	ndev->base_addr = dev->base_addr;
 	ndev->irq = dev->irq;
 	ndev->mem_start = dev->mem_start;
@@ -123,7 +123,7 @@ int ieee80211_if_add_mgmt(struct ieee802
 		goto fail;
 
 	ndev->ieee80211_ptr = local;
-	memcpy(ndev->dev_addr, local->mdev->dev_addr, ETH_ALEN);
+	memcpy(ndev->dev_addr, local->hw.perm_addr, ETH_ALEN);
 	SET_NETDEV_DEV(ndev, local->mdev->class_dev.dev);
 
 	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-20 19:37:14.729598504 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-20 19:40:33.149598504 +0100
@@ -4565,6 +4565,7 @@ int ieee80211_register_hw(struct ieee802
 		rtnl_unlock();
 		goto fail_dev;
 	}
+	memcpy(local->mdev->dev_addr, local->hw.perm_addr, ETH_ALEN);
 	result = register_netdevice(local->mdev);
 	if (result < 0) {
 		rtnl_unlock();


