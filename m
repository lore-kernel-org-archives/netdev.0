From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 06/21] RDS: Connection handling
Date: Mon, 26 Jan 2009 18:17:43 -0800
Message-ID: <1233022678-9259-7-git-send-email-andy.grover@oracle.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:43583 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391AbZA0CSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 21:18:24 -0500
In-Reply-To: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While arguably the fact that the underlying transport needs a
connection to convey RDS's datagrame reliably is not important
to rds proper, the transports implemented so far (IB and TCP)
have both been connection-oriented, and so the connection
state machine-related code is in the common rds code.

This patch also includes several work items, to handle connecting,
sending, receiving, and shutdown.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 drivers/infiniband/ulp/rds/connection.c |  501 +++++++++++++++++++++++++++++++
 drivers/infiniband/ulp/rds/threads.c    |  273 +++++++++++++++++
 2 files changed, 774 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/rds/connection.c
 create mode 100644 drivers/infiniband/ulp/rds/threads.c

diff --git a/drivers/infiniband/ulp/rds/connection.c b/drivers/infiniband/ulp/rds/connection.c
new file mode 100644
index 0000000..6174629
--- /dev/null
+++ b/drivers/infiniband/ulp/rds/connection.c
@@ -0,0 +1,501 @@
+/*
+ * Copyright (c) 2006 Oracle.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <net/inet_hashtables.h>
+
+#include "rds.h"
+#include "loop.h"
+#include "rdma.h"
+
+#define RDS_CONNECTION_HASH_BITS 12
+#define RDS_CONNECTION_HASH_ENTRIES (1 << RDS_CONNECTION_HASH_BITS)
+#define RDS_CONNECTION_HASH_MASK (RDS_CONNECTION_HASH_ENTRIES - 1)
+
+/* converting this to RCU is a chore for another day.. */
+static DEFINE_SPINLOCK(rds_conn_lock);
+static unsigned long rds_conn_count;
+static struct hlist_head rds_conn_hash[RDS_CONNECTION_HASH_ENTRIES];
+static struct kmem_cache *rds_conn_slab;
+
+static struct hlist_head *rds_conn_bucket(__be32 laddr, __be32 faddr)
+{
+	/* Pass NULL, don't need struct net for hash */
+	unsigned long hash = inet_ehashfn(NULL,
+					  be32_to_cpu(laddr), 0,
+					  be32_to_cpu(faddr), 0);
+	return &rds_conn_hash[hash & RDS_CONNECTION_HASH_MASK];
+}
+
+#define rds_conn_info_set(var, test, suffix) do {		\
+	if (test)						\
+		var |= RDS_INFO_CONNECTION_FLAG_##suffix;	\
+} while (0)
+
+static inline int rds_conn_is_sending(struct rds_connection *conn)
+{
+	int ret = 0;
+
+	if (!mutex_trylock(&conn->c_send_lock))
+		ret = 1;
+	else
+		mutex_unlock(&conn->c_send_lock);
+
+	return ret;
+}
+
+static struct rds_connection *rds_conn_lookup(struct hlist_head *head,
+					      __be32 laddr, __be32 faddr,
+					      struct rds_transport *trans)
+{
+	struct rds_connection *conn, *ret = NULL;
+	struct hlist_node *pos;
+
+	hlist_for_each_entry(conn, pos, head, c_hash_node) {
+		if (conn->c_faddr == faddr && conn->c_laddr == laddr &&
+				conn->c_trans == trans) {
+			ret = conn;
+			break;
+		}
+	}
+	rdsdebug("returning conn %p for %u.%u.%u.%u -> %u.%u.%u.%u\n", ret,
+		 NIPQUAD(laddr), NIPQUAD(faddr));
+	return ret;
+}
+
+/*
+ * This is called by transports as they're bringing down a connection.
+ * It clears partial message state so that the transport can start sending
+ * and receiving over this connection again in the future.  It is up to
+ * the transport to have serialized this call with its send and recv.
+ */
+void rds_conn_reset(struct rds_connection *conn)
+{
+	rdstrace(RDS_CONNECTION, RDS_MINIMAL,
+	  "connection %u.%u.%u.%u to %u.%u.%u.%u reset\n",
+	  NIPQUAD(conn->c_laddr),NIPQUAD(conn->c_faddr));
+
+	rds_stats_inc(s_conn_reset);
+	rds_send_reset(conn);
+	conn->c_flags = 0;
+
+	/* Do not clear next_rx_seq here, else we cannot distinguish
+	 * retransmitted packets from new packets, and will hand all
+	 * of them to the application. That is not consistent with the
+	 * reliability guarantees of RDS. */
+}
+
+/*
+ * There is only every one 'conn' for a given pair of addresses in the
+ * system at a time.  They contain messages to be retransmitted and so
+ * span the lifetime of the actual underlying transport connections.
+ *
+ * For now they are not garbage collected once they're created.  They
+ * are torn down as the module is removed, if ever.
+ */
+static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
+				       struct rds_transport *trans, gfp_t gfp,
+				       int is_outgoing)
+{
+	struct rds_connection *conn, *tmp, *parent = NULL;
+	struct hlist_head *head = rds_conn_bucket(laddr, faddr);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&rds_conn_lock, flags);
+	conn = rds_conn_lookup(head, laddr, faddr, trans);
+	if (conn
+	 && conn->c_loopback
+	 && conn->c_trans != &rds_loop_transport
+	 && !is_outgoing) {
+		/* This is a looped back IB connection, and we're
+		 * called by the code handling the incoming connect.
+		 * We need a second connection object into which we
+		 * can stick the other QP. */
+		parent = conn;
+		conn = parent->c_passive;
+	}
+	spin_unlock_irqrestore(&rds_conn_lock, flags);
+	if (conn)
+		goto out;
+
+	conn = kmem_cache_alloc(rds_conn_slab, gfp);
+	if (conn == NULL) {
+		conn = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+
+	memset(conn, 0, sizeof(*conn));
+
+	INIT_HLIST_NODE(&conn->c_hash_node);
+	conn->c_version = RDS_PROTOCOL_3_0;
+	conn->c_laddr = laddr;
+	conn->c_faddr = faddr;
+	spin_lock_init(&conn->c_lock);
+	conn->c_next_tx_seq = 1;
+
+	mutex_init(&conn->c_send_lock);
+	INIT_LIST_HEAD(&conn->c_send_queue);
+	INIT_LIST_HEAD(&conn->c_retrans);
+
+	ret = rds_cong_get_maps(conn);
+	if (ret) {
+		kmem_cache_free(rds_conn_slab, conn);
+		conn = ERR_PTR(ret);
+		goto out;
+	}
+
+	/*
+	 * This is where a connection becomes loopback.  If *any* RDS sockets
+	 * can bind to the destination address then we'd rather the messages
+	 * flow through loopback rather than either transport.
+	 */
+	if (rds_trans_get_preferred(faddr)) {
+		conn->c_loopback = 1;
+		if (is_outgoing && trans->t_prefer_loopback) {
+			/* "outgoing" connection - and the transport
+			 * says it wants the connection handled by the
+			 * loopback transport. This is what TCP does.
+			 */
+			trans = &rds_loop_transport;
+		}
+	}
+
+	conn->c_trans = trans;
+
+	ret = trans->conn_alloc(conn, gfp);
+	if (ret) {
+		kmem_cache_free(rds_conn_slab, conn);
+		conn = ERR_PTR(ret);
+		goto out;
+	}
+
+	atomic_set(&conn->c_state, RDS_CONN_DOWN);
+	conn->c_reconnect_jiffies = 0;
+	INIT_DELAYED_WORK(&conn->c_send_w, rds_send_worker);
+	INIT_DELAYED_WORK(&conn->c_recv_w, rds_recv_worker);
+	INIT_DELAYED_WORK(&conn->c_conn_w, rds_connect_worker);
+	INIT_WORK(&conn->c_down_w, rds_shutdown_worker);
+	mutex_init(&conn->c_cm_lock);
+	conn->c_flags = 0;
+
+	rdsdebug("allocated conn %p for %u.%u.%u.%u -> %u.%u.%u.%u\n", conn,
+		 NIPQUAD(laddr), NIPQUAD(faddr));
+
+	rdstrace(RDS_CONNECTION, RDS_MINIMAL,
+	  "allocated conn %p for %u.%u.%u.%u -> %u.%u.%u.%u over %s %s\n",
+	  conn, NIPQUAD(laddr), NIPQUAD(faddr),
+	  trans->t_name ? trans->t_name : "[unknown]",
+	  is_outgoing ? "(outgoing)" : "");
+
+	spin_lock_irqsave(&rds_conn_lock, flags);
+	if (parent == NULL) {
+		tmp = rds_conn_lookup(head, laddr, faddr, trans);
+		if (tmp == NULL)
+			hlist_add_head(&conn->c_hash_node, head);
+	} else {
+		tmp = parent->c_passive;
+		if (!tmp)
+			parent->c_passive = conn;
+	}
+
+	if (tmp) {
+		trans->conn_free(conn->c_transport_data);
+		kmem_cache_free(rds_conn_slab, conn);
+		conn = tmp;
+	} else {
+		rds_cong_add_conn(conn);
+		rds_conn_count++;
+	}
+
+	spin_unlock_irqrestore(&rds_conn_lock, flags);
+
+out:
+	return conn;
+}
+
+struct rds_connection *rds_conn_create(__be32 laddr, __be32 faddr,
+				       struct rds_transport *trans, gfp_t gfp)
+{
+	return __rds_conn_create(laddr, faddr, trans, gfp, 0);
+}
+EXPORT_SYMBOL_GPL(rds_conn_create);
+
+struct rds_connection *rds_conn_create_outgoing(__be32 laddr, __be32 faddr,
+				       struct rds_transport *trans, gfp_t gfp)
+{
+	return __rds_conn_create(laddr, faddr, trans, gfp, 1);
+}
+EXPORT_SYMBOL_GPL(rds_conn_create_outgoing);
+
+void rds_conn_destroy(struct rds_connection *conn)
+{
+	struct rds_message *rm, *rtmp;
+
+	rdsdebug("freeing conn %p for %u.%u.%u.%u -> "
+		 "%u.%u.%u.%u\n", conn, NIPQUAD(conn->c_laddr),
+		 NIPQUAD(conn->c_faddr));
+
+	rdstrace(RDS_CONNECTION, RDS_MINIMAL,
+	  "freeing conn %p for %u.%u.%u.%u -> %u.%u.%u.%u\n",
+	  conn, NIPQUAD(conn->c_laddr), NIPQUAD(conn->c_faddr));
+
+	hlist_del_init(&conn->c_hash_node);
+
+	/* wait for the rds thread to shut it down */
+	atomic_set(&conn->c_state, RDS_CONN_ERROR);
+	cancel_delayed_work(&conn->c_conn_w);
+	queue_work(rds_wq, &conn->c_down_w);
+	flush_workqueue(rds_wq);
+
+	/* tear down queued messages */
+	list_for_each_entry_safe(rm, rtmp,
+				 &conn->c_send_queue,
+				 m_conn_item) {
+		list_del_init(&rm->m_conn_item);
+		BUG_ON(!list_empty(&rm->m_sock_item));
+		rds_message_put(rm);
+	}
+	if (conn->c_xmit_rm)
+		rds_message_put(conn->c_xmit_rm);
+
+	conn->c_trans->conn_free(conn->c_transport_data);
+
+	/*
+	 * The congestion maps aren't freed up here.  They're
+	 * freed by rds_cong_exit() after all the connections
+	 * have been freed.
+	 */
+	rds_cong_remove_conn(conn);
+
+	BUG_ON(!list_empty(&conn->c_retrans));
+	kmem_cache_free(rds_conn_slab, conn);
+
+	rds_conn_count--;
+}
+EXPORT_SYMBOL_GPL(rds_conn_destroy);
+
+static void rds_conn_message_info(struct socket *sock, unsigned int len,
+				  struct rds_info_iterator *iter,
+				  struct rds_info_lengths *lens,
+				  int want_send)
+{
+	struct hlist_head *head;
+	struct hlist_node *pos;
+	struct list_head *list;
+	struct rds_connection *conn;
+	struct rds_message *rm;
+	unsigned long flags;
+	unsigned int total = 0;
+	size_t i;
+
+	len /= sizeof(struct rds_info_message);
+
+	spin_lock_irqsave(&rds_conn_lock, flags);
+
+	for (i = 0, head = rds_conn_hash; i < ARRAY_SIZE(rds_conn_hash);
+	     i++, head++) {
+		hlist_for_each_entry(conn, pos, head, c_hash_node) {
+			if (want_send)
+				list = &conn->c_send_queue;
+			else
+				list = &conn->c_retrans;
+
+			spin_lock(&conn->c_lock);
+
+			/* XXX too lazy to maintain counts.. */
+			list_for_each_entry(rm, list, m_conn_item) {
+				total++;
+				if (total <= len)
+					rds_inc_info_copy(&rm->m_inc, iter,
+							  conn->c_laddr,
+							  conn->c_faddr, 0);
+			}
+
+			spin_unlock(&conn->c_lock);
+		}
+	}
+
+	spin_unlock_irqrestore(&rds_conn_lock, flags);
+
+	lens->nr = total;
+	lens->each = sizeof(struct rds_info_message);
+}
+
+static void rds_conn_message_info_send(struct socket *sock, unsigned int len,
+				       struct rds_info_iterator *iter,
+				       struct rds_info_lengths *lens)
+{
+	rds_conn_message_info(sock, len, iter, lens, 1);
+}
+
+static void rds_conn_message_info_retrans(struct socket *sock,
+					  unsigned int len,
+					  struct rds_info_iterator *iter,
+					  struct rds_info_lengths *lens)
+{
+	rds_conn_message_info(sock, len, iter, lens, 0);
+}
+
+void rds_for_each_conn_info(struct socket *sock, unsigned int len,
+			  struct rds_info_iterator *iter,
+			  struct rds_info_lengths *lens,
+			  int (*visitor)(struct rds_connection *, void *),
+			  size_t item_len)
+{
+	uint64_t buffer[(item_len + 7) / 8];
+	struct hlist_head *head;
+	struct hlist_node *pos;
+	struct hlist_node *tmp;
+	struct rds_connection *conn;
+	unsigned long flags;
+	size_t i;
+
+	spin_lock_irqsave(&rds_conn_lock, flags);
+
+	lens->nr = 0;
+	lens->each = item_len;
+
+	for (i = 0, head = rds_conn_hash; i < ARRAY_SIZE(rds_conn_hash);
+	     i++, head++) {
+		hlist_for_each_entry_safe(conn, pos, tmp, head, c_hash_node) {
+
+			/* XXX no c_lock usage.. */
+			if (!visitor(conn, buffer))
+				continue;
+
+			/* We copy as much as we can fit in the buffer,
+			 * but we count all items so that the caller
+			 * can resize the buffer. */
+			if (len >= item_len) {
+				rds_info_copy(iter, buffer, item_len);
+				len -= item_len;
+			}
+			lens->nr++;
+		}
+	}
+
+	spin_unlock_irqrestore(&rds_conn_lock, flags);
+}
+EXPORT_SYMBOL_GPL(rds_for_each_conn_info);
+
+static int rds_conn_info_visitor(struct rds_connection *conn,
+				  void *buffer)
+{
+	struct rds_info_connection *cinfo = buffer;
+
+	cinfo->next_tx_seq = conn->c_next_tx_seq;
+	cinfo->next_rx_seq = conn->c_next_rx_seq;
+	cinfo->laddr = conn->c_laddr;
+	cinfo->faddr = conn->c_faddr;
+	strncpy(cinfo->transport, conn->c_trans->t_name,
+		sizeof(cinfo->transport));
+	cinfo->flags = 0;
+
+	rds_conn_info_set(cinfo->flags,
+			  rds_conn_is_sending(conn), SENDING);
+	/* XXX Future: return the state rather than these funky bits */
+	rds_conn_info_set(cinfo->flags,
+			  atomic_read(&conn->c_state) == RDS_CONN_CONNECTING,
+			  CONNECTING);
+	rds_conn_info_set(cinfo->flags,
+			  atomic_read(&conn->c_state) == RDS_CONN_UP,
+			  CONNECTED);
+	return 1;
+}
+
+static void rds_conn_info(struct socket *sock, unsigned int len,
+			  struct rds_info_iterator *iter,
+			  struct rds_info_lengths *lens)
+{
+	rds_for_each_conn_info(sock, len, iter, lens,
+				rds_conn_info_visitor,
+				sizeof(struct rds_info_connection));
+}
+
+int __init rds_conn_init(void)
+{
+	rds_conn_slab = kmem_cache_create("rds_connection",
+					  sizeof(struct rds_connection),
+					  0, 0, NULL);
+	if (rds_conn_slab == NULL)
+		return -ENOMEM;
+
+	rds_info_register_func(RDS_INFO_CONNECTIONS, rds_conn_info);
+	rds_info_register_func(RDS_INFO_SEND_MESSAGES,
+			       rds_conn_message_info_send);
+	rds_info_register_func(RDS_INFO_RETRANS_MESSAGES,
+			       rds_conn_message_info_retrans);
+
+	return 0;
+}
+
+void rds_conn_exit(void)
+{
+	rds_loop_exit();
+
+	WARN_ON(!hlist_empty(rds_conn_hash));
+
+	kmem_cache_destroy(rds_conn_slab);
+
+	rds_info_deregister_func(RDS_INFO_CONNECTIONS, rds_conn_info);
+	rds_info_deregister_func(RDS_INFO_SEND_MESSAGES,
+				 rds_conn_message_info_send);
+	rds_info_deregister_func(RDS_INFO_RETRANS_MESSAGES,
+				 rds_conn_message_info_retrans);
+}
+
+/*
+ * Force a disconnect
+ */
+void rds_conn_drop(struct rds_connection *conn)
+{
+	atomic_set(&conn->c_state, RDS_CONN_ERROR);
+	queue_work(rds_wq, &conn->c_down_w);
+}
+EXPORT_SYMBOL_GPL(rds_conn_drop);
+
+/*
+ * An error occurred on the connection
+ */
+void
+__rds_conn_error(struct rds_connection *conn, const char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	vprintk(fmt, ap);
+	va_end(ap);
+
+	rds_conn_drop(conn);
+}
diff --git a/drivers/infiniband/ulp/rds/threads.c b/drivers/infiniband/ulp/rds/threads.c
new file mode 100644
index 0000000..0017f90
--- /dev/null
+++ b/drivers/infiniband/ulp/rds/threads.c
@@ -0,0 +1,273 @@
+/*
+ * Copyright (c) 2006 Oracle.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/random.h>
+
+#include "rds.h"
+
+/*
+ * All of connection management is simplified by serializing it through
+ * work queues that execute in a connection managing thread.
+ *
+ * TCP wants to send acks through sendpage() in response to data_ready(),
+ * but it needs a process context to do so.
+ *
+ * The receive paths need to allocate but can't drop packets (!) so we have
+ * a thread around to block allocating if the receive fast path sees an
+ * allocation failure.
+ */
+
+/* Grand Unified Theory of connection life cycle:
+ * At any point in time, the connection can be in one of these states:
+ * DOWN, CONNECTING, UP, DISCONNECTING, ERROR
+ *
+ * The following transitions are possible:
+ *  ANY		  -> ERROR
+ *  UP		  -> DISCONNECTING
+ *  ERROR	  -> DISCONNECTING
+ *  DISCONNECTING -> DOWN
+ *  DOWN	  -> CONNECTING
+ *  CONNECTING	  -> UP
+ *
+ * Transition to state DISCONNECTING/DOWN:
+ *  -	Inside the shutdown worker; synchronizes with xmit path
+ *	through c_send_lock, and with connection management callbacks
+ *	via c_cm_lock.
+ *
+ *	For receive callbacks, we rely on the underlying transport
+ *	(TCP, IB/RDMA) to provide the necessary synchronisation.
+ */
+struct workqueue_struct *rds_wq;
+EXPORT_SYMBOL_GPL(rds_wq);
+
+void rds_connect_complete(struct rds_connection *conn)
+{
+	if (!rds_conn_transition(conn, RDS_CONN_CONNECTING, RDS_CONN_UP)) {
+		printk(KERN_WARNING "%s: Cannot transition to state UP, "
+				"current state is %d\n",
+				__func__,
+				atomic_read(&conn->c_state));
+		atomic_set(&conn->c_state, RDS_CONN_ERROR);
+		queue_work(rds_wq, &conn->c_down_w);
+		return;
+	}
+
+	rdstrace(RDS_CONNECTION, RDS_MINIMAL,
+	  "conn %p for %u.%u.%u.%u to %u.%u.%u.%u complete\n",
+	  conn, NIPQUAD(conn->c_laddr),NIPQUAD(conn->c_faddr));
+
+	conn->c_reconnect_jiffies = 0;
+	set_bit(0, &conn->c_map_queued);
+	queue_delayed_work(rds_wq, &conn->c_send_w, 0);
+	queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
+}
+EXPORT_SYMBOL_GPL(rds_connect_complete);
+
+/*
+ * This random exponential backoff is relied on to eventually resolve racing
+ * connects.
+ *
+ * If connect attempts race then both parties drop both connections and come
+ * here to wait for a random amount of time before trying again.  Eventually
+ * the backoff range will be so much greater than the time it takes to
+ * establish a connection that one of the pair will establish the connection
+ * before the other's random delay fires.
+ *
+ * Connection attempts that arrive while a connection is already established
+ * are also considered to be racing connects.  This lets a connection from
+ * a rebooted machine replace an existing stale connection before the transport
+ * notices that the connection has failed.
+ *
+ * We should *always* start with a random backoff; otherwise a broken connection
+ * will always take several iterations to be re-established.
+ */
+static void rds_queue_reconnect(struct rds_connection *conn)
+{
+	unsigned long rand;
+
+	rdstrace(RDS_CONNECTION, RDS_LOW,
+	  "conn %p for %u.%u.%u.%u to %u.%u.%u.%u reconnect jiffies %lu\n",
+	  conn, NIPQUAD(conn->c_laddr), NIPQUAD(conn->c_faddr),
+	  conn->c_reconnect_jiffies);
+
+	set_bit(RDS_RECONNECT_PENDING, &conn->c_flags);
+	if (conn->c_reconnect_jiffies == 0) {
+		conn->c_reconnect_jiffies = rds_sysctl_reconnect_min_jiffies;
+		queue_delayed_work(rds_wq, &conn->c_conn_w, 0);
+		return;
+	}
+
+	get_random_bytes(&rand, sizeof(rand));
+	rdsdebug("%lu delay %lu ceil conn %p for %u.%u.%u.%u -> %u.%u.%u.%u\n",
+		 rand % conn->c_reconnect_jiffies, conn->c_reconnect_jiffies,
+		 conn, NIPQUAD(conn->c_laddr), NIPQUAD(conn->c_faddr));
+	queue_delayed_work(rds_wq, &conn->c_conn_w,
+			   rand % conn->c_reconnect_jiffies);
+
+	conn->c_reconnect_jiffies = min(conn->c_reconnect_jiffies * 2,
+					rds_sysctl_reconnect_max_jiffies);
+}
+
+void rds_connect_worker(struct work_struct *work)
+{
+	struct rds_connection *conn = container_of(work, struct rds_connection, c_conn_w.work);
+	int ret;
+
+	clear_bit(RDS_RECONNECT_PENDING, &conn->c_flags);
+	if (rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING)) {
+		ret = conn->c_trans->conn_connect(conn);
+		rdsdebug("connect conn %p for %u.%u.%u.%u -> %u.%u.%u.%u "
+			 "ret %d\n", conn, NIPQUAD(conn->c_laddr),
+			 NIPQUAD(conn->c_faddr), ret);
+		rdstrace(RDS_CONNECTION, RDS_MINIMAL,
+		  "conn %p for %u.%u.%u.%u to %u.%u.%u.%u dispatched, ret %d\n",
+		  conn, NIPQUAD(conn->c_laddr), NIPQUAD(conn->c_faddr), ret);
+
+		if (ret) {
+			if (rds_conn_transition(conn, RDS_CONN_CONNECTING, RDS_CONN_DOWN))
+				rds_queue_reconnect(conn);
+			else
+				rds_conn_error(conn, "RDS: connect failed\n");
+		}
+	}
+}
+
+void rds_shutdown_worker(struct work_struct *work)
+{
+	struct rds_connection *conn = container_of(work, struct rds_connection, c_down_w);
+
+	/* shut it down unless it's down already */
+	if (!rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_DOWN)) {
+		/*
+		 * Quiesce the connection mgmt handlers before we start tearing
+		 * things down. We don't hold the mutex for the entire
+		 * duration of the shutdown operation, else we may be
+		 * deadlocking with the CM handler. Instead, the CM event
+		 * handler is supposed to check for state DISCONNECTING
+		 */
+		mutex_lock(&conn->c_cm_lock);
+		if (!rds_conn_transition(conn, RDS_CONN_UP, RDS_CONN_DISCONNECTING)
+		 && !rds_conn_transition(conn, RDS_CONN_ERROR, RDS_CONN_DISCONNECTING)) {
+			rds_conn_error(conn, "shutdown called in state %d\n",
+					atomic_read(&conn->c_state));
+			mutex_unlock(&conn->c_cm_lock);
+			return;
+		}
+		mutex_unlock(&conn->c_cm_lock);
+
+		mutex_lock(&conn->c_send_lock);
+		conn->c_trans->conn_shutdown(conn);
+		rds_conn_reset(conn);
+		mutex_unlock(&conn->c_send_lock);
+
+		if (!rds_conn_transition(conn, RDS_CONN_DISCONNECTING, RDS_CONN_DOWN)) {
+			/* This can happen - eg when we're in the middle of tearing
+			 * down the connection, and someone unloads the rds module.
+			 * Quite reproduceable with loopback connections.
+			 * Mostly harmless.
+			 */
+			rds_conn_error(conn,
+				"%s: failed to transition to state DOWN, "
+				"current state is %d\n",
+				__func__,
+				atomic_read(&conn->c_state));
+			return;
+		}
+	}
+
+	/* Then reconnect if it's still live.
+	 * The passive side of an IB loopback connection is never added
+	 * to the conn hash, so we never trigger a reconnect on this
+	 * conn - the reconnect is always triggered by the active peer. */
+	cancel_delayed_work(&conn->c_conn_w);
+	if (!hlist_unhashed(&conn->c_hash_node))
+		rds_queue_reconnect(conn);
+}
+
+void rds_send_worker(struct work_struct *work)
+{
+	struct rds_connection *conn = container_of(work, struct rds_connection, c_send_w.work);
+	int ret;
+
+	if (rds_conn_state(conn) == RDS_CONN_UP) {
+		ret = rds_send_xmit(conn);
+		rdsdebug("conn %p ret %d\n", conn, ret);
+		switch (ret) {
+		case -EAGAIN:
+			rds_stats_inc(s_send_immediate_retry);
+			queue_delayed_work(rds_wq, &conn->c_send_w, 0);
+			break;
+		case -ENOMEM:
+			rds_stats_inc(s_send_delayed_retry);
+			queue_delayed_work(rds_wq, &conn->c_send_w, 2);
+		default:
+			break;
+		}
+	}
+}
+
+void rds_recv_worker(struct work_struct *work)
+{
+	struct rds_connection *conn = container_of(work, struct rds_connection, c_recv_w.work);
+	int ret;
+
+	if (rds_conn_state(conn) == RDS_CONN_UP) {
+		ret = conn->c_trans->recv(conn);
+		rdsdebug("conn %p ret %d\n", conn, ret);
+		switch (ret) {
+		case -EAGAIN:
+			rds_stats_inc(s_recv_immediate_retry);
+			queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
+			break;
+		case -ENOMEM:
+			rds_stats_inc(s_recv_delayed_retry);
+			queue_delayed_work(rds_wq, &conn->c_recv_w, 2);
+		default:
+			break;
+		}
+	}
+}
+
+void rds_threads_exit(void)
+{
+	destroy_workqueue(rds_wq);
+}
+
+int __init rds_threads_init(void)
+{
+	rds_wq = create_singlethread_workqueue("krdsd");
+	if (rds_wq == NULL)
+		return -ENOMEM;
+
+	return 0;
+}
-- 
1.5.6.3

