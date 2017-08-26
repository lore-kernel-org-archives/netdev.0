From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/4] i825xx: switch to switch to dma_alloc_attrs
Date: Sat, 26 Aug 2017 09:21:24 +0200
Message-ID: <20170826072125.9790-4-hch@lst.de>
References: <20170826072125.9790-1-hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>, linux-mips@vger.kernel.org,
        linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170826072125.9790-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This way we can always pass DMA_ATTR_NON_CONSISTENT, the SNI mips version
will simply ignore the flag.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/i825xx/lasi_82596.c | 6 ++----
 drivers/net/ethernet/i825xx/lib82596.c   | 9 +++++----
 drivers/net/ethernet/i825xx/sni_82596.c  | 6 ++----
 3 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/i825xx/lasi_82596.c b/drivers/net/ethernet/i825xx/lasi_82596.c
index d787fdd5db7b..d5b5021aa759 100644
--- a/drivers/net/ethernet/i825xx/lasi_82596.c
+++ b/drivers/net/ethernet/i825xx/lasi_82596.c
@@ -96,8 +96,6 @@
 
 #define OPT_SWAP_PORT	0x0001	/* Need to wordswp on the MPU port */
 
-#define DMA_ALLOC                        dma_alloc_noncoherent
-#define DMA_FREE                         dma_free_noncoherent
 #define DMA_WBACK(ndev, addr, len) \
 	do { dma_cache_sync((ndev)->dev.parent, (void *)addr, len, DMA_TO_DEVICE); } while (0)
 
@@ -200,8 +198,8 @@ static int lan_remove_chip(struct parisc_device *pdev)
 	struct i596_private *lp = netdev_priv(dev);
 
 	unregister_netdev (dev);
-	DMA_FREE(&pdev->dev, sizeof(struct i596_private),
-		 (void *)lp->dma, lp->dma_addr);
+	dma_free_attrs(&pdev->dev, sizeof(struct i596_private), lp->dma,
+		       lp->dma_addr, DMA_ATTR_NON_CONSISTENT);
 	free_netdev (dev);
 	return 0;
 }
diff --git a/drivers/net/ethernet/i825xx/lib82596.c b/drivers/net/ethernet/i825xx/lib82596.c
index 8449c58f01fd..f00a1dc2128c 100644
--- a/drivers/net/ethernet/i825xx/lib82596.c
+++ b/drivers/net/ethernet/i825xx/lib82596.c
@@ -1063,8 +1063,9 @@ static int i82596_probe(struct net_device *dev)
 	if (!dev->base_addr || !dev->irq)
 		return -ENODEV;
 
-	dma = (struct i596_dma *) DMA_ALLOC(dev->dev.parent,
-		sizeof(struct i596_dma), &lp->dma_addr, GFP_KERNEL);
+	dma = dma_alloc_attrs(dev->dev.parent, sizeof(struct i596_dma),
+			      &lp->dma_addr, GFP_KERNEL,
+			      DMA_ATTR_NON_CONSISTENT);
 	if (!dma) {
 		printk(KERN_ERR "%s: Couldn't get shared memory\n", __FILE__);
 		return -ENOMEM;
@@ -1085,8 +1086,8 @@ static int i82596_probe(struct net_device *dev)
 
 	i = register_netdev(dev);
 	if (i) {
-		DMA_FREE(dev->dev.parent, sizeof(struct i596_dma),
-				    (void *)dma, lp->dma_addr);
+		dma_free_attrs(dev->dev.parent, sizeof(struct i596_dma),
+			       dma, lp->dma_addr, DMA_ATTR_NON_CONSISTENT);
 		return i;
 	}
 
diff --git a/drivers/net/ethernet/i825xx/sni_82596.c b/drivers/net/ethernet/i825xx/sni_82596.c
index 2af7f77345fb..b2c04a789744 100644
--- a/drivers/net/ethernet/i825xx/sni_82596.c
+++ b/drivers/net/ethernet/i825xx/sni_82596.c
@@ -23,8 +23,6 @@
 
 static const char sni_82596_string[] = "snirm_82596";
 
-#define DMA_ALLOC                      dma_alloc_coherent
-#define DMA_FREE                       dma_free_coherent
 #define DMA_WBACK(priv, addr, len)     do { } while (0)
 #define DMA_INV(priv, addr, len)       do { } while (0)
 #define DMA_WBACK_INV(priv, addr, len) do { } while (0)
@@ -152,8 +150,8 @@ static int sni_82596_driver_remove(struct platform_device *pdev)
 	struct i596_private *lp = netdev_priv(dev);
 
 	unregister_netdev(dev);
-	DMA_FREE(dev->dev.parent, sizeof(struct i596_private),
-		 lp->dma, lp->dma_addr);
+	dma_free_attrs(dev->dev.parent, sizeof(struct i596_private), lp->dma,
+		       lp->dma_addr, DMA_ATTR_NON_CONSISTENT);
 	iounmap(lp->ca);
 	iounmap(lp->mpu_port);
 	free_netdev (dev);
-- 
2.11.0
