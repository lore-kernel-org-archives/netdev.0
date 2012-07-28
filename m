From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/7] ipv4: Store route type in fib_info.
Date: Fri, 27 Jul 2012 21:18:27 -0700 (PDT)
Message-ID: <20120727.211827.1407418928330016981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab2G1ES1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 00:18:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This removes another value recorded in the fib_result return struct.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    3 ++-
 net/ipv4/devinet.c       |    2 +-
 net/ipv4/fib_frontend.c  |   10 +++++-----
 net/ipv4/fib_lookup.h    |    6 ++----
 net/ipv4/fib_semantics.c |   17 ++++++++++-------
 net/ipv4/fib_trie.c      |   20 ++++++++------------
 net/ipv4/route.c         |   36 ++++++++++++++++++++----------------
 7 files changed, 48 insertions(+), 46 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 847a46b..3cb9e45 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -100,6 +100,7 @@ struct fib_info {
 	unsigned char		fib_dead;
 	unsigned char		fib_protocol;
 	unsigned char		fib_scope;
+	unsigned char		fib_type;
 	__be32			fib_prefsrc;
 	u32			fib_priority;
 	u32			*fib_metrics;
@@ -125,8 +126,8 @@ struct fib_table;
 struct fib_result {
 	unsigned char		prefixlen;
 	unsigned char		__pad;
-	unsigned char		type;
 	unsigned char		__pad2;
+	unsigned char		__pad3;
 	u32			tclassid;
 	struct fib_nh		*nh;
 	struct fib_table	*table;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 1baaa53..1595a67d 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -163,7 +163,7 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 		local = fib_get_table(net, RT_TABLE_LOCAL);
 		if (local &&
 		    !fib_table_lookup(local, &fl4, &res, FIB_LOOKUP_NOREF) &&
-		    res.type == RTN_LOCAL)
+		    res.nh->nh_parent->fib_type == RTN_LOCAL)
 			result = res.nh->nh_dev;
 	}
 	if (result && devref)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index e02390d..495b540 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -175,7 +175,7 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 		rcu_read_lock();
 		if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
 			if (!dev || dev == res.nh->nh_dev)
-				ret = res.type;
+				ret = res.nh->nh_parent->fib_type;
 		}
 		rcu_read_unlock();
 	}
@@ -267,8 +267,8 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	net = dev_net(dev);
 	if (fib_lookup(net, &fl4, &res))
 		goto last_resort;
-	if (res.type != RTN_UNICAST) {
-		if (res.type != RTN_LOCAL || !accept_local)
+	if (res.nh->nh_parent->fib_type != RTN_UNICAST) {
+		if (res.nh->nh_parent->fib_type != RTN_LOCAL || !accept_local)
 			goto e_inval;
 	}
 	fib_combine_itag(itag, &res);
@@ -295,7 +295,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 
 	ret = 0;
 	if (fib_lookup(net, &fl4, &res) == 0) {
-		if (res.type == RTN_UNICAST)
+		if (res.nh->nh_parent->fib_type == RTN_UNICAST)
 			ret = res.nh->nh_scope >= RT_SCOPE_HOST;
 	}
 	return ret;
@@ -945,7 +945,7 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 
 			frn->prefixlen = res.prefixlen;
 			frn->nh_sel = nhsel;
-			frn->type = res.type;
+			frn->type = fi->fib_type;
 			frn->scope = fi->fib_scope;
 		}
 		rcu_read_unlock();
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 5f110b6..3dd6b49 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -9,7 +9,6 @@ struct fib_alias {
 	struct list_head	fa_list;
 	struct fib_info		*fa_info;
 	u8			fa_tos;
-	u8			fa_type;
 	u8			fa_state;
 	struct rcu_head		rcu;
 };
@@ -28,9 +27,8 @@ extern void fib_release_info(struct fib_info *);
 extern struct fib_info *fib_create_info(struct fib_config *cfg);
 extern int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
 extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-			 u32 tb_id, u8 type, __be32 dst,
