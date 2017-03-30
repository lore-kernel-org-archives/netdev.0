From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net 1/7] ibmvnic: Update main crq initialization and release
Date: Thu, 30 Mar 2017 02:48:54 -0400
Message-ID: <20170330064854.20309.69140.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40570 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753927AbdC3C7f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 22:59:35 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2U2sVZh031945
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 22:59:34 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29gfk28jv9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 22:59:33 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 29 Mar 2017 22:59:33 -0400
In-Reply-To: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the initialization and release routines for the crq queue so that
we validate the crq queue.

Additionally this updates the naming of the init and release routines
for the crq queue to drop the ibmvnic prefix. This matches the naming
for similar routines in the driver

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 1e8ba78..01ab60f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -113,7 +113,7 @@ static union sub_crq *ibmvnic_next_scrq(struct ibmvnic_adapter *,
 static void send_cap_queries(struct ibmvnic_adapter *adapter);
 static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter);
 static int ibmvnic_init(struct ibmvnic_adapter *);
-static void ibmvnic_release_crq_queue(struct ibmvnic_adapter *);
+static void release_crq_queue(struct ibmvnic_adapter *);
 
 struct ibmvnic_stat {
 	char name[ETH_GSTRING_LEN];
@@ -612,7 +612,7 @@ static void ibmvnic_release_resources(struct ibmvnic_adapter *adapter)
 	adapter->rx_pool = NULL;
 
 	release_sub_crqs(adapter);
-	ibmvnic_release_crq_queue(adapter);
+	release_crq_queue(adapter);
 
 	if (adapter->stats_token)
 		dma_unmap_single(dev, adapter->stats_token,
@@ -3069,12 +3069,15 @@ static int ibmvnic_reset_crq(struct ibmvnic_adapter *adapter)
 	return rc;
 }
 
-static void ibmvnic_release_crq_queue(struct ibmvnic_adapter *adapter)
+static void release_crq_queue(struct ibmvnic_adapter *adapter)
 {
 	struct ibmvnic_crq_queue *crq = &adapter->crq;
 	struct vio_dev *vdev = adapter->vdev;
 	long rc;
 
+	if (!crq->msgs)
+		return;
+
 	netdev_dbg(adapter->netdev, "Releasing CRQ\n");
 	free_irq(vdev->irq, adapter);
 	tasklet_kill(&adapter->tasklet);
@@ -3085,15 +3088,19 @@ static void ibmvnic_release_crq_queue(struct ibmvnic_adapter *adapter)
 	dma_unmap_single(&vdev->dev, crq->msg_token, PAGE_SIZE,
 			 DMA_BIDIRECTIONAL);
 	free_page((unsigned long)crq->msgs);
+	crq->msgs = NULL;
 }
 
-static int ibmvnic_init_crq_queue(struct ibmvnic_adapter *adapter)
+static int init_crq_queue(struct ibmvnic_adapter *adapter)
 {
 	struct ibmvnic_crq_queue *crq = &adapter->crq;
 	struct device *dev = &adapter->vdev->dev;
 	struct vio_dev *vdev = adapter->vdev;
 	int rc, retrc = -ENOMEM;
 
+	if (crq->msgs)
+		return 0;
+
 	crq->msgs = (union ibmvnic_crq *)get_zeroed_page(GFP_KERNEL);
 	/* Should we allocate more than one page? */
 
@@ -3155,6 +3162,7 @@ static int ibmvnic_init_crq_queue(struct ibmvnic_adapter *adapter)
 	dma_unmap_single(dev, crq->msg_token, PAGE_SIZE, DMA_BIDIRECTIONAL);
 map_failed:
 	free_page((unsigned long)crq->msgs);
+	crq->msgs = NULL;
 	return retrc;
 }
 
@@ -3222,7 +3230,7 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 	unsigned long timeout = msecs_to_jiffies(30000);
 	int rc;
 
-	rc = ibmvnic_init_crq_queue(adapter);
+	rc = init_crq_queue(adapter);
 	if (rc) {
 		dev_err(dev, "Couldn't initialize crq. rc=%d\n", rc);
 		return rc;
@@ -3232,7 +3240,7 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 				      sizeof(struct ibmvnic_statistics),
 				      DMA_FROM_DEVICE);
 	if (dma_mapping_error(dev, adapter->stats_token)) {
-		ibmvnic_release_crq_queue(adapter);
+		release_crq_queue(adapter);
 		dev_err(dev, "Couldn't map stats buffer\n");
 		return -ENOMEM;
 	}
@@ -3241,7 +3249,7 @@ static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 	ibmvnic_send_crq_init(adapter);
 	if (!wait_for_completion_timeout(&adapter->init_done, timeout)) {
 		dev_err(dev, "Initialization sequence timed out\n");
-		ibmvnic_release_crq_queue(adapter);
+		release_crq_queue(adapter);
 		return -1;
 	}
 
