From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 3/4] netlink: implement nla_put_in_addr and nla_put_in6_addr
Date: Sun, 29 Mar 2015 16:59:25 +0200
Message-ID: <c9e66821f590a443229b9049950b633c949f2864.1427639592.git.jbenc@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:59873 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752617AbbC2PA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2015 11:00:28 -0400
In-Reply-To: <cover.1427639592.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IP addresses are often stored in netlink attributes. Add generic functions
to do that.

For nla_put_in_addr, it would be nicer to pass struct in_addr but this is
not used universally throughout the kernel, in way too many places __be32 is
used to store IPv4 address.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c                            | 22 +++++++++----------
 include/linux/netfilter/ipset/ip_set.h         |  5 ++---
 include/net/netlink.h                          | 29 ++++++++++++++++++++++++++
 net/ipv4/devinet.c                             |  6 +++---
 net/ipv4/fib_rules.c                           |  4 ++--
 net/ipv4/fib_semantics.c                       |  8 +++----
 net/ipv4/ip_gre.c                              |  4 ++--
 net/ipv4/ip_vti.c                              |  4 ++--
 net/ipv4/ipip.c                                |  4 ++--
 net/ipv4/ipmr.c                                |  4 ++--
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  4 ++--
 net/ipv4/route.c                               |  8 +++----
 net/ipv4/tcp_metrics.c                         | 16 +++++++-------
 net/ipv6/addrconf.c                            | 10 ++++-----
 net/ipv6/addrlabel.c                           |  2 +-
 net/ipv6/fib6_rules.c                          |  6 ++----
 net/ipv6/ip6_gre.c                             |  4 ++--
 net/ipv6/ip6_tunnel.c                          |  6 ++----
 net/ipv6/ip6_vti.c                             |  6 ++----
 net/ipv6/ip6mr.c                               |  4 ++--
 net/ipv6/ndisc.c                               |  3 +--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  6 ++----
 net/ipv6/route.c                               | 14 ++++++-------
 net/ipv6/sit.c                                 | 12 +++++------
 net/l2tp/l2tp_netlink.c                        | 14 +++++++------
 net/netlabel/netlabel_mgmt.c                   | 20 +++++++-----------
 net/netlabel/netlabel_unlabeled.c              | 28 +++++++++++--------------
 net/openvswitch/flow_netlink.c                 |  6 ++++--
 net/wireless/nl80211.c                         |  4 ++--
 29 files changed, 139 insertions(+), 124 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1c80b67c688d..86f085f95408 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -187,9 +187,9 @@ static int vxlan_nla_put_addr(struct sk_buff *skb, int attr,
 			      const union vxlan_addr *ip)
 {
 	if (ip->sa.sa_family == AF_INET6)
-		return nla_put(skb, attr, sizeof(struct in6_addr), &ip->sin6.sin6_addr);
+		return nla_put_in6_addr(skb, attr, &ip->sin6.sin6_addr);
 	else
-		return nla_put_be32(skb, attr, ip->sin.sin_addr.s_addr);
+		return nla_put_in_addr(skb, attr, ip->sin.sin_addr.s_addr);
 }
 
 #else /* !CONFIG_IPV6 */
@@ -226,7 +226,7 @@ static int vxlan_nla_get_addr(union vxlan_addr *ip, struct nlattr *nla)
 static int vxlan_nla_put_addr(struct sk_buff *skb, int attr,
 			      const union vxlan_addr *ip)
 {
-	return nla_put_be32(skb, attr, ip->sin.sin_addr.s_addr);
+	return nla_put_in_addr(skb, attr, ip->sin.sin_addr.s_addr);
 }
 #endif
 
