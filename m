From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/5] inet: Hide route peer accesses behind helpers.
Date: Mon, 11 Jun 2012 02:29:08 -0700 (PDT)
Message-ID: <20120611.022908.953732817435232845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab2FKJ3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 05:29:09 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 09A7D584265
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 02:29:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We encode the pointer(s) into an unsigned long with one state bit.

The state bit is used so we can store the inetpeer tree root to use
when resolving the peer later.

Later the peer roots will be per-FIB table, and this change works to
facilitate that.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h  |   54 +++++++++++++++++++++++++++++++++++++++++++++
 include/net/ip6_fib.h   |   32 ++++++++++++++++++++++++++-
 include/net/ip6_route.h |    6 ++---
 include/net/route.h     |   42 +++++++++++++++++++++++++++++++----
 net/ipv4/route.c        |   56 ++++++++++++++++++++++++++++-------------------
 net/ipv4/xfrm4_policy.c |   10 ++++-----
 net/ipv6/route.c        |   42 ++++++++++++++++++++---------------
 net/ipv6/xfrm6_policy.c |   10 ++++-----
 8 files changed, 193 insertions(+), 59 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index b84b32f..d432489 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -71,6 +71,60 @@ struct inet_peer_base {
 	int			total;
 };
 
+#define INETPEER_BASE_BIT	0x1UL
+
+static inline struct inet_peer *inetpeer_ptr(unsigned long val)
+{
+	BUG_ON(val & INETPEER_BASE_BIT);
+	return (struct inet_peer *) val;
+}
+
+static inline struct inet_peer_base *inetpeer_base_ptr(unsigned long val)
+{
+	if (!(val & INETPEER_BASE_BIT))
+		return NULL;
+	val &= ~INETPEER_BASE_BIT;
+	return (struct inet_peer_base *) val;
+}
+
+static inline bool inetpeer_ptr_is_peer(unsigned long val)
+{
+	return !(val & INETPEER_BASE_BIT);
+}
+
+static inline void __inetpeer_ptr_set_peer(unsigned long *val, struct inet_peer *peer)
+{
+	/* This implicitly clears INETPEER_BASE_BIT */
+	*val = (unsigned long) peer;
+}
+
+static inline bool inetpeer_ptr_set_peer(unsigned long *ptr, struct inet_peer *peer)
+{
+	unsigned long val = (unsigned long) peer;
+	unsigned long orig = *ptr;
+
+	if (!(orig & INETPEER_BASE_BIT) || !val ||
+	    cmpxchg(ptr, orig, val) != orig)
+		return false;
+	return true;
+}
+
+static inline void inetpeer_init_ptr(unsigned long *ptr, struct inet_peer_base *base)
+{
+	*ptr = (unsigned long) base | INETPEER_BASE_BIT;
+}
+
+static inline void inetpeer_transfer_peer(unsigned long *to, unsigned long *from)
+{
+	unsigned long val = *from;
+
+	*to = val;
+	if (inetpeer_ptr_is_peer(val)) {
+		struct inet_peer *peer = inetpeer_ptr(val);
+		atomic_inc(&peer->refcnt);
+	}
+}
+
 extern void inet_peer_base_init(struct inet_peer_base *);
 
 void			inet_initpeers(void) __init;
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 0ae759a..3ac5f15 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -107,7 +107,7 @@ struct rt6_info {
 	u32				rt6i_peer_genid;
 
 	struct inet6_dev		*rt6i_idev;
-	struct inet_peer		*rt6i_peer;
+	unsigned long			_rt6i_peer;
 
 #ifdef CONFIG_XFRM
 	u32				rt6i_flow_cache_genid;
@@ -118,6 +118,36 @@ struct rt6_info {
 	u8				rt6i_protocol;
 };
 
+static inline struct inet_peer *rt6_peer_ptr(struct rt6_info *rt)
+{
+	return inetpeer_ptr(rt->_rt6i_peer);
+}
+
+static inline bool rt6_has_peer(struct rt6_info *rt)
+{
+	return inetpeer_ptr_is_peer(rt->_rt6i_peer);
+}
+
+static inline void __rt6_set_peer(struct rt6_info *rt, struct inet_peer *peer)
+{
+	__inetpeer_ptr_set_peer(&rt->_rt6i_peer, peer);
+}
+
+static inline bool rt6_set_peer(struct rt6_info *rt, struct inet_peer *peer)
+{
+	return inetpeer_ptr_set_peer(&rt->_rt6i_peer, peer);
+}
+
+static inline void rt6_init_peer(struct rt6_info *rt, struct inet_peer_base *base)
+{
+	inetpeer_init_ptr(&rt->_rt6i_peer, base);
+}
+
+static inline void rt6_transfer_peer(struct rt6_info *rt, struct rt6_info *ort)
+{
+	inetpeer_transfer_peer(&rt->_rt6i_peer, &ort->_rt6i_peer);
+}
+
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 {
 	return ((struct rt6_info *)dst)->rt6i_idev;
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 73d7502..f88a85c 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -57,11 +57,11 @@ extern void rt6_bind_peer(struct rt6_info *rt, int create);
 
 static inline struct inet_peer *__rt6_get_peer(struct rt6_info *rt, int create)
 {
-	if (rt->rt6i_peer)
-		return rt->rt6i_peer;
+	if (rt6_has_peer(rt))
+		return rt6_peer_ptr(rt);
 
 	rt6_bind_peer(rt, create);
-	return rt->rt6i_peer;
+	return rt6_peer_ptr(rt);
 }
 
 static inline struct inet_peer *rt6_get_peer(struct rt6_info *rt)
diff --git a/include/net/route.h b/include/net/route.h
index 433fc6c..6340c37 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -67,10 +67,44 @@ struct rtable {
 	/* Miscellaneous cached information */
 	__be32			rt_spec_dst; /* RFC1122 specific destination */
 	u32			rt_peer_genid;
-	struct inet_peer	*peer; /* long-living peer info */
+	unsigned long		_peer; /* long-living peer info */
 	struct fib_info		*fi; /* for client ref to shared metrics */
 };
 
+static inline struct inet_peer *rt_peer_ptr(struct rtable *rt)
+{
+	return inetpeer_ptr(rt->_peer);
+}
+
+static inline bool rt_has_peer(struct rtable *rt)
+{
+	return inetpeer_ptr_is_peer(rt->_peer);
+}
+
+static inline void __rt_set_peer(struct rtable *rt, struct inet_peer *peer)
+{
+	__inetpeer_ptr_set_peer(&rt->_peer, peer);
+}
+
+static inline bool rt_set_peer(struct rtable *rt, struct inet_peer *peer)
+{
+	return inetpeer_ptr_set_peer(&rt->_peer, peer);
+}
+
+static inline void rt_init_peer(struct rtable *rt, struct inet_peer_base *base)
+{
+	inetpeer_init_ptr(&rt->_peer, base);
+}
+
+static inline void rt_transfer_peer(struct rtable *rt, struct rtable *ort)
+{
+	rt->_peer = ort->_peer;
+	if (rt_has_peer(ort)) {
+		struct inet_peer *peer = rt_peer_ptr(ort);
+		atomic_inc(&peer->refcnt);
+	}
+}
+
 static inline bool rt_is_input_route(const struct rtable *rt)
 {
 	return rt->rt_route_iif != 0;
@@ -298,11 +332,11 @@ extern void rt_bind_peer(struct rtable *rt, __be32 daddr, int create);
 
 static inline struct inet_peer *__rt_get_peer(struct rtable *rt, __be32 daddr, int create)
 {
-	if (rt->peer)
-		return rt->peer;
+	if (rt_has_peer(rt))
+		return rt_peer_ptr(rt);
 
 	rt_bind_peer(rt, daddr, create);
-	return rt->peer;
+	return rt_peer_ptr(rt);
 }
 
 static inline struct inet_peer *rt_get_peer(struct rtable *rt, __be32 daddr)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2aa663a..03e5b61 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -677,7 +677,7 @@ static inline int rt_fast_clean(struct rtable *rth)
 static inline int rt_valuable(struct rtable *rth)
 {
 	return (rth->rt_flags & (RTCF_REDIRECTED | RTCF_NOTIFY)) ||
-		(rth->peer && rth->peer->pmtu_expires);
+		(rt_has_peer(rth) && rt_peer_ptr(rth)->pmtu_expires);
 }
 
 static int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long tmo2)
@@ -1325,12 +1325,16 @@ static u32 rt_peer_genid(void)
 
 void rt_bind_peer(struct rtable *rt, __be32 daddr, int create)
 {
-	struct net *net = dev_net(rt->dst.dev);
+	struct inet_peer_base *base;
 	struct inet_peer *peer;
 
-	peer = inet_getpeer_v4(net->ipv4.peers, daddr, create);
+	base = inetpeer_base_ptr(rt->_peer);
+	if (!base)
+		return;
+
+	peer = inet_getpeer_v4(base, daddr, create);
 
-	if (peer && cmpxchg(&rt->peer, NULL, peer) != NULL)
+	if (!rt_set_peer(rt, peer))
 		inet_putpeer(peer);
 	else
 		rt->rt_peer_genid = rt_peer_genid();
@@ -1533,8 +1537,10 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 						rt_genid(dev_net(dst->dev)));
 			rt_del(hash, rt);
 			ret = NULL;
-		} else if (rt->peer && peer_pmtu_expired(rt->peer)) {
-			dst_metric_set(dst, RTAX_MTU, rt->peer->pmtu_orig);
+		} else if (rt_has_peer(rt)) {
+			struct inet_peer *peer = rt_peer_ptr(rt);
+			if (peer_pmtu_expired(peer))
+				dst_metric_set(dst, RTAX_MTU, peer->pmtu_orig);
 		}
 	}
 	return ret;
