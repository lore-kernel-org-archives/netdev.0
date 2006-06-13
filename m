From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH] DM9000 - better checks for platform resources
Date: Tue, 13 Jun 2006 23:47:19 +0100
Message-ID: <20060613224719.GA26724@home.fluff.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-84-9-203-241.bulldogdsl.com ([84.9.203.241]:28310 "EHLO
	aeryn.fluff.org.uk") by vger.kernel.org with ESMTP id S1750919AbWFMWrU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 18:47:20 -0400
Received: from ben by aeryn.fluff.org.uk with local (Exim 3.36 #1 (Debian))
	id 1FqHfL-0006xN-00
	for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 23:47:19 +0100
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The current DM9000 driver cannot cope if it
is given more than 3 resources (for example, if
it is being passed an wake-up irq that it is
not using yet).

Check that we have been given at-least one IRQ
resource.

Also fix the minor type-casting for the case
of 2 resources.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dm9k-resource-clean.patch"

--- ../linux-2.6.17/linux-2.6.17-rc5/drivers/net/dm9000.c	2006-03-20 05:53:29.000000000 +0000
+++ linux-2.6.16-simtec2/drivers/net/dm9000.c	2006-05-22 21:46:18.000000000 +0100
@@ -410,10 +410,7 @@ dm9000_probe(struct platform_device *pde
 	if (pdev->num_resources < 2) {
 		ret = -ENODEV;
 		goto out;
-	}
-
-	switch (pdev->num_resources) {
-	case 2:
+	} else if (pdev->num_resources == 2) {
 		base = pdev->resource[0].start;
 
 		if (!request_mem_region(base, 4, ndev->name)) {
@@ -423,17 +420,16 @@ dm9000_probe(struct platform_device *pde
 
 		ndev->base_addr = base;
 		ndev->irq = pdev->resource[1].start;
-		db->io_addr = (void *)base;
-		db->io_data = (void *)(base + 4);
-
-		break;
+		db->io_addr = (void __iomem *)base;
+		db->io_data = (void __iomem *)(base + 4);
 
-	case 3:
+	} else {
 		db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 		db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 		db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 
-		if (db->addr_res == NULL || db->data_res == NULL) {
+		if (db->addr_res == NULL || db->data_res == NULL ||
+		    db->irq_res == NULL) {
 			printk(KERN_ERR PFX "insufficient resources\n");
 			ret = -ENOENT;
 			goto out;
@@ -482,7 +478,6 @@ dm9000_probe(struct platform_device *pde
 
 		/* ensure at least we have a default set of IO routines */
 		dm9000_set_io(db, iosize);
-
 	}
 
 	/* check to see if anything is being over-ridden */

--W/nzBZO5zC0uMSeA--
