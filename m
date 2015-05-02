From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next v3 4/9] ipv6: Only create RTF_CACHE routes after encountering pmtu exception
Date: Fri, 1 May 2015 17:26:53 -0700
Message-ID: <1430526418-3132761-5-git-send-email-kafai@fb.com>
References: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:18651 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750947AbbEBA2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 20:28:22 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t420QNE7012799
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 17:28:21 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u4hy5rdwv-5
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 17:28:21 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 21aa082af06211e4a0660002c9521c9e-c52d11e0 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 17:28:19 -0700
In-Reply-To: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a RTF_CACHE routes only after encountering a pmtu
exception.

After ip6_rt_update_pmtu() has inserted the RTF_CACHE route to the fib6
tree, the rt->rt6i_node->fn_sernum is bumped which will fail the
ip6_dst_check() and trigger a relookup.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip6_route.h |   2 +-
 net/ipv6/ip6_fib.c      |   1 +
 net/ipv6/route.c        | 100 ++++++++++++++++++++++++------------------------
 3 files changed, 53 insertions(+), 50 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 4caf7d6..784ee3d 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -202,7 +202,7 @@ static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt,
 {
 	if (rt->rt6i_flags & RTF_GATEWAY)
 		return &rt->rt6i_gateway;
-	else if (rt->rt6i_flags & RTF_CACHE)
+	else if (unlikely(rt->rt6i_flags & RTF_CACHE))
 		return &rt->rt6i_dst.addr;
 	else
 		return daddr;
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 96dbfff..7d66490 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -732,6 +732,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 					rt6_clean_expires(iter);
 				else
 					rt6_set_expires(iter, rt->dst.expires);
+				iter->rt6i_pmtu = rt->rt6i_pmtu;
 				return -EEXIST;
 			}
 			/* If we have the same destination and the same metric,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9e63c5c..b207eca 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -873,16 +873,13 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 				      struct flowi6 *fl6, int flags)
 {
 	struct fib6_node *fn, *saved_fn;
-	struct rt6_info *rt, *nrt;
+	struct rt6_info *rt;
 	int strict = 0;
-	int attempts = 3;
-	int err;
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
 	if (net->ipv6.devconf_all->forwarding == 0)
 		strict |= RT6_LOOKUP_F_REACHABLE;
 
-redo_fib6_lookup_lock:
 	read_lock_bh(&table->tb6_lock);
 
 	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
@@ -901,46 +898,12 @@ redo_rt6_select:
 			strict &= ~RT6_LOOKUP_F_REACHABLE;
 			fn = saved_fn;
 			goto redo_rt6_select;
-		} else {
-			dst_hold(&rt->dst);
-			read_unlock_bh(&table->tb6_lock);
-			goto out2;
 		}
 	}
 
 	dst_hold(&rt->dst);
 	read_unlock_bh(&table->tb6_lock);
 
-	if (rt->rt6i_flags & RTF_CACHE)
-		goto out2;
-
-	if (!rt6_is_gw_or_nonexthop(rt) ||
-	    !(rt->dst.flags & DST_HOST) || !(rt->dst.flags & RTF_LOCAL))
-		nrt = ip6_rt_cache_alloc(rt, &fl6->daddr, &fl6->saddr);
-	else
-		goto out2;
-
-	ip6_rt_put(rt);
-	rt = nrt ? : net->ipv6.ip6_null_entry;
-
-	dst_hold(&rt->dst);
-	if (nrt) {
-		err = ip6_ins_rt(nrt);
-		if (!err)
-			goto out2;
-	}
-
-	if (--attempts <= 0)
-		goto out2;
-
-	/*
-	 * Race condition! In the gap, when table->tb6_lock was
-	 * released someone could insert this route.  Relookup.
-	 */
-	ip6_rt_put(rt);
-	goto redo_fib6_lookup_lock;
-
-out2:
 	rt6_dst_from_metrics_check(rt);
 	rt->dst.lastuse = jiffies;
 	rt->dst.__use++;
@@ -1113,24 +1076,63 @@ static void ip6_link_failure(struct sk_buff *skb)
 	}
 }
 
-static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
-			       struct sk_buff *skb, u32 mtu)
+static void rt6_do_update_pmtu(struct rt6_info *rt, u32 mtu)
+{
+	struct net *net = dev_net(rt->dst.dev);
+
+	rt->rt6i_flags |= RTF_MODIFIED;
+	rt->rt6i_pmtu = mtu;
+	rt6_update_expires(rt, net->ipv6.sysctl.ip6_rt_mtu_expires);
+}
+
+static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
+				 const struct ipv6hdr *iph, u32 mtu)
 {
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
 
-	dst_confirm(dst);
-	if (mtu < dst_mtu(dst) && (rt6->rt6i_flags & RTF_CACHE)) {
-		struct net *net = dev_net(dst->dev);
+	if (rt6->rt6i_flags & RTF_LOCAL)
+		return;
 
-		rt6->rt6i_flags |= RTF_MODIFIED;
-		if (mtu < IPV6_MIN_MTU)
-			mtu = IPV6_MIN_MTU;
+	dst_confirm(dst);
+	mtu = max_t(u32, mtu, IPV6_MIN_MTU);
+	if (mtu >= dst_mtu(dst))
+		return;
 
-		rt6->rt6i_pmtu = mtu;
-		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
+	if (rt6->rt6i_flags & RTF_CACHE) {
+		rt6_do_update_pmtu(rt6, mtu);
+	} else {
+		const struct in6_addr *daddr, *saddr;
+		struct rt6_info *nrt6;
+
+		if (iph) {
+			daddr = &iph->daddr;
+			saddr = &iph->saddr;
+		} else if (sk) {
+			daddr = &sk->sk_v6_daddr;
+			saddr = &inet6_sk(sk)->saddr;
+		} else {
+			return;
+		}
+		nrt6 = ip6_rt_cache_alloc(rt6, daddr, saddr);
+		if (nrt6) {
+			rt6_do_update_pmtu(nrt6, mtu);
+
+			/* ip6_ins_rt(nrt6) will bump the
+			 * rt6->rt6i_node->fn_sernum
+			 * which will fail the next rt6_check() and
+			 * invalidate the sk->sk_dst_cache.
+			 */
+			ip6_ins_rt(nrt6);
+		}
 	}
 }
 
+static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			       struct sk_buff *skb, u32 mtu)
+{
+	__ip6_rt_update_pmtu(dst, sk, skb ? ipv6_hdr(skb) : NULL, mtu);
+}
+
 void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 		     int oif, u32 mark)
 {
@@ -1147,7 +1149,7 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst->error)
-		ip6_rt_update_pmtu(dst, NULL, skb, ntohl(mtu));
+		__ip6_rt_update_pmtu(dst, NULL, iph, ntohl(mtu));
 	dst_release(dst);
 }
 EXPORT_SYMBOL_GPL(ip6_update_pmtu);
-- 
1.8.1
