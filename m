From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next v3 9/9] ipv6: Create percpu rt6_info
Date: Fri, 1 May 2015 17:26:58 -0700
Message-ID: <1430526418-3132761-10-git-send-email-kafai@fb.com>
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
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58418 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751056AbbEBA2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 20:28:23 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t420QfAc014305
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 17:28:22 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u4djf8uf0-9
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 17:28:22 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 222b0a92f06211e4a2690002c9521c9e-c9ada1e0 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 17:28:20 -0700
In-Reply-To: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the patch
'ipv6: Only create RTF_CACHE routes after encountering pmtu exception',
we need to compensate the performance hit (bouncing dst->__refcnt).

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip6_fib.h           |   3 +-
 include/uapi/linux/ipv6_route.h |   1 +
 net/ipv6/ip6_fib.c              |  25 +++++++-
 net/ipv6/route.c                | 135 +++++++++++++++++++++++++++++++++++-----
 4 files changed, 146 insertions(+), 18 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 5556111..25704a6 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -121,6 +121,7 @@ struct rt6_info {
 	struct rt6key			rt6i_prefsrc;
 
 	struct inet6_dev		*rt6i_idev;
+	struct rt6_info __rcu * __percpu	*rt6i_pcpu;
 
 	u32				rt6i_metric;
 	u32				rt6i_pmtu;
@@ -161,7 +162,7 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
 
 static inline u32 rt6_get_cookie(const struct rt6_info *rt)
 {
-	if (unlikely(rt->dst.flags & DST_NOCACHE))
+	if (rt->rt6i_flags & RTF_PCPU || unlikely(rt->dst.flags & DST_NOCACHE))
 		rt = (struct rt6_info *)(rt->dst.from);
 
 	return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
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
index 7d66490..885408c 100644
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
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1d12207..a64830d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -104,11 +104,18 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
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
@@ -248,10 +255,10 @@ static const struct rt6_info ip6_blk_hole_entry_template = {
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
@@ -265,6 +272,34 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
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
@@ -273,6 +308,9 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 
 	dst_destroy_metrics_generic(dst);
 
+	if (rt->rt6i_pcpu)
+		free_percpu(rt->rt6i_pcpu);
+
 	if (idev) {
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
@@ -847,11 +885,11 @@ static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
 	 *	Clone the route.
 	 */
 
-	if (ort->rt6i_flags & RTF_CACHE)
+	if (ort->rt6i_flags & (RTF_CACHE | RTF_PCPU))
 		ort = (struct rt6_info *)ort->dst.from;
 
-	rt = ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
-			   0, ort->rt6i_table);
+	rt = __ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
+			     0, ort->rt6i_table);
 
 	if (!rt)
 		return NULL;
@@ -878,6 +916,57 @@ static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
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
+	ip6_rt_copy_init(pcpu_rt, rt);
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
+	rcu_read_lock();
+	p = raw_cpu_ptr(rt->rt6i_pcpu);
+	orig = rcu_dereference_check(*p,
+				     lockdep_is_held(&rt->rt6i_table->tb6_lock));
+	if (orig) {
+		dst_hold(&orig->dst);
+		rcu_read_unlock();
+		rt6_dst_from_metrics_check(orig);
+		return orig;
+	}
+	rcu_read_unlock();
+
+	pcpu_rt = ip6_rt_pcpu_alloc(rt);
+	if (!pcpu_rt) {
+		rt = net->ipv6.ip6_null_entry;
+		dst_hold(&rt->dst);
+		return rt;
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
+}
+
 static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
 				      struct flowi6 *fl6, int flags)
 {
@@ -910,11 +999,13 @@ redo_rt6_select:
 		}
 	}
 
-	dst_use(&rt->dst, jiffies);
-	read_unlock_bh(&table->tb6_lock);
 
 	if (rt == net->ipv6.ip6_null_entry || (rt->rt6i_flags & RTF_CACHE)) {
-		goto done;
+		dst_use(&rt->dst, jiffies);
+		read_unlock_bh(&table->tb6_lock);
+
+		rt6_dst_from_metrics_check(rt);
+		return rt;
 	} else if (unlikely((fl6->flowi6_flags & FLOWI_FLAG_KNOWN_NH) &&
 			    !(rt->rt6i_flags & RTF_GATEWAY))) {
 		/* Create a RTF_CACHE clone which will not be
@@ -925,6 +1016,9 @@ redo_rt6_select:
 
 		struct rt6_info *uncached_rt;
 
+		dst_use(&rt->dst, jiffies);
+		read_unlock_bh(&table->tb6_lock);
+
 		uncached_rt = ip6_rt_cache_alloc(rt, &fl6->daddr, NULL);
 		dst_release(&rt->dst);
 
@@ -932,13 +1026,22 @@ redo_rt6_select:
 			uncached_rt->dst.flags |= DST_NOCACHE;
 		else
 			uncached_rt = net->ipv6.ip6_null_entry;
+
 		dst_hold(&uncached_rt->dst);
 		return uncached_rt;
-	}
 
-done:
-	rt6_dst_from_metrics_check(rt);
-	return rt;
+	} else {
+		/* Get a percpu copy */
+
+		struct rt6_info *pcpu_rt;
+
+		rt->dst.lastuse = jiffies;
+		rt->dst.__use++;
+		pcpu_rt = rt6_get_pcpu_route(rt);
+		read_unlock_bh(&table->tb6_lock);
+
+		return pcpu_rt;
+	}
 }
 
 static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
@@ -1082,7 +1185,7 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 
 	rt6_dst_from_metrics_check(rt);
 
-	if (unlikely(dst->flags & DST_NOCACHE))
+	if ((rt->rt6i_flags & RTF_PCPU) || unlikely(dst->flags & DST_NOCACHE))
 		return rt6_dst_from_check(rt, cookie);
 	else
 		return rt6_check(rt, cookie);
-- 
1.8.1
