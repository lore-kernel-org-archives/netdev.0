From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net 4/4] ibmvnic: Correct ibmvnic handling of device open/close
Date: Fri, 17 Mar 2017 17:13:43 -0500
Message-ID: <1489788823-20980-5-git-send-email-jallen@linux.vnet.ibm.com>
References: <1489788823-20980-1-git-send-email-jallen@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:47335 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751096AbdCRBpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 21:45:02 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2HM92XB141537
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 18:14:10 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
        by mx0a-001b2d01.pphosted.com with ESMTP id 297yvckdsp-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 18:14:10 -0400
Received: from localhost
        by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Fri, 17 Mar 2017 16:14:09 -0600
In-Reply-To: <1489788823-20980-1-git-send-email-jallen@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When closing the ibmvnic device we need to release the resources used
in communicating to the virtual I/O server. These need to be
re-negotiated with the server at open time.

This patch moves the releasing of resources a separate routine
and updates the open and close handlers to release all resources at
close and re-negotiate and allocate these resources at open.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 114 +++++++++++++++++++++----------------
 drivers/net/ethernet/ibm/ibmvnic.h |   1 +
 2 files changed, 67 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index f8cc572..3d73182 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -113,6 +113,8 @@ static void send_request_unmap(struct ibmvnic_adapter *, u8);
 static void send_login(struct ibmvnic_adapter *adapter);
 static void send_cap_queries(struct ibmvnic_adapter *adapter);
 static int init_sub_crq_irqs(struct ibmvnic_adapter *adapter);
+static int ibmvnic_init(struct ibmvnic_adapter *);
+static void ibmvnic_release_crq_queue(struct ibmvnic_adapter *);
 
 struct ibmvnic_stat {
 	char name[ETH_GSTRING_LEN];
@@ -415,6 +417,12 @@ static int ibmvnic_open(struct net_device *netdev)
 	int rc = 0;
 	int i, j;
 
+	if (adapter->is_closed) {
+		rc = ibmvnic_init(adapter);
+		if (rc)
+			return rc;
+	}
+
 	rc = ibmvnic_login(netdev);
 	if (rc)
 		return rc;
@@ -525,6 +533,7 @@ static int ibmvnic_open(struct net_device *netdev)
 	ibmvnic_send_crq(adapter, &crq);
 
 	netif_tx_start_all_queues(netdev);
+	adapter->is_closed = false;
 
 	return 0;
 
@@ -564,21 +573,12 @@ static int ibmvnic_open(struct net_device *netdev)
 	return -ENOMEM;
 }
 
