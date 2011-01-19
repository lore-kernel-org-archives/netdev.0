From: kaber@trash.net
Subject: [PATCH 60/79] netfilter: fix Kconfig dependencies
Date: Wed, 19 Jan 2011 20:15:00 +0100
Message-ID: <1295464519-21763-61-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51978 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753970Ab1ASTPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:40 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Fix dependencies of netfilter realm match: it depends on NET_CLS_ROUTE,
which itself depends on NET_SCHED; this dependency is missing from netfilter.

Since matching on realms is also useful without having NET_SCHED enabled and
the option really only controls whether the tclassid member is included in
route and dst entries, rename the config option to IP_ROUTE_CLASSID and move
it outside of traffic scheduling context to get rid of the NET_SCHED dependeny.

Reported-by: Vladis Kletnieks <Valdis.Kletnieks@vt.edu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/dst.h        |    2 +-
 include/net/ip_fib.h     |    6 +++---
 net/ipv4/Kconfig         |    4 +++-
 net/ipv4/fib_rules.c     |   10 +++++-----
 net/ipv4/fib_semantics.c |   14 +++++++-------
 net/ipv4/ip_input.c      |    2 +-
 net/ipv4/route.c         |   26 +++++++++++++-------------
 net/netfilter/Kconfig    |    2 +-
 net/sched/Kconfig        |    5 +----
 net/sched/cls_flow.c     |    2 +-
 net/sched/em_meta.c      |    2 +-
 11 files changed, 37 insertions(+), 38 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index a5bd726..6baba83 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -72,7 +72,7 @@ struct dst_entry {
 
 	u32			metrics[RTAX_MAX];
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	__u32			tclassid;
 #else
 	__u32			__pad2;
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 07bdb5e..65d1fcd 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -55,7 +55,7 @@ struct fib_nh {
 	int			nh_weight;
 	int			nh_power;
 #endif
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	__u32			nh_tclassid;
 #endif
 	int			nh_oif;
@@ -201,7 +201,7 @@ static inline int fib_lookup(struct net *net, const struct flowi *flp,
 extern int __net_init fib4_rules_init(struct net *net);
 extern void __net_exit fib4_rules_exit(struct net *net);
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 extern u32 fib_rules_tclass(struct fib_result *res);
 #endif
 
@@ -235,7 +235,7 @@ extern struct fib_table *fib_hash_table(u32 id);
 
 static inline void fib_combine_itag(u32 *itag, struct fib_result *res)
 {
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	u32 rtag;
 #endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 9e95d7f..dcb2e18 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -140,6 +140,9 @@ config IP_ROUTE_VERBOSE
 	  handled by the klogd daemon which is responsible for kernel messages
 	  ("man klogd").
 
+config IP_ROUTE_CLASSID
+	bool
+
 config IP_PNP
 	bool "IP: kernel level autoconfiguration"
 	help
@@ -655,4 +658,3 @@ config TCP_MD5SIG
 	  on the Internet.
 
 	  If unsure, say N.
-
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 7981a24..9cefe72 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -41,12 +41,12 @@ struct fib4_rule {
 	__be32			srcmask;
 	__be32			dst;
 	__be32			dstmask;
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	u32			tclassid;
 #endif
 };
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 u32 fib_rules_tclass(struct fib_result *res)
 {
 	return res->r ? ((struct fib4_rule *) res->r)->tclassid : 0;
@@ -165,7 +165,7 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	if (frh->dst_len)
 		rule4->dst = nla_get_be32(tb[FRA_DST]);
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	if (tb[FRA_FLOW])
 		rule4->tclassid = nla_get_u32(tb[FRA_FLOW]);
 #endif
@@ -195,7 +195,7 @@ static int fib4_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
 	if (frh->tos && (rule4->tos != frh->tos))
 		return 0;
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	if (tb[FRA_FLOW] && (rule4->tclassid != nla_get_u32(tb[FRA_FLOW])))
 		return 0;
 #endif
@@ -224,7 +224,7 @@ static int fib4_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 	if (rule4->src_len)
 		NLA_PUT_BE32(skb, FRA_SRC, rule4->src);
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	if (rule4->tclassid)
 		NLA_PUT_U32(skb, FRA_FLOW, rule4->tclassid);
 #endif
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3e0da3e..a72c62d 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -200,7 +200,7 @@ static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 		    nh->nh_weight != onh->nh_weight ||
 #endif
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 		    nh->nh_tclassid != onh->nh_tclassid ||
 #endif
 		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_F_DEAD))
@@ -422,7 +422,7 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 
 			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
 			nexthop_nh->nh_gw = nla ? nla_get_be32(nla) : 0;
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 			nla = nla_find(attrs, attrlen, RTA_FLOW);
 			nexthop_nh->nh_tclassid = nla ? nla_get_u32(nla) : 0;
 #endif
@@ -476,7 +476,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
 			if (nla && nla_get_be32(nla) != nh->nh_gw)
 				return 1;
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 			nla = nla_find(attrs, attrlen, RTA_FLOW);
 			if (nla && nla_get_u32(nla) != nh->nh_tclassid)
 				return 1;
@@ -783,7 +783,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			goto err_inval;
 		if (cfg->fc_gw && fi->fib_nh->nh_gw != cfg->fc_gw)
 			goto err_inval;
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 		if (cfg->fc_flow && fi->fib_nh->nh_tclassid != cfg->fc_flow)
 			goto err_inval;
 #endif
@@ -796,7 +796,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		nh->nh_oif = cfg->fc_oif;
 		nh->nh_gw = cfg->fc_gw;
 		nh->nh_flags = cfg->fc_flags;
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 		nh->nh_tclassid = cfg->fc_flow;
 #endif
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
@@ -1006,7 +1006,7 @@ int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 
 		if (fi->fib_nh->nh_oif)
 			NLA_PUT_U32(skb, RTA_OIF, fi->fib_nh->nh_oif);
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 		if (fi->fib_nh[0].nh_tclassid)
 			NLA_PUT_U32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid);
 #endif
@@ -1031,7 +1031,7 @@ int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 
 			if (nh->nh_gw)
 				NLA_PUT_BE32(skb, RTA_GATEWAY, nh->nh_gw);
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 			if (nh->nh_tclassid)
 				NLA_PUT_U32(skb, RTA_FLOW, nh->nh_tclassid);
 #endif
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d859bcc..d7b2b09 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -340,7 +340,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 		}
 	}
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	if (unlikely(skb_dst(skb)->tclassid)) {
 		struct ip_rt_acct *st = this_cpu_ptr(ip_rt_acct);
 		u32 idx = skb_dst(skb)->tclassid;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 66610ea..f70ae1b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -511,7 +511,7 @@ static const struct file_operations rt_cpu_seq_fops = {
 	.release = seq_release,
 };
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 static int rt_acct_proc_show(struct seq_file *m, void *v)
 {
 	struct ip_rt_acct *dst, *src;
@@ -564,14 +564,14 @@ static int __net_init ip_rt_do_proc_init(struct net *net)
 	if (!pde)
 		goto err2;
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	pde = proc_create("rt_acct", 0, net->proc_net, &rt_acct_proc_fops);
 	if (!pde)
 		goto err3;
 #endif
 	return 0;
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 err3:
 	remove_proc_entry("rt_cache", net->proc_net_stat);
 #endif
@@ -585,7 +585,7 @@ static void __net_exit ip_rt_do_proc_exit(struct net *net)
 {
 	remove_proc_entry("rt_cache", net->proc_net_stat);
 	remove_proc_entry("rt_cache", net->proc_net);
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	remove_proc_entry("rt_acct", net->proc_net);
 #endif
 }
@@ -1784,7 +1784,7 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 	memcpy(addr, &src, 4);
 }
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 static void set_class_tag(struct rtable *rt, u32 tag)
 {
 	if (!(rt->dst.tclassid & 0xFFFF))
@@ -1811,7 +1811,7 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 			    rt->dst.dev->mtu > 576)
 				rt->dst.metrics[RTAX_MTU-1] = 576;
 		}
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
 	} else
