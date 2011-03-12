From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/25] net: Break struct flowi out into AF specific
 instances.
Date: Sat, 12 Mar 2011 15:26:50 -0800 (PST)
Message-ID: <20110312.152650.246532980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37579
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756185Ab1CLX0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:26:12 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5FBCC24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:26:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now we have struct flowi4, flowi6, and flowidn for each address
family.  And struct flowi is just a union of them all.

It might have been troublesome to convert flow_cache_uli_match() but
as it turns out this function is completely unused and therefore can
be simply removed.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dn.h       |    4 +-
 include/net/flow.h     |  114 ++++++++++++++++++++++++------------------------
 net/ipv4/xfrm4_state.c |    4 +-
 net/ipv6/mip6.c        |    4 +-
 net/ipv6/xfrm6_state.c |    4 +-
 net/xfrm/xfrm_policy.c |    8 ++--
 6 files changed, 69 insertions(+), 69 deletions(-)

diff --git a/include/net/dn.h b/include/net/dn.h
index a514a3c..558dc7f 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -194,8 +194,8 @@ static inline void dn_dn2eth(unsigned char *ethaddr, __le16 addr)
 
 static inline void dn_sk_ports_copy(struct flowi *fl, struct dn_scp *scp)
 {
-	fl->uli_u.dnports.sport = scp->addrloc;
-	fl->uli_u.dnports.dport = scp->addrrem;
+	fl->u.dn.uli.ports.sport = scp->addrloc;
+	fl->u.dn.uli.ports.dport = scp->addrrem;
 }
 
 extern unsigned dn_mss_from_pmtu(struct net_device *dev, int mtu);
diff --git a/include/net/flow.h b/include/net/flow.h
index f19f41d..9311690 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -48,61 +48,68 @@ union flowi_uli {
 	} mht;
 };
 
