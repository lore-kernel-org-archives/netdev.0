From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: [PATCH net REPOST] ipv4: fix tunneled VM traffic over hw VXLAN/GRE GSO NIC
Date: Tue, 31 Dec 2013 14:52:27 -0800
Message-ID: <1388530347-4850-1-git-send-email-weichunc@plumgrid.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org, or.gerlitz@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:57857 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756481Ab3LaWwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 17:52:33 -0500
Received: by mail-pa0-f45.google.com with SMTP id fb1so13175851pad.32
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 14:52:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 include/linux/netdevice.h |   13 +++++++++++++
 net/ipv4/gre_offload.c    |   11 +++++++----
 net/ipv4/udp.c            |    6 +++++-
 net/ipv4/udp_offload.c    |   37 +++++++++++++++++++------------------
 4 files changed, 44 insertions(+), 23 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d9a550b..e59518a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3008,6 +3008,19 @@ static inline void netif_set_gso_max_size(struct net_device *dev,
 	dev->gso_max_size = size;
 }
 
+static inline void skb_gso_error_unwind(struct sk_buff *skb, __be16 protocol,
+					int pulled_hlen, u16 mac_offset,
+					int mac_len)
+{
+	skb->protocol = protocol;
+	skb->encapsulation = 1;
+	skb_push(skb, pulled_hlen);
+	skb_reset_transport_header(skb);
+	skb->mac_header = mac_offset;
+	skb->network_header = skb->mac_header + mac_len;
+	skb->mac_len = mac_len;
+}
+
 static inline bool netif_is_macvlan(struct net_device *dev)
 {
 	return dev->priv_flags & IFF_MACVLAN;
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index e5d4361..2cd02f3 100644
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
@@ -58,13 +59,13 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	} else
 		csum = false;
 
+	if (unlikely(!pskb_may_pull(skb, ghl)))
+		goto out;
+
 	/* setup inner skb. */
 	skb->protocol = greh->protocol;
 	skb->encapsulation = 0;
 
-	if (unlikely(!pskb_may_pull(skb, ghl)))
-		goto out;
-
 	__skb_pull(skb, ghl);
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
@@ -73,8 +74,10 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	segs = skb_mac_gso_segment(skb, enc_features);
-	if (!segs || IS_ERR(segs))
+	if (!segs || IS_ERR(segs)) {
+		skb_gso_error_unwind(skb, protocol, ghl, mac_offset, mac_len);
 		goto out;
+	}
 
 	skb = segs;
 	tnl_hlen = skb_tnl_header_len(skb);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f140048..a7e4729 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2478,6 +2478,7 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 				       netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	u16 mac_offset = skb->mac_header;
 	int mac_len = skb->mac_len;
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	__be16 protocol = skb->protocol;
@@ -2497,8 +2498,11 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	segs = skb_mac_gso_segment(skb, enc_features);
-	if (!segs || IS_ERR(segs))
+	if (!segs || IS_ERR(segs)) {
+		skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
+				     mac_len);
 		goto out;
+	}
 
 	outer_hlen = skb_tnl_header_len(skb);
 	skb = segs;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 83206de..79c62bd 100644
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
@@ -63,27 +71,20 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
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
 out:
 	return segs;
 }
-- 
1.7.9.5
