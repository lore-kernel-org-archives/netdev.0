From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] tipc: Fix tipc_sk_reinit race conditions
Date: Tue, 07 Feb 2017 20:39:44 +0800
Message-ID: <E1cb53g-0003pz-KV@gondobar>
References: <20170207123827.GA14678@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:34337 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753829AbdBGMjx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 07:39:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two problems with the function tipc_sk_reinit.  Firstly
it's doing a manual walk over an rhashtable.  This is broken as
an rhashtable can be resized and if you manually walk over it
during a resize then you may miss entries.

Secondly it's missing memory barriers as previously the code used
spinlocks which provide the barriers implicitly.

This patch fixes both problems.

Fixes: 07f6c4bc048a ("tipc: convert tipc reference table to...")
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/tipc/net.c    |    4 ++++
 net/tipc/socket.c |   30 +++++++++++++++++++-----------
 2 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/net/tipc/net.c b/net/tipc/net.c
index 28bf4fe..ab8a2d5 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -110,6 +110,10 @@ int tipc_net_start(struct net *net, u32 addr)
 	char addr_string[16];
 
 	tn->own_addr = addr;
+
+	/* Ensure that the new address is visible before we reinit. */
+	smp_mb();
+
 	tipc_named_reinit(net);
 	tipc_sk_reinit(net);
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 333c5da..20240e1 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -384,8 +384,6 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	INIT_LIST_HEAD(&tsk->publications);
 	msg = &tsk->phdr;
 	tn = net_generic(sock_net(sk), tipc_net_id);
-	tipc_msg_init(tn->own_addr, msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG,
-		      NAMED_H_SIZE, 0);
 
 	/* Finish initializing socket data structures */
 	sock->ops = ops;
@@ -395,6 +393,13 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 		pr_warn("Socket create failed; port number exhausted\n");
 		return -EINVAL;
 	}
+
+	/* Ensure tsk is visible before we read own_addr. */
+	smp_mb();
+
+	tipc_msg_init(tn->own_addr, msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG,
+		      NAMED_H_SIZE, 0);
+
 	msg_set_origport(msg, tsk->portid);
 	setup_timer(&sk->sk_timer, tipc_sk_timeout, (unsigned long)tsk);
 	sk->sk_shutdown = 0;
@@ -2267,24 +2272,27 @@ static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
 void tipc_sk_reinit(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	const struct bucket_table *tbl;
-	struct rhash_head *pos;
+	struct rhashtable_iter iter;
 	struct tipc_sock *tsk;
 	struct tipc_msg *msg;
-	int i;
 
-	rcu_read_lock();
-	tbl = rht_dereference_rcu((&tn->sk_rht)->tbl, &tn->sk_rht);
-	for (i = 0; i < tbl->size; i++) {
-		rht_for_each_entry_rcu(tsk, pos, tbl, i, node) {
+	rhashtable_walk_enter(&tn->sk_rht, &iter);
+
+	do {
+		tsk = ERR_PTR(rhashtable_walk_start(&iter));
+		if (tsk)
+			continue;
+
+		while ((tsk = rhashtable_walk_next(&iter)) && !IS_ERR(tsk)) {
 			spin_lock_bh(&tsk->sk.sk_lock.slock);
 			msg = &tsk->phdr;
 			msg_set_prevnode(msg, tn->own_addr);
 			msg_set_orignode(msg, tn->own_addr);
 			spin_unlock_bh(&tsk->sk.sk_lock.slock);
 		}
-	}
-	rcu_read_unlock();
+
+		rhashtable_walk_stop(&iter);
+	} while (tsk == ERR_PTR(-EAGAIN));
 }
 
 static struct tipc_sock *tipc_sk_lookup(struct net *net, u32 portid)
