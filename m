From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 2/5] l2tp: ensure session can't get removed during
 pppol2tp_session_ioctl()
Date: Fri, 31 Mar 2017 13:02:26 +0200
Message-ID: <f016428e28ae63a86e7426dc5c48fc9fe6e1e1f7.1490955471.git.g.nault@alphalink.fr>
References: <cover.1490955471.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51761 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932879AbdCaLCb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 07:02:31 -0400
Content-Disposition: inline
In-Reply-To: <cover.1490955471.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Holding a reference on session is required before calling
pppol2tp_session_ioctl(). The session could get freed while processing the
ioctl otherwise. Since pppol2tp_session_ioctl() uses the session's socket,
we also need to take a reference on it in l2tp_session_get().

Fixes: fd558d186df2 ("l2tp: Split pppol2tp patch into separate l2tp and ppp parts")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 123b6a2411a0..827e55c41ba2 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1141,11 +1141,18 @@ static int pppol2tp_tunnel_ioctl(struct l2tp_tunnel *tunnel,
 		if (stats.session_id != 0) {
 			/* resend to session ioctl handler */
 			struct l2tp_session *session =
-				l2tp_session_find(sock_net(sk), tunnel, stats.session_id);
-			if (session != NULL)
-				err = pppol2tp_session_ioctl(session, cmd, arg);
-			else
+				l2tp_session_get(sock_net(sk), tunnel,
+						 stats.session_id, true);
+
+			if (session) {
+				err = pppol2tp_session_ioctl(session, cmd,
+							     arg);
+				if (session->deref)
+					session->deref(session);
+				l2tp_session_dec_refcount(session);
+			} else {
 				err = -EBADR;
+			}
 			break;
 		}
 #ifdef CONFIG_XFRM
-- 
2.11.0
