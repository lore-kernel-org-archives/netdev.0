From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH] tcp: Add SOF_TIMESTAMPING_TX_EOR and allow MSG_EOR in tcp_sendmsg
Date: Thu, 24 Mar 2016 15:46:32 -0700
Message-ID: <1458859592-751521-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:12249 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750870AbcCXWqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 18:46:44 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u2OMk1vn004680
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 15:46:43 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 21v01d6qwu-20
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 15:46:43 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 4216944af21211e59dde0002c991e86a-245da3f0 for <netdev@vger.kernel.org>;	Thu,
 24 Mar 2016 15:46:33 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends the SO_TIMESTAMPING work and the primary
objective is to track when TCP ACK is received for the
last byte of an application's message (e.g. HTTP2).

This patch allows the user process to use MSG_EOR during
tcp_sendmsg to tell the kernel that it is the last byte
of an application response message.

The user process can use the new SOF_TIMESTAMPING_TX_EOR to
ask the kernel to only track timestamp of the MSG_EOR byte.

Together with the existing SOF_TIMESTAMPING_TX_ACK and
SOF_TIMESTAMPING_OPT_ID, the user process knows which
response message the received TCP ACK is acknowledging.

The current SOF_TIMESTAMPING_TX_ACK is tracking the last
byte appended to a skb during the tcp_sendmsg.  It may track
multiple bytes if the response spans across multiple skbs.  While
it is enough to measure the response latency for application
protocol with a single request/response at a time (like HTTP 1.1
without pipeline), it does not work well for application protocol
with >1 pipeline responses (like HTTP2).

Each skb can only track one tskey (which is the seq number of
the last byte of the message).   To allow tracking the
last byte of multiple response messages, this patch takes an approach
by not appending to the last skb during tcp_sendmsg if the last skb's
tskey will be overwritten.  A similar case also happens during retransmit.

This approach avoids introducing another list to track the tskey.  The
downside is that it will have less gso benefit and/or more outgoing
packets.  Practically, due to the amount of measurement data generated,
sampling is usually used in production. (i.e. not every connection is
tracked).

One of our use case is at the webserver.  The webserver tracks
the HTTP2 response latency by measuring when the webserver
sends the first byte to the socket till the TCP ACK of the last byte
is received.  In the cases where we don't have client side
measurement, measuring from the server side is the only option.
In the cases we have the client side measurement, the server side
data can also be used to justify/cross-check-with the client
side data (e.g. is there slowness at the layer above the client's
TCP stack).

The TCP PRR paper [1] also measures a similar metrics:
"The TCP latency of a HTTP response when the server sends the first
 byte until it receives the acknowledgment (ACK) for the last byte."

[1] Proportional Rate Reduction for TCP:
http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/37486.pdf

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/uapi/linux/net_tstamp.h |  3 ++-
 net/ipv4/tcp.c                  | 23 ++++++++++++++++++-----
 net/ipv4/tcp_output.c           |  9 +++++++--
 3 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 6d1abea..5376569 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -25,8 +25,9 @@ enum {
 	SOF_TIMESTAMPING_TX_ACK = (1<<9),
 	SOF_TIMESTAMPING_OPT_CMSG = (1<<10),
 	SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
+	SOF_TIMESTAMPING_TX_EOR = (1<<12),
 
-	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_TSONLY,
+	SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_TX_EOR,
 	SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
 				 SOF_TIMESTAMPING_LAST
 };
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 08b8b96..7de96eb 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -428,11 +428,16 @@ void tcp_init_sock(struct sock *sk)
 }
 EXPORT_SYMBOL(tcp_init_sock);
 
-static void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb)
+static void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb, int flags)
 {
 	if (sk->sk_tsflags) {
-		struct skb_shared_info *shinfo = skb_shinfo(skb);
+		struct skb_shared_info *shinfo;
 
+		if ((sk->sk_tsflags & SOF_TIMESTAMPING_TX_EOR) &&
+		    !(flags & MSG_EOR))
+			return;
+
+		shinfo = skb_shinfo(skb);
 		sock_tx_timestamp(sk, &shinfo->tx_flags);
 		if (shinfo->tx_flags & SKBTX_ANY_TSTAMP)
 			shinfo->tskey = TCP_SKB_CB(skb)->seq + skb->len - 1;
@@ -957,7 +962,7 @@ new_segment:
 		offset += copy;
 		size -= copy;
 		if (!size) {
-			tcp_tx_timestamp(sk, skb);
+			tcp_tx_timestamp(sk, skb, flags);
 			goto out;
 		}
 
@@ -1073,6 +1078,14 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 	return err;
 }
 
+static bool tcp_tx_ts_noappend_skb(const struct sock *sk,
+				   const struct sk_buff *last_skb, int flags)
+{
+	return unlikely((sk->sk_tsflags & SOF_TIMESTAMPING_TX_EOR) &&
+			(flags & MSG_EOR) &&
+			(skb_shinfo(last_skb)->tx_flags & SKBTX_ANY_TSTAMP));
+}
+
 int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -1144,7 +1157,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 			copy = max - skb->len;
 		}
 
-		if (copy <= 0) {
+		if (copy <= 0 || tcp_tx_ts_noappend_skb(sk, skb, flags)) {
 new_segment:
 			/* Allocate new segment. If the interface is SG,
 			 * allocate skb fitting to single page.
@@ -1237,7 +1250,7 @@ new_segment:
 
 		copied += copy;
 		if (!msg_data_left(msg)) {
-			tcp_tx_timestamp(sk, skb);
+			tcp_tx_timestamp(sk, skb, flags);
 			goto out;
 		}
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7d2dc01..ee415cb 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2488,7 +2488,8 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 }
 
 /* Check if coalescing SKBs is legal. */
-static bool tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb)
+static bool tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb,
+			     const struct sk_buff *to)
 {
 	if (tcp_skb_pcount(skb) > 1)
 		return false;
@@ -2502,6 +2503,10 @@ static bool tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb)
 	/* Some heurestics for collapsing over SACK'd could be invented */
 	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
 		return false;
+	if (unlikely((sk->sk_tsflags & SOF_TIMESTAMPING_TX_EOR) &&
+		     (skb_shinfo(to)->tx_flags & SKBTX_ANY_TSTAMP) &&
+		     (skb_shinfo(skb)->tx_flags & SKBTX_ANY_TSTAMP)))
+		return false;
 
 	return true;
 }
@@ -2522,7 +2527,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 		return;
 
 	tcp_for_write_queue_from_safe(skb, tmp, sk) {
-		if (!tcp_can_collapse(sk, skb))
+		if (!tcp_can_collapse(sk, skb, to))
 			break;
 
 		space -= skb->len;
-- 
2.5.1
