From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2] inetpeer: fix token initialization
Date: Thu, 27 Sep 2012 16:11:00 +0200
Message-ID: <1348755060-3737-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1348752886.5093.1282.camel@edumazet-glaptop>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35011 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534Ab2I0OHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 10:07:33 -0400
In-Reply-To: <1348752886.5093.1282.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When jiffies wraps around (for example, 5 minutes after the boot, see
INITIAL_JIFFIES) and peer has just been created, now - peer->rate_last can be
< XRLIM_BURST_FACTOR * timeout, so token is not set to the maximum value, thus
some icmp packets can be unexpectedly dropped.

Fix this case by initializing last_rate to 60 seconds in the past.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
v2: fix initialization of peer instead of adding some tests in
    inet_peer_xrlim_allow()

 net/ipv4/inetpeer.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index e1e0a4e..c7527f6 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -510,7 +510,10 @@ relookup:
 					secure_ipv6_id(daddr->addr.a6));
 		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		p->rate_tokens = 0;
-		p->rate_last = 0;
+		/* 60*HZ is arbitrary, but chosen enough high so that the first
+		 * calculation of tokens is at its maximum.
+		 */
+		p->rate_last = jiffies - 60*HZ;
 		INIT_LIST_HEAD(&p->gc_list);
 
 		/* Link the node. */
-- 
1.7.12
