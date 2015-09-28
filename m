From: Weidong Wang <wangweidong1@huawei.com>
Subject: [PATCH net-next v2] BNX2: fix a Null Pointer for stats_blk
Date: Mon, 28 Sep 2015 15:01:50 +0800
Message-ID: <5608E5DE.6010706@huawei.com>
References: <56014CC0.3050201@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rui.xiang@huawei.com>, <manish.chopra@qlogic.com>
To: <sony.chacko@qlogic.com>, <Dept-HSGLinuxNICDev@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:28449 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319AbbI1HCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 03:02:18 -0400
In-Reply-To: <56014CC0.3050201@huawei.com>
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

Signed-off-by: Tianhong Ding <dingtianhong@huawei.com>
---
Change in v2:
 - Use Allocate the statistics block instead of spinlock, which
   suggested by David Miller.
 - Updating commit message according to changes.

---
 drivers/net/ethernet/broadcom/bnx2.c | 61 +++++++++++++++++++++++-------------
 1 file changed, 40 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 2b66ef3..1f33982 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -813,22 +813,11 @@ bnx2_alloc_rx_mem(struct bnx2 *bp)
 }

 static void
-bnx2_free_mem(struct bnx2 *bp)
+bnx2_free_stats_blk(struct net_device *dev)
 {
-	int i;
+	struct bnx2 *bp = netdev_priv(dev);
 	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];

-	bnx2_free_tx_mem(bp);
-	bnx2_free_rx_mem(bp);
-
-	for (i = 0; i < bp->ctx_pages; i++) {
-		if (bp->ctx_blk[i]) {
-			dma_free_coherent(&bp->pdev->dev, BNX2_PAGE_SIZE,
-					  bp->ctx_blk[i],
-					  bp->ctx_blk_mapping[i]);
-			bp->ctx_blk[i] = NULL;
-		}
-	}
 	if (bnapi->status_blk.msi) {
 		dma_free_coherent(&bp->pdev->dev, bp->status_stats_size,
 				  bnapi->status_blk.msi,
@@ -839,11 +828,12 @@ bnx2_free_mem(struct bnx2 *bp)
 }

 static int
-bnx2_alloc_mem(struct bnx2 *bp)
+bnx2_alloc_stats_blk(struct net_device *dev)
 {
-	int i, status_blk_size, err;
+	int i, status_blk_size;
 	struct bnx2_napi *bnapi;
 	void *status_blk;
+	struct bnx2 *bp = netdev_priv(dev);

 	/* Combine status and statistics blocks into one allocation. */
 	status_blk_size = L1_CACHE_ALIGN(sizeof(struct status_block));
@@ -852,11 +842,10 @@ bnx2_alloc_mem(struct bnx2 *bp)
 						 BNX2_SBLK_MSIX_ALIGN_SIZE);
 	bp->status_stats_size = status_blk_size +
 				sizeof(struct statistics_block);
-
 	status_blk = dma_zalloc_coherent(&bp->pdev->dev, bp->status_stats_size,
 					 &bp->status_blk_mapping, GFP_KERNEL);
 	if (status_blk == NULL)
-		goto alloc_mem_err;
+		return -ENOMEM;

 	bnapi = &bp->bnx2_napi[0];
 	bnapi->status_blk.msi = status_blk;
@@ -865,11 +854,10 @@ bnx2_alloc_mem(struct bnx2 *bp)
 	bnapi->hw_rx_cons_ptr =
 		&bnapi->status_blk.msi->status_rx_quick_consumer_index0;
 	if (bp->flags & BNX2_FLAG_MSIX_CAP) {
-		for (i = 1; i < bp->irq_nvecs; i++) {
+		for (i = 1; i < BNX2_MAX_MSIX_HW_VEC; i++) {
 			struct status_block_msix *sblk;

 			bnapi = &bp->bnx2_napi[i];
-
 			sblk = (status_blk + BNX2_SBLK_MSIX_ALIGN_SIZE * i);
 			bnapi->status_blk.msix = sblk;
 			bnapi->hw_tx_cons_ptr =
@@ -879,11 +867,35 @@ bnx2_alloc_mem(struct bnx2 *bp)
 			bnapi->int_num = i << 24;
 		}
 	}
-
 	bp->stats_blk = status_blk + status_blk_size;
-
 	bp->stats_blk_mapping = bp->status_blk_mapping + status_blk_size;

+	return 0;
+}
+
+static void
+bnx2_free_mem(struct bnx2 *bp)
+{
+	int i;
+
+	bnx2_free_tx_mem(bp);
+	bnx2_free_rx_mem(bp);
+
+	for (i = 0; i < bp->ctx_pages; i++) {
+		if (bp->ctx_blk[i]) {
+			dma_free_coherent(&bp->pdev->dev, BNX2_PAGE_SIZE,
+					  bp->ctx_blk[i],
+					  bp->ctx_blk_mapping[i]);
+			bp->ctx_blk[i] = NULL;
+		}
+	}
+}
+
+static int
+bnx2_alloc_mem(struct bnx2 *bp)
+{
+	int i, err;
+
 	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		bp->ctx_pages = 0x2000 / BNX2_PAGE_SIZE;
 		if (bp->ctx_pages == 0)
@@ -8330,6 +8342,11 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)

 	bp->phy_addr = 1;

+	/* allocate stats_blk */
+	rc = bnx2_alloc_stats_blk(dev);
+	if (rc)
+		goto err_out_unmap;
+
 	/* Disable WOL support if we are running on a SERDES chip. */
 	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 		bnx2_get_5709_media(bp);
@@ -8586,6 +8603,7 @@ error:
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 err_free:
+	bnx2_free_stats_blk(dev);
 	free_netdev(dev);
 	return rc;
 }
@@ -8603,6 +8621,7 @@ bnx2_remove_one(struct pci_dev *pdev)

 	pci_iounmap(bp->pdev, bp->regview);

+	bnx2_free_stats_blk(dev);
 	kfree(bp->temp_stats_blk);

 	if (bp->flags & BNX2_FLAG_AER_ENABLED) {
-- 
1.9.0
