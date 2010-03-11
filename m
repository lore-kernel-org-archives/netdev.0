From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 12/13] RDS: Do not call set_page_dirty() with irqs off
Date: Thu, 11 Mar 2010 15:50:06 -0800
Message-ID: <1268351407-7394-13-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17783 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796Ab0CKXwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:52:21 -0500
Received: from rcsinet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rcsinet12.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNqIgV003951
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:52:19 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

set_page_dirty() unconditionally re-enables interrupts, so
if we call it with irqs off, they will be on after the call,
and that's bad. This patch moves the call after we've re-enabled
interrupts in send_drop_to(), so it's safe.

Also, add BUG_ONs to let us know if we ever do call set_page_dirty
with interrupts off.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_rdma.c |    1 +
 net/rds/rdma.c    |    4 +++-
 net/rds/send.c    |   14 ++++++++------
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 65e668d..cfb1d90 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -440,6 +440,7 @@ static void __rds_ib_teardown_mr(struct rds_ib_mr *ibmr)
 
 			/* FIXME we need a way to tell a r/w MR
 			 * from a r/o MR */
+			BUG_ON(in_interrupt());
 			set_page_dirty(page);
 			put_page(page);
 		}
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 4c64daa..61b359d 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -438,8 +438,10 @@ void rds_rdma_free_op(struct rds_rdma_op *ro)
 		/* Mark page dirty if it was possibly modified, which
 		 * is the case for a RDMA_READ which copies from remote
 		 * to local memory */
-		if (!ro->r_write)
+		if (!ro->r_write) {
+			BUG_ON(in_interrupt());
 			set_page_dirty(page);
+		}
 		put_page(page);
 	}
 
diff --git a/net/rds/send.c b/net/rds/send.c
index 51e2def..4629a0b 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -507,12 +507,13 @@ EXPORT_SYMBOL_GPL(rds_send_get_message);
  */
 void rds_send_remove_from_sock(struct list_head *messages, int status)
 {
-	unsigned long flags = 0; /* silence gcc :P */
+	unsigned long flags;
 	struct rds_sock *rs = NULL;
 	struct rds_message *rm;
 
-	local_irq_save(flags);
 	while (!list_empty(messages)) {
+		int was_on_sock = 0;
+
 		rm = list_entry(messages->next, struct rds_message,
 				m_conn_item);
 		list_del_init(&rm->m_conn_item);
@@ -527,7 +528,7 @@ void rds_send_remove_from_sock(struct list_head *messages, int status)
 		 * while we're messing with it. It does not prevent the
 		 * message from being removed from the socket, though.
 		 */
-		spin_lock(&rm->m_rs_lock);
+		spin_lock_irqsave(&rm->m_rs_lock, flags);
 		if (!test_bit(RDS_MSG_ON_SOCK, &rm->m_flags))
 			goto unlock_and_drop;
 
@@ -556,21 +557,22 @@ void rds_send_remove_from_sock(struct list_head *messages, int status)
 					notifier->n_status = status;
 				rm->m_rdma_op->r_notifier = NULL;
 			}
-			rds_message_put(rm);
+			was_on_sock = 1;
 			rm->m_rs = NULL;
 		}
 		spin_unlock(&rs->rs_lock);
 
 unlock_and_drop:
-		spin_unlock(&rm->m_rs_lock);
+		spin_unlock_irqrestore(&rm->m_rs_lock, flags);
 		rds_message_put(rm);
+		if (was_on_sock)
+			rds_message_put(rm);
 	}
 
 	if (rs) {
 		rds_wake_sk_sleep(rs);
 		sock_put(rds_rs_to_sk(rs));
 	}
-	local_irq_restore(flags);
 }
 
 /*
-- 
1.6.3.3

