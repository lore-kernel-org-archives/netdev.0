From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 3/3] RDS: TCP: Force every connection to be initiated by numerically smaller IP address
Date: Wed, 16 Nov 2016 13:29:50 -0800
Message-ID: <ffffabdfe8df7b9940f50264175b8edc22085dd5.1478876910.git.sowmini.varadhan@oracle.com>
References: <cover.1478876910.git.sowmini.varadhan@oracle.com>
Cc: santosh.shilimkar@oracle.com, sowmini.varadhan@oracle.com,
        davem@davemloft.net, rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25953 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932785AbcKPVaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 16:30:01 -0500
In-Reply-To: <cover.1478876910.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1478876910.git.sowmini.varadhan@oracle.com>
References: <cover.1478876910.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When 2 RDS peers initiate an RDS-TCP connection simultaneously,
there is a potential for "duelling syns" on either/both sides.
See commit 241b271952eb ("RDS-TCP: Reset tcp callbacks if re-using an
outgoing socket in rds_tcp_accept_one()") for a description of this
condition, and the arbitration logic which ensures that the
numerically large IP address in the TCP connection is bound to the
RDS_TCP_PORT ("canonical ordering").

The rds_connection should not be marked as RDS_CONN_UP until the
arbitration logic has converged for the following reason. The sender
may start transmitting RDS datagrams as soon as RDS_CONN_UP is set,
and since the sender removes all datagrams from the rds_connection's
cp_retrans queue based on TCP acks. If the TCP ack was sent from
a tcp socket that got reset as part of duel aribitration (but
before data was delivered to the receivers RDS socket layer),
the sender may end up prematurely freeing the datagram, and
the datagram is no longer reliably deliverable.

This patch remedies that condition by making sure that, upon
receipt of 3WH completion state change notification of TCP_ESTABLISHED
in rds_tcp_state_change, we mark the rds_connection as RDS_CONN_UP
if, and only if, the IP addresses and ports for the connection are
canonically ordered. In all other cases, rds_tcp_state_change will
force an rds_conn_path_drop(), and rds_queue_reconnect() on
both peers will restart the connection to ensure canonical ordering.

A side-effect of enforcing this condition in rds_tcp_state_change()
is that rds_tcp_accept_one_path() can now be refactored for simplicity.
It is also no longer possible to encounter an RDS_CONN_UP connection in
the arbitration logic in rds_tcp_accept_one().

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/connection.c  |    1 +
 net/rds/tcp_connect.c |   14 +++++++++++++-
 net/rds/tcp_listen.c  |   29 ++++++++++++-----------------
 3 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index b86e188..fe9d31c 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -683,6 +683,7 @@ void rds_conn_path_connect_if_down(struct rds_conn_path *cp)
 	    !test_and_set_bit(RDS_RECONNECT_PENDING, &cp->cp_flags))
 		queue_delayed_work(rds_wq, &cp->cp_conn_w, 0);
 }
+EXPORT_SYMBOL_GPL(rds_conn_path_connect_if_down);
 
 void rds_conn_connect_if_down(struct rds_connection *conn)
 {
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index 05f61c5..d6839d9 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -60,7 +60,19 @@ void rds_tcp_state_change(struct sock *sk)
 	case TCP_SYN_RECV:
 		break;
 	case TCP_ESTABLISHED:
-		rds_connect_path_complete(cp, RDS_CONN_CONNECTING);
+		/* Force the peer to reconnect so that we have the
+		 * TCP ports going from <smaller-ip>.<transient> to
+		 * <larger-ip>.<RDS_TCP_PORT>. We avoid marking the
+		 * RDS connection as RDS_CONN_UP until the reconnect,
+		 * to avoid RDS datagram loss.
+		 */
+		if (cp->cp_conn->c_laddr > cp->cp_conn->c_faddr &&
+		    rds_conn_path_transition(cp, RDS_CONN_CONNECTING,
+					     RDS_CONN_ERROR)) {
+			rds_conn_path_drop(cp);
+		} else {
+			rds_connect_path_complete(cp, RDS_CONN_CONNECTING);
+		}
 		break;
 	case TCP_CLOSE_WAIT:
 	case TCP_CLOSE:
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index c9c4968..f74bab3 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -83,25 +83,20 @@ struct rds_tcp_connection *rds_tcp_accept_one_path(struct rds_connection *conn)
 {
 	int i;
 	bool peer_is_smaller = (conn->c_faddr < conn->c_laddr);
-	int npaths = conn->c_npaths;
-
-	if (npaths <= 1) {
-		struct rds_conn_path *cp = &conn->c_path[0];
-		int ret;
-
-		ret = rds_conn_path_transition(cp, RDS_CONN_DOWN,
-					       RDS_CONN_CONNECTING);
-		if (!ret)
-			rds_conn_path_transition(cp, RDS_CONN_ERROR,
-						 RDS_CONN_CONNECTING);
-		return cp->cp_transport_data;
-	}
+	int npaths = max_t(int, 1, conn->c_npaths);
 
-	/* for mprds, paths with cp_index > 0 MUST be initiated by the peer
+	/* for mprds, all paths MUST be initiated by the peer
 	 * with the smaller address.
 	 */
-	if (!peer_is_smaller)
+	if (!peer_is_smaller) {
+		/* Make sure we initiate at least one path if this
+		 * has not already been done; rds_start_mprds() will
+		 * take care of additional paths, if necessary.
+		 */
+		if (npaths == 1)
+			rds_conn_path_connect_if_down(&conn->c_path[0]);
 		return NULL;
+	}
 
 	for (i = 0; i < npaths; i++) {
 		struct rds_conn_path *cp = &conn->c_path[i];
@@ -171,8 +166,8 @@ int rds_tcp_accept_one(struct socket *sock)
 	mutex_lock(&rs_tcp->t_conn_path_lock);
 	cp = rs_tcp->t_cpath;
 	conn_state = rds_conn_path_state(cp);
-	if (conn_state != RDS_CONN_CONNECTING && conn_state != RDS_CONN_UP &&
-	    conn_state != RDS_CONN_ERROR)
+	WARN_ON(conn_state == RDS_CONN_UP);
+	if (conn_state != RDS_CONN_CONNECTING && conn_state != RDS_CONN_ERROR)
 		goto rst_nsk;
 	if (rs_tcp->t_sock) {
 		/* Need to resolve a duelling SYN between peers.
-- 
1.7.1
