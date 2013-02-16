From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 1/4] ipv6: introduce new type ipv6_addr_props to hold ipv6 address type and scope
Date: Sat, 16 Feb 2013 20:10:08 +0100
Message-ID: <20130216191008.GA23272@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org, brian.haley@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39305 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972Ab3BPTKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 14:10:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simplifies ipv6 address type handling. The old implementation had
the problem that scope and type where both squeezed into one int. Because
of this it was dangerous to do comparisons on it or check for scope while
it is actually being stripped out. This patch mainly improves type safety.

v2:
a) Incorportated feedback from Brian Haley
b) fix style in addrconf_core.c:__ipv6_addr_props

Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: Brian Haley <brian.haley@hp.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ipv6.h       | 20 ++++++----
 net/ipv6/addrconf.c      | 28 +++++++-------
 net/ipv6/addrconf_core.c | 99 +++++++++++++++++++++++++++++++-----------------
 net/ipv6/datagram.c      | 12 +++---
 4 files changed, 99 insertions(+), 60 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 851d541..a14700c 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -298,25 +298,31 @@ static inline int ip6_frag_mem(struct net *net)
 #define IPV6_FRAG_LOW_THRESH	(3 * 1024*1024)	/* 3145728 */
 #define IPV6_FRAG_TIMEOUT	(60 * HZ)	/* 60 seconds */
 
-extern int __ipv6_addr_type(const struct in6_addr *addr);
-static inline int ipv6_addr_type(const struct in6_addr *addr)
+struct ipv6_addr_props {
+	u16 type;
+	s16 scope;
+};
+
+extern struct ipv6_addr_props __ipv6_addr_props(const struct in6_addr *addr);
+static inline unsigned int ipv6_addr_type(const struct in6_addr *addr)
 {
-	return __ipv6_addr_type(addr) & 0xffff;
+	return __ipv6_addr_props(addr).type;
 }
 
 static inline int ipv6_addr_scope(const struct in6_addr *addr)
 {
-	return __ipv6_addr_type(addr) & IPV6_ADDR_SCOPE_MASK;
+	return __ipv6_addr_props(addr).scope;
 }
 
