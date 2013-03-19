From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 10/12] l2tp: push all ppp pseudowire shutdown through .release handler
Date: Tue, 19 Mar 2013 16:11:21 +0000
Message-ID: <1363709483-24021-11-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36147 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932883Ab3CSQLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:33 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If userspace deletes a ppp pseudowire using the netlink API, either by
directly deleting the session or by deleting the tunnel that contains the
session, we need to tear down the corresponding pppox channel.

Rather than trying to manage two pppox unbind codepaths, switch the netlink
and l2tp_core session_close handlers to close via. the l2tp_ppp socket
.release handler.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_ppp.c |   53 ++++++++++-----------------------------------------
 1 file changed, 10 insertions(+), 43 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 6a53371..7e3e16a 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -97,6 +97,7 @@
 #include <net/ip.h>
 #include <net/udp.h>
 #include <net/xfrm.h>
+#include <net/inet_common.h>
 
 #include <asm/byteorder.h>
 #include <linux/atomic.h>
@@ -447,34 +448,16 @@ static void pppol2tp_session_close(struct l2tp_session *session)
 {
 	struct pppol2tp_session *ps = l2tp_session_priv(session);
 	struct sock *sk = ps->sock;
-	struct sk_buff *skb;
+	struct socket *sock = sk->sk_socket;
 
 	BUG_ON(session->magic != L2TP_SESSION_MAGIC);
 
-	if (session->session_id == 0)
-		goto out;
-
-	if (sk != NULL) {
-		lock_sock(sk);
-
-		if (sk->sk_state & (PPPOX_CONNECTED | PPPOX_BOUND)) {
-			pppox_unbind_sock(sk);
-			sk->sk_state = PPPOX_DEAD;
-			sk->sk_state_change(sk);
-		}
-
-		/* Purge any queued data */
-		skb_queue_purge(&sk->sk_receive_queue);
-		skb_queue_purge(&sk->sk_write_queue);
-		while ((skb = skb_dequeue(&session->reorder_q))) {
-			kfree_skb(skb);
-			sock_put(sk);
-		}
 
-		release_sock(sk);
+	if (sock) {
+		inet_shutdown(sock, 2);
+		/* Don't let the session go away before our socket does */
+		l2tp_session_inc_refcount(session);
 	}
-
-out:
 	return;
 }
 
@@ -525,16 +508,12 @@ static int pppol2tp_release(struct socket *sock)
 	session = pppol2tp_sock_to_session(sk);
 
 	/* Purge any queued data */
-	skb_queue_purge(&sk->sk_receive_queue);
-	skb_queue_purge(&sk->sk_write_queue);
 	if (session != NULL) {
-		struct sk_buff *skb;
-		while ((skb = skb_dequeue(&session->reorder_q))) {
-			kfree_skb(skb);
-			sock_put(sk);
-		}
+		l2tp_session_queue_purge(session);
 		sock_put(sk);
 	}
+	skb_queue_purge(&sk->sk_receive_queue);
+	skb_queue_purge(&sk->sk_write_queue);
 
 	release_sock(sk);
 
@@ -880,18 +859,6 @@ out:
 	return error;
 }
 
-/* Called when deleting sessions via the netlink interface.
- */
-static int pppol2tp_session_delete(struct l2tp_session *session)
-{
-	struct pppol2tp_session *ps = l2tp_session_priv(session);
-
-	if (ps->sock == NULL)
-		l2tp_session_dec_refcount(session);
-
-	return 0;
-}
-
 #endif /* CONFIG_L2TP_V3 */
 
 /* getname() support.
@@ -1839,7 +1806,7 @@ static const struct pppox_proto pppol2tp_proto = {
 
 static const struct l2tp_nl_cmd_ops pppol2tp_nl_cmd_ops = {
 	.session_create	= pppol2tp_session_create,
-	.session_delete	= pppol2tp_session_delete,
+	.session_delete	= l2tp_session_delete,
 };
 
 #endif /* CONFIG_L2TP_V3 */
-- 
1.7.9.5
