From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 4/5] ipv6: Stop rt6_info from using inet_peer's metrics
Date: Tue, 28 Apr 2015 13:03:06 -0700
Message-ID: <1430251387-2942539-5-git-send-email-kafai@fb.com>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Yang Yingliang <yangyingliang@huawei.com>,
	shengyong <shengyong1@huawei.com>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55114 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031020AbbD1UD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 16:03:29 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t3SK3QM4025946
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:03:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1u2d8s8gek-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:03:29 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 a15c8544ede111e491660002c991e86a-6eff82c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 13:03:26 -0700
In-Reply-To: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_peer is indexed by the dst address alone.  However, the fib6 tree
could have multiple routing entries (rt6_info) for the same dst. For
example,
1. A /128 dst via multiple gateways.
2. A RTF_CACHE route cloned from a /128 route.

In the above cases, all of them will share the same metrics and
step on each other.

This patch will steer away from inet_peer's metrics and use
dst_cow_metrics_generic() for everything.

Change Highlights:
1. Remove rt6_cow_metrics() which currently acquires metrics from
   inet_peer for DST_HOST route (i.e. /128 route).
2. Add rt6i_pmtu to take care of the pmtu update to avoid creating a
   full size metrics just to override the RTAX_MTU.
3. After (2), the RTF_CACHE route can also share the metrics with its
   dst.from route, by:
   dst_init_metrics(&cache_rt->dst, dst_metrics_ptr(cache_rt->dst.from), true);
4. Stop creating RTF_CACHE route by cloning another RTF_CACHE route.  Instead,
   directly clone from rt->dst.

   [ Currently, cloning from another RTF_CACHE is only possible during
     rt6_do_redirect().  Also, the old clone is removed from the tree
     immediately after the new clone is added. ]

   In case of cloning from an older redirect RTF_CACHE, it should work as
   before.

   In case of cloning from an older pmtu RTF_CACHE, this patch will forget
   the pmtu and re-learn it (if there is any) from the redirected route.

The _rt6i_peer and DST_METRICS_FORCE_OVERWRITE will be removed
in the next cleanup patch.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/ip6_fib.h |  10 +----
 net/ipv6/route.c      | 102 +++++++++++++++++++++++++++++---------------------
 2 files changed, 60 insertions(+), 52 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 20e80fa..7383a8c 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -124,6 +124,7 @@ struct rt6_info {
 	unsigned long			_rt6i_peer;
 
 	u32				rt6i_metric;
+	u32				rt6i_pmtu;
 	/* more non-fragment space at head required */
 	unsigned short			rt6i_nfheader_len;
 	u8				rt6i_protocol;
@@ -189,15 +190,6 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 	rt0->rt6i_flags |= RTF_EXPIRES;
 }
 
-static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
-{
-	struct dst_entry *new = (struct dst_entry *) from;
-
-	rt->rt6i_flags &= ~RTF_EXPIRES;
-	dst_hold(new);
-	rt->dst.from = new;
-}
-
 static inline void ip6_rt_put(struct rt6_info *rt)
 {
 	/* dst_release() accepts a NULL parameter.
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index aa4cfdd..4d6eb5d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -92,6 +92,7 @@ static void		ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 					   struct sk_buff *skb, u32 mtu);
 static void		rt6_do_redirect(struct dst_entry *dst, struct sock *sk,
 					struct sk_buff *skb);
+static void		rt6_dst_from_metrics_check(struct rt6_info *rt);
 static int rt6_score_route(struct rt6_info *rt, int oif, int strict);
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
@@ -136,33 +137,12 @@ static struct inet_peer *rt6_get_peer_create(struct rt6_info *rt)
 
 static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
-	struct rt6_info *rt = (struct rt6_info *) dst;
-	struct inet_peer *peer;
-	u32 *p = NULL;
+	struct rt6_info *rt = (struct rt6_info *)dst;
 
-	if (!(rt->dst.flags & DST_HOST))
+	if (rt->rt6i_flags & RTF_CACHE)
+		return NULL;
+	else
 		return dst_cow_metrics_generic(dst, old);
-
-	peer = rt6_get_peer_create(rt);
-	if (peer) {
-		u32 *old_p = __DST_METRICS_PTR(old);
-		unsigned long prev, new;
-
-		p = peer->metrics;
-		if (inet_metrics_new(peer) ||
-		    (old & DST_METRICS_FORCE_OVERWRITE))
-			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
-
-		new = (unsigned long) p;
-		prev = cmpxchg(&dst->_metrics, old, new);
-
-		if (prev != old) {
-			p = __DST_METRICS_PTR(prev);
-			if (prev & DST_METRICS_READ_ONLY)
-				p = NULL;
-		}
-	}
-	return p;
 }
 
 static inline const void *choose_neigh_daddr(struct rt6_info *rt,
@@ -323,8 +303,7 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	struct inet6_dev *idev = rt->rt6i_idev;
 	struct dst_entry *from = dst->from;
 
-	if (!(rt->dst.flags & DST_HOST))
-		dst_destroy_metrics_generic(dst);
+	dst_destroy_metrics_generic(dst);
 
 	if (idev) {
 		rt->rt6i_idev = NULL;
@@ -333,11 +312,6 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 
 	dst->from = NULL;
 	dst_release(from);
-
-	if (rt6_has_peer(rt)) {
-		struct inet_peer *peer = rt6_peer_ptr(rt);
-		inet_putpeer(peer);
-	}
 }
 
 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
@@ -1003,6 +977,7 @@ redo_rt6_select:
 	goto redo_fib6_lookup_lock;
 
 out2:
+	rt6_dst_from_metrics_check(rt);
 	rt->dst.lastuse = jiffies;
 	rt->dst.__use++;
 
@@ -1111,6 +1086,13 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
  *	Destination cache support functions
  */
 
+static void rt6_dst_from_metrics_check(struct rt6_info *rt)
+{
+	if (rt->dst.from &&
+	    dst_metrics_ptr(&rt->dst) != dst_metrics_ptr(rt->dst.from))
+		dst_init_metrics(&rt->dst, dst_metrics_ptr(rt->dst.from), true);
+}
+
 static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	struct rt6_info *rt;
@@ -1127,6 +1109,8 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	if (rt6_check_expired(rt))
 		return NULL;
 
+	rt6_dst_from_metrics_check(rt);
+
 	return dst;
 }
 
