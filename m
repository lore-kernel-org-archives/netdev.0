From: David Miller <davem@davemloft.net>
Subject: [PATCH 20/25] net: Use flowi4 and flowi6 in xfrm layer.
Date: Sat, 12 Mar 2011 15:29:56 -0800 (PST)
Message-ID: <20110312.152956.200369801.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755582Ab1CLX3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:29:19 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id BE49924C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:29:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h      |   24 ++++++++++++------------
 net/ipv4/xfrm4_policy.c |   46 ++++++++++++++++++++++++----------------------
 net/ipv4/xfrm4_state.c  |   14 ++++++++------
 net/ipv6/xfrm6_policy.c |   39 +++++++++++++++++++++------------------
 net/ipv6/xfrm6_state.c  |   14 ++++++++------
 net/xfrm/xfrm_policy.c  |   28 ++++++++++++++++------------
 6 files changed, 89 insertions(+), 76 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index aa860ad..8f8bd82 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1142,9 +1142,9 @@ xfrm_address_t *xfrm_flowi_daddr(const struct flowi *fl, unsigned short family)
 {
 	switch (family){
 	case AF_INET:
-		return (xfrm_address_t *)&fl->fl4_dst;
+		return (xfrm_address_t *)&fl->u.ip4.daddr;
 	case AF_INET6:
-		return (xfrm_address_t *)&fl->fl6_dst;
+		return (xfrm_address_t *)&fl->u.ip6.daddr;
 	}
 	return NULL;
 }
@@ -1154,9 +1154,9 @@ xfrm_address_t *xfrm_flowi_saddr(const struct flowi *fl, unsigned short family)
 {
 	switch (family){
 	case AF_INET:
-		return (xfrm_address_t *)&fl->fl4_src;
+		return (xfrm_address_t *)&fl->u.ip4.saddr;
 	case AF_INET6:
-		return (xfrm_address_t *)&fl->fl6_src;
+		return (xfrm_address_t *)&fl->u.ip6.saddr;
 	}
 	return NULL;
 }
