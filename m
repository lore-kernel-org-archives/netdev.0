From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 01/17] RDS: split out connection specific state from rds_connection to rds_conn_path
Date: Mon, 13 Jun 2016 09:44:26 -0700
Message-ID: <eee0feb82ad25a7472b4f7f32d5fb8526f0f75e4.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25874 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964994AbcFMQpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:09 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for multipath RDS, split the rds_connection
structure into a base structure, and a per-path struct rds_conn_path.
The base structure tracks information and locks common to all
paths. The workqs for send/recv/shutdown etc are tracked per
rds_conn_path. Thus the workq callbacks now work with rds_conn_path.

This commit allows for one rds_conn_path per rds_connection, and will
be extended into multiple conn_paths in  subsequent commits.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/cong.c            |    3 +-
 net/rds/connection.c      |   18 +++++--
 net/rds/ib.c              |    1 +
 net/rds/ib_cm.c           |    1 +
 net/rds/ib_rdma.c         |    1 +
 net/rds/ib_recv.c         |    1 +
 net/rds/ib_send.c         |    1 +
 net/rds/loop.c            |    1 +
 net/rds/rdma_transport.c  |    1 +
 net/rds/rds.h             |  122 +++++++++++++++++++++++++++++---------------
 net/rds/rds_single_path.h |   30 +++++++++++
 net/rds/recv.c            |    1 +
 net/rds/send.c            |    1 +
 net/rds/tcp.c             |    1 +
 net/rds/tcp_connect.c     |    4 +-
 net/rds/tcp_listen.c      |   11 +++--
 net/rds/tcp_recv.c        |    1 +
 net/rds/tcp_send.c        |    1 +
 net/rds/threads.c         |   92 +++++++++++++++++++---------------
 19 files changed, 199 insertions(+), 93 deletions(-)
 create mode 100644 net/rds/rds_single_path.h

diff --git a/net/rds/cong.c b/net/rds/cong.c
index 6641bcf..8398fee 100644
--- a/net/rds/cong.c
+++ b/net/rds/cong.c
@@ -235,7 +235,8 @@ void rds_cong_queue_updates(struct rds_cong_map *map)
 			 *    therefore trigger warnings.
 			 * Defer the xmit to rds_send_worker() instead.
 			 */
-			queue_delayed_work(rds_wq, &conn->c_send_w, 0);
+			queue_delayed_work(rds_wq,
+					   &conn->c_path[0].cp_send_w, 0);
 		}
 	}
 
diff --git a/net/rds/connection.c b/net/rds/connection.c
index e3b118c..6fa2074 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -36,6 +36,7 @@
 #include <linux/export.h>
 #include <net/inet_hashtables.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "loop.h"
 
@@ -155,6 +156,7 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 	conn->c_faddr = faddr;
 	spin_lock_init(&conn->c_lock);
 	conn->c_next_tx_seq = 1;
+	conn->c_path[0].cp_conn = conn;
 	rds_conn_net_set(conn, net);
 
 	init_waitqueue_head(&conn->c_waitq);
@@ -197,7 +199,7 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 
 	atomic_set(&conn->c_state, RDS_CONN_DOWN);
 	conn->c_send_gen = 0;
-	conn->c_outgoing = (is_outgoing ? 1 : 0);
+	conn->c_path[0].cp_outgoing = (is_outgoing ? 1 : 0);
 	conn->c_reconnect_jiffies = 0;
 	INIT_DELAYED_WORK(&conn->c_send_w, rds_send_worker);
 	INIT_DELAYED_WORK(&conn->c_recv_w, rds_recv_worker);
@@ -320,8 +322,8 @@ void rds_conn_shutdown(struct rds_connection *conn)
 	if (!hlist_unhashed(&conn->c_hash_node)) {
 		rcu_read_unlock();
 		if (conn->c_trans->t_type != RDS_TRANS_TCP ||
-		    conn->c_outgoing == 1)
-			rds_queue_reconnect(conn);
+		    conn->c_path[0].cp_outgoing == 1)
+			rds_queue_reconnect(&conn->c_path[0]);
 	} else {
 		rcu_read_unlock();
 	}
