From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/9][BNX2]: Support multiple MSIX IRQs.
Date: Thu, 20 Dec 2007 12:32:47 -0800
Message-ID: <1198182767.9163.32.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1154 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813AbXLTTsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:48:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Support multiple MSIX IRQs.

Change bnx2_napi struct into an array and add code to manage multiple
IRQs.  MSIX hardware structures and new registers are also added.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ecfaad1..196d053 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -399,44 +399,65 @@ bnx2_write_phy(struct bnx2 *bp, u32 reg, u32 val)
 static void
 bnx2_disable_int(struct bnx2 *bp)
 {
-	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
-	       BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
+	int i;
+	struct bnx2_napi *bnapi;
+
+	for (i = 0; i < bp->irq_nvecs; i++) {
+		bnapi = &bp->bnx2_napi[i];
+		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
+		       BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
+	}
 	REG_RD(bp, BNX2_PCICFG_INT_ACK_CMD);
 }
 
 static void
 bnx2_enable_int(struct bnx2 *bp)
 {
-	struct bnx2_napi *bnapi = &bp->bnx2_napi;
+	int i;
+	struct bnx2_napi *bnapi;
 
-	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
-	       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
-	       BNX2_PCICFG_INT_ACK_CMD_MASK_INT | bnapi->last_status_idx);
+	for (i = 0; i < bp->irq_nvecs; i++) {
+		bnapi = &bp->bnx2_napi[i];
 
-	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
-	       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID | bnapi->last_status_idx);
+		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
+		       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+		       BNX2_PCICFG_INT_ACK_CMD_MASK_INT |
+		       bnapi->last_status_idx);
 
+		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
+		       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+		       bnapi->last_status_idx);
+	}
 	REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW);
 }
 
 static void
 bnx2_disable_int_sync(struct bnx2 *bp)
 {
+	int i;
+
 	atomic_inc(&bp->intr_sem);
 	bnx2_disable_int(bp);
-	synchronize_irq(bp->pdev->irq);
+	for (i = 0; i < bp->irq_nvecs; i++)
+		synchronize_irq(bp->irq_tbl[i].vector);
 }
 
 static void
 bnx2_napi_disable(struct bnx2 *bp)
 {
-	napi_disable(&bp->bnx2_napi.napi);
+	int i;
+
+	for (i = 0; i < bp->irq_nvecs; i++)
+		napi_disable(&bp->bnx2_napi[i].napi);
 }
 
 static void
 bnx2_napi_enable(struct bnx2 *bp)
 {
-	napi_enable(&bp->bnx2_napi.napi);
+	int i;
+
+	for (i = 0; i < bp->irq_nvecs; i++)
+		napi_enable(&bp->bnx2_napi[i].napi);
 }
 
 static void
@@ -559,6 +580,9 @@ bnx2_alloc_mem(struct bnx2 *bp)
 
 	/* Combine status and statistics blocks into one allocation. */
 	status_blk_size = L1_CACHE_ALIGN(sizeof(struct status_block));
+	if (bp->flags & MSIX_CAP_FLAG)
+		status_blk_size = L1_CACHE_ALIGN(BNX2_MAX_MSIX_HW_VEC *
+						 BNX2_SBLK_MSIX_ALIGN_SIZE);
 	bp->status_stats_size = status_blk_size +
 				sizeof(struct statistics_block);
 
@@ -569,7 +593,17 @@ bnx2_alloc_mem(struct bnx2 *bp)
 
 	memset(bp->status_blk, 0, bp->status_stats_size);
 
-	bp->bnx2_napi.status_blk = bp->status_blk;
+	bp->bnx2_napi[0].status_blk = bp->status_blk;
+	if (bp->flags & MSIX_CAP_FLAG) {
+		for (i = 1; i < BNX2_MAX_MSIX_VEC; i++) {
+			struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
+
+			bnapi->status_blk = (void *)
+				((unsigned long) bp->status_blk +
+				 BNX2_SBLK_MSIX_ALIGN_SIZE * i);
+			bnapi->int_num = i << 24;
+		}
+	}
 
 	bp->stats_blk = (void *) ((unsigned long) bp->status_blk +
 				  status_blk_size);
