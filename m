From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/6] inet: avoid fastopen lock for regular accept()
Date: Tue, 17 Mar 2015 18:32:30 -0700
Message-ID: <1426642351-26098-6-git-send-email-edumazet@google.com>
References: <1426642351-26098-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:33900 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932762AbbCRBem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 21:34:42 -0400
Received: by yhoa41 with SMTP id a41so311716yho.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 18:34:41 -0700 (PDT)
In-Reply-To: <1426642351-26098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not because a TCP listener is FastOpen ready that
all incoming sockets actually used FastOpen.

Avoid taking queue->fastopenq->lock if not needed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_connection_sock.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 741f0d96a7f7..f0f91858aecf 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -293,8 +293,8 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct request_sock_queue *queue = &icsk->icsk_accept_queue;
-	struct sock *newsk;
 	struct request_sock *req;
+	struct sock *newsk;
 	int error;
 
 	lock_sock(sk);
@@ -323,7 +323,9 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
 	newsk = req->sk;
 
 	sk_acceptq_removed(sk);
-	if (sk->sk_protocol == IPPROTO_TCP && queue->fastopenq != NULL) {
+	if (sk->sk_protocol == IPPROTO_TCP &&
+	    tcp_rsk(req)->tfo_listener &&
+	    queue->fastopenq) {
 		spin_lock_bh(&queue->fastopenq->lock);
 		if (tcp_rsk(req)->tfo_listener) {
 			/* We are still waiting for the final ACK from 3WHS
-- 
2.2.0.rc0.207.ga3a616c
