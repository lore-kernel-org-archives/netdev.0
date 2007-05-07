From: Brice Goglin <brice@myri.com>
Subject: [PATCH 5/6] myri10ge: move the DMA test code into its own function
Date: Mon, 07 May 2007 23:51:45 +0200
Message-ID: <463F9F71.7000305@myri.com>
References: <463F9E9E.8000808@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1954 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S967014AbXEGVvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 17:51:47 -0400
In-Reply-To: <463F9E9E.8000808@ens-lyon.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the DMA test code into its own function.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  121 ++++++++++++++++++++++------------------
 1 file changed, 68 insertions(+), 53 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2007-05-07 23:21:45.000000000 +0200
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2007-05-07 23:21:52.000000000 +0200
@@ -719,14 +719,78 @@
 		       mgp->dev->name);
 }
 
-static int myri10ge_reset(struct myri10ge_priv *mgp)
+static int myri10ge_dma_test(struct myri10ge_priv *mgp, int test_type)
 {
 	struct myri10ge_cmd cmd;
 	int status;
-	size_t bytes;
 	u32 len;
 	struct page *dmatest_page;
 	dma_addr_t dmatest_bus;
+	char *test = " ";
+
+	dmatest_page = alloc_page(GFP_KERNEL);
+	if (!dmatest_page)
+		return -ENOMEM;
+	dmatest_bus = pci_map_page(mgp->pdev, dmatest_page, 0, PAGE_SIZE,
+				   DMA_BIDIRECTIONAL);
+
+	/* Run a small DMA test.
+	 * The magic multipliers to the length tell the firmware
+	 * to do DMA read, write, or read+write tests.  The
+	 * results are returned in cmd.data0.  The upper 16
+	 * bits or the return is the number of transfers completed.
+	 * The lower 16 bits is the time in 0.5us ticks that the
+	 * transfers took to complete.
+	 */
+
+	len = mgp->tx.boundary;
+
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
+	cmd.data2 = len * 0x10000;
+	status = myri10ge_send_cmd(mgp, test_type, &cmd, 0);
+	if (status != 0) {
+		test = "read";
+		goto abort;
+	}
+	mgp->read_dma = ((cmd.data0 >> 16) * len * 2) / (cmd.data0 & 0xffff);
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
+	cmd.data2 = len * 0x1;
+	status = myri10ge_send_cmd(mgp, test_type, &cmd, 0);
+	if (status != 0) {
+		test = "write";
+		goto abort;
+	}
+	mgp->write_dma = ((cmd.data0 >> 16) * len * 2) / (cmd.data0 & 0xffff);
+
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
+	cmd.data2 = len * 0x10001;
+	status = myri10ge_send_cmd(mgp, test_type, &cmd, 0);
+	if (status != 0) {
+		test = "read/write";
+		goto abort;
+	}
+	mgp->read_write_dma = ((cmd.data0 >> 16) * len * 2 * 2) /
+	    (cmd.data0 & 0xffff);
+
+abort:
+	pci_unmap_page(mgp->pdev, dmatest_bus, PAGE_SIZE, DMA_BIDIRECTIONAL);
+	put_page(dmatest_page);
+
+	if (status != 0 && test_type != MXGEFW_CMD_UNALIGNED_TEST)
+		dev_warn(&mgp->pdev->dev, "DMA %s benchmark failed: %d\n",
+			 test, status);
+
+	return status;
+}
+
+static int myri10ge_reset(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_cmd cmd;
+	int status;
+	size_t bytes;
 
 	/* try to send a reset command to the card to see if it
 	 * is alive */
@@ -736,11 +800,8 @@
 		dev_err(&mgp->pdev->dev, "failed reset\n");
 		return -ENXIO;
 	}
-	dmatest_page = alloc_page(GFP_KERNEL);
-	if (!dmatest_page)
-		return -ENOMEM;
-	dmatest_bus = pci_map_page(mgp->pdev, dmatest_page, 0, PAGE_SIZE,
-				   DMA_BIDIRECTIONAL);
+
+	(void)myri10ge_dma_test(mgp, MXGEFW_DMA_TEST);
 
 	/* Now exchange information about interrupts  */
 
@@ -768,52 +829,6 @@
 	}
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
 
-	/* Run a small DMA test.
-	 * The magic multipliers to the length tell the firmware
-	 * to do DMA read, write, or read+write tests.  The
-	 * results are returned in cmd.data0.  The upper 16
-	 * bits or the return is the number of transfers completed.
-	 * The lower 16 bits is the time in 0.5us ticks that the
-	 * transfers took to complete.
-	 */
-
-	len = mgp->tx.boundary;
-
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
-	cmd.data2 = len * 0x10000;
-	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
-	if (status == 0)
-		mgp->read_dma = ((cmd.data0 >> 16) * len * 2) /
-		    (cmd.data0 & 0xffff);
-	else
-		dev_warn(&mgp->pdev->dev, "DMA read benchmark failed: %d\n",
-			 status);
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
-	cmd.data2 = len * 0x1;
-	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
-	if (status == 0)
-		mgp->write_dma = ((cmd.data0 >> 16) * len * 2) /
-		    (cmd.data0 & 0xffff);
-	else
-		dev_warn(&mgp->pdev->dev, "DMA write benchmark failed: %d\n",
-			 status);
-
-	cmd.data0 = MYRI10GE_LOWPART_TO_U32(dmatest_bus);
-	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(dmatest_bus);
-	cmd.data2 = len * 0x10001;
-	status = myri10ge_send_cmd(mgp, MXGEFW_DMA_TEST, &cmd, 0);
-	if (status == 0)
-		mgp->read_write_dma = ((cmd.data0 >> 16) * len * 2 * 2) /
-		    (cmd.data0 & 0xffff);
-	else
-		dev_warn(&mgp->pdev->dev,
-			 "DMA read/write benchmark failed: %d\n", status);
-
-	pci_unmap_page(mgp->pdev, dmatest_bus, PAGE_SIZE, DMA_BIDIRECTIONAL);
-	put_page(dmatest_page);
-
 	memset(mgp->rx_done.entry, 0, bytes);
 
 	/* reset mcp/driver shared state back to 0 */


