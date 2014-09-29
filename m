From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next 2/2] tcp: change TCP_ECN prefixes to lower case
Date: Mon, 29 Sep 2014 13:08:30 +0200
Message-ID: <1411988910-23710-2-git-send-email-fw@strlen.de>
References: <1411988910-23710-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59435 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751917AbaI2LIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 07:08:41 -0400
In-Reply-To: <1411988910-23710-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested by Stephen. Also drop inline keyword and let compiler decide.

gcc 4.7.3 decides to no longer inline tcp_ecn_check_ce, so split it up.
The actual evaluation is not inlined anymore while the ECN_OK test is.

Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_input.c     | 41 ++++++++++++++++++++++-------------------
 net/ipv4/tcp_minisocks.c |  6 +++---
 net/ipv4/tcp_output.c    | 18 +++++++++---------
 3 files changed, 34 insertions(+), 31 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 174181e..aa38f98 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -201,28 +201,25 @@ static inline bool tcp_in_quickack_mode(const struct sock *sk)
 	return icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong;
 }
 
-static inline void TCP_ECN_queue_cwr(struct tcp_sock *tp)
+static void tcp_ecn_queue_cwr(struct tcp_sock *tp)
 {
 	if (tp->ecn_flags & TCP_ECN_OK)
 		tp->ecn_flags |= TCP_ECN_QUEUE_CWR;
 }
 
-static inline void TCP_ECN_accept_cwr(struct tcp_sock *tp, const struct sk_buff *skb)
+static void tcp_ecn_accept_cwr(struct tcp_sock *tp, const struct sk_buff *skb)
 {
 	if (tcp_hdr(skb)->cwr)
 		tp->ecn_flags &= ~TCP_ECN_DEMAND_CWR;
 }
 
-static inline void TCP_ECN_withdraw_cwr(struct tcp_sock *tp)
+static void tcp_ecn_withdraw_cwr(struct tcp_sock *tp)
 {
 	tp->ecn_flags &= ~TCP_ECN_DEMAND_CWR;
 }
 
