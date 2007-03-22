From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.21] iw_cxgb3: Fix a resource leak in
	cxio_hal_init_ctrl_qp().
Date: Thu, 22 Mar 2007 16:39:57 -0500
Message-ID: <1174599597.16862.70.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
	General@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Fix a resource leak in cxio_hal_init_ctrl_qp().

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/cxio_hal.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/hw/cxgb3/cxio_hal.c
index 818cf1a..f5e9aee 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -498,9 +498,9 @@ static int cxio_hal_init_ctrl_qp(struct 
 	u64 sge_cmd, ctx0, ctx1;
 	u64 base_addr;
 	struct t3_modify_qp_wr *wqe;
-	struct sk_buff *skb = alloc_skb(sizeof(*wqe), GFP_KERNEL);
-
+	struct sk_buff *skb;
 
+	skb = alloc_skb(sizeof(*wqe), GFP_KERNEL);
 	if (!skb) {
 		PDBG("%s alloc_skb failed\n", __FUNCTION__);
 		return -ENOMEM;
@@ -508,7 +508,7 @@ static int cxio_hal_init_ctrl_qp(struct 
 	err = cxio_hal_init_ctrl_cq(rdev_p);
 	if (err) {
 		PDBG("%s err %d initializing ctrl_cq\n", __FUNCTION__, err);
-		return err;
+		goto err;
 	}
 	rdev_p->ctrl_qp.workq = dma_alloc_coherent(
 					&(rdev_p->rnic_info.pdev->dev),
@@ -518,7 +518,8 @@ static int cxio_hal_init_ctrl_qp(struct 
 					GFP_KERNEL);
 	if (!rdev_p->ctrl_qp.workq) {
 		PDBG("%s dma_alloc_coherent failed\n", __FUNCTION__);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto err;
 	}
 	pci_unmap_addr_set(&rdev_p->ctrl_qp, mapping,
 			   rdev_p->ctrl_qp.dma_addr);
@@ -556,6 +557,9 @@ static int cxio_hal_init_ctrl_qp(struct 
 	     rdev_p->ctrl_qp.workq, 1 << T3_CTRL_QP_SIZE_LOG2);
 	skb->priority = CPL_PRIORITY_CONTROL;
 	return (cxgb3_ofld_send(rdev_p->t3cdev_p, skb));
+err:
+	kfree_skb(skb);
+	return err;
 }
 
 static int cxio_hal_destroy_ctrl_qp(struct cxio_rdev *rdev_p)
