From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6] packet: Add GSO/checksum offload support to
 af_packet sockets
Date: Tue, 26 Jan 2010 12:30:19 -0800
Message-ID: <1264537819.24933.122.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:48467 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799Ab0AZUa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 15:30:28 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0QKKsMR030473
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 15:20:54 -0500
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0QKUP63127476
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 15:30:26 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0QKWTd2027058
	for <netdev@vger.kernel.org>; Tue, 26 Jan 2010 13:32:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds GSO/checksum offload to af_packet sockets using
virtio_net_hdr. Based on Rusty's patch to add this support to tun.
It allows GSO/checksum offload to be enabled when using raw socket
backend with virtio_net.
Adds PACKET_VNET_HDR socket option to prepend virtio_net_hdr in the
receive path and process/skip virtio_net_hdr in the send path. This
option is only allowed with SOCK_RAW sockets attached to ethernet
type devices.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 4021d47..aa57a5f 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -46,6 +46,7 @@ struct sockaddr_ll {
 #define PACKET_RESERVE			12
 #define PACKET_TX_RING			13
 #define PACKET_LOSS			14
+#define PACKET_VNET_HDR			15
 
 struct tpacket_stats {
 	unsigned int	tp_packets;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 53633c5..36d5360 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -80,6 +80,8 @@
 #include <linux/init.h>
 #include <linux/mutex.h>
 #include <linux/if_vlan.h>
+#include <linux/virtio_net.h>
+#include <linux/if_arp.h>
 
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -193,7 +195,8 @@ struct packet_sock {
 	struct mutex		pg_vec_lock;
 	unsigned int		running:1,	/* prot_hook is attached*/
 				auxdata:1,
-				origdev:1;
+				origdev:1,
+				vnet_hdr:1;
 	int			ifindex;	/* bound device		*/
 	__be16			num;
 	struct packet_mclist	*mclist;
@@ -1056,6 +1059,30 @@ out:
 }
 #endif
 
+static inline struct sk_buff *packet_alloc_skb(struct sock *sk, size_t prepad,
+					       size_t reserve, size_t len,
+					       size_t linear, int noblock,
+					       int *err)
+{
+	struct sk_buff *skb;
+
+	/* Under a page?  Don't bother with paged skb. */
+	if (prepad + len < PAGE_SIZE || !linear)
+		linear = len;
+
+	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
+				   err);
+	if (!skb)
+		return NULL;
+
+	skb_reserve(skb, reserve);
+	skb_put(skb, linear);
+	skb->data_len = len - linear;
+	skb->len += len - linear;
+
+	return skb;
+}
+
 static int packet_snd(struct socket *sock,
 			  struct msghdr *msg, size_t len)
 {
@@ -1066,14 +1093,15 @@ static int packet_snd(struct socket *sock,
 	__be16 proto;
 	unsigned char *addr;
 	int ifindex, err, reserve = 0;
+	struct virtio_net_hdr vnethdr = { 0 };
+	int offset = 0;
+	struct packet_sock *po = pkt_sk(sk);
 
 	/*
 	 *	Get and verify the address.
 	 */
 
 	if (saddr == NULL) {
-		struct packet_sock *po = pkt_sk(sk);
-
 		ifindex	= po->ifindex;
 		proto	= po->num;
 		addr	= NULL;
@@ -1100,25 +1128,52 @@ static int packet_snd(struct socket *sock,
 	if (!(dev->flags & IFF_UP))
 		goto out_unlock;
 
-	err = -EMSGSIZE;
-	if (len > dev->mtu+reserve)
-		goto out_unlock;
+	if (po->vnet_hdr) {
+		err = -EINVAL;
+		if (dev->type != ARPHRD_ETHER)
+			goto out_unlock;
+
+		if (len < sizeof(vnethdr))
+			goto out_unlock;
 
-	skb = sock_alloc_send_skb(sk, len + LL_ALLOCATED_SPACE(dev),
-				msg->msg_flags & MSG_DONTWAIT, &err);
+		len -= sizeof(vnethdr);
+
+		err = -EFAULT;
+		if (memcpy_fromiovec((void *)&vnethdr, msg->msg_iov,
+					sizeof(vnethdr))) 
+			goto out_unlock;
+	
+		if ((vnethdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
+		    (vnethdr.csum_start + vnethdr.csum_offset + 2 >
+		      vnethdr.hdr_len))
+			vnethdr.hdr_len = vnethdr.csum_start +
+						 vnethdr.csum_offset + 2;
+
+		err = -EINVAL;
+		if (vnethdr.hdr_len > len)
+			goto out_unlock;
+	} else {
+		err = -EMSGSIZE;
+		if (len > dev->mtu+reserve)
+			goto out_unlock;
+	}
+
+	err = -ENOBUFS;
+	skb = packet_alloc_skb(sk, LL_ALLOCATED_SPACE(dev),
+			       LL_RESERVED_SPACE(dev), len, vnethdr.hdr_len,
+			       msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto out_unlock;
 
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
-	skb_reset_network_header(skb);
+	skb_set_network_header(skb, reserve);
 
 	err = -EINVAL;
 	if (sock->type == SOCK_DGRAM &&
-	    dev_hard_header(skb, dev, ntohs(proto), addr, NULL, len) < 0)
+	    (offset = dev_hard_header(skb, dev, ntohs(proto), addr, NULL, len)) < 0)
 		goto out_free;
 
 	/* Returns -EFAULT on error */
-	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	err = skb_copy_datagram_from_iovec(skb, offset, msg->msg_iov, 0, len);
 	if (err)
 		goto out_free;
 
@@ -1127,6 +1182,51 @@ static int packet_snd(struct socket *sock,
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
+	if (po->vnet_hdr) {
+		skb_reset_mac_header(skb);
+		skb->protocol = eth_hdr(skb)->h_proto;
+
+		if (vnethdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
+			if (!skb_partial_csum_set(skb, vnethdr.csum_start,
+						  vnethdr.csum_offset)) {
+				err = -EINVAL;
+				goto out_free;
+			}
+		}
+
+		if (vnethdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+			switch (vnethdr.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
+			case VIRTIO_NET_HDR_GSO_TCPV4:
+				skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+				break;
+			case VIRTIO_NET_HDR_GSO_TCPV6:
+				skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+				break;
+			case VIRTIO_NET_HDR_GSO_UDP:
+				skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+				break;
+			default:
+				err = -EINVAL;
+				goto out_free;
+			}
+
+			if (vnethdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
+				skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
+
+			skb_shinfo(skb)->gso_size = vnethdr.gso_size;
+			if (skb_shinfo(skb)->gso_size == 0) {
+				err = -EINVAL;
+				goto out_free;
+                	}
+
+			/* Header must be checked, and gso_segs computed. */
+			skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+			skb_shinfo(skb)->gso_segs = 0;
+		}
+
+		len += sizeof(vnethdr);
+	}
+
 	/*
 	 *	Now send it
 	 */
@@ -1420,6 +1520,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int copied, err;
 	struct sockaddr_ll *sll;
+	int vnet_hdr_len = 0;
 
 	err = -EINVAL;
 	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
@@ -1451,6 +1552,44 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (skb == NULL)
 		goto out;
 
+	if (pkt_sk(sk)->vnet_hdr) {
+		struct virtio_net_hdr vnethdr = { 0 };
+
+		vnet_hdr_len = sizeof(vnethdr);
+		if ((len -= vnet_hdr_len) < 0)
+			return -EINVAL;
+
+		if (skb_is_gso(skb)) {
+			struct skb_shared_info *sinfo = skb_shinfo(skb);
+
+			/* This is a hint as to how much should be linear. */
+			vnethdr.hdr_len = skb_headlen(skb);
+			vnethdr.gso_size = sinfo->gso_size;
+			if (sinfo->gso_type & SKB_GSO_TCPV4)
+				vnethdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+			else if (sinfo->gso_type & SKB_GSO_TCPV6)
+				vnethdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+			else if (sinfo->gso_type & SKB_GSO_UDP)
+				vnethdr.gso_type = VIRTIO_NET_HDR_GSO_UDP;
+			else
+				BUG();
+			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
+				vnethdr.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+		} else
+			vnethdr.gso_type = VIRTIO_NET_HDR_GSO_NONE;
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			vnethdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+			vnethdr.csum_start = skb->csum_start - skb_headroom(skb);
+			vnethdr.csum_offset = skb->csum_offset;
+		} /* else everything is zero */
+
+		if (unlikely(memcpy_toiovec(msg->msg_iov, (void *)&vnethdr,
+					    sizeof(vnethdr)))) {
+			return -EFAULT;
+		}
+	}
+
 	/*
 	 *	If the address length field is there to be filled in, we fill
 	 *	it in now.
@@ -1502,7 +1641,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 *	Free or return the buffer as appropriate. Again this
 	 *	hides all the races and re-entrancy issues from us.
 	 */
-	err = (flags&MSG_TRUNC) ? skb->len : copied;
+	err = vnet_hdr_len + ((flags&MSG_TRUNC) ? skb->len : copied);
 
 out_free:
 	skb_free_datagram(sk, skb);
@@ -1826,6 +1965,22 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		po->origdev = !!val;
 		return 0;
 	}
+	case PACKET_VNET_HDR:
+	{
+		int val;
+
+		if (sock->type != SOCK_RAW)
+			return -EINVAL;
+		if (po->rx_ring.pg_vec || po->tx_ring.pg_vec)	
+			return -EBUSY;
+		if (optlen < sizeof(val))
+			return -EINVAL;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+
+		po->vnet_hdr = !!val;
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -1876,6 +2031,13 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 
 		data = &val;
 		break;
+	case PACKET_VNET_HDR:
+		if (len > sizeof(int))
+			len = sizeof(int);
+		val = po->vnet_hdr;
+
+		data = &val;
+		break;
 #ifdef CONFIG_PACKET_MMAP
 	case PACKET_VERSION:
 		if (len > sizeof(int))


