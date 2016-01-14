From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 4/4] net: Allow UDP and GRE to use inner checksum
 offloads with outer checksums needed
Date: Wed, 13 Jan 2016 21:12:21 -0800
Message-ID: <20160114051221.5119.91182.stgit@localhost.localdomain>
References: <20160114045532.5119.56124.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: ecree@solarflare.com, netdev@vger.kernel.org, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33334 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbcANFMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 00:12:23 -0500
Received: by mail-pa0-f44.google.com with SMTP id cy9so370589788pac.0
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 21:12:22 -0800 (PST)
In-Reply-To: <20160114045532.5119.56124.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables us to use inner checksum offloads if provided by
hardware with outer checksums computed by software.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/gre_offload.c |    2 --
 net/ipv4/udp_offload.c |   44 +++++++++++++++++++-------------------------
 2 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 5a8ee3282550..61608fe975fc 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -53,8 +53,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 		goto out;
 
 	csum = !!(greh->flags & GRE_CSUM);
-	if (csum)
-		skb->encap_hdr_csum = 1;
 
 	/* setup inner skb. */
 	skb->protocol = greh->protocol;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 45824f9b81c4..0a7f1207f3d3 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -39,31 +39,30 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	netdev_features_t enc_features;
 	int udp_offset, outer_hlen;
 	unsigned int oldlen;
-	bool need_csum = !!(skb_shinfo(skb)->gso_type &
-			    SKB_GSO_UDP_TUNNEL_CSUM);
 	bool remcsum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM);
-	bool offload_csum = false, dont_encap = (need_csum || remcsum);
+	bool need_csum, load_csum;
 
 	oldlen = (u16)~skb->len;
 
 	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
 		goto out;
 
+	/* Try to offload checksum if possible */
+	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
+	load_csum = need_csum &&
+		    !(skb->dev->features &
+		      (is_ipv6 ? (NETIF_F_HW_CSUM | NETIF_F_IPV6_CSUM) :
+				 (NETIF_F_HW_CSUM | NETIF_F_IP_CSUM)));
+
 	skb->encapsulation = 0;
 	__skb_pull(skb, tnl_hlen);
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
 	skb->protocol = new_protocol;
-	skb->encap_hdr_csum = need_csum;
+	skb->encap_hdr_csum = remcsum & load_csum;
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
@@ -81,16 +80,11 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		int len;
 		__be32 delta;
 
-		if (dont_encap) {
-			skb->encapsulation = 0;
+		if (remcsum)
 			skb->ip_summed = CHECKSUM_NONE;
-		} else {
-			/* Only set up inner headers if we might be offloading
-			 * inner checksum.
-			 */
-			skb_reset_inner_headers(skb);
-			skb->encapsulation = 1;
-		}
+
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = skb->ip_summed == CHECKSUM_PARTIAL;
 
 		skb->mac_len = mac_len;
 		skb->protocol = protocol;
@@ -111,16 +105,16 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		uh->check = ~csum_fold((__force __wsum)
 				       ((__force u32)uh->check +
 					(__force u32)delta));
-		if (offload_csum) {
+
+		if (skb->encapsulation || load_csum) {
+			uh->check = gso_make_checksum(skb, ~uh->check);
+			if (uh->check == 0)
+				uh->check = CSUM_MANGLED_0;
+		} else {
 			skb->ip_summed = CHECKSUM_PARTIAL;
 			skb->csum_start = skb_transport_header(skb) - skb->head;
 			skb->csum_offset = offsetof(struct udphdr, check);
 			gso_reset_checksum(skb, ~uh->check);
-		} else {
-			uh->check = gso_make_checksum(skb, ~uh->check);
-
-			if (uh->check == 0)
-				uh->check = CSUM_MANGLED_0;
 		}
 	} while ((skb = skb->next));
 out:
