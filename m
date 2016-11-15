From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: use new rhlist interface on sctp transport rhashtable
Date: Tue, 15 Nov 2016 23:23:11 +0800
Message-ID: <0a89ef8506db3bba6a37010bd5622cd145183ab4.1479223391.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>, phil@nwl.cc
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34178 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbcKOPXS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 10:23:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now sctp transport rhashtable uses hash(lport, dport, daddr) as the key
to hash a node to one chain. If in one host thousands of assocs connect
to one server with the same lport and different laddrs (although it's
not a normal case), all the transports would be hashed into the same
chain.

It may cause to keep returning -EBUSY when inserting a new node, as the
chain is too long and sctp inserts a transport node in a loop, which
could even lead to system hangs there.

The new rhlist interface works for this case that there are many nodes
with the same key in one chain. It puts them into a list then makes this
list be as a node of the chain.

This patch is to replace rhashtable_ interface with rhltable_ interface.
Since a chain would not be too long and it would not return -EBUSY with
this fix when inserting a node, the reinsert loop is also removed here.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h    |  2 +-
 include/net/sctp/structs.h |  4 +-
 net/sctp/associola.c       |  8 +++-
 net/sctp/input.c           | 93 ++++++++++++++++++++++++++--------------------
 net/sctp/socket.c          |  7 +---
 5 files changed, 64 insertions(+), 50 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 31acc3f..f0dcaeb 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -164,7 +164,7 @@ void sctp_backlog_migrate(struct sctp_association *assoc,
 			  struct sock *oldsk, struct sock *newsk);
 int sctp_transport_hashtable_init(void);
 void sctp_transport_hashtable_destroy(void);
