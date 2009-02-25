From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 07/26] RDS: loopback
Date: Tue, 24 Feb 2009 17:30:24 -0800
Message-ID: <1235525443-9007-8-git-send-email-andy.grover@oracle.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:48882 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304AbZBYBbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:31:08 -0500
In-Reply-To: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A simple rds transport to handle loopback connections.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/loop.c |  188 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/rds/loop.h |    9 +++
 2 files changed, 197 insertions(+), 0 deletions(-)
 create mode 100644 net/rds/loop.c
 create mode 100644 net/rds/loop.h

diff --git a/net/rds/loop.c b/net/rds/loop.c
new file mode 100644
index 0000000..4a61997
--- /dev/null
+++ b/net/rds/loop.c
@@ -0,0 +1,188 @@
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
+#include <linux/in.h>
+
+#include "rds.h"
+#include "loop.h"
+
+static DEFINE_SPINLOCK(loop_conns_lock);
+static LIST_HEAD(loop_conns);
+
+/*
+ * This 'loopback' transport is a special case for flows that originate
+ * and terminate on the same machine.
+ *
+ * Connection build-up notices if the destination address is thought of
+ * as a local address by a transport.  At that time it decides to use the
+ * loopback transport instead of the bound transport of the sending socket.
+ *
+ * The loopback transport's sending path just hands the sent rds_message
+ * straight to the receiving path via an embedded rds_incoming.
+ */
+
+/*
+ * Usually a message transits both the sender and receiver's conns as it
+ * flows to the receiver.  In the loopback case, though, the receive path
+ * is handed the sending conn so the sense of the addresses is reversed.
+ */
+static int rds_loop_xmit(struct rds_connection *conn, struct rds_message *rm,
+			 unsigned int hdr_off, unsigned int sg,
+			 unsigned int off)
+{
+	BUG_ON(hdr_off || sg || off);
+
+	rds_inc_init(&rm->m_inc, conn, conn->c_laddr);
+	rds_message_addref(rm); /* for the inc */
+
+	rds_recv_incoming(conn, conn->c_laddr, conn->c_faddr, &rm->m_inc,
+			  GFP_KERNEL, KM_USER0);
+
+	rds_send_drop_acked(conn, be64_to_cpu(rm->m_inc.i_hdr.h_sequence),
+			    NULL);
+
+	rds_inc_put(&rm->m_inc);
+
+	return sizeof(struct rds_header) + be32_to_cpu(rm->m_inc.i_hdr.h_len);
+}
+
+static int rds_loop_xmit_cong_map(struct rds_connection *conn,
+				  struct rds_cong_map *map,
+				  unsigned long offset)
+{
+	unsigned long i;
+
+	BUG_ON(offset);
+	BUG_ON(map != conn->c_lcong);
+
+	for (i = 0; i < RDS_CONG_MAP_PAGES; i++) {
+		memcpy((void *)conn->c_fcong->m_page_addrs[i],
+		       (void *)map->m_page_addrs[i], PAGE_SIZE);
+	}
+
+	rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
+
+	return sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
+}
+
+/* we need to at least give the thread something to succeed */
+static int rds_loop_recv(struct rds_connection *conn)
+{
+	return 0;
+}
+
+struct rds_loop_connection {
+	struct list_head loop_node;
+	struct rds_connection *conn;
+};
+
+/*
+ * Even the loopback transport needs to keep track of its connections,
+ * so it can call rds_conn_destroy() on them on exit. N.B. there are
+ * 1+ loopback addresses (127.*.*.*) so it's not a bug to have
+ * multiple loopback conns allocated, although rather useless.
+ */
+static int rds_loop_conn_alloc(struct rds_connection *conn, gfp_t gfp)
+{
+	struct rds_loop_connection *lc;
+	unsigned long flags;
+
+	lc = kzalloc(sizeof(struct rds_loop_connection), GFP_KERNEL);
+	if (lc == NULL)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&lc->loop_node);
+	lc->conn = conn;
+	conn->c_transport_data = lc;
+
+	spin_lock_irqsave(&loop_conns_lock, flags);
+	list_add_tail(&lc->loop_node, &loop_conns);
+	spin_unlock_irqrestore(&loop_conns_lock, flags);
+
+	return 0;
+}
+
+static void rds_loop_conn_free(void *arg)
+{
+	struct rds_loop_connection *lc = arg;
+	rdsdebug("lc %p\n", lc);
+	list_del(&lc->loop_node);
+	kfree(lc);
+}
+
+static int rds_loop_conn_connect(struct rds_connection *conn)
+{
+	rds_connect_complete(conn);
+	return 0;
+}
+
+static void rds_loop_conn_shutdown(struct rds_connection *conn)
+{
+}
+
+void rds_loop_exit(void)
+{
+	struct rds_loop_connection *lc, *_lc;
+	LIST_HEAD(tmp_list);
+
+	/* avoid calling conn_destroy with irqs off */
+	spin_lock_irq(&loop_conns_lock);
+	list_splice(&loop_conns, &tmp_list);
+	INIT_LIST_HEAD(&loop_conns);
+	spin_unlock_irq(&loop_conns_lock);
+
+	list_for_each_entry_safe(lc, _lc, &tmp_list, loop_node) {
+		WARN_ON(lc->conn->c_passive);
+		rds_conn_destroy(lc->conn);
+	}
+}
+
+/*
+ * This is missing .xmit_* because loop doesn't go through generic
+ * rds_send_xmit() and doesn't call rds_recv_incoming().  .listen_stop and
+ * .laddr_check are missing because transport.c doesn't iterate over
+ * rds_loop_transport.
+ */
+struct rds_transport rds_loop_transport = {
+	.xmit			= rds_loop_xmit,
+	.xmit_cong_map		= rds_loop_xmit_cong_map,
+	.recv			= rds_loop_recv,
+	.conn_alloc		= rds_loop_conn_alloc,
+	.conn_free		= rds_loop_conn_free,
+	.conn_connect		= rds_loop_conn_connect,
+	.conn_shutdown		= rds_loop_conn_shutdown,
+	.inc_copy_to_user	= rds_message_inc_copy_to_user,
+	.inc_purge		= rds_message_inc_purge,
+	.inc_free		= rds_message_inc_free,
+	.t_name			= "loopback",
+};
diff --git a/net/rds/loop.h b/net/rds/loop.h
new file mode 100644
index 0000000..f32b093
--- /dev/null
+++ b/net/rds/loop.h
@@ -0,0 +1,9 @@
+#ifndef _RDS_LOOP_H
+#define _RDS_LOOP_H
+
+/* loop.c */
+extern struct rds_transport rds_loop_transport;
+
+void rds_loop_exit(void);
+
+#endif
-- 
1.5.6.3

