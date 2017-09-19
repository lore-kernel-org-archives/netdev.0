From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v2] l2tp: fix race condition in l2tp_tunnel_delete
Date: Tue, 19 Sep 2017 15:40:40 +0200
Message-ID: <6bfc5aceda47773af4c75fe7e0e3c0d255a2342d.1505828155.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Guillaume Nault <g.nault@alphalink.fr>,
        Xin Long <lucien.xin@gmail.com>,
        Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39939 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751098AbdISNlA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 09:41:00 -0400
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

Also check the flag in the tunnel lookup functions, to avoid returning a
tunnel that is already scheduled for destruction.

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
v2: as Tom Parkin explained, we can't remove the tunnel from the
    per-net list from netlink. v2 uses only a dead flag, and adds
    corresponding checks during lookups

 net/l2tp/l2tp_core.c | 18 +++++++++---------
 net/l2tp/l2tp_core.h |  5 ++++-
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index ee485df73ccd..3891f0260f2b 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -203,7 +203,8 @@ struct l2tp_tunnel *l2tp_tunnel_get(const struct net *net, u32 tunnel_id)
 
 	rcu_read_lock_bh();
 	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
-		if (tunnel->tunnel_id == tunnel_id) {
+		if (tunnel->tunnel_id == tunnel_id &&
+		    !test_bit(0, &tunnel->dead)) {
 			l2tp_tunnel_inc_refcount(tunnel);
 			rcu_read_unlock_bh();
 
@@ -390,7 +391,8 @@ struct l2tp_tunnel *l2tp_tunnel_find(const struct net *net, u32 tunnel_id)
 
 	rcu_read_lock_bh();
 	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
-		if (tunnel->tunnel_id == tunnel_id) {
+		if (tunnel->tunnel_id == tunnel_id &&
+		    !test_bit(0, &tunnel->dead)) {
 			rcu_read_unlock_bh();
 			return tunnel;
 		}
@@ -409,7 +411,7 @@ struct l2tp_tunnel *l2tp_tunnel_find_nth(const struct net *net, int nth)
 
 	rcu_read_lock_bh();
 	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
-		if (++count > nth) {
+		if (++count > nth && !test_bit(0, &tunnel->dead)) {
 			rcu_read_unlock_bh();
 			return tunnel;
 		}
@@ -1685,14 +1687,12 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
 
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
index a305e0c5925a..deda869504d0 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -160,6 +160,9 @@ struct l2tp_tunnel_cfg {
 
 struct l2tp_tunnel {
 	int			magic;		/* Should be L2TP_TUNNEL_MAGIC */
+
+	unsigned long		dead;
+
 	struct rcu_head rcu;
 	rwlock_t		hlist_lock;	/* protect session_hlist */
 	bool			acpt_newsess;	/* Indicates whether this
@@ -254,7 +257,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id,
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
