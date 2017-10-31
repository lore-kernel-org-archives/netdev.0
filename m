From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 1/4] l2tp: remove ->ref() and ->deref()
Date: Tue, 31 Oct 2017 17:36:42 +0100
Message-ID: <f3e6c0bd3da465f1651a51646319b33ef6326e77.1509466904.git.g.nault@alphalink.fr>
References: <cover.1509466904.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38659 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752216AbdJaQgv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:36:51 -0400
Content-Disposition: inline
In-Reply-To: <cover.1509466904.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ->ref() and ->deref() callbacks are unused since PPP stopped using
them in ee40fb2e1eb5 ("l2tp: protect sock pointer of struct pppol2tp_session with RCU").

We can thus remove them from struct l2tp_session and drop the do_ref
parameter of l2tp_session_get*().

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_core.c    | 52 ++++++++-----------------------------------------
 net/l2tp/l2tp_core.h    | 10 +++-------
 net/l2tp/l2tp_debugfs.c |  4 +---
 net/l2tp/l2tp_ip.c      |  4 +---
 net/l2tp/l2tp_ip6.c     |  4 +---
 net/l2tp/l2tp_netlink.c | 20 ++++++++-----------
 net/l2tp/l2tp_ppp.c     | 10 +++-------
 7 files changed, 25 insertions(+), 79 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index a1d56e143fcd..216f49aec16f 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -216,12 +216,10 @@ struct l2tp_tunnel *l2tp_tunnel_get(const struct net *net, u32 tunnel_id)
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_get);
 
