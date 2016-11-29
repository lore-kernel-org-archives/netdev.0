From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [RFC PATCH net-next v2] ipv6: implement consistent hashing for equal-cost multipath routing
Date: Tue, 29 Nov 2016 18:15:18 +0100
Message-ID: <1480439718-18019-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:56430 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752603AbcK2RPY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:15:24 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id 7F2CF67D9CA
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 18:15:14 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When multiple nexthops are available for a given route, the routing engine
chooses a nexthop by computing the flow hash through get_hash_from_flowi6
and by taking that value modulo the number of nexthops. The resulting value
indexes the nexthop to select. This method causes issues when a new nexthop
is added or one is removed (e.g. link failure). In that case, the number
of nexthops changes and potentially all the flows get re-routed to another
nexthop.

This patch implements a consistent hash method to select the nexthop in
case of ECMP. The idea is to generate K slices (or intervals) for each
route with multiple nexthops. The nexthops are randomly assigned to those
slices, in a uniform manner. The number K is configurable through a sysctl
net.ipv6.route.ecmp_slices and is always an exponent of 2. To select the
nexthop, the algorithm takes the flow hash and computes an index which is
the flow hash modulo K. As K = 2^x, the modulo can be computed using a
simple binary AND operation (idx = hash & (K - 1)). The resulting index
references the selected nexthop. The lookup time complexity is thus O(1).

When a nexthop is added, it steals K/N slices from the other nexthops,
where N is the new number of nexthops. The slices are stolen randomly and
uniformly from the other nexthops. When a nexthop is removed, the orphan
slices are randomly reassigned to the other nexthops.