-			 int dst_len, u8 tos, struct fib_info *fi,
-			 unsigned int);
+			 u32 tb_id, __be32 dst, int dst_len, u8 tos,
+			 struct fib_info *fi, unsigned int);
 extern void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
 		      int dst_len, u32 tb_id, struct nl_info *info,
 		      unsigned int nlm_flags);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 6f73403..13b801a 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -252,7 +252,8 @@ static inline unsigned int fib_info_hashfn(const struct fib_info *fi)
 	unsigned int mask = (fib_info_hash_size - 1);
 	unsigned int val = fi->fib_nhs;
 
-	val ^= (fi->fib_protocol << 8) | fi->fib_scope;
+	val ^= ((fi->fib_protocol << 16) | (fi->fib_scope << 8) |
+		fi->fib_type);
 	val ^= (__force u32)fi->fib_prefsrc;
 	val ^= fi->fib_priority;
 	for_nexthops(fi) {
@@ -279,6 +280,7 @@ static struct fib_info *fib_find_info(const struct fib_info *nfi)
 			continue;
 		if (nfi->fib_protocol == fi->fib_protocol &&
 		    nfi->fib_scope == fi->fib_scope &&
+		    nfi->fib_type == fi->fib_type &&
 		    nfi->fib_prefsrc == fi->fib_prefsrc &&
 		    nfi->fib_priority == fi->fib_priority &&
 		    memcmp(nfi->fib_metrics, fi->fib_metrics,
@@ -359,8 +361,7 @@ void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
 		goto errout;
 
 	err = fib_dump_info(skb, info->pid, seq, event, tb_id,
-			    fa->fa_type, key, dst_len,
-			    fa->fa_tos, fa->fa_info, nlm_flags);
+			    key, dst_len, fa->fa_tos, fa->fa_info, nlm_flags);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in fib_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -610,7 +611,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			}
 		}
 		err = -EINVAL;
-		if (res.type != RTN_UNICAST && res.type != RTN_LOCAL)
+		if (res.nh->nh_parent->fib_type != RTN_UNICAST &&
+		    res.nh->nh_parent->fib_type != RTN_LOCAL)
 			goto out;
 		nh->nh_scope = res.nh->nh_parent->fib_scope;
 		nh->nh_oif = res.nh->nh_oif;
@@ -798,6 +800,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	fi->fib_net = hold_net(net);
 	fi->fib_protocol = cfg->fc_protocol;
 	fi->fib_scope = cfg->fc_scope;
+	fi->fib_type = cfg->fc_type;
 	fi->fib_flags = cfg->fc_flags;
 	fi->fib_priority = cfg->fc_priority;
 	fi->fib_prefsrc = cfg->fc_prefsrc;
@@ -957,7 +960,7 @@ failure:
 }
 
 int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-		  u32 tb_id, u8 type, __be32 dst, int dst_len, u8 tos,
