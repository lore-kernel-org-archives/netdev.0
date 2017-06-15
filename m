From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/3] rds: tcp: remove cp_outgoing
Date: Thu, 15 Jun 2017 11:28:53 -0700
Message-ID: <18dd49f5bd78d7a1b205540d3dce4807607e53ee.1497547381.git.sowmini.varadhan@oracle.com>
References: <cover.1497547381.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        santosh.shilimkar@oracle.com, imanti.mendez@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45486 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752449AbdFOSb3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 14:31:29 -0400
In-Reply-To: <cover.1497547381.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1497547381.git.sowmini.varadhan@oracle.com>
References: <cover.1497547381.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 1a0e100fb2c9 ("RDS: TCP: Force every connection to be
initiated by numerically smaller IP address") we no longer need
the logic associated with cp_outgoing, so clean up usage of this
field.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: Imanti Mendez <imanti.mendez@oracle.com>
---
 net/rds/connection.c  |    5 -----
 net/rds/rds.h         |    2 --
 net/rds/tcp_connect.c |    1 -
 net/rds/tcp_listen.c  |   19 ++++---------------
 4 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 6a5ebde..382443b 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -124,11 +124,6 @@ static void __rds_conn_path_init(struct rds_connection *conn,
 	cp->cp_conn = conn;
 	atomic_set(&cp->cp_state, RDS_CONN_DOWN);
 	cp->cp_send_gen = 0;
-	/* cp_outgoing is per-path. So we can only set it here
-	 * for the single-path transports.
-	 */
-	if (!conn->c_trans->t_mp_capable)
-		cp->cp_outgoing = (is_outgoing ? 1 : 0);
 	cp->cp_reconnect_jiffies = 0;
 	INIT_DELAYED_WORK(&cp->cp_send_w, rds_send_worker);
 	INIT_DELAYED_WORK(&cp->cp_recv_w, rds_recv_worker);
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 82d38cc..aa183d6 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -125,8 +125,6 @@ struct rds_conn_path {
 
 	unsigned int		cp_unacked_packets;
 	unsigned int		cp_unacked_bytes;
-	unsigned int		cp_outgoing:1,
-				cp_pad_to_32:31;
 	unsigned int		cp_index;
 };
 
diff --git a/net/rds/tcp_connect.c b/net/rds/tcp_connect.c
index d6839d9..97db861 100644
--- a/net/rds/tcp_connect.c
+++ b/net/rds/tcp_connect.c
@@ -135,7 +135,6 @@ int rds_tcp_conn_path_connect(struct rds_conn_path *cp)
 	ret = sock->ops->connect(sock, (struct sockaddr *)&dest, sizeof(dest),
 				 O_NONBLOCK);
 
-	cp->cp_outgoing = 1;
 	rdsdebug("connect to address %pI4 returned %d\n", &conn->c_faddr, ret);
 	if (ret == -EINPROGRESS)
 		ret = 0;
diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index 5076788..238ff5c 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -171,21 +171,10 @@ int rds_tcp_accept_one(struct socket *sock)
 	if (conn_state != RDS_CONN_CONNECTING && conn_state != RDS_CONN_ERROR)
 		goto rst_nsk;
 	if (rs_tcp->t_sock) {
-		/* Need to resolve a duelling SYN between peers.
-		 * We have an outstanding SYN to this peer, which may
-		 * potentially have transitioned to the RDS_CONN_UP state,
-		 * so we must quiesce any send threads before resetting
-		 * c_transport_data.
-		 */
-		if (ntohl(inet->inet_saddr) < ntohl(inet->inet_daddr) ||
-		    !cp->cp_outgoing) {
-			goto rst_nsk;
-		} else {
-			rds_tcp_reset_callbacks(new_sock, cp);
-			cp->cp_outgoing = 0;
-			/* rds_connect_path_complete() marks RDS_CONN_UP */
-			rds_connect_path_complete(cp, RDS_CONN_RESETTING);
-		}
+		/* Duelling SYN has been handled in rds_tcp_accept_one() */
+		rds_tcp_reset_callbacks(new_sock, cp);
+		/* rds_connect_path_complete() marks RDS_CONN_UP */
+		rds_connect_path_complete(cp, RDS_CONN_RESETTING);
 	} else {
 		rds_tcp_set_callbacks(new_sock, cp);
 		rds_connect_path_complete(cp, RDS_CONN_CONNECTING);
-- 
1.7.1
