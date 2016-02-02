From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 1/4] packet: move vnet_hdr code to helper functions
Date: Tue,  2 Feb 2016 10:56:46 -0500
Message-ID: <1454428609-26885-2-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1454428609-26885-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, daniel@iogearbox.net, mst@redhat.com,
	sri@us.ibm.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:35823 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933327AbcBBP4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 10:56:55 -0500
Received: by mail-qg0-f68.google.com with SMTP id b35so11916833qge.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 07:56:54 -0800 (PST)
In-Reply-To: <1454428609-26885-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

packet_snd and packet_rcv support virtio net headers for GSO.
Move this logic into helper functions to be able to reuse it in
tpacket_snd and tpacket_rcv.

This is a straighforward code move with one exception. Instead of
creating and passing a separate gso_type variable, reuse
vnet_hdr.gso_type after conversion from virtio to kernel gso type.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 261 ++++++++++++++++++++++++++++---------------------
 1 file changed, 148 insertions(+), 113 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 992396a..bd3de7b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1960,6 +1960,64 @@ static unsigned int run_filter(struct sk_buff *skb,
 	return res;
 }
 
+static int __packet_rcv_vnet(const struct sk_buff *skb,
+			     struct virtio_net_hdr *vnet_hdr)
+{
+	*vnet_hdr = (const struct virtio_net_hdr) { 0 };
+
+	if (skb_is_gso(skb)) {
+		struct skb_shared_info *sinfo = skb_shinfo(skb);
+
+		/* This is a hint as to how much should be linear. */
+		vnet_hdr->hdr_len =
+			__cpu_to_virtio16(vio_le(), skb_headlen(skb));
+		vnet_hdr->gso_size =
+			__cpu_to_virtio16(vio_le(), sinfo->gso_size);
+
+		if (sinfo->gso_type & SKB_GSO_TCPV4)
+			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+		else if (sinfo->gso_type & SKB_GSO_TCPV6)
+			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+		else if (sinfo->gso_type & SKB_GSO_UDP)
+			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
+		else if (sinfo->gso_type & SKB_GSO_FCOE)
+			return -EINVAL;
+		else
+			BUG();
+
+		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
+			vnet_hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+	} else
+		vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		vnet_hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+		vnet_hdr->csum_start = __cpu_to_virtio16(vio_le(),
+				  skb_checksum_start_offset(skb));
+		vnet_hdr->csum_offset = __cpu_to_virtio16(vio_le(),
+						 skb->csum_offset);
+	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		vnet_hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
+	} /* else everything is zero */
+
+	return 0;
+}
+
+static int packet_rcv_vnet(struct msghdr *msg, const struct sk_buff *skb,
+			   size_t *len)
+{
+	struct virtio_net_hdr vnet_hdr;
+
+	if (*len < sizeof(vnet_hdr))
+		return -EINVAL;
+	*len -= sizeof(vnet_hdr);
+
+	if (__packet_rcv_vnet(skb, &vnet_hdr))
+		return -EINVAL;
+
+	return memcpy_to_msg(msg, (void *)&vnet_hdr, sizeof(vnet_hdr));
+}
+
 /*
  * This function makes lazy skb cloning in hope that most of packets
  * are discarded by BPF.
@@ -2347,6 +2405,84 @@ static void tpacket_set_protocol(const struct net_device *dev,
 	}
 }
 
+static int __packet_snd_vnet_parse(struct virtio_net_hdr *vnet_hdr, size_t len)
+{
+	unsigned short gso_type = 0;
+
+	if ((vnet_hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
+	    (__virtio16_to_cpu(vio_le(), vnet_hdr->csum_start) +
+	     __virtio16_to_cpu(vio_le(), vnet_hdr->csum_offset) + 2 >
+	      __virtio16_to_cpu(vio_le(), vnet_hdr->hdr_len)))
+		vnet_hdr->hdr_len = __cpu_to_virtio16(vio_le(),
+			 __virtio16_to_cpu(vio_le(), vnet_hdr->csum_start) +
+			__virtio16_to_cpu(vio_le(), vnet_hdr->csum_offset) + 2);
+
+	if (__virtio16_to_cpu(vio_le(), vnet_hdr->hdr_len) > len)
+		return -EINVAL;
+
+	if (vnet_hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+		switch (vnet_hdr->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
+		case VIRTIO_NET_HDR_GSO_TCPV4:
+			gso_type = SKB_GSO_TCPV4;
+			break;
+		case VIRTIO_NET_HDR_GSO_TCPV6:
+			gso_type = SKB_GSO_TCPV6;
+			break;
+		case VIRTIO_NET_HDR_GSO_UDP:
+			gso_type = SKB_GSO_UDP;
+			break;
+		default:
+			return -EINVAL;
+		}
+
+		if (vnet_hdr->gso_type & VIRTIO_NET_HDR_GSO_ECN)
+			gso_type |= SKB_GSO_TCP_ECN;
+
+		if (vnet_hdr->gso_size == 0)
+			return -EINVAL;
+	}
+
+	vnet_hdr->gso_type = gso_type;	/* changes type, temporary storage */
+	return 0;
+}
+
+static int packet_snd_vnet_parse(struct msghdr *msg, size_t *len,
+				 struct virtio_net_hdr *vnet_hdr)
+{
+	int n;
+
+	if (*len < sizeof(*vnet_hdr))
+		return -EINVAL;
+	*len -= sizeof(*vnet_hdr);
+
+	n = copy_from_iter(vnet_hdr, sizeof(*vnet_hdr), &msg->msg_iter);
+	if (n != sizeof(*vnet_hdr))
+		return -EFAULT;
+
+	return __packet_snd_vnet_parse(vnet_hdr, *len);
+}
+
+static int packet_snd_vnet_gso(struct sk_buff *skb,
+			       struct virtio_net_hdr *vnet_hdr)
+{
+	if (vnet_hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
+		u16 s = __virtio16_to_cpu(vio_le(), vnet_hdr->csum_start);
+		u16 o = __virtio16_to_cpu(vio_le(), vnet_hdr->csum_offset);
+
+		if (!skb_partial_csum_set(skb, s, o))
+			return -EINVAL;
+	}
+
+	skb_shinfo(skb)->gso_size =
+		__virtio16_to_cpu(vio_le(), vnet_hdr->gso_size);
+	skb_shinfo(skb)->gso_type = vnet_hdr->gso_type;
+
+	/* Header must be checked, and gso_segs computed. */
+	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+	skb_shinfo(skb)->gso_segs = 0;
+	return 0;
+}
+
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		void *frame, struct net_device *dev, int size_max,
 		__be16 proto, unsigned char *addr, int hlen)
