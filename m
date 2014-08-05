From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Mon,  4 Aug 2014 22:11:49 -0400
Message-ID: <1407204710-21778-6-git-send-email-willemb@google.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:60844 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445AbaHECLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 22:11:53 -0400
Received: by mail-ie0-f202.google.com with SMTP id rl12so65568iec.3
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 19:11:52 -0700 (PDT)
In-Reply-To: <1407204710-21778-1-git-send-email-willemb@google.com>
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

If ID generation in ee_data is enabled, bytestream timestamps return a
byte offset, instead of the packet counter for datagrams.

The implementation supports a single timestamp per packet. It silenty
replaces requests for previous timestamps. To avoid missing tstamps,
flush the tcp queue by disabling Nagle, cork and autocork. Missing
tstamps can be detected by offset when the ee_data ID is enabled.

Implementation details:

- On GSO, the timestamping code can be included in the main loop. I
moved it into its own loop to reduce the impact on the common case
to a single branch.

- To avoid leaking the absolute seqno to userspace, the offset
returned in ee_data must always be relative. It is an offset between
an skb and sk field. The first is always set (also for GSO & ACK).
The second must also never be uninitialized. Only allow the ID
option on sockets in the ESTABLISHED state, for which the seqno
is available. Never reset it to zero (instead, move it to the
current seqno when reenabling the option).

Signed-off-by: Willem de Bruijn <willemb@google.com>

---
---
 net/core/skbuff.c      |  5 ++++-
 net/core/sock.c        | 13 +++++++++++--
 net/ipv4/tcp.c         | 22 +++++++++++++++++++---
 net/ipv4/tcp_offload.c | 18 ++++++++++++++++++
 4 files changed, 52 insertions(+), 6 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9705c07..3dec029 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3522,8 +3522,11 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
 	serr->ee.ee_info = tstype;
-	if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)
+	if (sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID) {
 		serr->ee.ee_data = skb_shinfo(skb)->tskey;
+		if (sk->sk_protocol == IPPROTO_TCP)
+			serr->ee.ee_data -= sk->sk_tskey;
+	}
 
 	err = sock_queue_err_skb(sk, skb);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 1e0f1c6..2714811 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -849,8 +849,17 @@ set_rcvbuf:
 			break;
 		}
 		if (val & SOF_TIMESTAMPING_OPT_ID &&
-		    !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID))
-			sk->sk_tskey = 0;
+		    !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_ID)) {
+			if (sk->sk_protocol == IPPROTO_TCP) {
+				if (sk->sk_state != TCP_ESTABLISHED) {
+					ret = -EINVAL;
+					break;
+				}
+				sk->sk_tskey = tcp_sk(sk)->snd_una;
+			} else {
+				sk->sk_tskey = 0;
+			}
+		}
 		sk->sk_tsflags = val;
 		if (val & SOF_TIMESTAMPING_RX_SOFTWARE)
 			sock_enable_timestamp(sk,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9d2118e..744af67 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -426,6 +426,15 @@ void tcp_init_sock(struct sock *sk)
 }
 EXPORT_SYMBOL(tcp_init_sock);
 
+void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb)
+{
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+
+	sock_tx_timestamp(sk, &shinfo->tx_flags);
+	if (shinfo->tx_flags & SKBTX_ANY_SW_TSTAMP)
+		shinfo->tskey = TCP_SKB_CB(skb)->seq + skb->len - 1;
+}
+
 /*
  *	Wait for a TCP event.
  *
@@ -523,7 +532,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 	}
 	/* This barrier is coupled with smp_wmb() in tcp_reset() */
 	smp_rmb();
-	if (sk->sk_err)
+	if (sk->sk_err || !skb_queue_empty(&sk->sk_error_queue))
 		mask |= POLLERR;
 
 	return mask;
@@ -959,8 +968,10 @@ new_segment:
 
 		copied += copy;
 		offset += copy;
-		if (!(size -= copy))
+		if (!(size -= copy)) {
+			tcp_tx_timestamp(sk, skb);
 			goto out;
+		}
 
 		if (skb->len < size_goal || (flags & MSG_OOB))
 			continue;
@@ -1252,8 +1263,10 @@ new_segment:
 
 			from += copy;
 			copied += copy;
-			if ((seglen -= copy) == 0 && iovlen == 0)
+			if ((seglen -= copy) == 0 && iovlen == 0) {
+				tcp_tx_timestamp(sk, skb);
 				goto out;
+			}
 
 			if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
 				continue;
@@ -1617,6 +1630,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct sk_buff *skb;
 	u32 urg_hole = 0;
 
+	if (unlikely(flags & MSG_ERRQUEUE))
+		return ip_recv_error(sk, msg, len, addr_len);
+
 	if (sk_can_busy_loop(sk) && skb_queue_empty(&sk->sk_receive_queue) &&
 	    (sk->sk_state == TCP_ESTABLISHED))
 		sk_busy_loop(sk, nonblock);
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 55046ec..f597119 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -14,6 +14,21 @@
 #include <net/tcp.h>
 #include <net/protocol.h>
 
+void tcp_gso_tstamp(struct sk_buff *skb, unsigned int ts_seq, unsigned int seq,
+		    unsigned int mss)
+{
+	while (skb) {
+		if (ts_seq < (__u64) seq + mss) {
+			skb_shinfo(skb)->tx_flags = SKBTX_SW_TSTAMP;
+			skb_shinfo(skb)->tskey = ts_seq;
+			return;
+		}
+
+		skb = skb->next;
+		seq += mss;
+	}
+}
+
 struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 				netdev_features_t features)
 {
@@ -91,6 +106,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	th = tcp_hdr(skb);
 	seq = ntohl(th->seq);
 
+	if (unlikely(skb_shinfo(gso_skb)->tx_flags & SKBTX_SW_TSTAMP))
+		tcp_gso_tstamp(segs, skb_shinfo(gso_skb)->tskey, seq, mss);
+
 	newcheck = ~csum_fold((__force __wsum)((__force u32)th->check +
 					       (__force u32)delta));
 
-- 
2.0.0.526.g5318336
