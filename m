From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next v3 2/4] ipv6: Compute multipath hash for ICMP errors from offending packet
Date: Wed, 23 Aug 2017 09:58:29 +0200
Message-ID: <20170823075831.27031-3-jkbs@redhat.com>
References: <20170823075831.27031-1-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37071 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753525AbdHWH6i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 03:58:38 -0400
Received: by mail-wm0-f53.google.com with SMTP id b189so9767770wmd.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 00:58:38 -0700 (PDT)
In-Reply-To: <20170823075831.27031-1-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When forwarding or sending out an ICMPv6 error, look at the embedded
packet that triggered the error and compute a flow hash over its
headers.

This let's us route the ICMP error together with the flow it belongs to
when multipath (ECMP) routing is in use, which in turn makes Path MTU
Discovery work in ECMP load-balanced or anycast setups (RFC 7690).

Granted, end-hosts behind the ECMP router (aka servers) need to reflect
the IPv6 Flow Label for PMTUD to work.

The code is organized to be in parallel with ipv4 stack:

  ip_multipath_l3_keys -> ip6_multipath_l3_keys
  fib_multipath_hash   -> rt6_multipath_hash

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 include/net/ip6_route.h |  1 +
 net/ipv6/icmp.c         |  1 +
 net/ipv6/route.c        | 50 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 52 insertions(+)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 907d39a..882bc3c 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -115,6 +115,7 @@ static inline int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
 
 struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 			    const struct in6_addr *saddr, int oif, int flags);
+u32 rt6_multipath_hash(const struct flowi6 *fl6, const struct sk_buff *skb);
 
 struct dst_entry *icmp6_dst_alloc(struct net_device *dev, struct flowi6 *fl6);
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 4f82830..dd7608c 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -519,6 +519,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	fl6.fl6_icmp_type = type;
 	fl6.fl6_icmp_code = code;
 	fl6.flowi6_uid = sock_net_uid(net, NULL);
+	fl6.mp_hash = rt6_multipath_hash(&fl6, skb);
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9b02064..6c4dd57 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1214,6 +1214,54 @@ struct dst_entry *ip6_route_input_lookup(struct net *net,
 }
 EXPORT_SYMBOL_GPL(ip6_route_input_lookup);
 
+static void ip6_multipath_l3_keys(const struct sk_buff *skb,
+				  struct flow_keys *keys)
+{
+	const struct ipv6hdr *outer_iph = ipv6_hdr(skb);
+	const struct ipv6hdr *key_iph = outer_iph;
+	const struct ipv6hdr *inner_iph;
+	const struct icmp6hdr *icmph;
+	struct ipv6hdr _inner_iph;
+
+	if (likely(outer_iph->nexthdr != IPPROTO_ICMPV6))
+		goto out;
+
+	icmph = icmp6_hdr(skb);
+	if (icmph->icmp6_type != ICMPV6_DEST_UNREACH &&
+	    icmph->icmp6_type != ICMPV6_PKT_TOOBIG &&
+	    icmph->icmp6_type != ICMPV6_TIME_EXCEED &&
+	    icmph->icmp6_type != ICMPV6_PARAMPROB)
+		goto out;
+
+	inner_iph = skb_header_pointer(skb,
+				       skb_transport_offset(skb) + sizeof(*icmph),
+				       sizeof(_inner_iph), &_inner_iph);
+	if (!inner_iph)
+		goto out;
+
+	key_iph = inner_iph;
+out:
+	memset(keys, 0, sizeof(*keys));
+	keys->control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
+	keys->addrs.v6addrs.src = key_iph->saddr;
+	keys->addrs.v6addrs.dst = key_iph->daddr;
+	keys->tags.flow_label = ip6_flowinfo(key_iph);
+	keys->basic.ip_proto = key_iph->nexthdr;
+}
+
+/* if skb is set it will be used and fl6 can be NULL */
+u32 rt6_multipath_hash(const struct flowi6 *fl6, const struct sk_buff *skb)
+{
+	struct flow_keys hash_keys;
+
+	if (skb) {
+		ip6_multipath_l3_keys(skb, &hash_keys);
+		return flow_hash_from_keys(&hash_keys);
+	}
+
+	return get_hash_from_flowi6(fl6);
+}
+
 void ip6_route_input(struct sk_buff *skb)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
@@ -1232,6 +1280,8 @@ void ip6_route_input(struct sk_buff *skb)
 	tun_info = skb_tunnel_info(skb);
 	if (tun_info && !(tun_info->mode & IP_TUNNEL_INFO_TX))
 		fl6.flowi6_tun_key.tun_id = tun_info->key.tun_id;
+	if (unlikely(fl6.flowi6_proto == IPPROTO_ICMPV6))
+		fl6.mp_hash = rt6_multipath_hash(&fl6, skb);
 	skb_dst_drop(skb);
 	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
 }
-- 
2.9.4
