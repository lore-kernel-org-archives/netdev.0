From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/6] net: bridge: Export bridge multicast router state
Date: Thu,  5 Oct 2017 12:36:39 +0200
Message-ID: <20171005103642.1414-4-jiri@resnulli.us>
References: <20171005103642.1414-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:44678 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751702AbdJEKgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:36:52 -0400
Received: by mail-wm0-f65.google.com with SMTP id 196so1223132wma.1
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 03:36:51 -0700 (PDT)
In-Reply-To: <20171005103642.1414-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Add an access function that, given a bridge netdevice, returns whether the
bridge device is currently an mrouter or not. The function uses the already
existing br_multicast_is_router function to check that.

This function is needed in order to allow ports that join an already
existing bridge to know the current mrouter state of the bridge device.
Together with the bridge device mrouter ports switchdev notifications, it
is possible to have full offloading of the semantics of the bridge device
mcast router state.

Due to the fact that the bridge multicast router status can change in
packet RX path, take the multicast_router bridge spinlock to protect the
read.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/if_bridge.h |  5 +++++
 net/bridge/br_multicast.c | 12 ++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 3cd18ac..283a9be 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -63,6 +63,7 @@ int br_multicast_list_adjacent(struct net_device *dev,
 bool br_multicast_has_querier_anywhere(struct net_device *dev, int proto);
 bool br_multicast_has_querier_adjacent(struct net_device *dev, int proto);
 bool br_multicast_enabled(const struct net_device *dev);
+bool br_multicast_router(const struct net_device *dev);
 #else
 static inline int br_multicast_list_adjacent(struct net_device *dev,
 					     struct list_head *br_ip_list)
@@ -83,6 +84,10 @@ static inline bool br_multicast_enabled(const struct net_device *dev)
 {
 	return false;
 }
+static inline bool br_multicast_router(const struct net_device *dev)
+{
+	return false;
+}
 #endif
 
 #if IS_ENABLED(CONFIG_BRIDGE) && IS_ENABLED(CONFIG_BRIDGE_VLAN_FILTERING)
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 4d4fcb5..b4c98a3 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -2220,6 +2220,18 @@ bool br_multicast_enabled(const struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(br_multicast_enabled);
 
+bool br_multicast_router(const struct net_device *dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	bool is_router;
+
+	spin_lock_bh(&br->multicast_lock);
+	is_router = br_multicast_is_router(br);
+	spin_unlock_bh(&br->multicast_lock);
+	return is_router;
+}
+EXPORT_SYMBOL_GPL(br_multicast_router);
+
 int br_multicast_set_querier(struct net_bridge *br, unsigned long val)
 {
 	unsigned long max_delay;
-- 
2.9.5
