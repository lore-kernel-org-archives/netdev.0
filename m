From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 1/5] RDS: Add TCP transport to RDS
Date: Fri, 21 Aug 2009 15:28:31 -0700
Message-ID: <1250893715-21939-2-git-send-email-andy.grover@oracle.com>
References: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:32891 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387AbZHUW2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 18:28:48 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n7LMTUuP028703
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 21 Aug 2009 22:29:32 GMT
In-Reply-To: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code allows RDS to be tunneled over a TCP connection.

RDMA operations are disabled when using TCP transport,
but this frees RDS from the IB/RDMA stack dependency, and allows
it to be used with standard Ethernet adapters, or in a VM.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 include/linux/rds.h   |   12 ++
 net/rds/tcp.c         |  319 +++++++++++++++++++++++++++++++++++++++++++
 net/rds/tcp.h         |   93 +++++++++++++
 net/rds/tcp_connect.c |  153 +++++++++++++++++++++
 net/rds/tcp_listen.c  |  199 +++++++++++++++++++++++++++
 net/rds/tcp_recv.c    |  356 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/rds/tcp_send.c    |  263 ++++++++++++++++++++++++++++++++++++
 net/rds/tcp_stats.c   |   74 ++++++++++
 8 files changed, 1469 insertions(+), 0 deletions(-)
 create mode 100644 net/rds/tcp.c
 create mode 100644 net/rds/tcp.h
 create mode 100644 net/rds/tcp_connect.c
 create mode 100644 net/rds/tcp_listen.c
 create mode 100644 net/rds/tcp_recv.c
 create mode 100644 net/rds/tcp_send.c
 create mode 100644 net/rds/tcp_stats.c

diff --git a/include/linux/rds.h b/include/linux/rds.h
index d91dc91..89d46e1 100644
--- a/include/linux/rds.h
+++ b/include/linux/rds.h
@@ -147,6 +147,18 @@ struct rds_info_socket {
 	u_int64_t	inum;
 } __attribute__((packed));
 
