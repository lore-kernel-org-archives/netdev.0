From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/7] ipv4: Provide fib_nh instead of fib_info in fib_result.
Date: Fri, 27 Jul 2012 21:18:19 -0700 (PDT)
Message-ID: <20120727.211819.1418384920189495051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab2G1ESV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 00:18:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The latter can be obtained via nh->nh_parent, and this makes
the fib_result->nh_sel member no longer necessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |   43 +++++++++++-------------
 net/ipv4/devinet.c       |    2 +-
 net/ipv4/fib_frontend.c  |   28 +++++++++-------
 net/ipv4/fib_lookup.h    |   11 -------
 net/ipv4/fib_semantics.c |   54 +++++++++++++++---------------
 net/ipv4/fib_trie.c      |    7 ++--
 net/ipv4/route.c         |   82 ++++++++++++++++++++++------------------------
 7 files changed, 108 insertions(+), 119 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e69c3a4..eb62a2f 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -123,14 +123,14 @@ struct fib_rule;
 
 struct fib_table;
 struct fib_result {
-	unsigned char	prefixlen;
-	unsigned char	nh_sel;
-	unsigned char	type;
-	unsigned char	scope;
-	u32		tclassid;
-	struct fib_info *fi;
-	struct fib_table *table;
-	struct list_head *fa_head;
+	unsigned char		prefixlen;
+	unsigned char		__pad;
+	unsigned char		type;
+	unsigned char		scope;
+	u32			tclassid;
+	struct fib_nh		*nh;
+	struct fib_table	*table;
+	struct list_head	*fa_head;
 };
 
 struct fib_result_nl {
@@ -150,31 +150,28 @@ struct fib_result_nl {
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
-#define FIB_RES_NH(res)		((res).fi->fib_nh[(res).nh_sel])
-
 #define FIB_TABLE_HASHSZ 2
 
 #else /* CONFIG_IP_ROUTE_MULTIPATH */
 
-#define FIB_RES_NH(res)		((res).fi->fib_nh[0])
-
 #define FIB_TABLE_HASHSZ 256
 
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
 
 extern __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
 
-#define FIB_RES_SADDR(net, res)				\
-	((FIB_RES_NH(res).nh_saddr_genid ==		\
-	  atomic_read(&(net)->ipv4.dev_addr_genid)) ?	\
-	 FIB_RES_NH(res).nh_saddr :			\
-	 fib_info_update_nh_saddr((net), &FIB_RES_NH(res)))
-#define FIB_RES_GW(res)			(FIB_RES_NH(res).nh_gw)
-#define FIB_RES_DEV(res)		(FIB_RES_NH(res).nh_dev)
-#define FIB_RES_OIF(res)		(FIB_RES_NH(res).nh_oif)
+static inline __be32 fib_res_prefsrc(struct net *net, struct fib_result *res)
+{
+	struct fib_nh *nh = res->nh;
+	struct fib_info *fi;
 
-#define FIB_RES_PREFSRC(net, res)	((res).fi->fib_prefsrc ? : \
-					 FIB_RES_SADDR(net, res))
+	fi = nh->nh_parent;
+	if (fi->fib_prefsrc)
+		return fi->fib_prefsrc;
+	if (nh->nh_saddr_genid == atomic_read(&net->ipv4.dev_addr_genid))
+		return nh->nh_saddr;
+	return fib_info_update_nh_saddr(net, nh);
+}
 
 struct fib_table {
 	struct hlist_node	tb_hlist;
@@ -302,7 +299,7 @@ static inline void fib_combine_itag(u32 *itag, const struct fib_result *res)
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	u32 rtag;
 #endif
-	*itag = FIB_RES_NH(*res).nh_tclassid<<16;
+	*itag = res->nh->nh_tclassid<<16;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	rtag = res->tclassid;
 	if (*itag == 0)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 44bf82e..1baaa53 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -164,7 +164,7 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 		if (local &&
 		    !fib_table_lookup(local, &fl4, &res, FIB_LOOKUP_NOREF) &&
 		    res.type == RTN_LOCAL)
-			result = FIB_RES_DEV(res);
+			result = res.nh->nh_dev;
 	}
 	if (result && devref)
 		dev_hold(result);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 8732cc7..d2e8dbe 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -174,7 +174,7 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 		ret = RTN_UNICAST;
 		rcu_read_lock();
 		if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
-			if (!dev || dev == res.fi->fib_dev)
+			if (!dev || dev == res.nh->nh_dev)
 				ret = res.type;
 		}
 		rcu_read_unlock();