@@ -1179,7 +1163,7 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 		if (mtu < IPV6_MIN_MTU)
 			mtu = IPV6_MIN_MTU;
 
-		dst_metric_set(dst, RTAX_MTU, mtu);
+		rt6->rt6i_pmtu = mtu;
 		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
 	}
 }
@@ -1359,12 +1343,17 @@ static unsigned int ip6_default_advmss(const struct dst_entry *dst)
 
 static unsigned int ip6_mtu(const struct dst_entry *dst)
 {
+	const struct rt6_info *rt = (const struct rt6_info *)dst;
+	unsigned int mtu = rt->rt6i_pmtu;
 	struct inet6_dev *idev;
-	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
 
 	if (mtu)
 		goto out;
 
+	mtu = dst_metric_raw(dst, RTAX_MTU);
+	if (mtu)
+		goto out;
+
 	mtu = IPV6_MIN_MTU;
 
 	rcu_read_lock();
@@ -1947,12 +1936,27 @@ out:
  *	Misc support functions
  */
 
+static void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
+{
+	BUG_ON(from->dst.from);
+
+	rt->rt6i_flags &= ~RTF_EXPIRES;
+	dst_hold(&from->dst);
+	rt->dst.from = &from->dst;
+	dst_init_metrics(&rt->dst, dst_metrics_ptr(&from->dst), true);
+}
+
 static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 				    const struct in6_addr *dest)
 {
 	struct net *net = dev_net(ort->dst.dev);
-	struct rt6_info *rt = ip6_dst_alloc(net, ort->dst.dev, 0,
-					    ort->rt6i_table);
+	struct rt6_info *rt;
+
+	if (ort->rt6i_flags & RTF_CACHE)
+		ort = (struct rt6_info *)ort->dst.from;
+
+	rt = ip6_dst_alloc(net, ort->dst.dev, 0,
+			   ort->rt6i_table);
 
 	if (rt) {
 		rt->dst.input = ort->dst.input;
@@ -1961,7 +1965,6 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 
 		rt->rt6i_dst.addr = *dest;
 		rt->rt6i_dst.plen = 128;
-		dst_copy_metrics(&rt->dst, &ort->dst);
 		rt->dst.error = ort->dst.error;
 		rt->rt6i_idev = ort->rt6i_idev;
 		if (rt->rt6i_idev)
@@ -2393,11 +2396,20 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	   PMTU discouvery.
 	 */
 	if (rt->dst.dev == arg->dev &&
-	    !dst_metric_locked(&rt->dst, RTAX_MTU) &&
-	    (dst_mtu(&rt->dst) >= arg->mtu ||
-	     (dst_mtu(&rt->dst) < arg->mtu &&
-	      dst_mtu(&rt->dst) == idev->cnf.mtu6))) {
-		dst_metric_set(&rt->dst, RTAX_MTU, arg->mtu);
+	    !dst_metric_locked(&rt->dst, RTAX_MTU)) {
+		if (rt->rt6i_flags & RTF_CACHE) {
+			/* For RTF_CACHE with rt6i_pmtu == 0
+			 * (i.e. a redirected route),
+			 * the metrics of its rt->dst.from has already
+			 * been updated.
+			 */
+			if (rt->rt6i_pmtu && rt->rt6i_pmtu > arg->mtu)
+				rt->rt6i_pmtu = arg->mtu;
+		} else if (dst_mtu(&rt->dst) >= arg->mtu ||
+			   (dst_mtu(&rt->dst) < arg->mtu &&
+			    dst_mtu(&rt->dst) == idev->cnf.mtu6)) {
+			dst_metric_set(&rt->dst, RTAX_MTU, arg->mtu);
+		}
 	}
 	return 0;
 }
@@ -2627,6 +2639,7 @@ static int rt6_fill_node(struct net *net,
 			 int iif, int type, u32 portid, u32 seq,
 			 int prefix, int nowait, unsigned int flags)
 {
+	u32 metrics[RTAX_MAX];
 	struct rtmsg *rtm;
 	struct nlmsghdr *nlh;
 	long expires;
@@ -2740,7 +2753,10 @@ static int rt6_fill_node(struct net *net,
 			goto nla_put_failure;
 	}
 
-	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
+	memcpy(metrics, dst_metrics_ptr(&rt->dst), sizeof(metrics));
+	if (rt->rt6i_pmtu)
+		metrics[RTAX_MTU - 1] = rt->rt6i_pmtu;
+	if (rtnetlink_put_metrics(skb, metrics) < 0)
 		goto nla_put_failure;
 
 	if (rt->rt6i_flags & RTF_GATEWAY) {
-- 
1.8.1
