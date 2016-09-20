From: Ram Amrani <Ram.Amrani@cavium.com>
Subject: [RFC v2 03/12] qedr: Add support for RoCE HW init
Date: Tue, 20 Sep 2016 13:35:55 +0300
Message-ID: <1474367764-9555-4-git-send-email-Ram.Amrani@cavium.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@cavium.com>, <Michal.Kalderon@cavium.com>,
        <Yuval.Mintz@cavium.com>, <rajesh.borundia@cavium.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        Ram amrani <Ram.Amrani@cavium.com>
To: <davem@davemloft.net>, <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:32917 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932281AbcITKgs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 06:36:48 -0400
In-Reply-To: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram amrani <Ram.Amrani@cavium.com>

Allocate and setup RoCE resources, interrupts and completion queues.
Adds device attributes.

Signed-off-by: Rajesh Borundia <rajesh.borundia@cavium.com>
Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
---
 drivers/infiniband/hw/qedr/main.c              | 417 +++++++++++-
 drivers/infiniband/hw/qedr/qedr.h              | 123 ++++
 drivers/infiniband/hw/qedr/qedr_hsi.h          |  56 ++
 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h     |  96 +++
 drivers/net/ethernet/qlogic/qed/Makefile       |   1 +
 drivers/net/ethernet/qlogic/qed/qed.h          |  26 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c      |   6 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.h      |   6 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c      | 155 +++++
 drivers/net/ethernet/qlogic/qed/qed_main.c     |  44 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   8 +-
 drivers/net/ethernet/qlogic/qed/qed_roce.c     | 887 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_roce.h     | 117 ++++
 drivers/net/ethernet/qlogic/qed/qed_sp.h       |   1 +
 drivers/net/ethernet/qlogic/qed/qed_spq.c      |   8 +
 include/linux/qed/qed_if.h                     |   5 +-
 include/linux/qed/qed_roce_if.h                | 345 ++++++++++
 17 files changed, 2294 insertions(+), 7 deletions(-)
 create mode 100644 drivers/infiniband/hw/qedr/qedr_hsi.h
 create mode 100644 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_roce.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_roce.h
 create mode 100644 include/linux/qed/qed_roce_if.h

diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index f60dc80..70ad9e6 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -36,6 +36,8 @@
 #include <linux/iommu.h>
 #include <net/addrconf.h>
 #include <linux/qed/qede_roce.h>
+#include <linux/qed/qed_chain.h>
+#include <linux/qed/qed_if.h>
 #include "qedr.h"
 
 MODULE_DESCRIPTION("QLogic 40G/100G ROCE Driver");
@@ -67,6 +69,17 @@ static enum rdma_link_layer qedr_link_layer(struct ib_device *device,
 	return IB_LINK_LAYER_ETHERNET;
 }
 
+static void qedr_get_dev_fw_str(struct ib_device *ibdev, char *str,
+				size_t str_len)
+{
+	struct qedr_dev *qedr = get_qedr_dev(ibdev);
+	u32 fw_ver = (u32)qedr->attr.fw_ver;
+
+	snprintf(str, str_len, "%d. %d. %d. %d",
+		 (fw_ver >> 24) & 0xFF, (fw_ver >> 16) & 0xFF,
+		 (fw_ver >> 8) & 0xFF, fw_ver & 0xFF);
+}
+
 static int qedr_register_device(struct qedr_dev *dev)
 {
 	strlcpy(dev->ibdev.name, "qedr%d", IB_DEVICE_NAME_MAX);
@@ -75,8 +88,139 @@ static int qedr_register_device(struct qedr_dev *dev)
 	dev->ibdev.owner = THIS_MODULE;
 
 	dev->ibdev.get_link_layer = qedr_link_layer;
+	dev->ibdev.get_dev_fw_str = qedr_get_dev_fw_str;
+
+	return 0;
+}
+
+/* This function allocates fast-path status block memory */
+static int qedr_alloc_mem_sb(struct qedr_dev *dev,
+			     struct qed_sb_info *sb_info, u16 sb_id)
+{
+	struct status_block *sb_virt;
+	dma_addr_t sb_phys;
+	int rc;
+
+	sb_virt = dma_alloc_coherent(&dev->pdev->dev,
+				     sizeof(*sb_virt), &sb_phys, GFP_KERNEL);
+	if (!sb_virt) {
+		pr_err("Status block allocation failed\n");
+		return -ENOMEM;
+	}
+
+	rc = dev->ops->common->sb_init(dev->cdev, sb_info,
+				       sb_virt, sb_phys, sb_id,
+				       QED_SB_TYPE_CNQ);
+	if (rc) {
+		pr_err("Status block initialization failed\n");
+		dma_free_coherent(&dev->pdev->dev, sizeof(*sb_virt),
+				  sb_virt, sb_phys);
+		return rc;
+	}
+
+	return 0;
+}
+
+static void qedr_free_mem_sb(struct qedr_dev *dev,
+			     struct qed_sb_info *sb_info, int sb_id)
+{
+	if (sb_info->sb_virt) {
+		dev->ops->common->sb_release(dev->cdev, sb_info, sb_id);
+		dma_free_coherent(&dev->pdev->dev, sizeof(*sb_info->sb_virt),
+				  (void *)sb_info->sb_virt, sb_info->sb_phys);
+	}
+}
+
+static void qedr_free_resources(struct qedr_dev *dev)
+{
+	int i;
+
+	for (i = 0; i < dev->num_cnq; i++) {
+		qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
+		dev->ops->common->chain_free(dev->cdev, &dev->cnq_array[i].pbl);
+	}
+
+	kfree(dev->cnq_array);
+	kfree(dev->sb_array);
+	kfree(dev->sgid_tbl);
+}
+
+static int qedr_alloc_resources(struct qedr_dev *dev)
+{
+	struct qedr_cnq *cnq;
+	__le16 *cons_pi;
+	u16 n_entries;
+	int i, rc;
+
+	dev->sgid_tbl = kzalloc(sizeof(union ib_gid) *
+				QEDR_MAX_SGID, GFP_KERNEL);
+	if (!dev->sgid_tbl)
+		return -ENOMEM;
+
+	spin_lock_init(&dev->sgid_lock);
+
+	/* Allocate Status blocks for CNQ */
+	dev->sb_array = kcalloc(dev->num_cnq, sizeof(*dev->sb_array),
+				GFP_KERNEL);
+	if (!dev->sb_array) {
+		rc = -ENOMEM;
+		goto err1;
+	}
+
+	dev->cnq_array = kcalloc(dev->num_cnq,
+				 sizeof(*dev->cnq_array), GFP_KERNEL);
+	if (!dev->cnq_array) {
+		rc = -ENOMEM;
+		goto err2;
+	}
+
+	dev->sb_start = dev->ops->rdma_get_start_sb(dev->cdev);
+
+	/* Allocate CNQ PBLs */
+	n_entries = min_t(u32, QED_RDMA_MAX_CNQ_SIZE, QEDR_ROCE_MAX_CNQ_SIZE);
+	for (i = 0; i < dev->num_cnq; i++) {
+		cnq = &dev->cnq_array[i];
+
+		rc = qedr_alloc_mem_sb(dev, &dev->sb_array[i],
+				       dev->sb_start + i);
+		if (rc)
+			goto err3;
+
+		rc = dev->ops->common->chain_alloc(dev->cdev,
+						   QED_CHAIN_USE_TO_CONSUME,
+						   QED_CHAIN_MODE_PBL,
+						   QED_CHAIN_CNT_TYPE_U16,
+						   n_entries,
+						   sizeof(struct regpair *),
+						   &cnq->pbl);
+		if (rc)
+			goto err4;
+
+		cnq->dev = dev;
+		cnq->sb = &dev->sb_array[i];
+		cons_pi = dev->sb_array[i].sb_virt->pi_array;
+		cnq->hw_cons_ptr = &cons_pi[QED_ROCE_PROTOCOL_INDEX];
+		cnq->index = i;
+		sprintf(cnq->name, "qedr%d@pci:%s", i, pci_name(dev->pdev));
+
+		DP_VERBOSE(dev, QEDR_MSG_INIT, "cnq[%d].cons=%d\n",
+			   i, qed_chain_get_cons_idx(&cnq->pbl));
+	}
 
 	return 0;
+err4:
+	qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
+err3:
+	for (--i; i >= 0; i--) {
+		dev->ops->common->chain_free(dev->cdev, &dev->cnq_array[i].pbl);
+		qedr_free_mem_sb(dev, &dev->sb_array[i], dev->sb_start + i);
+	}
+	kfree(dev->cnq_array);
+err2:
+	kfree(dev->sb_array);
+err1:
+	kfree(dev->sgid_tbl);
+	return rc;
 }
 
 /* QEDR sysfs interface */
@@ -167,9 +311,237 @@ static void qedr_pci_set_atomic(struct qedr_dev *dev, struct pci_dev *pdev)
 	}
 }
 
