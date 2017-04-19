From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/10] ibmvnic: Remove unused bouce buffer
Date: Wed, 19 Apr 2017 13:45:22 -0400
Message-ID: <20170419174522.37372.8560.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46287 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934640AbdDSN4Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 09:56:25 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JDrhmm045100
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:56:24 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29x760xmbe-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:56:24 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 19 Apr 2017 09:56:23 -0400
In-Reply-To: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bounce buffer is not used in the ibmvnic driver, just
get rid of it.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   53 ------------------------------------
 drivers/net/ethernet/ibm/ibmvnic.h |    4 ---
 2 files changed, 57 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 221d652..e8c72ab 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -502,50 +502,6 @@ static int init_tx_pools(struct net_device *netdev)
 	return 0;
 }
 
-static void release_bounce_buffer(struct ibmvnic_adapter *adapter)
-{
-	struct device *dev = &adapter->vdev->dev;
-
-	if (!adapter->bounce_buffer)
-		return;
-
-	if (!dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
-		dma_unmap_single(dev, adapter->bounce_buffer_dma,
-				 adapter->bounce_buffer_size,
-				 DMA_BIDIRECTIONAL);
-		adapter->bounce_buffer_dma = DMA_ERROR_CODE;
-	}
-
-	kfree(adapter->bounce_buffer);
-	adapter->bounce_buffer = NULL;
-}
-
-static int init_bounce_buffer(struct net_device *netdev)
-{
-	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
-	struct device *dev = &adapter->vdev->dev;
-	char *buf;
-	int buf_sz;
-	dma_addr_t map_addr;
-
-	buf_sz = (netdev->mtu + ETH_HLEN - 1) / PAGE_SIZE + 1;
-	buf = kmalloc(adapter->bounce_buffer_size, GFP_KERNEL);
-	if (!buf)
-		return -1;
-
-	map_addr = dma_map_single(dev, buf, buf_sz, DMA_TO_DEVICE);
-	if (dma_mapping_error(dev, map_addr)) {
-		dev_err(dev, "Couldn't map bounce buffer\n");
-		kfree(buf);
-		return -1;
-	}
-
-	adapter->bounce_buffer = buf;
-	adapter->bounce_buffer_size = buf_sz;
-	adapter->bounce_buffer_dma = map_addr;
-	return 0;
-}
-
 static void release_error_buffers(struct ibmvnic_adapter *adapter)
 {
 	struct device *dev = &adapter->vdev->dev;
@@ -597,7 +553,6 @@ static int ibmvnic_login(struct net_device *netdev)
 
 static void release_resources(struct ibmvnic_adapter *adapter)
 {
-	release_bounce_buffer(adapter);
 	release_tx_pools(adapter);
 	release_rx_pools(adapter);
 
@@ -656,10 +611,6 @@ static int ibmvnic_open(struct net_device *netdev)
 	if (rc)
 		goto ibmvnic_open_fail;
 
-	rc = init_bounce_buffer(netdev);
-	if (rc)
-		goto ibmvnic_open_fail;
-
 	replenish_pools(adapter);
 
 	/* We're ready to receive frames, enable the sub-crq interrupts and
@@ -880,7 +831,6 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int tx_bytes = 0;
 	dma_addr_t data_dma_addr;
 	struct netdev_queue *txq;
-	bool used_bounce = false;
 	unsigned long lpar_rc;
 	union sub_crq tx_crq;
 	unsigned int offset;
@@ -921,7 +871,6 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	tx_buff->index = index;
 	tx_buff->pool_index = queue_num;
 	tx_buff->last_frag = true;
-	tx_buff->used_bounce = used_bounce;
 
 	memset(&tx_crq, 0, sizeof(tx_crq));
 	tx_crq.v1.first = IBMVNIC_CRQ_CMD;
@@ -1517,7 +1466,6 @@ static int ibmvnic_complete_tx(struct ibmvnic_adapter *adapter,
 					continue;
 
 				txbuff->data_dma[j] = 0;
-				txbuff->used_bounce = false;
 			}
 			/* if sub_crq was sent indirectly */
 			first = txbuff->indir_arr[0].generic.first;
@@ -3343,7 +3291,6 @@ static unsigned long ibmvnic_get_desired_dma(struct vio_dev *vdev)
 	adapter = netdev_priv(netdev);
 
 	ret += PAGE_SIZE; /* the crq message queue */
-	ret += adapter->bounce_buffer_size;
 	ret += IOMMU_PAGE_ALIGN(sizeof(struct ibmvnic_statistics), tbl);
 
 	for (i = 0; i < adapter->req_tx_queues + adapter->req_rx_queues; i++)
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 8fbe05d..355225c 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -868,7 +868,6 @@ struct ibmvnic_tx_buff {
 	int index;
 	int pool_index;
 	bool last_frag;
-	bool used_bounce;
 	union sub_crq indir_arr[6];
 	u8 hdr_data[140];
 	dma_addr_t indir_dma;
@@ -924,9 +923,6 @@ struct ibmvnic_adapter {
 	dma_addr_t ip_offload_ctrl_tok;
 	bool migrated;
 	u32 msg_enable;
-	void *bounce_buffer;
-	int bounce_buffer_size;
-	dma_addr_t bounce_buffer_dma;
 
 	/* Statistics */
 	struct ibmvnic_statistics stats;