@@ -1168,12 +1168,12 @@ void xfrm_flowi_addr_get(const struct flowi *fl,
 {
 	switch(family) {
 	case AF_INET:
-		memcpy(&saddr->a4, &fl->fl4_src, sizeof(saddr->a4));
-		memcpy(&daddr->a4, &fl->fl4_dst, sizeof(daddr->a4));
+		memcpy(&saddr->a4, &fl->u.ip4.saddr, sizeof(saddr->a4));
+		memcpy(&daddr->a4, &fl->u.ip4.daddr, sizeof(daddr->a4));
 		break;
 	case AF_INET6:
-		ipv6_addr_copy((struct in6_addr *)&saddr->a6, &fl->fl6_src);
-		ipv6_addr_copy((struct in6_addr *)&daddr->a6, &fl->fl6_dst);
+		ipv6_addr_copy((struct in6_addr *)&saddr->a6, &fl->u.ip6.saddr);
+		ipv6_addr_copy((struct in6_addr *)&daddr->a6, &fl->u.ip6.daddr);
 		break;
 	}
 }
@@ -1221,12 +1221,12 @@ xfrm_state_addr_flow_check(const struct xfrm_state *x, const struct flowi *fl,
 	switch (family) {
 	case AF_INET:
 		return __xfrm4_state_addr_check(x,
-						(const xfrm_address_t *)&fl->fl4_dst,
-						(const xfrm_address_t *)&fl->fl4_src);
+						(const xfrm_address_t *)&fl->u.ip4.daddr,
+						(const xfrm_address_t *)&fl->u.ip4.saddr);
 	case AF_INET6:
 		return __xfrm6_state_addr_check(x,
-						(const xfrm_address_t *)&fl->fl6_dst,
-						(const xfrm_address_t *)&fl->fl6_src);
+						(const xfrm_address_t *)&fl->u.ip6.daddr,
+						(const xfrm_address_t *)&fl->u.ip6.saddr);
 	}
 	return 0;
 }
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index b111f468..30b312c 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -56,7 +56,7 @@ static int xfrm4_get_saddr(struct net *net,
 
 static int xfrm4_get_tos(const struct flowi *fl)
 {
-	return IPTOS_RT_MASK & fl->fl4_tos; /* Strip ECN bits */
+	return IPTOS_RT_MASK & fl->u.ip4.flowi4_tos; /* Strip ECN bits */
 }
 
 static int xfrm4_init_path(struct xfrm_dst *path, struct dst_entry *dst,
@@ -69,13 +69,14 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 			  const struct flowi *fl)
 {
 	struct rtable *rt = (struct rtable *)xdst->route;
+	const struct flowi4 *fl4 = &fl->u.ip4;
 
-	rt->rt_key_dst = fl->fl4_dst;
-	rt->rt_key_src = fl->fl4_src;
-	rt->rt_tos = fl->fl4_tos;
-	rt->rt_iif = fl->flowi_iif;
-	rt->rt_oif = fl->flowi_oif;
-	rt->rt_mark = fl->flowi_mark;
+	rt->rt_key_dst = fl4->daddr;
+	rt->rt_key_src = fl4->saddr;
+	rt->rt_tos = fl4->flowi4_tos;
+	rt->rt_iif = fl4->flowi4_iif;
+	rt->rt_oif = fl4->flowi4_oif;
+	rt->rt_mark = fl4->flowi4_mark;
 
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
@@ -102,9 +103,10 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
 	struct iphdr *iph = ip_hdr(skb);
 	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
+	struct flowi4 *fl4 = &fl->u.ip4;
 
-	memset(fl, 0, sizeof(struct flowi));
-	fl->flowi_mark = skb->mark;
+	memset(fl4, 0, sizeof(struct flowi4));
+	fl4->flowi4_mark = skb->mark;
 
 	if (!(iph->frag_off & htons(IP_MF | IP_OFFSET))) {
 		switch (iph->protocol) {
@@ -117,8 +119,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			    pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be16 *ports = (__be16 *)xprth;
 
-				fl->fl4_sport = ports[!!reverse];
-				fl->fl4_dport = ports[!reverse];
+				fl4->uli.ports.sport = ports[!!reverse];
+				fl4->uli.ports.dport = ports[!reverse];
 			}
 			break;
 
@@ -126,8 +128,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 2 - skb->data)) {
 				u8 *icmp = xprth;
 
-				fl->fl4_icmp_type = icmp[0];
-				fl->fl4_icmp_code = icmp[1];
+				fl4->uli.icmpt.type = icmp[0];
+				fl4->uli.icmpt.code = icmp[1];
 			}
 			break;
 
@@ -135,7 +137,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be32 *ehdr = (__be32 *)xprth;
 
-				fl->fl4_ipsec_spi = ehdr[0];
+				fl4->uli.spi = ehdr[0];
 			}
 			break;
 
@@ -143,7 +145,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 8 - skb->data)) {
 				__be32 *ah_hdr = (__be32*)xprth;
 
-				fl->fl4_ipsec_spi = ah_hdr[1];
+				fl4->uli.spi = ah_hdr[1];
 			}
 			break;
 
@@ -151,7 +153,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be16 *ipcomp_hdr = (__be16 *)xprth;
 
-				fl->fl4_ipsec_spi = htonl(ntohs(ipcomp_hdr[1]));
+				fl4->uli.spi = htonl(ntohs(ipcomp_hdr[1]));
 			}
 			break;
 
@@ -163,20 +165,20 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 				if (greflags[0] & GRE_KEY) {
 					if (greflags[0] & GRE_CSUM)
 						gre_hdr++;
-					fl->fl4_gre_key = gre_hdr[1];
+					fl4->uli.gre_key = gre_hdr[1];
 				}
 			}
 			break;
 
 		default:
-			fl->fl4_ipsec_spi = 0;
+			fl4->uli.spi = 0;
 			break;
 		}
 	}
