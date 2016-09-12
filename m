From: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Subject: [RFC 07/11] Add support for memory registeration verbs
Date: Mon, 12 Sep 2016 19:07:41 +0300
Message-ID: <1473696465-27986-8-git-send-email-Ram.Amrani@qlogic.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1473696465-27986-1-git-send-email-Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add support for user, dma and memory regions registration.

Signed-off-by: Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/qedr/main.c          |  13 +-
 drivers/infiniband/hw/qedr/qedr.h          |  45 ++++
 drivers/infiniband/hw/qedr/verbs.c         | 385 +++++++++++++++++++++++++++++
 drivers/infiniband/hw/qedr/verbs.h         |  14 ++
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 240 ++++++++++++++++++
 include/linux/qed/qed_roce_if.h            |   6 +
 6 files changed, 702 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/qedr/main.c b/drivers/infiniband/hw/qedr/main.c
index 722b895..3d4feb7 100644
--- a/drivers/infiniband/hw/qedr/main.c
+++ b/drivers/infiniband/hw/qedr/main.c
@@ -106,7 +106,9 @@ static int qedr_register_device(struct qedr_dev *dev)
 				     QEDR_UVERBS(CREATE_QP) |
 				     QEDR_UVERBS(MODIFY_QP) |
 				     QEDR_UVERBS(QUERY_QP) |
-				     QEDR_UVERBS(DESTROY_QP);
+				     QEDR_UVERBS(DESTROY_QP) |
+				     QEDR_UVERBS(REG_MR) |
+				     QEDR_UVERBS(DEREG_MR);
 
 	dev->ibdev.phys_port_cnt = 1;
 	dev->ibdev.num_comp_vectors = dev->num_cnq;
@@ -138,6 +140,15 @@ static int qedr_register_device(struct qedr_dev *dev)
 
 	dev->ibdev.query_pkey = qedr_query_pkey;
 
+	dev->ibdev.create_ah = qedr_create_ah;
+	dev->ibdev.destroy_ah = qedr_destroy_ah;
+
+	dev->ibdev.get_dma_mr = qedr_get_dma_mr;
+	dev->ibdev.dereg_mr = qedr_dereg_mr;
+	dev->ibdev.reg_user_mr = qedr_reg_user_mr;
+	dev->ibdev.alloc_mr = qedr_alloc_mr;
+	dev->ibdev.map_mr_sg = qedr_map_mr_sg;
+
 	dev->ibdev.dma_device = &dev->pdev->dev;
 	dev->ibdev.get_link_layer = qedr_link_layer;
 	dev->ibdev.get_dev_fw_str = qedr_get_dev_fw_str;
diff --git a/drivers/infiniband/hw/qedr/qedr.h b/drivers/infiniband/hw/qedr/qedr.h
index 1c9cc40..3cd4e52 100644
--- a/drivers/infiniband/hw/qedr/qedr.h
+++ b/drivers/infiniband/hw/qedr/qedr.h
@@ -374,6 +374,41 @@ struct qedr_qp {
 	struct qedr_userq urq;
 };
 
+struct qedr_ah {
+	struct ib_ah ibah;
+	struct ib_ah_attr attr;
+};
+
+enum qedr_mr_type {
+	QEDR_MR_USER,
+	QEDR_MR_KERNEL,
+	QEDR_MR_DMA,
+	QEDR_MR_FRMR
+};
+
+struct mr_info {
+	struct qedr_pbl *pbl_table;
+	struct qedr_pbl_info pbl_info;
+	struct list_head free_pbl_list;
+	struct list_head inuse_pbl_list;
+	u32 completed;
+	u32 completed_handled;
+};
+
+struct qedr_mr {
+	struct ib_mr ibmr;
+	struct ib_umem *umem;
+
+	struct qed_rdma_register_tid_in_params hw_mr;
+	enum qedr_mr_type type;
+
+	struct qedr_dev *dev;
+	struct mr_info info;
+
+	u64 *pages;
+	u32 npages;
+};
+
 static inline int qedr_get_dmac(struct qedr_dev *dev,
 				struct ib_ah_attr *ah_attr, u8 *mac_addr)
 {
@@ -417,4 +452,14 @@ static inline struct qedr_qp *get_qedr_qp(struct ib_qp *ibqp)
 {
 	return container_of(ibqp, struct qedr_qp, ibqp);
 }
+
+static inline struct qedr_ah *get_qedr_ah(struct ib_ah *ibah)
+{
+	return container_of(ibah, struct qedr_ah, ibah);
+}
+
+static inline struct qedr_mr *get_qedr_mr(struct ib_mr *ibmr)
+{
+	return container_of(ibmr, struct qedr_mr, ibmr);
+}
 #endif
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index 1d16c34..3d6045c 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -2054,3 +2054,388 @@ int qedr_destroy_qp(struct ib_qp *ibqp)
 
 	return rc;
 }
