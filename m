From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 03/14] RDS: destroy the ib state earlier during shutdown
Date: Sat, 22 Aug 2015 15:45:24 -0700
Message-ID: <1440283535-4800-4-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Destroy ib state early during shutdown. Otherwise we can get callbacks
after the QP isn't really able to handle them.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_cm.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 0da2a45..8b40d3c 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -639,6 +639,16 @@ void rds_ib_conn_shutdown(struct rds_connection *conn)
 			   (atomic_read(&ic->i_signaled_sends) == 0));
 		tasklet_kill(&ic->i_recv_tasklet);
 
+		/* first destroy the ib state that generates callbacks */
+		if (ic->i_cm_id->qp)
+			rdma_destroy_qp(ic->i_cm_id);
+		if (ic->i_send_cq)
+			ib_destroy_cq(ic->i_send_cq);
+		if (ic->i_recv_cq)
+			ib_destroy_cq(ic->i_recv_cq);
+		rdma_destroy_id(ic->i_cm_id);
+
+		/* then free the resources that ib callbacks use */
 		if (ic->i_send_hdrs)
 			ib_dma_free_coherent(dev,
 					   ic->i_send_ring.w_nr *
@@ -662,14 +672,6 @@ void rds_ib_conn_shutdown(struct rds_connection *conn)
 		if (ic->i_recvs)
 			rds_ib_recv_clear_ring(ic);
 
-		if (ic->i_cm_id->qp)
-			rdma_destroy_qp(ic->i_cm_id);
-		if (ic->i_send_cq)
-			ib_destroy_cq(ic->i_send_cq);
-		if (ic->i_recv_cq)
-			ib_destroy_cq(ic->i_recv_cq);
-		rdma_destroy_id(ic->i_cm_id);
-
 		/*
 		 * Move connection back to the nodev list.
 		 */
-- 
1.9.1
