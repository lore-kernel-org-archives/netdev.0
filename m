From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [RFC PATCH] net: ipv4: add l3 and l4 multipath algorithms
Date: Sun, 17 Apr 2016 16:29:35 +0200
Message-ID: <1460903375-22190-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: tom@herbertland.com, roopa@cumulusnetworks.com,
	dsa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	pch@ordbogen.com, davem@davemloft.net, eric.dumazet@gmail.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35404 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbcDQO3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 10:29:46 -0400
Received: by mail-wm0-f47.google.com with SMTP id a140so87875099wma.0
        for <netdev@vger.kernel.org>; Sun, 17 Apr 2016 07:29:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I've been looking into adding both l3 and l4 multipath algorithms which
are consistent in both forwarded and locally originated traffic.
This attempt removes the old multipath code, and trades performance for
unifying both locally originated and forwarded traffic cases.
There's one case that is much faster though - for the forwarded case if the
l4 hash is already present we'll shortcircuit and use that.
We would like to see/implement the following items:
 1. Unified and consistent multipath for local and forwarded traffic
 2. Choice between different multipath algorithms
 3. IPv4 and IPv6 symmetry (as much as we can)
 4. Use of precomputed hash where possible

The first two points and partially the fourth are implemented by this
patch. Currently we can only be certain if the hash is L4, thus we can only
use skb->hash in the L4 hash case, the L3 hash is always computed.
Later we might revisit fib_multipath_hash and change it to accept enum
pkt_hash_types based on the precomputed hash that is passed.
Unfortunately I have to remove the special ICMP handling for now, I don't
mind adding the same workaround for IPv6 though, I'm not sure which is
preferred. This patch changes the IPv4 L4 hash to be computed only over
{src/dst IP, src/dst port, protocol}.

About the third point if a change like this is acceptable, I'll post the
respective IPv6 change which will make it symmetric in the way the hash
is derived.

And about the fourth point, I have a quick and dirty patch that passes
the socket txhash (currently randomly generated) for connected sockets down
to the multipath selection algorithm. It uses a 4 byte hole in flowi_common
to pass it down, but it's far from ready so I will not be submitting it with
this change.

The hash over flow_keys directly was chosen to avoid one zeroing and a few
initializations since if I were to use a flowi hash function it'd boil down
to flow_keys again, but I'd have to zero and initialize a fake flowi4 struct
as well. If this is not desired, I don't mind reverting to using the flowi4
version.

What do you think ?

Thanks,
 Nik

Note: if you'd like to minimize the performance hit for L3, I can simply
use the jhash_2words directly, but that would violate point 3.
---
 drivers/net/vrf.c              |  2 +-
 include/net/ip_fib.h           | 16 ++++----
 include/net/route.h            |  5 +--
 include/uapi/linux/rtnetlink.h | 10 ++++-
 net/ipv4/fib_frontend.c        |  8 ++++
 net/ipv4/fib_semantics.c       | 23 +++++++-----
 net/ipv4/icmp.c                | 19 +---------
 net/ipv4/route.c               | 83 +++++++++++++++++++++---------------------
 8 files changed, 82 insertions(+), 84 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 9a9fabb900c1..3ab7a62edb23 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -768,7 +768,7 @@ static int vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 		if (res.type == RTN_LOCAL)
 			fl4->saddr = res.fi->fib_prefsrc ? : fl4->daddr;
 		else