+static const struct qed_rdma_ops *qed_ops;
+
+#define HILO_U64(hi, lo)		((((u64)(hi)) << 32) + (lo))
+
+static irqreturn_t qedr_irq_handler(int irq, void *handle)
+{
+	u16 hw_comp_cons, sw_comp_cons;
+	struct qedr_cnq *cnq = handle;
+
+	qed_sb_ack(cnq->sb, IGU_INT_DISABLE, 0);
+
+	qed_sb_update_sb_idx(cnq->sb);
+
+	hw_comp_cons = le16_to_cpu(*cnq->hw_cons_ptr);
+	sw_comp_cons = qed_chain_get_cons_idx(&cnq->pbl);
+
+	/* Align protocol-index and chain reads */
+	rmb();
+
+	while (sw_comp_cons != hw_comp_cons) {
+		sw_comp_cons = qed_chain_get_cons_idx(&cnq->pbl);
+		cnq->n_comp++;
+	}
+
+	qed_ops->rdma_cnq_prod_update(cnq->dev->rdma_ctx, cnq->index,
+				      sw_comp_cons);
+
+	qed_sb_ack(cnq->sb, IGU_INT_ENABLE, 1);
+
+	return IRQ_HANDLED;
+}
+
+static void qedr_sync_free_irqs(struct qedr_dev *dev)
+{
+	u32 vector;
+	int i;
+
+	for (i = 0; i < dev->int_info.used_cnt; i++) {
+		if (dev->int_info.msix_cnt) {
+			vector = dev->int_info.msix[i * dev->num_hwfns].vector;
+			synchronize_irq(vector);
+			free_irq(vector, &dev->cnq_array[i]);
+		}
+	}
+
+	dev->int_info.used_cnt = 0;
+}
+
+static int qedr_req_msix_irqs(struct qedr_dev *dev)
+{
+	int i, rc = 0;
+
+	if (dev->num_cnq > dev->int_info.msix_cnt) {
+		DP_ERR(dev,
+		       "Interrupt mismatch: %d CNQ queues > %d MSI-x vectors\n",
+		       dev->num_cnq, dev->int_info.msix_cnt);
+		return -EINVAL;
+	}
+
+	for (i = 0; i < dev->num_cnq; i++) {
+		rc = request_irq(dev->int_info.msix[i * dev->num_hwfns].vector,
+				 qedr_irq_handler, 0, dev->cnq_array[i].name,
+				 &dev->cnq_array[i]);
+		if (rc) {
+			DP_ERR(dev, "Request cnq %d irq failed\n", i);
+			qedr_sync_free_irqs(dev);
+		} else {
+			DP_VERBOSE(dev, QEDR_MSG_INIT,
+				   "Requested cnq irq for %s [entry %d]. Cookie is at %p\n",
+				   dev->cnq_array[i].name, i,
+				   &dev->cnq_array[i]);
+			dev->int_info.used_cnt++;
+		}
+	}
+
+	return rc;
+}
+
+static int qedr_setup_irqs(struct qedr_dev *dev)
+{
+	int rc;
+
+	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr_setup_irqs\n");
+
+	/* Learn Interrupt configuration */
+	rc = dev->ops->rdma_set_rdma_int(dev->cdev, dev->num_cnq);
+	if (rc < 0)
+		return rc;
+	rc = dev->ops->rdma_get_rdma_int(dev->cdev, &dev->int_info);
+	if (rc) {
+		DP_VERBOSE(dev, QEDR_MSG_INIT, "get_rdma_int failed\n");
+		return rc;
+	}
+
+	if (dev->int_info.msix_cnt) {
+		DP_VERBOSE(dev, QEDR_MSG_INIT, "rdma msix_cnt = %d\n",
+			   dev->int_info.msix_cnt);
+		rc = qedr_req_msix_irqs(dev);
+		if (rc)
+			return rc;
+	}
+	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr_setup_irqs succeeded\n");
+	return 0;
+}
+
+static int qedr_set_device_attr(struct qedr_dev *dev)
+{
+	struct qed_rdma_device *qed_attr;
+	struct qedr_device_attr *attr;
+	u32 page_size;
+
+	/* Part 1 - query core capabilities */
+	qed_attr = dev->ops->rdma_query_device(dev->rdma_ctx);
+
+	/* Part 2 - check capabilities */
+	page_size = ~dev->attr.page_size_caps + 1;
+	if (page_size > PAGE_SIZE) {
+		DP_ERR(dev,
+		       "Kernel PAGE_SIZE is %ld which is smaller than minimum page size (%d) required by qedr\n",
+		       PAGE_SIZE, page_size);
+		return -ENODEV;
+	}
+
+	/* Part 3 - copy and update capabilities */
+	attr = &dev->attr;
+	attr->vendor_id = qed_attr->vendor_id;
+	attr->vendor_part_id = qed_attr->vendor_part_id;
+	attr->hw_ver = qed_attr->hw_ver;
+	attr->fw_ver = qed_attr->fw_ver;
+	attr->node_guid = qed_attr->node_guid;
+	attr->sys_image_guid = qed_attr->sys_image_guid;
+	attr->max_cnq = qed_attr->max_cnq;
+	attr->max_sge = qed_attr->max_sge;
+	attr->max_inline = qed_attr->max_inline;
+	attr->max_sqe = min_t(u32, qed_attr->max_wqe, QEDR_MAX_SQE);
+	attr->max_rqe = min_t(u32, qed_attr->max_wqe, QEDR_MAX_RQE);
+	attr->max_qp_resp_rd_atomic_resc = qed_attr->max_qp_resp_rd_atomic_resc;
+	attr->max_qp_req_rd_atomic_resc = qed_attr->max_qp_req_rd_atomic_resc;
+	attr->max_dev_resp_rd_atomic_resc =
+	    qed_attr->max_dev_resp_rd_atomic_resc;
+	attr->max_cq = qed_attr->max_cq;
+	attr->max_qp = qed_attr->max_qp;
+	attr->max_mr = qed_attr->max_mr;
+	attr->max_mr_size = qed_attr->max_mr_size;
+	attr->max_cqe = min_t(u64, qed_attr->max_cqe, QEDR_MAX_CQES);
+	attr->max_mw = qed_attr->max_mw;
+	attr->max_fmr = qed_attr->max_fmr;
+	attr->max_mr_mw_fmr_pbl = qed_attr->max_mr_mw_fmr_pbl;
+	attr->max_mr_mw_fmr_size = qed_attr->max_mr_mw_fmr_size;
+	attr->max_pd = qed_attr->max_pd;
+	attr->max_ah = qed_attr->max_ah;
+	attr->max_pkey = qed_attr->max_pkey;
+	attr->max_srq = qed_attr->max_srq;
+	attr->max_srq_wr = qed_attr->max_srq_wr;
+	attr->dev_caps = qed_attr->dev_caps;
+	attr->page_size_caps = qed_attr->page_size_caps;
+	attr->dev_ack_delay = qed_attr->dev_ack_delay;
+	attr->reserved_lkey = qed_attr->reserved_lkey;
+	attr->bad_pkey_counter = qed_attr->bad_pkey_counter;
+	attr->max_stats_queues = qed_attr->max_stats_queues;
+
+	return 0;
+}
+
+static int qedr_init_hw(struct qedr_dev *dev)
+{
+	struct qed_rdma_add_user_out_params out_params;
+	struct qed_rdma_start_in_params *in_params;
+	struct qed_rdma_cnq_params *cur_pbl;
+	struct qed_rdma_events events;
+	dma_addr_t p_phys_table;
+	u32 page_cnt;
+	int rc = 0;
+	int i;
+
+	in_params =  kzalloc(sizeof(*in_params), GFP_KERNEL);
+	if (!in_params) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	in_params->desired_cnq = dev->num_cnq;
+	for (i = 0; i < dev->num_cnq; i++) {
+		cur_pbl = &in_params->cnq_pbl_list[i];
+
+		page_cnt = qed_chain_get_page_cnt(&dev->cnq_array[i].pbl);
+		cur_pbl->num_pbl_pages = page_cnt;
+
+		p_phys_table = qed_chain_get_pbl_phys(&dev->cnq_array[i].pbl);
+		cur_pbl->pbl_ptr = (u64)p_phys_table;
+	}
+
+	events.context = dev;
+
+	in_params->events = &events;
+	in_params->cq_mode = QED_RDMA_CQ_MODE_32_BITS;
+	in_params->max_mtu = dev->ndev->mtu;
+	ether_addr_copy(&in_params->mac_addr[0], dev->ndev->dev_addr);
+
+	rc = dev->ops->rdma_init(dev->cdev, in_params);
+	if (rc)
+		goto out;
+
+	rc = dev->ops->rdma_add_user(dev->rdma_ctx, &out_params);
+	if (rc)
+		goto out;
+
+	dev->db_addr = (void *)(uintptr_t)out_params.dpi_addr;
+	dev->db_phys_addr = out_params.dpi_phys_addr;
+	dev->db_size = out_params.dpi_size;
+	dev->dpi = out_params.dpi;
+
+	rc = qedr_set_device_attr(dev);
+out:
+	kfree(in_params);
+	if (rc)
+		DP_ERR(dev, "Init HW Failed rc = %d\n", rc);
+
+	return rc;
+}
+
+void qedr_stop_hw(struct qedr_dev *dev)
+{
+	dev->ops->rdma_remove_user(dev->rdma_ctx, dev->dpi);
+	dev->ops->rdma_stop(dev->rdma_ctx);
+}
+
 static struct qedr_dev *qedr_add(struct qed_dev *cdev, struct pci_dev *pdev,
 				 struct net_device *ndev)
 {
+	struct qed_dev_rdma_info dev_info;
 	struct qedr_dev *dev;
 	int rc = 0, i;
 
@@ -186,21 +558,59 @@ static struct qedr_dev *qedr_add(struct qed_dev *cdev, struct pci_dev *pdev,
 	dev->ndev = ndev;
 	dev->cdev = cdev;
 
+	qed_ops = qed_get_rdma_ops();
+	if (!qed_ops) {
+		DP_ERR(dev, "Failed to get qed roce operations\n");
+		goto init_err;
+	}
+
+	dev->ops = qed_ops;
+	rc = qed_ops->fill_dev_info(cdev, &dev_info);
+	if (rc)
+		goto init_err;
+
+	dev->num_hwfns = dev_info.common.num_hwfns;
+	dev->rdma_ctx = dev->ops->rdma_get_rdma_ctx(cdev);
+
+	dev->num_cnq = dev->ops->rdma_get_min_cnq_msix(cdev);
+	if (!dev->num_cnq) {
+		DP_ERR(dev, "not enough CNQ resources.\n");
+		goto init_err;
+	}
+
 	qedr_pci_set_atomic(dev, pdev);
+ 
+	rc = qedr_alloc_resources(dev);
+	if (rc)
+		goto init_err;
+
+	rc = qedr_init_hw(dev);
+	if (rc)
+		goto alloc_err;
+
+	rc = qedr_setup_irqs(dev);
+	if (rc)
+		goto irq_err;
 
 	rc = qedr_register_device(dev);
 	if (rc) {
 		DP_ERR(dev, "Unable to allocate register device\n");
-		goto init_err;
+		goto reg_err;
 	}
 
 	for (i = 0; i < ARRAY_SIZE(qedr_attributes); i++)
 		if (device_create_file(&dev->ibdev.dev, qedr_attributes[i]))
-			goto init_err;
+			goto reg_err;
 
 	DP_VERBOSE(dev, QEDR_MSG_INIT, "qedr driver loaded successfully\n");
 	return dev;
 
+reg_err:
+	qedr_sync_free_irqs(dev);
+irq_err:
+	qedr_stop_hw(dev);
+alloc_err:
+	qedr_free_resources(dev);
 init_err:
 	ib_dealloc_device(&dev->ibdev);
 	DP_ERR(dev, "qedr driver load failed rc=%d\n", rc);
@@ -215,6 +625,9 @@ static void qedr_remove(struct qedr_dev *dev)
 	 */
 	qedr_remove_sysfiles(dev);
 
+	qedr_stop_hw(dev);
+	qedr_sync_free_irqs(dev);
+	qedr_free_resources(dev);
 	ib_dealloc_device(&dev->ibdev);
 }
 
diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
index c8a1f61..0484d34 100644
--- a/drivers/infiniband/hw/qedr/qedr.h
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -35,7 +35,10 @@
 #include <linux/pci.h>
 #include <rdma/ib_addr.h>
 #include <linux/qed/qed_if.h>
+#include <linux/qed/qed_chain.h>
+#include <linux/qed/qed_roce_if.h>
 #include <linux/qed/qede_roce.h>
+#include "qedr_hsi.h"
 
 #define QEDR_MODULE_VERSION	"8.10.10.0"
 #define QEDR_NODE_DESC "QLogic 579xx RoCE HCA"
@@ -45,6 +48,60 @@ enum DP_QEDR_MODULE {
 	QEDR_MSG_INIT = 0x10000,
 };
 
+struct qedr_dev;
+
+struct qedr_cnq {
+	struct qedr_dev		*dev;
+	struct qed_chain	pbl;
+	struct qed_sb_info	*sb;
+	char			name[32];
+	u64			n_comp;
+	__le16			*hw_cons_ptr;
+	u8			index;
+};
+
+#define QEDR_MAX_SGID 128
+
+struct qedr_device_attr {
+	u32	vendor_id;
+	u32	vendor_part_id;
+	u32	hw_ver;
+	u64	fw_ver;
+	u64	node_guid;
+	u64	sys_image_guid;
+	u8	max_cnq;
+	u8	max_sge;
+	u16	max_inline;
+	u32	max_sqe;
+	u32	max_rqe;
+	u8	max_qp_resp_rd_atomic_resc;
+	u8	max_qp_req_rd_atomic_resc;
+	u64	max_dev_resp_rd_atomic_resc;
+	u32	max_cq;
+	u32	max_qp;
+	u32	max_mr;
+	u64	max_mr_size;
+	u32	max_cqe;
+	u32	max_mw;
+	u32	max_fmr;
+	u32	max_mr_mw_fmr_pbl;
+	u64	max_mr_mw_fmr_size;
+	u32	max_pd;
+	u32	max_ah;
+	u8	max_pkey;
+	u32	max_srq;
+	u32	max_srq_wr;
+	u8	max_srq_sge;
+	u8	max_stats_queues;
+	u32	dev_caps;
+
+	u64	page_size_caps;
+	u8	dev_ack_delay;
+	u32	reserved_lkey;
+	u32	bad_pkey_counter;
+	struct qed_rdma_events events;
+};
+
 struct qedr_dev {
 	struct ib_device	ibdev;
 	struct qed_dev		*cdev;
@@ -53,7 +110,73 @@ struct qedr_dev {
 
 	enum ib_atomic_cap	atomic_cap;
 
+	void *rdma_ctx;
+	struct qedr_device_attr attr;
+
+	const struct qed_rdma_ops *ops;
+	struct qed_int_info	int_info;
+
+	struct qed_sb_info	*sb_array;
+	struct qedr_cnq		*cnq_array;
+	int			num_cnq;
+	int			sb_start;
+
+	void __iomem		*db_addr;
+	u64			db_phys_addr;
+	u32			db_size;
+	u16			dpi;
+
+	union ib_gid *sgid_tbl;
+
+	/* Lock for sgid table */
+	spinlock_t sgid_lock;
+
+	u64			guid;
+
 	u32			dp_module;
 	u8			dp_level;
+	u8			num_hwfns;
 };
+
+#define QEDR_MAX_SQ_PBL			(0x8000)
+#define QEDR_MAX_SQ_PBL_ENTRIES		(0x10000 / sizeof(void *))
+#define QEDR_SQE_ELEMENT_SIZE		(sizeof(struct rdma_sq_sge))
+#define QEDR_MAX_SQE_ELEMENTS_PER_SQE	(ROCE_REQ_MAX_SINGLE_SQ_WQE_SIZE / \
+					 QEDR_SQE_ELEMENT_SIZE)
+#define QEDR_MAX_SQE_ELEMENTS_PER_PAGE	((RDMA_RING_PAGE_SIZE) / \
+					 QEDR_SQE_ELEMENT_SIZE)
+#define QEDR_MAX_SQE			((QEDR_MAX_SQ_PBL_ENTRIES) *\
+					 (RDMA_RING_PAGE_SIZE) / \
+					 (QEDR_SQE_ELEMENT_SIZE) /\
+					 (QEDR_MAX_SQE_ELEMENTS_PER_SQE))
+/* RQ */
+#define QEDR_MAX_RQ_PBL			(0x2000)
+#define QEDR_MAX_RQ_PBL_ENTRIES		(0x10000 / sizeof(void *))
+#define QEDR_RQE_ELEMENT_SIZE		(sizeof(struct rdma_rq_sge))
+#define QEDR_MAX_RQE_ELEMENTS_PER_RQE	(RDMA_MAX_SGE_PER_RQ_WQE)
+#define QEDR_MAX_RQE_ELEMENTS_PER_PAGE	((RDMA_RING_PAGE_SIZE) / \
+					 QEDR_RQE_ELEMENT_SIZE)
+#define QEDR_MAX_RQE			((QEDR_MAX_RQ_PBL_ENTRIES) *\
+					 (RDMA_RING_PAGE_SIZE) / \
+					 (QEDR_RQE_ELEMENT_SIZE) /\
+					 (QEDR_MAX_RQE_ELEMENTS_PER_RQE))
+
+#define QEDR_CQE_SIZE	(sizeof(union rdma_cqe))
+#define QEDR_MAX_CQE_PBL_SIZE (512 * 1024)
+#define QEDR_MAX_CQE_PBL_ENTRIES (((QEDR_MAX_CQE_PBL_SIZE) / \
+				  sizeof(u64)) - 1)
+#define QEDR_MAX_CQES ((u32)((QEDR_MAX_CQE_PBL_ENTRIES) * \
+			     (QED_CHAIN_PAGE_SIZE) / QEDR_CQE_SIZE))
+
+#define QEDR_ROCE_MAX_CNQ_SIZE		(0x4000)
+
+#define QEDR_MAX_PORT			(1)
+
+#define QEDR_UVERBS(CMD_NAME) (1ull << IB_USER_VERBS_CMD_##CMD_NAME)
+
+static inline struct qedr_dev *get_qedr_dev(struct ib_device *ibdev)
+{
+	return container_of(ibdev, struct qedr_dev, ibdev);
+}
+
 #endif
