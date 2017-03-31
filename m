From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 5/5] l2tp: take a reference on sessions used in genetlink
 handlers
Date: Fri, 31 Mar 2017 13:02:30 +0200
Message-ID: <32e49ef213e02f291b5accd3a9ac961e2d2f960b.1490955471.git.g.nault@alphalink.fr>
References: <cover.1490955471.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>, Bill Hong <bhong@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51790 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933126AbdCaLCf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 07:02:35 -0400
Content-Disposition: inline
In-Reply-To: <cover.1490955471.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Callers of l2tp_nl_session_find() need to hold a reference on the
returned session since there's no guarantee that it isn't going to
disappear from under them.

Relying on the fact that no l2tp netlink message may be processed
concurrently isn't enough: sessions can be deleted by other means
(e.g. by closing the PPPOL2TP socket of a ppp pseudowire).

l2tp_nl_cmd_session_delete() is a bit special: it runs a callback
function that may require a previous call to session->ref(). In
particular, for ppp pseudowires, the callback is l2tp_session_delete(),
which then calls pppol2tp_session_close() and dereferences the PPPOL2TP
socket. The socket might already be gone at the moment
l2tp_session_delete() calls session->ref(), so we need to take a
reference during the session lookup. So we need to pass the do_ref
variable down to l2tp_session_get() and l2tp_session_get_by_ifname().

Since all callers have to be updated, l2tp_session_find_by_ifname() and
l2tp_nl_session_find() are renamed to reflect their new behaviour.

Fixes: 33f72e6f0c67 ("l2tp : multicast notification to the registered listeners")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_core.c    |  9 +++++++--
 net/l2tp/l2tp_core.h    |  3 ++-
 net/l2tp/l2tp_netlink.c | 39 ++++++++++++++++++++++++++-------------
 3 files changed, 35 insertions(+), 16 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 46b450a1bc21..e927422d8c58 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -352,7 +352,8 @@ EXPORT_SYMBOL_GPL(l2tp_session_find_nth);
 /* Lookup a session by interface name.
  * This is very inefficient but is only used by management interfaces.
  */
-struct l2tp_session *l2tp_session_find_by_ifname(struct net *net, char *ifname)
+struct l2tp_session *l2tp_session_get_by_ifname(struct net *net, char *ifname,
+						bool do_ref)
 {
 	struct l2tp_net *pn = l2tp_pernet(net);
 	int hash;
@@ -362,7 +363,11 @@ struct l2tp_session *l2tp_session_find_by_ifname(struct net *net, char *ifname)
 	for (hash = 0; hash < L2TP_HASH_SIZE_2; hash++) {
 		hlist_for_each_entry_rcu(session, &pn->l2tp_session_hlist[hash], global_hlist) {
 			if (!strcmp(session->ifname, ifname)) {
+				l2tp_session_inc_refcount(session);
+				if (do_ref && session->ref)
+					session->ref(session);
 				rcu_read_unlock_bh();
+
 				return session;
 			}
 		}
@@ -372,7 +377,7 @@ struct l2tp_session *l2tp_session_find_by_ifname(struct net *net, char *ifname)
 
 	return NULL;
 }
-EXPORT_SYMBOL_GPL(l2tp_session_find_by_ifname);
+EXPORT_SYMBOL_GPL(l2tp_session_get_by_ifname);
 
 static int l2tp_session_add_to_tunnel(struct l2tp_tunnel *tunnel,
 				      struct l2tp_session *session)
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 4544e81a3d27..3b9b704a84e4 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -237,7 +237,8 @@ struct l2tp_session *l2tp_session_find(struct net *net,
 				       struct l2tp_tunnel *tunnel,
 				       u32 session_id);
 struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth);
-struct l2tp_session *l2tp_session_find_by_ifname(struct net *net, char *ifname);
+struct l2tp_session *l2tp_session_get_by_ifname(struct net *net, char *ifname,
+						bool do_ref);
 struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunnel_id);
 struct l2tp_tunnel *l2tp_tunnel_find_nth(struct net *net, int nth);
 
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index f1b68effb077..93e317377c66 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -48,7 +48,8 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 portid, u32 seq,
 /* Accessed under genl lock */
 static const struct l2tp_nl_cmd_ops *l2tp_nl_cmd_ops[__L2TP_PWTYPE_MAX];
 
