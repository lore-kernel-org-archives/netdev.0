From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 12/12] l2tp: unhash l2tp sessions on delete, not on free
Date: Tue, 19 Mar 2013 16:11:23 +0000
Message-ID: <1363709483-24021-13-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36146 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932922Ab3CSQLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:34 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we postpone unhashing of l2tp sessions until the structure is freed, we
risk:

 1. further packets arriving and getting queued while the pseudowire is being
    closed down
 2. the recv path hitting "scheduling while atomic" errors in the case that
    recv drops the last reference to a session and calls l2tp_session_free
    while in atomic context

As such, l2tp sessions should be unhashed from l2tp_core data structures early
in the teardown process prior to calling pseudowire close.  For pseudowires
like l2tp_ppp which have multiple shutdown codepaths, provide an unhash hook.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   75 +++++++++++++++++++++++---------------------------
 net/l2tp/l2tp_core.h |    1 +
 net/l2tp/l2tp_ppp.c  |   12 ++------
 3 files changed, 38 insertions(+), 50 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 97d30ac..8aecf5d 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1316,26 +1316,12 @@ again:
 
 			hlist_del_init(&session->hlist);
 
-			/* Since we should hold the sock lock while
-			 * doing any unbinding, we need to release the
-			 * lock we're holding before taking that lock.
-			 * Hold a reference to the sock so it doesn't
-			 * disappear as we're jumping between locks.
-			 */
 			if (session->ref != NULL)
 				(*session->ref)(session);
 
 			write_unlock_bh(&tunnel->hlist_lock);
 
-			if (tunnel->version != L2TP_HDR_VER_2) {
-				struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
-
-				spin_lock_bh(&pn->l2tp_session_hlist_lock);
-				hlist_del_init_rcu(&session->global_hlist);
-				spin_unlock_bh(&pn->l2tp_session_hlist_lock);
-				synchronize_rcu();
-			}
-
+			__l2tp_session_unhash(session);
 			l2tp_session_queue_purge(session);
 
 			if (session->session_close != NULL)
@@ -1732,64 +1718,71 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
  */
 void l2tp_session_free(struct l2tp_session *session)
 {
-	struct l2tp_tunnel *tunnel;
+	struct l2tp_tunnel *tunnel = session->tunnel;
 
 	BUG_ON(atomic_read(&session->ref_count) != 0);
 
-	tunnel = session->tunnel;
-	if (tunnel != NULL) {
+	if (tunnel) {
 		BUG_ON(tunnel->magic != L2TP_TUNNEL_MAGIC);
+		if (session->session_id != 0)
+			atomic_dec(&l2tp_session_count);
+		sock_put(tunnel->sock);
+		session->tunnel = NULL;
+		l2tp_tunnel_dec_refcount(tunnel);
+	}
+
+	kfree(session);
+
+	return;
+}
+EXPORT_SYMBOL_GPL(l2tp_session_free);
+
+/* Remove an l2tp session from l2tp_core's hash lists.
+ * Provides a tidyup interface for pseudowire code which can't just route all
+ * shutdown via. l2tp_session_delete and a pseudowire-specific session_close
+ * callback.
+ */
+void __l2tp_session_unhash(struct l2tp_session *session)
+{
+	struct l2tp_tunnel *tunnel = session->tunnel;
 
-		/* Delete the session from the hash */
+	/* Remove the session from core hashes */
+	if (tunnel) {
+		/* Remove from the per-tunnel hash */
 		write_lock_bh(&tunnel->hlist_lock);
 		hlist_del_init(&session->hlist);
 		write_unlock_bh(&tunnel->hlist_lock);
 
-		/* Unlink from the global hash if not L2TPv2 */
+		/* For L2TPv3 we have a per-net hash: remove from there, too */
 		if (tunnel->version != L2TP_HDR_VER_2) {
 			struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
-
 			spin_lock_bh(&pn->l2tp_session_hlist_lock);
 			hlist_del_init_rcu(&session->global_hlist);
 			spin_unlock_bh(&pn->l2tp_session_hlist_lock);
 			synchronize_rcu();
 		}
-
-		if (session->session_id != 0)
-			atomic_dec(&l2tp_session_count);
-
-		sock_put(tunnel->sock);
-
-		/* This will delete the tunnel context if this
-		 * is the last session on the tunnel.
-		 */
-		session->tunnel = NULL;
-		l2tp_tunnel_dec_refcount(tunnel);
 	}
-
-	kfree(session);
-
-	return;
 }
-EXPORT_SYMBOL_GPL(l2tp_session_free);
+EXPORT_SYMBOL_GPL(__l2tp_session_unhash);
 
 /* This function is used by the netlink SESSION_DELETE command and by
    pseudowire modules.
  */
 int l2tp_session_delete(struct l2tp_session *session)
 {
+	if (session->ref)
+		(*session->ref)(session);
+	__l2tp_session_unhash(session);
 	l2tp_session_queue_purge(session);
-
 	if (session->session_close != NULL)
 		(*session->session_close)(session);
-
+	if (session->deref)
+		(*session->ref)(session);
 	l2tp_session_dec_refcount(session);
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(l2tp_session_delete);
 
-
 /* We come here whenever a session's send_seq, cookie_len or
  * l2specific_len parameters are set.
  */
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 519b013..485a490 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -242,6 +242,7 @@ extern int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_i
 extern void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel);
 extern int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel);
 extern struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunnel, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg);
+extern void __l2tp_session_unhash(struct l2tp_session *session);
 extern int l2tp_session_delete(struct l2tp_session *session);
 extern void l2tp_session_free(struct l2tp_session *session);
 extern void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb, unsigned char *ptr, unsigned char *optr, u16 hdrflags, int length, int (*payload_hook)(struct sk_buff *skb));
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 9d0eb8c..637a341 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -466,19 +466,12 @@ static void pppol2tp_session_close(struct l2tp_session *session)
  */
 static void pppol2tp_session_destruct(struct sock *sk)
 {
-	struct l2tp_session *session;
-
-	if (sk->sk_user_data != NULL) {
-		session = sk->sk_user_data;
-		if (session == NULL)
-			goto out;
-
+	struct l2tp_session *session = sk->sk_user_data;
+	if (session) {
 		sk->sk_user_data = NULL;
 		BUG_ON(session->magic != L2TP_SESSION_MAGIC);
 		l2tp_session_dec_refcount(session);
 	}
-
-out:
 	return;
 }
 
@@ -509,6 +502,7 @@ static int pppol2tp_release(struct socket *sock)
 
 	/* Purge any queued data */
 	if (session != NULL) {
+		__l2tp_session_unhash(session);
 		l2tp_session_queue_purge(session);
 		sock_put(sk);
 	}
-- 
1.7.9.5