diff --git a/drivers/infiniband/hw/qedr/qedr_hsi.h b/drivers/infiniband/hw/qedr/qedr_hsi.h
new file mode 100644
index 0000000..66d2752
--- /dev/null
+++ b/drivers/infiniband/hw/qedr/qedr_hsi.h
@@ -0,0 +1,56 @@
+/* QLogic qedr NIC Driver
+ * Copyright (c) 2015-2016  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#ifndef __QED_HSI_ROCE__
+#define __QED_HSI_ROCE__
+
+#include <linux/qed/common_hsi.h>
+#include <linux/qed/roce_common.h>
+#include "qedr_hsi_rdma.h"
+
+/* Affiliated asynchronous events / errors enumeration */
+enum roce_async_events_type {
+	ROCE_ASYNC_EVENT_NONE = 0,
+	ROCE_ASYNC_EVENT_COMM_EST = 1,
+	ROCE_ASYNC_EVENT_SQ_DRAINED,
+	ROCE_ASYNC_EVENT_SRQ_LIMIT,
+	ROCE_ASYNC_EVENT_LAST_WQE_REACHED,
+	ROCE_ASYNC_EVENT_CQ_ERR,
+	ROCE_ASYNC_EVENT_LOCAL_INVALID_REQUEST_ERR,
+	ROCE_ASYNC_EVENT_LOCAL_CATASTROPHIC_ERR,
+	ROCE_ASYNC_EVENT_LOCAL_ACCESS_ERR,
+	ROCE_ASYNC_EVENT_QP_CATASTROPHIC_ERR,
+	ROCE_ASYNC_EVENT_CQ_OVERFLOW_ERR,
+	ROCE_ASYNC_EVENT_SRQ_EMPTY,
+	MAX_ROCE_ASYNC_EVENTS_TYPE
+};
+
+#endif /* __QED_HSI_ROCE__ */
diff --git a/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h b/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
new file mode 100644
index 0000000..3e508fb
--- /dev/null
+++ b/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
@@ -0,0 +1,96 @@
+/* QLogic qedr NIC Driver
+ * Copyright (c) 2015-2016  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#ifndef __QED_HSI_RDMA__
+#define __QED_HSI_RDMA__
+
+#include <linux/qed/rdma_common.h>
+
+/* rdma completion notification queue element */
+struct rdma_cnqe {
+	struct regpair	cq_handle;
+};
+
+struct rdma_cqe_responder {
+	struct regpair srq_wr_id;
+	struct regpair qp_handle;
+	__le32 imm_data_or_inv_r_Key;
+	__le32 length;
+	__le32 imm_data_hi;
+	__le16 rq_cons;
+	u8 flags;
+};
+
+struct rdma_cqe_requester {
+	__le16 sq_cons;
+	__le16 reserved0;
+	__le32 reserved1;
+	struct regpair qp_handle;
+	struct regpair reserved2;
+	__le32 reserved3;
+	__le16 reserved4;
+	u8 flags;
+	u8 status;
+};
+
+struct rdma_cqe_common {
+	struct regpair reserved0;
+	struct regpair qp_handle;
+	__le16 reserved1[7];
+	u8 flags;
+	u8 status;
+};
+
+/* rdma completion queue element */
+union rdma_cqe {
+	struct rdma_cqe_responder resp;
+	struct rdma_cqe_requester req;
+	struct rdma_cqe_common cmn;
+};
+
+struct rdma_sq_sge {
+	__le32 length;
+	struct regpair	addr;
+	__le32 l_key;
+};
+
+struct rdma_rq_sge {
+	struct regpair addr;
+	__le32 length;
+	__le32 flags;
+};
+
+struct rdma_srq_sge {
+	struct regpair addr;
+	__le32 length;
+	__le32 l_key;
+};
+#endif /* __QED_HSI_RDMA__ */
diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
index e067098..cda0af7 100644
--- a/drivers/net/ethernet/qlogic/qed/Makefile
+++ b/drivers/net/ethernet/qlogic/qed/Makefile
@@ -5,3 +5,4 @@ qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o \
 	 qed_selftest.o qed_dcbx.o qed_debug.o
 qed-$(CONFIG_QED_SRIOV) += qed_sriov.o qed_vf.o
 qed-$(CONFIG_QED_LL2) += qed_ll2.o
+qed-$(CONFIG_INFINIBAND_QEDR) += qed_roce.o
diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 91b571a..74052f5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -35,6 +35,9 @@ extern const struct qed_common_ops qed_common_ops_pass;
 
 #define QED_WFQ_UNIT	100
 
