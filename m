From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v3 12/13] packet: enable MSG_ZEROCOPY
Date: Wed, 21 Jun 2017 17:18:15 -0400
Message-ID: <20170621211816.53837-13-willemdebruijn.kernel@gmail.com>
References: <20170621211816.53837-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35777 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751818AbdFUVSe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 17:18:34 -0400
In-Reply-To: <20170621211816.53837-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support MSG_ZEROCOPY on PF_PACKET transmission.

Tested:

  msg_zerocopy.sh 4 packet:

  without zerocopy
    tx=121543 (7588 MB) txc=0 zc=n
    rx=121543 (7584 MB)

  with zerocopy
    tx=338252 (21119 MB) txc=338252 zc=y
    rx=338252 (21108 MB)

  msg_zerocopy.sh 4 packet_dgram:

  without zerocopy
    tx=122699 (7659 MB) txc=0 zc=n
    rx=122699 (7656 MB)

  with zerocopy
    tx=340390 (21248 MB) txc=340390 zc=y
    rx=340390 (21241 MB)

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 36 ++++++++++++++++++++++++++----------
 1 file changed, 26 insertions(+), 10 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f9349a495caf..a04791fd81f2 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2795,30 +2795,39 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 static struct sk_buff *packet_alloc_skb(struct sock *sk, size_t prepad,
 				        size_t reserve, size_t len,
-				        size_t linear, int noblock,
+					size_t linear, int flags,
 				        int *err)
 {
 	struct sk_buff *skb;
+	size_t data_len;
 
-	/* Under a page?  Don't bother with paged skb. */
-	if (prepad + len < PAGE_SIZE || !linear)
-		linear = len;
+	if (flags & MSG_ZEROCOPY) {
+		/* Minimize linear, but respect header lower bound */
+		linear = reserve + min(len, max_t(size_t, linear, MAX_HEADER));
+		data_len = 0;
+	} else {
+		/* Under a page? Don't bother with paged skb. */
+		if (prepad + len < PAGE_SIZE || !linear)
+			linear = len;
+		data_len = len - linear;
+	}
 
-	skb = sock_alloc_send_pskb(sk, prepad + linear, len - linear, noblock,
-				   err, 0);
+	skb = sock_alloc_send_pskb(sk, prepad + linear, data_len,
+				   flags & MSG_DONTWAIT, err, 0);
 	if (!skb)
 		return NULL;
 
 	skb_reserve(skb, reserve);
 	skb_put(skb, linear);
-	skb->data_len = len - linear;
-	skb->len += len - linear;
+	skb->data_len = data_len;
+	skb->len += data_len;
 
 	return skb;
 }
 
 static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 {
+	struct iov_iter *from = &msg->msg_iter;
 	struct sock *sk = sock->sk;
 	DECLARE_SOCKADDR(struct sockaddr_ll *, saddr, msg->msg_name);
 	struct sk_buff *skb;
@@ -2894,7 +2903,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	linear = __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len);
 	linear = max(linear, min_t(int, len, dev->hard_header_len));
 	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len, linear,
-			       msg->msg_flags & MSG_DONTWAIT, &err);
+			       msg->msg_flags, &err);
 	if (skb == NULL)
 		goto out_unlock;
 
@@ -2908,10 +2917,16 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	}
 
 	/* Returns -EFAULT on error */
-	err = skb_copy_datagram_from_iter(skb, offset, &msg->msg_iter, len);
+	err = skb_copy_datagram_from_iter(skb, offset, from, skb->len - offset);
 	if (err)
 		goto out_free;
 
+	if (msg->msg_flags & MSG_ZEROCOPY && len) {
+		err = skb_zerocopy_iter_alloc(skb, msg, iov_iter_count(from));
+		if (err)
+			goto out_free;
+	}
+
 	if (sock->type == SOCK_RAW &&
 	    !dev_validate_header(dev, skb->data, len)) {
 		err = -EINVAL;
@@ -2954,6 +2969,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	return len;
 
 out_free:
+	skb_zcopy_abort(skb);
 	kfree_skb(skb);
 out_unlock:
 	if (dev)
-- 
2.13.1.611.g7e3b11ae1-goog
