From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 13/18] RDS: RDMA: Fix the composite message user notification
Date: Tue,  6 Dec 2016 20:01:51 -0800
Message-ID: <1481083316-11648-14-git-send-email-santosh.shilimkar@oracle.com>
References: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When application sends an RDS RDMA composite message consist of
RDMA transfer to be followed up by non RDMA payload, it expect to
be notified *only* when the full message gets delivered. RDS RDMA
notification doesn't behave this way though.

Thanks to Venkat for debug and root casuing the issue
where only first part of the message(RDMA) was
successfully delivered but remainder payload delivery failed.
In that case, application should not be notified with
a false positive of message delivery success.

Fix this case by making sure the user gets notified only after
the full message delivery.

Reviewed-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_send.c | 25 +++++++++++++++----------
 net/rds/rdma.c    | 10 ++++++++++
 net/rds/rds.h     |  1 +
 net/rds/send.c    |  4 +++-
 4 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 19eca5c..5e72de1 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -69,16 +69,6 @@ static void rds_ib_send_complete(struct rds_message *rm,
 	complete(rm, notify_status);
 }
 
-static void rds_ib_send_unmap_data(struct rds_ib_connection *ic,
-				   struct rm_data_op *op,
-				   int wc_status)
-{
-	if (op->op_nents)
-		ib_dma_unmap_sg(ic->i_cm_id->device,
-				op->op_sg, op->op_nents,
-				DMA_TO_DEVICE);
-}
-
 static void rds_ib_send_unmap_rdma(struct rds_ib_connection *ic,
 				   struct rm_rdma_op *op,
 				   int wc_status)
@@ -139,6 +129,21 @@ static void rds_ib_send_unmap_atomic(struct rds_ib_connection *ic,
 		rds_ib_stats_inc(s_ib_atomic_fadd);
 }
 
+static void rds_ib_send_unmap_data(struct rds_ib_connection *ic,
+				   struct rm_data_op *op,
+				   int wc_status)
+{
+	struct rds_message *rm = container_of(op, struct rds_message, data);
+
+	if (op->op_nents)
+		ib_dma_unmap_sg(ic->i_cm_id->device,
+				op->op_sg, op->op_nents,
+				DMA_TO_DEVICE);
+
+	if (rm->rdma.op_active && rm->data.op_notify)
+		rds_ib_send_unmap_rdma(ic, &rm->rdma, wc_status);
+}
+
 /*
  * Unmap the resources associated with a struct send_work.
  *
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 8151c49..dd508e0 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -627,6 +627,16 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 		}
 		op->op_notifier->n_user_token = args->user_token;
 		op->op_notifier->n_status = RDS_RDMA_SUCCESS;
+
+		/* Enable rmda notification on data operation for composite
+		 * rds messages and make sure notification is enabled only
+		 * for the data operation which follows it so that application
+		 * gets notified only after full message gets delivered.
+		 */
+		if (rm->data.op_sg) {
+			rm->rdma.op_notify = 0;
+			rm->data.op_notify = !!(args->flags & RDS_RDMA_NOTIFY_ME);
+		}
 	}
 
 	/* The cookie contains the R_Key of the remote memory region, and
diff --git a/net/rds/rds.h b/net/rds/rds.h
index ebbf909..0bb8213 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -419,6 +419,7 @@ struct rds_message {
 		} rdma;
 		struct rm_data_op {
 			unsigned int		op_active:1;
+			unsigned int		op_notify:1;
 			unsigned int		op_nents;
 			unsigned int		op_count;
 			unsigned int		op_dmasg;
diff --git a/net/rds/send.c b/net/rds/send.c
index 0a6f38b..45e025b 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -476,12 +476,14 @@ void rds_rdma_send_complete(struct rds_message *rm, int status)
 	struct rm_rdma_op *ro;
 	struct rds_notifier *notifier;
 	unsigned long flags;
+	unsigned int notify = 0;
 
 	spin_lock_irqsave(&rm->m_rs_lock, flags);
 
+	notify =  rm->rdma.op_notify | rm->data.op_notify;
 	ro = &rm->rdma;
 	if (test_bit(RDS_MSG_ON_SOCK, &rm->m_flags) &&
-	    ro->op_active && ro->op_notify && ro->op_notifier) {
+	    ro->op_active && notify && ro->op_notifier) {
 		notifier = ro->op_notifier;
 		rs = rm->m_rs;
 		sock_hold(rds_rs_to_sk(rs));
-- 
1.9.1
