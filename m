From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 4/4] packet: tpacket_snd gso and checksum offload
Date: Tue,  2 Feb 2016 10:56:49 -0500
Message-ID: <1454428609-26885-5-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1454428609-26885-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, daniel@iogearbox.net, mst@redhat.com,
	sri@us.ibm.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:35835 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933405AbcBBP47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 10:56:59 -0500
Received: by mail-qg0-f68.google.com with SMTP id b35so11916921qge.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 07:56:58 -0800 (PST)
In-Reply-To: <1454428609-26885-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support socket option PACKET_VNET_HDR together with PACKET_TX_RING.

When enabled, a struct virtio_net_hdr is expected to precede the data
in the ring. The vnet option must be set before the ring is created.

The implementation reuses the existing skb_copy_bits code that is used
when dev->hard_header_len is non-zero. Move this ll_header check to
before the skb alloc and combine it with a test for vnet_hdr->hdr_len.
Allocate and copy the max of the two.

Verified with test program at
github.com/wdebruij/kerneltools/blob/master/tests/psock_txring_vnet.c

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 53 +++++++++++++++++++++++++++++++++++---------------
 1 file changed, 37 insertions(+), 16 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 89377bf..41e25b6 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2495,7 +2495,7 @@ static int packet_snd_vnet_gso(struct sk_buff *skb,
 
 static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		void *frame, struct net_device *dev, void *data, int tp_len,
-		__be16 proto, unsigned char *addr, int hlen)
+		__be16 proto, unsigned char *addr, int hlen, int copylen)
 {
 	union tpacket_uhdr ph;
 	int to_write, offset, len, nr_frags, len_max;
@@ -2522,20 +2522,17 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 				NULL, tp_len);
 		if (unlikely(err < 0))
 			return -EINVAL;
-	} else if (dev->hard_header_len) {
-		if (ll_header_truncated(dev, tp_len))
-			return -EINVAL;
-
+	} else if (copylen) {
 		skb_push(skb, dev->hard_header_len);
-		err = skb_store_bits(skb, 0, data,
-				dev->hard_header_len);
+		skb_put(skb, copylen - dev->hard_header_len);
+		err = skb_store_bits(skb, 0, data, copylen);
 		if (unlikely(err))
 			return err;
 		if (!skb->protocol)
 			tpacket_set_protocol(dev, skb);
 
-		data += dev->hard_header_len;
-		to_write -= dev->hard_header_len;
+		data += copylen;
+		to_write -= copylen;
 	}
 
 	offset = offset_in_page(data);
@@ -2588,7 +2585,7 @@ static int tpacket_parse_header(struct packet_sock *po, void *frame,
 		tp_len = ph.h1->tp_len;
 		break;
 	}
-	if (unlikely(tp_len > size_max)) {
+	if (unlikely(tp_len > size_max) && !po->has_vnet_hdr) {
 		pr_err("packet size is too long (%d > %d)\n", tp_len, size_max);
 		return -EMSGSIZE;
 	}
@@ -2631,6 +2628,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 {
 	struct sk_buff *skb;
 	struct net_device *dev;
+	struct virtio_net_hdr *vnet_hdr = NULL;
 	__be16 proto;
 	int err, reserve = 0;
 	void *ph;
@@ -2641,7 +2639,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	void *data;
 	int len_sum = 0;
 	int status = TP_STATUS_AVAILABLE;
-	int hlen, tlen;
+	int hlen, tlen, copylen = 0;
 
 	mutex_lock(&po->pg_vec_lock);
 
@@ -2694,8 +2692,28 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		status = TP_STATUS_SEND_REQUEST;
 		hlen = LL_RESERVED_SPACE(dev);
 		tlen = dev->needed_tailroom;
+		if (po->has_vnet_hdr) {
+			vnet_hdr = data;
+			if (tp_len < sizeof(*vnet_hdr) ||
+			    __packet_snd_vnet_parse(vnet_hdr, tp_len)) {
+				tp_len = -EINVAL;
+				goto tpacket_error;
+			}
+			data += sizeof(*vnet_hdr);
+			tp_len -= sizeof(*vnet_hdr);
+			copylen = __virtio16_to_cpu(vio_le(),
+						    vnet_hdr->hdr_len);
+		}
+		if (dev->hard_header_len) {
+			if (ll_header_truncated(dev, tp_len)) {
+				tp_len = -EINVAL;
+				goto tpacket_error;
+			}
+			copylen = max_t(int, copylen, dev->hard_header_len);
+		}
 		skb = sock_alloc_send_skb(&po->sk,
-				hlen + tlen + sizeof(struct sockaddr_ll),
+				hlen + tlen + sizeof(struct sockaddr_ll) +
+				(copylen - dev->hard_header_len),
 				!need_wait, &err);
 
 		if (unlikely(skb == NULL)) {
@@ -2705,9 +2723,10 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			goto out_status;
 		}
 		tp_len = tpacket_fill_skb(po, skb, ph, dev, data, tp_len, proto,
-					  addr, hlen);
+					  addr, hlen, copylen);
 		if (likely(tp_len >= 0) &&
 		    tp_len > dev->mtu + reserve &&
+		    !po->has_vnet_hdr &&
 		    !packet_extra_vlan_len_allowed(dev, skb))
 			tp_len = -EMSGSIZE;
 
@@ -2726,6 +2745,11 @@ tpacket_error:
 			}
 		}
 
+		if (po->has_vnet_hdr && packet_snd_vnet_gso(skb, vnet_hdr)) {
+			tp_len = -EINVAL;
+			goto tpacket_error;
+		}
+
 		packet_pick_tx_queue(dev, skb);
 
 		skb->destructor = tpacket_destruct_skb;
@@ -3616,9 +3640,6 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		}
 		if (optlen < len)
 			return -EINVAL;
-		if (pkt_sk(sk)->has_vnet_hdr &&
-		    optname == PACKET_TX_RING)
-			return -EINVAL;
 		if (copy_from_user(&req_u.req, optval, len))
 			return -EFAULT;
 		return packet_set_ring(sk, &req_u, 0,
-- 
2.7.0.rc3.207.g0ac5344
