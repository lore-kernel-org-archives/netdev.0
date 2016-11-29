From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH for-next 2/6] IB/hns: Fix the bug when free mr
Date: Tue, 29 Nov 2016 23:10:26 +0000
Message-ID: <20161129231030.1105600-3-salil.mehta@huawei.com>
References: <20161129231030.1105600-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161129231030.1105600-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shaobo Xu <xushaobo2@huawei.com>

If the resources of mr are freed while executing the user case, hardware
can not been notified in hip06 SoC. Then hardware will hold on when it
reads the payload by the PA which has been released.

In order to slove this problem, RoCE driver creates 8 reserved loopback
QPs to ensure zero wqe when free mr. When the mac address is reset, in
order to avoid loopback failure, we need to release the reserved loopback
QPs and recreate them.

Signed-off-by: Shaobo Xu <xushaobo2@huawei.com>
Reviewed-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_cmd.h    |    5 -
 drivers/infiniband/hw/hns/hns_roce_device.h |   10 +
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |  485 +++++++++++++++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |   34 ++
 drivers/infiniband/hw/hns/hns_roce_main.c   |    5 +-
 drivers/infiniband/hw/hns/hns_roce_mr.c     |   21 +-
 6 files changed, 545 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_cmd.h b/drivers/infiniband/hw/hns/hns_roce_cmd.h
index ed14ad3..f5a9ee2 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cmd.h
+++ b/drivers/infiniband/hw/hns/hns_roce_cmd.h
@@ -58,11 +58,6 @@ enum {
 	HNS_ROCE_CMD_QUERY_QP		= 0x22,
 };
 
-struct hns_roce_cmd_mailbox {
-	void		       *buf;
-	dma_addr_t		dma;
-};
-
 int hns_roce_cmd_mbox(struct hns_roce_dev *hr_dev, u64 in_param, u64 out_param,
 		      unsigned long in_modifier, u8 op_modifier, u16 op,
 		      unsigned long timeout);
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index e48464d..1050829 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -388,6 +388,11 @@ struct hns_roce_cmdq {
 	u8			toggle;
 };
 
+struct hns_roce_cmd_mailbox {
+	void		       *buf;
+	dma_addr_t		dma;
+};
+
 struct hns_roce_dev;
 
 struct hns_roce_qp {
@@ -522,6 +527,7 @@ struct hns_roce_hw {
 			 struct ib_recv_wr **bad_recv_wr);
 	int (*req_notify_cq)(struct ib_cq *ibcq, enum ib_cq_notify_flags flags);
 	int (*poll_cq)(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc);
+	int (*dereg_mr)(struct hns_roce_dev *hr_dev, struct hns_roce_mr *mr);
 	void	*priv;
 };
 
@@ -688,6 +694,10 @@ struct ib_mr *hns_roce_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 				   u64 virt_addr, int access_flags,
 				   struct ib_udata *udata);
 int hns_roce_dereg_mr(struct ib_mr *ibmr);
+int hns_roce_hw2sw_mpt(struct hns_roce_dev *hr_dev,
+		       struct hns_roce_cmd_mailbox *mailbox,
+		       unsigned long mpt_index);
+unsigned long key_to_hw_index(u32 key);
 
 void hns_roce_buf_free(struct hns_roce_dev *hr_dev, u32 size,
 		       struct hns_roce_buf *buf);
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index aee1d01..f67a3bf 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -295,6 +295,8 @@ int hns_roce_v1_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		roce_set_field(sq_db.u32_4, SQ_DOORBELL_U32_4_SQ_HEAD_M,
 			       SQ_DOORBELL_U32_4_SQ_HEAD_S,
 			      (qp->sq.head & ((qp->sq.wqe_cnt << 1) - 1)));