-static inline void TCP_ECN_check_ce(struct tcp_sock *tp, const struct sk_buff *skb)
+static void __tcp_ecn_check_ce(struct tcp_sock *tp, const struct sk_buff *skb)
 {
-	if (!(tp->ecn_flags & TCP_ECN_OK))
-		return;
-
 	switch (TCP_SKB_CB(skb)->ip_dsfield & INET_ECN_MASK) {
 	case INET_ECN_NOT_ECT:
 		/* Funny extension: if ECT is not set on a segment,
@@ -251,19 +248,25 @@ static inline void TCP_ECN_check_ce(struct tcp_sock *tp, const struct sk_buff *s
 	}
 }
 
-static inline void TCP_ECN_rcv_synack(struct tcp_sock *tp, const struct tcphdr *th)
+static void tcp_ecn_check_ce(struct tcp_sock *tp, const struct sk_buff *skb)
+{
+	if (tp->ecn_flags & TCP_ECN_OK)
+		__tcp_ecn_check_ce(tp, skb);
+}
+
+static void tcp_ecn_rcv_synack(struct tcp_sock *tp, const struct tcphdr *th)
 {
 	if ((tp->ecn_flags & TCP_ECN_OK) && (!th->ece || th->cwr))
 		tp->ecn_flags &= ~TCP_ECN_OK;
 }
 
-static inline void TCP_ECN_rcv_syn(struct tcp_sock *tp, const struct tcphdr *th)
+static void tcp_ecn_rcv_syn(struct tcp_sock *tp, const struct tcphdr *th)
 {
 	if ((tp->ecn_flags & TCP_ECN_OK) && (!th->ece || !th->cwr))
 		tp->ecn_flags &= ~TCP_ECN_OK;
 }
 
-static bool TCP_ECN_rcv_ecn_echo(const struct tcp_sock *tp, const struct tcphdr *th)
+static bool tcp_ecn_rcv_ecn_echo(const struct tcp_sock *tp, const struct tcphdr *th)
 {
 	if (th->ece && !th->syn && (tp->ecn_flags & TCP_ECN_OK))
 		return true;
@@ -660,7 +663,7 @@ static void tcp_event_data_recv(struct sock *sk, struct sk_buff *skb)
 	}
 	icsk->icsk_ack.lrcvtime = now;
 
-	TCP_ECN_check_ce(tp, skb);
+	tcp_ecn_check_ce(tp, skb);
 
 	if (skb->len >= 128)
 		tcp_grow_window(sk, skb);
@@ -1976,7 +1979,7 @@ void tcp_enter_loss(struct sock *sk)
 				       sysctl_tcp_reordering);
 	tcp_set_ca_state(sk, TCP_CA_Loss);
 	tp->high_seq = tp->snd_nxt;
-	TCP_ECN_queue_cwr(tp);
+	tcp_ecn_queue_cwr(tp);
 
 	/* F-RTO RFC5682 sec 3.1 step 1: retransmit SND.UNA if no previous
 	 * loss recovery is underway except recurring timeout(s) on
@@ -2368,7 +2371,7 @@ static void tcp_undo_cwnd_reduction(struct sock *sk, bool unmark_loss)
 
 		if (tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh = tp->prior_ssthresh;
-			TCP_ECN_withdraw_cwr(tp);
+			tcp_ecn_withdraw_cwr(tp);
 		}
 	} else {
 		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh);
@@ -2498,7 +2501,7 @@ static void tcp_init_cwnd_reduction(struct sock *sk)
 	tp->prr_delivered = 0;
 	tp->prr_out = 0;
 	tp->snd_ssthresh = inet_csk(sk)->icsk_ca_ops->ssthresh(sk);
-	TCP_ECN_queue_cwr(tp);
+	tcp_ecn_queue_cwr(tp);
 }
 
 static void tcp_cwnd_reduction(struct sock *sk, const int prior_unsacked,
@@ -3453,7 +3456,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 			flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una,
 							&sack_rtt_us);
 
-		if (TCP_ECN_rcv_ecn_echo(tp, tcp_hdr(skb))) {
+		if (tcp_ecn_rcv_ecn_echo(tp, tcp_hdr(skb))) {
 			flag |= FLAG_ECE;
 			ack_ev_flags |= CA_ACK_ECE;
 		}
@@ -4193,7 +4196,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 	struct sk_buff *skb1;
 	u32 seq, end_seq;
 
-	TCP_ECN_check_ce(tp, skb);
+	tcp_ecn_check_ce(tp, skb);
 
 	if (unlikely(tcp_try_rmem_schedule(sk, skb, skb->truesize))) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFODROP);
@@ -4376,7 +4379,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 	skb_dst_drop(skb);
 	__skb_pull(skb, tcp_hdr(skb)->doff * 4);
 
-	TCP_ECN_accept_cwr(tp, skb);
+	tcp_ecn_accept_cwr(tp, skb);
 
 	tp->rx_opt.dsack = 0;
 
@@ -5457,7 +5460,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 *    state to ESTABLISHED..."
 		 */
 
-		TCP_ECN_rcv_synack(tp, th);
+		tcp_ecn_rcv_synack(tp, th);
 
 		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
 		tcp_ack(sk, skb, FLAG_SLOWPATH);
@@ -5576,7 +5579,7 @@ discard:
 		tp->snd_wl1    = TCP_SKB_CB(skb)->seq;
 		tp->max_window = tp->snd_wnd;
 
-		TCP_ECN_rcv_syn(tp, th);
+		tcp_ecn_rcv_syn(tp, th);
 
 		tcp_mtup_init(sk);
 		tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 47b7350..63d2680 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -393,8 +393,8 @@ void tcp_openreq_init_rwin(struct request_sock *req,
 }
 EXPORT_SYMBOL(tcp_openreq_init_rwin);
 
-static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
-					 struct request_sock *req)
+static void tcp_ecn_openreq_child(struct tcp_sock *tp,
+				  const struct request_sock *req)
 {
 	tp->ecn_flags = inet_rsk(req)->ecn_ok ? TCP_ECN_OK : 0;
 }
@@ -507,7 +507,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		if (skb->len >= TCP_MSS_DEFAULT + newtp->tcp_header_len)
 			newicsk->icsk_ack.last_seg_size = skb->len - newtp->tcp_header_len;
 		newtp->rx_opt.mss_clamp = req->mss;
-		TCP_ECN_openreq_child(newtp, req);
+		tcp_ecn_openreq_child(newtp, req);
 		newtp->fastopen_rsk = NULL;
 		newtp->syn_data_acked = 0;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 86a0216..ee567e9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -318,7 +318,7 @@ static u16 tcp_select_window(struct sock *sk)
 }
 
 /* Packet ECN state for a SYN-ACK */
