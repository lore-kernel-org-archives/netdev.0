From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] RDS: rds_conn_lookup() should factor in the struct
 net for a match
Date: Thu, 3 Sep 2015 16:24:52 -0400
Message-ID: <20150903202452.GJ17626@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com, davem@davemloft.net,
	santosh.shilimkar@oracle.com, ajaykumar.hotchandani@oracle.com
To: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Only return a conn if the rds_conn_net(conn) matches the struct
net passed to rds_conn_lookup().

Fixes: 467fa15356ac ("RDS-TCP: Support multiple RDS-TCP listen endpoints,
       one per netns.")

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index a50e652..9b2de5e 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -70,7 +70,8 @@ static struct hlist_head *rds_conn_bucket(__be32 laddr, __be32 faddr)
 } while (0)
 
 /* rcu read lock must be held or the connection spinlock */
-static struct rds_connection *rds_conn_lookup(struct hlist_head *head,
+static struct rds_connection *rds_conn_lookup(struct net *net,
+					      struct hlist_head *head,
 					      __be32 laddr, __be32 faddr,
 					      struct rds_transport *trans)
 {
@@ -78,7 +79,7 @@ static struct rds_connection *rds_conn_lookup(struct hlist_head *head,
 
 	hlist_for_each_entry_rcu(conn, head, c_hash_node) {
 		if (conn->c_faddr == faddr && conn->c_laddr == laddr &&
-				conn->c_trans == trans) {
+		    conn->c_trans == trans && net == rds_conn_net(conn)) {
 			ret = conn;
 			break;
 		}
@@ -132,7 +133,7 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 	if (!is_outgoing && otrans->t_type == RDS_TRANS_TCP)
 		goto new_conn;
 	rcu_read_lock();
-	conn = rds_conn_lookup(head, laddr, faddr, trans);
+	conn = rds_conn_lookup(net, head, laddr, faddr, trans);
 	if (conn && conn->c_loopback && conn->c_trans != &rds_loop_transport &&
 	    laddr == faddr && !is_outgoing) {
 		/* This is a looped back IB connection, and we're
@@ -239,7 +240,7 @@ static struct rds_connection *__rds_conn_create(struct net *net,
 		if (!is_outgoing && otrans->t_type == RDS_TRANS_TCP)
 			found = NULL;
 		else
-			found = rds_conn_lookup(head, laddr, faddr, trans);
+			found = rds_conn_lookup(net, head, laddr, faddr, trans);
 		if (found) {
 			trans->conn_free(conn->c_transport_data);
 			kmem_cache_free(rds_conn_slab, conn);
-- 
1.7.1
