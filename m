From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Cache ip_error() routes even when not forwarding.
Date: Tue, 26 Jun 2012 16:37:28 -0700 (PDT)
Message-ID: <20120626.163728.1730632109008655618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754644Ab2FZXhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 19:37:43 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id DAE59583FCA
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 16:37:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And account for the fact that, when we are not forwarding, we should
bump statistic counters rather than emit an ICMP response.

RP-filter rejected lookups are still not cached.

Since -EHOSTUNREACH and -ENETUNREACH can now no longer be seen in
ip_rcv_finish(), remove those checks.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

It seems pretty clear to me that we should cache things consistently
regardless of whether we are forwarding on an interface or not.

I noticed this while monitoring the routing cache the other day.  If
you have some misconfigured host on your network (as I did :-), this
change increases diagnosability because you'll be able to see the
reject routes in /proc/net/rt_cache with the specific IPs involved.

It was actually a surprise to me that we do not cache RP-filtered
lookups.  It's probably a toss-up whether caching or not caching these
is better or not.  So I haven't touched that case for now.  If we do
start to cache those, it will be nice in that we can streamline the
logic of ip_rcv_finish() completely by removing all the special error
code checks and counter bumps.  Only the -EXDEV RP-filter one remains.

Committed to net-next

 net/ipv4/ip_input.c |    8 +-------
 net/ipv4/route.c    |   30 +++++++++++++++++++-----------
 2 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index bca2517..2a39204 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -342,13 +342,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 			err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
 						   iph->tos, skb->dev);
 			if (unlikely(err)) {
-				if (err == -EHOSTUNREACH)
-					IP_INC_STATS_BH(dev_net(skb->dev),
-							IPSTATS_MIB_INADDRERRORS);
-				else if (err == -ENETUNREACH)
-					IP_INC_STATS_BH(dev_net(skb->dev),
-							IPSTATS_MIB_INNOROUTES);
-				else if (err == -EXDEV)
+				if (err == -EXDEV)
 					NET_INC_STATS_BH(dev_net(skb->dev),
 							 LINUX_MIB_IPRPFILTER);
 				goto drop;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 846961c..81533e3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1609,12 +1609,28 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 
 static int ip_error(struct sk_buff *skb)
 {
+	struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
 	struct rtable *rt = skb_rtable(skb);
 	struct inet_peer *peer;
 	unsigned long now;
+	struct net *net;
 	bool send;
 	int code;
 
+	net = dev_net(rt->dst.dev);
+	if (!IN_DEV_FORWARD(in_dev)) {
+		switch (rt->dst.error) {
+		case EHOSTUNREACH:
+			IP_INC_STATS_BH(net, IPSTATS_MIB_INADDRERRORS);
+			break;
+
+		case ENETUNREACH:
+			IP_INC_STATS_BH(net, IPSTATS_MIB_INNOROUTES);
+			break;
+		}
+		goto out;
+	}
+
 	switch (rt->dst.error) {
 	case EINVAL:
 	default:
@@ -1624,8 +1640,7 @@ static int ip_error(struct sk_buff *skb)
 		break;
 	case ENETUNREACH:
 		code = ICMP_NET_UNREACH;
-		IP_INC_STATS_BH(dev_net(rt->dst.dev),
-				IPSTATS_MIB_INNOROUTES);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INNOROUTES);
 		break;
 	case EACCES:
 		code = ICMP_PKT_FILTERED;
@@ -2255,11 +2270,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
 	err = fib_lookup(net, &fl4, &res);
-	if (err != 0) {
-		if (!IN_DEV_FORWARD(in_dev))
-			goto e_hostunreach;
+	if (err != 0)
 		goto no_route;
-	}
 
 	RT_CACHE_STAT_INC(in_slow_tot);
 
@@ -2279,7 +2291,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	}
 
 	if (!IN_DEV_FORWARD(in_dev))
-		goto e_hostunreach;
+		goto no_route;
 	if (res.type != RTN_UNICAST)
 		goto martian_destination;
 
@@ -2367,10 +2379,6 @@ martian_destination:
 				     &daddr, &saddr, dev->name);
 #endif
 
-e_hostunreach:
-	err = -EHOSTUNREACH;
-	goto out;
-
 e_inval:
 	err = -EINVAL;
 	goto out;
-- 
1.7.10
