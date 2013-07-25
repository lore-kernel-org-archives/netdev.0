From: Asias He <asias@redhat.com>
Subject: [PATCH net-next] VSOCK: Move af_vsock.h and vsock_addr.h to include/net
Date: Thu, 25 Jul 2013 17:39:34 +0800
Message-ID: <1374745174-9859-1-git-send-email-asias@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy King <acking@vmware.com>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>, Asias He <asias@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753636Ab3GYJju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 05:39:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is useful for other VSOCK transport implemented outside the
net/vmw_vsock/ directory to use these headers.

Signed-off-by: Asias He <asias@redhat.com>
---
 include/net/af_vsock.h         | 175 +++++++++++++++++++++++++++++++++++++++++
 include/net/vsock_addr.h       |  30 +++++++
 net/vmw_vsock/af_vsock.c       |   3 +-
 net/vmw_vsock/af_vsock.h       | 175 -----------------------------------------
 net/vmw_vsock/vmci_transport.c |   2 +-
 net/vmw_vsock/vmci_transport.h |   4 +-
 net/vmw_vsock/vsock_addr.c     |   3 +-
 net/vmw_vsock/vsock_addr.h     |  30 -------
 8 files changed, 210 insertions(+), 212 deletions(-)
 create mode 100644 include/net/af_vsock.h
 create mode 100644 include/net/vsock_addr.h
 delete mode 100644 net/vmw_vsock/af_vsock.h
 delete mode 100644 net/vmw_vsock/vsock_addr.h

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
new file mode 100644
index 0000000..7d64d36
--- /dev/null
+++ b/include/net/af_vsock.h
@@ -0,0 +1,175 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2007-2013 VMware, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation version 2 and no later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#ifndef __AF_VSOCK_H__
+#define __AF_VSOCK_H__
+
+#include <linux/kernel.h>
+#include <linux/workqueue.h>
+#include <linux/vm_sockets.h>
+
+#include "vsock_addr.h"
+
+#define LAST_RESERVED_PORT 1023
+
+#define vsock_sk(__sk)    ((struct vsock_sock *)__sk)
+#define sk_vsock(__vsk)   (&(__vsk)->sk)
+
+struct vsock_sock {
+	/* sk must be the first member. */
+	struct sock sk;
+	struct sockaddr_vm local_addr;
+	struct sockaddr_vm remote_addr;
+	/* Links for the global tables of bound and connected sockets. */
+	struct list_head bound_table;
+	struct list_head connected_table;
+	/* Accessed without the socket lock held. This means it can never be
+	 * modified outsided of socket create or destruct.
+	 */
+	bool trusted;
+	bool cached_peer_allow_dgram;	/* Dgram communication allowed to
+					 * cached peer?
+					 */
+	u32 cached_peer;  /* Context ID of last dgram destination check. */
+	const struct cred *owner;
+	/* Rest are SOCK_STREAM only. */
+	long connect_timeout;
+	/* Listening socket that this came from. */
+	struct sock *listener;
+	/* Used for pending list and accept queue during connection handshake.
+	 * The listening socket is the head for both lists.  Sockets created
+	 * for connection requests are placed in the pending list until they
+	 * are connected, at which point they are put in the accept queue list
+	 * so they can be accepted in accept().  If accept() cannot accept the
+	 * connection, it is marked as rejected so the cleanup function knows
+	 * to clean up the socket.
+	 */
+	struct list_head pending_links;
+	struct list_head accept_queue;
+	bool rejected;
+	struct delayed_work dwork;
+	u32 peer_shutdown;
+	bool sent_request;
+	bool ignore_connecting_rst;
+
+	/* Private to transport. */
+	void *trans;
+};
+
+s64 vsock_stream_has_data(struct vsock_sock *vsk);
+s64 vsock_stream_has_space(struct vsock_sock *vsk);
+void vsock_pending_work(struct work_struct *work);
+struct sock *__vsock_create(struct net *net,
+			    struct socket *sock,
+			    struct sock *parent,
+			    gfp_t priority, unsigned short type);
+
+/**** TRANSPORT ****/
+
+struct vsock_transport_recv_notify_data {
+	u64 data1; /* Transport-defined. */
+	u64 data2; /* Transport-defined. */
+	bool notify_on_block;
+};
+
+struct vsock_transport_send_notify_data {
+	u64 data1; /* Transport-defined. */
+	u64 data2; /* Transport-defined. */
+};
+
+struct vsock_transport {
+	/* Initialize/tear-down socket. */
+	int (*init)(struct vsock_sock *, struct vsock_sock *);
+	void (*destruct)(struct vsock_sock *);
+	void (*release)(struct vsock_sock *);
+
+	/* Connections. */
+	int (*connect)(struct vsock_sock *);
+
+	/* DGRAM. */
+	int (*dgram_bind)(struct vsock_sock *, struct sockaddr_vm *);
+	int (*dgram_dequeue)(struct kiocb *kiocb, struct vsock_sock *vsk,
+			     struct msghdr *msg, size_t len, int flags);
+	int (*dgram_enqueue)(struct vsock_sock *, struct sockaddr_vm *,
+			     struct iovec *, size_t len);
+	bool (*dgram_allow)(u32 cid, u32 port);
+
+	/* STREAM. */
+	/* TODO: stream_bind() */
+	ssize_t (*stream_dequeue)(struct vsock_sock *, struct iovec *,
+				  size_t len, int flags);
+	ssize_t (*stream_enqueue)(struct vsock_sock *, struct iovec *,
+				  size_t len);
+	s64 (*stream_has_data)(struct vsock_sock *);
+	s64 (*stream_has_space)(struct vsock_sock *);
+	u64 (*stream_rcvhiwat)(struct vsock_sock *);
+	bool (*stream_is_active)(struct vsock_sock *);
+	bool (*stream_allow)(u32 cid, u32 port);
+
+	/* Notification. */
+	int (*notify_poll_in)(struct vsock_sock *, size_t, bool *);
+	int (*notify_poll_out)(struct vsock_sock *, size_t, bool *);
+	int (*notify_recv_init)(struct vsock_sock *, size_t,
+		struct vsock_transport_recv_notify_data *);
+	int (*notify_recv_pre_block)(struct vsock_sock *, size_t,
+		struct vsock_transport_recv_notify_data *);
+	int (*notify_recv_pre_dequeue)(struct vsock_sock *, size_t,
+		struct vsock_transport_recv_notify_data *);
+	int (*notify_recv_post_dequeue)(struct vsock_sock *, size_t,
+		ssize_t, bool, struct vsock_transport_recv_notify_data *);
+	int (*notify_send_init)(struct vsock_sock *,
+		struct vsock_transport_send_notify_data *);
+	int (*notify_send_pre_block)(struct vsock_sock *,
+		struct vsock_transport_send_notify_data *);
+	int (*notify_send_pre_enqueue)(struct vsock_sock *,
+		struct vsock_transport_send_notify_data *);
+	int (*notify_send_post_enqueue)(struct vsock_sock *, ssize_t,
+		struct vsock_transport_send_notify_data *);
+
+	/* Shutdown. */
+	int (*shutdown)(struct vsock_sock *, int);
+
+	/* Buffer sizes. */
+	void (*set_buffer_size)(struct vsock_sock *, u64);
+	void (*set_min_buffer_size)(struct vsock_sock *, u64);
+	void (*set_max_buffer_size)(struct vsock_sock *, u64);
+	u64 (*get_buffer_size)(struct vsock_sock *);
+	u64 (*get_min_buffer_size)(struct vsock_sock *);
+	u64 (*get_max_buffer_size)(struct vsock_sock *);
+
+	/* Addressing. */
+	u32 (*get_local_cid)(void);
+};
+
+/**** CORE ****/
+
+int vsock_core_init(const struct vsock_transport *t);
+void vsock_core_exit(void);
+
+/**** UTILS ****/
+
+void vsock_release_pending(struct sock *pending);
+void vsock_add_pending(struct sock *listener, struct sock *pending);
+void vsock_remove_pending(struct sock *listener, struct sock *pending);
+void vsock_enqueue_accept(struct sock *listener, struct sock *connected);
+void vsock_insert_connected(struct vsock_sock *vsk);
+void vsock_remove_bound(struct vsock_sock *vsk);
+void vsock_remove_connected(struct vsock_sock *vsk);
+struct sock *vsock_find_bound_socket(struct sockaddr_vm *addr);
+struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
+					 struct sockaddr_vm *dst);
+void vsock_for_each_connected_socket(void (*fn)(struct sock *sk));
+
+#endif /* __AF_VSOCK_H__ */
diff --git a/include/net/vsock_addr.h b/include/net/vsock_addr.h
new file mode 100644
index 0000000..9ccd531
--- /dev/null
+++ b/include/net/vsock_addr.h
@@ -0,0 +1,30 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2007-2013 VMware, Inc. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation version 2 and no later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#ifndef _VSOCK_ADDR_H_
+#define _VSOCK_ADDR_H_
+
+#include <linux/vm_sockets.h>
+
+void vsock_addr_init(struct sockaddr_vm *addr, u32 cid, u32 port);
+int vsock_addr_validate(const struct sockaddr_vm *addr);
+bool vsock_addr_bound(const struct sockaddr_vm *addr);
+void vsock_addr_unbind(struct sockaddr_vm *addr);
+bool vsock_addr_equals_addr(const struct sockaddr_vm *addr,
+			    const struct sockaddr_vm *other);
+int vsock_addr_cast(const struct sockaddr *addr, size_t len,
+		    struct sockaddr_vm **out_addr);
+
+#endif
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 593071d..57896ee 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -96,8 +96,7 @@
 #include <linux/wait.h>
 #include <linux/workqueue.h>
 #include <net/sock.h>
