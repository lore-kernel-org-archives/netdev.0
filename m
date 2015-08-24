From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3 net-next 3/8] tunnel: introduce udp_tun_rx_dst()
Date: Mon, 24 Aug 2015 10:43:10 -0700
Message-ID: <1440438195-5695-4-git-send-email-pshelar@nicira.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36567 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753447AbbHXRnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 13:43:25 -0400
Received: by pacgr6 with SMTP id gr6so1075234pac.3
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 10:43:24 -0700 (PDT)
In-Reply-To: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce function udp_tun_rx_dst() to initialize tunnel dst on
receive path.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
Rebased to support ipv6 tun-dst.
---
 drivers/net/vxlan.c        |   29 ++------------------
 include/net/dst_metadata.h |   61 ++++++++++++++++++++++++++++++++++++++++++++
 include/net/udp_tunnel.h   |    4 +++
 net/ipv4/ip_gre.c          |   21 +++-----------
 net/ipv4/udp_tunnel.c      |   25 +++++++++++++++++-
 5 files changed, 97 insertions(+), 43 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 61b457b..5b4cf66 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1264,36 +1264,13 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	if (vxlan_collect_metadata(vs)) {
-		tun_dst = metadata_dst_alloc(sizeof(*md), GFP_ATOMIC);
+		tun_dst = udp_tun_rx_dst(skb, vxlan_get_sk_family(vs), TUNNEL_KEY,
+					 cpu_to_be64(vni >> 8), sizeof(*md));
+
 		if (!tun_dst)
 			goto drop;
 
 		info = &tun_dst->u.tun_info;
-		if (vxlan_get_sk_family(vs) == AF_INET) {
-			const struct iphdr *iph = ip_hdr(skb);
-
-			info->key.u.ipv4.src = iph->saddr;
-			info->key.u.ipv4.dst = iph->daddr;
-			info->key.tos = iph->tos;
-			info->key.ttl = iph->ttl;
-		} else {
-			const struct ipv6hdr *ip6h = ipv6_hdr(skb);
-
-			info->key.u.ipv6.src = ip6h->saddr;
-			info->key.u.ipv6.dst = ip6h->daddr;
-			info->key.tos = ipv6_get_dsfield(ip6h);
-			info->key.ttl = ip6h->hop_limit;
-		}
-
-		info->key.tp_src = udp_hdr(skb)->source;
-		info->key.tp_dst = udp_hdr(skb)->dest;
-
-		info->mode = IP_TUNNEL_INFO_RX;
-		info->key.tun_flags = TUNNEL_KEY;
-		info->key.tun_id = cpu_to_be64(vni >> 8);
-		if (udp_hdr(skb)->check != 0)
-			info->key.tun_flags |= TUNNEL_CSUM;
-
 		md = ip_tunnel_info_opts(info, sizeof(*md));
 	} else {
 		memset(md, 0, sizeof(*md));
diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 2cb52d5..60c0332 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -48,4 +48,65 @@ static inline bool skb_valid_dst(const struct sk_buff *skb)
 struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags);
 struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags);
 
+static inline struct metadata_dst *tun_rx_dst(__be16 flags,
+					      __be64 tunnel_id, int md_size)
+{
+	struct metadata_dst *tun_dst;
+	struct ip_tunnel_info *info;
+
+	tun_dst = metadata_dst_alloc(md_size, GFP_ATOMIC);
+	if (!tun_dst)
+		return NULL;
+
+	info = &tun_dst->u.tun_info;
+	info->mode = IP_TUNNEL_INFO_RX;
+	info->key.tun_flags = flags;
+	info->key.tun_id = tunnel_id;
+	info->key.tp_src = 0;
+	info->key.tp_dst = 0;
+	return tun_dst;
+}
+
+static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
+						 __be16 flags,
+						 __be64 tunnel_id,
+						 int md_size)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct metadata_dst *tun_dst;
+	struct ip_tunnel_info *info;
+
+	tun_dst = tun_rx_dst(flags, tunnel_id, md_size);
+	if (!tun_dst)
+		return NULL;
+
+	info = &tun_dst->u.tun_info;
+	info->key.u.ipv4.src = iph->saddr;
+	info->key.u.ipv4.dst = iph->daddr;
+	info->key.tos = iph->tos;
+	info->key.ttl = iph->ttl;
+	return tun_dst;
+}
+
+static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
+						 __be16 flags,
+						 __be64 tunnel_id,
+						 int md_size)
+{
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	struct metadata_dst *tun_dst;
+	struct ip_tunnel_info *info;
+
+	tun_dst = tun_rx_dst(flags, tunnel_id, md_size);
+	if (!tun_dst)
+		return NULL;
+
+	info = &tun_dst->u.tun_info;
+	info->key.u.ipv6.src = ip6h->saddr;
+	info->key.u.ipv6.dst = ip6h->daddr;
+	info->key.tos = ipv6_get_dsfield(ip6h);
+	info->key.ttl = ip6h->hop_limit;
+	return tun_dst;
+}
+
 #endif /* __NET_DST_METADATA_H */
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index c491c12..35041d0 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -93,6 +93,10 @@ int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 
 void udp_tunnel_sock_release(struct socket *sock);
 
