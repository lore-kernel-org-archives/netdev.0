From: David Howells <dhowells@redhat.com>
Subject: [PATCH 04/11] rxrpc: Implement local endpoint cache
Date: Mon, 07 Mar 2016 14:38:27 +0000
Message-ID: <20160307143827.18567.17282.stgit@warthog.procyon.org.uk>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the local RxRPC endpoint cache.  Only the primary cache is used.
This is indexed on the following details:

  - Local network transport family - currently only AF_INET.
  - Local network transport type - currently only UDP.
  - Local network transport address.

The hash isn't very big since we don't expect to have many local endpoints
hanging around - RxRPC sockets opened with a 0 service ID (ie. client-only
sockets) share local endpoints if they have matching local network
addresses (typically all zeros).

We use a mutex to handle lookups and don't provide RCU-only lookups since
we only expect write access to this cache to be done from process context
when opening a socket.  The local endpoint object is pointed to by the
transport socket's sk_user_data for the life of the transport socket so
that it's fast to access by the transport socket sk_data_ready and
sk_error_report callbacks.

Further, the transport socket is shut down before we clear the sk_user_data
pointer, so that we can be sure that the transport socket's callbacks won't
be invoked once the RCU destruction is scheduled.

The local endpoint retains the transport socket that we use to send and
capture packets and capture network error messages (ICMP).  The socket is
opened when an endpoint is looked up - if it doesn't already exist.

Note that to make this work, we have to get rid of rxrpc_local_lock as that
causes a potential deadlock between a softirq looking in an object cache
whilst holding that lock vs objcache_clear() taking the cache lock and then
an interrupt.

However, since the socket is locked by the caller of the rxrpc_data_ready()
function and given that we don't clear sk_user_data until after we've shut
down the socket, we are guaranteed that the local endpoint struct is pinned
until rxrpc_data_ready() returns - so we don't need to lock the local
endpoint struct there.

The other places we've taken the lock where we read the usage count and
then increment it if not zero can be replaced by atomic_inc_not_zero()
(hidden inside rxrpc_get_local_maybe()).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c     |    5 +
 net/rxrpc/ar-accept.c    |    7 -
 net/rxrpc/ar-connevent.c |    2 
 net/rxrpc/ar-input.c     |   18 +--
 net/rxrpc/ar-internal.h  |   41 +++---
 net/rxrpc/ar-local.c     |    5 -
 net/rxrpc/local-object.c |  311 +++++++++++++++++++++++-----------------------
 7 files changed, 194 insertions(+), 195 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index a76501757b59..a27d8e3ef854 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -791,6 +791,8 @@ static int __init af_rxrpc_init(void)
 
 	rxrpc_epoch = get_seconds();
 
+	objcache_init(&rxrpc_local_cache);
+
 	ret = -ENOMEM;
 	rxrpc_call_jar = kmem_cache_create(
 		"rxrpc_call_jar", sizeof(struct rxrpc_call), 0,
@@ -856,6 +858,7 @@ error_proto:
 error_work_queue:
 	kmem_cache_destroy(rxrpc_call_jar);
 error_call_jar:
+	objcache_clear(&rxrpc_local_cache);
 	return ret;
 }
 
@@ -874,7 +877,7 @@ static void __exit af_rxrpc_exit(void)
 	rxrpc_destroy_all_connections();
 	rxrpc_destroy_all_transports();
 	rxrpc_destroy_all_peers();
-	rxrpc_destroy_all_locals();
+	objcache_clear(&rxrpc_local_cache);
 
 	ASSERTCMP(atomic_read(&rxrpc_n_skbs), ==, 0);
 
diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index 277731a5e67a..d43799f8d3ef 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -213,12 +213,7 @@ void rxrpc_accept_incoming_calls(struct work_struct *work)
 
 	_enter("%d", local->debug_id);
 
