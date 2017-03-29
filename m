From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] l2tp: purge socket queues in the .destruct() callback
Date: Wed, 29 Mar 2017 08:45:29 +0200
Message-ID: <bf0b71ec6a771f4af715573c340dd2a83b4f02b7.1490769866.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51709 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753309AbdC2Gpm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 02:45:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Rx path may grab the socket right before pppol2tp_release(), but
nothing guarantees that it will enqueue packets before
skb_queue_purge(). Therefore, the socket can be destroyed without its
queues fully purged.

Fix this by purging queues in pppol2tp_session_destruct() where we're
guaranteed nothing is still referencing the socket.

Fixes: 9e9cb6221aa7 ("l2tp: fix userspace reception on plain L2TP sockets")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 36cc56fd0418..123b6a2411a0 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -450,6 +450,10 @@ static void pppol2tp_session_close(struct l2tp_session *session)
 static void pppol2tp_session_destruct(struct sock *sk)
 {
 	struct l2tp_session *session = sk->sk_user_data;
+
+	skb_queue_purge(&sk->sk_receive_queue);
+	skb_queue_purge(&sk->sk_write_queue);
+
 	if (session) {
 		sk->sk_user_data = NULL;
 		BUG_ON(session->magic != L2TP_SESSION_MAGIC);
@@ -488,9 +492,6 @@ static int pppol2tp_release(struct socket *sock)
 		l2tp_session_queue_purge(session);
 		sock_put(sk);
 	}
-	skb_queue_purge(&sk->sk_receive_queue);
-	skb_queue_purge(&sk->sk_write_queue);
-
 	release_sock(sk);
 
 	/* This will delete the session context via
-- 
2.11.0
