From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 1/5] tcp: make is_dupack a parameter to tcp_fastretrans_alert()
Date: Wed, 16 Nov 2011 13:58:01 -0500
Message-ID: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f202.google.com ([74.125.82.202]:45634 "EHLO
	mail-wy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab1KPTDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 14:03:32 -0500
Received: by wye20 with SMTP id 20so18915wye.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 11:03:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow callers to decide whether an ACK is a duplicate ACK. This is a
prerequisite to allowing fastretrans_alert to be called from new
contexts, such as the no_queue and old_ack code paths, from which we
have extra info that tells us whether an ACK is a dupack.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 52b5c2d..f772aaa 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3009,11 +3009,11 @@ static void tcp_update_cwnd_in_recovery(struct sock *sk, int newly_acked_sacked,
  * tcp_xmit_retransmit_queue().
  */
 static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
-				  int newly_acked_sacked, int flag)
+				  int newly_acked_sacked, bool is_dupack,
+				  int flag)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	int is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
 	int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit = 0, mib_idx;
@@ -3681,10 +3681,12 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	u32 prior_snd_una = tp->snd_una;
 	u32 ack_seq = TCP_SKB_CB(skb)->seq;
 	u32 ack = TCP_SKB_CB(skb)->ack_seq;
+	bool is_dupack = false;
 	u32 prior_in_flight;
 	u32 prior_fackets;
 	int prior_packets;
 	int prior_sacked = tp->sacked_out;
+	int pkts_acked = 0;
 	int newly_acked_sacked = 0;
 	int frto_cwnd = 0;
 
@@ -3757,6 +3759,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	/* See if we can take anything off of the retransmit queue. */
 	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una);
 
+	pkts_acked = prior_packets - tp->packets_out;
 	newly_acked_sacked = (prior_packets - prior_sacked) -
 			     (tp->packets_out - tp->sacked_out);
 
@@ -3771,8 +3774,9 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
 		    tcp_may_raise_cwnd(sk, flag))
 			tcp_cong_avoid(sk, ack, prior_in_flight);
-		tcp_fastretrans_alert(sk, prior_packets - tp->packets_out,
-				      newly_acked_sacked, flag);
+		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
+		tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
+				      is_dupack, flag);
 	} else {
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
 			tcp_cong_avoid(sk, ack, prior_in_flight);
-- 
1.7.3.1
