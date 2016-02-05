From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 08/10] udp: Clean up the use of flags in UDP
 segmentation offload
Date: Fri, 05 Feb 2016 15:28:14 -0800
Message-ID: <20160205232814.18529.595.stgit@localhost.localdomain>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, tom@herbertland.com, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35230 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbcBEX2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 18:28:15 -0500
Received: by mail-pf0-f169.google.com with SMTP id c10so9943114pfc.2
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 15:28:15 -0800 (PST)
In-Reply-To: <20160205232109.18529.99816.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch goes though and cleans up the logic related to several of the
control flags used in UDP segmentation.  Specifically the use of dont_encap
isn't really needed as we can just check the skb for CHECKSUM_PARTIAL and
if it isn't set then we don't need to update the internal headers.  As such
we can just drop that value.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/udp_offload.c |   37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 86687f58d613..9e4816fc9927 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -33,16 +33,13 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	__be16 new_protocol, bool is_ipv6)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	bool remcsum, need_csum, offload_csum;
 	u16 mac_offset = skb->mac_header;
 	int mac_len = skb->mac_len;
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	__be16 protocol = skb->protocol;
 	int udp_offset, outer_hlen;
 	unsigned int oldlen;
-	bool need_csum = !!(skb_shinfo(skb)->gso_type &
-			    SKB_GSO_UDP_TUNNEL_CSUM);
-	bool remcsum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM);
-	bool offload_csum = false, dont_encap = (need_csum || remcsum);
 
 	oldlen = (u16)~skb->len;
 
@@ -55,14 +52,18 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
 	skb->protocol = new_protocol;
+
+	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
 	skb->encap_hdr_csum = need_csum;
+
+	remcsum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM);
 	skb->remcsum_offload = remcsum;
 
 	/* Try to offload checksum if possible */
 	offload_csum = !!(need_csum &&
-			  ((skb->dev->features & NETIF_F_HW_CSUM) ||
-			   (skb->dev->features & (is_ipv6 ?
-			    NETIF_F_IPV6_CSUM : NETIF_F_IP_CSUM))));
+			  (skb->dev->features &
+			   (is_ipv6 ? (NETIF_F_HW_CSUM | NETIF_F_IPV6_CSUM) :
+				      (NETIF_F_HW_CSUM | NETIF_F_IP_CSUM))));
 
 	features &= skb->dev->hw_enc_features;
 
@@ -92,13 +93,11 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
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
+
+		/* Set up inner headers if we are offloading inner checksum */
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			skb_reset_inner_headers(skb);
 			skb->encapsulation = 1;
 		}
@@ -122,15 +121,15 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		uh->check = ~csum_fold((__force __wsum)
 				       ((__force u32)uh->check +
 					(__force u32)delta));
-		if (offload_csum) {
-			skb->ip_summed = CHECKSUM_PARTIAL;
-			skb->csum_start = skb_transport_header(skb) - skb->head;
-			skb->csum_offset = offsetof(struct udphdr, check);
-		} else {
-			uh->check = gso_make_checksum(skb, ~uh->check);
 
+		if (skb->encapsulation || !offload_csum) {
+			uh->check = gso_make_checksum(skb, ~uh->check);
 			if (uh->check == 0)
 				uh->check = CSUM_MANGLED_0;
+		} else {
+			skb->ip_summed = CHECKSUM_PARTIAL;
+			skb->csum_start = skb_transport_header(skb) - skb->head;
+			skb->csum_offset = offsetof(struct udphdr, check);
 		}
 	} while ((skb = skb->next));
 out:
