From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 08/17] RDS: Make rds_send_queue_rm() rds_conn_path aware
Date: Mon, 13 Jun 2016 09:44:33 -0700
Message-ID: <c54dc9e91ee2a26945dc87d9873edf081f305cf2.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40965 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161018AbcFMQpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:12 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass the rds_conn_path to rds_send_queue_rm, and use it to initialize
the i_conn_path field in struct rds_incoming. This commit also makes
rds_send_queue_rm() MP capable, because it now takes locks
specific to the rds_conn_path passed in, instead of defaulting to
the c_path[0] based defines from rds_single_path.h

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/send.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 3fb280b..076ee41 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -787,6 +787,7 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
  * message from the flow with RDS_CANCEL_SENT_TO.
  */
 static int rds_send_queue_rm(struct rds_sock *rs, struct rds_connection *conn,
+			     struct rds_conn_path *cp,
 			     struct rds_message *rm, __be16 sport,
 			     __be16 dport, int *queued)
 {
@@ -830,13 +831,14 @@ static int rds_send_queue_rm(struct rds_sock *rs, struct rds_connection *conn,
 		   trying to minimize the time we hold c_lock */
 		rds_message_populate_header(&rm->m_inc.i_hdr, sport, dport, 0);
 		rm->m_inc.i_conn = conn;
+		rm->m_inc.i_conn_path = cp;
 		rds_message_addref(rm);
 
-		spin_lock(&conn->c_lock);
-		rm->m_inc.i_hdr.h_sequence = cpu_to_be64(conn->c_next_tx_seq++);
-		list_add_tail(&rm->m_conn_item, &conn->c_send_queue);
+		spin_lock(&cp->cp_lock);
+		rm->m_inc.i_hdr.h_sequence = cpu_to_be64(cp->cp_next_tx_seq++);
+		list_add_tail(&rm->m_conn_item, &cp->cp_send_queue);
 		set_bit(RDS_MSG_ON_CONN, &rm->m_flags);
-		spin_unlock(&conn->c_lock);
+		spin_unlock(&cp->cp_lock);
 
 		rdsdebug("queued msg %p len %d, rs %p bytes %d seq %llu\n",
 			 rm, len, rs, rs->rs_snd_bytes,
@@ -968,6 +970,7 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 	int queued = 0, allocated_mr = 0;
 	int nonblock = msg->msg_flags & MSG_DONTWAIT;
 	long timeo = sock_sndtimeo(sk, nonblock);
+	struct rds_conn_path *cpath;
 
 	/* Mirror Linux UDP mirror of BSD error message compatibility */
 	/* XXX: Perhaps MSG_MORE someday */
@@ -1074,7 +1077,9 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 		goto out;
 	}
 
-	while (!rds_send_queue_rm(rs, conn, rm, rs->rs_bound_port,
+	cpath = &conn->c_path[0];
+
+	while (!rds_send_queue_rm(rs, conn, cpath, rm, rs->rs_bound_port,
 				  dport, &queued)) {
 		rds_stats_inc(s_send_queue_full);
 
@@ -1084,7 +1089,7 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
 		}
 
 		timeo = wait_event_interruptible_timeout(*sk_sleep(sk),
-					rds_send_queue_rm(rs, conn, rm,
+					rds_send_queue_rm(rs, conn, cpath, rm,
 							  rs->rs_bound_port,
 							  dport,
 							  &queued),
-- 
1.7.1
