From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 4/7] net-timestamp: TCP timestamping
Date: Tue, 24 Jun 2014 11:43:49 -0400
Message-ID: <1403624632-17327-5-git-send-email-willemb@google.com>
References: <1403624632-17327-1-git-send-email-willemb@google.com>
Cc: eric.dumazet@gmail.com, richardcochran@gmail.com,
	davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:37368 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366AbaFXPoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:44:00 -0400
Received: by mail-pd0-f201.google.com with SMTP id v10so62699pde.4
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:43:59 -0700 (PDT)
In-Reply-To: <1403624632-17327-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP timestamping extends datagram MSG_TSTAMP support to bytestreams.

Bytestreams do not have a 1:1 relationship between send() buffers and
network packets. The feature interprets a send call with MSG_TSTAMP on
a bytestream as a request for a timestamp for the last byte in the
buffer.

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
 net/core/skbuff.c      | 12 ++++++++++++
 net/ipv4/tcp.c         | 21 +++++++++++++++++----
 net/ipv4/tcp_offload.c |  4 ++++
 net/socket.c           |  2 ++
 4 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bc653c4..07ba98d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -69,6 +69,7 @@
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
 #include <net/xfrm.h>
+#include <net/tcp.h>
 
 #include <asm/uaccess.h>
 #include <trace/events/skb.h>
@@ -3496,6 +3497,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	struct sock *sk = orig_skb->sk;
 	struct sock_exterr_skb *serr;
 	struct sk_buff *skb;
+	__u32 key = 0;
 	int err;
 
 	if (!sk)
@@ -3525,10 +3527,20 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 		*skb_hwtstamps(skb) = *skb_hwtstamps(orig_skb);
 	}
 
+	if (orig_skb->sk && orig_skb->sk->sk_protocol == IPPROTO_TCP) {
+		if (orig_skb->fclone == SKB_FCLONE_CLONE)
+			key = TCP_SKB_CB(orig_skb - 1)->end_seq;
+		else /* after GSO segmentation, clone no longer works */
+			key = ntohl(tcp_hdr(skb)->seq) +
+			      ntohs(ip_hdr(skb)->tot_len) -
+			      ip_hdrlen(skb) - tcp_hdrlen(skb);
+	}
+
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
+	serr->ee.ee_data = key;
 
 	err = sock_queue_err_skb(sk, skb);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index eb1dde3..4ceecd9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -878,6 +878,11 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }
 
+static bool tcp_skb_can_extend(struct sk_buff *skb)
+{
+	return !(skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP);
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
+			skb_shinfo(skb)->tx_flags |= skbflags_tx_tstamp(flags);
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
+				skb_shinfo(skb)->tx_flags |= skbflags_tx_tstamp(flags);
 				goto out;
+			}
 
 			if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
 				continue;
@@ -1616,6 +1626,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct sk_buff *skb;
 	u32 urg_hole = 0;
 
+	if (unlikely(flags & MSG_ERRQUEUE))
+		return ip_recv_error(sk, msg, len, addr_len);
+
 	if (sk_can_busy_loop(sk) && skb_queue_empty(&sk->sk_receive_queue) &&
 	    (sk->sk_state == TCP_ESTABLISHED))
 		sk_busy_loop(sk, nonblock);
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 4e86c59..730c2f6 100644
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
diff --git a/net/socket.c b/net/socket.c
index 18ab44a..d01e323 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -697,6 +697,7 @@ EXPORT_SYMBOL(kernel_sendmsg);
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb)
 {
+	struct sock_exterr_skb *serr = SKB_EXT_ERR(skb);
 	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP);
 	struct sock_errqueue_timestamping tss;
 	int empty = 1;
@@ -727,6 +728,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	     skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP) &&
 	    ktime_to_timespec_cond(skb->tstamp, &tss.ts_sw)) {
 		empty = 0;
+		tss.ts_key = serr->ee.ee_data;
 		tss.ts_type = SCM_TSTAMP_SND;
 	}
 	if (shhwtstamps) {
-- 
2.0.0.526.g5318336
