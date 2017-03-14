From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy choice
Date: Tue, 14 Mar 2017 17:36:15 +0200
Message-ID: <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com>
References: <1488884508-14016-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, jkbs@redhat.com, edumazet@google.com,
        pch@ordbogen.com, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36506 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752318AbdCNPgl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 11:36:41 -0400
Received: by mail-wm0-f44.google.com with SMTP id n11so67014011wma.1
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 08:36:40 -0700 (PDT)
In-Reply-To: <1488884508-14016-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for ECMP hash policy choice via a new sysctl
called fib_multipath_hash_policy and also adds support for L4 hashes.
The current values for fib_multipath_hash_policy are:
 0 - layer 3 (default)
 1 - layer 4
If there's an skb hash already set and it matches the chosen policy then it
will be used instead of being calculated (currently only for L4).
In L3 mode we always calculate the hash due to the ICMP error special
case, the flow dissector's field consistentification should handle the
address order thus we can remove the address reversals.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v3:
 - keep the ICMP error special handling and always calc L3 hash
   Jakub, could you please run your tests with this version ?

v2:
 - removed the output_key_hash as it's not needed anymore
 - reverted to my original/internal patch with L3 as default hash

 Documentation/networking/ip-sysctl.txt |  8 +++
 include/net/ip_fib.h                   | 14 ++----
 include/net/netns/ipv4.h               |  1 +
 include/net/route.h                    |  9 +---
 net/ipv4/fib_semantics.c               | 11 ++--
 net/ipv4/icmp.c                        | 19 +------
 net/ipv4/route.c                       | 92 ++++++++++++++++++++++++++--------
 net/ipv4/sysctl_net_ipv4.c             |  9 ++++
 8 files changed, 98 insertions(+), 65 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index fc73eeb7b3b8..558e19653106 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -73,6 +73,14 @@ fib_multipath_use_neigh - BOOLEAN
 	0 - disabled
 	1 - enabled
 
+fib_multipath_hash_policy - INTEGER
+	Controls which hash policy to use for multipath routes. Only valid
+	for kernels built with CONFIG_IP_ROUTE_MULTIPATH enabled.
+	Default: 0 (Layer 3)
+	Possible values:
+	0 - Layer 3
+	1 - Layer 4
+
 route/max_size - INTEGER
 	Maximum number of routes allowed in the kernel.  Increase
 	this when using large numbers of interfaces and/or routes.
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index d9cee9659978..8c608a17bd9a 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -383,17 +383,13 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event, bool force);
 int fib_sync_down_addr(struct net_device *dev, __be32 local);
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
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 622d2da27135..70a1d4251790 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -152,6 +152,7 @@ struct netns_ipv4 {
 #endif
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int sysctl_fib_multipath_use_neigh;
+	int sysctl_fib_multipath_hash_policy;
 #endif
 
 	unsigned int	fib_seq;	/* protected by rtnl_mutex */
diff --git a/include/net/route.h b/include/net/route.h
index c0874c87c173..32412c91c222 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -113,14 +113,7 @@ struct in_device;
 int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
-struct rtable *__ip_route_output_key_hash(struct net *, struct flowi4 *flp,
-					  int mp_hash);
-
-static inline struct rtable *__ip_route_output_key(struct net *net,
-						   struct flowi4 *flp)
-{
-	return __ip_route_output_key_hash(net, flp, -1);
-}
+struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp);
 
 struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 				    const struct sock *sk);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 317026a39cfa..6601bd9744c9 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -57,7 +57,6 @@ static unsigned int fib_info_cnt;
 static struct hlist_head fib_info_devhash[DEVINDEX_HASHSIZE];
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-u32 fib_multipath_secret __read_mostly;
 
 #define for_nexthops(fi) {						\
 	int nhsel; const struct fib_nh *nh;				\
@@ -576,9 +575,6 @@ static void fib_rebalance(struct fib_info *fi)
 
 		atomic_set(&nexthop_nh->nh_upper_bound, upper_bound);
 	} endfor_nexthops(fi);
