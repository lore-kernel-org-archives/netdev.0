From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/4] myri10ge: use pci_map_page to prepare the dmatest buffer
Date: Wed, 07 Mar 2007 20:00:45 +0100
Message-ID: <45EF0BDD.8070304@myri.com>
References: <45EF0B6C.9070005@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1951 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992482AbXCGTCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 14:02:53 -0500
In-Reply-To: <45EF0B6C.9070005@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allocate a specific page and use pci_map_page for dma test instead
of relying on another existing buffer.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-03-07 08:51:47.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-03-07 08:51:54.000000000 +0100
@@ -717,6 +717,8 @@
 	int status;
 	size_t bytes;
 	u32 len;
+	struct page *dmatest_page;
+	dma_addr_t dmatest_bus;
 
 	/* try to send a reset command to the card to see if it
 	 * is alive */
@@ -726,6 +728,11 @@
 		dev_err(&mgp->pdev->dev, "failed reset\n");
 		return -ENXIO;
 	}
+	dmatest_page = alloc_page(GFP_KERNEL);
+	if (!dmatest_page)
+		return -ENOMEM;
+	dmatest_bus = pci_map_page(mgp->pdev, dmatest_page, 0, PAGE_SIZE,
+				   DMA_BIDIRECTIONAL);
 
 	/* Now exchange information about interrupts  */
 
@@ -764,8 +771,8 @@
 
 	len = mgp->tx.boundary;
 
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->rx_done.bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->rx_done.bus);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
 	cmd.data2 = len * 0x10000;
 	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
 	if (status == 0)
@@ -774,8 +781,8 @@
 	else
 		dev_warn(&mgp->pdev->dev, "DMA read benchmark failed: %d\n",
 			 status);
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->rx_done.bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->rx_done.bus);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
 	cmd.data2 = len * 0x1;
 	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
 	if (status == 0)
@@ -785,8 +792,8 @@
 		dev_warn(&mgp->pdev->dev, "DMA write benchmark failed: %d\n",
 			 status);
 
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(mgp->rx_done.bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(mgp->rx_done.bus);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
 	cmd.data2 = len * 0x10001;
 	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
 	if (status == 0)
@@ -796,6 +803,9 @@
 		dev_warn(&mgp->pdev->dev,
 			 "DMA read/write benchmark failed: %d\n", status);
 
+	pci_unmap_page(mgp->pdev, dmatest_bus, PAGE_SIZE, DMA_BIDIRECTIONAL);
+	put_page(dmatest_page);
+
 	memset(mgp->rx_done.entry, 0, bytes);
 
 	/* reset mcp/driver shared state back to 0 */


