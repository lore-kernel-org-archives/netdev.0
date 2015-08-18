From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 06/13] route: move lwtunnel state to dst_entry
Date: Tue, 18 Aug 2015 22:33:15 +0200
Message-ID: <c48cfe628ead51a567f596b93e40e464a3947628.1439929916.git.jbenc@redhat.com>
References: <cover.1439929916.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753094AbbHRUdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 16:33:49 -0400
In-Reply-To: <cover.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the lwtunnel state resides in per-protocol data. This is
a problem if we encapsulate ipv6 traffic in an ipv4 tunnel (or vice versa).
The xmit function of the tunnel does not know whether the packet has been
routed to it by ipv4 or ipv6, yet it needs the lwtstate data. Moving the
lwtstate data to dst_entry makes such inter-protocol tunneling possible.

As a bonus, this brings a nice diffstat.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vrf.c              |  1 -
 drivers/net/vxlan.c            |  4 +--
 include/net/dst.h              |  3 +-
 include/net/dst_metadata.h     | 15 +++------
 include/net/ip6_fib.h          |  1 -
 include/net/lwtunnel.h         | 12 --------
 include/net/route.h            |  1 -
 net/core/dst.c                 |  3 ++
 net/core/filter.c              |  2 +-
 net/core/lwtunnel.c            | 70 ++++++------------------------------------
 net/ipv4/ip_gre.c              |  2 +-
 net/ipv4/route.c               | 20 +++++-------
 net/ipv6/ila.c                 | 14 +++------
 net/ipv6/ip6_fib.c             |  1 -
 net/ipv6/route.c               | 20 ++++++------
 net/mpls/mpls_iptunnel.c       |  7 ++---
 net/openvswitch/vport-netdev.c |  2 +-
 17 files changed, 48 insertions(+), 130 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 95097cb79354..6bc8662aa179 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -289,7 +289,6 @@ static struct rtable *vrf_rtable_create(struct net_device *dev)
 		rth->rt_uses_gateway = 0;
 		INIT_LIST_HEAD(&rth->rt_uncached);
 		rth->rt_uncached_list = NULL;
-		rth->rt_lwtstate = NULL;
 	}
 
 	return rth;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 41e9549e1d5e..e4b8ab63d0fa 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1909,7 +1909,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	u32 flags = vxlan->flags;
 
 	/* FIXME: Support IPv6 */
-	info = skb_tunnel_info(skb, AF_INET);
+	info = skb_tunnel_info(skb);
 
 	if (rdst) {
 		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
@@ -2105,7 +2105,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct vxlan_fdb *f;
 
 	/* FIXME: Support IPv6 */
-	info = skb_tunnel_info(skb, AF_INET);
+	info = skb_tunnel_info(skb);
 
 	skb_reset_mac_header(skb);
 	eth = eth_hdr(skb);
diff --git a/include/net/dst.h b/include/net/dst.h
index 2578811cef51..0a9a723f6c19 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -44,6 +44,7 @@ struct dst_entry {
 #else
 	void			*__pad1;
 #endif
+	struct lwtunnel_state   *lwtstate;
 	int			(*input)(struct sk_buff *);
 	int			(*output)(struct sock *sk, struct sk_buff *skb);
 
@@ -89,7 +90,7 @@ struct dst_entry {
 	 * (L1_CACHE_SIZE would be too much)
 	 */
 #ifdef CONFIG_64BIT
-	long			__pad_to_align_refcnt[2];
+	long			__pad_to_align_refcnt[1];
 #endif
 	/*
 	 * __refcnt wants to be on a different cache line from
diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 075f523ff23f..2cb52d562272 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -23,22 +23,17 @@ static inline struct metadata_dst *skb_metadata_dst(struct sk_buff *skb)
 	return NULL;
 }
 
-static inline struct ip_tunnel_info *skb_tunnel_info(struct sk_buff *skb,
-						     int family)
+static inline struct ip_tunnel_info *skb_tunnel_info(struct sk_buff *skb)
 {
 	struct metadata_dst *md_dst = skb_metadata_dst(skb);
-	struct rtable *rt;
+	struct dst_entry *dst;
 
 	if (md_dst)
 		return &md_dst->u.tun_info;
 
-	switch (family) {
-	case AF_INET:
-		rt = (struct rtable *)skb_dst(skb);
-		if (rt && rt->rt_lwtstate)
-			return lwt_tun_info(rt->rt_lwtstate);
-		break;
-	}
+	dst = skb_dst(skb);
+	if (dst && dst->lwtstate)
+		return lwt_tun_info(dst->lwtstate);
 
 	return NULL;
 }
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 276328e3daa6..063d30474cf6 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -133,7 +133,6 @@ struct rt6_info {
 	/* more non-fragment space at head required */
 	unsigned short			rt6i_nfheader_len;
 	u8				rt6i_protocol;
-	struct lwtunnel_state		*rt6i_lwtstate;
 };
 
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 34fd8f70c2ca..3a5fbabf97da 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -87,9 +87,7 @@ int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate);
 struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len);
 int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b);
 int lwtunnel_output(struct sock *sk, struct sk_buff *skb);
