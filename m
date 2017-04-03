From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] l2tp: take reference on sessions being dumped
Date: Mon, 3 Apr 2017 12:03:13 +0200
Message-ID: <806d0d7d9411be40c4910a1fa2e5ea438f3d0e1d.1491213045.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:54087 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752013AbdDCKDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 06:03:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take a reference on the sessions returned by l2tp_session_find_nth()
(and rename it l2tp_session_get_nth() to reflect this change), so that
caller is assured that the session isn't going to disappear while
processing it.

For procfs and debugfs handlers, the session is held in the .start()
callback and dropped in .show(). Given that pppol2tp_seq_session_show()
dereferences the associated PPPoL2TP socket and that
l2tp_dfs_seq_session_show() might call pppol2tp_show(), we also need to
call the session's .ref() callback to prevent the socket from going
away from under us.

Fixes: fd558d186df2 ("l2tp: Split pppol2tp patch into separate l2tp and ppp parts")
Fixes: 0ad6614048cf ("l2tp: Add debugfs files for dumping l2tp debug info")
Fixes: 309795f4bec2 ("l2tp: Add netlink control API for L2TP")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_core.c    |  8 ++++++--
 net/l2tp/l2tp_core.h    |  3 ++-
 net/l2tp/l2tp_debugfs.c | 10 +++++++---
 net/l2tp/l2tp_netlink.c |  7 +++++--
 net/l2tp/l2tp_ppp.c     | 10 +++++++---
 5 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index e927422d8c58..e37d9554da7b 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -327,7 +327,8 @@ struct l2tp_session *l2tp_session_get(struct net *net,
 }
 EXPORT_SYMBOL_GPL(l2tp_session_get);
 
-struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth)
+struct l2tp_session *l2tp_session_get_nth(struct l2tp_tunnel *tunnel, int nth,
+					  bool do_ref)
 {
 	int hash;
 	struct l2tp_session *session;
@@ -337,6 +338,9 @@ struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth)
 	for (hash = 0; hash < L2TP_HASH_SIZE; hash++) {
 		hlist_for_each_entry(session, &tunnel->session_hlist[hash], hlist) {
 			if (++count > nth) {
+				l2tp_session_inc_refcount(session);
+				if (do_ref && session->ref)
+					session->ref(session);
 				read_unlock_bh(&tunnel->hlist_lock);
 				return session;
 			}
@@ -347,7 +351,7 @@ struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth)
 
 	return NULL;
 }
-EXPORT_SYMBOL_GPL(l2tp_session_find_nth);
+EXPORT_SYMBOL_GPL(l2tp_session_get_nth);
 
 /* Lookup a session by interface name.
  * This is very inefficient but is only used by management interfaces.
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 3b9b704a84e4..8ce7818c7a9d 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -236,7 +236,8 @@ struct l2tp_session *l2tp_session_get(struct net *net,
 struct l2tp_session *l2tp_session_find(struct net *net,
 				       struct l2tp_tunnel *tunnel,
 				       u32 session_id);
-struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth);
+struct l2tp_session *l2tp_session_get_nth(struct l2tp_tunnel *tunnel, int nth,
+					  bool do_ref);
 struct l2tp_session *l2tp_session_get_by_ifname(struct net *net, char *ifname,
 						bool do_ref);
 struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunnel_id);
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index 2d6760a2ae34..d100aed3d06f 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -53,7 +53,7 @@ static void l2tp_dfs_next_tunnel(struct l2tp_dfs_seq_data *pd)
 
 static void l2tp_dfs_next_session(struct l2tp_dfs_seq_data *pd)
 {
-	pd->session = l2tp_session_find_nth(pd->tunnel, pd->session_idx);
+	pd->session = l2tp_session_get_nth(pd->tunnel, pd->session_idx, true);
 	pd->session_idx++;
 
 	if (pd->session == NULL) {
@@ -238,10 +238,14 @@ static int l2tp_dfs_seq_show(struct seq_file *m, void *v)
 	}
 
 	/* Show the tunnel or session context */
-	if (pd->session == NULL)
+	if (!pd->session) {
 		l2tp_dfs_seq_tunnel_show(m, pd->tunnel);
-	else
+	} else {
 		l2tp_dfs_seq_session_show(m, pd->session);
+		if (pd->session->deref)
+			pd->session->deref(pd->session);
+		l2tp_session_dec_refcount(pd->session);
+	}
 
 out:
 	return 0;
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 93e317377c66..7e3e669baac4 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -867,7 +867,7 @@ static int l2tp_nl_cmd_session_dump(struct sk_buff *skb, struct netlink_callback
 				goto out;
 		}
 
-		session = l2tp_session_find_nth(tunnel, si);
+		session = l2tp_session_get_nth(tunnel, si, false);
 		if (session == NULL) {
 			ti++;
 			tunnel = NULL;
@@ -877,8 +877,11 @@ static int l2tp_nl_cmd_session_dump(struct sk_buff *skb, struct netlink_callback
 
 		if (l2tp_nl_session_send(skb, NETLINK_CB(cb->skb).portid,
 					 cb->nlh->nlmsg_seq, NLM_F_MULTI,
-					 session, L2TP_CMD_SESSION_GET) < 0)
+					 session, L2TP_CMD_SESSION_GET) < 0) {
+			l2tp_session_dec_refcount(session);
 			break;
+		}
+		l2tp_session_dec_refcount(session);
 
 		si++;
 	}
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 26501902d1a7..7bf73091baa2 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1560,7 +1560,7 @@ static void pppol2tp_next_tunnel(struct net *net, struct pppol2tp_seq_data *pd)
 
 static void pppol2tp_next_session(struct net *net, struct pppol2tp_seq_data *pd)
 {
-	pd->session = l2tp_session_find_nth(pd->tunnel, pd->session_idx);
+	pd->session = l2tp_session_get_nth(pd->tunnel, pd->session_idx, true);
 	pd->session_idx++;
 
 	if (pd->session == NULL) {
@@ -1687,10 +1687,14 @@ static int pppol2tp_seq_show(struct seq_file *m, void *v)
 
 	/* Show the tunnel or session context.
 	 */
-	if (pd->session == NULL)
+	if (!pd->session) {
 		pppol2tp_seq_tunnel_show(m, pd->tunnel);
-	else
+	} else {
 		pppol2tp_seq_session_show(m, pd->session);
+		if (pd->session->deref)
+			pd->session->deref(pd->session);
+		l2tp_session_dec_refcount(pd->session);
+	}
 
 out:
 	return 0;
-- 
2.11.0
