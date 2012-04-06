From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 17/39] bnx2: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:31 +0200
Message-ID: <3958bafae0bfb262eda364adebf21aebb25af69a.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43471 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755981Ab2DFKKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:38 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   41 +++++++++++----------------------
 1 files changed, 14 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 8297e28..36037a6 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -7976,7 +7976,6 @@ static int __devinit
 bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 {
 	struct bnx2 *bp;
-	unsigned long mem_len;
 	int rc, i, j;
 	u32 reg;
 	u64 dma_mask, persist_dma_mask;
@@ -8036,13 +8035,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 #endif
 	INIT_WORK(&bp->reset_task, bnx2_reset_task);
 
-	dev->base_addr = dev->mem_start = pci_resource_start(pdev, 0);
-	mem_len = MB_GET_CID_ADDR(TX_TSS_CID + TX_MAX_TSS_RINGS + 1);
-	dev->mem_end = dev->mem_start + mem_len;
-	dev->irq = pdev->irq;
-
-	bp->regview = ioremap_nocache(dev->base_addr, mem_len);
-
+	bp->regview = pci_iomap(pdev, 0, MB_GET_CID_ADDR(TX_TSS_CID +
+							 TX_MAX_TSS_RINGS + 1));
 	if (!bp->regview) {
 		dev_err(&pdev->dev, "Cannot map register space, aborting\n");
 		rc = -ENOMEM;
@@ -8346,10 +8340,8 @@ err_out_unmap:
 		bp->flags &= ~BNX2_FLAG_AER_ENABLED;
 	}
 
-	if (bp->regview) {
-		iounmap(bp->regview);
-		bp->regview = NULL;
-	}
+	pci_iounmap(pdev, bp->regview);
+	bp->regview = NULL;
 
 err_out_release:
 	pci_release_regions(pdev);
@@ -8432,7 +8424,7 @@ static int __devinit
 bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int version_printed = 0;
-	struct net_device *dev = NULL;
+	struct net_device *dev;
 	struct bnx2 *bp;
 	int rc;
 	char str[40];
@@ -8442,15 +8434,12 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mq(sizeof(*bp), TX_MAX_RINGS);
-
 	if (!dev)
 		return -ENOMEM;
 
 	rc = bnx2_init_board(pdev, dev);
-	if (rc < 0) {
-		free_netdev(dev);
-		return rc;
-	}
+	if (rc < 0)
+		goto err_free;
 
 	dev->netdev_ops = &bnx2_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
@@ -8480,22 +8469,21 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto error;
 	}
 
-	netdev_info(dev, "%s (%c%d) %s found at mem %lx, IRQ %d, node addr %pM\n",
-		    board_info[ent->driver_data].name,
+	netdev_info(dev, "%s (%c%d) %s found at mem %lx, IRQ %d, "
+		    "node addr %pM\n", board_info[ent->driver_data].name,
 		    ((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
 		    ((CHIP_ID(bp) & 0x0ff0) >> 4),
-		    bnx2_bus_string(bp, str),
-		    dev->base_addr,
-		    bp->pdev->irq, dev->dev_addr);
+		    bnx2_bus_string(bp, str), (long)pci_resource_start(pdev, 0),
+		    pdev->irq, dev->dev_addr);
 
 	return 0;
 
 error:
-	if (bp->regview)
-		iounmap(bp->regview);
+	iounmap(bp->regview);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
+err_free:
 	free_netdev(dev);
 	return rc;
 }
@@ -8511,8 +8499,7 @@ bnx2_remove_one(struct pci_dev *pdev)
 	del_timer_sync(&bp->timer);
 	cancel_work_sync(&bp->reset_task);
 
-	if (bp->regview)
-		iounmap(bp->regview);
+	pci_iounmap(bp->pdev, bp->regview);
 
 	kfree(bp->temp_stats_blk);
 
-- 
1.7.7.6
