From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH 10/10] ipv6: Create percpu rt6_info
Date: Fri, 10 Apr 2015 18:54:13 -0700
Message-ID: <1428717253-1006248-11-git-send-email-kafai@fb.com>
References: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44928 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755210AbbDKByd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:54:33 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3B1s93L002366
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:54:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1tpqk1gc7v-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:54:33 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 b19f786edfed11e4aeea0002c9521c9e-f31d32c0 for <netdev@vger.kernel.org>;	Fri,
 10 Apr 2015 18:54:31 -0700
In-Reply-To: <1428717253-1006248-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the patch
'ipv6: Only create RTF_CACHE routes after encountering pmtu exceptions',
we need to compensate the performance hit (bouncing dst->__refcnt).

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h           |   8 ++
 include/net/ip6_route.h         |   2 +-
 include/uapi/linux/ipv6_route.h |   1 +
 net/ipv6/ip6_fib.c              |  22 +++++-
 net/ipv6/ip6_tunnel.c           |   2 +-
 net/ipv6/route.c                | 163 +++++++++++++++++++++++++++++++++++-----
 net/ipv6/tcp_ipv6.c             |   3 +-
 net/ipv6/xfrm6_policy.c         |   4 +-
 net/netfilter/ipvs/ip_vs_xmit.c |   2 +-
 net/sctp/ipv6.c                 |   2 +-
 10 files changed, 182 insertions(+), 27 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 20e80fa..65702c5 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -124,6 +124,7 @@ struct rt6_info {
 	unsigned long			_rt6i_peer;
 
 	u32				rt6i_metric;
+	struct rt6_info __rcu * __percpu	*rt6i_pcpu;
 	/* more non-fragment space at head required */
 	unsigned short			rt6i_nfheader_len;
 	u8				rt6i_protocol;
@@ -198,6 +199,13 @@ static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
 	rt->dst.from = new;
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
index 96dbfff..6aa9b80 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -154,10 +154,30 @@ static void node_free(struct fib6_node *fn)
 	kmem_cache_free(fib6_node_kmem, fn);
 }
 
+static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
+{
+	int cpu;
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
index 665e41c..14f99c1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -137,9 +137,16 @@ static struct inet_peer *rt6_get_peer_create(struct rt6_info *rt)
 	return __rt6_get_peer(rt, 1);
 }
 
