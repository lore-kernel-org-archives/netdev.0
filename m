From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: fix SYNACK RTT estimation in Fast Open
Date: Thu, 24 Oct 2013 08:44:25 -0700
Message-ID: <1382629465-20310-1-git-send-email-ycheng@google.com>
Cc: panweiping3@gmail.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:62966 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756133Ab3JXPwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 11:52:37 -0400
Received: by mail-pa0-f73.google.com with SMTP id kp14so70193pab.4
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 08:52:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tp->lsndtime may not always be the SYNACK timestamp if a passive
Fast Open socket sends data before handshake completes. And if the
remote acknowledges both the data and the SYNACK, the RTT sample
is already taken in tcp_ack(), so no need to call
tcp_update_ack_rtt() in tcp_synack_rtt_meas() aagain.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a16b01b..305cd05 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2871,14 +2871,19 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 }
 
 /* Compute time elapsed between (last) SYNACK and the ACK completing 3WHS. */
-static void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req)
+static void tcp_synack_rtt_meas(struct sock *sk, const u32 synack_stamp)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	s32 seq_rtt = -1;
 
-	if (tp->lsndtime && !tp->total_retrans)
-		seq_rtt = tcp_time_stamp - tp->lsndtime;
-	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt, -1);
+	if (synack_stamp && !tp->total_retrans)
+		seq_rtt = tcp_time_stamp - synack_stamp;
+
+	/* If the ACK acks both the SYNACK and the (Fast Open'd) data packets
+	 * sent in SYN_RECV, SYNACK RTT is the smooth RTT computed in tcp_ack()
+	 */
+	if (!tp->srtt)
+		tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt, -1);
 }
 
 static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
@@ -5587,6 +5592,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 	struct request_sock *req;
 	int queued = 0;
 	bool acceptable;
+	u32 synack_stamp;
 
 	tp->rx_opt.saw_tstamp = 0;
 
@@ -5669,9 +5675,11 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		 * so release it.
 		 */
 		if (req) {
+			synack_stamp = tcp_rsk(req)->snt_synack;
 			tp->total_retrans = req->num_retrans;
 			reqsk_fastopen_remove(sk, req, false);
 		} else {
+			synack_stamp = tp->lsndtime;
 			/* Make sure socket is routed, for correct metrics. */
 			icsk->icsk_af_ops->rebuild_header(sk);
 			tcp_init_congestion_control(sk);
@@ -5694,7 +5702,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		tp->snd_una = TCP_SKB_CB(skb)->ack_seq;
 		tp->snd_wnd = ntohs(th->window) << tp->rx_opt.snd_wscale;
 		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
-		tcp_synack_rtt_meas(sk, req);
+		tcp_synack_rtt_meas(sk, synack_stamp);
 
 		if (tp->rx_opt.tstamp_ok)
 			tp->advmss -= TCPOLEN_TSTAMP_ALIGNED;
-- 
1.8.4.1