@@ -2643,12 +2779,9 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	struct sockcm_cookie sockc;
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int offset = 0;
-	int vnet_hdr_len;
 	struct packet_sock *po = pkt_sk(sk);
-	unsigned short gso_type = 0;
 	int hlen, tlen;
 	int extra_len = 0;
-	ssize_t n;
 
 	/*
 	 *	Get and verify the address.
@@ -2686,53 +2819,9 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	if (sock->type == SOCK_RAW)
 		reserve = dev->hard_header_len;
 	if (po->has_vnet_hdr) {
-		vnet_hdr_len = sizeof(vnet_hdr);
-
-		err = -EINVAL;
-		if (len < vnet_hdr_len)
-			goto out_unlock;
-
-		len -= vnet_hdr_len;
-
-		err = -EFAULT;
-		n = copy_from_iter(&vnet_hdr, vnet_hdr_len, &msg->msg_iter);
-		if (n != vnet_hdr_len)
-			goto out_unlock;
-
-		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
-		    (__virtio16_to_cpu(vio_le(), vnet_hdr.csum_start) +
-		     __virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset) + 2 >
-		      __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len)))
-			vnet_hdr.hdr_len = __cpu_to_virtio16(vio_le(),
-				 __virtio16_to_cpu(vio_le(), vnet_hdr.csum_start) +
-				__virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset) + 2);
-
-		err = -EINVAL;
-		if (__virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len) > len)
+		err = packet_snd_vnet_parse(msg, &len, &vnet_hdr);
+		if (err)
 			goto out_unlock;
-
-		if (vnet_hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-			switch (vnet_hdr.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
-			case VIRTIO_NET_HDR_GSO_TCPV4:
-				gso_type = SKB_GSO_TCPV4;
-				break;
-			case VIRTIO_NET_HDR_GSO_TCPV6:
-				gso_type = SKB_GSO_TCPV6;
-				break;
-			case VIRTIO_NET_HDR_GSO_UDP:
-				gso_type = SKB_GSO_UDP;
-				break;
-			default:
-				goto out_unlock;
-			}
-
-			if (vnet_hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
-				gso_type |= SKB_GSO_TCP_ECN;
-
-			if (vnet_hdr.gso_size == 0)
-				goto out_unlock;
-
-		}
 	}
 
 	if (unlikely(sock_flag(sk, SOCK_NOFCS))) {
@@ -2744,7 +2833,8 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	}
 
 	err = -EMSGSIZE;
-	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN + extra_len))
+	if (!vnet_hdr.gso_type &&
+	    (len > dev->mtu + reserve + VLAN_HLEN + extra_len))
 		goto out_unlock;
 
 	err = -ENOBUFS;
@@ -2775,7 +2865,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 
 	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
-	if (!gso_type && (len > dev->mtu + reserve + extra_len) &&
+	if (!vnet_hdr.gso_type && (len > dev->mtu + reserve + extra_len) &&
 	    !packet_extra_vlan_len_allowed(dev, skb)) {
 		err = -EMSGSIZE;
 		goto out_free;
@@ -2789,24 +2879,10 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	packet_pick_tx_queue(dev, skb);
 
 	if (po->has_vnet_hdr) {
-		if (vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
-			u16 s = __virtio16_to_cpu(vio_le(), vnet_hdr.csum_start);
-			u16 o = __virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset);
-			if (!skb_partial_csum_set(skb, s, o)) {
-				err = -EINVAL;
-				goto out_free;
-			}
-		}
-
-		skb_shinfo(skb)->gso_size =
-			__virtio16_to_cpu(vio_le(), vnet_hdr.gso_size);
-		skb_shinfo(skb)->gso_type = gso_type;
-
-		/* Header must be checked, and gso_segs computed. */
-		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
-		skb_shinfo(skb)->gso_segs = 0;
-
-		len += vnet_hdr_len;
+		err = packet_snd_vnet_gso(skb, &vnet_hdr);
+		if (err)
+			goto out_free;
+		len += sizeof(vnet_hdr);
 	}
 
 	skb_probe_transport_header(skb, reserve);
