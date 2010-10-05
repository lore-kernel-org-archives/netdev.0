From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fib: RCU conversion of fib_lookup()
Date: Tue, 05 Oct 2010 22:41:36 +0200
Message-ID: <1286311296.2593.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35467 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761Ab0JEUln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 16:41:43 -0400
Received: by fxm4 with SMTP id 4so748960fxm.19
        for <netdev@vger.kernel.org>; Tue, 05 Oct 2010 13:41:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_lookup() converted to be called in RCU protected context, no
reference taken and released on a contended cache line (fib_clntref)

fib_table_lookup() and fib_semantic_match() get an additional parameter.

struct fib_info gets an rcu_head field, and is freed after an rcu grace
period.

Stress test :
(Sending 160.000.000 UDP frames on same neighbour,
IP route cache disabled, dual E5540 @2.53GHz,
32bit kernel, FIB_HASH) (about same results for FIB_TRIE)

Before patch :

real	1m31.199s
user	0m13.761s
sys	23m24.780s

After patch:

real	1m5.375s
user	0m14.997s
sys	15m50.115s

Before patch Profile :

13044.00 15.4% __ip_route_output_key vmlinux
 8438.00 10.0% dst_destroy           vmlinux
 5983.00  7.1% fib_semantic_match    vmlinux
 5410.00  6.4% fib_rules_lookup      vmlinux
 4803.00  5.7% neigh_lookup          vmlinux
 4420.00  5.2% _raw_spin_lock        vmlinux
 3883.00  4.6% rt_set_nexthop        vmlinux
 3261.00  3.9% _raw_read_lock        vmlinux
 2794.00  3.3% fib_table_lookup      vmlinux
 2374.00  2.8% neigh_resolve_output  vmlinux
 2153.00  2.5% dst_alloc             vmlinux
 1502.00  1.8% _raw_read_lock_bh     vmlinux
 1484.00  1.8% kmem_cache_alloc      vmlinux
 1407.00  1.7% eth_header            vmlinux
 1406.00  1.7% ipv4_dst_destroy      vmlinux
 1298.00  1.5% __copy_from_user_ll   vmlinux
 1174.00  1.4% dev_queue_xmit        vmlinux
 1000.00  1.2% ip_output             vmlinux

After patch Profile :

13712.00 15.8% dst_destroy             vmlinux
 8548.00  9.9% __ip_route_output_key   vmlinux
 7017.00  8.1% neigh_lookup            vmlinux
 4554.00  5.3% fib_semantic_match      vmlinux
 4067.00  4.7% _raw_read_lock          vmlinux
 3491.00  4.0% dst_alloc               vmlinux
 3186.00  3.7% neigh_resolve_output    vmlinux
 3103.00  3.6% fib_table_lookup        vmlinux
 2098.00  2.4% _raw_read_lock_bh       vmlinux
 2081.00  2.4% kmem_cache_alloc        vmlinux
 2013.00  2.3% _raw_spin_lock          vmlinux
 1763.00  2.0% __copy_from_user_ll     vmlinux
 1763.00  2.0% ip_output               vmlinux
 1761.00  2.0% ipv4_dst_destroy        vmlinux
 1631.00  1.9% eth_header              vmlinux
 1440.00  1.7% _raw_read_unlock_bh     vmlinux

Reference results, if IP route cache is enabled :

real	0m29.718s
user	0m10.845s
sys	7m37.341s


25213.00 29.5% __ip_route_output_key   vmlinux
 9011.00 10.5% dst_release             vmlinux
 4817.00  5.6% ip_push_pending_frames  vmlinux
 4232.00  5.0% ip_finish_output        vmlinux
 3940.00  4.6% udp_sendmsg             vmlinux
 3730.00  4.4% __copy_from_user_ll     vmlinux
 3716.00  4.4% ip_route_output_flow    vmlinux
 2451.00  2.9% __xfrm_lookup           vmlinux
 2221.00  2.6% ip_append_data          vmlinux
 1718.00  2.0% _raw_spin_lock_bh       vmlinux
 1655.00  1.9% __alloc_skb             vmlinux
 1572.00  1.8% sock_wfree              vmlinux
 1345.00  1.6% kfree                   vmlinux


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/fib_rules.h  |    2 +
 include/net/ip_fib.h     |   17 ++--------
 net/core/fib_rules.c     |    3 +
 net/ipv4/fib_frontend.c  |   27 ++++++++--------
 net/ipv4/fib_hash.c      |    5 +--
 net/ipv4/fib_lookup.h    |    2 -
 net/ipv4/fib_rules.c     |    3 +
 net/ipv4/fib_semantics.c |   21 ++++++++++---
 net/ipv4/fib_trie.c      |   10 +++---
 net/ipv4/route.c         |   59 +++++++++++++++----------------------
 10 files changed, 72 insertions(+), 77 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index ac2fd00..106f309 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -31,6 +31,8 @@ struct fib_lookup_arg {
 	void			*lookup_ptr;
 	void			*result;
 	struct fib_rule		*rule;
+	int			flags;
+#define FIB_LOOKUP_NOREF	1
 };
 
 struct fib_rules_ops {
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index c93f94e..ba3666d 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -86,6 +86,7 @@ struct fib_info {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			fib_power;
 #endif
+	struct rcu_head		rcu;
 	struct fib_nh		fib_nh[0];
 #define fib_dev		fib_nh[0].nh_dev
 };
@@ -148,7 +149,7 @@ struct fib_table {
 };
 
 extern int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
-			    struct fib_result *res);
+			    struct fib_result *res, int fib_flags);
 extern int fib_table_insert(struct fib_table *, struct fib_config *);
 extern int fib_table_delete(struct fib_table *, struct fib_config *);
 extern int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
