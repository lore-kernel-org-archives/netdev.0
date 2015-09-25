From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: avoid reorders for TFO passive connections
Date: Thu, 24 Sep 2015 17:16:05 -0700
Message-ID: <1443140165.29850.181.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33238 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbbIYAQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 20:16:08 -0400
Received: by pacex6 with SMTP id ex6so87278043pac.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 17:16:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We found that a TCP Fast Open passive connection was vulnerable
to reorders, as the exchange might look like

[1] C -> S S <FO ...> <request>
[2] S -> C S. ack request <options>
[3] S -> C . <answer>

packets [2] and [3] can be generated at almost the same time.

If C receives the 3rd packet before the 2nd, it will drop it as
the socket is in SYN_SENT state and expects a SYNACK.

S will have to retransmit the answer.

Current OOO avoidance in linux is defeated because SYNACK
packets are attached to the LISTEN socket, while DATA packets
are attached to the children. They might be sent by different cpus,
and different TX queues might be selected.

It turns out that for TFO, we created a child, which is a
full blown socket in TCP_SYN_RECV state, and we simply can attach
the SYNACK packet to this socket.

This means that at the time tcp_sendmsg() pushes DATA packet,
skb->ooo_okay will be set iff the SYNACK packet had been sent
and TX completed.

This removes the reorder source at the host level.

We also removed the export of tcp_try_fastopen(), as it is no
longer called from IPv6.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h       |    8 ++++----
 net/ipv4/tcp_fastopen.c |   35 +++++++++++++++++++----------------
 net/ipv4/tcp_input.c    |   19 +++++++++++--------
 3 files changed, 34 insertions(+), 28 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5cf9672c13e2..8397d49b47d4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1421,10 +1421,10 @@ void tcp_free_fastopen_req(struct tcp_sock *tp);
 
 extern struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 int tcp_fastopen_reset_cipher(void *key, unsigned int len);
-bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
-		      struct request_sock *req,
-		      struct tcp_fastopen_cookie *foc,
-		      struct dst_entry *dst);
+struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
+			      struct request_sock *req,
+			      struct tcp_fastopen_cookie *foc,
+			      struct dst_entry *dst);
 void tcp_fastopen_init_key_once(bool publish);
 #define TCP_FASTOPEN_KEY_LENGTH 16
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index f9c0fb84e435..db43c6286cf7 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -124,10 +124,10 @@ static bool tcp_fastopen_cookie_gen(struct request_sock *req,
 	return false;
 }
 
-static bool tcp_fastopen_create_child(struct sock *sk,
-				      struct sk_buff *skb,
-				      struct dst_entry *dst,
-				      struct request_sock *req)
+static struct sock *tcp_fastopen_create_child(struct sock *sk,
+					      struct sk_buff *skb,
+					      struct dst_entry *dst,
+					      struct request_sock *req)
 {
 	struct tcp_sock *tp;
 	struct request_sock_queue *queue = &inet_csk(sk)->icsk_accept_queue;
@@ -140,7 +140,7 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 
 	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
 	if (!child)
-		return false;
+		return NULL;
 
 	spin_lock(&queue->fastopenq->lock);
 	queue->fastopenq->qlen++;
@@ -216,9 +216,11 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 	tcp_rsk(req)->rcv_nxt = tp->rcv_nxt = end_seq;
 	sk->sk_data_ready(sk);
 	bh_unlock_sock(child);
-	sock_put(child);
+	/* Note: sock_put(child) will be done by tcp_conn_request()
+	 * after SYNACK packet is sent.
+	 */
 	WARN_ON(!req->sk);
-	return true;
+	return child;
 }
 
 static bool tcp_fastopen_queue_check(struct sock *sk)
@@ -261,13 +263,14 @@ static bool tcp_fastopen_queue_check(struct sock *sk)
  * may be updated and return the client in the SYN-ACK later. E.g., Fast Open
  * cookie request (foc->len == 0).
  */
-bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
-		      struct request_sock *req,
-		      struct tcp_fastopen_cookie *foc,
-		      struct dst_entry *dst)
+struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
+			      struct request_sock *req,
+			      struct tcp_fastopen_cookie *foc,
+			      struct dst_entry *dst)
 {
 	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
 	bool syn_data = TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1;
+	struct sock *child;
 
 	if (foc->len == 0) /* Client requests a cookie */
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENCOOKIEREQD);
@@ -276,7 +279,7 @@ bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 	      (syn_data || foc->len >= 0) &&
 	      tcp_fastopen_queue_check(sk))) {
 		foc->len = -1;
-		return false;
+		return NULL;
 	}
 
 	if (syn_data && (sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD))
@@ -296,11 +299,12 @@ bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 		 * data in SYN_RECV state.
 		 */
 fastopen:
-		if (tcp_fastopen_create_child(sk, skb, dst, req)) {
+		child = tcp_fastopen_create_child(sk, skb, dst, req);
+		if (child) {
 			foc->len = -1;
 			NET_INC_STATS_BH(sock_net(sk),
 					 LINUX_MIB_TCPFASTOPENPASSIVE);
-			return true;
+			return child;
 		}
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
 	} else if (foc->len > 0) /* Client presents an invalid cookie */
@@ -308,6 +312,5 @@ fastopen:
 
 	valid_foc.exp = foc->exp;
 	*foc = valid_foc;
-	return false;
+	return NULL;
 }
-EXPORT_SYMBOL(tcp_try_fastopen);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 497adf58a6b8..4964d53907e9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6111,14 +6111,15 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		     const struct tcp_request_sock_ops *af_ops,
 		     struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_fastopen_cookie foc = { .len = -1 };
+	__u32 isn = TCP_SKB_CB(skb)->tcp_tw_isn;
 	struct tcp_options_received tmp_opt;
-	struct request_sock *req;
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct sock *fastopen_sk = NULL;
 	struct dst_entry *dst = NULL;
-	__u32 isn = TCP_SKB_CB(skb)->tcp_tw_isn;
-	bool want_cookie = false, fastopen;
+	struct request_sock *req;
+	bool want_cookie = false;
 	struct flowi fl;
-	struct tcp_fastopen_cookie foc = { .len = -1 };
 	int err;
 
 
@@ -6229,11 +6230,13 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	tcp_rsk(req)->snt_isn = isn;
 	tcp_rsk(req)->txhash = net_tx_rndhash();
 	tcp_openreq_init_rwin(req, sk, dst);
-	fastopen = !want_cookie &&
-		   tcp_try_fastopen(sk, skb, req, &foc, dst);
-	err = af_ops->send_synack(sk, dst, &fl, req,
+	if (!want_cookie)
+		fastopen_sk = tcp_try_fastopen(sk, skb, req, &foc, dst);
+	err = af_ops->send_synack(fastopen_sk ?: sk, dst, &fl, req,
 				  skb_get_queue_mapping(skb), &foc);
-	if (!fastopen) {
+	if (fastopen_sk) {
+		sock_put(fastopen_sk);
+	} else {
 		if (err || want_cookie)
 			goto drop_and_free;
 
