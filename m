From: David Howells <dhowells@redhat.com>
Subject: [PATCH 03/11] rxrpc: Separate local endpoint object handling out
 into its own file
Date: Mon, 07 Mar 2016 14:38:20 +0000
Message-ID: <20160307143820.18567.13425.stgit@warthog.procyon.org.uk>
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

Separate local endpoint object handling out into its own file preparatory
to overhauling it to use the new object cache.  The original file is then
be used exclusively for the local endpoint packet and event handling.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile       |    1 
 net/rxrpc/ar-internal.h  |   15 +-
 net/rxrpc/ar-local.c     |  299 --------------------------------------------
 net/rxrpc/local-object.c |  316 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 328 insertions(+), 303 deletions(-)
 create mode 100644 net/rxrpc/local-object.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index b79fee14c763..166e4cb3b13c 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -19,6 +19,7 @@ af-rxrpc-y := \
 	ar-security.o \
 	ar-skbuff.o \
 	ar-transport.o \
+	local-object.o \
 	objcache.o
 
 af-rxrpc-$(CONFIG_PROC_FS) += ar-proc.o
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 21d6ae6f4cc6..cec573dbb5e1 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -598,11 +598,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *, struct sk_buff *);
 /*
  * ar-local.c
  */
-extern rwlock_t rxrpc_local_lock;
-
-struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *);
-void rxrpc_put_local(struct rxrpc_local *);
-void __exit rxrpc_destroy_all_locals(void);
+extern void rxrpc_process_local_events(struct work_struct *);
 
 /*
  * ar-key.c
@@ -676,6 +672,15 @@ struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
 					     struct rxrpc_peer *);
 
 /*
+ * local-object.c
+ */
+extern rwlock_t rxrpc_local_lock;
+
+struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *);
+void rxrpc_put_local(struct rxrpc_local *);
+void __exit rxrpc_destroy_all_locals(void);
+
+/*
  * sysctl.c
  */
 #ifdef CONFIG_SYSCTL
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
index 4e1e6db0050b..7060995a4276 100644
--- a/net/rxrpc/ar-local.c
+++ b/net/rxrpc/ar-local.c
@@ -22,303 +22,6 @@
 
 static const char rxrpc_version_string[65] = "linux-" UTS_RELEASE " AF_RXRPC";
 
