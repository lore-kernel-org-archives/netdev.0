From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Kill rt->rt_spec_dst, no longer used.
Date: Thu, 28 Jun 2012 04:08:54 -0700 (PDT)
Message-ID: <20120628.040854.485985077615766089.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617Ab2F1LIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 07:08:55 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 0F0475847F7
	for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 04:08:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h    |    2 +-
 include/net/route.h     |    1 -
 net/ipv4/fib_frontend.c |    9 ++-------
 net/ipv4/route.c        |   38 +++++++++-----------------------------
 net/ipv4/xfrm4_policy.c |    1 -
 5 files changed, 12 insertions(+), 39 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 1687b3d..9e6c26d 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -233,7 +233,7 @@ extern void		ip_fib_init(void);
 extern __be32 fib_compute_spec_dst(struct sk_buff *skb);
 extern int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 			       u8 tos, int oif, struct net_device *dev,
-			       __be32 *spec_dst, u32 *itag);
+			       u32 *itag);
 extern void fib_select_default(struct fib_result *res);
 
 /* Exported by fib_semantics.c */
diff --git a/include/net/route.h b/include/net/route.h
index 47eb25a..211e266 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -65,7 +65,6 @@ struct rtable {
 	__be32			rt_gateway;
 
 	/* Miscellaneous cached information */
-	__be32			rt_spec_dst; /* RFC1122 specific destination */
 	u32			rt_peer_genid;
 	unsigned long		_peer; /* long-living peer info */
 	struct fib_info		*fi; /* for client ref to shared metrics */
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 451939b..63b11ca 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -218,8 +218,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
  * called with rcu_read_lock()
  */
 int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst, u8 tos,
-			int oif, struct net_device *dev, __be32 *spec_dst,
-			u32 *itag)
+			int oif, struct net_device *dev, u32 *itag)
 {
 	struct in_device *in_dev;
 	struct flowi4 fl4;
@@ -258,7 +257,6 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst, u8 tos,
 		if (res.type != RTN_LOCAL || !accept_local)
 			goto e_inval;
 	}
-	*spec_dst = FIB_RES_PREFSRC(net, res);
 	fib_combine_itag(itag, &res);
 	dev_match = false;
 
@@ -287,17 +285,14 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst, u8 tos,
 
 	ret = 0;
 	if (fib_lookup(net, &fl4, &res) == 0) {
-		if (res.type == RTN_UNICAST) {
-			*spec_dst = FIB_RES_PREFSRC(net, res);
+		if (res.type == RTN_UNICAST)
 			ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
-		}
 	}
 	return ret;
 
 last_resort:
 	if (rpf)
 		goto e_rpf;
-	*spec_dst = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
 	*itag = 0;
 	return 0;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 81533e3..83d56a0 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -440,7 +440,7 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			r->rt_key_tos,
 			-1,
 			HHUptod,
-			r->rt_spec_dst, &len);
+			0, &len);
 
 		seq_printf(seq, "%*s\n", 127 - len, "");
 	}
@@ -1978,7 +1978,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 {
 	unsigned int hash;
 	struct rtable *rth;
-	__be32 spec_dst;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
 	u32 itag = 0;
 	int err;
@@ -1999,10 +1998,8 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_zeronet(saddr)) {
 		if (!ipv4_is_local_multicast(daddr))
 			goto e_inval;
-		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
 	} else {
-		err = fib_validate_source(skb, saddr, 0, tos, 0, dev, &spec_dst,
-					  &itag);
+		err = fib_validate_source(skb, saddr, 0, tos, 0, dev, &itag);
 		if (err < 0)
 			goto e_err;
 	}
@@ -2029,7 +2026,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_oif	= 0;
 	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
-	rth->rt_spec_dst= spec_dst;
 	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, dev_net(dev)->ipv4.peers);
 	rth->fi = NULL;
@@ -2093,7 +2089,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	int err;
 	struct in_device *out_dev;
 	unsigned int flags = 0;
-	__be32 spec_dst;
 	u32 itag;
 
 	/* get a working reference to the output device */
@@ -2105,7 +2100,7 @@ static int __mkroute_input(struct sk_buff *skb,
 
 
 	err = fib_validate_source(skb, saddr, daddr, tos, FIB_RES_OIF(*res),
-				  in_dev->dev, &spec_dst, &itag);
+				  in_dev->dev, &itag);
 	if (err < 0) {
 		ip_handle_martian_source(in_dev->dev, in_dev, skb, daddr,
 					 saddr);
@@ -2157,7 +2152,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_oif 	= 0;
 	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
-	rth->rt_spec_dst= spec_dst;
 	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, &res->table->tb_peers);
 	rth->fi = NULL;
