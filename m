From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next 4/5] ipv6: sr: add helper functions for seg6local
Date: Wed, 23 Aug 2017 17:32:02 +0200
Message-ID: <20170823153203.11951-5-david.lebrun@uclouvain.be>
References: <20170823153203.11951-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:36504 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754150AbdHWPbx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 11:31:53 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id F1A7B67DE63
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 17:31:43 +0200 (CEST)
In-Reply-To: <20170823153203.11951-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds three helper functions to be used with the seg6local packet
processing actions.

The decap_and_validate() function will be used by the End.D* actions, that
decapsulate an SR-enabled packet.

The advance_nextseg() function applies the fundamental operations to update
an SRH for the next segment.

The lookup_nexthop() function helps select the next-hop for the processed
SR packets. It supports an optional next-hop address to route the packet
specifically through it, and an optional routing table to use.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/Kconfig      |   1 +
 net/ipv6/seg6_local.c | 189 ++++++++++++++++++++++++++------------------------
 2 files changed, 101 insertions(+), 89 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 0d72239..ea71e4b 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -308,6 +308,7 @@ config IPV6_SEG6_LWTUNNEL
 	depends on IPV6
 	select LWTUNNEL
 	select DST_CACHE
+	select IPV6_MULTIPLE_TABLES
 	---help---
 	  Support for encapsulation of packets within an outer IPv6
 	  header and a Segment Routing Header using the lightweight
diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index c626325..26db4d3e 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -99,23 +99,105 @@ static struct ipv6_sr_hdr *get_and_validate_srh(struct sk_buff *skb)
 	return srh;
 }
 
