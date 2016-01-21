From: Jesse Gross <jesse@kernel.org>
Subject: [PATCH net] tunnels: Allow IPv6 UDP checksums to be correctly controlled.
Date: Wed, 20 Jan 2016 16:22:47 -0800
Message-ID: <1453335767-49234-1-git-send-email-jesse@kernel.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:44563 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752032AbcAUAXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 19:23:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When configuring checksums on UDP tunnels, the flags are different
for IPv4 vs. IPv6 (and reversed). However, when lightweight tunnels
are enabled the flags used are always the IPv4 versions, which are
ignored in the IPv6 code paths. This uses the correct IPv6 flags, so
checksums can be controlled appropriately.

Fixes: a725e514 ("vxlan: metadata based tunneling for IPv6")
Fixes: abe492b4 ("geneve: UDP checksum configuration via netlink")
Signed-off-by: Jesse Gross <jesse@kernel.org>
---
 drivers/net/geneve.c |  4 ++--
 drivers/net/vxlan.c  | 23 ++++++++++++++++-------
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 7456569..0b14ac3 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -980,9 +980,9 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 			opts = ip_tunnel_info_opts(info);
 
 		if (key->tun_flags & TUNNEL_CSUM)
-			flags |= GENEVE_F_UDP_CSUM;
+			flags &= ~GENEVE_F_UDP_ZERO_CSUM6_TX;
 		else
-			flags &= ~GENEVE_F_UDP_CSUM;
+			flags |= GENEVE_F_UDP_ZERO_CSUM6_TX;
 
 		err = geneve6_build_skb(dst, skb, key->tun_flags, vni,
 					info->options_len, opts,
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2d88c79..a85b1fc 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1985,11 +1985,6 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				     vxlan->cfg.port_max, true);
 
 	if (info) {
-		if (info->key.tun_flags & TUNNEL_CSUM)
-			flags |= VXLAN_F_UDP_CSUM;
-		else
-			flags &= ~VXLAN_F_UDP_CSUM;
-
 		ttl = info->key.ttl;
 		tos = info->key.tos;
 
@@ -2004,8 +1999,15 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			goto drop;
 		sk = vxlan->vn4_sock->sock->sk;
 
-		if (info && (info->key.tun_flags & TUNNEL_DONT_FRAGMENT))
-			df = htons(IP_DF);
+		if (info) {
+			if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
+				df = htons(IP_DF);
+
+			if (info->key.tun_flags & TUNNEL_CSUM)
+				flags |= VXLAN_F_UDP_CSUM;
+			else
+				flags &= ~VXLAN_F_UDP_CSUM;
+		}
 
 		memset(&fl4, 0, sizeof(fl4));
 		fl4.flowi4_oif = rdst ? rdst->remote_ifindex : 0;
@@ -2101,6 +2103,13 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			return;
 		}
 
+		if (info) {
+			if (info->key.tun_flags & TUNNEL_CSUM)
+				flags &= ~VXLAN_F_UDP_ZERO_CSUM6_TX;
+			else
+				flags |= VXLAN_F_UDP_ZERO_CSUM6_TX;
+		}
+
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
 		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &saddr, &dst->sin6.sin6_addr,
 				      0, ttl, src_port, dst_port, htonl(vni << 8), md,
-- 
2.5.0
