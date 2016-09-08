From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V7 2/4] net/dst: Utility functions to build dst_metadata without supplying an skb
Date: Thu,  8 Sep 2016 16:23:46 +0300
Message-ID: <1473341028-29368-3-git-send-email-hadarh@mellanox.com>
References: <1473341028-29368-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60052 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S941339AbcIHNYL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 09:24:11 -0400
In-Reply-To: <1473341028-29368-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>

Extract __ip_tun_set_dst() and __ipv6_tun_set_dst() out of
ip_tun_rx_dst() and ipv6_tun_rx_dst(), to be used without supplying an
skb.

Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 include/net/dst_metadata.h | 52 ++++++++++++++++++++++++++++++++++------------
 1 file changed, 39 insertions(+), 13 deletions(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 5db9f59..6965c8f 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -112,12 +112,13 @@ static inline struct ip_tunnel_info *skb_tunnel_info_unclone(struct sk_buff *skb
 	return &dst->u.tun_info;
 }
 
-static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
-						 __be16 flags,
-						 __be64 tunnel_id,
-						 int md_size)
+static inline struct metadata_dst *__ip_tun_set_dst(__be32 saddr,
+						    __be32 daddr,
+						    __u8 tos, __u8 ttl,
+						    __be16 flags,
+						    __be64 tunnel_id,
+						    int md_size)
 {
-	const struct iphdr *iph = ip_hdr(skb);
 	struct metadata_dst *tun_dst;
 
 	tun_dst = tun_rx_dst(md_size);
@@ -125,17 +126,30 @@ static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
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
+	return __ip_tun_set_dst(iph->saddr, iph->daddr, iph->tos, iph->ttl,
+				flags, tunnel_id, md_size);
+}
+
+static inline struct metadata_dst *__ipv6_tun_set_dst(const struct in6_addr *saddr,
+						      const struct in6_addr *daddr,
+						      __u8 tos, __u8 ttl,
+						      __be32 label,
+						      __be16 flags,
+						      __be64 tunnel_id,
+						      int md_size)
+{
 	struct metadata_dst *tun_dst;
 	struct ip_tunnel_info *info;
 
@@ -150,14 +164,26 @@ static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
 	info->key.tp_src = 0;
 	info->key.tp_dst = 0;
 
-	info->key.u.ipv6.src = ip6h->saddr;
-	info->key.u.ipv6.dst = ip6h->daddr;
+	info->key.u.ipv6.src = *saddr;
+	info->key.u.ipv6.dst = *daddr;
 
-	info->key.tos = ipv6_get_dsfield(ip6h);
-	info->key.ttl = ip6h->hop_limit;
-	info->key.label = ip6_flowlabel(ip6h);
+	info->key.tos = tos;
+	info->key.ttl = ttl;
+	info->key.label = label;
 
 	return tun_dst;
 }
 
+static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
+						   __be16 flags,
+						   __be64 tunnel_id,
+						   int md_size)
+{
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
+
+	return __ipv6_tun_set_dst(&ip6h->saddr, &ip6h->daddr,
+				  ipv6_get_dsfield(ip6h), ip6h->hop_limit,
+				  ip6_flowlabel(ip6h), flags, tunnel_id,
+				  md_size);
+}
 #endif /* __NET_DST_METADATA_H */
-- 
1.8.3.1