@@ -1827,7 +1827,7 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 	if (dst_metric(&rt->dst, RTAX_ADVMSS) > 65535 - 40)
 		rt->dst.metrics[RTAX_ADVMSS-1] = 65535 - 40;
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	set_class_tag(rt, fib_rules_tclass(res));
 #endif
@@ -1883,7 +1883,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->fl.mark    = skb->mark;
 	rth->fl.fl4_src	= saddr;
 	rth->rt_src	= saddr;
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
 	rth->rt_iif	=
@@ -2202,7 +2202,7 @@ local_input:
 	rth->fl.mark    = skb->mark;
 	rth->fl.fl4_src	= saddr;
 	rth->rt_src	= saddr;
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
 	rth->rt_iif	=
@@ -2820,7 +2820,7 @@ static int rt_fill_info(struct net *net,
 	}
 	if (rt->dst.dev)
 		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	if (rt->dst.tclassid)
 		NLA_PUT_U32(skb, RTA_FLOW, rt->dst.tclassid);
 #endif
@@ -3245,9 +3245,9 @@ static __net_initdata struct pernet_operations rt_genid_ops = {
 };
 
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 struct ip_rt_acct __percpu *ip_rt_acct __read_mostly;
-#endif /* CONFIG_NET_CLS_ROUTE */
+#endif /* CONFIG_IP_ROUTE_CLASSID */
 
 static __initdata unsigned long rhash_entries;
 static int __init set_rhash_entries(char *str)
