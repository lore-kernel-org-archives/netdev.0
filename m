From: David Howells <dhowells@redhat.com>
Subject: [RFC PATCH net-next] rxrpc: Support network namespacing
Date: Mon, 15 May 2017 13:56:23 +0100
Message-ID: <149485298311.11748.15143479827764414404.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43952 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753109AbdEOM4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 08:56:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support network namespacing in AF_RXRPC with the following changes:

 (1) All the local endpoint, peer and call lists, locks, counters, etc. are
     moved into the per-namespace record.

 (2) All the connection tracking is moved into the per-namespace record
     with the exception of the client connection ID tree, which is kept
     global so that connection IDs are kept unique per-machine.

     Possibly the client connection management should be kept global so
     that the number of active client connections is managed globally.
     This makes for a slightly tricky cleanup operation and starts to look
     like it ought to be control-grouped in some way.

 (3) Each namespace gets its own epoch.  This allows each network namespace
     to pretend to be a separate client machine.

     Possibly these should be kept unique per-machine also.

 (4) The /proc/net/rxrpc_xxx files are now called /proc/net/rxrpc/xxx and
     the contents reflect the namespace.

     I'm not sure sticking them in their own directory is a good idea at
     this point, though they are just info files.

fs/afs/ should be okay with this patch as it explicitly requires the current
net namespace to be init_net to permit a mount to proceed at the moment.  It
will, however, need updating so that cells, IP addresses and DNS records are
per-namespace also.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile       |    1 
 net/rxrpc/af_rxrpc.c     |   35 +++++------
 net/rxrpc/ar-internal.h  |   65 ++++++++++++++++----
 net/rxrpc/call_accept.c  |   14 ++--
 net/rxrpc/call_object.c  |   39 +++++++-----
 net/rxrpc/conn_client.c  |  153 +++++++++++++++++++++++-----------------------
 net/rxrpc/conn_object.c  |   55 ++++++++---------
 net/rxrpc/conn_service.c |   11 ++-
 net/rxrpc/local_object.c |   48 +++++++-------
 net/rxrpc/net_ns.c       |   85 ++++++++++++++++++++++++++
 net/rxrpc/peer_object.c  |   26 ++++----
 net/rxrpc/proc.c         |   40 ++++++++----
 12 files changed, 356 insertions(+), 216 deletions(-)
 create mode 100644 net/rxrpc/net_ns.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index b9da4d6b914f..9c68d2f8ba39 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -19,6 +19,7 @@ rxrpc-y := \
 	local_event.o \
 	local_object.o \
 	misc.o \
+	net_ns.o \
 	output.o \
 	peer_event.o \
 	peer_object.o \
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 7fb59c3f1542..cd34ffbff1d1 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -38,9 +38,6 @@ MODULE_PARM_DESC(debug, "RxRPC debugging mask");
 static struct proto rxrpc_proto;
 static const struct proto_ops rxrpc_rpc_ops;
 
-/* local epoch for detecting local-end reset */
-u32 rxrpc_epoch;
-
 /* current debugging ID */
 atomic_t rxrpc_debug_id;
 
@@ -155,7 +152,7 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 
 	memcpy(&rx->srx, srx, sizeof(rx->srx));
 
-	local = rxrpc_lookup_local(&rx->srx);
+	local = rxrpc_lookup_local(sock_net(sock->sk), &rx->srx);
 	if (IS_ERR(local)) {
 		ret = PTR_ERR(local);
 		goto error_unlock;
@@ -434,7 +431,7 @@ static int rxrpc_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 			ret = -EAFNOSUPPORT;
 			goto error_unlock;
 		}
-		local = rxrpc_lookup_local(&rx->srx);
+		local = rxrpc_lookup_local(sock_net(sock->sk), &rx->srx);
 		if (IS_ERR(local)) {
 			ret = PTR_ERR(local);
 			goto error_unlock;
@@ -582,9 +579,6 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 
 	_enter("%p,%d", sock, protocol);
 
-	if (!net_eq(net, &init_net))
-		return -EAFNOSUPPORT;
-
 	/* we support transport protocol UDP/UDP6 only */
 	if (protocol != PF_INET &&
 	    IS_ENABLED(CONFIG_AF_RXRPC_IPV6) && protocol != PF_INET6)
@@ -780,8 +774,6 @@ static int __init af_rxrpc_init(void)
 
 	BUILD_BUG_ON(sizeof(struct rxrpc_skb_priv) > FIELD_SIZEOF(struct sk_buff, cb));
 
-	get_random_bytes(&rxrpc_epoch, sizeof(rxrpc_epoch));
-	rxrpc_epoch |= RXRPC_RANDOM_EPOCH;
 	get_random_bytes(&tmp, sizeof(tmp));
 	tmp &= 0x3fffffff;
 	if (tmp == 0)
@@ -809,6 +801,10 @@ static int __init af_rxrpc_init(void)
 		goto error_security;
 	}
 
+	ret = register_pernet_subsys(&rxrpc_net_ops);
+	if (ret)
+		goto error_pernet;
+
 	ret = proto_register(&rxrpc_proto, 1);
 	if (ret < 0) {
 		pr_crit("Cannot register protocol\n");
@@ -839,11 +835,6 @@ static int __init af_rxrpc_init(void)
 		goto error_sysctls;
 	}
 
-#ifdef CONFIG_PROC_FS
-	proc_create("rxrpc_calls", 0, init_net.proc_net, &rxrpc_call_seq_fops);
-	proc_create("rxrpc_conns", 0, init_net.proc_net,
-		    &rxrpc_connection_seq_fops);
-#endif
 	return 0;
 
 error_sysctls:
@@ -855,6 +846,8 @@ static int __init af_rxrpc_init(void)
 error_sock:
 	proto_unregister(&rxrpc_proto);
 error_proto:
+	unregister_pernet_subsys(&rxrpc_net_ops);
+error_pernet:
 	rxrpc_exit_security();
 error_security:
 	destroy_workqueue(rxrpc_workqueue);
@@ -875,14 +868,16 @@ static void __exit af_rxrpc_exit(void)
 	unregister_key_type(&key_type_rxrpc);
 	sock_unregister(PF_RXRPC);
 	proto_unregister(&rxrpc_proto);
-	rxrpc_destroy_all_calls();
-	rxrpc_destroy_all_connections();
+	unregister_pernet_subsys(&rxrpc_net_ops);
 	ASSERTCMP(atomic_read(&rxrpc_n_tx_skbs), ==, 0);
 	ASSERTCMP(atomic_read(&rxrpc_n_rx_skbs), ==, 0);
-	rxrpc_destroy_all_locals();
 
-	remove_proc_entry("rxrpc_conns", init_net.proc_net);
-	remove_proc_entry("rxrpc_calls", init_net.proc_net);
+	/* Make sure the local and peer records pinned by any dying connections
+	 * are released.
+	 */
+	rcu_barrier();
+	rxrpc_destroy_client_conn_ids();
+
 	destroy_workqueue(rxrpc_workqueue);
 	rxrpc_exit_security();
 	kmem_cache_destroy(rxrpc_call_jar);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 7486926e60a8..067dbb3121d0 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -11,6 +11,8 @@
 
 #include <linux/atomic.h>
 #include <linux/seqlock.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <rxrpc/packet.h>
@@ -65,6 +67,37 @@ enum {
 };
 
 /*
+ * Per-network namespace data.
+ */
+struct rxrpc_net {
+	struct proc_dir_entry	*proc_net;	/* Subdir in /proc/net */
+	u32			epoch;		/* Local epoch for detecting local-end reset */
+	struct list_head	calls;		/* List of calls active in this namespace */
+	rwlock_t		call_lock;	/* Lock for ->calls */
+
+	struct list_head	conn_proc_list;	/* List of conns in this namespace for proc */
+	struct list_head	service_conns;	/* Service conns in this namespace */
+	rwlock_t		conn_lock;	/* Lock for ->conn_proc_list, ->service_conns */
+	struct delayed_work	service_conn_reaper;
+
+	unsigned int		nr_client_conns;
+	unsigned int		nr_active_client_conns;
+	bool			kill_all_client_conns;
+	spinlock_t		client_conn_cache_lock; /* Lock for ->*_client_conns */
+	spinlock_t		client_conn_discard_lock; /* Prevent multiple discarders */
+	struct list_head	waiting_client_conns;
+	struct list_head	active_client_conns;
+	struct list_head	idle_client_conns;
+	struct delayed_work	client_conn_reaper;
+
+	struct list_head	local_endpoints;
+	struct mutex		local_mutex;	/* Lock for ->local_endpoints */
+
+	spinlock_t		peer_hash_lock;	/* Lock for ->peer_hash */
+	DECLARE_HASHTABLE	(peer_hash, 10);
+};
+
+/*
  * Service backlog preallocation.
  *
  * This contains circular buffers of preallocated peers, connections and calls
@@ -211,6 +244,7 @@ struct rxrpc_security {
 struct rxrpc_local {
 	struct rcu_head		rcu;
 	atomic_t		usage;
+	struct rxrpc_net	*rxnet;		/* The network ns in which this resides */
 	struct list_head	link;
 	struct socket		*socket;	/* my UDP socket */
 	struct work_struct	processor;