-
-	net_get_random_once(&fib_multipath_secret,
-			    sizeof(fib_multipath_secret));
 }
 
 static inline void fib_add_weight(struct fib_info *fi,
@@ -1641,7 +1637,7 @@ void fib_select_multipath(struct fib_result *res, int hash)
 #endif
 
 void fib_select_path(struct net *net, struct fib_result *res,
-		     struct flowi4 *fl4, int mp_hash)
+		     struct flowi4 *fl4)
 {
 	bool oif_check;
 
@@ -1650,10 +1646,9 @@ void fib_select_path(struct net *net, struct fib_result *res,
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi->fib_nhs > 1 && oif_check) {
-		if (mp_hash < 0)
-			mp_hash = get_hash_from_flowi4(fl4) >> 1;
+		int h = fib_multipath_hash(res->fi, fl4, NULL);
 
-		fib_select_multipath(res, mp_hash);
+		fib_select_multipath(res, h);
 	}
 	else
 #endif
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index fc310db2708b..46630bc30754 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -464,22 +464,6 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	local_bh_enable();
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
@@ -505,8 +489,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->flowi4_oif = l3mdev_master_ifindex(skb_dst(skb_in)->dev);
 
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
-	rt = __ip_route_output_key_hash(net, fl4,
-					icmp_multipath_hash_skb(skb_in));
+	rt = __ip_route_output_key(net, fl4);
 	if (IS_ERR(rt))
 		return rt;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8471dd116771..3d7f99747285 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1734,11 +1734,11 @@ static int __mkroute_input(struct sk_buff *skb,
 }
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-
 /* To make ICMP packets follow the right flow, the multipath hash is
- * calculated from the inner IP addresses in reverse order.
+ * calculated from the inner IP addresses.
  */
-static int ip_multipath_icmp_hash(struct sk_buff *skb)
+static void ip_multipath_icmp_hash(const struct sk_buff *skb,
+				   struct flowi4 *fl4)
 {
 	const struct iphdr *outer_iph = ip_hdr(skb);
 	struct icmphdr _icmph;
@@ -1746,33 +1746,85 @@ static int ip_multipath_icmp_hash(struct sk_buff *skb)
 	struct iphdr _inner_iph;
 	const struct iphdr *inner_iph;
 
+	fl4->saddr = outer_iph->saddr;
+	fl4->daddr = outer_iph->daddr;
 	if (unlikely((outer_iph->frag_off & htons(IP_OFFSET)) != 0))
-		goto standard_hash;
+		return;
 
 	icmph = skb_header_pointer(skb, outer_iph->ihl * 4, sizeof(_icmph),
 				   &_icmph);
 	if (!icmph)
-		goto standard_hash;
+		return;
 
 	if (icmph->type != ICMP_DEST_UNREACH &&
 	    icmph->type != ICMP_REDIRECT &&
 	    icmph->type != ICMP_TIME_EXCEEDED &&
-	    icmph->type != ICMP_PARAMETERPROB) {
-		goto standard_hash;
-	}
+	    icmph->type != ICMP_PARAMETERPROB)
+		return;
 
 	inner_iph = skb_header_pointer(skb,
 				       outer_iph->ihl * 4 + sizeof(_icmph),
 				       sizeof(_inner_iph), &_inner_iph);
 	if (!inner_iph)
-		goto standard_hash;
+		return;
+	fl4->saddr = inner_iph->saddr;
+	fl4->daddr = inner_iph->daddr;
+}
 
-	return fib_multipath_hash(inner_iph->daddr, inner_iph->saddr);
+int fib_multipath_hash(const struct fib_info *fi, const struct flowi4 *fl4,
+		       const struct sk_buff *skb)
+{
+	struct net *net = fi->fib_net;
+	struct flow_keys hash_keys;
+	u32 mhash;
 
-standard_hash:
-	return fib_multipath_hash(outer_iph->saddr, outer_iph->daddr);
-}
+	switch (net->ipv4.sysctl_fib_multipath_hash_policy) {
+	case 0:
+		memset(&hash_keys, 0, sizeof(hash_keys));
+		hash_keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
+		if (skb && ip_hdr(skb)->protocol == IPPROTO_ICMP) {
+			struct flowi4 _fl4;
 
+			ip_multipath_icmp_hash(skb, &_fl4);
+			hash_keys.addrs.v4addrs.src = _fl4.saddr;
+			hash_keys.addrs.v4addrs.dst = _fl4.daddr;
+		} else {
+			hash_keys.addrs.v4addrs.src = fl4->saddr;
+			hash_keys.addrs.v4addrs.dst = fl4->daddr;
+		}
+		break;
+	case 1:
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
+			hash_keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
+			hash_keys.addrs.v4addrs.src = fl4->saddr;
+			hash_keys.addrs.v4addrs.dst = fl4->daddr;
+			hash_keys.ports.src = fl4->fl4_sport;
+			hash_keys.ports.dst = fl4->fl4_dport;
+			hash_keys.basic.ip_proto = fl4->flowi4_proto;
+		}
+		break;
+	}
+	mhash = flow_hash_from_keys(&hash_keys);
+
+	return mhash >> 1;
+}
+EXPORT_SYMBOL_GPL(fib_multipath_hash);
 #endif /* CONFIG_IP_ROUTE_MULTIPATH */
 
 static int ip_mkroute_input(struct sk_buff *skb,
@@ -1782,12 +1834,9 @@ static int ip_mkroute_input(struct sk_buff *skb,
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi && res->fi->fib_nhs > 1) {
-		int h;
+		struct flowi4 fl4 = { .daddr = daddr, .saddr = saddr };
+		int h = fib_multipath_hash(res->fi, &fl4, skb);
 
-		if (unlikely(ip_hdr(skb)->protocol == IPPROTO_ICMP))
-			h = ip_multipath_icmp_hash(skb);
-		else
-			h = fib_multipath_hash(saddr, daddr);
 		fib_select_multipath(res, h);
 	}
 #endif
@@ -2202,8 +2251,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
  * Major route resolver routine.
  */
 
-struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
-					  int mp_hash)
+struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 {
 	struct net_device *dev_out = NULL;
 	__u8 tos = RT_FL_TOS(fl4);
@@ -2365,7 +2413,7 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 		goto make_route;
 	}
 
-	fib_select_path(net, &res, fl4, mp_hash);
+	fib_select_path(net, &res, fl4);
 
 	dev_out = FIB_RES_DEV(res);
 	fl4->flowi4_oif = dev_out->ifindex;
@@ -2378,7 +2426,7 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 	rcu_read_unlock();
 	return rth;
 }
-EXPORT_SYMBOL_GPL(__ip_route_output_key_hash);
+EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
 static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst, u32 cookie)
 {
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d6880a6149ee..62c4f94923e5 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -1004,6 +1004,15 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
+	{
+		.procname	= "fib_multipath_hash_policy",
+		.data		= &init_net.ipv4.sysctl_fib_multipath_hash_policy,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 #endif
 	{
 		.procname	= "ip_unprivileged_port_start",
-- 
2.1.4