-
-#include "af_vsock.h"
+#include <net/af_vsock.h>
 
 static int __vsock_bind(struct sock *sk, struct sockaddr_vm *addr);
 static void vsock_sk_destruct(struct sock *sk);
diff --git a/net/vmw_vsock/af_vsock.h b/net/vmw_vsock/af_vsock.h
deleted file mode 100644
index 7d64d36..0000000
--- a/net/vmw_vsock/af_vsock.h
+++ /dev/null
@@ -1,175 +0,0 @@
-/*
- * VMware vSockets Driver
- *
- * Copyright (C) 2007-2013 VMware, Inc. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License as published by the Free
- * Software Foundation version 2 and no later version.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- */
-
-#ifndef __AF_VSOCK_H__
-#define __AF_VSOCK_H__
-
-#include <linux/kernel.h>
-#include <linux/workqueue.h>
-#include <linux/vm_sockets.h>
-
-#include "vsock_addr.h"
-
-#define LAST_RESERVED_PORT 1023
-
-#define vsock_sk(__sk)    ((struct vsock_sock *)__sk)
-#define sk_vsock(__vsk)   (&(__vsk)->sk)
-
-struct vsock_sock {
-	/* sk must be the first member. */
-	struct sock sk;
-	struct sockaddr_vm local_addr;
-	struct sockaddr_vm remote_addr;
-	/* Links for the global tables of bound and connected sockets. */
-	struct list_head bound_table;
-	struct list_head connected_table;
-	/* Accessed without the socket lock held. This means it can never be
-	 * modified outsided of socket create or destruct.
-	 */
-	bool trusted;
-	bool cached_peer_allow_dgram;	/* Dgram communication allowed to
-					 * cached peer?
-					 */
-	u32 cached_peer;  /* Context ID of last dgram destination check. */
-	const struct cred *owner;
-	/* Rest are SOCK_STREAM only. */
-	long connect_timeout;
-	/* Listening socket that this came from. */
-	struct sock *listener;
-	/* Used for pending list and accept queue during connection handshake.
-	 * The listening socket is the head for both lists.  Sockets created
-	 * for connection requests are placed in the pending list until they
-	 * are connected, at which point they are put in the accept queue list
-	 * so they can be accepted in accept().  If accept() cannot accept the
-	 * connection, it is marked as rejected so the cleanup function knows
-	 * to clean up the socket.
-	 */
-	struct list_head pending_links;
-	struct list_head accept_queue;
-	bool rejected;
-	struct delayed_work dwork;
-	u32 peer_shutdown;
-	bool sent_request;
-	bool ignore_connecting_rst;
-
-	/* Private to transport. */
-	void *trans;
-};
-
-s64 vsock_stream_has_data(struct vsock_sock *vsk);
-s64 vsock_stream_has_space(struct vsock_sock *vsk);
-void vsock_pending_work(struct work_struct *work);
-struct sock *__vsock_create(struct net *net,
-			    struct socket *sock,
-			    struct sock *parent,
-			    gfp_t priority, unsigned short type);
-
-/**** TRANSPORT ****/
-
-struct vsock_transport_recv_notify_data {
-	u64 data1; /* Transport-defined. */
-	u64 data2; /* Transport-defined. */
-	bool notify_on_block;
-};
-
-struct vsock_transport_send_notify_data {
-	u64 data1; /* Transport-defined. */
-	u64 data2; /* Transport-defined. */
-};
-
-struct vsock_transport {
-	/* Initialize/tear-down socket. */
-	int (*init)(struct vsock_sock *, struct vsock_sock *);
-	void (*destruct)(struct vsock_sock *);
-	void (*release)(struct vsock_sock *);
-
-	/* Connections. */
-	int (*connect)(struct vsock_sock *);
-
-	/* DGRAM. */
-	int (*dgram_bind)(struct vsock_sock *, struct sockaddr_vm *);
-	int (*dgram_dequeue)(struct kiocb *kiocb, struct vsock_sock *vsk,
-			     struct msghdr *msg, size_t len, int flags);
-	int (*dgram_enqueue)(struct vsock_sock *, struct sockaddr_vm *,
-			     struct iovec *, size_t len);
-	bool (*dgram_allow)(u32 cid, u32 port);
-
-	/* STREAM. */
-	/* TODO: stream_bind() */
-	ssize_t (*stream_dequeue)(struct vsock_sock *, struct iovec *,
-				  size_t len, int flags);
-	ssize_t (*stream_enqueue)(struct vsock_sock *, struct iovec *,
-				  size_t len);
-	s64 (*stream_has_data)(struct vsock_sock *);
-	s64 (*stream_has_space)(struct vsock_sock *);
-	u64 (*stream_rcvhiwat)(struct vsock_sock *);
-	bool (*stream_is_active)(struct vsock_sock *);
-	bool (*stream_allow)(u32 cid, u32 port);
-
-	/* Notification. */
-	int (*notify_poll_in)(struct vsock_sock *, size_t, bool *);
-	int (*notify_poll_out)(struct vsock_sock *, size_t, bool *);
-	int (*notify_recv_init)(struct vsock_sock *, size_t,
-		struct vsock_transport_recv_notify_data *);
-	int (*notify_recv_pre_block)(struct vsock_sock *, size_t,
-		struct vsock_transport_recv_notify_data *);
-	int (*notify_recv_pre_dequeue)(struct vsock_sock *, size_t,
-		struct vsock_transport_recv_notify_data *);
-	int (*notify_recv_post_dequeue)(struct vsock_sock *, size_t,
-		ssize_t, bool, struct vsock_transport_recv_notify_data *);
-	int (*notify_send_init)(struct vsock_sock *,
-		struct vsock_transport_send_notify_data *);
-	int (*notify_send_pre_block)(struct vsock_sock *,
-		struct vsock_transport_send_notify_data *);
-	int (*notify_send_pre_enqueue)(struct vsock_sock *,
-		struct vsock_transport_send_notify_data *);
-	int (*notify_send_post_enqueue)(struct vsock_sock *, ssize_t,
-		struct vsock_transport_send_notify_data *);
-
-	/* Shutdown. */
-	int (*shutdown)(struct vsock_sock *, int);
-
-	/* Buffer sizes. */
-	void (*set_buffer_size)(struct vsock_sock *, u64);
-	void (*set_min_buffer_size)(struct vsock_sock *, u64);
-	void (*set_max_buffer_size)(struct vsock_sock *, u64);
-	u64 (*get_buffer_size)(struct vsock_sock *);
-	u64 (*get_min_buffer_size)(struct vsock_sock *);
-	u64 (*get_max_buffer_size)(struct vsock_sock *);
-
-	/* Addressing. */
-	u32 (*get_local_cid)(void);
-};
-
-/**** CORE ****/
-
-int vsock_core_init(const struct vsock_transport *t);
-void vsock_core_exit(void);
-
-/**** UTILS ****/
-
-void vsock_release_pending(struct sock *pending);
-void vsock_add_pending(struct sock *listener, struct sock *pending);
-void vsock_remove_pending(struct sock *listener, struct sock *pending);
-void vsock_enqueue_accept(struct sock *listener, struct sock *connected);
-void vsock_insert_connected(struct vsock_sock *vsk);
-void vsock_remove_bound(struct vsock_sock *vsk);
-void vsock_remove_connected(struct vsock_sock *vsk);
-struct sock *vsock_find_bound_socket(struct sockaddr_vm *addr);
-struct sock *vsock_find_connected_socket(struct sockaddr_vm *src,
-					 struct sockaddr_vm *dst);
-void vsock_for_each_connected_socket(void (*fn)(struct sock *sk));
-
-#endif /* __AF_VSOCK_H__ */
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index ffc11df..9d69866 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -34,8 +34,8 @@
 #include <linux/wait.h>
 #include <linux/workqueue.h>
 #include <net/sock.h>