The number of slices for a route also fixes the maximum number of nexthops
possible for that route.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/net/ip6_fib.h    |  25 +++++++
 include/net/netns/ipv6.h |   1 +
 net/ipv6/ip6_fib.c       | 174 ++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv6/route.c         |  58 ++++++++--------
 4 files changed, 229 insertions(+), 29 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index a74e2aa..29594cc 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -93,6 +93,30 @@ struct rt6key {
 
 struct fib6_table;
 
+/* Multipath nexthop.
+ * @nh is the actual nexthop
+ * @nslices is the number of slices assigned to this nexthop
+ */
+struct rt6_multi_nh {
+	struct rt6_info *nh;
+	unsigned int	nslices;
+};
+
+/* Multipath routes map.
+ * @nhs is an array of available nexthops
+ * @size is the number of elements in @nhs
+ * @nslices is the number of slices and the number of elements in @index
+ *	    and is always in the form 2^x to prevent using a division for
+ *	    the computation of the modulo.
+ * @index is an array mapping a slice index to a nexthop index in @nhs
+ */
+struct rt6_multi_map {
+	struct rt6_multi_nh	*nhs;
+	unsigned int		size;
+	unsigned int		nslices;
+	__u8			*index;
+};
+
 struct rt6_info {
 	struct dst_entry		dst;
 
@@ -113,6 +137,7 @@ struct rt6_info {
 	 */
 	struct list_head		rt6i_siblings;
 	unsigned int			rt6i_nsiblings;
+	struct rt6_multi_map		*rt6i_nh_map;
 
 	atomic_t			rt6i_ref;
 
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index de7745e..4967846 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -36,6 +36,7 @@ struct netns_sysctl_ipv6 {
 	int idgen_retries;
 	int idgen_delay;
 	int flowlabel_state_ranges;
+	int ip6_rt_ecmp_slices;
 };
 
 struct netns_ipv6 {
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index ef54852..b6b1895 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -727,6 +727,166 @@ static void fib6_purge_rt(struct rt6_info *rt, struct fib6_node *fn,
 	}
 }
 
+static void fib6_mp_free(struct rt6_info *rt)
+{
+	struct rt6_multi_map *nh_map = rt->rt6i_nh_map;
+	struct rt6_info *sibling;
+
+	if (nh_map) {
+		list_for_each_entry(sibling, &rt->rt6i_siblings,
+				    rt6i_siblings) {
+			sibling->rt6i_nh_map = NULL;
+		}
+
+		rt->rt6i_nh_map = NULL;
+
+		kfree(nh_map->nhs);
+		kfree(nh_map->index);
+		kfree(nh_map);
+	}
+}
+
+static int fib6_mp_extend(struct net *net, struct rt6_info *sref,
+			  struct rt6_info *rt)
+{
+	struct rt6_multi_map *nh_map = sref->rt6i_nh_map;
+	struct rt6_multi_nh *tmp_nhs, *old_nhs;
+	unsigned int kslices;
+	unsigned int i, j;
+
+	if (!nh_map) {
+		__u8 *index;
+
+		nh_map = kmalloc(sizeof(*nh_map), GFP_ATOMIC);
+		if (!nh_map)
+			return -ENOMEM;
+
+		nh_map->size = 1;
+		nh_map->nslices = (1 << net->ipv6.sysctl.ip6_rt_ecmp_slices);
+
+		tmp_nhs = kmalloc(sizeof(*tmp_nhs), GFP_ATOMIC);
+		if (!tmp_nhs) {
+			kfree(nh_map);
+			return -ENOMEM;
+		}
+
+		tmp_nhs[0].nh = sref;
+		tmp_nhs[0].nslices = nh_map->nslices;
+		nh_map->nhs = tmp_nhs;
+
+		index = kmalloc_array(nh_map->nslices, sizeof(*index),
+				      GFP_ATOMIC);
+		if (!index) {
+			kfree(nh_map->nhs);
+			kfree(nh_map);
+			return -ENOMEM;
+		}
+
+		for (i = 0; i < nh_map->nslices; i++)
+			index[i] = 0;
+
+		nh_map->index = index;
+		sref->rt6i_nh_map = nh_map;
+	}
+
+	if (nh_map->size == nh_map->nslices)
+		return -ENOBUFS;
+
+	nh_map->size++;
+
+	tmp_nhs = kmalloc_array(nh_map->size, sizeof(*tmp_nhs), GFP_ATOMIC);
+	if (!tmp_nhs)
+		return -ENOMEM;
+
+	for (i = 0; i < nh_map->size - 1; i++)
+		tmp_nhs[i] = nh_map->nhs[i];
+
+	tmp_nhs[nh_map->size - 1].nh = rt;
+	tmp_nhs[nh_map->size - 1].nslices = 0;
+
+	kslices = nh_map->nslices / nh_map->size;
+
+	/* Loop over nexthops and steal a random slice until we have kslices for
+	 * the new nexthop. This algorithm ensures that flows are taken as
+	 * equally as possible from current nexthops.
+	 *
+	 * At each iteration, @j is the index in tmp_nhs of the nexthop
+	 * to steal from and @idx is the index of the slice to steal
+	 * among @j's slices.
+	 */
+	for (i = 0, j = 0; i < kslices; i++) {
+		unsigned int idx, k = 0;
+
+		if (tmp_nhs[j].nslices == 1)
+			continue;
+
+		idx = (prandom_u32() % tmp_nhs[j].nslices) + 1;
+		do {
+			if (nh_map->index[k++] == j)
+				idx--;
+		} while (idx);
+
+		nh_map->index[k - 1] = nh_map->size - 1;
+		tmp_nhs[nh_map->size - 1].nslices++;
+		tmp_nhs[j].nslices--;
+
+		j = (j + 1) % (nh_map->size - 1);
+	}
+
+	WARN_ON(tmp_nhs[nh_map->size - 1].nslices != kslices);
+
+	old_nhs = nh_map->nhs;
+	nh_map->nhs = tmp_nhs;
+	kfree(old_nhs);
+
+	rt->rt6i_nh_map = nh_map;
+
+	return 0;
+}
+
+static int fib6_mp_shrink(struct rt6_info *sref, struct rt6_info *rt)
+{
+	struct rt6_multi_map *nh_map = sref->rt6i_nh_map;
+	struct rt6_multi_nh *tmp_nhs, *old_nhs;
+	unsigned int i, j, idx = 0;
+
+	tmp_nhs = kmalloc_array(nh_map->size - 1, sizeof(*tmp_nhs), GFP_ATOMIC);
+	if (!tmp_nhs)
+		return -ENOMEM;
+
+	for (i = 0, j = 0; i < nh_map->size; i++) {
+		if (nh_map->nhs[i].nh != rt)
+			tmp_nhs[j++] = nh_map->nhs[i];
+		else
+			idx = i;
+	}
+
+	nh_map->size--;
+	old_nhs = nh_map->nhs;
+	nh_map->nhs = tmp_nhs;
+	kfree(old_nhs);
+
+	rt->rt6i_nh_map = NULL;
+
+	/* Update the slices index. For each slice mapping to the removed
+	 * nexthop, assign another random nexthop. For each slice mapping
+	 * to a nexthop that was after the removed nexthop, decrement the
+	 * nexthop index to reflect the shift. Nexthops that were before
+	 * the removed nexthop are unaffected.
+	 */
+	for (i = 0; i < nh_map->nslices; i++) {
+		if (nh_map->index[i] == idx) {
+			j = prandom_u32() % nh_map->size;
+			nh_map->index[i] = j;
+			nh_map->nhs[j].nslices++;
+		} else if (nh_map->index[i] > idx) {
+			nh_map->index[i]--;
+		}
+	}
+
+	return 0;
+}
+
 /*
  *	Insert routing information in a node.
  */
@@ -837,6 +997,9 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			}
 			sibling = sibling->dst.rt6_next;
 		}
+		err = fib6_mp_extend(info->nl_net, sibling, rt);
+		if (err < 0)
+			return err;
 		/* For each sibling in the list, increment the counter of
 		 * siblings. BUG() if counters does not match, list of siblings
 		 * is broken!
@@ -900,6 +1063,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			fn->fn_flags |= RTN_RTINFO;
 		}
 		nsiblings = iter->rt6i_nsiblings;
+		if (nsiblings)
+			fib6_mp_free(iter);
 		fib6_purge_rt(iter, fn, info->nl_net);
 		rt6_release(iter);
 
@@ -1407,13 +1572,20 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 
 	/* Remove this entry from other siblings */
 	if (rt->rt6i_nsiblings) {
-		struct rt6_info *sibling, *next_sibling;
+		struct rt6_info *sibling, *next_sibling, *sref;
+
+		sref = list_first_entry(&rt->rt6i_siblings, struct rt6_info,
+					rt6i_siblings);
 
 		list_for_each_entry_safe(sibling, next_sibling,
 					 &rt->rt6i_siblings, rt6i_siblings)
 			sibling->rt6i_nsiblings--;
 		rt->rt6i_nsiblings = 0;
 		list_del_init(&rt->rt6i_siblings);
+		if (!sref->rt6i_nsiblings)
+			fib6_mp_free(sref);
+		else
+			fib6_mp_shrink(sref, rt);
 	}
 
 	/* Adjust walkers */
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b317bb1..e9f13e0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -427,39 +427,27 @@ static bool rt6_check_expired(const struct rt6_info *rt)
 	return false;
 }
 
