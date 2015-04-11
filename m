From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH 04/10] ipv6: Only create RTF_CACHE routes after encountering pmtu exception
Date: Fri, 10 Apr 2015 18:54:07 -0700
Message-ID: <1428717253-1006248-5-git-send-email-kafai@fb.com>
References: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43511 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754973AbbDKByd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:54:33 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3B1pHxx010332
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:54:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1tpqvkrc85-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:54:32 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 b13f787edfed11e4a80d0002c992ebde-33bf82c0 for <netdev@vger.kernel.org>;	Fri,
 10 Apr 2015 18:54:30 -0700
In-Reply-To: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a RTF_CACHE routes only after encountering a pmtu exception.

After ip6_rt_update_pmtu() has inserted the RTF_CACHE route to the fib6 tree,
the rt->rt6i_node->fn_sernum will be bumped which fails the ip6_dst_check() and
triggers a relookup.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 92 ++++++++++++++++++++++++++++++--------------------------
 1 file changed, 49 insertions(+), 43 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f753a67..1b57bc9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -907,16 +907,13 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
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
@@ -935,46 +932,12 @@ redo_rt6_select:
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
-	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)) ||
-	    !(rt->dst.flags & DST_HOST))
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
 	rt->dst.lastuse = jiffies;
 	rt->dst.__use++;
 
@@ -1144,13 +1107,49 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
 
 	dst_confirm(dst);
-	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
+	mtu = max_t(u32, mtu, IPV6_MIN_MTU);
+	if (mtu >= dst_mtu(dst))
+		return;
+
+	if (!(rt6->rt6i_flags & RTF_CACHE) &&
+	    (!(rt6->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)) ||
+	     !(rt6->dst.flags & DST_HOST))) {
+		const struct in6_addr *daddr, *saddr;
+		struct rt6_info *nrt6;
+
+		if (skb) {
+			const struct ipv6hdr *iph = ipv6_hdr(skb);
+
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
+	} else {
+		rt6 = (struct rt6_info *)dst;
+	}
+
+	if (rt6->rt6i_dst.plen == 128) {
 		struct net *net = dev_net(dst->dev);
 
 		rt6->rt6i_flags |= RTF_MODIFIED;
-		if (mtu < IPV6_MIN_MTU)
-			mtu = IPV6_MIN_MTU;
-
 		dst_metric_set(dst, RTAX_MTU, mtu);
 		rt6_update_expires(rt6, net->ipv6.sysctl.ip6_rt_mtu_expires);
 	}
@@ -1171,8 +1170,15 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 	fl6.flowlabel = ip6_flowinfo(iph);
 
 	dst = ip6_route_output(net, NULL, &fl6);
-	if (!dst->error)
+	if (!dst->error) {
+		unsigned char *outer_network_header = skb_network_header(skb);
+		int offset;
+
+		skb_reset_network_header(skb);
+		offset = outer_network_header - skb_network_header(skb);
 		ip6_rt_update_pmtu(dst, NULL, skb, ntohl(mtu));
+		skb_set_network_header(skb, offset);
+	}
 	dst_release(dst);
 }
 EXPORT_SYMBOL_GPL(ip6_update_pmtu);
-- 
1.8.1
