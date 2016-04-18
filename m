From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH v2 net-next 4/7] tcp: Make use of MSG_EOR flag in tcp_sendmsg
Date: Mon, 18 Apr 2016 15:46:06 -0700
Message-ID: <1461019569-3037369-5-git-send-email-kafai@fb.com>
References: <1461019569-3037369-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46327 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751164AbcDRWqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 18:46:30 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3IMjSfq025851
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22d7r6r96s-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:46:29 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 634d717005b711e6ba510002c991e86a-b3ff2c50 for <netdev@vger.kernel.org>;	Mon,
 18 Apr 2016 15:46:28 -0700
In-Reply-To: <1461019569-3037369-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the user process to use MSG_EOR during
tcp_sendmsg to tell the kernel that it is the last byte
of an application response message.

It is currently useful when the end-user has turned on any bit of the
SOF_TIMESTAMPING_TX_RECORD_MASK (either by setsockopt or cmsg).
The kernel will then mark the newly added tcb->eor_info bit so
that the shinfo->tskey will not be overwritten (i.e. lost) in
the later skb append/collapse operation.

With selective SOF_TIMESTAMPING_TX_ACK (by cmsg) and MSG_EOR (this
patch), the user application can specially tell which outgoing byte
it wants to track its ACK and ask the kernel not to lose this
tracking info in the later skb append/collapse action.

This patch handles the append case in tcp_sendmsg.  The later
patches will handle the collapse during retransmission and
skb slicing in tcp_fragment()/tso_fragment().

One of our use case is at the webserver.  The webserver tracks
the HTTP2 response latency by measuring when the webserver sends
the first byte to the socket till the TCP ACK of the last byte
is received.  In the cases where we don't have client side
measurement, measuring from the server side is the only option.
In the cases we have the client side measurement, the server side
data can also be used to justify/cross-check-with the client
side data.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h |  5 ++++-
 net/ipv4/tcp.c    | 21 +++++++++++++++++----
 2 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c0ef054..f3c5dcb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -762,7 +762,10 @@ struct tcp_skb_cb {
 
 	__u8		ip_dsfield;	/* IPv4 tos or IPv6 dsfield	*/
 	__u8		txstamp_ack:1,	/* Record TX timestamp for ack? */
-			unused:7;
+			eor_info:1,	/* Any EOR marked info that prevents
+					 * skbs from merging.
+					 */
+			unused:6;
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 	union {
 		struct inet_skb_parm	h4;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4d73858..2918f42 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -428,15 +428,18 @@ void tcp_init_sock(struct sock *sk)
 }
 EXPORT_SYMBOL(tcp_init_sock);
 
-static void tcp_tx_timestamp(struct sock *sk, u16 tsflags, struct sk_buff *skb)
+static void tcp_tx_timestamp(struct sock *sk, u16 tsflags, struct sk_buff *skb,
+			     int flags)
 {
 	if (sk->sk_tsflags || tsflags) {
 		struct skb_shared_info *shinfo = skb_shinfo(skb);
 		struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
 		sock_tx_timestamp(sk, tsflags, &shinfo->tx_flags);
-		if (shinfo->tx_flags & SKBTX_ANY_TSTAMP)
+		if (shinfo->tx_flags & SKBTX_ANY_TSTAMP) {
 			shinfo->tskey = TCP_SKB_CB(skb)->seq + skb->len - 1;
+			tcb->eor_info = !!(flags & MSG_EOR);
+		}
 		tcb->txstamp_ack = !!(shinfo->tx_flags & SKBTX_ACK_TSTAMP);
 	}
 }
@@ -874,6 +877,13 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }
 
+static bool tcp_sendmsg_noappend(struct sock *sk, u16 tx_tsflags)
+{
+	return unlikely((tx_tsflags & SOF_TIMESTAMPING_TX_RECORD_MASK) &&
+			tcp_send_head(sk) &&
+			TCP_SKB_CB(tcp_write_queue_tail(sk))->eor_info);
+}
+
 static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 				size_t size, int flags)
 {
@@ -959,7 +969,7 @@ new_segment:
 		offset += copy;
 		size -= copy;
 		if (!size) {
-			tcp_tx_timestamp(sk, sk->sk_tsflags, skb);
+			tcp_tx_timestamp(sk, sk->sk_tsflags, skb, 0);
 			goto out;
 		}
 
@@ -1145,6 +1155,9 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 
 	sg = !!(sk->sk_route_caps & NETIF_F_SG);
 
+	if (tcp_sendmsg_noappend(sk, sockc.tsflags))
+		goto new_segment;
+
 	while (msg_data_left(msg)) {
 		int copy = 0;
 		int max = size_goal;
@@ -1249,7 +1262,7 @@ new_segment:
 
 		copied += copy;
 		if (!msg_data_left(msg)) {
-			tcp_tx_timestamp(sk, sockc.tsflags, skb);
+			tcp_tx_timestamp(sk, sockc.tsflags, skb, flags);
 			goto out;
 		}
 
-- 
2.5.1
