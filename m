From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net 2/7] ibmvnic: Create init and release routines for the
 bounce buffer
Date: Thu, 30 Mar 2017 02:49:00 -0400
Message-ID: <20170330064900.20309.56576.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:58443 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754233AbdC3C7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 22:59:40 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2U2sVnu121484
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 22:59:39 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29gdwgpr7b-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 22:59:38 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 29 Mar 2017 22:59:37 -0400
In-Reply-To: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the handling of initialization and releasing the bounce buffer to their
own init and release routines.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   77 +++++++++++++++++++++++-------------
 1 file changed, 50 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 01ab60f..c3e5305 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -372,6 +372,50 @@ static void free_rx_pool(struct ibmvnic_adapter *adapter,
 	pool->rx_buff = NULL;
 }
 
+static void release_bounce_buffer(struct ibmvnic_adapter *adapter)
+{
+	struct device *dev = &adapter->vdev->dev;
+
+	if (!adapter->bounce_buffer)
+		return;
+
+	if (!dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
+		dma_unmap_single(dev, adapter->bounce_buffer_dma,
+				 adapter->bounce_buffer_size,
+				 DMA_BIDIRECTIONAL);
+		adapter->bounce_buffer_dma = DMA_ERROR_CODE;
+	}
+
+	kfree(adapter->bounce_buffer);
+	adapter->bounce_buffer = NULL;
+}
+
+static int init_bounce_buffer(struct net_device *netdev)
+{
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+	struct device *dev = &adapter->vdev->dev;
+	char *buf;
+	int buf_sz;
+	dma_addr_t map_addr;
+
+	buf_sz = (netdev->mtu + ETH_HLEN - 1) / PAGE_SIZE + 1;
+	buf = kmalloc(adapter->bounce_buffer_size, GFP_KERNEL);
+	if (!buf)
+		return -1;
+
+	map_addr = dma_map_single(dev, buf, buf_sz, DMA_TO_DEVICE);
+	if (dma_mapping_error(dev, map_addr)) {
+		dev_err(dev, "Couldn't map bounce buffer\n");
+		kfree(buf);
+		return -1;
+	}
+
+	adapter->bounce_buffer = buf;
+	adapter->bounce_buffer_size = buf_sz;
+	adapter->bounce_buffer_dma = map_addr;
+	return 0;
+}
+
 static int ibmvnic_login(struct net_device *netdev)
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
@@ -500,20 +544,11 @@ static int ibmvnic_open(struct net_device *netdev)
 		tx_pool->consumer_index = 0;
 		tx_pool->producer_index = 0;
 	}
-	adapter->bounce_buffer_size =
-	    (netdev->mtu + ETH_HLEN - 1) / PAGE_SIZE + 1;
-	adapter->bounce_buffer = kmalloc(adapter->bounce_buffer_size,
-					 GFP_KERNEL);
-	if (!adapter->bounce_buffer)
-		goto bounce_alloc_failed;
 
-	adapter->bounce_buffer_dma = dma_map_single(dev, adapter->bounce_buffer,
-						    adapter->bounce_buffer_size,
-						    DMA_TO_DEVICE);
-	if (dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
-		dev_err(dev, "Couldn't map tx bounce buffer\n");
-		goto bounce_map_failed;
-	}
+	rc = init_bounce_buffer(netdev);
+	if (rc)
+		goto bounce_init_failed;
+
 	replenish_pools(adapter);
 
 	/* We're ready to receive frames, enable the sub-crq interrupts and
@@ -536,9 +571,7 @@ static int ibmvnic_open(struct net_device *netdev)
 
 	return 0;
 
-bounce_map_failed:
-	kfree(adapter->bounce_buffer);
-bounce_alloc_failed:
+bounce_init_failed:
 	i = tx_subcrqs - 1;
 	kfree(adapter->tx_pool[i].free_map);
 tx_fm_alloc_failed:
@@ -578,17 +611,7 @@ static void ibmvnic_release_resources(struct ibmvnic_adapter *adapter)
 	int tx_scrqs, rx_scrqs;
 	int i;
 
-	if (adapter->bounce_buffer) {
-		if (!dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
-			dma_unmap_single(&adapter->vdev->dev,
-					 adapter->bounce_buffer_dma,
-					 adapter->bounce_buffer_size,
-					 DMA_BIDIRECTIONAL);
-			adapter->bounce_buffer_dma = DMA_ERROR_CODE;
-		}
-		kfree(adapter->bounce_buffer);
-		adapter->bounce_buffer = NULL;
-	}
+	release_bounce_buffer(adapter);
 
 	tx_scrqs = be32_to_cpu(adapter->login_rsp_buf->num_txsubm_subcrqs);
 	for (i = 0; i < tx_scrqs; i++) {
