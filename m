From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 15/15] RDS: Refactor end of __conn_create for readability
Date: Fri, 17 Jul 2009 16:13:36 -0700
Message-ID: <1247872416-17834-16-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:30154 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758036AbZGQXov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:44:51 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNiPBW030297
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:44:26 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a comment for what's going on. Remove negative logic.
I find this much easier to understand quickly, although
there are a few lines duplicated.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/connection.c |   48 +++++++++++++++++++++++++++++++-----------------
 1 files changed, 31 insertions(+), 17 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 605fe3f..b420a20 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -126,7 +126,7 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 				       struct rds_transport *trans, gfp_t gfp,
 				       int is_outgoing)
 {
-	struct rds_connection *conn, *tmp, *parent = NULL;
+	struct rds_connection *conn, *parent = NULL;
 	struct hlist_head *head = rds_conn_bucket(laddr, faddr);
 	unsigned long flags;
 	int ret;
@@ -210,26 +210,40 @@ static struct rds_connection *__rds_conn_create(__be32 laddr, __be32 faddr,
 	  trans->t_name ? trans->t_name : "[unknown]",
 	  is_outgoing ? "(outgoing)" : "");
 
+	/*
+	 * Since we ran without holding the conn lock, someone could
+	 * have created the same conn (either normal or passive) in the
+	 * interim. We check while holding the lock. If we won, we complete
+	 * init and return our conn. If we lost, we rollback and return the
+	 * other one.
+	 */
 	spin_lock_irqsave(&rds_conn_lock, flags);
-	if (parent == NULL) {
-		tmp = rds_conn_lookup(head, laddr, faddr, trans);
-		if (tmp == NULL)
-			hlist_add_head(&conn->c_hash_node, head);
-	} else {
-		tmp = parent->c_passive;
-		if (!tmp)
+	if (parent) {
+		/* Creating passive conn */
+		if (parent->c_passive) {
+			trans->conn_free(conn->c_transport_data);
+			kmem_cache_free(rds_conn_slab, conn);
+			conn = parent->c_passive;
+		} else {
 			parent->c_passive = conn;
-	}
-
-	if (tmp) {
-		trans->conn_free(conn->c_transport_data);
-		kmem_cache_free(rds_conn_slab, conn);
-		conn = tmp;
+			rds_cong_add_conn(conn);
+			rds_conn_count++;
+		}
 	} else {
-		rds_cong_add_conn(conn);
-		rds_conn_count++;
+		/* Creating normal conn */
+		struct rds_connection *found;
+
+		found = rds_conn_lookup(head, laddr, faddr, trans);
+		if (found) {
+			trans->conn_free(conn->c_transport_data);
+			kmem_cache_free(rds_conn_slab, conn);
+			conn = found;
+		} else {
+			hlist_add_head(&conn->c_hash_node, head);
+			rds_cong_add_conn(conn);
+			rds_conn_count++;
+		}
 	}
-
 	spin_unlock_irqrestore(&rds_conn_lock, flags);
 
 out:
-- 
1.6.0.4

