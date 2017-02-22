From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC v2 09/12] udp: enable sendmsg zerocopy
Date: Wed, 22 Feb 2017 11:38:58 -0500
Message-ID: <20170222163901.90834-10-willemdebruijn.kernel@gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33599 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754873AbdBVQj1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:39:27 -0500
Received: by mail-qk0-f193.google.com with SMTP id x71so1187281qkb.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:39:26 -0800 (PST)
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add MSG_ZEROCOPY support to inet/dgram. This includes udplite.

Tested:
  loopback test snd_zerocopy_lo -u -z produces

  without zerocopy (-u):
    rx=173940 (10854 MB) tx=173940 txc=0
    rx=367026 (22904 MB) tx=367026 txc=0
    rx=564078 (35201 MB) tx=564078 txc=0
    rx=756588 (47214 MB) tx=756588 txc=0

  with zerocopy (-u -z):
    rx=377994 (23588 MB) tx=377994 txc=377980
    rx=792654 (49465 MB) tx=792654 txc=792632
    rx=1209582 (75483 MB) tx=1209582 txc=1209552
    rx=1628376 (101618 MB) tx=1628376 txc=1628338

  loopback test currently fails with corking, due to
  CHECKSUM_PARTIAL being disabled with UDP_CORK after commit
  d749c9cbffd6 ("ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked sockets")

  I will suggest to allow it on NETIF_F_LOOPBACK.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h |  5 +++++
 net/ipv4/ip_output.c   | 34 +++++++++++++++++++++++++++++-----
 2 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6ad1724ceb60..9e7386f3f7a8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -424,6 +424,11 @@ struct ubuf_info {
 
 #define skb_uarg(SKB)	((struct ubuf_info *)(skb_shinfo(SKB)->destructor_arg))
 
+#define sock_can_zerocopy(sk, rt, csummode) \
+	((rt->dst.dev->features & NETIF_F_SG) && \
+	 ((sk->sk_type == SOCK_RAW) || \
+	  (sk->sk_type == SOCK_DGRAM && csummode & CHECKSUM_UNNECESSARY)))
+
 struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size);
 struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
 					struct ubuf_info *uarg);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 737ce826d7ec..9e0110d8a429 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -919,7 +919,7 @@ static int __ip_append_data(struct sock *sk,
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
-
+	struct ubuf_info *uarg = NULL;
 	struct ip_options *opt = cork->opt;
 	int hh_len;
 	int exthdrlen;
@@ -963,9 +963,16 @@ static int __ip_append_data(struct sock *sk,
 	    !exthdrlen)
 		csummode = CHECKSUM_PARTIAL;
 
+	if (flags & MSG_ZEROCOPY && length &&
+	    sock_can_zerocopy(sk, rt, skb ? skb->ip_summed : csummode)) {
+		uarg = sock_zerocopy_realloc(sk, length, skb_zcopy(skb));
+		if (!uarg)
+			return -ENOBUFS;
+	}
+
 	cork->length += length;
 	if ((((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))) &&
-	    (sk->sk_protocol == IPPROTO_UDP) &&
+	    (sk->sk_protocol == IPPROTO_UDP) && !uarg &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
 	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
@@ -1017,6 +1024,8 @@ static int __ip_append_data(struct sock *sk,
 			if ((flags & MSG_MORE) &&
 			    !(rt->dst.dev->features&NETIF_F_SG))
 				alloclen = mtu;
+			else if (uarg)
+				alloclen = min_t(int, fraglen, MAX_HEADER);
 			else
 				alloclen = fraglen;
 
@@ -1059,11 +1068,12 @@ static int __ip_append_data(struct sock *sk,
 			cork->tx_flags = 0;
 			skb_shinfo(skb)->tskey = tskey;
 			tskey = 0;
+			skb_zcopy_set(skb, uarg);
 
 			/*
 			 *	Find where to start putting bytes.
 			 */
-			data = skb_put(skb, fraglen + exthdrlen);
+			data = skb_put(skb, alloclen);
 			skb_set_network_header(skb, exthdrlen);
 			skb->transport_header = (skb->network_header +
 						 fragheaderlen);
@@ -1079,7 +1089,9 @@ static int __ip_append_data(struct sock *sk,
 				pskb_trim_unique(skb_prev, maxfraglen);
 			}
 
-			copy = datalen - transhdrlen - fraggap;
+			copy = min(datalen,
+				   alloclen - exthdrlen - fragheaderlen);
+			copy -= transhdrlen - fraggap;
 			if (copy > 0 && getfrag(from, data + transhdrlen, offset, copy, fraggap, skb) < 0) {
 				err = -EFAULT;
 				kfree_skb(skb);
@@ -1087,7 +1099,7 @@ static int __ip_append_data(struct sock *sk,
 			}
 
 			offset += copy;
-			length -= datalen - fraggap;
+			length -= copy + transhdrlen;
 			transhdrlen = 0;
 			exthdrlen = 0;
 			csummode = CHECKSUM_NONE;
@@ -1115,6 +1127,17 @@ static int __ip_append_data(struct sock *sk,
 				err = -EFAULT;
 				goto error;
 			}
+		} else if (uarg) {
+			struct iov_iter *iter;
+
+			if (sk->sk_type == SOCK_RAW)
+				iter = &((struct msghdr **)from)[0]->msg_iter;
+			else
+				iter = &((struct msghdr *)from)->msg_iter;
+			err = skb_zerocopy_add_frags_iter(sk, skb, iter, copy, uarg);
+			if (err < 0)
+				goto error;
+			copy = err;
 		} else {
 			int i = skb_shinfo(skb)->nr_frags;
 
@@ -1155,6 +1178,7 @@ static int __ip_append_data(struct sock *sk,
 error_efault:
 	err = -EFAULT;
 error:
+	sock_zerocopy_put_abort(uarg);
 	cork->length -= length;
 	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
 	return err;
-- 
2.11.0.483.g087da7b7c-goog
