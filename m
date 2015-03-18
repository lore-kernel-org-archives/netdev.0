From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/6] tcp: rename struct tcp_request_sock listener
Date: Tue, 17 Mar 2015 18:32:29 -0700
Message-ID: <1426642351-26098-5-git-send-email-edumazet@google.com>
References: <1426642351-26098-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:48556 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932743AbbCRBe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 21:34:29 -0400
Received: by mail-vc0-f201.google.com with SMTP id id10so8039850vcb.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 18:34:28 -0700 (PDT)
In-Reply-To: <1426642351-26098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The listener field in struct tcp_request_sock is a pointer
back to the listener. We now have req->rsk_listener, so TCP
only needs one boolean and not a full pointer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h             |  2 +-
 net/core/request_sock.c         | 18 +++++++-----------
 net/ipv4/inet_connection_sock.c |  7 +++----
 net/ipv4/syncookies.c           |  2 +-
 net/ipv4/tcp_fastopen.c         |  7 +------
 net/ipv4/tcp_input.c            |  2 +-
 net/ipv6/syncookies.c           |  2 +-
 7 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 97dbf16f7d9d..f869ae8afbaf 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -111,7 +111,7 @@ struct tcp_request_sock_ops;
 struct tcp_request_sock {
 	struct inet_request_sock 	req;
 	const struct tcp_request_sock_ops *af_specific;
-	struct sock			*listener; /* needed for TFO */
+	bool				tfo_listener;
 	u32				rcv_isn;
 	u32				snt_isn;
 	u32				snt_synack; /* synack sent time */
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index e910317ef6d9..cc39a2aa663a 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -153,24 +153,22 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
  * case might also exist in tcp_v4_hnd_req() that will trigger this locking
  * order.
  *
- * When a TFO req is created, it needs to sock_hold its listener to prevent
- * the latter data structure from going away.
- *
- * This function also sets "treq->listener" to NULL and unreference listener
- * socket. treq->listener is used by the listener so it is protected by the
+ * This function also sets "treq->tfo_listener" to false.
+ * treq->tfo_listener is used by the listener so it is protected by the
  * fastopenq->lock in this function.
  */
 void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
 			   bool reset)
 {
-	struct sock *lsk = tcp_rsk(req)->listener;
-	struct fastopen_queue *fastopenq =
-	    inet_csk(lsk)->icsk_accept_queue.fastopenq;
+	struct sock *lsk = req->rsk_listener;
+	struct fastopen_queue *fastopenq;
+
+	fastopenq = inet_csk(lsk)->icsk_accept_queue.fastopenq;
 
 	tcp_sk(sk)->fastopen_rsk = NULL;
 	spin_lock_bh(&fastopenq->lock);
 	fastopenq->qlen--;
-	tcp_rsk(req)->listener = NULL;
+	tcp_rsk(req)->tfo_listener = false;
 	if (req->sk)	/* the child socket hasn't been accepted yet */
 		goto out;
 
@@ -179,7 +177,6 @@ void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
 		 * special RST handling below.
 		 */
 		spin_unlock_bh(&fastopenq->lock);
-		sock_put(lsk);
 		reqsk_put(req);
 		return;
 	}
@@ -201,5 +198,4 @@ void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
 	fastopenq->qlen++;
 out:
 	spin_unlock_bh(&fastopenq->lock);
-	sock_put(lsk);
 }
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 3390ba6f96b2..741f0d96a7f7 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -325,7 +325,7 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
 	sk_acceptq_removed(sk);
 	if (sk->sk_protocol == IPPROTO_TCP && queue->fastopenq != NULL) {
 		spin_lock_bh(&queue->fastopenq->lock);
-		if (tcp_rsk(req)->listener) {
+		if (tcp_rsk(req)->tfo_listener) {
 			/* We are still waiting for the final ACK from 3WHS
 			 * so can't free req now. Instead, we set req->sk to
 			 * NULL to signify that the child socket is taken
@@ -817,9 +817,9 @@ void inet_csk_listen_stop(struct sock *sk)
 
 		percpu_counter_inc(sk->sk_prot->orphan_count);
 
-		if (sk->sk_protocol == IPPROTO_TCP && tcp_rsk(req)->listener) {
+		if (sk->sk_protocol == IPPROTO_TCP && tcp_rsk(req)->tfo_listener) {
 			BUG_ON(tcp_sk(child)->fastopen_rsk != req);
-			BUG_ON(sk != tcp_rsk(req)->listener);
+			BUG_ON(sk != req->rsk_listener);
 
 			/* Paranoid, to prevent race condition if
 			 * an inbound pkt destined for child is
@@ -828,7 +828,6 @@ void inet_csk_listen_stop(struct sock *sk)
 			 * tcp_v4_destroy_sock().
 			 */
 			tcp_sk(child)->fastopen_rsk = NULL;
-			sock_put(sk);
 		}
 		inet_csk_destroy_sock(child);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index eb940750bb1b..574b67765a06 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -345,7 +345,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
 	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
 	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
-	treq->listener		= NULL;
+	treq->tfo_listener	= false;
 	ireq->ireq_family = AF_INET;
 
 	ireq->ir_iif = sk->sk_bound_dev_if;
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 84381319e1bc..186fd394ec0a 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -155,12 +155,7 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 	tp = tcp_sk(child);
 
 	tp->fastopen_rsk = req;
-	/* Do a hold on the listner sk so that if the listener is being
-	 * closed, the child that has been accepted can live on and still
-	 * access listen_lock.
-	 */
-	sock_hold(sk);
-	tcp_rsk(req)->listener = sk;
+	tcp_rsk(req)->tfo_listener = true;
 
 	/* RFC1323: The window in SYN & SYN/ACK segments is never
 	 * scaled. So correct it appropriately.
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fbe518981d36..a94ddb96fc85 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6120,7 +6120,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		if (err || want_cookie)
 			goto drop_and_free;
 
-		tcp_rsk(req)->listener = NULL;
+		tcp_rsk(req)->tfo_listener = false;
 		af_ops->queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	}
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 039e74dd29fe..1ef0c926ce9d 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -195,7 +195,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	ireq = inet_rsk(req);
 	treq = tcp_rsk(req);
-	treq->listener = NULL;
+	treq->tfo_listener = false;
 	ireq->ireq_family = AF_INET6;
 
 	if (security_inet_conn_request(sk, skb, req))
-- 
2.2.0.rc0.207.ga3a616c
