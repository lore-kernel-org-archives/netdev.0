From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: [PATCH net-next 2/3] tcp: improve RTT from SACK for CC
Date: Thu, 30 Apr 2015 18:23:31 +0200
Message-ID: <1430411012-4939-2-git-send-email-kennetkl@ifi.uio.no>
References: <1430411012-4939-1-git-send-email-kennetkl@ifi.uio.no>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:58382 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891AbbD3QZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 12:25:20 -0400
In-Reply-To: <1430411012-4939-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_sacktag_one() always picks the earliest sequence SACKed for RTT.
This might not make sense for congestion control in cases where:

  1. ACKs are lost, i.e. a SACK following a lost SACK covers both
     new and old segments at the receiver.
  2. The receiver disregards the RFC 5681 recommendation to immediately
     ACK out-of-order segments.

Give congestion control a RTT for the latest segment SACKed, which is the
most accurate RTT estimate, but preserve the conservative RTT for RTO.

Removes the call to skb_mstamp_get() in tcp_sacktag_one().

Cc: Yuchung Cheng <ycheng@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
---
 net/ipv4/tcp_input.c | 42 ++++++++++++++++++++++++------------------
 1 file changed, 24 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9902cf1..32bac6a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1130,7 +1130,14 @@ static bool tcp_check_dsack(struct sock *sk, const struct sk_buff *ack_skb,
 struct tcp_sacktag_state {
 	int	reord;
 	int	fack_count;
-	long	rtt_us; /* RTT measured by SACKing never-retransmitted data */
+	/* Timestamps for earliest and latest never-retransmitted segment
+	 * that was SACKed. RTO needs the earliest RTT to be conservative
+	 * against receivers that might delay SACKing (RFC 5681 does not
+	 * require ACKing out-of-order segments immediately), but congestion
+	 * control should still get an accurate delay signal.
+	 */
+	struct skb_mstamp first_sackt;
+	struct skb_mstamp last_sackt;
 	int	flag;
 };
 
@@ -1233,14 +1240,9 @@ static u8 tcp_sacktag_one(struct sock *sk,
 							   state->reord);
 				if (!after(end_seq, tp->high_seq))
 					state->flag |= FLAG_ORIG_SACK_ACKED;
-				/* Pick the earliest sequence sacked for RTT */
-				if (state->rtt_us < 0) {
-					struct skb_mstamp now;
-
-					skb_mstamp_get(&now);
-					state->rtt_us = skb_mstamp_us_delta(&now,
-								xmit_time);
-				}
+				if (state->first_sackt.v64 == 0)
+					state->first_sackt = *xmit_time;
+				state->last_sackt = *xmit_time;
 			}
 
 			if (sacked & TCPCB_LOST) {
@@ -3049,7 +3051,8 @@ static void tcp_ack_tstamp(struct sock *sk, struct sk_buff *skb,
  * arrived at the other end.
  */
 static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
-			       u32 prior_snd_una, long sack_rtt_us)
+			       u32 prior_snd_una,
+			       struct tcp_sacktag_state *sack)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct skb_mstamp first_ackt, last_ackt, now;
@@ -3057,8 +3060,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	u32 prior_sacked = tp->sacked_out;
 	u32 reord = tp->packets_out;
 	bool fully_acked = true;
-	long ca_seq_rtt_us = -1L;
+	long sack_rtt_us = -1L;
 	long seq_rtt_us = -1L;
+	long ca_rtt_us = -1L;
 	struct sk_buff *skb;
 	u32 pkts_acked = 0;
 	bool rtt_update;
@@ -3147,7 +3151,11 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	skb_mstamp_get(&now);
 	if (likely(first_ackt.v64)) {
 		seq_rtt_us = skb_mstamp_us_delta(&now, &first_ackt);
-		ca_seq_rtt_us = skb_mstamp_us_delta(&now, &last_ackt);
+		ca_rtt_us = skb_mstamp_us_delta(&now, &last_ackt);
+	}
+	if (sack->first_sackt.v64) {
+		sack_rtt_us = skb_mstamp_us_delta(&now, &sack->first_sackt);
+		ca_rtt_us = skb_mstamp_us_delta(&now, &sack->last_sackt);
 	}
 
 	rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt_us, sack_rtt_us);
@@ -3178,10 +3186,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 		tp->fackets_out -= min(pkts_acked, tp->fackets_out);
 
-		if (ca_ops->pkts_acked) {
-			long rtt_us = min_t(ulong, ca_seq_rtt_us, sack_rtt_us);
-			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
-		}
+		if (ca_ops->pkts_acked)
+			ca_ops->pkts_acked(sk, pkts_acked, ca_rtt_us);
 
 	} else if (skb && rtt_update && sack_rtt_us >= 0 &&
 		   sack_rtt_us > skb_mstamp_us_delta(&now, &skb->skb_mstamp)) {
@@ -3466,7 +3472,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	const int prior_unsacked = tp->packets_out - tp->sacked_out;
 	int acked = 0; /* Number of packets newly acked */
 
-	sack_state.rtt_us = -1L;
+	sack_state.first_sackt.v64 = 0;
 
 	/* We very likely will need to access write queue head. */
 	prefetchw(sk->sk_write_queue.next);
@@ -3555,7 +3561,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	/* See if we can take anything off of the retransmit queue. */
 	acked = tp->packets_out;
 	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una,
-				    sack_state.rtt_us);
+				    &sack_state);
 	acked -= tp->packets_out;
 
 	/* Advance cwnd if state allows */
-- 
2.1.0
