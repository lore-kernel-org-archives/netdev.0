From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3] ipv6: Kill ndisc_get_neigh() inline helper.
Date: Sat, 03 Dec 2011 22:24:19 -0500 (EST)
Message-ID: <20111203.222419.1404907249336480391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab1LDDYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 22:24:20 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB43OJuM014261
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 3 Dec 2011 19:24:20 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's only used in net/ipv6/route.c and the NULL device check is
superfluous for all of the existing call sites.

Just expand the __ndisc_lookup_errno() call at each location.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ndisc.h |    9 ---------
 net/ipv6/route.c    |    7 ++++---
 2 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 62beeb9..c977c37 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -145,13 +145,4 @@ int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl,
 extern void 			inet6_ifinfo_notify(int event,
 						    struct inet6_dev *idev);
 
-static inline struct neighbour * ndisc_get_neigh(struct net_device *dev, const struct in6_addr *addr)
-{
-
-	if (dev)
-		return __neigh_lookup_errno(&nd_tbl, addr, dev);
-
-	return ERR_PTR(-ENODEV);
-}
-
 #endif
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 897a13f..1138b0a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -744,7 +744,8 @@ static struct rt6_info *rt6_alloc_cow(const struct rt6_info *ort,
 #endif
 
 	retry:
-		neigh = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
+		neigh = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway,
+					     rt->rt6i_dev);
 		if (IS_ERR(neigh)) {
 			struct net *net = dev_net(rt->rt6i_dev);
 			int saved_rt_min_interval =
@@ -1085,7 +1086,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (neigh)
 		neigh_hold(neigh);
 	else {
-		neigh = ndisc_get_neigh(dev, addr);
+		neigh = __neigh_lookup_errno(&nd_tbl, addr, dev);
 		if (IS_ERR(neigh))
 			neigh = NULL;
 	}
@@ -2082,7 +2083,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 		rt->rt6i_flags |= RTF_ANYCAST;
 	else
 		rt->rt6i_flags |= RTF_LOCAL;
-	neigh = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
+	neigh = __neigh_lookup_errno(&nd_tbl, &rt->rt6i_gateway, rt->rt6i_dev);
 	if (IS_ERR(neigh)) {
 		dst_free(&rt->dst);
 
-- 
1.7.7.3
