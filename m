From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [PATCH] ibmveth: Fix alignment of rx queue bug
Date: Tue, 04 Sep 2012 19:41:37 -0500
Message-ID: <50469FC1.2000202@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netmon2.ecnet.ec ([157.100.45.15]:42145 "EHLO uio2.ecua.net.ec"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751560Ab2IEBPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 21:15:20 -0400
Received: from [192.168.2.100] (unknown [186.4.150.130])
	by uio2.ecua.net.ec (Postfix) with ESMTP id 8479810456E
	for <netdev@vger.kernel.org>; Tue,  4 Sep 2012 19:38:30 -0500 (ECT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug found by Nish Aravamudan 
(https://lkml.org/lkml/2012/5/15/220) where the driver is not following
the spec (it is not aligning the rx buffer on a 16-byte boundary) and the
hypervisor aborts the registration, making the device unusable. 

The fix follows BenH's recommendation (https://lkml.org/lkml/2012/7/20/461)
to replace the kmalloc+map for a single call to dma_alloc_coherent()
because that function always aligns to a 16-byte boundary.

The stable trees will run into this bug whenever the rx buffer kmalloc call
returns something not aligned on a 16-byte boundary.

Cc: <stable@vger.kernel.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---
 ibmveth.c |   26 +++++++++-----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

--- a/drivers/net/ethernet/ibm/ibmveth.c	2012-07-09 16:00:53.000000000 -0400
+++ b/drivers/net/ethernet/ibm/ibmveth.c	2012-08-17 19:51:02.840000188 -0400
@@ -472,14 +472,9 @@ static void ibmveth_cleanup(struct ibmve
 	}
 
 	if (adapter->rx_queue.queue_addr != NULL) {
-		if (!dma_mapping_error(dev, adapter->rx_queue.queue_dma)) {
-			dma_unmap_single(dev,
-					adapter->rx_queue.queue_dma,
-					adapter->rx_queue.queue_len,
-					DMA_BIDIRECTIONAL);
-			adapter->rx_queue.queue_dma = DMA_ERROR_CODE;
-		}
-		kfree(adapter->rx_queue.queue_addr);
+		dma_free_coherent(dev, adapter->rx_queue.queue_len,
+				  adapter->rx_queue.queue_addr,
+				  adapter->rx_queue.queue_dma);
 		adapter->rx_queue.queue_addr = NULL;
 	}
 
@@ -556,10 +551,13 @@ static int ibmveth_open(struct net_devic
 		goto err_out;
 	}
 
+	dev = &adapter->vdev->dev;
+
 	adapter->rx_queue.queue_len = sizeof(struct ibmveth_rx_q_entry) *
 						rxq_entries;
-	adapter->rx_queue.queue_addr = kmalloc(adapter->rx_queue.queue_len,
-						GFP_KERNEL);
+	adapter->rx_queue.queue_addr =
+	    dma_alloc_coherent(dev, adapter->rx_queue.queue_len,
+			       &adapter->rx_queue.queue_dma, GFP_KERNEL);
 
 	if (!adapter->rx_queue.queue_addr) {
 		netdev_err(netdev, "unable to allocate rx queue pages\n");
@@ -567,19 +565,13 @@ static int ibmveth_open(struct net_devic
 		goto err_out;
 	}
 
-	dev = &adapter->vdev->dev;
-
 	adapter->buffer_list_dma = dma_map_single(dev,
 			adapter->buffer_list_addr, 4096, DMA_BIDIRECTIONAL);
 	adapter->filter_list_dma = dma_map_single(dev,
 			adapter->filter_list_addr, 4096, DMA_BIDIRECTIONAL);
-	adapter->rx_queue.queue_dma = dma_map_single(dev,
-			adapter->rx_queue.queue_addr,
-			adapter->rx_queue.queue_len, DMA_BIDIRECTIONAL);
 
 	if ((dma_mapping_error(dev, adapter->buffer_list_dma)) ||
-	    (dma_mapping_error(dev, adapter->filter_list_dma)) ||
-	    (dma_mapping_error(dev, adapter->rx_queue.queue_dma))) {
+	    (dma_mapping_error(dev, adapter->filter_list_dma))) {
 		netdev_err(netdev, "unable to map filter or buffer list "
 			   "pages\n");
 		rc = -ENOMEM;
