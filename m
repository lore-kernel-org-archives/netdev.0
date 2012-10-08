From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH v2 3/3] ipv4: Don't report stale pmtu values to userspace
Date: Mon, 8 Oct 2012 12:56:54 +0200
Message-ID: <20121008105654.GB21577@secunet.com>
References: <20121008084642.GB15622@secunet.com>
 <20121008084853.GE15622@secunet.com>
 <1349690144.21172.3024.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49036 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752384Ab2JHK47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 06:56:59 -0400
Content-Disposition: inline
In-Reply-To: <1349690144.21172.3024.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We report cached pmtu values even if they are already expired.
Change this to not report these values after they are expired
and fix a race in the expire time calculation, as suggested by
Eric Dumazet.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 741df67..132e0df 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2187,8 +2187,18 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	    nla_put_be32(skb, RTA_GATEWAY, rt->rt_gateway))
 		goto nla_put_failure;
 
+	expires = rt->dst.expires;
+	if (expires) {
+		unsigned long now = jiffies;
+
+		if (time_before(now, expires))
+			expires -= now;
+		else
+			expires = 0;
+	}
+
 	memcpy(metrics, dst_metrics_ptr(&rt->dst), sizeof(metrics));
-	if (rt->rt_pmtu)
+	if (rt->rt_pmtu && expires)
 		metrics[RTAX_MTU - 1] = rt->rt_pmtu;
 	if (rtnetlink_put_metrics(skb, metrics) < 0)
 		goto nla_put_failure;
@@ -2198,13 +2208,6 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 		goto nla_put_failure;
 
 	error = rt->dst.error;
-	expires = rt->dst.expires;
-	if (expires) {
-		if (time_before(jiffies, expires))
-			expires -= jiffies;
-		else
-			expires = 0;
-	}
 
 	if (rt_is_input_route(rt)) {
 		if (nla_put_u32(skb, RTA_IIF, rt->rt_iif))
-- 
1.7.0.4