-int lwtunnel_output6(struct sock *sk, struct sk_buff *skb);
 int lwtunnel_input(struct sk_buff *skb);
-int lwtunnel_input6(struct sk_buff *skb);
 
 #else
 
@@ -160,21 +158,11 @@ static inline int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
 	return -EOPNOTSUPP;
 }
 
-static inline int lwtunnel_output6(struct sock *sk, struct sk_buff *skb)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int lwtunnel_input(struct sk_buff *skb)
 {
 	return -EOPNOTSUPP;
 }
 
-static inline int lwtunnel_input6(struct sk_buff *skb)
-{
-	return -EOPNOTSUPP;
-}
-
 #endif
 
 #endif /* __NET_LWTUNNEL_H */
diff --git a/include/net/route.h b/include/net/route.h
index 6dda2c1bf8c6..395d79bb556c 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -66,7 +66,6 @@ struct rtable {
 
 	struct list_head	rt_uncached;
 	struct uncached_list	*rt_uncached_list;
-	struct lwtunnel_state   *rt_lwtstate;
 };
 
 static inline bool rt_is_input_route(const struct rtable *rt)
diff --git a/net/core/dst.c b/net/core/dst.c
index f8694d1b8702..50dcdbb0ee46 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -20,6 +20,7 @@
 #include <net/net_namespace.h>
 #include <linux/sched.h>
 #include <linux/prefetch.h>
+#include <net/lwtunnel.h>
 
 #include <net/dst.h>
 #include <net/dst_metadata.h>
@@ -184,6 +185,7 @@ void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	dst->tclassid = 0;
 #endif
+	dst->lwtstate = NULL;
 	atomic_set(&dst->__refcnt, initial_ref);
 	dst->__use = 0;
 	dst->lastuse = jiffies;
@@ -264,6 +266,7 @@ again:
 		kfree(dst);
 	else
 		kmem_cache_free(dst->ops->kmem_cachep, dst);
+	lwtstate_put(dst->lwtstate);
 
 	dst = child;
 	if (dst) {
diff --git a/net/core/filter.c b/net/core/filter.c
index 379568562ffb..b4adc961413f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1489,7 +1489,7 @@ static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 {
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	struct bpf_tunnel_key *to = (struct bpf_tunnel_key *) (long) r2;
-	struct ip_tunnel_info *info = skb_tunnel_info(skb, AF_INET);
+	struct ip_tunnel_info *info = skb_tunnel_info(skb);
 
 	if (unlikely(size != sizeof(struct bpf_tunnel_key) || flags || !info))
 		return -EINVAL;
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 3331585174d9..e924c2e08554 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -179,14 +179,16 @@ int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b)
 }
 EXPORT_SYMBOL(lwtunnel_cmp_encap);
 
-int __lwtunnel_output(struct sock *sk, struct sk_buff *skb,
-		      struct lwtunnel_state *lwtstate)
+int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
 {
+	struct dst_entry *dst = skb_dst(skb);
 	const struct lwtunnel_encap_ops *ops;
+	struct lwtunnel_state *lwtstate;
 	int ret = -EINVAL;
 
-	if (!lwtstate)
+	if (!dst)
 		goto drop;
+	lwtstate = dst->lwtstate;
 
 	if (lwtstate->type == LWTUNNEL_ENCAP_NONE ||
 	    lwtstate->type > LWTUNNEL_ENCAP_MAX)
@@ -209,47 +211,18 @@ drop:
 
 	return ret;
 }
