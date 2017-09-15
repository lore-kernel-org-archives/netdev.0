From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] l2tp: fix race condition in l2tp_tunnel_delete
Date: Fri, 15 Sep 2017 11:08:07 +0200
Message-ID: <f07e7ba88b9b4651900a888796e3f8816d06a8a8.1505396134.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Guillaume Nault <g.nault@alphalink.fr>,
        Xin Long <lucien.xin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58402 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751156AbdIOJIP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 05:08:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tunnel is currently removed from the list during destruction. This
can lead to a double-free of the struct sock if we try to delete the tunnel
twice fast enough.

The first delete operation does a lookup (l2tp_tunnel_get), finds the
tunnel, calls l2tp_tunnel_delete, which queues it for deletion by
l2tp_tunnel_del_work.

The second delete operation also finds the tunnel and calls
l2tp_tunnel_delete. If the workqueue has already fired and started
running l2tp_tunnel_del_work, then l2tp_tunnel_delete will queue the
same tunnel a second time, and try to free the socket again.

Add a dead flag and remove tunnel from its list earlier. Then we can
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
 net/l2tp/l2tp_core.c | 30 ++++++++++++++++--------------
 net/l2tp/l2tp_core.h |  4 +++-
 2 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index ee485df73ccd..26553d3c4f8f 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1245,7 +1245,6 @@ EXPORT_SYMBOL_GPL(l2tp_xmit_skb);
 static void l2tp_tunnel_destruct(struct sock *sk)
 {
 	struct l2tp_tunnel *tunnel = l2tp_tunnel(sk);
-	struct l2tp_net *pn;
 
 	if (tunnel == NULL)
 		goto end;
@@ -1269,13 +1268,6 @@ static void l2tp_tunnel_destruct(struct sock *sk)
 	sk->sk_destruct = tunnel->old_sk_destruct;
 	sk->sk_user_data = NULL;
 
-	/* Remove the tunnel struct from the tunnel list */
-	pn = l2tp_pernet(tunnel->l2tp_net);
-	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
-	list_del_rcu(&tunnel->list);
-	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
-	atomic_dec(&l2tp_tunnel_count);
-
 	l2tp_tunnel_closeall(tunnel);
 
 	tunnel->sock = NULL;
@@ -1685,14 +1677,24 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
 
 /* This function is used by the netlink TUNNEL_DELETE command.
  */
-int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
+void l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 {
+	struct l2tp_net *pn;
+
+	if (tunnel->dead)
+		return;
+
 	l2tp_tunnel_inc_refcount(tunnel);
-	if (false == queue_work(l2tp_wq, &tunnel->del_work)) {
-		l2tp_tunnel_dec_refcount(tunnel);
-		return 1;
-	}
-	return 0;
+
+	/* Remove the tunnel struct from the tunnel list */
+	pn = l2tp_pernet(tunnel->l2tp_net);
+	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
+	tunnel->dead = 1;
+	list_del_rcu(&tunnel->list);
+	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
+	atomic_dec(&l2tp_tunnel_count);
+
+	queue_work(l2tp_wq, &tunnel->del_work);
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
 
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index a305e0c5925a..173e68bb8119 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -160,6 +160,8 @@ struct l2tp_tunnel_cfg {
 
 struct l2tp_tunnel {
 	int			magic;		/* Should be L2TP_TUNNEL_MAGIC */
+	int			dead;
+
 	struct rcu_head rcu;
 	rwlock_t		hlist_lock;	/* protect session_hlist */
 	bool			acpt_newsess;	/* Indicates whether this
@@ -254,7 +256,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id,
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