-/* Lookup a session. A new reference is held on the returned session.
- * Optionally calls session->ref() too if do_ref is true.
- */
+/* Lookup a session. A new reference is held on the returned session. */
 struct l2tp_session *l2tp_session_get(const struct net *net,
 				      struct l2tp_tunnel *tunnel,
-				      u32 session_id, bool do_ref)
+				      u32 session_id)
 {
 	struct hlist_head *session_list;
 	struct l2tp_session *session;
@@ -235,8 +233,6 @@ struct l2tp_session *l2tp_session_get(const struct net *net,
 		hlist_for_each_entry_rcu(session, session_list, global_hlist) {
 			if (session->session_id == session_id) {
 				l2tp_session_inc_refcount(session);
-				if (do_ref && session->ref)
-					session->ref(session);
 				rcu_read_unlock_bh();
 
 				return session;
@@ -252,8 +248,6 @@ struct l2tp_session *l2tp_session_get(const struct net *net,
 	hlist_for_each_entry(session, session_list, hlist) {
 		if (session->session_id == session_id) {
 			l2tp_session_inc_refcount(session);
-			if (do_ref && session->ref)
-				session->ref(session);
 			read_unlock_bh(&tunnel->hlist_lock);
 
 			return session;
@@ -265,8 +259,7 @@ struct l2tp_session *l2tp_session_get(const struct net *net,
 }
 EXPORT_SYMBOL_GPL(l2tp_session_get);
 
-struct l2tp_session *l2tp_session_get_nth(struct l2tp_tunnel *tunnel, int nth,
-					  bool do_ref)
+struct l2tp_session *l2tp_session_get_nth(struct l2tp_tunnel *tunnel, int nth)
 {
 	int hash;
 	struct l2tp_session *session;
@@ -277,8 +270,6 @@ struct l2tp_session *l2tp_session_get_nth(struct l2tp_tunnel *tunnel, int nth,
 		hlist_for_each_entry(session, &tunnel->session_hlist[hash], hlist) {
 			if (++count > nth) {
 				l2tp_session_inc_refcount(session);
-				if (do_ref && session->ref)
-					session->ref(session);
 				read_unlock_bh(&tunnel->hlist_lock);
 				return session;
 			}
@@ -295,8 +286,7 @@ EXPORT_SYMBOL_GPL(l2tp_session_get_nth);
  * This is very inefficient but is only used by management interfaces.
  */
 struct l2tp_session *l2tp_session_get_by_ifname(const struct net *net,
-						const char *ifname,
-						bool do_ref)
+						const char *ifname)
 {
 	struct l2tp_net *pn = l2tp_pernet(net);
 	int hash;
@@ -307,8 +297,6 @@ struct l2tp_session *l2tp_session_get_by_ifname(const struct net *net,
 		hlist_for_each_entry_rcu(session, &pn->l2tp_session_hlist[hash], global_hlist) {
 			if (!strcmp(session->ifname, ifname)) {
 				l2tp_session_inc_refcount(session);
-				if (do_ref && session->ref)
-					session->ref(session);
 				rcu_read_unlock_bh();
 
 				return session;
@@ -489,9 +477,6 @@ static void l2tp_recv_dequeue_skb(struct l2tp_session *session, struct sk_buff *
 		(*session->recv_skb)(session, skb, L2TP_SKB_CB(skb)->length);
 	else
 		kfree_skb(skb);
-
-	if (session->deref)
-		(*session->deref)(session);
 }
 
 /* Dequeue skbs from the session's reorder_q, subject to packet order.
@@ -520,8 +505,6 @@ static void l2tp_recv_dequeue(struct l2tp_session *session)
 			session->reorder_skip = 1;
 			__skb_unlink(skb, &session->reorder_q);
 			kfree_skb(skb);
-			if (session->deref)
-				(*session->deref)(session);
 			continue;
 		}
 
@@ -694,9 +677,6 @@ static int l2tp_recv_data_seq(struct l2tp_session *session, struct sk_buff *skb)
  * a data (not control) frame before coming here. Fields up to the
  * session-id have already been parsed and ptr points to the data
  * after the session-id.
- *
- * session->ref() must have been called prior to l2tp_recv_common().
- * session->deref() will be called automatically after skb is processed.
  */
 void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 		      unsigned char *ptr, unsigned char *optr, u16 hdrflags,
@@ -863,9 +843,6 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 discard:
 	atomic_long_inc(&session->stats.rx_errors);
 	kfree_skb(skb);
-
-	if (session->deref)
-		(*session->deref)(session);
 }
 EXPORT_SYMBOL(l2tp_recv_common);
 
@@ -879,8 +856,6 @@ int l2tp_session_queue_purge(struct l2tp_session *session)
 	while ((skb = skb_dequeue(&session->reorder_q))) {
 		atomic_long_inc(&session->stats.rx_errors);
 		kfree_skb(skb);
-		if (session->deref)
-			(*session->deref)(session);
 	}
 	return 0;
 }
@@ -972,13 +947,10 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 	}
 
 	/* Find the session context */
-	session = l2tp_session_get(tunnel->l2tp_net, tunnel, session_id, true);
+	session = l2tp_session_get(tunnel->l2tp_net, tunnel, session_id);
 	if (!session || !session->recv_skb) {
-		if (session) {
-			if (session->deref)
-				session->deref(session);
+		if (session)
 			l2tp_session_dec_refcount(session);
-		}
 
 		/* Not found? Pass to userspace to deal with */
 		l2tp_info(tunnel, L2TP_MSG_DATA,
@@ -1322,9 +1294,6 @@ void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel)
 			if (test_and_set_bit(0, &session->dead))
 				goto again;
 
-			if (session->ref != NULL)
-				(*session->ref)(session);
-
 			write_unlock_bh(&tunnel->hlist_lock);
 
 			__l2tp_session_unhash(session);
@@ -1333,9 +1302,6 @@ void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel)
 			if (session->session_close != NULL)
 				(*session->session_close)(session);
 
-			if (session->deref != NULL)
-				(*session->deref)(session);
-
 			l2tp_session_dec_refcount(session);
 
 			write_lock_bh(&tunnel->hlist_lock);
@@ -1759,15 +1725,13 @@ int l2tp_session_delete(struct l2tp_session *session)
 	if (test_and_set_bit(0, &session->dead))
 		return 0;
 
-	if (session->ref)
-		(*session->ref)(session);
 	__l2tp_session_unhash(session);
 	l2tp_session_queue_purge(session);
 	if (session->session_close != NULL)
 		(*session->session_close)(session);
-	if (session->deref)
-		(*session->deref)(session);
+
 	l2tp_session_dec_refcount(session);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(l2tp_session_delete);
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 77caa5966736..92c90e72259c 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -129,8 +129,6 @@ struct l2tp_session {
 	int (*build_header)(struct l2tp_session *session, void *buf);
 	void (*recv_skb)(struct l2tp_session *session, struct sk_buff *skb, int data_len);
 	void (*session_close)(struct l2tp_session *session);
-	void (*ref)(struct l2tp_session *session);
-	void (*deref)(struct l2tp_session *session);
 #if IS_ENABLED(CONFIG_L2TP_DEBUGFS)
 	void (*show)(struct seq_file *m, void *priv);
 #endif
@@ -245,12 +243,10 @@ struct l2tp_tunnel *l2tp_tunnel_get(const struct net *net, u32 tunnel_id);
 
 struct l2tp_session *l2tp_session_get(const struct net *net,
 				      struct l2tp_tunnel *tunnel,
-				      u32 session_id, bool do_ref);
-struct l2tp_session *l2tp_session_get_nth(struct l2tp_tunnel *tunnel, int nth,
-					  bool do_ref);
+				      u32 session_id);
+struct l2tp_session *l2tp_session_get_nth(struct l2tp_tunnel *tunnel, int nth);
 struct l2tp_session *l2tp_session_get_by_ifname(const struct net *net,
-						const char *ifname,
-						bool do_ref);
+						const char *ifname);
 struct l2tp_tunnel *l2tp_tunnel_find(const struct net *net, u32 tunnel_id);
 struct l2tp_tunnel *l2tp_tunnel_find_nth(const struct net *net, int nth);
 
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index 53bae54c4d6e..eb69411bcb47 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -53,7 +53,7 @@ static void l2tp_dfs_next_tunnel(struct l2tp_dfs_seq_data *pd)
 
 static void l2tp_dfs_next_session(struct l2tp_dfs_seq_data *pd)
 {
-	pd->session = l2tp_session_get_nth(pd->tunnel, pd->session_idx, true);
+	pd->session = l2tp_session_get_nth(pd->tunnel, pd->session_idx);
 	pd->session_idx++;
 
 	if (pd->session == NULL) {
@@ -241,8 +241,6 @@ static int l2tp_dfs_seq_show(struct seq_file *m, void *v)
 		l2tp_dfs_seq_tunnel_show(m, pd->tunnel);
 	} else {
 		l2tp_dfs_seq_session_show(m, pd->session);
-		if (pd->session->deref)
-			pd->session->deref(pd->session);
 		l2tp_session_dec_refcount(pd->session);
 	}
 
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 4d322c1b7233..6dbe450400a2 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -143,7 +143,7 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 	}
 
 	/* Ok, this is a data packet. Lookup the session. */
-	session = l2tp_session_get(net, NULL, session_id, true);
+	session = l2tp_session_get(net, NULL, session_id);
 	if (!session)
 		goto discard;
 
@@ -205,8 +205,6 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 	return sk_receive_skb(sk, skb, 1);
 
 discard_sess:
-	if (session->deref)
-		session->deref(session);
 	l2tp_session_dec_refcount(session);
 	goto discard;
 
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 88b397c30d86..59ebb6e4f735 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -156,7 +156,7 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 	}
 
 	/* Ok, this is a data packet. Lookup the session. */
-	session = l2tp_session_get(net, NULL, session_id, true);
+	session = l2tp_session_get(net, NULL, session_id);
 	if (!session)
 		goto discard;
 
@@ -219,8 +219,6 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 	return sk_receive_skb(sk, skb, 1);
 
 discard_sess:
-	if (session->deref)
-		session->deref(session);
 	l2tp_session_dec_refcount(session);
 	goto discard;
 
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index f04fb347d251..a1f24fb2be98 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -48,8 +48,7 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 portid, u32 seq,
 /* Accessed under genl lock */
 static const struct l2tp_nl_cmd_ops *l2tp_nl_cmd_ops[__L2TP_PWTYPE_MAX];
 
-static struct l2tp_session *l2tp_nl_session_get(struct genl_info *info,
-						bool do_ref)
+static struct l2tp_session *l2tp_nl_session_get(struct genl_info *info)
 {
 	u32 tunnel_id;
 	u32 session_id;
@@ -60,15 +59,14 @@ static struct l2tp_session *l2tp_nl_session_get(struct genl_info *info,
 
 	if (info->attrs[L2TP_ATTR_IFNAME]) {
 		ifname = nla_data(info->attrs[L2TP_ATTR_IFNAME]);
-		session = l2tp_session_get_by_ifname(net, ifname, do_ref);
+		session = l2tp_session_get_by_ifname(net, ifname);
 	} else if ((info->attrs[L2TP_ATTR_SESSION_ID]) &&
 		   (info->attrs[L2TP_ATTR_CONN_ID])) {
 		tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
 		session_id = nla_get_u32(info->attrs[L2TP_ATTR_SESSION_ID]);
 		tunnel = l2tp_tunnel_get(net, tunnel_id);
 		if (tunnel) {
-			session = l2tp_session_get(net, tunnel, session_id,
-						   do_ref);
+			session = l2tp_session_get(net, tunnel, session_id);
 			l2tp_tunnel_dec_refcount(tunnel);
 		}
 	}
@@ -649,7 +647,7 @@ static int l2tp_nl_cmd_session_create(struct sk_buff *skb, struct genl_info *inf
 							   &cfg);
 
 	if (ret >= 0) {
-		session = l2tp_session_get(net, tunnel, session_id, false);
+		session = l2tp_session_get(net, tunnel, session_id);
 		if (session) {
 			ret = l2tp_session_notify(&l2tp_nl_family, info, session,
 						  L2TP_CMD_SESSION_CREATE);
@@ -669,7 +667,7 @@ static int l2tp_nl_cmd_session_delete(struct sk_buff *skb, struct genl_info *inf
 	struct l2tp_session *session;
 	u16 pw_type;
 
-	session = l2tp_nl_session_get(info, true);
+	session = l2tp_nl_session_get(info);
 	if (session == NULL) {
 		ret = -ENODEV;
 		goto out;
@@ -683,8 +681,6 @@ static int l2tp_nl_cmd_session_delete(struct sk_buff *skb, struct genl_info *inf
 		if (l2tp_nl_cmd_ops[pw_type] && l2tp_nl_cmd_ops[pw_type]->session_delete)
 			ret = (*l2tp_nl_cmd_ops[pw_type]->session_delete)(session);
 
-	if (session->deref)
-		session->deref(session);
 	l2tp_session_dec_refcount(session);
 
 out:
@@ -696,7 +692,7 @@ static int l2tp_nl_cmd_session_modify(struct sk_buff *skb, struct genl_info *inf
 	int ret = 0;
 	struct l2tp_session *session;
 
-	session = l2tp_nl_session_get(info, false);
+	session = l2tp_nl_session_get(info);
 	if (session == NULL) {
 		ret = -ENODEV;
 		goto out;
@@ -828,7 +824,7 @@ static int l2tp_nl_cmd_session_get(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *msg;
 	int ret;
 
-	session = l2tp_nl_session_get(info, false);
+	session = l2tp_nl_session_get(info);
 	if (session == NULL) {
 		ret = -ENODEV;
 		goto err;
@@ -874,7 +870,7 @@ static int l2tp_nl_cmd_session_dump(struct sk_buff *skb, struct netlink_callback
 				goto out;
 		}
 
-		session = l2tp_session_get_nth(tunnel, si, false);
+		session = l2tp_session_get_nth(tunnel, si);
 		if (session == NULL) {
 			ti++;
 			tunnel = NULL;
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 845aba543dce..535db8319769 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -742,7 +742,7 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	if (tunnel->peer_tunnel_id == 0)
 		tunnel->peer_tunnel_id = peer_tunnel_id;
 
-	session = l2tp_session_get(sock_net(sk), tunnel, session_id, false);
+	session = l2tp_session_get(sock_net(sk), tunnel, session_id);
 	if (session) {
 		drop_refcnt = true;
 		ps = l2tp_session_priv(session);
@@ -1193,13 +1193,11 @@ static int pppol2tp_tunnel_ioctl(struct l2tp_tunnel *tunnel,
 			/* resend to session ioctl handler */
 			struct l2tp_session *session =
 				l2tp_session_get(sock_net(sk), tunnel,
-						 stats.session_id, true);
+						 stats.session_id);
 
 			if (session) {
 				err = pppol2tp_session_ioctl(session, cmd,
 							     arg);
-				if (session->deref)
-					session->deref(session);
 				l2tp_session_dec_refcount(session);
 			} else {
 				err = -EBADR;
@@ -1615,7 +1613,7 @@ static void pppol2tp_next_tunnel(struct net *net, struct pppol2tp_seq_data *pd)
 
 static void pppol2tp_next_session(struct net *net, struct pppol2tp_seq_data *pd)
 {
-	pd->session = l2tp_session_get_nth(pd->tunnel, pd->session_idx, true);
+	pd->session = l2tp_session_get_nth(pd->tunnel, pd->session_idx);
 	pd->session_idx++;
 
 	if (pd->session == NULL) {
@@ -1758,8 +1756,6 @@ static int pppol2tp_seq_show(struct seq_file *m, void *v)
 		pppol2tp_seq_tunnel_show(m, pd->tunnel);
 	} else {
 		pppol2tp_seq_session_show(m, pd->session);
-		if (pd->session->deref)
-			pd->session->deref(pd->session);
 		l2tp_session_dec_refcount(pd->session);
 	}
 
-- 
2.15.0