@@ -2767,7 +2801,7 @@ bnx2_msi(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct bnx2 *bp = netdev_priv(dev);
-	struct bnx2_napi *bnapi = &bp->bnx2_napi;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 
 	prefetch(bnapi->status_blk);
 	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
@@ -2788,7 +2822,7 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct bnx2 *bp = netdev_priv(dev);
-	struct bnx2_napi *bnapi = &bp->bnx2_napi;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 
 	prefetch(bnapi->status_blk);
 
@@ -2806,7 +2840,7 @@ bnx2_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct bnx2 *bp = netdev_priv(dev);
-	struct bnx2_napi *bnapi = &bp->bnx2_napi;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 	struct status_block *sblk = bnapi->status_blk;
 
 	/* When using INTx, it is possible for the interrupt to arrive
@@ -2911,7 +2945,7 @@ static int bnx2_poll(struct napi_struct *napi, int budget)
 		rmb();
 		if (likely(!bnx2_has_work(bnapi))) {
 			netif_rx_complete(bp->dev, napi);
-			if (likely(bp->flags & USING_MSI_FLAG)) {
+			if (likely(bp->flags & USING_MSI_OR_MSIX_FLAG)) {
 				REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 				       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
 				       bnapi->last_status_idx);
@@ -4072,6 +4106,15 @@ bnx2_init_remote_phy(struct bnx2 *bp)
 	}
 }
 
+static void
+bnx2_setup_msix_tbl(struct bnx2 *bp)
+{
+	REG_WR(bp, BNX2_PCI_GRC_WINDOW_ADDR, BNX2_PCI_GRC_WINDOW_ADDR_SEP_WIN);
+
+	REG_WR(bp, BNX2_PCI_GRC_WINDOW2_ADDR, BNX2_MSIX_TABLE_ADDR);
+	REG_WR(bp, BNX2_PCI_GRC_WINDOW3_ADDR, BNX2_MSIX_PBA_ADDR);
+}
+
 static int
 bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 {
@@ -4171,6 +4214,9 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 		rc = bnx2_alloc_bad_rbuf(bp);
 	}
 
+	if (bp->flags & USING_MSIX_FLAG)
+		bnx2_setup_msix_tbl(bp);
+
 	return rc;
 }
 
@@ -4178,7 +4224,7 @@ static int
 bnx2_init_chip(struct bnx2 *bp)
 {
 	u32 val;
-	int rc;
+	int rc, i;
 
 	/* Make sure the interrupt is not active. */
 	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
@@ -4274,7 +4320,9 @@ bnx2_init_chip(struct bnx2 *bp)
 		val |= BNX2_EMAC_RX_MTU_SIZE_JUMBO_ENA;
 	REG_WR(bp, BNX2_EMAC_RX_MTU_SIZE, val);
 
-	bp->bnx2_napi.last_status_idx = 0;
+	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++)
+		bp->bnx2_napi[i].last_status_idx = 0;
+
 	bp->rx_mode = BNX2_EMAC_RX_MODE_SORT_MODE;
 
 	/* Set up how to generate a link change interrupt. */