-	read_lock_bh(&rxrpc_local_lock);
-	if (atomic_read(&local->usage) > 0)
-		rxrpc_get_local(local);
-	else
-		local = NULL;
-	read_unlock_bh(&rxrpc_local_lock);
+	local = rxrpc_get_local_maybe(local);
 	if (!local) {
 		_leave(" [local dead]");
 		return;
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index 1bdaaed8cdc4..74ad0d24faad 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -317,7 +317,7 @@ void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
 {
 	CHECK_SLAB_OKAY(&local->usage);
 
-	if (!atomic_inc_not_zero(&local->usage)) {
+	if (!rxrpc_get_local_maybe(local)) {
 		printk("resurrected on reject\n");
 		BUG();
 	}
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 63ed75c40e29..514bfdaba322 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -598,9 +598,9 @@ static void rxrpc_post_packet_to_local(struct rxrpc_local *local,
 {
 	_enter("%p,%p", local, skb);
 
-	atomic_inc(&local->usage);
+	rxrpc_get_local(local);
 	skb_queue_tail(&local->event_queue, skb);
-	rxrpc_queue_work(&local->event_processor);
+	rxrpc_queue_work(&local->processor);
 }
 
 /*
@@ -675,13 +675,13 @@ void rxrpc_data_ready(struct sock *sk)
 
 	ASSERT(!irqs_disabled());
 
-	read_lock_bh(&rxrpc_local_lock);
-	local = sk->sk_user_data;
-	if (local && atomic_read(&local->usage) > 0)
-		rxrpc_get_local(local);
-	else
-		local = NULL;
-	read_unlock_bh(&rxrpc_local_lock);
+	/* The socket is locked by the caller and this prevents the socket from
+	 * being shut down, thus preventing sk_user_data from being cleared
+	 * until this function returns.  The local endpoint may, however, be in
+	 * the process of being discarded from the cache, so we still need to
+	 * validate it.
+	 */
+	local = rxrpc_get_local_maybe(sk->sk_user_data);
 	if (!local) {
 		_leave(" [local dead]");
 		return;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index cec573dbb5e1..ceb1442f745b 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -167,24 +167,24 @@ struct rxrpc_security {
 };
 
 /*
- * RxRPC local transport endpoint definition
- * - matched by local port, address and protocol type
+ * RxRPC local transport endpoint description
+ * - owned by a single AF_RXRPC socket
+ * - pointed to by transport socket struct sk_user_data
  */
 struct rxrpc_local {
+	struct obj_node		obj;
 	struct socket		*socket;	/* my UDP socket */
-	struct work_struct	destroyer;	/* endpoint destroyer */
 	struct work_struct	acceptor;	/* incoming call processor */
 	struct work_struct	rejecter;	/* packet reject writer */
-	struct work_struct	event_processor; /* endpoint event processor */
+	struct work_struct	processor;	/* endpoint packet processor */
 	struct list_head	services;	/* services listening on this endpoint */
-	struct list_head	link;		/* link in endpoint list */
 	struct rw_semaphore	defrag_sem;	/* control re-enablement of IP DF bit */
 	struct sk_buff_head	accept_queue;	/* incoming calls awaiting acceptance */
 	struct sk_buff_head	reject_queue;	/* packets awaiting rejection */
 	struct sk_buff_head	event_queue;	/* endpoint event packets awaiting processing */
+	struct mutex		conn_lock;	/* Client connection creation lock */
 	spinlock_t		lock;		/* access lock */
 	rwlock_t		services_lock;	/* lock for services list */
-	atomic_t		usage;
 	int			debug_id;	/* debug ID for printks */
 	volatile char		error_rcvd;	/* T if received ICMP error outstanding */
 	struct sockaddr_rxrpc	srx;		/* local address */
@@ -674,11 +674,25 @@ struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
 /*
  * local-object.c
  */
-extern rwlock_t rxrpc_local_lock;
+extern struct objcache rxrpc_local_cache;
 
 struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *);
-void rxrpc_put_local(struct rxrpc_local *);
-void __exit rxrpc_destroy_all_locals(void);
+
+static inline void rxrpc_get_local(struct rxrpc_local *local)
+{
+	objcache_get(&local->obj);
+}
+
+static inline
+struct rxrpc_local *rxrpc_get_local_maybe(struct rxrpc_local *local)
+{
+	return objcache_get_maybe(&local->obj) ? local : NULL;
+}
+
+static inline void rxrpc_put_local(struct rxrpc_local *local)
+{
+	objcache_put(&rxrpc_local_cache, &local->obj);
+}
 
 /*
  * sysctl.c
@@ -866,15 +880,6 @@ static inline void rxrpc_purge_queue(struct sk_buff_head *list)
 		rxrpc_free_skb(skb);
 }
 
-static inline void __rxrpc_get_local(struct rxrpc_local *local, const char *f)
-{
-	CHECK_SLAB_OKAY(&local->usage);
-	if (atomic_inc_return(&local->usage) == 1)
-		printk("resurrected (%s)\n", f);
-}
-
-#define rxrpc_get_local(LOCAL) __rxrpc_get_local((LOCAL), __func__)
-
 #define rxrpc_get_call(CALL)				\
 do {							\
 	CHECK_SLAB_OKAY(&(CALL)->usage);		\
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
index 7060995a4276..6ab0e9bfdbe8 100644
--- a/net/rxrpc/ar-local.c
+++ b/net/rxrpc/ar-local.c
@@ -82,13 +82,14 @@ static void rxrpc_send_version_request(struct rxrpc_local *local,
  */
 void rxrpc_process_local_events(struct work_struct *work)
 {
-	struct rxrpc_local *local = container_of(work, struct rxrpc_local, event_processor);
+	struct rxrpc_local *local =
+		container_of(work, struct rxrpc_local, processor);
 	struct sk_buff *skb;
 	char v;
 
 	_enter("");
 
-	atomic_inc(&local->usage);
+	rxrpc_get_local(local);
 	
 	while ((skb = skb_dequeue(&local->event_queue))) {
 		struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
diff --git a/net/rxrpc/local-object.c b/net/rxrpc/local-object.c
index 1dc701dbc715..4f44e86e70fe 100644
--- a/net/rxrpc/local-object.c
+++ b/net/rxrpc/local-object.c
@@ -19,38 +19,115 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
-static LIST_HEAD(rxrpc_locals);
-DEFINE_RWLOCK(rxrpc_local_lock);
-static DECLARE_RWSEM(rxrpc_local_sem);
-static DECLARE_WAIT_QUEUE_HEAD(rxrpc_local_wq);
+static void rxrpc_local_prepare_for_gc(struct obj_node *);
+static void rxrpc_local_gc_rcu(struct rcu_head *);
+static unsigned long rxrpc_local_hash_key(const void *);
+static int rxrpc_local_cmp_key(const struct obj_node *, const void *);
+
+static DEFINE_MUTEX(rxrpc_local_mutex);
+static struct hlist_head rxrpc_local_cache_hash[16];
+
+struct objcache rxrpc_local_cache = {
+	.name		= "locals",
+	.prepare_for_gc	= rxrpc_local_prepare_for_gc,
+	.gc_rcu		= rxrpc_local_gc_rcu,
+	.hash_key	= rxrpc_local_hash_key,
+	.cmp_key	= rxrpc_local_cmp_key,
+	.hash_table	= rxrpc_local_cache_hash,
+	.gc_delay	= 2,
+	.nr_buckets	= ARRAY_SIZE(rxrpc_local_cache_hash),
+};
 
-static void rxrpc_destroy_local(struct work_struct *work);
+/*
+ * Hash a local key.
+ */
+static unsigned long rxrpc_local_hash_key(const void *_srx)
+{
+	const struct sockaddr_rxrpc *srx = _srx;
+	const u16 *p;
+	unsigned int i, size;
+	unsigned long hash_key;
+
+	_enter("%u", srx->transport.family);
+
+	hash_key = srx->transport_type;
+	hash_key += srx->transport_len;
+	hash_key += srx->transport.family;
+
+	switch (srx->transport.family) {
+	case AF_INET:
+		hash_key += (u16 __force)srx->transport.sin.sin_port;
+		size = sizeof(srx->transport.sin.sin_addr);
+		p = (u16 *)&srx->transport.sin.sin_addr;
+		break;
+	default:
+		BUG();
+	}
+
+	/* Step through the local address in 16-bit portions for speed */
+	for (i = 0; i < size; i += sizeof(*p), p++)
+		hash_key += *p;
+
+	_leave(" = 0x%lx", hash_key);
+	return hash_key;
+}
 
 /*
- * allocate a new local
+ * Compare a local to a key.  Return -ve, 0 or +ve to indicate less than, same
+ * or greater than.
  */
-static
-struct rxrpc_local *rxrpc_alloc_local(struct sockaddr_rxrpc *srx)
+static int rxrpc_local_cmp_key(const struct obj_node *obj, const void *_srx)
+{
+	const struct rxrpc_local *local =
+		container_of(obj, struct rxrpc_local, obj);
+	const struct sockaddr_rxrpc *srx = _srx;
+	int diff;
+
+	diff = ((local->srx.transport_type - srx->transport_type) ?:
+		(local->srx.transport_len - srx->transport_len) ?:
+		(local->srx.transport.family - srx->transport.family));
+	if (diff != 0)
+		return diff;
+
+	switch (srx->transport.family) {
+	case AF_INET:
+		/* If the choice of UDP port is left up to the transport, then
+		 * the endpoint record doesn't match.
+		 */
+		return ((u16 __force)local->srx.transport.sin.sin_port -
+			(u16 __force)srx->transport.sin.sin_port) ?:
+			memcmp(&local->srx.transport.sin.sin_addr,
+			       &srx->transport.sin.sin_addr,
+			       sizeof(struct in_addr));
+	default:
+		BUG();
+	}
+}
+
+/*
+ * Allocate a new local endpoint.  This is service ID independent but rather
+ * defines a specific transport endpoint.
+ */
+static struct rxrpc_local *rxrpc_alloc_local(struct sockaddr_rxrpc *srx)
 {
 	struct rxrpc_local *local;
 
 	local = kzalloc(sizeof(struct rxrpc_local), GFP_KERNEL);
 	if (local) {
-		INIT_WORK(&local->destroyer, &rxrpc_destroy_local);
 		INIT_WORK(&local->acceptor, &rxrpc_accept_incoming_calls);
 		INIT_WORK(&local->rejecter, &rxrpc_reject_packets);
-		INIT_WORK(&local->event_processor, &rxrpc_process_local_events);
+		INIT_WORK(&local->processor, &rxrpc_process_local_events);
 		INIT_LIST_HEAD(&local->services);
-		INIT_LIST_HEAD(&local->link);
 		init_rwsem(&local->defrag_sem);
 		skb_queue_head_init(&local->accept_queue);
 		skb_queue_head_init(&local->reject_queue);
 		skb_queue_head_init(&local->event_queue);
+		mutex_init(&local->conn_lock);
 		spin_lock_init(&local->lock);
 		rwlock_init(&local->services_lock);
-		atomic_set(&local->usage, 1);
 		local->debug_id = atomic_inc_return(&rxrpc_debug_id);
 		memcpy(&local->srx, srx, sizeof(*srx));
+		local->srx.srx_service = 0;
 	}
 
 	_leave(" = %p", local);
@@ -59,9 +136,9 @@ struct rxrpc_local *rxrpc_alloc_local(struct sockaddr_rxrpc *srx)
 
 /*
  * create the local socket
- * - must be called with rxrpc_local_sem writelocked
+ * - must be called with rxrpc_local_mutex locked
  */
-static int rxrpc_create_local(struct rxrpc_local *local)
+static int rxrpc_open_socket(struct rxrpc_local *local)
 {
 	struct sock *sock;
 	int ret, opt;
@@ -80,10 +157,10 @@ static int rxrpc_create_local(struct rxrpc_local *local)
 	if (local->srx.transport_len > sizeof(sa_family_t)) {
 		_debug("bind");
 		ret = kernel_bind(local->socket,
-				  (struct sockaddr *) &local->srx.transport,
+				  (struct sockaddr *)&local->srx.transport,
 				  local->srx.transport_len);
 		if (ret < 0) {
-			_debug("bind failed");
+			_debug("bind failed %d", ret);
 			goto error;
 		}
 	}
@@ -106,10 +183,6 @@ static int rxrpc_create_local(struct rxrpc_local *local)
 		goto error;
 	}
 
-	write_lock_bh(&rxrpc_local_lock);
-	list_add(&local->link, &rxrpc_locals);
-	write_unlock_bh(&rxrpc_local_lock);
-
 	/* set the socket up */
 	sock = local->socket->sk;
 	sock->sk_user_data	= local;
@@ -129,71 +202,53 @@ error:
 }
 
 /*
- * create a new local endpoint using the specified UDP address
+ * Look up or create a new local endpoint using the specified address.
  */
 struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *srx)
 {
 	struct rxrpc_local *local;
+	struct obj_node *obj;
+	const char *new;
 	int ret;
 
-	_enter("{%d,%u,%pI4+%hu}",
-	       srx->transport_type,
-	       srx->transport.family,
-	       &srx->transport.sin.sin_addr,
-	       ntohs(srx->transport.sin.sin_port));
-
-	down_write(&rxrpc_local_sem);
-
-	/* see if we have a suitable local local endpoint already */
-	read_lock_bh(&rxrpc_local_lock);
-
-	list_for_each_entry(local, &rxrpc_locals, link) {
-		_debug("CMP {%d,%u,%pI4+%hu}",
-		       local->srx.transport_type,
-		       local->srx.transport.family,
-		       &local->srx.transport.sin.sin_addr,
-		       ntohs(local->srx.transport.sin.sin_port));
-
-		if (local->srx.transport_type != srx->transport_type ||
-		    local->srx.transport.family != srx->transport.family)
-			continue;
-
-		switch (srx->transport.family) {
-		case AF_INET:
-			if (local->srx.transport.sin.sin_port !=
-			    srx->transport.sin.sin_port)
-				continue;
-			if (memcmp(&local->srx.transport.sin.sin_addr,
-				   &srx->transport.sin.sin_addr,
-				   sizeof(struct in_addr)) != 0)
-				continue;
-			goto found_local;
-
-		default:
-			BUG();
-		}
+	if (srx->transport.family == AF_INET) {
+		_enter("{%d,%u,%pI4+%hu}",
+		       srx->transport_type,
+		       srx->transport.family,
+		       &srx->transport.sin.sin_addr,
+		       ntohs(srx->transport.sin.sin_port));
+	} else {
+		_enter("{%d,%u}",
+		       srx->transport_type,
+		       srx->transport.family);
+		return ERR_PTR(-EAFNOSUPPORT);
 	}
 
-	read_unlock_bh(&rxrpc_local_lock);
-
-	/* we didn't find one, so we need to create one */
-	local = rxrpc_alloc_local(srx);
-	if (!local) {
-		up_write(&rxrpc_local_sem);
-		return ERR_PTR(-ENOMEM);
+	mutex_lock(&rxrpc_local_mutex);
+
+	obj = objcache_lookup_rcu(&rxrpc_local_cache, srx);
+	if (obj && objcache_get_maybe(obj)) {
+		local = container_of(obj, struct rxrpc_local, obj);
+		new = "old";
+	} else {
+		local = rxrpc_alloc_local(srx);
+		if (!local)
+			goto nomem;
+
+		ret = rxrpc_open_socket(local);
+		if (ret < 0)
+			goto sock_error;
+
+		obj = objcache_try_add(&rxrpc_local_cache, &local->obj,
+				       &local->srx);
+		BUG_ON(obj != &local->obj);
+		new = "new";
 	}
 
-	ret = rxrpc_create_local(local);
-	if (ret < 0) {
-		up_write(&rxrpc_local_sem);
-		kfree(local);
-		_leave(" = %d", ret);
-		return ERR_PTR(ret);
-	}
+	mutex_unlock(&rxrpc_local_mutex);
 
-	up_write(&rxrpc_local_sem);
-
-	_net("LOCAL new %d {%d,%u,%pI4+%hu}",
+	_net("LOCAL %s %d {%d,%u,%pI4+%hu}",
+	     new,
 	     local->debug_id,
 	     local->srx.transport_type,
 	     local->srx.transport.family,
@@ -203,114 +258,54 @@ struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *srx)
 	_leave(" = %p [new]", local);
 	return local;
 
-found_local:
-	rxrpc_get_local(local);
-	read_unlock_bh(&rxrpc_local_lock);
-	up_write(&rxrpc_local_sem);
-
-	_net("LOCAL old %d {%d,%u,%pI4+%hu}",
-	     local->debug_id,
-	     local->srx.transport_type,
-	     local->srx.transport.family,
-	     &local->srx.transport.sin.sin_addr,
-	     ntohs(local->srx.transport.sin.sin_port));
-
-	_leave(" = %p [reuse]", local);
-	return local;
+nomem:
+	ret = -ENOMEM;
+sock_error:
+	mutex_unlock(&rxrpc_local_mutex);
+	kfree(local);
+	_leave(" = %d", ret);
+	return ERR_PTR(ret);
 }
 
 /*
- * release a local endpoint
+ * Prepare to garbage collect local endpoints.  Closing the socket cannot be
+ * done from an RCU callback context because it might sleep.
  */
-void rxrpc_put_local(struct rxrpc_local *local)
+static void rxrpc_local_prepare_for_gc(struct obj_node *obj)
 {
-	_enter("%p{u=%d}", local, atomic_read(&local->usage));
-
-	ASSERTCMP(atomic_read(&local->usage), >, 0);
-
-	/* to prevent a race, the decrement and the dequeue must be effectively
-	 * atomic */
-	write_lock_bh(&rxrpc_local_lock);
-	if (unlikely(atomic_dec_and_test(&local->usage))) {
-		_debug("destroy local");
-		rxrpc_queue_work(&local->destroyer);
+	struct rxrpc_local *local = container_of(obj, struct rxrpc_local, obj);
+	struct socket *socket = local->socket;
+
+	if (socket) {
+		local->socket = NULL;
+		kernel_sock_shutdown(socket, SHUT_RDWR);
+		socket->sk->sk_user_data = NULL;
+		sock_release(socket);
 	}
-	write_unlock_bh(&rxrpc_local_lock);
-	_leave("");
 }
 
 /*
- * destroy a local endpoint
+ * Destroy a local endpoint after the RCU grace period expires.
  */
-static void rxrpc_destroy_local(struct work_struct *work)
+static void rxrpc_local_gc_rcu(struct rcu_head *rcu)
 {
-	struct rxrpc_local *local =
-		container_of(work, struct rxrpc_local, destroyer);
-
-	_enter("%p{%d}", local, atomic_read(&local->usage));
-
-	down_write(&rxrpc_local_sem);
-
-	write_lock_bh(&rxrpc_local_lock);
-	if (atomic_read(&local->usage) > 0) {
-		write_unlock_bh(&rxrpc_local_lock);
-		up_read(&rxrpc_local_sem);
-		_leave(" [resurrected]");
-		return;
-	}
-
-	list_del(&local->link);
-	local->socket->sk->sk_user_data = NULL;
-	write_unlock_bh(&rxrpc_local_lock);
+	struct rxrpc_local *local = container_of(rcu, struct rxrpc_local, obj.rcu);
 
-	downgrade_write(&rxrpc_local_sem);
+	_enter("%p", local);
 
 	ASSERT(list_empty(&local->services));
 	ASSERT(!work_pending(&local->acceptor));
 	ASSERT(!work_pending(&local->rejecter));
-	ASSERT(!work_pending(&local->event_processor));
+	ASSERT(!work_pending(&local->processor));
 
 	/* finish cleaning up the local descriptor */
 	rxrpc_purge_queue(&local->accept_queue);
 	rxrpc_purge_queue(&local->reject_queue);
 	rxrpc_purge_queue(&local->event_queue);
-	kernel_sock_shutdown(local->socket, SHUT_RDWR);
-	sock_release(local->socket);
-
-	up_read(&rxrpc_local_sem);
 
 	_net("DESTROY LOCAL %d", local->debug_id);
 	kfree(local);
 
-	if (list_empty(&rxrpc_locals))
-		wake_up_all(&rxrpc_local_wq);
-
-	_leave("");
-}
-
-/*
- * preemptively destroy all local local endpoint rather than waiting for
- * them to be destroyed
- */
-void __exit rxrpc_destroy_all_locals(void)
-{
-	DECLARE_WAITQUEUE(myself,current);
-
-	_enter("");
-
-	/* we simply have to wait for them to go away */
-	if (!list_empty(&rxrpc_locals)) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		add_wait_queue(&rxrpc_local_wq, &myself);
-
-		while (!list_empty(&rxrpc_locals)) {
-			schedule();
-			set_current_state(TASK_UNINTERRUPTIBLE);
-		}
-
-		remove_wait_queue(&rxrpc_local_wq, &myself);
-		set_current_state(TASK_RUNNING);
-	}
-
+	objcache_obj_rcu_done(&rxrpc_local_cache);
 	_leave("");
 }
