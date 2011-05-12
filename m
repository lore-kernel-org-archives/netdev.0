From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] l2tp: fix potential rcu race
Date: Thu, 12 May 2011 06:22:36 +0200
Message-ID: <1305174156.3232.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	James Chapman <jchapman@katalix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62545 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab1ELEWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 00:22:41 -0400
Received: by wwa36 with SMTP id 36so1312965wwa.1
        for <netdev@vger.kernel.org>; Wed, 11 May 2011 21:22:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While trying to remove useless synchronize_rcu() calls, I found l2tp is
indeed incorrectly using two of such calls, but also bumps tunnel
refcount after list insertion.

tunnel refcount must be incremented before being made publically visible
by rcu readers.

This fix can be applied to 2.6.35+ and might need a backport for older
kernels, since things were shuffled in commit fd558d186df2c
(l2tp: Split pppol2tp patch into separate l2tp and ppp parts)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
CC: James Chapman <jchapman@katalix.com>
---

I based this patch on net-next-2.6 because of recent commits in this
file and linux-2.6 being on late RC phase. But its a stable candidate.

 net/l2tp/l2tp_core.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 9be095e..ed8a233 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1435,16 +1435,15 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 
 	/* Add tunnel to our list */
 	INIT_LIST_HEAD(&tunnel->list);
-	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
-	list_add_rcu(&tunnel->list, &pn->l2tp_tunnel_list);
-	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
-	synchronize_rcu();
 	atomic_inc(&l2tp_tunnel_count);
 
 	/* Bump the reference count. The tunnel context is deleted
-	 * only when this drops to zero.
+	 * only when this drops to zero. Must be done before list insertion
 	 */
 	l2tp_tunnel_inc_refcount(tunnel);
+	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
+	list_add_rcu(&tunnel->list, &pn->l2tp_tunnel_list);
+	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
 
 	err = 0;
 err:
@@ -1636,7 +1635,6 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 			hlist_add_head_rcu(&session->global_hlist,
 					   l2tp_session_id_hash_2(pn, session_id));
 			spin_unlock_bh(&pn->l2tp_session_hlist_lock);
-			synchronize_rcu();
 		}
 
 		/* Ignore management session in session count value */


