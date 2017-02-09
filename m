From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/10] bridge: mcast: Merge the mc router ports deletions to one function
Date: Thu,  9 Feb 2017 14:54:41 +0100
Message-ID: <1486648489-16455-3-git-send-email-jiri@resnulli.us>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35855 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753143AbdBIO0F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:26:05 -0500
Received: by mail-wm0-f67.google.com with SMTP id r18so3128661wmd.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:26:04 -0800 (PST)
In-Reply-To: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

There are three places where a port gets deleted from the mc router port
list. This patch join the actual deletion to one function.
It will be helpful for later patch that will offload changes in the mc
router ports list.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_multicast.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 8c0e896..2add6d4 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -47,6 +47,7 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 					 __u16 vid,
 					 const unsigned char *src);
 
+static void __del_port_router(struct net_bridge_port *p);
 #if IS_ENABLED(CONFIG_IPV6)
 static void br_ip6_multicast_leave_group(struct net_bridge *br,
 					 struct net_bridge_port *port,
@@ -850,16 +851,10 @@ static void br_multicast_router_expired(unsigned long data)
 	spin_lock(&br->multicast_lock);
 	if (port->multicast_router == MDB_RTR_TYPE_DISABLED ||
 	    port->multicast_router == MDB_RTR_TYPE_PERM ||
-	    timer_pending(&port->multicast_router_timer) ||
-	    hlist_unhashed(&port->rlist))
+	    timer_pending(&port->multicast_router_timer))
 		goto out;
 
-	hlist_del_init_rcu(&port->rlist);
-	br_rtr_notify(br->dev, port, RTM_DELMDB);
-	/* Don't allow timer refresh if the router expired */
-	if (port->multicast_router == MDB_RTR_TYPE_TEMP)
-		port->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
-
+	__del_port_router(port);
 out:
 	spin_unlock(&br->multicast_lock);
 }
@@ -1101,13 +1096,8 @@ void br_multicast_disable_port(struct net_bridge_port *port)
 		if (!(pg->flags & MDB_PG_FLAGS_PERMANENT))
 			br_multicast_del_pg(br, pg);
 
-	if (!hlist_unhashed(&port->rlist)) {
-		hlist_del_init_rcu(&port->rlist);
-		br_rtr_notify(br->dev, port, RTM_DELMDB);
-		/* Don't allow timer refresh if disabling */
-		if (port->multicast_router == MDB_RTR_TYPE_TEMP)
-			port->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
-	}
+	__del_port_router(port);
+
 	del_timer(&port->multicast_router_timer);
 	del_timer(&port->ip4_own_query.timer);
 #if IS_ENABLED(CONFIG_IPV6)
@@ -2059,6 +2049,10 @@ static void __del_port_router(struct net_bridge_port *p)
 		return;
 	hlist_del_init_rcu(&p->rlist);
 	br_rtr_notify(p->br->dev, p, RTM_DELMDB);
+
+	/* don't allow timer refresh */
+	if (p->multicast_router == MDB_RTR_TYPE_TEMP)
+		p->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
 }
 
 int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val)
-- 
2.7.4
