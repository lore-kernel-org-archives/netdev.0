From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] bridge: Restart queries when last querier expires
Date: Fri, 13 Apr 2012 20:37:42 +0800
Message-ID: <E1SIfl0-0000DS-EK@gondolin.me.apana.org.au>
References: <20120413123641.GA758@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:39715 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752958Ab2DMMho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 08:37:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Restart queries when last querier expires

As it stands when we discover that a real querier (one that queries
with a non-zero source address) we stop querying.  However, even
after said querier has fallen off the edge of the earth, we will
never restart querying (unless the bridge itself is restarted).

This patch fixes this by kicking our own querier into gear when
the timer for other queriers expire.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_multicast.c |   19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index dca0c66..b0796d7 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -36,6 +36,8 @@
 #define mlock_dereference(X, br) \
 	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
 
+static void br_multicast_start_querier(struct net_bridge *br);
+
 #if IS_ENABLED(CONFIG_IPV6)
 static inline int ipv6_is_transient_multicast(const struct in6_addr *addr)
 {
@@ -740,6 +742,21 @@ static void br_multicast_local_router_expired(unsigned long data)
 {
 }
 
+static void br_multicast_querier_expired(unsigned long data)
+{
+	struct net_bridge_port *port = (void *)data;
+	struct net_bridge *br = port->br;
+
+	spin_lock(&br->multicast_lock);
+	if (!netif_running(br->dev) || br->multicast_disabled)
+		goto out;
+
+	br_multicast_start_querier(br);
+
+out:
+	spin_unlock(&br->multicast_lock);
+}
+
 static void __br_multicast_send_query(struct net_bridge *br,
 				      struct net_bridge_port *port,
 				      struct br_ip *ip)
@@ -1562,7 +1579,7 @@ void br_multicast_init(struct net_bridge *br)
 	setup_timer(&br->multicast_router_timer,
 		    br_multicast_local_router_expired, 0);
 	setup_timer(&br->multicast_querier_timer,
-		    br_multicast_local_router_expired, 0);
+		    br_multicast_querier_expired, 0);
 	setup_timer(&br->multicast_query_timer, br_multicast_query_expired,
 		    (unsigned long)br);
 }