+		roce_set_field(sq_db.u32_4, SQ_DOORBELL_U32_4_SL_M,
+			       SQ_DOORBELL_U32_4_SL_S, qp->sl);
 		roce_set_field(sq_db.u32_4, SQ_DOORBELL_U32_4_PORT_M,
 			       SQ_DOORBELL_U32_4_PORT_S, qp->phy_port);
 		roce_set_field(sq_db.u32_8, SQ_DOORBELL_U32_8_QPN_M,
@@ -622,6 +624,213 @@ static int hns_roce_db_ext_init(struct hns_roce_dev *hr_dev, u32 sdb_ext_mod,
 	return ret;
 }
 
+static struct hns_roce_qp *hns_roce_v1_create_lp_qp(struct hns_roce_dev *hr_dev,
+						    struct ib_pd *pd)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct ib_qp_init_attr init_attr;
+	struct ib_qp *qp;
+
+	memset(&init_attr, 0, sizeof(struct ib_qp_init_attr));
+	init_attr.qp_type		= IB_QPT_RC;
+	init_attr.sq_sig_type		= IB_SIGNAL_ALL_WR;
+	init_attr.cap.max_recv_wr	= HNS_ROCE_MIN_WQE_NUM;
+	init_attr.cap.max_send_wr	= HNS_ROCE_MIN_WQE_NUM;
+
+	qp = hns_roce_create_qp(pd, &init_attr, NULL);
+	if (IS_ERR(qp)) {
+		dev_err(dev, "Create loop qp for mr free failed!");
+		return NULL;
+	}
+
+	return to_hr_qp(qp);
+}
+
+static int hns_roce_v1_rsv_lp_qp(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_caps *caps = &hr_dev->caps;
+	struct device *dev = &hr_dev->pdev->dev;
+	struct ib_cq_init_attr cq_init_attr;
+	struct hns_roce_free_mr *free_mr;
+	struct ib_qp_attr attr = { 0 };
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_qp *hr_qp;
+	struct ib_cq *cq;
+	struct ib_pd *pd;
+	u64 subnet_prefix;
+	int attr_mask = 0;
+	int i;
+	int ret;
+	u8 phy_port;
+	u8 sl;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	free_mr = &priv->free_mr;
+
+	/* Reserved cq for loop qp */
+	cq_init_attr.cqe		= HNS_ROCE_MIN_WQE_NUM * 2;
+	cq_init_attr.comp_vector	= 0;
+	cq = hns_roce_ib_create_cq(&hr_dev->ib_dev, &cq_init_attr, NULL, NULL);
+	if (IS_ERR(cq)) {
+		dev_err(dev, "Create cq for reseved loop qp failed!");
+		return -ENOMEM;
+	}
+	free_mr->mr_free_cq = to_hr_cq(cq);
+	free_mr->mr_free_cq->ib_cq.device		= &hr_dev->ib_dev;
+	free_mr->mr_free_cq->ib_cq.uobject		= NULL;
+	free_mr->mr_free_cq->ib_cq.comp_handler		= NULL;
+	free_mr->mr_free_cq->ib_cq.event_handler	= NULL;
+	free_mr->mr_free_cq->ib_cq.cq_context		= NULL;
+	atomic_set(&free_mr->mr_free_cq->ib_cq.usecnt, 0);
+
+	pd = hns_roce_alloc_pd(&hr_dev->ib_dev, NULL, NULL);
+	if (IS_ERR(pd)) {
+		dev_err(dev, "Create pd for reseved loop qp failed!");
+		ret = -ENOMEM;
+		goto alloc_pd_failed;
+	}
+	free_mr->mr_free_pd = to_hr_pd(pd);
+	free_mr->mr_free_pd->ibpd.device  = &hr_dev->ib_dev;
+	free_mr->mr_free_pd->ibpd.uobject = NULL;
+	atomic_set(&free_mr->mr_free_pd->ibpd.usecnt, 0);
+
+	attr.qp_access_flags	= IB_ACCESS_REMOTE_WRITE;
+	attr.pkey_index		= 0;
+	attr.min_rnr_timer	= 0;
+	/* Disable read ability */
+	attr.max_dest_rd_atomic = 0;
+	attr.max_rd_atomic	= 0;
+	/* Use arbitrary values as rq_psn and sq_psn */
+	attr.rq_psn		= 0x0808;
+	attr.sq_psn		= 0x0808;
+	attr.retry_cnt		= 7;
+	attr.rnr_retry		= 7;
+	attr.timeout		= 0x12;
+	attr.path_mtu		= IB_MTU_256;
+	attr.ah_attr.ah_flags		= 1;
+	attr.ah_attr.static_rate	= 3;
+	attr.ah_attr.grh.sgid_index	= 0;
+	attr.ah_attr.grh.hop_limit	= 1;
+	attr.ah_attr.grh.flow_label	= 0;
+	attr.ah_attr.grh.traffic_class	= 0;
+
+	subnet_prefix = cpu_to_be64(0xfe80000000000000LL);
+	for (i = 0; i < HNS_ROCE_V1_RESV_QP; i++) {
+		free_mr->mr_free_qp[i] = hns_roce_v1_create_lp_qp(hr_dev, pd);
+		if (IS_ERR(free_mr->mr_free_qp[i])) {
+			dev_err(dev, "Create loop qp failed!\n");
+			goto create_lp_qp_failed;
+		}
+		hr_qp = free_mr->mr_free_qp[i];
+
+		sl = i / caps->num_ports;
+
+		if (caps->num_ports == HNS_ROCE_MAX_PORTS)
+			phy_port = (i >= HNS_ROCE_MAX_PORTS) ? (i - 2) :
+				(i % caps->num_ports);
+		else
+			phy_port = i % caps->num_ports;
+
+		hr_qp->port		= phy_port + 1;
+		hr_qp->phy_port		= phy_port;
+		hr_qp->ibqp.qp_type	= IB_QPT_RC;
+		hr_qp->ibqp.device	= &hr_dev->ib_dev;
+		hr_qp->ibqp.uobject	= NULL;
+		atomic_set(&hr_qp->ibqp.usecnt, 0);
+		hr_qp->ibqp.pd		= pd;
+		hr_qp->ibqp.recv_cq	= cq;
+		hr_qp->ibqp.send_cq	= cq;
+
+		attr.ah_attr.port_num	= phy_port + 1;
+		attr.ah_attr.sl		= sl;
+		attr.port_num		= phy_port + 1;
+
+		attr.dest_qp_num	= hr_qp->qpn;
+		memcpy(attr.ah_attr.dmac, hr_dev->dev_addr[phy_port],
+		       MAC_ADDR_OCTET_NUM);
+
+		memcpy(attr.ah_attr.grh.dgid.raw,
+			&subnet_prefix, sizeof(u64));
+		memcpy(&attr.ah_attr.grh.dgid.raw[8],
+		       hr_dev->dev_addr[phy_port], 3);
+		memcpy(&attr.ah_attr.grh.dgid.raw[13],
+		       hr_dev->dev_addr[phy_port] + 3, 3);
+		attr.ah_attr.grh.dgid.raw[11] = 0xff;
+		attr.ah_attr.grh.dgid.raw[12] = 0xfe;
+		attr.ah_attr.grh.dgid.raw[8] ^= 2;
+
+		attr_mask |= IB_QP_PORT;
+
+		ret = hr_dev->hw->modify_qp(&hr_qp->ibqp, &attr, attr_mask,
+					    IB_QPS_RESET, IB_QPS_INIT);
+		if (ret) {
+			dev_err(dev, "modify qp failed(%d)!\n", ret);
+			goto create_lp_qp_failed;
+		}
+
+		ret = hr_dev->hw->modify_qp(&hr_qp->ibqp, &attr, attr_mask,
+					    IB_QPS_INIT, IB_QPS_RTR);
+		if (ret) {
+			dev_err(dev, "modify qp failed(%d)!\n", ret);
+			goto create_lp_qp_failed;
+		}
+
+		ret = hr_dev->hw->modify_qp(&hr_qp->ibqp, &attr, attr_mask,
+					    IB_QPS_RTR, IB_QPS_RTS);
+		if (ret) {
+			dev_err(dev, "modify qp failed(%d)!\n", ret);
+			goto create_lp_qp_failed;
+		}
+	}
+
+	return 0;
+
+create_lp_qp_failed:
+	for (i -= 1; i >= 0; i--) {
+		hr_qp = free_mr->mr_free_qp[i];
+		if (hns_roce_v1_destroy_qp(&hr_qp->ibqp))
+			dev_err(dev, "Destroy qp %d for mr free failed!\n", i);
+	}
+
+	if (hns_roce_dealloc_pd(pd))
+		dev_err(dev, "Destroy pd for create_lp_qp failed!\n");
+
+alloc_pd_failed:
+	if (hns_roce_ib_destroy_cq(cq))
+		dev_err(dev, "Destroy cq for create_lp_qp failed!\n");
+
+	return -EINVAL;
+}
+
+static void hns_roce_v1_release_lp_qp(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_free_mr *free_mr;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_qp *hr_qp;
+	int ret;
+	int i;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	free_mr = &priv->free_mr;
+
+	for (i = 0; i < HNS_ROCE_V1_RESV_QP; i++) {
+		hr_qp = free_mr->mr_free_qp[i];
+		ret = hns_roce_v1_destroy_qp(&hr_qp->ibqp);
+		if (ret)
+			dev_err(dev, "Destroy qp %d for mr free failed(%d)!\n",
+				i, ret);
+	}
+
+	ret = hns_roce_ib_destroy_cq(&free_mr->mr_free_cq->ib_cq);
+	if (ret)
+		dev_err(dev, "Destroy cq for mr_free failed(%d)!\n", ret);
+
+	ret = hns_roce_dealloc_pd(&free_mr->mr_free_pd->ibpd);
+	if (ret)
+		dev_err(dev, "Destroy pd for mr_free failed(%d)!\n", ret);
+}
+
 static int hns_roce_db_init(struct hns_roce_dev *hr_dev)
 {
 	struct device *dev = &hr_dev->pdev->dev;
@@ -659,6 +868,223 @@ static int hns_roce_db_init(struct hns_roce_dev *hr_dev)
 	return 0;
 }
 
