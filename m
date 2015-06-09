From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net v2] bridge: fix multicast router rlist endless loop
Date: Tue,  9 Jun 2015 10:23:57 -0700
Message-ID: <1433870637-15844-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1433842349-28089-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	herbert@gondor.apana.org.au,
	Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33395 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059AbbFIRYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 13:24:05 -0400
Received: by qkhg32 with SMTP id g32so12851653qkh.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 10:24:04 -0700 (PDT)
In-Reply-To: <1433842349-28089-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>

Since the addition of sysfs multicast router support if one set
multicast_router to "2" more than once, then the port would be added to
the hlist every time and could end up linking to itself and thus causing an
endless loop for rlist walkers.
So to reproduce just do:
echo 2 > multicast_router; echo 2 > multicast_router;
in a bridge port and let some igmp traffic flow, for me it hangs up
in br_multicast_flood().
Fix this by adding a check in br_multicast_add_router() if the port is
already linked.
The reason this didn't happen before the addition of multicast_router
sysfs entries is because there's a !hlist_unhashed check that prevents
it.

Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
Fixes: 0909e11758bd ("bridge: Add multicast_router sysfs entries")
---
v2: implement Herbert's suggestion and add the check to
    br_multicast_add_router instead of changing the sysfs caller.

 net/bridge/br_multicast.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 22fd0419b314..ff667e18b2d6 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1167,6 +1167,9 @@ static void br_multicast_add_router(struct net_bridge *br,
 	struct net_bridge_port *p;
 	struct hlist_node *slot = NULL;
 
+	if (!hlist_unhashed(&port->rlist))
+		return;
+
 	hlist_for_each_entry(p, &br->router_list, rlist) {
 		if ((unsigned long) port >= (unsigned long) p)
 			break;
@@ -1194,12 +1197,8 @@ static void br_multicast_mark_router(struct net_bridge *br,
 	if (port->multicast_router != 1)
 		return;
 
-	if (!hlist_unhashed(&port->rlist))
-		goto timer;
-
 	br_multicast_add_router(br, port);
 
-timer:
 	mod_timer(&port->multicast_router_timer,
 		  now + br->multicast_querier_interval);
 }
-- 
2.1.0
