From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 4/6] ipv6: Only create RTF_CACHE routes after encountering pmtu exception
Date: Tue, 28 Apr 2015 14:07:51 -0700
Message-ID: <1430255273-3045254-5-git-send-email-kafai@fb.com>
References: <1430255273-3045254-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:11774 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030957AbbD1VIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 17:08:14 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3SL6v3H008757
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 14:08:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u2eyhgc0r-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 14:08:13 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 ae1a85f2edea11e4a08a0002c95209d8-a9ea92c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 14:08:12 -0700
In-Reply-To: <1430255273-3045254-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a RTF_CACHE routes only after encountering a pmtu
exception.

After ip6_rt_update_pmtu() has inserted the RTF_CACHE route to the fib6
tree, the rt->rt6i_node->fn_sernum is bumped which will fail the
ip6_dst_check() and trigger a relookup.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/route.c | 96 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 48 insertions(+), 48 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8bc83bc..09ab0f4 100644
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
-		nrt = ip6_pmtu_rt_cache_alloc(rt, &fl6->daddr, &fl6->saddr);
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
@@ -1113,22 +1076,59 @@ static void ip6_link_failure(struct sk_buff *skb)
 	}
 }
 
-static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
-			       struct sk_buff *skb, u32 mtu)
+static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
+				 const struct ipv6hdr *iph, u32 mtu)
 {
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
+	struct net *net;
+
+	if (rt6->rt6i_flags & RTF_LOCAL)
+		return;
 
 	dst_confirm(dst);
-	if (mtu < dst_mtu(dst) && (rt6->rt6i_flags & RTF_CACHE)) {
-		struct net *net = dev_net(dst->dev);
+	mtu = max_t(u32, mtu, IPV6_MIN_MTU);
+	if (mtu >= dst_mtu(dst))
+		return;
 
-		rt6->rt6i_flags |= RTF_MODIFIED;
-		if (mtu < IPV6_MIN_MTU)
-			mtu = IPV6_MIN_MTU;
+	if (!(rt6->rt6i_flags & RTF_CACHE)) {
+		const struct in6_addr *daddr, *saddr;
+		struct rt6_info *nrt6;
 
-		rt6->rt6i_pmtu = mtu;
-		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
+		if (iph) {
+			daddr = &iph->daddr;
+			saddr = &iph->saddr;
+		} else if (sk) {
+			daddr = &sk->sk_v6_daddr;
+			saddr = &inet6_sk(sk)->saddr;
+		} else {
+			return;
+		}
+		nrt6 = ip6_pmtu_rt_cache_alloc(rt6, daddr, saddr);
+		if (!nrt6)
+			return;
+		/* ip6_ins_rt(nrt6) will bump the rt6->rt6i_node->fn_sernum
+		 * which will fail the next rt6_check() and invalidate the
+		 * sk->sk_dst_cache.
+		 */
+		if (ip6_ins_rt(nrt6)) {
+			dst_destroy(&nrt6->dst);
+			return;
+		}
+
+		rt6 = nrt6;
+		dst = &nrt6->dst;
 	}
+
+	net = dev_net(dst->dev);
+	rt6->rt6i_flags |= RTF_MODIFIED;
+	rt6->rt6i_pmtu = mtu;
+	rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
+}
+
+static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
+			       struct sk_buff *skb, u32 mtu)
+{
+	__ip6_rt_update_pmtu(dst, sk, skb ? ipv6_hdr(skb) : NULL, mtu);
 }
 
 void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
@@ -1147,7 +1147,7 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst->error)
-		ip6_rt_update_pmtu(dst, NULL, skb, ntohl(mtu));
+		__ip6_rt_update_pmtu(dst, NULL, iph, ntohl(mtu));
 	dst_release(dst);
 }
 EXPORT_SYMBOL_GPL(ip6_update_pmtu);
-- 
1.8.1