@@ -3177,51 +3253,10 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		packet_rcv_has_room(pkt_sk(sk), NULL);
 
 	if (pkt_sk(sk)->has_vnet_hdr) {
-		struct virtio_net_hdr vnet_hdr = { 0 };
-
-		err = -EINVAL;
-		vnet_hdr_len = sizeof(vnet_hdr);
-		if (len < vnet_hdr_len)
-			goto out_free;
-
-		len -= vnet_hdr_len;
-
-		if (skb_is_gso(skb)) {
-			struct skb_shared_info *sinfo = skb_shinfo(skb);
-
-			/* This is a hint as to how much should be linear. */
-			vnet_hdr.hdr_len =
-				__cpu_to_virtio16(vio_le(), skb_headlen(skb));
-			vnet_hdr.gso_size =
-				__cpu_to_virtio16(vio_le(), sinfo->gso_size);
-			if (sinfo->gso_type & SKB_GSO_TCPV4)
-				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
-			else if (sinfo->gso_type & SKB_GSO_TCPV6)
-				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
-			else if (sinfo->gso_type & SKB_GSO_UDP)
-				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_UDP;
-			else if (sinfo->gso_type & SKB_GSO_FCOE)
-				goto out_free;
-			else
-				BUG();
-			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
-				vnet_hdr.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
-		} else
-			vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE;
-
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			vnet_hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
-			vnet_hdr.csum_start = __cpu_to_virtio16(vio_le(),
-					  skb_checksum_start_offset(skb));
-			vnet_hdr.csum_offset = __cpu_to_virtio16(vio_le(),
-							 skb->csum_offset);
-		} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-			vnet_hdr.flags = VIRTIO_NET_HDR_F_DATA_VALID;
-		} /* else everything is zero */
-
-		err = memcpy_to_msg(msg, (void *)&vnet_hdr, vnet_hdr_len);
-		if (err < 0)
+		err = packet_rcv_vnet(msg, skb, &len);
+		if (err)
 			goto out_free;
+		vnet_hdr_len = sizeof(struct virtio_net_hdr);
 	}
 
 	/* You lose any data beyond the buffer you gave. If it worries
-- 
2.7.0.rc3.207.g0ac5344
