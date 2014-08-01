From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] drivers/net: Use managed interfaces
Date: Fri, 1 Aug 2014 21:00:03 +0530
Message-ID: <20140801153003.GA11527@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the use of managed interfaces like
devm_ioremap_resource and does away with the calls to free the
allocated memory in the probe and remove functions. Also, some
labels and variable are done away with. This fixes a bug as there
was a missing release_mem_region in the remove function.

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 drivers/net/ethernet/dnet.c | 46 ++++++++++++---------------------------------
 1 file changed, 12 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index e9b0fab..a379c3e 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -323,7 +323,8 @@ static int dnet_mii_init(struct dnet *bp)
 
 	bp->mii_bus->priv = bp;
 
-	bp->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
+	bp->mii_bus->irq = devm_kmalloc(&bp->pdev->dev,
+					sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 	if (!bp->mii_bus->irq) {
 		err = -ENOMEM;
 		goto err_out;
@@ -334,7 +335,7 @@ static int dnet_mii_init(struct dnet *bp)
 
 	if (mdiobus_register(bp->mii_bus)) {
 		err = -ENXIO;
-		goto err_out_free_mdio_irq;
+		goto err_out;
 	}
 
 	if (dnet_mii_probe(bp->dev) != 0) {
@@ -346,8 +347,6 @@ static int dnet_mii_init(struct dnet *bp)
 
 err_out_unregister_bus:
 	mdiobus_unregister(bp->mii_bus);
-err_out_free_mdio_irq:
-	kfree(bp->mii_bus->irq);
 err_out:
 	mdiobus_free(bp->mii_bus);
 	return err;
@@ -825,28 +824,14 @@ static int dnet_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct dnet *bp;
 	struct phy_device *phydev;
-	int err = -ENXIO;
-	unsigned int mem_base, mem_size, irq;
+	int err;
+	unsigned int irq;
 
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!res) {
-		dev_err(&pdev->dev, "no mmio resource defined\n");
-		goto err_out;
-	}
-	mem_base = res->start;
-	mem_size = resource_size(res);
 	irq = platform_get_irq(pdev, 0);
 
-	if (!request_mem_region(mem_base, mem_size, DRV_NAME)) {
-		dev_err(&pdev->dev, "no memory region available\n");
-		err = -EBUSY;
-		goto err_out;
-	}
-
-	err = -ENOMEM;
 	dev = alloc_etherdev(sizeof(*bp));
 	if (!dev)
-		goto err_out_release_mem;
+		return -ENOMEM;
 
 	/* TODO: Actually, we have some interesting features... */
 	dev->features |= 0;
@@ -859,10 +844,10 @@ static int dnet_probe(struct platform_device *pdev)
 
 	spin_lock_init(&bp->lock);
 
-	bp->regs = ioremap(mem_base, mem_size);
-	if (!bp->regs) {
-		dev_err(&pdev->dev, "failed to map registers, aborting.\n");
-		err = -ENOMEM;
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	bp->regs = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(bp->regs)) {
+		err = PTR_ERR(bp->regs);
 		goto err_out_free_dev;
 	}
 
@@ -871,7 +856,7 @@ static int dnet_probe(struct platform_device *pdev)
 	if (err) {
 		dev_err(&pdev->dev, "Unable to request IRQ %d (error %d)\n",
 		       irq, err);
-		goto err_out_iounmap;
+		goto err_out_free_dev;
 	}
 
 	dev->netdev_ops = &dnet_netdev_ops;
@@ -908,7 +893,7 @@ static int dnet_probe(struct platform_device *pdev)
 		goto err_out_unregister_netdev;
 
 	dev_info(&pdev->dev, "Dave DNET at 0x%p (0x%08x) irq %d %pM\n",
-	       bp->regs, mem_base, dev->irq, dev->dev_addr);
+	       bp->regs, (unsigned int)res->start, dev->irq, dev->dev_addr);
 	dev_info(&pdev->dev, "has %smdio, %sirq, %sgigabit, %sdma\n",
 	       (bp->capabilities & DNET_HAS_MDIO) ? "" : "no ",
 	       (bp->capabilities & DNET_HAS_IRQ) ? "" : "no ",
@@ -925,13 +910,8 @@ err_out_unregister_netdev:
 	unregister_netdev(dev);
 err_out_free_irq:
 	free_irq(dev->irq, dev);
-err_out_iounmap:
-	iounmap(bp->regs);
 err_out_free_dev:
 	free_netdev(dev);
-err_out_release_mem:
-	release_mem_region(mem_base, mem_size);
-err_out:
 	return err;
 }
 
@@ -948,11 +928,9 @@ static int dnet_remove(struct platform_device *pdev)
 		if (bp->phy_dev)
 			phy_disconnect(bp->phy_dev);
 		mdiobus_unregister(bp->mii_bus);
-		kfree(bp->mii_bus->irq);
 		mdiobus_free(bp->mii_bus);
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
-		iounmap(bp->regs);
 		free_netdev(dev);
 	}
 
-- 
1.9.1
