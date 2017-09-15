From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] l2tp: fix race condition in l2tp_tunnel_delete
Date: Fri, 15 Sep 2017 16:55:02 +0200
Message-ID: <20170915145502.GA18157@bistromath.localdomain>
References: <f07e7ba88b9b4651900a888796e3f8816d06a8a8.1505396134.git.sd@queasysnail.net>
 <20170915094259.GA3209@jackdaw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Guillaume Nault <g.nault@alphalink.fr>,
        Xin Long <lucien.xin@gmail.com>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35312 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751111AbdIOOzG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 10:55:06 -0400
Content-Disposition: inline
In-Reply-To: <20170915094259.GA3209@jackdaw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-09-15, 10:42:59 +0100, Tom Parkin wrote:
> On Fri, Sep 15, 2017 at 11:08:07AM +0200, Sabrina Dubroca wrote:
> > The tunnel is currently removed from the list during destruction. This
> > can lead to a double-free of the struct sock if we try to delete the tunnel
> > twice fast enough.
> > 
> > The first delete operation does a lookup (l2tp_tunnel_get), finds the
> > tunnel, calls l2tp_tunnel_delete, which queues it for deletion by
> > l2tp_tunnel_del_work.
> >
> > The second delete operation also finds the tunnel and calls
> > l2tp_tunnel_delete. If the workqueue has already fired and started
> > running l2tp_tunnel_del_work, then l2tp_tunnel_delete will queue the
> > same tunnel a second time, and try to free the socket again.
> > 
> > Add a dead flag and remove tunnel from its list earlier. Then we can
> > remove the check of queue_work's result that was meant to prevent that
> > race but doesn't.
> 
> How do we avoid leaving stale information on the tunnel list for
> use-cases which don't delete tunnels using netlink?  For example the
> L2TPv2 ppp/socket API depends on sk_destruct to clean up the kernel
> context on socket destruction.  Similarly, userspace may just close
> the tunnel socket without first making netlink calls to delete the
> tunnel.
> 
> By moving the tunnel list removal from l2tp_tunnel_destruct to
> l2tp_tunnel_delete I can't see how codepaths which don't involve
> l2tp_tunnel_delete don't end up with a corrupted tunnel list.

Ok, thanks for pointing that out. We could go with just the ->dead
flag then. I'm not sure whether we need to set it in
l2tp_tunnel_destruct as well.

-------- 8< --------

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index ee485df73ccd..e74596418169 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1685,14 +1685,12 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
 
 /* This function is used by the netlink TUNNEL_DELETE command.
  */
-int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
+void l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 {
-	l2tp_tunnel_inc_refcount(tunnel);
-	if (false == queue_work(l2tp_wq, &tunnel->del_work)) {
-		l2tp_tunnel_dec_refcount(tunnel);
-		return 1;
+	if (!test_and_set_bit(1, &tunnel->dead)) {
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
Sabrina
