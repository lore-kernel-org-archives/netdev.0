From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 13/17] tcp: attach SYNACK messages to request sockets instead of listener
Date: Fri,  2 Oct 2015 11:43:35 -0700
Message-ID: <1443811419-4798-14-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32955 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbbJBSoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:21 -0400
Received: by pacex6 with SMTP id ex6so113541085pac.0
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:21 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a listen backlog is very big (to avoid syncookies), then
the listener sk->sk_wmem_alloc is the main source of false
sharing, as we need to touch it twice per SYNACK re-transmit
and TX completion.

(One SYN packet takes listener lock once, but up to 6 SYNACK
are generated)

By attaching the skb to the request socket, we remove this
source of contention.

Tested:

 listen(fd, 10485760); // single listener (no SO_REUSEPORT)
 16 RX/TX queue NIC
 Sustain a SYNFLOOD attack of ~320,000 SYN per second,
 Sending ~1,400,000 SYNACK per second.
 Perf profiles now show listener spinlock being next bottleneck.

    20.29%  [kernel]  [k] queued_spin_lock_slowpath
    10.06%  [kernel]  [k] __inet_lookup_established
     5.12%  [kernel]  [k] reqsk_timer_handler
     3.22%  [kernel]  [k] get_next_timer_interrupt
     3.00%  [kernel]  [k] tcp_make_synack
     2.77%  [kernel]  [k] ipt_do_table
     2.70%  [kernel]  [k] run_timer_softirq
     2.50%  [kernel]  [k] ip_finish_output
     2.04%  [kernel]  [k] cascade

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h               |  6 ++++--
 net/ipv4/inet_connection_sock.c |  2 +-
 net/ipv4/tcp_fastopen.c         |  4 ++--
 net/ipv4/tcp_input.c            | 23 ++++++++++++-----------
 net/ipv4/tcp_ipv4.c             |  5 +++--
 net/ipv4/tcp_output.c           | 22 +++++++++++++++-------
 net/ipv6/tcp_ipv6.c             |  5 +++--
 net/sched/sch_fq.c              | 12 +++++++-----
 8 files changed, 47 insertions(+), 32 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 225e9561af35..a6be56d5f0e3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -462,7 +462,8 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 int tcp_connect(struct sock *sk);
 struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 				struct request_sock *req,
-				struct tcp_fastopen_cookie *foc);
+				struct tcp_fastopen_cookie *foc,
+				bool attach_req);
 int tcp_disconnect(struct sock *sk, int flags);
 
 void tcp_finish_connect(struct sock *sk, struct sk_buff *skb);
@@ -1715,7 +1716,8 @@ struct tcp_request_sock_ops {
 	__u32 (*init_seq)(const struct sk_buff *skb);
 	int (*send_synack)(const struct sock *sk, struct dst_entry *dst,
 			   struct flowi *fl, struct request_sock *req,
-			   u16 queue_mapping, struct tcp_fastopen_cookie *foc);
+			   u16 queue_mapping, struct tcp_fastopen_cookie *foc,
+			   bool attach_req);
 };
 
 #ifdef CONFIG_SYN_COOKIES
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 80904df02187..099e0ea9242a 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -628,7 +628,7 @@ static void reqsk_queue_hash_req(struct request_sock *req,
 	 * are committed to memory and refcnt initialized.
 	 */
 	smp_wmb();
-	atomic_set(&req->rsk_refcnt, 2);
+	atomic_set(&req->rsk_refcnt, 2 + 1);
 }
 
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index f69f436fcbcc..410ac481fda0 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -161,13 +161,13 @@ static struct sock *tcp_fastopen_create_child(struct sock *sk,
 	tp->snd_wnd = ntohs(tcp_hdr(skb)->window);
 
 	/* Activate the retrans timer so that SYNACK can be retransmitted.
-	 * The request socket is not added to the SYN table of the parent
+	 * The request socket is not added to the ehash
 	 * because it's been added to the accept queue directly.
 	 */
 	inet_csk_reset_xmit_timer(child, ICSK_TIME_RETRANS,
 				  TCP_TIMEOUT_INIT, TCP_RTO_MAX);
 
-	atomic_set(&req->rsk_refcnt, 1);
+	atomic_set(&req->rsk_refcnt, 2);
 	/* Add the child socket directly into the accept queue */
 	inet_csk_reqsk_queue_add(sk, req, child);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a56912772354..27108757c310 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6120,8 +6120,6 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	struct request_sock *req;
 	bool want_cookie = false;
 	struct flowi fl;
-	int err;
-
 
 	/* TW buckets are converted to open requests without
 	 * limitations, they conserve resources and peer is
@@ -6230,21 +6228,24 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tcp_rsk(req)->snt_isn = isn;
 	tcp_rsk(req)->txhash = net_tx_rndhash();
 	tcp_openreq_init_rwin(req, sk, dst);
-	if (!want_cookie)
+	if (!want_cookie) {
 		fastopen_sk = tcp_try_fastopen(sk, skb, req, &foc, dst);
-	err = af_ops->send_synack(fastopen_sk ?: sk, dst, &fl, req,
-				  skb_get_queue_mapping(skb), &foc);
+		tcp_reqsk_record_syn(sk, req, skb);
+	}
 	if (fastopen_sk) {
+		af_ops->send_synack(fastopen_sk, dst, &fl, req,
+				    skb_get_queue_mapping(skb), &foc, false);
 		sock_put(fastopen_sk);
 	} else {
-		if (err || want_cookie)
-			goto drop_and_free;
-
 		tcp_rsk(req)->tfo_listener = false;
-		inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+		if (!want_cookie)
+			inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+		af_ops->send_synack(sk, dst, &fl, req,
+				    skb_get_queue_mapping(skb), &foc, !want_cookie);
+		if (want_cookie)
+			goto drop_and_free;
 	}
-	tcp_reqsk_record_syn(sk, req, skb);
-
+	reqsk_put(req);
 	return 0;
 
 drop_and_release:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bfe9d39ee87d..ac2ea73e9aaf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -822,7 +822,8 @@ static int tcp_v4_send_synack(const struct sock *sk, struct dst_entry *dst,
 			      struct flowi *fl,
 			      struct request_sock *req,
 			      u16 queue_mapping,
-			      struct tcp_fastopen_cookie *foc)
+			      struct tcp_fastopen_cookie *foc,
+				  bool attach_req)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct flowi4 fl4;
@@ -833,7 +834,7 @@ static int tcp_v4_send_synack(const struct sock *sk, struct dst_entry *dst,
 	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
 		return -1;
 
-	skb = tcp_make_synack(sk, dst, req, foc);
+	skb = tcp_make_synack(sk, dst, req, foc, attach_req);
 
 	if (skb) {
 		__tcp_v4_send_check(skb, ireq->ir_loc_addr, ireq->ir_rmt_addr);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 09bb082ca1a7..55ed3266b05f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2947,7 +2947,8 @@ int tcp_send_synack(struct sock *sk)
  */
 struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 				struct request_sock *req,
-				struct tcp_fastopen_cookie *foc)
+				struct tcp_fastopen_cookie *foc,
+				bool attach_req)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	const struct tcp_sock *tp = tcp_sk(sk);
@@ -2959,11 +2960,7 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	u16 user_mss;
 	int mss;
 
