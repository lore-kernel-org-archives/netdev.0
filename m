From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH v3] geneve: ensure ECN info is handled properly in all tx/rx paths
Date: Mon, 21 Sep 2015 10:29:09 -0400
Message-ID: <1442845749-23978-1-git-send-email-linville@tuxdriver.com>
References: <20150920.222459.2251924175671848436.davem@davemloft.net>
Cc: davem@davemloft.net, Jesse Gross <jesse@nicira.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44716 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbbIUOaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 10:30:13 -0400
In-Reply-To: <20150920.222459.2251924175671848436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Partially due to a pre-exising "thinko", the new metadata-based tx/rx
paths were handling ECN propagation differently than the traditional
tx/rx paths.  This patch removes the "thinko" (involving multiple
ip_hdr assignments) on the rx path and corrects the ECN handling on
both the rx and tx paths.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
v3 -- replace "geneve: remove use of internal IP header when calling
	IP_ECN_decapsulate", include geneve_xmit bits
v2 -- ensure the collect_md path still calls IP_ECN_decapsulate

 drivers/net/geneve.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index da3259ce7c8d..922101253993 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -126,6 +126,8 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	__be32 addr;
 	int err;
 
+	iph = ip_hdr(skb); /* outer IP header... */
+
 	if (gs->collect_md) {
 		static u8 zero_vni[3];
 
@@ -133,7 +135,6 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 		addr = 0;
 	} else {
 		vni = gnvh->vni;
-		iph = ip_hdr(skb); /* Still outer IP header... */
 		addr = iph->saddr;
 	}
 
@@ -178,7 +179,6 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 
-	iph = ip_hdr(skb); /* Now inner IP header... */
 	err = IP_ECN_decapsulate(iph, skb);
 
 	if (unlikely(err)) {
@@ -626,6 +626,7 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct geneve_sock *gs = geneve->sock;
 	struct ip_tunnel_info *info = NULL;
 	struct rtable *rt = NULL;
+	const struct iphdr *iip; /* interior IP header */
 	struct flowi4 fl4;
 	__u8 tos, ttl;
 	__be16 sport;
@@ -653,6 +654,8 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
 	skb_reset_mac_header(skb);
 
+	iip = ip_hdr(skb);
+
 	if (info) {
 		const struct ip_tunnel_key *key = &info->key;
 		u8 *opts = NULL;
@@ -668,19 +671,16 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (unlikely(err))
 			goto err;
 
-		tos = key->tos;
+		tos = ip_tunnel_ecn_encap(key->tos, iip, skb);
 		ttl = key->ttl;
 		df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
 	} else {
-		const struct iphdr *iip; /* interior IP header */
-
 		udp_csum = false;
 		err = geneve_build_skb(rt, skb, 0, geneve->vni,
 				       0, NULL, udp_csum);
 		if (unlikely(err))
 			goto err;
 
-		iip = ip_hdr(skb);
 		tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, iip, skb);
 		ttl = geneve->ttl;
 		if (!ttl && IN_MULTICAST(ntohl(fl4.daddr)))
-- 
2.4.3
