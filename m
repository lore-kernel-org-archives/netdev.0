From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC PATCH 4/6] l2tp: export l2tp_tunnel_closeall
Date: Fri, 15 Feb 2013 10:25:17 +0000
Message-ID: <1360923919-7203-5-git-send-email-tparkin@katalix.com>
References: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:34091 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161231Ab3BOKZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 05:25:36 -0500
In-Reply-To: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_core internally uses l2tp_tunnel_closeall to close all sessions in a
tunnel when a UDP-encapsualtion socket is destroyed.  We need to do something
similar for IP-encapsualtion sockets.

Export l2tp_tunnel_closeall as a GPL symbol to enable l2tp_ip and l2tp_ip6 to
call it from their .destroy handlers.

---
 net/l2tp/l2tp_core.c |    4 ++--
 net/l2tp/l2tp_core.h |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 7f3ab65..26b5f00 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -114,7 +114,6 @@ struct l2tp_net {
 
 static void l2tp_session_set_header_len(struct l2tp_session *session, int version);
 static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel);
-static void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel);
 
 static inline struct l2tp_net *l2tp_pernet(struct net *net)
 {
@@ -1279,7 +1278,7 @@ end:
 
 /* When the tunnel is closed, all the attached sessions need to go too.
  */
-static void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel)
+void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel)
 {
 	int hash;
 	struct hlist_node *walk;
@@ -1342,6 +1341,7 @@ again:
 	}
 	write_unlock_bh(&tunnel->hlist_lock);
 }
+EXPORT_SYMBOL_GPL(l2tp_tunnel_closeall);
 
 /* Tunnel socket destroy hook for UDP encapsulation */
 static void l2tp_udp_encap_destroy(struct sock *sk)
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index a6d9c5d..d1b37c1 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -239,6 +239,7 @@ extern struct l2tp_tunnel *l2tp_tunnel_find(struct net *net, u32 tunnel_id);
 extern struct l2tp_tunnel *l2tp_tunnel_find_nth(struct net *net, int nth);
 
 extern int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32 peer_tunnel_id, struct l2tp_tunnel_cfg *cfg, struct l2tp_tunnel **tunnelp);
+extern void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel);
 extern int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel);
 extern struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunnel, u32 session_id, u32 peer_session_id, struct l2tp_session_cfg *cfg);
 extern int l2tp_session_delete(struct l2tp_session *session);
-- 
1.7.9.5
