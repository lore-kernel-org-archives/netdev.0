From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 2/2] l2tp: pass tunnel pointer to ->session_create()
Date: Fri, 1 Sep 2017 17:58:51 +0200
Message-ID: <17c6806db17f27621fbf4fd12d864775cf0411da.1504277892.git.g.nault@alphalink.fr>
References: <cover.1504277892.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:46016 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752148AbdIAP67 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 11:58:59 -0400
Content-Disposition: inline
In-Reply-To: <cover.1504277892.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using l2tp_tunnel_find() in pppol2tp_session_create() and
l2tp_eth_create() is racy, because no reference is held on the
returned session. These functions are only used to implement the
->session_create callback which is run by l2tp_nl_cmd_session_create().
Therefore searching for the parent tunnel isn't necessary because
l2tp_nl_cmd_session_create() already has a pointer to it and holds a
reference.

This patch modifies ->session_create()'s prototype to directly pass the
the parent tunnel as parameter, thus avoiding searching for it in
pppol2tp_session_create() and l2tp_eth_create().

Since we have to touch the ->session_create() call in
l2tp_nl_cmd_session_create(), let's also remove the useless conditional:
we know that ->session_create isn't NULL at this point because it's
already been checked earlier in this same function.

Finally, one might be tempted to think that the removed
l2tp_tunnel_find() calls were harmless because they would return the
same tunnel as the one held by l2tp_nl_cmd_session_create() anyway.
But that tunnel might be removed and a new one created with same tunnel
Id before the l2tp_tunnel_find() call. In this case l2tp_tunnel_find()
would return the new tunnel which wouldn't be protected by the
reference held by l2tp_nl_cmd_session_create().

Fixes: 309795f4bec2 ("l2tp: Add netlink control API for L2TP")
Fixes: d9e31d17ceba ("l2tp: Add L2TP ethernet pseudowire support")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_core.h    |  4 +++-
 net/l2tp/l2tp_eth.c     | 11 +++--------
 net/l2tp/l2tp_netlink.c |  8 ++++----
 net/l2tp/l2tp_ppp.c     | 19 +++++++------------
 4 files changed, 17 insertions(+), 25 deletions(-)

diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 4593d48df953..a305e0c5925a 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -201,7 +201,9 @@ struct l2tp_tunnel {
 };
 
 struct l2tp_nl_cmd_ops {
-	int (*session_create)(struct net *net, u32 tunnel_id, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg);
+	int (*session_create)(struct net *net, struct l2tp_tunnel *tunnel,
+			      u32 session_id, u32 peer_session_id,
+			      struct l2tp_session_cfg *cfg);
 	int (*session_delete)(struct l2tp_session *session);
 };
 
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 4de2ec94b08c..87da9ef61860 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -262,24 +262,19 @@ static void l2tp_eth_adjust_mtu(struct l2tp_tunnel *tunnel,
 	dev->needed_headroom += session->hdr_len;
 }
 
-static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
+static int l2tp_eth_create(struct net *net, struct l2tp_tunnel *tunnel,
+			   u32 session_id, u32 peer_session_id,
+			   struct l2tp_session_cfg *cfg)
 {
 	unsigned char name_assign_type;
 	struct net_device *dev;
 	char name[IFNAMSIZ];
-	struct l2tp_tunnel *tunnel;
 	struct l2tp_session *session;
 	struct l2tp_eth *priv;
 	struct l2tp_eth_sess *spriv;
 	int rc;
 	struct l2tp_eth_net *pn;
 
-	tunnel = l2tp_tunnel_find(net, tunnel_id);
-	if (!tunnel) {
-		rc = -ENODEV;
-		goto out;
-	}
-
 	if (cfg->ifname) {
 		strlcpy(name, cfg->ifname, IFNAMSIZ);
 		name_assign_type = NET_NAME_USER;
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 57427d430f10..7135f4645d3a 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -643,10 +643,10 @@ static int l2tp_nl_cmd_session_create(struct sk_buff *skb, struct genl_info *inf
 		break;
 	}
 
-	ret = -EPROTONOSUPPORT;
-	if (l2tp_nl_cmd_ops[cfg.pw_type]->session_create)
-		ret = (*l2tp_nl_cmd_ops[cfg.pw_type]->session_create)(net, tunnel_id,
-			session_id, peer_session_id, &cfg);
+	ret = l2tp_nl_cmd_ops[cfg.pw_type]->session_create(net, tunnel,
+							   session_id,
+							   peer_session_id,
+							   &cfg);
 
 	if (ret >= 0) {
 		session = l2tp_session_get(net, tunnel, session_id, false);
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index f0edb7209079..50e3ee9a9d61 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -788,25 +788,20 @@ static int pppol2tp_connect(struct socket *sock, struct sockaddr *uservaddr,
 
 #ifdef CONFIG_L2TP_V3
 
-/* Called when creating sessions via the netlink interface.
- */
-static int pppol2tp_session_create(struct net *net, u32 tunnel_id, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg)
+/* Called when creating sessions via the netlink interface. */
+static int pppol2tp_session_create(struct net *net, struct l2tp_tunnel *tunnel,
+				   u32 session_id, u32 peer_session_id,
+				   struct l2tp_session_cfg *cfg)
 {
 	int error;
-	struct l2tp_tunnel *tunnel;
 	struct l2tp_session *session;
 	struct pppol2tp_session *ps;
 
-	tunnel = l2tp_tunnel_find(net, tunnel_id);
-
-	/* Error if we can't find the tunnel */
-	error = -ENOENT;
-	if (tunnel == NULL)
-		goto out;
-
 	/* Error if tunnel socket is not prepped */
-	if (tunnel->sock == NULL)
+	if (!tunnel->sock) {
+		error = -ENOENT;
 		goto out;
+	}
 
 	/* Default MTU values. */
 	if (cfg->mtu == 0)
-- 
2.14.1
