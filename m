From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH for-next 1/3] iw_cxgb4: make queue allocation code more readable
Date: Fri,  5 Feb 2016 11:43:28 +0530
Message-ID: <1454652810-25086-2-git-send-email-hariprasad@chelsio.com>
References: <1454652810-25086-1-git-send-email-hariprasad@chelsio.com>
Cc: dledford@redhat.com, davem@davemloft.net,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:46585 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751212AbcBEGLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 01:11:18 -0500
In-Reply-To: <1454652810-25086-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename local mm* variables to more meaningful names

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/qp.c | 81 +++++++++++++++++++++-------------------
 1 file changed, 42 insertions(+), 39 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index e99345eb875a..dadf5f1855b3 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -1621,7 +1621,8 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 	unsigned int sqsize, rqsize;
 	struct c4iw_ucontext *ucontext;
 	int ret;
-	struct c4iw_mm_entry *mm1, *mm2, *mm3, *mm4, *mm5 = NULL;
+	struct c4iw_mm_entry *sq_key_mm, *rq_key_mm = NULL, *sq_db_key_mm;
+	struct c4iw_mm_entry *rq_db_key_mm = NULL, *ma_sync_key_mm = NULL;
 
 	PDBG("%s ib_pd %p\n", __func__, pd);
 
@@ -1706,29 +1707,30 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 		goto err2;
 
 	if (udata) {
-		mm1 = kmalloc(sizeof *mm1, GFP_KERNEL);
-		if (!mm1) {
+		sq_key_mm = kmalloc(sizeof(*sq_key_mm), GFP_KERNEL);
+		if (!sq_key_mm) {
 			ret = -ENOMEM;
 			goto err3;
 		}
-		mm2 = kmalloc(sizeof *mm2, GFP_KERNEL);
-		if (!mm2) {
+		rq_key_mm = kmalloc(sizeof(*rq_key_mm), GFP_KERNEL);
+		if (!rq_key_mm) {
 			ret = -ENOMEM;
 			goto err4;
 		}
-		mm3 = kmalloc(sizeof *mm3, GFP_KERNEL);
-		if (!mm3) {
+		sq_db_key_mm = kmalloc(sizeof(*sq_db_key_mm), GFP_KERNEL);
+		if (!sq_db_key_mm) {
 			ret = -ENOMEM;
 			goto err5;
 		}
-		mm4 = kmalloc(sizeof *mm4, GFP_KERNEL);
-		if (!mm4) {
+		rq_db_key_mm = kmalloc(sizeof(*rq_db_key_mm), GFP_KERNEL);
+		if (!rq_db_key_mm) {
 			ret = -ENOMEM;
 			goto err6;
 		}
 		if (t4_sq_onchip(&qhp->wq.sq)) {
-			mm5 = kmalloc(sizeof *mm5, GFP_KERNEL);
-			if (!mm5) {
+			ma_sync_key_mm = kmalloc(sizeof(*ma_sync_key_mm),
+						 GFP_KERNEL);
+			if (!ma_sync_key_mm) {
 				ret = -ENOMEM;
 				goto err7;
 			}
@@ -1743,7 +1745,7 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 		uresp.rq_size = qhp->wq.rq.size;
 		uresp.rq_memsize = qhp->wq.rq.memsize;
 		spin_lock(&ucontext->mmap_lock);
-		if (mm5) {
+		if (ma_sync_key_mm) {
 			uresp.ma_sync_key = ucontext->key;
 			ucontext->key += PAGE_SIZE;
 		} else {
@@ -1761,28 +1763,29 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 		ret = ib_copy_to_udata(udata, &uresp, sizeof uresp);
 		if (ret)
 			goto err8;
-		mm1->key = uresp.sq_key;
-		mm1->addr = qhp->wq.sq.phys_addr;
-		mm1->len = PAGE_ALIGN(qhp->wq.sq.memsize);
-		insert_mmap(ucontext, mm1);
-		mm2->key = uresp.rq_key;
-		mm2->addr = virt_to_phys(qhp->wq.rq.queue);
-		mm2->len = PAGE_ALIGN(qhp->wq.rq.memsize);
-		insert_mmap(ucontext, mm2);
-		mm3->key = uresp.sq_db_gts_key;
-		mm3->addr = (__force unsigned long)qhp->wq.sq.bar2_pa;
-		mm3->len = PAGE_SIZE;
-		insert_mmap(ucontext, mm3);
-		mm4->key = uresp.rq_db_gts_key;
-		mm4->addr = (__force unsigned long)qhp->wq.rq.bar2_pa;
-		mm4->len = PAGE_SIZE;
-		insert_mmap(ucontext, mm4);
-		if (mm5) {
-			mm5->key = uresp.ma_sync_key;
-			mm5->addr = (pci_resource_start(rhp->rdev.lldi.pdev, 0)
-				    + PCIE_MA_SYNC_A) & PAGE_MASK;
-			mm5->len = PAGE_SIZE;
-			insert_mmap(ucontext, mm5);
+		sq_key_mm->key = uresp.sq_key;
+		sq_key_mm->addr = qhp->wq.sq.phys_addr;
+		sq_key_mm->len = PAGE_ALIGN(qhp->wq.sq.memsize);
+		insert_mmap(ucontext, sq_key_mm);
+		rq_key_mm->key = uresp.rq_key;
+		rq_key_mm->addr = virt_to_phys(qhp->wq.rq.queue);
+		rq_key_mm->len = PAGE_ALIGN(qhp->wq.rq.memsize);
+		insert_mmap(ucontext, rq_key_mm);
+		sq_db_key_mm->key = uresp.sq_db_gts_key;
+		sq_db_key_mm->addr = (u64)(unsigned long)qhp->wq.sq.bar2_pa;
+		sq_db_key_mm->len = PAGE_SIZE;
+		insert_mmap(ucontext, sq_db_key_mm);
+		rq_db_key_mm->key = uresp.rq_db_gts_key;
+		rq_db_key_mm->addr = (u64)(unsigned long)qhp->wq.rq.bar2_pa;
+		rq_db_key_mm->len = PAGE_SIZE;
+		insert_mmap(ucontext, rq_db_key_mm);
+		if (ma_sync_key_mm) {
+			ma_sync_key_mm->key = uresp.ma_sync_key;
+			ma_sync_key_mm->addr =
+				(pci_resource_start(rhp->rdev.lldi.pdev, 0) +
+				PCIE_MA_SYNC_A) & PAGE_MASK;
+			ma_sync_key_mm->len = PAGE_SIZE;
+			insert_mmap(ucontext, ma_sync_key_mm);
 		}
 	}
 	qhp->ibqp.qp_num = qhp->wq.sq.qid;
@@ -1795,15 +1798,15 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 	     qhp->wq.rq.memsize, attrs->cap.max_recv_wr);
 	return &qhp->ibqp;
 err8:
-	kfree(mm5);
+	kfree(ma_sync_key_mm);
 err7:
-	kfree(mm4);
+	kfree(rq_db_key_mm);
 err6:
-	kfree(mm3);
+	kfree(sq_db_key_mm);
 err5:
-	kfree(mm2);
+	kfree(rq_key_mm);
 err4:
-	kfree(mm1);
+	kfree(sq_key_mm);
 err3:
 	remove_handle(rhp, &rhp->qpidr, qhp->wq.sq.qid);
 err2:
-- 
2.3.4
