From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/3] net: Refactor rtable initialization
Date: Wed,  2 Sep 2015 09:40:32 -0700
Message-ID: <1441212034-37464-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33193 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754604AbbIBQkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 12:40:41 -0400
Received: by pacex6 with SMTP id ex6so11768886pac.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 09:40:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All callers to rt_dst_alloc have nearly the same initialization following
a successful allocation. Consolidate it into rt_dst_alloc.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 85 ++++++++++++++++++++++----------------------------------
 1 file changed, 33 insertions(+), 52 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5f4a5565ad8b..eaefeadce07c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1438,12 +1438,33 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 }
 
 static struct rtable *rt_dst_alloc(struct net_device *dev,
+				   unsigned int flags, u16 type,
 				   bool nopolicy, bool noxfrm, bool will_cache)
 {
-	return dst_alloc(&ipv4_dst_ops, dev, 1, DST_OBSOLETE_FORCE_CHK,
-			 (will_cache ? 0 : (DST_HOST | DST_NOCACHE)) |
-			 (nopolicy ? DST_NOPOLICY : 0) |
-			 (noxfrm ? DST_NOXFRM : 0));
+	struct rtable *rt;
+
+	rt = dst_alloc(&ipv4_dst_ops, dev, 1, DST_OBSOLETE_FORCE_CHK,
+		       (will_cache ? 0 : (DST_HOST | DST_NOCACHE)) |
+		       (nopolicy ? DST_NOPOLICY : 0) |
+		       (noxfrm ? DST_NOXFRM : 0));
+
+	if (rt) {
+		rt->rt_genid = rt_genid_ipv4(dev_net(dev));
+		rt->rt_flags = flags;
+		rt->rt_type = type;
+		rt->rt_is_input = 0;
+		rt->rt_iif = 0;
+		rt->rt_pmtu = 0;
+		rt->rt_gateway = 0;
+		rt->rt_uses_gateway = 0;
+		INIT_LIST_HEAD(&rt->rt_uncached);
+
+		rt->dst.output = ip_output;
+		if (flags & RTCF_LOCAL)
+			rt->dst.input = ip_local_deliver;
+	}
+
+	return rt;
 }
 
 /* called in rcu_read_lock() section */
@@ -1452,6 +1473,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 {
 	struct rtable *rth;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	unsigned int flags = RTCF_MULTICAST;
 	u32 itag = 0;
 	int err;
 
@@ -1477,7 +1499,10 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		if (err < 0)
 			goto e_err;
 	}
-	rth = rt_dst_alloc(dev_net(dev)->loopback_dev,
+	if (our)
+		flags |= RTCF_LOCAL;
+
+	rth = rt_dst_alloc(dev_net(dev)->loopback_dev, flags, RTN_MULTICAST,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, false);
 	if (!rth)
 		goto e_nobufs;
@@ -1486,20 +1511,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->dst.tclassid = itag;
 #endif
 	rth->dst.output = ip_rt_bug;
-
-	rth->rt_genid	= rt_genid_ipv4(dev_net(dev));
-	rth->rt_flags	= RTCF_MULTICAST;
-	rth->rt_type	= RTN_MULTICAST;
 	rth->rt_is_input= 1;
-	rth->rt_iif	= 0;
-	rth->rt_pmtu	= 0;
-	rth->rt_gateway	= 0;
-	rth->rt_uses_gateway = 0;
-	INIT_LIST_HEAD(&rth->rt_uncached);
-	if (our) {
-		rth->dst.input= ip_local_deliver;
-		rth->rt_flags |= RTCF_LOCAL;
-	}
 
 #ifdef CONFIG_IP_MROUTE
 	if (!ipv4_is_local_multicast(daddr) && IN_DEV_MFORWARD(in_dev))
@@ -1608,7 +1620,7 @@ static int __mkroute_input(struct sk_buff *skb,
 		}
 	}
 
-	rth = rt_dst_alloc(out_dev->dev,
+	rth = rt_dst_alloc(out_dev->dev, 0, res->type,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
 			   IN_DEV_CONF_GET(out_dev, NOXFRM), do_cache);
 	if (!rth) {
@@ -1616,19 +1628,10 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	rth->rt_genid = rt_genid_ipv4(dev_net(rth->dst.dev));
-	rth->rt_flags = 0;
-	rth->rt_type = res->type;
 	rth->rt_is_input = 1;
-	rth->rt_iif 	= 0;
-	rth->rt_pmtu	= 0;
-	rth->rt_gateway	= 0;
-	rth->rt_uses_gateway = 0;
-	INIT_LIST_HEAD(&rth->rt_uncached);
 	RT_CACHE_STAT_INC(in_slow_tot);
 
 	rth->dst.input = ip_forward;
-	rth->dst.output = ip_output;
 
 	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
 	if (lwtunnel_output_redirect(rth->dst.lwtstate)) {
@@ -1795,26 +1798,16 @@ out:	return err;
 		}
 	}
 
-	rth = rt_dst_alloc(net->loopback_dev,
+	rth = rt_dst_alloc(net->loopback_dev, flags | RTCF_LOCAL, res.type,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
 	if (!rth)
 		goto e_nobufs;
 
-	rth->dst.input= ip_local_deliver;
 	rth->dst.output= ip_rt_bug;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
-
-	rth->rt_genid = rt_genid_ipv4(net);
-	rth->rt_flags 	= flags|RTCF_LOCAL;
-	rth->rt_type	= res.type;
 	rth->rt_is_input = 1;
-	rth->rt_iif	= 0;
-	rth->rt_pmtu	= 0;
-	rth->rt_gateway	= 0;
-	rth->rt_uses_gateway = 0;
-	INIT_LIST_HEAD(&rth->rt_uncached);
 
 	RT_CACHE_STAT_INC(in_slow_tot);
 	if (res.type == RTN_UNREACHABLE) {
@@ -1987,28 +1980,16 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	}
 
 add:
-	rth = rt_dst_alloc(dev_out,
+	rth = rt_dst_alloc(dev_out, flags, type,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
 			   IN_DEV_CONF_GET(in_dev, NOXFRM),
 			   do_cache);
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
-	rth->dst.output = ip_output;
-
-	rth->rt_genid = rt_genid_ipv4(dev_net(dev_out));
-	rth->rt_flags	= flags;
-	rth->rt_type	= type;
-	rth->rt_is_input = 0;
 	rth->rt_iif	= orig_oif ? : 0;
-	rth->rt_pmtu	= 0;
-	rth->rt_gateway = 0;
-	rth->rt_uses_gateway = 0;
-	INIT_LIST_HEAD(&rth->rt_uncached);
 	RT_CACHE_STAT_INC(out_slow_tot);
 
-	if (flags & RTCF_LOCAL)
-		rth->dst.input = ip_local_deliver;
 	if (flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
 		if (flags & RTCF_LOCAL &&
 		    !(dev_out->flags & IFF_LOOPBACK)) {
-- 
1.9.1
