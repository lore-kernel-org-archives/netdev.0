From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 1/2] l2tp: ensure sessions are freed after their PPPOL2TP
 socket
Date: Fri, 22 Sep 2017 15:39:23 +0200
Message-ID: <44b0d835c98aebc1896b4806bd9b74a9793856f2.1506086081.git.g.nault@alphalink.fr>
References: <cover.1506086081.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Tom Parkin <tparkin@katalix.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:52467 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752337AbdIVNjc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 09:39:32 -0400
Content-Disposition: inline
In-Reply-To: <cover.1506086081.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If l2tp_tunnel_delete() or l2tp_tunnel_closeall() deletes a session
right after pppol2tp_release() orphaned its socket, then the 'sock'
variable of the pppol2tp_session_close() callback is NULL. Yet the
session is still used by pppol2tp_release().

Therefore we need to take an extra reference in any case, to prevent
l2tp_tunnel_delete() or l2tp_tunnel_closeall() from freeing the session.

Since the pppol2tp_session_close() callback is only set if the session
is associated to a PPPOL2TP socket and that both l2tp_tunnel_delete()
and l2tp_tunnel_closeall() hold the PPPOL2TP socket before calling
pppol2tp_session_close(), we're sure that pppol2tp_session_close() and
pppol2tp_session_destruct() are paired and called in the right order.
So the reference taken by the former will be released by the later.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 50e3ee9a9d61..bc6e8bfc5be4 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -437,11 +437,11 @@ static void pppol2tp_session_close(struct l2tp_session *session)
 
 	BUG_ON(session->magic != L2TP_SESSION_MAGIC);
 
-	if (sock) {
+	if (sock)
 		inet_shutdown(sock, SEND_SHUTDOWN);
-		/* Don't let the session go away before our socket does */
-		l2tp_session_inc_refcount(session);
-	}
+
+	/* Don't let the session go away before our socket does */
+	l2tp_session_inc_refcount(session);
 }
 
 /* Really kill the session socket. (Called from sock_put() if
-- 
2.14.1
