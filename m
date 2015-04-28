From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 6/6] ipv6: Create percpu rt6_info
Date: Tue, 28 Apr 2015 14:07:53 -0700
Message-ID: <1430255273-3045254-7-git-send-email-kafai@fb.com>
References: <1430255273-3045254-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57005 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030931AbbD1VJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 17:09:13 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3SL8u8v012214
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 14:09:12 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u2fn7ggcu-6
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 14:09:12 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 ae2da6aaedea11e4b8880002c991e86a-8caa2c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 14:08:13 -0700
In-Reply-To: <1430255273-3045254-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the patch
'ipv6: Only create RTF_CACHE routes after encountering pmtu exception',
we need to compensate the performance hit (bouncing dst->__refcnt).

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/ip6_fib.h           |   8 +++
 include/net/ip6_route.h         |   2 +-
 include/uapi/linux/ipv6_route.h |   1 +
 net/ipv6/ip6_fib.c              |  25 ++++++-
 net/ipv6/ip6_tunnel.c           |   2 +-
 net/ipv6/route.c                | 150 +++++++++++++++++++++++++++++++++++-----
 net/ipv6/tcp_ipv6.c             |   3 +-
 net/ipv6/xfrm6_policy.c         |   6 +-
 net/netfilter/ipvs/ip_vs_xmit.c |   2 +-
 net/sctp/ipv6.c                 |   2 +-
 10 files changed, 171 insertions(+), 30 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index e000180..4b1fc9b 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -121,6 +121,7 @@ struct rt6_info {
 	struct rt6key			rt6i_prefsrc;
 
 	struct inet6_dev		*rt6i_idev;
+	struct rt6_info __rcu * __percpu	*rt6i_pcpu;
 
 	u32				rt6i_metric;
 	u32				rt6i_pmtu;
@@ -159,6 +160,13 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 	rt0->rt6i_flags |= RTF_EXPIRES;
 }
 
+static inline u32 rt6_get_cookie(const struct rt6_info *rt)
+{
+	if (rt->rt6i_flags & RTF_PCPU)
+		rt = (struct rt6_info *)(rt->dst.from);
+	return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
+}
+
 static inline void ip6_rt_put(struct rt6_info *rt)
 {
 	/* dst_release() accepts a NULL parameter.
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 0e4d170..397dd3a 100644
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
diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
index 2be7bd1..f6598d1 100644
--- a/include/uapi/linux/ipv6_route.h
+++ b/include/uapi/linux/ipv6_route.h
@@ -34,6 +34,7 @@
 #define RTF_PREF(pref)	((pref) << 27)
 #define RTF_PREF_MASK	0x18000000
 
+#define RTF_PCPU	0x40000000
 #define RTF_LOCAL	0x80000000
 
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 96dbfff..bf12be7 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -154,10 +154,33 @@ static void node_free(struct fib6_node *fn)
 	kmem_cache_free(fib6_node_kmem, fn);
 }
 
+static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
+{
+	int cpu;
+
+	if (!non_pcpu_rt->rt6i_pcpu)
+		return;
+
+	for_each_possible_cpu(cpu) {
+		struct rt6_info **ppcpu_rt;
+		struct rt6_info *pcpu_rt;
+
+		ppcpu_rt = per_cpu_ptr(non_pcpu_rt->rt6i_pcpu, cpu);
+		pcpu_rt = rcu_dereference_protected(*ppcpu_rt,
+			lockdep_is_held(&non_pcpu_rt->rt6i_table->tb6_lock));
+		if (pcpu_rt) {
+			dst_free(&pcpu_rt->dst);
+			*ppcpu_rt = NULL;
+		}
+	}
+}
+
 static void rt6_release(struct rt6_info *rt)
 {
-	if (atomic_dec_and_test(&rt->rt6i_ref))
+	if (atomic_dec_and_test(&rt->rt6i_ref)) {
+		rt6_free_pcpu(rt);
 		dst_free(&rt->dst);
+	}
 }
 
 static void fib6_link_table(struct net *net, struct fib6_table *tb)
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
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cb3c585..29227a0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -108,11 +108,18 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 					   const struct in6_addr *gwaddr, int ifindex);
 #endif
 
+static u32 *rt6_pcpu_cow_metrics(struct rt6_info *rt)
+{
+	return dst_metrics_write_ptr(rt->dst.from);
+}
+
 static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
 	struct rt6_info *rt = (struct rt6_info *)dst;
 
-	if (rt->rt6i_flags & RTF_CACHE)
+	if (rt->rt6i_flags & RTF_PCPU)
+		return rt6_pcpu_cow_metrics(rt);
+	else if (rt->rt6i_flags & RTF_CACHE)
 		return NULL;
 	else
 		return dst_cow_metrics_generic(dst, old);
@@ -252,10 +259,10 @@ static const struct rt6_info ip6_blk_hole_entry_template = {
 #endif
 
 /* allocate dst with ip6_dst_ops */
-static inline struct rt6_info *ip6_dst_alloc(struct net *net,
-					     struct net_device *dev,
-					     int flags,
-					     struct fib6_table *table)
+static struct rt6_info *__ip6_dst_alloc(struct net *net,
+					struct net_device *dev,
+					int flags,
+					struct fib6_table *table)
 {
 	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
 					0, DST_OBSOLETE_FORCE_CHK, flags);
@@ -269,6 +276,34 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 	return rt;
 }
 
