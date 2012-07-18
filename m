From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH v2 4/7] net-tcp: Fast Open client - receiving SYN-ACK
Date: Wed, 18 Jul 2012 14:01:44 -0700
Message-ID: <1342645307-17772-5-git-send-email-ycheng@google.com>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
Cc: sivasankar@cs.ucsd.edu, ycheng@google.com, netdev@vger.kernel.org
To: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f74.google.com ([209.85.214.74]:52374 "EHLO
	mail-bk0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab2GRVCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:02:35 -0400
Received: by bkcjc3 with SMTP id jc3so106871bkc.1
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:02:33 -0700 (PDT)
In-Reply-To: <1342645307-17772-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On receiving the SYN-ACK after SYN-data, the client needs to
a) update the cached MSS and cookie (if included in SYN-ACK)
b) retransmit the data not yet acknowledged by the SYN-ACK in the final ACK of
   the handshake.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |   40 +++++++++++++++++++++++++++++++++++-----
 1 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a06bb89..38b6a81 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5646,6 +5646,34 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	}
 }
 
+static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
+				    struct tcp_fastopen_cookie *cookie)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *data = tcp_write_queue_head(sk);
+	u16 mss = tp->rx_opt.mss_clamp;
+
+	if (mss == tp->rx_opt.user_mss) {
+		struct tcp_options_received opt;
+		const u8 *hash_location;
+
+		/* Get original SYNACK MSS value if user MSS sets mss_clamp */
+		tcp_clear_options(&opt);
+		opt.user_mss = opt.mss_clamp = 0;
+		tcp_parse_options(synack, &opt, &hash_location, 0, NULL);
+		mss = opt.mss_clamp;
+	}
+
+	tcp_fastopen_cache_set(sk, mss, cookie);
+
+	if (data) { /* Retransmit unacked data in SYN */
+		tcp_retransmit_skb(sk, data);
+		tcp_rearm_rto(sk);
+		return true;
+	}
+	return false;
+}
+
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 const struct tcphdr *th, unsigned int len)
 {
@@ -5653,9 +5681,10 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_cookie_values *cvp = tp->cookie_values;
+	struct tcp_fastopen_cookie foc = { .len = -1 };
 	int saved_clamp = tp->rx_opt.mss_clamp;
 
-	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0, NULL);
+	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0, &foc);
 
 	if (th->ack) {
 		/* rfc793:
@@ -5665,11 +5694,9 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 *	  If SEG.ACK =< ISS, or SEG.ACK > SND.NXT, send
 		 *        a reset (unless the RST bit is set, if so drop
 		 *        the segment and return)"
-		 *
-		 *  We do not send data with SYN, so that RFC-correct
-		 *  test reduces to:
 		 */
-		if (TCP_SKB_CB(skb)->ack_seq != tp->snd_nxt)
+		if (!after(TCP_SKB_CB(skb)->ack_seq, tp->snd_una) ||
+		    after(TCP_SKB_CB(skb)->ack_seq, tp->snd_nxt))
 			goto reset_and_undo;
 
 		if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
@@ -5781,6 +5808,9 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 
 		tcp_finish_connect(sk, skb);
 
+		if (tp->syn_fastopen && tcp_rcv_fastopen_synack(sk, skb, &foc))
+			return -1;
+
 		if (sk->sk_write_pending ||
 		    icsk->icsk_accept_queue.rskq_defer_accept ||
 		    icsk->icsk_ack.pingpong) {
-- 
1.7.7.3
