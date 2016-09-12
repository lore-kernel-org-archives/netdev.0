From: Ram Amrani <Ram.Amrani@qlogic.com>
Subject: [RFC 11/11] Add events support and register IB device
Date: Mon, 12 Sep 2016 19:07:45 +0300
Message-ID: <1473696465-27986-12-git-send-email-Ram.Amrani@qlogic.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Yuval.Mintz@qlogic.com>, <Ariel.Elior@qlogic.com>,
        <Michal.Kalderon@qlogic.com>, <rajesh.borundia@qlogic.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        Ram Amrani <Ram.Amrani@qlogic.com>
To: <dledford@redhat.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:42034 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752243AbcILQIw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 12:08:52 -0400
In-Reply-To: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add error handling support.
Register ib device with ib stack.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Ram Amrani <Ram.Amrani@qlogic.com>
---
 drivers/infiniband/hw/qedr/main.c  | 107 ++++++++++++++++++++++++++++++++++++-
 drivers/infiniband/hw/qedr/verbs.c |  37 +++++++++++++
 drivers/infiniband/hw/qedr/verbs.h |   9 ++++
 include/linux/qed/common_hsi.h     |   1 +
 4 files changed, 152 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index fb0b76c..242f31d 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -86,10 +86,25 @@ static void qedr_get_dev_fw_str(struct ib_device *ibdev, char *str,
 		 (fw_ver >> 8) & 0xFF, fw_ver & 0xFF);
 }
 
+static struct net_device *qedr_get_netdev(struct ib_device *dev, u8 port_num)
+{
+	struct qedr_dev *qdev;
+
+	qdev = get_qedr_dev(dev);
+	dev_hold(qdev->ndev);
+
+	/* The HW vendor's device driver must guarantee
+	 * that this function returns NULL before the net device reaches
+	 * NETDEV_UNREGISTER_FINAL state.
+	 */
+	return qdev->ndev;
+}
+
 static int qedr_register_device(struct qedr_dev *dev)
 {
 	strlcpy(dev->ibdev.name, "qedr%d", IB_DEVICE_NAME_MAX);
 
+	dev->ibdev.node_guid = dev->attr.node_guid;
 	memcpy(dev->ibdev.node_desc, QEDR_NODE_DESC, sizeof(QEDR_NODE_DESC));
 	dev->ibdev.owner = THIS_MODULE;
 	dev->ibdev.uverbs_abi_ver = QEDR_ABI_VERSION;
@@ -156,11 +171,15 @@ static int qedr_register_device(struct qedr_dev *dev)
 	dev->ibdev.post_send = qedr_post_send;
 	dev->ibdev.post_recv = qedr_post_recv;
 
+	dev->ibdev.process_mad = qedr_process_mad;
+	dev->ibdev.get_port_immutable = qedr_port_immutable;
+	dev->ibdev.get_netdev = qedr_get_netdev;
+
 	dev->ibdev.dma_device = &dev->pdev->dev;
 	dev->ibdev.get_link_layer = qedr_link_layer;
 	dev->ibdev.get_dev_fw_str = qedr_get_dev_fw_str;
 
-	return 0;
+	return ib_register_device(&dev->ibdev, NULL);
 }
 
 /* This function allocates fast-path status block memory */
@@ -548,6 +567,86 @@ static int qedr_set_device_attr(struct qedr_dev *dev)
 	return 0;
 }
 
