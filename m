From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next] tcp: memset ca_priv data to 0 properly
Date: Tue, 25 Apr 2017 17:38:02 -0700
Message-ID: <20170426003802.40091-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Wei Wang <weiwan@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33450 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1433671AbdDZAiO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 20:38:14 -0400
Received: by mail-pg0-f44.google.com with SMTP id 63so35709804pgh.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 17:38:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Always zero out ca_priv data in tcp_assign_congestion_control() so that
ca_priv data is cleared out during socket creation.
Also always zero out ca_priv data in tcp_reinit_congestion_control() so
that when cc algorithm is changed, ca_priv data is cleared out as well.
We should still zero out ca_priv data even in TCP_CLOSE state because
user could call connect() on AF_UNSPEC to disconnect the socket and
leave it in TCP_CLOSE state and later call setsockopt() to switch cc
algorithm on this socket.

Fixes: 2b0a8c9ee ("tcp: add CDG congestion control")
Reported-by: Andrey Konovalov  <andreyknvl@google.com>
Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_cong.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 79c4817abc94..6e3c512054a6 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -168,12 +168,8 @@ void tcp_assign_congestion_control(struct sock *sk)
 	}
 out:
 	rcu_read_unlock();
+	memset(icsk->icsk_ca_priv, 0, sizeof(icsk->icsk_ca_priv));
 
-	/* Clear out private data before diag gets it and
-	 * the ca has not been initialized.
-	 */
-	if (ca->get_info)
-		memset(icsk->icsk_ca_priv, 0, sizeof(icsk->icsk_ca_priv));
 	if (ca->flags & TCP_CONG_NEEDS_ECN)
 		INET_ECN_xmit(sk);
 	else
@@ -200,11 +196,10 @@ static void tcp_reinit_congestion_control(struct sock *sk,
 	tcp_cleanup_congestion_control(sk);
 	icsk->icsk_ca_ops = ca;
 	icsk->icsk_ca_setsockopt = 1;
+	memset(icsk->icsk_ca_priv, 0, sizeof(icsk->icsk_ca_priv));
 
-	if (sk->sk_state != TCP_CLOSE) {
-		memset(icsk->icsk_ca_priv, 0, sizeof(icsk->icsk_ca_priv));
+	if (sk->sk_state != TCP_CLOSE)
 		tcp_init_congestion_control(sk);
-	}
 }
 
 /* Manage refcounts on socket close. */
-- 
2.13.0.rc0.306.g87b477812d-goog
