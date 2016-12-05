From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 12/18] RDS: IB: Add vector spreading for cqs
Date: Sun,  4 Dec 2016 22:57:47 -0800
Message-ID: <1480921073-9140-13-git-send-email-santosh.shilimkar@oracle.com>
References: <1480921073-9140-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25680 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751774AbcLEG6R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 01:58:17 -0500
In-Reply-To: <1480921073-9140-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on available device vectors, allocate cqs accordingly to
get better spread of completion vectors which helps performace
great deal..

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.c    | 11 +++++++++++
 net/rds/ib.h    |  5 +++++
 net/rds/ib_cm.c | 40 +++++++++++++++++++++++++++++++++++++---
 3 files changed, 53 insertions(+), 3 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 5680d90..8d70884 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -111,6 +111,9 @@ static void rds_ib_dev_free(struct work_struct *work)
 		kfree(i_ipaddr);
 	}
 
+	if (rds_ibdev->vector_load)
+		kfree(rds_ibdev->vector_load);
+
 	kfree(rds_ibdev);
 }
 
@@ -159,6 +162,14 @@ static void rds_ib_add_one(struct ib_device *device)
 	rds_ibdev->max_initiator_depth = device->attrs.max_qp_init_rd_atom;
 	rds_ibdev->max_responder_resources = device->attrs.max_qp_rd_atom;
 
+	rds_ibdev->vector_load = kzalloc(sizeof(int) * device->num_comp_vectors,
+					 GFP_KERNEL);
+	if (!rds_ibdev->vector_load) {
+		pr_err("RDS/IB: %s failed to allocate vector memory\n",
+			__func__);
+		goto put_dev;
+	}
+
 	rds_ibdev->dev = device;
 	rds_ibdev->pd = ib_alloc_pd(device, 0);
 	if (IS_ERR(rds_ibdev->pd)) {
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 4987387..4b133b8 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -185,6 +185,10 @@ struct rds_ib_connection {
 
 	/* Endpoint role in connection */
 	int			i_active_side;
+
+	/* Send/Recv vectors */
+	int			i_scq_vector;
+	int			i_rcq_vector;
 };
 
 /* This assumes that atomic_t is at least 32 bits */
@@ -227,6 +231,7 @@ struct rds_ib_device {
 	spinlock_t		spinlock;	/* protect the above */
 	atomic_t		refcount;
 	struct work_struct	free_work;
+	int			*vector_load;
 };
 
 #define ibdev_to_node(ibdev) dev_to_node(ibdev->dma_device)
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 4d1bf04..33c8584 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -358,6 +358,28 @@ static void rds_ib_cq_comp_handler_send(struct ib_cq *cq, void *context)
 	tasklet_schedule(&ic->i_send_tasklet);
 }
 
+static inline int ibdev_get_unused_vector(struct rds_ib_device *rds_ibdev)
+{
+	int min = rds_ibdev->vector_load[rds_ibdev->dev->num_comp_vectors - 1];
+	int index = rds_ibdev->dev->num_comp_vectors - 1;
+	int i;
+
+	for (i = rds_ibdev->dev->num_comp_vectors - 1; i >= 0; i--) {
+		if (rds_ibdev->vector_load[i] < min) {
+			index = i;
+			min = rds_ibdev->vector_load[i];
+		}
+	}
+
+	rds_ibdev->vector_load[index]++;
+	return index;
+}
+
+static inline void ibdev_put_vector(struct rds_ib_device *rds_ibdev, int index)
+{
+	rds_ibdev->vector_load[index]--;
+}
+
 /*
  * This needs to be very careful to not leave IS_ERR pointers around for
  * cleanup to trip over.
@@ -399,25 +421,30 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 	/* Protection domain and memory range */
 	ic->i_pd = rds_ibdev->pd;
 
+	ic->i_scq_vector = ibdev_get_unused_vector(rds_ibdev);
 	cq_attr.cqe = ic->i_send_ring.w_nr + fr_queue_space + 1;
-
+	cq_attr.comp_vector = ic->i_scq_vector;
 	ic->i_send_cq = ib_create_cq(dev, rds_ib_cq_comp_handler_send,
 				     rds_ib_cq_event_handler, conn,
 				     &cq_attr);
 	if (IS_ERR(ic->i_send_cq)) {
 		ret = PTR_ERR(ic->i_send_cq);
 		ic->i_send_cq = NULL;
+		ibdev_put_vector(rds_ibdev, ic->i_scq_vector);
 		rdsdebug("ib_create_cq send failed: %d\n", ret);
 		goto out;
 	}
 
+	ic->i_rcq_vector = ibdev_get_unused_vector(rds_ibdev);
 	cq_attr.cqe = ic->i_recv_ring.w_nr;
+	cq_attr.comp_vector = ic->i_rcq_vector;
 	ic->i_recv_cq = ib_create_cq(dev, rds_ib_cq_comp_handler_recv,
 				     rds_ib_cq_event_handler, conn,
 				     &cq_attr);
 	if (IS_ERR(ic->i_recv_cq)) {
 		ret = PTR_ERR(ic->i_recv_cq);
 		ic->i_recv_cq = NULL;
+		ibdev_put_vector(rds_ibdev, ic->i_rcq_vector);
 		rdsdebug("ib_create_cq recv failed: %d\n", ret);
 		goto out;
 	}
@@ -780,10 +807,17 @@ void rds_ib_conn_path_shutdown(struct rds_conn_path *cp)
 		/* first destroy the ib state that generates callbacks */
 		if (ic->i_cm_id->qp)
 			rdma_destroy_qp(ic->i_cm_id);
-		if (ic->i_send_cq)
+		if (ic->i_send_cq) {
+			if (ic->rds_ibdev)
+				ibdev_put_vector(ic->rds_ibdev, ic->i_scq_vector);
 			ib_destroy_cq(ic->i_send_cq);
-		if (ic->i_recv_cq)
+		}
+
+		if (ic->i_recv_cq) {
+			if (ic->rds_ibdev)
+				ibdev_put_vector(ic->rds_ibdev, ic->i_rcq_vector);
 			ib_destroy_cq(ic->i_recv_cq);
+		}
 
 		/* then free the resources that ib callbacks use */
 		if (ic->i_send_hdrs)
-- 
1.9.1
