From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH] GSO: Provide software checksum of tunneled UDP
 fragmentation offload
Date: Wed, 24 Feb 2016 16:46:21 -0800
Message-ID: <20160225004621.22152.21938.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33273 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbcBYAqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 19:46:24 -0500
Received: by mail-pa0-f48.google.com with SMTP id fl4so21907671pad.0
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 16:46:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On reviewing the code I realized that GRE and UDP tunnels could cause a
kernel panic if we used GSO to segment a large UDP frame that was sent
through the tunnel with an outer checksum and hardware offloads were not
available.

In order to correct this we need to update the feature flags that are
passed to the skb_segment function so that in the event of UDP
fragmentation being requested for the inner header the segmentation
function will correctly generate the checksum for the payload if we cannot
segment the outer header.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/gre_offload.c |   21 ++++++++++++++++++---
 net/ipv4/udp_offload.c |   15 ++++++++++++---
 net/ipv6/udp_offload.c |    8 +++++++-
 3 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 3333bb8a34c4..632733f18019 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -24,7 +24,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	__be16 protocol = skb->protocol;
 	u16 mac_len = skb->mac_len;
 	int gre_offset, outer_hlen;
-	bool need_csum;
+	bool need_csum, ufo;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
 				~(SKB_GSO_TCPV4 |
@@ -58,8 +58,20 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_GRE_CSUM);
 	skb->encap_hdr_csum = need_csum;
 
+	ufo = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
+
 	features &= skb->dev->hw_enc_features;
 
+	/* The only checksum offload we care about from here on out is the
+	 * outer one so strip the existing checksum feature flags based
+	 * on the fact that we will be computing our checksum in software.
+	 */
+	if (ufo) {
+		features &= ~NETIF_F_CSUM_MASK;
+		if (!need_csum)
+			features |= NETIF_F_HW_CSUM;
+	}
+
 	/* segment inner packet. */
 	segs = skb_mac_gso_segment(skb, features);
 	if (IS_ERR_OR_NULL(segs)) {
@@ -75,8 +87,11 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 		struct gre_base_hdr *greh;
 		__be32 *pcsum;
 
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
+		/* Set up inner headers if we are offloading inner checksum */
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			skb_reset_inner_headers(skb);
+			skb->encapsulation = 1;
+		}
 
 		skb->mac_len = mac_len;
 		skb->protocol = protocol;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 56c4c8b88b28..f5abb1ae1358 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -33,8 +33,8 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	__be16 new_protocol, bool is_ipv6)
 {
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
+	bool remcsum, need_csum, offload_csum, ufo;
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	bool remcsum, need_csum, offload_csum;
 	struct udphdr *uh = udp_hdr(skb);
 	u16 mac_offset = skb->mac_header;
 	__be16 protocol = skb->protocol;
@@ -62,6 +62,8 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	remcsum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM);
 	skb->remcsum_offload = remcsum;
 
+	ufo = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
+
 	/* Try to offload checksum if possible */
 	offload_csum = !!(need_csum &&
 			  (skb->dev->features &
@@ -74,9 +76,9 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	 * outer one so strip the existing checksum feature flags and
 	 * instead set the flag based on our outer checksum offload value.
 	 */
-	if (remcsum) {
+	if (remcsum || ufo) {
 		features &= ~NETIF_F_CSUM_MASK;
-		if (offload_csum)
+		if (!need_csum || offload_csum)
 			features |= NETIF_F_HW_CSUM;
 	}
 
@@ -230,6 +232,13 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 
 	skb->ip_summed = CHECKSUM_NONE;
 
+	/* If there is no outer header we can fake a checksum offload
+	 * due to the fact that we have already done the checksum in
+	 * software prior to segmenting the frame.
+	 */
+	if (!skb->encap_hdr_csum)
+		features |= NETIF_F_HW_CSUM;
+
 	/* Fragment the skb. IP headers of the fragments are updated in
 	 * inet_gso_segment()
 	 */
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 7441e1e63893..2b0fbe6929e8 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -81,12 +81,18 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		csum = skb_checksum(skb, 0, skb->len, 0);
 		uh->check = udp_v6_check(skb->len, &ipv6h->saddr,
 					  &ipv6h->daddr, csum);
-
 		if (uh->check == 0)
 			uh->check = CSUM_MANGLED_0;
 
 		skb->ip_summed = CHECKSUM_NONE;
 
+		/* If there is no outer header we can fake a checksum offload
+		 * due to the fact that we have already done the checksum in
+		 * software prior to segmenting the frame.
+		 */
+		if (!skb->encap_hdr_csum)
+			features |= NETIF_F_HW_CSUM;
+
 		/* Check if there is enough headroom to insert fragment header. */
 		tnl_hlen = skb_tnl_header_len(skb);
 		if (skb->mac_header < (tnl_hlen + frag_hdr_sz)) {