+#define QED_WID_SIZE            (1024)
+#define QED_PF_DEMS_SIZE        (4)
+
 /* cau states */
 enum qed_coalescing_mode {
 	QED_COAL_MODE_DISABLE,
@@ -152,14 +155,17 @@ enum QED_RESOURCES {
 	QED_RL,
 	QED_MAC,
 	QED_VLAN,
+	QED_RDMA_CNQ_RAM,
 	QED_ILT,
 	QED_LL2_QUEUE,
+	QED_RDMA_STATS_QUEUE,
 	QED_MAX_RESC,
 };
 
 enum QED_FEATURE {
 	QED_PF_L2_QUE,
 	QED_VF,
+	QED_RDMA_CNQ,
 	QED_MAX_FEATURES,
 };
 
@@ -364,6 +370,7 @@ struct qed_hwfn {
 	/* Protocol related */
 	bool				using_ll2;
 	struct qed_ll2_info		*p_ll2_info;
+	struct qed_rdma_info		*p_rdma_info;
 	struct qed_pf_params		pf_params;
 
 	bool b_rdma_enabled_in_prs;
@@ -402,6 +409,17 @@ struct qed_hwfn {
 
 	struct dbg_tools_data		dbg_info;
 
+	/* PWM region specific data */
+	u32				dpi_size;
+	u32				dpi_count;
+
+	/* This is used to calculate the doorbell address */
+	u32 dpi_start_offset;
+
+	/* If one of the following is set then EDPM shouldn't be used */
+	u8 dcbx_no_edpm;
+	u8 db_bar_no_edpm;
+
 	struct qed_simd_fp_handler	simd_proto_handler[64];
 
 #ifdef CONFIG_QED_SRIOV
@@ -435,6 +453,8 @@ struct qed_int_params {
 	bool			fp_initialized;
 	u8			fp_msix_base;
 	u8			fp_msix_cnt;
+	u8			rdma_msix_base;
+	u8			rdma_msix_cnt;
 };
 
 struct qed_dbg_feature {
@@ -541,7 +561,6 @@ struct qed_dev {
 
 	bool				b_is_vf;
 	u32				drv_type;
-
 	struct qed_eth_stats		*reset_stats;
 	struct qed_fw_data		*fw_data;
 
@@ -574,6 +593,10 @@ struct qed_dev {
 #endif
 
 	const struct firmware		*firmware;
+
+	u32 rdma_max_sge;
+	u32 rdma_max_inline;
+	u32 rdma_max_srq_sge;
 };
 
 #define NUM_OF_VFS(dev)         MAX_NUM_VFS_BB
@@ -641,5 +664,6 @@ void qed_get_protocol_stats(struct qed_dev *cdev,
 			    enum qed_mcp_protocol_type type,
 			    union qed_mcp_protocol_stats *stats);
 int qed_slowpath_irq_req(struct qed_hwfn *hwfn);
+void qed_rdma_dpm_bar(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
 
 #endif /* _QED_H */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.c b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
index d9bea2a..82370a1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.c
@@ -48,7 +48,13 @@
 #define TM_ELEM_SIZE    4
 
 /* ILT constants */
+#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
+/* For RoCE we configure to 64K to cover for RoCE max tasks 256K purpose. */
+#define ILT_DEFAULT_HW_P_SIZE		4
+#else
 #define ILT_DEFAULT_HW_P_SIZE		3
+#endif
+
 #define ILT_PAGE_IN_BYTES(hw_p_size)	(1U << ((hw_p_size) + 12))
 #define ILT_CFG_REG(cli, reg)	PSWRQ2_REG_ ## cli ## _ ## reg ## _RT_OFFSET
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_cxt.h b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
index c6f6f2e..d00ad05 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_cxt.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_cxt.h
@@ -170,6 +170,12 @@ int qed_qm_reconf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
  */
 void qed_cxt_release_cid(struct qed_hwfn *p_hwfn,
 			 u32 cid);
+int qed_cxt_dynamic_ilt_alloc(struct qed_hwfn *p_hwfn,
+			      enum qed_cxt_elem_type elem_type, u32 iid);
+u32 qed_cxt_get_proto_tid_count(struct qed_hwfn *p_hwfn,
+				enum protocol_type type);
+u32 qed_cxt_get_proto_cid_start(struct qed_hwfn *p_hwfn,
+				enum protocol_type type);
 
 #define QED_CTX_WORKING_MEM 0
 #define QED_CTX_FL_MEM 1
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 9a8e153..eb6fbfc 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -38,6 +38,9 @@
 
 static DEFINE_SPINLOCK(qm_lock);
 
+#define QED_MIN_DPIS            (4)
+#define QED_MIN_PWM_REGION      (QED_WID_SIZE * QED_MIN_DPIS)
+
 /* API common to all protocols */
 enum BAR_ID {
 	BAR_ID_0,       /* used for GRC */
@@ -787,6 +790,140 @@ static int qed_hw_init_common(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+static int
+qed_hw_init_dpi_size(struct qed_hwfn *p_hwfn,
+		     struct qed_ptt *p_ptt, u32 pwm_region_size, u32 n_cpus)
+{
+	u32 dpi_page_size_1, dpi_page_size_2, dpi_page_size;
+	u32 dpi_bit_shift, dpi_count;
+	u32 min_dpis;
+
+	/* Calculate DPI size */
+	dpi_page_size_1 = QED_WID_SIZE * n_cpus;
+	dpi_page_size_2 = max_t(u32, QED_WID_SIZE, PAGE_SIZE);
+	dpi_page_size = max_t(u32, dpi_page_size_1, dpi_page_size_2);
+	dpi_page_size = roundup_pow_of_two(dpi_page_size);
+	dpi_bit_shift = ilog2(dpi_page_size / 4096);
+
+	dpi_count = pwm_region_size / dpi_page_size;
+
+	min_dpis = p_hwfn->pf_params.rdma_pf_params.min_dpis;
+	min_dpis = max_t(u32, QED_MIN_DPIS, min_dpis);
+
+	/* Update hwfn */
+	p_hwfn->dpi_size = dpi_page_size;
+	p_hwfn->dpi_count = dpi_count;
+
+	/* Update registers */
+	qed_wr(p_hwfn, p_ptt, DORQ_REG_PF_DPI_BIT_SHIFT, dpi_bit_shift);
+
+	if (dpi_count < min_dpis)
+		return -EINVAL;
+
+	return 0;
+}
+
+enum QED_ROCE_EDPM_MODE {
+	QED_ROCE_EDPM_MODE_ENABLE = 0,
+	QED_ROCE_EDPM_MODE_FORCE_ON = 1,
+	QED_ROCE_EDPM_MODE_DISABLE = 2,
+};
+
+static int
+qed_hw_init_pf_doorbell_bar(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	u32 pwm_regsize, norm_regsize;
+	u32 non_pwm_conn, min_addr_reg1;
+	u32 db_bar_size, n_cpus;
+	u32 roce_edpm_mode;
+	u32 pf_dems_shift;
+	int rc = 0;
+	u8 cond;
+
+	db_bar_size = qed_hw_bar_size(p_hwfn, BAR_ID_1);
+	if (p_hwfn->cdev->num_hwfns > 1)
+		db_bar_size /= 2;
+
+	/* Calculate doorbell regions */
+	non_pwm_conn = qed_cxt_get_proto_cid_start(p_hwfn, PROTOCOLID_CORE) +
+		       qed_cxt_get_proto_cid_count(p_hwfn, PROTOCOLID_CORE,
+						   NULL) +
+		       qed_cxt_get_proto_cid_count(p_hwfn, PROTOCOLID_ETH,
+						   NULL);
+	norm_regsize = roundup(QED_PF_DEMS_SIZE * non_pwm_conn, 4096);
+	min_addr_reg1 = norm_regsize / 4096;
+	pwm_regsize = db_bar_size - norm_regsize;
+
+	/* Check that the normal and PWM sizes are valid */
+	if (db_bar_size < norm_regsize) {
+		DP_ERR(p_hwfn->cdev,
+		       "Doorbell BAR size 0x%x is too small (normal region is 0x%0x )\n",
+		       db_bar_size, norm_regsize);
+		return -EINVAL;
+	}
+
+	if (pwm_regsize < QED_MIN_PWM_REGION) {
+		DP_ERR(p_hwfn->cdev,
+		       "PWM region size 0x%0x is too small. Should be at least 0x%0x (Doorbell BAR size is 0x%x and normal region size is 0x%0x)\n",
+		       pwm_regsize,
+		       QED_MIN_PWM_REGION, db_bar_size, norm_regsize);
+		return -EINVAL;
+	}
+
+	/* Calculate number of DPIs */
+	roce_edpm_mode = p_hwfn->pf_params.rdma_pf_params.roce_edpm_mode;
+	if ((roce_edpm_mode == QED_ROCE_EDPM_MODE_ENABLE) ||
+	    ((roce_edpm_mode == QED_ROCE_EDPM_MODE_FORCE_ON))) {
+		/* Either EDPM is mandatory, or we are attempting to allocate a
+		 * WID per CPU.
+		 */
+		n_cpus = num_active_cpus();
+		rc = qed_hw_init_dpi_size(p_hwfn, p_ptt, pwm_regsize, n_cpus);
+	}
+
+	cond = ((rc) && (roce_edpm_mode == QED_ROCE_EDPM_MODE_ENABLE)) ||
+	       (roce_edpm_mode == QED_ROCE_EDPM_MODE_DISABLE);
+	if (cond || p_hwfn->dcbx_no_edpm) {
+		/* Either EDPM is disabled from user configuration, or it is
+		 * disabled via DCBx, or it is not mandatory and we failed to
+		 * allocated a WID per CPU.
+		 */
+		n_cpus = 1;
+		rc = qed_hw_init_dpi_size(p_hwfn, p_ptt, pwm_regsize, n_cpus);
+
+		if (cond)
+			qed_rdma_dpm_bar(p_hwfn, p_ptt);
+	}
+
+	DP_INFO(p_hwfn,
+		"doorbell bar: normal_region_size=%d, pwm_region_size=%d, dpi_size=%d, dpi_count=%d, roce_edpm=%s\n",
+		norm_regsize,
+		pwm_regsize,
+		p_hwfn->dpi_size,
+		p_hwfn->dpi_count,
+		((p_hwfn->dcbx_no_edpm) || (p_hwfn->db_bar_no_edpm)) ?
+		"disabled" : "enabled");
+
+	if (rc) {
+		DP_ERR(p_hwfn,
+		       "Failed to allocate enough DPIs. Allocated %d but the current minimum is %d.\n",
+		       p_hwfn->dpi_count,
+		       p_hwfn->pf_params.rdma_pf_params.min_dpis);
+		return -EINVAL;
+	}
+
+	/* Update hwfn */
+	p_hwfn->dpi_start_offset = norm_regsize;
+
+	/* Update registers */
+	/* DEMS size is configured log2 of DWORDs, hence the division by 4 */
+	pf_dems_shift = ilog2(QED_PF_DEMS_SIZE / 4);
+	qed_wr(p_hwfn, p_ptt, DORQ_REG_PF_ICID_BIT_SHIFT_NORM, pf_dems_shift);
+	qed_wr(p_hwfn, p_ptt, DORQ_REG_PF_MIN_ADDR_REG1, min_addr_reg1);
+
+	return 0;
+}
+
 static int qed_hw_init_port(struct qed_hwfn *p_hwfn,
 			    struct qed_ptt *p_ptt, int hw_mode)
 {
@@ -860,6 +997,10 @@ static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 	/* Pure runtime initializations - directly to the HW  */
 	qed_int_igu_init_pure_rt(p_hwfn, p_ptt, true, true);
 
+	rc = qed_hw_init_pf_doorbell_bar(p_hwfn, p_ptt);
+	if (rc)
+		return rc;
+
 	if (b_hw_start) {
 		/* enable interrupts */
 		qed_int_igu_enable(p_hwfn, p_ptt, int_mode);
@@ -1284,6 +1425,19 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 	u32 *feat_num = p_hwfn->hw_info.feat_num;
 	int num_features = 1;
 
+#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
+	/* Roce CNQ require each: 1 status block. 1 CNQ, we divide the
+	 * status blocks equally between L2 / RoCE but with consideration as
+	 * to how many l2 queues / cnqs we have
+	 */
+	if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) {
+		num_features++;
+
+		feat_num[QED_RDMA_CNQ] =
+			min_t(u32, RESC_NUM(p_hwfn, QED_SB) / num_features,
+			      RESC_NUM(p_hwfn, QED_RDMA_CNQ_RAM));
+	}
+#endif
 	feat_num[QED_PF_L2_QUE] = min_t(u32, RESC_NUM(p_hwfn, QED_SB) /
 						num_features,
 					RESC_NUM(p_hwfn, QED_L2_QUEUE));
@@ -1325,6 +1479,7 @@ static int qed_hw_get_resc(struct qed_hwfn *p_hwfn)
 			     num_funcs;
 	resc_num[QED_ILT] = PXP_NUM_ILT_RECORDS_BB / num_funcs;
 	resc_num[QED_LL2_QUEUE] = MAX_NUM_LL2_RX_QUEUES / num_funcs;
+	resc_num[QED_RDMA_CNQ_RAM] = NUM_OF_CMDQS_CQS / num_funcs;
 
 	for (i = 0; i < QED_MAX_RESC; i++)
 		resc_start[i] = resc_num[i] * enabled_func_idx;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 48cdf62..4ee3151 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -33,6 +33,11 @@
 #include "qed_hw.h"
 #include "qed_selftest.h"
 
+#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
+#define QED_ROCE_QPS			(8192)
+#define QED_ROCE_DPIS			(8)
+#endif
+
 static char version[] =
 	"QLogic FastLinQ 4xxxx Core Module qed " DRV_MODULE_VERSION "\n";
 
@@ -206,8 +211,8 @@ int qed_fill_dev_info(struct qed_dev *cdev,
 	dev_info->pci_mem_start = cdev->pci_params.mem_start;
 	dev_info->pci_mem_end = cdev->pci_params.mem_end;
 	dev_info->pci_irq = cdev->pci_params.irq;
-	dev_info->rdma_supported =
-	    (cdev->hwfns[0].hw_info.personality == QED_PCI_ETH_ROCE);
+	dev_info->rdma_supported = (cdev->hwfns[0].hw_info.personality ==
+				    QED_PCI_ETH_ROCE);
 	dev_info->is_mf_default = IS_MF_DEFAULT(&cdev->hwfns[0]);
 	ether_addr_copy(dev_info->hw_mac, cdev->hwfns[0].hw_info.hw_mac_addr);
 
@@ -677,6 +682,9 @@ static int qed_slowpath_setup_int(struct qed_dev *cdev,
 				  enum qed_int_mode int_mode)
 {
 	struct qed_sb_cnt_info sb_cnt_info;
+#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
+	int num_l2_queues;
+#endif
 	int rc;
 	int i;
 
@@ -707,6 +715,31 @@ static int qed_slowpath_setup_int(struct qed_dev *cdev,
 	cdev->int_params.fp_msix_cnt = cdev->int_params.out.num_vectors -
 				       cdev->num_hwfns;
 
+#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
+	num_l2_queues = 0;
+	for_each_hwfn(cdev, i)
+		num_l2_queues += FEAT_NUM(&cdev->hwfns[i], QED_PF_L2_QUE);
+
+	DP_VERBOSE(cdev, QED_MSG_RDMA,
+		   "cdev->int_params.fp_msix_cnt=%d num_l2_queues=%d\n",
+		   cdev->int_params.fp_msix_cnt, num_l2_queues);
+
+	if (cdev->int_params.fp_msix_cnt > num_l2_queues) {
+		cdev->int_params.rdma_msix_cnt =
+			(cdev->int_params.fp_msix_cnt - num_l2_queues)
+			/ cdev->num_hwfns;
+		cdev->int_params.rdma_msix_base =
+			cdev->int_params.fp_msix_base + num_l2_queues;
+		cdev->int_params.fp_msix_cnt = num_l2_queues;
+	} else {
+		cdev->int_params.rdma_msix_cnt = 0;
+	}
+
+	DP_VERBOSE(cdev, QED_MSG_RDMA, "roce_msix_cnt=%d roce_msix_base=%d\n",
+		   cdev->int_params.rdma_msix_cnt,
+		   cdev->int_params.rdma_msix_base);
+#endif
+
 	return 0;
 }
 
@@ -810,6 +843,13 @@ static void qed_update_pf_params(struct qed_dev *cdev,
 {
 	int i;
 
+#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
+	params->rdma_pf_params.num_qps = QED_ROCE_QPS;
+	params->rdma_pf_params.min_dpis = QED_ROCE_DPIS;
+	/* divide by 3 the MRs to avoid MF ILT overflow */
+	params->rdma_pf_params.num_mrs = RDMA_MAX_TIDS;
+	params->rdma_pf_params.gl_pi = QED_ROCE_PROTOCOL_INDEX;
+#endif
 	for (i = 0; i < cdev->num_hwfns; i++) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index e75738d..b414a05 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -1448,5 +1448,11 @@
 	0x620000UL
 #define PHY_PCIE_REG_PHY1 \
 	0x624000UL
-
+#define NIG_REG_ROCE_DUPLICATE_TO_HOST 0x5088f0UL
+#define PRS_REG_LIGHT_L2_ETHERTYPE_EN 0x1f0968UL
+#define NIG_REG_LLH_ENG_CLS_ENG_ID_TBL 0x501b90UL
+#define DORQ_REG_PF_DPM_ENABLE 0x100510UL
+#define DORQ_REG_PF_ICID_BIT_SHIFT_NORM	0x100448UL
+#define DORQ_REG_PF_MIN_ADDR_REG1 0x100400UL
+#define DORQ_REG_PF_DPI_BIT_SHIFT 0x100450UL
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
new file mode 100644
index 0000000..e65a130
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -0,0 +1,887 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015-2016  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/io.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/tcp.h>
+#include <linux/bitops.h>
+#include <linux/qed/qed_roce_if.h>
+#include <linux/qed/qed_roce_if.h>
+#include "qed.h"
+#include "qed_cxt.h"
+#include "qed_hsi.h"
+#include "qed_hw.h"
+#include "qed_init_ops.h"
+#include "qed_int.h"
+#include "qed_ll2.h"
+#include "qed_mcp.h"
+#include "qed_reg_addr.h"
+#include "qed_sp.h"
+#include "qed_roce.h"
+
+void qed_async_roce_event(struct qed_hwfn *p_hwfn,
+			  struct event_ring_entry *p_eqe)
+{
+	struct qed_rdma_info *p_rdma_info = p_hwfn->p_rdma_info;
+
+	p_rdma_info->events.affiliated_event(p_rdma_info->events.context,
+					     p_eqe->opcode, &p_eqe->data);
+}
+
+static int qed_rdma_bmap_alloc(struct qed_hwfn *p_hwfn,
+			       struct qed_bmap *bmap, u32 max_count)
+{
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "max_count = %08x\n", max_count);
+
+	bmap->max_count = max_count;
+
+	bmap->bitmap = kzalloc(BITS_TO_LONGS(max_count) * sizeof(long),
+			       GFP_KERNEL);
+	if (!bmap->bitmap) {
+		DP_NOTICE(p_hwfn,
+			  "qed bmap alloc failed: cannot allocate memory (bitmap)\n");
+		return -ENOMEM;
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Allocated bitmap %p\n",
+		   bmap->bitmap);
+	return 0;
+}
+
+static int qed_rdma_bmap_alloc_id(struct qed_hwfn *p_hwfn,
+				  struct qed_bmap *bmap, u32 *id_num)
+{
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "bmap = %p\n", bmap);
+
+	*id_num = find_first_zero_bit(bmap->bitmap, bmap->max_count);
+
+	if (*id_num >= bmap->max_count) {
+		DP_NOTICE(p_hwfn, "no id available max_count=%d\n",
+			  bmap->max_count);
+		return -EINVAL;
+	}
+
+	__set_bit(*id_num, bmap->bitmap);
+
+	return 0;
+}
+
+static void qed_bmap_release_id(struct qed_hwfn *p_hwfn,
+				struct qed_bmap *bmap, u32 id_num)
+{
+	bool b_acquired;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "id_num = %08x", id_num);
+	if (id_num >= bmap->max_count)
+		return;
+
+	b_acquired = test_and_clear_bit(id_num, bmap->bitmap);
+	if (!b_acquired) {
+		DP_NOTICE(p_hwfn, "ID %d already released\n", id_num);
+		return;
+	}
+}
+
+u32 qed_rdma_get_sb_id(void *p_hwfn, u32 rel_sb_id)
+{
+	/* First sb id for RoCE is after all the l2 sb */
+	return FEAT_NUM((struct qed_hwfn *)p_hwfn, QED_PF_L2_QUE) + rel_sb_id;
+}
+
+u32 qed_rdma_query_cau_timer_res(void *rdma_cxt)
+{
+	return QED_CAU_DEF_RX_TIMER_RES;
+}
+
+static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt,
+			  struct qed_rdma_start_in_params *params)
+{
+	struct qed_rdma_info *p_rdma_info;
+	u32 num_cons, num_tasks;
+	int rc = -ENOMEM;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Allocating RDMA\n");
+
+	/* Allocate a struct with current pf rdma info */
+	p_rdma_info = kzalloc(sizeof(*p_rdma_info), GFP_KERNEL);
+	if (!p_rdma_info) {
+		DP_NOTICE(p_hwfn,
+			  "qed rdma alloc failed: cannot allocate memory (rdma info). rc = %d\n",
+			  rc);
+		return rc;
+	}
+
+	p_rdma_info = p_rdma_info;
+	p_rdma_info->proto = PROTOCOLID_ROCE;
+
+	num_cons = qed_cxt_get_proto_cid_count(p_hwfn, p_rdma_info->proto, 0);
+
+	p_rdma_info->num_qps = num_cons / 2;
+
+	num_tasks = qed_cxt_get_proto_tid_count(p_hwfn, PROTOCOLID_ROCE);
+
+	/* Each MR uses a single task */
+	p_rdma_info->num_mrs = num_tasks;
+
+	/* Queue zone lines are shared between RoCE and L2 in such a way that
+	 * they can be used by each without obstructing the other.
+	 */
+	p_rdma_info->queue_zone_base = (u16)FEAT_NUM(p_hwfn, QED_L2_QUEUE);
+
+	/* Allocate a struct with device params and fill it */
+	p_rdma_info->dev = kzalloc(sizeof(*p_rdma_info->dev), GFP_KERNEL);
+	if (!p_rdma_info->dev) {
+		DP_NOTICE(p_hwfn,
+			  "qed rdma alloc failed: cannot allocate memory (rdma info dev). rc = %d\n",
+			  rc);
+		goto free_rdma_info;
+	}
+
+	/* Allocate a struct with port params and fill it */
+	p_rdma_info->port = kzalloc(sizeof(*p_rdma_info->port), GFP_KERNEL);
+	if (!p_rdma_info->port) {
+		DP_NOTICE(p_hwfn,
+			  "qed rdma alloc failed: cannot allocate memory (rdma info port). rc = %d\n",
+			  rc);
+		goto free_rdma_dev;
+	}
+
+	/* Allocate bit map for pd's */
+	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->pd_map, RDMA_MAX_PDS);
+	if (rc) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+			   "Failed to allocate pd_map, rc = %d\n",
+			   rc);
+		goto free_rdma_port;
+	}
+
+	/* Allocate DPI bitmap */
+	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->dpi_map,
+				 p_hwfn->dpi_count);
+	if (rc) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+			   "Failed to allocate DPI bitmap, rc = %d\n", rc);
+		goto free_pd_map;
+	}
+
+	/* Allocate bitmap for cq's. The maximum number of CQs is bounded to
+	 * twice the number of QPs.
+	 */
+	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->cq_map,
+				 p_rdma_info->num_qps * 2);
+	if (rc) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+			   "Failed to allocate cq bitmap, rc = %d\n", rc);
+		goto free_dpi_map;
+	}
+
+	/* Allocate bitmap for toggle bit for cq icids
+	 * We toggle the bit every time we create or resize cq for a given icid.
+	 * The maximum number of CQs is bounded to  twice the number of QPs.
+	 */
+	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->toggle_bits,
+				 p_rdma_info->num_qps * 2);
+	if (rc) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+			   "Failed to allocate toogle bits, rc = %d\n", rc);
+		goto free_cq_map;
+	}
+
+	/* Allocate bitmap for itids */
+	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->tid_map,
+				 p_rdma_info->num_mrs);
+	if (rc) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+			   "Failed to allocate itids bitmaps, rc = %d\n", rc);
+		goto free_toggle_map;
+	}
+
+	/* Allocate bitmap for cids used for qps. */
+	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->cid_map, num_cons);
+	if (rc) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+			   "Failed to allocate cid bitmap, rc = %d\n", rc);
+		goto free_tid_map;
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Allocation successful\n");
+	return 0;
+
+free_tid_map:
+	kfree(p_rdma_info->tid_map.bitmap);
+free_toggle_map:
+	kfree(p_rdma_info->toggle_bits.bitmap);
+free_cq_map:
+	kfree(p_rdma_info->cq_map.bitmap);
+free_dpi_map:
+	kfree(p_rdma_info->dpi_map.bitmap);
+free_pd_map:
+	kfree(p_rdma_info->pd_map.bitmap);
+free_rdma_port:
+	kfree(p_rdma_info->port);
+free_rdma_dev:
+	kfree(p_rdma_info->dev);
+free_rdma_info:
+	kfree(p_rdma_info);
+
+	return rc;
+}
+
+void qed_rdma_resc_free(struct qed_hwfn *p_hwfn)
+{
+	struct qed_rdma_info *p_rdma_info = p_hwfn->p_rdma_info;
+
+	kfree(p_rdma_info->cid_map.bitmap);
+	kfree(p_rdma_info->tid_map.bitmap);
+	kfree(p_rdma_info->toggle_bits.bitmap);
+	kfree(p_rdma_info->cq_map.bitmap);
+	kfree(p_rdma_info->dpi_map.bitmap);
+	kfree(p_rdma_info->pd_map.bitmap);
+
+	kfree(p_rdma_info->port);
+	kfree(p_rdma_info->dev);
+
+	kfree(p_rdma_info);
+}
+
+static void qed_rdma_free(struct qed_hwfn *p_hwfn)
+{
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Freeing RDMA\n");
+
+	qed_rdma_resc_free(p_hwfn);
+}
+
+static void qed_rdma_get_guid(struct qed_hwfn *p_hwfn, u8 *guid)
+{
+	guid[0] = p_hwfn->hw_info.hw_mac_addr[0] ^ 2;
+	guid[1] = p_hwfn->hw_info.hw_mac_addr[1];
+	guid[2] = p_hwfn->hw_info.hw_mac_addr[2];
+	guid[3] = 0xff;
+	guid[4] = 0xfe;
+	guid[5] = p_hwfn->hw_info.hw_mac_addr[3];
+	guid[6] = p_hwfn->hw_info.hw_mac_addr[4];
+	guid[7] = p_hwfn->hw_info.hw_mac_addr[5];
+}
+
+static void qed_rdma_init_events(struct qed_hwfn *p_hwfn,
+				 struct qed_rdma_start_in_params *params)
+{
+	struct qed_rdma_events *events;
+
+	events = &p_hwfn->p_rdma_info->events;
+
+	events->unaffiliated_event = params->events->unaffiliated_event;
+	events->affiliated_event = params->events->affiliated_event;
+	events->context = params->events->context;
+}
+
+static void qed_rdma_init_devinfo(struct qed_hwfn *p_hwfn,
+				  struct qed_rdma_start_in_params *params)
+{
+	struct qed_rdma_device *dev = p_hwfn->p_rdma_info->dev;
+	struct qed_dev *cdev = p_hwfn->cdev;
+	u32 pci_status_control;
+	u32 num_qps;
+
+	/* Vendor specific information */
+	dev->vendor_id = cdev->vendor_id;
+	dev->vendor_part_id = cdev->device_id;
+	dev->hw_ver = 0;
+	dev->fw_ver = (FW_MAJOR_VERSION << 24) | (FW_MINOR_VERSION << 16) |
+		      (FW_REVISION_VERSION << 8) | (FW_ENGINEERING_VERSION);
+
+	qed_rdma_get_guid(p_hwfn, (u8 *)&dev->sys_image_guid);
+	dev->node_guid = dev->sys_image_guid;
+
+	dev->max_sge = min_t(u32, RDMA_MAX_SGE_PER_SQ_WQE,
+			     RDMA_MAX_SGE_PER_RQ_WQE);
+
+	if (cdev->rdma_max_sge)
+		dev->max_sge = min_t(u32, cdev->rdma_max_sge, dev->max_sge);
+
+	dev->max_inline = ROCE_REQ_MAX_INLINE_DATA_SIZE;
+
+	dev->max_inline = (cdev->rdma_max_inline) ?
+			  min_t(u32, cdev->rdma_max_inline, dev->max_inline) :
+			  dev->max_inline;
+
+	dev->max_wqe = QED_RDMA_MAX_WQE;
+	dev->max_cnq = (u8)FEAT_NUM(p_hwfn, QED_RDMA_CNQ);
+
+	/* The number of QPs may be higher than QED_ROCE_MAX_QPS. because
+	 * it is up-aligned to 16 and then to ILT page size within qed cxt.
+	 * This is OK in terms of ILT but we don't want to configure the FW
+	 * above its abilities
+	 */
+	num_qps = ROCE_MAX_QPS;
+	num_qps = min_t(u64, num_qps, p_hwfn->p_rdma_info->num_qps);
+	dev->max_qp = num_qps;
+
+	/* CQs uses the same icids that QPs use hence they are limited by the
+	 * number of icids. There are two icids per QP.
+	 */
+	dev->max_cq = num_qps * 2;
+
+	/* The number of mrs is smaller by 1 since the first is reserved */
+	dev->max_mr = p_hwfn->p_rdma_info->num_mrs - 1;
+	dev->max_mr_size = QED_RDMA_MAX_MR_SIZE;
+
+	/* The maximum CQE capacity per CQ supported.
+	 * max number of cqes will be in two layer pbl,
+	 * 8 is the pointer size in bytes
+	 * 32 is the size of cq element in bytes
+	 */
+	if (params->cq_mode == QED_RDMA_CQ_MODE_32_BITS)
+		dev->max_cqe = QED_RDMA_MAX_CQE_32_BIT;
+	else
+		dev->max_cqe = QED_RDMA_MAX_CQE_16_BIT;
+
+	dev->max_mw = 0;
+	dev->max_fmr = QED_RDMA_MAX_FMR;
+	dev->max_mr_mw_fmr_pbl = (PAGE_SIZE / 8) * (PAGE_SIZE / 8);
+	dev->max_mr_mw_fmr_size = dev->max_mr_mw_fmr_pbl * PAGE_SIZE;
+	dev->max_pkey = QED_RDMA_MAX_P_KEY;
+
+	dev->max_qp_resp_rd_atomic_resc = RDMA_RING_PAGE_SIZE /
+					  (RDMA_RESP_RD_ATOMIC_ELM_SIZE * 2);
+	dev->max_qp_req_rd_atomic_resc = RDMA_RING_PAGE_SIZE /
+					 RDMA_REQ_RD_ATOMIC_ELM_SIZE;
+	dev->max_dev_resp_rd_atomic_resc = dev->max_qp_resp_rd_atomic_resc *
+					   p_hwfn->p_rdma_info->num_qps;
+	dev->page_size_caps = QED_RDMA_PAGE_SIZE_CAPS;
+	dev->dev_ack_delay = QED_RDMA_ACK_DELAY;
+	dev->max_pd = RDMA_MAX_PDS;
+	dev->max_ah = p_hwfn->p_rdma_info->num_qps;
+	dev->max_stats_queues = (u8)RESC_NUM(p_hwfn, QED_RDMA_STATS_QUEUE);
+
+	/* Set capablities */
+	dev->dev_caps = 0;
+	SET_FIELD(dev->dev_caps, QED_RDMA_DEV_CAP_RNR_NAK, 1);
+	SET_FIELD(dev->dev_caps, QED_RDMA_DEV_CAP_PORT_ACTIVE_EVENT, 1);
+	SET_FIELD(dev->dev_caps, QED_RDMA_DEV_CAP_PORT_CHANGE_EVENT, 1);
+	SET_FIELD(dev->dev_caps, QED_RDMA_DEV_CAP_RESIZE_CQ, 1);
+	SET_FIELD(dev->dev_caps, QED_RDMA_DEV_CAP_BASE_MEMORY_EXT, 1);
+	SET_FIELD(dev->dev_caps, QED_RDMA_DEV_CAP_BASE_QUEUE_EXT, 1);
+	SET_FIELD(dev->dev_caps, QED_RDMA_DEV_CAP_ZBVA, 1);
+	SET_FIELD(dev->dev_caps, QED_RDMA_DEV_CAP_LOCAL_INV_FENCE, 1);
+
+	/* Check atomic operations support in PCI configuration space. */
+	pci_read_config_dword(cdev->pdev,
+			      cdev->pdev->pcie_cap + PCI_EXP_DEVCTL2,
+			      &pci_status_control);
+
+	if (pci_status_control & PCI_EXP_DEVCTL2_LTR_EN)
+		SET_FIELD(dev->dev_caps, QED_RDMA_DEV_CAP_ATOMIC_OP, 1);
+}
+
+static void qed_rdma_init_port(struct qed_hwfn *p_hwfn)
+{
+	struct qed_rdma_port *port = p_hwfn->p_rdma_info->port;
+	struct qed_rdma_device *dev = p_hwfn->p_rdma_info->dev;
+
+	port->port_state = p_hwfn->mcp_info->link_output.link_up ?
+			   QED_RDMA_PORT_UP : QED_RDMA_PORT_DOWN;
+
+	port->max_msg_size = min_t(u64,
+				   (dev->max_mr_mw_fmr_size *
+				    p_hwfn->cdev->rdma_max_sge),
+				   BIT(31));
+
+	port->pkey_bad_counter = 0;
+}
+
+static int qed_rdma_init_hw(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	u32 ll2_ethertype_en;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Initializing HW\n");
+	p_hwfn->b_rdma_enabled_in_prs = false;
+
+	qed_wr(p_hwfn, p_ptt, PRS_REG_ROCE_DEST_QP_MAX_PF, 0);
+
+	p_hwfn->rdma_prs_search_reg = PRS_REG_SEARCH_ROCE;
+
+	/* We delay writing to this reg until first cid is allocated. See
+	 * qed_cxt_dynamic_ilt_alloc function for more details
+	 */
+	ll2_ethertype_en = qed_rd(p_hwfn, p_ptt, PRS_REG_LIGHT_L2_ETHERTYPE_EN);
+	qed_wr(p_hwfn, p_ptt, PRS_REG_LIGHT_L2_ETHERTYPE_EN,
+	       (ll2_ethertype_en | 0x01));
+
+	if (qed_cxt_get_proto_cid_start(p_hwfn, PROTOCOLID_ROCE) % 2) {
+		DP_NOTICE(p_hwfn, "The first RoCE's cid should be even\n");
+		return -EINVAL;
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Initializing HW - Done\n");
+	return 0;
+}
+
+static int qed_rdma_start_fw(struct qed_hwfn *p_hwfn,
+			     struct qed_rdma_start_in_params *params,
+			     struct qed_ptt *p_ptt)
+{
+	struct rdma_init_func_ramrod_data *p_ramrod;
+	struct qed_rdma_cnq_params *p_cnq_pbl_list;
+	struct rdma_init_func_hdr *p_params_header;
+	struct rdma_cnq_params *p_cnq_params;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	u32 cnq_id, sb_id;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Starting FW\n");
+
+	/* Save the number of cnqs for the function close ramrod */
+	p_hwfn->p_rdma_info->num_cnqs = params->desired_cnq;
+
+	/* Start Roce */
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent, RDMA_RAMROD_FUNC_INIT,
+				 p_hwfn->p_rdma_info->proto, &init_data);
+	if (rc)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.roce_init_func.rdma;
+
+	p_params_header = &p_ramrod->params_header;
+	p_params_header->cnq_start_offset = (u8)RESC_START(p_hwfn,
+							   QED_RDMA_CNQ_RAM);
+	p_params_header->num_cnqs = params->desired_cnq;
+
+	if (params->cq_mode == QED_RDMA_CQ_MODE_16_BITS)
+		p_params_header->cq_ring_mode = 1;
+	else
+		p_params_header->cq_ring_mode = 0;
+
+	for (cnq_id = 0; cnq_id < params->desired_cnq; cnq_id++) {
+		sb_id = qed_rdma_get_sb_id(p_hwfn, cnq_id);
+		p_cnq_params = &p_ramrod->cnq_params[cnq_id];
+		p_cnq_pbl_list = &params->cnq_pbl_list[cnq_id];
+		p_cnq_params->sb_num =
+			cpu_to_le16(p_hwfn->sbs_info[sb_id]->igu_sb_id);
+
+		p_cnq_params->sb_index = p_hwfn->pf_params.rdma_pf_params.gl_pi;
+		p_cnq_params->num_pbl_pages = p_cnq_pbl_list->num_pbl_pages;
+
+		DMA_REGPAIR_LE(p_cnq_params->pbl_base_addr,
+			       p_cnq_pbl_list->pbl_ptr);
+
+		/* we assume here that cnq_id and qz_offset are the same */
+		p_cnq_params->queue_zone_num =
+			cpu_to_le16(p_hwfn->p_rdma_info->queue_zone_base +
+				    cnq_id);
+	}
+
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
+
+static int qed_rdma_reserve_lkey(struct qed_hwfn *p_hwfn)
+{
+	struct qed_rdma_device *dev = p_hwfn->p_rdma_info->dev;
+
+	/* The first DPI is reserved for the Kernel */
+	__set_bit(0, p_hwfn->p_rdma_info->dpi_map.bitmap);
+
+	/* Tid 0 will be used as the key for "reserved MR".
+	 * The driver should allocate memory for it so it can be loaded but no
+	 * ramrod should be passed on it.
+	 */
+	qed_rdma_alloc_tid(p_hwfn, &dev->reserved_lkey);
+	if (dev->reserved_lkey != RDMA_RESERVED_LKEY) {
+		DP_NOTICE(p_hwfn,
+			  "Reserved lkey should be equal to RDMA_RESERVED_LKEY\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int qed_rdma_setup(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt,
+			  struct qed_rdma_start_in_params *params)
+{
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "RDMA setup\n");
+
+	spin_lock_init(&p_hwfn->p_rdma_info->lock);
+
+	qed_rdma_init_devinfo(p_hwfn, params);
+	qed_rdma_init_port(p_hwfn);
+	qed_rdma_init_events(p_hwfn, params);
+
+	rc = qed_rdma_reserve_lkey(p_hwfn);
+	if (rc)
+		return rc;
+
+	rc = qed_rdma_init_hw(p_hwfn, p_ptt);
+	if (rc)
+		return rc;
+
+	return qed_rdma_start_fw(p_hwfn, params, p_ptt);
+}
+
+int qed_rdma_stop(void *rdma_cxt)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	struct rdma_close_func_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	struct qed_ptt *p_ptt;
+	u32 ll2_ethertype_en;
+	int rc = -EBUSY;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "RDMA stop\n");
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Failed to acquire PTT\n");
+		return rc;
+	}
+
+	/* Disable RoCE search */
+	qed_wr(p_hwfn, p_ptt, p_hwfn->rdma_prs_search_reg, 0);
+	p_hwfn->b_rdma_enabled_in_prs = false;
+
+	qed_wr(p_hwfn, p_ptt, PRS_REG_ROCE_DEST_QP_MAX_PF, 0);
+
+	ll2_ethertype_en = qed_rd(p_hwfn, p_ptt, PRS_REG_LIGHT_L2_ETHERTYPE_EN);
+
+	qed_wr(p_hwfn, p_ptt, PRS_REG_LIGHT_L2_ETHERTYPE_EN,
+	       (ll2_ethertype_en & 0xFFFE));
+
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	/* Stop RoCE */
+	rc = qed_sp_init_request(p_hwfn, &p_ent, RDMA_RAMROD_FUNC_CLOSE,
+				 p_hwfn->p_rdma_info->proto, &init_data);
+	if (rc)
+		goto out;
+
+	p_ramrod = &p_ent->ramrod.rdma_close_func;
+
+	p_ramrod->num_cnqs = p_hwfn->p_rdma_info->num_cnqs;
+	p_ramrod->cnq_start_offset = (u8)RESC_START(p_hwfn, QED_RDMA_CNQ_RAM);
+
+	rc = qed_spq_post(p_hwfn, p_ent, NULL);
+
+out:
+	qed_rdma_free(p_hwfn);
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "RDMA stop done, rc = %d\n", rc);
+	return rc;
+}
+
+int qed_rdma_add_user(void *rdma_cxt,
+		      struct qed_rdma_add_user_out_params *out_params)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	u32 dpi_start_offset;
+	u32 returned_id = 0;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Adding User\n");
+
+	/* Allocate DPI */
+	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+	rc = qed_rdma_bmap_alloc_id(p_hwfn, &p_hwfn->p_rdma_info->dpi_map,
+				    &returned_id);
+	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
+
+	out_params->dpi = (u16)returned_id;
+
+	/* Calculate the corresponding DPI address */
+	dpi_start_offset = p_hwfn->dpi_start_offset;
+
+	out_params->dpi_addr = (u64)((u8 __iomem *)p_hwfn->doorbells +
+				     dpi_start_offset +
+				     ((out_params->dpi) * p_hwfn->dpi_size));
+
+	out_params->dpi_phys_addr = p_hwfn->cdev->db_phys_addr +
+				    dpi_start_offset +
+				    ((out_params->dpi) * p_hwfn->dpi_size);
+
+	out_params->dpi_size = p_hwfn->dpi_size;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Adding user - done, rc = %d\n", rc);
+	return rc;
+}
+
+struct qed_rdma_device *qed_rdma_query_device(void *rdma_cxt)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Query device\n");
+
+	/* Return struct with device parameters */
+	return p_hwfn->p_rdma_info->dev;
+}
+
+int qed_rdma_alloc_tid(void *rdma_cxt, u32 *itid)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Allocate TID\n");
+
+	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+	rc = qed_rdma_bmap_alloc_id(p_hwfn,
+				    &p_hwfn->p_rdma_info->tid_map, itid);
+	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
+	if (rc)
+		goto out;
+
+	rc = qed_cxt_dynamic_ilt_alloc(p_hwfn, QED_ELEM_TASK, *itid);
+out:
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Allocate TID - done, rc = %d\n", rc);
+	return rc;
+}
+
+void qed_rdma_cnq_prod_update(void *rdma_cxt, u8 qz_offset, u16 prod)
+{
+	struct qed_hwfn *p_hwfn;
+	u16 qz_num;
+	u32 addr;
+
+	p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	qz_num = p_hwfn->p_rdma_info->queue_zone_base + qz_offset;
+	addr = GTT_BAR0_MAP_REG_USDM_RAM +
+	       USTORM_COMMON_QUEUE_CONS_OFFSET(qz_num);
+
+	REG_WR16(p_hwfn, addr, prod);
+
+	/* keep prod updates ordered */
+	wmb();
+}
+
+static int qed_fill_rdma_dev_info(struct qed_dev *cdev,
+				  struct qed_dev_rdma_info *info)
+{
+	memset(info, 0, sizeof(*info));
+
+	info->rdma_type = QED_RDMA_TYPE_ROCE;
+
+	qed_fill_dev_info(cdev, &info->common);
+
+	return 0;
+}
+
+static int qed_rdma_get_sb_start(struct qed_dev *cdev)
+{
+	int feat_num;
+
+	if (cdev->num_hwfns > 1)
+		feat_num = FEAT_NUM(QED_LEADING_HWFN(cdev), QED_PF_L2_QUE);
+	else
+		feat_num = FEAT_NUM(QED_LEADING_HWFN(cdev), QED_PF_L2_QUE) *
+			   cdev->num_hwfns;
+
+	return feat_num;
+}
+
+static int qed_rdma_get_min_cnq_msix(struct qed_dev *cdev)
+{
+	int n_cnq = FEAT_NUM(QED_LEADING_HWFN(cdev), QED_RDMA_CNQ);
+	int n_msix = cdev->int_params.rdma_msix_cnt;
+
+	return min_t(int, n_cnq, n_msix);
+}
+
+static int qed_rdma_set_int(struct qed_dev *cdev, u16 cnt)
+{
+	int limit = 0;
+
+	/* Mark the fastpath as free/used */
+	cdev->int_params.fp_initialized = cnt ? true : false;
+
+	if (cdev->int_params.out.int_mode != QED_INT_MODE_MSIX) {
+		DP_ERR(cdev,
+		       "qed roce supports only MSI-X interrupts (detected %d).\n",
+		       cdev->int_params.out.int_mode);
+		return -EINVAL;
+	} else if (cdev->int_params.fp_msix_cnt) {
+		limit = cdev->int_params.rdma_msix_cnt;
+	}
+
+	if (!limit)
+		return -ENOMEM;
+
+	return min_t(int, cnt, limit);
+}
+
+static int qed_rdma_get_int(struct qed_dev *cdev, struct qed_int_info *info)
+{
+	memset(info, 0, sizeof(*info));
+
+	if (!cdev->int_params.fp_initialized) {
+		DP_INFO(cdev,
+			"Protocol driver requested interrupt information, but its support is not yet configured\n");
+		return -EINVAL;
+	}
+
+	if (cdev->int_params.out.int_mode == QED_INT_MODE_MSIX) {
+		int msix_base = cdev->int_params.rdma_msix_base;
+
+		info->msix_cnt = cdev->int_params.rdma_msix_cnt;
+		info->msix = &cdev->int_params.msix_table[msix_base];
+
+		DP_VERBOSE(cdev, QED_MSG_RDMA, "msix_cnt = %d msix_base=%d\n",
+			   info->msix_cnt, msix_base);
+	}
+
+	return 0;
+}
+
+static void *qed_rdma_get_rdma_ctx(struct qed_dev *cdev)
+{
+	return QED_LEADING_HWFN(cdev);
+}
+
+static void qed_rdma_dpm_conf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	u32 val;
+
+	val = ((p_hwfn->dcbx_no_edpm) || (p_hwfn->db_bar_no_edpm)) ? 0 : 1;
+
+	qed_wr(p_hwfn, p_ptt, DORQ_REG_PF_DPM_ENABLE, val);
+	DP_VERBOSE(p_hwfn, (QED_MSG_DCB | QED_MSG_RDMA),
+		   "Changing DPM_EN state to %d (DCBX=%d, DB_BAR=%d)\n",
+		   val, p_hwfn->dcbx_no_edpm, p_hwfn->db_bar_no_edpm);
+}
+
+void qed_rdma_dpm_bar(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	p_hwfn->db_bar_no_edpm = true;
+
+	qed_rdma_dpm_conf(p_hwfn, p_ptt);
+}
+
+int qed_rdma_start(void *rdma_cxt, struct qed_rdma_start_in_params *params)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	struct qed_ptt *p_ptt;
+	int rc = -EBUSY;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+		   "desired_cnq = %08x\n", params->desired_cnq);
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		goto err;
+
+	rc = qed_rdma_alloc(p_hwfn, p_ptt, params);
+	if (rc)
+		goto err1;
+
+	rc = qed_rdma_setup(p_hwfn, p_ptt, params);
+	if (rc)
+		goto err2;
+
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return rc;
+
+err2:
+	qed_rdma_free(p_hwfn);
+err1:
+	qed_ptt_release(p_hwfn, p_ptt);
+err:
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "RDMA start - error, rc = %d\n", rc);
+	return rc;
+}
+
+static int qed_rdma_init(struct qed_dev *cdev,
+			 struct qed_rdma_start_in_params *params)
+{
+	return qed_rdma_start(QED_LEADING_HWFN(cdev), params);
+}
+
+void qed_rdma_remove_user(void *rdma_cxt, u16 dpi)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "dpi = %08x\n", dpi);
+
+	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+	qed_bmap_release_id(p_hwfn, &p_hwfn->p_rdma_info->dpi_map, dpi);
+	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
+}
+
+static const struct qed_rdma_ops qed_rdma_ops_pass = {
+	.common = &qed_common_ops_pass,
+	.fill_dev_info = &qed_fill_rdma_dev_info,
+	.rdma_get_rdma_ctx = &qed_rdma_get_rdma_ctx,
+	.rdma_init = &qed_rdma_init,
+	.rdma_add_user = &qed_rdma_add_user,
+	.rdma_remove_user = &qed_rdma_remove_user,
+	.rdma_stop = &qed_rdma_stop,
+	.rdma_query_device = &qed_rdma_query_device,
+	.rdma_get_start_sb = &qed_rdma_get_sb_start,
+	.rdma_get_rdma_int = &qed_rdma_get_int,
+	.rdma_set_rdma_int = &qed_rdma_set_int,
+	.rdma_get_min_cnq_msix = &qed_rdma_get_min_cnq_msix,
+	.rdma_cnq_prod_update = &qed_rdma_cnq_prod_update,
+};
+
+const struct qed_rdma_ops *qed_get_rdma_ops()
+{
+	return &qed_rdma_ops_pass;
+}
+EXPORT_SYMBOL(qed_get_rdma_ops);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.h b/drivers/net/ethernet/qlogic/qed/qed_roce.h
new file mode 100644
index 0000000..46f14b2
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.h
@@ -0,0 +1,117 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015-2016  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#ifndef _QED_ROCE_H
+#define _QED_ROCE_H
+#include <linux/types.h>
+#include <linux/bitops.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/qed/qed_if.h>
+#include <linux/qed/qed_roce_if.h>
+#include "qed.h"
+#include "qed_dev_api.h"
+#include "qed_hsi.h"
+
+#define QED_RDMA_MAX_FMR                    (RDMA_MAX_TIDS)
+#define QED_RDMA_MAX_P_KEY                  (1)
+#define QED_RDMA_MAX_WQE                    (0x7FFF)
+#define QED_RDMA_MAX_SRQ_WQE_ELEM           (0x7FFF)
+#define QED_RDMA_PAGE_SIZE_CAPS             (0xFFFFF000)
+#define QED_RDMA_ACK_DELAY                  (15)
+#define QED_RDMA_MAX_MR_SIZE                (0x10000000000ULL)
+#define QED_RDMA_MAX_CQS                    (RDMA_MAX_CQS)
+#define QED_RDMA_MAX_MRS                    (RDMA_MAX_TIDS)
+/* Add 1 for header element */
+#define QED_RDMA_MAX_SRQ_ELEM_PER_WQE	    (RDMA_MAX_SGE_PER_RQ_WQE + 1)
+#define QED_RDMA_MAX_SGE_PER_SRQ_WQE        (RDMA_MAX_SGE_PER_RQ_WQE)
+#define QED_RDMA_SRQ_WQE_ELEM_SIZE          (16)
+#define QED_RDMA_MAX_SRQS                   (32 * 1024)
+
+#define QED_RDMA_MAX_CQE_32_BIT             (0x7FFFFFFF - 1)
+#define QED_RDMA_MAX_CQE_16_BIT             (0x7FFF - 1)
+
+enum qed_rdma_toggle_bit {
+	QED_RDMA_TOGGLE_BIT_CLEAR = 0,
+	QED_RDMA_TOGGLE_BIT_SET = 1
+};
+
+struct qed_bmap {
+	unsigned long *bitmap;
+	u32 max_count;
+};
+
+struct qed_rdma_info {
+	/* spin lock to protect bitmaps */
+	spinlock_t lock;
+
+	struct qed_bmap cq_map;
+	struct qed_bmap pd_map;
+	struct qed_bmap tid_map;
+	struct qed_bmap qp_map;
+	struct qed_bmap srq_map;
+	struct qed_bmap cid_map;
+	struct qed_bmap dpi_map;
+	struct qed_bmap toggle_bits;
+	struct qed_rdma_events events;
+	struct qed_rdma_device *dev;
+	struct qed_rdma_port *port;
+	u32 last_tid;
+	u8 num_cnqs;
+	u32 num_qps;
+	u32 num_mrs;
+	u16 queue_zone_base;
+	enum protocol_type proto;
+};
+
+int
+qed_rdma_add_user(void *rdma_cxt,
+		  struct qed_rdma_add_user_out_params *out_params);
+int qed_rdma_alloc_pd(void *rdma_cxt, u16 *pd);
+int qed_rdma_alloc_tid(void *rdma_cxt, u32 *tid);
+int qed_rdma_deregister_tid(void *rdma_cxt, u32 tid);
+void qed_rdma_free_tid(void *rdma_cxt, u32 tid);
+struct qed_rdma_device *qed_rdma_query_device(void *rdma_cxt);
+int
+qed_rdma_register_tid(void *rdma_cxt,
+		      struct qed_rdma_register_tid_in_params *params);
+void qed_rdma_remove_user(void *rdma_cxt, u16 dpi);
+int qed_rdma_start(void *p_hwfn, struct qed_rdma_start_in_params *params);
+int qed_rdma_stop(void *rdma_cxt);
+u32 qed_rdma_get_sb_id(void *p_hwfn, u32 rel_sb_id);
+u32 qed_rdma_query_cau_timer_res(void *p_hwfn);
+void qed_rdma_cnq_prod_update(void *rdma_cxt, u8 cnq_index, u16 prod);
+void qed_rdma_resc_free(struct qed_hwfn *p_hwfn);
+void qed_async_roce_event(struct qed_hwfn *p_hwfn,
+			  struct event_ring_entry *p_eqe);
+#endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index a3c539f..652c908 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -85,6 +85,7 @@ union ramrod_data {
 	struct rdma_srq_create_ramrod_data rdma_create_srq;
 	struct rdma_srq_destroy_ramrod_data rdma_destroy_srq;
 	struct rdma_srq_modify_ramrod_data rdma_modify_srq;