+void hns_roce_v1_recreate_lp_qp_work_fn(struct work_struct *work)
+{
+	struct hns_roce_recreate_lp_qp_work *lp_qp_work;
+	struct hns_roce_dev *hr_dev;
+
+	lp_qp_work = container_of(work, struct hns_roce_recreate_lp_qp_work,
+				  work);
+	hr_dev = to_hr_dev(lp_qp_work->ib_dev);
+
+	hns_roce_v1_release_lp_qp(hr_dev);
+
+	if (hns_roce_v1_rsv_lp_qp(hr_dev))
+		dev_err(&hr_dev->pdev->dev, "create reserver qp failed\n");
+
+	if (lp_qp_work->comp_flag)
+		complete(lp_qp_work->comp);
+
+	kfree(lp_qp_work);
+}
+
+static int hns_roce_v1_recreate_lp_qp(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_recreate_lp_qp_work *lp_qp_work;
+	struct hns_roce_free_mr *free_mr;
+	struct hns_roce_v1_priv *priv;
+	struct completion comp;
+	unsigned long end =
+	  msecs_to_jiffies(HNS_ROCE_V1_RECREATE_LP_QP_TIMEOUT_MSECS) + jiffies;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	free_mr = &priv->free_mr;
+
+	lp_qp_work = kzalloc(sizeof(struct hns_roce_recreate_lp_qp_work),
+			     GFP_KERNEL);
+
+	INIT_WORK(&(lp_qp_work->work), hns_roce_v1_recreate_lp_qp_work_fn);
+
+	lp_qp_work->ib_dev = &(hr_dev->ib_dev);
+	lp_qp_work->comp = &comp;
+	lp_qp_work->comp_flag = 1;
+
+	init_completion(lp_qp_work->comp);
+
+	queue_work(free_mr->free_mr_wq, &(lp_qp_work->work));
+
+	while (time_before_eq(jiffies, end)) {
+		if (try_wait_for_completion(&comp))
+			return 0;
+		msleep(HNS_ROCE_V1_RECREATE_LP_QP_WAIT_VALUE);
+	}
+
+	lp_qp_work->comp_flag = 0;
+	if (try_wait_for_completion(&comp))
+		return 0;
+
+	dev_warn(dev, "recreate lp qp failed 20s timeout and return failed!\n");
+	return -ETIMEDOUT;
+}
+
+static int hns_roce_v1_send_lp_wqe(struct hns_roce_qp *hr_qp)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(hr_qp->ibqp.device);
+	struct device *dev = &hr_dev->pdev->dev;
+	struct ib_send_wr send_wr, *bad_wr;
+	int ret;
+
+	memset(&send_wr, 0, sizeof(send_wr));
+	send_wr.next	= NULL;
+	send_wr.num_sge	= 0;
+	send_wr.send_flags = 0;
+	send_wr.sg_list	= NULL;
+	send_wr.wr_id	= (unsigned long long)&send_wr;
+	send_wr.opcode	= IB_WR_RDMA_WRITE;
+
+	ret = hns_roce_v1_post_send(&hr_qp->ibqp, &send_wr, &bad_wr);
+	if (ret) {
+		dev_err(dev, "Post write wqe for mr free failed(%d)!", ret);
+		return ret;
+	}
+
+	return 0;
+}
+
+static void hns_roce_v1_mr_free_work_fn(struct work_struct *work)
+{
+	struct hns_roce_mr_free_work *mr_work;
+	struct ib_wc wc[HNS_ROCE_V1_RESV_QP];
+	struct hns_roce_free_mr *free_mr;
+	struct hns_roce_cq *mr_free_cq;
+	struct hns_roce_v1_priv *priv;
+	struct hns_roce_dev *hr_dev;
+	struct hns_roce_mr *hr_mr;
+	struct hns_roce_qp *hr_qp;
+	struct device *dev;
+	unsigned long end =
+		msecs_to_jiffies(HNS_ROCE_V1_FREE_MR_TIMEOUT_MSECS) + jiffies;
+	int i;
+	int ret;
+	int ne;
+
+	mr_work = container_of(work, struct hns_roce_mr_free_work, work);
+	hr_mr = (struct hns_roce_mr *)mr_work->mr;
+	hr_dev = to_hr_dev(mr_work->ib_dev);
+	dev = &hr_dev->pdev->dev;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	free_mr = &priv->free_mr;
+	mr_free_cq = free_mr->mr_free_cq;
+
+	for (i = 0; i < HNS_ROCE_V1_RESV_QP; i++) {
+		hr_qp = free_mr->mr_free_qp[i];
+		ret = hns_roce_v1_send_lp_wqe(hr_qp);
+		if (ret) {
+			dev_err(dev,
+			     "Send wqe (qp:0x%lx) for mr free failed(%d)!\n",
+			     hr_qp->qpn, ret);
+			goto free_work;
+		}
+	}
+
+	ne = HNS_ROCE_V1_RESV_QP;
+	do {
+		ret = hns_roce_v1_poll_cq(&mr_free_cq->ib_cq, ne, wc);
+		if (ret < 0) {
+			dev_err(dev,
+			   "(qp:0x%lx) starts, Poll cqe failed(%d) for mr 0x%x free! Remain %d cqe\n",
+			   hr_qp->qpn, ret, hr_mr->key, ne);
+			goto free_work;
+		}
+		ne -= ret;
+		msleep(HNS_ROCE_V1_FREE_MR_WAIT_VALUE);
+	} while (ne && time_before_eq(jiffies, end));
+
+	if (ne != 0)
+		dev_err(dev,
+			"Poll cqe for mr 0x%x free timeout! Remain %d cqe\n",
+			hr_mr->key, ne);
+
+free_work:
+	if (mr_work->comp_flag)
+		complete(mr_work->comp);
+	kfree(mr_work);
+}
+
+int hns_roce_v1_dereg_mr(struct hns_roce_dev *hr_dev, struct hns_roce_mr *mr)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_mr_free_work *mr_work;
+	struct hns_roce_free_mr *free_mr;
+	struct hns_roce_v1_priv *priv;
+	struct completion comp;
+	unsigned long end =
+		msecs_to_jiffies(HNS_ROCE_V1_FREE_MR_TIMEOUT_MSECS) + jiffies;
+	unsigned long start = jiffies;
+	int npages;
+	int ret = 0;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	free_mr = &priv->free_mr;
+
+	if (mr->enabled) {
+		if (hns_roce_hw2sw_mpt(hr_dev, NULL, key_to_hw_index(mr->key)
+				       & (hr_dev->caps.num_mtpts - 1)))
+			dev_warn(dev, "HW2SW_MPT failed!\n");
+	}
+
+	mr_work = kzalloc(sizeof(*mr_work), GFP_KERNEL);
+	if (!mr_work) {
+		ret = -ENOMEM;
+		goto free_mr;
+	}
+
+	INIT_WORK(&(mr_work->work), hns_roce_v1_mr_free_work_fn);
+
+	mr_work->ib_dev = &(hr_dev->ib_dev);
+	mr_work->comp = &comp;
+	mr_work->comp_flag = 1;
+	mr_work->mr = (void *)mr;
+	init_completion(mr_work->comp);
+
+	queue_work(free_mr->free_mr_wq, &(mr_work->work));
+
+	while (time_before_eq(jiffies, end)) {
+		if (try_wait_for_completion(&comp))
+			goto free_mr;
+		msleep(HNS_ROCE_V1_FREE_MR_WAIT_VALUE);
+	}
+
+	mr_work->comp_flag = 0;
+	if (try_wait_for_completion(&comp))
+		goto free_mr;
+
+	dev_warn(dev, "Free mr work 0x%x over 50s and failed!\n", mr->key);
+	ret = -ETIMEDOUT;
+
+free_mr:
+	dev_dbg(dev, "Free mr 0x%x use 0x%x us.\n",
+		mr->key, jiffies_to_usecs(jiffies) - jiffies_to_usecs(start));
+
+	if (mr->size != ~0ULL) {
+		npages = ib_umem_page_count(mr->umem);
+		dma_free_coherent(dev, npages * 8, mr->pbl_buf,
+				  mr->pbl_dma_addr);
+	}
+
+	hns_roce_bitmap_free(&hr_dev->mr_table.mtpt_bitmap,
+			     key_to_hw_index(mr->key), 0);
+
+	if (mr->umem)
+		ib_umem_release(mr->umem);
+
+	kfree(mr);
+
+	return ret;
+}
+
 static void hns_roce_db_free(struct hns_roce_dev *hr_dev)
 {
 	struct device *dev = &hr_dev->pdev->dev;
@@ -899,6 +1325,46 @@ static void hns_roce_tptr_free(struct hns_roce_dev *hr_dev)
 			  tptr_buf->buf, tptr_buf->map);
 }
 