+
+struct ib_ah *qedr_create_ah(struct ib_pd *ibpd, struct ib_ah_attr *attr)
+{
+	struct qedr_ah *ah = kzalloc(sizeof(*ah), GFP_ATOMIC);
+
+	ah->attr = *attr;
+
+	return &ah->ibah;
+}
+
+int qedr_destroy_ah(struct ib_ah *ibah)
+{
+	struct qedr_ah *ah = get_qedr_ah(ibah);
+
+	kfree(ah);
+	return 0;
+}
+
+static void free_mr_info(struct qedr_dev *dev, struct mr_info *info)
+{
+	struct qedr_pbl *pbl, *tmp;
+
+	if (info->pbl_table)
+		list_add_tail(&info->pbl_table->list_entry,
+			      &info->free_pbl_list);
+
+	if (!list_empty(&info->inuse_pbl_list))
+		list_splice(&info->inuse_pbl_list, &info->free_pbl_list);
+
+	list_for_each_entry_safe(pbl, tmp, &info->free_pbl_list, list_entry) {
+		list_del(&pbl->list_entry);
+		qedr_free_pbl(dev, &info->pbl_info, pbl);
+	}
+}
+
+static int init_mr_info(struct qedr_dev *dev, struct mr_info *info,
+			size_t page_list_len, bool two_layered)
+{
+	struct qedr_pbl *tmp;
+	int rc;
+
+	INIT_LIST_HEAD(&info->free_pbl_list);
+	INIT_LIST_HEAD(&info->inuse_pbl_list);
+
+	rc = qedr_prepare_pbl_tbl(dev, &info->pbl_info,
+				  page_list_len, two_layered);
+	if (rc)
+		goto done;
+
+	info->pbl_table = qedr_alloc_pbl_tbl(dev, &info->pbl_info, GFP_KERNEL);
+	if (!info->pbl_table) {
+		rc = -ENOMEM;
+		goto done;
+	}
+
+	DP_VERBOSE(dev, QEDR_MSG_MR, "pbl_table_pa = %pa\n",
+		   &info->pbl_table->pa);
+
+	/* in usual case we use 2 PBLs, so we add one to free
+	 * list and allocating another one
+	 */
+	tmp = qedr_alloc_pbl_tbl(dev, &info->pbl_info, GFP_KERNEL);
+	if (!tmp) {
+		DP_VERBOSE(dev, QEDR_MSG_MR, "Extra PBL is not allocated\n");
+		goto done;
+	}
+
+	list_add_tail(&tmp->list_entry, &info->free_pbl_list);
+
+	DP_VERBOSE(dev, QEDR_MSG_MR, "extra pbl_table_pa = %pa\n", &tmp->pa);
+
+done:
+	if (rc)
+		free_mr_info(dev, info);
+
+	return rc;
+}
+
+struct ib_mr *qedr_reg_user_mr(struct ib_pd *ibpd, u64 start, u64 len,
+			       u64 usr_addr, int acc, struct ib_udata *udata)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibpd->device);
+	struct qedr_mr *mr;
+	struct qedr_pd *pd;
+	int rc = -ENOMEM;
+
+	pd = get_qedr_pd(ibpd);
+	DP_VERBOSE(dev, QEDR_MSG_MR,
+		   "qedr_register user mr pd = %d start = %lld, len = %lld, usr_addr = %lld, acc = %d\n",
+		   pd->pd_id, start, len, usr_addr, acc);
+
+	if (acc & IB_ACCESS_REMOTE_WRITE && !(acc & IB_ACCESS_LOCAL_WRITE))
+		return ERR_PTR(-EINVAL);
+
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr)
+		return ERR_PTR(rc);
+
+	mr->type = QEDR_MR_USER;
+
+	mr->umem = ib_umem_get(ibpd->uobject->context, start, len, acc, 0);
+	if (IS_ERR(mr->umem)) {
+		rc = -EFAULT;
+		goto err0;
+	}
+
+	rc = init_mr_info(dev, &mr->info, ib_umem_page_count(mr->umem), 1);
+	if (rc)
+		goto err1;
+
+	qedr_populate_pbls(dev, mr->umem, mr->info.pbl_table,
+			   &mr->info.pbl_info);
+
+	rc = dev->ops->rdma_alloc_tid(dev->rdma_ctx, &mr->hw_mr.itid);
+	if (rc) {
+		DP_ERR(dev, "roce alloc tid returned an error %d\n", rc);
+		goto err1;
+	}
+
+	/* Index only, 18 bit long, lkey = itid << 8 | key */
+	mr->hw_mr.tid_type = QED_RDMA_TID_REGISTERED_MR;
+	mr->hw_mr.key = 0;
+	mr->hw_mr.pd = pd->pd_id;
+	mr->hw_mr.local_read = 1;
+	mr->hw_mr.local_write = (acc & IB_ACCESS_LOCAL_WRITE) ? 1 : 0;
+	mr->hw_mr.remote_read = (acc & IB_ACCESS_REMOTE_READ) ? 1 : 0;
+	mr->hw_mr.remote_write = (acc & IB_ACCESS_REMOTE_WRITE) ? 1 : 0;
+	mr->hw_mr.remote_atomic = (acc & IB_ACCESS_REMOTE_ATOMIC) ? 1 : 0;
+	mr->hw_mr.mw_bind = false;
+	mr->hw_mr.pbl_ptr = mr->info.pbl_table[0].pa;
+	mr->hw_mr.pbl_two_level = mr->info.pbl_info.two_layered;
+	mr->hw_mr.pbl_page_size_log = ilog2(mr->info.pbl_info.pbl_size);
+	mr->hw_mr.page_size_log = ilog2(mr->umem->page_size);
+	mr->hw_mr.fbo = ib_umem_offset(mr->umem);
+	mr->hw_mr.length = len;
+	mr->hw_mr.vaddr = usr_addr;
+	mr->hw_mr.zbva = false;
+	mr->hw_mr.phy_mr = false;
+	mr->hw_mr.dma_mr = false;
+
+	rc = dev->ops->rdma_register_tid(dev->rdma_ctx, &mr->hw_mr);
+	if (rc) {
+		DP_ERR(dev, "roce register tid returned an error %d\n", rc);
+		goto err2;
+	}
+
+	mr->ibmr.lkey = mr->hw_mr.itid << 8 | mr->hw_mr.key;
+	if (mr->hw_mr.remote_write || mr->hw_mr.remote_read ||
+	    mr->hw_mr.remote_atomic)
+		mr->ibmr.rkey = mr->hw_mr.itid << 8 | mr->hw_mr.key;
+
+	DP_VERBOSE(dev, QEDR_MSG_MR, "register user mr lkey: %x\n",
+		   mr->ibmr.lkey);
+	return &mr->ibmr;
+
+err2:
+	dev->ops->rdma_free_tid(dev->rdma_ctx, mr->hw_mr.itid);
+err1:
+	qedr_free_pbl(dev, &mr->info.pbl_info, mr->info.pbl_table);
+err0:
+	kfree(mr);
+	return ERR_PTR(rc);
+}
+
+int qedr_dereg_mr(struct ib_mr *ib_mr)
+{
+	struct qedr_mr *mr = get_qedr_mr(ib_mr);
+	struct qedr_dev *dev = get_qedr_dev(ib_mr->device);
+	int rc = 0;
+
+	rc = dev->ops->rdma_deregister_tid(dev->rdma_ctx, mr->hw_mr.itid);
+	if (rc)
+		return rc;
+
+	dev->ops->rdma_free_tid(dev->rdma_ctx, mr->hw_mr.itid);
+
+	if ((mr->type != QEDR_MR_DMA) && (mr->type != QEDR_MR_FRMR))
+		qedr_free_pbl(dev, &mr->info.pbl_info, mr->info.pbl_table);
+
+	/* it could be user registered memory. */
+	if (mr->umem)
+		ib_umem_release(mr->umem);
+
+	kfree(mr->pages);
+	kfree(mr);
+
+	return rc;
+}
+
+struct qedr_mr *__qedr_alloc_mr(struct ib_pd *ibpd, int max_page_list_len)
+{
+	struct qedr_pd *pd = get_qedr_pd(ibpd);
+	struct qedr_dev *dev = get_qedr_dev(ibpd->device);
+	struct qedr_mr *mr;
+	int rc = -ENOMEM;
+
+	DP_VERBOSE(dev, QEDR_MSG_MR,
+		   "qedr_alloc_frmr pd = %d max_page_list_len= %d\n", pd->pd_id,
+		   max_page_list_len);
+
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr)
+		return ERR_PTR(rc);
+
+	mr->dev = dev;
+	mr->type = QEDR_MR_FRMR;
+
+	rc = init_mr_info(dev, &mr->info, max_page_list_len, 1);
+	if (rc)
+		goto err0;
+
+	rc = dev->ops->rdma_alloc_tid(dev->rdma_ctx, &mr->hw_mr.itid);
+	if (rc) {
+		DP_ERR(dev, "roce alloc tid returned an error %d\n", rc);
+		goto err0;
+	}
+
+	/* Index only, 18 bit long, lkey = itid << 8 | key */
+	mr->hw_mr.tid_type = QED_RDMA_TID_FMR;
+	mr->hw_mr.key = 0;
+	mr->hw_mr.pd = pd->pd_id;
+	mr->hw_mr.local_read = 1;
+	mr->hw_mr.local_write = 0;
+	mr->hw_mr.remote_read = 0;
+	mr->hw_mr.remote_write = 0;
+	mr->hw_mr.remote_atomic = 0;
+	mr->hw_mr.mw_bind = false;
+	mr->hw_mr.pbl_ptr = 0;
+	mr->hw_mr.pbl_two_level = mr->info.pbl_info.two_layered;
+	mr->hw_mr.pbl_page_size_log = ilog2(mr->info.pbl_info.pbl_size);
+	mr->hw_mr.fbo = 0;
+	mr->hw_mr.length = 0;
+	mr->hw_mr.vaddr = 0;
+	mr->hw_mr.zbva = false;
+	mr->hw_mr.phy_mr = true;
+	mr->hw_mr.dma_mr = false;
+
+	rc = dev->ops->rdma_register_tid(dev->rdma_ctx, &mr->hw_mr);
+	if (rc) {
+		DP_ERR(dev, "roce register tid returned an error %d\n", rc);
+		goto err1;
+	}
+
+	mr->ibmr.lkey = mr->hw_mr.itid << 8 | mr->hw_mr.key;
+	mr->ibmr.rkey = mr->ibmr.lkey;
+
+	DP_VERBOSE(dev, QEDR_MSG_MR, "alloc frmr: %x\n", mr->ibmr.lkey);
+	return mr;
+
+err1:
+	dev->ops->rdma_free_tid(dev->rdma_ctx, mr->hw_mr.itid);
+err0:
+	kfree(mr);
+	return ERR_PTR(rc);
+}
+
+struct ib_mr *qedr_alloc_mr(struct ib_pd *ibpd,
+			    enum ib_mr_type mr_type, u32 max_num_sg)
+{
+	struct qedr_dev *dev;
+	struct qedr_mr *mr;
+
+	if (mr_type != IB_MR_TYPE_MEM_REG)
+		return ERR_PTR(-EINVAL);
+
+	mr = __qedr_alloc_mr(ibpd, max_num_sg);
+
+	if (IS_ERR(mr))
+		return ERR_PTR(-EINVAL);
+
+	dev = mr->dev;
+	mr->pages = kcalloc(max_num_sg, sizeof(u64), GFP_KERNEL);
+	if (!mr->pages) {
+		dev->ops->rdma_deregister_tid(dev->rdma_ctx, mr->hw_mr.itid);
+		dev->ops->rdma_free_tid(dev->rdma_ctx, mr->hw_mr.itid);
+		qedr_free_pbl(dev, &mr->info.pbl_info, mr->info.pbl_table);
+		return ERR_PTR(-EINVAL);
+	}
+
+	return &mr->ibmr;
+}
+
+static int qedr_set_page(struct ib_mr *ibmr, u64 addr)
+{
+	struct qedr_mr *mr = get_qedr_mr(ibmr);
+
+	if (unlikely(mr->npages == mr->info.pbl_info.num_pbes)) {
+		DP_ERR(mr->dev, "qedr_set_page failes when %d\n", mr->npages);
+		return -ENOMEM;
+	}
+
+	DP_VERBOSE(mr->dev, QEDR_MSG_MR, "qedr_set_page pages[%d] = 0x%llx\n\n",
+		   mr->npages, addr);
+
+	mr->pages[mr->npages++] = addr;
+
+	return 0;
+}
+
+static void handle_completed_mrs(struct qedr_dev *dev, struct mr_info *info)
+{
+	int work = info->completed - info->completed_handled - 1;
+
+	DP_VERBOSE(dev, QEDR_MSG_MR, "Special FMR work = %d\n", work);
+	while (work-- > 0 && !list_empty(&info->inuse_pbl_list)) {
+		struct qedr_pbl *pbl;
+
+		/* Free all the page list that are possible to be freed
+		 * (all the ones that were invalidated), under the assumption
+		 * that if an FMR was completed successfully that means that
+		 * if there was an invalidate operation before it also ended
+		 */
+		pbl = list_first_entry(&info->inuse_pbl_list,
+				       struct qedr_pbl, list_entry);
+		list_del(&pbl->list_entry);
+		list_add_tail(&pbl->list_entry, &info->free_pbl_list);
+		info->completed_handled++;
+	}
+}
+
+int qedr_map_mr_sg(struct ib_mr *ibmr, struct scatterlist *sg,
+		   int sg_nents, unsigned int *sg_offset)
+{
+	struct qedr_mr *mr = get_qedr_mr(ibmr);
+
+	mr->npages = 0;
+
+	handle_completed_mrs(mr->dev, &mr->info);
+	return ib_sg_to_pages(ibmr, sg, sg_nents, NULL, qedr_set_page);
+}
+
+struct ib_mr *qedr_get_dma_mr(struct ib_pd *ibpd, int acc)
+{
+	struct qedr_dev *dev = get_qedr_dev(ibpd->device);
+	struct qedr_pd *pd = get_qedr_pd(ibpd);
+	struct qedr_mr *mr;
+	int rc;
+
+	if (acc & IB_ACCESS_MW_BIND) {
+		DP_ERR(dev, "Unsupported access flags received for dma mr\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
+	if (!mr)
+		return ERR_PTR(-ENOMEM);
+
+	mr->type = QEDR_MR_DMA;
+
+	rc = dev->ops->rdma_alloc_tid(dev->rdma_ctx, &mr->hw_mr.itid);
+	if (rc) {
+		DP_ERR(dev, "roce alloc tid returned an error %d\n", rc);
+		goto err1;
+	}
+
+	/* index only, 18 bit long, lkey = itid << 8 | key */
+	mr->hw_mr.tid_type = QED_RDMA_TID_REGISTERED_MR;
+	mr->hw_mr.pd = pd->pd_id;
+	mr->hw_mr.local_read = 1;
+	mr->hw_mr.local_write = (acc & IB_ACCESS_LOCAL_WRITE) ? 1 : 0;
+	mr->hw_mr.remote_read = (acc & IB_ACCESS_REMOTE_READ) ? 1 : 0;
+	mr->hw_mr.remote_write = (acc & IB_ACCESS_REMOTE_WRITE) ? 1 : 0;
+	mr->hw_mr.remote_atomic = (acc & IB_ACCESS_REMOTE_ATOMIC) ? 1 : 0;
+	mr->hw_mr.dma_mr = true;
+
+	rc = dev->ops->rdma_register_tid(dev->rdma_ctx, &mr->hw_mr);
+	if (rc) {
+		DP_ERR(dev, "roce register tid returned an error %d\n", rc);
+		goto err2;
+	}
+
+	mr->ibmr.lkey = mr->hw_mr.itid << 8 | mr->hw_mr.key;
+	if (mr->hw_mr.remote_write || mr->hw_mr.remote_read ||
+	    mr->hw_mr.remote_atomic)
+		mr->ibmr.rkey = mr->hw_mr.itid << 8 | mr->hw_mr.key;
+
+	DP_VERBOSE(dev, QEDR_MSG_MR, "get dma mr: lkey = %x\n", mr->ibmr.lkey);
+	return &mr->ibmr;
+
+err2:
+	dev->ops->rdma_free_tid(dev->rdma_ctx, mr->hw_mr.itid);
+err1:
+	kfree(mr);
+	return ERR_PTR(rc);
+}
diff --git a/drivers/infiniband/hw/qedr/verbs.h b/drivers/infiniband/hw/qedr/verbs.h
index 80dbac1..e7cb3fd 100644
--- a/drivers/infiniband/hw/qedr/verbs.h
+++ b/drivers/infiniband/hw/qedr/verbs.h
@@ -44,4 +44,18 @@ int qedr_query_qp(struct ib_qp *, struct ib_qp_attr *qp_attr,
 		  int qp_attr_mask, struct ib_qp_init_attr *);
 int qedr_destroy_qp(struct ib_qp *ibqp);
 
+struct ib_ah *qedr_create_ah(struct ib_pd *ibpd, struct ib_ah_attr *attr);
+int qedr_destroy_ah(struct ib_ah *ibah);
+
+int qedr_dereg_mr(struct ib_mr *);
+struct ib_mr *qedr_get_dma_mr(struct ib_pd *, int acc);
+
+struct ib_mr *qedr_reg_user_mr(struct ib_pd *, u64 start, u64 length,
+			       u64 virt, int acc, struct ib_udata *);
+
+int qedr_map_mr_sg(struct ib_mr *ibmr, struct scatterlist *sg,
+		   int sg_nents, unsigned int *sg_offset);
+
+struct ib_mr *qedr_alloc_mr(struct ib_pd *pd, enum ib_mr_type mr_type,
+			    u32 max_num_sg);
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index cf92ff7..04e33ee 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -690,6 +690,17 @@ struct qed_rdma_device *qed_rdma_query_device(void *rdma_cxt)
 	return p_hwfn->p_rdma_info->dev;
 }
 
+void qed_rdma_free_tid(void *rdma_cxt, u32 itid)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "itid = %08x\n", itid);
+
+	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+	qed_bmap_release_id(p_hwfn, &p_hwfn->p_rdma_info->tid_map, itid);
+	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
+}
+
 int qed_rdma_alloc_tid(void *rdma_cxt, u32 *itid)
 {
 	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
@@ -2321,6 +2332,231 @@ int qed_rdma_modify_qp(void *rdma_cxt,
 	return rc;
 }
 
+int qed_rdma_register_tid(void *rdma_cxt,
+			  struct qed_rdma_register_tid_in_params *params)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	struct rdma_register_tid_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	enum rdma_tid_type tid_type;
+	u8 fw_return_code;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "itid = %08x\n", params->itid);
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent, RDMA_RAMROD_REGISTER_MR,
+				 p_hwfn->p_rdma_info->proto, &init_data);
+	if (rc) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "rc = %d\n", rc);
+		return rc;
+	}
+
+	if (p_hwfn->p_rdma_info->last_tid < params->itid)
+		p_hwfn->p_rdma_info->last_tid = params->itid;
+
+	p_ramrod = &p_ent->ramrod.rdma_register_tid;
+
+	p_ramrod->flags = 0;
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_REGISTER_TID_RAMROD_DATA_TWO_LEVEL_PBL,
+		  params->pbl_two_level);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_REGISTER_TID_RAMROD_DATA_ZERO_BASED, params->zbva);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_REGISTER_TID_RAMROD_DATA_PHY_MR, params->phy_mr);
+
+	/* Don't initialize D/C field, as it may override other bits. */
+	if (!(params->tid_type == QED_RDMA_TID_FMR) && !(params->dma_mr))
+		SET_FIELD(p_ramrod->flags,
+			  RDMA_REGISTER_TID_RAMROD_DATA_PAGE_SIZE_LOG,
+			  params->page_size_log - 12);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_REGISTER_TID_RAMROD_DATA_MAX_ID,
+		  p_hwfn->p_rdma_info->last_tid);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_REGISTER_TID_RAMROD_DATA_REMOTE_READ,
+		  params->remote_read);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_REGISTER_TID_RAMROD_DATA_REMOTE_WRITE,
+		  params->remote_write);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_REGISTER_TID_RAMROD_DATA_REMOTE_ATOMIC,
+		  params->remote_atomic);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_REGISTER_TID_RAMROD_DATA_LOCAL_WRITE,
+		  params->local_write);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_REGISTER_TID_RAMROD_DATA_LOCAL_READ, params->local_read);
+
+	SET_FIELD(p_ramrod->flags,
+		  RDMA_REGISTER_TID_RAMROD_DATA_ENABLE_MW_BIND,
+		  params->mw_bind);
+
+	SET_FIELD(p_ramrod->flags1,
+		  RDMA_REGISTER_TID_RAMROD_DATA_PBL_PAGE_SIZE_LOG,
+		  params->pbl_page_size_log - 12);
+
+	SET_FIELD(p_ramrod->flags2,
+		  RDMA_REGISTER_TID_RAMROD_DATA_DMA_MR, params->dma_mr);
+
+	switch (params->tid_type) {
+	case QED_RDMA_TID_REGISTERED_MR:
+		tid_type = RDMA_TID_REGISTERED_MR;
+		break;
+	case QED_RDMA_TID_FMR:
+		tid_type = RDMA_TID_FMR;
+		break;
+	case QED_RDMA_TID_MW_TYPE1:
+		tid_type = RDMA_TID_MW_TYPE1;
+		break;
+	case QED_RDMA_TID_MW_TYPE2A:
+		tid_type = RDMA_TID_MW_TYPE2A;
+		break;
+	default:
+		rc = -EINVAL;
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "rc = %d\n", rc);
+		return rc;
+	}
+	SET_FIELD(p_ramrod->flags1,
+		  RDMA_REGISTER_TID_RAMROD_DATA_TID_TYPE, tid_type);
+
+	p_ramrod->itid = cpu_to_le32(params->itid);
+	p_ramrod->key = params->key;
+	p_ramrod->pd = cpu_to_le16(params->pd);
+	p_ramrod->length_hi = (u8)(params->length >> 32);
+	p_ramrod->length_lo = DMA_LO_LE(params->length);
+	if (params->zbva) {
+		/* Lower 32 bits of the registered MR address.
+		 * In case of zero based MR, will hold FBO
+		 */
+		p_ramrod->va.hi = 0;
+		p_ramrod->va.lo = cpu_to_le32(params->fbo);
+	} else {
+		DMA_REGPAIR_LE(p_ramrod->va, params->vaddr);
+	}
+	DMA_REGPAIR_LE(p_ramrod->pbl_base, params->pbl_ptr);
+
+	/* DIF */
+	if (params->dif_enabled) {
+		SET_FIELD(p_ramrod->flags2,
+			  RDMA_REGISTER_TID_RAMROD_DATA_DIF_ON_HOST_FLG, 1);
+		DMA_REGPAIR_LE(p_ramrod->dif_error_addr,
+			       params->dif_error_addr);
+		DMA_REGPAIR_LE(p_ramrod->dif_runt_addr, params->dif_runt_addr);
+	}
+
+	rc = qed_spq_post(p_hwfn, p_ent, &fw_return_code);
+
+	if (fw_return_code != RDMA_RETURN_OK) {
+		DP_NOTICE(p_hwfn, "fw_return_code = %d\n", fw_return_code);
+		return -EINVAL;
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "Register TID, rc = %d\n", rc);
+	return rc;
+}
+
+int qed_rdma_deregister_tid(void *rdma_cxt, u32 itid)
+{
+	struct qed_hwfn *p_hwfn = (struct qed_hwfn *)rdma_cxt;
+	struct rdma_deregister_tid_ramrod_data *p_ramrod;
+	struct qed_sp_init_data init_data;
+	struct qed_spq_entry *p_ent;
+	struct qed_ptt *p_ptt;
+	u8 fw_return_code;
+	int rc;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "itid = %08x\n", itid);
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent, RDMA_RAMROD_DEREGISTER_MR,
+				 p_hwfn->p_rdma_info->proto, &init_data);
+	if (rc) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "rc = %d\n", rc);
+		return rc;
+	}
+
+	p_ramrod = &p_ent->ramrod.rdma_deregister_tid;
+	p_ramrod->itid = cpu_to_le32(itid);
+
+	rc = qed_spq_post(p_hwfn, p_ent, &fw_return_code);
+	if (rc) {
+		DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "rc = %d\n", rc);
+		return rc;
+	}
+
+	if (fw_return_code == RDMA_RETURN_DEREGISTER_MR_BAD_STATE_ERR) {
+		DP_NOTICE(p_hwfn, "fw_return_code = %d\n", fw_return_code);
+		return -EINVAL;
+	} else if (fw_return_code == RDMA_RETURN_NIG_DRAIN_REQ) {
+		/* Bit indicating that the TID is in use and a nig drain is
+		 * required before sending the ramrod again
+		 */
+		p_ptt = qed_ptt_acquire(p_hwfn);
+		if (!p_ptt) {
+			rc = -EBUSY;
+			DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+				   "Failed to acquire PTT\n");
+			return rc;
+		}
+
+		rc = qed_mcp_drain(p_hwfn, p_ptt);
+		if (rc) {
+			qed_ptt_release(p_hwfn, p_ptt);
+			DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+				   "Drain failed\n");
+			return rc;
+		}
+
+		qed_ptt_release(p_hwfn, p_ptt);
+
+		/* Resend the ramrod */
+		rc = qed_sp_init_request(p_hwfn, &p_ent,
+					 RDMA_RAMROD_DEREGISTER_MR,
+					 p_hwfn->p_rdma_info->proto,
+					 &init_data);
+		if (rc) {
+			DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+				   "Failed to init sp-element\n");
+			return rc;
+		}
+
+		rc = qed_spq_post(p_hwfn, p_ent, &fw_return_code);
+		if (rc) {
+			DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
+				   "Ramrod failed\n");
+			return rc;
+		}
+
+		if (fw_return_code != RDMA_RETURN_OK) {
+			DP_NOTICE(p_hwfn, "fw_return_code = %d\n",
+				  fw_return_code);
+			return rc;
+		}
+	}
+
+	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "De-registered TID, rc = %d\n", rc);
+	return rc;
+}
+
 static void *qed_rdma_get_rdma_ctx(struct qed_dev *cdev)
 {
 	return QED_LEADING_HWFN(cdev);
@@ -2419,6 +2655,10 @@ static const struct qed_rdma_ops qed_rdma_ops_pass = {
 	.rdma_modify_qp = &qed_rdma_modify_qp,
 	.rdma_query_qp = &qed_rdma_query_qp,
 	.rdma_destroy_qp = &qed_rdma_destroy_qp,
+	.rdma_alloc_tid = &qed_rdma_alloc_tid,
+	.rdma_free_tid = &qed_rdma_free_tid,
+	.rdma_register_tid = &qed_rdma_register_tid,
+	.rdma_deregister_tid = &qed_rdma_deregister_tid,
 };
 
 const struct qed_rdma_ops *qed_get_rdma_ops()
diff --git a/include/linux/qed/qed_roce_if.h b/include/linux/qed/qed_roce_if.h
index 02321e3..0b6df6e 100644
--- a/include/linux/qed/qed_roce_if.h
+++ b/include/linux/qed/qed_roce_if.h
@@ -512,6 +512,12 @@ struct qed_rdma_ops {
 	int (*rdma_query_qp)(void *rdma_cxt, struct qed_rdma_qp *qp,
 			     struct qed_rdma_query_qp_out_params *oparams);
 	int (*rdma_destroy_qp)(void *rdma_cxt, struct qed_rdma_qp *qp);
+	int
+	(*rdma_register_tid)(void *rdma_cxt,
+			     struct qed_rdma_register_tid_in_params *iparams);
+	int (*rdma_deregister_tid)(void *rdma_cxt, u32 itid);
+	int (*rdma_alloc_tid)(void *rdma_cxt, u32 *itid);
+	void (*rdma_free_tid)(void *rdma_cxt, u32 itid);
 };
 
 const struct qed_rdma_ops *qed_get_rdma_ops(void);
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
