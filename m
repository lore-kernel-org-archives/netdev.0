From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 3/4] net: introduce NETDEV_POST_INIT notifier
Date: Fri,  2 Oct 2009 17:15:27 +0200
Message-ID: <21e0ecd67498ddd64add62973a497b8eeb658254.1254495724.git.marcel@holtmann.org>
References: <cover.1254495724.git.marcel@holtmann.org>
 <ff8a6da2784c27455e9666469ec95d84a1e00fd4.1254495724.git.marcel@holtmann.org>
 <45ca9f6130993f8f935f98a99b83ebc7ae7c116d.1254495724.git.marcel@holtmann.org>
Cc: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33428 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175AbZJBPP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 11:15:56 -0400
In-Reply-To: <45ca9f6130993f8f935f98a99b83ebc7ae7c116d.1254495724.git.marcel@holtmann.org>
In-Reply-To: <cover.1254495724.git.marcel@holtmann.org>
References: <cover.1254495724.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>

For various purposes including a wireless extensions
bugfix, we need to hook into the netdev creation before
before netdev_register_kobject(). This will also ease
doing the dev type assignment that Marcel was working
on for cfg80211 drivers w/o touching them all.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/linux/notifier.h |    1 +
 net/core/dev.c           |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index 44428d2..29714b8 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -201,6 +201,7 @@ static inline int notifier_to_errno(int ret)
 #define NETDEV_PRE_UP		0x000D
 #define NETDEV_BONDING_OLDTYPE  0x000E
 #define NETDEV_BONDING_NEWTYPE  0x000F
+#define NETDEV_POST_INIT	0x0010
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
diff --git a/net/core/dev.c b/net/core/dev.c
index b8f74cf..a74c8fd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4836,6 +4836,12 @@ int register_netdevice(struct net_device *dev)
 		dev->features |= NETIF_F_GSO;
 
 	netdev_initialize_kobject(dev);
+
+	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
+	ret = notifier_to_errno(ret);
+	if (ret)
+		goto err_uninit;
+
 	ret = netdev_register_kobject(dev);
 	if (ret)
 		goto err_uninit;
-- 
1.6.2.5