-static int ibmvnic_close(struct net_device *netdev)
+static void ibmvnic_release_resources(struct ibmvnic_adapter *adapter)
 {
-	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 	struct device *dev = &adapter->vdev->dev;
-	union ibmvnic_crq crq;
+	int tx_scrqs, rx_scrqs;
 	int i;
 
-	adapter->closing = true;
-
-	for (i = 0; i < adapter->req_rx_queues; i++)
-		napi_disable(&adapter->napi[i]);
-
-	if (!adapter->failover)
-		netif_tx_stop_all_queues(netdev);
-
 	if (adapter->bounce_buffer) {
 		if (!dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
 			dma_unmap_single(&adapter->vdev->dev,
@@ -591,33 +591,70 @@ static int ibmvnic_close(struct net_device *netdev)
 		adapter->bounce_buffer = NULL;
 	}
 
-	memset(&crq, 0, sizeof(crq));
-	crq.logical_link_state.first = IBMVNIC_CRQ_CMD;
-	crq.logical_link_state.cmd = LOGICAL_LINK_STATE;
-	crq.logical_link_state.link_state = IBMVNIC_LOGICAL_LNK_DN;
-	ibmvnic_send_crq(adapter, &crq);
+	tx_scrqs = be32_to_cpu(adapter->login_rsp_buf->num_txsubm_subcrqs);
+	for (i = 0; i < tx_scrqs; i++) {
+		struct ibmvnic_tx_pool *tx_pool = &adapter->tx_pool[i];
 
-	for (i = 0; i < be32_to_cpu(adapter->login_rsp_buf->num_txsubm_subcrqs);
-	     i++) {
-		kfree(adapter->tx_pool[i].tx_buff);
-		free_long_term_buff(adapter,
-				    &adapter->tx_pool[i].long_term_buff);
-		kfree(adapter->tx_pool[i].free_map);
+		kfree(tx_pool->tx_buff);
+		free_long_term_buff(adapter, &tx_pool->long_term_buff);
+		kfree(tx_pool->free_map);
 	}
 	kfree(adapter->tx_pool);
 	adapter->tx_pool = NULL;
 
-	for (i = 0; i < be32_to_cpu(adapter->login_rsp_buf->num_rxadd_subcrqs);
-	     i++) {
-		free_rx_pool(adapter, &adapter->rx_pool[i]);
-		free_long_term_buff(adapter,
-				    &adapter->rx_pool[i].long_term_buff);
+	rx_scrqs = be32_to_cpu(adapter->login_rsp_buf->num_rxadd_subcrqs);
+	for (i = 0; i < rx_scrqs; i++) {
+		struct ibmvnic_rx_pool *rx_pool = &adapter->rx_pool[i];
+
+		free_rx_pool(adapter, rx_pool);
+		free_long_term_buff(adapter, &rx_pool->long_term_buff);
 	}
 	kfree(adapter->rx_pool);
 	adapter->rx_pool = NULL;
 
-	adapter->closing = false;
+	release_sub_crqs(adapter);
+	ibmvnic_release_crq_queue(adapter);
+
+	if (adapter->debugfs_dir && !IS_ERR(adapter->debugfs_dir))
+		debugfs_remove_recursive(adapter->debugfs_dir);
+
+	if (adapter->stats_token)
+		dma_unmap_single(dev, adapter->stats_token,
+				 sizeof(struct ibmvnic_statistics),
+				 DMA_FROM_DEVICE);
+
+	if (adapter->ras_comps)
+		dma_free_coherent(dev, adapter->ras_comp_num *
+				  sizeof(struct ibmvnic_fw_component),
+				  adapter->ras_comps, adapter->ras_comps_tok);
+
+	kfree(adapter->ras_comp_int);
+}
+
+static int ibmvnic_close(struct net_device *netdev)
+{
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
+	union ibmvnic_crq crq;
+	int i;
+
+	adapter->closing = true;
+
+	for (i = 0; i < adapter->req_rx_queues; i++)
+		napi_disable(&adapter->napi[i]);
+
+	if (!adapter->failover)
+		netif_tx_stop_all_queues(netdev);
 
+	memset(&crq, 0, sizeof(crq));
+	crq.logical_link_state.first = IBMVNIC_CRQ_CMD;
+	crq.logical_link_state.cmd = LOGICAL_LINK_STATE;
+	crq.logical_link_state.link_state = IBMVNIC_LOGICAL_LNK_DN;
+	ibmvnic_send_crq(adapter, &crq);
+
+	ibmvnic_release_resources(adapter);
+
+	adapter->is_closed = true;
+	adapter->closing = false;
 	return 0;
 }
 
@@ -3893,6 +3930,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	}
 
 	netdev->mtu = adapter->req_mtu - ETH_HLEN;
+	adapter->is_closed = false;
 
 	rc = register_netdev(netdev);
 	if (rc) {
@@ -3908,28 +3946,8 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 static int ibmvnic_remove(struct vio_dev *dev)
 {
 	struct net_device *netdev = dev_get_drvdata(&dev->dev);
-	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
-
-	release_sub_crqs(adapter);
-
-	ibmvnic_release_crq_queue(adapter);
-
-	if (adapter->debugfs_dir && !IS_ERR(adapter->debugfs_dir))
-		debugfs_remove_recursive(adapter->debugfs_dir);
-
-	dma_unmap_single(&dev->dev, adapter->stats_token,
-			 sizeof(struct ibmvnic_statistics), DMA_FROM_DEVICE);
-
-	if (adapter->ras_comps)
-		dma_free_coherent(&dev->dev,
-				  adapter->ras_comp_num *
-				  sizeof(struct ibmvnic_fw_component),
-				  adapter->ras_comps, adapter->ras_comps_tok);
-
-	kfree(adapter->ras_comp_int);
-
 	free_netdev(netdev);
 	dev_set_drvdata(&dev->dev, NULL);
 
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 1993b42..10ad259 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -1052,4 +1052,5 @@ struct ibmvnic_adapter {
 	struct work_struct ibmvnic_xport;
 	struct tasklet_struct tasklet;
 	bool failover;
+	bool is_closed;
 };
-- 
2.7.4
