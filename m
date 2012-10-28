From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next v2] tcp: better retrans tracking for defer-accept
Date: Sun, 28 Oct 2012 10:16:46 +0100
Message-ID: <1351415806.30380.401.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	ncardwell@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Elliott Hughes <enh@google.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
To: David Miller <davem@davemloft.net>, Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:53754 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab2J1JQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 05:16:50 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1330058eaa.19
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2012 02:16:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

For passive TCP connections using TCP_DEFER_ACCEPT facility,
we incorrectly increment req->retrans each time timeout triggers
while no SYNACK is sent.

SYNACK are not sent for TCP_DEFER_ACCEPT that were established (for wich
we received the ACK from client). Only the last SYNACK is
sent so that we can receive again an ACK from client, to move the
req into accept queue. We plan to change this later to avoid
the useless retransmit (and potential problem as this SYNACK could be
lost)

TCP_INFO later gives wrong information to user, claiming imaginary
retransmits.

Decouple req->retrans field into two independent fields :

num_retrans : number of retransmit
num_timeout : number of timeouts

num_timeout is the counter that is incremented at each timeout,
regardless of actual SYNACK being sent or not, and used to
compute the exponential timeout.

Introduce inet_rtx_syn_ack() helper to increment num_retrans
only if ->rtx_syn_ack() succeeded.

Use inet_rtx_syn_ack() from tcp_check_req() to increment num_retrans
when we re-send a SYNACK in answer to a (retransmitted) SYN.
Prior to this patch, we were not counting these retransmits.

Change tcp_v[46]_rtx_synack() to increment TCP_MIB_RETRANSSEGS
only if a synack packet was successfully queued.

Reported-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>
Cc: Elliott Hughes <enh@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
v2: fix get_openreq4() per Neal & Julian review
    Make sure to use real net-next tree

 include/net/request_sock.h      |   12 ++++++++----
 net/dccp/minisocks.c            |    3 +--
 net/ipv4/inet_connection_sock.c |   25 ++++++++++++++++++-------
 net/ipv4/inet_diag.c            |    2 +-
 net/ipv4/syncookies.c           |    2 +-
 net/ipv4/tcp_input.c            |    2 +-
 net/ipv4/tcp_ipv4.c             |   16 ++++++++++------
 net/ipv4/tcp_minisocks.c        |    8 ++++----
 net/ipv4/tcp_timer.c            |    8 ++++----
 net/ipv6/syncookies.c           |    2 +-
 net/ipv6/tcp_ipv6.c             |   11 +++++++----
 11 files changed, 56 insertions(+), 35 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index b01d8dd..a51dbd1 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -49,13 +49,16 @@ struct request_sock_ops {
 					   struct request_sock *req);
 };
 
