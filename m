From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] tcp: remove poll() flakes with FastOpen
Date: Tue, 18 Apr 2017 09:45:52 -0700
Message-ID: <20170418164552.29261-3-edumazet@google.com>
References: <20170418164552.29261-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34964 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757285AbdDRQqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 12:46:44 -0400
Received: by mail-pg0-f50.google.com with SMTP id 72so82274417pge.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:46:44 -0700 (PDT)
In-Reply-To: <20170418164552.29261-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using TCP FastOpen for an active session, we send one wakeup event
from tcp_finish_connect(), right before the data eventually contained in
the received SYNACK is queued to sk->sk_receive_queue.

This means that depending on machine load or luck, poll() users
might receive POLLOUT events instead of POLLIN|POLLOUT

To fix this, we need to move the call to sk->sk_state_change()
after the (optional) call to tcp_rcv_fastopen_synack()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 37e2aa925f62395cfb48145cd3a76b6afebb64b1..341f021f02a2931cd75b2e1e71af9729fc4c7895 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5580,10 +5580,6 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	else
 		tp->pred_flags = 0;
 
-	if (!sock_flag(sk, SOCK_DEAD)) {
-		sk->sk_state_change(sk);
-		sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
-	}
 }
 
 static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
@@ -5652,6 +5648,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_fastopen_cookie foc = { .len = -1 };
 	int saved_clamp = tp->rx_opt.mss_clamp;
+	bool fastopen_fail;
 
 	tcp_parse_options(skb, &tp->rx_opt, 0, &foc);
 	if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr)
@@ -5755,10 +5752,15 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 
 		tcp_finish_connect(sk, skb);
 
-		if ((tp->syn_fastopen || tp->syn_data) &&
-		    tcp_rcv_fastopen_synack(sk, skb, &foc))
-			return -1;
+		fastopen_fail = (tp->syn_fastopen || tp->syn_data) &&
+				tcp_rcv_fastopen_synack(sk, skb, &foc);
 
+		if (!sock_flag(sk, SOCK_DEAD)) {
+			sk->sk_state_change(sk);
+			sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
+		}
+		if (fastopen_fail)
+			return -1;
 		if (sk->sk_write_pending ||
 		    icsk->icsk_accept_queue.rskq_defer_accept ||
 		    icsk->icsk_ack.pingpong) {
-- 
2.12.2.762.g0e3151a226-goog