+void qedr_affiliated_event(void *context, u8 e_code, void *fw_handle)
+{
+#define EVENT_TYPE_NOT_DEFINED	0
+#define EVENT_TYPE_CQ		1
+#define EVENT_TYPE_QP		2
+	struct qedr_dev *dev = (struct qedr_dev *)context;
+	union event_ring_data *data = fw_handle;
+	u64 roce_handle64 = ((u64)data->roce_handle.hi << 32) +
+			    data->roce_handle.lo;
+	u8 event_type = EVENT_TYPE_NOT_DEFINED;
+	struct ib_event event;
+	struct ib_cq *ibcq;
+	struct ib_qp *ibqp;
+	struct qedr_cq *cq;
+	struct qedr_qp *qp;
+
+	switch (e_code) {
+	case ROCE_ASYNC_EVENT_CQ_OVERFLOW_ERR:
+		event.event = IB_EVENT_CQ_ERR;
+		event_type = EVENT_TYPE_CQ;
+		break;
+	case ROCE_ASYNC_EVENT_SQ_DRAINED:
+		event.event = IB_EVENT_SQ_DRAINED;
+		event_type = EVENT_TYPE_QP;
+		break;
+	case ROCE_ASYNC_EVENT_QP_CATASTROPHIC_ERR:
+		event.event = IB_EVENT_QP_FATAL;
+		event_type = EVENT_TYPE_QP;
+		break;
+	case ROCE_ASYNC_EVENT_LOCAL_INVALID_REQUEST_ERR:
+		event.event = IB_EVENT_QP_REQ_ERR;
+		event_type = EVENT_TYPE_QP;
+		break;
+	case ROCE_ASYNC_EVENT_LOCAL_ACCESS_ERR:
+		event.event = IB_EVENT_QP_ACCESS_ERR;
+		event_type = EVENT_TYPE_QP;
+		break;
+	default:
+		DP_ERR(dev, "unsupported event %d on handle=%llx\n", e_code,
+		       roce_handle64);
+	}
+
+	switch (event_type) {
+	case EVENT_TYPE_CQ:
+		cq = (struct qedr_cq *)(uintptr_t)roce_handle64;
+		if (cq) {
+			ibcq = &cq->ibcq;
+			if (ibcq->event_handler) {
+				event.device = ibcq->device;
+				event.element.cq = ibcq;
+				ibcq->event_handler(&event, ibcq->cq_context);
+			}
+		} else {
+			WARN(1,
+			     "Error: CQ event with NULL pointer ibcq. Handle=%llx\n",
+			     roce_handle64);
+		}
+		DP_ERR(dev, "CQ event %d on hanlde %p\n", e_code, cq);
+		break;
+	case EVENT_TYPE_QP:
+		qp = (struct qedr_qp *)(uintptr_t)roce_handle64;
+		if (qp) {
+			ibqp = &qp->ibqp;
+			if (ibqp->event_handler) {
+				event.device = ibqp->device;
+				event.element.qp = ibqp;
+				ibqp->event_handler(&event, ibqp->qp_context);
+			}
+		} else {
+			WARN(1,
+			     "Error: QP event with NULL pointer ibqp. Handle=%llx\n",
+			     roce_handle64);
+		}
+		DP_ERR(dev, "QP event %d on hanlde %p\n", e_code, qp);
+		break;
+	default:
+		break;
+	}
+}
+
 static int qedr_init_hw(struct qedr_dev *dev)
 {
 	struct qed_rdma_add_user_out_params out_params;
@@ -576,6 +675,7 @@ static int qedr_init_hw(struct qedr_dev *dev)
 		cur_pbl->pbl_ptr = (u64)p_phys_table;
 	}
 
+	events.affiliated_event = qedr_affiliated_event;
 	events.context = dev;
 
 	in_params->events = &events;
