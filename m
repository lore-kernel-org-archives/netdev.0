From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/10] switchdev: bridge: Offload multicast disabled
Date: Thu,  9 Feb 2017 14:54:40 +0100
Message-ID: <1486648489-16455-2-git-send-email-jiri@resnulli.us>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35059 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752631AbdBIO5Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:57:16 -0500
Received: by mail-wm0-f65.google.com with SMTP id u63so3260616wmu.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:57:15 -0800 (PST)
In-Reply-To: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Offload multicast disabled flag, for more accurate mc flood behavior:
When it is on, the mdb should be ignored.
When it is off, unregistered mc packets should be flooded to mc router
ports.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   |  2 ++
 net/bridge/br_multicast.c | 16 ++++++++++++++++
 2 files changed, 18 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index eba80c4..2971c2a 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -48,6 +48,7 @@ enum switchdev_attr_id {
 	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
 	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
 	SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
+	SWITCHDEV_ATTR_ID_BRIDGE_MC_DISABLED,
 };
 
 struct switchdev_attr {
@@ -62,6 +63,7 @@ struct switchdev_attr {
 		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
 		clock_t ageing_time;			/* BRIDGE_AGEING_TIME */
 		bool vlan_filtering;			/* BRIDGE_VLAN_FILTERING */
+		bool mc_disabled;			/* MC_DISABLED */
 	} u;
 };
 
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 1de3438..8c0e896 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -27,6 +27,7 @@
 #include <linux/inetdevice.h>
 #include <linux/mroute.h>
 #include <net/ip.h>
+#include <net/switchdev.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
 #include <net/mld.h>
@@ -1007,6 +1008,18 @@ static void br_ip6_multicast_port_query_expired(unsigned long data)
 }
 #endif
 
+static void br_mc_disabled_update(struct net_device *dev, bool value)
+{
+	struct switchdev_attr attr = {
+		.orig_dev = dev,
+		.id = SWITCHDEV_ATTR_ID_BRIDGE_MC_DISABLED,
+		.flags = SWITCHDEV_F_DEFER,
+		.u.mc_disabled = value,
+	};
+
+	switchdev_port_attr_set(dev, &attr);
+}
+
 int br_multicast_add_port(struct net_bridge_port *port)
 {
 	port->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
@@ -1019,6 +1032,8 @@ int br_multicast_add_port(struct net_bridge_port *port)
 	setup_timer(&port->ip6_own_query.timer,
 		    br_ip6_multicast_port_query_expired, (unsigned long)port);
 #endif
+	br_mc_disabled_update(port->dev, port->br->multicast_disabled);
+
 	port->mcast_stats = netdev_alloc_pcpu_stats(struct bridge_mcast_stats);
 	if (!port->mcast_stats)
 		return -ENOMEM;
@@ -2121,6 +2136,7 @@ int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 	if (br->multicast_disabled == !val)
 		goto unlock;
 
+	br_mc_disabled_update(br->dev, !val);
 	br->multicast_disabled = !val;
 	if (br->multicast_disabled)
 		goto unlock;
-- 
2.7.4
