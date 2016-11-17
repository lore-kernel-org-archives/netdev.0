From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next] af_packet: Use virtio_net_hdr_to_skb().
Date: Wed, 16 Nov 2016 18:23:08 -0800
Message-ID: <1479349388-46843-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:49320 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752377AbcKQCXZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 21:23:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the common virtio_net_hdr_to_skb() instead of open coding it.
Other call sites were changed by commit fd2a0437dc, but this one was
missed, maybe because it is split in two parts of the source code.

Also fix other call sites to be more uniform.

Fixes: fd2a0437dc ("virtio_net: introduce virtio_net_hdr_{from,to}_skb")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 drivers/net/macvtap.c      |  5 ++---
 drivers/net/tun.c          | 12 ++++--------
 include/linux/virtio_net.h |  2 +-
 net/packet/af_packet.c     | 44 +-------------------------------------------
 4 files changed, 8 insertions(+), 55 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 070e329..5da9861 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -821,9 +821,8 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		if (iov_iter_count(iter) < vnet_hdr_len)
 			return -EINVAL;
 
-		ret = virtio_net_hdr_from_skb(skb, &vnet_hdr,
-					      macvtap_is_little_endian(q));
-		if (ret)
+		if (virtio_net_hdr_from_skb(skb, &vnet_hdr,
+					    macvtap_is_little_endian(q)))
 			BUG();
 
 		if (copy_to_iter(&vnet_hdr, sizeof(vnet_hdr), iter) !=
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 9328568..864aae3 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1252,8 +1252,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		return -EFAULT;
 	}
 
-	err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
-	if (err) {
+	if (virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun))) {
 		this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
 		kfree_skb(skb);
 		return -EINVAL;
@@ -1361,15 +1360,12 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	}
 
 	if (vnet_hdr_sz) {
-		struct virtio_net_hdr gso = { 0 }; /* no info leak */
-		int ret;
-
+		struct virtio_net_hdr gso;
 		if (iov_iter_count(iter) < vnet_hdr_sz)
 			return -EINVAL;
 
-		ret = virtio_net_hdr_from_skb(skb, &gso,
-					      tun_is_little_endian(tun));
-		if (ret) {
+		if (virtio_net_hdr_from_skb(skb, &gso,
+					    tun_is_little_endian(tun))) {
 			struct skb_shared_info *sinfo = skb_shinfo(skb);
 			pr_err("unexpected GSO type: "
 			       "0x%x, gso_size %d, hdr_len %d\n",
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 1c912f8..74f1e33 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -98,4 +98,4 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 	return 0;
 }
 
-#endif /* _LINUX_VIRTIO_BYTEORDER */
+#endif /* _LINUX_VIRTIO_NET_H */
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 11db0d6..09abb88 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1971,8 +1971,6 @@ static unsigned int run_filter(struct sk_buff *skb,
 static int __packet_rcv_vnet(const struct sk_buff *skb,
 			     struct virtio_net_hdr *vnet_hdr)
 {
-	*vnet_hdr = (const struct virtio_net_hdr) { 0 };
-
 	if (virtio_net_hdr_from_skb(skb, vnet_hdr, vio_le()))
 		BUG();
 
@@ -2391,8 +2389,6 @@ static void tpacket_set_protocol(const struct net_device *dev,
 
 static int __packet_snd_vnet_parse(struct virtio_net_hdr *vnet_hdr, size_t len)
 {
-	unsigned short gso_type = 0;
-
 	if ((vnet_hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
 	    (__virtio16_to_cpu(vio_le(), vnet_hdr->csum_start) +
 	     __virtio16_to_cpu(vio_le(), vnet_hdr->csum_offset) + 2 >
@@ -2404,29 +2400,6 @@ static int __packet_snd_vnet_parse(struct virtio_net_hdr *vnet_hdr, size_t len)
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
 
@@ -2449,22 +2422,7 @@ static int packet_snd_vnet_parse(struct msghdr *msg, size_t *len,
 static int packet_snd_vnet_gso(struct sk_buff *skb,
 			       struct virtio_net_hdr *vnet_hdr)
 {
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
+	return virtio_net_hdr_to_skb(skb, vnet_hdr, vio_le());
 }
 
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
-- 
2.1.4
