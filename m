From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 1/2] net: introduce NETDEV_POST_INIT notifier
Date: Mon, 28 Sep 2009 10:21:29 +0200
Message-ID: <1254126089.6583.18.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Hugh Dickins <hugh.dickins@tiscali.co.uk>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40160 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbZI1IV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 04:21:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For various purposes including a wireless extensions
bugfix, we need to hook into the netdev creation before
before netdev_register_kobject(). This will also ease
doing the dev type assignment that Marcel was working
on for cfg80211 drivers w/o touching them all.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
I decided that it doesn't make a lot of sense to be after ndo_init but
before the other name/... checks.

 include/linux/notifier.h |    1 +
 net/core/dev.c           |    5 +++++
 2 files changed, 6 insertions(+)

--- wireless-testing.orig/include/linux/notifier.h	2009-09-28 10:14:54.000000000 +0200
+++ wireless-testing/include/linux/notifier.h	2009-09-28 10:16:07.000000000 +0200
@@ -201,6 +201,7 @@ static inline int notifier_to_errno(int 
 #define NETDEV_PRE_UP		0x000D
 #define NETDEV_BONDING_OLDTYPE  0x000E
 #define NETDEV_BONDING_NEWTYPE  0x000F
+#define NETDEV_POST_INIT	0x0010
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
--- wireless-testing.orig/net/core/dev.c	2009-09-28 10:14:54.000000000 +0200
+++ wireless-testing/net/core/dev.c	2009-09-28 10:20:46.000000000 +0200
@@ -4785,6 +4785,11 @@ int register_netdevice(struct net_device
 	if (dev->features & NETIF_F_SG)
 		dev->features |= NETIF_F_GSO;
 
+	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
+	ret = notifier_to_errno(ret);
+	if (ret)
+		goto err_uninit;
+
 	netdev_initialize_kobject(dev);
 	ret = netdev_register_kobject(dev);
 	if (ret)


