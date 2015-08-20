From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 06/10] udp: enable sendmsg zerocopy
Date: Thu, 20 Aug 2015 10:36:45 -0400
Message-ID: <1440081408-12302-7-git-send-email-willemb@google.com>
References: <1440081408-12302-1-git-send-email-willemb@google.com>
Cc: mst@redhat.com, jasowang@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:36461 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbbHTOg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 10:36:57 -0400
Received: by qkep139 with SMTP id p139so16167558qke.3
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 07:36:56 -0700 (PDT)
In-Reply-To: <1440081408-12302-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Add MSG_ZEROCOPY support to inet/dgram. This includes udplite.

Tested:
  loopback test //net/socket:snd_zerocopy_lo -u -z passes:

  without zerocopy (-u):
    rx=106644 (6655 MB) tx=106644 txc=0
    rx=219264 (13683 MB) tx=219264 txc=0
    rx=326958 (20403 MB) tx=326958 txc=0
    rx=430260 (26850 MB) tx=430260 txc=0

  with zerocopy (-u -z):
    rx=306924 (19153 MB) tx=306924 txc=306918
    rx=644700 (40232 MB) tx=644700 txc=644694
    rx=979200 (61106 MB) tx=979200 txc=979194
    rx=1308414 (81651 MB) tx=1308414 txc=1308408

  loopback test also passes with corking, with a mix of
  copied and user pages (-U -z):

  without zerocopy (-U):
    rx=105364 (6575 MB) tx=632184 txc=0
    rx=222964 (13913 MB) tx=1337784 txc=0
    rx=349025 (21780 MB) tx=2094150 txc=0
    rx=477526 (29799 MB) tx=2865156 txc=0

  with zerocopy (-U -z):
    rx=140490 (8767 MB) tx=842940 txc=421459
    rx=283919 (17717 MB) tx=1703514 txc=851738
    rx=434414 (27109 MB) tx=2606484 txc=1303213
    rx=571965 (35693 MB) tx=3431790 txc=1715856

  In corked mode, each sendmsg call passes only 1/6th of the total
  datagram, rendering zerocopy less effective.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/skbuff.h |  5 +++++
 net/ipv4/ip_output.c   | 34 +++++++++++++++++++++++++++++-----
 2 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 99de112..c1ea855 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -335,6 +335,11 @@ struct ubuf_info {
 
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
index 0138fad..16bab5e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -871,7 +871,7 @@ static int __ip_append_data(struct sock *sk,
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sk_buff *skb;
-
+	struct ubuf_info *uarg = NULL;
 	struct ip_options *opt = cork->opt;
 	int hh_len;
 	int exthdrlen;
@@ -914,9 +914,16 @@ static int __ip_append_data(struct sock *sk,
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
 	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
-	    (sk->sk_protocol == IPPROTO_UDP) &&
+	    (sk->sk_protocol == IPPROTO_UDP) && !uarg &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
 	    (sk->sk_type == SOCK_DGRAM)) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
@@ -968,6 +975,8 @@ alloc_new_skb:
 			if ((flags & MSG_MORE) &&
 			    !(rt->dst.dev->features&NETIF_F_SG))
 				alloclen = mtu;
+			else if (uarg)
+				alloclen = min_t(int, fraglen, MAX_HEADER);
 			else
 				alloclen = fraglen;
 
@@ -1010,11 +1019,12 @@ alloc_new_skb:
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
@@ -1030,7 +1040,9 @@ alloc_new_skb:
 				pskb_trim_unique(skb_prev, maxfraglen);
 			}
 
-			copy = datalen - transhdrlen - fraggap;
+			copy = min(datalen,
+				   alloclen - exthdrlen - fragheaderlen);
+			copy -= transhdrlen - fraggap;
 			if (copy > 0 && getfrag(from, data + transhdrlen, offset, copy, fraggap, skb) < 0) {
 				err = -EFAULT;
 				kfree_skb(skb);
@@ -1038,7 +1050,7 @@ alloc_new_skb:
 			}
 
 			offset += copy;
-			length -= datalen - fraggap;
+			length -= copy + transhdrlen;
 			transhdrlen = 0;
 			exthdrlen = 0;
 			csummode = CHECKSUM_NONE;
@@ -1063,6 +1075,17 @@ alloc_new_skb:
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
 
@@ -1103,6 +1126,7 @@ alloc_new_skb:
 error_efault:
 	err = -EFAULT;
 error:
+	sock_zerocopy_put_abort(uarg);
 	cork->length -= length;
 	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
 	return err;
-- 
2.5.0.276.gf5e568e
