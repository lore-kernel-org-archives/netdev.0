From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next v2 5/5] ipv6: Compute multipath hash for forwarded ICMP errors from offending packet
Date: Fri, 28 Oct 2016 14:32:35 +0200
Message-ID: <1477657955-5157-6-git-send-email-jkbs@redhat.com>
References: <1477657955-5157-1-git-send-email-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35415 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760007AbcJ1Mco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 08:32:44 -0400
Received: by mail-wm0-f44.google.com with SMTP id e69so97908438wmg.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 05:32:43 -0700 (PDT)
In-Reply-To: <1477657955-5157-1-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same as for the transmit path, let's do our best to ensure that received
ICMP errors that may be subject to forwarding will be routed the same
path as flow that triggered the error, if it was going in the opposite
direction.

v1 -> v2:
 - style change, put as many arguments as possible on the first line of
   a function call, and align consecutive lines to the first argument,
   pointed out by David Miller

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1184c2b..269e30d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1150,6 +1150,30 @@ struct dst_entry *ip6_route_input_lookup(struct net *net,
 }
 EXPORT_SYMBOL_GPL(ip6_route_input_lookup);
 
+static u32 ip6_multipath_icmp_hash(const struct sk_buff *skb)
+{
+	const struct icmp6hdr *icmph = icmp6_hdr(skb);
+	const struct ipv6hdr *inner_iph;
+	struct ipv6hdr _inner_iph;
+
+	if (icmph->icmp6_type != ICMPV6_DEST_UNREACH &&
+	    icmph->icmp6_type != ICMPV6_PKT_TOOBIG &&
+	    icmph->icmp6_type != ICMPV6_TIME_EXCEED &&
+	    icmph->icmp6_type != ICMPV6_PARAMPROB)
+		goto standard_hash;
+
+	inner_iph = skb_header_pointer(skb,
+				       skb_transport_offset(skb) + sizeof(*icmph),
+				       sizeof(_inner_iph), &_inner_iph);
+	if (!inner_iph)
+		goto standard_hash;
+
+	return icmpv6_multipath_hash(inner_iph);
+
+standard_hash:
+	return 0; /* compute it later, if needed */
+}
+
 void ip6_route_input(struct sk_buff *skb)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
@@ -1168,6 +1192,8 @@ void ip6_route_input(struct sk_buff *skb)
 	tun_info = skb_tunnel_info(skb);
 	if (tun_info && !(tun_info->mode & IP_TUNNEL_INFO_TX))
 		fl6.flowi6_tun_key.tun_id = tun_info->key.tun_id;
+	if (unlikely(fl6.flowi6_proto == IPPROTO_ICMPV6))
+		fl6.mp_hash = ip6_multipath_icmp_hash(skb);
 	skb_dst_drop(skb);
 	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
 }
-- 
2.7.4