@@ -185,11 +186,11 @@ static inline int fib_lookup(struct net *net, const struct flowi *flp,
 	struct fib_table *table;
 
 	table = fib_get_table(net, RT_TABLE_LOCAL);
-	if (!fib_table_lookup(table, flp, res))
+	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))
 		return 0;
 
 	table = fib_get_table(net, RT_TABLE_MAIN);
-	if (!fib_table_lookup(table, flp, res))
+	if (!fib_table_lookup(table, flp, res, FIB_LOOKUP_NOREF))
 		return 0;
 	return -ENETUNREACH;
 }
@@ -254,16 +255,6 @@ static inline void fib_info_put(struct fib_info *fi)
 		free_fib_info(fi);
 }
 
-static inline void fib_res_put(struct fib_result *res)
-{
-	if (res->fi)
-		fib_info_put(res->fi);
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	if (res->r)
-		fib_rule_put(res->r);
-#endif
-}
-
 #ifdef CONFIG_PROC_FS
 extern int __net_init  fib_proc_init(struct net *net);
 extern void __net_exit fib_proc_exit(struct net *net);
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index cfb7d25..21698f8 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -225,7 +225,8 @@ jumped:
 			err = ops->action(rule, fl, flags, arg);
 
 		if (err != -EAGAIN) {
-			if (likely(atomic_inc_not_zero(&rule->refcnt))) {
+			if ((arg->flags & FIB_LOOKUP_NOREF) ||
+			    likely(atomic_inc_not_zero(&rule->refcnt))) {
 				arg->rule = rule;
 				goto out;
 			}
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index b05c23b..919f2ad 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -168,8 +168,11 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 	struct fib_result res = { 0 };
 	struct net_device *dev = NULL;
 
-	if (fib_lookup(net, &fl, &res))
+	rcu_read_lock();
+	if (fib_lookup(net, &fl, &res)) {
+		rcu_read_unlock();
 		return NULL;
+	}
 	if (res.type != RTN_LOCAL)
 		goto out;
 	dev = FIB_RES_DEV(res);
@@ -177,7 +180,7 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 	if (dev && devref)
 		dev_hold(dev);
 out:
-	fib_res_put(&res);
+	rcu_read_unlock();
 	return dev;
 }
 EXPORT_SYMBOL(__ip_dev_find);
@@ -207,11 +210,12 @@ static inline unsigned __inet_dev_addr_type(struct net *net,
 	local_table = fib_get_table(net, RT_TABLE_LOCAL);
 	if (local_table) {
 		ret = RTN_UNICAST;
-		if (!fib_table_lookup(local_table, &fl, &res)) {
+		rcu_read_lock();
+		if (!fib_table_lookup(local_table, &fl, &res, FIB_LOOKUP_NOREF)) {
 			if (!dev || dev == res.fi->fib_dev)
 				ret = res.type;
-			fib_res_put(&res);
 		}
+		rcu_read_unlock();
 	}
 	return ret;
 }
@@ -235,6 +239,7 @@ EXPORT_SYMBOL(inet_dev_addr_type);
  * - figure out what "logical" interface this packet arrived
  *   and calculate "specific destination" address.
  * - check, that packet arrived from expected physical interface.
+ * called with rcu_read_lock()
  */
 int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			struct net_device *dev, __be32 *spec_dst,
@@ -259,7 +264,6 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 	struct net *net;
 
 	no_addr = rpf = accept_local = 0;
-	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev) {
 		no_addr = in_dev->ifa_list == NULL;
@@ -268,7 +272,6 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		if (mark && !IN_DEV_SRC_VMARK(in_dev))
 			fl.mark = 0;
 	}
-	rcu_read_unlock();
 
 	if (in_dev == NULL)
 		goto e_inval;
@@ -278,7 +281,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		goto last_resort;
 	if (res.type != RTN_UNICAST) {
 		if (res.type != RTN_LOCAL || !accept_local)
-			goto e_inval_res;
+			goto e_inval;
 	}
 	*spec_dst = FIB_RES_PREFSRC(res);
 	fib_combine_itag(itag, &res);
@@ -299,10 +302,8 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 #endif
 	if (dev_match) {
 		ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
-		fib_res_put(&res);
 		return ret;
 	}
-	fib_res_put(&res);
 	if (no_addr)
 		goto last_resort;
 	if (rpf == 1)
@@ -315,7 +316,6 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			*spec_dst = FIB_RES_PREFSRC(res);
 			ret = FIB_RES_NH(res).nh_scope >= RT_SCOPE_HOST;
 		}
