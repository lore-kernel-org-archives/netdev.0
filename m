From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 4/8] net: vxlan: enable local checksum offload
Date: Fri, 8 Jan 2016 19:45:51 +0000
Message-ID: <569011EF.8060602@solarflare.com>
References: <56901197.8040808@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.com>, <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:12847 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933079AbcAHTqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 14:46:14 -0500
In-Reply-To: <56901197.8040808@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/vxlan.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6369a57..d3509a1 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1708,10 +1708,8 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
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
@@ -1733,7 +1731,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 		goto err;
 	}
 
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 	if (IS_ERR(skb)) {
 		err = -EINVAL;
 		goto err;
@@ -1765,8 +1763,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	udp_tunnel6_xmit_skb(dst, sk, skb, dev, saddr, daddr, prio,
-			     ttl, src_port, dst_port,
-			     !!(vxflags & VXLAN_F_UDP_ZERO_CSUM6_TX));
+			     ttl, src_port, dst_port, !udp_sum);
 	return 0;
 err:
 	dst_release(dst);
@@ -1793,10 +1790,8 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
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
@@ -1814,7 +1809,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 	if (WARN_ON(!skb))
 		return -ENOMEM;
 
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
 
@@ -1844,8 +1839,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 
 	return udp_tunnel_xmit_skb(rt, sk, skb, src, dst, tos,
-				   ttl, df, src_port, dst_port, xnet,
-				   !(vxflags & VXLAN_F_UDP_CSUM));
+				   ttl, df, src_port, dst_port, xnet, !udp_sum);
 }
 
 /* Bypass encapsulation if the destination is local */
