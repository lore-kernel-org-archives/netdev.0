From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/3] tcp/dccp: add inet_csk_reqsk_queue_drop_and_put() helper
Date: Wed, 14 Oct 2015 10:58:38 -0700
Message-ID: <1444845519-20064-3-git-send-email-edumazet@google.com>
References: <1444845519-20064-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35823 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932686AbbJNR64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 13:58:56 -0400
Received: by padcn9 with SMTP id cn9so29513481pad.2
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:58:56 -0700 (PDT)
In-Reply-To: <1444845519-20064-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let's reduce the confusion about inet_csk_reqsk_queue_drop() :
In many cases we also need to release reference on request socket,
so add a helper to do this, reducing code size and complexity.

Fixes: 4bdc3d66147b ("tcp/dccp: fix behavior of stale SYN_RECV request sockets")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h |  1 +
 net/dccp/ipv4.c                    |  2 +-
 net/dccp/ipv6.c                    |  2 +-
 net/ipv4/inet_connection_sock.c    | 10 ++++++++--
 net/ipv4/tcp_ipv4.c                |  2 +-
 net/ipv6/tcp_ipv6.c                |  2 +-
 6 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 3208a65d1c28..89ecbc80b2ce 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -299,6 +299,7 @@ static inline int inet_csk_reqsk_queue_is_full(const struct sock *sk)
 }
 
 void inet_csk_reqsk_queue_drop(struct sock *sk, struct request_sock *req);
+void inet_csk_reqsk_queue_drop_and_put(struct sock *sk, struct request_sock *req);
 
 void inet_csk_destroy_sock(struct sock *sk);
 void inet_csk_prepare_forced_close(struct sock *sk);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 644af510d932..59bc180b02d8 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -828,7 +828,7 @@ lookup:
 		if (likely(sk->sk_state == DCCP_LISTEN)) {
 			nsk = dccp_check_req(sk, skb, req);
 		} else {
-			inet_csk_reqsk_queue_drop(sk, req);
+			inet_csk_reqsk_queue_drop_and_put(sk, req);
 			goto lookup;
 		}
 		if (!nsk) {
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 68831931b1fe..d9cc731f2619 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -686,7 +686,7 @@ lookup:
 		if (likely(sk->sk_state == DCCP_LISTEN)) {
 			nsk = dccp_check_req(sk, skb, req);
 		} else {
-			inet_csk_reqsk_queue_drop(sk, req);
+			inet_csk_reqsk_queue_drop_and_put(sk, req);
 			goto lookup;
 		}
 		if (!nsk) {
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 514b9e910bd4..a5a1b54915e5 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -546,6 +546,13 @@ void inet_csk_reqsk_queue_drop(struct sock *sk, struct request_sock *req)
 }
 EXPORT_SYMBOL(inet_csk_reqsk_queue_drop);
 
+void inet_csk_reqsk_queue_drop_and_put(struct sock *sk, struct request_sock *req)
+{
+	inet_csk_reqsk_queue_drop(sk, req);
+	reqsk_put(req);
+}
+EXPORT_SYMBOL(inet_csk_reqsk_queue_drop_and_put);
+
 static void reqsk_timer_handler(unsigned long data)
 {
 	struct request_sock *req = (struct request_sock *)data;
@@ -608,8 +615,7 @@ static void reqsk_timer_handler(unsigned long data)
 		return;
 	}
 drop:
-	inet_csk_reqsk_queue_drop(sk_listener, req);
-	reqsk_put(req);
+	inet_csk_reqsk_queue_drop_and_put(sk_listener, req);
 }
 
 static void reqsk_queue_hash_req(struct request_sock *req,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index aad2298de7ad..9c68cf3762c4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1591,7 +1591,7 @@ process:
 		if (likely(sk->sk_state == TCP_LISTEN)) {
 			nsk = tcp_check_req(sk, skb, req, false);
 		} else {
-			inet_csk_reqsk_queue_drop(sk, req);
+			inet_csk_reqsk_queue_drop_and_put(sk, req);
 			goto lookup;
 		}
 		if (!nsk) {
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7ce1c57199d1..acb06f86f372 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1386,7 +1386,7 @@ process:
 		if (likely(sk->sk_state == TCP_LISTEN)) {
 			nsk = tcp_check_req(sk, skb, req, false);
 		} else {
-			inet_csk_reqsk_queue_drop(sk, req);
+			inet_csk_reqsk_queue_drop_and_put(sk, req);
 			goto lookup;
 		}
 		if (!nsk) {
-- 
2.6.0.rc2.230.g3dd15c0
