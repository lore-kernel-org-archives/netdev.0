From: David Miller <davem@davemloft.net>
Subject: [BNX2]: Fix driver software flag namespace.
Date: Mon, 21 Jan 2008 17:17:55 -0800 (PST)
Message-ID: <20080121.171755.250146056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45542
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751359AbYAVBRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 20:17:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Michael, I noticed the following while checking in your patches today.

I've checked this into net-2.6.25

[BNX2]: Fix driver software flag namespace.

Prefix "bnx2->flags" names with BNX2_* for consistency.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 6581287..5605d41 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -580,7 +580,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 
 	/* Combine status and statistics blocks into one allocation. */
 	status_blk_size = L1_CACHE_ALIGN(sizeof(struct status_block));
-	if (bp->flags & MSIX_CAP_FLAG)
+	if (bp->flags & BNX2_FLAG_MSIX_CAP)
 		status_blk_size = L1_CACHE_ALIGN(BNX2_MAX_MSIX_HW_VEC *
 						 BNX2_SBLK_MSIX_ALIGN_SIZE);
 	bp->status_stats_size = status_blk_size +
@@ -594,7 +594,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 	memset(bp->status_blk, 0, bp->status_stats_size);
 
 	bp->bnx2_napi[0].status_blk = bp->status_blk;
-	if (bp->flags & MSIX_CAP_FLAG) {
+	if (bp->flags & BNX2_FLAG_MSIX_CAP) {
 		for (i = 1; i < BNX2_MAX_MSIX_VEC; i++) {
 			struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
 
@@ -3014,7 +3014,7 @@ static int bnx2_poll(struct napi_struct *napi, int budget)
 		rmb();
 		if (likely(!bnx2_has_work(bnapi))) {
 			netif_rx_complete(bp->dev, napi);
-			if (likely(bp->flags & USING_MSI_OR_MSIX_FLAG)) {
+			if (likely(bp->flags & BNX2_FLAG_USING_MSI_OR_MSIX)) {
 				REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 				       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
 				       bnapi->last_status_idx);
@@ -3051,10 +3051,10 @@ bnx2_set_rx_mode(struct net_device *dev)
 				  BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG);
 	sort_mode = 1 | BNX2_RPM_SORT_USER0_BC_EN;
 #ifdef BCM_VLAN
-	if (!bp->vlgrp && !(bp->flags & ASF_ENABLE_FLAG))
+	if (!bp->vlgrp && !(bp->flags & BNX2_FLAG_ASF_ENABLE))
 		rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
 #else
-	if (!(bp->flags & ASF_ENABLE_FLAG))
+	if (!(bp->flags & BNX2_FLAG_ASF_ENABLE))
 		rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
 #endif
 	if (dev->flags & IFF_PROMISC) {
@@ -3492,7 +3492,7 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 			wol_msg = BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL;
 		}
 
-		if (!(bp->flags & NO_WOL_FLAG))
+		if (!(bp->flags & BNX2_FLAG_NO_WOL))
 			bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT3 | wol_msg, 0);
 
 		pmcsr &= ~PCI_PM_CTRL_STATE_MASK;
@@ -4283,7 +4283,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 		rc = bnx2_alloc_bad_rbuf(bp);
 	}
 
-	if (bp->flags & USING_MSIX_FLAG)
+	if (bp->flags & BNX2_FLAG_USING_MSIX)
 		bnx2_setup_msix_tbl(bp);
 
 	return rc;
@@ -4309,11 +4309,11 @@ bnx2_init_chip(struct bnx2 *bp)
 
 	val |= (0x2 << 20) | (1 << 11);
 
-	if ((bp->flags & PCIX_FLAG) && (bp->bus_speed_mhz == 133))
+	if ((bp->flags & BNX2_FLAG_PCIX) && (bp->bus_speed_mhz == 133))
 		val |= (1 << 23);
 
 	if ((CHIP_NUM(bp) == CHIP_NUM_5706) &&
-	    (CHIP_ID(bp) != CHIP_ID_5706_A0) && !(bp->flags & PCIX_FLAG))
+	    (CHIP_ID(bp) != CHIP_ID_5706_A0) && !(bp->flags & BNX2_FLAG_PCIX))
 		val |= BNX2_DMA_CONFIG_CNTL_PING_PONG_DMA;
 
 	REG_WR(bp, BNX2_DMA_CONFIG, val);
@@ -4324,7 +4324,7 @@ bnx2_init_chip(struct bnx2 *bp)
 		REG_WR(bp, BNX2_TDMA_CONFIG, val);
 	}
 