@@ -675,7 +775,7 @@ static struct qedr_dev *qedr_add(struct qed_dev *cdev, struct pci_dev *pdev,
 
 	for (i = 0; i < ARRAY_SIZE(qedr_attributes); i++)
 		if (device_create_file(&dev->ibdev.dev, qedr_attributes[i]))
-			goto reg_err;
+			goto sysfs_err;
 
 	spin_lock(&qedr_devlist_lock);
 	list_add_tail_rcu(&dev->entry, &qedr_dev_list);
@@ -684,6 +784,8 @@ static struct qedr_dev *qedr_add(struct qed_dev *cdev, struct pci_dev *pdev,
 	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr driver loaded successfully\n");
 	return dev;
 
+sysfs_err:
+	ib_unregister_device(&dev->ibdev);
 reg_err:
 	qedr_sync_free_irqs(dev);
 irq_err:
@@ -703,6 +805,7 @@ static void qedr_remove(struct qedr_dev *dev)
 	 * of the registered clients.
 	 */
 	qedr_remove_sysfiles(dev);
+	ib_unregister_device(&dev->ibdev);
 
 	spin_lock(&qedr_devlist_lock);
 	list_del_rcu(&dev->entry);
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index 9381bc6..6055e27 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -3523,3 +3523,40 @@ int qedr_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
 	spin_unlock_irqrestore(&cq->cq_lock, flags);
 	return done;
 }
+
+int qedr_process_mad(struct ib_device *ibdev, int process_mad_flags,
+		     u8 port_num,
+		     const struct ib_wc *in_wc,
+		     const struct ib_grh *in_grh,
+		     const struct ib_mad_hdr *mad_hdr,
+		     size_t in_mad_size, struct ib_mad_hdr *out_mad,
+		     size_t *out_mad_size, u16 *out_mad_pkey_index)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibdev);
+
+	DP_VERBOSE(dev, QEDR_MSG_GSI,
+		   "QEDR_PROCESS_MAD in_mad %x %x %x %x %x %x %x %x\n",
+		   mad_hdr->attr_id, mad_hdr->base_version, mad_hdr->attr_mod,
+		   mad_hdr->class_specific, mad_hdr->class_version,
+		   mad_hdr->method, mad_hdr->mgmt_class, mad_hdr->status);
+	return IB_MAD_RESULT_SUCCESS;
+}
+
+int qedr_port_immutable(struct ib_device *ibdev, u8 port_num,
+			struct ib_port_immutable *immutable)
+{
+	struct ib_port_attr attr;
+	int err;
+
+	err = qedr_query_port(ibdev, port_num, &attr);
+	if (err)
+		return err;
+
+	immutable->pkey_tbl_len = attr.pkey_tbl_len;
+	immutable->gid_tbl_len = attr.gid_tbl_len;
+	immutable->core_cap_flags = RDMA_CORE_PORT_IBA_ROCE |
+				    RDMA_CORE_PORT_IBA_ROCE_UDP_ENCAP;
+	immutable->max_mad_size = IB_MGMT_MAD_SIZE;
+
+	return 0;
+}
diff --git a/drivers/infiniband/hw/qedr/verbs.h b/drivers/infiniband/hw/qedr/verbs.h
index 9eb2722b..da4535e 100644
--- a/drivers/infiniband/hw/qedr/verbs.h
+++ b/drivers/infiniband/hw/qedr/verbs.h
@@ -63,4 +63,13 @@ int qedr_post_send(struct ib_qp *, struct ib_send_wr *,
 		   struct ib_send_wr **bad_wr);
 int qedr_post_recv(struct ib_qp *, struct ib_recv_wr *,
 		   struct ib_recv_wr **bad_wr);
+int qedr_process_mad(struct ib_device *ibdev, int process_mad_flags,
+		     u8 port_num, const struct ib_wc *in_wc,
+		     const struct ib_grh *in_grh,
+		     const struct ib_mad_hdr *in_mad,
+		     size_t in_mad_size, struct ib_mad_hdr *out_mad,
+		     size_t *out_mad_size, u16 *out_mad_pkey_index);
+
+int qedr_port_immutable(struct ib_device *ibdev, u8 port_num,
+			struct ib_port_immutable *immutable);
 #endif
diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
index 70b30e4..83ce645 100644
--- a/include/linux/qed/common_hsi.h
+++ b/include/linux/qed/common_hsi.h
@@ -671,6 +671,7 @@ union event_ring_data {
 	struct iscsi_eqe_data iscsi_info;
 	struct malicious_vf_eqe_data malicious_vf;
 	struct initial_cleanup_eqe_data vf_init_cleanup;
+	struct regpair roce_handle;
 };
 
 /* Event Ring Entry */
-- 
1.8.3.1
