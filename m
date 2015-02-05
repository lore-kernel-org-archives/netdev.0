From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/3] IB/mlx4_ib: Reset flow support for IB kernel ULPs
Date: Thu,  5 Feb 2015 15:52:46 +0200
Message-ID: <1423144366-11814-4-git-send-email-ogerlitz@mellanox.com>
References: <1423144366-11814-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39731 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753253AbbBENw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 08:52:57 -0500
In-Reply-To: <1423144366-11814-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

The driver exposes interfaces that directly relate to HW state. Upon fatal
error, consumers of these interfaces (ULPs) that rely on completion of
all their posted work-request could hang, thereby introducing dependencies
in shutdown order.  To prevent this from happening, we manage the
relevant resources (CQs, QPs) that are used by the device. Upon a fatal error,
we now generate simulated completions for outstanding WQEs that were not
completed at the time the HW was reset.

It includes invoking the completion event handler for all involved CQs so that
the ULPs will poll those CQs. When polled we return simulated CQEs with
IB_WC_WR_FLUSH_ERR return code enabling ULPs to clean up their resources and
not wait forever for completions upon receiving remove_one.

The above change requires an extra check in the data path to make sure that when
device is in error state, the simulated CQEs will be returned and no further
WQEs will be posted.

Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/cq.c      |   57 ++++++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx4/main.c    |   64 ++++++++++++++++++++++++++++++++++
 drivers/infiniband/hw/mlx4/mlx4_ib.h |    9 +++++
 drivers/infiniband/hw/mlx4/qp.c      |   59 ++++++++++++++++++++++++++++---
 drivers/infiniband/hw/mlx4/srq.c     |    8 ++++
 include/linux/mlx4/device.h          |    2 +
 6 files changed, 193 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/cq.c b/drivers/infiniband/hw/mlx4/cq.c
