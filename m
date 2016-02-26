From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 1/3] bridge: mcast: use names for the different multicast_router types
Date: Fri, 26 Feb 2016 19:59:24 +0100
Message-ID: <1456513166-20159-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1456513166-20159-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36607 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932737AbcBZS7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 13:59:37 -0500
Received: by mail-wm0-f50.google.com with SMTP id g62so85518737wme.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 10:59:36 -0800 (PST)
In-Reply-To: <1456513166-20159-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using raw values makes it difficult to extend and also understand the
code, give them names and do explicit per-option manipulation in
br_multicast_set_port_router.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_bridge.h |  7 +++++
 net/bridge/br_multicast.c      | 59 ++++++++++++++++++++++--------------------
 2 files changed, 38 insertions(+), 28 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 610932b477c4..f2764b739f38 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -194,6 +194,13 @@ enum {
 };
 #define MDBA_MDB_EATTR_MAX (__MDBA_MDB_EATTR_MAX - 1)
 
+/* multicast router types */
+enum {
+	MDB_RTR_TYPE_DISABLED,
+	MDB_RTR_TYPE_TEMP_QUERY,
+	MDB_RTR_TYPE_PERM,
+};
+
 enum {
 	MDBA_ROUTER_UNSPEC,
 	MDBA_ROUTER_PORT,
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 8b6e4249be1b..015c47dd1364 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -759,7 +759,7 @@ static void br_multicast_router_expired(unsigned long data)
 	struct net_bridge *br = port->br;
 
 	spin_lock(&br->multicast_lock);
-	if (port->multicast_router != 1 ||
+	if (port->multicast_router != MDB_RTR_TYPE_TEMP_QUERY ||
 	    timer_pending(&port->multicast_router_timer) ||
 	    hlist_unhashed(&port->rlist))
 		goto out;
@@ -912,7 +912,7 @@ static void br_ip6_multicast_port_query_expired(unsigned long data)
 
 void br_multicast_add_port(struct net_bridge_port *port)
 {
-	port->multicast_router = 1;
+	port->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
 
 	setup_timer(&port->multicast_router_timer, br_multicast_router_expired,
 		    (unsigned long)port);
@@ -959,7 +959,8 @@ void br_multicast_enable_port(struct net_bridge_port *port)
 #if IS_ENABLED(CONFIG_IPV6)
 	br_multicast_enable(&port->ip6_own_query);
 #endif
-	if (port->multicast_router == 2 && hlist_unhashed(&port->rlist))
+	if (port->multicast_router == MDB_RTR_TYPE_PERM &&
+	    hlist_unhashed(&port->rlist))
 		br_multicast_add_router(br, port);
 
 out:
@@ -1227,13 +1228,13 @@ static void br_multicast_mark_router(struct net_bridge *br,
 	unsigned long now = jiffies;
 
 	if (!port) {
-		if (br->multicast_router == 1)
+		if (br->multicast_router == MDB_RTR_TYPE_TEMP_QUERY)
 			mod_timer(&br->multicast_router_timer,
 				  now + br->multicast_querier_interval);
 		return;
 	}
 
-	if (port->multicast_router != 1)
+	if (port->multicast_router != MDB_RTR_TYPE_TEMP_QUERY)
 		return;
 
 	br_multicast_add_router(br, port);
@@ -1713,7 +1714,7 @@ void br_multicast_init(struct net_bridge *br)
 	br->hash_elasticity = 4;
 	br->hash_max = 512;
 
-	br->multicast_router = 1;
+	br->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
 	br->multicast_querier = 0;
 	br->multicast_query_use_ifaddr = 0;
 	br->multicast_last_member_count = 2;
@@ -1823,11 +1824,11 @@ int br_multicast_set_router(struct net_bridge *br, unsigned long val)
 	spin_lock_bh(&br->multicast_lock);
 
 	switch (val) {
-	case 0:
-	case 2:
+	case MDB_RTR_TYPE_DISABLED:
+	case MDB_RTR_TYPE_PERM:
 		del_timer(&br->multicast_router_timer);
 		/* fall through */
-	case 1:
+	case MDB_RTR_TYPE_TEMP_QUERY:
 		br->multicast_router = val;
 		err = 0;
 		break;
@@ -1838,6 +1839,14 @@ int br_multicast_set_router(struct net_bridge *br, unsigned long val)
 	return err;
 }
 
+static void __del_port_router(struct net_bridge_port *p)
+{
+	if (hlist_unhashed(&p->rlist))
+		return;
+	hlist_del_init_rcu(&p->rlist);
+	br_rtr_notify(p->br->dev, p, RTM_DELMDB);
+}
+
 int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val)
 {
 	struct net_bridge *br = p->br;
@@ -1846,29 +1855,23 @@ int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val)
 	spin_lock(&br->multicast_lock);
 
 	switch (val) {
-	case 0:
-	case 1:
-	case 2:
-		p->multicast_router = val;
-		err = 0;
-
-		if (val < 2 && !hlist_unhashed(&p->rlist)) {
-			hlist_del_init_rcu(&p->rlist);
-			br_rtr_notify(br->dev, p, RTM_DELMDB);
-		}
-
-		if (val == 1)
-			break;
-
+	case MDB_RTR_TYPE_DISABLED:
+		__del_port_router(p);
+		del_timer(&p->multicast_router_timer);
+		break;
+	case MDB_RTR_TYPE_TEMP_QUERY:
+		__del_port_router(p);
+		break;
+	case MDB_RTR_TYPE_PERM:
 		del_timer(&p->multicast_router_timer);
-
-		if (val == 0)
-			break;
-
 		br_multicast_add_router(br, p);
 		break;
+	default:
+		goto unlock;
 	}
-
+	p->multicast_router = val;
+	err = 0;
+unlock:
 	spin_unlock(&br->multicast_lock);
 
 	return err;
-- 
2.4.3
