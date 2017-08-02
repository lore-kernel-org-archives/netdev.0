From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: remove extra POLL_OUT added for finished active connect()
Date: Wed,  2 Aug 2017 15:59:58 -0400
Message-ID: <20170802195958.21383-1-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:38789 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751879AbdHBUAI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 16:00:08 -0400
Received: by mail-qk0-f182.google.com with SMTP id x191so33143670qka.5
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 13:00:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 45f119bf936b ("tcp: remove header prediction") introduced a
minor bug: the sk_state_change() and sk_wake_async() notifications for
a completed active connection happen twice: once in this new spot
inside tcp_finish_connect() and once in the existing code in
tcp_rcv_synsent_state_process() immediately after it calls
tcp_finish_connect(). This commit remoes the duplicate POLL_OUT
notifications.

Fixes: 45f119bf936b ("tcp: remove header prediction")
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Cc: Florian Westphal <fw@strlen.de>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index df670d7ed98d..99cdf4ccabb8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5342,11 +5342,6 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 
 	if (sock_flag(sk, SOCK_KEEPOPEN))
 		inet_csk_reset_keepalive_timer(sk, keepalive_time_when(tp));
-
-	if (!sock_flag(sk, SOCK_DEAD)) {
-		sk->sk_state_change(sk);
-		sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
-	}
 }
 
 static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
-- 
2.14.0.rc1.383.gd1ce394fe2-goog