+struct rds_info_tcp_socket {
+	__be32          local_addr;
+	__be16          local_port;
+	__be32          peer_addr;
+	__be16          peer_port;
+	u_int64_t       hdr_rem;
+	u_int64_t       data_rem;
+	u_int32_t       last_sent_nxt;
+	u_int32_t       last_expected_una;
+	u_int32_t       last_seen_una;
+} __attribute__((packed));
+
 #define RDS_IB_GID_LEN	16
 struct rds_info_rdma_connection {
 	__be32		src_addr;
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
new file mode 100644
index 0000000..e0ac900
--- /dev/null
+++ b/net/rds/tcp.c
@@ -0,0 +1,319 @@
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
+#include <net/tcp.h>
+
+#include "rds.h"
+#include "tcp.h"
+
+/* only for info exporting */
+static DEFINE_SPINLOCK(rds_tcp_tc_list_lock);
+static LIST_HEAD(rds_tcp_tc_list);
+unsigned int rds_tcp_tc_count;
+
+/* Track rds_tcp_connection structs so they can be cleaned up */
+static DEFINE_SPINLOCK(rds_tcp_conn_lock);
+static LIST_HEAD(rds_tcp_conn_list);
+
+static struct kmem_cache *rds_tcp_conn_slab;
+
+#define RDS_TCP_DEFAULT_BUFSIZE (128 * 1024)
+
+/* doing it this way avoids calling tcp_sk() */
+void rds_tcp_nonagle(struct socket *sock)
+{
+	mm_segment_t oldfs = get_fs();
+	int val = 1;
+
+	set_fs(KERNEL_DS);
+	sock->ops->setsockopt(sock, SOL_TCP, TCP_NODELAY, (char __user *)&val,
+			      sizeof(val));
+	set_fs(oldfs);
+}
+
+void rds_tcp_tune(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	rds_tcp_nonagle(sock);
+
+	/*
+	 * We're trying to saturate gigabit with the default,
+	 * see svc_sock_setbufsize().
+	 */
+	lock_sock(sk);
+	sk->sk_sndbuf = RDS_TCP_DEFAULT_BUFSIZE;
+	sk->sk_rcvbuf = RDS_TCP_DEFAULT_BUFSIZE;
+	sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
+	release_sock(sk);
+}
+
+u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc)
+{
+	return tcp_sk(tc->t_sock->sk)->snd_nxt;
+}
+
+u32 rds_tcp_snd_una(struct rds_tcp_connection *tc)
+{
+	return tcp_sk(tc->t_sock->sk)->snd_una;
+}
+
+void rds_tcp_restore_callbacks(struct socket *sock,
+			       struct rds_tcp_connection *tc)
+{
+	rdsdebug("restoring sock %p callbacks from tc %p\n", sock, tc);
+	write_lock_bh(&sock->sk->sk_callback_lock);
+
+	/* done under the callback_lock to serialize with write_space */
+	spin_lock(&rds_tcp_tc_list_lock);
+	list_del_init(&tc->t_list_item);
+	rds_tcp_tc_count--;
+	spin_unlock(&rds_tcp_tc_list_lock);
+
+	tc->t_sock = NULL;
+
+	sock->sk->sk_write_space = tc->t_orig_write_space;
+	sock->sk->sk_data_ready = tc->t_orig_data_ready;
+	sock->sk->sk_state_change = tc->t_orig_state_change;
+	sock->sk->sk_user_data = NULL;
+
+	write_unlock_bh(&sock->sk->sk_callback_lock);
+}
+
+/*
+ * This is the only path that sets tc->t_sock.  Send and receive trust that
+ * it is set.  The RDS_CONN_CONNECTED bit protects those paths from being
+ * called while it isn't set.
+ */
+void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn)
+{
+	struct rds_tcp_connection *tc = conn->c_transport_data;
+
+	rdsdebug("setting sock %p callbacks to tc %p\n", sock, tc);
+	write_lock_bh(&sock->sk->sk_callback_lock);
+
+	/* done under the callback_lock to serialize with write_space */
+	spin_lock(&rds_tcp_tc_list_lock);
+	list_add_tail(&tc->t_list_item, &rds_tcp_tc_list);
+	rds_tcp_tc_count++;
+	spin_unlock(&rds_tcp_tc_list_lock);
+
+	/* accepted sockets need our listen data ready undone */
+	if (sock->sk->sk_data_ready == rds_tcp_listen_data_ready)
+		sock->sk->sk_data_ready = sock->sk->sk_user_data;
+
+	tc->t_sock = sock;
+	tc->conn = conn;
+	tc->t_orig_data_ready = sock->sk->sk_data_ready;
+	tc->t_orig_write_space = sock->sk->sk_write_space;
+	tc->t_orig_state_change = sock->sk->sk_state_change;
+
+	sock->sk->sk_user_data = conn;
+	sock->sk->sk_data_ready = rds_tcp_data_ready;
+	sock->sk->sk_write_space = rds_tcp_write_space;
+	sock->sk->sk_state_change = rds_tcp_state_change;
+
+	write_unlock_bh(&sock->sk->sk_callback_lock);
+}
+
+static void rds_tcp_tc_info(struct socket *sock, unsigned int len,
+			    struct rds_info_iterator *iter,
+			    struct rds_info_lengths *lens)
+{
+	struct rds_info_tcp_socket tsinfo;
+	struct rds_tcp_connection *tc;
+	unsigned long flags;
+	struct sockaddr_in sin;
+	int sinlen;
+
+	spin_lock_irqsave(&rds_tcp_tc_list_lock, flags);
+
+	if (len / sizeof(tsinfo) < rds_tcp_tc_count)
+		goto out;
+
+	list_for_each_entry(tc, &rds_tcp_tc_list, t_list_item) {
+
+		sock->ops->getname(sock, (struct sockaddr *)&sin, &sinlen, 0);
+		tsinfo.local_addr = sin.sin_addr.s_addr;
+		tsinfo.local_port = sin.sin_port;
+		sock->ops->getname(sock, (struct sockaddr *)&sin, &sinlen, 1);
+		tsinfo.peer_addr = sin.sin_addr.s_addr;
+		tsinfo.peer_port = sin.sin_port;
+
+		tsinfo.hdr_rem = tc->t_tinc_hdr_rem;
+		tsinfo.data_rem = tc->t_tinc_data_rem;
+		tsinfo.last_sent_nxt = tc->t_last_sent_nxt;
+		tsinfo.last_expected_una = tc->t_last_expected_una;
+		tsinfo.last_seen_una = tc->t_last_seen_una;
+
+		rds_info_copy(iter, &tsinfo, sizeof(tsinfo));
+	}
+
+out:
+	lens->nr = rds_tcp_tc_count;
+	lens->each = sizeof(tsinfo);
+
+	spin_unlock_irqrestore(&rds_tcp_tc_list_lock, flags);
+}
+
+static int rds_tcp_laddr_check(__be32 addr)
+{
+	if (inet_addr_type(&init_net, addr) == RTN_LOCAL)
+		return 0;
+	return -EADDRNOTAVAIL;
+}
+
+static int rds_tcp_conn_alloc(struct rds_connection *conn, gfp_t gfp)
+{
+	struct rds_tcp_connection *tc;
+
+	tc = kmem_cache_alloc(rds_tcp_conn_slab, gfp);
+	if (tc == NULL)
+		return -ENOMEM;
+
+	tc->t_sock = NULL;
+	tc->t_tinc = NULL;
+	tc->t_tinc_hdr_rem = sizeof(struct rds_header);
+	tc->t_tinc_data_rem = 0;
+
+	conn->c_transport_data = tc;
+
+	spin_lock_irq(&rds_tcp_conn_lock);
+	list_add_tail(&tc->t_tcp_node, &rds_tcp_conn_list);
+	spin_unlock_irq(&rds_tcp_conn_lock);
+
+	rdsdebug("alloced tc %p\n", conn->c_transport_data);
+	return 0;
+}
+
+static void rds_tcp_conn_free(void *arg)
+{
+	struct rds_tcp_connection *tc = arg;
+	rdsdebug("freeing tc %p\n", tc);
+	kmem_cache_free(rds_tcp_conn_slab, tc);
+}
+
+static void rds_tcp_destroy_conns(void)
+{
+	struct rds_tcp_connection *tc, *_tc;
+	LIST_HEAD(tmp_list);
+
+	/* avoid calling conn_destroy with irqs off */
+	spin_lock_irq(&rds_tcp_conn_lock);
+	list_splice(&rds_tcp_conn_list, &tmp_list);
+	INIT_LIST_HEAD(&rds_tcp_conn_list);
+	spin_unlock_irq(&rds_tcp_conn_lock);
+
+	list_for_each_entry_safe(tc, _tc, &tmp_list, t_tcp_node) {
+		if (tc->conn->c_passive)
+			rds_conn_destroy(tc->conn->c_passive);
+		rds_conn_destroy(tc->conn);
+	}
+}
+
+void rds_tcp_exit(void)
+{
+	rds_info_deregister_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
+	rds_tcp_listen_stop();
+	rds_tcp_destroy_conns();
+	rds_trans_unregister(&rds_tcp_transport);
+	rds_tcp_recv_exit();
+	kmem_cache_destroy(rds_tcp_conn_slab);
+}
+module_exit(rds_tcp_exit);
+
+struct rds_transport rds_tcp_transport = {
+	.laddr_check		= rds_tcp_laddr_check,
+	.xmit_prepare		= rds_tcp_xmit_prepare,
+	.xmit_complete		= rds_tcp_xmit_complete,
+	.xmit_cong_map		= rds_tcp_xmit_cong_map,
+	.xmit			= rds_tcp_xmit,
+	.recv			= rds_tcp_recv,
+	.conn_alloc		= rds_tcp_conn_alloc,
+	.conn_free		= rds_tcp_conn_free,
+	.conn_connect		= rds_tcp_conn_connect,
+	.conn_shutdown		= rds_tcp_conn_shutdown,
+	.inc_copy_to_user	= rds_tcp_inc_copy_to_user,
+	.inc_purge		= rds_tcp_inc_purge,
+	.inc_free		= rds_tcp_inc_free,
+	.stats_info_copy	= rds_tcp_stats_info_copy,
+	.exit			= rds_tcp_exit,
+	.t_owner		= THIS_MODULE,
+	.t_name			= "tcp",
+	.t_prefer_loopback	= 1,
+};
+
+int __init rds_tcp_init(void)
+{
+	int ret;
+
+	rds_tcp_conn_slab = kmem_cache_create("rds_tcp_connection",
+					      sizeof(struct rds_tcp_connection),
+					      0, 0, NULL);
+	if (rds_tcp_conn_slab == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = rds_tcp_recv_init();
+	if (ret)
+		goto out_slab;
+
+	ret = rds_trans_register(&rds_tcp_transport);
+	if (ret)
+		goto out_recv;
+
+	ret = rds_tcp_listen_init();
+	if (ret)
+		goto out_register;
+
+	rds_info_register_func(RDS_INFO_TCP_SOCKETS, rds_tcp_tc_info);
+
+	goto out;
+
+out_register:
+	rds_trans_unregister(&rds_tcp_transport);
+out_recv:
+	rds_tcp_recv_exit();
+out_slab:
+	kmem_cache_destroy(rds_tcp_conn_slab);
+out:
+	return ret;
+}
+module_init(rds_tcp_init);
+
+MODULE_AUTHOR("Oracle Corporation <rds-devel@oss.oracle.com>");
+MODULE_DESCRIPTION("RDS: TCP transport");
+MODULE_LICENSE("Dual BSD/GPL");
+
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
new file mode 100644
index 0000000..844fa6b
--- /dev/null
+++ b/net/rds/tcp.h
@@ -0,0 +1,93 @@
+#ifndef _RDS_TCP_H
+#define _RDS_TCP_H
+
+#define RDS_TCP_PORT	16385
+
+struct rds_tcp_incoming {
+	struct rds_incoming	ti_inc;
+	struct sk_buff_head	ti_skb_list;
+};
+
+struct rds_tcp_connection {
+
+	struct list_head	t_tcp_node;
+	struct rds_connection   *conn;
+	struct socket		*t_sock;
+	void			*t_orig_write_space;
+	void			*t_orig_data_ready;
+	void			*t_orig_state_change;
+
+	struct rds_tcp_incoming	*t_tinc;
+	size_t			t_tinc_hdr_rem;
+	size_t			t_tinc_data_rem;
+
+	/* XXX error report? */
+	struct work_struct	t_conn_w;
+	struct work_struct	t_send_w;
+	struct work_struct	t_down_w;
+	struct work_struct	t_recv_w;
+
+	/* for info exporting only */
+	struct list_head	t_list_item;
+	u32			t_last_sent_nxt;
+	u32			t_last_expected_una;
+	u32			t_last_seen_una;
+};
+
+struct rds_tcp_statistics {
+	uint64_t	s_tcp_data_ready_calls;
+	uint64_t	s_tcp_write_space_calls;
+	uint64_t	s_tcp_sndbuf_full;
+	uint64_t	s_tcp_connect_raced;
+	uint64_t	s_tcp_listen_closed_stale;
+};
+
+/* tcp.c */
+int __init rds_tcp_init(void);
+void rds_tcp_exit(void);
+void rds_tcp_tune(struct socket *sock);
+void rds_tcp_nonagle(struct socket *sock);
+void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn);
+void rds_tcp_restore_callbacks(struct socket *sock,
+			       struct rds_tcp_connection *tc);
+u32 rds_tcp_snd_nxt(struct rds_tcp_connection *tc);
+u32 rds_tcp_snd_una(struct rds_tcp_connection *tc);
+u64 rds_tcp_map_seq(struct rds_tcp_connection *tc, u32 seq);
+extern struct rds_transport rds_tcp_transport;
+
+/* tcp_connect.c */
+int rds_tcp_conn_connect(struct rds_connection *conn);
+void rds_tcp_conn_shutdown(struct rds_connection *conn);
+void rds_tcp_state_change(struct sock *sk);
+
+/* tcp_listen.c */
+int __init rds_tcp_listen_init(void);
+void rds_tcp_listen_stop(void);
+void rds_tcp_listen_data_ready(struct sock *sk, int bytes);
+
+/* tcp_recv.c */
+int __init rds_tcp_recv_init(void);
+void rds_tcp_recv_exit(void);
+void rds_tcp_data_ready(struct sock *sk, int bytes);
+int rds_tcp_recv(struct rds_connection *conn);
+void rds_tcp_inc_purge(struct rds_incoming *inc);
+void rds_tcp_inc_free(struct rds_incoming *inc);
+int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iovec *iov,
+			     size_t size);
+
+/* tcp_send.c */
+void rds_tcp_xmit_prepare(struct rds_connection *conn);
+void rds_tcp_xmit_complete(struct rds_connection *conn);
+int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
+	         unsigned int hdr_off, unsigned int sg, unsigned int off);
+void rds_tcp_write_space(struct sock *sk);
+int rds_tcp_xmit_cong_map(struct rds_connection *conn,
+			  struct rds_cong_map *map, unsigned long offset);
+
+/* tcp_stats.c */
+DECLARE_PER_CPU(struct rds_tcp_statistics, rds_tcp_stats);
+#define rds_tcp_stats_inc(member) rds_stats_inc_which(rds_tcp_stats, member)
+unsigned int rds_tcp_stats_info_copy(struct rds_info_iterator *iter,
+				     unsigned int avail);
+
+#endif
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
new file mode 100644
index 0000000..211522f
--- /dev/null
+++ b/net/rds/tcp_connect.c
@@ -0,0 +1,153 @@
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
+#include <net/tcp.h>
+
+#include "rds.h"
+#include "tcp.h"
+
+void rds_tcp_state_change(struct sock *sk)
+{
+	void (*state_change)(struct sock *sk);
+	struct rds_connection *conn;
+	struct rds_tcp_connection *tc;
+
+	read_lock(&sk->sk_callback_lock);
+	conn = sk->sk_user_data;
+	if (conn == NULL) {
+		state_change = sk->sk_state_change;
+		goto out;
+	}
+	tc = conn->c_transport_data;
+	state_change = tc->t_orig_state_change;
+
+	rdsdebug("sock %p state_change to %d\n", tc->t_sock, sk->sk_state);
+
+	switch(sk->sk_state) {
+		/* ignore connecting sockets as they make progress */
+		case TCP_SYN_SENT:
+		case TCP_SYN_RECV:
+			break;
+		case TCP_ESTABLISHED:
+			rds_connect_complete(conn);
+			break;
+		case TCP_CLOSE:
+			rds_conn_drop(conn);
+		default:
+			break;
+	}
+out:
+	read_unlock(&sk->sk_callback_lock);
+	state_change(sk);
+}
+
+int rds_tcp_conn_connect(struct rds_connection *conn)
+{
+	struct socket *sock = NULL;
+	struct sockaddr_in src, dest;
+	int ret;
+
+	ret = sock_create(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (ret < 0)
+		goto out;
+
+	rds_tcp_tune(sock);
+
+	src.sin_family = AF_INET;
+	src.sin_addr.s_addr = (__force u32)conn->c_laddr;
+	src.sin_port = (__force u16)htons(0);
+
+	ret = sock->ops->bind(sock, (struct sockaddr *)&src, sizeof(src));
+	if (ret) {
+		rdsdebug("bind failed with %d at address %u.%u.%u.%u\n",
+		     ret, NIPQUAD(conn->c_laddr));
+		goto out;
+	}
+
+	dest.sin_family = AF_INET;
+	dest.sin_addr.s_addr = (__force u32)conn->c_faddr;
+	dest.sin_port = (__force u16)htons(RDS_TCP_PORT);
+
+	/*
+	 * once we call connect() we can start getting callbacks and they
+	 * own the socket
+	 */
+	rds_tcp_set_callbacks(sock, conn);
+	ret = sock->ops->connect(sock, (struct sockaddr *)&dest, sizeof(dest),
+				 O_NONBLOCK);
+	sock = NULL;
+
+	rdsdebug("connect to address %u.%u.%u.%u returned %d\n",
+		 NIPQUAD(conn->c_faddr), ret);
+	if (ret == -EINPROGRESS)
+		ret = 0;
+
+out:
+	if (sock)
+		sock_release(sock);
+	return ret;
+}
+
+/*
+ * Before killing the tcp socket this needs to serialize with callbacks.  The
+ * caller has already grabbed the sending sem so we're serialized with other
+ * senders.
+ *
+ * TCP calls the callbacks with the sock lock so we hold it while we reset the
+ * callbacks to those set by TCP.  Our callbacks won't execute again once we
+ * hold the sock lock.
+ */
+void rds_tcp_conn_shutdown(struct rds_connection *conn)
+{
+	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct socket *sock = tc->t_sock;
+
+	rdsdebug("shutting down conn %p tc %p sock %p\n", conn, tc, sock);
+
+	if (sock) {
+		sock->ops->shutdown(sock, RCV_SHUTDOWN | SEND_SHUTDOWN);
+		lock_sock(sock->sk);
+		rds_tcp_restore_callbacks(sock, tc); /* tc->tc_sock = NULL */
+
+		release_sock(sock->sk);
+		sock_release(sock);
+	};
+
+	if (tc->t_tinc) {
+		rds_inc_put(&tc->t_tinc->ti_inc);
+		tc->t_tinc = NULL;
+	}
+	tc->t_tinc_hdr_rem = sizeof(struct rds_header);
+	tc->t_tinc_data_rem = 0;
+}
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
new file mode 100644
index 0000000..24b743e
--- /dev/null
+++ b/net/rds/tcp_listen.c
@@ -0,0 +1,199 @@
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
+#include <net/tcp.h>
+
+#include "rds.h"
+#include "tcp.h"
+
+/*
+ * cheesy, but simple..
+ */
+static void rds_tcp_accept_worker(struct work_struct *work);
+static DECLARE_WORK(rds_tcp_listen_work, rds_tcp_accept_worker);
+static struct socket *rds_tcp_listen_sock;
+
+static int rds_tcp_accept_one(struct socket *sock)
+{
+	struct socket *new_sock = NULL;
+	struct rds_connection *conn;
+	int ret;
+	struct inet_sock *inet;
+
+	ret = sock_create_lite(sock->sk->sk_family, sock->sk->sk_type,
+			       sock->sk->sk_protocol, &new_sock);
+	if (ret)
+		goto out;
+
+	new_sock->type = sock->type;
+	new_sock->ops = sock->ops;
+	ret = sock->ops->accept(sock, new_sock, O_NONBLOCK);
+	if (ret < 0)
+		goto out;
+
+	rds_tcp_tune(new_sock);
+
+	inet = inet_sk(new_sock->sk);
+
+	rdsdebug("accepted tcp %u.%u.%u.%u:%u -> %u.%u.%u.%u:%u\n",
+		  NIPQUAD(inet->saddr), ntohs(inet->sport),
+		  NIPQUAD(inet->daddr), ntohs(inet->dport));
+
+	conn = rds_conn_create(inet->saddr, inet->daddr, &rds_tcp_transport,
+			       GFP_KERNEL);
+	if (IS_ERR(conn)) {
+		ret = PTR_ERR(conn);
+		goto out;
+	}
+
+	/*
+	 * see the comment above rds_queue_delayed_reconnect()
+	 */
+	if (!rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING)) {
+		if (rds_conn_state(conn) == RDS_CONN_UP)
+			rds_tcp_stats_inc(s_tcp_listen_closed_stale);
+		else
+			rds_tcp_stats_inc(s_tcp_connect_raced);
+		rds_conn_drop(conn);
+		ret = 0;
+		goto out;
+	}
+
+	rds_tcp_set_callbacks(new_sock, conn);
+	rds_connect_complete(conn);
+	new_sock = NULL;
+	ret = 0;
+
+out:
+	if (new_sock)
+		sock_release(new_sock);
+	return ret;
+}
+
+static void rds_tcp_accept_worker(struct work_struct *work)
+{
+	while (rds_tcp_accept_one(rds_tcp_listen_sock) == 0)
+		cond_resched();
+}
+
+void rds_tcp_listen_data_ready(struct sock *sk, int bytes)
+{
+	void (*ready)(struct sock *sk, int bytes);
+
+	rdsdebug("listen data ready sk %p\n", sk);
+
+	read_lock(&sk->sk_callback_lock);
+	ready = sk->sk_user_data;
+	if (ready == NULL) { /* check for teardown race */
+		ready = sk->sk_data_ready;
+		goto out;
+	}
+
+	/*
+	 * ->sk_data_ready is also called for a newly established child socket
+	 * before it has been accepted and the accepter has set up their
+	 * data_ready.. we only want to queue listen work for our listening
+	 * socket
+	 */
+	if (sk->sk_state == TCP_LISTEN)
+		queue_work(rds_wq, &rds_tcp_listen_work);
+
+out:
+	read_unlock(&sk->sk_callback_lock);
+	ready(sk, bytes);
+}
+
+int __init rds_tcp_listen_init(void)
+{
+	struct sockaddr_in sin;
+	struct socket *sock = NULL;
+	int ret;
+
+	ret = sock_create(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (ret < 0)
+		goto out;
+
+	sock->sk->sk_reuse = 1;
+	rds_tcp_nonagle(sock);
+
+	write_lock_bh(&sock->sk->sk_callback_lock);
+	sock->sk->sk_user_data = sock->sk->sk_data_ready;
+	sock->sk->sk_data_ready = rds_tcp_listen_data_ready;
+	write_unlock_bh(&sock->sk->sk_callback_lock);
+
+	sin.sin_family = PF_INET,
+	sin.sin_addr.s_addr = (__force u32)htonl(INADDR_ANY);
+	sin.sin_port = (__force u16)htons(RDS_TCP_PORT);
+
+	ret = sock->ops->bind(sock, (struct sockaddr *)&sin, sizeof(sin));
+	if (ret < 0)
+		goto out;
+
+	ret = sock->ops->listen(sock, 64);
+	if (ret < 0)
+		goto out;
+
+	rds_tcp_listen_sock = sock;
+	sock = NULL;
+out:
+	if (sock)
+		sock_release(sock);
+	return ret;
+}
+
+void rds_tcp_listen_stop(void)
+{
+	struct socket *sock = rds_tcp_listen_sock;
+	struct sock *sk;
+
+	if (sock == NULL)
+		return;
+
+	sk = sock->sk;
+
+	/* serialize with and prevent further callbacks */
+	lock_sock(sk);
+	write_lock_bh(&sk->sk_callback_lock);
+	if (sk->sk_user_data) {
+		sk->sk_data_ready = sk->sk_user_data;
+		sk->sk_user_data = NULL;
+	}
+	write_unlock_bh(&sk->sk_callback_lock);
+	release_sock(sk);
+
+	/* wait for accepts to stop and close the socket */
+	flush_workqueue(rds_wq);
+	sock_release(sock);
+	rds_tcp_listen_sock = NULL;
+}
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
new file mode 100644
index 0000000..c00daff
--- /dev/null
+++ b/net/rds/tcp_recv.c
@@ -0,0 +1,356 @@
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
+#include <net/tcp.h>
+
+#include "rds.h"
+#include "tcp.h"
+
+static struct kmem_cache *rds_tcp_incoming_slab;
+
+void rds_tcp_inc_purge(struct rds_incoming *inc)
+{
+	struct rds_tcp_incoming *tinc;
+	tinc = container_of(inc, struct rds_tcp_incoming, ti_inc);
+	rdsdebug("purging tinc %p inc %p\n", tinc, inc);
+	skb_queue_purge(&tinc->ti_skb_list);
+}
+
+void rds_tcp_inc_free(struct rds_incoming *inc)
+{
+	struct rds_tcp_incoming *tinc;
+	tinc = container_of(inc, struct rds_tcp_incoming, ti_inc);
+	rds_tcp_inc_purge(inc);
+	rdsdebug("freeing tinc %p inc %p\n", tinc, inc);
+	kmem_cache_free(rds_tcp_incoming_slab, tinc);
+}
+
+/*
+ * this is pretty lame, but, whatever.
+ */
+int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iovec *first_iov,
+			     size_t size)
+{
+	struct rds_tcp_incoming *tinc;
+	struct iovec *iov, tmp;
+	struct sk_buff *skb;
+	unsigned long to_copy, skb_off;
+	int ret = 0;
+
+	if (size == 0)
+		goto out;
+
+	tinc = container_of(inc, struct rds_tcp_incoming, ti_inc);
+	iov = first_iov;
+	tmp = *iov;
+
+	skb_queue_walk(&tinc->ti_skb_list, skb) {
+		skb_off = 0;
+		while (skb_off < skb->len) {
+			while (tmp.iov_len == 0) {
+				iov++;
+				tmp = *iov;
+			}
+
+			to_copy = min(tmp.iov_len, size);
+			to_copy = min(to_copy, skb->len - skb_off);
+
+			rdsdebug("ret %d size %zu skb %p skb_off %lu "
+				 "skblen %d iov_base %p iov_len %zu cpy %lu\n",
+				 ret, size, skb, skb_off, skb->len,
+				 tmp.iov_base, tmp.iov_len, to_copy);
+
+			/* modifies tmp as it copies */
+			if (skb_copy_datagram_iovec(skb, skb_off, &tmp,
+						    to_copy)) {
+				ret = -EFAULT;
+				goto out;
+			}
+
+			size -= to_copy;
+			ret += to_copy;
+			skb_off += to_copy;
+			if (size == 0)
+				goto out;
+		}
+	}
+out:
+	return ret;
+}
+
+/*
+ * We have a series of skbs that have fragmented pieces of the congestion
+ * bitmap.  They must add up to the exact size of the congestion bitmap.  We
+ * use the skb helpers to copy those into the pages that make up the in-memory
+ * congestion bitmap for the remote address of this connection.  We then tell
+ * the congestion core that the bitmap has been changed so that it can wake up
+ * sleepers.
+ *
+ * This is racing with sending paths which are using test_bit to see if the
+ * bitmap indicates that their recipient is congested.
+ */
+
+static void rds_tcp_cong_recv(struct rds_connection *conn,
+			      struct rds_tcp_incoming *tinc)
+{
+	struct sk_buff *skb;
+	unsigned int to_copy, skb_off;
+	unsigned int map_off;
+	unsigned int map_page;
+	struct rds_cong_map *map;
+	int ret;
+
+	/* catch completely corrupt packets */
+	if (be32_to_cpu(tinc->ti_inc.i_hdr.h_len) != RDS_CONG_MAP_BYTES)
+		return;
+
+	map_page = 0;
+	map_off = 0;
+	map = conn->c_fcong;
+
+	skb_queue_walk(&tinc->ti_skb_list, skb) {
+		skb_off = 0;
+		while (skb_off < skb->len) {
+			to_copy = min_t(unsigned int, PAGE_SIZE - map_off,
+					skb->len - skb_off);
+
+			BUG_ON(map_page >= RDS_CONG_MAP_PAGES);
+
+			/* only returns 0 or -error */
+			ret = skb_copy_bits(skb, skb_off,
+				(void *)map->m_page_addrs[map_page] + map_off,
+				to_copy);
+			BUG_ON(ret != 0);
+
+			skb_off += to_copy;
+			map_off += to_copy;
+			if (map_off == PAGE_SIZE) {
+				map_off = 0;
+				map_page++;
+			}
+		}
+	}
+
+	rds_cong_map_updated(map, ~(u64) 0);
+}
+
+struct rds_tcp_desc_arg {
+	struct rds_connection *conn;
+	gfp_t gfp;
+	enum km_type km;
+};
+
+static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
+			     unsigned int offset, size_t len)
+{
+	struct rds_tcp_desc_arg *arg = desc->arg.data;
+	struct rds_connection *conn = arg->conn;
+	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_tcp_incoming *tinc = tc->t_tinc;
+	struct sk_buff *clone;
+	size_t left = len, to_copy;
+
+	rdsdebug("tcp data tc %p skb %p offset %u len %zu\n", tc, skb, offset,
+		 len);
+
+	/*
+	 * tcp_read_sock() interprets partial progress as an indication to stop
+	 * processing.
+	 */
+	while (left) {
+		if (tinc == NULL) {
+			tinc = kmem_cache_alloc(rds_tcp_incoming_slab,
+					        arg->gfp);
+			if (tinc == NULL) {
+				desc->error = -ENOMEM;
+				goto out;
+			}
+			tc->t_tinc = tinc;
+			rdsdebug("alloced tinc %p\n", tinc);
+			rds_inc_init(&tinc->ti_inc, conn, conn->c_faddr);
+			/*
+			 * XXX * we might be able to use the __ variants when
+			 * we've already serialized at a higher level.
+			 */
+			skb_queue_head_init(&tinc->ti_skb_list);
+		}
+
+		if (left && tc->t_tinc_hdr_rem) {
+			to_copy = min(tc->t_tinc_hdr_rem, left);
+			rdsdebug("copying %zu header from skb %p\n", to_copy,
+				 skb);
+			skb_copy_bits(skb, offset,
+				      (char *)&tinc->ti_inc.i_hdr +
+						sizeof(struct rds_header) -
+						tc->t_tinc_hdr_rem,
+				      to_copy);
+			tc->t_tinc_hdr_rem -= to_copy;
+			left -= to_copy;
+			offset += to_copy;
+
+			if (tc->t_tinc_hdr_rem == 0) {
+				/* could be 0 for a 0 len message */
+				tc->t_tinc_data_rem =
+					be32_to_cpu(tinc->ti_inc.i_hdr.h_len);
+			}
+		}
+
+		if (left && tc->t_tinc_data_rem) {
+			clone = skb_clone(skb, arg->gfp);
+			if (clone == NULL) {
+				desc->error = -ENOMEM;
+				goto out;
+			}
+
+			to_copy = min(tc->t_tinc_data_rem, left);
+			pskb_pull(clone, offset);
+			pskb_trim(clone, to_copy);
+			skb_queue_tail(&tinc->ti_skb_list, clone);
+
+			rdsdebug("skb %p data %p len %d off %u to_copy %zu -> "
+				 "clone %p data %p len %d\n",
+				 skb, skb->data, skb->len, offset, to_copy,
+				 clone, clone->data, clone->len);
+
+			tc->t_tinc_data_rem -= to_copy;
+			left -= to_copy;
+			offset += to_copy;
+		}
+
+		if (tc->t_tinc_hdr_rem == 0 && tc->t_tinc_data_rem == 0) {
+			if (tinc->ti_inc.i_hdr.h_flags == RDS_FLAG_CONG_BITMAP)
+				rds_tcp_cong_recv(conn, tinc);
+			else
+				rds_recv_incoming(conn, conn->c_faddr,
+						  conn->c_laddr, &tinc->ti_inc,
+						  arg->gfp, arg->km);
+
+			tc->t_tinc_hdr_rem = sizeof(struct rds_header);
+			tc->t_tinc_data_rem = 0;
+			tc->t_tinc = NULL;
+			rds_inc_put(&tinc->ti_inc);
+			tinc = NULL;
+		}
+	}
+out:
+	rdsdebug("returning len %zu left %zu skb len %d rx queue depth %d\n",
+		 len, left, skb->len,
+		 skb_queue_len(&tc->t_sock->sk->sk_receive_queue));
+	return len - left;
+}
+
+/* the caller has to hold the sock lock */
+int rds_tcp_read_sock(struct rds_connection *conn, gfp_t gfp, enum km_type km)
+{
+	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct socket *sock = tc->t_sock;
+	read_descriptor_t desc;
+	struct rds_tcp_desc_arg arg;
+
+	/* It's like glib in the kernel! */
+	arg.conn = conn;
+	arg.gfp = gfp;
+	arg.km = km;
+	desc.arg.data = &arg;
+	desc.error = 0;
+	desc.count = 1; /* give more than one skb per call */
+
+	tcp_read_sock(sock->sk, &desc, rds_tcp_data_recv);
+	rdsdebug("tcp_read_sock for tc %p gfp 0x%x returned %d\n", tc, gfp,
+		 desc.error);
+
+	return desc.error;
+}
+
+/*
+ * We hold the sock lock to serialize our rds_tcp_recv->tcp_read_sock from
+ * data_ready.
+ *
+ * if we fail to allocate we're in trouble.. blindly wait some time before
+ * trying again to see if the VM can free up something for us.
+ */
+int rds_tcp_recv(struct rds_connection *conn)
+{
+	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct socket *sock = tc->t_sock;
+	int ret = 0;
+
+	rdsdebug("recv worker conn %p tc %p sock %p\n", conn, tc, sock);
+
+	lock_sock(sock->sk);
+	ret = rds_tcp_read_sock(conn, GFP_KERNEL, KM_USER0);
+	release_sock(sock->sk);
+
+	return ret;
+}
+
+void rds_tcp_data_ready(struct sock *sk, int bytes)
+{
+	void (*ready)(struct sock *sk, int bytes);
+	struct rds_connection *conn;
+	struct rds_tcp_connection *tc;
+
+	rdsdebug("data ready sk %p bytes %d\n", sk, bytes);
+
+	read_lock(&sk->sk_callback_lock);
+	conn = sk->sk_user_data;
+	if (conn == NULL) { /* check for teardown race */
+		ready = sk->sk_data_ready;
+		goto out;
+	}
+
+	tc = conn->c_transport_data;
+	ready = tc->t_orig_data_ready;
+	rds_tcp_stats_inc(s_tcp_data_ready_calls);
+
+	if (rds_tcp_read_sock(conn, GFP_ATOMIC, KM_SOFTIRQ0) == -ENOMEM)
+		queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
+out:
+	read_unlock(&sk->sk_callback_lock);
+	ready(sk, bytes);
+}
+
+int __init rds_tcp_recv_init(void)
+{
+	rds_tcp_incoming_slab = kmem_cache_create("rds_tcp_incoming",
+					sizeof(struct rds_tcp_incoming),
+					0, 0, NULL);
+	if (rds_tcp_incoming_slab == NULL)
+		return -ENOMEM;
+	return 0;
+}
+
+void rds_tcp_recv_exit(void)
+{
+	kmem_cache_destroy(rds_tcp_incoming_slab);
+}
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
new file mode 100644
index 0000000..ab545e0
--- /dev/null
+++ b/net/rds/tcp_send.c
@@ -0,0 +1,263 @@
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
+#include <net/tcp.h>
+
+#include "rds.h"
+#include "tcp.h"
+
+static void rds_tcp_cork(struct socket *sock, int val)
+{
+	mm_segment_t oldfs;
+
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+	sock->ops->setsockopt(sock, SOL_TCP, TCP_CORK, (char __user *)&val,
+			      sizeof(val));
+	set_fs(oldfs);
+}
+
+void rds_tcp_xmit_prepare(struct rds_connection *conn)
+{
+	struct rds_tcp_connection *tc = conn->c_transport_data;
+
+	rds_tcp_cork(tc->t_sock, 1);
+}
+
+void rds_tcp_xmit_complete(struct rds_connection *conn)
+{
+	struct rds_tcp_connection *tc = conn->c_transport_data;
+
+	rds_tcp_cork(tc->t_sock, 0);
+}
+
+/* the core send_sem serializes this with other xmit and shutdown */
+int rds_tcp_sendmsg(struct socket *sock, void *data, unsigned int len)
+{
+	struct kvec vec = {
+                .iov_base = data,
+                .iov_len = len,
+	};
+        struct msghdr msg = {
+                .msg_flags = MSG_DONTWAIT | MSG_NOSIGNAL,
+        };
+
+	return kernel_sendmsg(sock, &msg, &vec, 1, vec.iov_len);
+}
+
+/* the core send_sem serializes this with other xmit and shutdown */
+int rds_tcp_xmit_cong_map(struct rds_connection *conn,
+			  struct rds_cong_map *map, unsigned long offset)
+{
+	static struct rds_header rds_tcp_map_header = {
+		.h_flags = RDS_FLAG_CONG_BITMAP,
+	};
+	struct rds_tcp_connection *tc = conn->c_transport_data;
+	unsigned long i;
+	int ret;
+	int copied = 0;
+
+	/* Some problem claims cpu_to_be32(constant) isn't a constant. */
+	rds_tcp_map_header.h_len = cpu_to_be32(RDS_CONG_MAP_BYTES);
+
+	if (offset < sizeof(struct rds_header)) {
+		ret = rds_tcp_sendmsg(tc->t_sock,
+				      (void *)&rds_tcp_map_header + offset,
+				      sizeof(struct rds_header) - offset);
+		if (ret <= 0)
+			return ret;
+		offset += ret;
+		copied = ret;
+		if (offset < sizeof(struct rds_header))
+			return ret;
+	}
+
+	offset -= sizeof(struct rds_header);
+	i = offset / PAGE_SIZE;
+	offset = offset % PAGE_SIZE;
+	BUG_ON(i >= RDS_CONG_MAP_PAGES);
+
+	do {
+		ret = tc->t_sock->ops->sendpage(tc->t_sock,
+					virt_to_page(map->m_page_addrs[i]),
+					offset, PAGE_SIZE - offset,
+					MSG_DONTWAIT);
+		if (ret <= 0)
+			break;
+		copied += ret;
+		offset += ret;
+		if (offset == PAGE_SIZE) {
+			offset = 0;
+			i++;
+		}
+	} while (i < RDS_CONG_MAP_PAGES);
+
+        return copied ? copied : ret;
+}
+
+/* the core send_sem serializes this with other xmit and shutdown */
+int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
+	         unsigned int hdr_off, unsigned int sg, unsigned int off)
+{
+	struct rds_tcp_connection *tc = conn->c_transport_data;
+	int done = 0;
+	int ret = 0;
+
+	if (hdr_off == 0) {
+		/*
+		 * m_ack_seq is set to the sequence number of the last byte of
+		 * header and data.  see rds_tcp_is_acked().
+		 */
+		tc->t_last_sent_nxt = rds_tcp_snd_nxt(tc);
+		rm->m_ack_seq = tc->t_last_sent_nxt +
+				sizeof(struct rds_header) +
+				be32_to_cpu(rm->m_inc.i_hdr.h_len) - 1;
+		smp_mb__before_clear_bit();
+		set_bit(RDS_MSG_HAS_ACK_SEQ, &rm->m_flags);
+		tc->t_last_expected_una = rm->m_ack_seq + 1;
+
+		rdsdebug("rm %p tcp nxt %u ack_seq %llu\n",
+			 rm, rds_tcp_snd_nxt(tc),
+			 (unsigned long long)rm->m_ack_seq);
+	}
+
+	if (hdr_off < sizeof(struct rds_header)) {
+		/* see rds_tcp_write_space() */
+		set_bit(SOCK_NOSPACE, &tc->t_sock->sk->sk_socket->flags);
+
+		ret = rds_tcp_sendmsg(tc->t_sock,
+				      (void *)&rm->m_inc.i_hdr + hdr_off,
+				      sizeof(rm->m_inc.i_hdr) - hdr_off);
+		if (ret < 0)
+			goto out;
+		done += ret;
+		if (hdr_off + done != sizeof(struct rds_header))
+			goto out;
+	}
+
+	while (sg < rm->m_nents) {
+		ret = tc->t_sock->ops->sendpage(tc->t_sock,
+						sg_page(&rm->m_sg[sg]),
+						rm->m_sg[sg].offset + off,
+						rm->m_sg[sg].length - off,
+						MSG_DONTWAIT|MSG_NOSIGNAL);
+		rdsdebug("tcp sendpage %p:%u:%u ret %d\n", (void *)sg_page(&rm->m_sg[sg]),
+			 rm->m_sg[sg].offset + off, rm->m_sg[sg].length - off,
+			 ret);
+		if (ret <= 0)
+			break;
+
+		off += ret;
+		done += ret;
+		if (off == rm->m_sg[sg].length) {
+			off = 0;
+			sg++;
+		}
+	}
+
+out:
+	if (ret <= 0) {
+		/* write_space will hit after EAGAIN, all else fatal */
+		if (ret == -EAGAIN) {
+			rds_tcp_stats_inc(s_tcp_sndbuf_full);
+			ret = 0;
+		} else {
+			printk(KERN_WARNING "RDS/tcp: send to %u.%u.%u.%u "
+			       "returned %d, disconnecting and reconnecting\n",
+			       NIPQUAD(conn->c_faddr), ret);
+			rds_conn_drop(conn);
+		}
+	}
+	if (done == 0)
+		done = ret;
+	return done;
+}
+
+/*
+ * rm->m_ack_seq is set to the tcp sequence number that corresponds to the
+ * last byte of the message, including the header.  This means that the
+ * entire message has been received if rm->m_ack_seq is "before" the next
+ * unacked byte of the TCP sequence space.  We have to do very careful
+ * wrapping 32bit comparisons here.
+ */
+static int rds_tcp_is_acked(struct rds_message *rm, uint64_t ack)
+{
+	if (!test_bit(RDS_MSG_HAS_ACK_SEQ, &rm->m_flags))
+		return 0;
+	return (__s32)((u32)rm->m_ack_seq - (u32)ack) < 0;
+}
+
+void rds_tcp_write_space(struct sock *sk)
+{
+	void (*write_space)(struct sock *sk);
+	struct rds_connection *conn;
+	struct rds_tcp_connection *tc;
+
+	read_lock(&sk->sk_callback_lock);
+	conn = sk->sk_user_data;
+	if (conn == NULL) {
+		write_space = sk->sk_write_space;
+		goto out;
+	}
+
+	tc = conn->c_transport_data;
+	rdsdebug("write_space for tc %p\n", tc);
+	write_space = tc->t_orig_write_space;
+	rds_tcp_stats_inc(s_tcp_write_space_calls);
+
+	rdsdebug("tcp una %u\n", rds_tcp_snd_una(tc));
+	tc->t_last_seen_una = rds_tcp_snd_una(tc);
+	rds_send_drop_acked(conn, rds_tcp_snd_una(tc), rds_tcp_is_acked);
+
+	queue_delayed_work(rds_wq, &conn->c_send_w, 0);
+out:
+	read_unlock(&sk->sk_callback_lock);
+
+	/*
+	 * write_space is only called when data leaves tcp's send queue if
+	 * SOCK_NOSPACE is set.  We set SOCK_NOSPACE every time we put
+	 * data in tcp's send queue because we use write_space to parse the
+	 * sequence numbers and notice that rds messages have been fully
+	 * received.
+	 *
+	 * tcp's write_space clears SOCK_NOSPACE if the send queue has more
+	 * than a certain amount of space. So we need to set it again *after*
+	 * we call tcp's write_space or else we might only get called on the
+	 * first of a series of incoming tcp acks.
+	 */
+	write_space(sk);
+
+	if (sk->sk_socket)
+		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
+}
diff --git a/net/rds/tcp_stats.c b/net/rds/tcp_stats.c
new file mode 100644
index 0000000..d5898d0
--- /dev/null
+++ b/net/rds/tcp_stats.c
@@ -0,0 +1,74 @@
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
+#include <linux/percpu.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
+
+#include "rds.h"
+#include "tcp.h"
+
+DEFINE_PER_CPU(struct rds_tcp_statistics, rds_tcp_stats)
+	____cacheline_aligned;
+
+static const char const *rds_tcp_stat_names[] = {
+	"tcp_data_ready_calls",
+	"tcp_write_space_calls",
+	"tcp_sndbuf_full",
+	"tcp_connect_raced",
+	"tcp_listen_closed_stale",
+};
+
+unsigned int rds_tcp_stats_info_copy(struct rds_info_iterator *iter,
+				     unsigned int avail)
+{
+	struct rds_tcp_statistics stats = {0, };
+	uint64_t *src;
+	uint64_t *sum;
+	size_t i;
+	int cpu;
+
+	if (avail < ARRAY_SIZE(rds_tcp_stat_names))
+		goto out;
+
+	for_each_online_cpu(cpu) {
+		src = (uint64_t *)&(per_cpu(rds_tcp_stats, cpu));
+		sum = (uint64_t *)&stats;
+		for (i = 0; i < sizeof(stats) / sizeof(uint64_t); i++)
+			*(sum++) += *(src++);
+	}
+
+	rds_stats_info_copy(iter, (uint64_t *)&stats, rds_tcp_stat_names,
+			    ARRAY_SIZE(rds_tcp_stat_names));
+out:
+	return ARRAY_SIZE(rds_tcp_stat_names);
+}
-- 
1.6.0.4