-	fl->flowi_proto = iph->protocol;
-	fl->fl4_dst = reverse ? iph->saddr : iph->daddr;
-	fl->fl4_src = reverse ? iph->daddr : iph->saddr;
-	fl->fl4_tos = iph->tos;
+	fl4->flowi4_proto = iph->protocol;
+	fl4->daddr = reverse ? iph->saddr : iph->daddr;
+	fl4->saddr = reverse ? iph->daddr : iph->saddr;
+	fl4->flowi4_tos = iph->tos;
 }
 
 static inline int xfrm4_garbage_collect(struct dst_ops *ops)
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index d8d5419..1717c64 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -23,17 +23,19 @@ static int xfrm4_init_flags(struct xfrm_state *x)
 static void
 __xfrm4_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 {
-	sel->daddr.a4 = fl->fl4_dst;
-	sel->saddr.a4 = fl->fl4_src;
-	sel->dport = xfrm_flowi_dport(fl, &fl->u.ip4.uli);
+	const struct flowi4 *fl4 = &fl->u.ip4;
+
+	sel->daddr.a4 = fl4->daddr;
+	sel->saddr.a4 = fl4->saddr;
+	sel->dport = xfrm_flowi_dport(fl, &fl4->uli);
 	sel->dport_mask = htons(0xffff);
-	sel->sport = xfrm_flowi_sport(fl, &fl->u.ip4.uli);
+	sel->sport = xfrm_flowi_sport(fl, &fl4->uli);
 	sel->sport_mask = htons(0xffff);
 	sel->family = AF_INET;
 	sel->prefixlen_d = 32;
 	sel->prefixlen_s = 32;
-	sel->proto = fl->flowi_proto;
-	sel->ifindex = fl->flowi_oif;
+	sel->proto = fl4->flowi4_proto;
+	sel->ifindex = fl4->flowi4_oif;
 }
 
 static void
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 213c759..254aa6d 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -30,15 +30,17 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos,
 					  const xfrm_address_t *saddr,
 					  const xfrm_address_t *daddr)
 {
-	struct flowi fl = {};
+	struct flowi6 fl6;
 	struct dst_entry *dst;
 	int err;
 
-	memcpy(&fl.fl6_dst, daddr, sizeof(fl.fl6_dst));
+	memset(&fl6, 0, sizeof(fl6));
+	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
 	if (saddr)
-		memcpy(&fl.fl6_src, saddr, sizeof(fl.fl6_src));
+		memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
 
-	dst = ip6_route_output(net, NULL, &fl);
+	dst = ip6_route_output(net, NULL,
+			       flowi6_to_flowi(&fl6));
 
 	err = dst->error;
 	if (dst->error) {
@@ -120,6 +122,7 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 static inline void
 _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
+	struct flowi6 *fl6 = &fl->u.ip6;
 	int onlyproto = 0;
 	u16 offset = skb_network_header_len(skb);
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
@@ -127,11 +130,11 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	const unsigned char *nh = skb_network_header(skb);
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
 
-	memset(fl, 0, sizeof(struct flowi));
-	fl->flowi_mark = skb->mark;
+	memset(fl6, 0, sizeof(struct flowi6));
+	fl6->flowi6_mark = skb->mark;
 
-	ipv6_addr_copy(&fl->fl6_dst, reverse ? &hdr->saddr : &hdr->daddr);
-	ipv6_addr_copy(&fl->fl6_src, reverse ? &hdr->daddr : &hdr->saddr);
+	ipv6_addr_copy(&fl6->daddr, reverse ? &hdr->saddr : &hdr->daddr);
+	ipv6_addr_copy(&fl6->saddr, reverse ? &hdr->daddr : &hdr->saddr);
 
 	while (nh + offset + 1 < skb->data ||
 	       pskb_may_pull(skb, nh + offset + 1 - skb->data)) {
@@ -158,20 +161,20 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 			     pskb_may_pull(skb, nh + offset + 4 - skb->data))) {
 				__be16 *ports = (__be16 *)exthdr;
 
-				fl->fl6_sport = ports[!!reverse];
-				fl->fl6_dport = ports[!reverse];
+				fl6->uli.ports.sport = ports[!!reverse];
+				fl6->uli.ports.dport = ports[!reverse];
 			}
-			fl->flowi_proto = nexthdr;
+			fl6->flowi6_proto = nexthdr;
 			return;
 
 		case IPPROTO_ICMPV6:
 			if (!onlyproto && pskb_may_pull(skb, nh + offset + 2 - skb->data)) {
 				u8 *icmp = (u8 *)exthdr;
 
-				fl->fl6_icmp_type = icmp[0];
-				fl->fl6_icmp_code = icmp[1];
+				fl6->uli.icmpt.type = icmp[0];
+				fl6->uli.icmpt.code = icmp[1];
 			}
-			fl->flowi_proto = nexthdr;
+			fl6->flowi6_proto = nexthdr;
 			return;
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
@@ -180,9 +183,9 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 				struct ip6_mh *mh;
 				mh = (struct ip6_mh *)exthdr;
 
-				fl->fl6_mh_type = mh->ip6mh_type;
+				fl6->uli.mht.type = mh->ip6mh_type;
 			}
