From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3] ipv4: Change rt->rt_iif encoding.
Date: Mon, 23 Jul 2012 16:45:51 -0700 (PDT)
Message-ID: <20120723.164551.594831620653528705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085Ab2GWXpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 19:45:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On input packet processing, rt->rt_iif will be zero if we should
use skb->dev->ifindex.

Since we access rt->rt_iif consistently via inet_iif(), that is
the only spot whose interpretation have to adjust.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    6 +++++-
 net/ipv4/route.c    |    8 ++++----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 60d611d..c29ef27 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -277,7 +277,11 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 
 static inline int inet_iif(const struct sk_buff *skb)
 {
-	return skb_rtable(skb)->rt_iif;
+	int iif = skb_rtable(skb)->rt_iif;
+
+	if (iif)
+		return iif;
+	return skb->skb_iif;
 }
 
 extern int sysctl_ip_default_ttl;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f6be781..6bcb8fc 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1309,7 +1309,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
 	rth->rt_is_input= 1;
-	rth->rt_iif	= dev->ifindex;
+	rth->rt_iif	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
 	if (our) {
@@ -1435,7 +1435,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
 	rth->rt_is_input = 1;
-	rth->rt_iif 	= in_dev->dev->ifindex;
+	rth->rt_iif 	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
 
@@ -1608,7 +1608,7 @@ local_input:
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
 	rth->rt_is_input = 1;
-	rth->rt_iif	= dev->ifindex;
+	rth->rt_iif	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
 	if (res.type == RTN_UNREACHABLE) {
@@ -1772,7 +1772,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
 	rth->rt_is_input = 0;
-	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
+	rth->rt_iif	= orig_oif ? : 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway = 0;
 
-- 
1.7.10.4