-		fib_res_put(&res);
 	}
 	return ret;
 
@@ -326,8 +326,6 @@ last_resort:
 	*itag = 0;
 	return 0;
 
-e_inval_res:
-	fib_res_put(&res);
 e_inval:
 	return -EINVAL;
 e_rpf:
@@ -873,15 +871,16 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 		local_bh_disable();
 
 		frn->tb_id = tb->tb_id;
-		frn->err = fib_table_lookup(tb, &fl, &res);
+		rcu_read_lock();
+		frn->err = fib_table_lookup(tb, &fl, &res, FIB_LOOKUP_NOREF);
 
 		if (!frn->err) {
 			frn->prefixlen = res.prefixlen;
 			frn->nh_sel = res.nh_sel;
 			frn->type = res.type;
 			frn->scope = res.scope;
-			fib_res_put(&res);
 		}
+		rcu_read_unlock();
 		local_bh_enable();
 	}
 }
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 4ed7e0d..83cca68 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -244,7 +244,8 @@ fn_new_zone(struct fn_hash *table, int z)
 }
 
 int fib_table_lookup(struct fib_table *tb,
-		     const struct flowi *flp, struct fib_result *res)
+		     const struct flowi *flp, struct fib_result *res,
+		     int fib_flags)
 {
 	int err;
 	struct fn_zone *fz;
@@ -264,7 +265,7 @@ int fib_table_lookup(struct fib_table *tb,
 
 			err = fib_semantic_match(&f->fn_alias,
 						 flp, res,
-						 fz->fz_order);
+						 fz->fz_order, fib_flags);
 			if (err <= 0)
 				goto out;
 		}
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 637b133..b9c9a9f 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -22,7 +22,7 @@ struct fib_alias {
 /* Exported by fib_semantics.c */
 extern int fib_semantic_match(struct list_head *head,
 			      const struct flowi *flp,
-			      struct fib_result *res, int prefixlen);
+			      struct fib_result *res, int prefixlen, int fib_flags);
 extern void fib_release_info(struct fib_info *);
 extern struct fib_info *fib_create_info(struct fib_config *cfg);
 extern int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 3230052..7981a24 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -57,6 +57,7 @@ int fib_lookup(struct net *net, struct flowi *flp, struct fib_result *res)
 {
 	struct fib_lookup_arg arg = {
 		.result = res,
+		.flags = FIB_LOOKUP_NOREF,
 	};
 	int err;
 
@@ -94,7 +95,7 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 	if (!tbl)
 		goto errout;
 
-	err = fib_table_lookup(tbl, flp, (struct fib_result *) arg->result);
+	err = fib_table_lookup(tbl, flp, (struct fib_result *) arg->result, arg->flags);
 	if (err > 0)
 		err = -EAGAIN;
 errout:
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index ba52f39..0f80dfc 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -148,6 +148,13 @@ static const struct
 
 /* Release a nexthop info record */
 
+static void free_fib_info_rcu(struct rcu_head *head)
+{
+	struct fib_info *fi = container_of(head, struct fib_info, rcu);
+
+	kfree(fi);
+}
+
 void free_fib_info(struct fib_info *fi)
 {
 	if (fi->fib_dead == 0) {
@@ -161,7 +168,7 @@ void free_fib_info(struct fib_info *fi)
 	} endfor_nexthops(fi);
 	fib_info_cnt--;
 	release_net(fi->fib_net);
-	kfree(fi);
+	call_rcu(&fi->rcu, free_fib_info_rcu);
 }
 
 void fib_release_info(struct fib_info *fi)
@@ -553,6 +560,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			nh->nh_scope = RT_SCOPE_LINK;
 			return 0;
 		}
