From: George Zhang <georgezhang@vmware.com>
Subject: [PATCH 5/6] VSOCK: utility functions.
Date: Wed, 21 Nov 2012 12:40:36 -0800
Message-ID: <20121121204029.14395.74016.stgit@promb-2n-dhcp175.eng.vmware.com>
References: <20121121203715.14395.27632.stgit@promb-2n-dhcp175.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	georgezhang@vmware.com, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121121203715.14395.27632.stgit@promb-2n-dhcp175.eng.vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

VSOCK utility functions for Linux VSocket module.

Signed-off-by: George Zhang <georgezhang@vmware.com>
Signed-off-by: Dmitry Torokhov <dtor@vmware.com>
Signed-off-by: Andy King <acking@vmware.com>

---
 net/vmw_vsock/util.c |  620 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/vmw_vsock/util.h |  314 +++++++++++++++++++++++++
 2 files changed, 934 insertions(+), 0 deletions(-)
 create mode 100644 net/vmw_vsock/util.c
 create mode 100644 net/vmw_vsock/util.h

diff --git a/net/vmw_vsock/util.c b/net/vmw_vsock/util.c
new file mode 100644
index 0000000..cd86482
--- /dev/null
+++ b/net/vmw_vsock/util.c
@@ -0,0 +1,620 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2007-2012 VMware, Inc. All rights reserved.
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
+/*
+ * util.c --
+ *
+ * Utility functions for Linux VSocket module.
+ */
+
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/socket.h>
+#include <linux/stddef.h>	/* for NULL */
+#include <net/sock.h>
+
+#include "af_vsock.h"
+#include "util.h"
+
+struct list_head vsock_bind_table[VSOCK_HASH_SIZE + 1];
+struct list_head vsock_connected_table[VSOCK_HASH_SIZE];
+
+DEFINE_SPINLOCK(vsock_table_lock);
+
+/*
+ *
+ * vsock_vmci_log_pkt --
+ *
+ * Logs the provided packet.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+void vsock_vmci_log_pkt(char const *function, u32 line,
+			struct vsock_packet *pkt)
+{
+	char buf[256];
+	char *cur = buf;
+	int left = sizeof buf;
+	int written = 0;
+	char *type_strings[] = {
+		[VSOCK_PACKET_TYPE_INVALID] = "INVALID",
+		[VSOCK_PACKET_TYPE_REQUEST] = "REQUEST",
+		[VSOCK_PACKET_TYPE_NEGOTIATE] = "NEGOTIATE",
+		[VSOCK_PACKET_TYPE_OFFER] = "OFFER",
+		[VSOCK_PACKET_TYPE_ATTACH] = "ATTACH",
+		[VSOCK_PACKET_TYPE_WROTE] = "WROTE",
+		[VSOCK_PACKET_TYPE_READ] = "READ",
+		[VSOCK_PACKET_TYPE_RST] = "RST",
+		[VSOCK_PACKET_TYPE_SHUTDOWN] = "SHUTDOWN",
+		[VSOCK_PACKET_TYPE_WAITING_WRITE] = "WAITING_WRITE",
+		[VSOCK_PACKET_TYPE_WAITING_READ] = "WAITING_READ",
+		[VSOCK_PACKET_TYPE_REQUEST2] = "REQUEST2",
+		[VSOCK_PACKET_TYPE_NEGOTIATE2] = "NEGOTIATE2",
+	};
+
+	written = snprintf(cur, left, "PKT: %u:%u -> %u:%u",
+			   VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.src),
+			   pkt->src_port,
+			   VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.dst),
+			   pkt->dst_port);
+	if (written >= left)
+		goto error;
+
+	left -= written;
+	cur += written;
+
+	switch (pkt->type) {
+	case VSOCK_PACKET_TYPE_REQUEST:
+	case VSOCK_PACKET_TYPE_NEGOTIATE:
+		written = snprintf(cur, left, ", %s, size = %" FMT64 "u",
+				   type_strings[pkt->type], pkt->u.size);
+		break;
+
+	case VSOCK_PACKET_TYPE_OFFER:
+	case VSOCK_PACKET_TYPE_ATTACH:
+		written = snprintf(cur, left, ", %s, handle = %u:%u",
+				   type_strings[pkt->type],
+				   VMCI_HANDLE_TO_CONTEXT_ID(pkt->u.handle),
+				   VMCI_HANDLE_TO_RESOURCE_ID(pkt->u.handle));
+		break;
+
+	case VSOCK_PACKET_TYPE_WROTE:
+	case VSOCK_PACKET_TYPE_READ:
+	case VSOCK_PACKET_TYPE_RST:
+		written = snprintf(cur, left, ", %s", type_strings[pkt->type]);
+		break;
+	case VSOCK_PACKET_TYPE_SHUTDOWN: {
+		bool recv;
+		bool send;
+
+		recv = pkt->u.mode & RCV_SHUTDOWN;
+		send = pkt->u.mode & SEND_SHUTDOWN;
+		written = snprintf(cur, left, ", %s, mode = %c%c",
+				   type_strings[pkt->type],
+				   recv ? 'R' : ' ', send ? 'S' : ' ');
+	}
+	break;
+
+	case VSOCK_PACKET_TYPE_WAITING_WRITE:
+	case VSOCK_PACKET_TYPE_WAITING_READ:
+		written = snprintf(cur, left,
+			", %s, generation = %" FMT64 "u, offset = %" FMT64 "u",
+			type_strings[pkt->type],
+			pkt->u.wait.generation, pkt->u.wait.offset);
+
+		break;
+
+	case VSOCK_PACKET_TYPE_REQUEST2:
+	case VSOCK_PACKET_TYPE_NEGOTIATE2:
+		written = snprintf(cur, left,
+				   ", %s, size = %" FMT64 "u, proto = %u",
+				   type_strings[pkt->type], pkt->u.size,
+				   pkt->proto);
+		break;
+
+	default:
+		written = snprintf(cur, left, ", unrecognized type");
+	}
+
+	if (written >= left)
+		goto error;
+
+	left -= written;
+	cur += written;
+
+	written = snprintf(cur, left, "  [%s:%u]\n", function, line);
+	if (written >= left)
+		goto error;
+
+	return;
+
+error:
+	pr_err("could not log packet\n");
+}
+
+/*
+ *
+ * vsock_vmci_init_tables --
+ *
+ * Initializes the tables used for socket lookup.
+ *
+ * Results: None.
+ *
+ * Side effects: None.
+ */
+
+void vsock_vmci_init_tables(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(vsock_bind_table); i++)
+		INIT_LIST_HEAD(&vsock_bind_table[i]);
+
+	for (i = 0; i < ARRAY_SIZE(vsock_connected_table); i++)
+		INIT_LIST_HEAD(&vsock_connected_table[i]);
+}
+
+/*
+ *
+ * __vsock_vmci_insert_bound --
+ *
+ * Inserts socket into the bound table.
+ *
+ * Note that this assumes any necessary locks are held.
+ *
+ * Results: None.
+ *
+ * Side effects: The reference count for sk is incremented.
+ */
+
+void __vsock_vmci_insert_bound(struct list_head *list, struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	sock_hold(sk);
+	list_add(&vsk->bound_table, list);
+}
+
+/*
+ *
+ * __vsock_vmci_insert_connected --
+ *
+ * Inserts socket into the connected table.
+ *
+ * Note that this assumes any necessary locks are held.
+ *
+ * Results: None.
+ *
+ * Side effects: The reference count for sk is incremented.
+ */
+
+void __vsock_vmci_insert_connected(struct list_head *list, struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	sock_hold(sk);
+	list_add(&vsk->connected_table, list);
+}
+
+/*
+ *
+ * __vsock_vmci_remove_bound --
+ *
+ * Removes socket from the bound table.
+ *
+ * Note that this assumes any necessary locks are held.
+ *
+ * Results: None.
+ *
+ * Side effects: The reference count for sk is decremented.
+ */
+
+void __vsock_vmci_remove_bound(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk;
+
+	vsk = vsock_sk(sk);
+
+	list_del_init(&vsk->bound_table);
+	sock_put(sk);
+}
+
+/*
+ *
+ * __vsock_vmci_remove_connected --
+ *
+ * Removes socket from the connected table.
+ *
+ * Note that this assumes any necessary locks are held.
+ *
+ * Results: None.
+ *
+ * Side effects: The reference count for sk is decremented.
+ */
+
+void __vsock_vmci_remove_connected(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk;
+
+	vsk = vsock_sk(sk);
+
+	list_del_init(&vsk->connected_table);
+	sock_put(sk);
+}
+
+/*
+ *
+ * __vsock_vmci_find_bound_socket --
+ *
+ * Finds the socket corresponding to the provided address in the bound sockets
+ * hash table.
+ *
+ * Note that this assumes any necessary locks are held.
+ *
+ * Results: The sock structure if found, NULL if not found.
+ *
+ * Side effects: None.
+ */
+
+struct sock *__vsock_vmci_find_bound_socket(struct sockaddr_vm *addr)
+{
+	struct vsock_vmci_sock *vsk;
+
+	list_for_each_entry(vsk, vsock_bound_sockets(addr), bound_table) {
+		if (vsock_addr_equals_addr_any(addr, &vsk->local_addr))
+			return sk_vsock(vsk);
+	}
+
+	return NULL;
+}
+
+/*
+ *
+ * __vsock_vmci_find_connected_socket --
+ *
+ * Finds the socket corresponding to the provided addresses in the connected
+ * sockets hash table.
+ *
+ * Note that this assumes any necessary locks are held.
+ *
+ * Results: The sock structure if found, NULL if not found.
+ *
+ * Side effects: None.
+ */
+
+struct sock *__vsock_vmci_find_connected_socket(struct sockaddr_vm *src,
+						struct sockaddr_vm *dst)
+{
+	struct vsock_vmci_sock *vsk;
+
+	list_for_each_entry(vsk, vsock_connected_sockets(src, dst),
+			    connected_table) {
+		if (vsock_addr_equals_addr(src, &vsk->remote_addr)
+		    && vsock_addr_equals_addr(dst, &vsk->local_addr)) {
+			return sk_vsock(vsk);
+		}
+	}
+
+	return NULL;
+}
+
+/*
+ *
+ * __vsock_vmci_in_bound_table --
+ *
+ * Determines whether the provided socket is in the bound table.
+ *
+ * Results: TRUE is socket is in bound table, FALSE otherwise.
+ *
+ * Side effects: None.
+ */
+
+bool __vsock_vmci_in_bound_table(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	return !list_empty(&vsk->bound_table);
+}
+
+/*
+ *
+ * __vsock_vmci_in_connected_table --
+ *
+ * Determines whether the provided socket is in the connected table.
+ *
+ * Results: TRUE is socket is in connected table, FALSE otherwise.
+ *
+ * Side effects: None.
+ */
+
+bool __vsock_vmci_in_connected_table(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+
+	return !list_empty(&vsk->connected_table);
+}
+
+/*
+ *
+ * vsock_vmci_get_pending --
+ *
+ * Retrieves a pending connection that matches the addresses specified in the
+ * provided packet.
+ *
+ * Assumes the socket lock is held for listener.
+ *
+ * Results: Socket of the pending connection on success, NULL if not found.
+ *
+ * Side effects: A reference is held on the socket until the release function
+ * is called.
+ */
+
+struct sock *vsock_vmci_get_pending(struct sock *listener,
+				    struct vsock_packet *pkt)
+{
+	struct vsock_vmci_sock *vlistener;
+	struct vsock_vmci_sock *vpending;
+	struct sock *pending;
+
+	vlistener = vsock_sk(listener);
+
+	list_for_each_entry(vpending, &vlistener->pending_links,
+			    pending_links) {
+		struct sockaddr_vm src;
+		struct sockaddr_vm dst;
+
+		vsock_addr_init(&src, VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.src),
+				pkt->src_port);
+		vsock_addr_init(&dst, VMCI_HANDLE_TO_CONTEXT_ID(pkt->dg.dst),
+				pkt->dst_port);
+
+		if (vsock_addr_equals_addr(&src, &vpending->remote_addr) &&
+		    vsock_addr_equals_addr(&dst, &vpending->local_addr)) {
+			pending = sk_vsock(vpending);
+			sock_hold(pending);
+			goto found;
+		}
+	}
+
+	pending = NULL;
+found:
+	return pending;
+
+}
+
+/*
+ *
+ * vsock_vmci_release_pending --
+ *
+ * Releases the reference on a socket previously obtained by a call to
+ * vsock_vmci_get_pending().
+ *
+ * Results: None.
+ *
+ * Side effects: The socket may be freed if this was the last reference.
+ */
+
+void vsock_vmci_release_pending(struct sock *pending)
+{
+	sock_put(pending);
+}
+
+/*
+ *
+ * vsock_vmci_add_pending --
+ *
+ * Adds a pending connection on listener's pending list.
+ *
+ * Assumes the socket lock is held for listener. Assumes the socket lock is
+ * held for pending.
+ *
+ * Results: None.
+ *
+ * Side effects: The reference count of the sockets is incremented.
+ */
+
+void vsock_vmci_add_pending(struct sock *listener, struct sock *pending)
+{
+	struct vsock_vmci_sock *vlistener;
+	struct vsock_vmci_sock *vpending;
+
+	vlistener = vsock_sk(listener);
+	vpending = vsock_sk(pending);
+
+	sock_hold(pending);
+	sock_hold(listener);
+	list_add_tail(&vpending->pending_links, &vlistener->pending_links);
+}
+
+/*
+ *
+ * vsock_vmci_remove_pending --
+ *
+ * Removes a pending connection from the listener's pending list.
+ *
+ * Assumes the socket lock is held for listener. Assumes the socket lock is
+ * held for pending.
+ *
+ * Results: None.
+ *
+ * Side effects: The reference count of the sockets is decremented.
+ */
+
+void vsock_vmci_remove_pending(struct sock *listener, struct sock *pending)
+{
+	struct vsock_vmci_sock *vpending = vsock_sk(pending);
+
+	list_del_init(&vpending->pending_links);
+	sock_put(listener);
+	sock_put(pending);
+}
+
+/*
+ *
+ * vsock_vmci_enqueue_accept --
+ *
+ * Enqueues the connected socket on the listening socket's accepting queue.
+ *
+ * Assumes the socket lock is held for listener. Assumes the socket lock is
+ * held for connected.
+ *
+ * Results: None.
+ *
+ * Side effects: The sockets' reference counts are incremented.
+ */
+
+void vsock_vmci_enqueue_accept(struct sock *listener, struct sock *connected)
+{
+	struct vsock_vmci_sock *vlistener;
+	struct vsock_vmci_sock *vconnected;
+
+	vlistener = vsock_sk(listener);
+	vconnected = vsock_sk(connected);
+
+	sock_hold(connected);
+	sock_hold(listener);
+	list_add_tail(&vconnected->accept_queue, &vlistener->accept_queue);
+}
+
+/*
+ *
+ * vsock_vmci_dequeue_accept --
+ *
+ * Dequeues the next connected socket from the listening socket's accept queue.
+ *
+ * Assumes the socket lock is held for listener.
+ *
+ * Note that the caller must call sock_put() on the returned socket once it is
+ * done with the socket.
+ *
+ * Results: The next socket from the queue, or NULL if the queue is empty.
+ *
+ * Side effects: The reference count of the listener is decremented.
+ */
+
+struct sock *vsock_vmci_dequeue_accept(struct sock *listener)
+{
+	struct vsock_vmci_sock *vlistener;
+	struct vsock_vmci_sock *vconnected;
+
+	vlistener = vsock_sk(listener);
+
+	if (list_empty(&vlistener->accept_queue))
+		return NULL;
+
+	vconnected = list_entry(vlistener->accept_queue.next,
+				struct vsock_vmci_sock, accept_queue);
+
+	list_del_init(&vconnected->accept_queue);
+	sock_put(listener);
+	/*
+	 * The caller will need a reference on the connected socket so we let
+	 * it call sock_put().
+	 */
+
+	return sk_vsock(vconnected);
+}
+
+/*
+ *
+ * vsock_vmci_remove_accept --
+ *
+ * Removes a socket from the accept queue of a listening socket.
+ *
+ * Assumes the socket lock is held for listener. Assumes the socket lock is
+ * held for connected.
+ *
+ * Results: None.
+ *
+ * Side effects: The sockets' reference counts are decremented.
+ */
+
+void vsock_vmci_remove_accept(struct sock *listener, struct sock *connected)
+{
+	struct vsock_vmci_sock *vconnected;
+
+	if (!vsock_vmci_in_accept_queue(connected))
+		return;
+
+	vconnected = vsock_sk(connected);
+
+	list_del_init(&vconnected->accept_queue);
+	sock_put(listener);
+	sock_put(connected);
+}
+
+/*
+ *
+ * vsock_vmci_in_accept_queue --
+ *
+ * Determines whether a socket is on an accept queue.
+ *
+ * Assumes the socket lock is held for sk.
+ *
+ * Results: TRUE if the socket is in an accept queue, FALSE otherwise.
+ *
+ * Side effects: None.
+ */
+
+bool vsock_vmci_in_accept_queue(struct sock *sk)
+{
+	/*
+	 * If our accept queue isn't empty, it means we're linked into some
+	 * listener socket's accept queue.
+	 */
+	return !vsock_vmci_is_accept_queue_empty(sk);
+}
+
+/*
+ *
+ * vsock_vmci_is_accept_queue_empty --
+ *
+ * Determines whether the provided socket's accept queue is empty.
+ *
+ * Assumes the socket lock is held for sk.
+ *
+ * Results: TRUE if the socket's accept queue is empty, FALSE otherwsise.
+ *
+ * Side effects: None.
+ *
+ */
+
+bool vsock_vmci_is_accept_queue_empty(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+	return list_empty(&vsk->accept_queue);
+}
+
+/*
+ *
+ * vsock_vmci_is_pending --
+ *
+ * Determines whether a socket is pending.
+ *
+ * Assumes the socket lock is held for sk.
+ *
+ * Results: TRUE if the socket is pending, FALSE otherwise.
+ *
+ * Side effects: None.
+ */
+
+bool vsock_vmci_is_pending(struct sock *sk)
+{
+	struct vsock_vmci_sock *vsk = vsock_sk(sk);
+	return !list_empty(&vsk->pending_links);
+}
diff --git a/net/vmw_vsock/util.h b/net/vmw_vsock/util.h
new file mode 100644
index 0000000..bc8ab7e
--- /dev/null
+++ b/net/vmw_vsock/util.h
@@ -0,0 +1,314 @@
+/*
+ * VMware vSockets Driver
+ *
+ * Copyright (C) 2007-2012 VMware, Inc. All rights reserved.
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
+/*
+ * util.h --
+ *
+ * Utility functions for Linux VSocket module.
+ */
+
+#ifndef __UTIL_H__
+#define __UTIL_H__
+
+#include <linux/types.h>
+#include <linux/stddef.h>	/* for NULL */
+#include <net/sock.h>
+#include <linux/spinlock.h>
+
+#include "vsock_common.h"
+#include "vsock_packet.h"
+
+/*
+ * Each bound VSocket is stored in the bind hash table and each connected
+ * VSocket is stored in the connected hash table.
+ *
+ * Unbound sockets are all put on the same list attached to the end of the hash
+ * table (vsock_unbound_sockets).  Bound sockets are added to the hash table in
+ * the bucket that their local address hashes to (vsock_bound_sockets(addr)
+ * represents the list that addr hashes to).
+ *
+ * Specifically, we initialize the vsock_bind_table array to a size of
+ * VSOCK_HASH_SIZE + 1 so that vsock_bind_table[0] through
+ * vsock_bind_table[VSOCK_HASH_SIZE - 1] are for bound sockets and
+ * vsock_bind_table[VSOCK_HASH_SIZE] is for unbound sockets.  The hash function
+ * mods with VSOCK_HASH_SIZE - 1 to ensure this.
+ */
+#define VSOCK_HASH_SIZE         251
+#define LAST_RESERVED_PORT      1023
+#define MAX_PORT_RETRIES        24
+
+extern struct list_head vsock_bind_table[VSOCK_HASH_SIZE + 1];
+extern struct list_head vsock_connected_table[VSOCK_HASH_SIZE];
+
+extern spinlock_t vsock_table_lock;
+
+#define VSOCK_HASH(addr)        ((addr)->svm_port % (VSOCK_HASH_SIZE - 1))
+#define vsock_bound_sockets(addr) (&vsock_bind_table[VSOCK_HASH(addr)])
+#define vsock_unbound_sockets     (&vsock_bind_table[VSOCK_HASH_SIZE])
+
+/* XXX This can probably be implemented in a better way. */
+#define VSOCK_CONN_HASH(src, dst)				\
+	(((src)->svm_cid ^ (dst)->svm_port) % (VSOCK_HASH_SIZE - 1))
+#define vsock_connected_sockets(src, dst)		\
+	(&vsock_connected_table[VSOCK_CONN_HASH(src, dst)])
+#define vsock_connected_sockets_vsk(vsk)				\
+	vsock_connected_sockets(&(vsk)->remote_addr, &(vsk)->local_addr)
+
+/*
+ * Prototypes.
+ */
+
+void vsock_vmci_log_pkt(char const *function, u32 line,
+			struct vsock_packet *pkt);
+
+void vsock_vmci_init_tables(void);
+void __vsock_vmci_insert_bound(struct list_head *list, struct sock *sk);
+void __vsock_vmci_insert_connected(struct list_head *list, struct sock *sk);
+void __vsock_vmci_remove_bound(struct sock *sk);
+void __vsock_vmci_remove_connected(struct sock *sk);
+struct sock *__vsock_vmci_find_bound_socket(struct sockaddr_vm *addr);
+struct sock *__vsock_vmci_find_connected_socket(struct sockaddr_vm *src,
+						struct sockaddr_vm *dst);
+bool __vsock_vmci_in_bound_table(struct sock *sk);
+bool __vsock_vmci_in_connected_table(struct sock *sk);
+
+struct sock *vsock_vmci_get_pending(struct sock *listener,
+				    struct vsock_packet *pkt);
+void vsock_vmci_release_pending(struct sock *pending);
+void vsock_vmci_add_pending(struct sock *listener, struct sock *pending);
+void vsock_vmci_remove_pending(struct sock *listener, struct sock *pending);
+void vsock_vmci_enqueue_accept(struct sock *listener, struct sock *connected);
+struct sock *vsock_vmci_dequeue_accept(struct sock *listener);
+void vsock_vmci_remove_accept(struct sock *listener, struct sock *connected);
+bool vsock_vmci_in_accept_queue(struct sock *sk);
+bool vsock_vmci_is_accept_queue_empty(struct sock *sk);
+bool vsock_vmci_is_pending(struct sock *sk);
+
+static inline void vsock_vmci_insert_bound(struct list_head *list,
+					   struct sock *sk);
+static inline void vsock_vmci_insert_connected(struct list_head *list,
+					       struct sock *sk);
+static inline void vsock_vmci_remove_bound(struct sock *sk);
+static inline void vsock_vmci_remove_connected(struct sock *sk);
+static inline struct sock *vsock_vmci_find_bound_socket(struct sockaddr_vm
+							*addr);
+static inline struct sock *vsock_vmci_find_connected_socket(struct sockaddr_vm
+							    *src,
+							    struct sockaddr_vm
+							    *dst);
+static inline bool vsock_vmci_in_bound_table(struct sock *sk);
+static inline bool vsock_vmci_in_connected_table(struct sock *sk);
+
+/*
+ *
+ * vsock_vmci_insert_bound --
+ *
+ * Inserts socket into the bound table.
+ *
+ * Note that it is important to invoke the bottom-half versions of the spinlock
+ * functions since these may be called from tasklets.
+ *
+ * Results: None.
+ *
+ * Side effects: vsock_table_lock is acquired and released.
+ */
+
+static inline void
+vsock_vmci_insert_bound(struct list_head *list, struct sock *sk)
+{
+	spin_lock_bh(&vsock_table_lock);
+	__vsock_vmci_insert_bound(list, sk);
+	spin_unlock_bh(&vsock_table_lock);
+}
+
+/*
+ *
+ * vsock_vmci_insert_connected --
+ *
+ * Inserts socket into the connected table.
+ *
+ * Note that it is important to invoke the bottom-half versions of the spinlock
+ * functions since these may be called from tasklets.
+ *
+ * Results: None.
+ *
+ * Side effects: vsock_table_lock is acquired and released.
+ */
+
+static inline void
+vsock_vmci_insert_connected(struct list_head *list, struct sock *sk)
+{
+	spin_lock_bh(&vsock_table_lock);
+	__vsock_vmci_insert_connected(list, sk);
+	spin_unlock_bh(&vsock_table_lock);
+}
+
+/*
+ *
+ * vsock_vmci_remove_bound --
+ *
+ * Removes socket from the bound list.
+ *
+ * Note that it is important to invoke the bottom-half versions of the spinlock
+ * functions since these may be called from tasklets.
+ *
+ * Results: None.
+ *
+ * Side effects: vsock_table_lock is acquired and released.
+ */
+
+static inline void vsock_vmci_remove_bound(struct sock *sk)
+{
+	spin_lock_bh(&vsock_table_lock);
+	__vsock_vmci_remove_bound(sk);
+	spin_unlock_bh(&vsock_table_lock);
+}
+
+/*
+ *
+ * vsock_vmci_remove_connected --
+ *
+ * Removes socket from the connected list.
+ *
+ * Note that it is important to invoke the bottom-half versions of the spinlock
+ * functions since these may be called from tasklets.
+ *
+ * Results: None.
+ *
+ * Side effects: vsock_table_lock is acquired and released.
+ */
+
+static inline void vsock_vmci_remove_connected(struct sock *sk)
+{
+	spin_lock_bh(&vsock_table_lock);
+	__vsock_vmci_remove_connected(sk);
+	spin_unlock_bh(&vsock_table_lock);
+}
+
+/*
+ *
+ * vsock_vmci_find_bound_socket --
+ *
+ * Finds the socket corresponding to the provided address in the bound sockets
+ * hash table.
+ *
+ * Note that it is important to invoke the bottom-half versions of the spinlock
+ * functions since these are called from tasklets.
+ *
+ * Results: The sock structure if found, NULL on failure.
+ *
+ * Side effects: vsock_table_lock is acquired and released. The socket's
+ * reference count is increased.
+ */
+
+static inline struct sock *vsock_vmci_find_bound_socket(struct sockaddr_vm
+							*addr)
+{
+	struct sock *sk;
+
+	spin_lock_bh(&vsock_table_lock);
+	sk = __vsock_vmci_find_bound_socket(addr);
+	if (sk)
+		sock_hold(sk);
+
+	spin_unlock_bh(&vsock_table_lock);
+
+	return sk;
+}
+
+/*
+ *
+ * vsock_vmci_find_connected_socket --
+ *
+ * Finds the socket corresponding to the provided address in the connected
+ * sockets hash table.
+ *
+ * Note that it is important to invoke the bottom-half versions of the spinlock
+ * functions since these are called from tasklets.
+ *
+ * Results: The sock structure if found, NULL on failure.
+ *
+ * Side effects: vsock_table_lock is acquired and released. The socket's
+ * reference count is increased.
+ */
+
+static inline struct sock *vsock_vmci_find_connected_socket(struct sockaddr_vm
+							    *src,
+							    struct sockaddr_vm
+							    *dst)
+{
+	struct sock *sk;
+
+	spin_lock_bh(&vsock_table_lock);
+	sk = __vsock_vmci_find_connected_socket(src, dst);
+	if (sk)
+		sock_hold(sk);
+
+	spin_unlock_bh(&vsock_table_lock);
+
+	return sk;
+}
+
+/*
+ *
+ * vsock_vmci_in_bound_table --
+ *
+ * Determines whether the provided socket is in the bound table.
+ *
+ * Note that it is important to invoke the bottom-half versions of the spinlock
+ * functions since these may be called from tasklets.
+ *
+ * Results: TRUE is socket is in bound table, FALSE otherwise.
+ *
+ * Side effects: vsock_table_lock is acquired and released.
+ */
+
+static inline bool vsock_vmci_in_bound_table(struct sock *sk)
+{
+	bool ret;
+
+	spin_lock_bh(&vsock_table_lock);
+	ret = __vsock_vmci_in_bound_table(sk);
+	spin_unlock_bh(&vsock_table_lock);
+
+	return ret;
+}
+
+/*
+ *
+ * vsock_vmci_in_connected_table --
+ *
+ * Determines whether the provided socket is in the connected table.
+ *
+ * Note that it is important to invoke the bottom-half versions of the spinlock
+ * functions since these may be called from tasklets.
+ *
+ * Results: TRUE is socket is in connected table, FALSE otherwise.
+ *
+ * Side effects: vsock_table_lock is acquired and released.
+ */
+
+static inline bool vsock_vmci_in_connected_table(struct sock *sk)
+{
+	bool ret;
+
+	spin_lock_bh(&vsock_table_lock);
+	ret = __vsock_vmci_in_connected_table(sk);
+	spin_unlock_bh(&vsock_table_lock);
+
+	return ret;
+}
+
+#endif /* __UTIL_H__ */
