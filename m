From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next 5/5] ipv6: sr: implement additional seg6local actions
Date: Wed, 23 Aug 2017 17:33:36 +0200
Message-ID: <20170823153336.12153-1-david.lebrun@uclouvain.be>
References: <20170823153203.11951-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33843 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932074AbdHWPdR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 11:33:17 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp5.sgsi.ucl.ac.be (Postfix) with ESMTPS id 5478F67DD82
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 17:33:08 +0200 (CEST)
In-Reply-To: <20170823153203.11951-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the following seg6local actions.

- SEG6_LOCAL_ACTION_END_T: regular SRH processing and forward to the
  next-hop looked up in the specified routing table.

- SEG6_LOCAL_ACTION_END_DX2: decapsulate an L2 frame and forward it to
  the specified network interface.

- SEG6_LOCAL_ACTION_END_DX4: decapsulate an IPv4 packet and forward it,
  possibly to the specified next-hop.

- SEG6_LOCAL_ACTION_END_DT6: decapsulate an IPv6 packet and forward it
  to the next-hop looked up in the specified routing table.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6_local.c | 147 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 147 insertions(+)

diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index 26db4d3e..9c1a885 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -30,6 +30,7 @@
 #ifdef CONFIG_IPV6_SEG6_HMAC
 #include <net/seg6_hmac.h>
 #endif
+#include <linux/etherdevice.h>
 
 struct seg6_local_lwt;
 
@@ -226,6 +227,82 @@ static int input_action_end_x(struct sk_buff *skb, struct seg6_local_lwt *slwt)
 	return -EINVAL;
 }
 
+static int input_action_end_t(struct sk_buff *skb, struct seg6_local_lwt *slwt)
+{
+	struct ipv6_sr_hdr *srh;
+
+	srh = get_and_validate_srh(skb);
+	if (!srh)
+		goto drop;
+
+	advance_nextseg(srh, &ipv6_hdr(skb)->daddr);
+
+	lookup_nexthop(skb, NULL, slwt->table);
+
+	return dst_input(skb);
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+/* decapsulate and forward inner L2 frame on specified interface */
+static int input_action_end_dx2(struct sk_buff *skb,
+				struct seg6_local_lwt *slwt)
+{
+	struct net *net = dev_net(skb->dev);
+	struct net_device *odev;
+	struct ethhdr *eth;
+
+	if (!decap_and_validate(skb, NEXTHDR_NONE))
+		goto drop;
+
+	if (!pskb_may_pull(skb, ETH_HLEN))
+		goto drop;
+
+	skb_reset_mac_header(skb);
+	eth = (struct ethhdr *)skb->data;
+
+	/* To determine the frame's protocol, we assume it is 802.3. This avoids
+	 * a call to eth_type_trans(), which is not really relevant for our
+	 * use case.
+	 */
+	if (!eth_proto_is_802_3(eth->h_proto))
+		goto drop;
+
+	odev = dev_get_by_index_rcu(net, slwt->oif);
+	if (!odev)
+		goto drop;
+
+	/* As we accept Ethernet frames, make sure the egress device is of
+	 * the correct type.
+	 */
+	if (odev->type != ARPHRD_ETHER)
+		goto drop;
+
+	if (!(odev->flags & IFF_UP) || !netif_carrier_ok(odev))
+		goto drop;
+
+	skb_orphan(skb);
+
+	if (skb_warn_if_lro(skb))
+		goto drop;
+
+	skb_forward_csum(skb);
+
+	if (skb->len - ETH_HLEN > odev->mtu)
+		goto drop;
+
+	skb->dev = odev;
+	skb->protocol = eth->h_proto;
+
+	return dev_queue_xmit(skb);
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
 /* decapsulate and forward to specified nexthop */
 static int input_action_end_dx6(struct sk_buff *skb,
 				struct seg6_local_lwt *slwt)
@@ -260,6 +337,56 @@ static int input_action_end_dx6(struct sk_buff *skb,
 	return -EINVAL;
 }
 
+static int input_action_end_dx4(struct sk_buff *skb,
+				struct seg6_local_lwt *slwt)
+{
+	struct iphdr *iph;
+	__be32 nhaddr;
+	int err;
+
+	if (!decap_and_validate(skb, IPPROTO_IPIP))
+		goto drop;
+
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+		goto drop;
+
+	skb->protocol = htons(ETH_P_IP);
+
+	iph = ip_hdr(skb);
+
+	nhaddr = slwt->nh4.s_addr ?: iph->daddr;
+
+	skb_dst_drop(skb);
+
+	err = ip_route_input(skb, nhaddr, iph->saddr, 0, skb->dev);
+	if (err)
+		goto drop;
+
+	return dst_input(skb);
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+static int input_action_end_dt6(struct sk_buff *skb,
+				struct seg6_local_lwt *slwt)
+{
+	if (!decap_and_validate(skb, IPPROTO_IPV6))
+		goto drop;
+
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+		goto drop;
+
+	lookup_nexthop(skb, NULL, slwt->table);
+
+	return dst_input(skb);
+
+drop:
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
 /* push an SRH on top of the current one */
 static int input_action_end_b6(struct sk_buff *skb, struct seg6_local_lwt *slwt)
 {
@@ -330,11 +457,31 @@ static struct seg6_action_desc seg6_action_table[] = {
 		.input		= input_action_end_x,
 	},
 	{
+		.action		= SEG6_LOCAL_ACTION_END_T,
+		.attrs		= (1 << SEG6_LOCAL_TABLE),
+		.input		= input_action_end_t,
+	},
+	{
+		.action		= SEG6_LOCAL_ACTION_END_DX2,
+		.attrs		= (1 << SEG6_LOCAL_OIF),
+		.input		= input_action_end_dx2,
+	},
+	{
 		.action		= SEG6_LOCAL_ACTION_END_DX6,
 		.attrs		= (1 << SEG6_LOCAL_NH6),
 		.input		= input_action_end_dx6,
 	},
 	{
+		.action		= SEG6_LOCAL_ACTION_END_DX4,
+		.attrs		= (1 << SEG6_LOCAL_NH4),
+		.input		= input_action_end_dx4,
+	},
+	{
+		.action		= SEG6_LOCAL_ACTION_END_DT6,
+		.attrs		= (1 << SEG6_LOCAL_TABLE),
+		.input		= input_action_end_dt6,
+	},
+	{
 		.action		= SEG6_LOCAL_ACTION_END_B6,
 		.attrs		= (1 << SEG6_LOCAL_SRH),
 		.input		= input_action_end_b6,
-- 
2.10.2