-	if (bp->flags & PCIX_FLAG) {
+	if (bp->flags & BNX2_FLAG_PCIX) {
 		u16 val16;
 
 		pci_read_config_word(bp->pdev, bp->pcix_cap + PCI_X_CMD,
@@ -4438,7 +4438,7 @@ bnx2_init_chip(struct bnx2 *bp)
 		      BNX2_HC_CONFIG_COLLECT_STATS;
 	}
 
-	if (bp->flags & USING_MSIX_FLAG) {
+	if (bp->flags & BNX2_FLAG_USING_MSIX) {
 		REG_WR(bp, BNX2_HC_MSIX_BIT_VECTOR,
 		       BNX2_HC_MSIX_BIT_VECTOR_VAL);
 
@@ -4456,7 +4456,7 @@ bnx2_init_chip(struct bnx2 *bp)
 		val |= BNX2_HC_CONFIG_SB_ADDR_INC_128B;
 	}
 
-	if (bp->flags & ONE_SHOT_MSI_FLAG)
+	if (bp->flags & BNX2_FLAG_ONE_SHOT_MSI)
 		val |= BNX2_HC_CONFIG_ONE_SHOT;
 
 	REG_WR(bp, BNX2_HC_CONFIG, val);
@@ -4543,7 +4543,7 @@ bnx2_init_tx_ring(struct bnx2 *bp)
 	struct bnx2_napi *bnapi;
 
 	bp->tx_vec = 0;
-	if (bp->flags & USING_MSIX_FLAG) {
+	if (bp->flags & BNX2_FLAG_USING_MSIX) {
 		cid = TX_TSS_CID;
 		bp->tx_vec = BNX2_TX_VEC;
 		REG_WR(bp, BNX2_TSCH_TSS_CFG, BNX2_TX_INT_NUM |
@@ -4693,7 +4693,7 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	bp->rx_pg_ring_size = 0;
 	bp->rx_max_pg_ring = 0;
 	bp->rx_max_pg_ring_idx = 0;
-	if ((rx_space > PAGE_SIZE) && !(bp->flags & JUMBO_BROKEN_FLAG)) {
+	if ((rx_space > PAGE_SIZE) && !(bp->flags & BNX2_FLAG_JUMBO_BROKEN)) {
 		int pages = PAGE_ALIGN(bp->dev->mtu - 40) >> PAGE_SHIFT;
 
 		jumbo_size = size * pages;
@@ -5075,7 +5075,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	struct bnx2_napi *bnapi = &bp->bnx2_napi[0], *tx_napi;
 
 	tx_napi = bnapi;
-	if (bp->flags & USING_MSIX_FLAG)
+	if (bp->flags & BNX2_FLAG_USING_MSIX)
 		tx_napi = &bp->bnx2_napi[BNX2_TX_VEC];
 
 	if (loopback_mode == BNX2_MAC_LOOPBACK) {
@@ -5467,7 +5467,7 @@ bnx2_request_irq(struct bnx2 *bp)
 	struct bnx2_irq *irq;
 	int rc = 0, i;
 
-	if (bp->flags & USING_MSI_OR_MSIX_FLAG)
+	if (bp->flags & BNX2_FLAG_USING_MSI_OR_MSIX)
 		flags = 0;
 	else
 		flags = IRQF_SHARED;
@@ -5496,12 +5496,12 @@ bnx2_free_irq(struct bnx2 *bp)
 			free_irq(irq->vector, dev);
 		irq->requested = 0;
 	}
-	if (bp->flags & USING_MSI_FLAG)
+	if (bp->flags & BNX2_FLAG_USING_MSI)
 		pci_disable_msi(bp->pdev);
-	else if (bp->flags & USING_MSIX_FLAG)
+	else if (bp->flags & BNX2_FLAG_USING_MSIX)
 		pci_disable_msix(bp->pdev);
 
-	bp->flags &= ~(USING_MSI_OR_MSIX_FLAG | ONE_SHOT_MSI_FLAG);
+	bp->flags &= ~(BNX2_FLAG_USING_MSI_OR_MSIX | BNX2_FLAG_ONE_SHOT_MSI);
 }
 
 static void
@@ -5533,7 +5533,7 @@ bnx2_enable_msix(struct bnx2 *bp)
 	strcat(bp->irq_tbl[BNX2_TX_VEC].name, "-tx");
 
 	bp->irq_nvecs = BNX2_MAX_MSIX_VEC;
-	bp->flags |= USING_MSIX_FLAG | ONE_SHOT_MSI_FLAG;
+	bp->flags |= BNX2_FLAG_USING_MSIX | BNX2_FLAG_ONE_SHOT_MSI;
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++)
 		bp->irq_tbl[i].vector = msix_ent[i].vector;
 }
@@ -5546,15 +5546,15 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 	bp->irq_nvecs = 1;
 	bp->irq_tbl[0].vector = bp->pdev->irq;
 
-	if ((bp->flags & MSIX_CAP_FLAG) && !dis_msi)
+	if ((bp->flags & BNX2_FLAG_MSIX_CAP) && !dis_msi)
 		bnx2_enable_msix(bp);
 
-	if ((bp->flags & MSI_CAP_FLAG) && !dis_msi &&
-	    !(bp->flags & USING_MSIX_FLAG)) {
+	if ((bp->flags & BNX2_FLAG_MSI_CAP) && !dis_msi &&
+	    !(bp->flags & BNX2_FLAG_USING_MSIX)) {
 		if (pci_enable_msi(bp->pdev) == 0) {
-			bp->flags |= USING_MSI_FLAG;
+			bp->flags |= BNX2_FLAG_USING_MSI;
 			if (CHIP_NUM(bp) == CHIP_NUM_5709) {
-				bp->flags |= ONE_SHOT_MSI_FLAG;
+				bp->flags |= BNX2_FLAG_ONE_SHOT_MSI;
 				bp->irq_tbl[0].handler = bnx2_msi_1shot;
 			} else
 				bp->irq_tbl[0].handler = bnx2_msi;
@@ -5606,7 +5606,7 @@ bnx2_open(struct net_device *dev)
 
 	bnx2_enable_int(bp);
 
-	if (bp->flags & USING_MSI_FLAG) {
+	if (bp->flags & BNX2_FLAG_USING_MSI) {
 		/* Test MSI to make sure it is working
 		 * If MSI test fails, go back to INTx mode
 		 */
@@ -5637,9 +5637,9 @@ bnx2_open(struct net_device *dev)
 			bnx2_enable_int(bp);
 		}
 	}
-	if (bp->flags & USING_MSI_FLAG)
+	if (bp->flags & BNX2_FLAG_USING_MSI)
 		printk(KERN_INFO PFX "%s: using MSI\n", dev->name);
-	else if (bp->flags & USING_MSIX_FLAG)
+	else if (bp->flags & BNX2_FLAG_USING_MSIX)
 		printk(KERN_INFO PFX "%s: using MSIX\n", dev->name);
 
 	netif_start_queue(dev);
@@ -5848,7 +5848,7 @@ bnx2_close(struct net_device *dev)
 	bnx2_disable_int_sync(bp);
 	bnx2_napi_disable(bp);
 	del_timer_sync(&bp->timer);
-	if (bp->flags & NO_WOL_FLAG)
+	if (bp->flags & BNX2_FLAG_NO_WOL)
 		reset_code = BNX2_DRV_MSG_CODE_UNLOAD_LNK_DN;
 	else if (bp->wol)
 		reset_code = BNX2_DRV_MSG_CODE_SUSPEND_WOL;
@@ -6171,7 +6171,7 @@ bnx2_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 
-	if (bp->flags & NO_WOL_FLAG) {
+	if (bp->flags & BNX2_FLAG_NO_WOL) {
 		wol->supported = 0;
 		wol->wolopts = 0;
 	}
@@ -6194,7 +6194,7 @@ bnx2_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		return -EINVAL;
 
 	if (wol->wolopts & WAKE_MAGIC) {
-		if (bp->flags & NO_WOL_FLAG)
+		if (bp->flags & BNX2_FLAG_NO_WOL)
 			return -EINVAL;
 
 		bp->wol = 1;
@@ -6966,7 +6966,7 @@ bnx2_get_pci_speed(struct bnx2 *bp)
 	if (reg & BNX2_PCICFG_MISC_STATUS_PCIX_DET) {
 		u32 clkreg;
 
-		bp->flags |= PCIX_FLAG;
+		bp->flags |= BNX2_FLAG_PCIX;
 
 		clkreg = REG_RD(bp, BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS);
 
@@ -7005,7 +7005,7 @@ bnx2_get_pci_speed(struct bnx2 *bp)
 	}
 
 	if (reg & BNX2_PCICFG_MISC_STATUS_32BIT_DET)
-		bp->flags |= PCI_32BIT_FLAG;
+		bp->flags |= BNX2_FLAG_PCI_32BIT;
 
 }
 
@@ -7093,9 +7093,9 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 			rc = -EIO;
 			goto err_out_unmap;
 		}
-		bp->flags |= PCIE_FLAG;
+		bp->flags |= BNX2_FLAG_PCIE;
 		if (CHIP_REV(bp) == CHIP_REV_Ax)
-			bp->flags |= JUMBO_BROKEN_FLAG;
+			bp->flags |= BNX2_FLAG_JUMBO_BROKEN;
 	} else {
 		bp->pcix_cap = pci_find_capability(pdev, PCI_CAP_ID_PCIX);
 		if (bp->pcix_cap == 0) {
@@ -7108,12 +7108,12 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709 && CHIP_REV(bp) != CHIP_REV_Ax) {
 		if (pci_find_capability(pdev, PCI_CAP_ID_MSIX))
-			bp->flags |= MSIX_CAP_FLAG;
+			bp->flags |= BNX2_FLAG_MSIX_CAP;
 	}
 
 	if (CHIP_ID(bp) != CHIP_ID_5706_A0 && CHIP_ID(bp) != CHIP_ID_5706_A1) {
 		if (pci_find_capability(pdev, PCI_CAP_ID_MSI))
-			bp->flags |= MSI_CAP_FLAG;
+			bp->flags |= BNX2_FLAG_MSI_CAP;
 	}
 
 	/* 5708 cannot support DMA addresses > 40-bit.  */
@@ -7136,7 +7136,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_unmap;
 	}
 
-	if (!(bp->flags & PCIE_FLAG))
+	if (!(bp->flags & BNX2_FLAG_PCIE))
 		bnx2_get_pci_speed(bp);
 
 	/* 5706A0 may falsely detect SERR and PERR. */
@@ -7146,7 +7146,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		REG_WR(bp, PCI_COMMAND, reg);
 	}
 	else if ((CHIP_ID(bp) == CHIP_ID_5706_A1) &&
-		!(bp->flags & PCIX_FLAG)) {
+		!(bp->flags & BNX2_FLAG_PCIX)) {
 
 		dev_err(&pdev->dev,
 			"5706 A1 can only be used in a PCIX bus, aborting.\n");
@@ -7196,7 +7196,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		bp->wol = 1;
 
 	if (reg & BNX2_PORT_FEATURE_ASF_ENABLED) {
-		bp->flags |= ASF_ENABLE_FLAG;
+		bp->flags |= BNX2_FLAG_ASF_ENABLE;
 
 		for (i = 0; i < 30; i++) {
 			reg = REG_RD_IND(bp, bp->shmem_base +
@@ -7268,7 +7268,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		reg = REG_RD_IND(bp, bp->shmem_base +
 				     BNX2_SHARED_HW_CFG_CONFIG);
 		if (!(reg & BNX2_SHARED_HW_CFG_GIG_LINK_ON_VAUX)) {
-			bp->flags |= NO_WOL_FLAG;
+			bp->flags |= BNX2_FLAG_NO_WOL;
 			bp->wol = 0;
 		}
 		if (CHIP_NUM(bp) != CHIP_NUM_5706) {
@@ -7289,7 +7289,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B1)) {
-		bp->flags |= NO_WOL_FLAG;
+		bp->flags |= BNX2_FLAG_NO_WOL;
 		bp->wol = 0;
 	}
 
@@ -7363,13 +7363,13 @@ bnx2_bus_string(struct bnx2 *bp, char *str)
 {
 	char *s = str;
 
-	if (bp->flags & PCIE_FLAG) {
+	if (bp->flags & BNX2_FLAG_PCIE) {
 		s += sprintf(s, "PCI Express");
 	} else {
 		s += sprintf(s, "PCI");
-		if (bp->flags & PCIX_FLAG)
+		if (bp->flags & BNX2_FLAG_PCIX)
 			s += sprintf(s, "-X");
-		if (bp->flags & PCI_32BIT_FLAG)
+		if (bp->flags & BNX2_FLAG_PCI_32BIT)
 			s += sprintf(s, " 32-bit");
 		else
 			s += sprintf(s, " 64-bit");
@@ -7519,7 +7519,7 @@ bnx2_suspend(struct pci_dev *pdev, pm_message_t state)
 	bnx2_netif_stop(bp);
 	netif_device_detach(dev);
 	del_timer_sync(&bp->timer);
-	if (bp->flags & NO_WOL_FLAG)
+	if (bp->flags & BNX2_FLAG_NO_WOL)
 		reset_code = BNX2_DRV_MSG_CODE_UNLOAD_LNK_DN;
 	else if (bp->wol)
 		reset_code = BNX2_DRV_MSG_CODE_SUSPEND_WOL;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 31a030a..cd79b5c 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6580,18 +6580,19 @@ struct bnx2 {
 	atomic_t		intr_sem;
 
 	u32			flags;
-#define PCIX_FLAG			0x00000001
-#define PCI_32BIT_FLAG			0x00000002
-#define MSIX_CAP_FLAG			0x00000004
-#define NO_WOL_FLAG			0x00000008
-#define USING_MSI_FLAG			0x00000020
-#define ASF_ENABLE_FLAG			0x00000040
-#define MSI_CAP_FLAG			0x00000080
-#define ONE_SHOT_MSI_FLAG		0x00000100
-#define PCIE_FLAG			0x00000200
-#define USING_MSIX_FLAG			0x00000400
-#define USING_MSI_OR_MSIX_FLAG		(USING_MSI_FLAG | USING_MSIX_FLAG)
-#define JUMBO_BROKEN_FLAG		0x00000800
+#define BNX2_FLAG_PCIX			0x00000001
+#define BNX2_FLAG_PCI_32BIT		0x00000002
+#define BNX2_FLAG_MSIX_CAP		0x00000004
+#define BNX2_FLAG_NO_WOL		0x00000008
+#define BNX2_FLAG_USING_MSI		0x00000020
+#define BNX2_FLAG_ASF_ENABLE		0x00000040
+#define BNX2_FLAG_MSI_CAP		0x00000080
+#define BNX2_FLAG_ONE_SHOT_MSI		0x00000100
+#define BNX2_FLAG_PCIE			0x00000200
+#define BNX2_FLAG_USING_MSIX		0x00000400
+#define BNX2_FLAG_USING_MSI_OR_MSIX	(BNX2_FLAG_USING_MSI | \
+					 BNX2_FLAG_USING_MSIX)
+#define BNX2_FLAG_JUMBO_BROKEN		0x00000800
 
 	/* Put tx producer and consumer fields in separate cache lines. */
 
