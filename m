From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 05/13] net/dst: Add dst port to dst_metadata utility functions
Date: Mon,  7 Nov 2016 15:14:40 +0200
Message-ID: <1478524488-1377-6-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39575 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932329AbcKGNPM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:12 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Add dst port parameter to __ip_tun_set_dst and __ipv6_tun_set_dst
utility functions.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/dst_metadata.h | 10 ++++++----
 net/sched/act_tunnel_key.c |  4 ++--
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 6965c8f..701fc81 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -115,6 +115,7 @@ static inline struct ip_tunnel_info *skb_tunnel_info_unclone(struct sk_buff *skb
 static inline struct metadata_dst *__ip_tun_set_dst(__be32 saddr,
 						    __be32 daddr,
 						    __u8 tos, __u8 ttl,
+						    __be16 tp_dst,
 						    __be16 flags,
 						    __be64 tunnel_id,
 						    int md_size)
@@ -127,7 +128,7 @@ static inline struct metadata_dst *__ip_tun_set_dst(__be32 saddr,
 
 	ip_tunnel_key_init(&tun_dst->u.tun_info.key,
 			   saddr, daddr, tos, ttl,
-			   0, 0, 0, tunnel_id, flags);
+			   0, 0, tp_dst, tunnel_id, flags);
 	return tun_dst;
 }
 
@@ -139,12 +140,13 @@ static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
 	const struct iphdr *iph = ip_hdr(skb);
 
 	return __ip_tun_set_dst(iph->saddr, iph->daddr, iph->tos, iph->ttl,
-				flags, tunnel_id, md_size);
+				0, flags, tunnel_id, md_size);
 }
 
 static inline struct metadata_dst *__ipv6_tun_set_dst(const struct in6_addr *saddr,
 						      const struct in6_addr *daddr,
 						      __u8 tos, __u8 ttl,
+						      __be16 tp_dst,
 						      __be32 label,
 						      __be16 flags,
 						      __be64 tunnel_id,
@@ -162,7 +164,7 @@ static inline struct metadata_dst *__ipv6_tun_set_dst(const struct in6_addr *sad
 	info->key.tun_flags = flags;
 	info->key.tun_id = tunnel_id;
 	info->key.tp_src = 0;
-	info->key.tp_dst = 0;
+	info->key.tp_dst = tp_dst;
 
 	info->key.u.ipv6.src = *saddr;
 	info->key.u.ipv6.dst = *daddr;
@@ -183,7 +185,7 @@ static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
 
 	return __ipv6_tun_set_dst(&ip6h->saddr, &ip6h->daddr,
 				  ipv6_get_dsfield(ip6h), ip6h->hop_limit,
-				  ip6_flowlabel(ip6h), flags, tunnel_id,
+				  0, ip6_flowlabel(ip6h), flags, tunnel_id,
 				  md_size);
 }
 #endif /* __NET_DST_METADATA_H */
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index cab1fd5..bd2f63e 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -119,7 +119,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 			daddr = nla_get_in_addr(tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]);
 
 			metadata = __ip_tun_set_dst(saddr, daddr, 0, 0,
-						    TUNNEL_KEY, key_id, 0);
+						    0, TUNNEL_KEY, key_id, 0);
 		} else if (tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC] &&
 			   tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]) {
 			struct in6_addr saddr;
@@ -129,7 +129,7 @@ static int tunnel_key_init(struct net *net, struct nlattr *nla,
 			daddr = nla_get_in6_addr(tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]);
 
 			metadata = __ipv6_tun_set_dst(&saddr, &daddr, 0, 0, 0,
-						      TUNNEL_KEY, key_id, 0);
+						      0, TUNNEL_KEY, key_id, 0);
 		}
 
 		if (!metadata) {
-- 
2.7.4
