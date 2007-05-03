From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH v2 14/16][BNX2]: Add 1-shot MSI handler for 5709.
Date: Thu, 03 May 2007 00:31:38 -0700
Message-ID: <1178177498.4909.77.camel@dell>
References: <1178068303.4820.35.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2389 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030799AbXECGod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 02:44:33 -0400
In-Reply-To: <1178068303.4820.35.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add 1-shot MSI handler for 5709.

The 5709 supports the one-shot MSI handler similar to some of the tg3
chips.  In this mode, the MSI disables itself automatically until it
is re-enabled at the end of NAPI poll.

Put the request_irq/free_irq logic in common procedures.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index f072028..97ed400 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2262,6 +2262,23 @@ bnx2_msi(int irq, void *dev_instance)
 }
 
 static irqreturn_t
+bnx2_msi_1shot(int irq, void *dev_instance)
+{
+	struct net_device *dev = dev_instance;
+	struct bnx2 *bp = netdev_priv(dev);
+
+	prefetch(bp->status_blk);
+
+	/* Return here if interrupt is disabled. */
+	if (unlikely(atomic_read(&bp->intr_sem) != 0))
+		return IRQ_HANDLED;
+
+	netif_rx_schedule(dev);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t
 bnx2_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
@@ -3759,13 +3776,17 @@ bnx2_init_chip(struct bnx2 *bp)
 	REG_WR(bp, BNX2_HC_STAT_COLLECT_TICKS, 0xbb8);  /* 3ms */
 
 	if (CHIP_ID(bp) == CHIP_ID_5706_A1)
-		REG_WR(bp, BNX2_HC_CONFIG, BNX2_HC_CONFIG_COLLECT_STATS);
+		val = BNX2_HC_CONFIG_COLLECT_STATS;
 	else {
-		REG_WR(bp, BNX2_HC_CONFIG, BNX2_HC_CONFIG_RX_TMR_MODE |
-		       BNX2_HC_CONFIG_TX_TMR_MODE |
-		       BNX2_HC_CONFIG_COLLECT_STATS);
+		val = BNX2_HC_CONFIG_RX_TMR_MODE | BNX2_HC_CONFIG_TX_TMR_MODE |
+		      BNX2_HC_CONFIG_COLLECT_STATS;
 	}
 
+	if (bp->flags & ONE_SHOT_MSI_FLAG)
+		val |= BNX2_HC_CONFIG_ONE_SHOT;
+
+	REG_WR(bp, BNX2_HC_CONFIG, val);
+
 	/* Clear internal stats counters. */
 	REG_WR(bp, BNX2_HC_COMMAND, BNX2_HC_COMMAND_CLR_STAT_NOW);
 
@@ -4610,6 +4631,38 @@ bnx2_restart_timer:
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 }
 
+static int
+bnx2_request_irq(struct bnx2 *bp)
+{
+	struct net_device *dev = bp->dev;
+	int rc = 0;
+
+	if (bp->flags & USING_MSI_FLAG) {
+		irq_handler_t	fn = bnx2_msi;
+
+		if (bp->flags & ONE_SHOT_MSI_FLAG)
+			fn = bnx2_msi_1shot;
+
+		rc = request_irq(bp->pdev->irq, fn, 0, dev->name, dev);
+	} else
+		rc = request_irq(bp->pdev->irq, bnx2_interrupt,
+				 IRQF_SHARED, dev->name, dev);
+	return rc;
+}
+
+static void
+bnx2_free_irq(struct bnx2 *bp)
+{
+	struct net_device *dev = bp->dev;
+
+	if (bp->flags & USING_MSI_FLAG) {
+		free_irq(bp->pdev->irq, dev);
+		pci_disable_msi(bp->pdev);
+		bp->flags &= ~(USING_MSI_FLAG | ONE_SHOT_MSI_FLAG);
+	} else
+		free_irq(bp->pdev->irq, dev);
+}
+
 /* Called with rtnl_lock */
 static int
 bnx2_open(struct net_device *dev)
@@ -4626,24 +4679,15 @@ bnx2_open(struct net_device *dev)
 	if (rc)
 		return rc;
 
