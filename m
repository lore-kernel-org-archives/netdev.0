From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/4] ip_tunnels: convert the mode field of ip_tunnel_info to flags
Date: Fri, 28 Aug 2015 16:27:25 +0200
Message-ID: <21cc14223253b50addb96dd054d02c3f7f2681ac.1440771116.git.jbenc@redhat.com>
References: <cover.1440771116.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631AbbH1O1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 10:27:41 -0400
In-Reply-To: <cover.1440771116.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mode field holds a single bit of information only (whether the
ip_tunnel_info struct is for rx or tx). Change the mode field to bit flags.
This allows more mode flags to be added.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c        | 2 +-
 include/net/dst_metadata.h | 1 -
 include/net/ip_tunnels.h   | 9 ++-------
 net/ipv4/ip_gre.c          | 2 +-
 net/ipv4/route.c           | 2 +-
 net/ipv6/route.c           | 2 +-
 6 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 30e56cb58884..bd1b8cdf2bf6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2113,7 +2113,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (vxlan->flags & VXLAN_F_COLLECT_METADATA &&
-	    info && info->mode == IP_TUNNEL_INFO_TX) {
+	    info && info->mode & IP_TUNNEL_INFO_TX) {
 		vxlan_xmit_one(skb, dev, NULL, false);
 		return NETDEV_TX_OK;
 	}
diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 60c03326c087..2b83f0d232e0 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -59,7 +59,6 @@ static inline struct metadata_dst *tun_rx_dst(__be16 flags,
 		return NULL;
 
 	info = &tun_dst->u.tun_info;
-	info->mode = IP_TUNNEL_INFO_RX;
 	info->key.tun_flags = flags;
 	info->key.tun_id = tunnel_id;
 	info->key.tp_src = 0;
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 224e4ecec91b..9bdb3948798f 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -50,13 +50,8 @@ struct ip_tunnel_key {
 	__be16			tp_dst;
 };
 
-/* Indicates whether the tunnel info structure represents receive
- * or transmit tunnel parameters.
- */
-enum {
-	IP_TUNNEL_INFO_RX,
-	IP_TUNNEL_INFO_TX,
-};
+/* Flags for ip_tunnel_info mode. */
+#define IP_TUNNEL_INFO_TX	0x01	/* represents tx tunnel parameters */
 
 struct ip_tunnel_info {
 	struct ip_tunnel_key	key;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index faf1cde6f8da..1e813a9f9378 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -511,7 +511,7 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 	int err;
 
 	tun_info = skb_tunnel_info(skb);
-	if (unlikely(!tun_info || tun_info->mode != IP_TUNNEL_INFO_TX))
+	if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX)))
 		goto err_free_skb;
 
 	key = &tun_info->key;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f3087aaa6dd8..3d9e70c804a9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1693,7 +1693,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	 */
 
 	tun_info = skb_tunnel_info(skb);
-	if (tun_info && tun_info->mode == IP_TUNNEL_INFO_RX)
+	if (tun_info && !(tun_info->mode & IP_TUNNEL_INFO_TX))
 		fl4.flowi4_tun_key.tun_id = tun_info->key.tun_id;
 	else
 		fl4.flowi4_tun_key.tun_id = 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index df3e353a012d..308dd5f9158f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1174,7 +1174,7 @@ void ip6_route_input(struct sk_buff *skb)
 	};
 
 	tun_info = skb_tunnel_info(skb);
-	if (tun_info && tun_info->mode == IP_TUNNEL_INFO_RX)
+	if (tun_info && !(tun_info->mode & IP_TUNNEL_INFO_TX))
 		fl6.flowi6_tun_key.tun_id = tun_info->key.tun_id;
 	skb_dst_drop(skb);
 	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
-- 
1.8.3.1
