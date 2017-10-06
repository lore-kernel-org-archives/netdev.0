From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH net v2 5/9] net/macmace: Fix and cleanup log messages
Date: Thu,  5 Oct 2017 21:11:05 -0400 (EDT)
Message-ID: <ebb920be1e7f2a837fff88ae71b3d9b1733c5682.1507211120.git.fthain@telegraphics.com.au>
References: <cover.1507211120.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1507211120.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Log the MAC address after the interface gets a meaningful name
and in doing so, make the registration error path more idiomatic.
Drop redundant debug messages for FIFO events recorded in the
interface statistics (consistent with mace.c).

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
Tested-by: Stan Johnson <userm57@yahoo.com>
---
 drivers/net/ethernet/apple/macmace.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index f17a160dbff2..54c1f1c2f54a 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -247,13 +247,14 @@ static int mace_probe(struct platform_device *pdev)
 	dev->netdev_ops		= &mace_netdev_ops;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 
-	printk(KERN_INFO "%s: 68K MACE, hardware address %pM\n",
-	       dev->name, dev->dev_addr);
-
 	err = register_netdev(dev);
-	if (!err)
-		return 0;
+	if (err)
+		goto out_free;
+
+	netdev_info(dev, "MAC %pM, IRQ %d\n", dev->dev_addr, dev->irq);
+	return 0;
 
+out_free:
 	free_netdev(dev);
 	return err;
 }
@@ -589,7 +590,6 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 			else if (fs & (UFLO|LCOL|RTRY)) {
 				++dev->stats.tx_aborted_errors;
 				if (mb->xmtfs & UFLO) {
-					printk(KERN_ERR "%s: DMA underrun.\n", dev->name);
 					dev->stats.tx_fifo_errors++;
 					mace_txdma_reset(dev);
 				}
@@ -644,10 +644,8 @@ static void mace_dma_rx_frame(struct net_device *dev, struct mace_frame *mf)
 
 	if (frame_status & (RS_OFLO | RS_CLSN | RS_FRAMERR | RS_FCSERR)) {
 		dev->stats.rx_errors++;
-		if (frame_status & RS_OFLO) {
-			printk(KERN_DEBUG "%s: fifo overflow.\n", dev->name);
+		if (frame_status & RS_OFLO)
 			dev->stats.rx_fifo_errors++;
-		}
 		if (frame_status & RS_CLSN)
 			dev->stats.collisions++;
 		if (frame_status & RS_FRAMERR)
-- 
2.13.5
