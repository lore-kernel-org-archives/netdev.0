From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2.6.29] myri10ge: don't forget pci_disable_device()
Date: Sat, 17 Jan 2009 19:27:19 +0100
Message-ID: <49722307.4010109@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1889 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760402AbZAQS1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jan 2009 13:27:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't forget to call pci_disable_device() in myri10ge_remove()
and when myri10ge_probe() fails.

By the way, update the copyright years.

Signed-off-by: Brice Goglin <brice@myri.com>

--- linux-2.6/drivers/net/myri10ge/myri10ge.c	2009-01-06 08:05:43.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2009-01-17 00:26:48.000000000 +0100
@@ -1,7 +1,7 @@
 /*************************************************************************
  * myri10ge.c: Myricom Myri-10G Ethernet driver.
  *
- * Copyright (C) 2005 - 2007 Myricom, Inc.
+ * Copyright (C) 2005 - 2009 Myricom, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.4-1.398"
+#define MYRI10GE_VERSION_STR "1.4.4-1.401"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -3786,7 +3786,7 @@
 	if (status != 0) {
 		dev_err(&pdev->dev, "Error %d writing PCI_EXP_DEVCTL\n",
 			status);
-		goto abort_with_netdev;
+		goto abort_with_enabled;
 	}
 
 	pci_set_master(pdev);
@@ -3801,13 +3801,13 @@
 	}
 	if (status != 0) {
 		dev_err(&pdev->dev, "Error %d setting DMA mask\n", status);
-		goto abort_with_netdev;
+		goto abort_with_enabled;
 	}
 	(void)pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
 	mgp->cmd = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->cmd),
 				      &mgp->cmd_bus, GFP_KERNEL);
 	if (mgp->cmd == NULL)
-		goto abort_with_netdev;
+		goto abort_with_enabled;
 
 	mgp->board_span = pci_resource_len(pdev, 0);
 	mgp->iomem_base = pci_resource_start(pdev, 0);
@@ -3943,8 +3943,10 @@
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
 			  mgp->cmd, mgp->cmd_bus);
 
-abort_with_netdev:
+abort_with_enabled:
+	pci_disable_device(pdev);
 
+abort_with_netdev:
 	free_netdev(netdev);
 	return status;
 }
@@ -3990,6 +3992,7 @@
 			  mgp->cmd, mgp->cmd_bus);
 
 	free_netdev(netdev);
+	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 }
 