@@ -553,10 +555,16 @@ void rds_conn_exit(void)
 /*
  * Force a disconnect
  */
+void rds_conn_path_drop(struct rds_conn_path *cp)
+{
+	atomic_set(&cp->cp_state, RDS_CONN_ERROR);
+	queue_work(rds_wq, &cp->cp_down_w);
+}
+EXPORT_SYMBOL_GPL(rds_conn_path_drop);
+
 void rds_conn_drop(struct rds_connection *conn)
 {
-	atomic_set(&conn->c_state, RDS_CONN_ERROR);
-	queue_work(rds_wq, &conn->c_down_w);
+	rds_conn_path_drop(&conn->c_path[0]);
 }
 EXPORT_SYMBOL_GPL(rds_conn_drop);
 
diff --git a/net/rds/ib.c b/net/rds/ib.c
index b5342fd..44946a6 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -40,6 +40,7 @@
 #include <linux/slab.h>
 #include <linux/module.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "ib.h"
 #include "ib_mr.h"
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 310cabc..4de5a35 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -36,6 +36,7 @@
 #include <linux/vmalloc.h>
 #include <linux/ratelimit.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "ib.h"
 
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index a0f21b6..977f698 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -35,6 +35,7 @@
 #include <linux/rculist.h>
 #include <linux/llist.h>
 
+#include "rds_single_path.h"
 #include "ib_mr.h"
 
 struct workqueue_struct *rds_ib_mr_wq;
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index abc8cc8..4ea8cb1 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -36,6 +36,7 @@
 #include <linux/dma-mapping.h>
 #include <rdma/rdma_cm.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "ib.h"
 
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index f27d2c8..6e4110a 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -36,6 +36,7 @@
 #include <linux/dmapool.h>
 #include <linux/ratelimit.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "ib.h"
 
diff --git a/net/rds/loop.c b/net/rds/loop.c
index 6b12b68..268f07f 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -34,6 +34,7 @@
 #include <linux/slab.h>
 #include <linux/in.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "loop.h"
 
diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 7220beb..345f090 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -33,6 +33,7 @@
 #include <linux/module.h>
 #include <rdma/rdma_cm.h>
 