@@ -225,7 +225,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 		fl4.flowi4_scope = scope;
 		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
 		if (!fib_lookup(net, &fl4, &res))
-			return FIB_RES_PREFSRC(net, res);
+			return fib_res_prefsrc(net, &res);
 	} else {
 		scope = RT_SCOPE_LINK;
 	}
@@ -247,6 +247,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 {
 	int ret, no_addr, accept_local;
 	struct fib_result res;
+	struct fib_info *fi;
 	struct flowi4 fl4;
 	struct net *net;
 	bool dev_match;
@@ -273,21 +274,17 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	fib_combine_itag(itag, &res);
 	dev_match = false;
 
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-	for (ret = 0; ret < res.fi->fib_nhs; ret++) {
-		struct fib_nh *nh = &res.fi->fib_nh[ret];
+	fi = res.nh->nh_parent;
+	for (ret = 0; ret < fi->fib_nhs; ret++) {
+		struct fib_nh *nh = &fi->fib_nh[ret];
 
 		if (nh->nh_dev == dev) {
 			dev_match = true;
 			break;
 		}
 	}
-#else
-	if (FIB_RES_DEV(res) == dev)
-		dev_match = true;
-#endif
 	if (dev_match) {
-		ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
+		ret = res.nh->nh_scope >= RT_SCOPE_HOST;
 		return ret;
 	}
 	if (no_addr)
@@ -299,7 +296,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	ret = 0;
 	if (fib_lookup(net, &fl4, &res) == 0) {
 		if (res.type == RTN_UNICAST)
-			ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
+			ret = res.nh->nh_scope >= RT_SCOPE_HOST;
 	}
 	return ret;
 
@@ -939,8 +936,15 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 		frn->err = fib_table_lookup(tb, &fl4, &res, FIB_LOOKUP_NOREF);
 
 		if (!frn->err) {
+			struct fib_nh *nh = res.nh;
+			struct fib_info *fi;
+			int nhsel;
+
+			fi = nh->nh_parent;
+			nhsel = nh - &fi->fib_nh[0];
+
 			frn->prefixlen = res.prefixlen;
-			frn->nh_sel = res.nh_sel;
+			frn->nh_sel = nhsel;
 			frn->type = res.type;
 			frn->scope = res.scope;
 		}
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index af0f14a..5f110b6 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -36,17 +36,6 @@ extern void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
 		      unsigned int nlm_flags);
 extern struct fib_alias *fib_find_alias(struct list_head *fah,
 					u8 tos, u32 prio);
-extern int fib_detect_death(struct fib_info *fi, int order,
-			    struct fib_info **last_resort,
-			    int *last_idx, int dflt);
-
-static inline void fib_result_assign(struct fib_result *res,
-				     struct fib_info *fi)
-{
-	/* we used to play games with refcounts, but we now use RCU */
-	res->fi = fi;
-}
-
 struct fib_prop {
 	int	error;
 	u8	scope;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index da0cc2e..b830245 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -393,13 +393,14 @@ struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio)
 	return NULL;
 }
 
