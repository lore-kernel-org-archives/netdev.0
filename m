From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] tcp: do not mess with listener sk_wmem_alloc
Date: Wed, 13 Apr 2016 22:05:39 -0700
Message-ID: <1460610340-22163-2-git-send-email-edumazet@google.com>
References: <1460610340-22163-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34643 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbcDNFFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 01:05:48 -0400
Received: by mail-pa0-f52.google.com with SMTP id ot11so41354580pab.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 22:05:47 -0700 (PDT)
In-Reply-To: <1460610340-22163-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When removing sk_refcnt manipulation on synflood, I missed that
using skb_set_owner_w() was racy, if sk->sk_wmem_alloc had already
transitioned to 0.

We should hold sk_refcnt instead, but this is a big deal under attack.
(Doing so increase performance from 3.2 Mpps to 3.8 Mpps only)

In this patch, I chose to not attach a socket to syncookies skb.

Performance is now 5 Mpps instead of 3.2 Mpps.

Following patch will remove last known false sharing in
tcp_rcv_state_process()

Fixes: 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     |  9 +++++++--
 net/ipv4/tcp_input.c  |  7 ++++---
 net/ipv4/tcp_ipv4.c   |  4 ++--
 net/ipv4/tcp_output.c | 16 ++++++++++++----
 net/ipv6/tcp_ipv6.c   |  4 ++--
 5 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 74d3ed5eb219..fd40f8c64d5f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -452,10 +452,15 @@ struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 int tcp_connect(struct sock *sk);
+enum tcp_synack_type {
+	TCP_SYNACK_NORMAL,
+	TCP_SYNACK_FASTOPEN,
+	TCP_SYNACK_COOKIE,
+};
 struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 				struct request_sock *req,
 				struct tcp_fastopen_cookie *foc,
-				bool attach_req);
+				enum tcp_synack_type synack_type);
 int tcp_disconnect(struct sock *sk, int flags);
 
 void tcp_finish_connect(struct sock *sk, struct sk_buff *skb);
@@ -1728,7 +1733,7 @@ struct tcp_request_sock_ops {
 	int (*send_synack)(const struct sock *sk, struct dst_entry *dst,
 			   struct flowi *fl, struct request_sock *req,
 			   struct tcp_fastopen_cookie *foc,
-			   bool attach_req);
+			   enum tcp_synack_type synack_type);
 };
 
 #ifdef CONFIG_SYN_COOKIES
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 983f04c11177..7ea7034af83f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6327,7 +6327,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	}
 	if (fastopen_sk) {
 		af_ops->send_synack(fastopen_sk, dst, &fl, req,
-				    &foc, false);
+				    &foc, TCP_SYNACK_FASTOPEN);
 		/* Add the child socket directly into the accept queue */
 		inet_csk_reqsk_queue_add(sk, req, fastopen_sk);
 		sk->sk_data_ready(sk);
@@ -6337,8 +6337,9 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		tcp_rsk(req)->tfo_listener = false;
 		if (!want_cookie)
 			inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
-		af_ops->send_synack(sk, dst, &fl, req,
-				    &foc, !want_cookie);
+		af_ops->send_synack(sk, dst, &fl, req, &foc,
+				    !want_cookie ? TCP_SYNACK_NORMAL :
+						   TCP_SYNACK_COOKIE);
 		if (want_cookie) {
 			reqsk_free(req);
 			return 0;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f4f2a0a3849d..d2a5763e5abc 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -830,7 +830,7 @@ static int tcp_v4_send_synack(const struct sock *sk, struct dst_entry *dst,
 			      struct flowi *fl,
 			      struct request_sock *req,
 			      struct tcp_fastopen_cookie *foc,
-				  bool attach_req)
+			      enum tcp_synack_type synack_type)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct flowi4 fl4;
@@ -841,7 +841,7 @@ static int tcp_v4_send_synack(const struct sock *sk, struct dst_entry *dst,
 	if (!dst && (dst = inet_csk_route_req(sk, &fl4, req)) == NULL)
 		return -1;
 
-	skb = tcp_make_synack(sk, dst, req, foc, attach_req);
+	skb = tcp_make_synack(sk, dst, req, foc, synack_type);
 
 	if (skb) {
 		__tcp_v4_send_check(skb, ireq->ir_loc_addr, ireq->ir_rmt_addr);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7d2dc015cd19..6451b83d81e9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2944,7 +2944,7 @@ int tcp_send_synack(struct sock *sk)
 struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 				struct request_sock *req,
 				struct tcp_fastopen_cookie *foc,
-				bool attach_req)
+				enum tcp_synack_type synack_type)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	const struct tcp_sock *tp = tcp_sk(sk);
@@ -2964,14 +2964,22 @@ struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 	/* Reserve space for headers. */
 	skb_reserve(skb, MAX_TCP_HEADER);
 
-	if (attach_req) {
+	switch (synack_type) {
+	case TCP_SYNACK_NORMAL:
 		skb_set_owner_w(skb, req_to_sk(req));
-	} else {
+		break;
+	case TCP_SYNACK_COOKIE:
+		/* Under synflood, we do not attach skb to a socket,
+		 * to avoid false sharing.
+		 */
+		break;
+	case TCP_SYNACK_FASTOPEN:
 		/* sk is a const pointer, because we want to express multiple
 		 * cpu might call us concurrently.
 		 * sk->sk_wmem_alloc in an atomic, we can promote to rw.
 		 */
 		skb_set_owner_w(skb, (struct sock *)sk);
+		break;
 	}
 	skb_dst_set(skb, dst);
 
@@ -3516,7 +3524,7 @@ int tcp_rtx_synack(const struct sock *sk, struct request_sock *req)
 	int res;
 
 	tcp_rsk(req)->txhash = net_tx_rndhash();
-	res = af_ops->send_synack(sk, NULL, &fl, req, NULL, true);
+	res = af_ops->send_synack(sk, NULL, &fl, req, NULL, TCP_SYNACK_NORMAL);
 	if (!res) {
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0e621bc1ae11..800265c7fd3f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -439,7 +439,7 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 			      struct flowi *fl,
 			      struct request_sock *req,
 			      struct tcp_fastopen_cookie *foc,
-			      bool attach_req)
+			      enum tcp_synack_type synack_type)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -452,7 +452,7 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 					       IPPROTO_TCP)) == NULL)
 		goto done;
 
-	skb = tcp_make_synack(sk, dst, req, foc, attach_req);
+	skb = tcp_make_synack(sk, dst, req, foc, synack_type);
 
 	if (skb) {
 		__tcp_v6_send_check(skb, &ireq->ir_v6_loc_addr,
-- 
2.8.0.rc3.226.g39d4020
