From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net v2 1/2] RDS:TCP: Synchronize rds_tcp_accept_one with rds_send_xmit when resetting t_sock
Date: Mon,  2 May 2016 11:24:51 -0700
Message-ID: <470ac585d014a6d8ea1600b8897bdc313e7c2431.1462212462.git.sowmini.varadhan@oracle.com>
References: <cover.1462212462.git.sowmini.varadhan@oracle.com>
Cc: santosh.shilimkar@oracle.com, davem@davemloft.net
To: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46163 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843AbcEBSZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 14:25:02 -0400
In-Reply-To: <cover.1462212462.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1462212462.git.sowmini.varadhan@oracle.com>
References: <cover.1462212462.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race condition between rds_send_xmit -> rds_tcp_xmit
and the code that deals with resolution of duelling syns added
by commit 241b271952eb ("RDS-TCP: Reset tcp callbacks if re-using an
outgoing socket in rds_tcp_accept_one()").

Specifically, we may end up derefencing a null pointer in rds_send_xmit
if we have the interleaving sequence:
           rds_tcp_accept_one                  rds_send_xmit

                                             conn is RDS_CONN_UP, so
    					 invoke rds_tcp_xmit

                                             tc = conn->c_transport_data
        rds_tcp_restore_callbacks
            /* reset t_sock */
    					 null ptr deref from tc->t_sock

The race condition can be avoided without adding the overhead of
additional locking in the xmit path: have rds_tcp_accept_one wait
for rds_tcp_xmit threads to complete before resetting callbacks.
The synchronization can be done in the same manner as rds_conn_shutdown().
First set the rds_conn_state to something other than RDS_CONN_UP
(so that new threads cannot get into rds_tcp_xmit()), then wait for
RDS_IN_XMIT to be cleared in the conn->c_flags indicating that any
threads in rds_tcp_xmit are done.

Fixes: 241b271952eb ("RDS-TCP: Reset tcp callbacks if re-using an
outgoing socket in rds_tcp_accept_one()")
Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
v2: spelling edit in commit: s/sequencee/sequence
 net/rds/tcp.c        |    2 +-
 net/rds/tcp_listen.c |   40 ++++++++++++++++++++++++----------------
 2 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 61ed2a8..9134544 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -127,7 +127,7 @@ void rds_tcp_restore_callbacks(struct socket *sock,
 
 /*
  * This is the only path that sets tc->t_sock.  Send and receive trust that
- * it is set.  The RDS_CONN_CONNECTED bit protects those paths from being
+ * it is set.  The RDS_CONN_UP bit protects those paths from being
  * called while it isn't set.
  */
 void rds_tcp_set_callbacks(struct socket *sock, struct rds_connection *conn)
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 0936a4a..0896187 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -115,24 +115,32 @@ int rds_tcp_accept_one(struct socket *sock)
 	 * rds_tcp_state_change() will do that cleanup
 	 */
 	rs_tcp = (struct rds_tcp_connection *)conn->c_transport_data;
-	if (rs_tcp->t_sock &&
-	    ntohl(inet->inet_saddr) < ntohl(inet->inet_daddr)) {
-		struct sock *nsk = new_sock->sk;
-
-		nsk->sk_user_data = NULL;
-		nsk->sk_prot->disconnect(nsk, 0);
-		tcp_done(nsk);
-		new_sock = NULL;
-		ret = 0;
-		goto out;
-	} else if (rs_tcp->t_sock) {
-		rds_tcp_restore_callbacks(rs_tcp->t_sock, rs_tcp);
-		conn->c_outgoing = 0;
-	}
-
 	rds_conn_transition(conn, RDS_CONN_DOWN, RDS_CONN_CONNECTING);
+	if (rs_tcp->t_sock) {
+		/* Need to resolve a duelling SYN between peers.
+		 * We have an outstanding SYN to this peer, which may
+		 * potentially have transitioned to the RDS_CONN_UP state,
+		 * so we must quiesce any send threads before resetting
+		 * c_transport_data.
+		 */
+		wait_event(conn->c_waitq,
+			   !test_bit(RDS_IN_XMIT, &conn->c_flags));
+		if (ntohl(inet->inet_saddr) < ntohl(inet->inet_daddr)) {
+			struct sock *nsk = new_sock->sk;
+
+			nsk->sk_user_data = NULL;
+			nsk->sk_prot->disconnect(nsk, 0);
+			tcp_done(nsk);
+			new_sock = NULL;
+			ret = 0;
+			goto out;
+		} else if (rs_tcp->t_sock) {
+			rds_tcp_restore_callbacks(rs_tcp->t_sock, rs_tcp);
+			conn->c_outgoing = 0;
+		}
+	}
 	rds_tcp_set_callbacks(new_sock, conn);
-	rds_connect_complete(conn);
+	rds_connect_complete(conn); /* marks RDS_CONN_UP */
 	new_sock = NULL;
 	ret = 0;
 
-- 
1.7.1
