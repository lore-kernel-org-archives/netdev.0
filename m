From: Alexander Couzens <lynxis@fe80.eu>
Subject: [PATCH] l2tp: protect tunnel->del_work by ref_count
Date: Mon, 28 Sep 2015 11:32:42 +0200
Message-ID: <1443432762-5561-1-git-send-email-lynxis@fe80.eu>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexander Couzens <lynxis@fe80.eu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.base45.de ([80.241.61.77]:53850 "EHLO mail.base45.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757023AbbI1KA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 06:00:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a small chance that tunnel_free() is called before tunnel->del_work scheduled
resulting in a zero pointer dereference.

Signed-off-by: Alexander Couzens <lynxis@fe80.eu>
---
 net/l2tp/l2tp_core.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index f6b090d..afca2eb 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1319,7 +1319,7 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 	tunnel = container_of(work, struct l2tp_tunnel, del_work);
 	sk = l2tp_tunnel_sock_lookup(tunnel);
 	if (!sk)
-		return;
+		goto out;
 
 	sock = sk->sk_socket;
 
@@ -1341,6 +1341,8 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 	}
 
 	l2tp_tunnel_sock_put(sk);
+out:
+	l2tp_tunnel_dec_refcount(tunnel);
 }
 
 /* Create a socket for the tunnel, if one isn't set up by
@@ -1636,8 +1638,13 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
  */
 int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 {
+	l2tp_tunnel_inc_refcount(tunnel);
 	l2tp_tunnel_closeall(tunnel);
-	return (false == queue_work(l2tp_wq, &tunnel->del_work));
+	if (false == queue_work(l2tp_wq, &tunnel->del_work)) {
+		l2tp_tunnel_dec_refcount(tunnel);
+		return 1;
+	}
+	return 0;
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
 
-- 
2.5.3
