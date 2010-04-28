From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/4] bridge: simplify multicast_add_router
Date: Tue, 27 Apr 2010 18:01:04 -0700
Message-ID: <20100428010336.068072153@vyatta.com>
References: <20100428010103.386761596@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46579 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754248Ab0D1BGw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 21:06:52 -0400
Content-Disposition: inline; filename=br-mcast-list2.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By coding slightly differently, there are only two cases
to deal with: add at head and add after previous entry.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_multicast.c	2010-04-27 17:02:06.720839467 -0700
+++ b/net/bridge/br_multicast.c	2010-04-27 17:11:06.518933878 -0700
@@ -1039,22 +1039,25 @@ static int br_ip6_multicast_mld2_report(
 }
 #endif
 
+/*
+ * Add port to rotuer_list
+ *  list is maintained ordered by pointer value
+ *  and locked by br->multicast_lock and RCU
+ */
 static void br_multicast_add_router(struct net_bridge *br,
 				    struct net_bridge_port *port)
 {
 	struct net_bridge_port *p;
-	struct hlist_node *n, *last = NULL;
+	struct hlist_node *n, *slot = NULL;
 
 	hlist_for_each_entry(p, n, &br->router_list, rlist) {
-		if ((unsigned long) port >= (unsigned long) p) {
-			hlist_add_before_rcu(n, &port->rlist);
-			return;
-		}
-		last = n;
+		if ((unsigned long) port >= (unsigned long) p)
+			break;
+		slot = n;
 	}
 
-	if (last)
-		hlist_add_after_rcu(last, &port->rlist);
+	if (slot)
+		hlist_add_after_rcu(slot, &port->rlist);
 	else
 		hlist_add_head_rcu(&port->rlist, &br->router_list);
 }

-- 

