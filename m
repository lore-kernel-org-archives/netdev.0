From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC v2 11/12] packet: enable sendmsg zerocopy
Date: Wed, 22 Feb 2017 11:39:00 -0500
Message-ID: <20170222163901.90834-12-willemdebruijn.kernel@gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35893 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754881AbdBVQj3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:39:29 -0500
Received: by mail-qk0-f193.google.com with SMTP id r90so1164869qki.3
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:39:29 -0800 (PST)
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support MSG_ZEROCOPY on PF_PACKET transmission.

Tested:
  pf_packet loopback test snd_zerocopy_lo -p -z produces:

  without zerocopy (-p):
    rx=0 (0 MB) tx=221696 txc=0
    rx=0 (0 MB) tx=443880 txc=0
    rx=0 (0 MB) tx=661056 txc=0
    rx=0 (0 MB) tx=877152 txc=0

  with zerocopy (-p -z):
    rx=0 (0 MB) tx=528548 txc=528544
    rx=0 (0 MB) tx=1052364 txc=1052360
    rx=0 (0 MB) tx=1571956 txc=1571952
    rx=0 (0 MB) tx=2094144 txc=2094140

  Packets do not arrive at the Rx socket due to a martian test:

    IPv4: martian destination 127.0.0.1 from 127.0.0.1, dev lo

  I'll need to revise snd_zerocopy_lo to bypass that.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 52 ++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 42 insertions(+), 10 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2bd0d1949312..af9ecc1edf72 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2754,28 +2754,55 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
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
 
+static int packet_zerocopy_sg_from_iovec(struct sk_buff *skb,
+					 struct msghdr *msg,
+					 int offset, size_t size)
+{
+	int ret;
+
+	/* if SOCK_DGRAM, head room was alloc'ed and holds ll-headers */
+	__skb_pull(skb, offset);
+	ret = zerocopy_sg_from_iter(skb, &msg->msg_iter);
+	__skb_push(skb, offset);
+	if (unlikely(ret))
+		return ret == -EMSGSIZE ? ret : -EIO;
+
+	if (!skb_zerocopy_alloc(skb, size))
+		return -ENOMEM;
+
+	return 0;
+}
+
 static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
@@ -2853,7 +2880,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	linear = __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len);
 	linear = max(linear, min_t(int, len, dev->hard_header_len));
 	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len, linear,
-			       msg->msg_flags & MSG_DONTWAIT, &err);
+			       msg->msg_flags, &err);
 	if (skb == NULL)
 		goto out_unlock;
 
@@ -2867,7 +2894,11 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	}
 
 	/* Returns -EFAULT on error */
-	err = skb_copy_datagram_from_iter(skb, offset, &msg->msg_iter, len);
+	if (msg->msg_flags & MSG_ZEROCOPY)
+		err = packet_zerocopy_sg_from_iovec(skb, msg, offset, len);
+	else
+		err = skb_copy_datagram_from_iter(skb, offset, &msg->msg_iter,
+						  len);
 	if (err)
 		goto out_free;
 
@@ -2913,6 +2944,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	return len;
 
 out_free:
+	skb_zcopy_abort(skb);
 	kfree_skb(skb);
 out_unlock:
 	if (dev)
-- 
2.11.0.483.g087da7b7c-goog
