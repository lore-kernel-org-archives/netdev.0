From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 04/22] ipv6: support for fib route lwtunnel encap attributes
Date: Fri, 10 Jul 2015 16:19:06 +0200
Message-ID: <aacdba17e7b068a5598f62d0816b95a2c2f9af77.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40479 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667AbbGJOTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:35 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support in ipv6 fib functions to parse Netlink
RTA encap attributes and attach encap state data to rt6_info.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/ip6_fib.h |  3 +++
 net/ipv6/ip6_fib.c    |  2 ++
 net/ipv6/route.c      | 33 ++++++++++++++++++++++++++++++---
 3 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 3b76849..276328e 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -51,6 +51,8 @@ struct fib6_config {
 	struct nlattr	*fc_mp;
 
 	struct nl_info	fc_nlinfo;
+	struct nlattr	*fc_encap;
+	u16		fc_encap_type;
 };
 
 struct fib6_node {
@@ -131,6 +133,7 @@ struct rt6_info {
 	/* more non-fragment space at head required */
 	unsigned short			rt6i_nfheader_len;
 	u8				rt6i_protocol;
+	struct lwtunnel_state		*rt6i_lwtstate;
 };
 
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 55d1986..d715f2e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -32,6 +32,7 @@
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 #include <net/addrconf.h>
+#include <net/lwtunnel.h>
 
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
@@ -177,6 +178,7 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 static void rt6_release(struct rt6_info *rt)
 {
 	if (atomic_dec_and_test(&rt->rt6i_ref)) {
+		lwtunnel_state_put(rt->rt6i_lwtstate);
 		rt6_free_pcpu(rt);
 		dst_free(&rt->dst);
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1a1122a..acfe25d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -58,6 +58,7 @@
 #include <net/netevent.h>
 #include <net/netlink.h>
 #include <net/nexthop.h>
+#include <net/lwtunnel.h>
 
 #include <asm/uaccess.h>
 
@@ -1773,6 +1774,17 @@ int ip6_route_add(struct fib6_config *cfg)
 
 	rt->dst.output = ip6_output;
 
+	if (cfg->fc_encap) {
+		struct lwtunnel_state *lwtstate;
+
+		err = lwtunnel_build_state(dev, cfg->fc_encap_type,
+					   cfg->fc_encap, &lwtstate);
+		if (err)
+			goto out;
+		lwtunnel_state_get(lwtstate);
+		rt->rt6i_lwtstate = lwtstate;
+	}
+
 	ipv6_addr_prefix(&rt->rt6i_dst.addr, &cfg->fc_dst, cfg->fc_dst_len);
 	rt->rt6i_dst.plen = cfg->fc_dst_len;
 	if (rt->rt6i_dst.plen == 128)
@@ -2598,6 +2610,8 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_METRICS]           = { .type = NLA_NESTED },
 	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
 	[RTA_PREF]              = { .type = NLA_U8 },
+	[RTA_ENCAP_TYPE]	= { .type = NLA_U16 },
+	[RTA_ENCAP]		= { .type = NLA_NESTED },
 };
 
 static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -2692,6 +2706,12 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 		cfg->fc_flags |= RTF_PREF(pref);
 	}
 
+	if (tb[RTA_ENCAP])
+		cfg->fc_encap = tb[RTA_ENCAP];
+
+	if (tb[RTA_ENCAP_TYPE])
+		cfg->fc_encap_type = nla_get_u16(tb[RTA_ENCAP_TYPE]);
+
 	err = 0;
 errout:
 	return err;
@@ -2724,6 +2744,10 @@ beginning:
 				r_cfg.fc_gateway = nla_get_in6_addr(nla);
 				r_cfg.fc_flags |= RTF_GATEWAY;
 			}
+			r_cfg.fc_encap = nla_find(attrs, attrlen, RTA_ENCAP);
+			nla = nla_find(attrs, attrlen, RTA_ENCAP_TYPE);
+			if (nla)
+				r_cfg.fc_encap_type = nla_get_u16(nla);
 		}
 		err = add ? ip6_route_add(&r_cfg) : ip6_route_del(&r_cfg);
 		if (err) {
@@ -2786,7 +2810,7 @@ static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return ip6_route_add(&cfg);
 }
 
-static inline size_t rt6_nlmsg_size(void)
+static inline size_t rt6_nlmsg_size(struct rt6_info *rt)
 {
 	return NLMSG_ALIGN(sizeof(struct rtmsg))
 	       + nla_total_size(16) /* RTA_SRC */
@@ -2800,7 +2824,8 @@ static inline size_t rt6_nlmsg_size(void)
 	       + RTAX_MAX * nla_total_size(4) /* RTA_METRICS */
 	       + nla_total_size(sizeof(struct rta_cacheinfo))
 	       + nla_total_size(TCP_CA_NAME_MAX) /* RTAX_CC_ALGO */
-	       + nla_total_size(1); /* RTA_PREF */
+	       + nla_total_size(1) /* RTA_PREF */
+	       + lwtunnel_get_encap_size(rt->rt6i_lwtstate);
 }
 
 static int rt6_fill_node(struct net *net,
@@ -2948,6 +2973,8 @@ static int rt6_fill_node(struct net *net,
 	if (nla_put_u8(skb, RTA_PREF, IPV6_EXTRACT_PREF(rt->rt6i_flags)))
 		goto nla_put_failure;
 
+	lwtunnel_fill_encap(skb, rt->rt6i_lwtstate);
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
@@ -3074,7 +3101,7 @@ void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info)
 	err = -ENOBUFS;
 	seq = info->nlh ? info->nlh->nlmsg_seq : 0;
 
-	skb = nlmsg_new(rt6_nlmsg_size(), gfp_any());
+	skb = nlmsg_new(rt6_nlmsg_size(rt), gfp_any());
 	if (!skb)
 		goto errout;
 
-- 
2.4.3
