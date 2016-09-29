From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/6] rxrpc: Reduce the rxrpc_local::services list
 to a pointer
Date: Thu, 29 Sep 2016 23:15:55 +0100
Message-ID: <147518735533.29235.2910247307985125845.stgit@warthog.procyon.org.uk>
References: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce the rxrpc_local::services list to just a pointer as we don't permit
multiple service endpoints to bind to a single transport endpoints (this is
excluded by rxrpc_lookup_local()).

The reason we don't allow this is that if you send a request to an AFS
filesystem service, it will try to talk back to your cache manager on the
port you sent from (this is how file change notifications are handled).  To
prevent someone from stealing your CM callbacks, we don't let AF_RXRPC
sockets share a UDP socket if at least one of them has a service bound.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c     |   21 ++++++++-------------
 net/rxrpc/ar-internal.h  |    3 +--
 net/rxrpc/call_accept.c  |    8 ++++----
 net/rxrpc/local_object.c |    3 +--
 net/rxrpc/security.c     |    8 ++++----
 5 files changed, 18 insertions(+), 25 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 8dbf7bed2cc4..44c9c2b0b190 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -136,7 +136,8 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *)saddr;
 	struct sock *sk = sock->sk;
 	struct rxrpc_local *local;
-	struct rxrpc_sock *rx = rxrpc_sk(sk), *prx;
+	struct rxrpc_sock *rx = rxrpc_sk(sk);
+	u16 service_id = srx->srx_service;
 	int ret;
 
 	_enter("%p,%p,%d", rx, saddr, len);
@@ -160,15 +161,12 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 		goto error_unlock;
 	}
 
-	if (rx->srx.srx_service) {
+	if (service_id) {
 		write_lock(&local->services_lock);
-		hlist_for_each_entry(prx, &local->services, listen_link) {
-			if (prx->srx.srx_service == rx->srx.srx_service)
-				goto service_in_use;
-		}
-
+		if (rcu_access_pointer(local->service))
+			goto service_in_use;
 		rx->local = local;
-		hlist_add_head_rcu(&rx->listen_link, &local->services);
+		rcu_assign_pointer(local->service, rx);
 		write_unlock(&local->services_lock);
 
 		rx->sk.sk_state = RXRPC_SERVER_BOUND;
@@ -599,7 +597,6 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 	rx->family = protocol;
 	rx->calls = RB_ROOT;
 
-	INIT_HLIST_NODE(&rx->listen_link);
 	spin_lock_init(&rx->incoming_lock);
 	INIT_LIST_HEAD(&rx->sock_calls);
 	INIT_LIST_HEAD(&rx->to_be_accepted);
@@ -681,11 +678,9 @@ static int rxrpc_release_sock(struct sock *sk)
 	sk->sk_state = RXRPC_CLOSE;
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 
-	ASSERTCMP(rx->listen_link.next, !=, LIST_POISON1);
-
-	if (!hlist_unhashed(&rx->listen_link)) {
+	if (rx->local && rx->local->service == rx) {
 		write_lock(&rx->local->services_lock);
-		hlist_del_rcu(&rx->listen_link);
+		rx->local->service = NULL;
 		write_unlock(&rx->local->services_lock);
 	}
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 6aadaa7d8b43..539db54697f9 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -93,7 +93,6 @@ struct rxrpc_sock {
 	rxrpc_notify_new_call_t	notify_new_call; /* Func to notify of new call */
 	rxrpc_discard_new_call_t discard_new_call; /* Func to discard a new call */
 	struct rxrpc_local	*local;		/* local endpoint */
-	struct hlist_node	listen_link;	/* link in the local endpoint's listen list */
 	struct rxrpc_backlog	*backlog;	/* Preallocation for services */
 	spinlock_t		incoming_lock;	/* Incoming call vs service shutdown lock */
 	struct list_head	sock_calls;	/* List of calls owned by this socket */
@@ -216,7 +215,7 @@ struct rxrpc_local {
 	struct list_head	link;
 	struct socket		*socket;	/* my UDP socket */
 	struct work_struct	processor;
-	struct hlist_head	services;	/* services listening on this endpoint */
+	struct rxrpc_sock __rcu	*service;	/* Service(s) listening on this endpoint */
 	struct rw_semaphore	defrag_sem;	/* control re-enablement of IP DF bit */
 	struct sk_buff_head	reject_queue;	/* packets awaiting rejection */
 	struct sk_buff_head	event_queue;	/* endpoint event packets awaiting processing */
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index a8d39d7cf42c..3cac231d8405 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -331,14 +331,14 @@ struct rxrpc_call *rxrpc_new_incoming_call(struct rxrpc_local *local,
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_sock *rx;
 	struct rxrpc_call *call;
+	u16 service_id = sp->hdr.serviceId;
 
 	_enter("");
 
 	/* Get the socket providing the service */
-	hlist_for_each_entry_rcu_bh(rx, &local->services, listen_link) {
-		if (rx->srx.srx_service == sp->hdr.serviceId)
-			goto found_service;
-	}
+	rx = rcu_dereference(local->service);
+	if (service_id == rx->srx.srx_service)
+		goto found_service;
 
 	trace_rxrpc_abort("INV", sp->hdr.cid, sp->hdr.callNumber, sp->hdr.seq,
 			  RX_INVALID_OPERATION, EOPNOTSUPP);
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index e3fad80b0795..ff4864d550b8 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -86,7 +86,6 @@ static struct rxrpc_local *rxrpc_alloc_local(const struct sockaddr_rxrpc *srx)
 		atomic_set(&local->usage, 1);
 		INIT_LIST_HEAD(&local->link);
 		INIT_WORK(&local->processor, rxrpc_local_processor);
-		INIT_HLIST_HEAD(&local->services);
 		init_rwsem(&local->defrag_sem);
 		skb_queue_head_init(&local->reject_queue);
 		skb_queue_head_init(&local->event_queue);
@@ -292,7 +291,7 @@ static void rxrpc_local_destroyer(struct rxrpc_local *local)
 	mutex_unlock(&rxrpc_local_mutex);
 
 	ASSERT(RB_EMPTY_ROOT(&local->client_conns));
-	ASSERT(hlist_empty(&local->services));
+	ASSERT(!local->service);
 
 	if (socket) {
 		local->socket = NULL;
diff --git a/net/rxrpc/security.c b/net/rxrpc/security.c
index 82d8134e9287..7d921e56e715 100644
--- a/net/rxrpc/security.c
+++ b/net/rxrpc/security.c
@@ -131,10 +131,10 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 
 	/* find the service */
 	read_lock(&local->services_lock);
-	hlist_for_each_entry(rx, &local->services, listen_link) {
-		if (rx->srx.srx_service == conn->params.service_id)
-			goto found_service;
-	}
+	rx = rcu_dereference_protected(local->service,
+				       lockdep_is_held(&local->services_lock));
+	if (rx && rx->srx.srx_service == conn->params.service_id)
+		goto found_service;
 
 	/* the service appears to have died */
 	read_unlock(&local->services_lock);
