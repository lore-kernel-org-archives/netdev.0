From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH RFC net-next 1/4] bridge: modify bridge and port to have often accessed fields in one cache line
Date: Tue, 31 Jan 2017 16:31:55 +0100
Message-ID: <1485876718-18091-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f177.google.com ([209.85.210.177]:34423 "EHLO
        mail-wj0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdAaPcX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 10:32:23 -0500
Received: by mail-wj0-f177.google.com with SMTP id uo9so15808283wjc.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 07:32:22 -0800 (PST)
In-Reply-To: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move around net_bridge so the vlan fields are in the beginning since
they're checked on every packet even if vlan filtering is disabled.
Also move topology_change in the same cache line with ageing_time and
forward_delay as they're all checked in br_fdb_update on each packet rx.
For the port move flags & vlan group to the beginning, so they're in the
same cache line with the port's state (both flags and state are checked
on each packet).

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_private.h | 43 ++++++++++++++++++++-----------------------
 1 file changed, 20 insertions(+), 23 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0b82a227fc34..d3be859a6346 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -202,12 +202,16 @@ struct net_bridge_mdb_htable
 	u32				ver;
 };
 
-struct net_bridge_port
-{
+struct net_bridge_port {
 	struct net_bridge		*br;
 	struct net_device		*dev;
 	struct list_head		list;
 
+	unsigned long			flags;
+#ifdef CONFIG_BRIDGE_VLAN_FILTERING
+	struct net_bridge_vlan_group	__rcu *vlgrp;
+#endif
+
 	/* STP */
 	u8				priority;
 	u8				state;
@@ -228,8 +232,6 @@ struct net_bridge_port
 	struct kobject			kobj;
 	struct rcu_head			rcu;
 
-	unsigned long 			flags;
-
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	struct bridge_mcast_own_query	ip4_own_query;
 #if IS_ENABLED(CONFIG_IPV6)
@@ -249,9 +251,6 @@ struct net_bridge_port
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll			*np;
 #endif
-#ifdef CONFIG_BRIDGE_VLAN_FILTERING
-	struct net_bridge_vlan_group	__rcu *vlgrp;
-#endif
 #ifdef CONFIG_NET_SWITCHDEV
 	int				offload_fwd_mark;
 #endif
@@ -273,14 +272,21 @@ static inline struct net_bridge_port *br_port_get_rtnl(const struct net_device *
 		rtnl_dereference(dev->rx_handler_data) : NULL;
 }
 
-struct net_bridge
-{
+struct net_bridge {
 	spinlock_t			lock;
+	spinlock_t			hash_lock;
 	struct list_head		port_list;
 	struct net_device		*dev;
-
 	struct pcpu_sw_netstats		__percpu *stats;
-	spinlock_t			hash_lock;
+	/* These fields are accessed on each packet */
+#ifdef CONFIG_BRIDGE_VLAN_FILTERING
+	u8				vlan_enabled;
+	u8				vlan_stats_enabled;
+	__be16				vlan_proto;
+	u16				default_pvid;
+	struct net_bridge_vlan_group	__rcu *vlgrp;
+#endif
+
 	struct hlist_head		hash[BR_HASH_SIZE];
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	union {
@@ -298,6 +304,9 @@ struct net_bridge
 	bridge_id			designated_root;
 	bridge_id			bridge_id;
 	u32				root_path_cost;
+	unsigned char			topology_change;
+	unsigned char			topology_change_detected;
+	u16				root_port;
 	unsigned long			max_age;
 	unsigned long			hello_time;
 	unsigned long			forward_delay;
@@ -309,7 +318,6 @@ struct net_bridge
 
 	u8				group_addr[ETH_ALEN];
 	bool				group_addr_set;
-	u16				root_port;
 
 	enum {
 		BR_NO_STP, 		/* no spanning tree */
@@ -317,9 +325,6 @@ struct net_bridge
 		BR_USER_STP,		/* new RSTP in userspace */
 	} stp_enabled;
 
-	unsigned char			topology_change;
-	unsigned char			topology_change_detected;
-
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	unsigned char			multicast_router;
 
@@ -371,14 +376,6 @@ struct net_bridge
 #ifdef CONFIG_NET_SWITCHDEV
 	int offload_fwd_mark;
 #endif
-
-#ifdef CONFIG_BRIDGE_VLAN_FILTERING
-	struct net_bridge_vlan_group	__rcu *vlgrp;
-	u8				vlan_enabled;
-	u8				vlan_stats_enabled;
-	__be16				vlan_proto;
-	u16				default_pvid;
-#endif
 };
 
 struct br_input_skb_cb {
-- 
2.1.4
