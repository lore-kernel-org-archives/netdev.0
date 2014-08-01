From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] net: ks8851-ml: Use devm_ioremap_resource
Date: Fri, 1 Aug 2014 20:59:13 +0530
Message-ID: <20140801152913.GA11494@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Jingoo Han <jg1.han@samsung.com>,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>,
	Arend van Spriel <arend@broadcom.com>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the use of devm_ioremap_resource, devm_kmalloc and
does away with the functions to free the allocated memory in the probe
and remove functions. Also, some labels are done away with. A bug is
fixed as two regions are allocated in the probe function, but only one
is freed in the remove function.

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 drivers/net/ethernet/micrel/ks8851_mll.c | 59 ++++++++++++--------------------
 1 file changed, 21 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index c83d16d..0eb4764 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1519,7 +1519,8 @@ static int ks_hw_init(struct ks_net *ks)
 	ks->all_mcast = 0;
 	ks->mcast_lst_size = 0;
 
-	ks->frame_head_info = kmalloc(MHEADER_SIZE, GFP_KERNEL);
+	ks->frame_head_info = devm_kmalloc(&ks->pdev->dev, MHEADER_SIZE,
+					   GFP_KERNEL);
 	if (!ks->frame_head_info)
 		return false;
 
@@ -1537,44 +1538,41 @@ MODULE_DEVICE_TABLE(of, ks8851_ml_dt_ids);
 
 static int ks8851_probe(struct platform_device *pdev)
 {
-	int err = -ENOMEM;
+	int err;
 	struct resource *io_d, *io_c;
 	struct net_device *netdev;
 	struct ks_net *ks;
 	u16 id, data;
 	const char *mac;
 
-	io_d = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	io_c = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-
-	if (!request_mem_region(io_d->start, resource_size(io_d), DRV_NAME))
-		goto err_mem_region;
-
-	if (!request_mem_region(io_c->start, resource_size(io_c), DRV_NAME))
-		goto err_mem_region1;
-
 	netdev = alloc_etherdev(sizeof(struct ks_net));
 	if (!netdev)
-		goto err_alloc_etherdev;
+		return -ENOMEM;
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	ks = netdev_priv(netdev);
 	ks->netdev = netdev;
-	ks->hw_addr = ioremap(io_d->start, resource_size(io_d));
 
-	if (!ks->hw_addr)
-		goto err_ioremap;
+	io_d = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	ks->hw_addr = devm_ioremap_resource(&pdev->dev, io_d);
+	if (IS_ERR(ks->hw_addr)) {
+		err = PTR_ERR(ks->hw_addr);
+		goto err_free;
+	}
 
-	ks->hw_addr_cmd = ioremap(io_c->start, resource_size(io_c));
-	if (!ks->hw_addr_cmd)
-		goto err_ioremap1;
+	io_c = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	ks->hw_addr_cmd = devm_ioremap_resource(&pdev->dev, io_c);
+	if (IS_ERR(ks->hw_addr_cmd)) {
+		err = PTR_ERR(ks->hw_addr_cmd);
+		goto err_free;
+	}
 
 	netdev->irq = platform_get_irq(pdev, 0);
 
 	if ((int)netdev->irq < 0) {
 		err = netdev->irq;
-		goto err_get_irq;
+		goto err_free;
 	}
 
 	ks->pdev = pdev;
@@ -1604,18 +1602,18 @@ static int ks8851_probe(struct platform_device *pdev)
 	if ((ks_rdreg16(ks, KS_CIDER) & ~CIDER_REV_MASK) != CIDER_ID) {
 		netdev_err(netdev, "failed to read device ID\n");
 		err = -ENODEV;
-		goto err_register;
+		goto err_free;
 	}
 
 	if (ks_read_selftest(ks)) {
 		netdev_err(netdev, "failed to read device ID\n");
 		err = -ENODEV;
-		goto err_register;
+		goto err_free;
 	}
 
 	err = register_netdev(netdev);
 	if (err)
-		goto err_register;
+		goto err_free;
 
 	platform_set_drvdata(pdev, netdev);
 
@@ -1663,32 +1661,17 @@ static int ks8851_probe(struct platform_device *pdev)
 
 err_pdata:
 	unregister_netdev(netdev);
-err_register:
-err_get_irq:
-	iounmap(ks->hw_addr_cmd);
-err_ioremap1:
-	iounmap(ks->hw_addr);
-err_ioremap:
+err_free:
 	free_netdev(netdev);
-err_alloc_etherdev:
-	release_mem_region(io_c->start, resource_size(io_c));
-err_mem_region1:
-	release_mem_region(io_d->start, resource_size(io_d));
-err_mem_region:
 	return err;
 }
 
 static int ks8851_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev = platform_get_drvdata(pdev);
-	struct ks_net *ks = netdev_priv(netdev);
-	struct resource *iomem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 
-	kfree(ks->frame_head_info);
 	unregister_netdev(netdev);
-	iounmap(ks->hw_addr);
 	free_netdev(netdev);
-	release_mem_region(iomem->start, resource_size(iomem));
 	return 0;
 
 }
-- 
1.9.1
