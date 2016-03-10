From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 3/3] packet: validate variable length ll headers
Date: Wed,  9 Mar 2016 21:58:34 -0500
Message-ID: <1457578714-36125-4-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1457578714-36125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:35761 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934871AbcCJC6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 21:58:42 -0500
Received: by mail-qg0-f66.google.com with SMTP id p68so4402759qge.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 18:58:42 -0800 (PST)
In-Reply-To: <1457578714-36125-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Replace link layer header validation check ll_header_truncate with
more generic dev_validate_header.

Validation based on hard_header_len incorrectly drops valid packets
in variable length protocols, such as AX25. dev_validate_header
calls header_ops.validate for such protocols to ensure correctness
below hard_header_len.

See also http://comments.gmane.org/gmane.linux.network/401064

Fixes 9c7077622dd9 ("packet: make packet_snd fail on len smaller than l2 header")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 43 ++++++++++++++++++-------------------------
 1 file changed, 18 insertions(+), 25 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d41b107..1ecfa71 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1915,6 +1915,10 @@ retry:
 		goto retry;
 	}
 
+	if (!dev_validate_header(dev, skb->data, len)) {
+		err = -EINVAL;
+		goto out_unlock;
+	}
 	if (len > (dev->mtu + dev->hard_header_len + extra_len) &&
 	    !packet_extra_vlan_len_allowed(dev, skb)) {
 		err = -EMSGSIZE;
@@ -2393,18 +2397,6 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
 	sock_wfree(skb);
 }
 
-static bool ll_header_truncated(const struct net_device *dev, int len)
-{
-	/* net device doesn't like empty head */
-	if (unlikely(len < dev->hard_header_len)) {
-		net_warn_ratelimited("%s: packet size is too short (%d < %d)\n",
-				     current->comm, len, dev->hard_header_len);
-		return true;
-	}
-
-	return false;
-}
-
 static void tpacket_set_protocol(const struct net_device *dev,
 				 struct sk_buff *skb)
 {
@@ -2522,16 +2514,20 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		if (unlikely(err < 0))
 			return -EINVAL;
 	} else if (copylen) {
+		int hdrlen = min_t(int, copylen, tp_len);
+
 		skb_push(skb, dev->hard_header_len);
 		skb_put(skb, copylen - dev->hard_header_len);
-		err = skb_store_bits(skb, 0, data, copylen);
+		err = skb_store_bits(skb, 0, data, hdrlen);
 		if (unlikely(err))
 			return err;
+		if (!dev_validate_header(dev, skb->data, hdrlen))
+			return -EINVAL;
 		if (!skb->protocol)
 			tpacket_set_protocol(dev, skb);
 
-		data += copylen;
-		to_write -= copylen;
+		data += hdrlen;
+		to_write -= hdrlen;
 	}
 
 	offset = offset_in_page(data);
@@ -2703,13 +2699,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 			copylen = __virtio16_to_cpu(vio_le(),
 						    vnet_hdr->hdr_len);
 		}
-		if (dev->hard_header_len) {
-			if (ll_header_truncated(dev, tp_len)) {
-				tp_len = -EINVAL;
-				goto tpacket_error;
-			}
-			copylen = max_t(int, copylen, dev->hard_header_len);
-		}
+		copylen = max_t(int, copylen, dev->hard_header_len);
 		skb = sock_alloc_send_skb(&po->sk,
 				hlen + tlen + sizeof(struct sockaddr_ll) +
 				(copylen - dev->hard_header_len),
@@ -2905,9 +2895,6 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 		offset = dev_hard_header(skb, dev, ntohs(proto), addr, NULL, len);
 		if (unlikely(offset < 0))
 			goto out_free;
-	} else {
-		if (ll_header_truncated(dev, len))
-			goto out_free;
 	}
 
 	/* Returns -EFAULT on error */
@@ -2915,6 +2902,12 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	if (err)
 		goto out_free;
 
+	if (sock->type == SOCK_RAW &&
+	    !dev_validate_header(dev, skb->data, len)) {
+		err = -EINVAL;
+		goto out_free;
+	}
+
 	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
 	if (!vnet_hdr.gso_type && (len > dev->mtu + reserve + extra_len) &&
-- 
2.7.0.rc3.207.g0ac5344
