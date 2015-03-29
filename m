From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 4/4] netlink: implement nla_get_in_addr and nla_get_in6_addr
Date: Sun, 29 Mar 2015 16:59:26 +0200
Message-ID: <6164b337fa032295cd8ec5aa444beb51f18a2bb7.1427639592.git.jbenc@redhat.com>
References: <cover.1427639592.git.jbenc@redhat.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Chapman <jchapman@katalix.com>,
	Paul Moore <paul@paul-moore.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59877 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617AbbC2PAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2015 11:00:31 -0400
In-Reply-To: <cover.1427639592.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those are counterparts to nla_put_in_addr and nla_put_in6_addr.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---

Note that nla_get_in6_addr returns the struct in6_addr rather than
a pointer to it. This may be frown upon by some; if desired, I'll rework
the function to accept target pointer as a parameter.
---
 drivers/net/vxlan.c                            | 16 +++++++---------
 include/net/netlink.h                          | 21 +++++++++++++++++++++
 net/ipv4/devinet.c                             | 10 +++++-----
 net/ipv4/fib_rules.c                           |  8 ++++----
 net/ipv4/fib_semantics.c                       |  4 ++--
 net/ipv4/ip_gre.c                              |  4 ++--
 net/ipv4/ip_vti.c                              |  4 ++--
 net/ipv4/ipip.c                                |  4 ++--
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  4 ++--
 net/ipv4/route.c                               |  4 ++--
 net/ipv4/tcp_metrics.c                         |  4 ++--
 net/ipv6/fib6_rules.c                          |  6 ++----
 net/ipv6/ip6_gre.c                             |  6 +++---
 net/ipv6/ip6_tunnel.c                          |  6 ++----
 net/ipv6/ip6_vti.c                             |  6 ++----
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  6 ++----
 net/ipv6/route.c                               |  6 +++---
 net/ipv6/sit.c                                 |  3 +--
 net/l2tp/l2tp_netlink.c                        |  4 ++--
 net/openvswitch/flow_netlink.c                 |  4 ++--
 net/wireless/nl80211.c                         |  4 ++--
 21 files changed, 72 insertions(+), 62 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 86f085f95408..a8d345054d23 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -171,11 +171,11 @@ static inline bool vxlan_addr_multicast(const union vxlan_addr *ipa)
 static int vxlan_nla_get_addr(union vxlan_addr *ip, struct nlattr *nla)
 {
 	if (nla_len(nla) >= sizeof(struct in6_addr)) {
-		nla_memcpy(&ip->sin6.sin6_addr, nla, sizeof(struct in6_addr));
+		ip->sin6.sin6_addr = nla_get_in6_addr(nla);
 		ip->sa.sa_family = AF_INET6;
 		return 0;
 	} else if (nla_len(nla) >= sizeof(__be32)) {
-		ip->sin.sin_addr.s_addr = nla_get_be32(nla);
+		ip->sin.sin_addr.s_addr = nla_get_in_addr(nla);
 		ip->sa.sa_family = AF_INET;
 		return 0;
 	} else {
@@ -215,7 +215,7 @@ static int vxlan_nla_get_addr(union vxlan_addr *ip, struct nlattr *nla)
 	if (nla_len(nla) >= sizeof(struct in6_addr)) {
 		return -EAFNOSUPPORT;
 	} else if (nla_len(nla) >= sizeof(__be32)) {
-		ip->sin.sin_addr.s_addr = nla_get_be32(nla);
+		ip->sin.sin_addr.s_addr = nla_get_in_addr(nla);
 		ip->sa.sa_family = AF_INET;
 		return 0;
 	} else {
@@ -2602,27 +2602,25 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	/* Unless IPv6 is explicitly requested, assume IPv4 */
 	dst->remote_ip.sa.sa_family = AF_INET;
 	if (data[IFLA_VXLAN_GROUP]) {
-		dst->remote_ip.sin.sin_addr.s_addr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
+		dst->remote_ip.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_GROUP]);
 	} else if (data[IFLA_VXLAN_GROUP6]) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
 
-		nla_memcpy(&dst->remote_ip.sin6.sin6_addr, data[IFLA_VXLAN_GROUP6],
-			   sizeof(struct in6_addr));
+		dst->remote_ip.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_GROUP6]);
 		dst->remote_ip.sa.sa_family = AF_INET6;
 		use_ipv6 = true;
 	}
 
 	if (data[IFLA_VXLAN_LOCAL]) {
-		vxlan->saddr.sin.sin_addr.s_addr = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
+		vxlan->saddr.sin.sin_addr.s_addr = nla_get_in_addr(data[IFLA_VXLAN_LOCAL]);
 		vxlan->saddr.sa.sa_family = AF_INET;
 	} else if (data[IFLA_VXLAN_LOCAL6]) {
 		if (!IS_ENABLED(CONFIG_IPV6))
 			return -EPFNOSUPPORT;
 
 		/* TODO: respect scope id */
-		nla_memcpy(&vxlan->saddr.sin6.sin6_addr, data[IFLA_VXLAN_LOCAL6],
-			   sizeof(struct in6_addr));
+		vxlan->saddr.sin6.sin6_addr = nla_get_in6_addr(data[IFLA_VXLAN_LOCAL6]);
 		vxlan->saddr.sa.sa_family = AF_INET6;
 		use_ipv6 = true;
 	}
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 17fc76e5b05e..2a5dbcc90d1c 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1128,6 +1128,27 @@ static inline unsigned long nla_get_msecs(const struct nlattr *nla)
 }
 
 /**
+ * nla_get_in_addr - return payload of IPv4 address attribute
+ * @nla: IPv4 address netlink attribute
+ */
+static inline __be32 nla_get_in_addr(const struct nlattr *nla)
+{
+	return *(__be32 *) nla_data(nla);
+}
+
+/**
+ * nla_get_in6_addr - return payload of IPv6 address attribute
+ * @nla: IPv6 address netlink attribute
+ */
+static inline struct in6_addr nla_get_in6_addr(const struct nlattr *nla)
+{
+	struct in6_addr tmp;
+
+	nla_memcpy(&tmp, nla, sizeof(tmp));
+	return tmp;
+}
+
+/**
  * nla_nest_start - Start a new level of nested attributes
  * @skb: socket buffer to add attributes to
  * @attrtype: attribute type of container
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 66cd85973056..c6473f365ad1 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -593,7 +593,7 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	for (ifap = &in_dev->ifa_list; (ifa = *ifap) != NULL;
 	     ifap = &ifa->ifa_next) {
 		if (tb[IFA_LOCAL] &&
-		    ifa->ifa_local != nla_get_be32(tb[IFA_LOCAL]))
+		    ifa->ifa_local != nla_get_in_addr(tb[IFA_LOCAL]))
 			continue;
 
 		if (tb[IFA_LABEL] && nla_strcmp(tb[IFA_LABEL], ifa->ifa_label))
@@ -601,7 +601,7 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 		if (tb[IFA_ADDRESS] &&
 		    (ifm->ifa_prefixlen != ifa->ifa_prefixlen ||
-		    !inet_ifa_match(nla_get_be32(tb[IFA_ADDRESS]), ifa)))
+		    !inet_ifa_match(nla_get_in_addr(tb[IFA_ADDRESS]), ifa)))
 			continue;
 
 		if (ipv4_is_multicast(ifa->ifa_address))
@@ -791,11 +791,11 @@ static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh,
 	ifa->ifa_scope = ifm->ifa_scope;
 	ifa->ifa_dev = in_dev;
 
-	ifa->ifa_local = nla_get_be32(tb[IFA_LOCAL]);
-	ifa->ifa_address = nla_get_be32(tb[IFA_ADDRESS]);
+	ifa->ifa_local = nla_get_in_addr(tb[IFA_LOCAL]);
+	ifa->ifa_address = nla_get_in_addr(tb[IFA_ADDRESS]);
 
 	if (tb[IFA_BROADCAST])
-		ifa->ifa_broadcast = nla_get_be32(tb[IFA_BROADCAST]);
+		ifa->ifa_broadcast = nla_get_in_addr(tb[IFA_BROADCAST]);
 
 	if (tb[IFA_LABEL])
 		nla_strlcpy(ifa->ifa_label, tb[IFA_LABEL], IFNAMSIZ);
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index edfea0deec43..8162dd8e86d7 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -194,10 +194,10 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	}
 
 	if (frh->src_len)
-		rule4->src = nla_get_be32(tb[FRA_SRC]);
+		rule4->src = nla_get_in_addr(tb[FRA_SRC]);
 
 	if (frh->dst_len)
-		rule4->dst = nla_get_be32(tb[FRA_DST]);
+		rule4->dst = nla_get_in_addr(tb[FRA_DST]);
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	if (tb[FRA_FLOW]) {
@@ -260,10 +260,10 @@ static int fib4_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
 		return 0;
 #endif
 
-	if (frh->src_len && (rule4->src != nla_get_be32(tb[FRA_SRC])))
+	if (frh->src_len && (rule4->src != nla_get_in_addr(tb[FRA_SRC])))
 		return 0;
 
-	if (frh->dst_len && (rule4->dst != nla_get_be32(tb[FRA_DST])))
+	if (frh->dst_len && (rule4->dst != nla_get_in_addr(tb[FRA_DST])))
 		return 0;
 
 	return 1;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 453b24e5322c..eac5aec7772a 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -468,7 +468,7 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
 
 			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
-			nexthop_nh->nh_gw = nla ? nla_get_be32(nla) : 0;
+			nexthop_nh->nh_gw = nla ? nla_get_in_addr(nla) : 0;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 			nla = nla_find(attrs, attrlen, RTA_FLOW);
 			nexthop_nh->nh_tclassid = nla ? nla_get_u32(nla) : 0;
@@ -523,7 +523,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
 
 			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
-			if (nla && nla_get_be32(nla) != nh->nh_gw)
+			if (nla && nla_get_in_addr(nla) != nh->nh_gw)
 				return 1;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 			nla = nla_find(attrs, attrlen, RTA_FLOW);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2e878df46075..0eb2a040a830 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -621,10 +621,10 @@ static void ipgre_netlink_parms(struct nlattr *data[], struct nlattr *tb[],
 		parms->o_key = nla_get_be32(data[IFLA_GRE_OKEY]);
 
 	if (data[IFLA_GRE_LOCAL])
-		parms->iph.saddr = nla_get_be32(data[IFLA_GRE_LOCAL]);
+		parms->iph.saddr = nla_get_in_addr(data[IFLA_GRE_LOCAL]);
 
 	if (data[IFLA_GRE_REMOTE])
-		parms->iph.daddr = nla_get_be32(data[IFLA_GRE_REMOTE]);
+		parms->iph.daddr = nla_get_in_addr(data[IFLA_GRE_REMOTE]);
 
 	if (data[IFLA_GRE_TTL])
 		parms->iph.ttl = nla_get_u8(data[IFLA_GRE_TTL]);
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index f189f2a8aaa5..5a6e27054f0a 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -456,10 +456,10 @@ static void vti_netlink_parms(struct nlattr *data[],
 		parms->o_key = nla_get_be32(data[IFLA_VTI_OKEY]);
 
 	if (data[IFLA_VTI_LOCAL])
-		parms->iph.saddr = nla_get_be32(data[IFLA_VTI_LOCAL]);
+		parms->iph.saddr = nla_get_in_addr(data[IFLA_VTI_LOCAL]);
 
 	if (data[IFLA_VTI_REMOTE])
-		parms->iph.daddr = nla_get_be32(data[IFLA_VTI_REMOTE]);
+		parms->iph.daddr = nla_get_in_addr(data[IFLA_VTI_REMOTE]);
 
 }
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 17df8d38bbbd..bfbcc85c02ee 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -325,10 +325,10 @@ static void ipip_netlink_parms(struct nlattr *data[],
 		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
 
 	if (data[IFLA_IPTUN_LOCAL])
-		parms->iph.saddr = nla_get_be32(data[IFLA_IPTUN_LOCAL]);
+		parms->iph.saddr = nla_get_in_addr(data[IFLA_IPTUN_LOCAL]);
 
 	if (data[IFLA_IPTUN_REMOTE])
-		parms->iph.daddr = nla_get_be32(data[IFLA_IPTUN_REMOTE]);
+		parms->iph.daddr = nla_get_in_addr(data[IFLA_IPTUN_REMOTE]);
 
 	if (data[IFLA_IPTUN_TTL]) {
 		parms->iph.ttl = nla_get_u8(data[IFLA_IPTUN_TTL]);
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index b36ebfc6b812..8c8d6642cbb0 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -342,8 +342,8 @@ static int ipv4_nlattr_to_tuple(struct nlattr *tb[],
 	if (!tb[CTA_IP_V4_SRC] || !tb[CTA_IP_V4_DST])
 		return -EINVAL;
 
-	t->src.u3.ip = nla_get_be32(tb[CTA_IP_V4_SRC]);
-	t->dst.u3.ip = nla_get_be32(tb[CTA_IP_V4_DST]);
+	t->src.u3.ip = nla_get_in_addr(tb[CTA_IP_V4_SRC]);
+	t->dst.u3.ip = nla_get_in_addr(tb[CTA_IP_V4_DST]);
 
 	return 0;
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1f147204f1f3..652b92ebd7ba 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2436,8 +2436,8 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	ip_hdr(skb)->protocol = IPPROTO_ICMP;
 	skb_reserve(skb, MAX_HEADER + sizeof(struct iphdr));
 
-	src = tb[RTA_SRC] ? nla_get_be32(tb[RTA_SRC]) : 0;
-	dst = tb[RTA_DST] ? nla_get_be32(tb[RTA_DST]) : 0;
+	src = tb[RTA_SRC] ? nla_get_in_addr(tb[RTA_SRC]) : 0;
+	dst = tb[RTA_DST] ? nla_get_in_addr(tb[RTA_DST]) : 0;
 	iif = tb[RTA_IIF] ? nla_get_u32(tb[RTA_IIF]) : 0;
 	mark = tb[RTA_MARK] ? nla_get_u32(tb[RTA_MARK]) : 0;
 
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 32e36ea6bc0f..71ec14c87579 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -948,7 +948,7 @@ static int __parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
 	a = info->attrs[v4];
 	if (a) {
 		addr->family = AF_INET;
-		addr->addr.a4 = nla_get_be32(a);
+		addr->addr.a4 = nla_get_in_addr(a);
 		if (hash)
 			*hash = (__force unsigned int) addr->addr.a4;
 		return 0;
@@ -958,7 +958,7 @@ static int __parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
 		if (nla_len(a) != sizeof(struct in6_addr))
 			return -EINVAL;
 		addr->family = AF_INET6;
-		memcpy(addr->addr.a6, nla_data(a), sizeof(addr->addr.a6));
+		addr->addr.in6 = nla_get_in6_addr(a);
 		if (hash)
 			*hash = ipv6_addr_hash(&addr->addr.in6);
 		return 0;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 9153e6bbcef8..c85513612940 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -199,12 +199,10 @@ static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	}
 
 	if (frh->src_len)
-		nla_memcpy(&rule6->src.addr, tb[FRA_SRC],
-			   sizeof(struct in6_addr));
+		rule6->src.addr = nla_get_in6_addr(tb[FRA_SRC]);
 
 	if (frh->dst_len)
-		nla_memcpy(&rule6->dst.addr, tb[FRA_DST],
-			   sizeof(struct in6_addr));
+		rule6->dst.addr = nla_get_in6_addr(tb[FRA_DST]);
 
 	rule6->src.plen = frh->src_len;
 	rule6->dst.plen = frh->dst_len;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 3d9097ee3f41..a765bc75b717 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1412,7 +1412,7 @@ static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 		goto out;
 
 	if (data[IFLA_GRE_REMOTE]) {
-		nla_memcpy(&daddr, data[IFLA_GRE_REMOTE], sizeof(struct in6_addr));
+		daddr = nla_get_in6_addr(data[IFLA_GRE_REMOTE]);
 		if (ipv6_addr_any(&daddr))
 			return -EINVAL;
 	}
@@ -1446,10 +1446,10 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
 		parms->o_key = nla_get_be32(data[IFLA_GRE_OKEY]);
 
 	if (data[IFLA_GRE_LOCAL])
-		nla_memcpy(&parms->laddr, data[IFLA_GRE_LOCAL], sizeof(struct in6_addr));
+		parms->laddr = nla_get_in6_addr(data[IFLA_GRE_LOCAL]);
 
 	if (data[IFLA_GRE_REMOTE])
-		nla_memcpy(&parms->raddr, data[IFLA_GRE_REMOTE], sizeof(struct in6_addr));
+		parms->raddr = nla_get_in6_addr(data[IFLA_GRE_REMOTE]);
 
 	if (data[IFLA_GRE_TTL])
 		parms->hop_limit = nla_get_u8(data[IFLA_GRE_TTL]);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index fc1a3121fd43..788cfe51c957 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1640,12 +1640,10 @@ static void ip6_tnl_netlink_parms(struct nlattr *data[],
 		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
 
 	if (data[IFLA_IPTUN_LOCAL])
-		nla_memcpy(&parms->laddr, data[IFLA_IPTUN_LOCAL],
-			   sizeof(struct in6_addr));
+		parms->laddr = nla_get_in6_addr(data[IFLA_IPTUN_LOCAL]);
 
 	if (data[IFLA_IPTUN_REMOTE])
-		nla_memcpy(&parms->raddr, data[IFLA_IPTUN_REMOTE],
-			   sizeof(struct in6_addr));
+		parms->raddr = nla_get_in6_addr(data[IFLA_IPTUN_REMOTE]);
 
 	if (data[IFLA_IPTUN_TTL])
 		parms->hop_limit = nla_get_u8(data[IFLA_IPTUN_TTL]);
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index f45dce8bfef2..7e0ca9a5b772 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -897,12 +897,10 @@ static void vti6_netlink_parms(struct nlattr *data[],
 		parms->link = nla_get_u32(data[IFLA_VTI_LINK]);
 
 	if (data[IFLA_VTI_LOCAL])
-		nla_memcpy(&parms->laddr, data[IFLA_VTI_LOCAL],
-			   sizeof(struct in6_addr));
+		parms->laddr = nla_get_in6_addr(data[IFLA_VTI_LOCAL]);
 
 	if (data[IFLA_VTI_REMOTE])
-		nla_memcpy(&parms->raddr, data[IFLA_VTI_REMOTE],
-			   sizeof(struct in6_addr));
+		parms->raddr = nla_get_in6_addr(data[IFLA_VTI_REMOTE]);
 
 	if (data[IFLA_VTI_IKEY])
 		parms->i_key = nla_get_be32(data[IFLA_VTI_IKEY]);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 78284a697439..fba91c6fc7ca 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -310,10 +310,8 @@ static int ipv6_nlattr_to_tuple(struct nlattr *tb[],
 	if (!tb[CTA_IP_V6_SRC] || !tb[CTA_IP_V6_DST])
 		return -EINVAL;
 
-	memcpy(&t->src.u3.ip6, nla_data(tb[CTA_IP_V6_SRC]),
-	       sizeof(u_int32_t) * 4);
-	memcpy(&t->dst.u3.ip6, nla_data(tb[CTA_IP_V6_DST]),
-	       sizeof(u_int32_t) * 4);
+	t->src.u3.in6 = nla_get_in6_addr(tb[CTA_IP_V6_SRC]);
+	t->dst.u3.in6 = nla_get_in6_addr(tb[CTA_IP_V6_DST]);
 
 	return 0;
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9693caf3b4fb..77acbc24d120 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2438,7 +2438,7 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	cfg->fc_nlinfo.nl_net = sock_net(skb->sk);
 
 	if (tb[RTA_GATEWAY]) {
-		nla_memcpy(&cfg->fc_gateway, tb[RTA_GATEWAY], 16);
+		cfg->fc_gateway = nla_get_in6_addr(tb[RTA_GATEWAY]);
 		cfg->fc_flags |= RTF_GATEWAY;
 	}
 
@@ -2461,7 +2461,7 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	}
 
 	if (tb[RTA_PREFSRC])
-		nla_memcpy(&cfg->fc_prefsrc, tb[RTA_PREFSRC], 16);
+		cfg->fc_prefsrc = nla_get_in6_addr(tb[RTA_PREFSRC]);
 
 	if (tb[RTA_OIF])
 		cfg->fc_ifindex = nla_get_u32(tb[RTA_OIF]);
@@ -2519,7 +2519,7 @@ beginning:
 
 			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
 			if (nla) {
-				nla_memcpy(&r_cfg.fc_gateway, nla, 16);
+				r_cfg.fc_gateway = nla_get_in6_addr(nla);
 				r_cfg.fc_flags |= RTF_GATEWAY;
 			}
 		}
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 9755c30498a6..ac9c908450da 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1530,8 +1530,7 @@ static bool ipip6_netlink_6rd_parms(struct nlattr *data[],
 
 	if (data[IFLA_IPTUN_6RD_PREFIX]) {
 		ret = true;
-		nla_memcpy(&ip6rd->prefix, data[IFLA_IPTUN_6RD_PREFIX],
-			   sizeof(struct in6_addr));
+		ip6rd->prefix = nla_get_in6_addr(data[IFLA_IPTUN_6RD_PREFIX]);
 	}
 
 	if (data[IFLA_IPTUN_6RD_RELAY_PREFIX]) {
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index a4f78d36bace..9e13c2ff8789 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -205,9 +205,9 @@ static int l2tp_nl_cmd_tunnel_create(struct sk_buff *skb, struct genl_info *info
 #endif
 		if (info->attrs[L2TP_ATTR_IP_SADDR] &&
 		    info->attrs[L2TP_ATTR_IP_DADDR]) {
-			cfg.local_ip.s_addr = nla_get_be32(
+			cfg.local_ip.s_addr = nla_get_in_addr(
 				info->attrs[L2TP_ATTR_IP_SADDR]);
-			cfg.peer_ip.s_addr = nla_get_be32(
+			cfg.peer_ip.s_addr = nla_get_in_addr(
 				info->attrs[L2TP_ATTR_IP_DADDR]);
 		} else {
 			ret = -EINVAL;
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c0c5b5519f45..c691b1a1eee0 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -535,11 +535,11 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			break;
 		case OVS_TUNNEL_KEY_ATTR_IPV4_SRC:
 			SW_FLOW_KEY_PUT(match, tun_key.ipv4_src,
-					nla_get_be32(a), is_mask);
+					nla_get_in_addr(a), is_mask);
 			break;
 		case OVS_TUNNEL_KEY_ATTR_IPV4_DST:
 			SW_FLOW_KEY_PUT(match, tun_key.ipv4_dst,
-					nla_get_be32(a), is_mask);
+					nla_get_in_addr(a), is_mask);
 			break;
 		case OVS_TUNNEL_KEY_ATTR_TOS:
 			SW_FLOW_KEY_PUT(match, tun_key.ipv4_tos,
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 6a4a4d7db1fc..2fb804bfa361 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -8993,8 +8993,8 @@ static int nl80211_parse_wowlan_tcp(struct cfg80211_registered_device *rdev,
 	cfg = kzalloc(size, GFP_KERNEL);
 	if (!cfg)
 		return -ENOMEM;
-	cfg->src = nla_get_be32(tb[NL80211_WOWLAN_TCP_SRC_IPV4]);
-	cfg->dst = nla_get_be32(tb[NL80211_WOWLAN_TCP_DST_IPV4]);
+	cfg->src = nla_get_in_addr(tb[NL80211_WOWLAN_TCP_SRC_IPV4]);
+	cfg->dst = nla_get_in_addr(tb[NL80211_WOWLAN_TCP_DST_IPV4]);
 	memcpy(cfg->dst_mac, nla_data(tb[NL80211_WOWLAN_TCP_DST_MAC]),
 	       ETH_ALEN);
 	if (tb[NL80211_WOWLAN_TCP_SRC_PORT])
-- 
1.8.3.1
