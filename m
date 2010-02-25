From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 5/6] cnic: Use union for the status blocks of
 different devices.
Date: Wed, 24 Feb 2010 16:42:08 -0800
Message-ID: <1267058529-18454-5-git-send-email-mchan@broadcom.com>
References: <1267058529-18454-1-git-send-email-mchan@broadcom.com>
 <1267058529-18454-2-git-send-email-mchan@broadcom.com>
 <1267058529-18454-3-git-send-email-mchan@broadcom.com>
 <1267058529-18454-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3606 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758692Ab0BYAct (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 19:32:49 -0500
In-Reply-To: <1267058529-18454-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only need to assign the status block address once and it also saves
space in the structure.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Eddie Wai <waie@broadcom.com>
---
 drivers/net/cnic.c |   35 +++++++++++++++++------------------
 drivers/net/cnic.h |    9 ++++++---
 2 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 0defe61..463408f 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -900,7 +900,8 @@ static int cnic_alloc_uio(struct cnic_dev *dev) {
 	uinfo->mem[0].memtype = UIO_MEM_PHYS;
 
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
-		uinfo->mem[1].addr = (unsigned long) cp->status_blk & PAGE_MASK;
+		uinfo->mem[1].addr = (unsigned long) cp->status_blk.gen &
+			PAGE_MASK;
 		if (cp->ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX)
 			uinfo->mem[1].size = BNX2_SBLK_MSIX_ALIGN_SIZE * 9;
 		else
@@ -1103,10 +1104,9 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	if (ret)
 		goto error;
 
-	cp->bnx2x_status_blk = cp->status_blk;
 	cp->bnx2x_def_status_blk = cp->ethdev->irq_arr[1].status_blk;
 
-	memset(cp->bnx2x_status_blk, 0, sizeof(struct host_status_block));
+	memset(cp->status_blk.bnx2x, 0, sizeof(*cp->status_blk.bnx2x));
 
 	cp->l2_rx_ring_size = 15;
 
@@ -2205,7 +2205,7 @@ static void cnic_service_bnx2_msix(unsigned long data)
 {
 	struct cnic_dev *dev = (struct cnic_dev *) data;
 	struct cnic_local *cp = dev->cnic_priv;
-	struct status_block_msix *status_blk = cp->bnx2_status_blk;
+	struct status_block_msix *status_blk = cp->status_blk.bnx2;
 	u32 status_idx = status_blk->status_idx;
 	u16 hw_prod, sw_prod;
 	int kcqe_cnt;
@@ -2251,7 +2251,7 @@ static irqreturn_t cnic_irq(int irq, void *dev_instance)
 	if (cp->ack_int)
 		cp->ack_int(dev);
 
-	prefetch(cp->status_blk);
+	prefetch(cp->status_blk.gen);
 	prefetch(&cp->kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
 
 	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags)))
@@ -2292,7 +2292,7 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 	struct cnic_local *cp = dev->cnic_priv;
 	u16 hw_prod, sw_prod;
 	struct cstorm_status_block_c *sblk =
-		&cp->bnx2x_status_blk->c_status_block;
+		&cp->status_blk.bnx2x->c_status_block;
 	u32 status_idx = sblk->status_block_index;
 	int kcqe_cnt;
 
@@ -2334,7 +2334,7 @@ static int cnic_service_bnx2x(void *data, void *status_blk)
 	struct cnic_local *cp = dev->cnic_priv;
 	u16 prod = cp->kcq_prod_idx & MAX_KCQ_IDX;
 
-	prefetch(cp->status_blk);
+	prefetch(cp->status_blk.bnx2x);
 	prefetch(&cp->kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
 
 	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags)))
@@ -3409,8 +3409,7 @@ static int cnic_init_bnx2_irq(struct cnic_dev *dev)
 		CNIC_WR(dev, base + BNX2_HC_COM_TICKS_OFF, (64 << 16) | 220);
 		CNIC_WR(dev, base + BNX2_HC_CMD_TICKS_OFF, (64 << 16) | 220);
 
-		cp->bnx2_status_blk = cp->status_blk;
-		cp->last_status_idx = cp->bnx2_status_blk->status_idx;
+		cp->last_status_idx = cp->status_blk.bnx2->status_idx;
 		tasklet_init(&cp->cnic_irq_task, cnic_service_bnx2_msix,
 			     (unsigned long) dev);
 		err = request_irq(ethdev->irq_arr[0].vector, cnic_irq, 0,
@@ -3419,7 +3418,7 @@ static int cnic_init_bnx2_irq(struct cnic_dev *dev)
 			tasklet_disable(&cp->cnic_irq_task);
 			return err;
 		}