+static struct rt6_info *ip6_dst_alloc(struct net *net,
+				      struct net_device *dev,
+				      int flags,
+				      struct fib6_table *table)
+{
+	struct rt6_info *rt = __ip6_dst_alloc(net, dev, flags, table);
+
+	if (rt) {
+		rt->rt6i_pcpu = alloc_percpu_gfp(struct rt6_info *, GFP_ATOMIC);
+		if (rt->rt6i_pcpu) {
+			int cpu;
+
+			for_each_possible_cpu(cpu) {
+				struct rt6_info **p;
+
+				p = per_cpu_ptr(rt->rt6i_pcpu, cpu);
+				/* no one shares rt */
+				*p =  NULL;
+			}
+		} else {
+			dst_destroy((struct dst_entry *)rt);
+			return NULL;
+		}
+	}
+
+	return rt;
+}
+
 static void ip6_dst_destroy(struct dst_entry *dst)
 {
 	struct rt6_info *rt = (struct rt6_info *)dst;
@@ -277,6 +312,9 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 
 	dst_destroy_metrics_generic(dst);
 
+	if (rt->rt6i_pcpu)
+		free_percpu(rt->rt6i_pcpu);
+
 	if (idev) {
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
@@ -870,11 +908,69 @@ static struct rt6_info *ip6_pmtu_rt_cache_alloc(struct rt6_info *ort,
 	return rt;
 }
 
+static struct rt6_info *ip6_rt_pcpu_alloc(struct rt6_info *rt)
+{
+	struct rt6_info *pcpu_rt;
+
+	pcpu_rt = __ip6_dst_alloc(dev_net(rt->dst.dev),
+				  rt->dst.dev, rt->dst.flags,
+				  rt->rt6i_table);
+
+	if (!pcpu_rt)
+		return NULL;
+	ip6_rt_copy_init(pcpu_rt, rt, NULL);
+	pcpu_rt->rt6i_protocol = rt->rt6i_protocol;
+	pcpu_rt->rt6i_flags |= RTF_PCPU;
+	return pcpu_rt;
+}
+
+static struct rt6_info *rt6_get_pcpu_route(struct rt6_info *rt)
+{
+	struct rt6_info *pcpu_rt, *orig, *prev, **p;
+	struct net *net = dev_net(rt->dst.dev);
+
+	if (rt == net->ipv6.ip6_null_entry || rt->rt6i_flags & RTF_CACHE)
+		goto done;
+
+	rcu_read_lock();
+	p = raw_cpu_ptr(rt->rt6i_pcpu);
+	orig = rcu_dereference_check(*p,
+				     lockdep_is_held(&rt->rt6i_table->tb6_lock));
+	if (orig) {
+		rt6_dst_from_metrics_check(orig);
+		dst_hold(&orig->dst);
+		rcu_read_unlock();
+		return orig;
+	}
+	rcu_read_unlock();
+
+	pcpu_rt = ip6_rt_pcpu_alloc(rt);
+	if (!pcpu_rt) {
+		rt = net->ipv6.ip6_null_entry;
+		goto done;
+	}
+	dst_hold(&pcpu_rt->dst);
+
+	prev = cmpxchg(p, orig, pcpu_rt);
+	if (prev == orig) {
+		if (orig)
+			call_rcu(&orig->dst.rcu_head, dst_rcu_free);
+	} else {
+		pcpu_rt->dst.flags |= DST_NOCACHE;
+	}
+	return pcpu_rt;
+
+done:
+	rt6_dst_from_metrics_check(rt);
+	dst_hold(&rt->dst);
+	return rt;
+}
+
 static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
 				      struct flowi6 *fl6, int flags)
 {
 	struct fib6_node *fn, *saved_fn;
-	struct rt6_info *rt;
+	struct rt6_info *rt, *pcpu_rt;
 	int strict = 0;
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
@@ -902,14 +998,13 @@ redo_rt6_select:
 		}
 	}
 