-/* Multipath route selection:
- *   Hash based function using packet header and flowlabel.
- * Adapted from fib_info_hashfn()
- */
-static int rt6_info_hash_nhsfn(unsigned int candidate_count,
-			       const struct flowi6 *fl6)
-{
-	return get_hash_from_flowi6(fl6) % candidate_count;
-}
-
 static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
 					     struct flowi6 *fl6, int oif,
 					     int strict)
 {
-	struct rt6_info *sibling, *next_sibling;
-	int route_choosen;
+	struct rt6_multi_map *nh_map = match->rt6i_nh_map;
+	__u32 hash = get_hash_from_flowi6(fl6);
+	unsigned int slice, idx;
+	struct rt6_info *res;
 
-	route_choosen = rt6_info_hash_nhsfn(match->rt6i_nsiblings + 1, fl6);
-	/* Don't change the route, if route_choosen == 0
-	 * (siblings does not include ourself)
-	 */
-	if (route_choosen)
-		list_for_each_entry_safe(sibling, next_sibling,
-				&match->rt6i_siblings, rt6i_siblings) {
-			route_choosen--;
-			if (route_choosen == 0) {
-				if (rt6_score_route(sibling, oif, strict) < 0)
-					break;
-				match = sibling;
-				break;
-			}
-		}
-	return match;
+	WARN_ON(!nh_map);
+	if (!nh_map)
+		return match;
+
+	slice = hash & (nh_map->nslices - 1);
+	idx = nh_map->index[slice];
+	res = nh_map->nhs[idx].nh;
+
+	if (rt6_score_route(res, oif, strict) < 0)
+		res = match;
+
+	return res;
 }
 
 /*
@@ -3550,6 +3538,9 @@ int ipv6_sysctl_rtcache_flush(struct ctl_table *ctl, int write,
 	return 0;
 }
 
+static int one = 1;
+static int thirtyone = 31;
+
 struct ctl_table ipv6_route_table_template[] = {
 	{
 		.procname	=	"flush",
@@ -3621,6 +3612,15 @@ struct ctl_table ipv6_route_table_template[] = {
 		.mode		=	0644,
 		.proc_handler	=	proc_dointvec_ms_jiffies,
 	},
+	{
+		.procname	=	"ecmp_slices",
+		.data		=	&init_net.ipv6.sysctl.ip6_rt_ecmp_slices,
+		.maxlen		=	sizeof(int),
+		.mode		=	0644,
+		.proc_handler	=	proc_dointvec_minmax,
+		.extra1		=	&one,
+		.extra2		=	&thirtyone,
+	},
 	{ }
 };
 
@@ -3644,6 +3644,7 @@ struct ctl_table * __net_init ipv6_route_sysctl_init(struct net *net)
 		table[7].data = &net->ipv6.sysctl.ip6_rt_mtu_expires;
 		table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
 		table[9].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
+		table[10].data = &net->ipv6.sysctl.ip6_rt_ecmp_slices;
 
 		/* Don't export sysctls to unprivileged users */
 		if (net->user_ns != &init_user_ns)
@@ -3707,6 +3708,7 @@ static int __net_init ip6_route_net_init(struct net *net)
 	net->ipv6.sysctl.ip6_rt_gc_elasticity = 9;
 	net->ipv6.sysctl.ip6_rt_mtu_expires = 10*60*HZ;
 	net->ipv6.sysctl.ip6_rt_min_advmss = IPV6_MIN_MTU - 20 - 40;
+	net->ipv6.sysctl.ip6_rt_ecmp_slices = 5;
 
 	net->ipv6.ip6_rt_gc_expire = 30*HZ;
 
-- 
2.7.3
