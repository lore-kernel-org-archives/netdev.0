From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: usec resolution SYN/ACK RTT
Date: Fri, 18 Sep 2015 11:36:14 -0700
Message-ID: <1442601374-27885-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35303 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbbIRSgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 14:36:20 -0400
Received: by pacfv12 with SMTP id fv12so58569895pac.2
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 11:36:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently SYN/ACK RTT is measured in jiffies. For LAN the SYN/ACK
RTT is often measured as 0ms or sometimes 1ms, which would affect
RTT estimation and min RTT samping used by some congestion control.

This patch improves SYN/ACK RTT to be usec resolution if platform
supports it. While the timestamping of SYN/ACK is done in request
sock, the RTT measurement is carefully arranged to avoid storing
another u64 timestamp in tcp_sock.

For regular handshake w/o SYNACK retransmission, the RTT is sampled
right after the child socket is created and right before the request
sock is released (tcp_check_req() in tcp_minisocks.c)

For Fast Open the child socket is already created when SYN/ACK was
sent, the RTT is sampled in tcp_rcv_state_process() after processing
the final ACK an right before the request socket is released.

If the SYN/ACK was retransmistted or SYN-cookie was used, we rely
on TCP timestamps to measure the RTT. The sample is taken at the
same place in tcp_rcv_state_process() after the timestamp values
are validated in tcp_validate_incoming(). Note that we do not store
TS echo value in request_sock for SYN-cookies, because the value
is already stored in tp->rx_opt used by tcp_ack_update_rtt().

One side benefit is that the RTT measurement now happens before
initializing congestion control (of the passive side). Therefore
the congestion control can use the SYN/ACK RTT.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h      |  2 +-
 include/net/tcp.h        |  1 +
 net/ipv4/syncookies.c    |  2 +-
 net/ipv4/tcp_input.c     | 29 ++++++++++++++---------------
 net/ipv4/tcp_minisocks.c |  3 ++-
 net/ipv6/syncookies.c    |  2 +-
 6 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 937b978..fcb573b 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -112,11 +112,11 @@ struct tcp_request_sock_ops;
 struct tcp_request_sock {
 	struct inet_request_sock 	req;
 	const struct tcp_request_sock_ops *af_specific;
+	struct skb_mstamp		snt_synack; /* first SYNACK sent time */
 	bool				tfo_listener;
 	u32				txhash;
 	u32				rcv_isn;
 	u32				snt_isn;
-	u32				snt_synack; /* synack sent time */
 	u32				last_oow_ack_time; /* last SYNACK */
 	u32				rcv_nxt; /* the ack # by SYNACK. For
 						  * FastOpen it's the seq#
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0cab28c..5cf9672 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -565,6 +565,7 @@ bool tcp_schedule_loss_probe(struct sock *sk);
 /* tcp_input.c */
 void tcp_resume_early_retransmit(struct sock *sk);
 void tcp_rearm_rto(struct sock *sk);
+void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req);
 void tcp_reset(struct sock *sk);
 
 /* tcp_timer.c */
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index d70b1f6..6595aff 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -345,7 +345,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
 	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
 	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
-	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
+	treq->snt_synack.v64	= 0;
 	treq->tfo_listener	= false;
 
 	ireq->ir_iif = sk->sk_bound_dev_if;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a62e9c7..497adf5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2953,21 +2953,21 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
 }
 
 /* Compute time elapsed between (last) SYNACK and the ACK completing 3WHS. */
-static void tcp_synack_rtt_meas(struct sock *sk, const u32 synack_stamp)
+void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	long seq_rtt_us = -1L;
+	long rtt_us = -1L;
 
-	if (synack_stamp && !tp->total_retrans)
-		seq_rtt_us = jiffies_to_usecs(tcp_time_stamp - synack_stamp);
+	if (req && !req->num_retrans && tcp_rsk(req)->snt_synack.v64) {
+		struct skb_mstamp now;
 
-	/* If the ACK acks both the SYNACK and the (Fast Open'd) data packets
-	 * sent in SYN_RECV, SYNACK RTT is the smooth RTT computed in tcp_ack()
-	 */
-	if (!tp->srtt_us)
-		tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt_us, -1L);
+		skb_mstamp_get(&now);
+		rtt_us = skb_mstamp_us_delta(&now, &tcp_rsk(req)->snt_synack);
+	}
+
+	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L);
 }
 
+
 static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -5706,7 +5706,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 	struct request_sock *req;
 	int queued = 0;
 	bool acceptable;
-	u32 synack_stamp;
 
 	tp->rx_opt.saw_tstamp = 0;
 
@@ -5785,15 +5784,16 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		if (!acceptable)
 			return 1;
 
+		if (!tp->srtt_us)
+			tcp_synack_rtt_meas(sk, req);
+
 		/* Once we leave TCP_SYN_RECV, we no longer need req
 		 * so release it.
 		 */
 		if (req) {
-			synack_stamp = tcp_rsk(req)->snt_synack;
 			tp->total_retrans = req->num_retrans;
 			reqsk_fastopen_remove(sk, req, false);
 		} else {
-			synack_stamp = tp->lsndtime;
 			/* Make sure socket is routed, for correct metrics. */
 			icsk->icsk_af_ops->rebuild_header(sk);
 			tcp_init_congestion_control(sk);
@@ -5816,7 +5816,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		tp->snd_una = TCP_SKB_CB(skb)->ack_seq;
 		tp->snd_wnd = ntohs(th->window) << tp->rx_opt.snd_wscale;
 		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
-		tcp_synack_rtt_meas(sk, synack_stamp);
 
 		if (tp->rx_opt.tstamp_ok)
 			tp->advmss -= TCPOLEN_TSTAMP_ALIGNED;
@@ -6027,7 +6026,7 @@ static void tcp_openreq_init(struct request_sock *req,
 	req->cookie_ts = 0;
 	tcp_rsk(req)->rcv_isn = TCP_SKB_CB(skb)->seq;
 	tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
-	tcp_rsk(req)->snt_synack = tcp_time_stamp;
+	skb_mstamp_get(&tcp_rsk(req)->snt_synack);
 	tcp_rsk(req)->last_oow_ack_time = 0;
 	req->mss = rx_opt->mss_clamp;
 	req->ts_recent = rx_opt->saw_tstamp ? rx_opt->rcv_tsval : 0;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6d8795b..10933d0 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -470,7 +470,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		newtp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
 		tcp_enable_early_retrans(newtp);
 		newtp->tlp_high_seq = 0;
-		newtp->lsndtime = treq->snt_synack;
+		newtp->lsndtime = treq->snt_synack.stamp_jiffies;
 		newtp->last_oow_ack_time = 0;
 		newtp->total_retrans = req->num_retrans;
 
@@ -760,6 +760,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (!child)
 		goto listen_overflow;
 
+	tcp_synack_rtt_meas(child, req);
 	inet_csk_reqsk_queue_drop(sk, req);
 	inet_csk_reqsk_queue_add(sk, req, child);
 	/* Warning: caller must not call reqsk_put(req);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 0909f4e..2461b3f 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -210,7 +210,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
 	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
 	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
-	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
+	treq->snt_synack.v64	= 0;
 	treq->rcv_isn = ntohl(th->seq) - 1;
 	treq->snt_isn = cookie;
 
-- 
2.6.0.rc0.131.gf624c3d
