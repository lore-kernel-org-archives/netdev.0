From: Tom Herbert <therbert@google.com>
Subject: [PATCH] ipv4: move rt_genid to different cache line
Date: Thu, 2 Jan 2014 12:00:23 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401021155330.32674@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:58668 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaABUAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 15:00:25 -0500
Received: by mail-ob0-f202.google.com with SMTP id gq1so3297150obb.1
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 12:00:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running a simple netperf TCP_RR test with 200 clients shows that
ipv4_dst_check is high on the list of functions in 'perf top'. The
pertinent action in this function is in the call to rt_is_expired
which checks the route genid (rt->rt_gentid) against the global value.
rt_genid is in the same cacheline as dst->__refcnt which is causing
false sharing.

This fix moves rt_genid into the first cacheline of the dst structure.
The dst structue is explicitly packed for cacheline optimization, so to
make room for the genid, I moved xfrm to cacheline with __refcnt (under
the assumption it is less likely to be in the critical path).

I don't believe there is an issue in ip6_dst_check since rt6i_genid
and the dst are in separate cachelines already (struct rt6_info).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/dst.h   | 10 ++++++----
 include/net/route.h |  1 -
 net/ipv4/route.c    | 13 +++++++------
 3 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 77eb53f..91777b2 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -39,10 +39,9 @@ struct dst_entry {
 	unsigned long           expires;
 	struct dst_entry	*path;
 	struct dst_entry	*from;
-#ifdef CONFIG_XFRM
-	struct xfrm_state	*xfrm;
-#else
-	void			*__pad1;
+	int			genid;
+#ifdef CONFIG_64BIT
+	int			__pad0;
 #endif
 	int			(*input)(struct sk_buff *);
 	int			(*output)(struct sk_buff *);
@@ -104,6 +103,9 @@ struct dst_entry {
 		struct rt6_info		*rt6_next;
 		struct dn_route __rcu	*dn_next;
 	};
+#ifdef CONFIG_XFRM
+	struct xfrm_state	*xfrm;
+#endif
 };
 
 u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
diff --git a/include/net/route.h b/include/net/route.h
index 638e3eb..72b4446 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -46,7 +46,6 @@ struct fib_info;
 struct rtable {
 	struct dst_entry	dst;
 
-	int			rt_genid;
 	unsigned int		rt_flags;
 	__u16			rt_type;
 	__u8			rt_is_input;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f8da282..8936da8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -436,7 +436,7 @@ static inline int ip_rt_proc_init(void)
 
 static inline bool rt_is_expired(const struct rtable *rth)
 {
-	return rth->rt_genid != rt_genid_ipv4(dev_net(rth->dst.dev));
+	return rth->dst.genid != rt_genid_ipv4(dev_net(rth->dst.dev));
 }
 
 void rt_cache_flush(struct net *net)
@@ -1459,8 +1459,8 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->dst.tclassid = itag;
 #endif
 	rth->dst.output = ip_rt_bug;
+	rth->dst.genid = rt_genid_ipv4(dev_net(dev));
 
-	rth->rt_genid	= rt_genid_ipv4(dev_net(dev));
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
 	rth->rt_is_input= 1;
@@ -1591,7 +1591,7 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	rth->rt_genid = rt_genid_ipv4(dev_net(rth->dst.dev));
+
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
 	rth->rt_is_input = 1;
@@ -1603,6 +1603,7 @@ static int __mkroute_input(struct sk_buff *skb,
 
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
+	rth->dst.genid = rt_genid_ipv4(dev_net(rth->dst.dev));
 
 	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
 	skb_dst_set(skb, &rth->dst);
@@ -1761,8 +1762,8 @@ local_input:
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
+	rth->dst.genid = rt_genid_ipv4(net);
 
-	rth->rt_genid = rt_genid_ipv4(net);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
 	rth->rt_is_input = 1;
@@ -1950,8 +1951,8 @@ add:
 		return ERR_PTR(-ENOBUFS);
 
 	rth->dst.output = ip_output;
+	rth->dst.genid = rt_genid_ipv4(dev_net(dev_out));
 
-	rth->rt_genid = rt_genid_ipv4(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
 	rth->rt_is_input = 0;
@@ -2228,12 +2229,12 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		new->dev = ort->dst.dev;
 		if (new->dev)
 			dev_hold(new->dev);
+		new->genid = rt_genid_ipv4(net);
 
 		rt->rt_is_input = ort->rt_is_input;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_pmtu = ort->rt_pmtu;
 
-		rt->rt_genid = rt_genid_ipv4(net);
 		rt->rt_flags = ort->rt_flags;
 		rt->rt_type = ort->rt_type;
 		rt->rt_gateway = ort->rt_gateway;
-- 
1.8.5.1
