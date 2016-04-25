From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v4 net-next 2/3] tcp: Handle eor bit when coalescing skb
Date: Mon, 25 Apr 2016 14:44:49 -0700
Message-ID: <1461620690-1081063-3-git-send-email-kafai@fb.com>
References: <1461620690-1081063-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Soheil Hassas Yeganeh <soheil@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:6381 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965004AbcDYVpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 17:45:12 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u3PLiW55015174
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 14:45:11 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 22gukm8u49-3
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 14:45:11 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 f7b137c60b2e11e69e850002c9dfb610-d5dfcc50 for <netdev@vger.kernel.org>;	Mon,
 25 Apr 2016 14:45:03 -0700
In-Reply-To: <1461620690-1081063-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:
1. Prevent next_skb from coalescing to the prev_skb if
   TCP_SKB_CB(prev_skb)->eor is set
2. Update the TCP_SKB_CB(prev_skb)->eor if coalescing is
   allowed

Packetdrill script for testing:
~~~~~~
+0 `sysctl -q -w net.ipv4.tcp_min_tso_segs=10`
+0 `sysctl -q -w net.ipv4.tcp_no_metrics_save=1`
+0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0 bind(3, ..., ...) = 0
+0 listen(3, 1) = 0

0.100 < S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 7>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) = 4
+0 setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) = 0

0.200 sendto(4, ..., 730, MSG_EOR, ..., ...) = 730
0.200 sendto(4, ..., 730, MSG_EOR, ..., ...) = 730
0.200 write(4, ..., 11680) = 11680

0.200 > P. 1:731(730) ack 1
0.200 > P. 731:1461(730) ack 1
0.200 > . 1461:8761(7300) ack 1
0.200 > P. 8761:13141(4380) ack 1

0.300 < . 1:1(0) ack 1 win 257 <sack 1461:13141,nop,nop>
0.300 > P. 1:731(730) ack 1
0.300 > P. 731:1461(730) ack 1
0.400 < . 1:1(0) ack 13141 win 257

0.400 close(4) = 0
0.400 > F. 13141:13141(0) ack 1
0.500 < F. 1:1(0) ack 13142 win 257
0.500 > . 13142:13142(0) ack 2

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c  | 4 ++++
 net/ipv4/tcp_output.c | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index dcad8f9..65fb708 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1303,6 +1303,7 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	}
 
 	TCP_SKB_CB(prev)->tcp_flags |= TCP_SKB_CB(skb)->tcp_flags;
+	TCP_SKB_CB(prev)->eor = TCP_SKB_CB(skb)->eor;
 	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 		TCP_SKB_CB(prev)->end_seq++;
 
@@ -1368,6 +1369,9 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 	if ((TCP_SKB_CB(prev)->sacked & TCPCB_TAGBITS) != TCPCB_SACKED_ACKED)
 		goto fallback;
 
+	if (!tcp_skb_can_collapse_to(prev))
+		goto fallback;
+
 	in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq) &&
 		  !before(end_seq, TCP_SKB_CB(skb)->end_seq);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 9d3b4b3..fa4d17f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2494,6 +2494,7 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 	 * packet counting does not break.
 	 */
 	TCP_SKB_CB(skb)->sacked |= TCP_SKB_CB(next_skb)->sacked & TCPCB_EVER_RETRANS;
+	TCP_SKB_CB(skb)->eor = TCP_SKB_CB(next_skb)->eor;
 
 	/* changed transmit queue under us so clear hints */
 	tcp_clear_retrans_hints_partial(tp);
@@ -2545,6 +2546,9 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 		if (!tcp_can_collapse(sk, skb))
 			break;
 
+		if (!tcp_skb_can_collapse_to(to))
+			break;
+
 		space -= skb->len;
 
 		if (first) {
-- 
2.5.1
