From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 09/11] au1000_eth: switch to dma_alloc_attrs
Date: Fri, 16 Jun 2017 09:17:14 +0200
Message-ID: <20170616071716.17321-10-hch@lst.de>
References: <20170616071716.17321-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
        netdev@vger.kernel.org, linux-metag@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linux-fbdev@vger.kernel.org,
        alsa-devel@alsa-project.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20170616071716.17321-1-hch@lst.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dma_alloc_attrs directly instead of the dma_alloc_noncoherent wrapper.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/amd/au1000_eth.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index a3c90fe5de00..73ca8879ada7 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1180,9 +1180,10 @@ static int au1000_probe(struct platform_device *pdev)
 	/* Allocate the data buffers
 	 * Snooping works fine with eth on all au1xxx
 	 */
-	aup->vaddr = (u32)dma_alloc_noncoherent(NULL, MAX_BUF_SIZE *
-						(NUM_TX_BUFFS + NUM_RX_BUFFS),
-						&aup->dma_addr,	0);
+	aup->vaddr = (u32)dma_alloc_attrs(NULL, MAX_BUF_SIZE *
+					  (NUM_TX_BUFFS + NUM_RX_BUFFS),
+					  &aup->dma_addr, 0,
+					  DMA_ATTR_NON_CONSISTENT);
 	if (!aup->vaddr) {
 		dev_err(&pdev->dev, "failed to allocate data buffers\n");
 		err = -ENOMEM;
@@ -1361,8 +1362,9 @@ static int au1000_probe(struct platform_device *pdev)
 err_remap2:
 	iounmap(aup->mac);
 err_remap1:
-	dma_free_noncoherent(NULL, MAX_BUF_SIZE * (NUM_TX_BUFFS + NUM_RX_BUFFS),
-			     (void *)aup->vaddr, aup->dma_addr);
+	dma_free_attrs(NULL, MAX_BUF_SIZE * (NUM_TX_BUFFS + NUM_RX_BUFFS),
+			(void *)aup->vaddr, aup->dma_addr,
+			DMA_ATTR_NON_CONSISTENT);
 err_vaddr:
 	free_netdev(dev);
 err_alloc:
@@ -1394,9 +1396,9 @@ static int au1000_remove(struct platform_device *pdev)
 		if (aup->tx_db_inuse[i])
 			au1000_ReleaseDB(aup, aup->tx_db_inuse[i]);
 
-	dma_free_noncoherent(NULL, MAX_BUF_SIZE *
-			(NUM_TX_BUFFS + NUM_RX_BUFFS),
-			(void *)aup->vaddr, aup->dma_addr);
+	dma_free_attrs(NULL, MAX_BUF_SIZE * (NUM_TX_BUFFS + NUM_RX_BUFFS),
+			(void *)aup->vaddr, aup->dma_addr,
+			DMA_ATTR_NON_CONSISTENT);
 
 	iounmap(aup->macdma);
 	iounmap(aup->mac);
-- 
2.11.0
