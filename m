From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 9/17][BNX2]: Add 5709 init code.
Date: Thu, 16 Nov 2006 19:05:47 -0800
Message-ID: <1163732747.6658.35.camel@rh4>
References: <1163731443.6658.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:20749 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1424919AbWKQCNX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 21:13:23 -0500
To: davem@davemloft.net
In-Reply-To: <1163731443.6658.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add 5709 init code.

Add basic support to initialize the 5709 chip.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2633579..baad015 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -236,8 +236,23 @@ static void
 bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 {
 	offset += cid_addr;
-	REG_WR(bp, BNX2_CTX_DATA_ADR, offset);
-	REG_WR(bp, BNX2_CTX_DATA, val);
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		int i;
+
+		REG_WR(bp, BNX2_CTX_CTX_DATA, val);
+		REG_WR(bp, BNX2_CTX_CTX_CTRL,
+		       offset | BNX2_CTX_CTX_CTRL_WRITE_REQ);
+		for (i = 0; i < 5; i++) {
+			u32 val;
+			val = REG_RD(bp, BNX2_CTX_CTX_CTRL);
+			if ((val & BNX2_CTX_CTX_CTRL_WRITE_REQ) == 0)
+				break;
+			udelay(5);
+		}
+	} else {
+		REG_WR(bp, BNX2_CTX_DATA_ADR, offset);
+		REG_WR(bp, BNX2_CTX_DATA, val);
+	}
 }
 
 static int
