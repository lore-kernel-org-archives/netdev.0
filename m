From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -net-2.6] ll_temac: Fix missing iounmaps
Date: Tue, 6 Jul 2010 07:44:20 +0000
Message-ID: <20100706074420.GA15451@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.linn@xilinx.com, brian.hill@xilinx.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:48975 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835Ab0GFHoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jul 2010 03:44:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix missing iounmaps.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/ll_temac_main.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 52dcc84..6474c49 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -964,7 +964,7 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 	np = of_parse_phandle(op->dev.of_node, "llink-connected", 0);
 	if (!np) {
 		dev_err(&op->dev, "could not find DMA node\n");
-		goto nodev;
+		goto err_iounmap;
 	}
 
 	/* Setup the DMA register accesses, could be DCR or memory mapped */
@@ -978,7 +978,7 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 			dev_dbg(&op->dev, "MEM base: %p\n", lp->sdma_regs);
 		} else {
 			dev_err(&op->dev, "unable to map DMA registers\n");
-			goto nodev;
+			goto err_iounmap;
 		}
 	}
 
@@ -987,7 +987,7 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 	if ((lp->rx_irq == NO_IRQ) || (lp->tx_irq == NO_IRQ)) {
 		dev_err(&op->dev, "could not determine irqs\n");
 		rc = -ENOMEM;
-		goto nodev;
+		goto err_iounmap_2;
 	}
 
 	of_node_put(np); /* Finished with the DMA node; drop the reference */
@@ -997,7 +997,7 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 	if ((!addr) || (size != 6)) {
 		dev_err(&op->dev, "could not find MAC address\n");
 		rc = -ENODEV;
-		goto nodev;
+		goto err_iounmap_2;
 	}
 	temac_set_mac_address(ndev, (void *)addr);
 
@@ -1013,7 +1013,7 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 	rc = sysfs_create_group(&lp->dev->kobj, &temac_attr_group);
 	if (rc) {
 		dev_err(lp->dev, "Error creating sysfs files\n");
-		goto nodev;
+		goto err_iounmap_2;
 	}
 
 	rc = register_netdev(lp->ndev);
@@ -1026,6 +1026,11 @@ temac_of_probe(struct of_device *op, const struct of_device_id *match)
 
  err_register_ndev:
 	sysfs_remove_group(&lp->dev->kobj, &temac_attr_group);
+ err_iounmap_2:
+	if (lp->sdma_regs)
+		iounmap(lp->sdma_regs);
+ err_iounmap:
+	iounmap(lp->regs);
  nodev:
 	free_netdev(ndev);
 	ndev = NULL;
@@ -1044,6 +1049,9 @@ static int __devexit temac_of_remove(struct of_device *op)
 		of_node_put(lp->phy_node);
 	lp->phy_node = NULL;
 	dev_set_drvdata(&op->dev, NULL);
+	iounmap(lp->regs);
+	if (lp->sdma_regs)
+		iounmap(lp->sdma_regs);
 	free_netdev(ndev);
 	return 0;
 }
-- 
1.6.4.4