@@ -4386,7 +4434,7 @@ bnx2_init_tx_ring(struct bnx2 *bp)
 {
 	struct tx_bd *txbd;
 	u32 cid;
-	struct bnx2_napi *bnapi = &bp->bnx2_napi;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 
 	bp->tx_wake_thresh = bp->tx_ring_size / 2;
 
@@ -4437,7 +4485,7 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	int i;
 	u16 prod, ring_prod;
 	u32 val, rx_cid_addr = GET_CID_ADDR(RX_CID);
-	struct bnx2_napi *bnapi = &bp->bnx2_napi;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 
 	bnapi->rx_prod = 0;
 	bnapi->rx_cons = 0;
@@ -4917,7 +4965,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	struct sw_bd *rx_buf;
 	struct l2_fhdr *rx_hdr;
 	int ret = -ENODEV;
-	struct bnx2_napi *bnapi = &bp->bnx2_napi;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 
 	if (loopback_mode == BNX2_MAC_LOOPBACK) {
 		bp->loopback = MAC_LOOPBACK;
@@ -5266,14 +5314,22 @@ bnx2_request_irq(struct bnx2 *bp)
 {
 	struct net_device *dev = bp->dev;
 	unsigned long flags;
-	struct bnx2_irq *irq = &bp->irq_tbl[0];
-	int rc;
+	struct bnx2_irq *irq;
+	int rc = 0, i;
 
-	if (bp->flags & USING_MSI_FLAG)
+	if (bp->flags & USING_MSI_OR_MSIX_FLAG)
 		flags = 0;
 	else
 		flags = IRQF_SHARED;
-	rc = request_irq(irq->vector, irq->handler, flags, dev->name, dev);
+	
+	for (i = 0; i < bp->irq_nvecs; i++) {
+		irq = &bp->irq_tbl[i];
+		rc = request_irq(irq->vector, irq->handler, flags, dev->name,
+				 dev);
+		if (rc)
+			break;
+		irq->requested = 1;
+	}
 	return rc;
 }
 
@@ -5281,12 +5337,30 @@ static void
 bnx2_free_irq(struct bnx2 *bp)
 {
 	struct net_device *dev = bp->dev;
+	struct bnx2_irq *irq;
+	int i;
 
-	free_irq(bp->irq_tbl[0].vector, dev);
-	if (bp->flags & USING_MSI_FLAG) {
-		pci_disable_msi(bp->pdev);
-		bp->flags &= ~(USING_MSI_FLAG | ONE_SHOT_MSI_FLAG);
+	for (i = 0; i < bp->irq_nvecs; i++) {
+		irq = &bp->irq_tbl[i];
+		if (irq->requested)
+			free_irq(irq->vector, dev);
+		irq->requested = 0;
 	}
+	if (bp->flags & USING_MSI_FLAG)
+		pci_disable_msi(bp->pdev);
+	else if (bp->flags & USING_MSIX_FLAG)
+		pci_disable_msix(bp->pdev);
+
+	bp->flags &= ~(USING_MSI_OR_MSIX_FLAG | ONE_SHOT_MSI_FLAG);
+}
+
+static void
+bnx2_enable_msix(struct bnx2 *bp)
+{
+	bnx2_setup_msix_tbl(bp);
+	REG_WR(bp, BNX2_PCI_MSIX_CONTROL, BNX2_MAX_MSIX_HW_VEC - 1);
+	REG_WR(bp, BNX2_PCI_MSIX_TBL_OFF_BIR, BNX2_PCI_GRC_WINDOW2_BASE);
+	REG_WR(bp, BNX2_PCI_MSIX_PBA_OFF_BIT, BNX2_PCI_GRC_WINDOW3_BASE);
 }
 
 static void
@@ -5294,8 +5368,14 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 {
 	bp->irq_tbl[0].handler = bnx2_interrupt;
 	strcpy(bp->irq_tbl[0].name, bp->dev->name);
+	bp->irq_nvecs = 1;
+	bp->irq_tbl[0].vector = bp->pdev->irq;
+
+	if ((bp->flags & MSIX_CAP_FLAG) && !dis_msi)
+		bnx2_enable_msix(bp);
 
-	if ((bp->flags & MSI_CAP_FLAG) && !dis_msi) {
+	if ((bp->flags & MSI_CAP_FLAG) && !dis_msi &&
+	    !(bp->flags & USING_MSIX_FLAG)) {
 		if (pci_enable_msi(bp->pdev) == 0) {
 			bp->flags |= USING_MSI_FLAG;
 			if (CHIP_NUM(bp) == CHIP_NUM_5709) {
@@ -5303,10 +5383,10 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 				bp->irq_tbl[0].handler = bnx2_msi_1shot;
 			} else
 				bp->irq_tbl[0].handler = bnx2_msi;
+
+			bp->irq_tbl[0].vector = bp->pdev->irq;
 		}
 	}
-
-	bp->irq_tbl[0].vector = bp->pdev->irq;
 }
 
 /* Called with rtnl_lock */
@@ -5448,7 +5528,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 len, vlan_tag_flags, last_frag, mss;
 	u16 prod, ring_prod;
 	int i;
-	struct bnx2_napi *bnapi = &bp->bnx2_napi;
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
 
 	if (unlikely(bnx2_tx_avail(bp, bnapi) <
 	    (skb_shinfo(skb)->nr_frags + 1))) {
@@ -6848,6 +6928,11 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		}
 	}
 
+	if (CHIP_NUM(bp) == CHIP_NUM_5709 && CHIP_REV(bp) != CHIP_REV_Ax) {
+		if (pci_find_capability(pdev, PCI_CAP_ID_MSIX))
+			bp->flags |= MSIX_CAP_FLAG;
+	}
+
 	if (CHIP_ID(bp) != CHIP_ID_5706_A0 && CHIP_ID(bp) != CHIP_ID_5706_A1) {
 		if (pci_find_capability(pdev, PCI_CAP_ID_MSI))
 			bp->flags |= MSI_CAP_FLAG;
@@ -7118,10 +7203,14 @@ bnx2_bus_string(struct bnx2 *bp, char *str)
 static int __devinit
 bnx2_init_napi(struct bnx2 *bp)
 {
-	struct bnx2_napi *bnapi = &bp->bnx2_napi;
+	int i;
+	struct bnx2_napi *bnapi;
 
-	bnapi->bp = bp;
-	netif_napi_add(bp->dev, &bnapi->napi, bnx2_poll, 64);
+	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
+		bnapi = &bp->bnx2_napi[i];
+		bnapi->bp = bp;
+	}
+	netif_napi_add(bp->dev, &bp->bnx2_napi[0].napi, bnx2_poll, 64);
 }
 
 static int __devinit
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index b75795b..d71ceb6 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -154,6 +154,33 @@ struct status_block {
 #endif
 };
 
+/*
+ *  status_block definition
+ */
+struct status_block_msix {
+#if defined(__BIG_ENDIAN)
+	u16 status_tx_quick_consumer_index;
+	u16 status_rx_quick_consumer_index;
+	u16 status_completion_producer_index;
+	u16 status_cmd_consumer_index;
+	u32 status_unused;
+	u16 status_idx;
+	u8 status_unused2;
+	u8 status_blk_num;
+#elif defined(__LITTLE_ENDIAN)
+	u16 status_rx_quick_consumer_index;
+	u16 status_tx_quick_consumer_index;
+	u16 status_cmd_consumer_index;
+	u16 status_completion_producer_index;
+	u32 status_unused;
+	u8 status_blk_num;
+	u8 status_unused2;
+	u16 status_idx;
+#endif
+};
+
+#define BNX2_SBLK_MSIX_ALIGN_SIZE	128
+
 
 /*
  *  statistics_block definition
@@ -413,6 +440,7 @@ struct l2_fhdr {
 #define BNX2_PCICFG_INT_ACK_CMD_USE_INT_HC_PARAM	 (1L<<17)
 #define BNX2_PCICFG_INT_ACK_CMD_MASK_INT		 (1L<<18)
 #define BNX2_PCICFG_INT_ACK_CMD_INTERRUPT_NUM		 (0xfL<<24)
+#define BNX2_PCICFG_INT_ACK_CMD_INT_NUM_SHIFT		 24
 
 #define BNX2_PCICFG_STATUS_BIT_SET_CMD			0x00000088
 #define BNX2_PCICFG_STATUS_BIT_CLEAR_CMD		0x0000008c
@@ -428,6 +456,9 @@ struct l2_fhdr {
 #define BNX2_PCI_GRC_WINDOW_ADDR_VALUE			 (0x1ffL<<13)
 #define BNX2_PCI_GRC_WINDOW_ADDR_SEP_WIN		 (1L<<31)
 
+#define BNX2_PCI_GRC_WINDOW2_BASE		 	 0xc000
+#define BNX2_PCI_GRC_WINDOW3_BASE		 	 0xe000
+
 #define BNX2_PCI_CONFIG_1				0x00000404
 #define BNX2_PCI_CONFIG_1_RESERVED0			 (0xffL<<0)
 #define BNX2_PCI_CONFIG_1_READ_BOUNDARY			 (0x7L<<8)
@@ -700,6 +731,8 @@ struct l2_fhdr {
 #define BNX2_PCI_GRC_WINDOW3_ADDR			0x00000618
 #define BNX2_PCI_GRC_WINDOW3_ADDR_VALUE			 (0x1ffL<<13)
 
+#define BNX2_MSIX_TABLE_ADDR				 0x318000
+#define BNX2_MSIX_PBA_ADDR				 0x31c000
 
 /*
  *  misc_reg definition
@@ -6500,6 +6533,7 @@ struct flash_spec {
 struct bnx2_irq {
 	irq_handler_t	handler;
 	u16		vector;
+	u8		requested;
 	char		name[16];
 };
 
@@ -6535,13 +6569,15 @@ struct bnx2 {
 	u32			flags;
 #define PCIX_FLAG			0x00000001
 #define PCI_32BIT_FLAG			0x00000002
-#define ONE_TDMA_FLAG			0x00000004	/* no longer used */
+#define MSIX_CAP_FLAG			0x00000004
 #define NO_WOL_FLAG			0x00000008
 #define USING_MSI_FLAG			0x00000020
 #define ASF_ENABLE_FLAG			0x00000040
 #define MSI_CAP_FLAG			0x00000080
 #define ONE_SHOT_MSI_FLAG		0x00000100
 #define PCIE_FLAG			0x00000200
+#define USING_MSIX_FLAG			0x00000400
+#define USING_MSI_OR_MSIX_FLAG		(USING_MSI_FLAG | USING_MSIX_FLAG)
 
 	/* Put tx producer and consumer fields in separate cache lines. */
 
@@ -6550,7 +6586,7 @@ struct bnx2 {
 	u32		tx_bidx_addr;
 	u32		tx_bseq_addr;
 
-	struct bnx2_napi	bnx2_napi;
+	struct bnx2_napi	bnx2_napi[BNX2_MAX_MSIX_VEC];
 
 #ifdef BCM_VLAN
 	struct			vlan_group *vlgrp;


