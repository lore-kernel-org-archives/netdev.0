From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 8/8] rxrpc: Rework local endpoint management
Date: Wed, 15 Jun 2016 17:42:34 +0100
Message-ID: <146600895462.18270.383990229044514960.stgit@warthog.procyon.org.uk>
References: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rework the local RxRPC endpoint management.

Local endpoint objects are maintained in a flat list as before.  This
should be okay as there shouldn't be more than one per open AF_RXRPC socket
(there can be fewer as local endpoints can be shared if their local service
ID is 0 and they share the same local transport parameters).

Changes:

 (1) Local endpoints may now only be shared if they have local service ID 0
     (ie. they're not being used for listening).

     This prevents a scenario where process A is listening of the Cache
     Manager port and process B contacts a fileserver - which may then
     attempt to send CM requests back to B.  But if A and B are sharing a
     local endpoint, A will get the CM requests meant for B.

 (2) We use a mutex to handle lookups and don't provide RCU-only lookups
     since we only expect to access the list when opening a socket or
     destroying an endpoint.

     The local endpoint object is pointed to by the transport socket's
     sk_user_data for the life of the transport socket - allowing us to
     refer to it directly from the sk_data_ready and sk_error_report
     callbacks.

 (3) atomic_inc_not_zero() now exists and can be used to only share a local
     endpoint if the last reference hasn't yet gone.

 (4) We can remove rxrpc_local_lock - a spinlock that had to be taken with
     BH processing disabled given that we assume sk_user_data won't change
     under us.

 (5) The transport socket is shut down before we clear the sk_user_data
     pointer so that we can be sure that the transport socket's callbacks
     won't be invoked once the RCU destruction is scheduled.

 (6) Local endpoints have a work item that handles both destruction and
     event processing.  The means that destruction doesn't then need to
     wait for event processing.  The event queues can then be cleared after
     the transport socket is shut down.

 (7) Local endpoints are no longer available for resurrection beyond the
     life of the sockets that had them open.  As soon as their last ref
     goes, they are scheduled for destruction and may not have their usage
     count moved from 0.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c     |   19 ++
 net/rxrpc/ar-internal.h  |   55 ++++---
 net/rxrpc/call_accept.c  |   25 +--
 net/rxrpc/conn_event.c   |   15 --
 net/rxrpc/input.c        |   29 +---
 net/rxrpc/local_event.c  |   10 -
 net/rxrpc/local_object.c |  353 +++++++++++++++++++++++++++-------------------
 7 files changed, 276 insertions(+), 230 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index ba373caddbeb..c83c3c75d665 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -102,6 +102,8 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
 
 	switch (srx->transport.family) {
 	case AF_INET:
+		if (srx->transport_len < sizeof(struct sockaddr_in))
+			return -EINVAL;
 		_debug("INET: %x @ %pI4",
 		       ntohs(srx->transport.sin.sin_port),
 		       &srx->transport.sin.sin_addr);
@@ -835,12 +837,27 @@ static void __exit af_rxrpc_exit(void)
 	rxrpc_destroy_all_calls();
 	rxrpc_destroy_all_connections();
 	rxrpc_destroy_all_transports();
-	rxrpc_destroy_all_locals();
 
 	ASSERTCMP(atomic_read(&rxrpc_n_skbs), ==, 0);
 
+	/* We need to flush the scheduled work twice because the local endpoint
+	 * records involve a work item in their destruction as they can only be
+	 * destroyed from process context.  However, a connection may have a
+	 * work item outstanding - and this will pin the local endpoint record
+	 * until the connection goes away.
+	 *
+	 * Peers don't pin locals and calls pin sockets - which prevents the
+	 * module from being unloaded - so we should only need two flushes.
+	 */
 	_debug("flush scheduled work");
 	flush_workqueue(rxrpc_workqueue);
+	_debug("flush scheduled work 2");
+	flush_workqueue(rxrpc_workqueue);
+	_debug("synchronise RCU");
+	rcu_barrier();
+	_debug("destroy locals");
+	rxrpc_destroy_all_locals();
+
 	remove_proc_entry("rxrpc_conns", init_net.proc_net);
 	remove_proc_entry("rxrpc_calls", init_net.proc_net);
 	destroy_workqueue(rxrpc_workqueue);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index fa50b09eaa63..c168268467cd 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -170,25 +170,26 @@ struct rxrpc_security {
 };
 
 /*
- * RxRPC local transport endpoint definition
- * - matched by local port, address and protocol type
+ * RxRPC local transport endpoint description
+ * - owned by a single AF_RXRPC socket
+ * - pointed to by transport socket struct sk_user_data
  */
 struct rxrpc_local {
+	struct rcu_head		rcu;
+	atomic_t		usage;
+	struct list_head	link;
 	struct socket		*socket;	/* my UDP socket */
-	struct work_struct	destroyer;	/* endpoint destroyer */
-	struct work_struct	acceptor;	/* incoming call processor */
-	struct work_struct	rejecter;	/* packet reject writer */
-	struct work_struct	event_processor; /* endpoint event processor */
+	struct work_struct	processor;
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
+	bool			dead;
 	struct sockaddr_rxrpc	srx;		/* local address */
 };
 
@@ -487,7 +488,7 @@ extern struct rxrpc_transport *rxrpc_name_to_transport(struct rxrpc_sock *,
 /*
  * call_accept.c
  */
-void rxrpc_accept_incoming_calls(struct work_struct *);
+void rxrpc_accept_incoming_calls(struct rxrpc_local *);
 struct rxrpc_call *rxrpc_accept_call(struct rxrpc_sock *, unsigned long);
 int rxrpc_reject_call(struct rxrpc_sock *);
 
@@ -527,7 +528,7 @@ void __exit rxrpc_destroy_all_calls(void);
  */
 void rxrpc_process_connection(struct work_struct *);
 void rxrpc_reject_packet(struct rxrpc_local *, struct sk_buff *);
-void rxrpc_reject_packets(struct work_struct *);
+void rxrpc_reject_packets(struct rxrpc_local *);
 
 /*
  * conn_object.c
@@ -575,17 +576,32 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time_t,
 /*
  * local_event.c
  */
-extern void rxrpc_process_local_events(struct work_struct *);
+extern void rxrpc_process_local_events(struct rxrpc_local *);
 
 /*
  * local_object.c
  */
-extern rwlock_t rxrpc_local_lock;
-
-struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *);
-void rxrpc_put_local(struct rxrpc_local *);
+struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *);
+void __rxrpc_put_local(struct rxrpc_local *);
 void __exit rxrpc_destroy_all_locals(void);
 
+static inline void rxrpc_get_local(struct rxrpc_local *local)
+{
+	atomic_inc(&local->usage);
+}
+
+static inline
+struct rxrpc_local *rxrpc_get_local_maybe(struct rxrpc_local *local)
+{
+	return atomic_inc_not_zero(&local->usage) ? local : NULL;
+}
+
+static inline void rxrpc_put_local(struct rxrpc_local *local)
+{
+	if (atomic_dec_and_test(&local->usage))
+		__rxrpc_put_local(local);
+}
+
 /*
  * misc.c
  */
@@ -874,15 +890,6 @@ static inline void rxrpc_purge_queue(struct sk_buff_head *list)
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
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index e5723f4dce89..50136c76ebd1 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -202,10 +202,8 @@ error_nofree:
  * accept incoming calls that need peer, transport and/or connection setting up
  * - the packets we get are all incoming client DATA packets that have seq == 1
  */
-void rxrpc_accept_incoming_calls(struct work_struct *work)
+void rxrpc_accept_incoming_calls(struct rxrpc_local *local)
 {
-	struct rxrpc_local *local =
-		container_of(work, struct rxrpc_local, acceptor);
 	struct rxrpc_skb_priv *sp;
 	struct sockaddr_rxrpc srx;
 	struct rxrpc_sock *rx;
@@ -215,21 +213,8 @@ void rxrpc_accept_incoming_calls(struct work_struct *work)
 
 	_enter("%d", local->debug_id);
 
-	read_lock_bh(&rxrpc_local_lock);
-	if (atomic_read(&local->usage) > 0)
-		rxrpc_get_local(local);
-	else
-		local = NULL;
-	read_unlock_bh(&rxrpc_local_lock);
-	if (!local) {
-		_leave(" [local dead]");
-		return;
-	}
-
-process_next_packet:
 	skb = skb_dequeue(&local->accept_queue);
 	if (!skb) {
-		rxrpc_put_local(local);
 		_leave("\n");
 		return;
 	}
@@ -292,7 +277,7 @@ found_service:
 	case -ECONNRESET: /* old calls are ignored */
 	case -ECONNABORTED: /* aborted calls are reaborted or ignored */
 	case 0:
-		goto process_next_packet;
+		return;
 	case -ECONNREFUSED:
 		goto invalid_service;
 	case -EBUSY:
@@ -308,18 +293,18 @@ backlog_full:
 busy:
 	rxrpc_busy(local, &srx, &whdr);
 	rxrpc_free_skb(skb);
-	goto process_next_packet;
+	return;
 
 invalid_service:
 	skb->priority = RX_INVALID_OPERATION;
 	rxrpc_reject_packet(local, skb);
-	goto process_next_packet;
+	return;
 
 	/* can't change connection security type mid-flow */
 security_mismatch:
 	skb->priority = RX_PROTOCOL_ERROR;
 	rxrpc_reject_packet(local, skb);
-	goto process_next_packet;
+	return;
 }
 
 /*
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 8bdd692d4862..00c92b614485 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -314,19 +314,14 @@ void rxrpc_reject_packet(struct rxrpc_local *local, struct sk_buff *skb)
 {
 	CHECK_SLAB_OKAY(&local->usage);
 
-	if (!atomic_inc_not_zero(&local->usage)) {
-		printk("resurrected on reject\n");
-		BUG();
-	}
-
 	skb_queue_tail(&local->reject_queue, skb);
-	rxrpc_queue_work(&local->rejecter);
+	rxrpc_queue_work(&local->processor);
 }
 
 /*
  * reject packets through the local endpoint
  */
-void rxrpc_reject_packets(struct work_struct *work)
+void rxrpc_reject_packets(struct rxrpc_local *local)
 {
 	union {
 		struct sockaddr sa;
@@ -334,16 +329,12 @@ void rxrpc_reject_packets(struct work_struct *work)
 	} sa;
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_wire_header whdr;
-	struct rxrpc_local *local;
 	struct sk_buff *skb;
 	struct msghdr msg;
 	struct kvec iov[2];
 	size_t size;
 	__be32 code;
 
-	local = container_of(work, struct rxrpc_local, rejecter);
-	rxrpc_get_local(local);
-
 	_enter("%d", local->debug_id);
 
 	iov[0].iov_base = &whdr;
@@ -395,9 +386,7 @@ void rxrpc_reject_packets(struct work_struct *work)
 		}
 
 		rxrpc_free_skb(skb);
-		rxrpc_put_local(local);
 	}
 
