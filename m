From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/5] tcp: fix fastopen races vs lockless listener
Date: Sun,  4 Oct 2015 21:08:07 -0700
Message-ID: <1444018091-21987-2-git-send-email-edumazet@google.com>
References: <1444018091-21987-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33700 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbJEEIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 00:08:24 -0400
Received: by pacex6 with SMTP id ex6so163663562pac.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 21:08:24 -0700 (PDT)
In-Reply-To: <1444018091-21987-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are multiple races that need fixes :

1) skb_get() + queue skb + kfree_skb() is racy

An accept() can be done on another cpu, data consumed immediately.
tcp_recvmsg() uses __kfree_skb() as it is assumed all skb found in
socket receive queue are private.

Then the kfree_skb() in tcp_rcv_state_process() uses an already freed skb

2) tcp_reqsk_record_syn() needs to be done before tcp_try_fastopen()
for the same reasons.

3) We want to send the SYNACK before queueing child into accept queue,
otherwise we might reintroduce the ooo issue fixed in
commit 7c85af881044 ("tcp: avoid reorders for TFO passive connections")

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_fastopen.c | 26 +++++++-------------------
 net/ipv4/tcp_input.c    |  6 +++++-
 2 files changed, 12 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 410ac481fda0..93396bf7b475 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -168,8 +168,6 @@ static struct sock *tcp_fastopen_create_child(struct sock *sk,
 				  TCP_TIMEOUT_INIT, TCP_RTO_MAX);
 
 	atomic_set(&req->rsk_refcnt, 2);
-	/* Add the child socket directly into the accept queue */
-	inet_csk_reqsk_queue_add(sk, req, child);
 
 	/* Now finish processing the fastopen child socket. */
 	inet_csk(child)->icsk_af_ops->rebuild_header(child);
@@ -178,12 +176,10 @@ static struct sock *tcp_fastopen_create_child(struct sock *sk,
 	tcp_init_metrics(child);
 	tcp_init_buffer_space(child);
 
-	/* Queue the data carried in the SYN packet. We need to first
-	 * bump skb's refcnt because the caller will attempt to free it.
-	 * Note that IPv6 might also have used skb_get() trick
-	 * in tcp_v6_conn_request() to keep this SYN around (treq->pktopts)
-	 * So we need to eventually get a clone of the packet,
-	 * before inserting it in sk_receive_queue.
+	/* Queue the data carried in the SYN packet.
+	 * We used to play tricky games with skb_get().
+	 * With lockless listener, it is a dead end.
+	 * Do not think about it.
 	 *
 	 * XXX (TFO) - we honor a zero-payload TFO request for now,
 	 * (any reason not to?) but no need to queue the skb since
@@ -191,12 +187,7 @@ static struct sock *tcp_fastopen_create_child(struct sock *sk,
 	 */
 	end_seq = TCP_SKB_CB(skb)->end_seq;
 	if (end_seq != TCP_SKB_CB(skb)->seq + 1) {
-		struct sk_buff *skb2;
-
-		if (unlikely(skb_shared(skb)))
-			skb2 = skb_clone(skb, GFP_ATOMIC);
-		else
-			skb2 = skb_get(skb);
+		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
 		if (likely(skb2)) {
 			skb_dst_drop(skb2);
@@ -214,12 +205,9 @@ static struct sock *tcp_fastopen_create_child(struct sock *sk,
 		}
 	}
 	tcp_rsk(req)->rcv_nxt = tp->rcv_nxt = end_seq;
-	sk->sk_data_ready(sk);
-	bh_unlock_sock(child);
-	/* Note: sock_put(child) will be done by tcp_conn_request()
-	 * after SYNACK packet is sent.
+	/* tcp_conn_request() is sending the SYNACK,
+	 * and queues the child into listener accept queue.
 	 */
-	WARN_ON(!req->sk);
 	return child;
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 27108757c310..a95c8eb04ff7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6229,12 +6229,16 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tcp_rsk(req)->txhash = net_tx_rndhash();
 	tcp_openreq_init_rwin(req, sk, dst);
 	if (!want_cookie) {
-		fastopen_sk = tcp_try_fastopen(sk, skb, req, &foc, dst);
 		tcp_reqsk_record_syn(sk, req, skb);
+		fastopen_sk = tcp_try_fastopen(sk, skb, req, &foc, dst);
 	}
 	if (fastopen_sk) {
 		af_ops->send_synack(fastopen_sk, dst, &fl, req,
 				    skb_get_queue_mapping(skb), &foc, false);
+		/* Add the child socket directly into the accept queue */
+		inet_csk_reqsk_queue_add(sk, req, fastopen_sk);
+		sk->sk_data_ready(sk);
+		bh_unlock_sock(fastopen_sk);
 		sock_put(fastopen_sk);
 	} else {
 		tcp_rsk(req)->tfo_listener = false;
-- 
2.6.0.rc2.230.g3dd15c0
