From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH v3 net-next 2/3] tcp: Handle eor bit when coalescing skb
Date: Tue, 19 Apr 2016 23:24:56 -0700
Message-ID: <1461133497-1515104-3-git-send-email-kafai@fb.com>
References: <1461133497-1515104-1-git-send-email-kafai@fb.com>
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
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49039 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752967AbcDTGZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 02:25:09 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3K6OHb1007150
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 23:25:08 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 22d1yk2v3b-4
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 23:25:08 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 9ebf652e06c011e68c7a24be05956610-3dfdc50 for <netdev@vger.kernel.org>;	Tue,
 19 Apr 2016 23:25:05 -0700
In-Reply-To: <1461133497-1515104-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:
1. Prevent next_skb from coalescing to the prev_skb if
   TCP_SKB_CB(prev_skb)->eor is set
2. Update the TCP_SKB_CB(prev_skb)->eor if coalescing is
   allowed

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
index 75e8336..68c55e5 100644
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
 
+	if (TCP_SKB_CB(prev)->eor)
+		goto fallback;
+
 	in_sack = !after(start_seq, TCP_SKB_CB(skb)->seq) &&
 		  !before(end_seq, TCP_SKB_CB(skb)->end_seq);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a6e4a83..96bdf98 100644
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
 
+		if (TCP_SKB_CB(to)->eor)
+			break;
+
 		space -= skb->len;
 
 		if (first) {
-- 
2.5.1
