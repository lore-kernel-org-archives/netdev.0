From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 10/13] udp: enable MSG_ZEROCOPY
Date: Sun, 18 Jun 2017 18:44:11 -0400
Message-ID: <20170618224414.59012-11-willemdebruijn.kernel@gmail.com>
References: <20170618224414.59012-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33628 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753313AbdFRWo3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 18:44:29 -0400
In-Reply-To: <20170618224414.59012-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add MSG_ZEROCOPY support to INET(6). This includes UDP, but also
RAW sockets that do not take the raw_send_hdrinc() path.

Zerocopy is only effective when payload is not touched at all. Limit
it to paths that support both checksum offload and scatter-gather.

When a caller passes MSG_ZEROCOPY to send and it returns a positive
result, the caller must always receive a completion notification.
Therefore, attach the structure even when zerocopy is not possible.
Also in edge cases, such as corking with mixed zc/non-zc calls.

Tested:
  msg_zerocopy.sh 4 udp:

  without zerocopy
    tx=146127 (9118 MB) txc=0 zc=n
    rx=146127 (9118 MB)

  with zerocopy
    tx=335789 (20954 MB) txc=335789 zc=y
    rx=335789 (20954 MB)

  msg_zerocopy.sh 4 raw:

  without zerocopy
    tx=106461 (6643 MB) txc=0 zc=n
    rx=106461 (6643 MB)

  with zerocopy
    tx=296082 (18476 MB) txc=296082 zc=y
    rx=296082 (18476 MB)

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c     |  4 ++++
 net/ipv4/ip_output.c  | 37 ++++++++++++++++++++++++++++++-------
 net/ipv6/ip6_output.c | 40 +++++++++++++++++++++++++++++++++-------
 3 files changed, 67 insertions(+), 14 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0beaf961f79c..7d4c12316df6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1145,6 +1145,10 @@ extern int __zerocopy_sg_from_iter(struct sock *sk, struct sk_buff *skb,
 int skb_zerocopy_iter(struct sock *sk, struct sk_buff *skb, struct msghdr *msg,
 		      int len)
 {
+	/* raw has extra indirection in raw_frag_vec */
+	if (sk->sk_type == SOCK_RAW && sk->sk_family != PF_PACKET)
+		msg = *(struct msghdr **)msg;
+
 	return __zerocopy_sg_from_iter(sk, skb, &msg->msg_iter, len);
 }
 EXPORT_SYMBOL_GPL(skb_zerocopy_iter);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7a3fd25e8913..3ff425f7ded6 100644
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
@@ -963,9 +963,21 @@ static int __ip_append_data(struct sock *sk,
 	    !exthdrlen)
 		csummode = CHECKSUM_PARTIAL;
 
+	if (flags & MSG_ZEROCOPY && length) {
+		uarg = sock_zerocopy_realloc(sk, length, skb_zcopy(skb));
+		if (!uarg)
+			return -ENOBUFS;
+
+		if (!(rt->dst.dev->features & NETIF_F_SG) ||
+		    (sk->sk_type == SOCK_DGRAM && csummode == CHECKSUM_NONE)) {
+			uarg->zerocopy = 0;
+			skb_zcopy_set(skb, uarg);
+		}
+	}
+
 	cork->length += length;
 	if ((((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))) &&
-	    (sk->sk_protocol == IPPROTO_UDP) &&
+	    (sk->sk_protocol == IPPROTO_UDP) && !uarg &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !dst_xfrm(&rt->dst) &&
 	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
@@ -997,6 +1009,7 @@ static int __ip_append_data(struct sock *sk,
 			unsigned int fraglen;
 			unsigned int fraggap;
 			unsigned int alloclen;
+			unsigned int zcopylen = 0;
 			struct sk_buff *skb_prev;
 alloc_new_skb:
 			skb_prev = skb;
@@ -1017,8 +1030,12 @@ static int __ip_append_data(struct sock *sk,
 			if ((flags & MSG_MORE) &&
 			    !(rt->dst.dev->features&NETIF_F_SG))
 				alloclen = mtu;
-			else
+			else if (!uarg || !uarg->zerocopy)
 				alloclen = fraglen;
+			else {
+				alloclen = min_t(int, fraglen, MAX_HEADER);
+				zcopylen = fraglen - alloclen;
+			}
 
 			alloclen += exthdrlen;
 
@@ -1059,11 +1076,12 @@ static int __ip_append_data(struct sock *sk,
 			cork->tx_flags = 0;
 			skb_shinfo(skb)->tskey = tskey;
 			tskey = 0;
+			skb_zcopy_set(skb, uarg);
 
 			/*
 			 *	Find where to start putting bytes.
 			 */
-			data = skb_put(skb, fraglen + exthdrlen);
+			data = skb_put(skb, fraglen + exthdrlen - zcopylen);
 			skb_set_network_header(skb, exthdrlen);
 			skb->transport_header = (skb->network_header +
 						 fragheaderlen);
@@ -1079,7 +1097,7 @@ static int __ip_append_data(struct sock *sk,
 				pskb_trim_unique(skb_prev, maxfraglen);
 			}
 
-			copy = datalen - transhdrlen - fraggap;
+			copy = datalen - transhdrlen - fraggap - zcopylen;
 			if (copy > 0 && getfrag(from, data + transhdrlen, offset, copy, fraggap, skb) < 0) {
 				err = -EFAULT;
 				kfree_skb(skb);
@@ -1087,7 +1105,7 @@ static int __ip_append_data(struct sock *sk,
 			}
 
 			offset += copy;
-			length -= datalen - fraggap;
+			length -= copy + transhdrlen;
 			transhdrlen = 0;
 			exthdrlen = 0;
 			csummode = CHECKSUM_NONE;
@@ -1115,7 +1133,7 @@ static int __ip_append_data(struct sock *sk,
 				err = -EFAULT;
 				goto error;
 			}
-		} else {
+		} else if (!uarg || !uarg->zerocopy) {
 			int i = skb_shinfo(skb)->nr_frags;
 
 			err = -ENOMEM;
@@ -1145,6 +1163,10 @@ static int __ip_append_data(struct sock *sk,
 			skb->data_len += copy;
 			skb->truesize += copy;
 			atomic_add(copy, &sk->sk_wmem_alloc);
+		} else {
+			err = skb_zerocopy_iter(sk, skb, from, copy);
+			if (err)
+				goto error;
 		}
 		offset += copy;
 		length -= copy;
@@ -1155,6 +1177,7 @@ static int __ip_append_data(struct sock *sk,
 error_efault:
 	err = -EFAULT;
 error:
+	sock_zerocopy_put_abort(uarg);
 	cork->length -= length;
 	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
 	return err;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5baa6fab4b97..38d9722d4e3c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1307,6 +1307,7 @@ static int __ip6_append_data(struct sock *sk,
 	struct ipv6_txoptions *opt = v6_cork->opt;
 	int csummode = CHECKSUM_NONE;
 	unsigned int maxnonfragsize, headersize;
+	struct ubuf_info *uarg = NULL;
 
 	skb = skb_peek_tail(queue);
 	if (!skb) {
@@ -1368,6 +1369,18 @@ static int __ip6_append_data(struct sock *sk,
 			tskey = sk->sk_tskey++;
 	}
 
+	if (flags & MSG_ZEROCOPY && length) {
+		uarg = sock_zerocopy_realloc(sk, length, skb_zcopy(skb));
+		if (!uarg)
+			return -ENOBUFS;
+
+		if (!(rt->dst.dev->features & NETIF_F_SG) ||
+		    (sk->sk_type == SOCK_DGRAM && csummode == CHECKSUM_NONE)) {
+			uarg->zerocopy = 0;
+			skb_zcopy_set(skb, uarg);
+		}
+	}
+
 	/*
 	 * Let's try using as much space as possible.
 	 * Use MTU if total length of the message fits into the MTU.
@@ -1387,7 +1400,7 @@ static int __ip6_append_data(struct sock *sk,
 	cork->length += length;
 	if ((((length + fragheaderlen) > mtu) ||
 	     (skb && skb_is_gso(skb))) &&
-	    (sk->sk_protocol == IPPROTO_UDP) &&
+	    (sk->sk_protocol == IPPROTO_UDP) && !uarg &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !dst_xfrm(&rt->dst) &&
 	    (sk->sk_type == SOCK_DGRAM) && !udp_get_no_check6_tx(sk)) {
 		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
@@ -1413,6 +1426,7 @@ static int __ip6_append_data(struct sock *sk,
 			unsigned int fraglen;
 			unsigned int fraggap;
 			unsigned int alloclen;
+			unsigned int zcopylen = 0;
 alloc_new_skb:
 			/* There's no room in the current skb */
 			if (skb)
@@ -1435,11 +1449,17 @@ static int __ip6_append_data(struct sock *sk,
 
 			if (datalen > (cork->length <= mtu && !(cork->flags & IPCORK_ALLFRAG) ? mtu : maxfraglen) - fragheaderlen)
 				datalen = maxfraglen - fragheaderlen - rt->dst.trailer_len;
+			fraglen = datalen + fragheaderlen;
+
 			if ((flags & MSG_MORE) &&
 			    !(rt->dst.dev->features&NETIF_F_SG))
 				alloclen = mtu;
-			else
-				alloclen = datalen + fragheaderlen;
+			else if (!uarg || !uarg->zerocopy)
+				alloclen = fraglen;
+			else {
+				alloclen = min_t(int, fraglen, MAX_HEADER);
+				zcopylen = fraglen - alloclen;
+			}
 
 			alloclen += dst_exthdrlen;
 
@@ -1461,7 +1481,7 @@ static int __ip6_append_data(struct sock *sk,
 			 */
 			alloclen += sizeof(struct frag_hdr);
 
-			copy = datalen - transhdrlen - fraggap;
+			copy = datalen - transhdrlen - fraggap - zcopylen;
 			if (copy < 0) {
 				err = -EINVAL;
 				goto error;
@@ -1497,11 +1517,12 @@ static int __ip6_append_data(struct sock *sk,
 			tx_flags = 0;
 			skb_shinfo(skb)->tskey = tskey;
 			tskey = 0;
+			skb_zcopy_set(skb, uarg);
 
 			/*
 			 *	Find where to start putting bytes
 			 */
-			data = skb_put(skb, fraglen);
+			data = skb_put(skb, fraglen - zcopylen);
 			skb_set_network_header(skb, exthdrlen);
 			data += fragheaderlen;
 			skb->transport_header = (skb->network_header +
@@ -1524,7 +1545,7 @@ static int __ip6_append_data(struct sock *sk,
 			}
 
 			offset += copy;
-			length -= datalen - fraggap;
+			length -= copy + transhdrlen;
 			transhdrlen = 0;
 			exthdrlen = 0;
 			dst_exthdrlen = 0;
@@ -1552,7 +1573,7 @@ static int __ip6_append_data(struct sock *sk,
 				err = -EFAULT;
 				goto error;
 			}
-		} else {
+		} else if (!uarg || !uarg->zerocopy) {
 			int i = skb_shinfo(skb)->nr_frags;
 
 			err = -ENOMEM;
@@ -1582,6 +1603,10 @@ static int __ip6_append_data(struct sock *sk,
 			skb->data_len += copy;
 			skb->truesize += copy;
 			atomic_add(copy, &sk->sk_wmem_alloc);
+		} else {
+			err = skb_zerocopy_iter(sk, skb, from, copy);
+			if (err)
+				goto error;
 		}
 		offset += copy;
 		length -= copy;
@@ -1592,6 +1617,7 @@ static int __ip6_append_data(struct sock *sk,
 error_efault:
 	err = -EFAULT;
 error:
+	sock_zerocopy_put_abort(uarg);
 	cork->length -= length;
 	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	return err;
-- 
2.13.1.518.g3df882009-goog