+#include <net/af_vsock.h>
 
-#include "af_vsock.h"
 #include "vmci_transport_notify.h"
 
 static int vmci_transport_recv_dgram_cb(void *data, struct vmci_datagram *dg);
diff --git a/net/vmw_vsock/vmci_transport.h b/net/vmw_vsock/vmci_transport.h
index fd88ea8..ce6c962 100644
--- a/net/vmw_vsock/vmci_transport.h
+++ b/net/vmw_vsock/vmci_transport.h
@@ -19,8 +19,8 @@
 #include <linux/vmw_vmci_defs.h>
 #include <linux/vmw_vmci_api.h>
 
-#include "vsock_addr.h"
-#include "af_vsock.h"
+#include <net/vsock_addr.h>
+#include <net/af_vsock.h>
 
 /* If the packet format changes in a release then this should change too. */
 #define VMCI_TRANSPORT_PACKET_VERSION 1
diff --git a/net/vmw_vsock/vsock_addr.c b/net/vmw_vsock/vsock_addr.c
index ec2611b..82486ee 100644
--- a/net/vmw_vsock/vsock_addr.c
+++ b/net/vmw_vsock/vsock_addr.c
@@ -17,8 +17,7 @@
 #include <linux/socket.h>
 #include <linux/stddef.h>
 #include <net/sock.h>
