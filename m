From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] bridge: fix multicast router rlist endless loop
Date: Tue,  9 Jun 2015 02:32:28 -0700
Message-ID: <1433842349-28089-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	herbert@gondor.apana.org.au,
	Nikolay Aleksandrov <razor@blackwall.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:35489 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932538AbbFIJcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 05:32:42 -0400
Received: by qkhq76 with SMTP id q76so6227509qkh.2
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 02:32:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>

Since the addition of sysfs multicast router support if one set
multicast_router to "2" more than once, then the port would be added to the
hlist every time and could end up linking to itself and thus causing an
endless loop for rlist walkers.
So to reproduce just do:
echo 2 > multicast_router; echo 2 > multicast_router;
in a bridge port and let some igmp traffic flow, for me it hangs up
in br_multicast_flood().
Fix this by removing the "val < 2" check, and just do the hlist_del
always.
We can remove the "!hlist_unhashed" check because it's already done by
hlist_del_init_rcu(), in fact this can also be done for
br_multicast_disable_port() but that is net-next material.
The reason this didn't happen before the addition of multicast_router
sysfs entries is because there's a !hlist_unhashed check that prevents
it.

Signed-off-by: Nikolay Aleksandrov <razor@blackwall.org>
Fixes: 0909e11758bd ("bridge: Add multicast_router sysfs entries")
---
 net/bridge/br_multicast.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 22fd0419b314..ecdd13512320 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1993,8 +1993,7 @@ int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val)
 		p->multicast_router = val;
 		err = 0;
 
-		if (val < 2 && !hlist_unhashed(&p->rlist))
-			hlist_del_init_rcu(&p->rlist);
+		hlist_del_init_rcu(&p->rlist);
 
 		if (val == 1)
 			break;
-- 
2.1.0
