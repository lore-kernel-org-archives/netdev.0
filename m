From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V2 2/4] net/dst: Utility functions to build dst_metadata without supplying an skb
Date: Wed, 24 Aug 2016 15:27:08 +0300
Message-ID: <20160824122710.30356-3-amir@vadai.me>
References: <20160824122710.30356-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34052 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754342AbcHXMnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 08:43:32 -0400
Received: by mail-wm0-f65.google.com with SMTP id q128so2494311wma.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 05:42:59 -0700 (PDT)
In-Reply-To: <20160824122710.30356-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extract _ip_tun_rx_dst() and _ipv6_tun_rx_dst() out of ip_tun_rx_dst()
and ipv6_tun_rx_dst(), to be used without supplying an skb.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/net/dst_metadata.h | 45 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 32 insertions(+), 13 deletions(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 5db9f5910428..892b3b69fb8d 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -112,12 +112,10 @@ static inline struct ip_tunnel_info *skb_tunnel_info_unclone(struct sk_buff *skb
 	return &dst->u.tun_info;
 }
 
-static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
-						 __be16 flags,
-						 __be64 tunnel_id,
-						 int md_size)
+static inline struct metadata_dst *
+_ip_tun_rx_dst(__be32 saddr, __be32 daddr, __u8 tos, __u8 ttl,
+	       __be16 flags, __be64 tunnel_id, int md_size)
 {
-	const struct iphdr *iph = ip_hdr(skb);
 	struct metadata_dst *tun_dst;
 
 	tun_dst = tun_rx_dst(md_size);
@@ -125,17 +123,27 @@ static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
 		return NULL;
 
 	ip_tunnel_key_init(&tun_dst->u.tun_info.key,
-			   iph->saddr, iph->daddr, iph->tos, iph->ttl,
+			   saddr, daddr, tos, ttl,
 			   0, 0, 0, tunnel_id, flags);
 	return tun_dst;
 }
 
-static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
+static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
 						 __be16 flags,
 						 __be64 tunnel_id,
 						 int md_size)
 {
-	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	const struct iphdr *iph = ip_hdr(skb);
+
+	return _ip_tun_rx_dst(iph->saddr, iph->daddr, iph->tos, iph->ttl,
+			      flags, tunnel_id, md_size);
+}
+
+static inline struct metadata_dst *
+_ipv6_tun_rx_dst(struct in6_addr saddr, struct in6_addr daddr,
+		 __u8 tos, __u8 ttl, __be32 label,
+		 __be16 flags, __be64 tunnel_id, int md_size)
+{
 	struct metadata_dst *tun_dst;
 	struct ip_tunnel_info *info;
 
@@ -150,14 +158,25 @@ static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
 	info->key.tp_src = 0;
 	info->key.tp_dst = 0;
 
-	info->key.u.ipv6.src = ip6h->saddr;
-	info->key.u.ipv6.dst = ip6h->daddr;
+	info->key.u.ipv6.src = saddr;
+	info->key.u.ipv6.dst = daddr;
 
-	info->key.tos = ipv6_get_dsfield(ip6h);
-	info->key.ttl = ip6h->hop_limit;
-	info->key.label = ip6_flowlabel(ip6h);
+	info->key.tos = tos;
+	info->key.ttl = ttl;
+	info->key.label = label;
 
 	return tun_dst;
 }
 
+static inline struct metadata_dst *
+ipv6_tun_rx_dst(struct sk_buff *skb, __be16 flags, __be64 tunnel_id,
+		int md_size)
+{
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
+
+	return _ipv6_tun_rx_dst(ip6h->saddr, ip6h->daddr,
+				ipv6_get_dsfield(ip6h), ip6h->hop_limit,
+				ip6_flowlabel(ip6h), flags, tunnel_id,
+				md_size);
+}
 #endif /* __NET_DST_METADATA_H */
-- 
2.9.0
