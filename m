From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 4/8] net: vxlan: enable local checksum offload
Date: Fri, 5 Feb 2016 20:42:13 +0000
Message-ID: <56B50925.4090602@solarflare.com>
References: <56B50886.1050201@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.com>, <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:36841 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752116AbcBEUmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 15:42:21 -0500
In-Reply-To: <56B50886.1050201@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/vxlan.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6543918..7299e5f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1706,10 +1706,8 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 		if (csum_start <= VXLAN_MAX_REMCSUM_START &&
 		    !(csum_start & VXLAN_RCO_SHIFT_MASK) &&
 		    (skb->csum_offset == offsetof(struct udphdr, check) ||
-		     skb->csum_offset == offsetof(struct tcphdr, check))) {
-			udp_sum = false;
+		     skb->csum_offset == offsetof(struct tcphdr, check)))
 			type |= SKB_GSO_TUNNEL_REMCSUM;
-		}
 	}
 
 	skb_scrub_packet(skb, xnet);
@@ -1731,7 +1729,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 		goto err;
 	}
 
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 	if (IS_ERR(skb)) {
 		err = -EINVAL;
 		goto err;
@@ -1763,8 +1761,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	udp_tunnel6_xmit_skb(dst, sk, skb, dev, saddr, daddr, prio,
-			     ttl, src_port, dst_port,
-			     !!(vxflags & VXLAN_F_UDP_ZERO_CSUM6_TX));
+			     ttl, src_port, dst_port, !udp_sum);
 	return 0;
 err:
 	dst_release(dst);
@@ -1791,10 +1788,8 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 		if (csum_start <= VXLAN_MAX_REMCSUM_START &&
 		    !(csum_start & VXLAN_RCO_SHIFT_MASK) &&
 		    (skb->csum_offset == offsetof(struct udphdr, check) ||
-		     skb->csum_offset == offsetof(struct tcphdr, check))) {
-			udp_sum = false;
+		     skb->csum_offset == offsetof(struct tcphdr, check)))
 			type |= SKB_GSO_TUNNEL_REMCSUM;
-		}
 	}
 
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
@@ -1812,7 +1807,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 	if (WARN_ON(!skb))
 		return -ENOMEM;
 
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
 
@@ -1842,8 +1837,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	udp_tunnel_xmit_skb(rt, sk, skb, src, dst, tos, ttl, df,
-			    src_port, dst_port, xnet,
-			    !(vxflags & VXLAN_F_UDP_CSUM));
+			    src_port, dst_port, xnet, !udp_sum);
 	return 0;
 }
 