-			fl->flowi_proto = nexthdr;
+			fl6->flowi6_proto = nexthdr;
 			return;
 #endif
 
@@ -191,8 +194,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 		case IPPROTO_ESP:
 		case IPPROTO_COMP:
 		default:
-			fl->fl6_ipsec_spi = 0;
-			fl->flowi_proto = nexthdr;
+			fl6->uli.spi = 0;
+			fl6->flowi6_proto = nexthdr;
 			return;
 		}
 	}
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index b456533..afe941e 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -22,19 +22,21 @@
 static void
 __xfrm6_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 {
+	const struct flowi6 *fl6 = &fl->u.ip6;
+
 	/* Initialize temporary selector matching only
 	 * to current session. */
-	ipv6_addr_copy((struct in6_addr *)&sel->daddr, &fl->fl6_dst);
-	ipv6_addr_copy((struct in6_addr *)&sel->saddr, &fl->fl6_src);
-	sel->dport = xfrm_flowi_dport(fl, &fl->u.ip6.uli);
+	ipv6_addr_copy((struct in6_addr *)&sel->daddr, &fl6->daddr);
+	ipv6_addr_copy((struct in6_addr *)&sel->saddr, &fl6->saddr);
+	sel->dport = xfrm_flowi_dport(fl, &fl6->uli);
 	sel->dport_mask = htons(0xffff);
-	sel->sport = xfrm_flowi_sport(fl, &fl->u.ip6.uli);
+	sel->sport = xfrm_flowi_sport(fl, &fl6->uli);
 	sel->sport_mask = htons(0xffff);
 	sel->family = AF_INET6;
 	sel->prefixlen_d = 128;
 	sel->prefixlen_s = 128;
-	sel->proto = fl->flowi_proto;
-	sel->ifindex = fl->flowi_oif;
+	sel->proto = fl6->flowi6_proto;
+	sel->ifindex = fl6->flowi6_oif;
 }
 
 static void
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2ecd18a..1ba0258 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -59,23 +59,27 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 static inline int
 __xfrm4_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
-	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
-		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl, &fl->u.ip4.uli) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl, &fl->u.ip4.uli) ^ sel->sport) & sel->sport_mask) &&
-		(fl->flowi_proto == sel->proto || !sel->proto) &&
-		(fl->flowi_oif == sel->ifindex || !sel->ifindex);
+	const struct flowi4 *fl4 = &fl->u.ip4;
+
+	return  addr_match(&fl4->daddr, &sel->daddr, sel->prefixlen_d) &&
+		addr_match(&fl4->saddr, &sel->saddr, sel->prefixlen_s) &&
+		!((xfrm_flowi_dport(fl, &fl4->uli) ^ sel->dport) & sel->dport_mask) &&
+		!((xfrm_flowi_sport(fl, &fl4->uli) ^ sel->sport) & sel->sport_mask) &&
+		(fl4->flowi4_proto == sel->proto || !sel->proto) &&
+		(fl4->flowi4_oif == sel->ifindex || !sel->ifindex);
 }
 
 static inline int
 __xfrm6_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
-	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
-		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl, &fl->u.ip6.uli) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl, &fl->u.ip6.uli) ^ sel->sport) & sel->sport_mask) &&
-		(fl->flowi_proto == sel->proto || !sel->proto) &&
-		(fl->flowi_oif == sel->ifindex || !sel->ifindex);
+	const struct flowi6 *fl6 = &fl->u.ip6;
+
+	return  addr_match(&fl6->daddr, &sel->daddr, sel->prefixlen_d) &&
+		addr_match(&fl6->saddr, &sel->saddr, sel->prefixlen_s) &&
+		!((xfrm_flowi_dport(fl, &fl6->uli) ^ sel->dport) & sel->dport_mask) &&
+		!((xfrm_flowi_sport(fl, &fl6->uli) ^ sel->sport) & sel->sport_mask) &&
+		(fl6->flowi6_proto == sel->proto || !sel->proto) &&
+		(fl6->flowi6_oif == sel->ifindex || !sel->ifindex);
 }
 
 int xfrm_selector_match(const struct xfrm_selector *sel, const struct flowi *fl,
-- 
1.7.4.1