+		rcu_read_lock();
 		{
 			struct flowi fl = {
 				.nl_u = {
@@ -568,8 +576,10 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			if (fl.fl4_scope < RT_SCOPE_LINK)
 				fl.fl4_scope = RT_SCOPE_LINK;
 			err = fib_lookup(net, &fl, &res);
-			if (err)
+			if (err) {
+				rcu_read_unlock();
 				return err;
+			}
 		}
 		err = -EINVAL;
 		if (res.type != RTN_UNICAST && res.type != RTN_LOCAL)
@@ -585,7 +595,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 			goto out;
 		err = 0;
 out:
-		fib_res_put(&res);
+		rcu_read_unlock();
 		return err;
 	} else {
 		struct in_device *in_dev;
@@ -879,7 +889,7 @@ failure:
 
 /* Note! fib_semantic_match intentionally uses  RCU list functions. */
 int fib_semantic_match(struct list_head *head, const struct flowi *flp,
-		       struct fib_result *res, int prefixlen)
+		       struct fib_result *res, int prefixlen, int fib_flags)
 {
 	struct fib_alias *fa;
 	int nh_sel = 0;
@@ -943,7 +953,8 @@ out_fill_res:
 	res->type = fa->fa_type;
 	res->scope = fa->fa_scope;
 	res->fi = fa->fa_info;
-	atomic_inc(&res->fi->fib_clntref);
+	if (!(fib_flags & FIB_LOOKUP_NOREF))
+		atomic_inc(&res->fi->fib_clntref);
 	return 0;
 }
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index a96e5ec..271c89b 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1342,7 +1342,7 @@ err:
 /* should be called with rcu_read_lock */
 static int check_leaf(struct trie *t, struct leaf *l,
 		      t_key key,  const struct flowi *flp,
-		      struct fib_result *res)
+		      struct fib_result *res, int fib_flags)
 {
 	struct leaf_info *li;
 	struct hlist_head *hhead = &l->list;
@@ -1356,7 +1356,7 @@ static int check_leaf(struct trie *t, struct leaf *l,
 		if (l->key != (key & ntohl(mask)))
 			continue;
 
-		err = fib_semantic_match(&li->falh, flp, res, plen);
+		err = fib_semantic_match(&li->falh, flp, res, plen, fib_flags);
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 		if (err <= 0)
@@ -1372,7 +1372,7 @@ static int check_leaf(struct trie *t, struct leaf *l,
 }
 
 int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
-		     struct fib_result *res)
+		     struct fib_result *res, int fib_flags)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	int ret;
@@ -1399,7 +1399,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
 
 	/* Just a leaf? */
 	if (IS_LEAF(n)) {
-		ret = check_leaf(t, (struct leaf *)n, key, flp, res);
+		ret = check_leaf(t, (struct leaf *)n, key, flp, res, fib_flags);
 		goto found;
 	}
 
@@ -1424,7 +1424,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
 		}
 
 		if (IS_LEAF(n)) {
-			ret = check_leaf(t, (struct leaf *)n, key, flp, res);
+			ret = check_leaf(t, (struct leaf *)n, key, flp, res, fib_flags);
 			if (ret > 0)
 				goto backtrace;
 			goto found;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 04e0df8..7864d0c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1773,12 +1773,15 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 
 	if (rt->fl.iif == 0)
 		src = rt->rt_src;
-	else if (fib_lookup(dev_net(rt->dst.dev), &rt->fl, &res) == 0) {
-		src = FIB_RES_PREFSRC(res);
-		fib_res_put(&res);
-	} else
-		src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
+	else {
+		rcu_read_lock();
+		if (fib_lookup(dev_net(rt->dst.dev), &rt->fl, &res) == 0)
+			src = FIB_RES_PREFSRC(res);
+		else
+			src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
 					RT_SCOPE_UNIVERSE);
+		rcu_read_unlock();
+	}
 	memcpy(addr, &src, 4);
 }
 
@@ -2081,6 +2084,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
  *	Such approach solves two big problems:
  *	1. Not simplex devices are handled properly.
  *	2. IP spoofing attempts are filtered with 100% of guarantee.
+ *	called with rcu_read_lock()
  */
 
 static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
@@ -2102,7 +2106,6 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	unsigned	hash;
 	__be32		spec_dst;
 	int		err = -EINVAL;
-	int		free_res = 0;
 	struct net    * net = dev_net(dev);
 
 	/* IP on this device is disabled. */
@@ -2134,12 +2137,12 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	/*
 	 *	Now we are ready to route packet.
 	 */
