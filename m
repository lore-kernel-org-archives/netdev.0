From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/2] cnic: Put uio init in separate function.
Date: Wed, 26 Aug 2009 12:49:23 -0700
Message-ID: <1251316163-9359-2-git-send-email-mchan@broadcom.com>
References: <1251316163-9359-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4553 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752889AbZHZTmS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 15:42:18 -0400
In-Reply-To: <1251316163-9359-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow the 10G iSCSI code to reuse the function.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   68 +++++++++++++++++++++++++++++++--------------------
 1 files changed, 41 insertions(+), 27 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 039900c..f8a0923 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -762,33 +762,14 @@ static int cnic_alloc_l2_rings(struct cnic_dev *dev, int pages)
 	return 0;
 }
 
-static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
-{
+static int cnic_alloc_uio(struct cnic_dev *dev) {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct uio_info *uinfo;
 	int ret;
 
-	ret = cnic_alloc_dma(dev, &cp->kwq_info, KWQ_PAGE_CNT, 1);
-	if (ret)
-		goto error;
-	cp->kwq = (struct kwqe **) cp->kwq_info.pg_arr;
-
-	ret = cnic_alloc_dma(dev, &cp->kcq_info, KCQ_PAGE_CNT, 1);
-	if (ret)
-		goto error;
-	cp->kcq = (struct kcqe **) cp->kcq_info.pg_arr;
-
-	ret = cnic_alloc_context(dev);
-	if (ret)
-		goto error;
-
-	ret = cnic_alloc_l2_rings(dev, 2);
-	if (ret)
-		goto error;
-
 	uinfo = kzalloc(sizeof(*uinfo), GFP_ATOMIC);
 	if (!uinfo)
-		goto error;
+		return -ENOMEM;
 
 	uinfo->mem[0].addr = dev->netdev->base_addr;
 	uinfo->mem[0].internal_addr = dev->regview;
@@ -796,10 +777,15 @@ static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
 	uinfo->mem[0].memtype = UIO_MEM_PHYS;
 
 	uinfo->mem[1].addr = (unsigned long) cp->status_blk & PAGE_MASK;
-	if (cp->ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX)
-		uinfo->mem[1].size = BNX2_SBLK_MSIX_ALIGN_SIZE * 9;
-	else
-		uinfo->mem[1].size = BNX2_SBLK_MSIX_ALIGN_SIZE;
+	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
+		if (cp->ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX)
+			uinfo->mem[1].size = BNX2_SBLK_MSIX_ALIGN_SIZE * 9;
+		else
+			uinfo->mem[1].size = BNX2_SBLK_MSIX_ALIGN_SIZE;
+
+		uinfo->name = "bnx2_cnic";
+	}
+
 	uinfo->mem[1].memtype = UIO_MEM_LOGICAL;
 
 	uinfo->mem[2].addr = (unsigned long) cp->l2_ring;
@@ -810,7 +796,6 @@ static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
 	uinfo->mem[3].size = cp->l2_buf_size;
 	uinfo->mem[3].memtype = UIO_MEM_LOGICAL;
 
-	uinfo->name = "bnx2_cnic";
 	uinfo->version = CNIC_MODULE_VERSION;
 	uinfo->irq = UIO_IRQ_CUSTOM;
 
@@ -822,10 +807,39 @@ static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
 	ret = uio_register_device(&dev->pcidev->dev, uinfo);
 	if (ret) {
 		kfree(uinfo);
-		goto error;
+		return ret;
 	}
 
 	cp->cnic_uinfo = uinfo;
+	return 0;
+}
+
+static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int ret;
+
+	ret = cnic_alloc_dma(dev, &cp->kwq_info, KWQ_PAGE_CNT, 1);
+	if (ret)
+		goto error;
+	cp->kwq = (struct kwqe **) cp->kwq_info.pg_arr;
+
+	ret = cnic_alloc_dma(dev, &cp->kcq_info, KCQ_PAGE_CNT, 1);
+	if (ret)
+		goto error;
+	cp->kcq = (struct kcqe **) cp->kcq_info.pg_arr;
+
+	ret = cnic_alloc_context(dev);
+	if (ret)
+		goto error;
+
+	ret = cnic_alloc_l2_rings(dev, 2);
+	if (ret)
+		goto error;
+
+	ret = cnic_alloc_uio(dev);
+	if (ret)
+		goto error;
 
 	return 0;
 
-- 
1.6.4.GIT


