From: Allen Pais <allen.pais@oracle.com>
Subject: [PATCH 1/2] net: bridge: Convert timers to use timer_setup()
Date: Thu,  2 Nov 2017 10:58:50 +0530
Message-ID: <1509600531-16086-1-git-send-email-allen.pais@oracle.com>
Cc: davem@davemloft.net, keescook@chromium.org,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        Allen Pais <allen.pais@oracle.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33242 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdKBF3L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 01:29:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

switch to using the new timer_setup() and from_timer() api's.

Signed-off-by: Allen Pais <allen.pais@oracle.com>
---
 net/bridge/br_multicast.c | 75 +++++++++++++++++++++++------------------------
 1 file changed, 37 insertions(+), 38 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 8dc5c8d..8de4d10 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -239,9 +239,9 @@ static void br_multicast_free_group(struct rcu_head *head)
 	kfree(mp);
 }
 
-static void br_multicast_group_expired(unsigned long data)
+static void br_multicast_group_expired(struct timer_list *t)
 {
-	struct net_bridge_mdb_entry *mp = (void *)data;
+	struct net_bridge_mdb_entry *mp = from_timer(mp, t, timer);
 	struct net_bridge *br = mp->br;
 	struct net_bridge_mdb_htable *mdb;
 
@@ -302,9 +302,9 @@ static void br_multicast_del_pg(struct net_bridge *br,
 	WARN_ON(1);
 }
 
-static void br_multicast_port_group_expired(unsigned long data)
+static void br_multicast_port_group_expired(struct timer_list *t)
 {
-	struct net_bridge_port_group *pg = (void *)data;
+	struct net_bridge_port_group *pg = from_timer(pg, t, timer);
 	struct net_bridge *br = pg->port->br;
 
 	spin_lock(&br->multicast_lock);
@@ -701,8 +701,7 @@ struct net_bridge_mdb_entry *br_multicast_new_group(struct net_bridge *br,
 
 	mp->br = br;
 	mp->addr = *group;
-	setup_timer(&mp->timer, br_multicast_group_expired,
-		    (unsigned long)mp);
+	timer_setup(&mp->timer, br_multicast_group_expired, 0);
 
 	hlist_add_head_rcu(&mp->hlist[mdb->ver], &mdb->mhash[hash]);
 	mdb->size++;
@@ -729,8 +728,7 @@ struct net_bridge_port_group *br_multicast_new_port_group(
 	p->flags = flags;
 	rcu_assign_pointer(p->next, next);
 	hlist_add_head(&p->mglist, &port->mglist);
-	setup_timer(&p->timer, br_multicast_port_group_expired,
-		    (unsigned long)p);
+	timer_setup(&p->timer, br_multicast_port_group_expired, 0);
 
 	if (src)
 		memcpy(p->eth_addr, src, ETH_ALEN);
@@ -843,9 +841,10 @@ static int br_ip6_multicast_add_group(struct net_bridge *br,
 }
 #endif
 
-static void br_multicast_router_expired(unsigned long data)
+static void br_multicast_router_expired(struct timer_list *t)
 {
-	struct net_bridge_port *port = (void *)data;
+	struct net_bridge_port *port =
+			from_timer(port, t, multicast_router_timer);
 	struct net_bridge *br = port->br;
 
 	spin_lock(&br->multicast_lock);
@@ -859,7 +858,7 @@ static void br_multicast_router_expired(unsigned long data)
 	spin_unlock(&br->multicast_lock);
 }
 
-static void br_multicast_local_router_expired(unsigned long data)
+static void br_multicast_local_router_expired(struct timer_list *unused)
 {
 }
 
@@ -876,17 +875,17 @@ static void br_multicast_querier_expired(struct net_bridge *br,
 	spin_unlock(&br->multicast_lock);
 }
 
-static void br_ip4_multicast_querier_expired(unsigned long data)
+static void br_ip4_multicast_querier_expired(struct timer_list *t)
 {
-	struct net_bridge *br = (void *)data;
+	struct net_bridge *br = from_timer(br, t, ip4_other_query.timer);
 
 	br_multicast_querier_expired(br, &br->ip4_own_query);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static void br_ip6_multicast_querier_expired(unsigned long data)
+static void br_ip6_multicast_querier_expired(struct timer_list *t)
 {
-	struct net_bridge *br = (void *)data;
+	struct net_bridge *br = from_timer(br, t, ip6_other_query.timer);
 
 	br_multicast_querier_expired(br, &br->ip6_own_query);
 }
@@ -987,17 +986,17 @@ static void br_multicast_send_query(struct net_bridge *br,
 	spin_unlock(&br->multicast_lock);
 }
 
-static void br_ip4_multicast_port_query_expired(unsigned long data)
+static void br_ip4_multicast_port_query_expired(struct timer_list *t)
 {
-	struct net_bridge_port *port = (void *)data;
+	struct net_bridge_port *port = from_timer(port, t, ip4_own_query.timer);
 
 	br_multicast_port_query_expired(port, &port->ip4_own_query);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static void br_ip6_multicast_port_query_expired(unsigned long data)
+static void br_ip6_multicast_port_query_expired(struct timer_list *t)
 {
-	struct net_bridge_port *port = (void *)data;
+	struct net_bridge_port *port = from_timer(port, t, ip6_own_query.timer);
 
 	br_multicast_port_query_expired(port, &port->ip6_own_query);
 }
@@ -1019,13 +1018,13 @@ int br_multicast_add_port(struct net_bridge_port *port)
 {
 	port->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
 
-	setup_timer(&port->multicast_router_timer, br_multicast_router_expired,
-		    (unsigned long)port);
-	setup_timer(&port->ip4_own_query.timer,
-		    br_ip4_multicast_port_query_expired, (unsigned long)port);
+	timer_setup(&port->multicast_router_timer,
+		    br_multicast_router_expired, 0);
+	timer_setup(&port->ip4_own_query.timer,
+		    br_ip4_multicast_port_query_expired, 0);
 #if IS_ENABLED(CONFIG_IPV6)
-	setup_timer(&port->ip6_own_query.timer,
-		    br_ip6_multicast_port_query_expired, (unsigned long)port);
+	timer_setup(&port->ip6_own_query.timer,
+		    br_ip6_multicast_port_query_expired, 0);
 #endif
 	br_mc_disabled_update(port->dev, port->br->multicast_disabled);
 
@@ -1906,17 +1905,17 @@ static void br_multicast_query_expired(struct net_bridge *br,
 	spin_unlock(&br->multicast_lock);
 }
 
-static void br_ip4_multicast_query_expired(unsigned long data)
+static void br_ip4_multicast_query_expired(struct timer_list *t)
 {
-	struct net_bridge *br = (void *)data;
+	struct net_bridge *br = from_timer(br, t, ip4_own_query.timer);
 
 	br_multicast_query_expired(br, &br->ip4_own_query, &br->ip4_querier);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static void br_ip6_multicast_query_expired(unsigned long data)
+static void br_ip6_multicast_query_expired(struct timer_list *t)
 {
-	struct net_bridge *br = (void *)data;
+	struct net_bridge *br = from_timer(br, t, ip6_own_query.timer);
 
 	br_multicast_query_expired(br, &br->ip6_own_query, &br->ip6_querier);
 }
@@ -1951,17 +1950,17 @@ void br_multicast_init(struct net_bridge *br)
 	br->has_ipv6_addr = 1;
 
 	spin_lock_init(&br->multicast_lock);
-	setup_timer(&br->multicast_router_timer,
+	timer_setup(&br->multicast_router_timer,
 		    br_multicast_local_router_expired, 0);
-	setup_timer(&br->ip4_other_query.timer,
-		    br_ip4_multicast_querier_expired, (unsigned long)br);
-	setup_timer(&br->ip4_own_query.timer, br_ip4_multicast_query_expired,
-		    (unsigned long)br);
+	timer_setup(&br->ip4_other_query.timer,
+		    br_ip4_multicast_querier_expired, 0);
+	timer_setup(&br->ip4_own_query.timer,
+		    br_ip4_multicast_query_expired, 0);
 #if IS_ENABLED(CONFIG_IPV6)
-	setup_timer(&br->ip6_other_query.timer,
-		    br_ip6_multicast_querier_expired, (unsigned long)br);
-	setup_timer(&br->ip6_own_query.timer, br_ip6_multicast_query_expired,
-		    (unsigned long)br);
+	timer_setup(&br->ip6_other_query.timer,
+		    br_ip6_multicast_querier_expired, 0);
+	timer_setup(&br->ip6_own_query.timer,
+		    br_ip6_multicast_query_expired, 0);
 #endif
 }
 
-- 
1.9.1
