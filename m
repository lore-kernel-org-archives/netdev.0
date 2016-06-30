From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 6/9] RDS: TCP: make receive path use the rds_conn_path
Date: Thu, 30 Jun 2016 16:11:15 -0700
Message-ID: <4d725517aba6ba787402589616818cc55226848a.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	sowmini.varadhan@oracle.com, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:44442 "EHLO
	aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbcF3XMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 19:12:21 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
	by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u5UNC6Q4007268
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 23:12:07 GMT
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ->sk_user_data contains a pointer to the rds_conn_path
for the socket. Use this consistently in the rds_tcp_data_ready
callbacks to get the rds_conn_path for rds_recv_incoming.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/ib.c       |    2 +-
 net/rds/ib.h       |    2 +-
 net/rds/ib_recv.c  |    3 ++-
 net/rds/loop.c     |    4 ++--
 net/rds/rds.h      |    2 +-
 net/rds/tcp.c      |    2 +-
 net/rds/tcp.h      |    2 +-
 net/rds/tcp_recv.c |   29 ++++++++++++++++-------------
 net/rds/threads.c  |    2 +-
 9 files changed, 26 insertions(+), 22 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 1b29ec9..e6ba856 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -385,7 +385,7 @@ struct rds_transport rds_ib_transport = {
 	.xmit			= rds_ib_xmit,
 	.xmit_rdma		= rds_ib_xmit_rdma,
 	.xmit_atomic		= rds_ib_xmit_atomic,
-	.recv			= rds_ib_recv,
+	.recv_path		= rds_ib_recv_path,
 	.conn_alloc		= rds_ib_conn_alloc,
 	.conn_free		= rds_ib_conn_free,
 	.conn_connect		= rds_ib_conn_connect,
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 2051f4b..579de7e 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -354,7 +354,7 @@ void rds_ib_mr_cqe_handler(struct rds_ib_connection *ic, struct ib_wc *wc);
 /* ib_recv.c */
 int rds_ib_recv_init(void);
 void rds_ib_recv_exit(void);
-int rds_ib_recv(struct rds_connection *conn);
+int rds_ib_recv_path(struct rds_conn_path *conn);
 int rds_ib_recv_alloc_caches(struct rds_ib_connection *ic);
 void rds_ib_recv_free_caches(struct rds_ib_connection *ic);
 void rds_ib_recv_refill(struct rds_connection *conn, int prefill, gfp_t gfp);
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 4ea8cb1..606a11f 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -1009,8 +1009,9 @@ void rds_ib_recv_cqe_handler(struct rds_ib_connection *ic,
 		rds_ib_recv_refill(conn, 0, GFP_NOWAIT);
 }
 
-int rds_ib_recv(struct rds_connection *conn)
+int rds_ib_recv_path(struct rds_conn_path *cp)
 {
+	struct rds_connection *conn = cp->cp_conn;
 	struct rds_ib_connection *ic = conn->c_transport_data;
 	int ret = 0;
 
diff --git a/net/rds/loop.c b/net/rds/loop.c
index 318c21d..20284a4 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -102,7 +102,7 @@ static void rds_loop_inc_free(struct rds_incoming *inc)
 }
 
 /* we need to at least give the thread something to succeed */
-static int rds_loop_recv(struct rds_connection *conn)
+static int rds_loop_recv_path(struct rds_conn_path *cp)
 {
 	return 0;
 }
@@ -185,7 +185,7 @@ void rds_loop_exit(void)
  */
 struct rds_transport rds_loop_transport = {
 	.xmit			= rds_loop_xmit,
-	.recv			= rds_loop_recv,
+	.recv_path		= rds_loop_recv_path,
 	.conn_alloc		= rds_loop_conn_alloc,
 	.conn_free		= rds_loop_conn_free,
 	.conn_connect		= rds_loop_conn_connect,
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 5bbad08..0faca30 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -462,7 +462,7 @@ struct rds_transport {
 		    unsigned int hdr_off, unsigned int sg, unsigned int off);
 	int (*xmit_rdma)(struct rds_connection *conn, struct rm_rdma_op *op);
 	int (*xmit_atomic)(struct rds_connection *conn, struct rm_atomic_op *op);
-	int (*recv)(struct rds_connection *conn);
+	int (*recv_path)(struct rds_conn_path *cp);
 	int (*inc_copy_to_user)(struct rds_incoming *inc, struct iov_iter *to);
 	void (*inc_free)(struct rds_incoming *inc);
 
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 5658f3e..7bc136c 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -359,7 +359,7 @@ struct rds_transport rds_tcp_transport = {
 	.xmit_path_prepare	= rds_tcp_xmit_path_prepare,
 	.xmit_path_complete	= rds_tcp_xmit_path_complete,
 	.xmit			= rds_tcp_xmit,
-	.recv			= rds_tcp_recv,
+	.recv_path		= rds_tcp_recv_path,
 	.conn_alloc		= rds_tcp_conn_alloc,
 	.conn_free		= rds_tcp_conn_free,
 	.conn_connect		= rds_tcp_conn_connect,
diff --git a/net/rds/tcp.h b/net/rds/tcp.h
index 151b09d..5a5f91a 100644
--- a/net/rds/tcp.h
+++ b/net/rds/tcp.h
@@ -75,7 +75,7 @@ int rds_tcp_keepalive(struct socket *sock);
 int rds_tcp_recv_init(void);
 void rds_tcp_recv_exit(void);
 void rds_tcp_data_ready(struct sock *sk);
-int rds_tcp_recv(struct rds_connection *conn);
+int rds_tcp_recv_path(struct rds_conn_path *cp);
 void rds_tcp_inc_free(struct rds_incoming *inc);
 int rds_tcp_inc_copy_to_user(struct rds_incoming *inc, struct iov_iter *to);
 
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index aa7a79a..ad4892e 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -34,7 +34,6 @@
 #include <linux/slab.h>
 #include <net/tcp.h>
 
-#include "rds_single_path.h"
 #include "rds.h"
 #include "tcp.h"
 
@@ -148,7 +147,7 @@ static void rds_tcp_cong_recv(struct rds_connection *conn,
 }
 
 struct rds_tcp_desc_arg {
-	struct rds_connection *conn;
+	struct rds_conn_path *conn_path;
 	gfp_t gfp;
 };
 
@@ -156,8 +155,8 @@ static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
 			     unsigned int offset, size_t len)
 {
 	struct rds_tcp_desc_arg *arg = desc->arg.data;
-	struct rds_connection *conn = arg->conn;
-	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_conn_path *cp = arg->conn_path;
+	struct rds_tcp_connection *tc = cp->cp_transport_data;
 	struct rds_tcp_incoming *tinc = tc->t_tinc;
 	struct sk_buff *clone;
 	size_t left = len, to_copy;
@@ -179,7 +178,8 @@ static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
 			}
 			tc->t_tinc = tinc;
 			rdsdebug("alloced tinc %p\n", tinc);
-			rds_inc_init(&tinc->ti_inc, conn, conn->c_faddr);
+			rds_inc_path_init(&tinc->ti_inc, cp,
+					  cp->cp_conn->c_faddr);
 			/*
 			 * XXX * we might be able to use the __ variants when
 			 * we've already serialized at a higher level.
@@ -229,6 +229,8 @@ static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
 		}
 
 		if (tc->t_tinc_hdr_rem == 0 && tc->t_tinc_data_rem == 0) {
+			struct rds_connection *conn = cp->cp_conn;
+
 			if (tinc->ti_inc.i_hdr.h_flags == RDS_FLAG_CONG_BITMAP)
 				rds_tcp_cong_recv(conn, tinc);
 			else
@@ -251,15 +253,15 @@ static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
 }
 
 /* the caller has to hold the sock lock */
-static int rds_tcp_read_sock(struct rds_connection *conn, gfp_t gfp)
+static int rds_tcp_read_sock(struct rds_conn_path *cp, gfp_t gfp)
 {
-	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_tcp_connection *tc = cp->cp_transport_data;
 	struct socket *sock = tc->t_sock;
 	read_descriptor_t desc;
 	struct rds_tcp_desc_arg arg;
 
 	/* It's like glib in the kernel! */
-	arg.conn = conn;
+	arg.conn_path = cp;
 	arg.gfp = gfp;
 	desc.arg.data = &arg;
 	desc.error = 0;
@@ -279,16 +281,17 @@ static int rds_tcp_read_sock(struct rds_connection *conn, gfp_t gfp)
  * if we fail to allocate we're in trouble.. blindly wait some time before
  * trying again to see if the VM can free up something for us.
  */
-int rds_tcp_recv(struct rds_connection *conn)
+int rds_tcp_recv_path(struct rds_conn_path *cp)
 {
-	struct rds_tcp_connection *tc = conn->c_transport_data;
+	struct rds_tcp_connection *tc = cp->cp_transport_data;
 	struct socket *sock = tc->t_sock;
 	int ret = 0;
 
-	rdsdebug("recv worker conn %p tc %p sock %p\n", conn, tc, sock);
+	rdsdebug("recv worker path [%d] tc %p sock %p\n",
+		 cp->cp_index, tc, sock);
 
 	lock_sock(sock->sk);
-	ret = rds_tcp_read_sock(conn, GFP_KERNEL);
+	ret = rds_tcp_read_sock(cp, GFP_KERNEL);
 	release_sock(sock->sk);
 
 	return ret;
@@ -313,7 +316,7 @@ void rds_tcp_data_ready(struct sock *sk)
 	ready = tc->t_orig_data_ready;
 	rds_tcp_stats_inc(s_tcp_data_ready_calls);
 
-	if (rds_tcp_read_sock(cp->cp_conn, GFP_ATOMIC) == -ENOMEM)
+	if (rds_tcp_read_sock(cp, GFP_ATOMIC) == -ENOMEM)
 		queue_delayed_work(rds_wq, &cp->cp_recv_w, 0);
 out:
 	read_unlock_bh(&sk->sk_callback_lock);
diff --git a/net/rds/threads.c b/net/rds/threads.c
index 9fbe95b..f717b69 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -203,7 +203,7 @@ void rds_recv_worker(struct work_struct *work)
 	int ret;
 
 	if (rds_conn_path_state(cp) == RDS_CONN_UP) {
-		ret = cp->cp_conn->c_trans->recv(cp->cp_conn);
+		ret = cp->cp_conn->c_trans->recv_path(cp);
 		rdsdebug("conn %p ret %d\n", cp->cp_conn, ret);
 		switch (ret) {
 		case -EAGAIN:
-- 
1.7.1
