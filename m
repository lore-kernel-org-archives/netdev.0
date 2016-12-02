From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] geneve: avoid use-after-free of skb->data
Date: Fri,  2 Dec 2016 16:49:29 +0100
Message-ID: <027c88dd060f5ca4535cb346db125829b2181a88.1480675406.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        "John W . Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45752 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751606AbcLBPu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 10:50:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

geneve{,6}_build_skb can end up doing a pskb_expand_head(), which
makes the ip_hdr(skb) reference we stashed earlier stale. Since it's
only needed as an argument to ip_tunnel_ecn_encap(), move this
directly in the function call.

Fixes: 08399efc6319 ("geneve: ensure ECN info is handled properly in all tx/rx paths")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/geneve.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 532695c8209b..bab65647b80f 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -859,7 +859,6 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct geneve_sock *gs4;
 	struct rtable *rt = NULL;
-	const struct iphdr *iip; /* interior IP header */
 	int err = -EINVAL;
 	struct flowi4 fl4;
 	__u8 tos, ttl;
@@ -890,8 +889,6 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
 	skb_reset_mac_header(skb);
 
-	iip = ip_hdr(skb);
-
 	if (info) {
 		const struct ip_tunnel_key *key = &info->key;
 		u8 *opts = NULL;
@@ -911,7 +908,7 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		if (unlikely(err))
 			goto tx_error;
 
-		tos = ip_tunnel_ecn_encap(key->tos, iip, skb);
+		tos = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
 		ttl = key->ttl;
 		df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
 	} else {
@@ -920,7 +917,7 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		if (unlikely(err))
 			goto tx_error;
 
-		tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, iip, skb);
+		tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, ip_hdr(skb), skb);
 		ttl = geneve->ttl;
 		if (!ttl && IN_MULTICAST(ntohl(fl4.daddr)))
 			ttl = 1;
@@ -952,7 +949,6 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct dst_entry *dst = NULL;
-	const struct iphdr *iip; /* interior IP header */
 	struct geneve_sock *gs6;
 	int err = -EINVAL;
 	struct flowi6 fl6;
@@ -982,8 +978,6 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
 	skb_reset_mac_header(skb);
 
-	iip = ip_hdr(skb);
-
 	if (info) {
 		const struct ip_tunnel_key *key = &info->key;
 		u8 *opts = NULL;
@@ -1004,7 +998,7 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		if (unlikely(err))
 			goto tx_error;
 
-		prio = ip_tunnel_ecn_encap(key->tos, iip, skb);
+		prio = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
 		ttl = key->ttl;
 		label = info->key.label;
 	} else {
@@ -1014,7 +1008,7 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 			goto tx_error;
 
 		prio = ip_tunnel_ecn_encap(ip6_tclass(fl6.flowlabel),
-					   iip, skb);
+					   ip_hdr(skb), skb);
 		ttl = geneve->ttl;
 		if (!ttl && ipv6_addr_is_multicast(&fl6.daddr))
 			ttl = 1;
-- 
2.10.2