+	struct roce_init_func_ramrod_data roce_init_func;
 
 	struct iscsi_slow_path_hdr iscsi_empty;
 	struct iscsi_init_ramrod_params iscsi_init;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 349af18..caff415 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -28,6 +28,9 @@
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
 #include "qed_sriov.h"
+#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
+#include "qed_roce.h"
+#endif
 
 /***************************************************************************
 * Structures & Definitions
@@ -237,6 +240,11 @@ qed_async_event_completion(struct qed_hwfn *p_hwfn,
 			   struct event_ring_entry *p_eqe)
 {
 	switch (p_eqe->protocol_id) {
+#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
+	case PROTOCOLID_ROCE:
+		qed_async_roce_event(p_hwfn, p_eqe);
+		return 0;
+#endif
 	case PROTOCOLID_COMMON:
 		return qed_sriov_eqe_event(p_hwfn,
 					   p_eqe->opcode,
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index e313742..f9ae903 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -34,6 +34,8 @@ enum dcbx_protocol_type {
 	DCBX_MAX_PROTOCOL_TYPE
 };
 
+#define QED_ROCE_PROTOCOL_INDEX (3)
+
 #ifdef CONFIG_DCB
 #define QED_LLDP_CHASSIS_ID_STAT_LEN 4
 #define QED_LLDP_PORT_ID_STAT_LEN 4
@@ -268,6 +270,7 @@ struct qed_dev_info {
 
 enum qed_sb_type {
 	QED_SB_TYPE_L2_QUEUE,
+	QED_SB_TYPE_CNQ,
 };
 
 enum qed_protocol {
@@ -628,7 +631,7 @@ enum DP_MODULE {
 	QED_MSG_CXT	= 0x800000,
 	QED_MSG_LL2	= 0x1000000,
 	QED_MSG_ILT	= 0x2000000,
-	QED_MSG_ROCE	= 0x4000000,
+	QED_MSG_RDMA	= 0x4000000,
 	QED_MSG_DEBUG	= 0x8000000,
 	/* to be added...up to 0x8000000 */
 };
