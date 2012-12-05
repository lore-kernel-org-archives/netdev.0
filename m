From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH 3/3] delete request_sock->friend
Date: Wed,  5 Dec 2012 10:54:19 +0800
Message-ID: <d19e6cf3f93f50fb57e89149eac1d0af9a04e153.1354674154.git.wpan@redhat.com>
References: <CAEkNxbGTwGEBMCpSdib_paaxs0ekc52HWNo2Vai0nNSrZ1Zkng@mail.gmail.com>
 <cover.1354674151.git.wpan@redhat.com>
Cc: brutus@google.com, Weiping Pan <wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53861 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661Ab2LECyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 21:54:31 -0500
In-Reply-To: <cover.1354674151.git.wpan@redhat.com>
In-Reply-To: <cover.1354674151.git.wpan@redhat.com>
References: <cover.1354674151.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sock pointed by request_sock->friend may be freed since it does not have a
lock to protect it.
I just delete request_sock->friend since I think it is useless.

For sk_buff->friend, it has the same problem, and we use
"atomic_add(skb->truesize, &sk->sk_wmem_alloc)" to guarantee that the sock can
not be freed before the skb is freed.

Then for 3-way handshake with tcp friends enabled,
SYN->friend is NULL, SYN/ACK->friend is set in tcp_make_synack(),
and ACK->friend is set in tcp_send_ack().

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 include/net/inet_connection_sock.h |    4 ++
 include/net/request_sock.h         |    1 -
 net/ipv4/inet_connection_sock.c    |   58 +++++++++++++++++++++++------------
 net/ipv4/tcp_input.c               |   10 ------
 net/ipv4/tcp_ipv4.c                |    7 +++-
 net/ipv4/tcp_minisocks.c           |    7 ++++-
 net/ipv4/tcp_output.c              |   21 ++++++++-----
 net/ipv6/tcp_ipv6.c                |    1 -
 8 files changed, 66 insertions(+), 43 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index ba1d361..883e029 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -147,6 +147,10 @@ static inline void *inet_csk_ca(const struct sock *sk)
 extern struct sock *inet_csk_clone_lock(const struct sock *sk,
 					const struct request_sock *req,
 					const gfp_t priority);
