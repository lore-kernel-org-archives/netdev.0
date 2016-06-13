From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 09/17] RDS: Pass rds_conn_path to rds_send_xmit()
Date: Mon, 13 Jun 2016 09:44:34 -0700
Message-ID: <2f819b07e136a4cdb3e82afffbf6b4cbc69de88f.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40946 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965095AbcFMQpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:10 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass a struct rds_conn_path to rds_send_xmit so that MP capable
transports can transmit packets on something other than c_path[0].
The eventual goal for MP capable transports is to hash the rds
socket to a path based on the bound local address/port, and use
this path as the argument to rds_send_xmit()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/ib_cm.c   |    2 +-
 net/rds/rds.h     |    4 +-
 net/rds/send.c    |  149 +++++++++++++++++++++++++++++------------------------
 net/rds/threads.c |    2 +-
 4 files changed, 87 insertions(+), 70 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 4de5a35..3342876 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -274,7 +274,7 @@ static void rds_ib_tasklet_fn_send(unsigned long data)
 	if (rds_conn_up(conn) &&
 	    (!test_bit(RDS_LL_SEND_FULL, &conn->c_flags) ||
 	    test_bit(0, &conn->c_map_queued)))
-		rds_send_xmit(ic->conn);
+		rds_send_xmit(&ic->conn->c_path[0]);
 }
 
 static void poll_rcq(struct rds_ib_connection *ic, struct ib_cq *cq,
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 2cffd37..b6072eb 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -457,7 +457,9 @@ struct rds_transport {
 	int (*conn_connect)(struct rds_connection *conn);
 	void (*conn_shutdown)(struct rds_connection *conn);
 	void (*xmit_prepare)(struct rds_connection *conn);
+	void (*xmit_path_prepare)(struct rds_conn_path *cp);
 	void (*xmit_complete)(struct rds_connection *conn);
+	void (*xmit_path_complete)(struct rds_conn_path *cp);
 	int (*xmit)(struct rds_connection *conn, struct rds_message *rm,
 		    unsigned int hdr_off, unsigned int sg, unsigned int off);
 	int (*xmit_rdma)(struct rds_connection *conn, struct rm_rdma_op *op);
@@ -780,7 +782,7 @@ void rds_inc_info_copy(struct rds_incoming *inc,
 /* send.c */
 int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len);
 void rds_send_reset(struct rds_connection *conn);
-int rds_send_xmit(struct rds_connection *conn);
+int rds_send_xmit(struct rds_conn_path *cp);
 struct sockaddr_in;
 void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest);
 typedef int (*is_acked_func)(struct rds_message *rm, uint64_t ack);
diff --git a/net/rds/send.c b/net/rds/send.c
index 076ee41..966311d 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -107,14 +107,14 @@ void rds_send_reset(struct rds_connection *conn)
 }
 EXPORT_SYMBOL_GPL(rds_send_reset);
 
-static int acquire_in_xmit(struct rds_connection *conn)
+static int acquire_in_xmit(struct rds_conn_path *cp)
 {
-	return test_and_set_bit(RDS_IN_XMIT, &conn->c_flags) == 0;
+	return test_and_set_bit(RDS_IN_XMIT, &cp->cp_flags) == 0;
 }
 
-static void release_in_xmit(struct rds_connection *conn)
+static void release_in_xmit(struct rds_conn_path *cp)
 {
-	clear_bit(RDS_IN_XMIT, &conn->c_flags);
+	clear_bit(RDS_IN_XMIT, &cp->cp_flags);
 	smp_mb__after_atomic();
 	/*
 	 * We don't use wait_on_bit()/wake_up_bit() because our waking is in a
@@ -122,8 +122,8 @@ static void release_in_xmit(struct rds_connection *conn)
 	 * the system-wide hashed waitqueue buckets in the fast path only to
 	 * almost never find waiters.
 	 */
-	if (waitqueue_active(&conn->c_waitq))
-		wake_up_all(&conn->c_waitq);
+	if (waitqueue_active(&cp->cp_waitq))
+		wake_up_all(&cp->cp_waitq);
 }
 
 /*
@@ -140,8 +140,9 @@ static void release_in_xmit(struct rds_connection *conn)
  *      - small message latency is higher behind queued large messages
  *      - large message latency isn't starved by intervening small sends
  */
