From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v3] l2tp: fix race condition in l2tp_tunnel_delete
Date: Tue, 26 Sep 2017 16:16:43 +0200
Message-ID: <d6011f741f7ea38a61006b9f2cde8e544b4d206b.1506432922.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Guillaume Nault <g.nault@alphalink.fr>,
        Xin Long <lucien.xin@gmail.com>,
        Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965228AbdIZORV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 10:17:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we try to delete the same tunnel twice, the first delete operation
does a lookup (l2tp_tunnel_get), finds the tunnel, calls
l2tp_tunnel_delete, which queues it for deletion by
l2tp_tunnel_del_work.

The second delete operation also finds the tunnel and calls
l2tp_tunnel_delete. If the workqueue has already fired and started
running l2tp_tunnel_del_work, then l2tp_tunnel_delete will queue the
same tunnel a second time, and try to free the socket again.

Add a dead flag to prevent firing the workqueue twice. Then we can
remove the check of queue_work's result that was meant to prevent that
race but doesn't.

Reproducer:

    ip l2tp add tunnel tunnel_id 3000 peer_tunnel_id 4000 local 192.168.0.2 remote 192.168.0.1 encap udp udp_sport 5000 udp_dport 6000
    ip l2tp add session name l2tp1 tunnel_id 3000 session_id 1000 peer_session_id 2000
    ip link set l2tp1 up
    ip l2tp del tunnel tunnel_id 3000
    ip l2tp del tunnel tunnel_id 3000

Fixes: f8ccac0e4493 ("l2tp: put tunnel socket release on a workqueue")
Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
v3: only prevent double deletion, drop checks during lookups

v2: as Tom Parkin explained, we can't remove the tunnel from the
    per-net list from netlink. v2 uses only a dead flag, and adds
    corresponding checks during lookups

 net/l2tp/l2tp_core.c | 10 ++++------
 net/l2tp/l2tp_core.h |  5 ++++-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index d8c2a89a76e1..02d61101b108 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1688,14 +1688,12 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
 
 /* This function is used by the netlink TUNNEL_DELETE command.
  */
-int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
+void l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 {
-	l2tp_tunnel_inc_refcount(tunnel);
-	if (false == queue_work(l2tp_wq, &tunnel->del_work)) {
-		l2tp_tunnel_dec_refcount(tunnel);
-		return 1;
+	if (!test_and_set_bit(0, &tunnel->dead)) {
+		l2tp_tunnel_inc_refcount(tunnel);
+		queue_work(l2tp_wq, &tunnel->del_work);
 	}
-	return 0;
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
 
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 70a12df40a5f..67c79d9b5c6c 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -161,6 +161,9 @@ struct l2tp_tunnel_cfg {
 
 struct l2tp_tunnel {
 	int			magic;		/* Should be L2TP_TUNNEL_MAGIC */
+
+	unsigned long		dead;
+
 	struct rcu_head rcu;
 	rwlock_t		hlist_lock;	/* protect session_hlist */
 	bool			acpt_newsess;	/* Indicates whether this
@@ -255,7 +258,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id,
 		       u32 peer_tunnel_id, struct l2tp_tunnel_cfg *cfg,
 		       struct l2tp_tunnel **tunnelp);
 void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel);
-int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel);
+void l2tp_tunnel_delete(struct l2tp_tunnel *tunnel);
 struct l2tp_session *l2tp_session_create(int priv_size,
 					 struct l2tp_tunnel *tunnel,
 					 u32 session_id, u32 peer_session_id,
-- 
2.14.1