-
-int lwtunnel_output6(struct sock *sk, struct sk_buff *skb)
-{
-	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
-	struct lwtunnel_state *lwtstate = NULL;
-
-	if (rt) {
-		lwtstate = rt->rt6i_lwtstate;
-		skb->dev = rt->dst.dev;
-	}
-
-	skb->protocol = htons(ETH_P_IPV6);
-
-	return __lwtunnel_output(sk, skb, lwtstate);
-}
-EXPORT_SYMBOL(lwtunnel_output6);
-
-int lwtunnel_output(struct sock *sk, struct sk_buff *skb)
-{
-	struct rtable *rt = (struct rtable *)skb_dst(skb);
-	struct lwtunnel_state *lwtstate = NULL;
-
-	if (rt) {
-		lwtstate = rt->rt_lwtstate;
-		skb->dev = rt->dst.dev;
-	}
-
-	skb->protocol = htons(ETH_P_IP);
-
-	return __lwtunnel_output(sk, skb, lwtstate);
-}
 EXPORT_SYMBOL(lwtunnel_output);
 
-int __lwtunnel_input(struct sk_buff *skb,
-		     struct lwtunnel_state *lwtstate)
+int lwtunnel_input(struct sk_buff *skb)
 {
+	struct dst_entry *dst = skb_dst(skb);
 	const struct lwtunnel_encap_ops *ops;
+	struct lwtunnel_state *lwtstate;
 	int ret = -EINVAL;
 
-	if (!lwtstate)
+	if (!dst)
 		goto drop;
+	lwtstate = dst->lwtstate;
 
 	if (lwtstate->type == LWTUNNEL_ENCAP_NONE ||
 	    lwtstate->type > LWTUNNEL_ENCAP_MAX)
@@ -272,27 +245,4 @@ drop:
 
 	return ret;
 }
-
-int lwtunnel_input6(struct sk_buff *skb)
-{
-	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
-	struct lwtunnel_state *lwtstate = NULL;
-
-	if (rt)
-		lwtstate = rt->rt6i_lwtstate;
-
-	return __lwtunnel_input(skb, lwtstate);
-}
-EXPORT_SYMBOL(lwtunnel_input6);
-
-int lwtunnel_input(struct sk_buff *skb)
-{
-	struct rtable *rt = (struct rtable *)skb_dst(skb);
-	struct lwtunnel_state *lwtstate = NULL;
-
-	if (rt)
-		lwtstate = rt->rt_lwtstate;
-
-	return __lwtunnel_input(skb, lwtstate);
-}
 EXPORT_SYMBOL(lwtunnel_input);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5193618b2600..1bf328182697 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -521,7 +521,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 	__be16 df, flags;
 	int err;
 
-	tun_info = skb_tunnel_info(skb, AF_INET);
+	tun_info = skb_tunnel_info(skb);
 	if (unlikely(!tun_info || tun_info->mode != IP_TUNNEL_INFO_TX))
 		goto err_free_skb;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 2403e85107f0..f3087aaa6dd8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1359,7 +1359,6 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 		list_del(&rt->rt_uncached);
 		spin_unlock_bh(&ul->lock);
 	}
-	lwtstate_put(rt->rt_lwtstate);
 }
 
 void rt_flush_dev(struct net_device *dev)
@@ -1408,7 +1407,7 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
-		rt->rt_lwtstate = lwtstate_get(nh->nh_lwtstate);
+		rt->dst.lwtstate = lwtstate_get(nh->nh_lwtstate);
 		if (unlikely(fnhe))
 			cached = rt_bind_exception(rt, fnhe, daddr);
 		else if (!(rt->dst.flags & DST_NOCACHE))
