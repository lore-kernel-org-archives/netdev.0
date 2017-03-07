From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] rds: ib: add error handle
Date: Tue,  7 Mar 2017 02:48:36 -0500
Message-ID: <1488872916-24751-1-git-send-email-yanjun.zhu@oracle.com>
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In the function rds_ib_setup_qp, the error handle is missing. When some
error occurs, it is possible that memory leak occurs. As such, error
handle is added.

Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Reviewed-by: Guanglei Li <guanglei.li-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/rds/ib_cm.c | 47 ++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 36 insertions(+), 11 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index ce3775a..d47ae0f 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -442,7 +442,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 		ic->i_send_cq = NULL;
 		ibdev_put_vector(rds_ibdev, ic->i_scq_vector);
 		rdsdebug("ib_create_cq send failed: %d\n", ret);
-		goto out;
+		goto rds_ibdev_out;
 	}
 
 	ic->i_rcq_vector = ibdev_get_unused_vector(rds_ibdev);
@@ -456,19 +456,19 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 		ic->i_recv_cq = NULL;
 		ibdev_put_vector(rds_ibdev, ic->i_rcq_vector);
 		rdsdebug("ib_create_cq recv failed: %d\n", ret);
-		goto out;
+		goto send_cq_out;
 	}
 
 	ret = ib_req_notify_cq(ic->i_send_cq, IB_CQ_NEXT_COMP);
 	if (ret) {
 		rdsdebug("ib_req_notify_cq send failed: %d\n", ret);
-		goto out;
+		goto recv_cq_out;
 	}
 
 	ret = ib_req_notify_cq(ic->i_recv_cq, IB_CQ_SOLICITED);
 	if (ret) {
 		rdsdebug("ib_req_notify_cq recv failed: %d\n", ret);
-		goto out;
+		goto recv_cq_out;
 	}
 
 	/* XXX negotiate max send/recv with remote? */
@@ -494,7 +494,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	ret = rdma_create_qp(ic->i_cm_id, ic->i_pd, &attr);
 	if (ret) {
 		rdsdebug("rdma_create_qp failed: %d\n", ret);
-		goto out;
+		goto recv_cq_out;
 	}
 
 	ic->i_send_hdrs = ib_dma_alloc_coherent(dev,
@@ -504,7 +504,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	if (!ic->i_send_hdrs) {
 		ret = -ENOMEM;
 		rdsdebug("ib_dma_alloc_coherent send failed\n");
-		goto out;
+		goto qp_out;
 	}
 
 	ic->i_recv_hdrs = ib_dma_alloc_coherent(dev,
@@ -514,7 +514,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	if (!ic->i_recv_hdrs) {
 		ret = -ENOMEM;
 		rdsdebug("ib_dma_alloc_coherent recv failed\n");
-		goto out;
+		goto send_hdrs_dma_out;
 	}
 
 	ic->i_ack = ib_dma_alloc_coherent(dev, sizeof(struct rds_header),
@@ -522,7 +522,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	if (!ic->i_ack) {
 		ret = -ENOMEM;
 		rdsdebug("ib_dma_alloc_coherent ack failed\n");
-		goto out;
+		goto recv_hdrs_dma_out;
 	}
 
 	ic->i_sends = vzalloc_node(ic->i_send_ring.w_nr * sizeof(struct rds_ib_send_work),
@@ -530,7 +530,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	if (!ic->i_sends) {
 		ret = -ENOMEM;
 		rdsdebug("send allocation failed\n");
-		goto out;
+		goto ack_dma_out;
 	}
 
 	ic->i_recvs = vzalloc_node(ic->i_recv_ring.w_nr * sizeof(struct rds_ib_recv_work),
@@ -538,7 +538,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	if (!ic->i_recvs) {
 		ret = -ENOMEM;
 		rdsdebug("recv allocation failed\n");
-		goto out;
+		goto sends_out;
 	}
 
 	rds_ib_recv_init_ack(ic);
@@ -546,8 +546,33 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	rdsdebug("conn %p pd %p cq %p %p\n", conn, ic->i_pd,
 		 ic->i_send_cq, ic->i_recv_cq);
 
-out:
+	return ret;
+
+sends_out:
+	vfree(ic->i_sends);
+ack_dma_out:
+	ib_dma_free_coherent(dev, sizeof(struct rds_header),
+			     ic->i_ack, ic->i_ack_dma);
+recv_hdrs_dma_out:
+	ib_dma_free_coherent(dev, ic->i_recv_ring.w_nr *
+					sizeof(struct rds_header),
+					ic->i_recv_hdrs, ic->i_recv_hdrs_dma);
+send_hdrs_dma_out:
+	ib_dma_free_coherent(dev, ic->i_send_ring.w_nr *
+					sizeof(struct rds_header),
+					ic->i_send_hdrs, ic->i_send_hdrs_dma);
+qp_out:
+	rdma_destroy_qp(ic->i_cm_id);
+recv_cq_out:
+	if (!ib_destroy_cq(ic->i_recv_cq))
+		ic->i_recv_cq = NULL;
+send_cq_out:
+	if (!ib_destroy_cq(ic->i_send_cq))
+		ic->i_send_cq = NULL;
+rds_ibdev_out:
+	rds_ib_remove_conn(rds_ibdev, conn);
 	rds_ib_dev_put(rds_ibdev);
+
 	return ret;
 }
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