-	if ((CHIP_ID(bp) != CHIP_ID_5706_A0) &&
-		(CHIP_ID(bp) != CHIP_ID_5706_A1) &&
-		!disable_msi) {
-
+	if ((bp->flags & MSI_CAP_FLAG) && !disable_msi) {
 		if (pci_enable_msi(bp->pdev) == 0) {
 			bp->flags |= USING_MSI_FLAG;
-			rc = request_irq(bp->pdev->irq, bnx2_msi, 0, dev->name,
-					dev);
+			if (CHIP_NUM(bp) == CHIP_NUM_5709)
+				bp->flags |= ONE_SHOT_MSI_FLAG;
 		}
-		else {
-			rc = request_irq(bp->pdev->irq, bnx2_interrupt,
-					IRQF_SHARED, dev->name, dev);
-		}
-	}
-	else {
-		rc = request_irq(bp->pdev->irq, bnx2_interrupt, IRQF_SHARED,
-				dev->name, dev);
 	}
+	rc = bnx2_request_irq(bp);
+
 	if (rc) {
 		bnx2_free_mem(bp);
 		return rc;
@@ -4652,11 +4696,7 @@ bnx2_open(struct net_device *dev)
 	rc = bnx2_init_nic(bp);
 
 	if (rc) {
-		free_irq(bp->pdev->irq, dev);
-		if (bp->flags & USING_MSI_FLAG) {
-			pci_disable_msi(bp->pdev);
-			bp->flags &= ~USING_MSI_FLAG;
-		}
+		bnx2_free_irq(bp);
 		bnx2_free_skbs(bp);
 		bnx2_free_mem(bp);
 		return rc;
@@ -4680,16 +4720,13 @@ bnx2_open(struct net_device *dev)
 			       bp->dev->name);
 
 			bnx2_disable_int(bp);
-			free_irq(bp->pdev->irq, dev);
-			pci_disable_msi(bp->pdev);
-			bp->flags &= ~USING_MSI_FLAG;
+			bnx2_free_irq(bp);
 
 			rc = bnx2_init_nic(bp);
 
-			if (!rc) {
-				rc = request_irq(bp->pdev->irq, bnx2_interrupt,
-					IRQF_SHARED, dev->name, dev);
-			}
+			if (!rc)
+				rc = bnx2_request_irq(bp);
+
 			if (rc) {
 				bnx2_free_skbs(bp);
 				bnx2_free_mem(bp);
@@ -4927,11 +4964,7 @@ bnx2_close(struct net_device *dev)
 	else
 		reset_code = BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL;
 	bnx2_reset_chip(bp, reset_code);
-	free_irq(bp->pdev->irq, dev);
-	if (bp->flags & USING_MSI_FLAG) {
-		pci_disable_msi(bp->pdev);
-		bp->flags &= ~USING_MSI_FLAG;
-	}
+	bnx2_free_irq(bp);
 	bnx2_free_skbs(bp);
 	bnx2_free_mem(bp);
 	bp->link_up = 0;
@@ -6095,6 +6128,11 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		}
 	}
 
+	if (CHIP_ID(bp) != CHIP_ID_5706_A0 && CHIP_ID(bp) != CHIP_ID_5706_A1) {
+		if (pci_find_capability(pdev, PCI_CAP_ID_MSI))
+			bp->flags |= MSI_CAP_FLAG;
+	}
+
 	/* 5708 cannot support DMA addresses > 40-bit.  */
 	if (CHIP_NUM(bp) == CHIP_NUM_5708)
 		persist_dma_mask = dma_mask = DMA_40BIT_MASK;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index ba175a8..121576d 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6468,12 +6468,14 @@ struct bnx2 {
 	u32 			last_status_idx;
 
 	u32			flags;
-#define PCIX_FLAG			1
-#define PCI_32BIT_FLAG			2
-#define ONE_TDMA_FLAG			4	/* no longer used */
-#define NO_WOL_FLAG			8
-#define USING_MSI_FLAG			0x20
-#define ASF_ENABLE_FLAG			0x40
+#define PCIX_FLAG			0x00000001
+#define PCI_32BIT_FLAG			0x00000002
+#define ONE_TDMA_FLAG			0x00000004	/* no longer used */
+#define NO_WOL_FLAG			0x00000008
+#define USING_MSI_FLAG			0x00000020
+#define ASF_ENABLE_FLAG			0x00000040
+#define MSI_CAP_FLAG			0x00000080
+#define ONE_SHOT_MSI_FLAG		0x00000100
 
 	/* Put tx producer and consumer fields in separate cache lines. */
 


