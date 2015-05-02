From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 2/2] net/rds: RDS-TCP: only initiate reconnect attempt on outgoing TCP socket.
Date: Sat,  2 May 2015 07:55:09 -0400
Message-ID: <dd769ee60561d78138cf7a652b8a63a68ce1dde3.1430421231.git.sowmini.varadhan@oracle.com>
References: <cover.1430421231.git.sowmini.varadhan@oracle.com>
Cc: chien.yen@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, ajaykumar.hotchandani@oracle.com,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1430421231.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1430421231.git.sowmini.varadhan@oracle.com>
References: <cover.1430421231.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the peer of an RDS-TCP connection restarts, a reconnect
attempt should only be made from the active side  of the TCP
connection, i.e. the side that has a transient TCP port
number, else the 2 nodes will have an endless exchange of
3WHs followed by RSTs. Do not add the passive side of the TCP 
connection to the c_hash_node and thus avoid triggering 
rds_queue_reconnect() for passive rds connections. Passive side
cleanup/recovery is handled in the rds_tcp module.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 60f0cd6..da6da57 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -234,13 +234,22 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 		/* Creating normal conn */
 		struct rds_connection *found;
 
-		found = rds_conn_lookup(head, laddr, faddr, trans);
+		if (!is_outgoing && otrans->t_type == RDS_TRANS_TCP)
+			found = NULL;
+		else
+			found = rds_conn_lookup(head, laddr, faddr, trans);
 		if (found) {
 			trans->conn_free(conn->c_transport_data);
 			kmem_cache_free(rds_conn_slab, conn);
 			conn = found;
 		} else {
-			hlist_add_head_rcu(&conn->c_hash_node, head);
+			if ((is_outgoing && otrans->t_type == RDS_TRANS_TCP) ||
+			    (otrans->t_type != RDS_TRANS_TCP)) {
+				/* Only the active side should be added to
+				 * reconnect list for TCP.
+				 */
+				hlist_add_head_rcu(&conn->c_hash_node, head);
+			}
 			rds_cong_add_conn(conn);
 			rds_conn_count++;
 		}
-- 
1.7.1