-	if ((err = fib_lookup(net, &fl, &res)) != 0) {
+	err = fib_lookup(net, &fl, &res);
+	if (err != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
 			goto e_hostunreach;
 		goto no_route;
 	}
-	free_res = 1;
 
 	RT_CACHE_STAT_INC(in_slow_tot);
 
@@ -2148,8 +2151,8 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	if (res.type == RTN_LOCAL) {
 		err = fib_validate_source(saddr, daddr, tos,
-					     net->loopback_dev->ifindex,
-					     dev, &spec_dst, &itag, skb->mark);
+					  net->loopback_dev->ifindex,
+					  dev, &spec_dst, &itag, skb->mark);
 		if (err < 0)
 			goto martian_source_keep_err;
 		if (err)
@@ -2164,9 +2167,6 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		goto martian_destination;
 
 	err = ip_mkroute_input(skb, &res, &fl, in_dev, daddr, saddr, tos);
-done:
-	if (free_res)
-		fib_res_put(&res);
 out:	return err;
 
 brd_input:
@@ -2226,7 +2226,7 @@ local_input:
 	rth->rt_type	= res.type;
 	hash = rt_hash(daddr, saddr, fl.iif, rt_genid(net));
 	err = rt_intern_hash(hash, rth, NULL, skb, fl.iif);
-	goto done;
+	goto out;
 
 no_route:
 	RT_CACHE_STAT_INC(in_no_route);
@@ -2249,21 +2249,21 @@ martian_destination:
 
 e_hostunreach:
 	err = -EHOSTUNREACH;
-	goto done;
+	goto out;
 
 e_inval:
 	err = -EINVAL;
-	goto done;
+	goto out;
 
 e_nobufs:
 	err = -ENOBUFS;
-	goto done;
+	goto out;
 
 martian_source:
 	err = -EINVAL;
 martian_source_keep_err:
 	ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
-	goto done;
+	goto out;
 }
 
 int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
@@ -2349,6 +2349,7 @@ skip_cache:
 }
 EXPORT_SYMBOL(ip_route_input_common);
 
+/* called with rcu_read_lock() */
 static int __mkroute_output(struct rtable **result,
 			    struct fib_result *res,
 			    const struct flowi *fl,
@@ -2373,18 +2374,13 @@ static int __mkroute_output(struct rtable **result,
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
-	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev_out);
-	if (!in_dev) {
-		rcu_read_unlock();
+	if (!in_dev)
 		return -EINVAL;
-	}
+
 	if (res->type == RTN_BROADCAST) {
 		flags |= RTCF_BROADCAST | RTCF_LOCAL;
-		if (res->fi) {
-			fib_info_put(res->fi);
-			res->fi = NULL;
-		}
+		res->fi = NULL;
 	} else if (res->type == RTN_MULTICAST) {
 		flags |= RTCF_MULTICAST | RTCF_LOCAL;
 		if (!ip_check_mc(in_dev, oldflp->fl4_dst, oldflp->fl4_src,
@@ -2394,10 +2390,8 @@ static int __mkroute_output(struct rtable **result,
 		 * default one, but do not gateway in this case.
 		 * Yes, it is hack.
 		 */
-		if (res->fi && res->prefixlen < 4) {
-			fib_info_put(res->fi);
+		if (res->fi && res->prefixlen < 4)
 			res->fi = NULL;
-		}
 	}
 
 
@@ -2467,6 +2461,7 @@ static int __mkroute_output(struct rtable **result,
 	return 0;
 }
 
+/* called with rcu_read_lock() */
 static int ip_mkroute_output(struct rtable **rp,
 			     struct fib_result *res,
 			     const struct flowi *fl,
@@ -2509,7 +2504,6 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 	struct fib_result res;
 	unsigned int flags = 0;
 	struct net_device *dev_out = NULL;
-	int free_res = 0;
 	int err;
 
 
@@ -2636,15 +2630,12 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 		err = -ENETUNREACH;
 		goto out;
 	}
-	free_res = 1;
 
 	if (res.type == RTN_LOCAL) {
 		if (!fl.fl4_src)
 			fl.fl4_src = fl.fl4_dst;
 		dev_out = net->loopback_dev;
 		fl.oif = dev_out->ifindex;
-		if (res.fi)
-			fib_info_put(res.fi);
 		res.fi = NULL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
@@ -2668,8 +2659,6 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 make_route:
 	err = ip_mkroute_output(rp, &res, &fl, oldflp, dev_out, flags);
 
-	if (free_res)
-		fib_res_put(&res);
 out:	return err;
 }
 


