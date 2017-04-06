From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 2/2] l2tp: don't mask errors in pppol2tp_getsockopt()
Date: Thu, 6 Apr 2017 18:31:21 +0200
Message-ID: <8f2ecb39a300e1e33bfb04eac7bc8f66c63891f7.1491495941.git.g.nault@alphalink.fr>
References: <cover.1491495941.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:60555 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753473AbdDFQb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 12:31:26 -0400
Content-Disposition: inline
In-Reply-To: <cover.1491495941.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pppol2tp_getsockopt() doesn't take into account the error code returned
by pppol2tp_tunnel_getsockopt() or pppol2tp_session_getsockopt(). If
error occurs there, pppol2tp_getsockopt() continues unconditionally and
reports erroneous values.

Fixes: fd558d186df2 ("l2tp: Split pppol2tp patch into separate l2tp and ppp parts")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ppp.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 973a9185b276..32ea0f3d868c 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1505,8 +1505,13 @@ static int pppol2tp_getsockopt(struct socket *sock, int level, int optname,
 
 		err = pppol2tp_tunnel_getsockopt(sk, tunnel, optname, &val);
 		sock_put(ps->tunnel_sock);
-	} else
+		if (err)
+			goto end_put_sess;
+	} else {
 		err = pppol2tp_session_getsockopt(sk, session, optname, &val);
+		if (err)
+			goto end_put_sess;
+	}
 
 	err = -EFAULT;
 	if (put_user(len, optlen))
-- 
2.11.0
