From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V3 1/4] net/ip_tunnels: Introduce tunnel_id_to_key32() and key32_to_tunnel_id()
Date: Thu, 25 Aug 2016 19:13:44 +0300
Message-ID: <1472141627-27339-2-git-send-email-hadarh@mellanox.com>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38668 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751569AbcHYQUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:20:48 -0400
In-Reply-To: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>

Add utility functions to convert a 32 bits key into a 64 bits tunnel and
vice versa.
These functions will be used instead of cloning code in GRE and VXLAN,
and in tc act_iptunnel which will be introduced in a following patch in
this patchset.

Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 drivers/net/vxlan.c      |  4 ++--
 include/net/ip_tunnels.h | 19 +++++++++++++++++++
 include/net/vxlan.h      | 18 ------------------
 net/ipv4/ip_gre.c        | 23 ++---------------------
 4 files changed, 23 insertions(+), 41 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c0dda6f..b1ddf8f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1294,7 +1294,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 		struct metadata_dst *tun_dst;
 
 		tun_dst = udp_tun_rx_dst(skb, vxlan_get_sk_family(vs), TUNNEL_KEY,
-					 vxlan_vni_to_tun_id(vni), sizeof(*md));
+					 key32_to_tunnel_id(vni), sizeof(*md));
 
 		if (!tun_dst)
 			goto drop;
@@ -1948,7 +1948,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			goto drop;
 		}
 		dst_port = info->key.tp_dst ? : vxlan->cfg.dst_port;
-		vni = vxlan_tun_id_to_vni(info->key.tun_id);
+		vni = tunnel_id_to_key32(info->key.tun_id);
 		remote_ip.sa.sa_family = ip_tunnel_info_af(info);
 		if (remote_ip.sa.sa_family == AF_INET) {
 			remote_ip.sin.sin_addr.s_addr = info->key.u.ipv4.dst;
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index a5e7035..e598c63 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -222,6 +222,25 @@ static inline unsigned short ip_tunnel_info_af(const struct ip_tunnel_info
 	return tun_info->mode & IP_TUNNEL_INFO_IPV6 ? AF_INET6 : AF_INET;
 }
 
+static inline __be64 key32_to_tunnel_id(__be32 key)
+{
+#ifdef __BIG_ENDIAN
+	return (__force __be64)key;
+#else
+	return (__force __be64)((__force u64)key << 32);
+#endif
+}
+
+/* Returns the least-significant 32 bits of a __be64. */
+static inline __be32 tunnel_id_to_key32(__be64 tun_id)
+{
+#ifdef __BIG_ENDIAN
+	return (__force __be32)tun_id;
+#else
+	return (__force __be32)((__force u64)tun_id >> 32);
+#endif
+}
+
 #ifdef CONFIG_INET
 
 int ip_tunnel_init(struct net_device *dev);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index b96d036..0255613 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -350,24 +350,6 @@ static inline __be32 vxlan_vni_field(__be32 vni)
 #endif
 }
 
-static inline __be32 vxlan_tun_id_to_vni(__be64 tun_id)
-{
-#if defined(__BIG_ENDIAN)
-	return (__force __be32)tun_id;
-#else
-	return (__force __be32)((__force u64)tun_id >> 32);
-#endif
-}
-
-static inline __be64 vxlan_vni_to_tun_id(__be32 vni)
-{
-#if defined(__BIG_ENDIAN)
-	return (__force __be64)vni;
-#else
-	return (__force __be64)((u64)(__force u32)vni << 32);
-#endif
-}
-
 static inline size_t vxlan_rco_start(__be32 vni_field)
 {
 	return be32_to_cpu(vni_field & VXLAN_RCO_MASK) << VXLAN_RCO_SHIFT;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 113cc43..576f705 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -246,25 +246,6 @@ static void gre_err(struct sk_buff *skb, u32 info)
 	ipgre_err(skb, info, &tpi);
 }
 
-static __be64 key_to_tunnel_id(__be32 key)
-{
-#ifdef __BIG_ENDIAN
-	return (__force __be64)((__force u32)key);
-#else
-	return (__force __be64)((__force u64)key << 32);
-#endif
-}
-
-/* Returns the least-significant 32 bits of a __be64. */
-static __be32 tunnel_id_to_key(__be64 x)
-{
-#ifdef __BIG_ENDIAN
-	return (__force __be32)x;
-#else
-	return (__force __be32)((__force u64)x >> 32);
-#endif
-}
-
 static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 		       struct ip_tunnel_net *itn, int hdr_len, bool raw_proto)
 {
@@ -290,7 +271,7 @@ static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 			__be64 tun_id;
 
 			flags = tpi->flags & (TUNNEL_CSUM | TUNNEL_KEY);
-			tun_id = key_to_tunnel_id(tpi->key);
+			tun_id = key32_to_tunnel_id(tpi->key);
 			tun_dst = ip_tun_rx_dst(skb, flags, tun_id, 0);
 			if (!tun_dst)
 				return PACKET_REJECT;
@@ -446,7 +427,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	flags = tun_info->key.tun_flags & (TUNNEL_CSUM | TUNNEL_KEY);
 	gre_build_header(skb, tunnel_hlen, flags, proto,
-			 tunnel_id_to_key(tun_info->key.tun_id), 0);
+			 tunnel_id_to_key32(tun_info->key.tun_id), 0);
 
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
 
-- 
1.8.3.1