-			fib_select_path(net, &res, fl4, -1);
+			fib_select_path(net, &res, fl4);
 	}
 
 	fl4->flowi4_flags = flags;
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 4079fc18ffe4..0ddcc028e520 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -37,6 +37,7 @@ struct fib_config {
 	u32			fc_flags;
 	u32			fc_priority;
 	__be32			fc_prefsrc;
+	u32			fc_mp_alg;
 	struct nlattr		*fc_mx;
 	struct rtnexthop	*fc_mp;
 	int			fc_mx_len;
@@ -120,6 +121,7 @@ struct fib_info {
 	int			fib_nhs;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			fib_weight;
+	u32			fib_mp_alg;
 #endif
 	struct rcu_head		rcu;
 	struct fib_nh		fib_nh[0];
@@ -322,17 +324,13 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event, bool force);
 int fib_sync_down_addr(struct net *net, __be32 local);
 int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
 
-extern u32 fib_multipath_secret __read_mostly;
-
-static inline int fib_multipath_hash(__be32 saddr, __be32 daddr)
-{
-	return jhash_2words((__force u32)saddr, (__force u32)daddr,
-			    fib_multipath_secret) >> 1;
-}
-
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+int fib_multipath_hash(const struct fib_info *fi, const struct flowi4 *fl4,
+		       const struct sk_buff *skb);
+#endif
 void fib_select_multipath(struct fib_result *res, int hash);
 void fib_select_path(struct net *net, struct fib_result *res,
-		     struct flowi4 *fl4, int mp_hash);
+		     struct flowi4 *fl4);
 
 /* Exported by fib_trie.c */
 void fib_trie_init(void);
diff --git a/include/net/route.h b/include/net/route.h
index f4b11eee1754..2146964bdf6d 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -114,13 +114,12 @@ struct in_device;
 int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