@@ -2223,7 +2217,6 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	u32		itag = 0;
 	struct rtable	*rth;
 	unsigned int	hash;
-	__be32		spec_dst;
 	int		err = -EINVAL;
 	struct net    *net = dev_net(dev);
 
@@ -2281,12 +2274,11 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (res.type == RTN_LOCAL) {
 		err = fib_validate_source(skb, saddr, daddr, tos,
 					  net->loopback_dev->ifindex,
-					  dev, &spec_dst, &itag);
+					  dev, &itag);
 		if (err < 0)
 			goto martian_source_keep_err;
 		if (err)
 			flags |= RTCF_DIRECTSRC;
-		spec_dst = daddr;
 		goto local_input;
 	}
 
@@ -2302,11 +2294,8 @@ brd_input:
 	if (skb->protocol != htons(ETH_P_IP))
 		goto e_inval;
 
-	if (ipv4_is_zeronet(saddr))
-		spec_dst = inet_select_addr(dev, 0, RT_SCOPE_LINK);
-	else {
-		err = fib_validate_source(skb, saddr, 0, tos, 0, dev, &spec_dst,
-					  &itag);
+	if (!ipv4_is_zeronet(saddr)) {
+		err = fib_validate_source(skb, saddr, 0, tos, 0, dev, &itag);
 		if (err < 0)
 			goto martian_source_keep_err;
 		if (err)
@@ -2344,7 +2333,6 @@ local_input:
 	rth->rt_oif	= 0;
 	rth->rt_mark    = skb->mark;
 	rth->rt_gateway	= daddr;
-	rth->rt_spec_dst= spec_dst;
 	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, net->ipv4.peers);
 	rth->fi = NULL;
@@ -2362,7 +2350,6 @@ local_input:
 
 no_route:
 	RT_CACHE_STAT_INC(in_no_route);
-	spec_dst = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
 	res.type = RTN_UNREACHABLE;
 	if (err == -ESRCH)
 		err = -ENETUNREACH;
@@ -2545,7 +2532,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_oif	= orig_oif;
 	rth->rt_mark    = fl4->flowi4_mark;
 	rth->rt_gateway = fl4->daddr;
-	rth->rt_spec_dst= fl4->saddr;
 	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, (res->table ?
 			   &res->table->tb_peers :
@@ -2554,12 +2540,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	RT_CACHE_STAT_INC(out_slow_tot);
 
-	if (flags & RTCF_LOCAL) {
+	if (flags & RTCF_LOCAL)
 		rth->dst.input = ip_local_deliver;
-		rth->rt_spec_dst = fl4->daddr;
-	}
 	if (flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
-		rth->rt_spec_dst = fl4->saddr;
 		if (flags & RTCF_LOCAL &&
 		    !(dev_out->flags & IFF_LOOPBACK)) {
 			rth->dst.output = ip_mc_output;
@@ -2890,7 +2873,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_dst = ort->rt_dst;
 		rt->rt_src = ort->rt_src;
 		rt->rt_gateway = ort->rt_gateway;
-		rt->rt_spec_dst = ort->rt_spec_dst;
 		rt_transfer_peer(rt, ort);
 		rt->fi = ort->fi;
 		if (rt->fi)
@@ -2965,10 +2947,8 @@ static int rt_fill_info(struct net *net,
 	    nla_put_u32(skb, RTA_FLOW, rt->dst.tclassid))
 		goto nla_put_failure;
 #endif
-	if (rt_is_input_route(rt)) {
-		if (nla_put_be32(skb, RTA_PREFSRC, rt->rt_spec_dst))
-			goto nla_put_failure;
-	} else if (rt->rt_src != rt->rt_key_src) {
+	if (!rt_is_input_route(rt) &&
+	    rt->rt_src != rt->rt_key_src) {
 		if (nla_put_be32(skb, RTA_PREFSRC, rt->rt_src))
 			goto nla_put_failure;
 	}
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 8855d82..9815ea0 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -100,7 +100,6 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.rt.rt_src = rt->rt_src;
 	xdst->u.rt.rt_dst = rt->rt_dst;
 	xdst->u.rt.rt_gateway = rt->rt_gateway;
-	xdst->u.rt.rt_spec_dst = rt->rt_spec_dst;
 
 	return 0;
 }
-- 
1.7.10.2