+		  u32 tb_id, __be32 dst, int dst_len, u8 tos,
 		  struct fib_info *fi, unsigned int flags)
 {
 	struct nlmsghdr *nlh;
@@ -978,7 +981,7 @@ int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 		rtm->rtm_table = RT_TABLE_COMPAT;
 	if (nla_put_u32(skb, RTA_TABLE, tb_id))
 		goto nla_put_failure;
-	rtm->rtm_type = type;
+	rtm->rtm_type = fi->fib_type;
 	rtm->rtm_flags = fi->fib_flags;
 	rtm->rtm_scope = fi->fib_scope;
 	rtm->rtm_protocol = fi->fib_protocol;
@@ -1142,7 +1145,7 @@ void fib_select_default(struct fib_result *res)
 
 		if ((next_nh->nh_parent->fib_scope !=
 		     res->nh->nh_parent->fib_scope) ||
-		    fa->fa_type != RTN_UNICAST)
+		    next_nh->nh_parent->fib_type != RTN_UNICAST)
 			continue;
 
 		if (next_nh->nh_parent->fib_priority >
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 83cf215..f812f06 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1253,8 +1253,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 				break;
 			if (fa->fa_info->fib_priority != fi->fib_priority)
 				break;
-			if (fa->fa_type == cfg->fc_type &&
-			    fa->fa_info == fi) {
+			if (fa->fa_info == fi) {
 				fa_match = fa;
 				break;
 			}
@@ -1278,7 +1277,6 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			fi_drop = fa->fa_info;
 			new_fa->fa_tos = fa->fa_tos;
 			new_fa->fa_info = fi;
-			new_fa->fa_type = cfg->fc_type;
 			state = fa->fa_state;
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
 
@@ -1314,7 +1312,6 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 
 	new_fa->fa_info = fi;
 	new_fa->fa_tos = tos;
-	new_fa->fa_type = cfg->fc_type;
 	new_fa->fa_state = 0;
 	/*
 	 * Insert new entry to the list.
@@ -1374,7 +1371,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 			if (fa->fa_info->fib_scope < flp->flowi4_scope)
 				continue;
 			fib_alias_accessed(fa);
-			err = fib_props[fa->fa_type].error;
+			err = fib_props[fi->fib_type].error;
 			if (err) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 				t->stats.semantic_match_passed++;
@@ -1395,7 +1392,6 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 				t->stats.semantic_match_passed++;
 #endif
 				res->prefixlen = li->plen;
-				res->type = fa->fa_type;
 				res->nh = nh;
 				res->table = tb;
 				res->fa_head = &li->falh;
@@ -1670,7 +1666,8 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 		if (fa->fa_tos != tos)
 			break;
 
-		if ((!cfg->fc_type || fa->fa_type == cfg->fc_type) &&
+		if ((!cfg->fc_type ||
+		     fa->fa_info->fib_type == cfg->fc_type) &&
 		    (cfg->fc_scope == RT_SCOPE_NOWHERE ||
 		     fa->fa_info->fib_scope == cfg->fc_scope) &&
 		    (!cfg->fc_prefsrc ||
@@ -1873,7 +1870,6 @@ static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
 				  cb->nlh->nlmsg_seq,
 				  RTM_NEWROUTE,
 				  tb->tb_id,
-				  fa->fa_type,
 				  xkey,
 				  plen,
 				  fa->fa_tos,
@@ -2394,7 +2390,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 					   rtn_scope(buf1, sizeof(buf1),
 						     fa->fa_info->fib_scope),
 					   rtn_type(buf2, sizeof(buf2),
-						    fa->fa_type));
+						    fa->fa_info->fib_type));
 				if (fa->fa_tos)
 					seq_printf(seq, " tos=%d", fa->fa_tos);
 				seq_putc(seq, '\n');
@@ -2546,11 +2542,11 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 
 		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
 			const struct fib_info *fi = fa->fa_info;
-			unsigned int flags = fib_flag_trans(fa->fa_type, mask, fi);
+			unsigned int flags = fib_flag_trans(fi->fib_type, mask, fi);
 			int len;
 
-			if (fa->fa_type == RTN_BROADCAST
-			    || fa->fa_type == RTN_MULTICAST)
+			if (fi->fib_type == RTN_BROADCAST ||
+			    fi->fib_type == RTN_MULTICAST)
 				continue;
 
 			if (fi)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0b3277c..6d4353b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1436,7 +1436,7 @@ static int __mkroute_input(struct sk_buff *skb,
 
 	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
 	rth->rt_flags = flags;
-	rth->rt_type = res->type;
+	rth->rt_type = res->nh->nh_parent->fib_type;
 	rth->rt_is_input = 1;
 	rth->rt_iif 	= 0;
 	rth->rt_pmtu	= 0;
@@ -1445,7 +1445,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 
-	rt_set_nexthop(rth, daddr, res, NULL, nh, res->type, itag);
+	rt_set_nexthop(rth, daddr, res, NULL, nh, rth->rt_type, itag);
 	skb_dst_set(skb, &rth->dst);
 out:
 	err = 0;
@@ -1491,6 +1491,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	int		err = -EINVAL;
 	struct net    *net = dev_net(dev);
 	bool do_cache;
+	u8 type;
 
 	/* IP on this device is disabled. */
 
@@ -1541,10 +1542,11 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	RT_CACHE_STAT_INC(in_slow_tot);
 
-	if (res.type == RTN_BROADCAST)
+	type = res.nh->nh_parent->fib_type;
+	if (type == RTN_BROADCAST)
 		goto brd_input;
 
-	if (res.type == RTN_LOCAL) {
+	if (type == RTN_LOCAL) {
 		err = fib_validate_source(skb, saddr, daddr, tos,
 					  net->loopback_dev->ifindex,
 					  dev, in_dev, &itag);
@@ -1555,7 +1557,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	if (!IN_DEV_FORWARD(in_dev))
 		goto no_route;
-	if (res.type != RTN_UNICAST)
+	if (type != RTN_UNICAST)
 		goto martian_destination;
 
 	err = ip_mkroute_input(skb, &res, &fl4, in_dev, daddr, saddr, tos);
@@ -1572,7 +1574,7 @@ brd_input:
 			goto martian_source_keep_err;
 	}
 	flags |= RTCF_BROADCAST;
-	res.type = RTN_BROADCAST;
+	type = RTN_BROADCAST;
 	RT_CACHE_STAT_INC(in_brd);
 
 local_input:
@@ -1602,12 +1604,12 @@ local_input:
 
 	rth->rt_genid = rt_genid(net);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
-	rth->rt_type	= res.type;
+	rth->rt_type	= type;
 	rth->rt_is_input = 1;
 	rth->rt_iif	= 0;
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
-	if (res.type == RTN_UNREACHABLE) {
+	if (type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
 		rth->dst.error= -err;
 		rth->rt_flags 	&= ~RTCF_LOCAL;
@@ -1620,7 +1622,7 @@ local_input:
 
 no_route:
 	RT_CACHE_STAT_INC(in_no_route);
-	res.type = RTN_UNREACHABLE;
+	type = RTN_UNREACHABLE;
 	if (err == -ESRCH)
 		err = -ENETUNREACH;
 	goto local_input;
@@ -1700,13 +1702,12 @@ EXPORT_SYMBOL(ip_route_input_noref);
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
 				       const struct flowi4 *fl4, int orig_oif,
-				       struct net_device *dev_out,
+				       struct net_device *dev_out, u8 type,
 				       unsigned int flags)
 {
 	struct fib_nh_exception *fnhe;
 	struct fib_nh *nh = res->nh;
 	struct in_device *in_dev;
-	u16 type = res->type;
 	struct rtable *rth;
 
 	in_dev = __in_dev_get_rcu(dev_out);
@@ -1809,6 +1810,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 	struct fib_result res;
 	struct rtable *rth;
 	int orig_oif;
+	u8 type;
 
 	res.tclassid	= 0;
 	res.nh		= NULL;
@@ -1822,6 +1824,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 			 RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
 
 	rcu_read_lock();
+	type = 0;
 	if (fl4->saddr) {
 		rth = ERR_PTR(-EINVAL);
 		if (ipv4_is_multicast(fl4->saddr) ||
@@ -1906,7 +1909,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 			fl4->daddr = fl4->saddr = htonl(INADDR_LOOPBACK);
 		dev_out = net->loopback_dev;
 		fl4->flowi4_oif = net->loopback_dev->ifindex;
-		res.type = RTN_LOCAL;
+		type = RTN_LOCAL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
@@ -1936,14 +1939,15 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 			if (fl4->saddr == 0)
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_LINK);
-			res.type = RTN_UNICAST;
+			type = RTN_UNICAST;
 			goto make_route;
 		}
 		rth = ERR_PTR(-ENETUNREACH);
 		goto out;
 	}
+	type = res.nh->nh_parent->fib_type;
 
-	if (res.type == RTN_LOCAL) {
+	if (type == RTN_LOCAL) {
 		if (!fl4->saddr) {
 			struct fib_info *fi = res.nh->nh_parent;
 			if (fi->fib_prefsrc)
@@ -1965,7 +1969,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 #endif
 	if (!res.prefixlen &&
 	    res.table->tb_num_default > 1 &&
-	    res.type == RTN_UNICAST && !fl4->flowi4_oif)
+	    type == RTN_UNICAST && !fl4->flowi4_oif)
 		fib_select_default(&res);
 
 	if (!fl4->saddr)
@@ -1976,7 +1980,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 
 
 make_route:
-	rth = __mkroute_output(&res, fl4, orig_oif, dev_out, flags);
+	rth = __mkroute_output(&res, fl4, orig_oif, dev_out, type, flags);
 
 out:
 	rcu_read_unlock();
-- 
1.7.10.4
