From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Fix fatal typo in setup of multicast_querier_expired
Date: Mon, 30 Apr 2012 20:22:56 +1000
Message-ID: <20120430102256.GA32587@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:53948 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755574Ab2D3KXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 06:23:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unfortunately it seems that I didn't properly test the case of
an expired external querier in the recent multicast bridge series.

The setup of the timer in that case is completely broken and leads
to a NULL-pointer dereference.  This patch fixes it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 26df642..b320871 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -744,8 +744,7 @@ static void br_multicast_local_router_expired(unsigned long data)
 
 static void br_multicast_querier_expired(unsigned long data)
 {
-	struct net_bridge_port *port = (void *)data;
-	struct net_bridge *br = port->br;
+	struct net_bridge *br = (void *)data;
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) || br->multicast_disabled)
@@ -1581,7 +1580,7 @@ void br_multicast_init(struct net_bridge *br)
 	setup_timer(&br->multicast_router_timer,
 		    br_multicast_local_router_expired, 0);
 	setup_timer(&br->multicast_querier_timer,
-		    br_multicast_querier_expired, 0);
+		    br_multicast_querier_expired, (unsigned long)br);
 	setup_timer(&br->multicast_query_timer, br_multicast_query_expired,
 		    (unsigned long)br);
 }

Sorry for the screw-up.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
