From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 2/2] l2tp: remove l2tp_session_find()
Date: Tue, 11 Apr 2017 13:12:21 +0200
Message-ID: <696f3031d0bbb1d301b13e560ce9d3a094e5ef5e.1491908878.git.g.nault@alphalink.fr>
References: <cover.1491908878.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:58763 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753235AbdDKLMd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 07:12:33 -0400
Content-Disposition: inline
In-Reply-To: <cover.1491908878.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function isn't used anymore.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_core.c | 51 +--------------------------------------------------
 net/l2tp/l2tp_core.h |  3 ---
 2 files changed, 1 insertion(+), 53 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index e37d9554da7b..154974be1eed 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -217,27 +217,6 @@ static void l2tp_tunnel_sock_put(struct sock *sk)
 	sock_put(sk);
 }
 
-/* Lookup a session by id in the global session list
- */
-static struct l2tp_session *l2tp_session_find_2(struct net *net, u32 session_id)
-{
-	struct l2tp_net *pn = l2tp_pernet(net);
-	struct hlist_head *session_list =
-		l2tp_session_id_hash_2(pn, session_id);
-	struct l2tp_session *session;
-
-	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu(session, session_list, global_hlist) {
-		if (session->session_id == session_id) {
-			rcu_read_unlock_bh();
-			return session;
-		}
-	}
-	rcu_read_unlock_bh();
-
-	return NULL;
-}
-
 /* Session hash list.
  * The session_id SHOULD be random according to RFC2661, but several
  * L2TP implementations (Cisco and Microsoft) use incrementing
@@ -250,35 +229,7 @@ l2tp_session_id_hash(struct l2tp_tunnel *tunnel, u32 session_id)
 	return &tunnel->session_hlist[hash_32(session_id, L2TP_HASH_BITS)];
 }
 
-/* Lookup a session by id
- */
-struct l2tp_session *l2tp_session_find(struct net *net, struct l2tp_tunnel *tunnel, u32 session_id)
-{
-	struct hlist_head *session_list;
-	struct l2tp_session *session;
-
-	/* In L2TPv3, session_ids are unique over all tunnels and we
-	 * sometimes need to look them up before we know the
-	 * tunnel.
-	 */
-	if (tunnel == NULL)
-		return l2tp_session_find_2(net, session_id);
-
-	session_list = l2tp_session_id_hash(tunnel, session_id);
-	read_lock_bh(&tunnel->hlist_lock);
-	hlist_for_each_entry(session, session_list, hlist) {
-		if (session->session_id == session_id) {
-			read_unlock_bh(&tunnel->hlist_lock);
-			return session;
-		}
-	}
-	read_unlock_bh(&tunnel->hlist_lock);
-
-	return NULL;
-}
-EXPORT_SYMBOL_GPL(l2tp_session_find);
-
-/* Like l2tp_session_find() but takes a reference on the returned session.
+/* Lookup a session. A new reference is held on the returned session.
  * Optionally calls session->ref() too if do_ref is true.
  */
 struct l2tp_session *l2tp_session_get(struct net *net,
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 8ce7818c7a9d..a3248e18badb 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -233,9 +233,6 @@ static inline struct l2tp_tunnel *l2tp_sock_to_tunnel(struct sock *sk)
 struct l2tp_session *l2tp_session_get(struct net *net,
 				      struct l2tp_tunnel *tunnel,
 				      u32 session_id, bool do_ref);
-struct l2tp_session *l2tp_session_find(struct net *net,
-				       struct l2tp_tunnel *tunnel,
-				       u32 session_id);
 struct l2tp_session *l2tp_session_get_nth(struct l2tp_tunnel *tunnel, int nth,
 					  bool do_ref);
 struct l2tp_session *l2tp_session_get_by_ifname(struct net *net, char *ifname,
-- 
2.11.0
