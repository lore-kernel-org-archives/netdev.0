From: Loic Prylli <loicp@google.com>
Subject: [PATCH] net: Fix NETDEV_CHANGE notifier usage causing spurious arp flush
Date: Tue,  1 Jul 2014 21:39:43 -0700
Message-ID: <1404275983-7908-1-git-send-email-loicp@google.com>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>,
	Jiri Pirko <jiri@resnulli.us>, Loic Prylli <loicp@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:59948 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbaGBEkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:40:31 -0400
Received: by mail-oa0-f73.google.com with SMTP id eb12so2453125oac.4
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:40:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bug was introduced in NETDEV_CHANGE notifier sequence causing the
arp table to be sometimes spuriously cleared (including manual arp
entries marked permanent), upon network link carrier changes.

The changed argument for the notifier was applied only to a single
caller of NETDEV_CHANGE, missing among others netdev_state_change().
So upon net_carrier events induced by the network, which are
triggering a call to netdev_state_change(), arp_netdev_event() would
decide whether to clear or not arp cache based on random/junk stack
values (a kind of read buffer overflow).

Fixes: be9efd365328 ("net: pass changed flags along with NETDEV_CHANGE event")
Fixes: 6c8b4e3ff81b ("arp: flush arp cache on IFF_NOARP change")
Signed-off-by: Loic Prylli <loicp@google.com>
---
 net/core/dev.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 30eedf6..63129d4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -148,6 +148,9 @@ struct list_head ptype_all __read_mostly;	/* Taps */
 static struct list_head offload_base __read_mostly;
 
 static int netif_rx_internal(struct sk_buff *skb);
+static int call_netdevice_notifiers_info(unsigned long val,
+					 struct net_device *dev,
+					 struct netdev_notifier_info *info);
 
 /*
  * The @dev_base_head list is protected by @dev_base_lock and the rtnl
@@ -1207,7 +1210,11 @@ EXPORT_SYMBOL(netdev_features_change);
 void netdev_state_change(struct net_device *dev)
 {
 	if (dev->flags & IFF_UP) {
-		call_netdevice_notifiers(NETDEV_CHANGE, dev);
+		struct netdev_notifier_change_info change_info;
+
+		change_info.flags_changed = 0;
+		call_netdevice_notifiers_info(NETDEV_CHANGE, dev,
+					      &change_info.info);
 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 	}
 }
-- 
2.0.0.526.g5318336
