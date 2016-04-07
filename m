From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 07/11] GENEVE: Add option to mangle IP IDs on inner
 headers when using TSO
Date: Thu, 07 Apr 2016 18:32:37 -0400
Message-ID: <20160407223237.11142.33072.stgit@ahduyck-xeon-server>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34503 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932141AbcDGWcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:32:45 -0400
Received: by mail-pa0-f50.google.com with SMTP id fe3so62582789pab.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 15:32:40 -0700 (PDT)
In-Reply-To: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for a feature I am calling IP ID mangling.  It is
basically just another way of saying the IP IDs that are transmitted by the
tunnel may not match up with what would normally be expected.  Specifically
what will happen is in the case of TSO the IP IDs on the headers will be a
fixed value so a given TSO will repeat the same inner IP ID value gso_segs
number of times.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/geneve.c         |   24 ++++++++++++++++++++++--
 include/net/udp_tunnel.h     |    8 --------
 include/uapi/linux/if_link.h |    1 +
 3 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index bc168894bda3..6352223d80c3 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -80,6 +80,7 @@ struct geneve_dev {
 #define GENEVE_F_UDP_ZERO_CSUM_TX	BIT(0)
 #define GENEVE_F_UDP_ZERO_CSUM6_TX	BIT(1)
 #define GENEVE_F_UDP_ZERO_CSUM6_RX	BIT(2)
+#define GENEVE_F_TCP_FIXEDID		BIT(3)
 
 struct geneve_sock {
 	bool			collect_md;
@@ -702,9 +703,14 @@ static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 	int min_headroom;
 	int err;
 	bool udp_sum = !(flags & GENEVE_F_UDP_ZERO_CSUM_TX);
+	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 
 	skb_scrub_packet(skb, xnet);
 
+	if ((flags & GENEVE_F_TCP_FIXEDID) && skb_is_gso(skb) &&
+	    (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4))
+		type |= SKB_GSO_TCP_FIXEDID;
+
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr);
 	err = skb_cow_head(skb, min_headroom);
@@ -713,7 +719,7 @@ static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 		goto free_rt;
 	}
 
-	skb = udp_tunnel_handle_offloads(skb, udp_sum);
+	skb = iptunnel_handle_offloads(skb, type);
 	if (IS_ERR(skb)) {
 		err = PTR_ERR(skb);
 		goto free_rt;
@@ -739,9 +745,14 @@ static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 	int min_headroom;
 	int err;
 	bool udp_sum = !(flags & GENEVE_F_UDP_ZERO_CSUM6_TX);
+	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 
 	skb_scrub_packet(skb, xnet);
 
+	if ((flags & GENEVE_F_TCP_FIXEDID) && skb_is_gso(skb) &&
+	    (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4))
+		type |= SKB_GSO_TCP_FIXEDID;
+
 	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
 			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct ipv6hdr);
 	err = skb_cow_head(skb, min_headroom);
@@ -750,7 +761,7 @@ static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 		goto free_dst;
 	}
 
-	skb = udp_tunnel_handle_offloads(skb, udp_sum);
+	skb = iptunnel_handle_offloads(skb, type);
 	if (IS_ERR(skb)) {
 		err = PTR_ERR(skb);
 		goto free_dst;
@@ -1249,6 +1260,7 @@ static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
 	[IFLA_GENEVE_UDP_CSUM]		= { .type = NLA_U8 },
 	[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]	= { .type = NLA_U8 },
 	[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]	= { .type = NLA_U8 },
+	[IFLA_GENEVE_IPID_MANGLE]	= { .type = NLA_FLAG },
 };
 
 static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -1436,6 +1448,9 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
 	    nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
 		flags |= GENEVE_F_UDP_ZERO_CSUM6_RX;
 
+	if (data[IFLA_GENEVE_IPID_MANGLE])
+		flags |= GENEVE_F_TCP_FIXEDID;
+
 	return geneve_configure(net, dev, &remote, vni, ttl, tos, label,
 				dst_port, metadata, flags);
 }
@@ -1460,6 +1475,7 @@ static size_t geneve_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u8)) + /* IFLA_GENEVE_UDP_CSUM */
 		nla_total_size(sizeof(__u8)) + /* IFLA_GENEVE_UDP_ZERO_CSUM6_TX */
 		nla_total_size(sizeof(__u8)) + /* IFLA_GENEVE_UDP_ZERO_CSUM6_RX */
+		nla_total_size(0) +	 /* IFLA_GENEVE_IPID_MANGLE */
 		0;
 }
 
@@ -1505,6 +1521,10 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 		       !!(geneve->flags & GENEVE_F_UDP_ZERO_CSUM6_RX)))
 		goto nla_put_failure;
 
+	if ((geneve->flags & GENEVE_F_TCP_FIXEDID) &&
+	    nla_put_flag(skb, IFLA_GENEVE_IPID_MANGLE))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index b83114077cee..c44d04259665 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -98,14 +98,6 @@ struct metadata_dst *udp_tun_rx_dst(struct sk_buff *skb, unsigned short family,
 				    __be16 flags, __be64 tunnel_id,
 				    int md_size);
 
-static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
-							 bool udp_csum)
-{
-	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
-
-	return iptunnel_handle_offloads(skb, type);
-}
-
 static inline void udp_tunnel_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	struct udphdr *uh;
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a3bc3f2a63d3..38acf49c818b 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -513,6 +513,7 @@ enum {
 	IFLA_GENEVE_UDP_ZERO_CSUM6_TX,
 	IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
 	IFLA_GENEVE_LABEL,
+	IFLA_GENEVE_IPID_MANGLE,
 	__IFLA_GENEVE_MAX
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