-static LIST_HEAD(rxrpc_locals);
-DEFINE_RWLOCK(rxrpc_local_lock);
-static DECLARE_RWSEM(rxrpc_local_sem);
-static DECLARE_WAIT_QUEUE_HEAD(rxrpc_local_wq);
-
-static void rxrpc_destroy_local(struct work_struct *work);
-static void rxrpc_process_local_events(struct work_struct *work);
-
-/*
- * allocate a new local
- */
-static
-struct rxrpc_local *rxrpc_alloc_local(struct sockaddr_rxrpc *srx)
-{
-	struct rxrpc_local *local;
-
-	local = kzalloc(sizeof(struct rxrpc_local), GFP_KERNEL);
-	if (local) {
-		INIT_WORK(&local->destroyer, &rxrpc_destroy_local);
-		INIT_WORK(&local->acceptor, &rxrpc_accept_incoming_calls);
-		INIT_WORK(&local->rejecter, &rxrpc_reject_packets);
-		INIT_WORK(&local->event_processor, &rxrpc_process_local_events);
-		INIT_LIST_HEAD(&local->services);
-		INIT_LIST_HEAD(&local->link);
-		init_rwsem(&local->defrag_sem);
-		skb_queue_head_init(&local->accept_queue);
-		skb_queue_head_init(&local->reject_queue);
-		skb_queue_head_init(&local->event_queue);
-		spin_lock_init(&local->lock);
-		rwlock_init(&local->services_lock);
-		atomic_set(&local->usage, 1);
-		local->debug_id = atomic_inc_return(&rxrpc_debug_id);
-		memcpy(&local->srx, srx, sizeof(*srx));
-	}
-
-	_leave(" = %p", local);
-	return local;
-}
-
-/*
- * create the local socket
- * - must be called with rxrpc_local_sem writelocked
- */
-static int rxrpc_create_local(struct rxrpc_local *local)
-{
-	struct sock *sock;
-	int ret, opt;
-
-	_enter("%p{%d}", local, local->srx.transport_type);
-
-	/* create a socket to represent the local endpoint */
-	ret = sock_create_kern(&init_net, PF_INET, local->srx.transport_type,
-			       IPPROTO_UDP, &local->socket);
-	if (ret < 0) {
-		_leave(" = %d [socket]", ret);
-		return ret;
-	}
-
-	/* if a local address was supplied then bind it */
-	if (local->srx.transport_len > sizeof(sa_family_t)) {
-		_debug("bind");
-		ret = kernel_bind(local->socket,
-				  (struct sockaddr *) &local->srx.transport,
-				  local->srx.transport_len);
-		if (ret < 0) {
-			_debug("bind failed");
-			goto error;
-		}
-	}
-
-	/* we want to receive ICMP errors */
-	opt = 1;
-	ret = kernel_setsockopt(local->socket, SOL_IP, IP_RECVERR,
-				(char *) &opt, sizeof(opt));
-	if (ret < 0) {
-		_debug("setsockopt failed");
-		goto error;
-	}
-
-	/* we want to set the don't fragment bit */
-	opt = IP_PMTUDISC_DO;
-	ret = kernel_setsockopt(local->socket, SOL_IP, IP_MTU_DISCOVER,
-				(char *) &opt, sizeof(opt));
-	if (ret < 0) {
-		_debug("setsockopt failed");
-		goto error;
-	}
-
-	write_lock_bh(&rxrpc_local_lock);
-	list_add(&local->link, &rxrpc_locals);
-	write_unlock_bh(&rxrpc_local_lock);
-
-	/* set the socket up */
-	sock = local->socket->sk;
-	sock->sk_user_data	= local;
-	sock->sk_data_ready	= rxrpc_data_ready;
-	sock->sk_error_report	= rxrpc_UDP_error_report;
-	_leave(" = 0");
-	return 0;
-
-error:
-	kernel_sock_shutdown(local->socket, SHUT_RDWR);
-	local->socket->sk->sk_user_data = NULL;
-	sock_release(local->socket);
-	local->socket = NULL;
-
-	_leave(" = %d", ret);
-	return ret;
-}
-
-/*
- * create a new local endpoint using the specified UDP address
- */
-struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *srx)
-{
-	struct rxrpc_local *local;
-	int ret;
-
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
-	}
-
-	read_unlock_bh(&rxrpc_local_lock);
-
-	/* we didn't find one, so we need to create one */
-	local = rxrpc_alloc_local(srx);
-	if (!local) {
-		up_write(&rxrpc_local_sem);
-		return ERR_PTR(-ENOMEM);
-	}
-
-	ret = rxrpc_create_local(local);
-	if (ret < 0) {
-		up_write(&rxrpc_local_sem);
-		kfree(local);
-		_leave(" = %d", ret);
-		return ERR_PTR(ret);
-	}
-
-	up_write(&rxrpc_local_sem);
-
-	_net("LOCAL new %d {%d,%u,%pI4+%hu}",
-	     local->debug_id,
-	     local->srx.transport_type,
-	     local->srx.transport.family,
-	     &local->srx.transport.sin.sin_addr,
-	     ntohs(local->srx.transport.sin.sin_port));
-
-	_leave(" = %p [new]", local);
-	return local;
-
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
-}
-
-/*
- * release a local endpoint
- */
-void rxrpc_put_local(struct rxrpc_local *local)
-{
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
-	}
-	write_unlock_bh(&rxrpc_local_lock);
-	_leave("");
-}
-
-/*
- * destroy a local endpoint
- */
-static void rxrpc_destroy_local(struct work_struct *work)
-{
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
-
-	downgrade_write(&rxrpc_local_sem);
-
-	ASSERT(list_empty(&local->services));
-	ASSERT(!work_pending(&local->acceptor));
-	ASSERT(!work_pending(&local->rejecter));
-	ASSERT(!work_pending(&local->event_processor));
-
-	/* finish cleaning up the local descriptor */
-	rxrpc_purge_queue(&local->accept_queue);
-	rxrpc_purge_queue(&local->reject_queue);
-	rxrpc_purge_queue(&local->event_queue);
-	kernel_sock_shutdown(local->socket, SHUT_RDWR);
-	sock_release(local->socket);
-
-	up_read(&rxrpc_local_sem);
-
-	_net("DESTROY LOCAL %d", local->debug_id);
-	kfree(local);
-
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
-	_leave("");
-}
-
 /*
  * Reply to a version request
  */
