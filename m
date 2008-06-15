From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 1/9] DM9000: Remove the 2 resources probe scheme.
Date: Mon, 16 Jun 2008 00:26:54 +0100
Message-ID: <20080615232814.735153296@fluff.org.uk>
References: <20080615232653.642837440@fluff.org.uk>
Cc: Jeff Garzik <jeff@garzik.org>, Ben Dooks <ben-linux@fluff.org>,
	Laurent Pinchart <laurentp@cse-semaphore.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:54107 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756471AbYFOX2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 19:28:17 -0400
Content-Disposition: inline; filename=thirdparty/dm9000-remove-2resources.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laurent Pinchart <laurentp@cse-semaphore.com>

The dm9000 driver accepts either 2 or 3 resources to describe the platform
devices. The 2 resources case abuses the ioresource mechanism by passing
ioremap()ed memory through the platform device resources. This patch removes
that case and converts boards that were using it to the 3 resources scheme.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>
Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
---

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 6bc8924..fca7831 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -528,7 +528,6 @@ dm9000_probe(struct platform_device *pdev)
 	struct board_info *db;	/* Point a board information structure */
 	struct net_device *ndev;
 	const unsigned char *mac_src;
-	unsigned long base;
 	int ret = 0;
 	int iosize;
 	int i;
@@ -561,78 +560,61 @@ dm9000_probe(struct platform_device *pdev)
 	if (pdev->num_resources < 2) {
 		ret = -ENODEV;
 		goto out;
-	} else if (pdev->num_resources == 2) {
-		base = pdev->resource[0].start;
-
-		if (!request_mem_region(base, 4, ndev->name)) {
-			ret = -EBUSY;
-			goto out;
-		}
-
-		ndev->base_addr = base;
-		ndev->irq = pdev->resource[1].start;
-		db->io_addr = (void __iomem *)base;
-		db->io_data = (void __iomem *)(base + 4);
+	}
 
-		/* ensure at least we have a default set of IO routines */
-		dm9000_set_io(db, 2);
+	db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 
-	} else {
-		db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-		db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-		db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-
-		if (db->addr_res == NULL || db->data_res == NULL ||
-		    db->irq_res == NULL) {
-			dev_err(db->dev, "insufficient resources\n");
-			ret = -ENOENT;
-			goto out;
-		}
+	if (db->addr_res == NULL || db->data_res == NULL ||
+	    db->irq_res == NULL) {
+		dev_err(db->dev, "insufficient resources\n");
+		ret = -ENOENT;
+		goto out;
+	}
 
-		i = res_size(db->addr_res);
-		db->addr_req = request_mem_region(db->addr_res->start, i,
-						  pdev->name);
+	iosize = res_size(db->addr_res);
+	db->addr_req = request_mem_region(db->addr_res->start, iosize,
+					  pdev->name);
 
-		if (db->addr_req == NULL) {
-			dev_err(db->dev, "cannot claim address reg area\n");
-			ret = -EIO;
-			goto out;
-		}
-
-		db->io_addr = ioremap(db->addr_res->start, i);
+	if (db->addr_req == NULL) {
+		dev_err(db->dev, "cannot claim address reg area\n");
+		ret = -EIO;
+		goto out;
+	}
 
-		if (db->io_addr == NULL) {
-			dev_err(db->dev, "failed to ioremap address reg\n");
-			ret = -EINVAL;
-			goto out;
-		}
+	db->io_addr = ioremap(db->addr_res->start, iosize);
 
-		iosize = res_size(db->data_res);
-		db->data_req = request_mem_region(db->data_res->start, iosize,
-						  pdev->name);
+	if (db->io_addr == NULL) {
+		dev_err(db->dev, "failed to ioremap address reg\n");
+		ret = -EINVAL;
+		goto out;
+	}
 
-		if (db->data_req == NULL) {
-			dev_err(db->dev, "cannot claim data reg area\n");
-			ret = -EIO;
-			goto out;
-		}
+	iosize = res_size(db->data_res);
+	db->data_req = request_mem_region(db->data_res->start, iosize,
+					  pdev->name);
 
-		db->io_data = ioremap(db->data_res->start, iosize);
+	if (db->data_req == NULL) {
+		dev_err(db->dev, "cannot claim data reg area\n");
+		ret = -EIO;
+		goto out;
+	}
 
-		if (db->io_data == NULL) {
-			dev_err(db->dev,"failed to ioremap data reg\n");
-			ret = -EINVAL;
-			goto out;
-		}
+	db->io_data = ioremap(db->data_res->start, iosize);
 
-		/* fill in parameters for net-dev structure */
+	if (db->io_data == NULL) {
+		dev_err(db->dev,"failed to ioremap data reg\n");
+		ret = -EINVAL;
+		goto out;
+	}
 
-		ndev->base_addr = (unsigned long)db->io_addr;
-		ndev->irq	= db->irq_res->start;
+	/* fill in parameters for net-dev structure */
+	ndev->base_addr = (unsigned long)db->io_addr;
+	ndev->irq	= db->irq_res->start;
 
-		/* ensure at least we have a default set of IO routines */
-		dm9000_set_io(db, iosize);
-	}
+	/* ensure at least we have a default set of IO routines */
+	dm9000_set_io(db, iosize);
 
 	/* check to see if anything is being over-ridden */
 	if (pdata != NULL) {

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