-static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
+static u32 *rt6_pcpu_cow_metrics(struct rt6_info *rt)
 {
-	struct rt6_info *rt = (struct rt6_info *) dst;
+	rt = (struct rt6_info *)rt->dst.from;
+	BUG_ON(rt->rt6i_flags & RTF_PCPU);
+	return dst_metrics_write_ptr(&rt->dst);
+}
+
+static u32 *rt6_cow_metrics(struct rt6_info *rt, unsigned long old)
+{
+	struct dst_entry *dst = &rt->dst;
 	struct inet_peer *peer;
 	u32 *p = NULL;
 
@@ -168,6 +175,16 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
+static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
+{
+	struct rt6_info *rt = (struct rt6_info *)dst;
+
+	if (rt->rt6i_flags & RTF_PCPU)
+		return rt6_pcpu_cow_metrics(rt);
+	else
+		return rt6_cow_metrics(rt, old);
+}
+
 static inline const void *choose_neigh_daddr(struct rt6_info *rt,
 					     struct sk_buff *skb,
 					     const void *daddr)
@@ -302,10 +319,10 @@ static const struct rt6_info ip6_blk_hole_entry_template = {
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
@@ -320,6 +337,34 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
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
@@ -337,6 +382,9 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	if (peer_metrics != dst->_metrics)
 		dst_destroy_metrics_generic(dst);
 
+	if (rt->rt6i_pcpu)
+		free_percpu(rt->rt6i_pcpu);
+
 	if (idev) {
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
@@ -925,11 +973,68 @@ static struct rt6_info *ip6_pmtu_rt_cache_alloc(struct rt6_info *ort,
 	return rt;
 }
 
+static struct rt6_info *ip6_rt_pcpu_alloc(struct rt6_info *rt)
+{
+	struct rt6_info *pcpu_rt = __ip6_dst_alloc(dev_net(rt->dst.dev),
+						   rt->dst.dev, rt->dst.flags,
+						   rt->rt6i_table);
+
+	if (!pcpu_rt)
+		return NULL;
+	ip6_rt_copy_init(pcpu_rt, rt, NULL);
+	pcpu_rt->dst._metrics = (rt->dst._metrics | DST_METRICS_READ_ONLY);
+	rt6_set_from(pcpu_rt, rt);
+	pcpu_rt->rt6i_metric = rt->rt6i_metric;
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
+	if (rt->rt6i_flags & RTF_CACHE || rt == net->ipv6.ip6_null_entry)
+		goto done;
+
+	rcu_read_lock();
+	p = raw_cpu_ptr(rt->rt6i_pcpu);
+	orig = rcu_dereference_check(*p,
+				     lockdep_is_held(&rt->rt6i_table->tb6_lock));
+	if (orig &&
+	    dst_metrics_ptr(orig->dst.from) == dst_metrics_ptr(&orig->dst)) {
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
+
+	prev = cmpxchg(p, orig, pcpu_rt);
+	if (prev == orig) {
+		if (orig)
+			call_rcu(&orig->dst.rcu_head, dst_rcu_free);
+	} else {
+		pcpu_rt->dst.flags |= DST_NOCACHE;
+	}
+	rt = pcpu_rt;
+
+done:
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
@@ -957,13 +1062,13 @@ redo_rt6_select:
 		}
 	}
 
-	dst_hold(&rt->dst);
+	pcpu_rt = rt6_get_pcpu_route(rt);
 	read_unlock_bh(&table->tb6_lock);
 
 	rt->dst.lastuse = jiffies;
 	rt->dst.__use++;
 
-	return rt;
+	return pcpu_rt;
 }
 
 static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
@@ -1068,6 +1173,26 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
  *	Destination cache support functions
  */
 
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
+	    dst_metrics_ptr(rt->dst.from) == dst_metrics_ptr(&rt->dst))
+		return rt6_check((struct rt6_info *)(rt->dst.from), cookie);
+	else
+		return NULL;
+}
+
 static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	struct rt6_info *rt;
@@ -1078,13 +1203,10 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
 	 * into this function always.
 	 */
-	if (!rt->rt6i_node || (rt->rt6i_node->fn_sernum != cookie))
-		return NULL;
-
-	if (rt6_check_expired(rt))
-		return NULL;
-
-	return dst;
+	if (rt->rt6i_flags & RTF_PCPU)
+		return rt6_pcpu_check(rt, cookie);
+	else
+		return rt6_check(rt, cookie);
 }
 
 static struct dst_entry *ip6_negative_advice(struct dst_entry *dst)
@@ -1978,8 +2100,13 @@ static void ip6_rt_copy_init(struct rt6_info *rt,
 static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
 					   const struct in6_addr *dest)
 {
-	struct rt6_info *rt = ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
-					    0, ort->rt6i_table);
+	struct rt6_info *rt;
+
+	if (ort->rt6i_flags & RTF_PCPU)
+		ort = (struct rt6_info *)ort->dst.from;
+
+	rt = __ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
+			     0, ort->rt6i_table);
 
 	if (!rt)
 		return NULL;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index dfcca70..e2e9576 100644
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
index f337a90..e818c61 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -84,7 +84,7 @@ static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 	if (dst->ops->family == AF_INET6) {
 		struct rt6_info *rt = (struct rt6_info *)dst;
 		if (rt->rt6i_node)
-			path->path_cookie = rt->rt6i_node->fn_sernum;
+			path->path_cookie = rt6_get_cookie(rt);
 	}
 
 	path->u.rt6.rt6i_nfheader_len = nfheader_len;
@@ -115,7 +115,7 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.rt6.rt6i_metric = rt->rt6i_metric;
 	xdst->u.rt6.rt6i_node = rt->rt6i_node;
 	if (rt->rt6i_node)
-		xdst->route_cookie = rt->rt6i_node->fn_sernum;
+		xdst->route_cookie = rt6_get_cookie(rt);
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