index a3b70f6..543ecdd 100644
--- a/drivers/infiniband/hw/mlx4/cq.c
+++ b/drivers/infiniband/hw/mlx4/cq.c
@@ -188,6 +188,8 @@ struct ib_cq *mlx4_ib_create_cq(struct ib_device *ibdev, int entries, int vector
 	spin_lock_init(&cq->lock);
 	cq->resize_buf = NULL;
 	cq->resize_umem = NULL;
+	INIT_LIST_HEAD(&cq->send_qp_list);
+	INIT_LIST_HEAD(&cq->recv_qp_list);
 
 	if (context) {
 		struct mlx4_ib_create_cq ucmd;
@@ -594,6 +596,55 @@ static int use_tunnel_data(struct mlx4_ib_qp *qp, struct mlx4_ib_cq *cq, struct
 	return 0;
 }
 
+static void mlx4_ib_qp_sw_comp(struct mlx4_ib_qp *qp, int num_entries,
+			       struct ib_wc *wc, int *npolled, int is_send)
+{
+	struct mlx4_ib_wq *wq;
+	unsigned cur;
+	int i;
+
+	wq = is_send ? &qp->sq : &qp->rq;
+	cur = wq->head - wq->tail;
+
+	if (cur == 0)
+		return;
+
+	for (i = 0;  i < cur && *npolled < num_entries; i++) {
+		wc->wr_id = wq->wrid[wq->tail & (wq->wqe_cnt - 1)];
+		wc->status = IB_WC_WR_FLUSH_ERR;
+		wc->vendor_err = MLX4_CQE_SYNDROME_WR_FLUSH_ERR;
+		wq->tail++;
+		(*npolled)++;
+		wc->qp = &qp->ibqp;
+		wc++;
+	}
+}
+
+static void mlx4_ib_poll_sw_comp(struct mlx4_ib_cq *cq, int num_entries,
+				 struct ib_wc *wc, int *npolled)
+{
+	struct mlx4_ib_qp *qp;
+
+	*npolled = 0;
+	/* Find uncompleted WQEs belonging to that cq and retrun
+	 * simulated FLUSH_ERR completions
+	 */
+	list_for_each_entry(qp, &cq->send_qp_list, cq_send_list) {
+		mlx4_ib_qp_sw_comp(qp, num_entries, wc, npolled, 1);
+		if (*npolled >= num_entries)
+			goto out;
+	}
+
+	list_for_each_entry(qp, &cq->recv_qp_list, cq_recv_list) {
+		mlx4_ib_qp_sw_comp(qp, num_entries, wc + *npolled, npolled, 0);
+		if (*npolled >= num_entries)
+			goto out;
+	}
+
+out:
+	return;
+}
+
 static int mlx4_ib_poll_one(struct mlx4_ib_cq *cq,
 			    struct mlx4_ib_qp **cur_qp,
 			    struct ib_wc *wc)
@@ -836,8 +887,13 @@ int mlx4_ib_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
 	unsigned long flags;
 	int npolled;
 	int err = 0;
+	struct mlx4_ib_dev *mdev = to_mdev(cq->ibcq.device);
 
 	spin_lock_irqsave(&cq->lock, flags);
+	if (mdev->dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR) {
+		mlx4_ib_poll_sw_comp(cq, num_entries, wc, &npolled);
+		goto out;
+	}
 
 	for (npolled = 0; npolled < num_entries; ++npolled) {
 		err = mlx4_ib_poll_one(cq, &cur_qp, wc + npolled);
@@ -847,6 +903,7 @@ int mlx4_ib_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
 
 	mlx4_cq_set_ci(&cq->mcq);
 
+out:
 	spin_unlock_irqrestore(&cq->lock, flags);
 
 	if (err == 0 || err == -EAGAIN)
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 271d3f1..66cb011 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -2308,6 +2308,8 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 
 	spin_lock_init(&ibdev->sm_lock);
 	mutex_init(&ibdev->cap_mask_mutex);
+	INIT_LIST_HEAD(&ibdev->qp_list);
+	spin_lock_init(&ibdev->reset_flow_resource_lock);
 
 	if (ibdev->steering_support == MLX4_STEERING_MODE_DEVICE_MANAGED &&
 	    ib_num_ports) {
@@ -2622,6 +2624,67 @@ out:
 	return;
 }
 
+static void mlx4_ib_handle_catas_error(struct mlx4_ib_dev *ibdev)
+{
+	struct mlx4_ib_qp *mqp;
+	unsigned long flags_qp;
+	unsigned long flags_cq;
+	struct mlx4_ib_cq *send_mcq, *recv_mcq;
+	struct list_head    cq_notify_list;
+	struct mlx4_cq *mcq;
+	unsigned long flags;
+
+	pr_warn("mlx4_ib_handle_catas_error was started\n");
+	INIT_LIST_HEAD(&cq_notify_list);
+
+	/* Go over qp list reside on that ibdev, sync with create/destroy qp.*/
+	spin_lock_irqsave(&ibdev->reset_flow_resource_lock, flags);
+
+	list_for_each_entry(mqp, &ibdev->qp_list, qps_list) {
+		spin_lock_irqsave(&mqp->sq.lock, flags_qp);
+		if (mqp->sq.tail != mqp->sq.head) {
+			send_mcq = to_mcq(mqp->ibqp.send_cq);
+			spin_lock_irqsave(&send_mcq->lock, flags_cq);
+			if (send_mcq->mcq.comp &&
+			    mqp->ibqp.send_cq->comp_handler) {
+				if (!send_mcq->mcq.reset_notify_added) {
+					send_mcq->mcq.reset_notify_added = 1;
+					list_add_tail(&send_mcq->mcq.reset_notify,
+						      &cq_notify_list);
+				}
+			}
+			spin_unlock_irqrestore(&send_mcq->lock, flags_cq);
+		}
+		spin_unlock_irqrestore(&mqp->sq.lock, flags_qp);
+		/* Now, handle the QP's receive queue */
+		spin_lock_irqsave(&mqp->rq.lock, flags_qp);
+		/* no handling is needed for SRQ */
+		if (!mqp->ibqp.srq) {
+			if (mqp->rq.tail != mqp->rq.head) {
+				recv_mcq = to_mcq(mqp->ibqp.recv_cq);
+				spin_lock_irqsave(&recv_mcq->lock, flags_cq);
+				if (recv_mcq->mcq.comp &&
+				    mqp->ibqp.recv_cq->comp_handler) {
+					if (!recv_mcq->mcq.reset_notify_added) {
+						recv_mcq->mcq.reset_notify_added = 1;
+						list_add_tail(&recv_mcq->mcq.reset_notify,
+							      &cq_notify_list);
+					}
+				}
+				spin_unlock_irqrestore(&recv_mcq->lock,
+						       flags_cq);
+			}
+		}
+		spin_unlock_irqrestore(&mqp->rq.lock, flags_qp);
+	}
+
+	list_for_each_entry(mcq, &cq_notify_list, reset_notify) {
+		mcq->comp(mcq);
+	}
+	spin_unlock_irqrestore(&ibdev->reset_flow_resource_lock, flags);
+	pr_warn("mlx4_ib_handle_catas_error ended\n");
+}
+
 static void handle_bonded_port_state_event(struct work_struct *work)
 {
 	struct ib_event_work *ew =
@@ -2701,6 +2764,7 @@ static void mlx4_ib_event(struct mlx4_dev *dev, void *ibdev_ptr,
 	case MLX4_DEV_EVENT_CATASTROPHIC_ERROR:
 		ibdev->ib_active = false;
 		ibev.event = IB_EVENT_DEVICE_FATAL;
+		mlx4_ib_handle_catas_error(ibdev);
 		break;
 
 	case MLX4_DEV_EVENT_PORT_MGMT_CHANGE:
diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw/mlx4/mlx4_ib.h
index 721540c..f829fd9 100644
--- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
+++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
@@ -110,6 +110,9 @@ struct mlx4_ib_cq {
 	struct mutex		resize_mutex;
 	struct ib_umem	       *umem;
 	struct ib_umem	       *resize_umem;
+	/* List of qps that it serves.*/
+	struct list_head		send_qp_list;
+	struct list_head		recv_qp_list;
 };
 
 struct mlx4_ib_mr {
@@ -300,6 +303,9 @@ struct mlx4_ib_qp {
 	struct mlx4_roce_smac_vlan_info pri;
 	struct mlx4_roce_smac_vlan_info alt;
 	u64			reg_id;
+	struct list_head	qps_list;
+	struct list_head	cq_recv_list;
+	struct list_head	cq_send_list;
 };
 
 struct mlx4_ib_srq {
@@ -535,6 +541,9 @@ struct mlx4_ib_dev {
 	/* lock when destroying qp1_proxy and getting netdev events */
 	struct mutex		qp1_proxy_lock[MLX4_MAX_PORTS];
 	u8			bond_next_port;
+	/* protect resources needed as part of reset flow */
+	spinlock_t		reset_flow_resource_lock;
+	struct list_head		qp_list;
 };
 
 struct ib_event_work {
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index 792f9dc..dfc6ca1 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -46,6 +46,11 @@
 #include "mlx4_ib.h"
 #include "user.h"
 
+static void mlx4_ib_lock_cqs(struct mlx4_ib_cq *send_cq,
+			     struct mlx4_ib_cq *recv_cq);
+static void mlx4_ib_unlock_cqs(struct mlx4_ib_cq *send_cq,
+			       struct mlx4_ib_cq *recv_cq);
+
 enum {
 	MLX4_IB_ACK_REQ_FREQ	= 8,
 };
@@ -618,6 +623,8 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 	struct mlx4_ib_sqp *sqp;
 	struct mlx4_ib_qp *qp;
 	enum mlx4_ib_qp_type qp_type = (enum mlx4_ib_qp_type) init_attr->qp_type;
+	struct mlx4_ib_cq *mcq;
+	unsigned long flags;
 
 	/* When tunneling special qps, we use a plain UD qp */
 	if (sqpn) {
@@ -828,6 +835,24 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 	qp->mqp.event = mlx4_ib_qp_event;
 	if (!*caller_qp)
 		*caller_qp = qp;
+
+	spin_lock_irqsave(&dev->reset_flow_resource_lock, flags);
+	mlx4_ib_lock_cqs(to_mcq(init_attr->send_cq),
+			 to_mcq(init_attr->recv_cq));
+	/* Maintain device to QPs access, needed for further handling
+	 * via reset flow
+	 */
+	list_add_tail(&qp->qps_list, &dev->qp_list);
+	/* Maintain CQ to QPs access, needed for further handling
+	 * via reset flow
+	 */
+	mcq = to_mcq(init_attr->send_cq);
+	list_add_tail(&qp->cq_send_list, &mcq->send_qp_list);
+	mcq = to_mcq(init_attr->recv_cq);
+	list_add_tail(&qp->cq_recv_list, &mcq->recv_qp_list);
+	mlx4_ib_unlock_cqs(to_mcq(init_attr->send_cq),
+			   to_mcq(init_attr->recv_cq));
+	spin_unlock_irqrestore(&dev->reset_flow_resource_lock, flags);
 	return 0;
 
 err_qpn:
@@ -886,13 +911,13 @@ static void mlx4_ib_lock_cqs(struct mlx4_ib_cq *send_cq, struct mlx4_ib_cq *recv
 	__acquires(&send_cq->lock) __acquires(&recv_cq->lock)
 {
 	if (send_cq == recv_cq) {
-		spin_lock_irq(&send_cq->lock);
+		spin_lock(&send_cq->lock);
 		__acquire(&recv_cq->lock);
 	} else if (send_cq->mcq.cqn < recv_cq->mcq.cqn) {
-		spin_lock_irq(&send_cq->lock);
+		spin_lock(&send_cq->lock);
 		spin_lock_nested(&recv_cq->lock, SINGLE_DEPTH_NESTING);
 	} else {
-		spin_lock_irq(&recv_cq->lock);
+		spin_lock(&recv_cq->lock);
 		spin_lock_nested(&send_cq->lock, SINGLE_DEPTH_NESTING);
 	}
 }
@@ -902,13 +927,13 @@ static void mlx4_ib_unlock_cqs(struct mlx4_ib_cq *send_cq, struct mlx4_ib_cq *re
 {
 	if (send_cq == recv_cq) {
 		__release(&recv_cq->lock);
-		spin_unlock_irq(&send_cq->lock);
+		spin_unlock(&send_cq->lock);
 	} else if (send_cq->mcq.cqn < recv_cq->mcq.cqn) {
 		spin_unlock(&recv_cq->lock);
-		spin_unlock_irq(&send_cq->lock);
+		spin_unlock(&send_cq->lock);
 	} else {
 		spin_unlock(&send_cq->lock);
-		spin_unlock_irq(&recv_cq->lock);
+		spin_unlock(&recv_cq->lock);
 	}
 }
 
@@ -953,6 +978,7 @@ static void destroy_qp_common(struct mlx4_ib_dev *dev, struct mlx4_ib_qp *qp,
 			      int is_user)
 {
 	struct mlx4_ib_cq *send_cq, *recv_cq;
+	unsigned long flags;
 
 	if (qp->state != IB_QPS_RESET) {
 		if (mlx4_qp_modify(dev->dev, NULL, to_mlx4_state(qp->state),
@@ -984,8 +1010,13 @@ static void destroy_qp_common(struct mlx4_ib_dev *dev, struct mlx4_ib_qp *qp,
 
 	get_cqs(qp, &send_cq, &recv_cq);
 
+	spin_lock_irqsave(&dev->reset_flow_resource_lock, flags);
 	mlx4_ib_lock_cqs(send_cq, recv_cq);
 
+	/* del from lists under both locks above to protect reset flow paths */
+	list_del(&qp->qps_list);
+	list_del(&qp->cq_send_list);
+	list_del(&qp->cq_recv_list);
 	if (!is_user) {
 		__mlx4_ib_cq_clean(recv_cq, qp->mqp.qpn,
 				 qp->ibqp.srq ? to_msrq(qp->ibqp.srq): NULL);
@@ -996,6 +1027,7 @@ static void destroy_qp_common(struct mlx4_ib_dev *dev, struct mlx4_ib_qp *qp,
 	mlx4_qp_remove(dev->dev, &qp->mqp);
 
 	mlx4_ib_unlock_cqs(send_cq, recv_cq);
+	spin_unlock_irqrestore(&dev->reset_flow_resource_lock, flags);
 
 	mlx4_qp_free(dev->dev, &qp->mqp);
 
@@ -2618,8 +2650,15 @@ int mlx4_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 	__be32 uninitialized_var(lso_hdr_sz);
 	__be32 blh;
 	int i;
+	struct mlx4_ib_dev *mdev = to_mdev(ibqp->device);
 
 	spin_lock_irqsave(&qp->sq.lock, flags);
+	if (mdev->dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR) {
+		err = -EIO;
+		*bad_wr = wr;
+		nreq = 0;
+		goto out;
+	}
 
 	ind = qp->sq_next_wqe;
 
@@ -2917,10 +2956,18 @@ int mlx4_ib_post_recv(struct ib_qp *ibqp, struct ib_recv_wr *wr,
 	int ind;
 	int max_gs;
 	int i;
+	struct mlx4_ib_dev *mdev = to_mdev(ibqp->device);
 
 	max_gs = qp->rq.max_gs;
 	spin_lock_irqsave(&qp->rq.lock, flags);
 
+	if (mdev->dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR) {
+		err = -EIO;
+		*bad_wr = wr;
+		nreq = 0;
+		goto out;
+	}
+
 	ind = qp->rq.head & (qp->rq.wqe_cnt - 1);
 
 	for (nreq = 0; wr; ++nreq, wr = wr->next) {
diff --git a/drivers/infiniband/hw/mlx4/srq.c b/drivers/infiniband/hw/mlx4/srq.c
index 62d9285..dce5dfe 100644
--- a/drivers/infiniband/hw/mlx4/srq.c
+++ b/drivers/infiniband/hw/mlx4/srq.c
@@ -316,8 +316,15 @@ int mlx4_ib_post_srq_recv(struct ib_srq *ibsrq, struct ib_recv_wr *wr,
 	int err = 0;
 	int nreq;
 	int i;
+	struct mlx4_ib_dev *mdev = to_mdev(ibsrq->device);
 
 	spin_lock_irqsave(&srq->lock, flags);
+	if (mdev->dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR) {
+		err = -EIO;
+		*bad_wr = wr;
+		nreq = 0;
+		goto out;
+	}
 
 	for (nreq = 0; wr; ++nreq, wr = wr->next) {
 		if (unlikely(wr->num_sge > srq->msrq.max_gs)) {
@@ -362,6 +369,7 @@ int mlx4_ib_post_srq_recv(struct ib_srq *ibsrq, struct ib_recv_wr *wr,
 
 		*srq->db.db = cpu_to_be32(srq->wqe_ctr);
 	}
+out:
 
 	spin_unlock_irqrestore(&srq->lock, flags);
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 977b0b1..e742201 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -689,6 +689,8 @@ struct mlx4_cq {
 		void (*comp)(struct mlx4_cq *);
 		void		*priv;
 	} tasklet_ctx;
+	int		reset_notify_added;
+	struct list_head	reset_notify;
 };
 
 struct mlx4_qp {
-- 
1.7.1