-	rxrpc_put_local(local);
 	_leave("");
 }
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 3b405dbf3a05..47fb167af3e4 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -594,9 +594,8 @@ static void rxrpc_post_packet_to_local(struct rxrpc_local *local,
 {
 	_enter("%p,%p", local, skb);
 
-	atomic_inc(&local->usage);
 	skb_queue_tail(&local->event_queue, skb);
-	rxrpc_queue_work(&local->event_processor);
+	rxrpc_queue_work(&local->processor);
 }
 
 /*
@@ -664,11 +663,15 @@ cant_find_conn:
 /*
  * handle data received on the local endpoint
  * - may be called in interrupt context
+ *
+ * The socket is locked by the caller and this prevents the socket from being
+ * shut down and the local endpoint from going away, thus sk_user_data will not
+ * be cleared until this function returns.
  */
 void rxrpc_data_ready(struct sock *sk)
 {
 	struct rxrpc_skb_priv *sp;
-	struct rxrpc_local *local;
+	struct rxrpc_local *local = sk->sk_user_data;
 	struct sk_buff *skb;
 	int ret;
 
@@ -676,21 +679,8 @@ void rxrpc_data_ready(struct sock *sk)
 
 	ASSERT(!irqs_disabled());
 
-	read_lock_bh(&rxrpc_local_lock);
-	local = sk->sk_user_data;
-	if (local && atomic_read(&local->usage) > 0)
-		rxrpc_get_local(local);
-	else
-		local = NULL;
-	read_unlock_bh(&rxrpc_local_lock);
-	if (!local) {
-		_leave(" [local dead]");
-		return;
-	}
-
 	skb = skb_recv_datagram(sk, 0, 1, &ret);
 	if (!skb) {
-		rxrpc_put_local(local);
 		if (ret == -EAGAIN)
 			return;
 		_debug("UDP socket error %d", ret);
@@ -704,7 +694,6 @@ void rxrpc_data_ready(struct sock *sk)
 	/* we'll probably need to checksum it (didn't call sock_recvmsg) */
 	if (skb_checksum_complete(skb)) {
 		rxrpc_free_skb(skb);
-		rxrpc_put_local(local);
 		__UDP_INC_STATS(&init_net, UDP_MIB_INERRORS, 0);
 		_leave(" [CSUM failed]");
 		return;
@@ -769,7 +758,6 @@ void rxrpc_data_ready(struct sock *sk)
 	}
 
 out:
-	rxrpc_put_local(local);
 	return;
 
 cant_route_call:
@@ -779,8 +767,7 @@ cant_route_call:
 		if (sp->hdr.seq == 1) {
 			_debug("first packet");
 			skb_queue_tail(&local->accept_queue, skb);
-			rxrpc_queue_work(&local->acceptor);
-			rxrpc_put_local(local);
+			rxrpc_queue_work(&local->processor);
 			_leave(" [incoming]");
 			return;
 		}
@@ -793,13 +780,11 @@ cant_route_call:
 		_debug("reject type %d",sp->hdr.type);
 		rxrpc_reject_packet(local, skb);
 	}
-	rxrpc_put_local(local);
 	_leave(" [no call]");
 	return;
 
 bad_message:
 	skb->priority = RX_PROTOCOL_ERROR;
 	rxrpc_reject_packet(local, skb);
-	rxrpc_put_local(local);
 	_leave(" [badmsg]");
 }
diff --git a/net/rxrpc/local_event.c b/net/rxrpc/local_event.c
index 194db2e6d548..31a3f86ef2f6 100644
--- a/net/rxrpc/local_event.c
+++ b/net/rxrpc/local_event.c
@@ -82,17 +82,15 @@ static void rxrpc_send_version_request(struct rxrpc_local *local,
 /*
  * Process event packets targetted at a local endpoint.
  */
-void rxrpc_process_local_events(struct work_struct *work)
+void rxrpc_process_local_events(struct rxrpc_local *local)
 {
-	struct rxrpc_local *local = container_of(work, struct rxrpc_local, event_processor);
 	struct sk_buff *skb;
 	char v;
 
 	_enter("");
 
-	atomic_inc(&local->usage);
-
-	while ((skb = skb_dequeue(&local->event_queue))) {
+	skb = skb_dequeue(&local->event_queue);
+	if (skb) {
 		struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 
 		_debug("{%d},{%u}", local->debug_id, sp->hdr.type);
@@ -111,10 +109,8 @@ void rxrpc_process_local_events(struct work_struct *work)
 			break;
 		}
 
-		rxrpc_put_local(local);
 		rxrpc_free_skb(skb);
 	}
 
-	rxrpc_put_local(local);
 	_leave("");
 }
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index c1b8d745bf5e..009b321712bc 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -1,6 +1,6 @@
 /* Local endpoint object management
  *
- * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Copyright (C) 2016 Red Hat, Inc. All Rights Reserved.
  * Written by David Howells (dhowells@redhat.com)
  *
  * This program is free software; you can redistribute it and/or
@@ -17,40 +17,72 @@
 #include <linux/slab.h>
 #include <linux/udp.h>
 #include <linux/ip.h>
+#include <linux/hashtable.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
-static LIST_HEAD(rxrpc_locals);
-DEFINE_RWLOCK(rxrpc_local_lock);
-static DECLARE_RWSEM(rxrpc_local_sem);
-static DECLARE_WAIT_QUEUE_HEAD(rxrpc_local_wq);
+static void rxrpc_local_processor(struct work_struct *);
+static void rxrpc_local_rcu(struct rcu_head *);
 
-static void rxrpc_destroy_local(struct work_struct *work);
+static DEFINE_MUTEX(rxrpc_local_mutex);
+static LIST_HEAD(rxrpc_local_endpoints);
 
 /*
- * allocate a new local
+ * Compare a local to an address.  Return -ve, 0 or +ve to indicate less than,
+ * same or greater than.
+ *
+ * We explicitly don't compare the RxRPC service ID as we want to reject
+ * conflicting uses by differing services.  Further, we don't want to share
+ * addresses with different options (IPv6), so we don't compare those bits
+ * either.
  */
-static
-struct rxrpc_local *rxrpc_alloc_local(struct sockaddr_rxrpc *srx)
+static long rxrpc_local_cmp_key(const struct rxrpc_local *local,
+				const struct sockaddr_rxrpc *srx)
+{
+	long diff;
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
+ * Allocate a new local endpoint.
+ */
+static struct rxrpc_local *rxrpc_alloc_local(const struct sockaddr_rxrpc *srx)
 {
 	struct rxrpc_local *local;
 
 	local = kzalloc(sizeof(struct rxrpc_local), GFP_KERNEL);
 	if (local) {
-		INIT_WORK(&local->destroyer, &rxrpc_destroy_local);
-		INIT_WORK(&local->acceptor, &rxrpc_accept_incoming_calls);
-		INIT_WORK(&local->rejecter, &rxrpc_reject_packets);
-		INIT_WORK(&local->event_processor, &rxrpc_process_local_events);
-		INIT_LIST_HEAD(&local->services);
+		atomic_set(&local->usage, 1);
 		INIT_LIST_HEAD(&local->link);
+		INIT_WORK(&local->processor, rxrpc_local_processor);
+		INIT_LIST_HEAD(&local->services);
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
 	}
@@ -61,9 +93,9 @@ struct rxrpc_local *rxrpc_alloc_local(struct sockaddr_rxrpc *srx)
 
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
@@ -82,10 +114,10 @@ static int rxrpc_create_local(struct rxrpc_local *local)
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
@@ -108,10 +140,6 @@ static int rxrpc_create_local(struct rxrpc_local *local)
 		goto error;
 	}
 
-	write_lock_bh(&rxrpc_local_lock);
-	list_add(&local->link, &rxrpc_locals);
-	write_unlock_bh(&rxrpc_local_lock);
-
 	/* set the socket up */
 	sock = local->socket->sk;
 	sock->sk_user_data	= local;
@@ -131,188 +159,227 @@ error:
 }
 
 /*
- * create a new local endpoint using the specified UDP address
+ * Look up or create a new local endpoint using the specified local address.
  */
-struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *srx)
+struct rxrpc_local *rxrpc_lookup_local(const struct sockaddr_rxrpc *srx)
 {
 	struct rxrpc_local *local;
+	struct list_head *cursor;
+	const char *age;
+	long diff;
 	int ret;
 
-	_enter("{%d,%u,%pI4+%hu}",
-	       srx->transport_type,
-	       srx->transport.family,
-	       &srx->transport.sin.sin_addr,
-	       ntohs(srx->transport.sin.sin_port));
-
-	down_write(&rxrpc_local_sem);
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
+	}
 
-	/* see if we have a suitable local local endpoint already */
-	read_lock_bh(&rxrpc_local_lock);
+	mutex_lock(&rxrpc_local_mutex);
 
-	list_for_each_entry(local, &rxrpc_locals, link) {
-		_debug("CMP {%d,%u,%pI4+%hu}",
-		       local->srx.transport_type,
-		       local->srx.transport.family,
-		       &local->srx.transport.sin.sin_addr,
-		       ntohs(local->srx.transport.sin.sin_port));
+	for (cursor = rxrpc_local_endpoints.next;
+	     cursor != &rxrpc_local_endpoints;
+	     cursor = cursor->next) {
+		local = list_entry(cursor, struct rxrpc_local, link);
 
-		if (local->srx.transport_type != srx->transport_type ||
-		    local->srx.transport.family != srx->transport.family)
+		diff = rxrpc_local_cmp_key(local, srx);
+		if (diff < 0)
 			continue;
+		if (diff > 0)
+			break;
+
+		/* Services aren't allowed to share transport sockets, so
+		 * reject that here.  It is possible that the object is dying -
+		 * but it may also still have the local transport address that
+		 * we want bound.
+		 */
+		if (srx->srx_service) {
+			local = NULL;
+			goto addr_in_use;
+		}
 
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
+		/* Found a match.  We replace a dying object.  Attempting to
+		 * bind the transport socket may still fail if we're attempting
+		 * to use a local address that the dying object is still using.
+		 */
+		if (!atomic_inc_not_zero(&local->usage)) {
+			cursor = cursor->next;
+			list_del_init(&local->link);
+			break;
 		}
-	}
 
-	read_unlock_bh(&rxrpc_local_lock);
+		age = "old";
+		goto found;
+	}
 
-	/* we didn't find one, so we need to create one */
 	local = rxrpc_alloc_local(srx);
-	if (!local) {
-		up_write(&rxrpc_local_sem);
-		return ERR_PTR(-ENOMEM);
-	}
+	if (!local)
+		goto nomem;
 
-	ret = rxrpc_create_local(local);
-	if (ret < 0) {
-		up_write(&rxrpc_local_sem);
-		kfree(local);
-		_leave(" = %d", ret);
-		return ERR_PTR(ret);
-	}
+	ret = rxrpc_open_socket(local);
+	if (ret < 0)
+		goto sock_error;
+
+	list_add_tail(&local->link, cursor);
+	age = "new";
 
-	up_write(&rxrpc_local_sem);
+found:
+	mutex_unlock(&rxrpc_local_mutex);
 
-	_net("LOCAL new %d {%d,%u,%pI4+%hu}",
+	_net("LOCAL %s %d {%d,%u,%pI4+%hu}",
+	     age,
 	     local->debug_id,
 	     local->srx.transport_type,
 	     local->srx.transport.family,
 	     &local->srx.transport.sin.sin_addr,
 	     ntohs(local->srx.transport.sin.sin_port));
 
-	_leave(" = %p [new]", local);
+	_leave(" = %p", local);
 	return local;
 
-found_local:
-	rxrpc_get_local(local);
-	read_unlock_bh(&rxrpc_local_lock);
-	up_write(&rxrpc_local_sem);
+nomem:
+	ret = -ENOMEM;
+sock_error:
+	mutex_unlock(&rxrpc_local_mutex);
+	kfree(local);
+	_leave(" = %d", ret);
+	return ERR_PTR(ret);
 
-	_net("LOCAL old %d {%d,%u,%pI4+%hu}",
-	     local->debug_id,
-	     local->srx.transport_type,
-	     local->srx.transport.family,
-	     &local->srx.transport.sin.sin_addr,
-	     ntohs(local->srx.transport.sin.sin_port));
+addr_in_use:
+	mutex_unlock(&rxrpc_local_mutex);
+	_leave(" = -EADDRINUSE");
+	return ERR_PTR(-EADDRINUSE);
+}
 
-	_leave(" = %p [reuse]", local);
-	return local;
+/*
+ * A local endpoint reached its end of life.
+ */
+void __rxrpc_put_local(struct rxrpc_local *local)
+{
+	_enter("%d", local->debug_id);
+	rxrpc_queue_work(&local->processor);
 }
 
 /*
- * release a local endpoint
+ * Destroy a local endpoint's socket and then hand the record to RCU to dispose
+ * of.
+ *
+ * Closing the socket cannot be done from bottom half context or RCU callback
+ * context because it might sleep.
  */
-void rxrpc_put_local(struct rxrpc_local *local)
+static void rxrpc_local_destroyer(struct rxrpc_local *local)
 {
-	_enter("%p{u=%d}", local, atomic_read(&local->usage));
+	struct socket *socket = local->socket;
 
-	ASSERTCMP(atomic_read(&local->usage), >, 0);
+	_enter("%d", local->debug_id);
 
-	/* to prevent a race, the decrement and the dequeue must be effectively
-	 * atomic */
-	write_lock_bh(&rxrpc_local_lock);
-	if (unlikely(atomic_dec_and_test(&local->usage))) {
-		_debug("destroy local");
-		rxrpc_queue_work(&local->destroyer);
+	/* We can get a race between an incoming call packet queueing the
+	 * processor again and the work processor starting the destruction
+	 * process which will shut down the UDP socket.
+	 */
+	if (local->dead) {
+		_leave(" [already dead]");
+		return;
 	}
-	write_unlock_bh(&rxrpc_local_lock);
-	_leave("");
+	local->dead = true;
+
+	mutex_lock(&rxrpc_local_mutex);
+	list_del_init(&local->link);
+	mutex_unlock(&rxrpc_local_mutex);
+
+	ASSERT(list_empty(&local->services));
+
+	if (socket) {
+		local->socket = NULL;
+		kernel_sock_shutdown(socket, SHUT_RDWR);
+		socket->sk->sk_user_data = NULL;
+		sock_release(socket);
+	}
+
+	/* At this point, there should be no more packets coming in to the
+	 * local endpoint.
+	 */
+	rxrpc_purge_queue(&local->accept_queue);
+	rxrpc_purge_queue(&local->reject_queue);
+	rxrpc_purge_queue(&local->event_queue);
+
+	_debug("rcu local %d", local->debug_id);
+	call_rcu(&local->rcu, rxrpc_local_rcu);
 }
 
 /*
- * destroy a local endpoint
+ * Process events on an endpoint
  */
-static void rxrpc_destroy_local(struct work_struct *work)
+static void rxrpc_local_processor(struct work_struct *work)
 {
 	struct rxrpc_local *local =
-		container_of(work, struct rxrpc_local, destroyer);
+		container_of(work, struct rxrpc_local, processor);
+	bool again;
 
-	_enter("%p{%d}", local, atomic_read(&local->usage));
+	_enter("%d", local->debug_id);
 
-	down_write(&rxrpc_local_sem);
+	do {
+		again = false;
+		if (atomic_read(&local->usage) == 0)
+			return rxrpc_local_destroyer(local);
 
-	write_lock_bh(&rxrpc_local_lock);
-	if (atomic_read(&local->usage) > 0) {
-		write_unlock_bh(&rxrpc_local_lock);
-		up_read(&rxrpc_local_sem);
-		_leave(" [resurrected]");
-		return;
-	}
+		if (!skb_queue_empty(&local->accept_queue)) {
+			rxrpc_accept_incoming_calls(local);
+			again = true;
+		}
 
-	list_del(&local->link);
-	local->socket->sk->sk_user_data = NULL;
-	write_unlock_bh(&rxrpc_local_lock);
+		if (!skb_queue_empty(&local->reject_queue)) {
+			rxrpc_reject_packets(local);
+			again = true;
+		}
 
-	downgrade_write(&rxrpc_local_sem);
+		if (!skb_queue_empty(&local->event_queue)) {
+			rxrpc_process_local_events(local);
+			again = true;
+		}
+	} while (again);
+}
 
-	ASSERT(list_empty(&local->services));
-	ASSERT(!work_pending(&local->acceptor));
-	ASSERT(!work_pending(&local->rejecter));
-	ASSERT(!work_pending(&local->event_processor));
+/*
+ * Destroy a local endpoint after the RCU grace period expires.
+ */
+static void rxrpc_local_rcu(struct rcu_head *rcu)
+{
+	struct rxrpc_local *local = container_of(rcu, struct rxrpc_local, rcu);
 
-	/* finish cleaning up the local descriptor */
-	rxrpc_purge_queue(&local->accept_queue);
-	rxrpc_purge_queue(&local->reject_queue);
-	rxrpc_purge_queue(&local->event_queue);
-	kernel_sock_shutdown(local->socket, SHUT_RDWR);
-	sock_release(local->socket);
+	_enter("%d", local->debug_id);
 
-	up_read(&rxrpc_local_sem);
+	ASSERT(!work_pending(&local->processor));
 
 	_net("DESTROY LOCAL %d", local->debug_id);
 	kfree(local);
-
-	if (list_empty(&rxrpc_locals))
-		wake_up_all(&rxrpc_local_wq);
-
 	_leave("");
 }
 
 /*
- * preemptively destroy all local local endpoint rather than waiting for
- * them to be destroyed
+ * Verify the local endpoint list is empty by this point.
  */
 void __exit rxrpc_destroy_all_locals(void)
 {
-	DECLARE_WAITQUEUE(myself,current);
+	struct rxrpc_local *local;
 
 	_enter("");
 
-	/* we simply have to wait for them to go away */
-	if (!list_empty(&rxrpc_locals)) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		add_wait_queue(&rxrpc_local_wq, &myself);
-
-		while (!list_empty(&rxrpc_locals)) {
-			schedule();
-			set_current_state(TASK_UNINTERRUPTIBLE);
-		}
+	if (list_empty(&rxrpc_local_endpoints))
+		return;
 
-		remove_wait_queue(&rxrpc_local_wq, &myself);
-		set_current_state(TASK_RUNNING);
+	mutex_lock(&rxrpc_local_mutex);
+	list_for_each_entry(local, &rxrpc_local_endpoints, link) {
+		pr_err("AF_RXRPC: Leaked local %p {%d}\n",
+		       local, atomic_read(&local->usage));
 	}
-
-	_leave("");
+	mutex_unlock(&rxrpc_local_mutex);
+	BUG();
 }
