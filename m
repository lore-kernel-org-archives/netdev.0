From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 03/14] tcp: remove tcp_rcv_state_process() tcp_hdr argument
Date: Tue, 29 Sep 2015 07:42:41 -0700
Message-ID: <1443537772-15305-4-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34853 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756581AbbI2Onb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:43:31 -0400
Received: by pacfv12 with SMTP id fv12so8440089pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:43:30 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factorize code to get tcp header from skb. It makes no sense
to duplicate code in callers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h        | 3 +--
 net/ipv4/tcp_input.c     | 4 ++--
 net/ipv4/tcp_ipv4.c      | 2 +-
 net/ipv4/tcp_minisocks.c | 2 +-
 net/ipv6/tcp_ipv6.c      | 2 +-
 5 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1cfdedbe47e1..1fe0bd458cb4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -365,8 +365,7 @@ void tcp_wfree(struct sk_buff *skb);
 void tcp_write_timer_handler(struct sock *sk);
 void tcp_delack_timer_handler(struct sock *sk);
 int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
-int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-			  const struct tcphdr *th);
+int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb);
 void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			 const struct tcphdr *th, unsigned int len);
 void tcp_rcv_space_adjust(struct sock *sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index dcbddf12f4b3..67b27aee8d28 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5698,11 +5698,11 @@ reset_and_undo:
  *	address independent.
  */
 
-int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-			  const struct tcphdr *th)
+int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	const struct tcphdr *th = tcp_hdr(skb);
 	struct request_sock *req;
 	int queued = 0;
 	bool acceptable;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7e5ae1e01009..67c0dc8bddbf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1420,7 +1420,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 	} else
 		sock_rps_save_rxhash(sk, skb);
 
-	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb))) {
+	if (tcp_rcv_state_process(sk, skb)) {
 		rsk = sk;
 		goto reset;
 	}
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 9c7c61cf7462..139668cc2347 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -821,7 +821,7 @@ int tcp_child_process(struct sock *parent, struct sock *child,
 	int state = child->sk_state;
 
 	if (!sock_owned_by_user(child)) {
-		ret = tcp_rcv_state_process(child, skb, tcp_hdr(skb));
+		ret = tcp_rcv_state_process(child, skb);
 		/* Wakeup parent, send SIGIO */
 		if (state == TCP_SYN_RECV && child->sk_state != state)
 			parent->sk_data_ready(parent);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b6e473f0f62e..334d548a0cf6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1272,7 +1272,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	} else
 		sock_rps_save_rxhash(sk, skb);
 
-	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb)))
+	if (tcp_rcv_state_process(sk, skb))
 		goto reset;
 	if (opt_skb)
 		goto ipv6_pktoptions;
-- 
2.6.0.rc2.230.g3dd15c0