-static inline int __ipv6_addr_src_scope(int type)
+static inline int __ipv6_addr_src_scope(struct ipv6_addr_props props)
 {
-	return (type == IPV6_ADDR_ANY) ? __IPV6_ADDR_SCOPE_INVALID : (type >> 16);
+	return (props.type == IPV6_ADDR_ANY) ?
+		__IPV6_ADDR_SCOPE_INVALID : props.scope;
 }
 
 static inline int ipv6_addr_src_scope(const struct in6_addr *addr)
 {
-	return __ipv6_addr_src_scope(__ipv6_addr_type(addr));
+	return __ipv6_addr_src_scope(__ipv6_addr_props(addr));
 }
 
 static inline int ipv6_addr_cmp(const struct in6_addr *a1, const struct in6_addr *a2)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 86c235d..c3a0ff7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1106,7 +1106,7 @@ enum {
 
 struct ipv6_saddr_score {
 	int			rule;
-	int			addr_type;
+	struct ipv6_addr_props	addr_props;
 	struct inet6_ifaddr	*ifa;
 	DECLARE_BITMAP(scorebits, IPV6_SADDR_RULE_MAX);
 	int			scopedist;
@@ -1180,7 +1180,7 @@ static int ipv6_get_saddr_eval(struct net *net,
 		 * C > d + 14 - B >= 15 + 14 - B = 29 - B.
 		 * Assume B = 0 and we get C > 29.
 		 */
-		ret = __ipv6_addr_src_scope(score->addr_type);
+		ret = __ipv6_addr_src_scope(score->addr_props);
 		if (ret >= dst->scope)
 			ret = -ret;
 		else
@@ -1189,8 +1189,9 @@ static int ipv6_get_saddr_eval(struct net *net,
 		break;
 	case IPV6_SADDR_RULE_PREFERRED:
 		/* Rule 3: Avoid deprecated and optimistic addresses */
-		ret = ipv6_saddr_preferred(score->addr_type) ||
-		      !(score->ifa->flags & (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC));
+		ret = ipv6_saddr_preferred(score->addr_props.type) ||
+			!(score->ifa->flags &
+			  (IFA_F_DEPRECATED|IFA_F_OPTIMISTIC));
 		break;
 #ifdef CONFIG_IPV6_MIP6
 	case IPV6_SADDR_RULE_HOA:
@@ -1209,7 +1210,7 @@ static int ipv6_get_saddr_eval(struct net *net,
 	case IPV6_SADDR_RULE_LABEL:
 		/* Rule 6: Prefer matching label */
 		ret = ipv6_addr_label(net,
-				      &score->ifa->addr, score->addr_type,
+				      &score->ifa->addr, score->addr_props.type,
 				      score->ifa->idev->dev->ifindex) == dst->label;
 		break;
 #ifdef CONFIG_IPV6_PRIVACY
@@ -1258,13 +1259,12 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 				*score = &scores[0], *hiscore = &scores[1];
 	struct ipv6_saddr_dst dst;
 	struct net_device *dev;
-	int dst_type;
+	struct ipv6_addr_props dst_props = __ipv6_addr_props(daddr);
 
-	dst_type = __ipv6_addr_type(daddr);
 	dst.addr = daddr;
 	dst.ifindex = dst_dev ? dst_dev->ifindex : 0;
-	dst.scope = __ipv6_addr_src_scope(dst_type);
-	dst.label = ipv6_addr_label(net, daddr, dst_type, dst.ifindex);
+	dst.scope = __ipv6_addr_src_scope(dst_props);
+	dst.label = ipv6_addr_label(net, daddr, dst_props.type, dst.ifindex);
 	dst.prefs = prefs;
 
 	hiscore->rule = -1;
@@ -1287,7 +1287,7 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 		 *    belonging to the same site as the outgoing
 		 *    interface.)
 		 */
-		if (((dst_type & IPV6_ADDR_MULTICAST) ||
+		if ((dst_props.type & IPV6_ADDR_MULTICAST ||
 		     dst.scope <= IPV6_ADDR_SCOPE_LINKLOCAL) &&
 		    dst.ifindex && dev->ifindex != dst.ifindex)
 			continue;
@@ -1314,10 +1314,12 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 			    (!(score->ifa->flags & IFA_F_OPTIMISTIC)))
 				continue;
 
-			score->addr_type = __ipv6_addr_type(&score->ifa->addr);
+			score->addr_props =
+				__ipv6_addr_props(&score->ifa->addr);
 
-			if (unlikely(score->addr_type == IPV6_ADDR_ANY ||
-				     score->addr_type & IPV6_ADDR_MULTICAST)) {
+			if (unlikely(score->addr_props.type == IPV6_ADDR_ANY ||
+				     score->addr_props.type &
+				     IPV6_ADDR_MULTICAST)) {
 				LIMIT_NETDEBUG(KERN_DEBUG
 					       "ADDRCONF: unspecified / multicast address "
 					       "assigned as unicast address on %s",
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index d051e5f..99cb205 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -6,75 +6,104 @@
 #include <linux/export.h>
 #include <net/ipv6.h>
 
-#define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
-
-static inline unsigned int ipv6_addr_scope2type(unsigned int scope)
+static inline struct ipv6_addr_props ipv6_addr_mc_props(unsigned int scope)
 {
 	switch (scope) {
 	case IPV6_ADDR_SCOPE_NODELOCAL:
-		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_NODELOCAL) |
-			IPV6_ADDR_LOOPBACK);
+		return (struct ipv6_addr_props){
+			.type = IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK,
+			.scope = IPV6_ADDR_SCOPE_NODELOCAL
+		};
 	case IPV6_ADDR_SCOPE_LINKLOCAL:
-		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL) |
-			IPV6_ADDR_LINKLOCAL);
+		return (struct ipv6_addr_props){
+			.type = IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL,
+			.scope = IPV6_ADDR_SCOPE_LINKLOCAL
+		};
 	case IPV6_ADDR_SCOPE_SITELOCAL:
-		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL) |
-			IPV6_ADDR_SITELOCAL);
+		return (struct ipv6_addr_props){
+			.type = IPV6_ADDR_MULTICAST|IPV6_ADDR_SITELOCAL,
+			.scope = IPV6_ADDR_SCOPE_SITELOCAL
+		};
 	}
-	return IPV6_ADDR_SCOPE_TYPE(scope);
+	return (struct ipv6_addr_props){
+		.type = IPV6_ADDR_MULTICAST,
+		.scope = scope
+	};
 }
 
-int __ipv6_addr_type(const struct in6_addr *addr)
+struct ipv6_addr_props __ipv6_addr_props(const struct in6_addr *addr)
 {
-	__be32 st;
-
-	st = addr->s6_addr32[0];
+	__be32 st = addr->s6_addr32[0];
 
 	/* Consider all addresses with the first three bits different of
 	   000 and 111 as unicasts.
 	 */
 	if ((st & htonl(0xE0000000)) != htonl(0x00000000) &&
 	    (st & htonl(0xE0000000)) != htonl(0xE0000000))
-		return (IPV6_ADDR_UNICAST |
-			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));
+		return (struct ipv6_addr_props){
+			.type = IPV6_ADDR_UNICAST,
+			.scope = IPV6_ADDR_SCOPE_GLOBAL
+		};
 
 	if ((st & htonl(0xFF000000)) == htonl(0xFF000000)) {
 		/* multicast */
 		/* addr-select 3.1 */
-		return (IPV6_ADDR_MULTICAST |
-			ipv6_addr_scope2type(IPV6_ADDR_MC_SCOPE(addr)));
+		return ipv6_addr_mc_props(IPV6_ADDR_MC_SCOPE(addr));
 	}
 
 	if ((st & htonl(0xFFC00000)) == htonl(0xFE800000))
-		return (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_UNICAST |
-			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL));		/* addr-select 3.1 */
+		/* addr-select 3.1 */
+		return (struct ipv6_addr_props){
+			.type = IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST,
+			.scope = IPV6_ADDR_SCOPE_LINKLOCAL
+		};
 	if ((st & htonl(0xFFC00000)) == htonl(0xFEC00000))
-		return (IPV6_ADDR_SITELOCAL | IPV6_ADDR_UNICAST |
-			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL));		/* addr-select 3.1 */
+		/* addr-select 3.1 */
+		return (struct ipv6_addr_props){
+			.type = IPV6_ADDR_SITELOCAL|IPV6_ADDR_UNICAST,
+			.scope = IPV6_ADDR_SCOPE_SITELOCAL,
+		};
 	if ((st & htonl(0xFE000000)) == htonl(0xFC000000))
