From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 7/8] net: ip_tunnel: remove 'csum_help' argument to
 iptunnel_handle_offloads
Date: Fri, 8 Jan 2016 19:47:16 +0000
Message-ID: <56901244.8060809@solarflare.com>
References: <56901197.8040808@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.com>, <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:34034 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932778AbcAHTrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 14:47:46 -0500
In-Reply-To: <56901197.8040808@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All users now pass false, so we can remove it, and remove the code that
 was conditional upon it.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/vxlan.c             |  4 ++--
 include/net/ip_tunnels.h        |  3 +--
 include/net/udp_tunnel.h        |  3 +--
 net/ipv4/fou.c                  |  4 ++--
 net/ipv4/ip_gre.c               |  3 +--
 net/ipv4/ip_tunnel_core.c       | 15 +--------------
 net/ipv4/ipip.c                 |  2 +-
 net/ipv6/sit.c                  |  4 ++--
 net/netfilter/ipvs/ip_vs_xmit.c |  6 ++----
 9 files changed, 13 insertions(+), 31 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d3509a1..32ff1ef 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1731,7 +1731,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 		goto err;
 	}
 
-	skb = iptunnel_handle_offloads(skb, false, type);
+	skb = iptunnel_handle_offloads(skb, type);
 	if (IS_ERR(skb)) {
 		err = -EINVAL;
 		goto err;
@@ -1809,7 +1809,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 	if (WARN_ON(!skb))
 		return -ENOMEM;
 
-	skb = iptunnel_handle_offloads(skb, false, type);
+	skb = iptunnel_handle_offloads(skb, type);
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 62a750a..2c10119 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -279,8 +279,7 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
 					     gfp_t flags);
 
-struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb, bool gre_csum,
-					 int gso_type_mask);
+struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb, int gso_type_mask);
 
 static inline void iptunnel_xmit_stats(int err,
 				       struct net_device_stats *err_stats,
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 210eb90..b9dd3ed 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -103,8 +103,7 @@ static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
 {
 	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 
-	/* As we're a UDP tunnel, we support LCO, so don't need csum_help */
-	return iptunnel_handle_offloads(skb, false, type);
+	return iptunnel_handle_offloads(skb, type);
 }
 
 static inline void udp_tunnel_gro_complete(struct sk_buff *skb, int nhoff)
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 3d4c9a7..8ea0519 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -786,7 +786,7 @@ int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 						       SKB_GSO_UDP_TUNNEL;
 	__be16 sport;
 
-	skb = iptunnel_handle_offloads(skb, false, type);
+	skb = iptunnel_handle_offloads(skb, type);
 
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
@@ -819,7 +819,7 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 
 	optlen += need_priv ? GUE_LEN_PRIV : 0;
 
-	skb = iptunnel_handle_offloads(skb, false, type);
+	skb = iptunnel_handle_offloads(skb, type);
 
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 8a589d3..8bac0ce 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -506,8 +506,7 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 static struct sk_buff *gre_handle_offloads(struct sk_buff *skb,
 					   bool csum)
 {
-	return iptunnel_handle_offloads(skb, false,
-					csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
+	return iptunnel_handle_offloads(skb, csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
 }
 
 static struct rtable *gre_get_rt(struct sk_buff *skb,
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 1db8418..f98bd53 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -147,7 +147,6 @@ struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
 EXPORT_SYMBOL_GPL(iptunnel_metadata_reply);
 
 struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
-					 bool csum_help,
 					 int gso_type_mask)
 {
 	int err;
@@ -165,19 +164,7 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
 		return skb;
 	}
 
-	/* If packet is not gso and we are resolving any partial checksum,
-	 * clear encapsulation flag. This allows setting CHECKSUM_PARTIAL
-	 * on the outer header without confusing devices that implement
-	 * NETIF_F_IP_CSUM with encapsulation.
-	 */
-	if (csum_help)
-		skb->encapsulation = 0;
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL && csum_help) {
-		err = skb_checksum_help(skb);
-		if (unlikely(err))
-			goto error;
-	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		skb->ip_summed = CHECKSUM_NONE;
 
 	return skb;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 1f06729..71045c3 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -219,7 +219,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb->protocol != htons(ETH_P_IP)))
 		goto tx_error;
 
-	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
+	skb = iptunnel_handle_offloads(skb, SKB_GSO_IPIP);
 	if (IS_ERR(skb))
 		goto out;
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index dcccae8..acda206 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -912,7 +912,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		goto tx_error;
 	}
 
-	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_SIT);
+	skb = iptunnel_handle_offloads(skb, SKB_GSO_SIT);
 	if (IS_ERR(skb)) {
 		ip_rt_put(rt);
 		goto out;
@@ -1003,7 +1003,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr  *tiph = &tunnel->parms.iph;
 
-	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_IPIP);
+	skb = iptunnel_handle_offloads(skb, SKB_GSO_IPIP);
 	if (IS_ERR(skb))
 		goto out;
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 3264cb49..a3f5cd9 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1019,8 +1019,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (IS_ERR(skb))
 		goto tx_error;
 
-	skb = iptunnel_handle_offloads(
-		skb, false, __tun_gso_type_mask(AF_INET, cp->af));
+	skb = iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET, cp->af));
 	if (IS_ERR(skb))
 		goto tx_error;
 
@@ -1112,8 +1111,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (IS_ERR(skb))
 		goto tx_error;
 
-	skb = iptunnel_handle_offloads(
-		skb, false, __tun_gso_type_mask(AF_INET6, cp->af));
+	skb = iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET6, cp->af));
 	if (IS_ERR(skb))
 		goto tx_error;
 