-
-#include "vsock_addr.h"
+#include <net/vsock_addr.h>
 
 void vsock_addr_init(struct sockaddr_vm *addr, u32 cid, u32 port)
 {
diff --git a/net/vmw_vsock/vsock_addr.h b/net/vmw_vsock/vsock_addr.h
deleted file mode 100644
index 9ccd531..0000000
--- a/net/vmw_vsock/vsock_addr.h
+++ /dev/null
@@ -1,30 +0,0 @@
-/*
- * VMware vSockets Driver
- *
- * Copyright (C) 2007-2013 VMware, Inc. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License as published by the Free
- * Software Foundation version 2 and no later version.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- */
-
-#ifndef _VSOCK_ADDR_H_
-#define _VSOCK_ADDR_H_
-
-#include <linux/vm_sockets.h>
-
-void vsock_addr_init(struct sockaddr_vm *addr, u32 cid, u32 port);
-int vsock_addr_validate(const struct sockaddr_vm *addr);
-bool vsock_addr_bound(const struct sockaddr_vm *addr);
-void vsock_addr_unbind(struct sockaddr_vm *addr);
-bool vsock_addr_equals_addr(const struct sockaddr_vm *addr,
-			    const struct sockaddr_vm *other);
-int vsock_addr_cast(const struct sockaddr *addr, size_t len,
-		    struct sockaddr_vm **out_addr);
-
-#endif
-- 
1.8.3.1