@@ -2807,13 +2807,13 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 
 	if (!vxlan_addr_any(&dst->remote_ip)) {
 		if (dst->remote_ip.sa.sa_family == AF_INET) {
-			if (nla_put_be32(skb, IFLA_VXLAN_GROUP,
-					 dst->remote_ip.sin.sin_addr.s_addr))
+			if (nla_put_in_addr(skb, IFLA_VXLAN_GROUP,
+					    dst->remote_ip.sin.sin_addr.s_addr))
 				goto nla_put_failure;
 #if IS_ENABLED(CONFIG_IPV6)
 		} else {
-			if (nla_put(skb, IFLA_VXLAN_GROUP6, sizeof(struct in6_addr),
-				    &dst->remote_ip.sin6.sin6_addr))
+			if (nla_put_in6_addr(skb, IFLA_VXLAN_GROUP6,
+					     &dst->remote_ip.sin6.sin6_addr))
 				goto nla_put_failure;
 #endif
 		}
@@ -2824,13 +2824,13 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 
 	if (!vxlan_addr_any(&vxlan->saddr)) {
 		if (vxlan->saddr.sa.sa_family == AF_INET) {
-			if (nla_put_be32(skb, IFLA_VXLAN_LOCAL,
-					 vxlan->saddr.sin.sin_addr.s_addr))
+			if (nla_put_in_addr(skb, IFLA_VXLAN_LOCAL,
+					    vxlan->saddr.sin.sin_addr.s_addr))
 				goto nla_put_failure;
 #if IS_ENABLED(CONFIG_IPV6)
 		} else {
-			if (nla_put(skb, IFLA_VXLAN_LOCAL6, sizeof(struct in6_addr),
-				    &vxlan->saddr.sin6.sin6_addr))
+			if (nla_put_in6_addr(skb, IFLA_VXLAN_LOCAL6,
+					     &vxlan->saddr.sin6.sin6_addr))
 				goto nla_put_failure;
 #endif
 		}
diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index f1606fa6132d..34b172301558 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -483,7 +483,7 @@ static inline int nla_put_ipaddr4(struct sk_buff *skb, int type, __be32 ipaddr)
 
 	if (!__nested)
 		return -EMSGSIZE;
-	ret = nla_put_net32(skb, IPSET_ATTR_IPADDR_IPV4, ipaddr);
+	ret = nla_put_in_addr(skb, IPSET_ATTR_IPADDR_IPV4, ipaddr);
 	if (!ret)
 		ipset_nest_end(skb, __nested);
 	return ret;
@@ -497,8 +497,7 @@ static inline int nla_put_ipaddr6(struct sk_buff *skb, int type,
 
 	if (!__nested)
 		return -EMSGSIZE;
-	ret = nla_put(skb, IPSET_ATTR_IPADDR_IPV6,
-		      sizeof(struct in6_addr), ipaddrptr);
+	ret = nla_put_in6_addr(skb, IPSET_ATTR_IPADDR_IPV6, ipaddrptr);
 	if (!ret)
 		ipset_nest_end(skb, __nested);
 	return ret;
diff --git a/include/net/netlink.h b/include/net/netlink.h
index e010ee8da41d..17fc76e5b05e 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -4,6 +4,7 @@
 #include <linux/types.h>
 #include <linux/netlink.h>
 #include <linux/jiffies.h>
+#include <linux/in6.h>
 
 /* ========================================================================
  *         Netlink Messages and Attributes Interface (As Seen On TV)
@@ -105,6 +106,8 @@
  *   nla_put_string(skb, type, str)	add string attribute to skb
  *   nla_put_flag(skb, type)		add flag attribute to skb
  *   nla_put_msecs(skb, type, jiffies)	add msecs attribute to skb
+ *   nla_put_in_addr(skb, type, addr)	add IPv4 address attribute to skb
+ *   nla_put_in6_addr(skb, type, addr)	add IPv6 address attribute to skb
  *
  * Nested Attributes Construction:
  *   nla_nest_start(skb, type)		start a nested attribute
@@ -957,6 +960,32 @@ static inline int nla_put_msecs(struct sk_buff *skb, int attrtype,
 }
 
 /**
+ * nla_put_in_addr - Add an IPv4 address netlink attribute to a socket
+ * buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @addr: IPv4 address
+ */
+static inline int nla_put_in_addr(struct sk_buff *skb, int attrtype,
+				  __be32 addr)
+{
+	return nla_put_be32(skb, attrtype, addr);
+}
+
+/**
+ * nla_put_in6_addr - Add an IPv6 address netlink attribute to a socket
+ * buffer
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @addr: IPv6 address
+ */
+static inline int nla_put_in6_addr(struct sk_buff *skb, int attrtype,
+				   const struct in6_addr *addr)
+{
+	return nla_put(skb, attrtype, sizeof(*addr), addr);
+}
+
+/**
  * nla_get_u32 - return payload of u32 attribute
  * @nla: u32 netlink attribute
  */
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 975ee5e30c64..66cd85973056 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1541,11 +1541,11 @@ static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
 		valid = INFINITY_LIFE_TIME;
 	}
 	if ((ifa->ifa_address &&
-	     nla_put_be32(skb, IFA_ADDRESS, ifa->ifa_address)) ||
+	     nla_put_in_addr(skb, IFA_ADDRESS, ifa->ifa_address)) ||
 	    (ifa->ifa_local &&
-	     nla_put_be32(skb, IFA_LOCAL, ifa->ifa_local)) ||
+	     nla_put_in_addr(skb, IFA_LOCAL, ifa->ifa_local)) ||
 	    (ifa->ifa_broadcast &&
-	     nla_put_be32(skb, IFA_BROADCAST, ifa->ifa_broadcast)) ||
+	     nla_put_in_addr(skb, IFA_BROADCAST, ifa->ifa_broadcast)) ||
 	    (ifa->ifa_label[0] &&
 	     nla_put_string(skb, IFA_LABEL, ifa->ifa_label)) ||
 	    nla_put_u32(skb, IFA_FLAGS, ifa->ifa_flags) ||
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index e9bc5e42cf43..edfea0deec43 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -279,9 +279,9 @@ static int fib4_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 	frh->tos = rule4->tos;
 
 	if ((rule4->dst_len &&
-	     nla_put_be32(skb, FRA_DST, rule4->dst)) ||
+	     nla_put_in_addr(skb, FRA_DST, rule4->dst)) ||
 	    (rule4->src_len &&
-	     nla_put_be32(skb, FRA_SRC, rule4->src)))
+	     nla_put_in_addr(skb, FRA_SRC, rule4->src)))
 		goto nla_put_failure;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	if (rule4->tclassid &&
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 66c1e4fbf884..453b24e5322c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1015,7 +1015,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	rtm->rtm_protocol = fi->fib_protocol;
 
 	if (rtm->rtm_dst_len &&
-	    nla_put_be32(skb, RTA_DST, dst))
+	    nla_put_in_addr(skb, RTA_DST, dst))
 		goto nla_put_failure;
 	if (fi->fib_priority &&
 	    nla_put_u32(skb, RTA_PRIORITY, fi->fib_priority))
