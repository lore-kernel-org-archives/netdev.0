From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 2/2] net: Add support for UDP local checksum offload as
 a part of tunnel segmentation
Date: Mon, 11 Jan 2016 09:06:12 -0800
Message-ID: <20160111170612.5210.29602.stgit@localhost.localdomain>
References: <20160111165937.5210.61555.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, alexander.duyck@gmail.com
To: ecree@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36577 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933658AbcAKRGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:06:14 -0500
Received: by mail-pf0-f169.google.com with SMTP id n128so47431481pfn.3
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:06:14 -0800 (PST)
In-Reply-To: <20160111165937.5210.61555.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we can use the local checksum offload as a
part of UDP tunnel segmentation offload.  The advantage to this is
significant as we can get both inner and outer checksum offloads on hardware
that supports inner checksum offloads.  This allows us to make use of the
UDP Rx checksum offload available on most hardware to validate the outer
and inner headers via the code that converts CHECKSUM_UNNECESSARY into
CHECKSUM_COMPLETE for UDP tunnels.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/udp_offload.c |   38 +++++++++++++++++++++++---------------
 1 file changed, 23 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 130042660181..9543f800763f 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -42,28 +42,28 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	bool need_csum = !!(skb_shinfo(skb)->gso_type &
 			    SKB_GSO_UDP_TUNNEL_CSUM);
 	bool remcsum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM);
-	bool offload_csum = false, dont_encap = (need_csum || remcsum);
+	bool offload_csum;
 
 	oldlen = (u16)~skb->len;
 
 	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
 		goto out;
 
+	/* Try to offload checksum if possible */
+	offload_csum = !!(need_csum &&
+			  ((skb->dev->features & NETIF_F_HW_CSUM) ||
+			   (skb->dev->features & (is_ipv6 ?
+			    NETIF_F_IPV6_CSUM : NETIF_F_IP_CSUM))));
+
 	skb->encapsulation = 0;
 	__skb_pull(skb, tnl_hlen);
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
 	skb->protocol = new_protocol;
-	skb->encap_hdr_csum = need_csum;
+	skb->encap_hdr_csum = need_csum && !offload_csum;
 	skb->remcsum_offload = remcsum;
 
-	/* Try to offload checksum if possible */
-	offload_csum = !!(need_csum &&
-			  ((skb->dev->features & NETIF_F_HW_CSUM) ||
-			   (skb->dev->features & (is_ipv6 ?
-			    NETIF_F_IPV6_CSUM : NETIF_F_IP_CSUM))));
-
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & features;
 	segs = gso_inner_segment(skb, enc_features);
@@ -81,13 +81,10 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		int len;
 		__be32 delta;
 
-		if (dont_encap) {
-			skb->encapsulation = 0;
-			skb->ip_summed = CHECKSUM_NONE;
-		} else {
-			/* Only set up inner headers if we might be offloading
-			 * inner checksum.
-			 */
+		/* Only set up inner headers if we might be offloading
+		 * inner checksum.
+		 */
+		if (!remcsum) {
 			skb_reset_inner_headers(skb);
 			skb->encapsulation = 1;
 		}
@@ -111,6 +108,17 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		uh->check = ~csum_fold((__force __wsum)
 				       ((__force u32)uh->check +
 					(__force u32)delta));
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			uh->check = csum_fold(lco_csum(skb));
+			if (uh->check == 0)
+				uh->check = CSUM_MANGLED_0;
+			continue;
+		}
+
+		skb->encapsulation = 0;
+		skb->ip_summed = CHECKSUM_NONE;
+
 		if (offload_csum) {
 			skb->ip_summed = CHECKSUM_PARTIAL;
 			skb->csum_start = skb_transport_header(skb) - skb->head;