-static struct l2tp_session *l2tp_nl_session_find(struct genl_info *info)
+static struct l2tp_session *l2tp_nl_session_get(struct genl_info *info,
+						bool do_ref)
 {
 	u32 tunnel_id;
 	u32 session_id;
@@ -59,14 +60,15 @@ static struct l2tp_session *l2tp_nl_session_find(struct genl_info *info)
 
 	if (info->attrs[L2TP_ATTR_IFNAME]) {
 		ifname = nla_data(info->attrs[L2TP_ATTR_IFNAME]);
-		session = l2tp_session_find_by_ifname(net, ifname);
+		session = l2tp_session_get_by_ifname(net, ifname, do_ref);
 	} else if ((info->attrs[L2TP_ATTR_SESSION_ID]) &&
 		   (info->attrs[L2TP_ATTR_CONN_ID])) {
 		tunnel_id = nla_get_u32(info->attrs[L2TP_ATTR_CONN_ID]);
 		session_id = nla_get_u32(info->attrs[L2TP_ATTR_SESSION_ID]);
 		tunnel = l2tp_tunnel_find(net, tunnel_id);
 		if (tunnel)
-			session = l2tp_session_find(net, tunnel, session_id);
+			session = l2tp_session_get(net, tunnel, session_id,
+						   do_ref);
 	}
 
 	return session;
@@ -660,7 +662,7 @@ static int l2tp_nl_cmd_session_delete(struct sk_buff *skb, struct genl_info *inf
 	struct l2tp_session *session;
 	u16 pw_type;
 
-	session = l2tp_nl_session_find(info);
+	session = l2tp_nl_session_get(info, true);
 	if (session == NULL) {
 		ret = -ENODEV;
 		goto out;
@@ -674,6 +676,10 @@ static int l2tp_nl_cmd_session_delete(struct sk_buff *skb, struct genl_info *inf
 		if (l2tp_nl_cmd_ops[pw_type] && l2tp_nl_cmd_ops[pw_type]->session_delete)
 			ret = (*l2tp_nl_cmd_ops[pw_type]->session_delete)(session);
 
+	if (session->deref)
+		session->deref(session);
+	l2tp_session_dec_refcount(session);
+
 out:
 	return ret;
 }
@@ -683,7 +689,7 @@ static int l2tp_nl_cmd_session_modify(struct sk_buff *skb, struct genl_info *inf
 	int ret = 0;
 	struct l2tp_session *session;
 
-	session = l2tp_nl_session_find(info);
+	session = l2tp_nl_session_get(info, false);
 	if (session == NULL) {
 		ret = -ENODEV;
 		goto out;
@@ -718,6 +724,8 @@ static int l2tp_nl_cmd_session_modify(struct sk_buff *skb, struct genl_info *inf
 	ret = l2tp_session_notify(&l2tp_nl_family, info,
 				  session, L2TP_CMD_SESSION_MODIFY);
 
+	l2tp_session_dec_refcount(session);
+
 out:
 	return ret;
 }
@@ -813,29 +821,34 @@ static int l2tp_nl_cmd_session_get(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *msg;
 	int ret;
 
-	session = l2tp_nl_session_find(info);
+	session = l2tp_nl_session_get(info, false);
 	if (session == NULL) {
 		ret = -ENODEV;
-		goto out;
+		goto err;
 	}
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg) {
 		ret = -ENOMEM;
-		goto out;
+		goto err_ref;
 	}
 
 	ret = l2tp_nl_session_send(msg, info->snd_portid, info->snd_seq,
 				   0, session, L2TP_CMD_SESSION_GET);
 	if (ret < 0)
-		goto err_out;
+		goto err_ref_msg;
 
-	return genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
+	ret = genlmsg_unicast(genl_info_net(info), msg, info->snd_portid);
 
-err_out:
-	nlmsg_free(msg);
+	l2tp_session_dec_refcount(session);
 
-out:
+	return ret;
+
+err_ref_msg:
+	nlmsg_free(msg);
+err_ref:
+	l2tp_session_dec_refcount(session);
+err:
 	return ret;
 }
 
-- 
2.11.0
