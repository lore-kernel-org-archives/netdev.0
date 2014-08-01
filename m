From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] cirrus: cs89x0: Use managed interfaces
Date: Fri, 1 Aug 2014 20:58:19 +0530
Message-ID: <20140801152819.GA11441@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the use of managed interfaces like
devm_ioremap_resource and does away with the functions to free the
allocated memory in the probe and remove functions. Also, many labels
are done away with. The field size in no longer needed and is hence
removed from the struct net_local.

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 drivers/net/ethernet/cirrus/cs89x0.c | 32 +++++++-------------------------
 1 file changed, 7 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index fe84fba..9823a0e 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -145,7 +145,6 @@ struct net_local {
 	int force;		/* force various values; see FORCE* above. */
 	spinlock_t lock;
 	void __iomem *virt_addr;/* CS89x0 virtual address. */
-	unsigned long size;	/* Length of CS89x0 memory region. */
 #if ALLOW_DMA
 	int use_dma;		/* Flag: we're using dma */
 	int dma;		/* DMA channel */
@@ -1854,41 +1853,29 @@ static int __init cs89x0_platform_probe(struct platform_device *pdev)
 
 	lp = netdev_priv(dev);
 
-	mem_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	dev->irq = platform_get_irq(pdev, 0);
-	if (mem_res == NULL || dev->irq <= 0) {
-		dev_warn(&dev->dev, "memory/interrupt resource missing\n");
+	if (dev->irq <= 0) {
+		dev_warn(&dev->dev, "interrupt resource missing\n");
 		err = -ENXIO;
 		goto free;
 	}
 
-	lp->size = resource_size(mem_res);
-	if (!request_mem_region(mem_res->start, lp->size, DRV_NAME)) {
-		dev_warn(&dev->dev, "request_mem_region() failed\n");
-		err = -EBUSY;
+	mem_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	virt_addr = devm_ioremap_resource(&pdev->dev, mem_res);
+	if (IS_ERR(virt_addr)) {
+		err = PTR_ERR(virt_addr);
 		goto free;
 	}
 
-	virt_addr = ioremap(mem_res->start, lp->size);
-	if (!virt_addr) {
-		dev_warn(&dev->dev, "ioremap() failed\n");
-		err = -ENOMEM;
-		goto release;
-	}
-
 	err = cs89x0_probe1(dev, virt_addr, 0);
 	if (err) {
 		dev_warn(&dev->dev, "no cs8900 or cs8920 detected\n");
-		goto unmap;
+		goto free;
 	}
 
 	platform_set_drvdata(pdev, dev);
 	return 0;
 
-unmap:
-	iounmap(virt_addr);
-release:
-	release_mem_region(mem_res->start, lp->size);
 free:
 	free_netdev(dev);
 	return err;
@@ -1897,17 +1884,12 @@ free:
 static int cs89x0_platform_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
-	struct net_local *lp = netdev_priv(dev);
-	struct resource *mem_res;
 
 	/* This platform_get_resource() call will not return NULL, because
 	 * the same call in cs89x0_platform_probe() has returned a non NULL
 	 * value.
 	 */
-	mem_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	unregister_netdev(dev);
-	iounmap(lp->virt_addr);
-	release_mem_region(mem_res->start, lp->size);
 	free_netdev(dev);
 	return 0;
 }
-- 
1.9.1
