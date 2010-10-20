From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH -next 1/2] ibmveth: Cleanup error handling inside
	ibmveth_open
Date: Wed, 20 Oct 2010 14:21:13 +0000
Message-ID: <20101020142113.GA1026@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rcj@linux.vnet.ibm.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:44172 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752943Ab0JTOVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Oct 2010 10:21:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated code in one place.

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/ibmveth.c |   44 ++++++++++++++++++++------------------------
 1 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index b3e157e..2ae8336 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -546,9 +546,8 @@ static int ibmveth_open(struct net_device *netdev)
 	if (!adapter->buffer_list_addr || !adapter->filter_list_addr) {
 		netdev_err(netdev, "unable to allocate filter or buffer list "
 			   "pages\n");
-		ibmveth_cleanup(adapter);
-		napi_disable(&adapter->napi);
-		return -ENOMEM;
+		rc = -ENOMEM;
+		goto err_out;
 	}
 
 	adapter->rx_queue.queue_len = sizeof(struct ibmveth_rx_q_entry) *
@@ -558,9 +557,8 @@ static int ibmveth_open(struct net_device *netdev)
 
 	if (!adapter->rx_queue.queue_addr) {
 		netdev_err(netdev, "unable to allocate rx queue pages\n");
-		ibmveth_cleanup(adapter);
-		napi_disable(&adapter->napi);
-		return -ENOMEM;
+		rc = -ENOMEM;
+		goto err_out;
 	}
 
 	dev = &adapter->vdev->dev;
@@ -578,9 +576,8 @@ static int ibmveth_open(struct net_device *netdev)
 	    (dma_mapping_error(dev, adapter->rx_queue.queue_dma))) {
 		netdev_err(netdev, "unable to map filter or buffer list "
 			   "pages\n");
-		ibmveth_cleanup(adapter);
-		napi_disable(&adapter->napi);
-		return -ENOMEM;
+		rc = -ENOMEM;
+		goto err_out;
 	}
 
 	adapter->rx_queue.index = 0;
@@ -611,9 +608,8 @@ static int ibmveth_open(struct net_device *netdev)
 				     adapter->filter_list_dma,
 				     rxq_desc.desc,
 				     mac_address);
-		ibmveth_cleanup(adapter);
-		napi_disable(&adapter->napi);
-		return -ENONET;
+		rc = -ENONET;
+		goto err_out;
 	}
 
 	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
@@ -622,9 +618,8 @@ static int ibmveth_open(struct net_device *netdev)
 		if (ibmveth_alloc_buffer_pool(&adapter->rx_buff_pool[i])) {
 			netdev_err(netdev, "unable to alloc pool\n");
 			adapter->rx_buff_pool[i].active = 0;
-			ibmveth_cleanup(adapter);
-			napi_disable(&adapter->napi);
-			return -ENOMEM ;
+			rc = -ENOMEM;
+			goto err_out;
 		}
 	}
 
@@ -638,27 +633,23 @@ static int ibmveth_open(struct net_device *netdev)
 			rc = h_free_logical_lan(adapter->vdev->unit_address);
 		} while (H_IS_LONG_BUSY(rc) || (rc == H_BUSY));
 
-		ibmveth_cleanup(adapter);
-		napi_disable(&adapter->napi);
-		return rc;
+		goto err_out;
 	}
 
 	adapter->bounce_buffer =
 	    kmalloc(netdev->mtu + IBMVETH_BUFF_OH, GFP_KERNEL);
 	if (!adapter->bounce_buffer) {
 		netdev_err(netdev, "unable to allocate bounce buffer\n");
-		ibmveth_cleanup(adapter);
-		napi_disable(&adapter->napi);
-		return -ENOMEM;
+		rc = -ENOMEM;
+		goto err_out;
 	}
 	adapter->bounce_buffer_dma =
 	    dma_map_single(&adapter->vdev->dev, adapter->bounce_buffer,
 			   netdev->mtu + IBMVETH_BUFF_OH, DMA_BIDIRECTIONAL);
 	if (dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
 		netdev_err(netdev, "unable to map bounce buffer\n");
-		ibmveth_cleanup(adapter);
-		napi_disable(&adapter->napi);
-		return -ENOMEM;
+		rc = -ENOMEM;
+		goto err_out;
 	}
 
 	netdev_dbg(netdev, "initial replenish cycle\n");
@@ -669,6 +660,11 @@ static int ibmveth_open(struct net_device *netdev)
 	netdev_dbg(netdev, "open complete\n");
 
 	return 0;
+
+err_out:
+	ibmveth_cleanup(adapter);
+	napi_disable(&adapter->napi);
+	return rc;
 }
 
 static int ibmveth_close(struct net_device *netdev)
-- 
1.7.2.2

