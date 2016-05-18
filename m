From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/4] ocfs2/cluster: block BH in TCP callbacks
Date: Tue, 17 May 2016 17:44:07 -0700
Message-ID: <1463532249-20850-3-git-send-email-edumazet@google.com>
References: <1463532249-20850-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Venkatesh Srinivas <venkateshs@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33171 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbcERAoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 20:44:22 -0400
Received: by mail-pf0-f172.google.com with SMTP id 206so12230069pfu.0
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 17:44:22 -0700 (PDT)
In-Reply-To: <1463532249-20850-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP stack can now run from process context.

Use read_lock_bh() variant to restore previous assumption.

Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
Fixes: d41a69f1d390 ("tcp: make tcp_sendmsg() aware of socket backlog")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 fs/ocfs2/cluster/tcp.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index 2d0acd6678fe..4238eb28889f 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -600,10 +600,11 @@ static void o2net_set_nn_state(struct o2net_node *nn,
 static void o2net_data_ready(struct sock *sk)
 {
 	void (*ready)(struct sock *sk);
+	struct o2net_sock_container *sc;
 
-	read_lock(&sk->sk_callback_lock);
-	if (sk->sk_user_data) {
-		struct o2net_sock_container *sc = sk->sk_user_data;
+	read_lock_bh(&sk->sk_callback_lock);
+	sc = sk->sk_user_data;
+	if (sc) {
 		sclog(sc, "data_ready hit\n");
 		o2net_set_data_ready_time(sc);
 		o2net_sc_queue_work(sc, &sc->sc_rx_work);
@@ -611,7 +612,7 @@ static void o2net_data_ready(struct sock *sk)
 	} else {
 		ready = sk->sk_data_ready;
 	}
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 
 	ready(sk);
 }
@@ -622,7 +623,7 @@ static void o2net_state_change(struct sock *sk)
 	void (*state_change)(struct sock *sk);
 	struct o2net_sock_container *sc;
 
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	sc = sk->sk_user_data;
 	if (sc == NULL) {
 		state_change = sk->sk_state_change;
@@ -649,7 +650,7 @@ static void o2net_state_change(struct sock *sk)
 		break;
 	}
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 	state_change(sk);
 }
 
@@ -2012,7 +2013,7 @@ static void o2net_listen_data_ready(struct sock *sk)
 {
 	void (*ready)(struct sock *sk);
 
-	read_lock(&sk->sk_callback_lock);
+	read_lock_bh(&sk->sk_callback_lock);
 	ready = sk->sk_user_data;
 	if (ready == NULL) { /* check for teardown race */
 		ready = sk->sk_data_ready;
@@ -2039,7 +2040,7 @@ static void o2net_listen_data_ready(struct sock *sk)
 	}
 
 out:
-	read_unlock(&sk->sk_callback_lock);
+	read_unlock_bh(&sk->sk_callback_lock);
 	if (ready != NULL)
 		ready(sk);
 }
-- 
2.8.0.rc3.226.g39d4020