-static inline void TCP_ECN_send_synack(struct sock *sk, struct sk_buff *skb)
+static void tcp_ecn_send_synack(struct sock *sk, struct sk_buff *skb)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 
@@ -330,7 +330,7 @@ static inline void TCP_ECN_send_synack(struct sock *sk, struct sk_buff *skb)
 }
 
 /* Packet ECN state for a SYN.  */
-static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
+static void tcp_ecn_send_syn(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -344,8 +344,8 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 	}
 }
 
-static __inline__ void
-TCP_ECN_make_synack(const struct request_sock *req, struct tcphdr *th,
+static void
+tcp_ecn_make_synack(const struct request_sock *req, struct tcphdr *th,
 		    struct sock *sk)
 {
 	if (inet_rsk(req)->ecn_ok) {
@@ -358,7 +358,7 @@ TCP_ECN_make_synack(const struct request_sock *req, struct tcphdr *th,
 /* Set up ECN state for a packet on a ESTABLISHED socket that is about to
  * be sent.
  */
-static inline void TCP_ECN_send(struct sock *sk, struct sk_buff *skb,
+static void tcp_ecn_send(struct sock *sk, struct sk_buff *skb,
 				int tcp_header_len)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -960,7 +960,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	tcp_options_write((__be32 *)(th + 1), tp, &opts);
 	if (likely((tcb->tcp_flags & TCPHDR_SYN) == 0))
-		TCP_ECN_send(sk, skb, tcp_header_size);
+		tcp_ecn_send(sk, skb, tcp_header_size);
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Calculate the MD5 hash, as we have all we need now */
@@ -2800,7 +2800,7 @@ int tcp_send_synack(struct sock *sk)
 		}
 
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ACK;
-		TCP_ECN_send_synack(sk, skb);
+		tcp_ecn_send_synack(sk, skb);
 	}
 	return tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 }
@@ -2859,7 +2859,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	memset(th, 0, sizeof(struct tcphdr));
 	th->syn = 1;
 	th->ack = 1;
-	TCP_ECN_make_synack(req, th, sk);
+	tcp_ecn_make_synack(req, th, sk);
 	th->source = htons(ireq->ir_num);
 	th->dest = ireq->ir_rmt_port;
 	/* Setting of flags are superfluous here for callers (and ECE is
@@ -3098,7 +3098,7 @@ int tcp_connect(struct sock *sk)
 	tcp_init_nondata_skb(buff, tp->write_seq++, TCPHDR_SYN);
 	tp->retrans_stamp = tcp_time_stamp;
 	tcp_connect_queue_skb(sk, buff);
-	TCP_ECN_send_syn(sk, buff);
+	tcp_ecn_send_syn(sk, buff);
 
 	/* Send off SYN; include data in Fast Open. */
 	err = tp->fastopen_req ? tcp_send_syn_data(sk, buff) :
-- 
1.8.1.5