+static bool decap_and_validate(struct sk_buff *skb, int proto)
+{
+	struct ipv6_sr_hdr *srh;
+	unsigned int off = 0;
+
+	srh = get_srh(skb);
+	if (srh && srh->segments_left > 0)
+		return false;
+
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	if (srh && !seg6_hmac_validate_skb(skb))
+		return false;
+#endif
+
+	if (ipv6_find_hdr(skb, &off, proto, NULL, NULL) < 0)
+		return false;
+
+	if (!pskb_pull(skb, off))
+		return false;
+
+	skb_postpull_rcsum(skb, skb_network_header(skb), off);
+
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+	skb->encapsulation = 0;
+
+	return true;
+}
+
+static void advance_nextseg(struct ipv6_sr_hdr *srh, struct in6_addr *daddr)
+{
+	struct in6_addr *addr;
+
+	srh->segments_left--;
+	addr = srh->segments + srh->segments_left;
+	*daddr = *addr;
+}
+
+static void lookup_nexthop(struct sk_buff *skb, struct in6_addr *nhaddr,
+			   u32 tbl_id)
+{
+	struct net *net = dev_net(skb->dev);
+	struct ipv6hdr *hdr = ipv6_hdr(skb);
+	int flags = RT6_LOOKUP_F_HAS_SADDR;
+	struct dst_entry *dst = NULL;
+	struct rt6_info *rt;
+	struct flowi6 fl6;
+
+	fl6.flowi6_iif = skb->dev->ifindex;
+	fl6.daddr = nhaddr ? *nhaddr : hdr->daddr;
+	fl6.saddr = hdr->saddr;
+	fl6.flowlabel = ip6_flowinfo(hdr);
+	fl6.flowi6_mark = skb->mark;
+	fl6.flowi6_proto = hdr->nexthdr;
+
+	if (nhaddr)
+		fl6.flowi6_flags = FLOWI_FLAG_KNOWN_NH;
+
+	if (!tbl_id) {
+		dst = ip6_route_input_lookup(net, skb->dev, &fl6, flags);
+	} else {
+		struct fib6_table *table;
+
+		table = fib6_get_table(net, tbl_id);
+		if (!table)
+			goto out;
+
+		rt = ip6_pol_route(net, table, 0, &fl6, flags);
+		dst = &rt->dst;
+	}
+
+	if (dst && dst->dev->flags & IFF_LOOPBACK && !dst->error) {
+		dst_release(dst);
+		dst = NULL;
+	}
+
+out:
+	if (!dst) {
+		rt = net->ipv6.ip6_blk_hole_entry;
+		dst = &rt->dst;
+		dst_hold(dst);
+	}
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst);
+}
+
 /* regular endpoint function */
 static int input_action_end(struct sk_buff *skb, struct seg6_local_lwt *slwt)
 {
 	struct ipv6_sr_hdr *srh;
-	struct in6_addr *addr;
 
 	srh = get_and_validate_srh(skb);
 	if (!srh)
 		goto drop;
 
-	srh->segments_left--;
-	addr = srh->segments + srh->segments_left;
-
-	ipv6_hdr(skb)->daddr = *addr;
+	advance_nextseg(srh, &ipv6_hdr(skb)->daddr);
 
-	skb_dst_drop(skb);
-	ip6_route_input(skb);
+	lookup_nexthop(skb, NULL, 0);
 
 	return dst_input(skb);
 
@@ -127,41 +209,15 @@ static int input_action_end(struct sk_buff *skb, struct seg6_local_lwt *slwt)
 /* regular endpoint, and forward to specified nexthop */
 static int input_action_end_x(struct sk_buff *skb, struct seg6_local_lwt *slwt)
 {
-	struct net *net = dev_net(skb->dev);
 	struct ipv6_sr_hdr *srh;
-	struct dst_entry *dst;
-	struct in6_addr *addr;
-	struct ipv6hdr *hdr;
-	struct flowi6 fl6;
-	int flags;
 
 	srh = get_and_validate_srh(skb);
 	if (!srh)
 		goto drop;
 
-	srh->segments_left--;
-	addr = srh->segments + srh->segments_left;
-
-	hdr = ipv6_hdr(skb);
-	hdr->daddr = *addr;
-
-	skb_dst_drop(skb);
-
-	fl6.flowi6_iif = skb->dev->ifindex;
-	fl6.daddr = slwt->nh6;
-	fl6.saddr = hdr->saddr;
-	fl6.flowlabel = ip6_flowinfo(hdr);
-	fl6.flowi6_mark = skb->mark;
-	fl6.flowi6_proto = hdr->nexthdr;
-
-	flags = RT6_LOOKUP_F_HAS_SADDR | RT6_LOOKUP_F_IFACE |
-		RT6_LOOKUP_F_REACHABLE;
+	advance_nextseg(srh, &ipv6_hdr(skb)->daddr);
 
-	dst = ip6_route_input_lookup(net, skb->dev, &fl6, flags);
-	if (dst->dev->flags & IFF_LOOPBACK)
-		goto drop;
-
-	skb_dst_set(skb, dst);
+	lookup_nexthop(skb, &slwt->nh6, 0);
 
 	return dst_input(skb);
 
@@ -174,42 +230,18 @@ static int input_action_end_x(struct sk_buff *skb, struct seg6_local_lwt *slwt)
 static int input_action_end_dx6(struct sk_buff *skb,
 				struct seg6_local_lwt *slwt)
 {
-	struct net *net = dev_net(skb->dev);
-	struct ipv6hdr *inner_hdr;
-	struct ipv6_sr_hdr *srh;
-	struct dst_entry *dst;
-	unsigned int off = 0;
-	struct flowi6 fl6;
-	bool use_nh;
-	int flags;
+	struct in6_addr *nhaddr = NULL;
 
 	/* this function accepts IPv6 encapsulated packets, with either
 	 * an SRH with SL=0, or no SRH.
 	 */
 
-	srh = get_srh(skb);
-	if (srh && srh->segments_left > 0)
-		goto drop;
-
-#ifdef CONFIG_IPV6_SEG6_HMAC
-	if (srh && !seg6_hmac_validate_skb(skb))
+	if (!decap_and_validate(skb, IPPROTO_IPV6))
 		goto drop;
-#endif
 
-	if (ipv6_find_hdr(skb, &off, IPPROTO_IPV6, NULL, NULL) < 0)
-		goto drop;
-
-	if (!pskb_pull(skb, off))
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto drop;
 
-	skb_postpull_rcsum(skb, skb_network_header(skb), off);
-
-	skb_reset_network_header(skb);
-	skb_reset_transport_header(skb);
-	skb->encapsulation = 0;
-
-	inner_hdr = ipv6_hdr(skb);
-
 	/* The inner packet is not associated to any local interface,
 	 * so we do not call netif_rx().
 	 *
@@ -217,26 +249,10 @@ static int input_action_end_dx6(struct sk_buff *skb,
 	 * inner packet's DA. Otherwise, use the specified nexthop.
 	 */
 
-	use_nh = !ipv6_addr_any(&slwt->nh6);
+	if (!ipv6_addr_any(&slwt->nh6))
+		nhaddr = &slwt->nh6;
 
-	skb_dst_drop(skb);
-
-	fl6.flowi6_iif = skb->dev->ifindex;
-	fl6.daddr = use_nh ? slwt->nh6 : inner_hdr->daddr;
-	fl6.saddr = inner_hdr->saddr;
-	fl6.flowlabel = ip6_flowinfo(inner_hdr);
-	fl6.flowi6_mark = skb->mark;
-	fl6.flowi6_proto = inner_hdr->nexthdr;
-
-	flags = RT6_LOOKUP_F_HAS_SADDR | RT6_LOOKUP_F_REACHABLE;
-	if (use_nh)
-		flags |= RT6_LOOKUP_F_IFACE;
-
-	dst = ip6_route_input_lookup(net, skb->dev, &fl6, flags);
-	if (dst->dev->flags & IFF_LOOPBACK)
-		goto drop;
-
-	skb_dst_set(skb, dst);
+	lookup_nexthop(skb, nhaddr, 0);
 
 	return dst_input(skb);
 drop:
@@ -261,8 +277,7 @@ static int input_action_end_b6(struct sk_buff *skb, struct seg6_local_lwt *slwt)
 	ipv6_hdr(skb)->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
 
-	skb_dst_drop(skb);
-	ip6_route_input(skb);
+	lookup_nexthop(skb, NULL, 0);
 
 	return dst_input(skb);
 
@@ -276,16 +291,13 @@ static int input_action_end_b6_encap(struct sk_buff *skb,
 				     struct seg6_local_lwt *slwt)
 {
 	struct ipv6_sr_hdr *srh;
-	struct in6_addr *addr;
 	int err = -EINVAL;
 
 	srh = get_and_validate_srh(skb);
 	if (!srh)
 		goto drop;
 
-	srh->segments_left--;
-	addr = srh->segments + srh->segments_left;
-	ipv6_hdr(skb)->daddr = *addr;
+	advance_nextseg(srh, &ipv6_hdr(skb)->daddr);
 
 	skb_reset_inner_headers(skb);
 	skb->encapsulation = 1;
@@ -297,8 +309,7 @@ static int input_action_end_b6_encap(struct sk_buff *skb,
 	ipv6_hdr(skb)->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
 
-	skb_dst_drop(skb);
-	ip6_route_input(skb);
+	lookup_nexthop(skb, NULL, 0);
 
 	return dst_input(skb);
 
-- 
2.10.2