@@ -403,6 +418,14 @@ bnx2_free_mem(struct bnx2 *bp)
 {
 	int i;
 
+	for (i = 0; i < bp->ctx_pages; i++) {
+		if (bp->ctx_blk[i]) {
+			pci_free_consistent(bp->pdev, BCM_PAGE_SIZE,
+					    bp->ctx_blk[i],
+					    bp->ctx_blk_mapping[i]);
+			bp->ctx_blk[i] = NULL;
+		}
+	}
 	if (bp->status_blk) {
 		pci_free_consistent(bp->pdev, bp->status_stats_size,
 				    bp->status_blk, bp->status_blk_mapping);
@@ -481,6 +504,18 @@ bnx2_alloc_mem(struct bnx2 *bp)
 
 	bp->stats_blk_mapping = bp->status_blk_mapping + status_blk_size;
 
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		bp->ctx_pages = 0x2000 / BCM_PAGE_SIZE;
+		if (bp->ctx_pages == 0)
+			bp->ctx_pages = 1;
+		for (i = 0; i < bp->ctx_pages; i++) {
+			bp->ctx_blk[i] = pci_alloc_consistent(bp->pdev,
+						BCM_PAGE_SIZE,
+						&bp->ctx_blk_mapping[i]);
+			if (bp->ctx_blk[i] == NULL)
+				goto alloc_mem_err;
+		}
+	}
 	return 0;
 
 alloc_mem_err:
@@ -803,13 +838,13 @@ bnx2_set_mac_link(struct bnx2 *bp)
 
 	val &= ~(BNX2_EMAC_MODE_PORT | BNX2_EMAC_MODE_HALF_DUPLEX |
 		BNX2_EMAC_MODE_MAC_LOOP | BNX2_EMAC_MODE_FORCE_LINK |
-		BNX2_EMAC_MODE_25G);
+		BNX2_EMAC_MODE_25G_MODE);
 
 	if (bp->link_up) {
 		switch (bp->line_speed) {
 			case SPEED_10:
-				if (CHIP_NUM(bp) == CHIP_NUM_5708) {
-					val |= BNX2_EMAC_MODE_PORT_MII_10;
+				if (CHIP_NUM(bp) != CHIP_NUM_5706) {
+					val |= BNX2_EMAC_MODE_PORT_MII_10M;
 					break;
 				}
 				/* fall through */
@@ -817,7 +852,7 @@ bnx2_set_mac_link(struct bnx2 *bp)
 				val |= BNX2_EMAC_MODE_PORT_MII;
 				break;
 			case SPEED_2500:
-				val |= BNX2_EMAC_MODE_25G;
+				val |= BNX2_EMAC_MODE_25G_MODE;
 				/* fall through */
 			case SPEED_1000:
 				val |= BNX2_EMAC_MODE_PORT_GMII;
@@ -1263,9 +1298,8 @@ bnx2_init_5706s_phy(struct bnx2 *bp)
 {
 	bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5706) {
-        	REG_WR(bp, BNX2_MISC_UNUSED0, 0x300);
-	}
+	if (CHIP_NUM(bp) == CHIP_NUM_5706)
+        	REG_WR(bp, BNX2_MISC_GP_HW_CTL0, 0x300);
 
 	if (bp->dev->mtu > 1500) {
 		u32 val;
@@ -1408,7 +1442,7 @@ bnx2_set_phy_loopback(struct bnx2 *bp)
 	mac_mode = REG_RD(bp, BNX2_EMAC_MODE);
 	mac_mode &= ~(BNX2_EMAC_MODE_PORT | BNX2_EMAC_MODE_HALF_DUPLEX |
 		      BNX2_EMAC_MODE_MAC_LOOP | BNX2_EMAC_MODE_FORCE_LINK |
-		      BNX2_EMAC_MODE_25G);
+		      BNX2_EMAC_MODE_25G_MODE);
 
 	mac_mode |= BNX2_EMAC_MODE_PORT_GMII;
 	REG_WR(bp, BNX2_EMAC_MODE, mac_mode);
@@ -1459,6 +1493,40 @@ bnx2_fw_sync(struct bnx2 *bp, u32 msg_da
 	return 0;
 }
 
+static int
+bnx2_init_5709_context(struct bnx2 *bp)
+{
+	int i, ret = 0;
+	u32 val;
+
+	val = BNX2_CTX_COMMAND_ENABLED | BNX2_CTX_COMMAND_MEM_INIT | (1 << 12);
+	val |= (BCM_PAGE_BITS - 8) << 16;
+	REG_WR(bp, BNX2_CTX_COMMAND, val);
+	for (i = 0; i < bp->ctx_pages; i++) {
+		int j;
+
+		REG_WR(bp, BNX2_CTX_HOST_PAGE_TBL_DATA0,
+		       (bp->ctx_blk_mapping[i] & 0xffffffff) |
+		       BNX2_CTX_HOST_PAGE_TBL_DATA0_VALID);
+		REG_WR(bp, BNX2_CTX_HOST_PAGE_TBL_DATA1,
+		       (u64) bp->ctx_blk_mapping[i] >> 32);
+		REG_WR(bp, BNX2_CTX_HOST_PAGE_TBL_CTRL, i |
+		       BNX2_CTX_HOST_PAGE_TBL_CTRL_WRITE_REQ);
+		for (j = 0; j < 10; j++) {
+
+			val = REG_RD(bp, BNX2_CTX_HOST_PAGE_TBL_CTRL);
+			if (!(val & BNX2_CTX_HOST_PAGE_TBL_CTRL_WRITE_REQ))
+				break;
+			udelay(5);
+		}
+		if (val & BNX2_CTX_HOST_PAGE_TBL_CTRL_WRITE_REQ) {
+			ret = -EBUSY;
+			break;
+		}
+	}
+	return ret;
+}
+
 static void
 bnx2_init_context(struct bnx2 *bp)
 {
@@ -1581,9 +1649,8 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, u16 i
 		return -ENOMEM;
 	}
 
-	if (unlikely((align = (unsigned long) skb->data & 0x7))) {
-		skb_reserve(skb, 8 - align);
-	}
+	if (unlikely((align = (unsigned long) skb->data & (BNX2_RX_ALIGN - 1))))
+		skb_reserve(skb, BNX2_RX_ALIGN - align);
 
 	mapping = pci_map_single(bp->pdev, skb->data, bp->rx_buf_use_size,
 		PCI_DMA_FROMDEVICE);
@@ -3282,7 +3349,10 @@ bnx2_init_chip(struct bnx2 *bp)
 
 	/* Initialize context mapping and zero out the quick contexts.  The
 	 * context block must have already been enabled. */
-	bnx2_init_context(bp);
+	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		bnx2_init_5709_context(bp);
+	else
+		bnx2_init_context(bp);
 
 	if ((rc = bnx2_init_cpus(bp)) != 0)
 		return rc;
@@ -3393,12 +3463,40 @@ bnx2_init_chip(struct bnx2 *bp)
 	return rc;
 }
 
+static void
+bnx2_init_tx_context(struct bnx2 *bp, u32 cid)
+{
+	u32 val, offset0, offset1, offset2, offset3;
+
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		offset0 = BNX2_L2CTX_TYPE_XI;
+		offset1 = BNX2_L2CTX_CMD_TYPE_XI;
+		offset2 = BNX2_L2CTX_TBDR_BHADDR_HI_XI;
+		offset3 = BNX2_L2CTX_TBDR_BHADDR_LO_XI;
+	} else {
+		offset0 = BNX2_L2CTX_TYPE;
+		offset1 = BNX2_L2CTX_CMD_TYPE;
+		offset2 = BNX2_L2CTX_TBDR_BHADDR_HI;
+		offset3 = BNX2_L2CTX_TBDR_BHADDR_LO;
+	}
+	val = BNX2_L2CTX_TYPE_TYPE_L2 | BNX2_L2CTX_TYPE_SIZE_L2;
+	CTX_WR(bp, GET_CID_ADDR(cid), offset0, val);
+
+	val = BNX2_L2CTX_CMD_TYPE_TYPE_L2 | (8 << 16);
+	CTX_WR(bp, GET_CID_ADDR(cid), offset1, val);
+
+	val = (u64) bp->tx_desc_mapping >> 32;
+	CTX_WR(bp, GET_CID_ADDR(cid), offset2, val);
+
+	val = (u64) bp->tx_desc_mapping & 0xffffffff;
+	CTX_WR(bp, GET_CID_ADDR(cid), offset3, val);
+}
 
 static void
 bnx2_init_tx_ring(struct bnx2 *bp)
 {
 	struct tx_bd *txbd;
-	u32 val;
+	u32 cid;
 
 	bp->tx_wake_thresh = bp->tx_ring_size / 2;
 
@@ -3412,19 +3510,11 @@ bnx2_init_tx_ring(struct bnx2 *bp)
 	bp->hw_tx_cons = 0;
 	bp->tx_prod_bseq = 0;
 
-	val = BNX2_L2CTX_TYPE_TYPE_L2;
-	val |= BNX2_L2CTX_TYPE_SIZE_L2;
-	CTX_WR(bp, GET_CID_ADDR(TX_CID), BNX2_L2CTX_TYPE, val);
+	cid = TX_CID;
+	bp->tx_bidx_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_TX_HOST_BIDX;
+	bp->tx_bseq_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_TX_HOST_BSEQ;
 
-	val = BNX2_L2CTX_CMD_TYPE_TYPE_L2;
-	val |= 8 << 16;
-	CTX_WR(bp, GET_CID_ADDR(TX_CID), BNX2_L2CTX_CMD_TYPE, val);
-
-	val = (u64) bp->tx_desc_mapping >> 32;
-	CTX_WR(bp, GET_CID_ADDR(TX_CID), BNX2_L2CTX_TBDR_BHADDR_HI, val);
-
-	val = (u64) bp->tx_desc_mapping & 0xffffffff;
-	CTX_WR(bp, GET_CID_ADDR(TX_CID), BNX2_L2CTX_TBDR_BHADDR_LO, val);
+	bnx2_init_tx_context(bp, cid);
 }
 
 static void
@@ -3437,8 +3527,8 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 
 	/* 8 for CRC and VLAN */
 	bp->rx_buf_use_size = bp->dev->mtu + ETH_HLEN + bp->rx_offset + 8;
-	/* 8 for alignment */
-	bp->rx_buf_size = bp->rx_buf_use_size + 8;
+	/* hw alignment */
+	bp->rx_buf_size = bp->rx_buf_use_size + BNX2_RX_ALIGN;
 
 	ring_prod = prod = bp->rx_prod = 0;
 	bp->rx_cons = 0;
@@ -5542,13 +5632,6 @@ bnx2_init_board(struct pci_dev *pdev, st
 		goto err_out_release;
 	}
 
-	bp->pcix_cap = pci_find_capability(pdev, PCI_CAP_ID_PCIX);
-	if (bp->pcix_cap == 0) {
-		dev_err(&pdev->dev, "Cannot find PCIX capability, aborting.\n");
-		rc = -EIO;
-		goto err_out_release;
-	}
-
 	if (pci_set_dma_mask(pdev, DMA_64BIT_MASK) == 0) {
 		bp->flags |= USING_DAC_FLAG;
 		if (pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK) != 0) {
@@ -5571,7 +5654,7 @@ bnx2_init_board(struct pci_dev *pdev, st
 	INIT_WORK(&bp->reset_task, bnx2_reset_task, bp);
 
 	dev->base_addr = dev->mem_start = pci_resource_start(pdev, 0);
-	mem_len = MB_GET_CID_ADDR(17);
+	mem_len = MB_GET_CID_ADDR(TX_TSS_CID + 1);
 	dev->mem_end = dev->mem_start + mem_len;
 	dev->irq = pdev->irq;
 
@@ -5595,6 +5678,16 @@ bnx2_init_board(struct pci_dev *pdev, st
 
 	bp->chip_id = REG_RD(bp, BNX2_MISC_ID);
 
+	if (CHIP_NUM(bp) != CHIP_NUM_5709) {
+		bp->pcix_cap = pci_find_capability(pdev, PCI_CAP_ID_PCIX);
+		if (bp->pcix_cap == 0) {
+			dev_err(&pdev->dev,
+				"Cannot find PCIX capability, aborting.\n");
+			rc = -EIO;
+			goto err_out_unmap;
+		}
+	}
+
 	/* Get bus information. */
 	reg = REG_RD(bp, BNX2_PCICFG_MISC_STATUS);
 	if (reg & BNX2_PCICFG_MISC_STATUS_PCIX_DET) {


