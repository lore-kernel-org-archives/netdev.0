From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 3/4] ip_tunnels: introduce ip6_tunnel_key_init
Date: Thu,  1 Oct 2015 16:44:41 +0200
Message-ID: <bc6c2e24fd657871553a1b1ae8c999c8b9b151d8.1443710454.git.jbenc@redhat.com>
References: <cover.1443710454.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752966AbbJAOpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 10:45:16 -0400
In-Reply-To: <cover.1443710454.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already have ip_tunnel_key_init, this does the same for IPv6. Will be
used also by openvswitch in the next patch.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
New patch in v2 of the set.
---
 include/net/dst_metadata.h | 18 ++++++------------
 include/net/ip_tunnels.h   | 40 +++++++++++++++++++++++++++++++---------
 2 files changed, 37 insertions(+), 21 deletions(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index af9d5382f6cb..30e925aba1a4 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -85,23 +85,17 @@ static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
 {
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct metadata_dst *tun_dst;
-	struct ip_tunnel_info *info;
 
 	tun_dst = tun_rx_dst(md_size);
 	if (!tun_dst)
 		return NULL;
 
-	info = &tun_dst->u.tun_info;
-	info->mode = IP_TUNNEL_INFO_IPV6;
-	info->key.tun_flags = flags;
-	info->key.tun_id = tunnel_id;
-	info->key.tp_src = 0;
-	info->key.tp_dst = 0;
-
-	info->key.u.ipv6.src = ip6h->saddr;
-	info->key.u.ipv6.dst = ip6h->daddr;
-	info->key.tos = ipv6_get_dsfield(ip6h);
-	info->key.ttl = ip6h->hop_limit;
+	tun_dst->u.tun_info.mode = IP_TUNNEL_INFO_IPV6;
+	ip6_tunnel_key_init(&tun_dst->u.tun_info.key,
+			    &ip6h->saddr, &ip6h->daddr,
+			    ipv6_get_dsfield(ip6h), ip6h->hop_limit,
+			    0, 0, tunnel_id, flags);
+
 	return tun_dst;
 }
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index f6dafec9102c..087b2e24e5e0 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -179,17 +179,12 @@ int ip_tunnel_encap_add_ops(const struct ip_tunnel_encap_ops *op,
 int ip_tunnel_encap_del_ops(const struct ip_tunnel_encap_ops *op,
 			    unsigned int num);
 
-static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
-				      __be32 saddr, __be32 daddr,
-				      u8 tos, u8 ttl,
-				      __be16 tp_src, __be16 tp_dst,
-				      __be64 tun_id, __be16 tun_flags)
+static inline void __ip_tunnel_key_init(struct ip_tunnel_key *key,
+					u8 tos, u8 ttl,
+					__be16 tp_src, __be16 tp_dst,
+					__be64 tun_id, __be16 tun_flags)
 {
 	key->tun_id = tun_id;
-	key->u.ipv4.src = saddr;
-	key->u.ipv4.dst = daddr;
-	memset((unsigned char *)key + IP_TUNNEL_KEY_IPV4_PAD,
-	       0, IP_TUNNEL_KEY_IPV4_PAD_LEN);
 	key->tos = tos;
 	key->ttl = ttl;
 	key->tun_flags = tun_flags;
@@ -207,6 +202,33 @@ static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
 		       0, sizeof(*key) - IP_TUNNEL_KEY_SIZE);
 }
 
+static inline void ip_tunnel_key_init(struct ip_tunnel_key *key,
+				      __be32 saddr, __be32 daddr,
+				      u8 tos, u8 ttl,
+				      __be16 tp_src, __be16 tp_dst,
+				      __be64 tun_id, __be16 tun_flags)
+{
+	__ip_tunnel_key_init(key, tos, ttl, tp_src, tp_dst, tun_id,
+			     tun_flags);
+	key->u.ipv4.src = saddr;
+	key->u.ipv4.dst = daddr;
+	memset((unsigned char *)key + IP_TUNNEL_KEY_IPV4_PAD,
+	       0, IP_TUNNEL_KEY_IPV4_PAD_LEN);
+}
+
+static inline void ip6_tunnel_key_init(struct ip_tunnel_key *key,
+				       const struct in6_addr *saddr,
+				       const struct in6_addr *daddr,
+				       u8 tos, u8 ttl,
+				       __be16 tp_src, __be16 tp_dst,
+				       __be64 tun_id, __be16 tun_flags)
+{
+	__ip_tunnel_key_init(key, tos, ttl, tp_src, tp_dst, tun_id,
+			     tun_flags);
+	key->u.ipv6.src = *saddr;
+	key->u.ipv6.dst = *daddr;
+}
+
 static inline unsigned short ip_tunnel_info_af(const struct ip_tunnel_info
 					       *tun_info)
 {
-- 
1.8.3.1
