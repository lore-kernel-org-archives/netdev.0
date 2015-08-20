From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 08/10] packet: enable sendmsg zerocopy
Date: Thu, 20 Aug 2015 10:36:47 -0400
Message-ID: <1440081408-12302-9-git-send-email-willemb@google.com>
References: <1440081408-12302-1-git-send-email-willemb@google.com>
Cc: mst@redhat.com, jasowang@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:36478 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbbHTOg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 10:36:58 -0400
Received: by qkep139 with SMTP id p139so16167970qke.3
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 07:36:57 -0700 (PDT)
In-Reply-To: <1440081408-12302-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support MSG_ZEROCOPY on PF_PACKET transmission.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 45 +++++++++++++++++++++++++++++++++++----------
 1 file changed, 35 insertions(+), 10 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b5afe53..8c5588b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2476,28 +2476,47 @@ out:
 
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
+		linear = min(len, max_t(size_t, linear, MAX_HEADER));
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
+					 struct msghdr *msg, size_t size)
+{
+	if (zerocopy_sg_from_iter(skb, &msg->msg_iter))
+		return -EIO;
+	if (!skb_zerocopy_alloc(skb, size))
+		return -ENOMEM;
+
+	return 0;
+}
+
 static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
@@ -2515,6 +2534,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	int hlen, tlen;
 	int extra_len = 0;
 	ssize_t n;
+	bool zerocopy = msg->msg_flags & MSG_ZEROCOPY;
 
 	/*
 	 *	Get and verify the address.
@@ -2611,7 +2631,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	tlen = dev->needed_tailroom;
 	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len,
 			       __virtio16_to_cpu(false, vnet_hdr.hdr_len),
-			       msg->msg_flags & MSG_DONTWAIT, &err);
+			       msg->msg_flags, &err);
 	if (skb == NULL)
 		goto out_unlock;
 
@@ -2628,7 +2648,11 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	}
 
 	/* Returns -EFAULT on error */
-	err = skb_copy_datagram_from_iter(skb, offset, &msg->msg_iter, len);
+	if (zerocopy)
+		err = packet_zerocopy_sg_from_iovec(skb, msg, len);
+	else
+		err = skb_copy_datagram_from_iter(skb, offset, &msg->msg_iter,
+						  len);
 	if (err)
 		goto out_free;
 
@@ -2690,6 +2714,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	return len;
 
 out_free:
+	sock_zerocopy_put_abort(skb_zcopy(skb));
 	kfree_skb(skb);
 out_unlock:
 	if (dev)
-- 
2.5.0.276.gf5e568e
