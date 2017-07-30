From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [RFC PATCH net-next 5/5] ipv6: sr: implement several seg6local actions
Date: Sun, 30 Jul 2017 18:16:09 +0200
Message-ID: <20170730161609.30095-1-david.lebrun@uclouvain.be>
References: <20170730161436.29967-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40930 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754171AbdG3QZ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 12:25:56 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id EB55B67DBBB
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 18:16:00 +0200 (CEST)
In-Reply-To: <20170730161436.29967-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the following seg6local actions.

- SEG6_LOCAL_ACTION_END: regular SRH processing. The DA of the packet
  is updated to the next segment and forwarded accordingly.

- SEG6_LOCAL_ACTION_END_X: same as above, except that the packet is
  forwarded to the specified IPv6 next-hop.

- SEG6_LOCAL_ACTION_END_B6: insert the specified SRH directly after
  the IPv6 header of the packet.

- SEG6_LOCAL_ACTION_END_B6_ENCAP: encapsulate the packet within
  an outer IPv6 header, containing the specified SRH.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6_local.c | 176 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 176 insertions(+)

diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index ab1fc1b..a7b346b 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -58,11 +58,187 @@ static struct seg6_local_lwt *seg6_local_lwtunnel(struct lwtunnel_state *lwt)
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
+static int input_action_end_x(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	struct net *net = dev_net(skb->dev);
+	struct ipv6_sr_hdr *srh;
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
+	flags = RT6_LOOKUP_F_HAS_SADDR | RT6_LOOKUP_F_REACHABLE;
+	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
+
+	return dst_input(skb);
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
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
+static int input_action_end_b6_encap(struct sk_buff *skb,
+				     struct seg6_local_lwt *slwt)
+{
+	struct ipv6_sr_hdr *srh;
+	int err = -EINVAL;
+
+	srh = get_and_validate_srh(skb);
+	if (!srh)
+		goto drop;
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