-		return (IPV6_ADDR_UNICAST |
-			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));			/* RFC 4193 */
+		/* RFC 4193 */
+		return (struct ipv6_addr_props){
+			.type = IPV6_ADDR_UNICAST,
+			.scope = IPV6_ADDR_SCOPE_GLOBAL,
+		};
 
 	if ((addr->s6_addr32[0] | addr->s6_addr32[1]) == 0) {
 		if (addr->s6_addr32[2] == 0) {
 			if (addr->s6_addr32[3] == 0)
-				return IPV6_ADDR_ANY;
+				return (struct ipv6_addr_props){
+					.type = IPV6_ADDR_ANY
+				};
 
 			if (addr->s6_addr32[3] == htonl(0x00000001))
-				return (IPV6_ADDR_LOOPBACK | IPV6_ADDR_UNICAST |
-					IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL));	/* addr-select 3.4 */
+				/* addr-select 3.4 */
+				return (struct ipv6_addr_props){
+					.type = IPV6_ADDR_LOOPBACK|
+						IPV6_ADDR_UNICAST,
+					.scope = IPV6_ADDR_SCOPE_LINKLOCAL
+				};
 
-			return (IPV6_ADDR_COMPATv4 | IPV6_ADDR_UNICAST |
-				IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.3 */
+			/* addr-select 3.3 */
+			return (struct ipv6_addr_props){
+				.type = IPV6_ADDR_COMPATv4|IPV6_ADDR_UNICAST,
+				.scope = IPV6_ADDR_SCOPE_GLOBAL
+			};
 		}
 
 		if (addr->s6_addr32[2] == htonl(0x0000ffff))
-			return (IPV6_ADDR_MAPPED |
-				IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.3 */
+			/* addr-select 3.3 */
+			return (struct ipv6_addr_props){
+				.type = IPV6_ADDR_MAPPED,
+				.scope = IPV6_ADDR_SCOPE_GLOBAL
+			};
 	}
 
-	return (IPV6_ADDR_UNICAST |
-		IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.4 */
+	/* addr-select 3.4 */
+	return (struct ipv6_addr_props){
+		.type = IPV6_ADDR_UNICAST,
+		.scope = IPV6_ADDR_SCOPE_GLOBAL
+	};
 }
-EXPORT_SYMBOL(__ipv6_addr_type);
-
+EXPORT_SYMBOL(__ipv6_addr_props);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index f5a5478..05f0889 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -614,7 +614,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 	int err = 0;
 
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
-		int addr_type;
+		struct ipv6_addr_props addr_props;
 
 		if (!CMSG_OK(msg, cmsg)) {
 			err = -EINVAL;
@@ -644,7 +644,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 				fl6->flowi6_oif = src_info->ipi6_ifindex;
 			}
 
-			addr_type = __ipv6_addr_type(&src_info->ipi6_addr);
+			addr_props = __ipv6_addr_props(&src_info->ipi6_addr);
 
 			rcu_read_lock();
 			if (fl6->flowi6_oif) {
@@ -653,13 +653,15 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 					rcu_read_unlock();
 					return -ENODEV;
 				}
-			} else if (addr_type & IPV6_ADDR_LINKLOCAL) {
+			} else if (addr_props.type & IPV6_ADDR_LINKLOCAL) {
 				rcu_read_unlock();
 				return -EINVAL;
 			}
 
-			if (addr_type != IPV6_ADDR_ANY) {
-				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
+			if (addr_props.type != IPV6_ADDR_ANY) {
+				int strict =
+					__ipv6_addr_src_scope(addr_props) <=
+					IPV6_ADDR_SCOPE_LINKLOCAL;
 				if (!(inet_sk(sk)->freebind || inet_sk(sk)->transparent) &&
 				    !ipv6_chk_addr(net, &src_info->ipi6_addr,
 						   strict ? dev : NULL, 0))
-- 
1.8.1.2