-	dst_hold(&rt->dst);
+	pcpu_rt = rt6_get_pcpu_route(rt);
 	read_unlock_bh(&table->tb6_lock);
 
-	rt6_dst_from_metrics_check(rt);
 	rt->dst.lastuse = jiffies;
 	rt->dst.__use++;
 
-	return rt;
+	return pcpu_rt;
 }
 
 static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
@@ -1020,6 +1115,26 @@ static void rt6_dst_from_metrics_check(struct rt6_info *rt)
 		dst_init_metrics(&rt->dst, dst_metrics_ptr(rt->dst.from), true);
 }
 
+static struct dst_entry *rt6_check(struct rt6_info *rt, u32 cookie)
+{
+	if (!rt->rt6i_node || rt->rt6i_node->fn_sernum != cookie)
+		return NULL;
+
+	if (rt6_check_expired(rt))
+		return NULL;
+
+	return &rt->dst;
+}
+
+static struct dst_entry *rt6_pcpu_check(struct rt6_info *rt, u32 cookie)
+{
+	if (rt->dst.obsolete == DST_OBSOLETE_FORCE_CHK &&
+	    rt6_check((struct rt6_info *)(rt->dst.from), cookie))
+		return &rt->dst;
+	else
+		return NULL;
+}
+
 static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	struct rt6_info *rt;
@@ -1030,15 +1145,12 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
 	 * into this function always.
 	 */
-	if (!rt->rt6i_node || (rt->rt6i_node->fn_sernum != cookie))
-		return NULL;
-
-	if (rt6_check_expired(rt))
-		return NULL;
-
 	rt6_dst_from_metrics_check(rt);
 
-	return dst;
+	if (rt->rt6i_flags & RTF_PCPU)
+		return rt6_pcpu_check(rt, cookie);
+	else
+		return rt6_check(rt, cookie);
 }
 
 static struct dst_entry *ip6_negative_advice(struct dst_entry *dst)
@@ -1943,11 +2055,11 @@ static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
 {
 	struct rt6_info *rt;
 
-	if (ort->rt6i_flags & RTF_CACHE)
+	if (ort->rt6i_flags & (RTF_PCPU | RTF_CACHE))
 		ort = (struct rt6_info *)ort->dst.from;
 
-	rt = ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
-			   0, ort->rt6i_table);
+	rt = __ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
+			     0, ort->rt6i_table);
 
 	if (!rt)
 		return NULL;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 042a645..b416305 100644
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
index 9fa13f6..d012834 100644
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