@@ -377,7 +80,7 @@ static void rxrpc_send_version_request(struct rxrpc_local *local,
 /*
  * Process event packets targetted at a local endpoint.
  */
-static void rxrpc_process_local_events(struct work_struct *work)
+void rxrpc_process_local_events(struct work_struct *work)
 {
 	struct rxrpc_local *local = container_of(work, struct rxrpc_local, event_processor);
 	struct sk_buff *skb;
diff --git a/net/rxrpc/local-object.c b/net/rxrpc/local-object.c
new file mode 100644
index 000000000000..1dc701dbc715
--- /dev/null
+++ b/net/rxrpc/local-object.c
@@ -0,0 +1,316 @@
+/* Local endpoint object management
+ *
+ * Copyright (C) 2015 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/udp.h>
+#include <linux/ip.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+static LIST_HEAD(rxrpc_locals);
+DEFINE_RWLOCK(rxrpc_local_lock);
+static DECLARE_RWSEM(rxrpc_local_sem);
+static DECLARE_WAIT_QUEUE_HEAD(rxrpc_local_wq);
+
+static void rxrpc_destroy_local(struct work_struct *work);
+
+/*
+ * allocate a new local
+ */
+static
+struct rxrpc_local *rxrpc_alloc_local(struct sockaddr_rxrpc *srx)
+{
+	struct rxrpc_local *local;
+
+	local = kzalloc(sizeof(struct rxrpc_local), GFP_KERNEL);
+	if (local) {
+		INIT_WORK(&local->destroyer, &rxrpc_destroy_local);
+		INIT_WORK(&local->acceptor, &rxrpc_accept_incoming_calls);
+		INIT_WORK(&local->rejecter, &rxrpc_reject_packets);
+		INIT_WORK(&local->event_processor, &rxrpc_process_local_events);
+		INIT_LIST_HEAD(&local->services);
+		INIT_LIST_HEAD(&local->link);
+		init_rwsem(&local->defrag_sem);
+		skb_queue_head_init(&local->accept_queue);
+		skb_queue_head_init(&local->reject_queue);
+		skb_queue_head_init(&local->event_queue);
+		spin_lock_init(&local->lock);
+		rwlock_init(&local->services_lock);
+		atomic_set(&local->usage, 1);
+		local->debug_id = atomic_inc_return(&rxrpc_debug_id);
+		memcpy(&local->srx, srx, sizeof(*srx));
+	}
+
+	_leave(" = %p", local);
+	return local;
+}
+
+/*
+ * create the local socket
+ * - must be called with rxrpc_local_sem writelocked
+ */
+static int rxrpc_create_local(struct rxrpc_local *local)
+{
+	struct sock *sock;
+	int ret, opt;
+
+	_enter("%p{%d}", local, local->srx.transport_type);
+
+	/* create a socket to represent the local endpoint */
+	ret = sock_create_kern(&init_net, PF_INET, local->srx.transport_type,
+			       IPPROTO_UDP, &local->socket);
+	if (ret < 0) {
+		_leave(" = %d [socket]", ret);
+		return ret;
+	}
+
+	/* if a local address was supplied then bind it */
+	if (local->srx.transport_len > sizeof(sa_family_t)) {
+		_debug("bind");
+		ret = kernel_bind(local->socket,
+				  (struct sockaddr *) &local->srx.transport,
+				  local->srx.transport_len);
+		if (ret < 0) {
+			_debug("bind failed");
+			goto error;
+		}
+	}
+
+	/* we want to receive ICMP errors */
+	opt = 1;
+	ret = kernel_setsockopt(local->socket, SOL_IP, IP_RECVERR,
+				(char *) &opt, sizeof(opt));
+	if (ret < 0) {
+		_debug("setsockopt failed");
+		goto error;
+	}
+
+	/* we want to set the don't fragment bit */
+	opt = IP_PMTUDISC_DO;
+	ret = kernel_setsockopt(local->socket, SOL_IP, IP_MTU_DISCOVER,
+				(char *) &opt, sizeof(opt));
+	if (ret < 0) {
+		_debug("setsockopt failed");
+		goto error;
+	}
+
+	write_lock_bh(&rxrpc_local_lock);
+	list_add(&local->link, &rxrpc_locals);
+	write_unlock_bh(&rxrpc_local_lock);
+
+	/* set the socket up */
+	sock = local->socket->sk;
+	sock->sk_user_data	= local;
+	sock->sk_data_ready	= rxrpc_data_ready;
+	sock->sk_error_report	= rxrpc_UDP_error_report;
+	_leave(" = 0");
+	return 0;
+
+error:
+	kernel_sock_shutdown(local->socket, SHUT_RDWR);
+	local->socket->sk->sk_user_data = NULL;
+	sock_release(local->socket);
+	local->socket = NULL;
+
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
+ * create a new local endpoint using the specified UDP address
+ */
+struct rxrpc_local *rxrpc_lookup_local(struct sockaddr_rxrpc *srx)
+{
+	struct rxrpc_local *local;
+	int ret;
+
+	_enter("{%d,%u,%pI4+%hu}",
+	       srx->transport_type,
+	       srx->transport.family,
+	       &srx->transport.sin.sin_addr,
+	       ntohs(srx->transport.sin.sin_port));
+
+	down_write(&rxrpc_local_sem);
+
+	/* see if we have a suitable local local endpoint already */
+	read_lock_bh(&rxrpc_local_lock);
+
+	list_for_each_entry(local, &rxrpc_locals, link) {
+		_debug("CMP {%d,%u,%pI4+%hu}",
+		       local->srx.transport_type,
+		       local->srx.transport.family,
+		       &local->srx.transport.sin.sin_addr,
+		       ntohs(local->srx.transport.sin.sin_port));
+
+		if (local->srx.transport_type != srx->transport_type ||
+		    local->srx.transport.family != srx->transport.family)
+			continue;
+
+		switch (srx->transport.family) {
+		case AF_INET:
+			if (local->srx.transport.sin.sin_port !=
+			    srx->transport.sin.sin_port)
+				continue;
+			if (memcmp(&local->srx.transport.sin.sin_addr,
+				   &srx->transport.sin.sin_addr,
+				   sizeof(struct in_addr)) != 0)
+				continue;
+			goto found_local;
+
+		default:
+			BUG();
+		}
+	}
+
+	read_unlock_bh(&rxrpc_local_lock);
+
+	/* we didn't find one, so we need to create one */
+	local = rxrpc_alloc_local(srx);
+	if (!local) {
+		up_write(&rxrpc_local_sem);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	ret = rxrpc_create_local(local);
+	if (ret < 0) {
+		up_write(&rxrpc_local_sem);
+		kfree(local);
+		_leave(" = %d", ret);
+		return ERR_PTR(ret);
+	}
+
+	up_write(&rxrpc_local_sem);
+
+	_net("LOCAL new %d {%d,%u,%pI4+%hu}",
+	     local->debug_id,
+	     local->srx.transport_type,
+	     local->srx.transport.family,
+	     &local->srx.transport.sin.sin_addr,
+	     ntohs(local->srx.transport.sin.sin_port));
+
+	_leave(" = %p [new]", local);
+	return local;
+
+found_local:
+	rxrpc_get_local(local);
+	read_unlock_bh(&rxrpc_local_lock);
+	up_write(&rxrpc_local_sem);
+
+	_net("LOCAL old %d {%d,%u,%pI4+%hu}",
+	     local->debug_id,
+	     local->srx.transport_type,
+	     local->srx.transport.family,
+	     &local->srx.transport.sin.sin_addr,
+	     ntohs(local->srx.transport.sin.sin_port));
+
+	_leave(" = %p [reuse]", local);
+	return local;
+}
+
+/*
+ * release a local endpoint
+ */
+void rxrpc_put_local(struct rxrpc_local *local)
+{
+	_enter("%p{u=%d}", local, atomic_read(&local->usage));
+
+	ASSERTCMP(atomic_read(&local->usage), >, 0);
+
+	/* to prevent a race, the decrement and the dequeue must be effectively
+	 * atomic */
+	write_lock_bh(&rxrpc_local_lock);
+	if (unlikely(atomic_dec_and_test(&local->usage))) {
+		_debug("destroy local");
+		rxrpc_queue_work(&local->destroyer);
+	}
+	write_unlock_bh(&rxrpc_local_lock);
+	_leave("");
+}
+
+/*
+ * destroy a local endpoint
+ */
+static void rxrpc_destroy_local(struct work_struct *work)
+{
+	struct rxrpc_local *local =
+		container_of(work, struct rxrpc_local, destroyer);
+
+	_enter("%p{%d}", local, atomic_read(&local->usage));
+
+	down_write(&rxrpc_local_sem);
+
+	write_lock_bh(&rxrpc_local_lock);
+	if (atomic_read(&local->usage) > 0) {
+		write_unlock_bh(&rxrpc_local_lock);
+		up_read(&rxrpc_local_sem);
+		_leave(" [resurrected]");
+		return;
+	}
+
+	list_del(&local->link);
+	local->socket->sk->sk_user_data = NULL;
+	write_unlock_bh(&rxrpc_local_lock);
+
+	downgrade_write(&rxrpc_local_sem);
+
+	ASSERT(list_empty(&local->services));
+	ASSERT(!work_pending(&local->acceptor));
+	ASSERT(!work_pending(&local->rejecter));
+	ASSERT(!work_pending(&local->event_processor));
+
+	/* finish cleaning up the local descriptor */
+	rxrpc_purge_queue(&local->accept_queue);
+	rxrpc_purge_queue(&local->reject_queue);
+	rxrpc_purge_queue(&local->event_queue);
+	kernel_sock_shutdown(local->socket, SHUT_RDWR);
+	sock_release(local->socket);
+
+	up_read(&rxrpc_local_sem);
+
+	_net("DESTROY LOCAL %d", local->debug_id);
+	kfree(local);
+
+	if (list_empty(&rxrpc_locals))
+		wake_up_all(&rxrpc_local_wq);
+
+	_leave("");
+}
+
+/*
+ * preemptively destroy all local local endpoint rather than waiting for
+ * them to be destroyed
+ */
+void __exit rxrpc_destroy_all_locals(void)
+{
+	DECLARE_WAITQUEUE(myself,current);
+
+	_enter("");
+
+	/* we simply have to wait for them to go away */
+	if (!list_empty(&rxrpc_locals)) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		add_wait_queue(&rxrpc_local_wq, &myself);
+
+		while (!list_empty(&rxrpc_locals)) {
+			schedule();
+			set_current_state(TASK_UNINTERRUPTIBLE);
+		}
+
+		remove_wait_queue(&rxrpc_local_wq, &myself);
+		set_current_state(TASK_RUNNING);
+	}
+
+	_leave("");
+}
