From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH v5 net-next 3/4] tcp: add in_flight to tcp_skb_cb
Date: Tue, 4 Aug 2015 18:39:07 -0700
Message-ID: <1438738748-1756255-4-git-send-email-brakmo@fb.com>
References: <1438738748-1756255-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49065 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750920AbbHEBjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 21:39:13 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t751cYGh024808
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2015 18:39:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1w35dkghjm-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 18:39:13 -0700
Received: from facebook.com (2401:db00:20:a00f:face:0:16:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 c5bb37c23b1211e584f60002c95209d8-c17fd2b0 for <netdev@vger.kernel.org>;	Tue,
 04 Aug 2015 18:39:11 -0700
In-Reply-To: <1438738748-1756255-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add in_flight (bytes in flight when packet was sent) field
to tx component of tcp_skb_cb and make it available to
congestion modules' pkts_acked() function through the
ack_sample function argument.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/net/tcp.h     | 2 ++
 net/ipv4/tcp_input.c  | 5 ++++-
 net/ipv4/tcp_output.c | 4 +++-
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a086a98..cdd93e5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -757,6 +757,7 @@ struct tcp_skb_cb {
 	union {
 		struct {
 			/* There is space for up to 20 bytes */
+			__u32 in_flight;/* Bytes in flight when packet sent */
 		} tx;   /* only used for outgoing skbs */
 		union {
 			struct inet_skb_parm	h4;
@@ -842,6 +843,7 @@ union tcp_cc_info;
 struct ack_sample {
 	u32 pkts_acked;
 	s32 rtt_us;
+	u32 in_flight;
 };
 
 struct tcp_congestion_ops {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f506a0a..338e6bb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3069,6 +3069,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	long ca_rtt_us = -1L;
 	struct sk_buff *skb;
 	u32 pkts_acked = 0;
+	u32 last_in_flight = 0;
 	bool rtt_update;
 	int flag = 0;
 
@@ -3108,6 +3109,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			if (!first_ackt.v64)
 				first_ackt = last_ackt;
 
+			last_in_flight = TCP_SKB_CB(skb)->tx.in_flight;
 			reord = min(pkts_acked, reord);
 			if (!after(scb->end_seq, tp->high_seq))
 				flag |= FLAG_ORIG_SACK_ACKED;
@@ -3197,7 +3199,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	}
 
 	if (icsk->icsk_ca_ops->pkts_acked) {
-		struct ack_sample sample = {pkts_acked, ca_rtt_us};
+		struct ack_sample sample = {pkts_acked, ca_rtt_us,
+					    last_in_flight};
 
 		icsk->icsk_ca_ops->pkts_acked(sk, &sample);
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7d1efa7..0fccd5f 100644
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
1.8.5.6