-struct rtable *__ip_route_output_key_hash(struct net *, struct flowi4 *flp,
-					  int mp_hash);
+struct rtable *__ip_route_output_key_hash(struct net *, struct flowi4 *flp);
 
 static inline struct rtable *__ip_route_output_key(struct net *net,
 						   struct flowi4 *flp)
 {
-	return __ip_route_output_key_hash(net, flp, -1);
+	return __ip_route_output_key_hash(net, flp);
 }
 
 struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 6be7fabf94a8..5d76194557d9 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -272,6 +272,14 @@ enum rt_scope_t {
 #define RTM_F_PREFIX		0x800	/* Prefix addresses		*/
 #define RTM_F_LOOKUP_TABLE	0x1000	/* set rtm_table to FIB lookup result */
 
+/* Multipath algorithms */
+enum rt_mp_alg_t {
+	RT_MP_ALG_L3_HASH,
+	RT_MP_ALG_L4_HASH,
+	__RT_MP_ALG_MAX
+};
+#define RT_MP_ALG_MAX (__RT_MP_ALG_MAX - 1)
+
 /* Reserved table identifiers */
 
 enum rt_class_t {
@@ -302,7 +310,7 @@ enum rtattr_type_t {
 	RTA_FLOW,
 	RTA_CACHEINFO,
 	RTA_SESSION, /* no longer used */
-	RTA_MP_ALGO, /* no longer used */
+	RTA_MP_ALGO,
 	RTA_TABLE,
 	RTA_MARK,
 	RTA_MFC_STATS,
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 8a9246deccfe..0aecfec8f7a6 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -624,6 +624,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_PREFSRC]		= { .type = NLA_U32 },
 	[RTA_METRICS]		= { .type = NLA_NESTED },
 	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
+	[RTA_MP_ALGO]		= { .type = NLA_U32 },
 	[RTA_FLOW]		= { .type = NLA_U32 },
 	[RTA_ENCAP_TYPE]	= { .type = NLA_U16 },
 	[RTA_ENCAP]		= { .type = NLA_NESTED },
@@ -686,6 +687,13 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 			cfg->fc_mp = nla_data(attr);
 			cfg->fc_mp_len = nla_len(attr);
 			break;
+		case RTA_MP_ALGO:
+			cfg->fc_mp_alg = nla_get_u32(attr);
+			if (cfg->fc_mp_alg > RT_MP_ALG_MAX) {
+				err = -EINVAL;
+				goto errout;
+			}
+			break;
 		case RTA_FLOW:
 			cfg->fc_flow = nla_get_u32(attr);
 			break;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index ab64d9f2eef9..8af436352ec4 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -57,7 +57,6 @@ static unsigned int fib_info_cnt;
 static struct hlist_head fib_info_devhash[DEVINDEX_HASHSIZE];
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-u32 fib_multipath_secret __read_mostly;
 
 #define for_nexthops(fi) {						\
 	int nhsel; const struct fib_nh *nh;				\
@@ -257,6 +256,11 @@ static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
 {
 	const struct fib_nh *onh = ofi->fib_nh;
 
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	if (fi->fib_mp_alg != ofi->fib_mp_alg)
+		return -1;
+#endif
+
 	for_nexthops(fi) {
 		if (nh->nh_oif != onh->nh_oif ||
 		    nh->nh_gw  != onh->nh_gw ||
@@ -575,9 +579,6 @@ static void fib_rebalance(struct fib_info *fi)
 
 		atomic_set(&nexthop_nh->nh_upper_bound, upper_bound);
 	} endfor_nexthops(fi);
-
-	net_get_random_once(&fib_multipath_secret,
-			    sizeof(fib_multipath_secret));
 }
 
 static inline void fib_add_weight(struct fib_info *fi,
@@ -1064,6 +1065,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 
 	if (cfg->fc_mp) {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
+		fi->fib_mp_alg = cfg->fc_mp_alg;
 		err = fib_get_nhs(fi, cfg->fc_mp, cfg->fc_mp_len, cfg);
 		if (err != 0)
 			goto failure;
@@ -1277,6 +1279,9 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		struct rtnexthop *rtnh;
 		struct nlattr *mp;
 
+		if (nla_put_u32(skb, RTA_MP_ALGO, fi->fib_mp_alg))
+			goto nla_put_failure;
+
 		mp = nla_nest_start(skb, RTA_MULTIPATH);
 		if (!mp)
 			goto nla_put_failure;
@@ -1602,16 +1607,14 @@ void fib_select_multipath(struct fib_result *res, int hash)
 #endif
 
 void fib_select_path(struct net *net, struct fib_result *res,
-		     struct flowi4 *fl4, int mp_hash)
+		     struct flowi4 *fl4)
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi->fib_nhs > 1 && fl4->flowi4_oif == 0) {
-		if (mp_hash < 0)
-			mp_hash = get_hash_from_flowi4(fl4) >> 1;
+		int h = fib_multipath_hash(res->fi, fl4, NULL);
 
-		fib_select_multipath(res, mp_hash);
-	}
-	else
+		fib_select_multipath(res, h);
+	} else
 #endif
 	if (!res->prefixlen &&
 	    res->table->tb_num_default > 1 &&
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 6333489771ed..51a4db5f22ad 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -440,22 +440,6 @@ out_unlock:
 	icmp_xmit_unlock(sk);
 }
 
-#ifdef CONFIG_IP_ROUTE_MULTIPATH
-
-/* Source and destination is swapped. See ip_multipath_icmp_hash */
-static int icmp_multipath_hash_skb(const struct sk_buff *skb)
-{
-	const struct iphdr *iph = ip_hdr(skb);
-
-	return fib_multipath_hash(iph->daddr, iph->saddr);
-}
-
-#else
-
-#define icmp_multipath_hash_skb(skb) (-1)
-
-#endif
-
 static struct rtable *icmp_route_lookup(struct net *net,
 					struct flowi4 *fl4,
 					struct sk_buff *skb_in,
@@ -480,8 +464,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->flowi4_oif = l3mdev_master_ifindex(skb_in->dev);
 
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
-	rt = __ip_route_output_key_hash(net, fl4,
-					icmp_multipath_hash_skb(skb_in));
+	rt = __ip_route_output_key_hash(net, fl4);
 	if (IS_ERR(rt))
 		return rt;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 02c62299d717..fba9de1f02d9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1692,45 +1692,49 @@ out:
 }
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-
-/* To make ICMP packets follow the right flow, the multipath hash is
- * calculated from the inner IP addresses in reverse order.
- */
-static int ip_multipath_icmp_hash(struct sk_buff *skb)
+int fib_multipath_hash(const struct fib_info *fi, const struct flowi4 *fl4,
+		       const struct sk_buff *skb)
 {
-	const struct iphdr *outer_iph = ip_hdr(skb);
-	struct icmphdr _icmph;
-	const struct icmphdr *icmph;
-	struct iphdr _inner_iph;
-	const struct iphdr *inner_iph;
-
-	if (unlikely((outer_iph->frag_off & htons(IP_OFFSET)) != 0))
-		goto standard_hash;
+	struct flow_keys hash_keys;
+	u32 mhash;
 
-	icmph = skb_header_pointer(skb, outer_iph->ihl * 4, sizeof(_icmph),
-				   &_icmph);
-	if (!icmph)
-		goto standard_hash;
-
-	if (icmph->type != ICMP_DEST_UNREACH &&
-	    icmph->type != ICMP_REDIRECT &&
-	    icmph->type != ICMP_TIME_EXCEEDED &&
-	    icmph->type != ICMP_PARAMETERPROB) {
-		goto standard_hash;
+	switch (fi->fib_mp_alg) {
+	case RT_MP_ALG_L3_HASH:
+		memset(&hash_keys, 0, sizeof(hash_keys));
+		hash_keys.addrs.v4addrs.src = fl4->saddr;
+		hash_keys.addrs.v4addrs.dst = fl4->daddr;
+		break;
+	case RT_MP_ALG_L4_HASH:
+		/* skb is currently provided only when forwarding */
+		if (skb) {
+			unsigned int flag = FLOW_DISSECTOR_F_STOP_AT_ENCAP;
+			struct flow_keys keys;
+
+			/* short-circuit if we already have L4 hash present */
+			if (skb->l4_hash)
+				return skb_get_hash_raw(skb) >> 1;
+			memset(&hash_keys, 0, sizeof(hash_keys));
+			skb_flow_dissect_flow_keys(skb, &keys, flag);
+			hash_keys.addrs.v4addrs.src = keys.addrs.v4addrs.src;
+			hash_keys.addrs.v4addrs.dst = keys.addrs.v4addrs.dst;
+			hash_keys.ports.src = keys.ports.src;
+			hash_keys.ports.dst = keys.ports.dst;
+			hash_keys.basic.ip_proto = keys.basic.ip_proto;
+		} else {
+			memset(&hash_keys, 0, sizeof(hash_keys));
+			hash_keys.addrs.v4addrs.src = fl4->saddr;
+			hash_keys.addrs.v4addrs.dst = fl4->daddr;
+			hash_keys.ports.src = fl4->fl4_sport;
+			hash_keys.ports.dst = fl4->fl4_dport;
+			hash_keys.basic.ip_proto = fl4->flowi4_proto;
+		}
+		break;
 	}
+	mhash = flow_hash_from_keys(&hash_keys);
 
-	inner_iph = skb_header_pointer(skb,
-				       outer_iph->ihl * 4 + sizeof(_icmph),
-				       sizeof(_inner_iph), &_inner_iph);
-	if (!inner_iph)
-		goto standard_hash;
-
-	return fib_multipath_hash(inner_iph->daddr, inner_iph->saddr);
-
-standard_hash:
-	return fib_multipath_hash(outer_iph->saddr, outer_iph->daddr);
+	return mhash >> 1;
 }
-
+EXPORT_SYMBOL_GPL(fib_multipath_hash);
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
 
 static int ip_mkroute_input(struct sk_buff *skb,
@@ -1741,12 +1745,8 @@ static int ip_mkroute_input(struct sk_buff *skb,
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi && res->fi->fib_nhs > 1) {
-		int h;
+		int h = fib_multipath_hash(res->fi, fl4, skb);
 
-		if (unlikely(ip_hdr(skb)->protocol == IPPROTO_ICMP))
-			h = ip_multipath_icmp_hash(skb);
-		else
-			h = fib_multipath_hash(saddr, daddr);
 		fib_select_multipath(res, h);
 	}
 #endif
@@ -2125,8 +2125,7 @@ add:
  * Major route resolver routine.
  */
 
-struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
-					  int mp_hash)
+struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4)
 {
 	struct net_device *dev_out = NULL;
 	__u8 tos = RT_FL_TOS(fl4);
@@ -2289,7 +2288,7 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 		goto make_route;
 	}
 
-	fib_select_path(net, &res, fl4, mp_hash);
+	fib_select_path(net, &res, fl4);
 
 	dev_out = FIB_RES_DEV(res);
 	fl4->flowi4_oif = dev_out->ifindex;
-- 
2.4.11