-int fib_detect_death(struct fib_info *fi, int order,
-		     struct fib_info **last_resort, int *last_idx, int dflt)
+int fib_detect_death(struct fib_nh *nh, int order,
+		     struct fib_nh **last_resort, int *last_idx,
+		     int dflt)
 {
 	struct neighbour *n;
 	int state = NUD_NONE;
 
-	n = neigh_lookup(&arp_tbl, &fi->fib_nh[0].nh_gw, fi->fib_dev);
+	n = neigh_lookup(&arp_tbl, &nh->nh_gw, nh->nh_dev);
 	if (n) {
 		state = n->nud_state;
 		neigh_release(n);
@@ -410,7 +411,7 @@ int fib_detect_death(struct fib_info *fi, int order,
 		return 0;
 	if ((state & NUD_VALID) ||
 	    (*last_idx < 0 && order > dflt)) {
-		*last_resort = fi;
+		*last_resort = nh;
 		*last_idx = order;
 	}
 	return 1;
@@ -612,8 +613,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		if (res.type != RTN_UNICAST && res.type != RTN_LOCAL)
 			goto out;
 		nh->nh_scope = res.scope;
-		nh->nh_oif = FIB_RES_OIF(res);
-		nh->nh_dev = dev = FIB_RES_DEV(res);
+		nh->nh_oif = res.nh->nh_oif;
+		nh->nh_dev = dev = res.nh->nh_dev;
 		if (!dev)
 			goto out;
 		dev_hold(dev);
@@ -1130,54 +1131,55 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 /* Must be invoked inside of an RCU protected region.  */
 void fib_select_default(struct fib_result *res)
 {
-	struct fib_info *fi = NULL, *last_resort = NULL;
+	struct fib_nh *nh = NULL, *last_resort = NULL;
 	struct list_head *fa_head = res->fa_head;
 	struct fib_table *tb = res->table;
 	int order = -1, last_idx = -1;
 	struct fib_alias *fa;
 
 	list_for_each_entry_rcu(fa, fa_head, fa_list) {
-		struct fib_info *next_fi = fa->fa_info;
+		struct fib_nh *next_nh = &fa->fa_info->fib_nh[0];
 
-		if (next_fi->fib_scope != res->scope ||
+		if (next_nh->nh_parent->fib_scope != res->scope ||
 		    fa->fa_type != RTN_UNICAST)
 			continue;
 
-		if (next_fi->fib_priority > res->fi->fib_priority)
+		if (next_nh->nh_parent->fib_priority >
+		    res->nh->nh_parent->fib_priority)
 			break;
-		if (!next_fi->fib_nh[0].nh_gw ||
-		    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
+
+		if (!next_nh->nh_gw || next_nh->nh_scope != RT_SCOPE_LINK)
 			continue;
 
 		fib_alias_accessed(fa);
 
-		if (fi == NULL) {
-			if (next_fi != res->fi)
+		if (nh == NULL) {
+			if (next_nh != res->nh)
 				break;
-		} else if (!fib_detect_death(fi, order, &last_resort,
+		} else if (!fib_detect_death(nh, order, &last_resort,
 					     &last_idx, tb->tb_default)) {
-			fib_result_assign(res, fi);
+			res->nh = nh;
 			tb->tb_default = order;
 			goto out;
 		}
-		fi = next_fi;
+		nh = next_nh;
 		order++;
 	}
 
-	if (order <= 0 || fi == NULL) {
+	if (order <= 0 || nh == NULL) {
 		tb->tb_default = -1;
 		goto out;
 	}
 
-	if (!fib_detect_death(fi, order, &last_resort, &last_idx,
-				tb->tb_default)) {
-		fib_result_assign(res, fi);
+	if (!fib_detect_death(nh, order, &last_resort, &last_idx,
+			      tb->tb_default)) {
+		res->nh = nh;
 		tb->tb_default = order;
 		goto out;
 	}
 
 	if (last_idx >= 0)
-		fib_result_assign(res, last_resort);
+		res->nh = last_resort;
 	tb->tb_default = last_idx;
 out:
 	return;
@@ -1249,7 +1251,7 @@ int fib_sync_up(struct net_device *dev)
  */
 void fib_select_multipath(struct fib_result *res)
 {
-	struct fib_info *fi = res->fi;
+	struct fib_info *fi = res->nh->nh_parent;
 	int w;
 
 	spin_lock_bh(&fib_multipath_lock);
@@ -1265,7 +1267,7 @@ void fib_select_multipath(struct fib_result *res)
 		if (power <= 0) {
 			spin_unlock_bh(&fib_multipath_lock);
 			/* Race condition: route has just become dead. */
-			res->nh_sel = 0;
+			res->nh = &fi->fib_nh[0];
 			return;
 		}
 	}
@@ -1284,7 +1286,7 @@ void fib_select_multipath(struct fib_result *res)
 			if (w <= 0) {
 				nexthop_nh->nh_power--;
 				fi->fib_power--;
-				res->nh_sel = nhsel;
+				res->nh = &fi->fib_nh[nhsel];
 				spin_unlock_bh(&fib_multipath_lock);
 				return;
 			}
@@ -1292,7 +1294,7 @@ void fib_select_multipath(struct fib_result *res)
 	} endfor_nexthops(fi);
 
 	/* Race condition: route has just become dead. */
-	res->nh_sel = 0;
+	res->nh = &fi->fib_nh[0];
 	spin_unlock_bh(&fib_multipath_lock);
 }
 #endif
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 18cbc15..04b0e26 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1384,7 +1384,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 			if (fi->fib_flags & RTNH_F_DEAD)
 				continue;
 			for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
-				const struct fib_nh *nh = &fi->fib_nh[nhsel];
+				struct fib_nh *nh = &fi->fib_nh[nhsel];
 
 				if (nh->nh_flags & RTNH_F_DEAD)
 					continue;
@@ -1395,10 +1395,9 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 				t->stats.semantic_match_passed++;
 #endif
 				res->prefixlen = li->plen;
-				res->nh_sel = nhsel;
 				res->type = fa->fa_type;
-				res->scope = fa->fa_info->fib_scope;
-				res->fi = fi;
+				res->scope = fi->fib_scope;
+				res->nh = nh;
 				res->table = tb;
 				res->fa_head = &li->falh;
 				if (!(fib_flags & FIB_LOOKUP_NOREF))
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index fc1a81c..0b3277c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -722,7 +722,7 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 			neigh_event_send(n, NULL);
 		} else {
 			if (fib_lookup(net, fl4, &res) == 0) {
-				struct fib_nh *nh = &FIB_RES_NH(res);
+				struct fib_nh *nh = res.nh;
 
 				update_or_create_fnhe(nh, fl4->daddr, new_gw,
 						      0, 0);
@@ -926,7 +926,7 @@ static u32 __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 		mtu = ip_rt_min_pmtu;
 
 	if (fib_lookup(dev_net(rt->dst.dev), fl4, &res) == 0) {
-		struct fib_nh *nh = &FIB_RES_NH(res);
+		struct fib_nh *nh = res.nh;
 
 		update_or_create_fnhe(nh, fl4->daddr, 0, mtu,
 				      jiffies + ip_rt_mtu_expires);
@@ -1085,7 +1085,7 @@ void ip_rt_get_source(u8 *addr, struct sk_buff *skb, struct rtable *rt)
 
 		rcu_read_lock();
 		if (fib_lookup(dev_net(rt->dst.dev), &fl4, &res) == 0)
-			src = FIB_RES_PREFSRC(dev_net(rt->dst.dev), res);
+			src = fib_res_prefsrc(dev_net(rt->dst.dev), &res);
 		else
 			src = inet_select_addr(rt->dst.dev,
 					       rt_nexthop(rt, iph->daddr),
@@ -1237,16 +1237,14 @@ static bool rt_cache_valid(const struct rtable *rt)
 static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			   const struct fib_result *res,
 			   struct fib_nh_exception *fnhe,
-			   struct fib_info *fi, u16 type, u32 itag)
+			   struct fib_nh *nh, u16 type, u32 itag)
 {
-	if (fi) {
-		struct fib_nh *nh = &FIB_RES_NH(*res);
-
+	if (nh) {
 		if (nh->nh_gw && nh->nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = nh->nh_gw;
 		if (unlikely(fnhe))
 			rt_bind_exception(rt, fnhe, daddr);
-		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
+		dst_init_metrics(&rt->dst, nh->nh_parent->fib_metrics, true);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
@@ -1373,6 +1371,7 @@ static int __mkroute_input(struct sk_buff *skb,
 			   struct in_device *in_dev,
 			   __be32 daddr, __be32 saddr, u32 tos)
 {
+	struct fib_nh *nh = res->nh;
 	struct rtable *rth;
 	int err;
 	struct in_device *out_dev;
@@ -1381,14 +1380,14 @@ static int __mkroute_input(struct sk_buff *skb,
 	u32 itag;
 
 	/* get a working reference to the output device */
-	out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
+	out_dev = __in_dev_get_rcu(nh->nh_dev);
 	if (out_dev == NULL) {
 		net_crit_ratelimited("Bug in ip_route_input_slow(). Please report.\n");
 		return -EINVAL;
 	}
 
 
-	err = fib_validate_source(skb, saddr, daddr, tos, FIB_RES_OIF(*res),
+	err = fib_validate_source(skb, saddr, daddr, tos, nh->nh_oif,
 				  in_dev->dev, in_dev, &itag);
 	if (err < 0) {
 		ip_handle_martian_source(in_dev->dev, in_dev, skb, daddr,
@@ -1399,7 +1398,7 @@ static int __mkroute_input(struct sk_buff *skb,
 
 	if (out_dev == in_dev && err &&
 	    (IN_DEV_SHARED_MEDIA(out_dev) ||
-	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(*res))))
+	     inet_addr_onlink(out_dev, saddr, nh->nh_gw)))
 		flags |= RTCF_DOREDIRECT;
 
 	if (skb->protocol != htons(ETH_P_IP)) {
@@ -1418,15 +1417,13 @@ static int __mkroute_input(struct sk_buff *skb,
 	}
 
 	do_cache = false;
-	if (res->fi) {
-		if (!itag) {
-			rth = FIB_RES_NH(*res).nh_rth_input;
-			if (rt_cache_valid(rth)) {
-				skb_dst_set_noref(skb, &rth->dst);
-				goto out;
-			}
-			do_cache = true;
+	if (!itag) {
+		rth = nh->nh_rth_input;
+		if (rt_cache_valid(rth)) {
+			skb_dst_set_noref(skb, &rth->dst);
+			goto out;
 		}
+		do_cache = true;
 	}
 
 	rth = rt_dst_alloc(out_dev->dev,
@@ -1448,7 +1445,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 
-	rt_set_nexthop(rth, daddr, res, NULL, res->fi, res->type, itag);
+	rt_set_nexthop(rth, daddr, res, NULL, nh, res->type, itag);
 	skb_dst_set(skb, &rth->dst);
 out:
 	err = 0;
@@ -1463,7 +1460,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res->fi && res->fi->fib_nhs > 1)
+	if (res->nh->nh_parent->fib_nhs > 1)
 		fib_select_multipath(res);
 #endif
 
@@ -1507,7 +1504,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
 		goto martian_source;
 
-	res.fi = NULL;
+	res.nh = NULL;
 	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
 		goto brd_input;
 
@@ -1580,9 +1577,9 @@ brd_input:
 
 local_input:
 	do_cache = false;
-	if (res.fi) {
+	if (res.nh) {
 		if (!itag) {
-			rth = FIB_RES_NH(res).nh_rth_input;
+			rth = res.nh->nh_rth_input;
 			if (rt_cache_valid(rth)) {
 				skb_dst_set_noref(skb, &rth->dst);
 				err = 0;
@@ -1616,7 +1613,7 @@ local_input:
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
 	if (do_cache)
-		rt_cache_route(&FIB_RES_NH(res), rth);
+		rt_cache_route(res.nh, rth);
 	skb_dst_set(skb, &rth->dst);
 	err = 0;
 	goto out;
@@ -1706,8 +1703,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 				       struct net_device *dev_out,
 				       unsigned int flags)
 {
-	struct fib_info *fi = res->fi;
 	struct fib_nh_exception *fnhe;
+	struct fib_nh *nh = res->nh;
 	struct in_device *in_dev;
 	u16 type = res->type;
 	struct rtable *rth;
@@ -1732,7 +1729,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	if (type == RTN_BROADCAST) {
 		flags |= RTCF_BROADCAST | RTCF_LOCAL;
-		fi = NULL;
+		nh = NULL;
 	} else if (type == RTN_MULTICAST) {
 		flags |= RTCF_MULTICAST | RTCF_LOCAL;
 		if (!ip_check_mc_rcu(in_dev, fl4->daddr, fl4->saddr,
@@ -1742,15 +1739,15 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		 * default one, but do not gateway in this case.
 		 * Yes, it is hack.
 		 */
-		if (fi && res->prefixlen < 4)
-			fi = NULL;
+		if (nh && res->prefixlen < 4)
+			nh = NULL;
 	}
 
 	fnhe = NULL;
-	if (fi) {
-		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
+	if (nh) {
+		fnhe = find_exception(nh, fl4->daddr);
 		if (!fnhe) {
-			rth = FIB_RES_NH(*res).nh_rth_output;
+			rth = nh->nh_rth_output;
 			if (rt_cache_valid(rth)) {
 				dst_hold(&rth->dst);
 				return rth;
@@ -1760,7 +1757,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth = rt_dst_alloc(dev_out,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
 			   IN_DEV_CONF_GET(in_dev, NOXFRM),
-			   fi && !fnhe);
+			   nh && !fnhe);
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
@@ -1795,7 +1792,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #endif
 	}
 
-	rt_set_nexthop(rth, fl4->daddr, res, fnhe, fi, type, 0);
+	rt_set_nexthop(rth, fl4->daddr, res, fnhe, nh, type, 0);
 
 	return rth;
 }
@@ -1814,7 +1811,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	int orig_oif;
 
 	res.tclassid	= 0;
-	res.fi		= NULL;
+	res.nh		= NULL;
 	res.table	= NULL;
 
 	orig_oif = fl4->flowi4_oif;
@@ -1915,7 +1912,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	}
 
 	if (fib_lookup(net, fl4, &res)) {
-		res.fi = NULL;
+		res.nh = NULL;
 		res.table = NULL;
 		if (fl4->flowi4_oif) {
 			/* Apparently, routing tables are wrong. Assume,
@@ -1948,20 +1945,21 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 	if (res.type == RTN_LOCAL) {
 		if (!fl4->saddr) {
-			if (res.fi->fib_prefsrc)
-				fl4->saddr = res.fi->fib_prefsrc;
+			struct fib_info *fi = res.nh->nh_parent;
+			if (fi->fib_prefsrc)
+				fl4->saddr = fi->fib_prefsrc;
 			else
 				fl4->saddr = fl4->daddr;
 		}
 		dev_out = net->loopback_dev;
 		fl4->flowi4_oif = dev_out->ifindex;
-		res.fi = NULL;
+		res.nh = NULL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif == 0)
+	if (res.nh->nh_parent->fib_nhs > 1 && fl4->flowi4_oif == 0)
 		fib_select_multipath(&res);
 	else
 #endif
@@ -1971,9 +1969,9 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		fib_select_default(&res);
 
 	if (!fl4->saddr)
-		fl4->saddr = FIB_RES_PREFSRC(net, res);
+		fl4->saddr = fib_res_prefsrc(net, &res);
 
-	dev_out = FIB_RES_DEV(res);
+	dev_out = res.nh->nh_dev;
 	fl4->flowi4_oif = dev_out->ifindex;
 
 
-- 
1.7.10.4