+extern struct sock *inet_csk_friend_clone_lock(const struct sock *sk,
+					const struct request_sock *req,
+					const struct sk_buff *skb,
+					const gfp_t priority);
 
 enum inet_csk_ack_state_t {
 	ICSK_ACK_SCHED	= 1,
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index c6dfa26..a51dbd1 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -66,7 +66,6 @@ struct request_sock {
 	unsigned long			expires;
 	const struct request_sock_ops	*rsk_ops;
 	struct sock			*sk;
-	struct sock			*friend;
 	u32				secid;
 	u32				peer_secid;
 };
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index ce4b79b..7af92ed 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -659,26 +659,6 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 	if (newsk != NULL) {
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 
-		if (req->friend) {
-			/*
-			 * Make friends with the requestor but the ACK of
-			 * the request is already in-flight so the race is
-			 * on to make friends before the ACK is processed.
-			 * If the requestor's sk_friend value is != NULL
-			 * then the requestor has already processed the
-			 * ACK so indicate state change to wake'm up.
-			 */
-			struct sock *was;
-
-			sock_hold(req->friend);
-			newsk->sk_friend = req->friend;
-			sock_hold(newsk);
-			was = xchg(&req->friend->sk_friend, newsk);
-			/* If requester already connect()ed, maybe sleeping */
-			if (was && !sock_flag(req->friend, SOCK_DEAD))
-				sk->sk_state_change(req->friend);
-		}
-
 		newsk->sk_state = TCP_SYN_RECV;
 		newicsk->icsk_bind_hash = NULL;
 
@@ -700,6 +680,44 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(inet_csk_clone_lock);
 
+/**
+ *	inet_csk_friend_clone_lock - clone an inet socket, and lock its clone
+ *	@sk: the socket to clone
+ *	@req: request_sock
+ *	@skb: who sends the request
+ *	@priority: for allocation (%GFP_KERNEL, %GFP_ATOMIC, etc)
+ *
+ *	Caller must unlock socket even in error path (bh_unlock_sock(newsk))
+ */
+struct sock *inet_csk_friend_clone_lock(const struct sock *sk,
+				 const struct request_sock *req,
+				 const struct sk_buff *skb,
+				 const gfp_t priority)
+{
+	struct sock *newsk = inet_csk_clone_lock(sk, req, priority);
+
+	if (newsk) {
+		struct sock *friend = skb->friend;
+		if (friend) {
+			/*
+			 * Make friends.
+			 */
+			struct sock *was;
+
+			sock_hold(friend);
+			newsk->sk_friend = friend;
+			sock_hold(newsk);
+			was = xchg(&friend->sk_friend, newsk);
+			/* If requester already connect()ed, maybe sleeping */
+			if (was && !sock_flag(friend, SOCK_DEAD))
+				sk->sk_state_change(friend);
+		}
+	}
+
+	return newsk;
+}
+EXPORT_SYMBOL_GPL(inet_csk_friend_clone_lock);
+
 /*
  * At this point, there should be no process reference to this
  * socket, and thus no user references at all.  Therefore we
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9640a81..39db09d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5726,16 +5726,6 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 *    state to ESTABLISHED..."
 		 */
 
-		if (skb->friend) {
-			/*
-			 * If friends haven't been made yet, our sk_friend
-			 * still == NULL, then update with the ACK's friend
-			 * value (the listen()er's sock addr) which is used
-			 * as a place holder.
-			 */
-			cmpxchg(&sk->sk_friend, NULL, skb->friend);
-		}
-
 		TCP_ECN_rcv_synack(tp, th);
 
 		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f494914..8d61e4c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1512,8 +1512,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
 #endif
 
-	req->friend = skb->friend;
-
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
@@ -1873,6 +1871,11 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
 		goto csum_err;
 
+	if (sysctl_tcp_friends && skb->friend) {
+		skb->sk = skb->friend;
+		skb->destructor = sock_wfree;
+	}
+
 	if (sk->sk_state == TCP_LISTEN) {
 		struct sock *nsk = tcp_v4_hnd_req(sk, skb);
 		if (!nsk)
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 36d832a..753126e 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -383,7 +383,12 @@ static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
  */
 struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req, struct sk_buff *skb)
 {
-	struct sock *newsk = inet_csk_clone_lock(sk, req, GFP_ATOMIC);
+	struct sock *newsk = NULL;
+
+	if (sysctl_tcp_friends && skb->friend)
+		newsk = inet_csk_friend_clone_lock(sk, req, skb, GFP_ATOMIC);
+	else
+		newsk = inet_csk_clone_lock(sk, req, GFP_ATOMIC);
 
 	if (newsk != NULL) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 509c5e3..4d71549 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1028,13 +1028,9 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	tcb = TCP_SKB_CB(skb);
 	memset(&opts, 0, sizeof(opts));
 
-	if (unlikely(tcb->tcp_flags & TCPHDR_SYN)) {
-		/* Only try to make friends if enabled */
-		if (sysctl_tcp_friends)
-			skb->friend = sk;
-
+	if (unlikely(tcb->tcp_flags & TCPHDR_SYN))
 		tcp_options_size = tcp_syn_options(sk, skb, &opts, &md5);
-	} else
+	else
 		tcp_options_size = tcp_established_options(sk, skb, &opts,
 							   &md5);
 	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
@@ -1050,7 +1046,11 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	skb_orphan(skb);
 	skb->sk = sk;
-	skb->destructor = (sysctl_tcp_limit_output_bytes > 0) ?
+
+	if (skb->friend)
+		skb->destructor = NULL;
+	else
+		skb->destructor = (sysctl_tcp_limit_output_bytes > 0) ?
 			  tcp_wfree : sock_wfree;
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 
@@ -2734,8 +2734,10 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	memset(&opts, 0, sizeof(opts));
 
 	/* Only try to make friends if enabled */
-	if (sysctl_tcp_friends)
+	if (sysctl_tcp_friends) {
 		skb->friend = sk;
+		atomic_add(skb->truesize, &sk->sk_wmem_alloc);
+	}
 
 #ifdef CONFIG_SYN_COOKIES
 	if (unlikely(req->cookie_ts))
@@ -3120,6 +3122,9 @@ void tcp_send_ack(struct sock *sk)
 
 	/* Send it off, this clears delayed acks for us. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
+
+	if (sysctl_tcp_friends)
+		buff->friend = sk;
 	tcp_transmit_skb(sk, buff, 0, sk_gfp_atomic(sk, GFP_ATOMIC));
 }
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 828d5f7..6565cf5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -969,7 +969,6 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv6_ops;
 #endif
 
-	req->friend = skb->friend;
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
-- 
1.7.4.4
