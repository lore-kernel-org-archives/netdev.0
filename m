From: Tom Herbert <therbert@google.com>
Subject: [PATCH 8/8] vxlan: Add support for zero UDP6 checksums
Date: Mon, 12 May 2014 09:59:25 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:35436 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756465AbaELQ71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 12:59:27 -0400
Received: by mail-yh0-f74.google.com with SMTP id 29so1001137yhl.3
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 09:59:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added module parameters to specify sending of TX checksums and
allow receiving RX checksums. Also added a module parameter and
support for using IPv4 checksums on TX (default is off so zero
checksums are sent).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/vxlan.c | 42 ++++++++++++++++++++++++++----------------
 1 file changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1dfee9a..4839edb 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -83,6 +83,18 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
+static bool use_udp_checksums;
+module_param(use_udp_checksums, bool, 0644);
+MODULE_PARM_DESC(use_udp_checksums, "Send UDP checksums (IPv4)");
+
+static bool udp6_tx_zero_checksums;
+module_param(udp6_tx_zero_checksums, bool, 0644);
+MODULE_PARM_DESC(udp6_tx_zero_checksums, "Send zero IPv6 checksums");
+
+static bool udp6_rx_zero_checksums;
+module_param(udp6_rx_zero_checksums, bool, 0644);
+MODULE_PARM_DESC(udp6_rx_zero_checksums, "Receive zero IPv6 checksums");
+
 static int vxlan_net_id;
 
 static const u8 all_zeros_mac[ETH_ALEN];
@@ -1666,27 +1678,13 @@ static int vxlan6_xmit_skb(struct vxlan_sock *vs,
 	uh->source = src_port;
 
 	uh->len = htons(skb->len);
-	uh->check = 0;
 
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
 	skb_dst_set(skb, dst);
 
-	if (!skb_is_gso(skb) && !(dst->dev->features & NETIF_F_IPV6_CSUM)) {
-		__wsum csum = skb_checksum(skb, 0, skb->len, 0);
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		uh->check = csum_ipv6_magic(saddr, daddr, skb->len,
-					    IPPROTO_UDP, csum);
-		if (uh->check == 0)
-			uh->check = CSUM_MANGLED_0;
-	} else {
-		skb->ip_summed = CHECKSUM_PARTIAL;
-		skb->csum_start = skb_transport_header(skb) - skb->head;
-		skb->csum_offset = offsetof(struct udphdr, check);
-		uh->check = ~csum_ipv6_magic(saddr, daddr,
-					     skb->len, IPPROTO_UDP, 0);
-	}
+	udp6_set_csum(vs->sock->sk, skb, saddr, daddr, skb->len);
 
 	__skb_push(skb, sizeof(*ip6h));
 	skb_reset_network_header(skb);
@@ -1756,7 +1754,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
 	uh->source = src_port;
 
 	uh->len = htons(skb->len);
-	uh->check = 0;
+
+	udp_set_csum(vs->sock->sk, skb, src, dst, skb->len);
 
 	err = handle_offloads(skb);
 	if (err)
@@ -2442,6 +2441,13 @@ static struct socket *create_v6_sock(struct net *net, __be16 port)
 
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
+
+	if (udp6_rx_zero_checksums)
+		udp_set_no_check6_rx(sk, true);
+
+	if (udp6_tx_zero_checksums)
+		udp_set_no_check6_tx(sk, true);
+
 	return sock;
 }
 
@@ -2486,6 +2492,10 @@ static struct socket *create_v4_sock(struct net *net, __be16 port)
 
 	/* Disable multicast loopback */
 	inet_sk(sk)->mc_loop = 0;
+
+	if (!use_udp_checksums)
+		sock->sk->sk_no_check_tx = 1;
+
 	return sock;
 }
 
-- 
1.9.1.423.g4596e3a
