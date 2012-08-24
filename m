From: Kozlov Dmitry <xeb@mail.ru>
Subject: [PATCH 1/1] l2tp: avoid to use synchronize_rcu in tunnel free function
Date: Fri, 24 Aug 2012 15:07:38 +0400
Message-ID: <1430615.YYms4uRCh4@dima>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: kleptog@svana.org, jchapman@katalix.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp12.mail.ru ([94.100.176.89]:45799 "EHLO smtp12.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759298Ab2HXLHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 07:07:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid to use synchronize_rcu in l2tp_tunnel_free because context may be
atomic.

Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
---
 net/l2tp/l2tp_core.c |    3 +--
 net/l2tp/l2tp_core.h |    1 +
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 393355d..513cab0 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1347,11 +1347,10 @@ static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel)
 	/* Remove from tunnel list */
 	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
 	list_del_rcu(&tunnel->list);
+	kfree_rcu(tunnel, rcu);
 	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
-	synchronize_rcu();
 
 	atomic_dec(&l2tp_tunnel_count);
-	kfree(tunnel);
 }
 
 /* Create a socket for the tunnel, if one isn't set up by
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index a38ec6c..56d583e 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -163,6 +163,7 @@ struct l2tp_tunnel_cfg {
 
 struct l2tp_tunnel {
 	int			magic;		/* Should be L2TP_TUNNEL_MAGIC */
+	struct rcu_head rcu;
 	rwlock_t		hlist_lock;	/* protect session_hlist */
 	struct hlist_head	session_hlist[L2TP_HASH_SIZE];
 						/* hashed list of sessions,