@@ -1024,11 +1024,11 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		goto nla_put_failure;
 
 	if (fi->fib_prefsrc &&
-	    nla_put_be32(skb, RTA_PREFSRC, fi->fib_prefsrc))
+	    nla_put_in_addr(skb, RTA_PREFSRC, fi->fib_prefsrc))
 		goto nla_put_failure;
 	if (fi->fib_nhs == 1) {
 		if (fi->fib_nh->nh_gw &&
-		    nla_put_be32(skb, RTA_GATEWAY, fi->fib_nh->nh_gw))
+		    nla_put_in_addr(skb, RTA_GATEWAY, fi->fib_nh->nh_gw))
 			goto nla_put_failure;
 		if (fi->fib_nh->nh_oif &&
 		    nla_put_u32(skb, RTA_OIF, fi->fib_nh->nh_oif))
@@ -1058,7 +1058,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			rtnh->rtnh_ifindex = nh->nh_oif;
 
 			if (nh->nh_gw &&
-			    nla_put_be32(skb, RTA_GATEWAY, nh->nh_gw))
+			    nla_put_in_addr(skb, RTA_GATEWAY, nh->nh_gw))
 				goto nla_put_failure;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 			if (nh->nh_tclassid &&
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 6207275fc749..2e878df46075 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -776,8 +776,8 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_be16(skb, IFLA_GRE_OFLAGS, tnl_flags_to_gre_flags(p->o_flags)) ||
 	    nla_put_be32(skb, IFLA_GRE_IKEY, p->i_key) ||
 	    nla_put_be32(skb, IFLA_GRE_OKEY, p->o_key) ||
-	    nla_put_be32(skb, IFLA_GRE_LOCAL, p->iph.saddr) ||
-	    nla_put_be32(skb, IFLA_GRE_REMOTE, p->iph.daddr) ||
+	    nla_put_in_addr(skb, IFLA_GRE_LOCAL, p->iph.saddr) ||
+	    nla_put_in_addr(skb, IFLA_GRE_REMOTE, p->iph.daddr) ||
 	    nla_put_u8(skb, IFLA_GRE_TTL, p->iph.ttl) ||
 	    nla_put_u8(skb, IFLA_GRE_TOS, p->iph.tos) ||
 	    nla_put_u8(skb, IFLA_GRE_PMTUDISC,
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 94efe148181c..f189f2a8aaa5 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -505,8 +505,8 @@ static int vti_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	nla_put_u32(skb, IFLA_VTI_LINK, p->link);
 	nla_put_be32(skb, IFLA_VTI_IKEY, p->i_key);
 	nla_put_be32(skb, IFLA_VTI_OKEY, p->o_key);
-	nla_put_be32(skb, IFLA_VTI_LOCAL, p->iph.saddr);
-	nla_put_be32(skb, IFLA_VTI_REMOTE, p->iph.daddr);
+	nla_put_in_addr(skb, IFLA_VTI_LOCAL, p->iph.saddr);
+	nla_put_in_addr(skb, IFLA_VTI_REMOTE, p->iph.daddr);
 
 	return 0;
 }
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 915d215a7d14..17df8d38bbbd 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -450,8 +450,8 @@ static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct ip_tunnel_parm *parm = &tunnel->parms;
 
 	if (nla_put_u32(skb, IFLA_IPTUN_LINK, parm->link) ||
-	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
-	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
+	    nla_put_in_addr(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
+	    nla_put_in_addr(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->iph.ttl) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c688cd1b2110..b4a545d24adb 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2281,8 +2281,8 @@ static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 		rtm->rtm_protocol = RTPROT_MROUTED;
 	rtm->rtm_flags    = 0;
 
-	if (nla_put_be32(skb, RTA_SRC, c->mfc_origin) ||
-	    nla_put_be32(skb, RTA_DST, c->mfc_mcastgrp))
+	if (nla_put_in_addr(skb, RTA_SRC, c->mfc_origin) ||
+	    nla_put_in_addr(skb, RTA_DST, c->mfc_mcastgrp))
 		goto nla_put_failure;
 	err = __ipmr_fill_mroute(mrt, skb, c, rtm);
 	/* do not break the dump if cache is unresolved */
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 5c61328b7704..b36ebfc6b812 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -322,8 +322,8 @@ getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 static int ipv4_tuple_to_nlattr(struct sk_buff *skb,
 				const struct nf_conntrack_tuple *tuple)
 {
-	if (nla_put_be32(skb, CTA_IP_V4_SRC, tuple->src.u3.ip) ||
-	    nla_put_be32(skb, CTA_IP_V4_DST, tuple->dst.u3.ip))
+	if (nla_put_in_addr(skb, CTA_IP_V4_SRC, tuple->src.u3.ip) ||
+	    nla_put_in_addr(skb, CTA_IP_V4_DST, tuple->dst.u3.ip))
 		goto nla_put_failure;
 	return 0;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index be8703d02ef0..1f147204f1f3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2319,11 +2319,11 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	if (IPCB(skb)->flags & IPSKB_DOREDIRECT)
 		r->rtm_flags |= RTCF_DOREDIRECT;
 
-	if (nla_put_be32(skb, RTA_DST, dst))
+	if (nla_put_in_addr(skb, RTA_DST, dst))
 		goto nla_put_failure;
 	if (src) {
 		r->rtm_src_len = 32;
-		if (nla_put_be32(skb, RTA_SRC, src))
+		if (nla_put_in_addr(skb, RTA_SRC, src))
 			goto nla_put_failure;
 	}
 	if (rt->dst.dev &&
@@ -2336,11 +2336,11 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 #endif
 	if (!rt_is_input_route(rt) &&
 	    fl4->saddr != src) {
-		if (nla_put_be32(skb, RTA_PREFSRC, fl4->saddr))
+		if (nla_put_in_addr(skb, RTA_PREFSRC, fl4->saddr))
 			goto nla_put_failure;
 	}
 	if (rt->rt_uses_gateway &&
-	    nla_put_be32(skb, RTA_GATEWAY, rt->rt_gateway))
+	    nla_put_in_addr(skb, RTA_GATEWAY, rt->rt_gateway))
 		goto nla_put_failure;
 
 	expires = rt->dst.expires;
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index f62c2c68ced0..32e36ea6bc0f 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -786,19 +786,19 @@ static int tcp_metrics_fill_info(struct sk_buff *msg,
 
 	switch (tm->tcpm_daddr.family) {
 	case AF_INET:
-		if (nla_put_be32(msg, TCP_METRICS_ATTR_ADDR_IPV4,
-				tm->tcpm_daddr.addr.a4) < 0)
+		if (nla_put_in_addr(msg, TCP_METRICS_ATTR_ADDR_IPV4,
+				    tm->tcpm_daddr.addr.a4) < 0)
 			goto nla_put_failure;
-		if (nla_put_be32(msg, TCP_METRICS_ATTR_SADDR_IPV4,
-				tm->tcpm_saddr.addr.a4) < 0)
+		if (nla_put_in_addr(msg, TCP_METRICS_ATTR_SADDR_IPV4,
+				    tm->tcpm_saddr.addr.a4) < 0)
 			goto nla_put_failure;
 		break;
 	case AF_INET6:
-		if (nla_put(msg, TCP_METRICS_ATTR_ADDR_IPV6, 16,
-			    tm->tcpm_daddr.addr.a6) < 0)
+		if (nla_put_in6_addr(msg, TCP_METRICS_ATTR_ADDR_IPV6,
+				     &tm->tcpm_daddr.addr.in6) < 0)
 			goto nla_put_failure;
-		if (nla_put(msg, TCP_METRICS_ATTR_SADDR_IPV6, 16,
-			    tm->tcpm_saddr.addr.a6) < 0)
+		if (nla_put_in6_addr(msg, TCP_METRICS_ATTR_SADDR_IPV6,
+				     &tm->tcpm_saddr.addr.in6) < 0)
 			goto nla_put_failure;
 		break;
 	default:
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2660263e1131..40a9c11de07c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4237,11 +4237,11 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 	}
 
 	if (!ipv6_addr_any(&ifa->peer_addr)) {
-		if (nla_put(skb, IFA_LOCAL, 16, &ifa->addr) < 0 ||
-		    nla_put(skb, IFA_ADDRESS, 16, &ifa->peer_addr) < 0)
+		if (nla_put_in6_addr(skb, IFA_LOCAL, &ifa->addr) < 0 ||
+		    nla_put_in6_addr(skb, IFA_ADDRESS, &ifa->peer_addr) < 0)
 			goto error;
 	} else
-		if (nla_put(skb, IFA_ADDRESS, 16, &ifa->addr) < 0)
+		if (nla_put_in6_addr(skb, IFA_ADDRESS, &ifa->addr) < 0)
 			goto error;
 
 	if (put_cacheinfo(skb, ifa->cstamp, ifa->tstamp, preferred, valid) < 0)
@@ -4273,7 +4273,7 @@ static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
 		return -EMSGSIZE;
 
 	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
-	if (nla_put(skb, IFA_MULTICAST, 16, &ifmca->mca_addr) < 0 ||
+	if (nla_put_in6_addr(skb, IFA_MULTICAST, &ifmca->mca_addr) < 0 ||
 	    put_cacheinfo(skb, ifmca->mca_cstamp, ifmca->mca_tstamp,
 			  INFINITY_LIFE_TIME, INFINITY_LIFE_TIME) < 0) {
 		nlmsg_cancel(skb, nlh);
@@ -4299,7 +4299,7 @@ static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
 		return -EMSGSIZE;
 
 	put_ifaddrmsg(nlh, 128, IFA_F_PERMANENT, scope, ifindex);
-	if (nla_put(skb, IFA_ANYCAST, 16, &ifaca->aca_addr) < 0 ||
+	if (nla_put_in6_addr(skb, IFA_ANYCAST, &ifaca->aca_addr) < 0 ||
 	    put_cacheinfo(skb, ifaca->aca_cstamp, ifaca->aca_tstamp,
 			  INFINITY_LIFE_TIME, INFINITY_LIFE_TIME) < 0) {
 		nlmsg_cancel(skb, nlh);
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 3cc50e2d3bf5..882124ebb438 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -477,7 +477,7 @@ static int ip6addrlbl_fill(struct sk_buff *skb,
 
 	ip6addrlbl_putmsg(nlh, p->prefixlen, p->ifindex, lseq);
 
-	if (nla_put(skb, IFAL_ADDRESS, 16, &p->prefix) < 0 ||
+	if (nla_put_in6_addr(skb, IFAL_ADDRESS, &p->prefix) < 0 ||
 	    nla_put_u32(skb, IFAL_LABEL, p->label) < 0) {
 		nlmsg_cancel(skb, nlh);
 		return -EMSGSIZE;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 27ca79682efb..9153e6bbcef8 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -250,11 +250,9 @@ static int fib6_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 	frh->tos = rule6->tclass;
 
 	if ((rule6->dst.plen &&
-	     nla_put(skb, FRA_DST, sizeof(struct in6_addr),
-		     &rule6->dst.addr)) ||
+	     nla_put_in6_addr(skb, FRA_DST, &rule6->dst.addr)) ||
 	    (rule6->src.plen &&
-	     nla_put(skb, FRA_SRC, sizeof(struct in6_addr),
-		     &rule6->src.addr)))
+	     nla_put_in6_addr(skb, FRA_SRC, &rule6->src.addr)))
 		goto nla_put_failure;
 	return 0;
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index bc28b7d42a6d..3d9097ee3f41 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1622,8 +1622,8 @@ static int ip6gre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_be16(skb, IFLA_GRE_OFLAGS, p->o_flags) ||
 	    nla_put_be32(skb, IFLA_GRE_IKEY, p->i_key) ||
 	    nla_put_be32(skb, IFLA_GRE_OKEY, p->o_key) ||
-	    nla_put(skb, IFLA_GRE_LOCAL, sizeof(struct in6_addr), &p->laddr) ||
-	    nla_put(skb, IFLA_GRE_REMOTE, sizeof(struct in6_addr), &p->raddr) ||
+	    nla_put_in6_addr(skb, IFLA_GRE_LOCAL, &p->laddr) ||
+	    nla_put_in6_addr(skb, IFLA_GRE_REMOTE, &p->raddr) ||
 	    nla_put_u8(skb, IFLA_GRE_TTL, p->hop_limit) ||
 	    /*nla_put_u8(skb, IFLA_GRE_TOS, t->priority) ||*/
 	    nla_put_u8(skb, IFLA_GRE_ENCAP_LIMIT, p->encap_limit) ||
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 41f84f76ad9d..fc1a3121fd43 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1739,10 +1739,8 @@ static int ip6_tnl_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct __ip6_tnl_parm *parm = &tunnel->parms;
 
 	if (nla_put_u32(skb, IFLA_IPTUN_LINK, parm->link) ||
-	    nla_put(skb, IFLA_IPTUN_LOCAL, sizeof(struct in6_addr),
-		    &parm->laddr) ||
-	    nla_put(skb, IFLA_IPTUN_REMOTE, sizeof(struct in6_addr),
-		    &parm->raddr) ||
+	    nla_put_in6_addr(skb, IFLA_IPTUN_LOCAL, &parm->laddr) ||
+	    nla_put_in6_addr(skb, IFLA_IPTUN_REMOTE, &parm->raddr) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->hop_limit) ||
 	    nla_put_u8(skb, IFLA_IPTUN_ENCAP_LIMIT, parm->encap_limit) ||
 	    nla_put_be32(skb, IFLA_IPTUN_FLOWINFO, parm->flowinfo) ||
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 5fb9e212eca8..f45dce8bfef2 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -983,10 +983,8 @@ static int vti6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct __ip6_tnl_parm *parm = &tunnel->parms;
 
 	if (nla_put_u32(skb, IFLA_VTI_LINK, parm->link) ||
-	    nla_put(skb, IFLA_VTI_LOCAL, sizeof(struct in6_addr),
-		    &parm->laddr) ||
-	    nla_put(skb, IFLA_VTI_REMOTE, sizeof(struct in6_addr),
-		    &parm->raddr) ||
+	    nla_put_in6_addr(skb, IFLA_VTI_LOCAL, &parm->laddr) ||
+	    nla_put_in6_addr(skb, IFLA_VTI_REMOTE, &parm->raddr) ||
 	    nla_put_be32(skb, IFLA_VTI_IKEY, parm->i_key) ||
 	    nla_put_be32(skb, IFLA_VTI_OKEY, parm->o_key))
 		goto nla_put_failure;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 4b9315aa273e..d0b7b3f31e61 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2378,8 +2378,8 @@ static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 		rtm->rtm_protocol = RTPROT_MROUTED;
 	rtm->rtm_flags    = 0;
 
-	if (nla_put(skb, RTA_SRC, 16, &c->mf6c_origin) ||
-	    nla_put(skb, RTA_DST, 16, &c->mf6c_mcastgrp))
+	if (nla_put_in6_addr(skb, RTA_SRC, &c->mf6c_origin) ||
+	    nla_put_in6_addr(skb, RTA_DST, &c->mf6c_mcastgrp))
 		goto nla_put_failure;
 	err = __ip6mr_fill_mroute(mrt, skb, c, rtm);
 	/* do not break the dump if cache is unresolved */
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 247ad7c298f7..c9699b0e25e3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1049,8 +1049,7 @@ static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *opt)
 
 	memcpy(ndmsg + 1, opt, opt->nd_opt_len << 3);
 
-	if (nla_put(skb, NDUSEROPT_SRCADDR, sizeof(struct in6_addr),
-		    &ipv6_hdr(ra)->saddr))
+	if (nla_put_in6_addr(skb, NDUSEROPT_SRCADDR, &ipv6_hdr(ra)->saddr))
 		goto nla_put_failure;
 	nlmsg_end(skb, nlh);
 
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index b68d0e59c1f8..78284a697439 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -290,10 +290,8 @@ ipv6_getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 static int ipv6_tuple_to_nlattr(struct sk_buff *skb,
 				const struct nf_conntrack_tuple *tuple)
 {
-	if (nla_put(skb, CTA_IP_V6_SRC, sizeof(u_int32_t) * 4,
-		    &tuple->src.u3.ip6) ||
-	    nla_put(skb, CTA_IP_V6_DST, sizeof(u_int32_t) * 4,
-		    &tuple->dst.u3.ip6))
+	if (nla_put_in6_addr(skb, CTA_IP_V6_SRC, &tuple->src.u3.in6) ||
+	    nla_put_in6_addr(skb, CTA_IP_V6_DST, &tuple->dst.u3.in6))
 		goto nla_put_failure;
 	return 0;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 58c0e6a4d15d..9693caf3b4fb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2669,19 +2669,19 @@ static int rt6_fill_node(struct net *net,
 		rtm->rtm_flags |= RTM_F_CLONED;
 
 	if (dst) {
-		if (nla_put(skb, RTA_DST, 16, dst))
+		if (nla_put_in6_addr(skb, RTA_DST, dst))
 			goto nla_put_failure;
 		rtm->rtm_dst_len = 128;
 	} else if (rtm->rtm_dst_len)
-		if (nla_put(skb, RTA_DST, 16, &rt->rt6i_dst.addr))
+		if (nla_put_in6_addr(skb, RTA_DST, &rt->rt6i_dst.addr))
 			goto nla_put_failure;
 #ifdef CONFIG_IPV6_SUBTREES
 	if (src) {
-		if (nla_put(skb, RTA_SRC, 16, src))
+		if (nla_put_in6_addr(skb, RTA_SRC, src))
 			goto nla_put_failure;
 		rtm->rtm_src_len = 128;
 	} else if (rtm->rtm_src_len &&
-		   nla_put(skb, RTA_SRC, 16, &rt->rt6i_src.addr))
+		   nla_put_in6_addr(skb, RTA_SRC, &rt->rt6i_src.addr))
 		goto nla_put_failure;
 #endif
 	if (iif) {
@@ -2705,14 +2705,14 @@ static int rt6_fill_node(struct net *net,
 	} else if (dst) {
 		struct in6_addr saddr_buf;
 		if (ip6_route_get_saddr(net, rt, dst, 0, &saddr_buf) == 0 &&
-		    nla_put(skb, RTA_PREFSRC, 16, &saddr_buf))
+		    nla_put_in6_addr(skb, RTA_PREFSRC, &saddr_buf))
 			goto nla_put_failure;
 	}
 
 	if (rt->rt6i_prefsrc.plen) {
 		struct in6_addr saddr_buf;
 		saddr_buf = rt->rt6i_prefsrc.addr;
-		if (nla_put(skb, RTA_PREFSRC, 16, &saddr_buf))
+		if (nla_put_in6_addr(skb, RTA_PREFSRC, &saddr_buf))
 			goto nla_put_failure;
 	}
 
@@ -2720,7 +2720,7 @@ static int rt6_fill_node(struct net *net,
 		goto nla_put_failure;
 
 	if (rt->rt6i_flags & RTF_GATEWAY) {
-		if (nla_put(skb, RTA_GATEWAY, 16, &rt->rt6i_gateway) < 0)
+		if (nla_put_in6_addr(skb, RTA_GATEWAY, &rt->rt6i_gateway) < 0)
 			goto nla_put_failure;
 	}
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index e4cbd5798eba..9755c30498a6 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1683,8 +1683,8 @@ static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct ip_tunnel_parm *parm = &tunnel->parms;
 
 	if (nla_put_u32(skb, IFLA_IPTUN_LINK, parm->link) ||
-	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
-	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
+	    nla_put_in_addr(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
+	    nla_put_in_addr(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->iph.ttl) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
@@ -1694,10 +1694,10 @@ static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 		goto nla_put_failure;
 
 #ifdef CONFIG_IPV6_SIT_6RD
-	if (nla_put(skb, IFLA_IPTUN_6RD_PREFIX, sizeof(struct in6_addr),
-		    &tunnel->ip6rd.prefix) ||
-	    nla_put_be32(skb, IFLA_IPTUN_6RD_RELAY_PREFIX,
-			 tunnel->ip6rd.relay_prefix) ||
+	if (nla_put_in6_addr(skb, IFLA_IPTUN_6RD_PREFIX,
+			     &tunnel->ip6rd.prefix) ||
+	    nla_put_in_addr(skb, IFLA_IPTUN_6RD_RELAY_PREFIX,
+			    tunnel->ip6rd.relay_prefix) ||
 	    nla_put_u16(skb, IFLA_IPTUN_6RD_PREFIXLEN,
 			tunnel->ip6rd.prefixlen) ||
 	    nla_put_u16(skb, IFLA_IPTUN_6RD_RELAY_PREFIXLEN,
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index b4e923f77954..a4f78d36bace 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -376,15 +376,17 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 	case L2TP_ENCAPTYPE_IP:
 #if IS_ENABLED(CONFIG_IPV6)
 		if (np) {
-			if (nla_put(skb, L2TP_ATTR_IP6_SADDR, sizeof(np->saddr),
-				    &np->saddr) ||
-			    nla_put(skb, L2TP_ATTR_IP6_DADDR, sizeof(sk->sk_v6_daddr),
-				    &sk->sk_v6_daddr))
+			if (nla_put_in6_addr(skb, L2TP_ATTR_IP6_SADDR,
+					     &np->saddr) ||
+			    nla_put_in6_addr(skb, L2TP_ATTR_IP6_DADDR,
+					     &sk->sk_v6_daddr))
 				goto nla_put_failure;
 		} else
 #endif
-		if (nla_put_be32(skb, L2TP_ATTR_IP_SADDR, inet->inet_saddr) ||
-		    nla_put_be32(skb, L2TP_ATTR_IP_DADDR, inet->inet_daddr))
+		if (nla_put_in_addr(skb, L2TP_ATTR_IP_SADDR,
+				    inet->inet_saddr) ||
+		    nla_put_in_addr(skb, L2TP_ATTR_IP_DADDR,
+				    inet->inet_daddr))
 			goto nla_put_failure;
 		break;
 	}
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index 70440748fe5c..13f777f20995 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -293,15 +293,13 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 				return -ENOMEM;
 
 			addr_struct.s_addr = iter4->addr;
-			ret_val = nla_put(skb, NLBL_MGMT_A_IPV4ADDR,
-					  sizeof(struct in_addr),
-					  &addr_struct);
+			ret_val = nla_put_in_addr(skb, NLBL_MGMT_A_IPV4ADDR,
+						  addr_struct.s_addr);
 			if (ret_val != 0)
 				return ret_val;
 			addr_struct.s_addr = iter4->mask;
-			ret_val = nla_put(skb, NLBL_MGMT_A_IPV4MASK,
-					  sizeof(struct in_addr),
-					  &addr_struct);
+			ret_val = nla_put_in_addr(skb, NLBL_MGMT_A_IPV4MASK,
+						  addr_struct.s_addr);
 			if (ret_val != 0)
 				return ret_val;
 			map4 = netlbl_domhsh_addr4_entry(iter4);
@@ -328,14 +326,12 @@ static int netlbl_mgmt_listentry(struct sk_buff *skb,
 			if (nla_b == NULL)
 				return -ENOMEM;
 
-			ret_val = nla_put(skb, NLBL_MGMT_A_IPV6ADDR,
-					  sizeof(struct in6_addr),
-					  &iter6->addr);
+			ret_val = nla_put_in6_addr(skb, NLBL_MGMT_A_IPV6ADDR,
+						   &iter6->addr);
 			if (ret_val != 0)
 				return ret_val;
-			ret_val = nla_put(skb, NLBL_MGMT_A_IPV6MASK,
-					  sizeof(struct in6_addr),
-					  &iter6->mask);
+			ret_val = nla_put_in6_addr(skb, NLBL_MGMT_A_IPV6MASK,
+						   &iter6->mask);
 			if (ret_val != 0)
 				return ret_val;
 			map6 = netlbl_domhsh_addr6_entry(iter6);
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index aec7994f78cf..b0380927f05f 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1117,34 +1117,30 @@ static int netlbl_unlabel_staticlist_gen(u32 cmd,
 		struct in_addr addr_struct;
 
 		addr_struct.s_addr = addr4->list.addr;
-		ret_val = nla_put(cb_arg->skb,
-				  NLBL_UNLABEL_A_IPV4ADDR,
-				  sizeof(struct in_addr),
-				  &addr_struct);
+		ret_val = nla_put_in_addr(cb_arg->skb,
+					  NLBL_UNLABEL_A_IPV4ADDR,
+					  addr_struct.s_addr);
 		if (ret_val != 0)
 			goto list_cb_failure;
 
 		addr_struct.s_addr = addr4->list.mask;
-		ret_val = nla_put(cb_arg->skb,
-				  NLBL_UNLABEL_A_IPV4MASK,
-				  sizeof(struct in_addr),
-				  &addr_struct);
+		ret_val = nla_put_in_addr(cb_arg->skb,
+					  NLBL_UNLABEL_A_IPV4MASK,
+					  addr_struct.s_addr);
 		if (ret_val != 0)
 			goto list_cb_failure;
 
 		secid = addr4->secid;
 	} else {
-		ret_val = nla_put(cb_arg->skb,
-				  NLBL_UNLABEL_A_IPV6ADDR,
-				  sizeof(struct in6_addr),
-				  &addr6->list.addr);
+		ret_val = nla_put_in6_addr(cb_arg->skb,
+					   NLBL_UNLABEL_A_IPV6ADDR,
+					   &addr6->list.addr);
 		if (ret_val != 0)
 			goto list_cb_failure;
 
-		ret_val = nla_put(cb_arg->skb,
-				  NLBL_UNLABEL_A_IPV6MASK,
-				  sizeof(struct in6_addr),
-				  &addr6->list.mask);
+		ret_val = nla_put_in6_addr(cb_arg->skb,
+					   NLBL_UNLABEL_A_IPV6MASK,
+					   &addr6->list.mask);
 		if (ret_val != 0)
 			goto list_cb_failure;
 
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 22b18c145c92..c0c5b5519f45 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -648,10 +648,12 @@ static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
 	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id))
 		return -EMSGSIZE;
 	if (output->ipv4_src &&
-	    nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC, output->ipv4_src))
+	    nla_put_in_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC,
+			    output->ipv4_src))
 		return -EMSGSIZE;
 	if (output->ipv4_dst &&
-	    nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST, output->ipv4_dst))
+	    nla_put_in_addr(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST,
+			    output->ipv4_dst))
 		return -EMSGSIZE;
 	if (output->ipv4_tos &&
 	    nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, output->ipv4_tos))
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index d6ba4a6bbff6..6a4a4d7db1fc 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -8761,8 +8761,8 @@ static int nl80211_send_wowlan_tcp(struct sk_buff *msg,
 	if (!nl_tcp)
 		return -ENOBUFS;
 
-	if (nla_put_be32(msg, NL80211_WOWLAN_TCP_SRC_IPV4, tcp->src) ||
-	    nla_put_be32(msg, NL80211_WOWLAN_TCP_DST_IPV4, tcp->dst) ||
+	if (nla_put_in_addr(msg, NL80211_WOWLAN_TCP_SRC_IPV4, tcp->src) ||
+	    nla_put_in_addr(msg, NL80211_WOWLAN_TCP_DST_IPV4, tcp->dst) ||
 	    nla_put(msg, NL80211_WOWLAN_TCP_DST_MAC, ETH_ALEN, tcp->dst_mac) ||
 	    nla_put_u16(msg, NL80211_WOWLAN_TCP_SRC_PORT, tcp->src_port) ||
 	    nla_put_u16(msg, NL80211_WOWLAN_TCP_DST_PORT, tcp->dst_port) ||
-- 
1.8.3.1