+extern int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req);
+
 /* struct request_sock - mini sock to represent a connection request
  */
 struct request_sock {
 	struct request_sock		*dl_next; /* Must be first member! */
 	u16				mss;
-	u8				retrans;
-	u8				cookie_ts; /* syncookie: encode tcpopts in timestamp */
+	u8				num_retrans; /* number of retransmits */
+	u8				cookie_ts:1; /* syncookie: encode tcpopts in timestamp */
+	u8				num_timeout:7; /* number of timeouts */
 	/* The following two fields can be easily recomputed I think -AK */
 	u32				window_clamp; /* window clamp at creation time */
 	u32				rcv_wnd;	  /* rcv_wnd offered first time */
@@ -231,7 +234,7 @@ static inline int reqsk_queue_removed(struct request_sock_queue *queue,
 {
 	struct listen_sock *lopt = queue->listen_opt;
 
-	if (req->retrans == 0)
+	if (req->num_timeout == 0)
 		--lopt->qlen_young;
 
 	return --lopt->qlen;
@@ -269,7 +272,8 @@ static inline void reqsk_queue_hash_req(struct request_sock_queue *queue,
 	struct listen_sock *lopt = queue->listen_opt;
 
 	req->expires = jiffies + timeout;
-	req->retrans = 0;
+	req->num_retrans = 0;
+	req->num_timeout = 0;
 	req->sk = NULL;
 	req->dl_next = lopt->syn_table[hash];
 
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index ea850ce..662071b 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -174,8 +174,7 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 			 * To protect against Request floods, increment retrans
 			 * counter (backoff, monitored by dccp_response_timer).
 			 */
-			req->retrans++;
-			req->rsk_ops->rtx_syn_ack(sk, req, NULL);
+			inet_rtx_syn_ack(sk, req);
 		}
 		/* Network Duplicate, discard packet */
 		return NULL;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index d34ce29..2026542 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -521,21 +521,31 @@ static inline void syn_ack_recalc(struct request_sock *req, const int thresh,
 				  int *expire, int *resend)
 {
 	if (!rskq_defer_accept) {
-		*expire = req->retrans >= thresh;
+		*expire = req->num_timeout >= thresh;
 		*resend = 1;
 		return;
 	}
-	*expire = req->retrans >= thresh &&
-		  (!inet_rsk(req)->acked || req->retrans >= max_retries);
+	*expire = req->num_timeout >= thresh &&
+		  (!inet_rsk(req)->acked || req->num_timeout >= max_retries);
 	/*
 	 * Do not resend while waiting for data after ACK,
 	 * start to resend on end of deferring period to give
 	 * last chance for data or ACK to create established socket.
 	 */
 	*resend = !inet_rsk(req)->acked ||
-		  req->retrans >= rskq_defer_accept - 1;
+		  req->num_timeout >= rskq_defer_accept - 1;
 }
 
+int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req)
+{
+	int err = req->rsk_ops->rtx_syn_ack(parent, req, NULL);
+
+	if (!err)
+		req->num_retrans++;
+	return err;
+}
+EXPORT_SYMBOL(inet_rtx_syn_ack);
+
 void inet_csk_reqsk_queue_prune(struct sock *parent,
 				const unsigned long interval,
 				const unsigned long timeout,
@@ -599,13 +609,14 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 				req->rsk_ops->syn_ack_timeout(parent, req);
 				if (!expire &&
 				    (!resend ||
-				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL) ||
+				     !inet_rtx_syn_ack(parent, req) ||
 				     inet_rsk(req)->acked)) {
 					unsigned long timeo;
 
-					if (req->retrans++ == 0)
+					if (req->num_timeout++ == 0)
 						lopt->qlen_young--;
-					timeo = min((timeout << req->retrans), max_rto);
+					timeo = min(timeout << req->num_timeout,
+						    max_rto);
 					req->expires = now + timeo;
 					reqp = &req->dl_next;
 					continue;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e5bad82..b5e781b 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -620,7 +620,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_family = sk->sk_family;
 	r->idiag_state = TCP_SYN_RECV;
 	r->idiag_timer = 1;
-	r->idiag_retrans = req->retrans;
+	r->idiag_retrans = req->num_retrans;
 
 	r->id.idiag_if = sk->sk_bound_dev_if;
 	sock_diag_save_cookie(req, r->id.idiag_cookie);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index ba48e79..b236ef0 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -340,7 +340,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	}
 
 	req->expires	= 0UL;
-	req->retrans	= 0;
+	req->num_retrans = 0;
 
 	/*
 	 * We need to lookup the route here to get at the correct
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 60cf836..e95b4e5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5991,7 +5991,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 				 */
 				if (req) {
 					tcp_synack_rtt_meas(sk, req);
-					tp->total_retrans = req->retrans;
+					tp->total_retrans = req->num_retrans;
 
 					reqsk_fastopen_remove(sk, req, false);
 				} else {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 694ea4c..ad4ed75 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -877,10 +877,13 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 }
 
 static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req,
-			      struct request_values *rvp)
+			     struct request_values *rvp)
 {
-	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-	return tcp_v4_send_synack(sk, NULL, req, rvp, 0, false);
+	int res = tcp_v4_send_synack(sk, NULL, req, rvp, 0, false);
+
+	if (!res)
+		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
+	return res;
 }
 
 /*
@@ -1386,7 +1389,8 @@ static int tcp_v4_conn_req_fastopen(struct sock *sk,
 	struct sock *child;
 	int err;
 
-	req->retrans = 0;
+	req->num_retrans = 0;
+	req->num_timeout = 0;
 	req->sk = NULL;
 
 	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
@@ -1740,7 +1744,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	tcp_initialize_rcv_mss(newsk);
 	tcp_synack_rtt_meas(newsk, req);
-	newtp->total_retrans = req->retrans;
+	newtp->total_retrans = req->num_retrans;
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
@@ -2638,7 +2642,7 @@ static void get_openreq4(const struct sock *sk, const struct request_sock *req,
 		0, 0, /* could print option size, but that is af dependent. */
 		1,    /* timers active (only the expire timer) */
 		jiffies_delta_to_clock_t(delta),
