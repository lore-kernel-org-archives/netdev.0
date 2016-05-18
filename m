From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/4] tipc: block BH in TCP callbacks
Date: Tue, 17 May 2016 17:44:09 -0700
Message-ID: <1463532249-20850-5-git-send-email-edumazet@google.com>
References: <1463532249-20850-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Venkatesh Srinivas <venkateshs@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36725 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174AbcERAo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 20:44:28 -0400
Received: by mail-pa0-f44.google.com with SMTP id bt5so11625085pac.3
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 17:44:28 -0700 (PDT)
In-Reply-To: <1463532249-20850-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP stack can now run from process context.

Use read_lock_bh(&sk->sk_callback_lock) variant to restore previous
assumption.

Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
Fixes: d41a69f1d390 ("tcp: make tcp_sendmsg() aware of socket backlog")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jon Maloy <jon.maloy@ericsson.com>
Cc: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/server.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/tipc/server.c b/net/tipc/server.c
index 7a0af2dc0406..272d20a795d5 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -138,28 +138,28 @@ static void sock_data_ready(struct sock *sk)
 {
 	struct tipc_conn *con;
 
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	con = sock2con(sk);
 	if (con && test_bit(CF_CONNECTED, &con->flags)) {
 		conn_get(con);
 		if (!queue_work(con->server->rcv_wq, &con->rwork))
 			conn_put(con);
 	}
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 }
 
 static void sock_write_space(struct sock *sk)
 {
 	struct tipc_conn *con;
 
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	con = sock2con(sk);
 	if (con && test_bit(CF_CONNECTED, &con->flags)) {
 		conn_get(con);
 		if (!queue_work(con->server->send_wq, &con->swork))
 			conn_put(con);
 	}
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 }
 
 static void tipc_register_callbacks(struct socket *sock, struct tipc_conn *con)
-- 
2.8.0.rc3.226.g39d4020
