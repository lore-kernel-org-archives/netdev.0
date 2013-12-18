From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: [PATCH net-next] ipv4: fix tunneled VM traffic over hw VXLAN/GRE GSO NIC
Date: Wed, 18 Dec 2013 11:02:48 -0800
Message-ID: <1387393368-1028-1-git-send-email-weichunc@plumgrid.com>
Cc: eric.dumazet@gmail.com, ast@plumgrid.com, netdev@vger.kernel.org,
	joseph.gasparakis@intel.com, or.gerlitz@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:45931 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031Ab3LRTCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 14:02:52 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so60003pab.20
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 11:02:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is also seen on 'net'.

VM to VM GSO traffic is broken if it goes through VXLAN or GRE
tunnel and the physical NIC on the host supports hardware VXLAN/GRE
GSO offload (e.g. bnx2x and next-gen mlx4).

Two issues -
(VXLAN) VM traffic has SKB_GSO_DODGY and SKB_GSO_UDP_TUNNEL with
SKB_GSO_TCP/UDP set depending on the inner protocol. GSO header
integrity check fails in udp4_ufo_fragment if inner protocol is
TCP. Also gso_segs is calculated incorrectly using skb->len that
includes tunnel header. Fix: robust check should only be applied
to the inner packet.

(VXLAN & GRE) Once GSO header integrity check passes, NULL segs
is returned and the original skb is sent to hardware. However the
tunnel header is already pulled. Fix: tunnel header needs to be
restored so that hardware can perform GSO properly on the original
packet.

Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
---
 net/ipv4/gre_offload.c |   15 ++++++++++++++-
 net/ipv4/udp.c         |   15 ++++++++++++++-
 net/ipv4/udp_offload.c |   38 ++++++++++++++++++++------------------
 3 files changed, 48 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index e5d4361..c7cea5b 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -28,6 +28,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	netdev_features_t enc_features;
 	int ghl = GRE_HEADER_SECTION;
 	struct gre_base_hdr *greh;
+	u16 mac_offset = skb->mac_header;
 	int mac_len = skb->mac_len;
 	__be16 protocol = skb->protocol;
 	int tnl_hlen;
@@ -73,7 +74,19 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	segs = skb_mac_gso_segment(skb, enc_features);
-	if (!segs || IS_ERR(segs))
+	/* Verifying header integrity only. */
+	if (!segs) {
+		skb->protocol = protocol;
+		skb->encapsulation = 1;
+		skb_push(skb, ghl);
+		skb_reset_transport_header(skb);
+		skb->mac_header = mac_offset;
+		skb->network_header = skb->mac_header + mac_len;
+		skb->mac_len = mac_len;
+		goto out;
+	}
+
+	if (IS_ERR(segs))
 		goto out;
 
 	skb = segs;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 44f6a20..c9ec121 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2474,6 +2474,7 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 				       netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	u16 mac_offset = skb->mac_header;
 	int mac_len = skb->mac_len;
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	__be16 protocol = skb->protocol;
@@ -2493,7 +2494,19 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	segs = skb_mac_gso_segment(skb, enc_features);
-	if (!segs || IS_ERR(segs))
+	/* Verifying header integrity only. */
+	if (!segs) {
+		skb->encapsulation = 1;
+		skb_push(skb, tnl_hlen);
+		skb_reset_transport_header(skb);
+		skb->mac_header = mac_offset;
+		skb->network_header = skb->mac_header + mac_len;
+		skb->mac_len = mac_len;
+		skb->protocol = protocol;
+		goto out;
+	}
+
+	if (IS_ERR(segs))
 		goto out;
 
 	outer_hlen = skb_tnl_header_len(skb);
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 83206de..bd09f65 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -41,6 +41,14 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	unsigned int mss;
+	int offset;
+	__wsum csum;
+
+	if (skb->encapsulation &&
+	    skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) {
+		segs = skb_udp_tunnel_segment(skb, features);
+		goto out;
+	}
 
 	mss = skb_shinfo(skb)->gso_size;
 	if (unlikely(skb->len <= mss))
@@ -63,27 +71,21 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 		goto out;
 	}
 
+	/* Do software UFO. Complete and fill in the UDP checksum as
+	 * HW cannot do checksum of UDP packets sent as multiple
+	 * IP fragments.
+	 */
+	offset = skb_checksum_start_offset(skb);
+	csum = skb_checksum(skb, offset, skb->len - offset, 0);
+	offset += skb->csum_offset;
+	*(__sum16 *)(skb->data + offset) = csum_fold(csum);
+	skb->ip_summed = CHECKSUM_NONE;
+
 	/* Fragment the skb. IP headers of the fragments are updated in
 	 * inet_gso_segment()
 	 */
-	if (skb->encapsulation && skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL)
-		segs = skb_udp_tunnel_segment(skb, features);
-	else {
-		int offset;
-		__wsum csum;
-
-		/* Do software UFO. Complete and fill in the UDP checksum as
-		 * HW cannot do checksum of UDP packets sent as multiple
-		 * IP fragments.
-		 */
-		offset = skb_checksum_start_offset(skb);
-		csum = skb_checksum(skb, offset, skb->len - offset, 0);
-		offset += skb->csum_offset;
-		*(__sum16 *)(skb->data + offset) = csum_fold(csum);
-		skb->ip_summed = CHECKSUM_NONE;
-
-		segs = skb_segment(skb, features);
-	}
+	segs = skb_segment(skb, features);
+
 out:
 	return segs;
 }
-- 
1.7.9.5