-void sctp_hash_transport(struct sctp_transport *t);
+int sctp_hash_transport(struct sctp_transport *t);
 void sctp_unhash_transport(struct sctp_transport *t);
 struct sctp_transport *sctp_addrs_lookup_transport(
 				struct net *net,
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 11c3bf2..c5a2d83 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -124,7 +124,7 @@ extern struct sctp_globals {
 	/* This is the sctp port control hash.	*/
 	struct sctp_bind_hashbucket *port_hashtable;
 	/* This is the hash of all transports. */
-	struct rhashtable transport_hashtable;
+	struct rhltable transport_hashtable;
 
 	/* Sizes of above hashtables. */
 	int ep_hashsize;
@@ -762,7 +762,7 @@ static inline int sctp_packet_empty(struct sctp_packet *packet)
 struct sctp_transport {
 	/* A list of transports. */
 	struct list_head transports;
-	struct rhash_head node;
+	struct rhlist_head node;
 
 	/* Reference counting. */
 	atomic_t refcnt;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index f10d339..68428e1 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -700,11 +700,15 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 	/* Set the peer's active state. */
 	peer->state = peer_state;
 
+	/* Add this peer into the transport hashtable */
+	if (sctp_hash_transport(peer)) {
+		sctp_transport_free(peer);
+		return NULL;
+	}
+
 	/* Attach the remote transport to our asoc.  */
 	list_add_tail_rcu(&peer->transports, &asoc->peer.transport_addr_list);
 	asoc->peer.transport_count++;
-	/* Add this peer into the transport hashtable */
-	sctp_hash_transport(peer);
 
 	/* If we do not yet have a primary path, set one.  */
 	if (!asoc->peer.primary_path) {
diff --git a/net/sctp/input.c b/net/sctp/input.c
index a01a56e..458e506 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -790,10 +790,9 @@ static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
 
 /* rhashtable for transport */
 struct sctp_hash_cmp_arg {
-	const struct sctp_endpoint	*ep;
-	const union sctp_addr		*laddr;
-	const union sctp_addr		*paddr;
-	const struct net		*net;
+	const union sctp_addr	*paddr;
+	const struct net	*net;
+	u16			lport;
 };
 
 static inline int sctp_hash_cmp(struct rhashtable_compare_arg *arg,
@@ -801,7 +800,6 @@ static inline int sctp_hash_cmp(struct rhashtable_compare_arg *arg,
 {
 	struct sctp_transport *t = (struct sctp_transport *)ptr;
 	const struct sctp_hash_cmp_arg *x = arg->key;
-	struct sctp_association *asoc;
 	int err = 1;
 
 	if (!sctp_cmp_addr_exact(&t->ipaddr, x->paddr))
@@ -809,19 +807,10 @@ static inline int sctp_hash_cmp(struct rhashtable_compare_arg *arg,
 	if (!sctp_transport_hold(t))
 		return err;
 
-	asoc = t->asoc;
-	if (!net_eq(sock_net(asoc->base.sk), x->net))
+	if (!net_eq(sock_net(t->asoc->base.sk), x->net))
+		goto out;
+	if (x->lport != htons(t->asoc->base.bind_addr.port))
 		goto out;
-	if (x->ep) {
-		if (x->ep != asoc->ep)
-			goto out;
-	} else {
-		if (x->laddr->v4.sin_port != htons(asoc->base.bind_addr.port))
-			goto out;
-		if (!sctp_bind_addr_match(&asoc->base.bind_addr,
-					  x->laddr, sctp_sk(asoc->base.sk)))
-			goto out;
-	}
 
 	err = 0;
 out:
@@ -851,11 +840,9 @@ static inline u32 sctp_hash_key(const void *data, u32 len, u32 seed)
 	const struct sctp_hash_cmp_arg *x = data;
 	const union sctp_addr *paddr = x->paddr;
 	const struct net *net = x->net;
-	u16 lport;
+	u16 lport = x->lport;
 	u32 addr;
 
-	lport = x->ep ? htons(x->ep->base.bind_addr.port) :
-			x->laddr->v4.sin_port;
 	if (paddr->sa.sa_family == AF_INET6)
 		addr = jhash(&paddr->v6.sin6_addr, 16, seed);
 	else
@@ -875,29 +862,32 @@ static const struct rhashtable_params sctp_hash_params = {
 
 int sctp_transport_hashtable_init(void)
 {
-	return rhashtable_init(&sctp_transport_hashtable, &sctp_hash_params);
+	return rhltable_init(&sctp_transport_hashtable, &sctp_hash_params);
 }
 
 void sctp_transport_hashtable_destroy(void)
 {
-	rhashtable_destroy(&sctp_transport_hashtable);
+	rhltable_destroy(&sctp_transport_hashtable);
 }
 
-void sctp_hash_transport(struct sctp_transport *t)
+int sctp_hash_transport(struct sctp_transport *t)
 {
 	struct sctp_hash_cmp_arg arg;
+	int err;
 
 	if (t->asoc->temp)
-		return;
+		return 0;
 
-	arg.ep = t->asoc->ep;
-	arg.paddr = &t->ipaddr;
 	arg.net   = sock_net(t->asoc->base.sk);
+	arg.paddr = &t->ipaddr;
+	arg.lport = htons(t->asoc->base.bind_addr.port);
 
-reinsert:
-	if (rhashtable_lookup_insert_key(&sctp_transport_hashtable, &arg,
-					 &t->node, sctp_hash_params) == -EBUSY)
-		goto reinsert;
+	err = rhltable_insert_key(&sctp_transport_hashtable, &arg,
+				  &t->node, sctp_hash_params);
+	if (err)
+		pr_err_once("insert transport fail, errno %d\n", err);
+
+	return err;
 }
 
 void sctp_unhash_transport(struct sctp_transport *t)
@@ -905,39 +895,62 @@ void sctp_unhash_transport(struct sctp_transport *t)
 	if (t->asoc->temp)
 		return;
 
-	rhashtable_remove_fast(&sctp_transport_hashtable, &t->node,
-			       sctp_hash_params);
+	rhltable_remove(&sctp_transport_hashtable, &t->node,
+			sctp_hash_params);
 }
 
+/* return a transport with holding it */
 struct sctp_transport *sctp_addrs_lookup_transport(
 				struct net *net,
 				const union sctp_addr *laddr,
 				const union sctp_addr *paddr)
 {
+	struct rhlist_head *tmp, *list;
+	struct sctp_transport *t;
 	struct sctp_hash_cmp_arg arg = {
-		.ep    = NULL,
-		.laddr = laddr,
 		.paddr = paddr,
 		.net   = net,
+		.lport = laddr->v4.sin_port,
 	};
 
-	return rhashtable_lookup_fast(&sctp_transport_hashtable, &arg,
-				      sctp_hash_params);
+	list = rhltable_lookup(&sctp_transport_hashtable, &arg,
+			       sctp_hash_params);
+
+	rhl_for_each_entry_rcu(t, tmp, list, node) {
+		if (!sctp_transport_hold(t))
+			continue;
+
+		if (sctp_bind_addr_match(&t->asoc->base.bind_addr,
+					 laddr, sctp_sk(t->asoc->base.sk)))
+			return t;
+		sctp_transport_put(t);
+	}
+
+	return NULL;
 }
 
+/* return a transport without holding it, as it's only used under sock lock */
 struct sctp_transport *sctp_epaddr_lookup_transport(
 				const struct sctp_endpoint *ep,
 				const union sctp_addr *paddr)
 {
 	struct net *net = sock_net(ep->base.sk);
+	struct rhlist_head *tmp, *list;
+	struct sctp_transport *t;
 	struct sctp_hash_cmp_arg arg = {
-		.ep    = ep,
 		.paddr = paddr,
 		.net   = net,
+		.lport = htons(ep->base.bind_addr.port),
 	};
 
-	return rhashtable_lookup_fast(&sctp_transport_hashtable, &arg,
-				      sctp_hash_params);
+	list = rhltable_lookup(&sctp_transport_hashtable, &arg,
+			       sctp_hash_params);
+
+	rhl_for_each_entry_rcu(t, tmp, list, node)
+		if (ep == t->asoc->ep)
+			return t;
+
+	return NULL;
 }
 
 /* Look up an association. */
@@ -951,7 +964,7 @@ static struct sctp_association *__sctp_lookup_association(
 	struct sctp_association *asoc = NULL;
 
 	t = sctp_addrs_lookup_transport(net, local, peer);
-	if (!t || !sctp_transport_hold(t))
+	if (!t)
 		goto out;
 
 	asoc = t->asoc;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f23ad91..d5f4b4a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4392,10 +4392,7 @@ int sctp_transport_walk_start(struct rhashtable_iter *iter)
 {
 	int err;
 
-	err = rhashtable_walk_init(&sctp_transport_hashtable, iter,
-				   GFP_KERNEL);
-	if (err)
-		return err;
+	rhltable_walk_enter(&sctp_transport_hashtable, iter);
 
 	err = rhashtable_walk_start(iter);
 	if (err && err != -EAGAIN) {
@@ -4479,7 +4476,7 @@ int sctp_transport_lookup_process(int (*cb)(struct sctp_transport *, void *),
 
 	rcu_read_lock();
 	transport = sctp_addrs_lookup_transport(net, laddr, paddr);
-	if (!transport || !sctp_transport_hold(transport))
+	if (!transport)
 		goto out;
 
 	rcu_read_unlock();
-- 
2.1.0
