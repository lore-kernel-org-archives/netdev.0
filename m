From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] l2tp: hold tunnel in pppol2tp_connect()
Date: Mon, 30 Oct 2017 17:58:58 +0100
Message-ID: <684fcf4b6a907b378274b92f033f7b78b2021809.1509381647.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:40988 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932356AbdJ3Q7C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 12:59:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use l2tp_tunnel_get() in pppol2tp_connect() to ensure the tunnel isn't
going to disappear while processing the rest of the function.

Fixes: fd558d186df2 ("l2tp: Split pppol2tp patch into separate l2tp and ppp parts")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---

Note: in case of backporting to -stable, this patch only makes sense if
f3c66d4e144a ("l2tp: prevent creation of sessions on terminated tunnels")
is already present in the tree, as we need this issue to be fixed
before fixing the current one.

The reason is that when connecting a session, we don't only depend on
the tunnel, but also on its socket. Therefore, holding a reference on
the tunnel is not enough, we also have to make sure that it's not going
to drop its socket before the session is registered.

 net/l2tp/l2tp_ppp.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index f50452b919d5..0c2738349442 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -584,6 +584,7 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	u32 tunnel_id, peer_tunnel_id;
 	u32 session_id, peer_session_id;
 	bool drop_refcnt = false;
+	bool drop_tunnel = false;
 	int ver = 2;
 	int fd;
 
@@ -652,7 +653,9 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	if (tunnel_id == 0)
 		goto end;
 
-	tunnel = l2tp_tunnel_find(sock_net(sk), tunnel_id);
+	tunnel = l2tp_tunnel_get(sock_net(sk), tunnel_id);
+	if (tunnel)
+		drop_tunnel = true;
 
 	/* Special case: create tunnel context if session_id and
 	 * peer_session_id is 0. Otherwise look up tunnel using supplied
@@ -781,6 +784,8 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 end:
 	if (drop_refcnt)
 		l2tp_session_dec_refcount(session);
+	if (drop_tunnel)
+		l2tp_tunnel_dec_refcount(tunnel);
 	release_sock(sk);
 
 	return error;
-- 
2.15.0.rc2
