From: Weidong Wang <wangweidong1@huawei.com>
Subject: [PATCH net-next v3] BNX2: fix a Null Pointer for stats_blk
Date: Thu, 8 Oct 2015 18:03:47 +0800
Message-ID: <56163F83.1000901@huawei.com>
References: <56014CC0.3050201@huawei.com> <5608E5DE.6010706@huawei.com> <560A02FA.6030309@huawei.com> <20150929.211011.677113057504126372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <sony.chacko@qlogic.com>, <Dept-HSGLinuxNICDev@qlogic.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rui.xiang@huawei.com>, <manish.chopra@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:8679 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755913AbbJHKE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 06:04:56 -0400
In-Reply-To: <20150929.211011.677113057504126372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

we have two processes to do:
P1#: ifconfig eth0 down; which will call bnx2_close, then will
, and set Null to stats_blk
P2#: ifconfig eth0; which will call bnx2_get_stats64, it will
use stats_blk.
In one case:
    --P1#--                   --P2#--
                              stats_blk(no null)
    bnx2_free_mem
    ->bp->stats_blk = NULL
                              GET_64BIT_NET_STATS

then it will cause 'NULL Pointer' Problem.
it is as well with 'ethtool -S ethx'.

Allocate the statistics block at probe time so that this problem is
impossible

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
Change in v2:
 - Use Allocate the statistics block instead of spinlock, which
   suggested by David Miller.
 - Updating commit message according to changes.

Change in v3:
 - bnx2_alloc_stats_blk is just allocating the stats block.
 - use 'bp->status_blk' to store the status_blk which would used
   in other funcs, just to key the codes simplified.

---
 drivers/net/ethernet/broadcom/bnx2.c | 79 ++++++++++++++++++++++++------------
 drivers/net/ethernet/broadcom/bnx2.h |  1 +
 2 files changed, 53 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 2b66ef3..6259064 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -813,6 +813,46 @@ bnx2_alloc_rx_mem(struct bnx2 *bp)
 }

 static void
+bnx2_free_stats_blk(struct net_device *dev)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+
+	if (bp->status_blk) {
+		dma_free_coherent(&bp->pdev->dev, bp->status_stats_size,
+				  bp->status_blk,
+				  bp->status_blk_mapping);
+		bp->status_blk = NULL;
+		bp->stats_blk = NULL;
+	}
+}
+
+static int
+bnx2_alloc_stats_blk(struct net_device *dev)
+{
+	int status_blk_size;
+	void *status_blk;
+	struct bnx2 *bp = netdev_priv(dev);
+
+	/* Combine status and statistics blocks into one allocation. */
+	status_blk_size = L1_CACHE_ALIGN(sizeof(struct status_block));
+	if (bp->flags & BNX2_FLAG_MSIX_CAP)
+		status_blk_size = L1_CACHE_ALIGN(BNX2_MAX_MSIX_HW_VEC *
+						 BNX2_SBLK_MSIX_ALIGN_SIZE);
+	bp->status_stats_size = status_blk_size +
+				sizeof(struct statistics_block);
+	status_blk = dma_zalloc_coherent(&bp->pdev->dev, bp->status_stats_size,
+					 &bp->status_blk_mapping, GFP_KERNEL);
+	if (status_blk == NULL)
+		return -ENOMEM;
+
+	bp->status_blk = status_blk;
+	bp->stats_blk = status_blk + status_blk_size;
+	bp->stats_blk_mapping = bp->status_blk_mapping + status_blk_size;
+
+	return 0;
+}
+
+static void
 bnx2_free_mem(struct bnx2 *bp)
 {
 	int i;
@@ -829,37 +869,19 @@ bnx2_free_mem(struct bnx2 *bp)
 			bp->ctx_blk[i] = NULL;
 		}
 	}
-	if (bnapi->status_blk.msi) {
-		dma_free_coherent(&bp->pdev->dev, bp->status_stats_size,
-				  bnapi->status_blk.msi,
-				  bp->status_blk_mapping);
+
+	if (bnapi->status_blk.msi)
 		bnapi->status_blk.msi = NULL;
-		bp->stats_blk = NULL;
-	}
 }

 static int
 bnx2_alloc_mem(struct bnx2 *bp)
 {
-	int i, status_blk_size, err;
+	int i, err;
 	struct bnx2_napi *bnapi;
-	void *status_blk;
-
-	/* Combine status and statistics blocks into one allocation. */
-	status_blk_size = L1_CACHE_ALIGN(sizeof(struct status_block));
-	if (bp->flags & BNX2_FLAG_MSIX_CAP)
-		status_blk_size = L1_CACHE_ALIGN(BNX2_MAX_MSIX_HW_VEC *
-						 BNX2_SBLK_MSIX_ALIGN_SIZE);
-	bp->status_stats_size = status_blk_size +
-				sizeof(struct statistics_block);
-
-	status_blk = dma_zalloc_coherent(&bp->pdev->dev, bp->status_stats_size,
-					 &bp->status_blk_mapping, GFP_KERNEL);
-	if (status_blk == NULL)
-		goto alloc_mem_err;

 	bnapi = &bp->bnx2_napi[0];
-	bnapi->status_blk.msi = status_blk;
+	bnapi->status_blk.msi = bp->status_blk;
 	bnapi->hw_tx_cons_ptr =
 		&bnapi->status_blk.msi->status_tx_quick_consumer_index0;
 	bnapi->hw_rx_cons_ptr =
@@ -870,7 +892,7 @@ bnx2_alloc_mem(struct bnx2 *bp)

 			bnapi = &bp->bnx2_napi[i];

-			sblk = (status_blk + BNX2_SBLK_MSIX_ALIGN_SIZE * i);
+			sblk = (bp->status_blk + BNX2_SBLK_MSIX_ALIGN_SIZE * i);
 			bnapi->status_blk.msix = sblk;
 			bnapi->hw_tx_cons_ptr =
 				&sblk->status_tx_quick_consumer_index;
@@ -880,10 +902,6 @@ bnx2_alloc_mem(struct bnx2 *bp)
 		}
 	}

-	bp->stats_blk = status_blk + status_blk_size;
-
-	bp->stats_blk_mapping = bp->status_blk_mapping + status_blk_size;
-
 	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		bp->ctx_pages = 0x2000 / BNX2_PAGE_SIZE;
 		if (bp->ctx_pages == 0)
@@ -8330,6 +8348,11 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)

 	bp->phy_addr = 1;

+	/* allocate stats_blk */
+	rc = bnx2_alloc_stats_blk(dev);
+	if (rc)
+		goto err_out_unmap;
+
 	/* Disable WOL support if we are running on a SERDES chip. */
 	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 		bnx2_get_5709_media(bp);
@@ -8586,6 +8609,7 @@ error:
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 err_free:
+	bnx2_free_stats_blk(dev);
 	free_netdev(dev);
 	return rc;
 }
@@ -8603,6 +8627,7 @@ bnx2_remove_one(struct pci_dev *pdev)

 	pci_iounmap(bp->pdev, bp->regview);

+	bnx2_free_stats_blk(dev);
 	kfree(bp->temp_stats_blk);

 	if (bp->flags & BNX2_FLAG_AER_ENABLED) {
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index f92f76c..380234d 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6928,6 +6928,7 @@ struct bnx2 {

 	dma_addr_t		status_blk_mapping;

+	void *status_blk;
 	struct statistics_block	*stats_blk;
 	struct statistics_block	*temp_stats_blk;
 	dma_addr_t		stats_blk_mapping;
-- 
1.9.0
