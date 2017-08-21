From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 3/6] gretap: support lwtunnel under bridge (NVGRE)
Date: Mon, 21 Aug 2017 19:15:20 +0200
Message-ID: <20170821171523.951260-4-equinox@diac24.net>
References: <20170821171523.951260-1-equinox@diac24.net>
Cc: amine.kherbouche@6wind.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, David Lamparter <equinox@diac24.net>
To: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:37094 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753830AbdHURPp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 13:15:45 -0400
In-Reply-To: <20170821171523.951260-1-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables using an IPv4 multicast destination for gretap and enables
learning unicast destinations through the bridge fdb.  Alternatively, a
zero destination can be used together with manual entry creation via
netlink.

This is essentially basic NVGRE support, if the GRE key is configured
appropriately.  VLAN to key mapping is not supported.  Implementing
NVGRE was actually an unintentional side effect.

[v2: move src/dst flipping to RX path, allow zero tunnel daddr]
Signed-off-by: David Lamparter <equinox@diac24.net>
---
 net/ipv4/ip_gre.c    | 40 +++++++++++++++++++++++++++++++++++-----
 net/ipv4/ip_tunnel.c |  1 +
 2 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7a7829e839c2..1596f709e5b6 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -266,15 +266,35 @@ static int __ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 			skb_pop_mac_header(skb);
 		else
 			skb_reset_mac_header(skb);
-		if (tunnel->collect_md) {
+		if (tunnel->collect_md ||
+		    tunnel->parms.iph.daddr == 0 ||
+		    ipv4_is_multicast(tunnel->parms.iph.daddr)) {
 			__be16 flags;
 			__be64 tun_id;
 
 			flags = tpi->flags & (TUNNEL_CSUM | TUNNEL_KEY);
 			tun_id = key32_to_tunnel_id(tpi->key);
-			tun_dst = ip_tun_rx_dst(skb, flags, tun_id, 0);
-			if (!tun_dst)
-				return PACKET_REJECT;
+			if (tunnel->collect_md) {
+				tun_dst = ip_tun_rx_dst(skb, flags, tun_id, 0);
+				if (!tun_dst)
+					return PACKET_REJECT;
+			} else {
+				tun_dst = metadata_dst_alloc(0,
+						METADATA_IP_TUNNEL, GFP_ATOMIC);
+				if (!tun_dst)
+					return PACKET_REJECT;
+
+				/* build dst appropriate for responding */
+				tun_dst->u.tun_info.options_len = 0;
+				tun_dst->u.tun_info.mode = IP_TUNNEL_INFO_TX;
+
+				ip_tunnel_key_init(&tun_dst->u.tun_info.key,
+						   tunnel->parms.iph.saddr,
+						   iph->saddr,
+						   tunnel->parms.iph.tos,
+						   tunnel->parms.iph.ttl,
+						   0, 0, 0, tun_id, flags);
+			}
 		}
 
 		ip_tunnel_rcv(tunnel, skb, tpi, tun_dst, log_ecn_error);
@@ -507,11 +527,14 @@ static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_info *tun_info = skb_tunnel_info(skb);
 
-	if (tunnel->collect_md) {
+	if (tunnel->collect_md || tun_info) {
 		gre_fb_xmit(skb, dev, htons(ETH_P_TEB));
 		return NETDEV_TX_OK;
 	}
+	/* tunnel layer doesn't expect a metadata dst */
+	skb_dst_drop(skb);
 
 	if (gre_handle_offloads(skb, !!(tunnel->parms.o_flags & TUNNEL_CSUM)))
 		goto free_skb;
@@ -933,6 +956,7 @@ static int gre_tap_init(struct net_device *dev)
 {
 	__gre_tunnel_init(dev);
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	netif_keep_dst(dev);
 
 	return ip_tunnel_init(dev);
 }
@@ -940,6 +964,10 @@ static int gre_tap_init(struct net_device *dev)
 static const struct net_device_ops gre_tap_netdev_ops = {
 	.ndo_init		= gre_tap_init,
 	.ndo_uninit		= ip_tunnel_uninit,
+#ifdef CONFIG_NET_IPGRE_BROADCAST
+	.ndo_open		= ipgre_open,
+	.ndo_stop		= ipgre_close,
+#endif
 	.ndo_start_xmit		= gre_tap_xmit,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -947,6 +975,8 @@ static const struct net_device_ops gre_tap_netdev_ops = {
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
 	.ndo_get_iflink		= ip_tunnel_get_iflink,
 	.ndo_fill_metadata_dst	= gre_fill_metadata_dst,
+	.ndo_metadst_fill	= ip_tunnel_fill_metadst,
+	.ndo_metadst_build	= ip_tunnel_build_metadst,
 };
 
 static void ipgre_tap_setup(struct net_device *dev)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 129d1a3616f8..451c11fc9ae5 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -140,6 +140,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
 		if ((local != t->parms.iph.saddr || t->parms.iph.daddr != 0) &&
+		    (local != t->parms.iph.saddr || !ipv4_is_multicast(t->parms.iph.daddr)) &&
 		    (local != t->parms.iph.daddr || !ipv4_is_multicast(local)))
 			continue;
 
-- 
2.13.0