-int rds_send_xmit(struct rds_connection *conn)
+int rds_send_xmit(struct rds_conn_path *cp)
 {
+	struct rds_connection *conn = cp->cp_conn;
 	struct rds_message *rm;
 	unsigned long flags;
 	unsigned int tmp;
@@ -161,7 +162,7 @@ int rds_send_xmit(struct rds_connection *conn)
 	 * avoids blocking the caller and trading per-connection data between
 	 * caches per message.
 	 */
-	if (!acquire_in_xmit(conn)) {
+	if (!acquire_in_xmit(cp)) {
 		rds_stats_inc(s_send_lock_contention);
 		ret = -ENOMEM;
 		goto out;
@@ -175,21 +176,25 @@ int rds_send_xmit(struct rds_connection *conn)
 	 * The acquire_in_xmit() check above ensures that only one
 	 * caller can increment c_send_gen at any time.
 	 */
-	conn->c_send_gen++;
-	send_gen = conn->c_send_gen;
+	cp->cp_send_gen++;
+	send_gen = cp->cp_send_gen;
 
 	/*
 	 * rds_conn_shutdown() sets the conn state and then tests RDS_IN_XMIT,
 	 * we do the opposite to avoid races.
 	 */
-	if (!rds_conn_up(conn)) {
-		release_in_xmit(conn);
+	if (!rds_conn_path_up(cp)) {
+		release_in_xmit(cp);
 		ret = 0;
 		goto out;
 	}
 
-	if (conn->c_trans->xmit_prepare)
+	if (conn->c_trans->t_mp_capable) {
+		if (conn->c_trans->xmit_path_prepare)
+			conn->c_trans->xmit_path_prepare(cp);
+	} else if (conn->c_trans->xmit_prepare) {
 		conn->c_trans->xmit_prepare(conn);
+	}
 
 	/*
 	 * spin trying to push headers and data down the connection until
@@ -197,7 +202,7 @@ int rds_send_xmit(struct rds_connection *conn)
 	 */
 	while (1) {
 
-		rm = conn->c_xmit_rm;
+		rm = cp->cp_xmit_rm;
 
 		/*
 		 * If between sending messages, we can send a pending congestion
@@ -210,14 +215,16 @@ int rds_send_xmit(struct rds_connection *conn)
 				break;
 			}
 			rm->data.op_active = 1;
+			rm->m_inc.i_conn_path = cp;
+			rm->m_inc.i_conn = cp->cp_conn;
 
-			conn->c_xmit_rm = rm;
+			cp->cp_xmit_rm = rm;
 		}
 
 		/*
 		 * If not already working on one, grab the next message.
 		 *
-		 * c_xmit_rm holds a ref while we're sending this message down
+		 * cp_xmit_rm holds a ref while we're sending this message down
 		 * the connction.  We can use this ref while holding the
 		 * send_sem.. rds_send_reset() is serialized with it.
 		 */
@@ -234,10 +241,10 @@ int rds_send_xmit(struct rds_connection *conn)
 			if (batch_count >= send_batch_count)
 				goto over_batch;
 
-			spin_lock_irqsave(&conn->c_lock, flags);
+			spin_lock_irqsave(&cp->cp_lock, flags);
 
-			if (!list_empty(&conn->c_send_queue)) {
-				rm = list_entry(conn->c_send_queue.next,
+			if (!list_empty(&cp->cp_send_queue)) {
+				rm = list_entry(cp->cp_send_queue.next,
 						struct rds_message,
 						m_conn_item);
 				rds_message_addref(rm);
@@ -246,10 +253,11 @@ int rds_send_xmit(struct rds_connection *conn)
 				 * Move the message from the send queue to the retransmit
 				 * list right away.
 				 */
-				list_move_tail(&rm->m_conn_item, &conn->c_retrans);
+				list_move_tail(&rm->m_conn_item,
+					       &cp->cp_retrans);
 			}
 
-			spin_unlock_irqrestore(&conn->c_lock, flags);
+			spin_unlock_irqrestore(&cp->cp_lock, flags);
 
 			if (!rm)
 				break;
@@ -263,32 +271,34 @@ int rds_send_xmit(struct rds_connection *conn)
 			 */
 			if (rm->rdma.op_active &&
 			    test_bit(RDS_MSG_RETRANSMITTED, &rm->m_flags)) {
-				spin_lock_irqsave(&conn->c_lock, flags);
+				spin_lock_irqsave(&cp->cp_lock, flags);
 				if (test_and_clear_bit(RDS_MSG_ON_CONN, &rm->m_flags))
 					list_move(&rm->m_conn_item, &to_be_dropped);
-				spin_unlock_irqrestore(&conn->c_lock, flags);
+				spin_unlock_irqrestore(&cp->cp_lock, flags);
 				continue;
 			}
 
 			/* Require an ACK every once in a while */
 			len = ntohl(rm->m_inc.i_hdr.h_len);
-			if (conn->c_unacked_packets == 0 ||
-			    conn->c_unacked_bytes < len) {
+			if (cp->cp_unacked_packets == 0 ||
+			    cp->cp_unacked_bytes < len) {
 				__set_bit(RDS_MSG_ACK_REQUIRED, &rm->m_flags);
 
-				conn->c_unacked_packets = rds_sysctl_max_unacked_packets;
-				conn->c_unacked_bytes = rds_sysctl_max_unacked_bytes;
+				cp->cp_unacked_packets =
+					rds_sysctl_max_unacked_packets;
+				cp->cp_unacked_bytes =
+					rds_sysctl_max_unacked_bytes;
 				rds_stats_inc(s_send_ack_required);
 			} else {
-				conn->c_unacked_bytes -= len;
-				conn->c_unacked_packets--;
+				cp->cp_unacked_bytes -= len;
+				cp->cp_unacked_packets--;
 			}
 
-			conn->c_xmit_rm = rm;
+			cp->cp_xmit_rm = rm;
 		}
 
 		/* The transport either sends the whole rdma or none of it */
-		if (rm->rdma.op_active && !conn->c_xmit_rdma_sent) {
+		if (rm->rdma.op_active && !cp->cp_xmit_rdma_sent) {
 			rm->m_final_op = &rm->rdma;
 			/* The transport owns the mapped memory for now.
 			 * You can't unmap it while it's on the send queue
@@ -300,11 +310,11 @@ int rds_send_xmit(struct rds_connection *conn)
 				wake_up_interruptible(&rm->m_flush_wait);
 				break;
 			}
-			conn->c_xmit_rdma_sent = 1;
+			cp->cp_xmit_rdma_sent = 1;
 
 		}
 
-		if (rm->atomic.op_active && !conn->c_xmit_atomic_sent) {
+		if (rm->atomic.op_active && !cp->cp_xmit_atomic_sent) {
 			rm->m_final_op = &rm->atomic;
 			/* The transport owns the mapped memory for now.
 			 * You can't unmap it while it's on the send queue
@@ -316,7 +326,7 @@ int rds_send_xmit(struct rds_connection *conn)
 				wake_up_interruptible(&rm->m_flush_wait);
 				break;
 			}
-			conn->c_xmit_atomic_sent = 1;
+			cp->cp_xmit_atomic_sent = 1;
 
 		}
 
@@ -342,41 +352,42 @@ int rds_send_xmit(struct rds_connection *conn)
 				rm->data.op_active = 0;
 		}
 
-		if (rm->data.op_active && !conn->c_xmit_data_sent) {
+		if (rm->data.op_active && !cp->cp_xmit_data_sent) {
 			rm->m_final_op = &rm->data;
+
 			ret = conn->c_trans->xmit(conn, rm,
-						  conn->c_xmit_hdr_off,
-						  conn->c_xmit_sg,
-						  conn->c_xmit_data_off);
+						  cp->cp_xmit_hdr_off,
+						  cp->cp_xmit_sg,
+						  cp->cp_xmit_data_off);
 			if (ret <= 0)
 				break;
 
-			if (conn->c_xmit_hdr_off < sizeof(struct rds_header)) {
+			if (cp->cp_xmit_hdr_off < sizeof(struct rds_header)) {
 				tmp = min_t(int, ret,
 					    sizeof(struct rds_header) -
-					    conn->c_xmit_hdr_off);
-				conn->c_xmit_hdr_off += tmp;
+					    cp->cp_xmit_hdr_off);
+				cp->cp_xmit_hdr_off += tmp;
 				ret -= tmp;
 			}
 
-			sg = &rm->data.op_sg[conn->c_xmit_sg];
+			sg = &rm->data.op_sg[cp->cp_xmit_sg];
 			while (ret) {
 				tmp = min_t(int, ret, sg->length -
-						      conn->c_xmit_data_off);
-				conn->c_xmit_data_off += tmp;
+						      cp->cp_xmit_data_off);
+				cp->cp_xmit_data_off += tmp;
 				ret -= tmp;
-				if (conn->c_xmit_data_off == sg->length) {
-					conn->c_xmit_data_off = 0;
+				if (cp->cp_xmit_data_off == sg->length) {
+					cp->cp_xmit_data_off = 0;
 					sg++;
-					conn->c_xmit_sg++;
-					BUG_ON(ret != 0 &&
-					       conn->c_xmit_sg == rm->data.op_nents);
+					cp->cp_xmit_sg++;
+					BUG_ON(ret != 0 && cp->cp_xmit_sg ==
+					       rm->data.op_nents);
 				}
 			}
 
-			if (conn->c_xmit_hdr_off == sizeof(struct rds_header) &&
-			    (conn->c_xmit_sg == rm->data.op_nents))
-				conn->c_xmit_data_sent = 1;
+			if (cp->cp_xmit_hdr_off == sizeof(struct rds_header) &&
+			    (cp->cp_xmit_sg == rm->data.op_nents))
+				cp->cp_xmit_data_sent = 1;
 		}
 
 		/*
@@ -384,23 +395,27 @@ int rds_send_xmit(struct rds_connection *conn)
 		 * if there is a data op. Thus, if the data is sent (or there was
 		 * none), then we're done with the rm.
 		 */
-		if (!rm->data.op_active || conn->c_xmit_data_sent) {
-			conn->c_xmit_rm = NULL;
-			conn->c_xmit_sg = 0;
-			conn->c_xmit_hdr_off = 0;
-			conn->c_xmit_data_off = 0;
-			conn->c_xmit_rdma_sent = 0;
-			conn->c_xmit_atomic_sent = 0;
-			conn->c_xmit_data_sent = 0;
+		if (!rm->data.op_active || cp->cp_xmit_data_sent) {
+			cp->cp_xmit_rm = NULL;
+			cp->cp_xmit_sg = 0;
+			cp->cp_xmit_hdr_off = 0;
+			cp->cp_xmit_data_off = 0;
+			cp->cp_xmit_rdma_sent = 0;
+			cp->cp_xmit_atomic_sent = 0;
+			cp->cp_xmit_data_sent = 0;
 
 			rds_message_put(rm);
 		}
 	}
 
 over_batch:
-	if (conn->c_trans->xmit_complete)
+	if (conn->c_trans->t_mp_capable) {
+		if (conn->c_trans->xmit_path_complete)
+			conn->c_trans->xmit_path_complete(cp);
+	} else if (conn->c_trans->xmit_complete) {
 		conn->c_trans->xmit_complete(conn);
-	release_in_xmit(conn);
+	}
+	release_in_xmit(cp);
 
 	/* Nuke any messages we decided not to retransmit. */
 	if (!list_empty(&to_be_dropped)) {
@@ -428,12 +443,12 @@ int rds_send_xmit(struct rds_connection *conn)
 	if (ret == 0) {
 		smp_mb();
 		if ((test_bit(0, &conn->c_map_queued) ||
-		     !list_empty(&conn->c_send_queue)) &&
-		    send_gen == conn->c_send_gen) {
+		     !list_empty(&cp->cp_send_queue)) &&
+		    send_gen == cp->cp_send_gen) {
 			rds_stats_inc(s_send_lock_queue_raced);
 			if (batch_count < send_batch_count)
 				goto restart;
-			queue_delayed_work(rds_wq, &conn->c_send_w, 1);
+			queue_delayed_work(rds_wq, &cp->cp_send_w, 1);
 		}
 	}
 out:
@@ -1110,9 +1125,9 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	 */
 	rds_stats_inc(s_send_queued);
 
-	ret = rds_send_xmit(conn);
+	ret = rds_send_xmit(cpath);
 	if (ret == -ENOMEM || ret == -EAGAIN)
-		queue_delayed_work(rds_wq, &conn->c_send_w, 1);
+		queue_delayed_work(rds_wq, &cpath->cp_send_w, 1);
 
 	rds_message_put(rm);
 	return payload_len;
diff --git a/net/rds/threads.c b/net/rds/threads.c
index 6d0979b..50d2657 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -177,7 +177,7 @@ void rds_send_worker(struct work_struct *work)
 
 	if (rds_conn_path_state(cp) == RDS_CONN_UP) {
 		clear_bit(RDS_LL_SEND_FULL, &cp->cp_flags);
-		ret = rds_send_xmit(cp->cp_conn);
+		ret = rds_send_xmit(cp);
 		cond_resched();
 		rdsdebug("conn %p ret %d\n", cp->cp_conn, ret);
 		switch (ret) {
-- 
1.7.1
