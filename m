From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH v2 net-next 2/3] tcp: add in_flight to tcp_skb_cb
Date: Tue, 21 Jul 2015 21:21:35 -0700
Message-ID: <1437538896-1330704-3-git-send-email-brakmo@fb.com>
References: <1437538896-1330704-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:1269 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751219AbbGVEVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 00:21:43 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6M4GiBe005195
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 21:21:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vt0rmgbqf-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 21:21:42 -0700
Received: from facebook.com (2401:db00:20:a00f:face:0:16:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 279107dc302911e5ad6e0002c9931860-fbbfc2b0 for <netdev@vger.kernel.org>;	Tue,
 21 Jul 2015 21:21:42 -0700
In-Reply-To: <1437538896-1330704-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on comments by Neal Cardwell to tcp_nv patch:

  AFAICT this patch would not require an increase in the size of sk_buff
  cb[] if it were to take advantage of the fact that the tcp_skb_cb
  header.h4 and header.h6 fields are only used in the packet reception
  code path, and this in_flight field is only used on the transmit
  side. So the in_flight field could be placed in a struct that is
  itself placed in a union with the "header" union.

  That way the sender code can remember the in_flight value
  without requiring any extra space. And in the future other
  sender-side info could be stored in the "tx" struct, if needed.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/net/tcp.h     | 13 ++++++++++---
 net/ipv4/tcp_input.c  |  5 ++++-
 net/ipv4/tcp_output.c |  4 +++-
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 26e7651..2e62efe 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -755,11 +755,17 @@ struct tcp_skb_cb {
 	/* 1 byte hole */
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 	union {
-		struct inet_skb_parm	h4;
+		struct {
+			/* bytes in flight when this packet was sent */
+			__u32 in_flight;
+		} tx;   /* only used for outgoing skbs */
+		union {
+			struct inet_skb_parm	h4;
 #if IS_ENABLED(CONFIG_IPV6)
-		struct inet6_skb_parm	h6;
+			struct inet6_skb_parm	h6;
 #endif
-	} header;	/* For incoming frames		*/
+		} header;	/* For incoming skbs */
+	};
 };
 
 #define TCP_SKB_CB(__skb)	((struct tcp_skb_cb *)&((__skb)->cb[0]))
@@ -837,6 +843,7 @@ union tcp_cc_info;
 struct ack_sample {
 	u32 pkts_acked;
 	s32 rtt_us;
+	u32 in_flight;
 };
 
 struct tcp_congestion_ops {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4f641f6..aca4ae5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3068,6 +3068,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	long ca_rtt_us = -1L;
 	struct sk_buff *skb;
 	u32 pkts_acked = 0;
+	u32 last_in_flight = 0;
 	bool rtt_update;
 	int flag = 0;
 
@@ -3107,6 +3108,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			if (!first_ackt.v64)
 				first_ackt = last_ackt;
 
+			last_in_flight = TCP_SKB_CB(skb)->tx.in_flight;
 			reord = min(pkts_acked, reord);
 			if (!after(scb->end_seq, tp->high_seq))
 				flag |= FLAG_ORIG_SACK_ACKED;
@@ -3196,7 +3198,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	}
 
 	if (icsk->icsk_ca_ops->pkts_acked) {
-		struct ack_sample sample = {pkts_acked, ca_rtt_us};
+		struct ack_sample sample = {pkts_acked, ca_rtt_us,
+					    last_in_flight};
 
 		icsk->icsk_ca_ops->pkts_acked(sk, sample);
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7105784..e9deab5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -920,9 +920,12 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	int err;
 
 	BUG_ON(!skb || !tcp_skb_pcount(skb));
+	tp = tcp_sk(sk);
 
 	if (clone_it) {
 		skb_mstamp_get(&skb->skb_mstamp);
+		TCP_SKB_CB(skb)->tx.in_flight = TCP_SKB_CB(skb)->end_seq
+			- tp->snd_una;
 
 		if (unlikely(skb_cloned(skb)))
 			skb = pskb_copy(skb, gfp_mask);
@@ -933,7 +936,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	}
 
 	inet = inet_sk(sk);
-	tp = tcp_sk(sk);
 	tcb = TCP_SKB_CB(skb);
 	memset(&opts, 0, sizeof(opts));
 
-- 
1.8.1