-		while (cp->bnx2_status_blk->status_completion_producer_index &&
+		while (cp->status_blk.bnx2->status_completion_producer_index &&
 		       i < 10) {
 			CNIC_WR(dev, BNX2_HC_COALESCE_NOW,
 				1 << (11 + sblk_num));
@@ -3427,13 +3426,13 @@ static int cnic_init_bnx2_irq(struct cnic_dev *dev)
 			i++;
 			barrier();
 		}
-		if (cp->bnx2_status_blk->status_completion_producer_index) {
+		if (cp->status_blk.bnx2->status_completion_producer_index) {
 			cnic_free_irq(dev);
 			goto failed;
 		}
 
 	} else {
-		struct status_block *sblk = cp->status_blk;
+		struct status_block *sblk = cp->status_blk.gen;
 		u32 hc_cmd = CNIC_RD(dev, BNX2_HC_COMMAND);
 		int i = 0;
 
@@ -3490,7 +3489,7 @@ static void cnic_init_bnx2_tx_ring(struct cnic_dev *dev)
 	int i;
 	struct tx_bd *txbd;
 	dma_addr_t buf_map;
-	struct status_block *s_blk = cp->status_blk;
+	struct status_block *s_blk = cp->status_blk.gen;
 
 	sb_id = cp->status_blk_num;
 	tx_cid = 20;
@@ -3498,7 +3497,7 @@ static void cnic_init_bnx2_tx_ring(struct cnic_dev *dev)
 	cnic_init_context(dev, tx_cid + 1);
 	cp->tx_cons_ptr = &s_blk->status_tx_quick_consumer_index2;
 	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
-		struct status_block_msix *sblk = cp->status_blk;
+		struct status_block_msix *sblk = cp->status_blk.bnx2;
 
 		tx_cid = TX_TSS_CID + sb_id - 1;
 		cnic_init_context(dev, tx_cid);
@@ -3554,7 +3553,7 @@ static void cnic_init_bnx2_rx_ring(struct cnic_dev *dev)
 	u32 cid_addr, sb_id, val, coal_reg, coal_val;
 	int i;
 	struct rx_bd *rxbd;
-	struct status_block *s_blk = cp->status_blk;
+	struct status_block *s_blk = cp->status_blk.gen;
 
 	sb_id = cp->status_blk_num;
 	cnic_init_context(dev, 2);
@@ -3562,7 +3561,7 @@ static void cnic_init_bnx2_rx_ring(struct cnic_dev *dev)
 	coal_reg = BNX2_HC_COMMAND;
 	coal_val = CNIC_RD(dev, coal_reg);
 	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
-		struct status_block_msix *sblk = cp->status_blk;
+		struct status_block_msix *sblk = cp->status_blk.bnx2;
 
 		cp->rx_cons_ptr = &sblk->status_rx_quick_consumer_index;
 		coal_reg = BNX2_HC_COALESCE_NOW;
@@ -3661,7 +3660,7 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_eth_dev *ethdev = cp->ethdev;
-	struct status_block *sblk = cp->status_blk;
+	struct status_block *sblk = cp->status_blk.gen;
 	u32 val;
 	int err;
 
@@ -4250,7 +4249,7 @@ static int cnic_start_hw(struct cnic_dev *dev)
 	cp->chip_id = ethdev->chip_id;
 	pci_dev_get(dev->pcidev);
 	cp->func = PCI_FUNC(dev->pcidev->devfn);
-	cp->status_blk = ethdev->irq_arr[0].status_blk;
+	cp->status_blk.gen = ethdev->irq_arr[0].status_blk;
 	cp->status_blk_num = ethdev->irq_arr[0].status_blk_num;
 
 	err = cp->alloc_resc(dev);
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 1921597..d566390 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -224,9 +224,12 @@ struct cnic_local {
 	u16		kcq_prod_idx;
 	u32		kcq_io_addr;
 
-	void				*status_blk;
-	struct status_block_msix	*bnx2_status_blk;
-	struct host_status_block	*bnx2x_status_blk;
+	union {
+		void				*gen;
+		struct status_block_msix	*bnx2;
+		struct host_status_block	*bnx2x;
+	} status_blk;
+
 	struct host_def_status_block	*bnx2x_def_status_blk;
 
 	u32				status_blk_num;
-- 
1.6.4.GIT


