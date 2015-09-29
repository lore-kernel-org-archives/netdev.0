From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 02/14] tcp: remove unused len argument from tcp_rcv_state_process()
Date: Tue, 29 Sep 2015 07:42:40 -0700
Message-ID: <1443537772-15305-3-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32811 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755091AbbI2OnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:43:19 -0400
Received: by pacex6 with SMTP id ex6so8404942pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:43:19 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once we realize tcp_rcv_synsent_state_process() does not use
its 'len' argument and we get rid of it, then it becomes clear
this argument is no longer used in tcp_rcv_state_process()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h        | 2 +-
 net/ipv4/tcp_input.c     | 6 +++---
 net/ipv4/tcp_ipv4.c      | 2 +-
 net/ipv4/tcp_minisocks.c | 3 +--
 net/ipv6/tcp_ipv6.c      | 2 +-
 5 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cdbf63d3c5cf..1cfdedbe47e1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -366,7 +366,7 @@ void tcp_write_timer_handler(struct sock *sk);
 void tcp_delack_timer_handler(struct sock *sk);
 int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-			  const struct tcphdr *th, unsigned int len);
+			  const struct tcphdr *th);
 void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			 const struct tcphdr *th, unsigned int len);
 void tcp_rcv_space_adjust(struct sock *sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4964d53907e9..dcbddf12f4b3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5472,7 +5472,7 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 }
 
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
-					 const struct tcphdr *th, unsigned int len)
+					 const struct tcphdr *th)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -5699,7 +5699,7 @@ reset_and_undo:
  */
 
 int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-			  const struct tcphdr *th, unsigned int len)
+			  const struct tcphdr *th)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -5749,7 +5749,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		goto discard;
 
 	case TCP_SYN_SENT:
-		queued = tcp_rcv_synsent_state_process(sk, skb, th, len);
+		queued = tcp_rcv_synsent_state_process(sk, skb, th);
 		if (queued >= 0)
 			return queued;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4300d0132b9f..7e5ae1e01009 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1420,7 +1420,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 	} else
 		sock_rps_save_rxhash(sk, skb);
 
-	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len)) {
+	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb))) {
 		rsk = sk;
 		goto reset;
 	}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index e4fe62b6b106..9c7c61cf7462 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -821,8 +821,7 @@ int tcp_child_process(struct sock *parent, struct sock *child,
 	int state = child->sk_state;
 
 	if (!sock_owned_by_user(child)) {
-		ret = tcp_rcv_state_process(child, skb, tcp_hdr(skb),
-					    skb->len);
+		ret = tcp_rcv_state_process(child, skb, tcp_hdr(skb));
 		/* Wakeup parent, send SIGIO */
 		if (state == TCP_SYN_RECV && child->sk_state != state)
 			parent->sk_data_ready(parent);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c47e5c87a2a8..b6e473f0f62e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1272,7 +1272,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	} else
 		sock_rps_save_rxhash(sk, skb);
 
-	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len))
+	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb)))
 		goto reset;
 	if (opt_skb)
 		goto ipv6_pktoptions;
-- 
2.6.0.rc2.230.g3dd15c0