@@ -601,7 +635,6 @@ struct rxrpc_ack_summary {
  * af_rxrpc.c
  */
 extern atomic_t rxrpc_n_tx_skbs, rxrpc_n_rx_skbs;
-extern u32 rxrpc_epoch;
 extern atomic_t rxrpc_debug_id;
 extern struct workqueue_struct *rxrpc_workqueue;
 
@@ -634,8 +667,6 @@ extern const char *const rxrpc_call_states[];
 extern const char *const rxrpc_call_completions[];
 extern unsigned int rxrpc_max_call_lifetime;
 extern struct kmem_cache *rxrpc_call_jar;
-extern struct list_head rxrpc_calls;
-extern rwlock_t rxrpc_call_lock;
 
 struct rxrpc_call *rxrpc_find_call_by_user_ID(struct rxrpc_sock *, unsigned long);
 struct rxrpc_call *rxrpc_alloc_call(gfp_t);
@@ -653,7 +684,7 @@ void rxrpc_see_call(struct rxrpc_call *);
 void rxrpc_get_call(struct rxrpc_call *, enum rxrpc_call_trace);
 void rxrpc_put_call(struct rxrpc_call *, enum rxrpc_call_trace);
 void rxrpc_cleanup_call(struct rxrpc_call *);
-void __exit rxrpc_destroy_all_calls(void);
+void rxrpc_destroy_all_calls(struct rxrpc_net *);
 
 static inline bool rxrpc_is_service_call(const struct rxrpc_call *call)
 {
@@ -773,7 +804,8 @@ int rxrpc_connect_call(struct rxrpc_call *, struct rxrpc_conn_parameters *,
 void rxrpc_expose_client_call(struct rxrpc_call *);
 void rxrpc_disconnect_client_call(struct rxrpc_call *);
 void rxrpc_put_client_conn(struct rxrpc_connection *);
-void __exit rxrpc_destroy_all_client_connections(void);
+void rxrpc_discard_expired_client_conns(struct work_struct *);
+void rxrpc_destroy_all_client_connections(struct rxrpc_net *);
 
 /*
  * conn_event.c
@@ -784,9 +816,6 @@ void rxrpc_process_connection(struct work_struct *);
  * conn_object.c
  */
 extern unsigned int rxrpc_connection_expiry;
-extern struct list_head rxrpc_connections;
-extern struct list_head rxrpc_connection_proc_list;
-extern rwlock_t rxrpc_connection_lock;
 
 int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *, struct sk_buff *);
 struct rxrpc_connection *rxrpc_alloc_connection(gfp_t);
@@ -800,7 +829,8 @@ void rxrpc_see_connection(struct rxrpc_connection *);
 void rxrpc_get_connection(struct rxrpc_connection *);
 struct rxrpc_connection *rxrpc_get_connection_maybe(struct rxrpc_connection *);
 void rxrpc_put_service_conn(struct rxrpc_connection *);
-void __exit rxrpc_destroy_all_connections(void);
+void rxrpc_service_connection_reaper(struct work_struct *);
+void rxrpc_destroy_all_connections(struct rxrpc_net *);
 
 static inline bool rxrpc_conn_is_client(const struct rxrpc_connection *conn)
 {
@@ -828,7 +858,7 @@ static inline void rxrpc_put_connection(struct rxrpc_connection *conn)
  */
 struct rxrpc_connection *rxrpc_find_service_conn_rcu(struct rxrpc_peer *,
 						     struct sk_buff *);
-struct rxrpc_connection *rxrpc_prealloc_service_connection(gfp_t);
+struct rxrpc_connection *rxrpc_prealloc_service_connection(struct rxrpc_net *, gfp_t);
 void rxrpc_new_incoming_connection(struct rxrpc_connection *, struct sk_buff *);
 void rxrpc_unpublish_service_conn(struct rxrpc_connection *);
 
@@ -861,9 +891,9 @@ extern void rxrpc_process_local_events(struct rxrpc_local *);
 /*
  * local_object.c
  */
-struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *);
+struct rxrpc_local *rxrpc_lookup_local(struct net *, const struct sockaddr_rxrpc *);
 void __rxrpc_put_local(struct rxrpc_local *);
-void __exit rxrpc_destroy_all_locals(void);
+void rxrpc_destroy_all_locals(struct rxrpc_net *);
 
 static inline void rxrpc_get_local(struct rxrpc_local *local)
 {
@@ -902,6 +932,17 @@ extern unsigned int rxrpc_resend_timeout;
 extern const s8 rxrpc_ack_priority[];
 
 /*
+ * net_ns.c
+ */
+extern unsigned int rxrpc_net_id;
+extern struct pernet_operations rxrpc_net_ops;
+
+static inline struct rxrpc_net *rxrpc_net(struct net *net)
+{
+	return net_generic(net, rxrpc_net_id);
+}
+
+/*
  * output.c
  */
 int rxrpc_send_ack_packet(struct rxrpc_call *, bool);
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 1752fcf8e8f1..a8515b0d4717 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -38,6 +38,7 @@ static int rxrpc_service_prealloc_one(struct rxrpc_sock *rx,
 {
 	const void *here = __builtin_return_address(0);
 	struct rxrpc_call *call;
+	struct rxrpc_net *rxnet = rxrpc_net(sock_net(&rx->sk));
 	int max, tmp;
 	unsigned int size = RXRPC_BACKLOG_MAX;
 	unsigned int head, tail, call_head, call_tail;
@@ -79,7 +80,7 @@ static int rxrpc_service_prealloc_one(struct rxrpc_sock *rx,
 	if (CIRC_CNT(head, tail, size) < max) {
 		struct rxrpc_connection *conn;
 
-		conn = rxrpc_prealloc_service_connection(gfp);
+		conn = rxrpc_prealloc_service_connection(rxnet, gfp);
 		if (!conn)
 			return -ENOMEM;
 		b->conn_backlog[head] = conn;
@@ -136,9 +137,9 @@ static int rxrpc_service_prealloc_one(struct rxrpc_sock *rx,
 
 	write_unlock(&rx->call_lock);
 
-	write_lock(&rxrpc_call_lock);
-	list_add_tail(&call->link, &rxrpc_calls);
-	write_unlock(&rxrpc_call_lock);
+	write_lock(&rxnet->call_lock);
+	list_add_tail(&call->link, &rxnet->calls);
+	write_unlock(&rxnet->call_lock);
 
 	b->call_backlog[call_head] = call;
 	smp_store_release(&b->call_backlog_head, (call_head + 1) & (size - 1));
@@ -185,6 +186,7 @@ int rxrpc_service_prealloc(struct rxrpc_sock *rx, gfp_t gfp)
 void rxrpc_discard_prealloc(struct rxrpc_sock *rx)
 {
 	struct rxrpc_backlog *b = rx->backlog;
+	struct rxrpc_net *rxnet = rxrpc_net(sock_net(&rx->sk));
 	unsigned int size = RXRPC_BACKLOG_MAX, head, tail;
 
 	if (!b)
@@ -209,10 +211,10 @@ void rxrpc_discard_prealloc(struct rxrpc_sock *rx)
 	tail = b->conn_backlog_tail;
 	while (CIRC_CNT(head, tail, size) > 0) {
 		struct rxrpc_connection *conn = b->conn_backlog[tail];
-		write_lock(&rxrpc_connection_lock);
+		write_lock(&rxnet->conn_lock);
 		list_del(&conn->link);
 		list_del(&conn->proc_link);
-		write_unlock(&rxrpc_connection_lock);
+		write_unlock(&rxnet->conn_lock);
 		kfree(conn);
 		tail = (tail + 1) & (size - 1);
 	}
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 47f7f4205653..692110808baa 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -44,8 +44,6 @@ const char *const rxrpc_call_completions[NR__RXRPC_CALL_COMPLETIONS] = {
 };
 
 struct kmem_cache *rxrpc_call_jar;
-LIST_HEAD(rxrpc_calls);
-DEFINE_RWLOCK(rxrpc_call_lock);
 
 static void rxrpc_call_timer_expired(unsigned long _call)
 {
@@ -207,6 +205,7 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 	__releases(&rx->sk.sk_lock.slock)
 {
 	struct rxrpc_call *call, *xcall;
+	struct rxrpc_net *rxnet = rxrpc_net(sock_net(&rx->sk));
 	struct rb_node *parent, **pp;
 	const void *here = __builtin_return_address(0);
 	int ret;
@@ -255,9 +254,9 @@ struct rxrpc_call *rxrpc_new_client_call(struct rxrpc_sock *rx,
 
 	write_unlock(&rx->call_lock);
 
-	write_lock(&rxrpc_call_lock);
-	list_add_tail(&call->link, &rxrpc_calls);
-	write_unlock(&rxrpc_call_lock);
+	write_lock(&rxnet->call_lock);
+	list_add_tail(&call->link, &rxnet->calls);
+	write_unlock(&rxnet->call_lock);
 
 	/* From this point on, the call is protected by its own lock. */
 	release_sock(&rx->sk);
@@ -508,6 +507,7 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *rx)
  */
 void rxrpc_put_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
 {
+	struct rxrpc_net *rxnet;
 	const void *here = __builtin_return_address(0);
 	int n;
 
@@ -520,9 +520,12 @@ void rxrpc_put_call(struct rxrpc_call *call, enum rxrpc_call_trace op)
 		_debug("call %d dead", call->debug_id);
 		ASSERTCMP(call->state, ==, RXRPC_CALL_COMPLETE);
 
-		write_lock(&rxrpc_call_lock);
-		list_del_init(&call->link);
-		write_unlock(&rxrpc_call_lock);
+		if (!list_empty(&call->link)) {
+			rxnet = rxrpc_net(sock_net(&call->socket->sk));
+			write_lock(&rxnet->call_lock);
+			list_del_init(&call->link);
+			write_unlock(&rxnet->call_lock);
+		}
 
 		rxrpc_cleanup_call(call);
 	}
@@ -570,21 +573,23 @@ void rxrpc_cleanup_call(struct rxrpc_call *call)
 }
 
 /*
- * Make sure that all calls are gone.
+ * Make sure that all calls are gone from a network namespace.  To reach this
+ * point, any open UDP sockets in that namespace must have been closed, so any
+ * outstanding calls cannot be doing I/O.
  */
-void __exit rxrpc_destroy_all_calls(void)
+void rxrpc_destroy_all_calls(struct rxrpc_net *rxnet)
 {
 	struct rxrpc_call *call;
 
 	_enter("");
 
-	if (list_empty(&rxrpc_calls))
+	if (list_empty(&rxnet->calls))
 		return;
 
-	write_lock(&rxrpc_call_lock);
+	write_lock(&rxnet->call_lock);
 
-	while (!list_empty(&rxrpc_calls)) {
-		call = list_entry(rxrpc_calls.next, struct rxrpc_call, link);
+	while (!list_empty(&rxnet->calls)) {
+		call = list_entry(rxnet->calls.next, struct rxrpc_call, link);
 		_debug("Zapping call %p", call);
 
 		rxrpc_see_call(call);
@@ -595,10 +600,10 @@ void __exit rxrpc_destroy_all_calls(void)
 		       rxrpc_call_states[call->state],
 		       call->flags, call->events);
 
-		write_unlock(&rxrpc_call_lock);
+		write_unlock(&rxnet->call_lock);
 		cond_resched();
-		write_lock(&rxrpc_call_lock);
+		write_lock(&rxnet->call_lock);
 	}
 
-	write_unlock(&rxrpc_call_lock);
+	write_unlock(&rxnet->call_lock);
 }
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index e8dea0d49e7f..c86f3202f967 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -31,7 +31,7 @@
  *      may freely grant available channels to new calls and calls may be
  *      waiting on it for channels to become available.
  *
- *	The connection is on the rxrpc_active_client_conns list which is kept
+ *	The connection is on the rxnet->active_client_conns list which is kept
  *	in activation order for culling purposes.
  *
  *	rxrpc_nr_active_client_conns is held incremented also.
@@ -46,7 +46,7 @@
  *      expires, the EXPOSED flag is cleared and the connection transitions to
  *      the INACTIVE state.
  *
- *	The connection is on the rxrpc_idle_client_conns list which is kept in
+ *	The connection is on the rxnet->idle_client_conns list which is kept in
  *	order of how soon they'll expire.
  *
  * There are flags of relevance to the cache:
@@ -85,27 +85,13 @@ __read_mostly unsigned int rxrpc_reap_client_connections = 900;
 __read_mostly unsigned int rxrpc_conn_idle_client_expiry = 2 * 60 * HZ;
 __read_mostly unsigned int rxrpc_conn_idle_client_fast_expiry = 2 * HZ;
 
-static unsigned int rxrpc_nr_client_conns;
-static unsigned int rxrpc_nr_active_client_conns;
-static __read_mostly bool rxrpc_kill_all_client_conns;
-
-static DEFINE_SPINLOCK(rxrpc_client_conn_cache_lock);
-static DEFINE_SPINLOCK(rxrpc_client_conn_discard_mutex);
-static LIST_HEAD(rxrpc_waiting_client_conns);
-static LIST_HEAD(rxrpc_active_client_conns);
-static LIST_HEAD(rxrpc_idle_client_conns);
-
 /*
  * We use machine-unique IDs for our client connections.
  */
 DEFINE_IDR(rxrpc_client_conn_ids);
 static DEFINE_SPINLOCK(rxrpc_conn_id_lock);
 
-static void rxrpc_cull_active_client_conns(void);
-static void rxrpc_discard_expired_client_conns(struct work_struct *);
-
-static DECLARE_DELAYED_WORK(rxrpc_client_conn_reap,
-			    rxrpc_discard_expired_client_conns);
+static void rxrpc_cull_active_client_conns(struct rxrpc_net *);
 
 /*
  * Get a connection ID and epoch for a client connection from the global pool.
@@ -116,6 +102,7 @@ static DECLARE_DELAYED_WORK(rxrpc_client_conn_reap,
 static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 					  gfp_t gfp)
 {
+	struct rxrpc_net *rxnet = conn->params.local->rxnet;
 	int id;
 
 	_enter("");
@@ -131,7 +118,7 @@ static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 	spin_unlock(&rxrpc_conn_id_lock);
 	idr_preload_end();
 
-	conn->proto.epoch = rxrpc_epoch;
+	conn->proto.epoch = rxnet->epoch;
 	conn->proto.cid = id << RXRPC_CIDSHIFT;
 	set_bit(RXRPC_CONN_HAS_IDR, &conn->flags);
 	_leave(" [CID %x]", conn->proto.cid);
@@ -183,6 +170,7 @@ static struct rxrpc_connection *
 rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 {
 	struct rxrpc_connection *conn;
+	struct rxrpc_net *rxnet = cp->local->rxnet;
 	int ret;
 
 	_enter("");
@@ -213,9 +201,9 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 	if (ret < 0)
 		goto error_2;
 
-	write_lock(&rxrpc_connection_lock);
-	list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
-	write_unlock(&rxrpc_connection_lock);
+	write_lock(&rxnet->conn_lock);
+	list_add_tail(&conn->proc_link, &rxnet->conn_proc_list);
+	write_unlock(&rxnet->conn_lock);
 
 	/* We steal the caller's peer ref. */
 	cp->peer = NULL;
@@ -243,12 +231,13 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
  */
 static bool rxrpc_may_reuse_conn(struct rxrpc_connection *conn)
 {
+	struct rxrpc_net *rxnet = conn->params.local->rxnet;
 	int id_cursor, id, distance, limit;
 
 	if (test_bit(RXRPC_CONN_DONT_REUSE, &conn->flags))
 		goto dont_reuse;
 
-	if (conn->proto.epoch != rxrpc_epoch)
+	if (conn->proto.epoch != rxnet->epoch)
 		goto mark_dont_reuse;
 
 	/* The IDR tree gets very expensive on memory if the connection IDs are
@@ -440,12 +429,13 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 /*
  * Activate a connection.
  */
-static void rxrpc_activate_conn(struct rxrpc_connection *conn)
+static void rxrpc_activate_conn(struct rxrpc_net *rxnet,
+				struct rxrpc_connection *conn)
 {
 	trace_rxrpc_client(conn, -1, rxrpc_client_to_active);
 	conn->cache_state = RXRPC_CONN_CLIENT_ACTIVE;
-	rxrpc_nr_active_client_conns++;
-	list_move_tail(&conn->cache_link, &rxrpc_active_client_conns);
+	rxnet->nr_active_client_conns++;
+	list_move_tail(&conn->cache_link, &rxnet->active_client_conns);
 }
 
 /*
@@ -460,7 +450,8 @@ static void rxrpc_activate_conn(struct rxrpc_connection *conn)
  * channels if it has been culled to make space and then re-requested by a new
  * call.
  */
-static void rxrpc_animate_client_conn(struct rxrpc_connection *conn)
+static void rxrpc_animate_client_conn(struct rxrpc_net *rxnet,
+				      struct rxrpc_connection *conn)
 {
 	unsigned int nr_conns;
 
@@ -469,12 +460,12 @@ static void rxrpc_animate_client_conn(struct rxrpc_connection *conn)
 	if (conn->cache_state == RXRPC_CONN_CLIENT_ACTIVE)
 		goto out;
 
-	spin_lock(&rxrpc_client_conn_cache_lock);
+	spin_lock(&rxnet->client_conn_cache_lock);
 
-	nr_conns = rxrpc_nr_client_conns;
+	nr_conns = rxnet->nr_client_conns;
 	if (!test_and_set_bit(RXRPC_CONN_COUNTED, &conn->flags)) {
 		trace_rxrpc_client(conn, -1, rxrpc_client_count);
-		rxrpc_nr_client_conns = nr_conns + 1;
+		rxnet->nr_client_conns = nr_conns + 1;
 	}
 
 	switch (conn->cache_state) {
@@ -494,21 +485,21 @@ static void rxrpc_animate_client_conn(struct rxrpc_connection *conn)
 	}
 
 out_unlock:
-	spin_unlock(&rxrpc_client_conn_cache_lock);
+	spin_unlock(&rxnet->client_conn_cache_lock);
 out:
 	_leave(" [%d]", conn->cache_state);
 	return;
 
 activate_conn:
 	_debug("activate");
-	rxrpc_activate_conn(conn);
+	rxrpc_activate_conn(rxnet, conn);
 	goto out_unlock;
 
 wait_for_capacity:
 	_debug("wait");
 	trace_rxrpc_client(conn, -1, rxrpc_client_to_waiting);
 	conn->cache_state = RXRPC_CONN_CLIENT_WAITING;
-	list_move_tail(&conn->cache_link, &rxrpc_waiting_client_conns);
+	list_move_tail(&conn->cache_link, &rxnet->waiting_client_conns);
 	goto out_unlock;
 }
 
@@ -660,18 +651,19 @@ int rxrpc_connect_call(struct rxrpc_call *call,
 		       struct sockaddr_rxrpc *srx,
 		       gfp_t gfp)
 {
+	struct rxrpc_net *rxnet = cp->local->rxnet;
 	int ret;
 
 	_enter("{%d,%lx},", call->debug_id, call->user_call_ID);
 
-	rxrpc_discard_expired_client_conns(NULL);
-	rxrpc_cull_active_client_conns();
+	rxrpc_discard_expired_client_conns(&rxnet->client_conn_reaper.work);
+	rxrpc_cull_active_client_conns(rxnet);
 
 	ret = rxrpc_get_client_conn(call, cp, srx, gfp);
 	if (ret < 0)
 		return ret;
 
-	rxrpc_animate_client_conn(call->conn);
+	rxrpc_animate_client_conn(rxnet, call->conn);
 	rxrpc_activate_channels(call->conn);
 
 	ret = rxrpc_wait_for_channel(call, gfp);
@@ -729,6 +721,7 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 	unsigned int channel = call->cid & RXRPC_CHANNELMASK;
 	struct rxrpc_connection *conn = call->conn;
 	struct rxrpc_channel *chan = &conn->channels[channel];
+	struct rxrpc_net *rxnet = rxrpc_net(sock_net(&call->socket->sk));
 
 	trace_rxrpc_client(conn, channel, rxrpc_client_chan_disconnect);
 	call->conn = NULL;
@@ -750,7 +743,7 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 		/* We must deactivate or idle the connection if it's now
 		 * waiting for nothing.
 		 */
-		spin_lock(&rxrpc_client_conn_cache_lock);
+		spin_lock(&rxnet->client_conn_cache_lock);
 		if (conn->cache_state == RXRPC_CONN_CLIENT_WAITING &&
 		    list_empty(&conn->waiting_calls) &&
 		    !conn->active_chans)
@@ -787,14 +780,14 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 	 * list.  It might even get moved back to the active list whilst we're
 	 * waiting for the lock.
 	 */
-	spin_lock(&rxrpc_client_conn_cache_lock);
+	spin_lock(&rxnet->client_conn_cache_lock);
 
 	switch (conn->cache_state) {
 	case RXRPC_CONN_CLIENT_ACTIVE:
 		if (list_empty(&conn->waiting_calls)) {
 			rxrpc_deactivate_one_channel(conn, channel);
 			if (!conn->active_chans) {
-				rxrpc_nr_active_client_conns--;
+				rxnet->nr_active_client_conns--;
 				goto idle_connection;
 			}
 			goto out;
@@ -820,7 +813,7 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 	}
 
 out:
-	spin_unlock(&rxrpc_client_conn_cache_lock);
+	spin_unlock(&rxnet->client_conn_cache_lock);
 out_2:
 	spin_unlock(&conn->channel_lock);
 	rxrpc_put_connection(conn);
@@ -835,11 +828,11 @@ void rxrpc_disconnect_client_call(struct rxrpc_call *call)
 		trace_rxrpc_client(conn, channel, rxrpc_client_to_idle);
 		conn->idle_timestamp = jiffies;
 		conn->cache_state = RXRPC_CONN_CLIENT_IDLE;
-		list_move_tail(&conn->cache_link, &rxrpc_idle_client_conns);
-		if (rxrpc_idle_client_conns.next == &conn->cache_link &&
-		    !rxrpc_kill_all_client_conns)
+		list_move_tail(&conn->cache_link, &rxnet->idle_client_conns);
+		if (rxnet->idle_client_conns.next == &conn->cache_link &&
+		    !rxnet->kill_all_client_conns)
 			queue_delayed_work(rxrpc_workqueue,
-					   &rxrpc_client_conn_reap,
+					   &rxnet->client_conn_reaper,
 					   rxrpc_conn_idle_client_expiry);
 	} else {
 		trace_rxrpc_client(conn, channel, rxrpc_client_to_inactive);
@@ -857,6 +850,7 @@ rxrpc_put_one_client_conn(struct rxrpc_connection *conn)
 {
 	struct rxrpc_connection *next = NULL;
 	struct rxrpc_local *local = conn->params.local;
+	struct rxrpc_net *rxnet = local->rxnet;
 	unsigned int nr_conns;
 
 	trace_rxrpc_client(conn, -1, rxrpc_client_cleanup);
@@ -875,18 +869,18 @@ rxrpc_put_one_client_conn(struct rxrpc_connection *conn)
 
 	if (test_bit(RXRPC_CONN_COUNTED, &conn->flags)) {
 		trace_rxrpc_client(conn, -1, rxrpc_client_uncount);
-		spin_lock(&rxrpc_client_conn_cache_lock);
-		nr_conns = --rxrpc_nr_client_conns;
+		spin_lock(&rxnet->client_conn_cache_lock);
+		nr_conns = --rxnet->nr_client_conns;
 
 		if (nr_conns < rxrpc_max_client_connections &&
-		    !list_empty(&rxrpc_waiting_client_conns)) {
-			next = list_entry(rxrpc_waiting_client_conns.next,
+		    !list_empty(&rxnet->waiting_client_conns)) {
+			next = list_entry(rxnet->waiting_client_conns.next,
 					  struct rxrpc_connection, cache_link);
 			rxrpc_get_connection(next);
-			rxrpc_activate_conn(next);
+			rxrpc_activate_conn(rxnet, next);
 		}
 
-		spin_unlock(&rxrpc_client_conn_cache_lock);
+		spin_unlock(&rxnet->client_conn_cache_lock);
 	}
 
 	rxrpc_kill_connection(conn);
@@ -921,10 +915,10 @@ void rxrpc_put_client_conn(struct rxrpc_connection *conn)
 /*
  * Kill the longest-active client connections to make room for new ones.
  */
-static void rxrpc_cull_active_client_conns(void)
+static void rxrpc_cull_active_client_conns(struct rxrpc_net *rxnet)
 {
 	struct rxrpc_connection *conn;
-	unsigned int nr_conns = rxrpc_nr_client_conns;
+	unsigned int nr_conns = rxnet->nr_client_conns;
 	unsigned int nr_active, limit;
 
 	_enter("");
@@ -936,12 +930,12 @@ static void rxrpc_cull_active_client_conns(void)
 	}
 	limit = rxrpc_reap_client_connections;
 
-	spin_lock(&rxrpc_client_conn_cache_lock);
-	nr_active = rxrpc_nr_active_client_conns;
+	spin_lock(&rxnet->client_conn_cache_lock);
+	nr_active = rxnet->nr_active_client_conns;
 
 	while (nr_active > limit) {
-		ASSERT(!list_empty(&rxrpc_active_client_conns));
-		conn = list_entry(rxrpc_active_client_conns.next,
+		ASSERT(!list_empty(&rxnet->active_client_conns));
+		conn = list_entry(rxnet->active_client_conns.next,
 				  struct rxrpc_connection, cache_link);
 		ASSERTCMP(conn->cache_state, ==, RXRPC_CONN_CLIENT_ACTIVE);
 
@@ -953,14 +947,14 @@ static void rxrpc_cull_active_client_conns(void)
 			trace_rxrpc_client(conn, -1, rxrpc_client_to_waiting);
 			conn->cache_state = RXRPC_CONN_CLIENT_WAITING;
 			list_move_tail(&conn->cache_link,
-				       &rxrpc_waiting_client_conns);
+				       &rxnet->waiting_client_conns);
 		}
 
 		nr_active--;
 	}
 
-	rxrpc_nr_active_client_conns = nr_active;
-	spin_unlock(&rxrpc_client_conn_cache_lock);
+	rxnet->nr_active_client_conns = nr_active;
+	spin_unlock(&rxnet->client_conn_cache_lock);
 	ASSERTCMP(nr_active, >=, 0);
 	_leave(" [culled]");
 }
@@ -972,22 +966,25 @@ static void rxrpc_cull_active_client_conns(void)
  * This may be called from conn setup or from a work item so cannot be
  * considered non-reentrant.
  */
-static void rxrpc_discard_expired_client_conns(struct work_struct *work)
+void rxrpc_discard_expired_client_conns(struct work_struct *work)
 {
 	struct rxrpc_connection *conn;
+	struct rxrpc_net *rxnet =
+		container_of(to_delayed_work(work),
+			     struct rxrpc_net, client_conn_reaper);
 	unsigned long expiry, conn_expires_at, now;
 	unsigned int nr_conns;
 	bool did_discard = false;
 
-	_enter("%c", work ? 'w' : 'n');
+	_enter("");
 
-	if (list_empty(&rxrpc_idle_client_conns)) {
+	if (list_empty(&rxnet->idle_client_conns)) {
 		_leave(" [empty]");
 		return;
 	}
 
 	/* Don't double up on the discarding */
-	if (!spin_trylock(&rxrpc_client_conn_discard_mutex)) {
+	if (!spin_trylock(&rxnet->client_conn_discard_lock)) {
 		_leave(" [already]");
 		return;
 	}
@@ -995,19 +992,19 @@ static void rxrpc_discard_expired_client_conns(struct work_struct *work)
 	/* We keep an estimate of what the number of conns ought to be after
 	 * we've discarded some so that we don't overdo the discarding.
 	 */
-	nr_conns = rxrpc_nr_client_conns;
+	nr_conns = rxnet->nr_client_conns;
 
 next:
-	spin_lock(&rxrpc_client_conn_cache_lock);
+	spin_lock(&rxnet->client_conn_cache_lock);
 
-	if (list_empty(&rxrpc_idle_client_conns))
+	if (list_empty(&rxnet->idle_client_conns))
 		goto out;
 
-	conn = list_entry(rxrpc_idle_client_conns.next,
+	conn = list_entry(rxnet->idle_client_conns.next,
 			  struct rxrpc_connection, cache_link);
 	ASSERT(test_bit(RXRPC_CONN_EXPOSED, &conn->flags));
 
-	if (!rxrpc_kill_all_client_conns) {
+	if (!rxnet->kill_all_client_conns) {
 		/* If the number of connections is over the reap limit, we
 		 * expedite discard by reducing the expiry timeout.  We must,
 		 * however, have at least a short grace period to be able to do
@@ -1030,7 +1027,7 @@ static void rxrpc_discard_expired_client_conns(struct work_struct *work)
 	conn->cache_state = RXRPC_CONN_CLIENT_INACTIVE;
 	list_del_init(&conn->cache_link);
 
-	spin_unlock(&rxrpc_client_conn_cache_lock);
+	spin_unlock(&rxnet->client_conn_cache_lock);
 
 	/* When we cleared the EXPOSED flag, we took on responsibility for the
 	 * reference that that had on the usage count.  We deal with that here.
@@ -1050,14 +1047,14 @@ static void rxrpc_discard_expired_client_conns(struct work_struct *work)
 	 * then things get messier.
 	 */
 	_debug("not yet");
-	if (!rxrpc_kill_all_client_conns)
+	if (!rxnet->kill_all_client_conns)
 		queue_delayed_work(rxrpc_workqueue,
-				   &rxrpc_client_conn_reap,
+				   &rxnet->client_conn_reaper,
 				   conn_expires_at - now);
 
 out:
-	spin_unlock(&rxrpc_client_conn_cache_lock);
-	spin_unlock(&rxrpc_client_conn_discard_mutex);
+	spin_unlock(&rxnet->client_conn_cache_lock);
+	spin_unlock(&rxnet->client_conn_discard_lock);
 	_leave("");
 }
 
@@ -1065,17 +1062,17 @@ static void rxrpc_discard_expired_client_conns(struct work_struct *work)
  * Preemptively destroy all the client connection records rather than waiting
  * for them to time out
  */
-void __exit rxrpc_destroy_all_client_connections(void)
+void rxrpc_destroy_all_client_connections(struct rxrpc_net *rxnet)
 {
 	_enter("");
 
-	spin_lock(&rxrpc_client_conn_cache_lock);
-	rxrpc_kill_all_client_conns = true;
-	spin_unlock(&rxrpc_client_conn_cache_lock);
+	spin_lock(&rxnet->client_conn_cache_lock);
+	rxnet->kill_all_client_conns = true;
+	spin_unlock(&rxnet->client_conn_cache_lock);
 
-	cancel_delayed_work(&rxrpc_client_conn_reap);
+	cancel_delayed_work(&rxnet->client_conn_reaper);
 
-	if (!queue_delayed_work(rxrpc_workqueue, &rxrpc_client_conn_reap, 0))
+	if (!queue_delayed_work(rxrpc_workqueue, &rxnet->client_conn_reaper, 0))
 		_debug("destroy: queue failed");
 
 	_leave("");
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index b0ecb770fdce..ade4d3d0b2a7 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -22,13 +22,6 @@
  */
 unsigned int rxrpc_connection_expiry = 10 * 60;
 
-static void rxrpc_connection_reaper(struct work_struct *work);
-
-LIST_HEAD(rxrpc_connections);
-LIST_HEAD(rxrpc_connection_proc_list);
-DEFINE_RWLOCK(rxrpc_connection_lock);
-static DECLARE_DELAYED_WORK(rxrpc_connection_reap, rxrpc_connection_reaper);
-
 static void rxrpc_destroy_connection(struct rcu_head *);
 
 /*
@@ -222,15 +215,17 @@ void rxrpc_disconnect_call(struct rxrpc_call *call)
  */
 void rxrpc_kill_connection(struct rxrpc_connection *conn)
 {
+	struct rxrpc_net *rxnet = conn->params.local->rxnet;
+
 	ASSERT(!rcu_access_pointer(conn->channels[0].call) &&
 	       !rcu_access_pointer(conn->channels[1].call) &&
 	       !rcu_access_pointer(conn->channels[2].call) &&
 	       !rcu_access_pointer(conn->channels[3].call));
 	ASSERT(list_empty(&conn->cache_link));
 
-	write_lock(&rxrpc_connection_lock);
+	write_lock(&rxnet->conn_lock);
 	list_del_init(&conn->proc_link);
-	write_unlock(&rxrpc_connection_lock);
+	write_unlock(&rxnet->conn_lock);
 
 	/* Drain the Rx queue.  Note that even though we've unpublished, an
 	 * incoming packet could still be being added to our Rx queue, so we
@@ -309,14 +304,17 @@ rxrpc_get_connection_maybe(struct rxrpc_connection *conn)
  */
 void rxrpc_put_service_conn(struct rxrpc_connection *conn)
 {
+	struct rxrpc_net *rxnet;
 	const void *here = __builtin_return_address(0);
 	int n;
 
 	n = atomic_dec_return(&conn->usage);
 	trace_rxrpc_conn(conn, rxrpc_conn_put_service, n, here);
 	ASSERTCMP(n, >=, 0);
-	if (n == 0)
-		rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
+	if (n == 0) {
+		rxnet = conn->params.local->rxnet;
+		rxrpc_queue_delayed_work(&rxnet->service_conn_reaper, 0);
+	}
 }
 
 /*
@@ -348,9 +346,12 @@ static void rxrpc_destroy_connection(struct rcu_head *rcu)
 /*
  * reap dead service connections
  */
-static void rxrpc_connection_reaper(struct work_struct *work)
+void rxrpc_service_connection_reaper(struct work_struct *work)
 {
 	struct rxrpc_connection *conn, *_p;
+	struct rxrpc_net *rxnet =
+		container_of(to_delayed_work(work),
+			     struct rxrpc_net, service_conn_reaper);
 	unsigned long reap_older_than, earliest, idle_timestamp, now;
 
 	LIST_HEAD(graveyard);
@@ -361,8 +362,8 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 	reap_older_than = now - rxrpc_connection_expiry * HZ;
 	earliest = ULONG_MAX;
 
-	write_lock(&rxrpc_connection_lock);
-	list_for_each_entry_safe(conn, _p, &rxrpc_connections, link) {
+	write_lock(&rxnet->conn_lock);
+	list_for_each_entry_safe(conn, _p, &rxnet->service_conns, link) {
 		ASSERTCMP(atomic_read(&conn->usage), >, 0);
 		if (likely(atomic_read(&conn->usage) > 1))
 			continue;
@@ -393,12 +394,12 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 
 		list_move_tail(&conn->link, &graveyard);
 	}
-	write_unlock(&rxrpc_connection_lock);
+	write_unlock(&rxnet->conn_lock);
 
 	if (earliest != ULONG_MAX) {
 		_debug("reschedule reaper %ld", (long) earliest - now);
 		ASSERT(time_after(earliest, now));
-		rxrpc_queue_delayed_work(&rxrpc_connection_reap,
+		rxrpc_queue_delayed_work(&rxnet->client_conn_reaper,
 					 earliest - now);
 	}
 
@@ -418,36 +419,30 @@ static void rxrpc_connection_reaper(struct work_struct *work)
  * preemptively destroy all the service connection records rather than
  * waiting for them to time out
  */
-void __exit rxrpc_destroy_all_connections(void)
+void rxrpc_destroy_all_connections(struct rxrpc_net *rxnet)
 {
 	struct rxrpc_connection *conn, *_p;
 	bool leak = false;
 
 	_enter("");
 
-	rxrpc_destroy_all_client_connections();
+	rxrpc_destroy_all_client_connections(rxnet);
 
 	rxrpc_connection_expiry = 0;
-	cancel_delayed_work(&rxrpc_connection_reap);
-	rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
+	cancel_delayed_work(&rxnet->client_conn_reaper);
+	rxrpc_queue_delayed_work(&rxnet->client_conn_reaper, 0);
 	flush_workqueue(rxrpc_workqueue);
 
-	write_lock(&rxrpc_connection_lock);
-	list_for_each_entry_safe(conn, _p, &rxrpc_connections, link) {
+	write_lock(&rxnet->conn_lock);
+	list_for_each_entry_safe(conn, _p, &rxnet->service_conns, link) {
 		pr_err("AF_RXRPC: Leaked conn %p {%d}\n",
 		       conn, atomic_read(&conn->usage));
 		leak = true;
 	}
-	write_unlock(&rxrpc_connection_lock);
+	write_unlock(&rxnet->conn_lock);
 	BUG_ON(leak);
 
-	ASSERT(list_empty(&rxrpc_connection_proc_list));
-
-	/* Make sure the local and peer records pinned by any dying connections
-	 * are released.
-	 */
-	rcu_barrier();
-	rxrpc_destroy_client_conn_ids();
+	ASSERT(list_empty(&rxnet->conn_proc_list));
 
 	_leave("");
 }
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index eef551f40dc2..edfc633f7d5e 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -121,7 +121,8 @@ static void rxrpc_publish_service_conn(struct rxrpc_peer *peer,
  * Preallocate a service connection.  The connection is placed on the proc and
  * reap lists so that we don't have to get the lock from BH context.
  */
-struct rxrpc_connection *rxrpc_prealloc_service_connection(gfp_t gfp)
+struct rxrpc_connection *rxrpc_prealloc_service_connection(struct rxrpc_net *rxnet,
+							   gfp_t gfp)
 {
 	struct rxrpc_connection *conn = rxrpc_alloc_connection(gfp);
 
@@ -132,10 +133,10 @@ struct rxrpc_connection *rxrpc_prealloc_service_connection(gfp_t gfp)
 		conn->state = RXRPC_CONN_SERVICE_PREALLOC;
 		atomic_set(&conn->usage, 2);
 
-		write_lock(&rxrpc_connection_lock);
-		list_add_tail(&conn->link, &rxrpc_connections);
-		list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
-		write_unlock(&rxrpc_connection_lock);
+		write_lock(&rxnet->conn_lock);
+		list_add_tail(&conn->link, &rxnet->service_conns);
+		list_add_tail(&conn->proc_link, &rxnet->conn_proc_list);
+		write_unlock(&rxnet->conn_lock);
 
 		trace_rxrpc_conn(conn, rxrpc_conn_new_service,
 				 atomic_read(&conn->usage),
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index ff4864d550b8..17d79fd73ade 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -25,9 +25,6 @@
 static void rxrpc_local_processor(struct work_struct *);
 static void rxrpc_local_rcu(struct rcu_head *);
 
-static DEFINE_MUTEX(rxrpc_local_mutex);
-static LIST_HEAD(rxrpc_local_endpoints);
-
 /*
  * Compare a local to an address.  Return -ve, 0 or +ve to indicate less than,
  * same or greater than.
@@ -77,13 +74,15 @@ static long rxrpc_local_cmp_key(const struct rxrpc_local *local,
 /*
  * Allocate a new local endpoint.
  */
-static struct rxrpc_local *rxrpc_alloc_local(const struct sockaddr_rxrpc *srx)
+static struct rxrpc_local *rxrpc_alloc_local(struct rxrpc_net *rxnet,
+					     const struct sockaddr_rxrpc *srx)
 {
 	struct rxrpc_local *local;
 
 	local = kzalloc(sizeof(struct rxrpc_local), GFP_KERNEL);
 	if (local) {
 		atomic_set(&local->usage, 1);
+		local->rxnet = rxnet;
 		INIT_LIST_HEAD(&local->link);
 		INIT_WORK(&local->processor, rxrpc_local_processor);
 		init_rwsem(&local->defrag_sem);
@@ -105,7 +104,7 @@ static struct rxrpc_local *rxrpc_alloc_local(const struct sockaddr_rxrpc *srx)
  * create the local socket
  * - must be called with rxrpc_local_mutex locked
  */
-static int rxrpc_open_socket(struct rxrpc_local *local)
+static int rxrpc_open_socket(struct rxrpc_local *local, struct net *net)
 {
 	struct sock *sock;
 	int ret, opt;
@@ -114,7 +113,7 @@ static int rxrpc_open_socket(struct rxrpc_local *local)
 	       local, local->srx.transport_type, local->srx.transport.family);
 
 	/* create a socket to represent the local endpoint */
-	ret = sock_create_kern(&init_net, local->srx.transport.family,
+	ret = sock_create_kern(net, local->srx.transport.family,
 			       local->srx.transport_type, 0, &local->socket);
 	if (ret < 0) {
 		_leave(" = %d [socket]", ret);
@@ -172,9 +171,11 @@ static int rxrpc_open_socket(struct rxrpc_local *local)
 /*
  * Look up or create a new local endpoint using the specified local address.
  */
-struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *srx)
+struct rxrpc_local *rxrpc_lookup_local(struct net *net,
+				       const struct sockaddr_rxrpc *srx)
 {
 	struct rxrpc_local *local;
+	struct rxrpc_net *rxnet = rxrpc_net(net);
 	struct list_head *cursor;
 	const char *age;
 	long diff;
@@ -183,10 +184,10 @@ struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *srx)
 	_enter("{%d,%d,%pISp}",
 	       srx->transport_type, srx->transport.family, &srx->transport);
 
-	mutex_lock(&rxrpc_local_mutex);
+	mutex_lock(&rxnet->local_mutex);
 
-	for (cursor = rxrpc_local_endpoints.next;
-	     cursor != &rxrpc_local_endpoints;
+	for (cursor = rxnet->local_endpoints.next;
+	     cursor != &rxnet->local_endpoints;
 	     cursor = cursor->next) {
 		local = list_entry(cursor, struct rxrpc_local, link);
 
@@ -220,11 +221,11 @@ struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *srx)
 		goto found;
 	}
 
-	local = rxrpc_alloc_local(srx);
+	local = rxrpc_alloc_local(rxnet, srx);
 	if (!local)
 		goto nomem;
 
-	ret = rxrpc_open_socket(local);
+	ret = rxrpc_open_socket(local, net);
 	if (ret < 0)
 		goto sock_error;
 
@@ -232,7 +233,7 @@ struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *srx)
 	age = "new";
 
 found:
-	mutex_unlock(&rxrpc_local_mutex);
+	mutex_unlock(&rxnet->local_mutex);
 
 	_net("LOCAL %s %d {%pISp}",
 	     age, local->debug_id, &local->srx.transport);
@@ -243,13 +244,13 @@ struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *srx)
 nomem:
 	ret = -ENOMEM;
 sock_error:
-	mutex_unlock(&rxrpc_local_mutex);
+	mutex_unlock(&rxnet->local_mutex);
 	kfree(local);
 	_leave(" = %d", ret);
 	return ERR_PTR(ret);
 
 addr_in_use:
-	mutex_unlock(&rxrpc_local_mutex);
+	mutex_unlock(&rxnet->local_mutex);
 	_leave(" = -EADDRINUSE");
 	return ERR_PTR(-EADDRINUSE);
 }
@@ -273,6 +274,7 @@ void __rxrpc_put_local(struct rxrpc_local *local)
 static void rxrpc_local_destroyer(struct rxrpc_local *local)
 {
 	struct socket *socket = local->socket;
+	struct rxrpc_net *rxnet = local->rxnet;
 
 	_enter("%d", local->debug_id);
 
@@ -286,9 +288,9 @@ static void rxrpc_local_destroyer(struct rxrpc_local *local)
 	}
 	local->dead = true;
 
-	mutex_lock(&rxrpc_local_mutex);
+	mutex_lock(&rxnet->local_mutex);
 	list_del_init(&local->link);
-	mutex_unlock(&rxrpc_local_mutex);
+	mutex_unlock(&rxnet->local_mutex);
 
 	ASSERT(RB_EMPTY_ROOT(&local->client_conns));
 	ASSERT(!local->service);
@@ -357,7 +359,7 @@ static void rxrpc_local_rcu(struct rcu_head *rcu)
 /*
  * Verify the local endpoint list is empty by this point.
  */
-void __exit rxrpc_destroy_all_locals(void)
+void rxrpc_destroy_all_locals(struct rxrpc_net *rxnet)
 {
 	struct rxrpc_local *local;
 
@@ -365,15 +367,13 @@ void __exit rxrpc_destroy_all_locals(void)
 
 	flush_workqueue(rxrpc_workqueue);
 
-	if (!list_empty(&rxrpc_local_endpoints)) {
-		mutex_lock(&rxrpc_local_mutex);
-		list_for_each_entry(local, &rxrpc_local_endpoints, link) {
+	if (!list_empty(&rxnet->local_endpoints)) {
+		mutex_lock(&rxnet->local_mutex);
+		list_for_each_entry(local, &rxnet->local_endpoints, link) {
 			pr_err("AF_RXRPC: Leaked local %p {%d}\n",
 			       local, atomic_read(&local->usage));
 		}
-		mutex_unlock(&rxrpc_local_mutex);
+		mutex_unlock(&rxnet->local_mutex);
 		BUG();
 	}
-
-	rcu_barrier();
 }
diff --git a/net/rxrpc/net_ns.c b/net/rxrpc/net_ns.c
new file mode 100644
index 000000000000..26449a6bb076
--- /dev/null
+++ b/net/rxrpc/net_ns.c
@@ -0,0 +1,85 @@
+/* rxrpc network namespace handling.
+ *
+ * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <linux/proc_fs.h>
+#include "ar-internal.h"
+
+unsigned int rxrpc_net_id;
+
+/*
+ * Initialise a per-network namespace record.
+ */
+static __net_init int rxrpc_init_net(struct net *net)
+{
+	struct rxrpc_net *rxnet = rxrpc_net(net);
+	int ret;
+
+	get_random_bytes(&rxnet->epoch, sizeof(rxnet->epoch));
+	rxnet->epoch |= RXRPC_RANDOM_EPOCH;
+
+	INIT_LIST_HEAD(&rxnet->calls);
+	rwlock_init(&rxnet->call_lock);
+
+	INIT_LIST_HEAD(&rxnet->conn_proc_list);
+	INIT_LIST_HEAD(&rxnet->service_conns);
+	rwlock_init(&rxnet->conn_lock);
+	INIT_DELAYED_WORK(&rxnet->service_conn_reaper,
+			  rxrpc_service_connection_reaper);
+
+	rxnet->nr_client_conns = 0;
+	rxnet->nr_active_client_conns = 0;
+	rxnet->kill_all_client_conns = false;
+	spin_lock_init(&rxnet->client_conn_cache_lock);
+	spin_lock_init(&rxnet->client_conn_discard_lock);
+	INIT_LIST_HEAD(&rxnet->waiting_client_conns);
+	INIT_LIST_HEAD(&rxnet->active_client_conns);
+	INIT_LIST_HEAD(&rxnet->idle_client_conns);
+	INIT_DELAYED_WORK(&rxnet->client_conn_reaper,
+			  rxrpc_discard_expired_client_conns);
+
+	INIT_LIST_HEAD(&rxnet->local_endpoints);
+	mutex_init(&rxnet->local_mutex);
+	hash_init(rxnet->peer_hash);
+	spin_lock_init(&rxnet->peer_hash_lock);
+
+	ret = -ENOMEM;
+	rxnet->proc_net = proc_net_mkdir(net, "rxrpc", net->proc_net);
+	if (!rxnet->proc_net)
+		goto err_proc;
+
+	proc_create("calls", 0444, rxnet->proc_net, &rxrpc_call_seq_fops);
+	proc_create("conns", 0444, rxnet->proc_net, &rxrpc_connection_seq_fops);
+	return 0;
+
+	proc_remove(rxnet->proc_net);
+err_proc:
+	return ret;
+}
+
+/*
+ * Clean up a per-network namespace record.
+ */
+static __net_exit void rxrpc_exit_net(struct net *net)
+{
+	struct rxrpc_net *rxnet = rxrpc_net(net);
+
+	rxrpc_destroy_all_calls(rxnet);
+	rxrpc_destroy_all_connections(rxnet);
+	rxrpc_destroy_all_locals(rxnet);
+	proc_remove(rxnet->proc_net);
+}
+
+struct pernet_operations rxrpc_net_ops = {
+	.init	= rxrpc_init_net,
+	.exit	= rxrpc_exit_net,
+	.id	= &rxrpc_net_id,
+	.size	= sizeof(struct rxrpc_net),
+};
diff --git a/net/rxrpc/peer_object.c b/net/rxrpc/peer_object.c
index 862eea6b266c..cfed3b27adf0 100644
--- a/net/rxrpc/peer_object.c
+++ b/net/rxrpc/peer_object.c
@@ -26,9 +26,6 @@
 #include <net/ip6_route.h>
 #include "ar-internal.h"
 
-static DEFINE_HASHTABLE(rxrpc_peer_hash, 10);
-static DEFINE_SPINLOCK(rxrpc_peer_hash_lock);
-
 /*
  * Hash a peer key.
  */
@@ -124,8 +121,9 @@ static struct rxrpc_peer *__rxrpc_lookup_peer_rcu(
 	unsigned long hash_key)
 {
 	struct rxrpc_peer *peer;
+	struct rxrpc_net *rxnet = local->rxnet;
 
-	hash_for_each_possible_rcu(rxrpc_peer_hash, peer, hash_link, hash_key) {
+	hash_for_each_possible_rcu(rxnet->peer_hash, peer, hash_link, hash_key) {
 		if (rxrpc_peer_cmp_key(peer, local, srx, hash_key) == 0) {
 			if (atomic_read(&peer->usage) == 0)
 				return NULL;
@@ -301,13 +299,14 @@ struct rxrpc_peer *rxrpc_lookup_incoming_peer(struct rxrpc_local *local,
 					      struct rxrpc_peer *prealloc)
 {
 	struct rxrpc_peer *peer;
+	struct rxrpc_net *rxnet = local->rxnet;
 	unsigned long hash_key;
 
 	hash_key = rxrpc_peer_hash_key(local, &prealloc->srx);
 	prealloc->local = local;
 	rxrpc_init_peer(prealloc, hash_key);
 
-	spin_lock(&rxrpc_peer_hash_lock);
+	spin_lock(&rxnet->peer_hash_lock);
 
 	/* Need to check that we aren't racing with someone else */
 	peer = __rxrpc_lookup_peer_rcu(local, &prealloc->srx, hash_key);
@@ -315,10 +314,10 @@ struct rxrpc_peer *rxrpc_lookup_incoming_peer(struct rxrpc_local *local,
 		peer = NULL;
 	if (!peer) {
 		peer = prealloc;
-		hash_add_rcu(rxrpc_peer_hash, &peer->hash_link, hash_key);
+		hash_add_rcu(rxnet->peer_hash, &peer->hash_link, hash_key);
 	}
 
-	spin_unlock(&rxrpc_peer_hash_lock);
+	spin_unlock(&rxnet->peer_hash_lock);
 	return peer;
 }
 
@@ -329,6 +328,7 @@ struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *local,
 				     struct sockaddr_rxrpc *srx, gfp_t gfp)
 {
 	struct rxrpc_peer *peer, *candidate;
+	struct rxrpc_net *rxnet = local->rxnet;
 	unsigned long hash_key = rxrpc_peer_hash_key(local, srx);
 
 	_enter("{%pISp}", &srx->transport);
@@ -350,17 +350,17 @@ struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *local,
 			return NULL;
 		}
 
-		spin_lock_bh(&rxrpc_peer_hash_lock);
+		spin_lock_bh(&rxnet->peer_hash_lock);
 
 		/* Need to check that we aren't racing with someone else */
 		peer = __rxrpc_lookup_peer_rcu(local, srx, hash_key);
 		if (peer && !rxrpc_get_peer_maybe(peer))
 			peer = NULL;
 		if (!peer)
-			hash_add_rcu(rxrpc_peer_hash,
+			hash_add_rcu(rxnet->peer_hash,
 				     &candidate->hash_link, hash_key);
 
-		spin_unlock_bh(&rxrpc_peer_hash_lock);
+		spin_unlock_bh(&rxnet->peer_hash_lock);
 
 		if (peer)
 			kfree(candidate);
@@ -379,11 +379,13 @@ struct rxrpc_peer *rxrpc_lookup_peer(struct rxrpc_local *local,
  */
 void __rxrpc_put_peer(struct rxrpc_peer *peer)
 {
+	struct rxrpc_net *rxnet = peer->local->rxnet;
+
 	ASSERT(hlist_empty(&peer->error_targets));
 
-	spin_lock_bh(&rxrpc_peer_hash_lock);
+	spin_lock_bh(&rxnet->peer_hash_lock);
 	hash_del_rcu(&peer->hash_link);
-	spin_unlock_bh(&rxrpc_peer_hash_lock);
+	spin_unlock_bh(&rxnet->peer_hash_lock);
 
 	kfree_rcu(peer, rcu);
 }
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index b9bcfbfb095c..e92d8405b15a 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -30,19 +30,25 @@ static const char *const rxrpc_conn_states[RXRPC_CONN__NR_STATES] = {
  */
 static void *rxrpc_call_seq_start(struct seq_file *seq, loff_t *_pos)
 {
+	struct rxrpc_net *rxnet = rxrpc_net(seq_file_net(seq));
+
 	rcu_read_lock();
-	read_lock(&rxrpc_call_lock);
-	return seq_list_start_head(&rxrpc_calls, *_pos);
+	read_lock(&rxnet->call_lock);
+	return seq_list_start_head(&rxnet->calls, *_pos);
 }
 
 static void *rxrpc_call_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	return seq_list_next(v, &rxrpc_calls, pos);
+	struct rxrpc_net *rxnet = rxrpc_net(seq_file_net(seq));
+
+	return seq_list_next(v, &rxnet->calls, pos);
 }
 
 static void rxrpc_call_seq_stop(struct seq_file *seq, void *v)
 {
-	read_unlock(&rxrpc_call_lock);
+	struct rxrpc_net *rxnet = rxrpc_net(seq_file_net(seq));
+
+	read_unlock(&rxnet->call_lock);
 	rcu_read_unlock();
 }
 
@@ -52,10 +58,11 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	struct rxrpc_sock *rx;
 	struct rxrpc_peer *peer;
 	struct rxrpc_call *call;
+	struct rxrpc_net *rxnet = rxrpc_net(seq_file_net(seq));
 	rxrpc_seq_t tx_hard_ack, rx_hard_ack;
 	char lbuff[50], rbuff[50];
 
-	if (v == &rxrpc_calls) {
+	if (v == &rxnet->calls) {
 		seq_puts(seq,
 			 "Proto Local                                          "
 			 " Remote                                         "
@@ -113,7 +120,8 @@ static const struct seq_operations rxrpc_call_seq_ops = {
 
 static int rxrpc_call_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &rxrpc_call_seq_ops);
+	return seq_open_net(inode, file, &rxrpc_call_seq_ops,
+			    sizeof(struct seq_net_private));
 }
 
 const struct file_operations rxrpc_call_seq_fops = {
@@ -129,27 +137,34 @@ const struct file_operations rxrpc_call_seq_fops = {
  */
 static void *rxrpc_connection_seq_start(struct seq_file *seq, loff_t *_pos)
 {
-	read_lock(&rxrpc_connection_lock);
-	return seq_list_start_head(&rxrpc_connection_proc_list, *_pos);
+	struct rxrpc_net *rxnet = rxrpc_net(seq_file_net(seq));
+
+	read_lock(&rxnet->conn_lock);
+	return seq_list_start_head(&rxnet->conn_proc_list, *_pos);
 }
 
 static void *rxrpc_connection_seq_next(struct seq_file *seq, void *v,
 				       loff_t *pos)
 {
-	return seq_list_next(v, &rxrpc_connection_proc_list, pos);
+	struct rxrpc_net *rxnet = rxrpc_net(seq_file_net(seq));
+
+	return seq_list_next(v, &rxnet->conn_proc_list, pos);
 }
 
 static void rxrpc_connection_seq_stop(struct seq_file *seq, void *v)
 {
-	read_unlock(&rxrpc_connection_lock);
+	struct rxrpc_net *rxnet = rxrpc_net(seq_file_net(seq));
+
+	read_unlock(&rxnet->conn_lock);
 }
 
 static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 {
 	struct rxrpc_connection *conn;
+	struct rxrpc_net *rxnet = rxrpc_net(seq_file_net(seq));
 	char lbuff[50], rbuff[50];
 
-	if (v == &rxrpc_connection_proc_list) {
+	if (v == &rxnet->conn_proc_list) {
 		seq_puts(seq,
 			 "Proto Local                                          "
 			 " Remote                                         "
@@ -197,7 +212,8 @@ static const struct seq_operations rxrpc_connection_seq_ops = {
 
 static int rxrpc_connection_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &rxrpc_connection_seq_ops);
+	return seq_open_net(inode, file, &rxrpc_connection_seq_ops,
+			    sizeof(struct seq_net_private));
 }
 
 const struct file_operations rxrpc_connection_seq_fops = {