@@ -1796,14 +1802,13 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 static void ipv4_dst_destroy(struct dst_entry *dst)
 {
 	struct rtable *rt = (struct rtable *) dst;
-	struct inet_peer *peer = rt->peer;
 
 	if (rt->fi) {
 		fib_info_put(rt->fi);
 		rt->fi = NULL;
 	}
-	if (peer) {
-		rt->peer = NULL;
+	if (rt_has_peer(rt)) {
+		struct inet_peer *peer = rt_peer_ptr(rt);
 		inet_putpeer(peer);
 	}
 }
@@ -1816,8 +1821,11 @@ static void ipv4_link_failure(struct sk_buff *skb)
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_UNREACH, 0);
 
 	rt = skb_rtable(skb);
-	if (rt && rt->peer && peer_pmtu_cleaned(rt->peer))
-		dst_metric_set(&rt->dst, RTAX_MTU, rt->peer->pmtu_orig);
+	if (rt && rt_has_peer(rt)) {
+		struct inet_peer *peer = rt_peer_ptr(rt);
+		if (peer_pmtu_cleaned(peer))
+			dst_metric_set(&rt->dst, RTAX_MTU, peer->pmtu_orig);
+	}
 }
 
 static int ip_rt_bug(struct sk_buff *skb)
@@ -1919,7 +1927,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 			    struct fib_info *fi)
 {
-	struct net *net = dev_net(rt->dst.dev);
+	struct inet_peer_base *base;
 	struct inet_peer *peer;
 	int create = 0;
 
@@ -1929,8 +1937,12 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 	if (fl4 && (fl4->flowi4_flags & FLOWI_FLAG_PRECOW_METRICS))
 		create = 1;
 
-	rt->peer = peer = inet_getpeer_v4(net->ipv4.peers, rt->rt_dst, create);
+	base = inetpeer_base_ptr(rt->_peer);
+	BUG_ON(!base);
+
+	peer = inet_getpeer_v4(base, rt->rt_dst, create);
 	if (peer) {
+		__rt_set_peer(rt, peer);
 		rt->rt_peer_genid = rt_peer_genid();
 		if (inet_metrics_new(peer))
 			memcpy(peer->metrics, fi->fib_metrics,
@@ -2046,7 +2058,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->rt_peer_genid = 0;
-	rth->peer = NULL;
+	rt_init_peer(rth, dev_net(dev)->ipv4.peers);
 	rth->fi = NULL;
 	if (our) {
 		rth->dst.input= ip_local_deliver;
@@ -2174,7 +2186,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->rt_peer_genid = 0;
-	rth->peer = NULL;
+	rt_init_peer(rth, dev_net(rth->dst.dev)->ipv4.peers);
 	rth->fi = NULL;
 
 	rth->dst.input = ip_forward;
@@ -2357,7 +2369,7 @@ local_input:
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->rt_peer_genid = 0;
-	rth->peer = NULL;
+	rt_init_peer(rth, net->ipv4.peers);
 	rth->fi = NULL;
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
@@ -2561,7 +2573,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_gateway = fl4->daddr;
 	rth->rt_spec_dst= fl4->saddr;
 	rth->rt_peer_genid = 0;
-	rth->peer = NULL;
+	rt_init_peer(rth, dev_net(dev_out)->ipv4.peers);
 	rth->fi = NULL;
 
 	RT_CACHE_STAT_INC(out_slow_tot);
@@ -2898,9 +2910,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_src = ort->rt_src;
 		rt->rt_gateway = ort->rt_gateway;
 		rt->rt_spec_dst = ort->rt_spec_dst;
-		rt->peer = ort->peer;
-		if (rt->peer)
-			atomic_inc(&rt->peer->refcnt);
+		rt_transfer_peer(rt, ort);
 		rt->fi = ort->fi;
 		if (rt->fi)
 			atomic_inc(&rt->fi->fib_clntref);
@@ -2938,7 +2948,6 @@ static int rt_fill_info(struct net *net,
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
 	unsigned long expires = 0;
-	const struct inet_peer *peer = rt->peer;
 	u32 id = 0, ts = 0, tsage = 0, error;
 
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*r), flags);
@@ -2994,8 +3003,9 @@ static int rt_fill_info(struct net *net,
 		goto nla_put_failure;
 
 	error = rt->dst.error;
-	if (peer) {
-		inet_peer_refcheck(rt->peer);
+	if (rt_has_peer(rt)) {
+		const struct inet_peer *peer = rt_peer_ptr(rt);
+		inet_peer_refcheck(peer);
 		id = atomic_read(&peer->ip_id_count) & 0xffff;
 		if (peer->tcp_ts_stamp) {
 			ts = peer->tcp_ts;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 0d3426c..8855d82 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -90,9 +90,7 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
 
-	xdst->u.rt.peer = rt->peer;
-	if (rt->peer)
-		atomic_inc(&rt->peer->refcnt);
+	rt_transfer_peer(&xdst->u.rt, rt);
 
 	/* Sheit... I remember I did this right. Apparently,
 	 * it was magically lost, so this code needs audit */
@@ -212,8 +210,10 @@ static void xfrm4_dst_destroy(struct dst_entry *dst)
 
 	dst_destroy_metrics_generic(dst);
 
-	if (likely(xdst->u.rt.peer))
-		inet_putpeer(xdst->u.rt.peer);
+	if (rt_has_peer(&xdst->u.rt)) {
+		struct inet_peer *peer = rt_peer_ptr(&xdst->u.rt);
+		inet_putpeer(peer);
+	}
 
 	xfrm_dst_destroy(xdst);
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8fc41d5..17a9b86 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -258,16 +258,18 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 #endif
 
 /* allocate dst with ip6_dst_ops */
-static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops,
+static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 					     struct net_device *dev,
 					     int flags)
 {
-	struct rt6_info *rt = dst_alloc(ops, dev, 0, 0, flags);
+	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
+					0, 0, flags);
 
-	if (rt)
+	if (rt) {
 		memset(&rt->rt6i_table, 0,
 		       sizeof(*rt) - sizeof(struct dst_entry));
-
+		rt6_init_peer(rt, net->ipv6.peers);
+	}
 	return rt;
 }
 
@@ -275,7 +277,6 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct inet6_dev *idev = rt->rt6i_idev;
-	struct inet_peer *peer = rt->rt6i_peer;
 
 	if (!(rt->dst.flags & DST_HOST))
 		dst_destroy_metrics_generic(dst);
@@ -288,8 +289,8 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	if (!(rt->rt6i_flags & RTF_EXPIRES) && dst->from)
 		dst_release(dst->from);
 
-	if (peer) {
-		rt->rt6i_peer = NULL;
+	if (rt6_has_peer(rt)) {
+		struct inet_peer *peer = rt6_peer_ptr(rt);
 		inet_putpeer(peer);
 	}
 }
@@ -303,11 +304,15 @@ static u32 rt6_peer_genid(void)
 
 void rt6_bind_peer(struct rt6_info *rt, int create)
 {
-	struct net *net = dev_net(rt->dst.dev);
+	struct inet_peer_base *base;
 	struct inet_peer *peer;
 
-	peer = inet_getpeer_v6(net->ipv6.peers, &rt->rt6i_dst.addr, create);
-	if (peer && cmpxchg(&rt->rt6i_peer, NULL, peer) != NULL)
+	base = inetpeer_base_ptr(rt->_rt6i_peer);
+	if (!base)
+		return;
+
+	peer = inet_getpeer_v6(base, &rt->rt6i_dst.addr, create);
+	if (!rt6_set_peer(rt, peer))
 		inet_putpeer(peer);
 	else
 		rt->rt6i_peer_genid = rt6_peer_genid();
@@ -950,6 +955,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 	rt = dst_alloc(&ip6_dst_blackhole_ops, ort->dst.dev, 1, 0, 0);
 	if (rt) {
 		memset(&rt->rt6i_table, 0, sizeof(*rt) - sizeof(struct dst_entry));
+		rt6_init_peer(rt, net->ipv6.peers);
 
 		new = &rt->dst;
 
@@ -994,7 +1000,7 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 
 	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie)) {
 		if (rt->rt6i_peer_genid != rt6_peer_genid()) {
-			if (!rt->rt6i_peer)
+			if (!rt6_has_peer(rt))
 				rt6_bind_peer(rt, 0);
 			rt->rt6i_peer_genid = rt6_peer_genid();
 		}
@@ -1108,7 +1114,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (unlikely(!idev))
 		return ERR_PTR(-ENODEV);
 
-	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, dev, 0);
+	rt = ip6_dst_alloc(net, dev, 0);
 	if (unlikely(!rt)) {
 		in6_dev_put(idev);
 		dst = ERR_PTR(-ENOMEM);
@@ -1290,7 +1296,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (!table)
 		goto out;
 
-	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, NULL, DST_NOCOUNT);
+	rt = ip6_dst_alloc(net, NULL, DST_NOCOUNT);
 
 	if (!rt) {
 		err = -ENOMEM;
@@ -1812,8 +1818,7 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 				    const struct in6_addr *dest)
 {
 	struct net *net = dev_net(ort->dst.dev);
-	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
-					    ort->dst.dev, 0);
+	struct rt6_info *rt = ip6_dst_alloc(net, ort->dst.dev, 0);
 
 	if (rt) {
 		rt->dst.input = ort->dst.input;
@@ -2097,8 +2102,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    bool anycast)
 {
 	struct net *net = dev_net(idev->dev);
-	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
-					    net->loopback_dev, 0);
+	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev, 0);
 	int err;
 
 	if (!rt) {
@@ -2519,7 +2523,9 @@ static int rt6_fill_node(struct net *net,
 	else
 		expires = INT_MAX;
 
-	peer = rt->rt6i_peer;
+	peer = NULL;
+	if (rt6_has_peer(rt))
+		peer = rt6_peer_ptr(rt);
 	ts = tsage = 0;
 	if (peer && peer->tcp_ts_stamp) {
 		ts = peer->tcp_ts;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 8625fba..d749484 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -99,9 +99,7 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	if (!xdst->u.rt6.rt6i_idev)
 		return -ENODEV;
 
-	xdst->u.rt6.rt6i_peer = rt->rt6i_peer;
-	if (rt->rt6i_peer)
-		atomic_inc(&rt->rt6i_peer->refcnt);
+	rt6_transfer_peer(&xdst->u.rt6, rt);
 
 	/* Sheit... I remember I did this right. Apparently,
 	 * it was magically lost, so this code needs audit */
@@ -223,8 +221,10 @@ static void xfrm6_dst_destroy(struct dst_entry *dst)
 	if (likely(xdst->u.rt6.rt6i_idev))
 		in6_dev_put(xdst->u.rt6.rt6i_idev);
 	dst_destroy_metrics_generic(dst);
-	if (likely(xdst->u.rt6.rt6i_peer))
-		inet_putpeer(xdst->u.rt6.rt6i_peer);
+	if (rt6_has_peer(&xdst->u.rt6)) {
+		struct inet_peer *peer = rt6_peer_ptr(&xdst->u.rt6);
+		inet_putpeer(peer);
+	}
 	xfrm_dst_destroy(xdst);
 }
 
-- 
1.7.10
