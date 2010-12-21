From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] stmmac: unwind properly in stmmac_dvr_probe()
Date: Tue, 21 Dec 2010 10:34:56 +0300
Message-ID: <20101221073456.GG1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:52879 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163Ab0LUHfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 02:35:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original code had a several problems:
*) It had potential null dereferences of "priv" and "res".
*) It released the memory region before it was aquired.
*) It didn't free "ndev" after it was allocated.
*) It didn't call unregister_netdev() after calling stmmac_probe().

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 20f803d..34a0af3 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1647,10 +1647,8 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 
 	pr_info("STMMAC driver:\n\tplatform registration... ");
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!res) {
-		ret = -ENODEV;
-		goto out;
-	}
+	if (!res)
+		return -ENODEV;
 	pr_info("\tdone!\n");
 
 	if (!request_mem_region(res->start, resource_size(res),
@@ -1658,22 +1656,21 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 		pr_err("%s: ERROR: memory allocation failed"
 		       "cannot get the I/O addr 0x%x\n",
 		       __func__, (unsigned int)res->start);
-		ret = -EBUSY;
-		goto out;
+		return -EBUSY;
 	}
 
 	addr = ioremap(res->start, resource_size(res));
 	if (!addr) {
 		pr_err("%s: ERROR: memory mapping failed\n", __func__);
 		ret = -ENOMEM;
-		goto out;
+		goto out_release_region;
 	}
 
 	ndev = alloc_etherdev(sizeof(struct stmmac_priv));
 	if (!ndev) {
 		pr_err("%s: ERROR: allocating the device\n", __func__);
 		ret = -ENOMEM;
-		goto out;
+		goto out_unmap;
 	}
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
@@ -1683,8 +1680,8 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	if (ndev->irq == -ENXIO) {
 		pr_err("%s: ERROR: MAC IRQ configuration "
 		       "information not found\n", __func__);
-		ret = -ENODEV;
-		goto out;
+		ret = -ENXIO;
+		goto out_free_ndev;
 	}
 
 	priv = netdev_priv(ndev);
@@ -1711,18 +1708,18 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	if (priv->plat->init) {
 		ret = priv->plat->init(pdev);
 		if (unlikely(ret))
-			goto out;
+			goto out_free_ndev;
 	}
 
 	/* MAC HW revice detection */
 	ret = stmmac_mac_device_setup(ndev);
 	if (ret < 0)
-		goto out;
+		goto out_plat_exit;
 
 	/* Network Device Registration */
 	ret = stmmac_probe(ndev);
 	if (ret < 0)
-		goto out;
+		goto out_plat_exit;
 
 	/* associate a PHY - it is provided by another platform bus */
 	if (!driver_for_each_device
@@ -1730,7 +1727,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	     stmmac_associate_phy)) {
 		pr_err("No PHY device is associated with this MAC!\n");
 		ret = -ENODEV;
-		goto out;
+		goto out_unregister;
 	}
 
 	pr_info("\t%s - (dev. name: %s - id: %d, IRQ #%d\n"
@@ -1741,19 +1738,22 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	pr_debug("\tMDIO bus (id: %d)...", priv->plat->bus_id);
 	ret = stmmac_mdio_register(ndev);
 	if (ret < 0)
-		goto out;
+		goto out_unregister;
 	pr_debug("registered!\n");
+	return 0;
 
-out:
-	if (ret < 0) {
-		if (priv->plat->exit)
-			priv->plat->exit(pdev);
-
-		platform_set_drvdata(pdev, NULL);
-		release_mem_region(res->start, resource_size(res));
-		if (addr != NULL)
-			iounmap(addr);
-	}
+out_unregister:
+	unregister_netdev(ndev);
+out_plat_exit:
+	if (priv->plat->exit)
+		priv->plat->exit(pdev);
+out_free_ndev:
+	free_netdev(ndev);
+	platform_set_drvdata(pdev, NULL);
+out_unmap:
+	iounmap(addr);
+out_release_region:
+	release_mem_region(res->start, resource_size(res));
 
 	return ret;
 }
