From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v2 1/2] tcp: add in_flight to tcp_skb_cb
Date: Wed, 8 Jun 2016 21:16:44 -0700
Message-ID: <1465445805-2521783-2-git-send-email-brakmo@fb.com>
References: <1465445805-2521783-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60558 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752459AbcFIERD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 00:17:03 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u594GQ3M003067
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2016 21:17:02 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23ex8k0g4x-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 21:17:02 -0700
Received: from facebook.com (2401:db00:11:d037:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 02d104a02df911e692b20002c9521c9e-c2bf62e0 for <netdev@vger.kernel.org>;	Wed,
 08 Jun 2016 21:17:00 -0700
In-Reply-To: <1465445805-2521783-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add in_flight (bytes in flight when packet was sent) field
to tx component of tcp_skb_cb and make it available to
congestion modules' pkts_acked() function through the
ack_sample function argument.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h     | 2 ++
 net/ipv4/tcp_input.c  | 5 ++++-
 net/ipv4/tcp_output.c | 4 +++-
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0bcc70f..a79894b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -767,6 +767,7 @@ struct tcp_skb_cb {
 	union {
 		struct {
 			/* There is space for up to 20 bytes */
+			__u32 in_flight;/* Bytes in flight when packet sent */
 		} tx;   /* only used for outgoing skbs */
 		union {
 			struct inet_skb_parm	h4;
@@ -859,6 +860,7 @@ union tcp_cc_info;
 struct ack_sample {
 	u32 pkts_acked;
 	s32 rtt_us;
+	u32 in_flight;
 };
 
 struct tcp_congestion_ops {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6c8f4cd0..c7f33f0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3115,6 +3115,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	long ca_rtt_us = -1L;
 	struct sk_buff *skb;
 	u32 pkts_acked = 0;
+	u32 last_in_flight = 0;
 	bool rtt_update;
 	int flag = 0;
 
@@ -3154,6 +3155,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			if (!first_ackt.v64)
 				first_ackt = last_ackt;
 
+			last_in_flight = TCP_SKB_CB(skb)->tx.in_flight;
 			reord = min(pkts_acked, reord);
 			if (!after(scb->end_seq, tp->high_seq))
 				flag |= FLAG_ORIG_SACK_ACKED;
@@ -3250,7 +3252,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 	if (icsk->icsk_ca_ops->pkts_acked) {
 		struct ack_sample sample = { .pkts_acked = pkts_acked,
-					     .rtt_us = ca_rtt_us };
+					     .rtt_us = ca_rtt_us,
+					     .in_flight = last_in_flight };
 
 		icsk->icsk_ca_ops->pkts_acked(sk, &sample);
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8bd9911..b1bcba0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -911,9 +911,12 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	int err;
 
 	BUG_ON(!skb || !tcp_skb_pcount(skb));
+	tp = tcp_sk(sk);
 
 	if (clone_it) {
 		skb_mstamp_get(&skb->skb_mstamp);
+		TCP_SKB_CB(skb)->tx.in_flight = TCP_SKB_CB(skb)->end_seq
+			- tp->snd_una;
 
 		if (unlikely(skb_cloned(skb)))
 			skb = pskb_copy(skb, gfp_mask);
@@ -924,7 +927,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	}
 
 	inet = inet_sk(sk);
-	tp = tcp_sk(sk);
 	tcb = TCP_SKB_CB(skb);
 	memset(&opts, 0, sizeof(opts));
 
-- 
2.8.0.rc2
