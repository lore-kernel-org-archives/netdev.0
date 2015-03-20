From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 6/7] tipc: Use inlined rhashtable interface
Date: Fri, 20 Mar 2015 21:57:05 +1100
Message-ID: <E1YYubx-0004mC-6y@gondolin.me.apana.org.au>
References: <20150320105421.GA18148@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50479 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbbCTK5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:57:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts tipc to the inlined rhashtable interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/tipc/socket.c |   32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index c03a3d3..73c2f51 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -133,6 +133,8 @@ static const struct nla_policy tipc_nl_sock_policy[TIPC_NLA_SOCK_MAX + 1] = {
 	[TIPC_NLA_SOCK_HAS_PUBL]	= { .type = NLA_FLAG }
 };
 
+static const struct rhashtable_params tsk_rht_params;
+
 /*
  * Revised TIPC socket locking policy:
  *
@@ -2245,7 +2247,7 @@ static struct tipc_sock *tipc_sk_lookup(struct net *net, u32 portid)
 	struct tipc_sock *tsk;
 
 	rcu_read_lock();
-	tsk = rhashtable_lookup(&tn->sk_rht, &portid);
+	tsk = rhashtable_lookup_fast(&tn->sk_rht, &portid, tsk_rht_params);
 	if (tsk)
 		sock_hold(&tsk->sk);
 	rcu_read_unlock();
@@ -2267,7 +2269,8 @@ static int tipc_sk_insert(struct tipc_sock *tsk)
 			portid = TIPC_MIN_PORT;
 		tsk->portid = portid;
 		sock_hold(&tsk->sk);
-		if (rhashtable_lookup_insert(&tn->sk_rht, &tsk->node))
+		if (!rhashtable_lookup_insert_fast(&tn->sk_rht, &tsk->node,
+						   tsk_rht_params))
 			return 0;
 		sock_put(&tsk->sk);
 	}
@@ -2280,26 +2283,27 @@ static void tipc_sk_remove(struct tipc_sock *tsk)
 	struct sock *sk = &tsk->sk;
 	struct tipc_net *tn = net_generic(sock_net(sk), tipc_net_id);
 
-	if (rhashtable_remove(&tn->sk_rht, &tsk->node)) {
+	if (!rhashtable_remove_fast(&tn->sk_rht, &tsk->node, tsk_rht_params)) {
 		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
 		__sock_put(sk);
 	}
 }
 
+static const struct rhashtable_params tsk_rht_params = {
+	.nelem_hint = 192,
+	.head_offset = offsetof(struct tipc_sock, node),
+	.key_offset = offsetof(struct tipc_sock, portid),
+	.key_len = sizeof(u32), /* portid */
+	.hashfn = jhash,
+	.max_size = 1048576,
+	.min_size = 256,
+};
+
 int tipc_sk_rht_init(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct rhashtable_params rht_params = {
-		.nelem_hint = 192,
-		.head_offset = offsetof(struct tipc_sock, node),
-		.key_offset = offsetof(struct tipc_sock, portid),
-		.key_len = sizeof(u32), /* portid */
-		.hashfn = jhash,
-		.max_size = 1048576,
-		.min_size = 256,
-	};
-
-	return rhashtable_init(&tn->sk_rht, &rht_params);
+
+	return rhashtable_init(&tn->sk_rht, &tsk_rht_params);
 }
 
 void tipc_sk_rht_destroy(struct net *net)
