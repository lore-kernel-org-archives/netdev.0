From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/6] tunnel: introduce udp_tun_rx_dst()
Date: Tue, 11 Aug 2015 22:17:33 -0700
Message-ID: <1439356653-21724-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35923 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873AbbHLFSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 01:18:40 -0400
Received: by pdco4 with SMTP id o4so3279577pdc.3
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 22:18:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce function udp_tun_rx_dst() to initialize tunnel dst on
receive path.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c        | 18 ++----------------
 include/net/dst_metadata.h | 27 +++++++++++++++++++++++++++
 include/net/udp_tunnel.h   |  3 +++
 net/ipv4/ip_gre.c          | 21 +++++----------------
 net/ipv4/udp_tunnel.c      | 24 +++++++++++++++++++++++-
 5 files changed, 60 insertions(+), 33 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 06c0731..94a12ef 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1269,26 +1269,12 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	if (vxlan_collect_metadata(vs)) {
-		const struct iphdr *iph = ip_hdr(skb);
-
-		tun_dst = metadata_dst_alloc(sizeof(*md), GFP_ATOMIC);
+		tun_dst = udp_tun_rx_dst(skb, TUNNEL_KEY,
+					 cpu_to_be64(vni >> 8), sizeof(*md));
 		if (!tun_dst)
 			goto drop;
 
 		info = &tun_dst->u.tun_info;
-		info->key.ipv4_src = iph->saddr;
-		info->key.ipv4_dst = iph->daddr;
-		info->key.ipv4_tos = iph->tos;
-		info->key.ipv4_ttl = iph->ttl;
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
index 075f523..c0934bd 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -53,4 +53,31 @@ static inline bool skb_valid_dst(const struct sk_buff *skb)
 struct metadata_dst *metadata_dst_alloc(u8 optslen, gfp_t flags);
 struct metadata_dst __percpu *metadata_dst_alloc_percpu(u8 optslen, gfp_t flags);
 
+static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
+						 __be16 flags,
+						 __be64 tunnel_id,
+						 int md_size)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct metadata_dst *tun_dst;
+	struct ip_tunnel_info *info;
+
+	tun_dst = metadata_dst_alloc(md_size, GFP_ATOMIC);
+	if (!tun_dst)
+		return NULL;
+
+	info = &tun_dst->u.tun_info;
+	info->key.ipv4_src = iph->saddr;
+	info->key.ipv4_dst = iph->daddr;
+	info->key.ipv4_tos = iph->tos;
+	info->key.ipv4_ttl = iph->ttl;
+
+	info->mode = IP_TUNNEL_INFO_RX;
+	info->key.tun_flags = flags;
+	info->key.tun_id = tunnel_id;
+	info->key.tp_src = 0;
+	info->key.tp_dst = 0;
+	return tun_dst;
+}
+
 #endif /* __NET_DST_METADATA_H */
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index c491c12..0ca17873 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -93,6 +93,9 @@ int udp_tunnel6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 
 void udp_tunnel_sock_release(struct socket *sock);
 
+struct metadata_dst *udp_tun_rx_dst(struct sk_buff *skb, __be16 flags,
+				 __be64 tunnel_id, int md_size);
+
 static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
 							 bool udp_csum)
 {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fb44d69..51f722a 100644
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
-			info->key.ipv4_src = iph->saddr;
-			info->key.ipv4_dst = iph->daddr;
-			info->key.ipv4_tos = iph->tos;
-			info->key.ipv4_ttl = iph->ttl;
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
index 933ea90..b67fe04 100644
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
@@ -103,4 +104,25 @@ void udp_tunnel_sock_release(struct socket *sock)
 }
 EXPORT_SYMBOL_GPL(udp_tunnel_sock_release);
 
+struct metadata_dst *udp_tun_rx_dst(struct sk_buff *skb, __be16 flags,
+				    __be64 tunnel_id, int md_size)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct metadata_dst *tun_dst;
+	struct ip_tunnel_info *info;
+
+	tun_dst = ip_tun_rx_dst(skb, flags, tunnel_id, md_size);
+	if (!tun_dst)
+		return NULL;
+
+	info = &tun_dst->u.tun_info;
+	info->key.tp_src = udp_hdr(skb)->source;
+	info->key.tp_dst = udp_hdr(skb)->dest;
+	if (udp_hdr(skb)->check != 0)
+		info->key.tun_flags |= TUNNEL_CSUM;
+
+	return tun_dst;
+}
+EXPORT_SYMBOL_GPL(udp_tun_rx_dst);
+
 MODULE_LICENSE("GPL");
-- 
1.8.3.1
