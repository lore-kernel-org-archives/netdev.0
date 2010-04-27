From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] bridge: multicast router list manipulation
Date: Tue, 27 Apr 2010 10:13:11 -0700
Message-ID: <20100427101311.2f445227@nehalam>
References: <20100228054012.GA7583@gondor.apana.org.au>
 <E1NlbuX-00021m-Bq@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43824 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754932Ab0D0RNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 13:13:38 -0400
In-Reply-To: <E1NlbuX-00021m-Bq@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I prefer that the hlist be only accessed through the hlist macro
objects. Explicit twiddling of links (especially with RCU) exposes
the code to future bugs.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/bridge/br_multicast.c	2010-04-27 09:54:02.180531924 -0700
+++ b/net/bridge/br_multicast.c	2010-04-27 10:07:19.188688664 -0700
@@ -1041,21 +1041,21 @@ static int br_ip6_multicast_mld2_report(
 static void br_multicast_add_router(struct net_bridge *br,
 				    struct net_bridge_port *port)
 {
-	struct hlist_node *p;
-	struct hlist_node **h;
+	struct net_bridge_port *p;
+	struct hlist_node *n, *last = NULL;
 
-	for (h = &br->router_list.first;
-	     (p = *h) &&
-	     (unsigned long)container_of(p, struct net_bridge_port, rlist) >
-	     (unsigned long)port;
-	     h = &p->next)
-		;
-
-	port->rlist.pprev = h;
-	port->rlist.next = p;
-	rcu_assign_pointer(*h, &port->rlist);
-	if (p)
-		p->pprev = &port->rlist.next;
+	hlist_for_each_entry(p, n, &br->router_list, rlist) {
+		if ((unsigned long) port >= (unsigned long) p) {
+			hlist_add_before_rcu(n, &port->rlist);
+			return;
+		}
+		last = n;
+	}
+
+	if (last)
+		hlist_add_after_rcu(last, &port->rlist);
+	else
+		hlist_add_head_rcu(&port->rlist, &br->router_list);
 }
 
 static void br_multicast_mark_router(struct net_bridge *br,

