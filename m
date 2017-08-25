From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] l2tp: initialise session's refcount before making it
 reachable
Date: Fri, 25 Aug 2017 16:22:17 +0200
Message-ID: <f37a31f7fbfa4c02c4a263672f86eac4e80be272.1503670839.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:50613 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932562AbdHYOWV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 10:22:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sessions must be fully initialised before calling
l2tp_session_add_to_tunnel(). Otherwise, there's a short time frame
where partially initialised sessions can be accessed by external users.

Fixes: dbdbc73b4478 ("l2tp: fix duplicate session creation")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_core.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index b0c2d4ae781d..f363669eae47 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1844,6 +1844,8 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 
 		l2tp_session_set_header_len(session, tunnel->version);
 
+		refcount_set(&session->ref_count, 1);
+
 		err = l2tp_session_add_to_tunnel(tunnel, session);
 		if (err) {
 			kfree(session);
@@ -1851,10 +1853,6 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 			return ERR_PTR(err);
 		}
 
-		/* Bump the reference count. The session context is deleted
-		 * only when this drops to zero.
-		 */
-		refcount_set(&session->ref_count, 1);
 		l2tp_tunnel_inc_refcount(tunnel);
 
 		/* Ensure tunnel socket isn't deleted */
-- 
2.14.1
