From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC v2 PATCH 2/3] tcp: Early SYN limit and SYN cookie handling to
	mitigate SYN floods
Date: Thu, 31 May 2012 15:40:03 +0200
Message-ID: <20120531134003.10311.14051.stgit@localhost.localdomain>
References: <20120531133807.10311.79711.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 0304ds2-fs.1.fullrate.dk ([89.150.128.48]:11040 "EHLO
	firesoul.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758032Ab2EaNhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 09:37:43 -0400
In-Reply-To: <20120531133807.10311.79711.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP SYN handling is on the slow path via tcp_v4_rcv(), and is
performed while holding spinlock bh_lock_sock().

Real-life and testlab experiments show, that the kernel choks
when reaching 130Kpps SYN floods (powerful Nehalem 16 cores).
Measuring with perf reveals, that its caused by
bh_lock_sock_nested() call in tcp_v4_rcv().

With this patch, the machine can handle 750Kpps (max of the SYN
flood generator) with cycles to spare, CPU load on the big machine
dropped to 1%, from 100%.

Notice we only handle syn cookie early on, normal SYN packets
are still processed under the bh_lock_sock().

V2:
 - Check for existing connection request (reqsk)
 - Avoid (unlikely) variable race in tcp_make_synack for tcp_full_space(sk)

Signed-off-by: Martin Topholm <mph@hoth.dk>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/tcp_ipv4.c   |   48 +++++++++++++++++++++++++++++++++++++++++-------
 net/ipv4/tcp_output.c |   20 ++++++++++++++------
 2 files changed, 55 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ed9d35a..29e9c4a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1274,8 +1274,10 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
  */
 int tcp_v4_syn_conn_limit(struct sock *sk, struct sk_buff *skb)
 {
-	struct request_sock *req;
+	struct request_sock *req = NULL;
 	struct inet_request_sock *ireq;
+	struct request_sock *exist_req;
+	struct request_sock **prev;
 	struct tcp_options_received tmp_opt;
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
@@ -1290,7 +1292,10 @@ int tcp_v4_syn_conn_limit(struct sock *sk, struct sk_buff *skb)
 	if (isn)
 		goto no_limit;
 
-	/* Start sending SYN cookies when request sock queue is full*/
+	/* Start sending SYN cookies when request sock queue is full
+	 * - Should lock while full queue check, but we don't need
+	 *   that precise/exact threshold here.
+	 */
 	if (!inet_csk_reqsk_queue_is_full(sk))
 		goto no_limit;
 
@@ -1300,6 +1305,29 @@ int tcp_v4_syn_conn_limit(struct sock *sk, struct sk_buff *skb)
 	if (!tcp_syn_flood_action(sk, skb, "TCP"))
 		goto drop; /* Not enabled, indicate drop, due to queue full */
 
+	/* Check for existing connection request (reqsk) as this might
+	 *   be a retransmitted SYN which have gotten into the
+	 *   reqsk_queue.  If so, we choose to drop the reqsk, and use
+	 *   SYN cookies to restore the state later, even-though this
+	 *   can cause issues, if the original SYN/ACK didn't get
+	 *   dropped, but somehow were delayed in the network and the
+	 *   SYN-retransmission timer on the client-side fires before
+	 *   the SYN/ACK reaches the client.  We choose to neglect
+	 *   this situation as we are under attack, and don't want to
+	 *   open an attack vector, of falling back to the slow locked
+	 *   path.
+	 */
+	bh_lock_sock(sk);
+	exist_req = inet_csk_search_req(sk, &prev, tcp_hdr(skb)->source, saddr, daddr);
+	if (exist_req) { /* Drop existing reqsk */
+		if (TCP_SKB_CB(skb)->seq == tcp_rsk(exist_req)->rcv_isn)
+			net_warn_ratelimited("Retransmitted SYN from %pI4"
+					     " (orig reqsk dropped)", &saddr);
+
+		inet_csk_reqsk_queue_drop(sk, exist_req, prev);
+	}
+	bh_unlock_sock(sk);
+
 	/* Allocate a request_sock */
 	req = inet_reqsk_alloc(&tcp_request_sock_ops);
 	if (!req) {
@@ -1331,6 +1359,7 @@ int tcp_v4_syn_conn_limit(struct sock *sk, struct sk_buff *skb)
 	ireq->no_srccheck = inet_sk(sk)->transparent;
 	ireq->opt = tcp_v4_save_options(sk, skb);
 
+	/* Considering lock here, cannot determine security module behavior */
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
@@ -1345,7 +1374,10 @@ int tcp_v4_syn_conn_limit(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->snt_isn = isn;
 	tcp_rsk(req)->snt_synack = tcp_time_stamp;
 
-	/* Send SYN-ACK containing cookie */
+	/* Send SYN-ACK containing cookie
+	 * - tcp_v4_send_synack() handles alloc of a dst route cache,
+	 *   but also releases it immediately afterwards
+	 */
 	tcp_v4_send_synack(sk, NULL, req, NULL);
 
 drop_and_free:
@@ -1382,10 +1414,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
-	/* SYN cookie handling */
-	if (tcp_v4_syn_conn_limit(sk, skb))
-		goto drop;
-
 	req = inet_reqsk_alloc(&tcp_request_sock_ops);
 	if (!req)
 		goto drop;
@@ -1792,6 +1820,12 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
+	/* Early and parallel SYN limit check, that sends syncookies */
+	if (sk->sk_state == TCP_LISTEN && th->syn && !th->ack && !th->fin) {
+		if (tcp_v4_syn_conn_limit(sk, skb))
+			goto discard_and_relse;
+	}
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 803cbfe..81fd4fc 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2458,6 +2458,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	int tcp_header_size;
 	int mss;
 	int s_data_desired = 0;
+	int tcp_full_space_val;
 
 	if (cvp != NULL && cvp->s_data_constant && cvp->s_data_desired)
 		s_data_desired = cvp->s_data_desired;
@@ -2479,13 +2480,16 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		/* Set this up on the first call only */
 		req->window_clamp = tp->window_clamp ? : dst_metric(dst, RTAX_WINDOW);
 
+		/* Instruct compiler not do additional loads */
+		ACCESS_ONCE(tcp_full_space_val) = tcp_full_space(sk);
+
 		/* limit the window selection if the user enforce a smaller rx buffer */
 		if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
-		    (req->window_clamp > tcp_full_space(sk) || req->window_clamp == 0))
-			req->window_clamp = tcp_full_space(sk);
+		    (req->window_clamp > tcp_full_space_val || req->window_clamp == 0))
+			req->window_clamp = tcp_full_space_val;
 
 		/* tcp_full_space because it is guaranteed to be the first packet */
-		tcp_select_initial_window(tcp_full_space(sk),
+		tcp_select_initial_window(tcp_full_space_val,
 			mss - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
 			&req->rcv_wnd,
 			&req->window_clamp,
@@ -2582,6 +2586,7 @@ void tcp_connect_init(struct sock *sk)
 {
 	const struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	int tcp_full_space_val;
 	__u8 rcv_wscale;
 
 	/* We'll fix this up when we get a response from the other end.
@@ -2610,12 +2615,15 @@ void tcp_connect_init(struct sock *sk)
 
 	tcp_initialize_rcv_mss(sk);
 
+	/* Instruct compiler not do additional loads */
+	ACCESS_ONCE(tcp_full_space_val) = tcp_full_space(sk);
+
 	/* limit the window selection if the user enforce a smaller rx buffer */
 	if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
-	    (tp->window_clamp > tcp_full_space(sk) || tp->window_clamp == 0))
-		tp->window_clamp = tcp_full_space(sk);
+	    (tp->window_clamp > tcp_full_space_val || tp->window_clamp == 0))
+		tp->window_clamp = tcp_full_space_val;
 
-	tcp_select_initial_window(tcp_full_space(sk),
+	tcp_select_initial_window(tcp_full_space_val,
 				  tp->advmss - (tp->rx_opt.ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
