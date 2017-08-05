From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v2 5/5] ipv6: sr: implement several seg6local actions
Date: Sat, 5 Aug 2017 12:39:48 +0200
Message-ID: <20170805103948.21549-1-david.lebrun@uclouvain.be>
References: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:47457 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751348AbdHEKjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 06:39:44 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id 92EBB67DBFA
        for <netdev@vger.kernel.org>; Sat,  5 Aug 2017 12:39:34 +0200 (CEST)
In-Reply-To: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the following seg6local actions.

- SEG6_LOCAL_ACTION_END: regular SRH processing. The DA of the packet
  is updated to the next segment and forwarded accordingly.

- SEG6_LOCAL_ACTION_END_X: same as above, except that the packet is
  forwarded to the specified IPv6 next-hop.

- SEG6_LOCAL_ACTION_END_DX6: decapsulate the packet and forward to
  inner IPv6 packet to the specified IPv6 next-hop.

- SEG6_LOCAL_ACTION_END_B6: insert the specified SRH directly after
  the IPv6 header of the packet.

- SEG6_LOCAL_ACTION_END_B6_ENCAP: encapsulate the packet within
  an outer IPv6 header, containing the specified SRH.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6_local.c | 271 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 271 insertions(+)

diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index ab1fc1b..147680e 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -58,11 +58,282 @@ static struct seg6_local_lwt *seg6_local_lwtunnel(struct lwtunnel_state *lwt)
 	return (struct seg6_local_lwt *)lwt->data;
 }
 
