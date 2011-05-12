From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next V3] net: af_packet: Untangle packet_snd by adding vpacket_snd
Date: Thu, 12 May 2011 16:25:30 -0700
Message-ID: <b174c9df4b7c39b4e951f1f309a4fd9086179c3c.1305242549.git.joe@perches.com>
References: <20110512.175959.1343349350164758016.davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110512.175959.1343349350164758016.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current packet_snd handles both vlan and non-vlan frames
with initialization of a struct virtio_net_hdr that is unused
by non-vlan frames.

Create a new vpacket_snd that uses this virtio_net_hdr and
remove it and the vlan and gso logic from packet_snd.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/packet/af_packet.c |  250 ++++++++++++++++++++++++++++++++----------------
 1 files changed, 169 insertions(+), 81 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 549527b..d4bcf51 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1113,42 +1113,38 @@ static inline struct sk_buff *packet_alloc_skb(struct sock *sk, size_t prepad,
 	return skb;
 }
 
-static int packet_snd(struct socket *sock,
-			  struct msghdr *msg, size_t len)
+static int vpacket_snd(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
 	unsigned char *addr;
 	int ifindex, err, reserve = 0;
-	struct virtio_net_hdr vnet_hdr = { 0 };
-	int offset = 0;
+	struct virtio_net_hdr vnet_hdr;
+	int offset;
 	int vnet_hdr_len;
 	struct packet_sock *po = pkt_sk(sk);
 	unsigned short gso_type = 0;
+	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 
-	/*
-	 *	Get and verify the address.
-	 */
-
-	if (saddr == NULL) {
-		ifindex	= po->ifindex;
-		proto	= po->num;
-		addr	= NULL;
+	/* Get and verify the address */
+	if (!saddr) {
+		ifindex = po->ifindex;
+		proto = po->num;
+		addr = NULL;
 	} else {
 		err = -EINVAL;
 		if (msg->msg_namelen < sizeof(struct sockaddr_ll))
 			goto out;
-		if (msg->msg_namelen < (saddr->sll_halen + offsetof(struct sockaddr_ll, sll_addr)))
+		if (msg->msg_namelen < (saddr->sll_halen +
+					offsetof(struct sockaddr_ll, sll_addr)))
 			goto out;
-		ifindex	= saddr->sll_ifindex;
-		proto	= saddr->sll_protocol;
-		addr	= saddr->sll_addr;
+		ifindex = saddr->sll_ifindex;
+		proto = saddr->sll_protocol;
+		addr = saddr->sll_addr;
 	}
 
-
 	dev = dev_get_by_index(sock_net(sk), ifindex);
 	err = -ENXIO;
 	if (dev == NULL)
@@ -1160,52 +1156,47 @@ static int packet_snd(struct socket *sock,
 	if (!(dev->flags & IFF_UP))
 		goto out_unlock;
 
-	if (po->has_vnet_hdr) {
-		vnet_hdr_len = sizeof(vnet_hdr);
+	vnet_hdr_len = sizeof(vnet_hdr);
 
-		err = -EINVAL;
-		if (len < vnet_hdr_len)
-			goto out_unlock;
-
-		len -= vnet_hdr_len;
+	err = -EINVAL;
+	if (len < vnet_hdr_len)
+		goto out_unlock;
 
-		err = memcpy_fromiovec((void *)&vnet_hdr, msg->msg_iov,
-				       vnet_hdr_len);
-		if (err < 0)
-			goto out_unlock;
+	len -= vnet_hdr_len;
 
-		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
-		    (vnet_hdr.csum_start + vnet_hdr.csum_offset + 2 >
-		      vnet_hdr.hdr_len))
-			vnet_hdr.hdr_len = vnet_hdr.csum_start +
-						 vnet_hdr.csum_offset + 2;
+	err = memcpy_fromiovec((void *)&vnet_hdr, msg->msg_iov, vnet_hdr_len);
+	if (err < 0)
+		goto out_unlock;
 
-		err = -EINVAL;
-		if (vnet_hdr.hdr_len > len)
-			goto out_unlock;
+	if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
+	    (vnet_hdr.csum_start + vnet_hdr.csum_offset + 2 > vnet_hdr.hdr_len))
+		vnet_hdr.hdr_len = (vnet_hdr.csum_start +
+				    vnet_hdr.csum_offset + 2);
 
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
+	err = -EINVAL;
+	if (vnet_hdr.hdr_len > len)
+		goto out_unlock;
 
-			if (vnet_hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
-				gso_type |= SKB_GSO_TCP_ECN;
+	if (vnet_hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+		switch (vnet_hdr.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
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
+			goto out_unlock;
+		}
 
-			if (vnet_hdr.gso_size == 0)
-				goto out_unlock;
+		if (vnet_hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
+			gso_type |= SKB_GSO_TCP_ECN;
 
-		}
+		if (vnet_hdr.gso_size == 0)
+			goto out_unlock;
 	}
 
 	err = -EMSGSIZE;
@@ -1216,15 +1207,19 @@ static int packet_snd(struct socket *sock,
 	skb = packet_alloc_skb(sk, LL_ALLOCATED_SPACE(dev),
 			       LL_RESERVED_SPACE(dev), len, vnet_hdr.hdr_len,
 			       msg->msg_flags & MSG_DONTWAIT, &err);
-	if (skb == NULL)
+	if (!skb)
 		goto out_unlock;
 
 	skb_set_network_header(skb, reserve);
 
 	err = -EINVAL;
-	if (sock->type == SOCK_DGRAM &&
-	    (offset = dev_hard_header(skb, dev, ntohs(proto), addr, NULL, len)) < 0)
-		goto out_free;
+	if (sock->type == SOCK_DGRAM) {
+		offset = dev_hard_header(skb, dev, ntohs(proto), addr,
+					 NULL, len);
+		if (offset < 0)
+			goto out_free;
+	} else
+		offset = 0;
 
 	/* Returns -EFAULT on error */
 	err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov, 0, len);
@@ -1253,33 +1248,123 @@ static int packet_snd(struct socket *sock,
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
-	if (po->has_vnet_hdr) {
-		if (vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
-			if (!skb_partial_csum_set(skb, vnet_hdr.csum_start,
-						  vnet_hdr.csum_offset)) {
-				err = -EINVAL;
-				goto out_free;
-			}
+	if (vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
+		if (!skb_partial_csum_set(skb, vnet_hdr.csum_start,
+					  vnet_hdr.csum_offset)) {
+			err = -EINVAL;
+			goto out_free;
 		}
+	}
+
+	skb_shinfo(skb)->gso_size = vnet_hdr.gso_size;
+	skb_shinfo(skb)->gso_type = gso_type;
 
-		skb_shinfo(skb)->gso_size = vnet_hdr.gso_size;
-		skb_shinfo(skb)->gso_type = gso_type;
+	/* Header must be checked, and gso_segs computed */
+	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+	skb_shinfo(skb)->gso_segs = 0;
 
-		/* Header must be checked, and gso_segs computed. */
-		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
-		skb_shinfo(skb)->gso_segs = 0;
+	len += vnet_hdr_len;
 
-		len += vnet_hdr_len;
+	/* Now send it */
+	err = dev_queue_xmit(skb);
+	if (err > 0) {
+		err = net_xmit_errno(err);
+		if (err)
+			goto out_unlock;
 	}
 
-	/*
-	 *	Now send it
-	 */
+	dev_put(dev);
 
-	err = dev_queue_xmit(skb);
-	if (err > 0 && (err = net_xmit_errno(err)) != 0)
+	return len;
+
+out_free:
+	kfree_skb(skb);
+out_unlock:
+	if (dev)
+		dev_put(dev);
+out:
+	return err;
+}
+
+static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+	struct sk_buff *skb;
+	struct net_device *dev;
+	__be16 proto;
+	unsigned char *addr;
+	int ifindex, err, reserve = 0;
+	int offset;
+	struct packet_sock *po = pkt_sk(sk);
+	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
+
+	/* Get and verify the address */
+	if (!saddr) {
+		ifindex = po->ifindex;
+		proto = po->num;
+		addr = NULL;
+	} else {
+		err = -EINVAL;
+		if (msg->msg_namelen < sizeof(struct sockaddr_ll))
+			goto out;
+		if (msg->msg_namelen < (saddr->sll_halen +
+					offsetof(struct sockaddr_ll, sll_addr)))
+			goto out;
+		ifindex = saddr->sll_ifindex;
+		proto = saddr->sll_protocol;
+		addr = saddr->sll_addr;
+	}
+
+	dev = dev_get_by_index(sock_net(sk), ifindex);
+	err = -ENXIO;
+	if (dev == NULL)
+		goto out_unlock;
+	if (sock->type == SOCK_RAW)
+		reserve = dev->hard_header_len;
+
+	err = -ENETDOWN;
+	if (!(dev->flags & IFF_UP))
+		goto out_unlock;
+
+	err = -ENOBUFS;
+	skb = packet_alloc_skb(sk, LL_ALLOCATED_SPACE(dev),
+			       LL_RESERVED_SPACE(dev), len, 0,
+			       msg->msg_flags & MSG_DONTWAIT, &err);
+	if (!skb)
 		goto out_unlock;
 
+	skb_set_network_header(skb, reserve);
+
+	err = -EINVAL;
+	if (sock->type == SOCK_DGRAM) {
+		offset = dev_hard_header(skb, dev, ntohs(proto), addr,
+					 NULL, len);
+		if (offset < 0)
+			goto out_free;
+	} else
+		offset = 0;
+
+	/* Returns -EFAULT on error */
+	err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov, 0, len);
+	if (err)
+		goto out_free;
+	err = sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
+	if (err < 0)
+		goto out_free;
+
+	skb->protocol = proto;
+	skb->dev = dev;
+	skb->priority = sk->sk_priority;
+	skb->mark = sk->sk_mark;
+
+	/* Now send it */
+	err = dev_queue_xmit(skb);
+	if (err > 0) {
+		err = net_xmit_errno(err);
+		if (err)
+			goto out_unlock;
+	}
+
 	dev_put(dev);
 
 	return len;
@@ -1294,14 +1379,17 @@ out:
 }
 
 static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
-		struct msghdr *msg, size_t len)
+			  struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
+
 	if (po->tx_ring.pg_vec)
 		return tpacket_snd(po, msg);
-	else
-		return packet_snd(sock, msg, len);
+	else if (po->has_vnet_hdr)
+		return vpacket_snd(sock, msg, len);
+
+	return packet_snd(sock, msg, len);
 }
 
 /*
-- 
1.7.5.rc3.dirty
