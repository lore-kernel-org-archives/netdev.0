From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 01/16] net: Refactor rtable allocation and initialization
Date: Mon, 27 Jul 2015 12:30:54 -0600
Message-ID: <1438021869-49186-2-git-send-email-dsa@cumulusnetworks.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	mingo@kernel.org, luto@amacapital.net,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34217 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628AbbG0Scw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 14:32:52 -0400
Received: by igk11 with SMTP id 11so74182197igk.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 11:32:51 -0700 (PDT)
In-Reply-To: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All callers to rt_dst_alloc have nearly the same initialization following
a successful allocation. Consolidate it into ip_route_new_rtable.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/route.h |   3 ++
 net/ipv4/route.c    | 111 +++++++++++++++++++++++-----------------------------
 2 files changed, 51 insertions(+), 63 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 2d45f419477f..cec7a2a055c8 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -111,6 +111,9 @@ struct in_device;
 int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
+struct rtable *ip_route_new_rtable(struct net_device *dev,
+				   unsigned int flags, u16 type,
+				   bool nopolicy, bool noxfrm, bool do_cache);
 struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
 struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 				    struct sock *sk);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 11096396ef4a..ef140919211f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1443,12 +1443,42 @@ static struct rtable *rt_dst_alloc(struct net_device *dev,
 			 (noxfrm ? DST_NOXFRM : 0));
 }
 
+struct rtable *ip_route_new_rtable(struct net_device *dev,
+				   unsigned int flags, u16 type,
+				   bool nopolicy, bool noxfrm, bool do_cache)
+{
+	struct rtable *rth;
+
+	rth = rt_dst_alloc(dev, nopolicy, noxfrm, do_cache);
+	if (rth) {
+		rth->rt_genid = rt_genid_ipv4(dev_net(dev));
+		rth->rt_flags = flags;
+		rth->rt_type = type;
+		rth->rt_is_input = 0;
+		rth->rt_iif = 0;
+		rth->rt_pmtu = 0;
+		rth->rt_gateway = 0;
+		rth->rt_uses_gateway = 0;
+		INIT_LIST_HEAD(&rth->rt_uncached);
+		rth->rt_lwtstate = NULL;
+
+		rth->dst.output = ip_output;
+		if (flags & RTCF_LOCAL)
+			rth->dst.input = ip_local_deliver;
+	}
+
+	return rth;
+}
+EXPORT_SYMBOL(ip_route_new_rtable);
+
 /* called in rcu_read_lock() section */
 static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 				u8 tos, struct net_device *dev, int our)
 {
 	struct rtable *rth;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	unsigned int flags = RTCF_MULTICAST;
+	u16 type = RTN_MULTICAST;
 	u32 itag = 0;
 	int err;
 
@@ -1474,8 +1504,13 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		if (err < 0)
 			goto e_err;
 	}
-	rth = rt_dst_alloc(dev_net(dev)->loopback_dev,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, false);
+	if (our)
+		flags |= RTCF_LOCAL;
+
+	rth = ip_route_new_rtable(dev_net(dev)->loopback_dev,
+				  flags, type,
+				  IN_DEV_CONF_GET(in_dev, NOPOLICY),
+				  false, false);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1483,22 +1518,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
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
-	rth->rt_lwtstate = NULL;
-	if (our) {
-		rth->dst.input= ip_local_deliver;
-		rth->rt_flags |= RTCF_LOCAL;
-	}
-
 #ifdef CONFIG_IP_MROUTE
 	if (!ipv4_is_local_multicast(daddr) && IN_DEV_MFORWARD(in_dev))
 		rth->dst.input = ip_mr_input;
@@ -1606,28 +1626,17 @@ static int __mkroute_input(struct sk_buff *skb,
 		}
 	}
 
-	rth = rt_dst_alloc(out_dev->dev,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
-			   IN_DEV_CONF_GET(out_dev, NOXFRM), do_cache);
+	rth = ip_route_new_rtable(out_dev->dev, 0, res->type,
+				  IN_DEV_CONF_GET(in_dev, NOPOLICY),
+				  IN_DEV_CONF_GET(out_dev, NOXFRM), do_cache);
 	if (!rth) {
 		err = -ENOBUFS;
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
-	rth->rt_lwtstate = NULL;
 	RT_CACHE_STAT_INC(in_slow_tot);
-
 	rth->dst.input = ip_forward;
-	rth->dst.output = ip_output;
 
 	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
 	if (lwtunnel_output_redirect(rth->rt_lwtstate))
@@ -1788,28 +1797,17 @@ out:	return err;
 		}
 	}
 
-	rth = rt_dst_alloc(net->loopback_dev,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
+	rth = ip_route_new_rtable(net->loopback_dev, flags | RTCF_LOCAL,
+				  res.type, IN_DEV_CONF_GET(in_dev, NOPOLICY),
+				  false, do_cache);
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
-	rth->rt_lwtstate = NULL;
-
 	RT_CACHE_STAT_INC(in_slow_tot);
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
@@ -1981,29 +1979,16 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	}
 
 add:
-	rth = rt_dst_alloc(dev_out,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
-			   IN_DEV_CONF_GET(in_dev, NOXFRM),
-			   do_cache);
+	rth = ip_route_new_rtable(dev_out, flags, type,
+				  IN_DEV_CONF_GET(in_dev, NOPOLICY),
+				  IN_DEV_CONF_GET(in_dev, NOXFRM),
+				  do_cache);
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
-	rth->dst.output = ip_output;
-
-	rth->rt_genid = rt_genid_ipv4(dev_net(dev_out));
-	rth->rt_flags	= flags;
-	rth->rt_type	= type;
-	rth->rt_is_input = 0;
-	rth->rt_iif	= orig_oif ? : 0;
-	rth->rt_pmtu	= 0;
-	rth->rt_gateway = 0;
-	rth->rt_uses_gateway = 0;
-	INIT_LIST_HEAD(&rth->rt_uncached);
-	rth->rt_lwtstate = NULL;
+	rth->rt_iif	= orig_oif;
 	RT_CACHE_STAT_INC(out_slow_tot);
 
-	if (flags & RTCF_LOCAL)
-		rth->dst.input = ip_local_deliver;
 	if (flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
 		if (flags & RTCF_LOCAL &&
 		    !(dev_out->flags & IFF_LOOPBACK)) {
-- 
2.3.2 (Apple Git-55)
