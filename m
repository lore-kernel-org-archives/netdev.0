From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: avoid spurious SYN flood detection at
 listen() time
Date: Wed, 14 Oct 2015 06:16:49 -0700
Message-ID: <1444828609.4166.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32860 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645AbbJNNQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 09:16:51 -0400
Received: by pabrc13 with SMTP id rc13so54589406pab.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 06:16:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

At listen() time, there is a small window where listener is visible with
a zero backlog, triggering a spurious "Possible SYN flooding on port"
message.

Nothing prevents us from setting the correct backlog.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h |    2 +-
 net/ipv4/inet_connection_sock.c    |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 3208a65d1c280aaa893e0084108c21f62912e79b..fd645c49e71ef3e39d6452f054857b1b32176c9d 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -312,7 +312,7 @@ static inline unsigned int inet_csk_listen_poll(const struct sock *sk)
 			(POLLIN | POLLRDNORM) : 0;
 }
 
-int inet_csk_listen_start(struct sock *sk, const int nr_table_entries);
+int inet_csk_listen_start(struct sock *sk, int backlog);
 void inet_csk_listen_stop(struct sock *sk);
 
 void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 514b9e910bd4ea245995346fe8188edd6f24b46f..ba9ec9a0d0ce5fad74a811ab82d4408594474893 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -727,14 +727,14 @@ void inet_csk_prepare_forced_close(struct sock *sk)
 }
 EXPORT_SYMBOL(inet_csk_prepare_forced_close);
 
-int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
+int inet_csk_listen_start(struct sock *sk, int backlog)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 
 	reqsk_queue_alloc(&icsk->icsk_accept_queue);
 
-	sk->sk_max_ack_backlog = 0;
+	sk->sk_max_ack_backlog = backlog;
 	sk->sk_ack_backlog = 0;
 	inet_csk_delack_init(sk);
 
