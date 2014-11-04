From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 2/7] udp: Offload outer UDP tunnel csum if available
Date: Tue,  4 Nov 2014 09:06:52 -0800
Message-ID: <1415120817-2105-3-git-send-email-therbert@google.com>
References: <1415120817-2105-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:64298 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbaKDRH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:07:27 -0500
Received: by mail-ig0-f173.google.com with SMTP id r10so7078205igi.12
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:07:26 -0800 (PST)
In-Reply-To: <1415120817-2105-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __skb_udp_tunnel_segment if outer UDP checksums are enabled and
ip_summed is not already CHECKSUM_PARTIAL, set up checksum offload
if device features allow it.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp_offload.c | 52 ++++++++++++++++++++++++++++++++++----------------
 1 file changed, 36 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 6480cea..a774711 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -29,7 +29,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	netdev_features_t features,
 	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
 					     netdev_features_t features),
-	__be16 new_protocol)
+	__be16 new_protocol, bool is_ipv6)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	u16 mac_offset = skb->mac_header;
@@ -39,7 +39,9 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	netdev_features_t enc_features;
 	int udp_offset, outer_hlen;
 	unsigned int oldlen;
-	bool need_csum;
+	bool need_csum = !!(skb_shinfo(skb)->gso_type &
+			    SKB_GSO_UDP_TUNNEL_CSUM);
+	bool offload_csum = false, dont_encap = need_csum;
 
 	oldlen = (u16)~skb->len;
 
@@ -52,10 +54,12 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
 	skb->protocol = new_protocol;
+	skb->encap_hdr_csum = need_csum;
 
-	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM);
-	if (need_csum)
-		skb->encap_hdr_csum = 1;
+	/* Try to offload checksum if possible */
+	offload_csum = !!(need_csum &&
+			  (skb->dev->features &
+			   (is_ipv6 ? NETIF_F_V6_CSUM : NETIF_F_V4_CSUM)));
 
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & features;
@@ -72,11 +76,21 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	do {
 		struct udphdr *uh;
 		int len;
-
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
+		__be32 delta;
+
+		if (dont_encap) {
+			skb->encapsulation = 0;
+			skb->ip_summed = CHECKSUM_NONE;
+		} else {
+			/* Only set up inner headers if we might be offloading
+			 * inner checksum.
+			 */
+			skb_reset_inner_headers(skb);
+			skb->encapsulation = 1;
+		}
 
 		skb->mac_len = mac_len;
+		skb->protocol = protocol;
 
 		skb_push(skb, outer_hlen);
 		skb_reset_mac_header(skb);
@@ -86,19 +100,25 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		uh = udp_hdr(skb);
 		uh->len = htons(len);
 
-		if (need_csum) {
-			__be32 delta = htonl(oldlen + len);
+		if (!need_csum)
+			continue;
+
+		delta = htonl(oldlen + len);
+
+		uh->check = ~csum_fold((__force __wsum)
+				       ((__force u32)uh->check +
+					(__force u32)delta));
 
-			uh->check = ~csum_fold((__force __wsum)
-					       ((__force u32)uh->check +
-						(__force u32)delta));
+		if (offload_csum) {
+			skb->ip_summed = CHECKSUM_PARTIAL;
+			skb->csum_start = skb_transport_header(skb) - skb->head;
+			skb->csum_offset = offsetof(struct udphdr, check);
+		} else {
 			uh->check = gso_make_checksum(skb, ~uh->check);
 
 			if (uh->check == 0)
 				uh->check = CSUM_MANGLED_0;
 		}
-
-		skb->protocol = protocol;
 	} while ((skb = skb->next));
 out:
 	return segs;
@@ -134,7 +154,7 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	}
 
 	segs = __skb_udp_tunnel_segment(skb, features, gso_inner_segment,
-					protocol);
+					protocol, is_ipv6);
 
 out_unlock:
 	rcu_read_unlock();
-- 
2.1.0.rc2.206.gedb03e5
