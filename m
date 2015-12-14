From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH 2/2] net: vxlan: enable local checksum offload on HW_CSUM
 devices
Date: Mon, 14 Dec 2015 15:13:29 +0000
Message-ID: <566EDC99.1010604@solarflare.com>
References: <566EDC16.1060706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:5794 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751061AbbLNPNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 10:13:37 -0500
In-Reply-To: <566EDC16.1060706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/vxlan.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6369a57..c1660d6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1785,6 +1785,9 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 	bool udp_sum = !!(vxflags & VXLAN_F_UDP_CSUM);
 	int type = udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 	u16 hdrlen = sizeof(struct vxlanhdr);
+	/* Is device able to do the inner checksum? */
+	bool inner_csum = skb_dst(skb) && skb_dst(skb)->dev &&
+				(skb_dst(skb)->dev->features & NETIF_F_HW_CSUM);
 
 	if ((vxflags & VXLAN_F_REMCSUM_TX) &&
 	    skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -1814,7 +1817,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
 	if (WARN_ON(!skb))
 		return -ENOMEM;
 
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
+	skb = iptunnel_handle_offloads(skb, udp_sum && !inner_csum, type);
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
 
-- 
2.4.3