+static int hns_roce_free_mr_init(struct hns_roce_dev *hr_dev)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct hns_roce_free_mr *free_mr;
+	struct hns_roce_v1_priv *priv;
+	int ret = 0;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	free_mr = &priv->free_mr;
+
+	free_mr->free_mr_wq = create_singlethread_workqueue("hns_roce_free_mr");
+	if (!free_mr->free_mr_wq) {
+		dev_err(dev, "Create free mr workqueue failed!\n");
+		return -ENOMEM;
+	}
+
+	ret = hns_roce_v1_rsv_lp_qp(hr_dev);
+	if (ret) {
+		dev_err(dev, "Reserved loop qp failed(%d)!\n", ret);
+		flush_workqueue(free_mr->free_mr_wq);
+		destroy_workqueue(free_mr->free_mr_wq);
+	}
+
+	return ret;
+}
+
+static void hns_roce_free_mr_free(struct hns_roce_dev *hr_dev)
+{
+	struct hns_roce_free_mr *free_mr;
+	struct hns_roce_v1_priv *priv;
+
+	priv = (struct hns_roce_v1_priv *)hr_dev->hw->priv;
+	free_mr = &priv->free_mr;
+
+	flush_workqueue(free_mr->free_mr_wq);
+	destroy_workqueue(free_mr->free_mr_wq);
+
+	hns_roce_v1_release_lp_qp(hr_dev);
+}
+
 /**
  * hns_roce_v1_reset - reset RoCE
  * @hr_dev: RoCE device struct pointer
@@ -1100,10 +1566,19 @@ int hns_roce_v1_init(struct hns_roce_dev *hr_dev)
 		goto error_failed_des_qp_init;
 	}
 
+	ret = hns_roce_free_mr_init(hr_dev);
+	if (ret) {
+		dev_err(dev, "free mr init failed!\n");
+		goto error_failed_free_mr_init;
+	}
+
 	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_UP);
 
 	return 0;
 
+error_failed_free_mr_init:
+	hns_roce_des_qp_free(hr_dev);
+
 error_failed_des_qp_init:
 	hns_roce_tptr_free(hr_dev);
 
@@ -1121,6 +1596,7 @@ int hns_roce_v1_init(struct hns_roce_dev *hr_dev)
 void hns_roce_v1_exit(struct hns_roce_dev *hr_dev)
 {
 	hns_roce_port_enable(hr_dev, HNS_ROCE_PORT_DOWN);
+	hns_roce_free_mr_free(hr_dev);
 	hns_roce_des_qp_free(hr_dev);
 	hns_roce_tptr_free(hr_dev);
 	hns_roce_bt_free(hr_dev);
@@ -1161,6 +1637,14 @@ void hns_roce_v1_set_mac(struct hns_roce_dev *hr_dev, u8 phy_port, u8 *addr)
 	u32 *p;
 	u32 val;
 
+	/*
+	 * When mac changed, loopback may fail
+	 * because of smac not equal to dmac.
+	 * We Need to release and create reserved qp again.
+	 */
+	if (hr_dev->hw->dereg_mr && hns_roce_v1_recreate_lp_qp(hr_dev))
+		dev_warn(&hr_dev->pdev->dev, "recreate lp qp timeout!\n");
+
 	p = (u32 *)(&addr[0]);
 	reg_smac_l = *p;
 	roce_raw_write(reg_smac_l, hr_dev->reg_base + ROCEE_SMAC_L_0_REG +
@@ -3299,5 +3783,6 @@ struct hns_roce_hw hns_roce_hw_v1 = {
 	.post_recv = hns_roce_v1_post_recv,
 	.req_notify_cq = hns_roce_v1_req_notify_cq,
 	.poll_cq = hns_roce_v1_poll_cq,
+	.dereg_mr = hns_roce_v1_dereg_mr,
 	.priv = &hr_v1_priv,
 };
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index 1d250c0..b213b5e 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -58,6 +58,7 @@
 #define HNS_ROCE_V1_PHY_UAR_NUM				8
 
 #define HNS_ROCE_V1_GID_NUM				16
+#define HNS_ROCE_V1_RESV_QP				8
 
 #define HNS_ROCE_V1_NUM_COMP_EQE			0x8000
 #define HNS_ROCE_V1_NUM_ASYNC_EQE			0x400
@@ -107,6 +108,10 @@
 #define HNS_ROCE_V1_DB_STAGE2				2
 #define HNS_ROCE_V1_CHECK_DB_TIMEOUT_MSECS		10000
 #define HNS_ROCE_V1_CHECK_DB_SLEEP_MSECS		20
+#define HNS_ROCE_V1_FREE_MR_TIMEOUT_MSECS		50000
+#define HNS_ROCE_V1_RECREATE_LP_QP_TIMEOUT_MSECS	10000
+#define HNS_ROCE_V1_FREE_MR_WAIT_VALUE			5
+#define HNS_ROCE_V1_RECREATE_LP_QP_WAIT_VALUE		20
 
 #define HNS_ROCE_BT_RSV_BUF_SIZE			(1 << 17)
 
@@ -969,6 +974,10 @@ struct hns_roce_sq_db {
 #define SQ_DOORBELL_U32_4_SQ_HEAD_M   \
 	(((1UL << 15) - 1) << SQ_DOORBELL_U32_4_SQ_HEAD_S)
 
+#define SQ_DOORBELL_U32_4_SL_S 16
+#define SQ_DOORBELL_U32_4_SL_M   \
+	(((1UL << 2) - 1) << SQ_DOORBELL_U32_4_SL_S)
+
 #define SQ_DOORBELL_U32_4_PORT_S 18
 #define SQ_DOORBELL_U32_4_PORT_M  (((1UL << 3) - 1) << SQ_DOORBELL_U32_4_PORT_S)
 
@@ -1015,14 +1024,39 @@ struct hns_roce_des_qp {
 	int	requeue_flag;
 };
 
+struct hns_roce_mr_free_work {
+	struct	work_struct work;
+	struct	ib_device *ib_dev;
+	struct	completion *comp;
+	int	comp_flag;
+	void	*mr;
+};
+
+struct hns_roce_recreate_lp_qp_work {
+	struct	work_struct work;
+	struct	ib_device *ib_dev;
+	struct	completion *comp;
+	int	comp_flag;
+};
+
+struct hns_roce_free_mr {
+	struct workqueue_struct *free_mr_wq;
+	struct hns_roce_qp *mr_free_qp[HNS_ROCE_V1_RESV_QP];
+	struct hns_roce_cq *mr_free_cq;
+	struct hns_roce_pd *mr_free_pd;
+};
+
 struct hns_roce_v1_priv {
 	struct hns_roce_db_table  db_table;
 	struct hns_roce_raq_table raq_table;
 	struct hns_roce_bt_table  bt_table;
 	struct hns_roce_tptr_table tptr_table;
 	struct hns_roce_des_qp des_qp;
+	struct hns_roce_free_mr free_mr;
 };
 
 int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool dereset);
+int hns_roce_v1_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc);
+int hns_roce_v1_destroy_qp(struct ib_qp *ibqp);
 
 #endif
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 914d0ac..0cedec0 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -129,7 +129,6 @@ static int handle_en_event(struct hns_roce_dev *hr_dev, u8 port,
 {
 	struct device *dev = &hr_dev->pdev->dev;
 	struct net_device *netdev;
-	unsigned long flags;
 
 	netdev = hr_dev->iboe.netdevs[port];
 	if (!netdev) {
@@ -137,7 +136,7 @@ static int handle_en_event(struct hns_roce_dev *hr_dev, u8 port,
 		return -ENODEV;
 	}
 
-	spin_lock_irqsave(&hr_dev->iboe.lock, flags);
+	spin_lock_bh(&hr_dev->iboe.lock);
 
 	switch (event) {
 	case NETDEV_UP:
@@ -156,7 +155,7 @@ static int handle_en_event(struct hns_roce_dev *hr_dev, u8 port,
 		break;
 	}
 
-	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+	spin_unlock_bh(&hr_dev->iboe.lock);
 	return 0;
 }
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
index 9b8a1ad..4139abe 100644
--- a/drivers/infiniband/hw/hns/hns_roce_mr.c
+++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
@@ -42,7 +42,7 @@ static u32 hw_index_to_key(unsigned long ind)
 	return (u32)(ind >> 24) | (ind << 8);
 }
 
-static unsigned long key_to_hw_index(u32 key)
+unsigned long key_to_hw_index(u32 key)
 {
 	return (key << 24) | (key >> 8);
 }
@@ -56,7 +56,7 @@ static int hns_roce_sw2hw_mpt(struct hns_roce_dev *hr_dev,
 				 HNS_ROCE_CMD_TIMEOUT_MSECS);
 }
 
-static int hns_roce_hw2sw_mpt(struct hns_roce_dev *hr_dev,
+int hns_roce_hw2sw_mpt(struct hns_roce_dev *hr_dev,
 			      struct hns_roce_cmd_mailbox *mailbox,
 			      unsigned long mpt_index)
 {
@@ -607,13 +607,20 @@ struct ib_mr *hns_roce_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 
 int hns_roce_dereg_mr(struct ib_mr *ibmr)
 {
+	struct hns_roce_dev *hr_dev = to_hr_dev(ibmr->device);
 	struct hns_roce_mr *mr = to_hr_mr(ibmr);
+	int ret = 0;
 
-	hns_roce_mr_free(to_hr_dev(ibmr->device), mr);
-	if (mr->umem)
-		ib_umem_release(mr->umem);
+	if (hr_dev->hw->dereg_mr) {
+		ret = hr_dev->hw->dereg_mr(hr_dev, mr);
+	} else {
+		hns_roce_mr_free(hr_dev, mr);
 
-	kfree(mr);
+		if (mr->umem)
+			ib_umem_release(mr->umem);
 
-	return 0;
+		kfree(mr);
+	}
+
+	return ret;
 }
-- 
1.7.9.5