diff --git a/include/linux/qed/qed_roce_if.h b/include/linux/qed/qed_roce_if.h
new file mode 100644
index 0000000..0f7d527
--- /dev/null
+++ b/include/linux/qed/qed_roce_if.h
@@ -0,0 +1,345 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015-2016  QLogic Corporation
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and /or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#ifndef _QED_ROCE_IF_H
+#define _QED_ROCE_IF_H
+#include <linux/types.h>
+#include <linux/delay.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/qed/qed_if.h>
+#include <linux/qed/qed_ll2_if.h>
+
+#define QED_RDMA_MAX_CNQ_SIZE               (0xFFFF)
+
+/* rdma interface */
+enum qed_rdma_tid_type {
+	QED_RDMA_TID_REGISTERED_MR,
+	QED_RDMA_TID_FMR,
+	QED_RDMA_TID_MW_TYPE1,
+	QED_RDMA_TID_MW_TYPE2A
+};
+
+struct qed_rdma_events {
+	void *context;
+	void (*affiliated_event)(void *context, u8 fw_event_code,
+				 void *fw_handle);
+	void (*unaffiliated_event)(void *context, u8 event_code);
+};
+
+struct qed_rdma_device {
+	u32 vendor_id;
+	u32 vendor_part_id;
+	u32 hw_ver;
+	u64 fw_ver;
+
+	u64 node_guid;
+	u64 sys_image_guid;
+
+	u8 max_cnq;
+	u8 max_sge;
+	u8 max_srq_sge;
+	u16 max_inline;
+	u32 max_wqe;
+	u32 max_srq_wqe;
+	u8 max_qp_resp_rd_atomic_resc;
+	u8 max_qp_req_rd_atomic_resc;
+	u64 max_dev_resp_rd_atomic_resc;
+	u32 max_cq;
+	u32 max_qp;
+	u32 max_srq;
+	u32 max_mr;
+	u64 max_mr_size;
+	u32 max_cqe;
+	u32 max_mw;
+	u32 max_fmr;
+	u32 max_mr_mw_fmr_pbl;
+	u64 max_mr_mw_fmr_size;
+	u32 max_pd;
+	u32 max_ah;
+	u8 max_pkey;
+	u16 max_srq_wr;
+	u8 max_stats_queues;
+	u32 dev_caps;
+
+	/* Abilty to support RNR-NAK generation */
+
+#define QED_RDMA_DEV_CAP_RNR_NAK_MASK                           0x1
+#define QED_RDMA_DEV_CAP_RNR_NAK_SHIFT                  0
+	/* Abilty to support shutdown port */
+#define QED_RDMA_DEV_CAP_SHUTDOWN_PORT_MASK                     0x1
+#define QED_RDMA_DEV_CAP_SHUTDOWN_PORT_SHIFT                    1
+	/* Abilty to support port active event */
+#define QED_RDMA_DEV_CAP_PORT_ACTIVE_EVENT_MASK         0x1
+#define QED_RDMA_DEV_CAP_PORT_ACTIVE_EVENT_SHIFT                2
+	/* Abilty to support port change event */
+#define QED_RDMA_DEV_CAP_PORT_CHANGE_EVENT_MASK         0x1
+#define QED_RDMA_DEV_CAP_PORT_CHANGE_EVENT_SHIFT                3
+	/* Abilty to support system image GUID */
+#define QED_RDMA_DEV_CAP_SYS_IMAGE_MASK                 0x1
+#define QED_RDMA_DEV_CAP_SYS_IMAGE_SHIFT                        4
+	/* Abilty to support bad P_Key counter support */
+#define QED_RDMA_DEV_CAP_BAD_PKEY_CNT_MASK                      0x1
+#define QED_RDMA_DEV_CAP_BAD_PKEY_CNT_SHIFT                     5
+	/* Abilty to support atomic operations */
+#define QED_RDMA_DEV_CAP_ATOMIC_OP_MASK                 0x1
+#define QED_RDMA_DEV_CAP_ATOMIC_OP_SHIFT                        6
+#define QED_RDMA_DEV_CAP_RESIZE_CQ_MASK                 0x1
+#define QED_RDMA_DEV_CAP_RESIZE_CQ_SHIFT                        7
+	/* Abilty to support modifying the maximum number of
+	 * outstanding work requests per QP
+	 */
+#define QED_RDMA_DEV_CAP_RESIZE_MAX_WR_MASK                     0x1
+#define QED_RDMA_DEV_CAP_RESIZE_MAX_WR_SHIFT                    8
+	/* Abilty to support automatic path migration */
+#define QED_RDMA_DEV_CAP_AUTO_PATH_MIG_MASK                     0x1
+#define QED_RDMA_DEV_CAP_AUTO_PATH_MIG_SHIFT                    9
+	/* Abilty to support the base memory management extensions */
+#define QED_RDMA_DEV_CAP_BASE_MEMORY_EXT_MASK                   0x1
+#define QED_RDMA_DEV_CAP_BASE_MEMORY_EXT_SHIFT          10
+#define QED_RDMA_DEV_CAP_BASE_QUEUE_EXT_MASK                    0x1
+#define QED_RDMA_DEV_CAP_BASE_QUEUE_EXT_SHIFT                   11
+	/* Abilty to support multipile page sizes per memory region */
+#define QED_RDMA_DEV_CAP_MULTI_PAGE_PER_MR_EXT_MASK             0x1
+#define QED_RDMA_DEV_CAP_MULTI_PAGE_PER_MR_EXT_SHIFT            12
+	/* Abilty to support block list physical buffer list */
+#define QED_RDMA_DEV_CAP_BLOCK_MODE_MASK                        0x1
+#define QED_RDMA_DEV_CAP_BLOCK_MODE_SHIFT                       13
+	/* Abilty to support zero based virtual addresses */
+#define QED_RDMA_DEV_CAP_ZBVA_MASK                              0x1
+#define QED_RDMA_DEV_CAP_ZBVA_SHIFT                             14
+	/* Abilty to support local invalidate fencing */
+#define QED_RDMA_DEV_CAP_LOCAL_INV_FENCE_MASK                   0x1
+#define QED_RDMA_DEV_CAP_LOCAL_INV_FENCE_SHIFT          15
+	/* Abilty to support Loopback on QP */
+#define QED_RDMA_DEV_CAP_LB_INDICATOR_MASK                      0x1
+#define QED_RDMA_DEV_CAP_LB_INDICATOR_SHIFT                     16
+	u64 page_size_caps;
+	u8 dev_ack_delay;
+	u32 reserved_lkey;
+	u32 bad_pkey_counter;
+	struct qed_rdma_events events;
+};
+
+enum qed_port_state {
+	QED_RDMA_PORT_UP,
+	QED_RDMA_PORT_DOWN,
+};
+
+enum qed_roce_capability {
+	QED_ROCE_V1 = 1 << 0,
+	QED_ROCE_V2 = 1 << 1,
+};
+
+struct qed_rdma_port {
+	enum qed_port_state port_state;
+	int link_speed;
+	u64 max_msg_size;
+	u8 source_gid_table_len;
+	void *source_gid_table_ptr;
+	u8 pkey_table_len;
+	void *pkey_table_ptr;
+	u32 pkey_bad_counter;
+	enum qed_roce_capability capability;
+};
+
+struct qed_rdma_cnq_params {
+	u8 num_pbl_pages;
+	u64 pbl_ptr;
+};
+
+/* The CQ Mode affects the CQ doorbell transaction size.
+ * 64/32 bit machines should configure to 32/16 bits respectively.
+ */
+enum qed_rdma_cq_mode {
+	QED_RDMA_CQ_MODE_16_BITS,
+	QED_RDMA_CQ_MODE_32_BITS,
+};
+
+struct qed_roce_dcqcn_params {
+	u8 notification_point;
+	u8 reaction_point;
+
+	/* fields for notification point */
+	u32 cnp_send_timeout;
+
+	/* fields for reaction point */
+	u32 rl_bc_rate;
+	u16 rl_max_rate;
+	u16 rl_r_ai;
+	u16 rl_r_hai;
+	u16 dcqcn_g;
+	u32 dcqcn_k_us;
+	u32 dcqcn_timeout_us;
+};
+
+struct qed_rdma_start_in_params {
+	struct qed_rdma_events *events;
+	struct qed_rdma_cnq_params cnq_pbl_list[128];
+	u8 desired_cnq;
+	enum qed_rdma_cq_mode cq_mode;
+	struct qed_roce_dcqcn_params dcqcn_params;
+	u16 max_mtu;
+	u8 mac_addr[ETH_ALEN];
+	u8 iwarp_flags;
+};
+
+struct qed_rdma_add_user_out_params {
+	u16 dpi;
+	u64 dpi_addr;
+	u64 dpi_phys_addr;
+	u32 dpi_size;
+};
+
+enum roce_mode {
+	ROCE_V1,
+	ROCE_V2_IPV4,
+	ROCE_V2_IPV6,
+	MAX_ROCE_MODE
+};
+
+union qed_gid {
+	u8 bytes[16];
+	u16 words[8];
+	u32 dwords[4];
+	u64 qwords[2];
+	u32 ipv4_addr;
+};
+
+struct qed_rdma_register_tid_in_params {
+	u32 itid;
+	enum qed_rdma_tid_type tid_type;
+	u8 key;
+	u16 pd;
+	bool local_read;
+	bool local_write;
+	bool remote_read;
+	bool remote_write;
+	bool remote_atomic;
+	bool mw_bind;
+	u64 pbl_ptr;
+	bool pbl_two_level;
+	u8 pbl_page_size_log;
+	u8 page_size_log;
+	u32 fbo;
+	u64 length;
+	u64 vaddr;
+	bool zbva;
+	bool phy_mr;
+	bool dma_mr;
+
+	bool dif_enabled;
+	u64 dif_error_addr;
+	u64 dif_runt_addr;
+};
+
+struct qed_rdma_create_srq_in_params {
+	u64 pbl_base_addr;
+	u64 prod_pair_addr;
+	u16 num_pages;
+	u16 pd_id;
+	u16 page_size;
+};
+
+struct qed_rdma_create_srq_out_params {
+	u16 srq_id;
+};
+
+struct qed_rdma_destroy_srq_in_params {
+	u16 srq_id;
+};
+
+struct qed_rdma_modify_srq_in_params {
+	u32 wqe_limit;
+	u16 srq_id;
+};
+
+struct qed_rdma_stats_out_params {
+	u64 sent_bytes;
+	u64 sent_pkts;
+	u64 rcv_bytes;
+	u64 rcv_pkts;
+};
+
+struct qed_rdma_counters_out_params {
+	u64 pd_count;
+	u64 max_pd;
+	u64 dpi_count;
+	u64 max_dpi;
+	u64 cq_count;
+	u64 max_cq;
+	u64 qp_count;
+	u64 max_qp;
+	u64 tid_count;
+	u64 max_tid;
+};
+
+#define QED_ROCE_TX_HEAD_FAILURE        (1)
+#define QED_ROCE_TX_FRAG_FAILURE        (2)
+
+enum qed_rdma_type {
+	QED_RDMA_TYPE_ROCE,
+};
+
+struct qed_dev_rdma_info {
+	struct qed_dev_info common;
+	enum qed_rdma_type rdma_type;
+};
+
+struct qed_rdma_ops {
+	const struct qed_common_ops *common;
+
+	int (*fill_dev_info)(struct qed_dev *cdev,
+			     struct qed_dev_rdma_info *info);
+	void *(*rdma_get_rdma_ctx)(struct qed_dev *cdev);
+
+	int (*rdma_init)(struct qed_dev *dev,
+			 struct qed_rdma_start_in_params *iparams);
+
+	int (*rdma_add_user)(void *rdma_cxt,
+			     struct qed_rdma_add_user_out_params *oparams);
+
+	void (*rdma_remove_user)(void *rdma_cxt, u16 dpi);
+	int (*rdma_stop)(void *rdma_cxt);
+	struct qed_rdma_device* (*rdma_query_device)(void *rdma_cxt);
+	int (*rdma_get_start_sb)(struct qed_dev *cdev);
+	int (*rdma_get_min_cnq_msix)(struct qed_dev *cdev);
+	void (*rdma_cnq_prod_update)(void *rdma_cxt, u8 cnq_index, u16 prod);
+	int (*rdma_get_rdma_int)(struct qed_dev *cdev,
+				 struct qed_int_info *info);
+	int (*rdma_set_rdma_int)(struct qed_dev *cdev, u16 cnt);
+};
+
+const struct qed_rdma_ops *qed_get_rdma_ops(void);
+
+#endif
-- 
1.8.3.1