@@ -1494,7 +1493,6 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
-	rth->rt_lwtstate = NULL;
 	if (our) {
 		rth->dst.input= ip_local_deliver;
 		rth->rt_flags |= RTCF_LOCAL;
@@ -1624,19 +1622,18 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
-	rth->rt_lwtstate = NULL;
 	RT_CACHE_STAT_INC(in_slow_tot);
 
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 
 	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
-	if (lwtunnel_output_redirect(rth->rt_lwtstate)) {
-		rth->rt_lwtstate->orig_output = rth->dst.output;
+	if (lwtunnel_output_redirect(rth->dst.lwtstate)) {
+		rth->dst.lwtstate->orig_output = rth->dst.output;
 		rth->dst.output = lwtunnel_output;
 	}
-	if (lwtunnel_input_redirect(rth->rt_lwtstate)) {
-		rth->rt_lwtstate->orig_input = rth->dst.input;
+	if (lwtunnel_input_redirect(rth->dst.lwtstate)) {
+		rth->dst.lwtstate->orig_input = rth->dst.input;
 		rth->dst.input = lwtunnel_input;
 	}
 	skb_dst_set(skb, &rth->dst);
@@ -1695,7 +1692,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   by fib_lookup.
 	 */
 
-	tun_info = skb_tunnel_info(skb, AF_INET);
+	tun_info = skb_tunnel_info(skb);
 	if (tun_info && tun_info->mode == IP_TUNNEL_INFO_RX)
 		fl4.flowi4_tun_key.tun_id = tun_info->key.tun_id;
 	else
@@ -1815,7 +1812,6 @@ local_input:
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
-	rth->rt_lwtstate = NULL;
 
 	RT_CACHE_STAT_INC(in_slow_tot);
 	if (res.type == RTN_UNREACHABLE) {
@@ -2006,7 +2002,6 @@ add:
 	rth->rt_gateway = 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
-	rth->rt_lwtstate = NULL;
 	RT_CACHE_STAT_INC(out_slow_tot);
 
 	if (flags & RTCF_LOCAL)
@@ -2029,7 +2024,7 @@ add:
 	}
 
 	rt_set_nexthop(rth, fl4->daddr, res, fnhe, fi, type, 0);
-	if (lwtunnel_output_redirect(rth->rt_lwtstate))
+	if (lwtunnel_output_redirect(rth->dst.lwtstate))
 		rth->dst.output = lwtunnel_output;
 
 	return rth;
@@ -2293,7 +2288,6 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_uses_gateway = ort->rt_uses_gateway;
 
 		INIT_LIST_HEAD(&rt->rt_uncached);
-		rt->rt_lwtstate = NULL;
 		dst_free(new);
 	}
 
diff --git a/net/ipv6/ila.c b/net/ipv6/ila.c
index 2540ab4b76d1..f011c3d5ca40 100644
--- a/net/ipv6/ila.c
+++ b/net/ipv6/ila.c
@@ -89,16 +89,13 @@ static void update_ipv6_locator(struct sk_buff *skb, struct ila_params *p)
 static int ila_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct rt6_info *rt6 = NULL;
 
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto drop;
 
-	rt6 = (struct rt6_info *)dst;
+	update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
 
-	update_ipv6_locator(skb, ila_params_lwtunnel(rt6->rt6i_lwtstate));
-
-	return rt6->rt6i_lwtstate->orig_output(sk, skb);
+	return dst->lwtstate->orig_output(sk, skb);
 
 drop:
 	kfree_skb(skb);
@@ -108,16 +105,13 @@ drop:
 static int ila_input(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct rt6_info *rt6 = NULL;
 
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto drop;
 
-	rt6 = (struct rt6_info *)dst;
-
-	update_ipv6_locator(skb, ila_params_lwtunnel(rt6->rt6i_lwtstate));
+	update_ipv6_locator(skb, ila_params_lwtunnel(dst->lwtstate));
 
-	return rt6->rt6i_lwtstate->orig_input(skb);
+	return dst->lwtstate->orig_input(skb);
 
 drop:
 	kfree_skb(skb);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 5693b5eb8482..865e777ae20c 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -178,7 +178,6 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 static void rt6_release(struct rt6_info *rt)
 {
 	if (atomic_dec_and_test(&rt->rt6i_ref)) {
-		lwtstate_put(rt->rt6i_lwtstate);
 		rt6_free_pcpu(rt);
 		dst_free(&rt->dst);
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c3733049715e..e6bbcdee7707 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1784,14 +1784,14 @@ int ip6_route_add(struct fib6_config *cfg)
 					   cfg->fc_encap, &lwtstate);
 		if (err)
 			goto out;
-		rt->rt6i_lwtstate = lwtstate_get(lwtstate);
-		if (lwtunnel_output_redirect(rt->rt6i_lwtstate)) {
-			rt->rt6i_lwtstate->orig_output = rt->dst.output;
-			rt->dst.output = lwtunnel_output6;
+		rt->dst.lwtstate = lwtstate_get(lwtstate);
+		if (lwtunnel_output_redirect(rt->dst.lwtstate)) {
+			rt->dst.lwtstate->orig_output = rt->dst.output;
+			rt->dst.output = lwtunnel_output;
 		}
-		if (lwtunnel_input_redirect(rt->rt6i_lwtstate)) {
-			rt->rt6i_lwtstate->orig_input = rt->dst.input;
-			rt->dst.input = lwtunnel_input6;
+		if (lwtunnel_input_redirect(rt->dst.lwtstate)) {
+			rt->dst.lwtstate->orig_input = rt->dst.input;
+			rt->dst.input = lwtunnel_input;
 		}
 	}
 
@@ -2174,7 +2174,7 @@ static void ip6_rt_copy_init(struct rt6_info *rt, struct rt6_info *ort)
 #endif
 	rt->rt6i_prefsrc = ort->rt6i_prefsrc;
 	rt->rt6i_table = ort->rt6i_table;
-	rt->rt6i_lwtstate = lwtstate_get(ort->rt6i_lwtstate);
+	rt->dst.lwtstate = lwtstate_get(ort->dst.lwtstate);
 }
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
@@ -2838,7 +2838,7 @@ static inline size_t rt6_nlmsg_size(struct rt6_info *rt)
 	       + nla_total_size(sizeof(struct rta_cacheinfo))
 	       + nla_total_size(TCP_CA_NAME_MAX) /* RTAX_CC_ALGO */
 	       + nla_total_size(1) /* RTA_PREF */
-	       + lwtunnel_get_encap_size(rt->rt6i_lwtstate);
+	       + lwtunnel_get_encap_size(rt->dst.lwtstate);
 }
 
 static int rt6_fill_node(struct net *net,
@@ -2991,7 +2991,7 @@ static int rt6_fill_node(struct net *net,
 	if (nla_put_u8(skb, RTA_PREF, IPV6_EXTRACT_PREF(rt->rt6i_flags)))
 		goto nla_put_failure;
 
-	lwtunnel_fill_encap(skb, rt->rt6i_lwtstate);
+	lwtunnel_fill_encap(skb, rt->dst.lwtstate);
 
 	nlmsg_end(skb, nlh);
 	return 0;
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 276f8c992218..3da5ca3ba563 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -48,7 +48,6 @@ int mpls_output(struct sock *sk, struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct rtable *rt = NULL;
 	struct rt6_info *rt6 = NULL;
-	struct lwtunnel_state *lwtstate = NULL;
 	int err = 0;
 	bool bos;
 	int i;
@@ -58,11 +57,9 @@ int mpls_output(struct sock *sk, struct sk_buff *skb)
 	if (skb->protocol == htons(ETH_P_IP)) {
 		ttl = ip_hdr(skb)->ttl;
 		rt = (struct rtable *)dst;
-		lwtstate = rt->rt_lwtstate;
 	} else if (skb->protocol == htons(ETH_P_IPV6)) {
 		ttl = ipv6_hdr(skb)->hop_limit;
 		rt6 = (struct rt6_info *)dst;
-		lwtstate = rt6->rt6i_lwtstate;
 	} else {
 		goto drop;
 	}
@@ -72,12 +69,12 @@ int mpls_output(struct sock *sk, struct sk_buff *skb)
 	/* Find the output device */
 	out_dev = dst->dev;
 	if (!mpls_output_possible(out_dev) ||
-	    !lwtstate || skb_warn_if_lro(skb))
+	    !dst->lwtstate || skb_warn_if_lro(skb))
 		goto drop;
 
 	skb_forward_csum(skb);
 
-	tun_encap_info = mpls_lwtunnel_encap(lwtstate);
+	tun_encap_info = mpls_lwtunnel_encap(dst->lwtstate);
 
 	/* Verify the destination can hold the packet */
 	new_header_size = mpls_encap_size(tun_encap_info);
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index 4b70aaa4a746..a75011505039 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -57,7 +57,7 @@ static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 	skb_push(skb, ETH_HLEN);
 	ovs_skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
 
-	ovs_vport_receive(vport, skb, skb_tunnel_info(skb, AF_INET));
+	ovs_vport_receive(vport, skb, skb_tunnel_info(skb));
 	return;
 
 error:
-- 
1.8.3.1
