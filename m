From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] ipv4: Don't report stale pmtu values to userspace
Date: Mon, 8 Oct 2012 10:48:53 +0200
Message-ID: <20121008084853.GE15622@secunet.com>
References: <20121008084642.GB15622@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46817 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628Ab2JHIs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 04:48:58 -0400
Content-Disposition: inline
In-Reply-To: <20121008084642.GB15622@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We report cached pmtu values even if they are already expired.
Change this to not report these values after they are expired.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 741df67..24b52dd 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2187,8 +2187,16 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	    nla_put_be32(skb, RTA_GATEWAY, rt->rt_gateway))
 		goto nla_put_failure;
 
+	expires = rt->dst.expires;
+	if (expires) {
+		if (time_before(jiffies, expires))
+			expires -= jiffies;
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
@@ -2198,13 +2206,6 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
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