-		req->retrans,
+		req->num_timeout,
 		from_kuid_munged(seq_user_ns(f), uid),
 		0,  /* non standard timer */
 		0, /* open_requests have no inode */
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 27536ba..0404b3f 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -552,7 +552,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			 * it can be estimated (approximately)
 			 * from another data.
 			 */
-			tmp_opt.ts_recent_stamp = get_seconds() - ((TCP_TIMEOUT_INIT/HZ)<<req->retrans);
+			tmp_opt.ts_recent_stamp = get_seconds() - ((TCP_TIMEOUT_INIT/HZ)<<req->num_timeout);
 			paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
 		}
 	}
@@ -581,7 +581,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 		 * Note that even if there is new data in the SYN packet
 		 * they will be thrown away too.
 		 */
-		req->rsk_ops->rtx_syn_ack(sk, req, NULL);
+		inet_rtx_syn_ack(sk, req);
 		return NULL;
 	}
 
@@ -695,7 +695,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	/* Got ACK for our SYNACK, so update baseline for SYNACK RTT sample. */
 	if (tmp_opt.saw_tstamp && tmp_opt.rcv_tsecr)
 		tcp_rsk(req)->snt_synack = tmp_opt.rcv_tsecr;
-	else if (req->retrans) /* don't take RTT sample if retrans && ~TS */
+	else if (req->num_retrans) /* don't take RTT sample if retrans && ~TS */
 		tcp_rsk(req)->snt_synack = 0;
 
 	/* For Fast Open no more processing is needed (sk is the
@@ -705,7 +705,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 		return sk;
 
 	/* While TCP_DEFER_ACCEPT is active, drop bare ACK. */
-	if (req->retrans < inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
+	if (req->num_timeout < inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
 	    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
 		inet_rsk(req)->acked = 1;
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDEFERACCEPTDROP);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index fc04711..62c69ab 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -318,7 +318,7 @@ static void tcp_fastopen_synack_timer(struct sock *sk)
 	req = tcp_sk(sk)->fastopen_rsk;
 	req->rsk_ops->syn_ack_timeout(sk, req);
 
-	if (req->retrans >= max_retries) {
+	if (req->num_timeout >= max_retries) {
 		tcp_write_err(sk);
 		return;
 	}
@@ -327,10 +327,10 @@ static void tcp_fastopen_synack_timer(struct sock *sk)
 	 * regular retransmit because if the child socket has been accepted
 	 * it's not good to give up too easily.
 	 */
-	req->rsk_ops->rtx_syn_ack(sk, req, NULL);
-	req->retrans++;
+	inet_rtx_syn_ack(sk, req);
+	req->num_timeout++;
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-			  TCP_TIMEOUT_INIT << req->retrans, TCP_RTO_MAX);
+			  TCP_TIMEOUT_INIT << req->num_timeout, TCP_RTO_MAX);
 }
 
 /*
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 182ab9a..4016197 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -214,7 +214,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		ireq6->iif = inet6_iif(skb);
 
 	req->expires = 0UL;
-	req->retrans = 0;
+	req->num_retrans = 0;
 	ireq->ecn_ok		= ecn_ok;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index bb6782e..c73d0eb 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -495,9 +495,12 @@ static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req,
 			     struct request_values *rvp)
 {
 	struct flowi6 fl6;
+	int res;
 
-	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-	return tcp_v6_send_synack(sk, NULL, &fl6, req, rvp, 0);
+	res = tcp_v6_send_synack(sk, NULL, &fl6, req, rvp, 0);
+	if (!res)
+		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
+	return res;
 }
 
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
@@ -1364,7 +1367,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	tcp_initialize_rcv_mss(newsk);
 	tcp_synack_rtt_meas(newsk, req);
-	newtp->total_retrans = req->retrans;
+	newtp->total_retrans = req->num_retrans;
 
 	newinet->inet_daddr = newinet->inet_saddr = LOOPBACK4_IPV6;
 	newinet->inet_rcv_saddr = LOOPBACK4_IPV6;
@@ -1866,7 +1869,7 @@ static void get_openreq6(struct seq_file *seq,
 		   0,0, /* could print option size, but that is af dependent. */
 		   1,   /* timers active (only the expire timer) */
 		   jiffies_to_clock_t(ttd),
-		   req->retrans,
+		   req->num_timeout,
 		   from_kuid_munged(seq_user_ns(seq), uid),
 		   0,  /* non standard timer */
 		   0, /* open_requests have no inode */
