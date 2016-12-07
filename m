From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 14/18] RDS: IB: fix panic due to handlers running post teardown
Date: Tue,  6 Dec 2016 20:01:52 -0800
Message-ID: <1481083316-11648-15-git-send-email-santosh.shilimkar@oracle.com>
References: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shutdown code reaping loop takes care of emptying the
CQ's before they being destroyed. And once tasklets are
killed, the hanlders are not expected to run.

But because of core tasklet code issues, tasklet handler could
still run even after tasklet_kill,
RDS IB shutdown code already reaps the CQs before freeing
cq/qp resources so as such the handlers have nothing left
to do post shutdown.

On other hand any handler running after teardown and trying
to access already freed qp/cq resources causes issues
Patch fixes this race by  makes sure that handlers returns
without any action post teardown.

Reviewed-by: Wengang <wen.gang.wang@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.h    |  1 +
 net/rds/ib_cm.c | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index 4b133b8..8efd1eb 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -185,6 +185,7 @@ struct rds_ib_connection {
 
 	/* Endpoint role in connection */
 	int			i_active_side;
+	atomic_t		i_cq_quiesce;
 
 	/* Send/Recv vectors */
 	int			i_scq_vector;
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 33c8584..ce3775a 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -128,6 +128,8 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 			  ic->i_flowctl ? ", flow control" : "");
 	}
 
+	atomic_set(&ic->i_cq_quiesce, 0);
+
 	/* Init rings and fill recv. this needs to wait until protocol
 	 * negotiation is complete, since ring layout is different
 	 * from 3.1 to 4.1.
@@ -267,6 +269,10 @@ static void rds_ib_tasklet_fn_send(unsigned long data)
 
 	rds_ib_stats_inc(s_ib_tasklet_call);
 
+	/* if cq has been already reaped, ignore incoming cq event */
+	if (atomic_read(&ic->i_cq_quiesce))
+		return;
+
 	poll_scq(ic, ic->i_send_cq, ic->i_send_wc);
 	ib_req_notify_cq(ic->i_send_cq, IB_CQ_NEXT_COMP);
 	poll_scq(ic, ic->i_send_cq, ic->i_send_wc);
@@ -308,6 +314,10 @@ static void rds_ib_tasklet_fn_recv(unsigned long data)
 
 	rds_ib_stats_inc(s_ib_tasklet_call);
 
+	/* if cq has been already reaped, ignore incoming cq event */
+	if (atomic_read(&ic->i_cq_quiesce))
+		return;
+
 	memset(&state, 0, sizeof(state));
 	poll_rcq(ic, ic->i_recv_cq, ic->i_recv_wc, &state);
 	ib_req_notify_cq(ic->i_recv_cq, IB_CQ_SOLICITED);
@@ -804,6 +814,8 @@ void rds_ib_conn_path_shutdown(struct rds_conn_path *cp)
 		tasklet_kill(&ic->i_send_tasklet);
 		tasklet_kill(&ic->i_recv_tasklet);
 
+		atomic_set(&ic->i_cq_quiesce, 1);
+
 		/* first destroy the ib state that generates callbacks */
 		if (ic->i_cm_id->qp)
 			rdma_destroy_qp(ic->i_cm_id);
-- 
1.9.1
