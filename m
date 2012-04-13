From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/3] bridge: Add br_multicast_start_querier
Date: Fri, 13 Apr 2012 20:37:42 +0800
Message-ID: <E1SIfl0-0000DO-5v@gondolin.me.apana.org.au>
References: <20120413123641.GA758@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:56083 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752899Ab2DMMho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 08:37:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Add br_multicast_start_querier

This patch adds the helper br_multicast_start_querier so that
the code which starts the queriers in br_multicast_toggle can
be reused elsewhere.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_multicast.c |   25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 27ca25e..dca0c66 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1689,9 +1689,23 @@ unlock:
 	return err;
 }
 
-int br_multicast_toggle(struct net_bridge *br, unsigned long val)
+static void br_multicast_start_querier(struct net_bridge *br)
 {
 	struct net_bridge_port *port;
+
+	br_multicast_open(br);
+
+	list_for_each_entry(port, &br->port_list, list) {
+		if (port->state == BR_STATE_DISABLED ||
+		    port->state == BR_STATE_BLOCKING)
+			continue;
+
+		__br_multicast_enable_port(port);
+	}
+}
+
+int br_multicast_toggle(struct net_bridge *br, unsigned long val)
+{
 	int err = 0;
 	struct net_bridge_mdb_htable *mdb;
 
@@ -1721,14 +1735,7 @@ rollback:
 			goto rollback;
 	}
 
-	br_multicast_open(br);
-	list_for_each_entry(port, &br->port_list, list) {
-		if (port->state == BR_STATE_DISABLED ||
-		    port->state == BR_STATE_BLOCKING)
-			continue;
-
-		__br_multicast_enable_port(port);
-	}
+	br_multicast_start_querier(br);
 
 unlock:
 	spin_unlock_bh(&br->multicast_lock);
