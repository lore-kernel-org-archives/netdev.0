From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v4 4/5] net-timestamp: TCP timestamping
Date: Wed, 30 Jul 2014 11:48:47 -0400
Message-ID: <1406735328-7520-5-git-send-email-willemb@google.com>
References: <1406735328-7520-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:42291 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928AbaG3Psu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 11:48:50 -0400
Received: by mail-oi0-f73.google.com with SMTP id u20so409266oif.4
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 08:48:50 -0700 (PDT)
In-Reply-To: <1406735328-7520-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP timestamping extends SO_TIMESTAMPING to bytestreams.

Bytestreams do not have a 1:1 relationship between send() buffers and
network packets. The feature interprets a send call on a bytestream as
a request for a timestamp for the last byte in that send() buffer.

The choice corresponds to a request for a timestamp when all bytes in
the buffer have been sent. That assumption depends on in-order kernel
transmission. This is the common case. That said, it is possible to
construct a traffic shaping tree that would result in reordering.
The guarantee is strong, then, but not ironclad.

This implementation supports send and sendpages (splice). GSO replaces
one large packet with multiple smaller packets. This patch also copies
the option into the correct smaller packet.

This patch does not yet support timestamping on data in an initial TCP
Fast Open SYN, because that takes a very different data path.

The implementation supports a single timestamp per packet. To avoid
having multiple timestamp requests per sk_buff, the skb is locked
against extension once the flag is set.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/tcp.c         | 23 ++++++++++++++++++-----
 net/ipv4/tcp_offload.c |  4 ++++
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9d2118e..739d514 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -523,7 +523,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	}
 	/* This barrier is coupled with smp_wmb() in tcp_reset() */
 	smp_rmb();
-	if (sk->sk_err)
+	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR;
 
 	return mask;
@@ -878,6 +878,11 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }
 
+static bool tcp_skb_can_extend(struct sk_buff *skb)
+{
+	return !(skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP);
+}
+
 static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 				size_t size, int flags)
 {
@@ -911,7 +916,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 		int copy, i;
 		bool can_coalesce;
 
-		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
+		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0 ||
+		    !tcp_skb_can_extend(skb)) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
@@ -959,8 +965,10 @@ new_segment:
 
 		copied += copy;
 		offset += copy;
-		if (!(size -= copy))
+		if (!(size -= copy)) {
+			sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 			goto out;
+		}
 
 		if (skb->len < size_goal || (flags & MSG_OOB))
 			continue;
@@ -1160,7 +1168,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				copy = max - skb->len;
 			}
 
-			if (copy <= 0) {
+			if (copy <= 0 || !tcp_skb_can_extend(skb)) {
 new_segment:
 				/* Allocate new segment. If the interface is SG,
 				 * allocate skb fitting to single page.
@@ -1252,8 +1260,10 @@ new_segment:
 
 			from += copy;
 			copied += copy;
-			if ((seglen -= copy) == 0 && iovlen == 0)
+			if ((seglen -= copy) == 0 && iovlen == 0) {
+				sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 				goto out;
+			}
 
 			if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
 				continue;
@@ -1617,6 +1627,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct sk_buff *skb;
 	u32 urg_hole = 0;
 
+	if (unlikely(flags & MSG_ERRQUEUE))
+		return ip_recv_error(sk, msg, len, addr_len);
+
 	if (sk_can_busy_loop(sk) && skb_queue_empty(&sk->sk_receive_queue) &&
 	    (sk->sk_state == TCP_ESTABLISHED))
 		sk_busy_loop(sk, nonblock);
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 55046ec..156e21e 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -134,6 +134,10 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 				(__force u32)delta));
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		th->check = gso_make_checksum(skb, ~th->check);
+
+	if (unlikely(skb_shinfo(gso_skb)->tx_flags & SKBTX_SW_TSTAMP))
+		skb_shinfo(skb)->tx_flags |= SKBTX_SW_TSTAMP;
+
 out:
 	return segs;
 }
-- 
2.0.0.526.g5318336