+#include "rds_single_path.h"
 #include "rdma_transport.h"
 #include "ib.h"
 
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 387df5f..ca31a07 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -84,56 +84,69 @@ enum {
 #define RDS_IN_XMIT		2
 #define RDS_RECV_REFILL		3
 
+/* Max number of multipaths per RDS connection. Must be a power of 2 */
+#define	RDS_MPATH_WORKERS	1
+
+/* Per mpath connection state */
+struct rds_conn_path {
+	struct rds_connection	*cp_conn;
+	struct rds_message	*cp_xmit_rm;
+	unsigned long		cp_xmit_sg;
+	unsigned int		cp_xmit_hdr_off;
+	unsigned int		cp_xmit_data_off;
+	unsigned int		cp_xmit_atomic_sent;
+	unsigned int		cp_xmit_rdma_sent;
+	unsigned int		cp_xmit_data_sent;
+
+	spinlock_t		cp_lock;		/* protect msg queues */
+	u64			cp_next_tx_seq;
+	struct list_head	cp_send_queue;
+	struct list_head	cp_retrans;
+
+	u64			cp_next_rx_seq;
+
+	void			*cp_transport_data;
+
+	atomic_t		cp_state;
+	unsigned long		cp_send_gen;
+	unsigned long		cp_flags;
+	unsigned long		cp_reconnect_jiffies;
+	struct delayed_work	cp_send_w;
+	struct delayed_work	cp_recv_w;
+	struct delayed_work	cp_conn_w;
+	struct work_struct	cp_down_w;
+	struct mutex		cp_cm_lock;	/* protect cp_state & cm */
+	wait_queue_head_t	cp_waitq;
+
+	unsigned int		cp_unacked_packets;
+	unsigned int		cp_unacked_bytes;
+	unsigned int		cp_outgoing:1,
+				cp_pad_to_32:31;
+	unsigned int		cp_index;
+};
+
+/* One rds_connection per RDS address pair */
 struct rds_connection {
 	struct hlist_node	c_hash_node;
 	__be32			c_laddr;
 	__be32			c_faddr;
 	unsigned int		c_loopback:1,
-				c_outgoing:1,
-				c_pad_to_32:30;
+				c_pad_to_32:31;
+	int			c_npaths;
 	struct rds_connection	*c_passive;
+	struct rds_transport	*c_trans;
 
 	struct rds_cong_map	*c_lcong;
 	struct rds_cong_map	*c_fcong;
 
-	struct rds_message	*c_xmit_rm;
-	unsigned long		c_xmit_sg;
-	unsigned int		c_xmit_hdr_off;
-	unsigned int		c_xmit_data_off;
-	unsigned int		c_xmit_atomic_sent;
-	unsigned int		c_xmit_rdma_sent;
-	unsigned int		c_xmit_data_sent;
-
-	spinlock_t		c_lock;		/* protect msg queues */
-	u64			c_next_tx_seq;
-	struct list_head	c_send_queue;
-	struct list_head	c_retrans;
-
-	u64			c_next_rx_seq;
-
-	struct rds_transport	*c_trans;
-	void			*c_transport_data;
-
-	atomic_t		c_state;
-	unsigned long		c_send_gen;
-	unsigned long		c_flags;
-	unsigned long		c_reconnect_jiffies;
-	struct delayed_work	c_send_w;
-	struct delayed_work	c_recv_w;
-	struct delayed_work	c_conn_w;
-	struct work_struct	c_down_w;
-	struct mutex		c_cm_lock;	/* protect conn state & cm */
-	wait_queue_head_t	c_waitq;
+	/* Protocol version */
+	unsigned int		c_version;
+	possible_net_t		c_net;
 
 	struct list_head	c_map_item;
 	unsigned long		c_map_queued;
 
-	unsigned int		c_unacked_packets;
-	unsigned int		c_unacked_bytes;
-
-	/* Protocol version */
-	unsigned int		c_version;
-	possible_net_t		c_net;
+	struct rds_conn_path	c_path[RDS_MPATH_WORKERS];
 };
 
 static inline
@@ -639,6 +652,7 @@ struct rds_connection *rds_conn_create_outgoing(struct net *net,
 void rds_conn_shutdown(struct rds_connection *conn);
 void rds_conn_destroy(struct rds_connection *conn);
 void rds_conn_drop(struct rds_connection *conn);
+void rds_conn_path_drop(struct rds_conn_path *cpath);
 void rds_conn_connect_if_down(struct rds_connection *conn);
 void rds_for_each_conn_info(struct socket *sock, unsigned int len,
 			  struct rds_info_iterator *iter,
@@ -651,27 +665,51 @@ void __rds_conn_error(struct rds_connection *conn, const char *, ...);
 	__rds_conn_error(conn, KERN_WARNING "RDS: " fmt)
 
 static inline int
+rds_conn_path_transition(struct rds_conn_path *cp, int old, int new)
+{
+	return atomic_cmpxchg(&cp->cp_state, old, new) == old;
+}
+
+static inline int
 rds_conn_transition(struct rds_connection *conn, int old, int new)
 {
-	return atomic_cmpxchg(&conn->c_state, old, new) == old;
+	return rds_conn_path_transition(&conn->c_path[0], old, new);
+}
+
+static inline int
+rds_conn_path_state(struct rds_conn_path *cp)
+{
+	return atomic_read(&cp->cp_state);
 }
 
 static inline int
 rds_conn_state(struct rds_connection *conn)
 {
-	return atomic_read(&conn->c_state);
+	return rds_conn_path_state(&conn->c_path[0]);
+}
+
+static inline int
+rds_conn_path_up(struct rds_conn_path *cp)
+{
+	return atomic_read(&cp->cp_state) == RDS_CONN_UP;
 }
 
 static inline int
 rds_conn_up(struct rds_connection *conn)
 {
-	return atomic_read(&conn->c_state) == RDS_CONN_UP;
+	return rds_conn_path_up(&conn->c_path[0]);
+}
+
+static inline int
+rds_conn_path_connecting(struct rds_conn_path *cp)
+{
+	return atomic_read(&cp->cp_state) == RDS_CONN_CONNECTING;
 }
 
 static inline int
 rds_conn_connecting(struct rds_connection *conn)
 {
-	return atomic_read(&conn->c_state) == RDS_CONN_CONNECTING;
+	return rds_conn_path_connecting(&conn->c_path[0]);
 }
 
 /* message.c */
@@ -809,12 +847,12 @@ extern unsigned int  rds_sysctl_trace_level;
 int rds_threads_init(void);
 void rds_threads_exit(void);
 extern struct workqueue_struct *rds_wq;
-void rds_queue_reconnect(struct rds_connection *conn);
+void rds_queue_reconnect(struct rds_conn_path *cp);
 void rds_connect_worker(struct work_struct *);
 void rds_shutdown_worker(struct work_struct *);
 void rds_send_worker(struct work_struct *);
 void rds_recv_worker(struct work_struct *);
-void rds_connect_path_complete(struct rds_connection *conn, int curr);
+void rds_connect_path_complete(struct rds_conn_path *conn, int curr);
 void rds_connect_complete(struct rds_connection *conn);
 
 /* transport.c */
diff --git a/net/rds/rds_single_path.h b/net/rds/rds_single_path.h
new file mode 100644
index 0000000..e1241af
--- /dev/null
+++ b/net/rds/rds_single_path.h
@@ -0,0 +1,30 @@
+#ifndef _RDS_RDS_SINGLE_H
+#define _RDS_RDS_SINGLE_H
+
+#define	c_xmit_rm		c_path[0].cp_xmit_rm
+#define	c_xmit_sg		c_path[0].cp_xmit_sg
+#define	c_xmit_hdr_off		c_path[0].cp_xmit_hdr_off
+#define	c_xmit_data_off		c_path[0].cp_xmit_data_off
+#define	c_xmit_atomic_sent	c_path[0].cp_xmit_atomic_sent
+#define	c_xmit_rdma_sent	c_path[0].cp_xmit_rdma_sent
+#define	c_xmit_data_sent	c_path[0].cp_xmit_data_sent
+#define	c_lock			c_path[0].cp_lock
+#define c_next_tx_seq		c_path[0].cp_next_tx_seq
+#define c_send_queue		c_path[0].cp_send_queue
+#define c_retrans		c_path[0].cp_retrans
+#define c_next_rx_seq		c_path[0].cp_next_rx_seq
+#define c_transport_data	c_path[0].cp_transport_data
+#define c_state			c_path[0].cp_state
+#define c_send_gen		c_path[0].cp_send_gen
+#define c_flags			c_path[0].cp_flags
+#define c_reconnect_jiffies	c_path[0].cp_reconnect_jiffies
+#define c_send_w		c_path[0].cp_send_w
+#define c_recv_w		c_path[0].cp_recv_w
+#define c_conn_w		c_path[0].cp_conn_w
+#define c_down_w		c_path[0].cp_down_w
+#define c_cm_lock		c_path[0].cp_cm_lock
+#define c_waitq			c_path[0].cp_waitq
+#define c_unacked_packets	c_path[0].cp_unacked_packets
+#define c_unacked_bytes		c_path[0].cp_unacked_bytes
+
+#endif /* _RDS_RDS_SINGLE_H */
diff --git a/net/rds/recv.c b/net/rds/recv.c
index 8413f6c..78b5c43 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -38,6 +38,7 @@
 #include <linux/time.h>
 #include <linux/rds.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 
 void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
diff --git a/net/rds/send.c b/net/rds/send.c
index b1962f8..a3b3b35 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -40,6 +40,7 @@
 #include <linux/export.h>
 #include <linux/sizes.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 
 /* When transmitting messages in rds_send_xmit, we need to emerge from
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 74ee126..4bc1c15 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -38,6 +38,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "tcp.h"
 
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index fba13d0..ba9ec67 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -34,6 +34,7 @@
 #include <linux/in.h>
 #include <net/tcp.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "tcp.h"
 
@@ -60,7 +61,8 @@ void rds_tcp_state_change(struct sock *sk)
 		case TCP_SYN_RECV:
 			break;
 		case TCP_ESTABLISHED:
-			rds_connect_path_complete(conn, RDS_CONN_CONNECTING);
+			rds_connect_path_complete(&conn->c_path[0],
+						  RDS_CONN_CONNECTING);
 			break;
 		case TCP_CLOSE_WAIT:
 		case TCP_CLOSE:
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 686b1d0..22d9bb1 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -35,6 +35,7 @@
 #include <linux/in.h>
 #include <net/tcp.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "tcp.h"
 
@@ -132,17 +133,19 @@ int rds_tcp_accept_one(struct socket *sock)
 		 * c_transport_data.
 		 */
 		if (ntohl(inet->inet_saddr) < ntohl(inet->inet_daddr) ||
-		    !conn->c_outgoing) {
+		    !conn->c_path[0].cp_outgoing) {
 			goto rst_nsk;
 		} else {
 			rds_tcp_reset_callbacks(new_sock, conn);
-			conn->c_outgoing = 0;
+			conn->c_path[0].cp_outgoing = 0;
 			/* rds_connect_path_complete() marks RDS_CONN_UP */
-			rds_connect_path_complete(conn, RDS_CONN_DISCONNECTING);
+			rds_connect_path_complete(&conn->c_path[0],
+						  RDS_CONN_DISCONNECTING);
 		}
 	} else {
 		rds_tcp_set_callbacks(new_sock, conn);
-		rds_connect_path_complete(conn, RDS_CONN_CONNECTING);
+		rds_connect_path_complete(&conn->c_path[0],
+					  RDS_CONN_CONNECTING);
 	}
 	new_sock = NULL;
 	ret = 0;
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index c3196f9..3f8fb38 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -34,6 +34,7 @@
 #include <linux/slab.h>
 #include <net/tcp.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "tcp.h"
 
diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
index 22d0f20..2b3414f 100644
--- a/net/rds/tcp_send.c
+++ b/net/rds/tcp_send.c
@@ -34,6 +34,7 @@
 #include <linux/in.h>
 #include <net/tcp.h>
 
+#include "rds_single_path.h"
 #include "rds.h"
 #include "tcp.h"
 
diff --git a/net/rds/threads.c b/net/rds/threads.c
index 4a32304..6d0979b 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -71,30 +71,30 @@
 struct workqueue_struct *rds_wq;
 EXPORT_SYMBOL_GPL(rds_wq);
 
-void rds_connect_path_complete(struct rds_connection *conn, int curr)
+void rds_connect_path_complete(struct rds_conn_path *cp, int curr)
 {
-	if (!rds_conn_transition(conn, curr, RDS_CONN_UP)) {
+	if (!rds_conn_path_transition(cp, curr, RDS_CONN_UP)) {
 		printk(KERN_WARNING "%s: Cannot transition to state UP, "
 				"current state is %d\n",
 				__func__,
-				atomic_read(&conn->c_state));
-		rds_conn_drop(conn);
+				atomic_read(&cp->cp_state));
+		rds_conn_path_drop(cp);
 		return;
 	}
 
 	rdsdebug("conn %p for %pI4 to %pI4 complete\n",
-	  conn, &conn->c_laddr, &conn->c_faddr);
+	  cp->cp_conn, &cp->cp_conn->c_laddr, &cp->cp_conn->c_faddr);
 
-	conn->c_reconnect_jiffies = 0;
-	set_bit(0, &conn->c_map_queued);
-	queue_delayed_work(rds_wq, &conn->c_send_w, 0);
-	queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
+	cp->cp_reconnect_jiffies = 0;
+	set_bit(0, &cp->cp_conn->c_map_queued);
+	queue_delayed_work(rds_wq, &cp->cp_send_w, 0);
+	queue_delayed_work(rds_wq, &cp->cp_recv_w, 0);
 }
 EXPORT_SYMBOL_GPL(rds_connect_path_complete);
 
 void rds_connect_complete(struct rds_connection *conn)
 {
-	rds_connect_path_complete(conn, RDS_CONN_CONNECTING);
+	rds_connect_path_complete(&conn->c_path[0], RDS_CONN_CONNECTING);
 }
 EXPORT_SYMBOL_GPL(rds_connect_complete);
 
@@ -116,46 +116,52 @@ EXPORT_SYMBOL_GPL(rds_connect_complete);
  * We should *always* start with a random backoff; otherwise a broken connection
  * will always take several iterations to be re-established.
  */
-void rds_queue_reconnect(struct rds_connection *conn)
+void rds_queue_reconnect(struct rds_conn_path *cp)
 {
 	unsigned long rand;
+	struct rds_connection *conn = cp->cp_conn;
 
 	rdsdebug("conn %p for %pI4 to %pI4 reconnect jiffies %lu\n",
 	  conn, &conn->c_laddr, &conn->c_faddr,
-	  conn->c_reconnect_jiffies);
+	  cp->cp_reconnect_jiffies);
 
-	set_bit(RDS_RECONNECT_PENDING, &conn->c_flags);
-	if (conn->c_reconnect_jiffies == 0) {
-		conn->c_reconnect_jiffies = rds_sysctl_reconnect_min_jiffies;
-		queue_delayed_work(rds_wq, &conn->c_conn_w, 0);
+	set_bit(RDS_RECONNECT_PENDING, &cp->cp_flags);
+	if (cp->cp_reconnect_jiffies == 0) {
+		cp->cp_reconnect_jiffies = rds_sysctl_reconnect_min_jiffies;
+		queue_delayed_work(rds_wq, &cp->cp_conn_w, 0);
 		return;
 	}
 
 	get_random_bytes(&rand, sizeof(rand));
 	rdsdebug("%lu delay %lu ceil conn %p for %pI4 -> %pI4\n",
-		 rand % conn->c_reconnect_jiffies, conn->c_reconnect_jiffies,
+		 rand % cp->cp_reconnect_jiffies, cp->cp_reconnect_jiffies,
 		 conn, &conn->c_laddr, &conn->c_faddr);
-	queue_delayed_work(rds_wq, &conn->c_conn_w,
-			   rand % conn->c_reconnect_jiffies);
+	queue_delayed_work(rds_wq, &cp->cp_conn_w,
+			   rand % cp->cp_reconnect_jiffies);
 
-	conn->c_reconnect_jiffies = min(conn->c_reconnect_jiffies * 2,
+	cp->cp_reconnect_jiffies = min(cp->cp_reconnect_jiffies * 2,
 					rds_sysctl_reconnect_max_jiffies);
 }
 
 void rds_connect_worker(struct work_struct *work)
 {
-	struct rds_connection *conn = container_of(work, struct rds_connection, c_conn_w.work);
+	struct rds_conn_path *cp = container_of(work,
+						struct rds_conn_path,
+						cp_conn_w.work);
+	struct rds_connection *conn = cp->cp_conn;
 	int ret;
 
-	clear_bit(RDS_RECONNECT_PENDING, &conn->c_flags);
-	if (rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING)) {
+	clear_bit(RDS_RECONNECT_PENDING, &cp->cp_flags);
+	if (rds_conn_path_transition(cp, RDS_CONN_DOWN, RDS_CONN_CONNECTING)) {
 		ret = conn->c_trans->conn_connect(conn);
 		rdsdebug("conn %p for %pI4 to %pI4 dispatched, ret %d\n",
 			conn, &conn->c_laddr, &conn->c_faddr, ret);
 
 		if (ret) {
-			if (rds_conn_transition(conn, RDS_CONN_CONNECTING, RDS_CONN_DOWN))
-				rds_queue_reconnect(conn);
+			if (rds_conn_path_transition(cp,
+						     RDS_CONN_CONNECTING,
+						     RDS_CONN_DOWN))
+				rds_queue_reconnect(cp);
 			else
 				rds_conn_error(conn, "RDS: connect failed\n");
 		}
@@ -164,22 +170,24 @@ void rds_connect_worker(struct work_struct *work)
 
 void rds_send_worker(struct work_struct *work)
 {
-	struct rds_connection *conn = container_of(work, struct rds_connection, c_send_w.work);
+	struct rds_conn_path *cp = container_of(work,
+						struct rds_conn_path,
+						cp_send_w.work);
 	int ret;
 
-	if (rds_conn_state(conn) == RDS_CONN_UP) {
-		clear_bit(RDS_LL_SEND_FULL, &conn->c_flags);
-		ret = rds_send_xmit(conn);
+	if (rds_conn_path_state(cp) == RDS_CONN_UP) {
+		clear_bit(RDS_LL_SEND_FULL, &cp->cp_flags);
+		ret = rds_send_xmit(cp->cp_conn);
 		cond_resched();
-		rdsdebug("conn %p ret %d\n", conn, ret);
+		rdsdebug("conn %p ret %d\n", cp->cp_conn, ret);
 		switch (ret) {
 		case -EAGAIN:
 			rds_stats_inc(s_send_immediate_retry);
-			queue_delayed_work(rds_wq, &conn->c_send_w, 0);
+			queue_delayed_work(rds_wq, &cp->cp_send_w, 0);
 			break;
 		case -ENOMEM:
 			rds_stats_inc(s_send_delayed_retry);
-			queue_delayed_work(rds_wq, &conn->c_send_w, 2);
+			queue_delayed_work(rds_wq, &cp->cp_send_w, 2);
 		default:
 			break;
 		}
@@ -188,20 +196,22 @@ void rds_send_worker(struct work_struct *work)
 
 void rds_recv_worker(struct work_struct *work)
 {
-	struct rds_connection *conn = container_of(work, struct rds_connection, c_recv_w.work);
+	struct rds_conn_path *cp = container_of(work,
+						struct rds_conn_path,
+						cp_recv_w.work);
 	int ret;
 
-	if (rds_conn_state(conn) == RDS_CONN_UP) {
-		ret = conn->c_trans->recv(conn);
-		rdsdebug("conn %p ret %d\n", conn, ret);
+	if (rds_conn_path_state(cp) == RDS_CONN_UP) {
+		ret = cp->cp_conn->c_trans->recv(cp->cp_conn);
+		rdsdebug("conn %p ret %d\n", cp->cp_conn, ret);
 		switch (ret) {
 		case -EAGAIN:
 			rds_stats_inc(s_recv_immediate_retry);
-			queue_delayed_work(rds_wq, &conn->c_recv_w, 0);
+			queue_delayed_work(rds_wq, &cp->cp_recv_w, 0);
 			break;
 		case -ENOMEM:
 			rds_stats_inc(s_recv_delayed_retry);
-			queue_delayed_work(rds_wq, &conn->c_recv_w, 2);
+			queue_delayed_work(rds_wq, &cp->cp_recv_w, 2);
 		default:
 			break;
 		}
@@ -210,9 +220,11 @@ void rds_recv_worker(struct work_struct *work)
 
 void rds_shutdown_worker(struct work_struct *work)
 {
-	struct rds_connection *conn = container_of(work, struct rds_connection, c_down_w);
+	struct rds_conn_path *cp = container_of(work,
+						struct rds_conn_path,
+						cp_down_w);
 
-	rds_conn_shutdown(conn);
+	rds_conn_shutdown(cp->cp_conn);
 }
 
 void rds_threads_exit(void)
-- 
1.7.1
