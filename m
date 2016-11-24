From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [RFC PATCH net-next] ipv6: implement consistent hashing for equal-cost multipath routing
Date: Thu, 24 Nov 2016 20:59:16 +0100
Message-ID: <1480017556-25988-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34231 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757358AbcKXUIn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 15:08:43 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id 8E62967DD2B
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2016 20:59:16 +0100 (CET)
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
case of ECMP. The idea is to generate N random numbers (__u32) for each
nexthop, where N is configurable. In order to select a nexthop, we find the
number that is directly higher than the flow hash (which is also __u32).
The nexthop associated to the number is then selected. The lookup method
performs a binary search over the sorted array of numbers, which yields a
time complexity of O(log n), where n is the number of nexthops times the
number of random values generated for each number.

This feature can be enabled through the CONFIG_IPV6_MULTIPATH_CONSISTENT
option and the number of random values generated for each nexthop is
defined through CONFIG_IPV6_MPCONSIST_BUCKETSIZE.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/net/ip6_fib.h |  20 ++++
 net/ipv6/Kconfig      |  26 +++++
 net/ipv6/Makefile     |   1 +
 net/ipv6/ip6_ecmp.c   | 263 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_fib.c    |  18 ++++
 net/ipv6/route.c      |  56 +++++++++++
 6 files changed, 384 insertions(+)
 create mode 100644 net/ipv6/ip6_ecmp.c

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index a74e2aa..e22417d 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -93,6 +93,16 @@ struct rt6key {
 
 struct fib6_table;
 
+struct rt6_multi_nh {
+	__u32		key;
+	struct rt6_info *nh;
+};
+
+struct rt6_multi_map {
+	struct rt6_multi_nh	*nhs;
+	unsigned int		size;
+};
+
 struct rt6_info {
 	struct dst_entry		dst;
 
@@ -113,6 +123,9 @@ struct rt6_info {
 	 */
 	struct list_head		rt6i_siblings;
 	unsigned int			rt6i_nsiblings;
+#ifdef CONFIG_IPV6_MULTIPATH_CONSISTENT
+	struct rt6_multi_map		*rt6i_nh_map;
+#endif
 
 	atomic_t			rt6i_ref;
 
@@ -302,4 +315,11 @@ static inline void              fib6_rules_cleanup(void)
 	return ;
 }
 #endif
+
+#ifdef CONFIG_IPV6_MULTIPATH_CONSISTENT
+int fib6_mp_shrink(struct rt6_info *sref, struct rt6_info *rt);
+int fib6_mp_extend(struct rt6_info *rt, struct rt6_multi_map *nh_map);
+void fib6_mp_free(struct rt6_info *rt);
+#endif
+
 #endif
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index ec1267e..ebfae0d 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -324,4 +324,30 @@ config IPV6_SEG6_HMAC
 
 	  If unsure, say N.
 
+config IPV6_MULTIPATH_CONSISTENT
+	bool "IPv6: enable consistent hashing for ECMP"
+	depends on IPV6
+	---help---
+	  Enable consistent hashing for Equal-Cost Multi-Path (ECMP)
+	  route selection. By default, the nexthop is selected by taking
+	  the flow hash modulo the number of nexthops. When a nexthop is
+	  added or removed (e.g. link failure), all flows might change to
+	  a different nexthop as the modulo changes. Enabling this option
+	  allows to ensure that when a nexthop is removed, only the affected
+	  flows are assigned to another nexthop, and they are balanced equally
+	  across the remaining nexthops. When a nexthop is added, only a subset
+	  of the flows are assigned to it. The lookup performance is O(log n)
+	  where n is the number of nexthops times CONFIG_IPV6_MPCONSIST_BUCKETSIZE.
+
+	  If unsure, say N.
+
+config IPV6_MPCONSIST_BUCKETSIZE
+	int "IPv6: bucket size for ECMP consistent hashing"
+	default 10
+	depends on IPV6_MULTIPATH_CONSISTENT
+	---help---
+	  Define the number of hash entries generated for each ECMP nexthop.
+	  A higher value increases the uniform distribution of flows across
+	  nexthops, but also increases lookup performances logarithmically.
+
 endif # IPV6
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index a9e9fec..6481c5d 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -25,6 +25,7 @@ ipv6-$(CONFIG_SYN_COOKIES) += syncookies.o
 ipv6-$(CONFIG_NETLABEL) += calipso.o
 ipv6-$(CONFIG_IPV6_SEG6_LWTUNNEL) += seg6_iptunnel.o
 ipv6-$(CONFIG_IPV6_SEG6_HMAC) += seg6_hmac.o
+ipv6-$(CONFIG_IPV6_MULTIPATH_CONSISTENT) += ip6_ecmp.o
 
 ipv6-objs += $(ipv6-y)
 
diff --git a/net/ipv6/ip6_ecmp.c b/net/ipv6/ip6_ecmp.c
new file mode 100644
index 0000000..799a328
--- /dev/null
+++ b/net/ipv6/ip6_ecmp.c
@@ -0,0 +1,263 @@
+/*
+ * IPv6 Equal-Cost Multi-Path
+ *
+ * Author:
+ * David Lebrun <david.lebrun@uclouvain.be>
+
+ *  This program is free software; you can redistribute it and/or
+ *	  modify it under the terms of the GNU General Public License
+ *	  as published by the Free Software Foundation; either version
+ *	  2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/net.h>
+#include <linux/route.h>
+#include <linux/netdevice.h>
+#include <linux/in6.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+
+#include <net/ipv6.h>
+#include <net/ndisc.h>
+#include <net/addrconf.h>
+#include <net/lwtunnel.h>
+
+#include <net/ip6_fib.h>
+#include <net/ip6_route.h>
+
+static int mphash_bucket_size = CONFIG_IPV6_MPCONSIST_BUCKETSIZE;
+
+void fib6_mp_free(struct rt6_info *rt)
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
+		kfree(nh_map);
+	}
+}
+
+static bool fib6_mp_key_exists(struct rt6_multi_nh *nhs, unsigned int size,
+			       __u32 key)
+{
+	unsigned int i;
+
+	for (i = 0; i < size; i++) {
+		if (nhs[i].key == key)
+			return true;
+	}
+
+	return false;
+}
+
+static void fib6_mp_populate(struct rt6_multi_nh *nhs, unsigned int offset,
+			     unsigned int size, unsigned int fullsize,
+			     struct rt6_info *rt)
+{
+	unsigned int i;
+
+	for (i = offset; i < offset + size; i++) {
+		__u32 key;
+
+		do {
+			get_random_bytes(&key, sizeof(key));
+		} while (fib6_mp_key_exists(nhs, fullsize, key));
+
+		nhs[i].key = key;
+		nhs[i].nh = rt;
+	}
+}
+
+static int fib6_mp_update(struct rt6_info *rt, struct rt6_multi_nh *nhs,
+			  unsigned int size, bool check)
+{
+	struct rt6_multi_map *new_map;
+	struct rt6_info *sibling;
+
+	new_map = kmalloc(sizeof(*new_map), GFP_ATOMIC);
+	if (!new_map)
+		return -ENOMEM;
+
+	new_map->nhs = nhs;
+	new_map->size = size;
+
+	list_for_each_entry(sibling, &rt->rt6i_siblings, rt6i_siblings) {
+		if (check)
+			WARN_ON(sibling->rt6i_nh_map);
+		sibling->rt6i_nh_map = new_map;
+	}
+
+	rt->rt6i_nh_map = new_map;
+
+	return 0;
+}
+
+static void ___merge(struct rt6_multi_nh *nhs, struct rt6_multi_nh *helper,
+		     unsigned int low, unsigned int middle, unsigned int high)
+{
+	unsigned int i, j, k;
+
+	i = low;
+	j = middle + 1;
+	k = 0;
+
+	while (i <= middle || j <= high) {
+		if (i <= middle && j <= high) {
+			if (nhs[i].key < nhs[j].key)
+				helper[k++] = nhs[i++];
+			else
+				helper[k++] = nhs[j++];
+		} else if (i <= middle) {
+			helper[k++] = nhs[i++];
+		} else {
+			helper[k++] = nhs[j++];
+		}
+	}
+
+	for (i = 0; i < (high - low + 1); i++)
+		nhs[low + i] = helper[i];
+}
+
+static void ___mergesort(struct rt6_multi_nh *nhs, struct rt6_multi_nh *helper,
+			 unsigned int low, unsigned int high)
+{
+	unsigned int middle;
+
+	if (low > high)
+		return;
+
+	middle = ((low + high) / 2);
+
+	if (low < high) {
+		___mergesort(nhs, helper, low, middle);
+		___mergesort(nhs, helper, middle + 1, high);
+	}
+
+	___merge(nhs, helper, low, middle, high);
+}
+
+static int fib6_mp_sort(struct rt6_multi_nh *nhs, unsigned int size)
+{
+	struct rt6_multi_nh *helper;
+
+	helper = kmalloc_array(size, sizeof(*helper), GFP_ATOMIC);
+	if (!helper)
+		return -ENOMEM;
+
+	___mergesort(nhs, helper, 0, size - 1);
+	kfree(helper);
+
+	return 0;
+}
+
+int fib6_mp_extend(struct rt6_info *rt, struct rt6_multi_map *nh_map)
+{
+	struct rt6_multi_nh *tmp_nhs;
+	unsigned int size;
+	int err;
+
+	if (!nh_map) {
+		struct rt6_info *sibling;
+
+		size = mphash_bucket_size * 2;
+		tmp_nhs = kcalloc(size, sizeof(struct rt6_multi_nh),
+				  GFP_ATOMIC);
+		if (!tmp_nhs)
+			return -ENOMEM;
+
+		sibling = list_first_entry(&rt->rt6i_siblings, struct rt6_info,
+					   rt6i_siblings);
+
+		fib6_mp_populate(tmp_nhs, 0, mphash_bucket_size, size, sibling);
+
+		fib6_mp_populate(tmp_nhs, mphash_bucket_size,
+				 mphash_bucket_size, size, rt);
+
+		err = fib6_mp_sort(tmp_nhs, size);
+		if (err) {
+			kfree(tmp_nhs);
+			return err;
+		}
+
+		err = fib6_mp_update(rt, tmp_nhs, size, true);
+		if (err) {
+			kfree(tmp_nhs);
+			return err;
+		}
+
+		return 0;
+	}
+
+	size = nh_map->size + mphash_bucket_size;
+	tmp_nhs = __krealloc(nh_map->nhs, size * sizeof(*tmp_nhs), GFP_ATOMIC);
+	if (!tmp_nhs)
+		return -ENOMEM;
+
+	memset(tmp_nhs + nh_map->size, 0,
+	       mphash_bucket_size * sizeof(*tmp_nhs));
+
+	fib6_mp_populate(tmp_nhs, nh_map->size, mphash_bucket_size, size, rt);
+
+	err = fib6_mp_sort(tmp_nhs, size);
+	if (err) {
+		kfree(tmp_nhs);
+		return err;
+	}
+
+	err = fib6_mp_update(rt, tmp_nhs, size, false);
+	if (err) {
+		kfree(tmp_nhs);
+		return err;
+	}
+
+	if (tmp_nhs != nh_map->nhs)
+		kfree(nh_map->nhs);
+	kfree(nh_map);
+
+	return 0;
+}
+
+int fib6_mp_shrink(struct rt6_info *sref, struct rt6_info *rt)
+{
+	struct rt6_multi_map *nh_map = sref->rt6i_nh_map;
+	struct rt6_multi_nh *tmp_nhs;
+	unsigned int size, i, j;
+	int err;
+
+	WARN_ON(!nh_map);
+	if (!nh_map)
+		return -ENOENT;
+
+	size = nh_map->size - mphash_bucket_size;
+	tmp_nhs = kcalloc(size, sizeof(*tmp_nhs), GFP_ATOMIC);
+	if (!tmp_nhs)
+		return -ENOMEM;
+
+	for (i = 0, j = 0; i < nh_map->size; i++) {
+		if (nh_map->nhs[i].nh != rt)
+			tmp_nhs[j++] = nh_map->nhs[i];
+	}
+
+	err = fib6_mp_update(sref, tmp_nhs, size, false);
+	if (err) {
+		kfree(tmp_nhs);
+		return err;
+	}
+
+	rt->rt6i_nh_map = NULL;
+	kfree(nh_map->nhs);
+	kfree(nh_map);
+
+	return 0;
+}
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index ef54852..ad5f645 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -837,6 +837,9 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			}
 			sibling = sibling->dst.rt6_next;
 		}
+#ifdef CONFIG_IPV6_MULTIPATH_CONSISTENT
+		fib6_mp_extend(rt, sibling->rt6i_nh_map);
+#endif
 		/* For each sibling in the list, increment the counter of
 		 * siblings. BUG() if counters does not match, list of siblings
 		 * is broken!
@@ -900,6 +903,10 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			fn->fn_flags |= RTN_RTINFO;
 		}
 		nsiblings = iter->rt6i_nsiblings;
+#ifdef CONFIG_IPV6_MULTIPATH_CONSISTENT
+		if (nsiblings)
+			fib6_mp_free(iter);
+#endif
 		fib6_purge_rt(iter, fn, info->nl_net);
 		rt6_release(iter);
 
@@ -1407,6 +1414,11 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 
 	/* Remove this entry from other siblings */
 	if (rt->rt6i_nsiblings) {
+#ifdef CONFIG_IPV6_MULTIPATH_CONSISTENT
+		struct rt6_info *sref = list_first_entry(&rt->rt6i_siblings,
+							 struct rt6_info,
+							 rt6i_siblings);
+#endif
 		struct rt6_info *sibling, *next_sibling;
 
 		list_for_each_entry_safe(sibling, next_sibling,
@@ -1414,6 +1426,12 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 			sibling->rt6i_nsiblings--;
 		rt->rt6i_nsiblings = 0;
 		list_del_init(&rt->rt6i_siblings);
+#ifdef CONFIG_IPV6_MULTIPATH_CONSISTENT
+		if (!sref->rt6i_nsiblings)
+			fib6_mp_free(sref);
+		else
+			fib6_mp_shrink(sref, rt);
+#endif
 	}
 
 	/* Adjust walkers */
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b317bb1..109f371 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -427,6 +427,60 @@ static bool rt6_check_expired(const struct rt6_info *rt)
 	return false;
 }
 
+#ifdef CONFIG_IPV6_MULTIPATH_CONSISTENT
+
+static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
+					     struct flowi6 *fl6, int oif,
+					     int strict)
+{
+	struct rt6_multi_map *nh_map = match->rt6i_nh_map;
+	__u32 hash = get_hash_from_flowi6(fl6);
+	unsigned int left, right, idx;
+	struct rt6_info *res = NULL;
+
+	WARN_ON(!nh_map);
+	if (!nh_map)
+		return match;
+
+	if (hash <= nh_map->nhs[0].key ||
+	    hash > nh_map->nhs[nh_map->size - 1].key) {
+		res = nh_map->nhs[0].nh;
+		goto skip_lookup;
+	}
+
+	left = 0;
+	right = nh_map->size - 1;
+
+	do {
+		struct rt6_multi_nh *nh1, *nh2;
+
+		idx = (left + right) / 2;
+		nh1 = &nh_map->nhs[idx];
+		nh2 = &nh_map->nhs[idx + 1];
+
+		if (hash < nh1->key && hash < nh2->key)
+			right = idx;
+		else if (hash > nh1->key && hash > nh2->key)
+			left = idx + 1;
+		else if (hash == nh1->key)
+			res = nh1->nh;
+		else
+			res = nh2->nh;
+	} while (left != right && !res);
+
+	WARN_ON(!res);
+	if (!res)
+		return match;
+
+skip_lookup:
+	if (rt6_score_route(res, oif, strict) < 0)
+		res = match;
+
+	return res;
+}
+
+#else
+
 /* Multipath route selection:
  *   Hash based function using packet header and flowlabel.
  * Adapted from fib_info_hashfn()
@@ -462,6 +516,8 @@ static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
 	return match;
 }
 
+#endif
+
 /*
  *	Route lookup. Any table->tb6_lock is implied.
  */
-- 
2.7.3