@@ -3263,7 +3263,7 @@ int __init ip_rt_init(void)
 {
 	int rc = 0;
 
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	ip_rt_acct = __alloc_percpu(256 * sizeof(struct ip_rt_acct), __alignof__(struct ip_rt_acct));
 	if (!ip_rt_acct)
 		panic("IP: failed to allocate ip_rt_acct\n");
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 1534f2b..1b79353 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -886,7 +886,7 @@ config NETFILTER_XT_MATCH_RATEEST
 config NETFILTER_XT_MATCH_REALM
 	tristate  '"realm" match support'
 	depends on NETFILTER_ADVANCED
-	select NET_CLS_ROUTE
+	select IP_ROUTE_CLASSID
 	help
 	  This option adds a `realm' match, which allows you to use the realm
 	  key from the routing subsystem inside iptables.
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index a36270a..4b753ef 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -243,7 +243,7 @@ config NET_CLS_TCINDEX
 
 config NET_CLS_ROUTE4
 	tristate "Routing decision (ROUTE)"
-	select NET_CLS_ROUTE
+	select IP_ROUTE_CLASSID
 	select NET_CLS
 	---help---
 	  If you say Y here, you will be able to classify packets
@@ -252,9 +252,6 @@ config NET_CLS_ROUTE4
 	  To compile this code as a module, choose M here: the
 	  module will be called cls_route.
 
-config NET_CLS_ROUTE
-	bool
-
 config NET_CLS_FW
 	tristate "Netfilter mark (FW)"
 	select NET_CLS
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 5b271a1..a3b293d 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -276,7 +276,7 @@ fallback:
 
 static u32 flow_get_rtclassid(const struct sk_buff *skb)
 {
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 	if (skb_dst(skb))
 		return skb_dst(skb)->tclassid;
 #endif
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 34da5e2..0d66e58 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -255,7 +255,7 @@ META_COLLECTOR(int_rtclassid)
 	if (unlikely(skb_dst(skb) == NULL))
 		*err = -1;
 	else
-#ifdef CONFIG_NET_CLS_ROUTE
+#ifdef CONFIG_IP_ROUTE_CLASSID
 		dst->value = skb_dst(skb)->tclassid;
 #else
 		dst->value = 0;
-- 
1.7.2.3