+struct metadata_dst *udp_tun_rx_dst(struct sk_buff *skb, unsigned short family,
+				    __be16 flags, __be64 tunnel_id,
+				    int md_size);
+
 static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
 							 bool udp_csum)
 {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 1bf3281..faf1cde 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -400,25 +400,14 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 	if (tunnel) {
 		skb_pop_mac_header(skb);
 		if (tunnel->collect_md) {
-			struct ip_tunnel_info *info;
+			__be16 flags;
+			__be64 tun_id;
 
-			tun_dst = metadata_dst_alloc(0, GFP_ATOMIC);
+			flags = tpi->flags & (TUNNEL_CSUM | TUNNEL_KEY);
+			tun_id = key_to_tunnel_id(tpi->key);
+			tun_dst = ip_tun_rx_dst(skb, flags, tun_id, 0);
 			if (!tun_dst)
 				return PACKET_REJECT;
-
-			info = &tun_dst->u.tun_info;
-			info->key.u.ipv4.src = iph->saddr;
-			info->key.u.ipv4.dst = iph->daddr;
-			info->key.tos = iph->tos;
-			info->key.ttl = iph->ttl;
-
-			info->mode = IP_TUNNEL_INFO_RX;
-			info->key.tun_flags = tpi->flags &
-					      (TUNNEL_CSUM | TUNNEL_KEY);
-			info->key.tun_id = key_to_tunnel_id(tpi->key);
-
-			info->key.tp_src = 0;
-			info->key.tp_dst = 0;
 		}
 
 		ip_tunnel_rcv(tunnel, skb, tpi, tun_dst, log_ecn_error);
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 933ea90..aba4286 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -4,9 +4,10 @@
 #include <linux/udp.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
+#include <net/dst_metadata.h>
+#include <net/net_namespace.h>
 #include <net/udp.h>
 #include <net/udp_tunnel.h>
-#include <net/net_namespace.h>
 
 int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
 		     struct socket **sockp)
@@ -103,4 +104,26 @@ void udp_tunnel_sock_release(struct socket *sock)
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_sock_release);
 
+struct metadata_dst *udp_tun_rx_dst(struct sk_buff *skb,  unsigned short family,
+				    __be16 flags, __be64 tunnel_id, int md_size)
+{
+	struct metadata_dst *tun_dst;
+	struct ip_tunnel_info *info;
+
+	if (family == AF_INET)
+		tun_dst = ip_tun_rx_dst(skb, flags, tunnel_id, md_size);
+	else
+		tun_dst = ipv6_tun_rx_dst(skb, flags, tunnel_id, md_size);
+	if (!tun_dst)
+		return NULL;
+
+	info = &tun_dst->u.tun_info;
+	info->key.tp_src = udp_hdr(skb)->source;
+	info->key.tp_dst = udp_hdr(skb)->dest;
+	if (udp_hdr(skb)->check)
+		info->key.tun_flags |= TUNNEL_CSUM;
+	return tun_dst;
+}
+EXPORT_SYMBOL_GPL(udp_tun_rx_dst);
+
 MODULE_LICENSE("GPL");
-- 
1.7.1