-struct flowi {
+struct flowi4 {
+	struct flowi_common	__fl_common;
+	__be32			daddr;
+	__be32			saddr;
+	union flowi_uli		uli;
+};
+
+struct flowi6 {
 	struct flowi_common	__fl_common;
-#define flowi_oif		__fl_common.flowic_oif
-#define flowi_iif		__fl_common.flowic_iif
-#define flowi_mark		__fl_common.flowic_mark
-#define flowi_tos		__fl_common.flowic_tos
-#define flowi_scope		__fl_common.flowic_scope
-#define flowi_proto		__fl_common.flowic_proto
-#define flowi_flags		__fl_common.flowic_flags
-#define flowi_secid		__fl_common.flowic_secid
+	struct in6_addr		daddr;
+	struct in6_addr		saddr;
+	__be32			flowlabel;
+	union flowi_uli		uli;
+};
 
+struct flowidn {
+	struct flowi_common	__fl_common;
+	__le16			daddr;
+	__le16			saddr;
+	union flowi_uli		uli;
+};
+
+struct flowi {
 	union {
-		struct {
-			__be32			daddr;
-			__be32			saddr;
-		} ip4_u;
-		
-		struct {
-			struct in6_addr		daddr;
-			struct in6_addr		saddr;
-			__be32			flowlabel;
-		} ip6_u;
-
-		struct {
-			__le16			daddr;
-			__le16			saddr;
-			__u8			scope;
-		} dn_u;
-	} nl_u;
-#define fld_dst		nl_u.dn_u.daddr
-#define fld_src		nl_u.dn_u.saddr
-#define fld_scope	nl_u.dn_u.scope
-#define fl6_dst		nl_u.ip6_u.daddr
-#define fl6_src		nl_u.ip6_u.saddr
-#define fl6_flowlabel	nl_u.ip6_u.flowlabel
-#define fl4_dst		nl_u.ip4_u.daddr
-#define fl4_src		nl_u.ip4_u.saddr
+		struct flowi_common	__fl_common;
+		struct flowi4		ip4;
+		struct flowi6		ip6;
+		struct flowidn		dn;
+	} u;
+#define flowi_oif	u.__fl_common.flowic_oif
+#define flowi_iif	u.__fl_common.flowic_iif
+#define flowi_mark	u.__fl_common.flowic_mark
+#define flowi_tos	u.__fl_common.flowic_tos
+#define flowi_scope	u.__fl_common.flowic_scope
+#define flowi_proto	u.__fl_common.flowic_proto
+#define flowi_flags	u.__fl_common.flowic_flags
+#define flowi_secid	u.__fl_common.flowic_secid
 #define fl4_tos		flowi_tos
 #define fl4_scope	flowi_scope
-
-	union flowi_uli uli_u;
-#define fl4_sport	uli_u.ports.sport
-#define fl4_dport	uli_u.ports.dport
-#define fl4_icmp_type	uli_u.icmpt.type
-#define fl4_icmp_code	uli_u.icmpt.code
-#define fl4_ipsec_spi	uli_u.spi
-#define fl4_mh_type	uli_u.mht.type
-#define fl4_gre_key	uli_u.gre_key
-#define fl6_sport	uli_u.ports.sport
-#define fl6_dport	uli_u.ports.dport
-#define fl6_icmp_type	uli_u.icmpt.type
-#define fl6_icmp_code	uli_u.icmpt.code
-#define fl6_ipsec_spi	uli_u.spi
-#define fl6_mh_type	uli_u.mht.type
-#define fl6_gre_key	uli_u.gre_key
+#define fld_scope	flowi_scope
+
+#define fld_dst		u.dn.daddr
+#define fld_src		u.dn.saddr
+#define fl6_dst		u.ip6.daddr
+#define fl6_src		u.ip6.saddr
+#define fl6_flowlabel	u.ip6.flowlabel
+#define fl4_dst		u.ip4.daddr
+#define fl4_src		u.ip4.saddr
+#define fl4_sport	u.ip4.uli.ports.sport
+#define fl4_dport	u.ip4.uli.ports.dport
+#define fl4_icmp_type	u.ip4.uli.icmpt.type
+#define fl4_icmp_code	u.ip4.uli.icmpt.code
+#define fl4_ipsec_spi	u.ip4.uli.spi
+#define fl4_mh_type	u.ip4.uli.mht.type
+#define fl4_gre_key	u.ip4.uli.gre_key
+#define fl6_sport	u.ip6.uli.ports.sport
+#define fl6_dport	u.ip6.uli.ports.dport
+#define fl6_icmp_type	u.ip6.uli.icmpt.type
+#define fl6_icmp_code	u.ip6.uli.icmpt.code
+#define fl6_ipsec_spi	u.ip6.uli.spi
+#define fl6_mh_type	u.ip6.uli.mht.type
+#define fl6_gre_key	u.ip6.uli.gre_key
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 #define FLOW_DIR_IN	0
@@ -134,11 +141,4 @@ extern struct flow_cache_object *flow_cache_lookup(
 extern void flow_cache_flush(void);
 extern atomic_t flow_cache_genid;
 
-static inline int flow_cache_uli_match(const struct flowi *fl1,
-				       const struct flowi *fl2)
-{
-	return (fl1->flowi_proto == fl2->flowi_proto &&
-		!memcmp(&fl1->uli_u, &fl2->uli_u, sizeof(fl1->uli_u)));
-}
-
 #endif
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 663b550..d8d5419 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -25,9 +25,9 @@ __xfrm4_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 {
 	sel->daddr.a4 = fl->fl4_dst;
 	sel->saddr.a4 = fl->fl4_src;
-	sel->dport = xfrm_flowi_dport(fl, &fl->uli_u);
+	sel->dport = xfrm_flowi_dport(fl, &fl->u.ip4.uli);
 	sel->dport_mask = htons(0xffff);
-	sel->sport = xfrm_flowi_sport(fl, &fl->uli_u);
+	sel->sport = xfrm_flowi_sport(fl, &fl->u.ip4.uli);
 	sel->sport_mask = htons(0xffff);
 	sel->family = AF_INET;
 	sel->prefixlen_d = 32;
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 5038e6b..e1767ae 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -241,10 +241,10 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 	sel.prefixlen_s = 128;
 	sel.family = AF_INET6;
 	sel.proto = fl->flowi_proto;
-	sel.dport = xfrm_flowi_dport(fl, &fl->uli_u);
+	sel.dport = xfrm_flowi_dport(fl, &fl->u.ip6.uli);
 	if (sel.dport)
 		sel.dport_mask = htons(~0);
-	sel.sport = xfrm_flowi_sport(fl, &fl->uli_u);
+	sel.sport = xfrm_flowi_sport(fl, &fl->u.ip6.uli);
 	if (sel.sport)
 		sel.sport_mask = htons(~0);
 	sel.ifindex = fl->flowi_oif;
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 71277ce..b456533 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -26,9 +26,9 @@ __xfrm6_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 	 * to current session. */
 	ipv6_addr_copy((struct in6_addr *)&sel->daddr, &fl->fl6_dst);
 	ipv6_addr_copy((struct in6_addr *)&sel->saddr, &fl->fl6_src);
-	sel->dport = xfrm_flowi_dport(fl, &fl->uli_u);
+	sel->dport = xfrm_flowi_dport(fl, &fl->u.ip6.uli);
 	sel->dport_mask = htons(0xffff);
-	sel->sport = xfrm_flowi_sport(fl, &fl->uli_u);
+	sel->sport = xfrm_flowi_sport(fl, &fl->u.ip6.uli);
 	sel->sport_mask = htons(0xffff);
 	sel->family = AF_INET6;
 	sel->prefixlen_d = 128;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d54b6e7..2ecd18a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -61,8 +61,8 @@ __xfrm4_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
 	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl, &fl->uli_u) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl, &fl->uli_u) ^ sel->sport) & sel->sport_mask) &&
+		!((xfrm_flowi_dport(fl, &fl->u.ip4.uli) ^ sel->dport) & sel->dport_mask) &&
+		!((xfrm_flowi_sport(fl, &fl->u.ip4.uli) ^ sel->sport) & sel->sport_mask) &&
 		(fl->flowi_proto == sel->proto || !sel->proto) &&
 		(fl->flowi_oif == sel->ifindex || !sel->ifindex);
 }
@@ -72,8 +72,8 @@ __xfrm6_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 {
 	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl, &fl->uli_u) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl, &fl->uli_u) ^ sel->sport) & sel->sport_mask) &&
+		!((xfrm_flowi_dport(fl, &fl->u.ip6.uli) ^ sel->dport) & sel->dport_mask) &&
+		!((xfrm_flowi_sport(fl, &fl->u.ip6.uli) ^ sel->sport) & sel->sport_mask) &&
 		(fl->flowi_proto == sel->proto || !sel->proto) &&
 		(fl->flowi_oif == sel->ifindex || !sel->ifindex);
 }
-- 
1.7.4.1

