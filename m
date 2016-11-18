From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next v2 4/5] af_packet: Use virtio_net_hdr_to_skb().
Date: Fri, 18 Nov 2016 15:40:41 -0800
Message-ID: <1479512442-61601-4-git-send-email-jarno@ovn.org>
References: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:53071 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753169AbcKRXk7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 18:40:59 -0500
In-Reply-To: <1479512442-61601-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the common virtio_net_hdr_to_skb() instead of open coding it.
Other call sites were changed by commit fd2a0437dc, but this one was
missed, maybe because it is split in two parts of the source code.

Interim comparisons of 'vnet_hdr->gso_type' still work as both the
vnet_hdr and skb notion of gso_type is zero when there is no gso.

Fixes: fd2a0437dc ("virtio_net: introduce virtio_net_hdr_{from,to}_skb")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/packet/af_packet.c | 51 +++-----------------------------------------------
 1 file changed, 3 insertions(+), 48 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index abe6c0b..1816b77 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2388,8 +2388,6 @@ static void tpacket_set_protocol(const struct net_device *dev,
 
 static int __packet_snd_vnet_parse(struct virtio_net_hdr *vnet_hdr, size_t len)
 {
-	unsigned short gso_type = 0;
-
 	if ((vnet_hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
 	    (__virtio16_to_cpu(vio_le(), vnet_hdr->csum_start) +
 	     __virtio16_to_cpu(vio_le(), vnet_hdr->csum_offset) + 2 >
@@ -2401,29 +2399,6 @@ static int __packet_snd_vnet_parse(struct virtio_net_hdr *vnet_hdr, size_t len)
 	if (__virtio16_to_cpu(vio_le(), vnet_hdr->hdr_len) > len)
 		return -EINVAL;
 
-	if (vnet_hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		switch (vnet_hdr->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
-		case VIRTIO_NET_HDR_GSO_TCPV4:
-			gso_type = SKB_GSO_TCPV4;
-			break;
-		case VIRTIO_NET_HDR_GSO_TCPV6:
-			gso_type = SKB_GSO_TCPV6;
-			break;
-		case VIRTIO_NET_HDR_GSO_UDP:
-			gso_type = SKB_GSO_UDP;
-			break;
-		default:
-			return -EINVAL;
-		}
-
-		if (vnet_hdr->gso_type & VIRTIO_NET_HDR_GSO_ECN)
-			gso_type |= SKB_GSO_TCP_ECN;
-
-		if (vnet_hdr->gso_size == 0)
-			return -EINVAL;
-	}
-
-	vnet_hdr->gso_type = gso_type;	/* changes type, temporary storage */
 	return 0;
 }
 
@@ -2443,27 +2418,6 @@ static int packet_snd_vnet_parse(struct msghdr *msg, size_t *len,
 	return __packet_snd_vnet_parse(vnet_hdr, *len);
 }
 
-static int packet_snd_vnet_gso(struct sk_buff *skb,
-			       struct virtio_net_hdr *vnet_hdr)
-{
-	if (vnet_hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
-		u16 s = __virtio16_to_cpu(vio_le(), vnet_hdr->csum_start);
-		u16 o = __virtio16_to_cpu(vio_le(), vnet_hdr->csum_offset);
-
-		if (!skb_partial_csum_set(skb, s, o))
-			return -EINVAL;
-	}
-
-	skb_shinfo(skb)->gso_size =
-		__virtio16_to_cpu(vio_le(), vnet_hdr->gso_size);
-	skb_shinfo(skb)->gso_type = vnet_hdr->gso_type;
-
-	/* Header must be checked, and gso_segs computed. */
-	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
-	skb_shinfo(skb)->gso_segs = 0;
-	return 0;
-}
-
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		void *frame, struct net_device *dev, void *data, int tp_len,
 		__be16 proto, unsigned char *addr, int hlen, int copylen,
@@ -2723,7 +2677,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			}
 		}
 
-		if (po->has_vnet_hdr && packet_snd_vnet_gso(skb, vnet_hdr)) {
+		if (po->has_vnet_hdr && virtio_net_hdr_to_skb(skb, vnet_hdr,
+							      vio_le())) {
 			tp_len = -EINVAL;
 			goto tpacket_error;
 		}
@@ -2914,7 +2869,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	packet_pick_tx_queue(dev, skb);
 
 	if (po->has_vnet_hdr) {
-		err = packet_snd_vnet_gso(skb, &vnet_hdr);
+		err = virtio_net_hdr_to_skb(skb, &vnet_hdr, vio_le());
 		if (err)
 			goto out_free;
 		len += sizeof(vnet_hdr);
-- 
2.1.4
