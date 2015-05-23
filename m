From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v5 06/11] ipv6: Add rt6_get_cookie() function
Date: Fri, 22 May 2015 20:56:01 -0700
Message-ID: <1432353366-2296465-7-git-send-email-kafai@fb.com>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38292 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946073AbbEWD4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 23:56:19 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t4N3tUZp031359
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 20:56:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1ujbmy0gys-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 20:56:15 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 a73f469600ff11e5ac510002c9521c9e-17c9f6e0 for <netdev@vger.kernel.org>;	Fri,
 22 May 2015 20:56:12 -0700
In-Reply-To: <1432353366-2296465-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of doing the rt6->rt6i_node check whenever we need
to get the route's cookie.  Refactor it into rt6_get_cookie().
It is a prep work to handle FLOWI_FLAG_KNOWN_NH and also
percpu rt6_info later.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip6_fib.h           | 5 +++++
 include/net/ip6_route.h         | 2 +-
 net/ipv6/ip6_tunnel.c           | 2 +-
 net/ipv6/tcp_ipv6.c             | 3 +--
 net/ipv6/xfrm6_policy.c         | 6 ++----
 net/netfilter/ipvs/ip_vs_xmit.c | 2 +-
 net/sctp/ipv6.c                 | 2 +-
 7 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index e000180..a4bece6 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -159,6 +159,11 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 	rt0->rt6i_flags |= RTF_EXPIRES;
 }
 
+static inline u32 rt6_get_cookie(const struct rt6_info *rt)
+{
+	return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
+}
+
 static inline void ip6_rt_put(struct rt6_info *rt)
 {
 	/* dst_release() accepts a NULL parameter.
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 784ee3d..297629a 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -145,7 +145,7 @@ static inline void __ip6_dst_store(struct sock *sk, struct dst_entry *dst,
 #ifdef CONFIG_IPV6_SUBTREES
 	np->saddr_cache = saddr;
 #endif
-	np->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
+	np->dst_cookie = rt6_get_cookie(rt);
 }
 
 static inline void ip6_dst_store(struct sock *sk, struct dst_entry *dst,
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 5cafd92..2e67b66 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -151,7 +151,7 @@ EXPORT_SYMBOL_GPL(ip6_tnl_dst_reset);
 void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *) dst;
-	t->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
+	t->dst_cookie = rt6_get_cookie(rt);
 	dst_release(t->dst_cache);
 	t->dst_cache = dst;
 }
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2275999..c656c03 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -99,8 +99,7 @@ static void inet6_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
 		dst_hold(dst);
 		sk->sk_rx_dst = dst;
 		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
-		if (rt->rt6i_node)
-			inet6_sk(sk)->rx_dst_cookie = rt->rt6i_node->fn_sernum;
+		inet6_sk(sk)->rx_dst_cookie = rt6_get_cookie(rt);
 	}
 }
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 6ae256b..ed0583c 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -76,8 +76,7 @@ static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 {
 	if (dst->ops->family == AF_INET6) {
 		struct rt6_info *rt = (struct rt6_info *)dst;
-		if (rt->rt6i_node)
-			path->path_cookie = rt->rt6i_node->fn_sernum;
+		path->path_cookie = rt6_get_cookie(rt);
 	}
 
 	path->u.rt6.rt6i_nfheader_len = nfheader_len;
@@ -105,8 +104,7 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 						   RTF_LOCAL);
 	xdst->u.rt6.rt6i_metric = rt->rt6i_metric;
 	xdst->u.rt6.rt6i_node = rt->rt6i_node;
-	if (rt->rt6i_node)
-		xdst->route_cookie = rt->rt6i_node->fn_sernum;
+	xdst->route_cookie = rt6_get_cookie(rt);
 	xdst->u.rt6.rt6i_gateway = rt->rt6i_gateway;
 	xdst->u.rt6.rt6i_dst = rt->rt6i_dst;
 	xdst->u.rt6.rt6i_src = rt->rt6i_src;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 38f8627..5eff9f6 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -435,7 +435,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 				goto err_unreach;
 			}
 			rt = (struct rt6_info *) dst;
-			cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
+			cookie = rt6_get_cookie(rt);
 			__ip_vs_dst_set(dest, dest_dst, &rt->dst, cookie);
 			spin_unlock_bh(&dest->dst_lock);
 			IP_VS_DBG(10, "new dst %pI6, src %pI6, refcnt=%d\n",
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 17a0120..e917d27 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -331,7 +331,7 @@ out:
 
 		rt = (struct rt6_info *)dst;
 		t->dst = dst;
-		t->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
+		t->dst_cookie = rt6_get_cookie(rt);
 		pr_debug("rt6_dst:%pI6/%d rt6_src:%pI6\n",
 			 &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
 			 &fl6->saddr);
-- 
1.8.1
