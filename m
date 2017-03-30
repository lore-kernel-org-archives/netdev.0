From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net 6/7] ibmvnic: Create init/release routines for stats
 token
Date: Thu, 30 Mar 2017 02:49:23 -0400
Message-ID: <20170330064923.20309.88639.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:48247 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754450AbdC3DAC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 23:00:02 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2U2sVgd030692
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 23:00:01 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29gdaeg407-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 23:00:01 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 29 Mar 2017 23:00:00 -0400
In-Reply-To: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create an initialization and a release routine for the stats token used by
the ibmvnic driver.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   46 +++++++++++++++++++++++++++---------
 1 file changed, 34 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index f2d2f1f..a2f972d 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -302,6 +302,36 @@ static void replenish_pools(struct ibmvnic_adapter *adapter)
 	}
 }
 
+static void release_stats_token(struct ibmvnic_adapter *adapter)
+{
+	struct device *dev = &adapter->vdev->dev;
+
+	if (!adapter->stats_token)
+		return;
+
+	dma_unmap_single(dev, adapter->stats_token,
+			 sizeof(struct ibmvnic_statistics),
+			 DMA_FROM_DEVICE);
+	adapter->stats_token = 0;
+}
+
+static int init_stats_token(struct ibmvnic_adapter *adapter)
+{
+	struct device *dev = &adapter->vdev->dev;
+	dma_addr_t stok;
+
+	stok = dma_map_single(dev, &adapter->stats,
+			      sizeof(struct ibmvnic_statistics),
+			      DMA_FROM_DEVICE);
+	if (dma_mapping_error(dev, stok)) {
+		dev_err(dev, "Couldn't map stats buffer\n");
+		return -1;
+	}
+
+	adapter->stats_token = stok;
+	return 0;
+}
+
 static void release_rx_pools(struct ibmvnic_adapter *adapter)
 {
 	struct ibmvnic_rx_pool *rx_pool;
@@ -647,8 +677,6 @@ static int ibmvnic_open(struct net_device *netdev)
 
 static void ibmvnic_release_resources(struct ibmvnic_adapter *adapter)
 {
-	struct device *dev = &adapter->vdev->dev;
-
 	release_bounce_buffer(adapter);
 	release_tx_pools(adapter);
 	release_rx_pools(adapter);
@@ -656,10 +684,7 @@ static void ibmvnic_release_resources(struct ibmvnic_adapter *adapter)
 	release_sub_crqs(adapter);
 	release_crq_queue(adapter);
 
-	if (adapter->stats_token)
-		dma_unmap_single(dev, adapter->stats_token,
-				 sizeof(struct ibmvnic_statistics),
-				 DMA_FROM_DEVICE);
+	release_stats_token(adapter);
 }
 
 static int ibmvnic_close(struct net_device *netdev)
@@ -3269,13 +3294,10 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 		return rc;
 	}
 
-	adapter->stats_token = dma_map_single(dev, &adapter->stats,
-				      sizeof(struct ibmvnic_statistics),
-				      DMA_FROM_DEVICE);
-	if (dma_mapping_error(dev, adapter->stats_token)) {
+	rc = init_stats_token(adapter);
+	if (rc) {
 		release_crq_queue(adapter);
-		dev_err(dev, "Couldn't map stats buffer\n");
-		return -ENOMEM;
+		return rc;
 	}
 
 	init_completion(&adapter->init_done);
