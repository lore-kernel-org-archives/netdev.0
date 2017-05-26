From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/18] bridge: Export multicast enabled state
Date: Fri, 26 May 2017 08:37:24 +0200
Message-ID: <20170526063740.8909-3-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36688 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965861AbdEZGhq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:37:46 -0400
Received: by mail-wm0-f68.google.com with SMTP id k15so1677314wmh.3
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:37:45 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

During enslavement to a bridge, after the CHANGEUPPER is sent, the
multicast enabled state of the bridge isn't propagated down to the
offloading driver unless it's changed.

This patch allows such drivers to query the multicast enabled state from
the bridge, so that they'll be able to correctly configure their flood
tables during port enslavement.

In case multicast is disabled, unregistered multicast packets can be
treated as broadcast and be flooded through all the bridge ports.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/if_bridge.h | 5 +++++
 net/bridge/br_multicast.c | 8 ++++++++
 2 files changed, 13 insertions(+)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index d6cd103..3cd18ac 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -62,6 +62,7 @@ int br_multicast_list_adjacent(struct net_device *dev,
 			       struct list_head *br_ip_list);
 bool br_multicast_has_querier_anywhere(struct net_device *dev, int proto);
 bool br_multicast_has_querier_adjacent(struct net_device *dev, int proto);
+bool br_multicast_enabled(const struct net_device *dev);
 #else
 static inline int br_multicast_list_adjacent(struct net_device *dev,
 					     struct list_head *br_ip_list)
@@ -78,6 +79,10 @@ static inline bool br_multicast_has_querier_adjacent(struct net_device *dev,
 {
 	return false;
 }
+static inline bool br_multicast_enabled(const struct net_device *dev)
+{
+	return false;
+}
 #endif
 
 #if IS_ENABLED(CONFIG_BRIDGE) && IS_ENABLED(CONFIG_BRIDGE_VLAN_FILTERING)
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index faa7261..8dc5c8d 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -2176,6 +2176,14 @@ int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 	return err;
 }
 
+bool br_multicast_enabled(const struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	return !br->multicast_disabled;
+}
+EXPORT_SYMBOL_GPL(br_multicast_enabled);
+
 int br_multicast_set_querier(struct net_bridge *br, unsigned long val)
 {
 	unsigned long max_delay;
-- 
2.9.3
