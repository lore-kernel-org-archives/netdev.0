From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 07/17] RDS: Remove stale function rds_send_get_message()
Date: Mon, 13 Jun 2016 09:44:32 -0700
Message-ID: <3c645bd5c8d906fa0d3093826a54b68ad5de1e7b.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40945 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964982AbcFMQpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:10 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only caller of rds_send_get_message() was
rds_iw_send_cq_comp_handler() which was removed as part of
commit dcdede0406d3 ("RDS: Drop stale iWARP RDMA transport"),
so remove rds_send_get_message() for the same reason.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/rds.h  |    2 --
 net/rds/send.c |   36 ------------------------------------
 2 files changed, 0 insertions(+), 38 deletions(-)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index d94aa36..2cffd37 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -789,8 +789,6 @@ void rds_send_drop_acked(struct rds_connection *conn, u64 ack,
 void rds_send_path_drop_acked(struct rds_conn_path *cp, u64 ack,
 			      is_acked_func is_acked);
 int rds_send_pong(struct rds_connection *conn, __be16 dport);
-struct rds_message *rds_send_get_message(struct rds_connection *,
-					 struct rm_rdma_op *);
 
 /* rdma.c */
 void rds_rdma_unuse(struct rds_sock *rs, u32 r_key, int force);
diff --git a/net/rds/send.c b/net/rds/send.c
index 3f6a96c..3fb280b 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -566,42 +566,6 @@ __rds_send_complete(struct rds_sock *rs, struct rds_message *rm, int status)
 }
 
 /*
- * This is called from the IB send completion when we detect
- * a RDMA operation that failed with remote access error.
- * So speed is not an issue here.
- */
-struct rds_message *rds_send_get_message(struct rds_connection *conn,
-					 struct rm_rdma_op *op)
-{
-	struct rds_message *rm, *tmp, *found = NULL;
-	unsigned long flags;
-
-	spin_lock_irqsave(&conn->c_lock, flags);
-
-	list_for_each_entry_safe(rm, tmp, &conn->c_retrans, m_conn_item) {
-		if (&rm->rdma == op) {
-			atomic_inc(&rm->m_refcount);
-			found = rm;
-			goto out;
-		}
-	}
-
-	list_for_each_entry_safe(rm, tmp, &conn->c_send_queue, m_conn_item) {
-		if (&rm->rdma == op) {
-			atomic_inc(&rm->m_refcount);
-			found = rm;
-			break;
-		}
-	}
-
-out:
-	spin_unlock_irqrestore(&conn->c_lock, flags);
-
-	return found;
-}
-EXPORT_SYMBOL_GPL(rds_send_get_message);
-
-/*
  * This removes messages from the socket's list if they're on it.  The list
  * argument must be private to the caller, we must be able to modify it
  * without locks.  The messages must have a reference held for their
-- 
1.7.1