-	/* sk is a const pointer, because we want to express multiple cpus
-	 * might call us concurrently.
-	 * sock_wmalloc() will change sk->sk_wmem_alloc in an atomic way.
-	 */
-	skb = sock_wmalloc((struct sock *)sk, MAX_TCP_HEADER, 1, GFP_ATOMIC);
+	skb = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
 	if (unlikely(!skb)) {
 		dst_release(dst);
 		return NULL;
@@ -2971,6 +2968,17 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	/* Reserve space for headers. */
 	skb_reserve(skb, MAX_TCP_HEADER);
 
+	if (attach_req) {
+		skb->destructor = sock_edemux;
+		sock_hold(req_to_sk(req));
+		skb->sk = req_to_sk(req);
+	} else {
+		/* sk is a const pointer, because we want to express multiple
+		 * cpu might call us concurrently.
+		 * sk->sk_wmem_alloc in an atomic, we can promote to rw.
+		 */
+		skb_set_owner_w(skb, (struct sock *)sk);
+	}
 	skb_dst_set(skb, dst);
 
 	mss = dst_metric_advmss(dst);
@@ -3510,7 +3518,7 @@ int tcp_rtx_synack(const struct sock *sk, struct request_sock *req)
 	int res;
 
 	tcp_rsk(req)->txhash = net_tx_rndhash();
-	res = af_ops->send_synack(sk, NULL, &fl, req, 0, NULL);
+	res = af_ops->send_synack(sk, NULL, &fl, req, 0, NULL, true);
 	if (!res) {
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a215614cfb2b..3d18571811c5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -438,7 +438,8 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 			      struct flowi *fl,
 			      struct request_sock *req,
 			      u16 queue_mapping,
-			      struct tcp_fastopen_cookie *foc)
+			      struct tcp_fastopen_cookie *foc,
+			      bool attach_req)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -451,7 +452,7 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 					       IPPROTO_TCP)) == NULL)
 		goto done;
 
-	skb = tcp_make_synack(sk, dst, req, foc);
+	skb = tcp_make_synack(sk, dst, req, foc, attach_req);
 
 	if (skb) {
 		__tcp_v6_send_check(skb, &ireq->ir_v6_loc_addr,
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index f377702d4b91..3386cce4751e 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -224,13 +224,15 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 	if (unlikely((skb->priority & TC_PRIO_MAX) == TC_PRIO_CONTROL))
 		return &q->internal;
 
-	/* SYNACK messages are attached to a listener socket.
-	 * 1) They are not part of a 'flow' yet
-	 * 2) We do not want to rate limit them (eg SYNFLOOD attack),
+	/* SYNACK messages are attached to a TCP_NEW_SYN_RECV request socket
+	 * 1) request sockets are not full blown,
+	 *    they do not contain sk_pacing_rate
+	 * 2) They are not part of a 'flow' yet
+	 * 3) We do not want to rate limit them (eg SYNFLOOD attack),
 	 *    especially if the listener set SO_MAX_PACING_RATE
-	 * 3) We pretend they are orphaned
+	 * 4) We pretend they are orphaned
 	 */
-	if (!sk || sk->sk_state == TCP_LISTEN) {
+	if (!sk || sk->sk_state == TCP_NEW_SYN_RECV) {
 		unsigned long hash = skb_get_hash(skb) & q->orphan_mask;
 
 		/* By forcing low order bit to 1, we make sure to not
-- 
2.6.0.rc2.230.g3dd15c0