+static struct ipv6_sr_hdr *get_srh(struct sk_buff *skb)
+{
+	struct ipv6_sr_hdr *srh;
+	struct ipv6hdr *hdr;
+	int len;
+
+	hdr = ipv6_hdr(skb);
+	if (hdr->nexthdr != IPPROTO_ROUTING)
+		return NULL;
+
+	srh = (struct ipv6_sr_hdr *)(hdr + 1);
+	len = (srh->hdrlen + 1) << 3;
+
+	if (!pskb_may_pull(skb, sizeof(*hdr) + len))
+		return NULL;
+
+	if (!seg6_validate_srh(srh, len))
+		return NULL;
+
+	return srh;
+}
+
+static struct ipv6_sr_hdr *get_and_validate_srh(struct sk_buff *skb)
+{
+	struct ipv6_sr_hdr *srh;
+
+	srh = get_srh(skb);
+	if (!srh)
+		return NULL;
+
+	if (srh->segments_left == 0)
+		return NULL;
+
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	if (!seg6_hmac_validate_skb(skb))
+		return NULL;
+#endif
+
+	return srh;
+}
+
+/* regular endpoint function */
+static int input_action_end(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	struct ipv6_sr_hdr *srh;
+	struct in6_addr *addr;
+
+	srh = get_and_validate_srh(skb);
+	if (!srh)
+		goto drop;
+
+	srh->segments_left--;
+	addr = srh->segments + srh->segments_left;
+
+	ipv6_hdr(skb)->daddr = *addr;
+
+	skb_dst_drop(skb);
+	ip6_route_input(skb);
+
+	return dst_input(skb);
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+/* regular endpoint, and forward to specified nexthop */
+static int input_action_end_x(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	struct net *net = dev_net(skb->dev);
+	struct ipv6_sr_hdr *srh;
+	struct dst_entry *dst;
+	struct in6_addr *addr;
+	struct ipv6hdr *hdr;
+	struct flowi6 fl6;
+	int flags;
+
+	srh = get_and_validate_srh(skb);
+	if (!srh)
+		goto drop;
+
+	srh->segments_left--;
+	addr = srh->segments + srh->segments_left;
+
+	hdr = ipv6_hdr(skb);
+	hdr->daddr = *addr;
+
+	skb_dst_drop(skb);
+
+	fl6.flowi6_iif = skb->dev->ifindex;
+	fl6.daddr = slwt->nh6;
+	fl6.saddr = hdr->saddr;
+	fl6.flowlabel = ip6_flowinfo(hdr);
+	fl6.flowi6_mark = skb->mark;
+	fl6.flowi6_proto = hdr->nexthdr;
+
+	flags = RT6_LOOKUP_F_HAS_SADDR | RT6_LOOKUP_F_IFACE |
+		RT6_LOOKUP_F_REACHABLE;
+
+	dst = ip6_route_input_lookup(net, skb->dev, &fl6, flags);
+	if (dst->dev->flags & IFF_LOOPBACK)
+		goto drop;
+
+	skb_dst_set(skb, dst);
+
+	return dst_input(skb);
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+/* decapsulate and forward to specified nexthop */
+static int input_action_end_dx6(struct sk_buff *skb,
+				struct seg6_local_lwt *slwt)
+{
+	struct net *net = dev_net(skb->dev);
+	struct ipv6hdr *inner_hdr;
+	struct ipv6_sr_hdr *srh;
+	struct dst_entry *dst;
+	unsigned int off = 0;
+	struct flowi6 fl6;
+	bool use_nh;
+	int flags;
+
+	/* this function accepts IPv6 encapsulated packets, with either
+	 * an SRH with SL=0, or no SRH.
+	 */
+
+	srh = get_srh(skb);
+	if (srh && srh->segments_left > 0)
+		goto drop;
+
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	if (srh && !seg6_hmac_validate_skb(skb))
+		goto drop;
+#endif
+
+	if (ipv6_find_hdr(skb, &off, IPPROTO_IPV6, NULL, NULL) < 0)
+		goto drop;
+
+	if (!pskb_pull(skb, off))
+		goto drop;
+
+	skb_postpull_rcsum(skb, skb_network_header(skb), off);
+
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+	skb->encapsulation = 0;
+
+	inner_hdr = ipv6_hdr(skb);
+
+	/* The inner packet is not associated to any local interface,
+	 * so we do not call netif_rx().
+	 *
+	 * If slwt->nh6 is set to ::, then lookup the nexthop for the
+	 * inner packet's DA. Otherwise, use the specified nexthop.
+	 */
+
+	use_nh = !ipv6_addr_any(&slwt->nh6);
+
+	skb_dst_drop(skb);
+
+	fl6.flowi6_iif = skb->dev->ifindex;
+	fl6.daddr = use_nh ? slwt->nh6 : inner_hdr->daddr;
+	fl6.saddr = inner_hdr->saddr;
+	fl6.flowlabel = ip6_flowinfo(inner_hdr);
+	fl6.flowi6_mark = skb->mark;
+	fl6.flowi6_proto = inner_hdr->nexthdr;
+
+	flags = RT6_LOOKUP_F_HAS_SADDR | RT6_LOOKUP_F_REACHABLE;
+	if (use_nh)
+		flags |= RT6_LOOKUP_F_IFACE;
+
+	dst = ip6_route_input_lookup(net, skb->dev, &fl6, flags);
+	if (dst->dev->flags & IFF_LOOPBACK)
+		goto drop;
+
+	skb_dst_set(skb, dst);
+
+	return dst_input(skb);
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+/* push an SRH on top of the current one */
+static int input_action_end_b6(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	struct ipv6_sr_hdr *srh;
+	int err = -EINVAL;
+
+	srh = get_and_validate_srh(skb);
+	if (!srh)
+		goto drop;
+
+	err = seg6_do_srh_inline(skb, slwt->srh);
+	if (err)
+		goto drop;
+
+	ipv6_hdr(skb)->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
+	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
+
+	skb_dst_drop(skb);
+	ip6_route_input(skb);
+
+	return dst_input(skb);
+
+drop:
+	kfree_skb(skb);
+	return err;
+}
+
+/* encapsulate within an outer IPv6 header and a specified SRH */
+static int input_action_end_b6_encap(struct sk_buff *skb,
+				     struct seg6_local_lwt *slwt)
+{
+	struct ipv6_sr_hdr *srh;
+	struct in6_addr *addr;
+	int err = -EINVAL;
+
+	srh = get_and_validate_srh(skb);
+	if (!srh)
+		goto drop;
+
+	srh->segments_left--;
+	addr = srh->segments + srh->segments_left;
+	ipv6_hdr(skb)->daddr = *addr;
+
+	skb_reset_inner_headers(skb);
+	skb->encapsulation = 1;
+
+	err = seg6_do_srh_encap(skb, slwt->srh);
+	if (err)
+		goto drop;
+
+	ipv6_hdr(skb)->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
+	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
+
+	skb_dst_drop(skb);
+	ip6_route_input(skb);
+
+	return dst_input(skb);
+
+drop:
+	kfree_skb(skb);
+	return err;
+}
+
 static struct seg6_action_desc seg6_action_table[] = {
 	{
 		.action		= SEG6_LOCAL_ACTION_END,
 		.attrs		= 0,
+		.input		= input_action_end,
+	},
+	{
+		.action		= SEG6_LOCAL_ACTION_END_X,
+		.attrs		= (1 << SEG6_LOCAL_NH6),
+		.input		= input_action_end_x,
 	},
+	{
+		.action		= SEG6_LOCAL_ACTION_END_DX6,
+		.attrs		= (1 << SEG6_LOCAL_NH6),
+		.input		= input_action_end_dx6,
+	},
+	{
+		.action		= SEG6_LOCAL_ACTION_END_B6,
+		.attrs		= (1 << SEG6_LOCAL_SRH),
+		.input		= input_action_end_b6,
+	},
+	{
+		.action		= SEG6_LOCAL_ACTION_END_B6_ENCAP,
+		.attrs		= (1 << SEG6_LOCAL_SRH),
+		.input		= input_action_end_b6_encap,
+		.static_headroom	= sizeof(struct ipv6hdr),
+	}
 };
 
 static struct seg6_action_desc *__get_action_desc(int action)
-- 
2.10.2
